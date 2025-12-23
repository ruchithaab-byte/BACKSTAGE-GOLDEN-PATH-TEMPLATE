# Template Strategy Analysis: Single vs Domain-Specific Templates

**Question**: Do we need separate templates for each domain (clinical, billing, inventory) or can we use one parameterized template?

---

## Current Approach

### What We Have Now
- ✅ **Single Generic Module Template** with `{{ values.moduleName }}`
- ✅ **Parameterized** - works for any module name
- ✅ **Nunjucks conditionals** in skeleton files
- ✅ **Same structure** for all modules (api/internal separation)

### What Phase 3 Plan Suggests
- ❓ Separate templates: `clinical-module`, `billing-module`, `inventory-module`
- ❓ Each with domain-specific parameters
- ❓ Domain-specific example code

---

## Analysis: Single vs Domain-Specific Templates

### Option 1: Single Parameterized Template (Recommended) ✅

**Structure:**
```
hims-platform-monorepo-template/
├── template.yaml (with pattern selection)
└── skeleton/
    └── modules/{{ values.moduleName }}/
        ├── api/
        └── internal/
```

**How It Works:**
1. User selects **module pattern** in UI (clinical, billing, inventory, etc.)
2. Same template.yaml, different parameters
3. Nunjucks conditionals generate domain-specific code
4. Example implementations based on pattern

**Pros:**
- ✅ **Single source of truth** - one template to maintain
- ✅ **Consistent structure** - all modules follow same pattern
- ✅ **Less duplication** - shared code in one place
- ✅ **Easier maintenance** - fix once, applies to all
- ✅ **Composable-Monolithic Hybrid** - matches recommended strategy
- ✅ **Pattern selection** - user picks domain, template adapts

