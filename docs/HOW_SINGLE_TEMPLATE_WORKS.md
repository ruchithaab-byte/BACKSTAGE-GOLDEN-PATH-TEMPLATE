# How Single Template with All Patterns Works

## ✅ YES - All Patterns in ONE Template

This is exactly how the **Composable-Monolithic Hybrid** strategy works!

---

## Visual Example

### What the User Sees (Backstage UI)

```
Step 1: Module Configuration
├── Module Name: [clinical]
└── Module Pattern: [Dropdown]
    ├── clinical      ← User selects this
    ├── billing
    ├── inventory
    ├── laboratory
    ├── abdm
    └── generic

Step 2: Pattern-Specific Configuration (Shown based on selection)
└── If "clinical" selected:
    ├── FHIR Resource Types: [Patient, Encounter, Observation]
    └── Compliance Fields: ✅ (always enabled)

Step 3: Generate Module
└── Creates: modules/clinical/ with FHIR-aligned code
```

---

## How It Works Technically

### 1. Single template.yaml

```yaml
parameters:
  - title: Module Configuration
    properties:
      moduleName:
        title: Module Name
        type: string
      
      modulePattern:
        title: Module Pattern
        type: string
        enum:
          - clinical      # All patterns in ONE enum
          - billing
          - inventory
          - laboratory
          - abdm
          - generic

  # Pattern-specific fields (oneOf)
  dependencies:
    modulePattern:
      oneOf:
        # Clinical pattern fields
        - properties:
            modulePattern: { enum: ['clinical'] }
            fhirResourceTypes: [...]
        
        # Billing pattern fields
        - properties:
            modulePattern: { enum: ['billing'] }
            includePmJay: true
            includeNhcx: true
        
        # Inventory pattern fields
        - properties:
            modulePattern: { enum: ['inventory'] }
            includeFefo: true
            includeBatchTracking: true
        
        # ... all other patterns
```

### 2. Single skeleton/ with Conditionals

```java
// ONE file with ALL patterns
// skeleton/modules/{{ values.moduleName }}/internal/domain/Entity.java

@Entity
public class {{ values.moduleName | capitalize }}Entity {
    
    // Common fields (ALL patterns)
    private UUID id;
    private UUID tenantId;
    private OffsetDateTime createdAt;
    
    // Pattern-specific fields (conditional)
    {% if values.modulePattern == 'clinical' %}
    // Clinical code here
    private String fhirResourceType;
    {% elif values.modulePattern == 'billing' %}
    // Billing code here
    {% if values.includePmJay %}
    private String beneficiaryId;
    {% endif %}
    {% elif values.modulePattern == 'inventory' %}
    // Inventory code here
    {% if values.includeFefo %}
    private LocalDate expiryDate;
    {% endif %}
    {% else %}
    // Generic code here
    private String name;
    {% endif %}
}
```

---

## Real-World Example

### User Creates Clinical Module

**User selects:**
- Module Name: `clinical`
- Module Pattern: `clinical`
- FHIR Resource Types: `[Patient, Encounter, Observation]`

**Template generates:**
```java
// Only clinical code is generated
@Entity
public class ClinicalEntity {
    private UUID id;
    private UUID tenantId;
    private String fhirResourceType;  // ← Clinical-specific
    private String fhirResourceId;     // ← Clinical-specific
}
```

### User Creates Billing Module

**User selects:**
- Module Name: `billing`
- Module Pattern: `billing`
- Include PM-JAY: `true`
- Include NHCX: `true`

**Template generates:**
```java
// Only billing code is generated
@Entity
public class BillingEntity {
    private UUID id;
    private UUID tenantId;
    private String beneficiaryId;      // ← Billing-specific (PM-JAY)
    private String nhcxBundleId;       // ← Billing-specific (NHCX)
}
```

**Same template, different output based on pattern selection!**

---

## File Structure (All in ONE Template)

```
hims-platform-module-template/
├── template.yaml                    # ONE file with all patterns
│   ├── modulePattern enum: [clinical, billing, inventory, ...]
│   └── dependencies.oneOf: [clinical fields, billing fields, ...]
│
└── skeleton/                        # ONE directory with conditionals
    └── modules/{{ values.moduleName }}/
        ├── api/
        └── internal/
            ├── domain/
            │   └── Entity.java      # ONE file with {% if %} blocks
            ├── service/
            │   └── Service.java     # ONE file with {% if %} blocks
            └── ...
```

---

## Benefits

### ✅ Single Source of Truth
- One template to maintain
- One skeleton directory
- Fix bug once → applies to all patterns

### ✅ Consistent Structure
- All modules follow same Spring Modulith pattern
- Same Core Kernel integration
- Same RLS policies, audit columns

### ✅ Easy to Extend
- Add new pattern → add to enum + oneOf
- Add new field → add conditional in skeleton
- Test all patterns in one template

### ✅ Better Developer Experience
- Pattern selection in UI (feels composable)
- Only see relevant fields
- One template to learn

---

## Summary

**YES - All patterns can be in ONE template!**

**How:**
1. ✅ Single `template.yaml` with pattern enum
2. ✅ `dependencies.oneOf` for pattern-specific fields
3. ✅ Single `skeleton/` with Nunjucks conditionals
4. ✅ User selects pattern → template generates domain-specific code

**This is the Composable-Monolithic Hybrid strategy - exactly what we should implement!**

---

**Next**: Enhance the existing template to add pattern selection instead of creating separate templates.

