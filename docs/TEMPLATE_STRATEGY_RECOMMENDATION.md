# Template Strategy: Single Template with Pattern Selection ✅

## Answer: NO - Use ONE Template with Pattern Selection

**You don't need separate templates for each domain.** Use a **single template** with pattern-based selection (oneOf) and Nunjucks conditionals.

---

## Why Single Template is Better

### ✅ Matches Composable-Monolithic Hybrid Strategy

Per the Backstage Golden Path strategy:
- ✅ **Single `template.yaml`** with pattern selection (oneOf)
- ✅ **Single `skeleton/` directory** with Nunjucks conditionals
- ✅ **Pattern-based UI** - user selects domain pattern
- ✅ **Conditional code generation** - Nunjucks renders domain-specific code

### ✅ Benefits

1. **Easier Maintenance**
   - Fix bug once → applies to all modules
   - Add feature once → available to all
   - Single source of truth

2. **Consistent Structure**
   - All modules follow same Spring Modulith pattern
   - Same Core Kernel integration
   - Same RLS policies, audit columns

3. **Less Code Duplication**
   - Shared structure in one place
   - Domain differences = configuration, not structure

4. **Better Developer Experience**
   - Pattern selection in UI (composable feel)
   - Single template to learn
   - Consistent patterns

---

## How It Works

### Current Structure (Already Good!)

```
hims-platform-monorepo-template/
├── template.yaml (single template)
└── skeleton/
    └── modules/{{ values.moduleName }}/
        ├── api/
        └── internal/
```

### Enhanced Structure (Phase 3)

```
hims-platform-monorepo-template/
├── template.yaml (with pattern selection)
└── skeleton/
    └── modules/{{ values.moduleName }}/
        ├── api/
        └── internal/
            ├── domain/
            │   └── {{ values.moduleName | capitalize }}Entity.java
            │       {% if values.modulePattern == 'clinical' %}
            │       // FHIR-aligned entity
            │       {% elif values.modulePattern == 'billing' %}
            │       // PM-JAY/NHCX entity
            │       {% else %}
            │       // Generic entity
            │       {% endif %}
```

---

## Implementation: Pattern Selection in template.yaml

### Add Pattern Selection

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
        description: Business domain name (e.g., clinical, billing, inventory)
        pattern: '^[a-z][a-z0-9]*$'
      
      modulePattern:
        title: Module Pattern
        type: string
        enum:
          - clinical
          - billing
          - inventory
          - laboratory
          - abdm
          - generic
        description: Select the domain pattern for this module
        default: generic

  dependencies:
    modulePattern:
      oneOf:
        # Clinical Pattern
        - properties:
            modulePattern: { enum: ['clinical'] }
            fhirResourceTypes:
              title: FHIR Resource Types
              type: array
              items: { type: string }
              default: ['Patient', 'Encounter', 'Observation']
            includeComplianceFields:
              type: boolean
              const: true  # Always true for clinical
        
        # Billing Pattern
        - properties:
            modulePattern: { enum: ['billing'] }
            includePmJay:
              title: Include PM-JAY Support
              type: boolean
              default: true
            includeNhcx:
              title: Include NHCX Integration
              type: boolean
              default: true
        
        # Inventory Pattern
        - properties:
            modulePattern: { enum: ['inventory'] }
            includeFefo:
              title: Include FEFO Support
              type: boolean
              default: true
            includeBatchTracking:
              title: Include Batch Tracking
              type: boolean
              default: true
        
        # Generic Pattern (default)
        - properties:
            modulePattern: { enum: ['generic'] }
```

---

## Skeleton Files with Conditionals

### Example: Entity with Pattern-Specific Code

```java
// skeleton/modules/{{ values.moduleName }}/internal/domain/{{ values.moduleName | capitalize }}Entity.java

package com.hims.modules.{{ values.moduleName }}.internal.domain;

import jakarta.persistence.*;
// ... imports

@Entity
@Table(name = "{{ values.moduleName }}_items", schema = "{{ values.moduleName }}")
public class {{ values.moduleName | capitalize }}Entity {
    
    // Common fields (all patterns)
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(name = "tenant_id", nullable = false)
    private UUID tenantId;
    
    // Pattern-specific fields
    {% if values.modulePattern == 'clinical' %}
    // Clinical-specific: FHIR fields
    @Column(name = "fhir_resource_type")
    private String fhirResourceType;
    
    @Column(name = "fhir_resource_id")
    private String fhirResourceId;
    {% elif values.modulePattern == 'billing' %}
    // Billing-specific: PM-JAY/NHCX fields
    {% if values.includePmJay %}
    @Column(name = "beneficiary_id")
    private String beneficiaryId;
    {% endif %}
    {% if values.includeNhcx %}
    @Column(name = "nhcx_bundle_id")
    private String nhcxBundleId;
    {% endif %}
    {% elif values.modulePattern == 'inventory' %}
    // Inventory-specific: FEFO/Batch fields
    {% if values.includeFefo %}
    @Column(name = "expiry_date")
    private LocalDate expiryDate;
    {% endif %}
    {% if values.includeBatchTracking %}
    @Column(name = "batch_number")
    private String batchNumber;
    {% endif %}
    {% endif %}
    
    // Common audit fields (all patterns)
    @Column(name = "created_at", nullable = false)
    private OffsetDateTime createdAt;
    // ...
}
```

---

## What This Means for Phase 3

### Instead of Creating Separate Templates

**Don't create:**
- ❌ `clinical-module-template/`
- ❌ `billing-module-template/`
- ❌ `inventory-module-template/`

**Instead, enhance the existing template:**
- ✅ Add pattern selection to `template.yaml`
- ✅ Add domain-specific examples to skeleton (with Nunjucks conditionals)
- ✅ Add domain-specific schema templates (with conditionals)
- ✅ Add pattern-specific documentation

---

## Phase 3 Tasks (Revised)

### 3.1 Enhance Module Template (Not Create Separate Ones)
- [ ] Add pattern selection to `template.yaml` (oneOf)
- [ ] Add clinical pattern parameters (FHIR resource types)
- [ ] Add billing pattern parameters (PM-JAY/NHCX flags)
- [ ] Add inventory pattern parameters (FEFO/batch flags)
- [ ] Add domain-specific examples to skeleton (Nunjucks conditionals)

### 3.2 Add Domain-Specific Examples
- [ ] Clinical: Patient CRUD example (wrapped in `{% if values.modulePattern == 'clinical' %}`)
- [ ] Billing: Invoice generation example (wrapped in `{% if values.modulePattern == 'billing' %}`)
- [ ] Inventory: Stock management example (wrapped in `{% if values.modulePattern == 'inventory' %}`)

### 3.3 Add Domain-Specific Schema Templates
- [ ] Clinical schema template (FHIR-aligned)
- [ ] Billing schema template (PM-JAY/NHCX)
- [ ] Inventory schema template (FEFO/batch)
- [ ] All in same template file with conditionals

---

## Summary

**Answer**: **NO, you don't need separate templates.**

**Use:**
- ✅ **ONE template.yaml** with pattern selection (oneOf)
- ✅ **ONE skeleton/** directory with Nunjucks conditionals
- ✅ **Pattern-based UI** - user selects domain pattern
- ✅ **Conditional code generation** - domain-specific code based on pattern

**This matches the Composable-Monolithic Hybrid strategy and is the recommended approach.**

---

**Next Step**: Enhance the existing template with pattern selection instead of creating separate templates.

