# Phase 3 Final Approach - ULTRA THINK

## Decision: Hybrid Approach

After careful analysis, the best approach is:

### Strategy: Keep Existing + Add Conditional Files

1. **Keep existing hardcoded modules** (clinical, billing, abdm)
   - These already exist and work
   - No need to change them

2. **Add new modules with conditional filenames**
   - Use Backstage Pattern 3: Conditional filenames
   - Files only created if checkbox is true
   - Pattern-specific code inside files

3. **Use generic template for custom modules**
   - `{{ values.moduleName }}/` remains for custom modules

---

## Implementation: Conditional File Creation

### For Each New Module (inventory, laboratory, etc.)

Create files with conditional filenames:

**Example - Inventory Module**:
```
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/domain/{% if values.includeInventoryModule %}InventoryItem.java{% endif %}
```

**How it works**:
- If `includeInventoryModule` is true → file created at `modules/inventory/internal/domain/InventoryItem.java`
- If `includeInventoryModule` is false → filename becomes empty → file skipped

---

## File Structure for Each Module

For each of the 10 new modules, create:

1. **Entity** (domain/)
2. **Repository** (repo/)
3. **Service** (service/)
4. **Controller** (web/)
5. **Service Provider Interface** (api/spi/)
6. **Event** (api/event/)
7. **Listener** (listener/)

**Total**: 7 files × 10 modules = 70 files

---

## Pattern-Specific Code

Each file contains pattern-specific code:

### Clinical Pattern
- FHIR resource types
- FHIR resource mapping
- STG compliance

### Billing Pattern
- PM-JAY fields
- NHCX integration
- Pre-authorization workflow

### Inventory Pattern
- FEFO support
- Batch tracking
- Soft FK to clinical

### Laboratory Pattern
- Sample collection
- QC tracking
- Machine interface

### And so on...

---

## Implementation Order

1. ✅ Template enhanced (all checkboxes added)
2. 🚧 Create inventory module (complete example)
3. ⏳ Create laboratory module (P0)
4. ⏳ Create P1 modules (4 modules)
5. ⏳ Create P2 modules (4 modules)
6. ⏳ Add pattern-specific code to all
7. ⏳ Test with multiple modules

---

## Status

**Current**: Creating inventory module as complete example
**Next**: Apply pattern to all remaining modules

