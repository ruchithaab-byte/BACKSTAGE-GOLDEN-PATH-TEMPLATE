# Backstage Template Enhancement Roadmap: Monorepo Support

## Overview

This document outlines the specific enhancements needed to align the Backstage Golden Path template with the proposed `hims-platform/` monorepo structure.

---

## Phase 1: Monorepo Bootstrap Template (Priority: High)

### Goal
Create a new template that scaffolds the entire monorepo structure on first use.

### Template Name
`hims-platform-monorepo-template`

### Structure to Scaffold
```
hims-platform/
├── .github/workflows/          # CI/CD workflows
├── docs/                       # Documentation structure
├── contracts/                  # Shared contracts
├── infra/                      # Infrastructure as code
├── backend-monolith/           # Spring Modulith application
├── analytics-worker/           # FastAPI worker
├── frontend/                   # Next.js UI
├── scripts/                    # Dev/CI helper scripts
├── docker-compose.yml          # Local orchestration
└── README.md
```

### Template Parameters
```yaml
parameters:
  - title: Monorepo Setup
    properties:
      platformName:
        title: Platform Name
        type: string
        default: hims-platform
      description:
        title: Platform Description
        type: string
      owner:
        title: Owner
        type: string
        ui:field: OwnerPicker
      system:
        title: System
        type: string
        ui:field: EntityPicker
  
  - title: Initial Modules
    properties:
      includeClinicalModule:
        title: Include Clinical Module
        type: boolean
        default: true
      includeBillingModule:
        title: Include Billing Module
        type: boolean
        default: true
      includeInventoryModule:
        title: Include Inventory Module
        type: boolean
        default: false
```

### Implementation Checklist
- [ ] Create `hims-platform-monorepo-template/template.yaml`
- [ ] Create `hims-platform-monorepo-template/skeleton/` with full monorepo structure
- [ ] Add Nunjucks conditionals for optional modules
- [ ] Scaffold initial `contracts/` structure
- [ ] Scaffold `docs/adr/` with initial ADR
- [ ] Scaffold `infra/docker/` and `infra/k8s/` directories
- [ ] Create `docker-compose.yml` template
- [ ] Test end-to-end scaffolding

---

## Phase 2: Enhanced Module Template (Priority: High)

### Goal
Enhance the existing `spring-boot-saas-service` template to support adding modules to an existing monorepo.

### New Pattern: `modular-monolith-module`

### Template Parameters Addition
```yaml
servicePattern:
  enum:
    - modular-monolith-module      # NEW
    - standalone-microservice      # Existing
    - saas-backend-for-frontend    # Existing
    - event-driven-workflow        # Existing
    - cqrs-read-projector         # Existing

# New dependencies block
dependencies:
  servicePattern:
    oneOf:
      - properties:
          servicePattern: { enum: ['modular-monolith-module'] }
          moduleName:
            title: Module Name
            type: string
            description: Business domain name (e.g., clinical, billing)
            pattern: '^[a-z][a-z0-9]*$'
          isFirstModule:
            title: Is this the first module?
            type: boolean
            default: false
            description: If true, scaffolds core/ directory
          targetMonorepo:
            title: Target Monorepo (optional)
            type: string
            description: GitHub URL of existing monorepo (for documentation)
            ui:help: Leave empty if creating standalone module
```

### Skeleton Structure Changes

**Current Structure** (standalone service):
```
skeleton/src/main/java/com/hms/servicename/
├── controller/
├── service/
└── repository/
```

**New Structure** (modular monolith module):
```
skeleton/src/main/java/com/hms/
├── {% if values.isFirstModule %}core/{% endif %}
│   ├── auth/
│   │   ├── JwtTokenValidator.java
│   │   └── SecurityFilterChain.java
│   ├── tenant/
│   │   ├── TenantContext.java
│   │   ├── TenantIdentifierResolver.java
│   │   └── MultiTenantConnectionProvider.java
│   ├── audit/
│   │   ├── LogAudit.java
│   │   └── AuditAspect.java
│   ├── config/
│   │   ├── FeatureFlagsConfig.java
│   │   └── ModuleWiringConfig.java
│   └── infra/
│       ├── Clock.java
│       └── IdGenerator.java
└── modules/
    └── {{ values.moduleName }}/
        ├── api/
        │   ├── dto/
        │   │   └── {{ values.moduleName | capitalize }}Dto.java
        │   ├── event/
        │   │   └── {{ values.moduleName | capitalize }}Event.java
        │   └── spi/
        │       └── {{ values.moduleName | capitalize }}Provider.java
        └── internal/
            ├── domain/
            │   └── {{ values.moduleName | capitalize }}Entity.java
            ├── repo/
            │   └── {{ values.moduleName | capitalize }}Repository.java
            ├── service/
            │   └── {{ values.moduleName | capitalize }}Service.java
            ├── web/
            │   └── {{ values.moduleName | capitalize }}Controller.java
            ├── listeners/
            │   └── {% if values.includeKafkaConsumer %}{{ values.moduleName | capitalize }}EventListener.java{% endif %}
            └── mapper/
                └── {{ values.moduleName | capitalize }}Mapper.java
```

