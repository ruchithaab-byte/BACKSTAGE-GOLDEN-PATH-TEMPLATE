# Template Usage Guide

## Overview

This guide explains **which template to use when** and **how to use them correctly**.

---

## Template Catalog

### 1. Monorepo Bootstrap Template

**Location**: `hims-platform-monorepo-template/`

**When to Use**:
- Creating a new HIMS Platform instance
- Setting up a new project
- Initial platform scaffolding

**What It Creates**:
- Complete monorepo structure
- Backend monolith (Spring Boot + Spring Modulith)
- Analytics worker (FastAPI)
- Frontend (Next.js)
- Infrastructure (Docker, K8s, Terraform)
- Core schema (tenants, users)

**Usage**:
1. Go to Backstage → Create Component
2. Select "HIMS Platform Monorepo"
3. Fill in wizard (platform name, modules, database)
4. Click Create

**Output**: Complete platform ready for module development

---

### 2. Module Template

**Location**: `hims-platform-monorepo-template/skeleton/backend-monolith/src/main/java/com/hims/modules/`

**When to Use**:
- Adding a new business module to existing platform
- Creating clinical, billing, inventory, etc. modules
- After monorepo is already scaffolded

**What It Creates**:
- Module structure (api/ and internal/ packages)
- Service Provider Interface
- Service implementation (wired to Core Kernel)
- REST controller placeholder
- Kafka listener placeholder
- Schema migration template
- ArchUnit tests

**Usage**:
1. Use schema scaffolding template to generate migration
2. Copy module structure to `modules/<moduleName>/`
3. Customize placeholders with actual business logic
4. Run migration: `mvn flyway:migrate`

**Output**: New module ready for business logic implementation

---

### 3. Schema Scaffolding Templates

**Location**: `db/migration/V001__create_schema.sql.template`

**When to Use**:
- Creating a new schema for a module
- Adding tables to existing schema
- Generating compliant, tenant-safe schemas

**What It Creates**:
- Schema creation SQL
- Table definitions with tenant isolation
- RLS policies
- Audit triggers
- Compliance fields (optional)

**Usage**:
1. Process template with Nunjucks
2. Replace placeholders (table names, columns)
3. Add to `db/migration/` directory
4. Run: `mvn flyway:migrate`

**Output**: Flyway migration with RLS and compliance

---

## Decision Tree

### "I want to create a new platform"
→ Use **Monorepo Bootstrap Template**

### "I want to add a new module to existing platform"
→ Use **Module Template** + **Schema Scaffolding Template**

### "I want to add tables to an existing module"
→ Use **Schema Scaffolding Template** only

### "I want to add business logic"
→ **No template needed** - Add code to existing module structure

---

## Common Workflows

### Workflow 1: New Platform Setup

```
1. Use Monorepo Bootstrap Template
   → Creates complete platform structure

2. Start infrastructure
   → docker-compose up -d postgres redis kafka

3. Run core migrations
   → mvn flyway:migrate (in backend-monolith)

4. Start backend
   → mvn spring-boot:run

5. Platform is ready for modules
```

### Workflow 2: Add New Module

```
1. Use Module Template
   → Creates module structure

2. Use Schema Scaffolding Template
   → Generates schema migration

3. Customize placeholders
   → Replace example_table, add business logic

4. Run migration
   → mvn flyway:migrate

5. Implement business logic
   → Add to service, controller, etc.

6. Module is ready
```

### Workflow 3: Add Tables to Module

```
1. Use Schema Scaffolding Template
   → Generate new migration

2. Customize table definition
   → Replace placeholders

3. Add to db/migration/
   → Follow naming: V<version>__<description>.sql

4. Run migration
   → mvn flyway:migrate

5. Update JPA entities
   → Add to internal/domain/

6. Tables are ready
```

---

## Where to Put Business Logic

### ✅ CORRECT Locations

**Service Layer**:
```
modules/<moduleName>/internal/service/
```
- Business logic goes here
- Implements API interface
- Uses Core Kernel (tenant, audit, events)

**Domain Layer**:
```
modules/<moduleName>/internal/domain/
```
- JPA entities
- Domain models
- Business rules (if needed)

**Controller Layer**:
```
modules/<moduleName>/internal/web/
```
- REST endpoints
- Request/response handling
- Uses DTOs (not domain entities)

### ❌ WRONG Locations

**Core Kernel**:
```
core/
```
- ❌ No business logic here
- ❌ No domain knowledge
- ✅ Infrastructure only

**API Package**:
```
modules/<moduleName>/api/
```
- ❌ No business logic here
- ✅ Contracts only (DTOs, interfaces, events)

---

## Template Parameters Reference

### Monorepo Bootstrap

**Required**:
- `platformName`: Platform name (kebab-case)
- `description`: Platform description
- `owner`: Backstage group owner
- `system`: Backstage system
- `postgresDbName`: PostgreSQL database name
- `repoUrl`: Git repository URL

**Optional**:
- `includeClinicalModule`: Include clinical module (default: true)
- `includeBillingModule`: Include billing module (default: true)
- `includeInventoryModule`: Include inventory module (default: false)
- `includeComplianceFields`: Include compliance fields (default: true)

### Module Template

**Required**:
- `moduleName`: Module name (e.g., clinical, billing)
- `schemaName`: PostgreSQL schema name (usually same as moduleName)

**Optional**:
- `includeComplianceFields`: Include compliance fields (default: true)
- `platformName`: Platform name (for Kafka consumer group)

### Schema Scaffolding

**Required**:
- `schemaName`: PostgreSQL schema name

**Optional**:
- `includeComplianceFields`: Include compliance fields (default: true)

---

## Validation Checklist

Before using a template:

- [ ] Understand what the template creates
- [ ] Know where to put business logic (after scaffolding)
- [ ] Have database credentials ready
- [ ] Have Git repository URL ready
- [ ] Understand module boundaries

After scaffolding:

- [ ] Generated code compiles
- [ ] Migrations run successfully
- [ ] Application starts
- [ ] ArchUnit tests pass
- [ ] Documentation is clear

---

## Troubleshooting

### "Template execution failed"
- Check all required parameters are provided
- Verify Nunjucks syntax is correct
- Check file permissions

### "Migration fails"
- Verify database connection
- Check schema name is correct
- Ensure core schema exists first

### "ArchUnit tests fail"
- Check module boundaries are correct
- Verify API/internal separation
- Ensure no cross-module internal dependencies

### "Application won't start"
- Check Core Kernel is present
- Verify tenant context is set
- Check database migrations ran

---

## Getting Help

- **Documentation**: See `docs/` directory
- **Examples**: See phase summaries (PHASE_1_X_SUMMARY.md)
- **Architecture**: See CORE_KERNEL_SCOPE.md
- **Schema**: See SCHEMA_SCAFFOLDING_GUIDE.md
- **Modules**: See MODULE_TEMPLATE_GUIDE.md

---

**Remember**: Templates create structure, not features. Add business logic after scaffolding.