**Cons:**
- ⚠️ **Larger skeleton/** directory (but manageable with Nunjucks)
- ⚠️ **More conditionals** in skeleton files

---

### Option 2: Separate Domain Templates (Not Recommended) ❌

**Structure:**
```
hims-platform-monorepo-template/
├── clinical-module-template/
│   ├── template.yaml
│   └── skeleton/
├── billing-module-template/
│   ├── template.yaml
│   └── skeleton/
└── inventory-module-template/
    ├── template.yaml
    └── skeleton/
```

**How It Works:**
1. Each domain has its own template
2. Separate template.yaml files
3. Domain-specific skeleton directories
4. User picks which template to use

**Pros:**
- ✅ **Domain-specific** - tailored to each domain
- ✅ **Smaller files** - each template is focused

**Cons:**
- ❌ **Code duplication** - same structure repeated 10+ times
- ❌ **Maintenance nightmare** - fix bugs in 10+ places
- ❌ **Inconsistent** - modules drift apart over time
- ❌ **More templates to manage** - harder to maintain
- ❌ **Doesn't match Composable-Monolithic strategy**

---

## Recommendation: Single Template with Pattern Selection ✅

### Implementation Strategy

**Use ONE template with pattern-based selection:**

```yaml
# template.yaml
parameters:
  - title: Module Configuration
    properties:
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
          
        # Generic Pattern (for custom modules)
        - properties:
            modulePattern: { enum: ['generic'] }
            moduleName:
              title: Module Name
              type: string
```

### Skeleton Structure with Conditionals

```java
// skeleton/modules/{{ values.moduleName }}/internal/domain/{{ values.moduleName | capitalize }}Entity.java

{% if values.modulePattern == 'clinical' %}
// FHIR-aligned entity structure
@Entity
@Table(name = "{{ values.moduleName }}_resources", schema = "clinical")
public class {{ values.moduleName | capitalize }}Entity {
    // FHIR-specific fields
    @Column(name = "fhir_resource_type")
    private String fhirResourceType;
    // ...
}
{% elif values.modulePattern == 'billing' %}
// PM-JAY/NHCX aligned entity
@Entity
@Table(name = "{{ values.moduleName }}_records", schema = "billing")
public class {{ values.moduleName | capitalize }}Entity {
    {% if values.includePmJay %}
    @Column(name = "beneficiary_id")
    private String beneficiaryId;
    {% endif %}
    {% if values.includeNhcx %}
    @Column(name = "nhcx_bundle_id")
    private String nhcxBundleId;
    {% endif %}
    // ...
}
{% else %}
// Generic entity structure
@Entity
@Table(name = "{{ values.moduleName }}_items", schema = "{{ values.moduleName }}")
public class {{ values.moduleName | capitalize }}Entity {
    // Generic fields
    // ...
}
{% endif %}
```

---

## Why Single Template Works Better

### 1. All Modules Share Same Structure
- ✅ Spring Modulith pattern (api/internal)
- ✅ Core Kernel integration
- ✅ RLS policies
- ✅ Audit columns
- ✅ Compliance fields

### 2. Differences Are Configuration, Not Structure
- ✅ Clinical: FHIR resource types
- ✅ Billing: PM-JAY/NHCX flags
- ✅ Inventory: FEFO/batch tracking flags
- ✅ All handled by parameters + conditionals

### 3. Easier to Maintain
- ✅ Fix bug once → applies to all modules
- ✅ Add feature once → available to all
- ✅ Consistent patterns → easier onboarding

### 4. Matches Composable-Monolithic Strategy
- ✅ Single template.yaml (composable UI)
- ✅ Single skeleton/ (monolithic source)
- ✅ Nunjucks conditionals (pattern-specific code)
- ✅ Pattern selection (user experience)

---

## Implementation Plan

### Phase 3: Enhanced Single Template

**Instead of creating separate templates, enhance the existing one:**

1. **Add Pattern Selection** to template.yaml
   - Clinical, Billing, Inventory, Laboratory, ABDM, Generic
   - Pattern-specific parameters (oneOf)

2. **Add Domain-Specific Examples** to skeleton
   - Clinical: Patient CRUD example
   - Billing: Invoice generation example
   - Inventory: Stock management example
   - Wrapped in Nunjucks conditionals

3. **Add Domain-Specific Schema Templates**
   - Clinical: FHIR-aligned schema
   - Billing: PM-JAY/NHCX schema
   - Inventory: FEFO/batch schema
   - Selected based on pattern

4. **Add Domain-Specific Documentation**
   - Pattern-specific README sections
   - Domain-specific examples
   - Pattern-specific best practices

---

## Decision Matrix

| Criteria | Single Template | Separate Templates |
|----------|----------------|-------------------|
| **Maintainability** | ✅ High (one place) | ❌ Low (10+ places) |
| **Consistency** | ✅ High (same structure) | ❌ Low (drift over time) |
| **Flexibility** | ✅ High (pattern selection) | ✅ High (domain-specific) |
| **Complexity** | ⚠️ Medium (more conditionals) | ❌ High (more templates) |
| **Developer Experience** | ✅ Good (pattern selection) | ⚠️ OK (template selection) |
| **Matches Strategy** | ✅ Yes (Composable-Monolithic) | ❌ No (separate templates) |

---

## Final Recommendation

**Use ONE template with pattern-based selection:**

✅ **Single `template.yaml`** with pattern selection (oneOf)  
✅ **Single `skeleton/` directory** with Nunjucks conditionals  
✅ **Pattern-specific parameters** (clinical, billing, inventory, etc.)  
✅ **Domain-specific examples** (wrapped in conditionals)  
✅ **Shared structure** (api/internal, Core Kernel integration)  

**Benefits:**
- Easier to maintain
- Consistent across all modules
- Matches Composable-Monolithic strategy
- Better developer experience
- Less code duplication

**This is the recommended approach per the Backstage Golden Path strategy.**

---

## Next Steps

1. ✅ Enhance existing template.yaml with pattern selection
2. ✅ Add domain-specific parameters (oneOf)
3. ✅ Add domain-specific examples to skeleton (Nunjucks conditionals)
4. ✅ Add domain-specific schema templates
5. ✅ Test with different patterns

---

**Answer**: **No, we don't need separate templates. Use ONE template with pattern selection.**

