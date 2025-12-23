# Module Template Guide

## Overview

This guide explains how to scaffold new modules using the Spring Modulith module template.

## Module Structure

Each module follows this structure:

```
modules/<moduleName>/
├── api/                    # Public API (other modules can depend on this)
│   ├── dto/               # Data Transfer Objects
│   ├── event/             # Domain events
│   └── spi/               # Service Provider Interfaces
└── internal/              # Private implementation
    ├── domain/            # JPA entities
    ├── repo/              # JPA repositories
    ├── service/            # Business logic (implements API)
    ├── web/                # REST controllers
    └── listener/          # Kafka event listeners
```

## Key Rules

### 1. API Package is Public
- Other modules CAN depend on `api` packages
- Other modules CANNOT depend on `internal` packages
- API packages define contracts, not implementations

### 2. Internal Package is Private
- Only the module itself can access `internal` packages
- Controllers, services, repositories are all internal
- Domain entities are internal

### 3. Core Kernel Integration
- Modules MUST use Core Kernel for:
  - Tenant context (`TenantContext`)
  - Audit logging (`@LogAudit`)
  - Event publishing (`EventPublisher`)
  - Configuration (`FeatureFlags`, `EnvironmentConfig`)

### 4. Schema Per Module
- Each module has its own PostgreSQL schema
- Schema name matches module name (e.g., `clinical`, `billing`)
- RLS policies enforce tenant isolation
- No cross-schema foreign keys

## Scaffolding a Module

### Step 1: Use Template

The module template requires:
- `moduleName`: Module name (e.g., `clinical`, `billing`)
- `schemaName`: PostgreSQL schema name (usually same as moduleName)
- `includeComplianceFields`: Boolean flag for compliance fields

### Step 2: Generated Files

The template generates:
1. **API Package**:
   - `api/dto/` - DTOs (placeholder)
   - `api/event/` - Domain events (placeholder)
   - `api/spi/` - Service Provider Interface

2. **Internal Package**:
   - `internal/domain/` - JPA entity (placeholder)
   - `internal/repo/` - JPA repository (placeholder)
   - `internal/service/` - Service implementation (wired to Core Kernel)
   - `internal/web/` - REST controller (placeholder)
   - `internal/listener/` - Kafka listener (placeholder)

3. **Schema Migration**:
   - `V003__create_<moduleName>_schema.sql` - Schema and tables

4. **Architecture Tests**:
   - `ModuleArchitectureTest.java` - ArchUnit rules

### Step 3: Customize

1. **Replace Placeholders**:
   - Replace `{{ values.moduleName }}_entities` with actual table names
   - Replace placeholder DTOs with actual DTOs
   - Replace placeholder service methods with actual logic

2. **Add Business Logic**:
   - Implement service methods
   - Add domain entities
   - Add repositories
   - Add controllers

3. **Add Schema Tables**:
   - Use schema scaffolding templates
   - Add actual tables (not just example_table)
   - Ensure RLS policies are correct

## Core Kernel Integration

### Tenant Context

```java
import com.hims.core.tenant.TenantContext;

String tenantId = TenantContext.getTenantId();
String userId = TenantContext.getUserId();
```

### Audit Logging

```java
import com.hims.core.audit.LogAudit;

@LogAudit(
    action = "CREATE_PATIENT",
    resourceType = "PATIENT",
    description = "Create patient"
)
public void createPatient(PatientDto dto) {
    // Business logic
}
```

### Event Publishing

```java
import com.hims.core.events.EventPublisher;
import com.hims.core.events.EventMetadata;

eventPublisher.publish(
    "patient.created",
    Map.of("id", patientId),
    EventMetadata.create()
        .withTenant(TenantContext.getTenantId())
        .withUser(TenantContext.getUserId())
        .build()
);
```

## Architecture Rules

### ArchUnit Tests

Each module includes ArchUnit tests that enforce:

1. **API Cannot Depend on Internal**:
   ```java
   noClasses()
       .that().resideInAPackage("api..")
       .should().dependOnClassesThat()
       .resideInAPackage("internal..");
   ```

2. **Internal Cannot Depend on Other Modules' Internal**:
   ```java
   noClasses()
       .that().resideInAPackage("internal..")
       .should().dependOnClassesThat()
       .resideInAnyPackage("com.hims.modules.clinical.internal..");
   ```

3. **Services Must Implement API Interface**:
   ```java
   classes()
       .that().resideInAPackage("internal.service..")
       .should().implement(ServiceProvider.class);
   ```

## Schema Integration

### Schema Migration

Each module generates a schema migration:
- Creates schema (if not exists)
- Creates tables with tenant isolation
- Enables RLS policies
- Creates indexes
- Sets up triggers for audit columns

### RLS Policies

All tables use this pattern:
```sql
CREATE POLICY tenant_isolation_policy ON schema.table_name
    FOR ALL
    USING (tenant_id::text = current_setting('app.current_tenant', true))
    WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
```

## Common Patterns

### Cross-Module Communication

**✅ CORRECT**: Use API interfaces
```java
// In billing module
@Autowired
private ClinicalServiceProvider clinicalService;  // From clinical.api.spi
```

**❌ WRONG**: Access internal packages
```java
// DON'T DO THIS
import com.hims.modules.clinical.internal.service.ClinicalService;
```

### Event Publishing

**✅ CORRECT**: Publish via Core Kernel
```java
eventPublisher.publish("patient.created", data, metadata);
```

**❌ WRONG**: Direct Kafka access
```java
// DON'T DO THIS
kafkaTemplate.send("patient-events", data);
```

## Validation Checklist

Before committing a module:

- [ ] Module structure follows api/internal pattern
- [ ] Service implements API interface
- [ ] Controller uses DTOs (not domain entities)
- [ ] Schema migration includes RLS policies
- [ ] ArchUnit tests pass
- [ ] Core Kernel integration (tenant, audit, events)
- [ ] No cross-module internal dependencies
- [ ] No business logic in templates (only structure)

---

**Remember**: Module templates are about structure, not features. Add business logic after scaffolding.

