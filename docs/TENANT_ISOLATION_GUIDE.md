# Tenant Isolation Guide

## Overview

This guide explains how tenant isolation works in the HIMS Platform and how to ensure it's correctly implemented.

---

## How Tenant Isolation Works

### 1. Core Kernel Sets Context

The Core Kernel's `MultiTenantConnectionProvider` sets PostgreSQL session variables **before any query**:

```java
stmt.execute("SET app.current_tenant = '" + tenantId + "'");
stmt.execute("SET app.current_user = '" + userId + "'");
```

These variables are set automatically for every database connection.

### 2. RLS Policies Enforce Isolation

All tenant tables have Row Level Security (RLS) policies:

```sql
CREATE POLICY tenant_isolation_policy ON schema.table_name
    FOR ALL
    USING (tenant_id::text = current_setting('app.current_tenant', true))
    WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
```

These policies ensure:
- Users can only see rows for their tenant
- Users can only insert/update rows for their tenant
- Queries automatically filter by tenant

### 3. Tenant Context is Required

**Key Rule**: There are **no fallbacks**. If `app.current_tenant` is not set:
- RLS policies will fail
- Queries will return no rows (or error)
- This is **by design** - it prevents data leaks

---

## How to Use Tenant Context

### In Services

```java
import com.hims.core.tenant.TenantContext;

@Service
public class MyService {
    
    public void doSomething() {
        // Tenant context is automatically set by Core Kernel
        String tenantId = TenantContext.getTenantId();
        String userId = TenantContext.getUserId();
        
        // Use tenantId for business logic
        // RLS policies handle database filtering automatically
    }
}
```

### In Entities

```java
@Entity
@Table(name = "my_table", schema = "my_schema")
public class MyEntity {
    
    @Column(name = "tenant_id", nullable = false)
    private UUID tenantId;  // Required for RLS
    
    // ... other fields
}
```

### In Repositories

```java
@Repository
public interface MyRepository extends JpaRepository<MyEntity, UUID> {
    
    // RLS automatically filters by tenant_id
    // No need to add WHERE tenant_id = ? clauses
    List<MyEntity> findByName(String name);
}
```

---

## Schema Requirements

### Every Tenant Table MUST Have

1. **tenant_id Column**:
   ```sql
   tenant_id UUID NOT NULL,
   ```

2. **RLS Enabled**:
   ```sql
   ALTER TABLE schema.table_name ENABLE ROW LEVEL SECURITY;
   ```

3. **RLS Policy**:
   ```sql
   CREATE POLICY tenant_isolation_policy ON schema.table_name
       FOR ALL
       USING (tenant_id::text = current_setting('app.current_tenant', true))
       WITH CHECK (tenant_id::text = current_setting('app.current_tenant', true));
   ```

4. **Index on tenant_id**:
   ```sql
   CREATE INDEX idx_table_name_tenant_id ON schema.table_name(tenant_id);
   ```

---

## Common Mistakes

### ❌ Missing tenant_id Column

```sql
-- WRONG
CREATE TABLE my_table (
    id UUID PRIMARY KEY,
    name VARCHAR(255)
);
```

**Fix**: Always include `tenant_id UUID NOT NULL`

### ❌ RLS Not Enabled

```sql
-- WRONG
CREATE TABLE my_table (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL
);
-- Missing: ALTER TABLE ... ENABLE ROW LEVEL SECURITY;
```

**Fix**: Always enable RLS on tenant tables

### ❌ Wrong RLS Policy

```sql
-- WRONG: Hard-coded tenant check
CREATE POLICY tenant_isolation_policy ON my_table
    USING (tenant_id = 'some-tenant-id');
```

**Fix**: Use `current_setting('app.current_tenant', true)`

### ❌ Manual Tenant Filtering

```java
// WRONG: Manual filtering (RLS already does this)
List<Entity> entities = repository.findByTenantId(tenantId);
```

**Fix**: RLS handles filtering automatically, just query normally

