# Schema Scaffolding Guide

## Overview

This guide explains how to use the schema scaffolding templates to generate Flyway migrations with RLS, compliance fields, and tenant isolation.

## Template Files

### 1. `V001__create_schema.sql.template`

Creates a new schema with:
- Schema creation
- Example table with tenant isolation
- RLS policies
- Audit triggers
- Compliance fields (optional)

### 2. `V002__add_compliance_fields.sql.template`

Adds compliance fields to existing tables:
- `encryption_key_id`
- `data_sovereignty_tag`
- `consent_ref`

## Usage

### Step 1: Configure Template Parameters

In `template.yaml`, add schema configuration:

```yaml
schemaName:
  title: Schema Name
  type: string
  description: PostgreSQL schema name (e.g., clinical, billing)
  
includeComplianceFields:
  title: Include Compliance Fields
  type: boolean
  default: true
  description: Include DPDP/HIPAA compliance fields
```

### Step 2: Process Template

Use Nunjucks to process the template:

```bash
# Example: Generate clinical schema migration
nunjucks V001__create_schema.sql.template \
  --schemaName=clinical \
  --includeComplianceFields=true \
  > V003__create_clinical_schema.sql
```

### Step 3: Customize Generated Migration

1. Replace `example_table` with your actual table name
2. Replace business columns with your actual columns
3. Add additional indexes as needed
4. Remove example table if not needed

### Step 4: Run Migration

```bash
mvn flyway:migrate
```

## Key Requirements

### 1. Tenant Isolation (REQUIRED)

Every table MUST have:
```sql
tenant_id UUID NOT NULL,
```

RLS policy MUST reference:
```sql
current_setting('app.current_tenant', true)
```

### 2. Audit Columns (REQUIRED)

Every table MUST have:
```sql
created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
created_by UUID,
updated_by UUID,
```

### 3. RLS Policies (REQUIRED)

Every tenant table MUST have:
```sql
ALTER TABLE schema.table_name ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON schema.table_name
    FOR ALL
    USING (tenant_id::text = current_setting('app.current_tenant', true))
    WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
```

### 4. No Cross-Schema Foreign Keys

Use soft references (UUIDs) instead:
```sql
-- ❌ WRONG: Cross-schema foreign key
CONSTRAINT fk_patient FOREIGN KEY (patient_id) 
    REFERENCES clinical.patients(id)

-- ✅ CORRECT: Soft reference
patient_id UUID,  -- Reference to clinical.patients(id), validated at service layer
```

### 5. Compliance Fields (OPTIONAL)

If `includeComplianceFields` is true:
```sql
encryption_key_id VARCHAR(255),
data_sovereignty_tag VARCHAR(100),
consent_ref UUID,
```

## Core Kernel Integration

The Core Kernel's `MultiTenantConnectionProvider` automatically sets:
- `app.current_tenant` - Current tenant ID
- `app.current_user` - Current user ID

These are set BEFORE any query executes, enabling RLS policies to work correctly.

## Example: Clinical Schema

```sql
-- V003__create_clinical_schema.sql
CREATE SCHEMA IF NOT EXISTS clinical;

CREATE TABLE clinical.patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by UUID,
    updated_by UUID,
    
    -- Business columns
    name JSONB,  -- FHIR HumanName
    birth_date DATE,
    
    -- Compliance fields
    encryption_key_id VARCHAR(255),
    data_sovereignty_tag VARCHAR(100),
    consent_ref UUID,
    
    CONSTRAINT patients_tenant_id_fk FOREIGN KEY (tenant_id) 
        REFERENCES core.tenants(id) ON DELETE CASCADE
);

-- RLS
ALTER TABLE clinical.patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation_policy ON clinical.patients
    FOR ALL
    USING (tenant_id::text = current_setting('app.current_tenant', true))
    WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
```

## Validation Checklist

Before committing a migration:

- [ ] Schema name is correct
- [ ] All tables have `tenant_id` column
- [ ] All tables have audit columns
- [ ] RLS is enabled on tenant tables
- [ ] RLS policies reference `app.current_tenant`
- [ ] No cross-schema foreign keys
- [ ] Compliance fields included (if needed)
- [ ] Indexes created for tenant_id
- [ ] Triggers set up for audit columns
- [ ] Grants configured for application_role

## Common Mistakes

### ❌ Missing Tenant ID
```sql
-- WRONG
CREATE TABLE clinical.patients (
    id UUID PRIMARY KEY,
    name VARCHAR(255)
);
```

### ❌ Wrong RLS Policy
```sql
-- WRONG: Hard-coded tenant check
CREATE POLICY tenant_isolation_policy ON clinical.patients
    USING (tenant_id = 'some-tenant-id');
```

### ✅ Correct
```sql
-- CORRECT: Uses session variable
CREATE POLICY tenant_isolation_policy ON clinical.patients
    USING (tenant_id::text = current_setting('app.current_tenant', true));
```

## Testing

### Test RLS Policies

```sql
-- Set tenant context
SET app.current_tenant = 'tenant-1';

-- Insert data
INSERT INTO clinical.patients (tenant_id, name) 
VALUES ('tenant-1', '{"given": ["John"]}');

-- Try to access other tenant's data (should fail)
SET app.current_tenant = 'tenant-2';
SELECT * FROM clinical.patients;  -- Should return no rows
```

---

**Remember**: Schema scaffolding is about infrastructure, not business logic. Keep it simple and generic.

