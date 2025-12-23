# Phase 3 Skeleton Strategy - ULTRA THINK

## Challenge: Conditional Module Creation

**Problem**: Nunjucks processes ALL files in skeleton. We need to create modules conditionally based on checkboxes.

**Current Structure**:
```
skeleton/modules/
├── {{ values.moduleName }}/  (generic template)
├── clinical/                 (hardcoded - always created)
├── billing/                  (hardcoded - always created)
└── abdm/                     (hardcoded - always created)
```

**Target Structure**:
```
skeleton/modules/
├── {% if values.includeClinicalModule %}clinical/{% endif %}
├── {% if values.includeBillingModule %}billing/{% endif %}
├── {% if values.includeInventoryModule %}inventory/{% endif %}
└── ... (all 13 modules conditional)
```

## Solution: Nunjucks File Path Conditionals

**Key Insight**: In Backstage templates, Nunjucks processes file paths AND file contents.

**Approach 1: Conditional File Creation (Recommended)**
- Create module files with conditional paths
- Use Nunjucks to conditionally include files
- Files are only created if condition is true

**Approach 2: Conditional Content**
- Always create module directories
- Use conditionals in file contents to include/exclude code
- Simpler but creates empty directories

**Best Approach**: Hybrid
- Use conditional file creation for module structure
- Use conditional content for pattern-specific code

## Implementation Plan

### Step 1: Create Conditional Module Directories

For each module, create a conditional structure:

```
skeleton/modules/
├── {% if values.includeClinicalModule %}
│   └── clinical/
│       ├── api/
│       └── internal/
│   {% endif %}
├── {% if values.includeBillingModule %}
│   └── billing/
│       ├── api/
│       └── internal/
│   {% endif %}
```

**But wait**: Nunjucks doesn't support conditional directory creation directly in file paths.

### Actual Solution: Conditional File Creation

**Strategy**: Create files conditionally using Nunjucks in file names or use a different approach.

**Better Strategy**: Use the generic template `{{ values.moduleName }}/` and create module-specific instances.

**Best Strategy**: Create module-specific directories that are always present, but use conditionals in file contents to control what gets generated.

Actually, the simplest approach:
1. Keep generic template `{{ values.moduleName }}/` for custom modules
2. Create specific module directories (clinical, billing, etc.) that are conditionally populated
3. Use Nunjucks conditionals in file contents to include/exclude code

## Revised Strategy

### Approach: Module-Specific Directories with Conditional Content

1. **Create module directories** (always present in skeleton)
2. **Use conditionals in file contents** to control code generation
3. **Use pattern-specific code** based on module name

**Structure**:
```
skeleton/modules/
├── clinical/              (always exists)
│   ├── api/
│   └── internal/
│       ├── domain/
│       │   └── ClinicalEntity.java  (with pattern-specific code)
│       └── service/
│           └── ClinicalService.java (with pattern-specific code)
├── billing/               (always exists)
│   └── ... (same structure)
└── {{ values.moduleName }}/  (generic template)
```

**File Contents Use Conditionals**:
```java
// ClinicalEntity.java
{% if values.includeClinicalModule %}
// Clinical-specific code here
{% endif %}
```

**Problem**: This creates empty directories even when modules aren't selected.

## Best Solution: Conditional File Creation via Nunjucks

**Key**: Backstage's fetch:template processes files, not directories. We can use Nunjucks to conditionally create files.

**Strategy**: 
1. Create module files with conditional logic
2. Files are only included if condition is true
3. Directories are created automatically when files are included

**Implementation**:
- Use Nunjucks conditionals in file paths (if supported)
- OR use conditional file inclusion in template processing

Actually, the correct approach for Backstage:
- Files in skeleton are processed by Nunjucks
- We can't conditionally exclude entire directories
- But we CAN conditionally include/exclude file contents
- Empty directories won't be created if no files are in them

**Final Strategy**:
1. Create module-specific files conditionally
2. Use pattern-specific code in file contents
3. Files only created if checkbox is true (via conditional file naming or content)

## Implementation Details

### For Each Module (e.g., clinical):

1. **Create module structure files**:
   - `modules/clinical/api/spi/ClinicalServiceProvider.java`
   - `modules/clinical/internal/domain/ClinicalEntity.java`
   - `modules/clinical/internal/service/ClinicalService.java`
   - etc.

2. **Wrap file contents in conditionals**:
   ```java
   {% if values.includeClinicalModule %}
   // Clinical module code here
   {% endif %}
   ```

3. **Add pattern-specific code**:
   ```java
   {% if values.includeClinicalModule %}
   {% if values.clinicalPattern == 'fhir-aligned' %}
   // FHIR-specific code
   {% else %}
   // Basic clinical code
   {% endif %}
   {% endif %}
   ```

## Next Steps

1. Create module-specific directories for all 13 modules
2. Add conditional content to each module's files
3. Add pattern-specific code based on module type
4. Test with multiple modules selected

