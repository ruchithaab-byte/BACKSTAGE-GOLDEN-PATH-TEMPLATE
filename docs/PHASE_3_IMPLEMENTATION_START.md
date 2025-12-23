# Phase 3 Implementation - Starting Now

## Implementation Strategy

**Approach**: Incremental, careful implementation
**Starting Point**: Phase 3.1 - Template Enhancement

---

## Phase 3.1: Template Enhancement - Pattern Selection

### Current Understanding

**Current Template**: Monorepo template with checkboxes
- `includeClinicalModule` (boolean)
- `includeBillingModule` (boolean)
- `includeInventoryModule` (boolean)

**Issue**: Checkboxes exist but don't have pattern-specific configuration

**Solution**: Add pattern selection for each module checkbox

---

## Implementation Plan

### Step 1: Enhance Checkboxes with Pattern Selection

**Current**:
```yaml
includeClinicalModule:
  title: Include Clinical Module
  type: boolean
  default: true
```

**Enhanced**:
```yaml
includeClinicalModule:
  title: Include Clinical Module
  type: boolean
  default: true

# If clinical is selected, show pattern options
dependencies:
  includeClinicalModule:
    oneOf:
      - properties:
          includeClinicalModule: { const: true }
          clinicalPattern:
            title: Clinical Module Pattern
            type: string
            enum: ['fhir-aligned', 'basic']
            default: 'fhir-aligned'
          fhirResourceTypes:
            title: FHIR Resource Types
            type: array
            items: { type: string, enum: ['Patient', 'Encounter', 'Observation'] }
            default: ['Patient', 'Encounter', 'Observation']
```

**But wait** - this gets complex with multiple checkboxes.

### Better Approach: Pattern Selection Per Module

Instead of boolean checkboxes, use module selection with pattern:

```yaml
initialModules:
  title: Initial Modules
  type: array
  items:
    type: object
    properties:
      moduleName:
        type: string
        enum: ['clinical', 'billing', 'inventory', 'laboratory', ...]
      modulePattern:
        type: string
        # Pattern-specific to module
```

**But this is too complex for initial setup.**

### Best Approach: Keep Checkboxes, Add Pattern Selection Step

**Step 1**: Select modules (checkboxes) - SIMPLE
**Step 2**: Configure patterns for selected modules - PATTERN-SPECIFIC

This way:
- User selects modules they want (simple checkboxes)
- Then configures each selected module with pattern-specific options

---

## Revised Implementation Plan

### Phase 3.1.1: Keep Simple Checkboxes (Current)
- Keep existing checkboxes
- Add more checkboxes for all 14 modules

### Phase 3.1.2: Add Pattern Configuration Step
- After module selection, add pattern configuration
- Only show patterns for selected modules
- Pattern-specific parameters (oneOf)

### Phase 3.1.3: Update Skeleton
- Create modules conditionally based on checkboxes
- Use pattern-specific code based on pattern selection

---

## Starting Implementation

**Step 1**: Add all 14 module checkboxes to template.yaml
**Step 2**: Add pattern selection step (conditional on selected modules)
**Step 3**: Update skeleton to create modules conditionally
**Step 4**: Add pattern-specific code to skeleton

Let's start!