### Implementation Checklist
- [ ] Add `modular-monolith-module` to `template.yaml` enum
- [ ] Create dependencies block for module pattern
- [ ] Update skeleton Java package structure
- [ ] Add conditional `core/` directory scaffolding
- [ ] Update `pom.xml` to support Spring Modulith dependencies
- [ ] Add `module-info.java` for Spring Modulith (if needed)
- [ ] Test module scaffolding

---

## Phase 3: Contracts Scaffolding (Priority: Medium)

### Goal
Scaffold versioned contract files (OpenAPI, events) for new services/modules.

### New Template Parameters
```yaml
- title: Contract Configuration
  properties:
    contractsVersion:
      title: Initial API Version
      type: string
      default: v1
      pattern: '^v\d+$'
      ui:help: Version format: v1, v2, etc.
    includeOpenApiSpec:
      title: Generate OpenAPI Specification
      type: boolean
      default: true
    includeEventSchemas:
      title: Generate Event Schemas
      type: boolean
      default: false
      ui:help: Enable if service publishes/consumes Kafka events
```

### Skeleton Structure
```
skeleton/contracts/
├── openapi/
│   └── {{ values.serviceName }}/
│       └── {{ values.contractsVersion }}/
│           └── api.yaml
└── events/
    └── {% if values.includeEventSchemas %}{{ values.serviceName }}-events/
        └── {{ values.contractsVersion }}/
            └── events.yaml{% endif %}
```

### OpenAPI Template (`api.yaml`)
```yaml
openapi: 3.0.3
info:
  title: {{ values.serviceName | replace('-', ' ') | title }} API
  version: {{ values.contractsVersion }}
  description: API specification for {{ values.serviceName }}
servers:
  - url: http://localhost:{{ values.servicePort | default(8080) }}
    description: Local development
paths:
  /health:
    get:
      summary: Health check endpoint
      responses:
        '200':
          description: Service is healthy
```

### Event Schema Template (`events.yaml`)
```yaml
asyncapi: 2.6.0
info:
  title: {{ values.serviceName }} Events
  version: {{ values.contractsVersion }}
channels:
  {% if values.includeKafkaConsumer %}
  {{ values.kafkaTopicName }}:
    subscribe:
      message:
        $ref: '#/components/messages/{{ values.serviceName }}Event'
  {% endif %}
components:
  messages:
    {{ values.serviceName }}Event:
      payload:
        type: object
        properties:
          eventId:
            type: string
          timestamp:
            type: string
            format: date-time
```

### Implementation Checklist
- [ ] Add contract parameters to `template.yaml`
- [ ] Create `skeleton/contracts/` directory structure
- [ ] Create OpenAPI template (`api.yaml`)
- [ ] Create AsyncAPI template (`events.yaml`)
- [ ] Add Nunjucks conditionals for optional contracts
- [ ] Test contract generation

---

## Phase 4: Documentation Scaffolding (Priority: Medium)

### Goal
Scaffold initial documentation structure (ADRs, runbooks, API docs).

### Skeleton Structure
```
skeleton/docs/
├── adr/
│   └── 0001-initial-scaffolding.md
├── runbooks/
│   └── README.md
├── api/
│   └── README.md
└── hld/
    └── README.md
```

### ADR Template (`0001-initial-scaffolding.md`)
```markdown
# ADR-0001: Initial Service Scaffolding

## Status
Accepted

## Context
This service was scaffolded using the Backstage Golden Path template on {{ "now" | date }}.

## Decision
- Service Pattern: {{ values.servicePattern }}
- Technology Stack: Spring Boot 3.2, Java 17
{% if values.includeFlowable %}- Workflow Engine: Flowable 7.x{% endif %}
{% if values.includeKafkaConsumer %}- Event Streaming: Kafka{% endif %}
{% if values.includeRedis %}- Cache: Redis{% endif %}

## Consequences
- Positive: Follows organization's Golden Path patterns
- Negative: None identified

## Notes
- Initial scaffolding; ADRs should be added as architecture evolves
```

### Runbooks README Template
```markdown
# Runbooks

This directory contains operational runbooks for {{ values.serviceName }}.

## Structure
- `incident-response.md` - General incident response procedures
- `backup-restore.md` - Backup and restore procedures
- `scaling.md` - Horizontal scaling procedures

## On-Call
- Primary: [TBD]
- Secondary: [TBD]

## Quick Links
- [Service Dashboard](https://grafana.example.com/d/{{ values.serviceName }})
- [Logs](https://logs.example.com/{{ values.serviceName }})
- [Metrics](https://prometheus.example.com/{{ values.serviceName }})
```

