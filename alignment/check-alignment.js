#!/usr/bin/env node
/**
 * Platform alignment verification script.
 *
 * Compares template skeleton metadata, local dev env resources,
 * and downstream service repos to ensure they are in sync.
 */
const fs = require('fs');
const path = require('path');

const rootDir = path.resolve(__dirname, '..');
const resolveFromRoot = (target) => path.resolve(rootDir, target);

const configPath = path.join(__dirname, 'config.json');
if (!fs.existsSync(configPath)) {
  console.error(`Missing config file at ${configPath}`);
  process.exit(1);
}
const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));

const yamlModulePath = path.join(resolveFromRoot(config.backstageApp), 'node_modules', 'js-yaml');
let yaml;
try {
  // eslint-disable-next-line import/no-dynamic-require, global-require
  yaml = require(yamlModulePath);
} catch (error) {
  console.error('Unable to load js-yaml. Run `yarn install` in the Backstage app first.');
  console.error(error.message);
  process.exit(1);
}

const report = [];
let failures = 0;

const record = (name, status, details = '') => {
  if (status === 'fail') {
    failures += 1;
  }
  report.push({ name, status, details });
};

const loadYaml = (filePath) => {
  try {
    const content = fs.readFileSync(filePath, 'utf8');
    return yaml.load(content);
  } catch (error) {
    throw new Error(`Failed to read YAML at ${filePath}: ${error.message}`);
  }
};

const loadPom = (pomPath) => {
  const xml = fs.readFileSync(pomPath, 'utf8');
  const props = {};
  const propsMatch = xml.match(/<properties>([\s\S]*?)<\/properties>/i);
  if (propsMatch) {
    const inner = propsMatch[1];
    const propRegex = /<([\w.\-]+)>([\s\S]*?)<\/\1>/g;
    let match = propRegex.exec(inner);
    while (match) {
      props[match[1]] = match[2].trim();
      match = propRegex.exec(inner);
    }
  }
  return { path: pomPath, xml, props };
};

const resolveVersion = (raw, props) => {
  if (!raw) {
    return null;
  }
  const trimmed = raw.trim();
  const varMatch = trimmed.match(/^\$\{(.+)\}$/);
  if (varMatch) {
    const key = varMatch[1];
    return props[key] || trimmed;
  }
  return trimmed;
};

const findDependencyVersion = (pom, artifactId) => {
  const needle = `<artifactId>${artifactId}</artifactId>`;
  const artifactIndex = pom.xml.indexOf(needle);
  if (artifactIndex === -1) {
    return null;
  }
  const blockEnd = pom.xml.indexOf('</dependency>', artifactIndex);
  if (blockEnd === -1) {
    return null;
  }
  const block = pom.xml.slice(artifactIndex, blockEnd);
  const versionMatch = block.match(/<version>([^<]+)<\/version>/i);
  if (!versionMatch) {
    return null;
  }
  return resolveVersion(versionMatch[1], pom.props);
};

const templatePom = loadPom(path.join(resolveFromRoot(config.templateRoot), 'skeleton', 'pom.xml'));
const libsPom = loadPom(
  path.join(resolveFromRoot(config.platformLibraries), 'hms-common-lib', 'pom.xml'),
);

const versionComparisons = [
  {
    label: 'Permit SDK version parity',
    templateArtifact: 'permit-sdk-java',
    libArtifact: 'permit-sdk-java',
  },
  {
    label: 'Flowable version parity',
    templateArtifact: 'flowable-spring-boot-starter',
    libArtifact: 'flowable-engine',
  },
  {
    label: 'Logstash encoder version parity',
    templateArtifact: 'logstash-logback-encoder',
    libArtifact: 'logstash-logback-encoder',
  },
];

versionComparisons.forEach((check) => {
  const templateVersion = findDependencyVersion(templatePom, check.templateArtifact);
  const libVersion = findDependencyVersion(libsPom, check.libArtifact);
  if (!templateVersion || !libVersion) {
    record(
      check.label,
      'fail',
      `Unable to locate versions for template=${templateVersion} lib=${libVersion}`,
    );
    return;
  }
  if (templateVersion !== libVersion) {
    record(
      check.label,
      'fail',
      `Template ${templateVersion} vs platform lib ${libVersion}`,
    );
  } else {
    record(check.label, 'pass', `Version ${templateVersion}`);
  }
});

