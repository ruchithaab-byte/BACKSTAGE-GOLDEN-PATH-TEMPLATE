# Phase 3: Detailed Implementation Plan - ULTRA THINK

## Executive Summary

**Goal**: Create comprehensive template patterns for all 14 schemas using single template with pattern selection (Composable-Monolithic Hybrid).

**Approach**: 
- Single `template.yaml` with pattern enum (all 14 patterns)
- Single `skeleton/` with Nunjucks conditionals
- Pattern-specific parameters (oneOf)
- Pattern-specific code generation

---

## Phase 3.1: Template Enhancement - Pattern Selection

### Current State
- ✅ Checkboxes exist (clinical, billing, inventory)
- ❌ No pattern selection
- ❌ Modules not conditional
- ❌ Only 3-4 modules supported

### Target State
- ✅ Pattern enum with all 14 schemas
- ✅ Pattern-specific parameters (oneOf)
- ✅ Conditional module creation
- ✅ All 14 patterns supported

### Implementation Steps

#### Step 1.1: Add Pattern Selection to template.yaml
```yaml
parameters:
  - title: Module Configuration
    required:
      - moduleName
      - modulePattern
    properties:
      moduleName:
        title: Module Name
        type: string
        description: Business domain name
        pattern: '^[a-z][a-z0-9]*$'
      
      modulePattern:
        title: Module Pattern
        type: string
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
        default: generic
```

#### Step 1.2: Add Pattern-Specific Parameters (oneOf)
- Clinical: FHIR resource types
- Billing: PM-JAY/NHCX flags
- Inventory: FEFO/batch tracking
- Laboratory: Sample tracking, QC
- Blood Bank: Donor management
- Scheduling: Appointments, slots
- Communication: Notifications
- Documents: Document management
- Imaging: DICOM integration
- Warehouse: Warehouse management
- Terminology: Code systems
- Integration: External integrations
- ABDM: ABDM workflows
- Generic: Basic fields

#### Step 1.3: Update Steps to Pass Pattern Parameters
- Pass `modulePattern` to Nunjucks
- Pass pattern-specific parameters conditionally

---

## Phase 3.2: Skeleton Enhancement - Pattern-Specific Code

### Current State
- ✅ Generic template `{{ values.moduleName }}/`
- ✅ Some hardcoded modules (clinical, billing, abdm)
- ❌ Not conditional based on checkboxes
- ❌ No pattern-specific code

### Target State
- ✅ Conditional module creation based on checkboxes
- ✅ Pattern-specific entity structures
- ✅ Pattern-specific service examples
- ✅ Pattern-specific schema templates

### Implementation Steps

#### Step 2.1: Create Conditional Module Directories
```
skeleton/modules/
├── {% if values.includeClinicalModule %}
│   └── clinical/
│       └── ... (full structure)
│   {% endif %}
├── {% if values.includeBillingModule %}
│   └── billing/
│       └── ... (full structure)
│   {% endif %}
└── {% if values.includeInventoryModule %}
    └── inventory/
        └── ... (full structure)
    {% endif %}
```

**Challenge**: Nunjucks can't easily create conditional directories.

**Solution**: Use generic template with pattern-specific code inside.

#### Step 2.2: Pattern-Specific Entity Code
Each entity file uses pattern-specific fields:
- Clinical: FHIR fields
- Billing: PM-JAY/NHCX fields
- Inventory: FEFO/batch fields
- etc.

#### Step 2.3: Pattern-Specific Service Examples
Each service has pattern-specific methods:
- Clinical: Patient CRUD
- Billing: Invoice generation
- Inventory: Stock management
- etc.

#### Step 2.4: Pattern-Specific Schema Templates
Each pattern has domain-specific schema:
- Clinical: FHIR-aligned tables
- Billing: PM-JAY/NHCX tables
- Inventory: FEFO/batch tables
- etc.

---

## Phase 3.3: Pattern Implementation Priority

### P0: Critical Patterns (5 patterns)
1. **Clinical** - Enhance existing
   - FHIR resource types
   - Patient, Encounter, Observation
   - STG compliance

2. **Billing** - Enhance existing
   - PM-JAY support
   - NHCX integration
   - Pre-authorization workflow

3. **Inventory** - Create new
   - FEFO support
   - Batch tracking
   - Soft FK to clinical

4. **Laboratory** - Create new
   - Sample collection
   - QC tracking
   - Machine interface

5. **ABDM** - Enhance existing
   - M1: ABHA Creation
   - M2: Care Context Linking
   - M3: Consent Management

### P1: Important Patterns (4 patterns)
6. **Blood Bank** - Create new
   - Donor management
   - Blood unit tracking
   - Cross-matching

7. **Scheduling** - Create new
   - Appointments
   - Slots management
   - Queue/token system

8. **Communication** - Create new
   - Notifications
   - Templates
   - Campaigns

9. **Documents** - Create new
   - Document management
   - Version control
   - Access control

### P2: Can Use Generic (4 patterns)
10. **Imaging** - Generic pattern
11. **Warehouse** - Generic pattern
12. **Terminology** - Generic pattern
13. **Integration** - Generic pattern

---

## Phase 3.4: Implementation Strategy

### Strategy: Incremental Enhancement

**Phase 3.4.1: Core Pattern Selection (Week 1)**
- Add pattern enum to template.yaml
- Add pattern-specific parameters (oneOf)
- Update skeleton to use pattern in generic template
- Test with existing patterns (clinical, billing, abdm)

**Phase 3.4.2: P0 Patterns (Weeks 2-3)**
- Enhance clinical pattern (FHIR)
- Enhance billing pattern (PM-JAY/NHCX)
- Create inventory pattern (FEFO/batch)
- Create laboratory pattern (LIMS)
- Enhance ABDM pattern (workflows)

