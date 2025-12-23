# Database Migrations

This directory contains Flyway migrations for the platform.

## Migration Naming Convention

- `V<version>__<description>.sql` - Versioned migrations
- `V000__create_core_schema.sql` - Core schema (runs first)
- `V001__initial_schema.sql` - Module schemas (conditional)
- `V002__add_compliance_fields.sql` - Compliance fields (optional)

## Schema Scaffolding Templates

When scaffolding new modules, use these templates:

### 1. Create Schema Template
- **File**: `V001__create_schema.sql.template`
- **Usage**: Creates a new schema with RLS policies
- **Parameters**:
  - `schemaName`: PostgreSQL schema name
  - `includeComplianceFields`: Boolean flag for compliance fields

### 2. Add Compliance Fields Template
- **File**: `V002__add_compliance_fields.sql.template`
- **Usage**: Adds DPDP/HIPAA compliance fields to existing tables
- **Parameters**:
  - `schemaName`: PostgreSQL schema name
  - `includeComplianceFields`: Boolean flag

## Key Requirements

### 1. Tenant Isolation
- All tables MUST have `tenant_id UUID NOT NULL`
- RLS policies MUST reference `app.current_tenant`
- Core Kernel's `MultiTenantConnectionProvider` sets this variable

### 2. Audit Columns
- All tables MUST have:
  - `created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP`
  - `updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP`
  - `created_by UUID`
  - `updated_by UUID`

### 3. RLS Policies
- All tenant tables MUST have RLS enabled
- Policies MUST use `current_setting('app.current_tenant', true)`
- System bypass policy for migrations (restrict in production)

### 4. No Cross-Schema Foreign Keys
- Use soft references (UUIDs) instead
- Validate at application service layer
- No `FOREIGN KEY` constraints across schemas

### 5. Compliance Fields (Optional)
- `encryption_key_id VARCHAR(255)`
- `data_sovereignty_tag VARCHAR(100)`
- `consent_ref UUID`

## Example Migration

```sql
-- Create schema
CREATE SCHEMA IF NOT EXISTS clinical;

-- Create table with tenant isolation
CREATE TABLE clinical.patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- ... other columns
);

-- Enable RLS
ALTER TABLE clinical.patients ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY tenant_isolation_policy ON clinical.patients
    FOR ALL
    USING (tenant_id::text = current_setting('app.current_tenant', true))
    WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
```

## Running Migrations

```bash
# Run all migrations
mvn flyway:migrate

# Validate migrations
mvn flyway:validate

# Info about migrations
mvn flyway:info
```

## Core Kernel Integration

The Core Kernel's `MultiTenantConnectionProvider` sets these session variables before any query:

```java
stmt.execute("SET app.current_tenant = '" + tenantId + "'");
stmt.execute("SET app.current_user = '" + userId + "'");
```

RLS policies use these variables to enforce tenant isolation.

---

**Important**: Never bypass RLS in production. All queries must go through Core Kernel's tenant context.