const localDevEnvPath = resolveFromRoot(config.localDevEnv);
const postgresSqlPath = path.join(localDevEnvPath, 'postgres', 'init', '01-create-databases.sql');
const postgresSql = fs.readFileSync(postgresSqlPath, 'utf8');
const postgresDbMatches = [...postgresSql.matchAll(/CREATE DATABASE ([\w-]+);/gi)];
const postgresDbs = new Set(postgresDbMatches.map((match) => match[1]));

const kongConfigPath = path.join(localDevEnvPath, 'kong', 'kong.yml');
const kongConfig = loadYaml(kongConfigPath);
const kongServiceNames = new Set((kongConfig.services || []).map((svc) => svc.name));

const kumaDir = path.join(localDevEnvPath, 'kuma', 'dataplanes');

config.services.forEach((service) => {
  const servicePath = resolveFromRoot(service.path);
  const catalogPath = path.join(servicePath, 'catalog-info.yaml');
  const catalog = loadYaml(catalogPath);
  const dependsOn = new Set(catalog?.spec?.dependsOn || []);
  const expectedDeps = new Set([
    'api:default/scalekit',
    `resource:default/postgres-${service.postgresDb}`,
  ]);
  if (service.pattern === 'event-driven-workflow' && service.flowableKafkaTopic) {
    expectedDeps.add(`resource:default/kafka-${service.flowableKafkaTopic}`);
  }
  if (service.pattern === 'cqrs-read-projector') {
    expectedDeps.add(`resource:default/redis-hms-cache`);
  }

  const missingDeps = [...expectedDeps].filter((dep) => !dependsOn.has(dep));
  if (missingDeps.length) {
    record(
      `Catalog dependencies: ${service.name}`,
      'fail',
      `Missing ${missingDeps.join(', ')}`,
    );
  } else {
    record(`Catalog dependencies: ${service.name}`, 'pass');
  }

  if (!postgresDbs.has(service.postgresDb)) {
    record(
      `Postgres DB provisioned: ${service.name}`,
      'fail',
      `Database ${service.postgresDb} not found in local env SQL`,
    );
  } else {
    record(`Postgres DB provisioned: ${service.name}`, 'pass');
  }

  if (!kongServiceNames.has(service.name)) {
    record(
      `Kong route registered: ${service.name}`,
      'fail',
      'Service missing from kong/kong.yml',
    );
  } else {
    record(`Kong route registered: ${service.name}`, 'pass');
  }

  const dataplanePath = path.join(kumaDir, `${service.name}.yaml`);
  if (!fs.existsSync(dataplanePath)) {
    record(`Kuma dataplane present: ${service.name}`, 'fail', 'Missing dataplane file');
  } else {
    const dp = loadYaml(dataplanePath);
    if (dp?.networking?.address === service.name) {
      record(`Kuma dataplane present: ${service.name}`, 'pass');
    } else {
      record(
        `Kuma dataplane present: ${service.name}`,
        'fail',
        `Unexpected address ${dp?.networking?.address}`,
      );
    }
  }
});

const resultsPath = path.join(__dirname, 'check-results.json');
const summary = {
  generatedAt: new Date().toISOString(),
  checks: report,
};
fs.writeFileSync(resultsPath, `${JSON.stringify(summary, null, 2)}\n`);

report.forEach((entry) => {
  const prefix = entry.status === 'pass' ? '✔' : '✖';
  console.log(`${prefix} ${entry.name}${entry.details ? ` – ${entry.details}` : ''}`);
});

if (failures > 0) {
  console.error(`Alignment check failed with ${failures} issue(s). See ${resultsPath}.`);
  process.exit(1);
}

console.log(`All alignment checks passed. Detailed results written to ${resultsPath}.`);