**Phase 3.4.3: P1 Patterns (Week 4)**
- Create blood_bank pattern
- Create scheduling pattern
- Create communication pattern
- Create documents pattern

**Phase 3.4.4: P2 Patterns (Week 4)**
- Use generic pattern for imaging, warehouse, terminology, integration
- Add minimal pattern-specific code if needed

**Phase 3.4.5: Documentation (Week 4)**
- Pattern catalog
- Decision tree
- Usage guide
- Examples

---

## Phase 3.5: Technical Considerations

### Challenge 1: Conditional Module Directories
**Problem**: Nunjucks can't easily create conditional directories.

**Solution**: 
- Use generic template `{{ values.moduleName }}/`
- Pass module name from checkbox selection
- Create multiple modules by calling template multiple times (not possible)
- **Better**: Create all modules conditionally in skeleton, but use pattern-specific code inside

**Actual Solution**:
- Keep generic template structure
- Use pattern-specific code inside files
- Modules are created based on checkboxes, but code is pattern-specific

### Challenge 2: Multiple Modules from Checkboxes
**Problem**: How to create multiple modules when checkboxes are selected?

**Solution**:
- Create separate conditional directories for each module
- Each directory has full module structure
- Each uses pattern-specific code based on module name

**Implementation**:
```
skeleton/modules/
├── {% if values.includeClinicalModule %}
│   └── clinical/
│       └── ... (uses clinical pattern code)
│   {% endif %}
├── {% if values.includeBillingModule %}
│   └── billing/
│       └── ... (uses billing pattern code)
│   {% endif %}
└── {% if values.includeInventoryModule %}
    └── inventory/
        └── ... (uses inventory pattern code)
    {% endif %}
```

### Challenge 3: Pattern-Specific Code in Generic Template
**Problem**: Generic template `{{ values.moduleName }}/` needs pattern-specific code.

**Solution**:
- Detect pattern from module name (clinical → clinical pattern)
- Use Nunjucks conditionals based on module name
- Each module gets pattern-specific code

---

## Phase 3.6: File Structure Plan

### Template Files to Create/Modify

1. **template.yaml**
   - Add pattern selection enum
   - Add pattern-specific parameters (oneOf)
   - Update steps to pass pattern

2. **skeleton/modules/{{ values.moduleName }}/**
   - Add pattern-specific entity code
   - Add pattern-specific service code
   - Add pattern-specific controller code

3. **skeleton/modules/clinical/** (conditional)
   - Full module structure
   - Clinical pattern code

4. **skeleton/modules/billing/** (conditional)
   - Full module structure
   - Billing pattern code

5. **skeleton/modules/inventory/** (conditional)
   - Full module structure
   - Inventory pattern code

6. **Schema templates**
   - Pattern-specific schema templates
   - Conditional based on pattern

---

## Phase 3.7: Testing Strategy

### Test Cases

1. **Single Module Creation**
   - Create clinical module only
   - Verify clinical pattern code generated
   - Verify FHIR fields present

2. **Multiple Module Creation**
   - Create clinical + billing + inventory
   - Verify all modules created
   - Verify pattern-specific code in each

3. **Pattern-Specific Parameters**
   - Test clinical with FHIR resource types
   - Test billing with PM-JAY/NHCX flags
   - Test inventory with FEFO/batch flags

4. **Schema Generation**
   - Verify pattern-specific schemas generated
   - Verify RLS policies
   - Verify compliance fields

---

## Phase 3.8: Risk Mitigation

### Risk 1: Skeleton Becomes Too Large
**Mitigation**: 
- Use Nunjucks conditionals effectively
- Keep pattern-specific code minimal
- Reuse common patterns

### Risk 2: Pattern-Specific Code Duplication
**Mitigation**:
- Use generic template with conditionals
- Extract common code to shared templates
- Document pattern differences clearly

### Risk 3: Complex Conditional Logic
**Mitigation**:
- Keep conditionals simple
- Use clear pattern names
- Document pattern selection logic

---

## Phase 3.9: Success Criteria

### Must Have
- ✅ All 14 patterns in enum
- ✅ P0 patterns fully implemented (5 patterns)
- ✅ P1 patterns fully implemented (4 patterns)
- ✅ P2 patterns use generic (4 patterns)
- ✅ Pattern-specific code works
- ✅ Multiple modules can be created
- ✅ Schema generation works

### Should Have
- ✅ Pattern-specific examples
- ✅ Pattern-specific documentation
- ✅ Decision tree for pattern selection

### Nice to Have
- ✅ Pattern-specific tests
- ✅ Pattern-specific CI/CD configs

---

## Phase 3.10: Implementation Order

### Week 1: Foundation
1. Add pattern selection to template.yaml
2. Add pattern-specific parameters (oneOf)
3. Update skeleton to use pattern in generic template
4. Test with existing patterns

### Week 2: P0 Patterns (Part 1)
1. Enhance clinical pattern
2. Enhance billing pattern
3. Create inventory pattern

### Week 3: P0 Patterns (Part 2)
1. Create laboratory pattern
2. Enhance ABDM pattern
3. Test all P0 patterns

### Week 4: P1/P2 Patterns + Documentation
1. Create P1 patterns (4 patterns)
2. Configure P2 patterns (generic)
3. Create documentation
4. Final testing

---

## Next Steps

1. ✅ Review and approve plan
2. ✅ Start with Phase 3.1 (Template Enhancement)
3. ✅ Implement incrementally
4. ✅ Test after each phase
5. ✅ Document as we go

---

**Status**: Ready to implement Phase 3 with ULTRA THINK approach.