### Implementation Checklist
- [ ] Create `skeleton/docs/` directory structure
- [ ] Create ADR template with Nunjucks variables
- [ ] Create runbooks README template
- [ ] Create API docs README template
- [ ] Test documentation generation

---

## Phase 5: Architectural Enforcement (Priority: Low)

### Goal
Scaffold ArchUnit rules to enforce module boundaries in modular monolith.

### Skeleton Structure
```
skeleton/src/test/java/com/hims/arch/
└── ModuleBoundaryRules.java
```

### ArchUnit Rules Template
```java
package com.hims.arch;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;
import org.junit.jupiter.api.Test;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.*;

public class ModuleBoundaryRules {

    private static final JavaClasses classes = 
        new ClassFileImporter().importPackages("com.hims");

    @Test
    void modulesShouldNotImportInternalPackages() {
        ArchRule rule = noClasses()
            .that().resideInAPackage("..modules..api..")
            .should().dependOnClassesThat()
            .resideInAPackage("..modules..internal..");
        
        rule.check(classes);
    }

    @Test
    void modulesShouldOnlyAccessOtherModulesViaApi() {
        ArchRule rule = classes()
            .that().resideInAPackage("..modules..internal..")
            .should().onlyDependOnClassesThat()
            .resideInAnyPackage(
                "..modules..api..",
                "..core..",
                "java..",
                "org.springframework.."
            );
        
        rule.check(classes);
    }

    @Test
    void coreShouldNotDependOnModules() {
        ArchRule rule = noClasses()
            .that().resideInAPackage("..core..")
            .should().dependOnClassesThat()
            .resideInAPackage("..modules..");
        
        rule.check(classes);
    }
}
```

### pom.xml Dependency Addition
```xml
{% if values.servicePattern == 'modular-monolith-module' %}
<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5</artifactId>
    <version>1.2.1</version>
    <scope>test</scope>
</dependency>
{% endif %}
```

### Implementation Checklist
- [ ] Create `skeleton/src/test/java/com/hims/arch/` directory
- [ ] Create `ModuleBoundaryRules.java` template
- [ ] Add ArchUnit dependency to `pom.xml` (conditional)
- [ ] Test ArchUnit rules generation

---

## Phase 6: Integration Testing (Priority: High)

### Goal
Test all enhancements end-to-end with real scenarios.

### Test Scenarios

#### Scenario 1: Monorepo Bootstrap
1. Execute `hims-platform-monorepo-template`
2. Verify complete monorepo structure
3. Verify all three services (backend, worker, frontend)
4. Verify `docker-compose.yml` works
5. Verify CI/CD workflows

#### Scenario 2: Add Module to Monorepo
1. Execute `spring-boot-saas-service` template with `modular-monolith-module` pattern
2. Verify module structure in `backend-monolith/modules/`
3. Verify contracts in `contracts/`
4. Verify documentation in `docs/`
5. Verify ArchUnit rules

#### Scenario 3: Standalone Microservice
1. Execute `spring-boot-saas-service` template with `standalone-microservice` pattern
2. Verify standalone structure (not monorepo)
3. Verify all patterns work (BFF, Flowable, Outbox, CQRS)

### Implementation Checklist
- [ ] Create test scenarios document
- [ ] Execute Scenario 1 (monorepo bootstrap)
- [ ] Execute Scenario 2 (add module)
- [ ] Execute Scenario 3 (standalone service)
- [ ] Document any issues
- [ ] Fix issues and re-test

---

## Summary

### Priority Order
1. **Phase 1**: Monorepo Bootstrap Template (enables full monorepo workflow)
2. **Phase 2**: Enhanced Module Template (enables adding modules)
3. **Phase 6**: Integration Testing (validates everything works)
4. **Phase 3**: Contracts Scaffolding (improves contract management)
5. **Phase 4**: Documentation Scaffolding (improves documentation)
6. **Phase 5**: Architectural Enforcement (nice-to-have)

### Estimated Effort
- Phase 1: 2-3 days
- Phase 2: 1-2 days
- Phase 3: 1 day
- Phase 4: 0.5 days
- Phase 5: 0.5 days
- Phase 6: 1-2 days

**Total**: ~6-9 days

### Dependencies
- Phase 1 can be done independently
- Phase 2 depends on Phase 1 (for testing)
- Phase 3-5 can be done in parallel
- Phase 6 depends on all previous phases

---

## Next Steps

1. **Review this roadmap** with the team
2. **Prioritize phases** based on business needs
3. **Assign ownership** for each phase
4. **Create GitHub issues** for tracking
5. **Begin Phase 1** implementation

