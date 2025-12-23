# Module Coverage Analysis: 14 Schemas vs Template Support

## Current Database Schemas (14 Total)

From the database structure, we have:

1. ✅ **abdm** - ABDM integration
2. ✅ **billing** - Billing and insurance
3. ✅ **blood_bank** - Blood bank management
4. ✅ **clinical** - Clinical data
5. ✅ **communication** - Notifications
6. ✅ **core** - Core platform (tenants, users)
7. ✅ **documents** - Document management
8. ✅ **imaging** - Medical imaging
9. ✅ **integration** - External integrations
10. ✅ **inventory** - Inventory management
11. ✅ **laboratory** - Laboratory/LIMS
12. ✅ **scheduling** - Appointments/scheduling
13. ✅ **terminology** - Terminology/codes
14. ✅ **warehouse** - Warehouse management

---

## Current Template Support

### Modules in Template (Currently)

**Checkboxes in template.yaml:**
- ✅ `includeClinicalModule` (default: true)
- ✅ `includeBillingModule` (default: true)
- ✅ `includeInventoryModule` (default: false)

**Modules in skeleton:**
- ✅ `clinical/` (exists - from Phase 2)
- ✅ `billing/` (exists - from Phase 2)
- ✅ `abdm/` (exists - from Phase 2)
- ✅ `{{ values.moduleName }}/` (generic template)

**Total: 3 specific modules + 1 generic template**

---

## Gap Analysis: 14 Schemas vs 3 Modules

### ✅ Currently Supported (3)
1. **clinical** - Has module structure
2. **billing** - Has module structure
3. **abdm** - Has module structure

### ❌ Missing Module Templates (11)
1. **blood_bank** - No module template
2. **communication** - No module template
3. **documents** - No module template
4. **imaging** - No module template
5. **integration** - No module template
6. **inventory** - Has checkbox but no specific template
7. **laboratory** - No module template
8. **scheduling** - No module template
9. **terminology** - No module template
10. **warehouse** - No module template
11. **core** - Core Kernel (not a module, infrastructure)

---

## What Phase 3 Should Cover

### Priority 1: Major Business Modules (P0)
1. ✅ **clinical** - Already exists
2. ✅ **billing** - Already exists
3. ✅ **inventory** - Checkbox exists, needs template
4. ✅ **laboratory** - Critical for LIMS
5. ✅ **abdm** - Already exists

### Priority 2: Support Modules (P1)
6. **blood_bank** - Blood bank management
7. **scheduling** - Appointments/scheduling
8. **communication** - Notifications
9. **documents** - Document management

### Priority 3: Infrastructure Modules (P2)
10. **imaging** - Medical imaging
11. **warehouse** - Warehouse management
12. **terminology** - Terminology/codes
13. **integration** - External integrations

### Not a Module:
- **core** - Core Kernel (infrastructure, not a business module)

---

## Phase 3 Plan: Support All 14 Schemas

### Approach: Single Template with Pattern Selection

**Instead of 14 separate templates, use ONE template with:**
- Pattern enum: [clinical, billing, inventory, laboratory, blood_bank, scheduling, communication, documents, imaging, warehouse, terminology, integration, abdm, generic]
- Pattern-specific parameters (oneOf)
- Pattern-specific code (Nunjucks conditionals)

### Implementation Strategy

**Step 1: Add All Patterns to template.yaml**
```yaml
modulePattern:
  enum:
    - clinical
    - billing
    - inventory
    - laboratory
    - blood_bank
    - scheduling
    - communication
    - documents
    - imaging
    - warehouse
    - terminology
    - integration
    - abdm
    - generic
```

**Step 2: Add Pattern-Specific Parameters**
- Clinical: FHIR resource types
- Billing: PM-JAY/NHCX flags
- Inventory: FEFO/batch tracking
- Laboratory: Sample tracking, QC
- Blood Bank: Donor management, cross-matching
- Scheduling: Appointments, slots
- Communication: Notifications, templates
- Documents: Document management
- Imaging: DICOM, PACS integration
- Warehouse: Warehouse management
- Terminology: Code systems, mappings
- Integration: External integrations
- ABDM: ABDM workflows

**Step 3: Add Pattern-Specific Code to Skeleton**
- Each pattern gets domain-specific entity structure
- Each pattern gets domain-specific service examples
- Each pattern gets domain-specific schema templates

---

## Current Status

### ✅ What We Have
- 3 modules with structure (clinical, billing, abdm)
- Generic template for any module
- 14 schemas in database (V001__complete_hims_schema.sql)

### ❌ What's Missing
- 11 module templates (blood_bank, communication, documents, imaging, integration, inventory, laboratory, scheduling, terminology, warehouse)
- Pattern selection in template.yaml
- Pattern-specific code in skeleton

---

## Phase 3 Scope

### Must Have (P0)
- Clinical pattern (enhance existing)
- Billing pattern (enhance existing)
- Inventory pattern (create)
- Laboratory pattern (create)
- ABDM pattern (enhance existing)

### Should Have (P1)
- Blood Bank pattern
- Scheduling pattern
- Communication pattern
- Documents pattern

### Nice to Have (P2)
- Imaging pattern
- Warehouse pattern
- Terminology pattern
- Integration pattern

---

## Recommendation

**Phase 3 should:**
1. ✅ Create pattern selection in template.yaml (all 14 patterns)
2. ✅ Add pattern-specific code for P0 patterns (5 patterns)
3. ✅ Add pattern-specific code for P1 patterns (4 patterns)
4. ✅ Add generic pattern for P2 patterns (4 patterns can use generic)

**This ensures all 14 schemas are supported, with full templates for critical modules.**

---

## Summary

**Current:**
- 14 schemas in database ✅
- 3 modules in template ❌
- 11 modules missing ❌

**Phase 3 Goal:**
- Support all 14 schemas ✅
- Full templates for P0/P1 (9 patterns)
- Generic template for P2 (4 patterns)

**Answer: No, template doesn't support all 14 patterns yet. Phase 3 will add them.**

