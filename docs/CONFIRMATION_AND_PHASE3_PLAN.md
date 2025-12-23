# Confirmation: Multiple Modules + Phase 3 Plan

## ✅ CONFIRMED: Multiple Checkboxes Work

**Yes, you CAN select multiple checkboxes!**

The template.yaml has:
- ✅ `includeClinicalModule` checkbox (default: true)
- ✅ `includeBillingModule` checkbox (default: true)
- ✅ `includeInventoryModule` checkbox (default: false)

**User can check all three and create all modules at once!**

---

## ⚠️ ISSUE FOUND: Skeleton Needs Fix

**Current Problem:**
- Checkboxes exist and work ✅
- But skeleton only has `{{ values.moduleName }}/` template (single module)
- Doesn't create multiple modules based on checkboxes ❌

**What Happens Now:**
- User checks all three boxes
- Template passes all flags to Nunjucks
- But skeleton only creates one generic module (not three specific modules)

---

## Solution: Fix Skeleton Before Phase 3

### What Needs to Be Done:

**Create module-specific directories conditionally:**

```
skeleton/modules/
├── {% if values.includeClinicalModule %}
│   └── clinical/
│       ├── api/
│       └── internal/
│           ├── domain/
│           ├── service/
│           ├── repo/
│           └── web/
│   {% endif %}
├── {% if values.includeBillingModule %}
│   └── billing/
│       └── ... (same structure)
│   {% endif %}
└── {% if values.includeInventoryModule %}
    └── inventory/
        └── ... (same structure)
    {% endif %}
```

**Each module directory should:**
- Use the existing `{{ values.moduleName }}/` template structure
- But be hardcoded to specific module names (clinical, billing, inventory)
- Include pattern-specific code (FHIR for clinical, PM-JAY for billing, etc.)

---

## Phase 3 Plan (After Fix)

### Phase 3: Module Template Pattern Library

**Goal**: Create comprehensive template patterns for all major modules

**Tasks:**
1. **Enhance Module Template with Pattern Selection**
   - Add `modulePattern` enum (clinical, billing, inventory, etc.)
   - Add pattern-specific parameters (oneOf)
   - Add pattern-specific code in skeleton (Nunjucks conditionals)

2. **Add Domain-Specific Examples**
   - Clinical: Patient CRUD example (FHIR-aligned)
   - Billing: Invoice generation example (PM-JAY/NHCX)
   - Inventory: Stock management example (FEFO/batch)

3. **Add Domain-Specific Schema Templates**
   - Clinical schema template (FHIR-aligned)
   - Billing schema template (PM-JAY/NHCX)
   - Inventory schema template (FEFO/batch)

4. **Template Pattern Library Documentation**
   - Pattern catalog
   - Decision tree
   - Usage guide

---

## Action Plan

### Step 1: Fix Multiple Modules (NOW)
- Create conditional module directories in skeleton
- Test with all checkboxes selected
- Verify all modules are created

### Step 2: Proceed to Phase 3 (AFTER FIX)
- Enhance template with pattern selection
- Add domain-specific examples
- Add domain-specific schema templates
- Create documentation

---

## Status

**Current**: ✅ Checkboxes work, ❌ Skeleton doesn't create multiple modules  
**Next**: Fix skeleton, then proceed to Phase 3  
**Timeline**: Fix (1-2 hours), then Phase 3 (4 weeks)

---

**Ready to fix skeleton and proceed to Phase 3?** ✅

