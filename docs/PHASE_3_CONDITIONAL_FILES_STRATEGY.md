# Phase 3: Conditional Files Strategy - CORRECTED

## Key Insight from Backstage Documentation

**Pattern 3: Conditionally Scaffolding Files and Directories**

> The fetch:template action supports Nunjucks in filenames. If a filename expression templates to a "falsy" value (e.g., an empty string), the file will be skipped entirely.

**Example from docs**:
```
skeleton/src/main/java/com/example/consumer/{% if values.includeKafka %}KafkaConsumerService.java{% endif %}
```

If `includeKafka` is false, filename becomes empty string → file is skipped.

---

## Correct Approach for Modules

### Strategy: Conditional Filenames for Each Module File

For each module, create files with conditional filenames:

**Inventory Module Example**:
```
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/domain/{% if values.includeInventoryModule %}InventoryItem.java{% endif %}
```

**Problem**: This creates complex nested conditionals in paths.

### Better Strategy: Module-Specific Files with Full Conditional Paths

**For Inventory Module**:
```
skeleton/modules/{% if values.includeInventoryModule %}inventory/internal/domain/InventoryItem.java{% endif %}
```

If `includeInventoryModule` is false, entire path becomes empty → file skipped.

**For Laboratory Module**:
```
skeleton/modules/{% if values.includeLaboratoryModule %}laboratory/internal/domain/LaboratorySample.java{% endif %}
```

---

## Implementation Plan

### Step 1: Create Module Files with Conditional Paths

For each of the 13 modules, create:
1. Entity file (domain/)
2. Repository file (repo/)
3. Service file (service/)
4. Controller file (web/)
5. Service Provider Interface (api/spi/)
6. Event file (api/event/)
7. Listener file (listener/)

### Step 2: Use Pattern-Specific Code Inside Files

Each file contains pattern-specific code:
- Clinical: FHIR fields
- Billing: PM-JAY/NHCX fields
- Inventory: FEFO/batch fields
- etc.

### Step 3: Keep Existing Modules

- clinical/ (already exists - keep as is)
- billing/ (already exists - keep as is)
- abdm/ (already exists - keep as is)
- {{ values.moduleName }}/ (generic template - keep as is)

---

## File Structure Example

### Inventory Module (Conditional)

```
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/domain/{% if values.includeInventoryModule %}InventoryItem.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/repo/{% if values.includeInventoryModule %}InventoryItemRepository.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/service/{% if values.includeInventoryModule %}InventoryService.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/web/{% if values.includeInventoryModule %}InventoryController.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/api/spi/{% if values.includeInventoryModule %}InventoryServiceProvider.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/api/event/{% if values.includeInventoryModule %}InventoryEvent.java{% endif %}
skeleton/modules/{% if values.includeInventoryModule %}inventory{% endif %}/internal/listener/{% if values.includeInventoryModule %}InventoryEventListener.java{% endif %}
```

---

## Alternative: Simpler Structure

Actually, a simpler approach:
1. Keep existing modules (clinical, billing, abdm) as hardcoded
2. Create new modules using conditional filenames
3. Use pattern-specific code inside files

This avoids complex nested conditionals.

---

## Next Steps

1. Create inventory module files with conditional filenames
2. Add pattern-specific code (FEFO, batch tracking)
3. Create laboratory module files
4. Create P1 modules (blood_bank, scheduling, communication, documents)
5. Create P2 modules (imaging, warehouse, terminology, integration)
6. Test with multiple modules selected

---

**Status**: Implementing conditional file creation strategy