---

## Testing Tenant Isolation

### Test RLS Policies

```sql
-- Set tenant context
SET app.current_tenant = 'tenant-1';

-- Insert data
INSERT INTO my_schema.my_table (tenant_id, name) 
VALUES ('tenant-1', 'Test');

-- Try to access other tenant's data (should return no rows)
SET app.current_tenant = 'tenant-2';
SELECT * FROM my_schema.my_table;  -- Should return no rows

-- Switch back to tenant-1
SET app.current_tenant = 'tenant-1';
SELECT * FROM my_schema.my_table;  -- Should return the row
```

### Test in Application

```java
@Test
void testTenantIsolation() {
    // Set tenant context
    TenantContext.setTenantId("tenant-1");
    
    // Create entity
    MyEntity entity = new MyEntity();
    entity.setTenantId(UUID.fromString("tenant-1"));
    repository.save(entity);
    
    // Switch tenant
    TenantContext.setTenantId("tenant-2");
    
    // Query should return no rows (RLS filters)
    List<MyEntity> entities = repository.findAll();
    assertThat(entities).isEmpty();
}
```

---

## Troubleshooting

### "RLS policy not working"
- Check `app.current_tenant` is set (use `SHOW app.current_tenant;`)
- Verify RLS is enabled (`SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'my_schema';`)
- Check policy exists (`SELECT * FROM pg_policies WHERE schemaname = 'my_schema';`)

### "Queries return no rows"
- Verify `app.current_tenant` is set correctly
- Check tenant_id matches current_setting
- Verify RLS policy is correct

### "Can't insert data"
- Check `WITH CHECK` clause in RLS policy
- Verify tenant_id is set in INSERT statement
- Check `app.current_tenant` is set

---

## Best Practices

### 1. Always Set tenant_id

When creating entities:
```java
MyEntity entity = new MyEntity();
entity.setTenantId(UUID.fromString(TenantContext.getTenantId()));
```

### 2. Trust RLS

Don't manually filter by tenant_id in queries:
```java
// ✅ CORRECT: RLS handles filtering
List<Entity> entities = repository.findAll();

// ❌ WRONG: Manual filtering (redundant)
List<Entity> entities = repository.findByTenantId(tenantId);
```

### 3. Use Soft References

For cross-module references:
```java
// ✅ CORRECT: Soft reference (UUID)
@Column(name = "patient_id")
private UUID patientId;  // Reference to clinical.patients(id)

// ❌ WRONG: Foreign key across schemas
@ManyToOne
@JoinColumn(name = "patient_id")
private Patient patient;  // Cross-schema FK not allowed
```

### 4. Test Tenant Isolation

Always test that:
- Users can't see other tenants' data
- Users can't modify other tenants' data
- Queries automatically filter by tenant

---

## Security Notes

### Production Considerations

1. **Restrict System Bypass Policy**:
   ```sql
   -- Development: Allow postgres to bypass
   CREATE POLICY system_bypass_policy ON my_table
       FOR ALL TO postgres USING (true);
   
   -- Production: Remove or restrict this policy
   ```

2. **Monitor RLS Performance**:
   - RLS adds overhead to queries
   - Indexes on tenant_id are critical
   - Monitor query performance

3. **Audit Tenant Access**:
   - Use Core Kernel's audit logging
   - Track which tenants access which data
   - Monitor for suspicious patterns

---

## Summary

**Tenant Isolation = RLS Policies + Core Kernel Context**

- Core Kernel sets `app.current_tenant` automatically
- RLS policies enforce isolation at database level
- No manual filtering needed
- No fallbacks - context is required

**Key Rule**: If `app.current_tenant` is not set, queries will fail. This is by design to prevent data leaks.

---

For more information:
- See `CORE_KERNEL_SCOPE.md` for Core Kernel details
- See `SCHEMA_SCAFFOLDING_GUIDE.md` for schema setup
- See `MODULE_TEMPLATE_GUIDE.md` for module structure

