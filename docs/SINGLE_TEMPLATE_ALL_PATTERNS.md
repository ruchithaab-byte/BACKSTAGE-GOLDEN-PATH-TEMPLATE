# Single Template with All Patterns - How It Works

## Answer: YES ✅

**You can have ALL patterns (clinical, billing, inventory, etc.) in ONE template.**

This is exactly what the **Composable-Monolithic Hybrid** strategy does!

---

## How It Works

### 1. Single template.yaml with Pattern Selection

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: hims-platform-module
  title: HIMS Platform Module
  description: Create a new module for the HIMS Platform (supports all domain patterns)

spec:
  parameters:
    # Step 1: Basic Module Info
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
            - clinical      # FHIR-aligned clinical module
            - billing      # PM-JAY/NHCX billing module
            - inventory    # FEFO/batch inventory module
            - laboratory   # LIMS laboratory module
            - abdm         # ABDM integration module
            - generic      # Generic module (default)
          description: Select the domain pattern for this module
          default: generic

    # Step 2: Pattern-Specific Configuration (oneOf)
    dependencies:
      modulePattern:
        oneOf:
          # --- CLINICAL PATTERN ---
          - properties:
              modulePattern:
                enum: ['clinical']
              fhirResourceTypes:
                title: FHIR Resource Types
                type: array
                items:
                  type: string
                  enum: ['Patient', 'Encounter', 'Observation', 'Condition', 'MedicationRequest']
                default: ['Patient', 'Encounter', 'Observation']
                description: Select FHIR resource types to scaffold
              includeComplianceFields:
                type: boolean
                const: true  # Always true for clinical
                description: Compliance fields are always included for clinical modules
          
          # --- BILLING PATTERN ---
          - properties:
              modulePattern:
                enum: ['billing']
              includePmJay:
                title: Include PM-JAY Support
                type: boolean
                default: true
                description: Include PM-JAY specific fields and workflows
              includeNhcx:
                title: Include NHCX Integration
                type: boolean
                default: true
                description: Include NHCX (National Health Claims Exchange) fields
              includePreAuth:
                title: Include Pre-Authorization Workflow
                type: boolean
                default: true
                description: Include pre-authorization table and workflow
          
          # --- INVENTORY PATTERN ---
          - properties:
              modulePattern:
                enum: ['inventory']
              includeFefo:
                title: Include FEFO Support
                type: boolean
                default: true
                description: First Expiry First Out (FEFO) batch tracking
              includeBatchTracking:
                title: Include Batch Tracking
                type: boolean
                default: true
                description: Track batches, lot numbers, and expiry dates
              includeSoftFkToClinical:
                title: Link to Clinical Module
                type: boolean
                default: true
                description: Add soft FK references to clinical.patients/prescriptions
          
          # --- LABORATORY PATTERN ---
          - properties:
              modulePattern:
                enum: ['laboratory']
              includeSampleTracking:
                title: Include Sample Collection Tracking
                type: boolean
                default: true
                description: LIMS sample collection workflow
              includeQcTracking:
                title: Include QC Tracking
                type: boolean
                default: true
                description: Quality control tracking
              includeMachineInterface:
                title: Include Machine Interface
                type: boolean
                default: true
                description: Bi-directional machine interface support
          
          # --- ABDM PATTERN ---
          - properties:
              modulePattern:
                enum: ['abdm']
              abdmWorkflows:
                title: ABDM Workflows
                type: array
                items:
                  type: string
                  enum: ['M1_ABHA_Creation', 'M2_Care_Context_Linking', 'M3_Consent_Management']
                default: ['M1_ABHA_Creation', 'M2_Care_Context_Linking']
                description: Select ABDM workflows to scaffold
          
          # --- GENERIC PATTERN (default) ---
          - properties:
              modulePattern:
                enum: ['generic']
              # No additional fields needed for generic pattern

  steps:
    - id: fetch-skeleton
      name: Fetch Skeleton
      action: fetch:template
      input:
        url: ./skeleton
        values:
          # Pass all parameters
          moduleName: ${{ parameters.moduleName }}
          modulePattern: ${{ parameters.modulePattern }}
          
          # Pattern-specific values (passed conditionally)
          fhirResourceTypes: ${{ parameters.fhirResourceTypes }}
          includePmJay: ${{ parameters.includePmJay }}
          includeNhcx: ${{ parameters.includeNhcx }}
          includeFefo: ${{ parameters.includeFefo }}
          # ... etc
```

---

## 2. Single skeleton/ Directory with Nunjucks Conditionals

### Example: Entity File with All Patterns

```java
// skeleton/modules/{{ values.moduleName }}/internal/domain/{{ values.moduleName | capitalize }}Entity.java

package com.hims.modules.{{ values.moduleName }}.internal.domain;

import com.hims.core.tenant.TenantContextHolder;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * {{ values.moduleName | capitalize }} Entity
 * 
 * {% if values.modulePattern == 'clinical' %}
 * Clinical module entity - FHIR-aligned.
 * Supports FHIR resource types: {{ values.fhirResourceTypes | join(', ') }}
 * {% elif values.modulePattern == 'billing' %}
 * Billing module entity - PM-JAY/NHCX compliant.
 * {% if values.includePmJay %}PM-JAY support enabled.{% endif %}
 * {% if values.includeNhcx %}NHCX integration enabled.{% endif %}
 * {% elif values.modulePattern == 'inventory' %}
 * Inventory module entity - FEFO and batch tracking.
 * {% if values.includeFefo %}FEFO support enabled.{% endif %}
 * {% if values.includeBatchTracking %}Batch tracking enabled.{% endif %}
 * {% elif values.modulePattern == 'laboratory' %}
 * Laboratory module entity - LIMS support.
 * {% elif values.modulePattern == 'abdm' %}
 * ABDM integration module entity.
 * {% else %}
 * Generic module entity.
 * {% endif %}
 */
@Entity
@Table(name = "{{ values.moduleName }}_items", schema = "{{ values.moduleName }}")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class {{ values.moduleName | capitalize }}Entity {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;
    
    // ============================================================================
    // TENANT ISOLATION (Core Kernel - All Patterns)
    // ============================================================================
    @Column(name = "tenant_id", nullable = false, updatable = false)
    private UUID tenantId;
    
    // ============================================================================
    // AUDIT COLUMNS (Core Kernel - All Patterns)
    // ============================================================================
    @Column(name = "created_at", nullable = false, updatable = false)
    @Builder.Default
    private OffsetDateTime createdAt = OffsetDateTime.now();
    
    @Column(name = "updated_at", nullable = false)
    @Builder.Default
    private OffsetDateTime updatedAt = OffsetDateTime.now();
    
    @Column(name = "created_by")
    private UUID createdBy;
    
    @Column(name = "updated_by")
    private UUID updatedBy;
    
    // ============================================================================
    // COMPLIANCE FIELDS (All Patterns - Conditional)
    // ============================================================================
    {% if values.includeComplianceFields or values.modulePattern == 'clinical' %}
    @Column(name = "encryption_key_id")
    private String encryptionKeyId;
    
    @Column(name = "data_sovereignty_tag")
    private String dataSovereigntyTag;
    
    @Column(name = "consent_ref")
    private UUID consentRef;
    {% endif %}
    
    // ============================================================================
    // PATTERN-SPECIFIC FIELDS
    // ============================================================================
    
    {% if values.modulePattern == 'clinical' %}
    // --- CLINICAL PATTERN: FHIR Fields ---
    @Column(name = "fhir_resource_type", length = 50)
    private String fhirResourceType; // e.g., "Patient", "Encounter", "Observation"
    
    @Column(name = "fhir_resource_id", length = 255)
    private String fhirResourceId; // FHIR resource ID
    
    @Column(name = "fhir_resource", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object fhirResource; // Full FHIR resource (JSONB)
    
    {% elif values.modulePattern == 'billing' %}
    // --- BILLING PATTERN: PM-JAY/NHCX Fields ---
    {% if values.includePmJay %}
    @Column(name = "beneficiary_id", length = 50)
    private String beneficiaryId; // PM-JAY beneficiary ID
    
    @Column(name = "family_id", length = 50)
    private String familyId; // Family floater ID
    
    @Column(name = "scheme_code", length = 50)
    private String schemeCode; // "PM-JAY", "CGHS", "ECHS"
    {% endif %}
    
    {% if values.includeNhcx %}
    @Column(name = "nhcx_bundle_id", length = 255)
    private String nhcxBundleId; // NHCX bundle ID
    
    @Column(name = "nhcx_request_id", length = 255)
    private String nhcxRequestId; // NHCX request ID
    
    @Column(name = "nhcx_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object nhcxResponse; // NHCX gateway response
    {% endif %}
    
    {% if values.includePreAuth %}
    @Column(name = "preauth_number", length = 50)
    private String preauthNumber; // Pre-authorization number
    {% endif %}
    
    {% elif values.modulePattern == 'inventory' %}
    // --- INVENTORY PATTERN: FEFO/Batch Fields ---
    {% if values.includeFefo %}
    @Column(name = "expiry_date")
    private java.time.LocalDate expiryDate; // For FEFO sorting
    
    @Column(name = "manufacturing_date")
    private java.time.LocalDate manufacturingDate;
    {% endif %}
    
    {% if values.includeBatchTracking %}
    @Column(name = "batch_number", length = 100)
    private String batchNumber; // Lot/batch number
    
    @Column(name = "lot_number", length = 100)
    private String lotNumber; // Alternative lot identifier
    {% endif %}
    
    {% if values.includeSoftFkToClinical %}
    @Column(name = "prescription_id")
    private UUID prescriptionId; // Soft FK to clinical.prescriptions
    {% endif %}
    
    {% elif values.modulePattern == 'laboratory' %}
    // --- LABORATORY PATTERN: LIMS Fields ---
    {% if values.includeSampleTracking %}
    @Column(name = "sample_number", length = 50)
    private String sampleNumber; // Unique sample number
    
    @Column(name = "barcode", length = 100)
    private String barcode; // Sample barcode
    
    @Column(name = "collection_date")
    private OffsetDateTime collectionDate;
    {% endif %}
    
    {% if values.includeQcTracking %}
    @Column(name = "qc_status", length = 50)
    private String qcStatus; // "pending", "passed", "failed"
    
    @Column(name = "qc_date")
    private OffsetDateTime qcDate;
    {% endif %}
    
    {% if values.includeMachineInterface %}
    @Column(name = "machine_id", length = 100)
    private String machineId; // Lab machine identifier
    
    @Column(name = "machine_interface_status", length = 50)
    private String machineInterfaceStatus; // "pending", "sent", "processed"
    {% endif %}
    
    {% elif values.modulePattern == 'abdm' %}
    // --- ABDM PATTERN: ABDM Integration Fields ---
    @Column(name = "abdm_request_id", length = 255)
    private String abdmRequestId; // ABDM transaction ID
    
    @Column(name = "abdm_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object abdmResponse; // ABDM gateway response
    
    {% if 'M1_ABHA_Creation' in values.abdmWorkflows %}
    @Column(name = "abha_number", length = 20)
    private String abhaNumber; // ABHA number
    
    @Column(name = "abha_address", length = 100)
    private String abhaAddress; // ABHA address
    {% endif %}
    
    {% if 'M2_Care_Context_Linking' in values.abdmWorkflows %}
    @Column(name = "care_context_reference", length = 255)
    private String careContextReference; // ABDM care context ID
    
    @Column(name = "linking_status", length = 50)
    private String linkingStatus; // "pending", "linked", "delinked"
    {% endif %}
    
    {% else %}
    // --- GENERIC PATTERN: Basic Fields ---
    @Column(name = "name", length = 255)
    private String name;
    
    @Column(name = "description", columnDefinition = "TEXT")
    private String description;
    {% endif %}
    
    // ============================================================================
    // METADATA (All Patterns)
    // ============================================================================
    @Column(name = "metadata", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object metadata;
    
    // ============================================================================
    // LIFECYCLE CALLBACKS (All Patterns)
    // ============================================================================
    @PrePersist
    protected void onCreate() {
        if (tenantId == null) {
            tenantId = TenantContextHolder.getContext()
                .map(ctx -> ctx.getTenantId())
                .orElseThrow(() -> new IllegalStateException("Tenant context must be set"));
        }
        if (createdAt == null) {
            createdAt = OffsetDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = OffsetDateTime.now();
        }
        if (createdBy == null) {
            createdBy = TenantContextHolder.getContext()
                .map(ctx -> ctx.getUserId())
                .orElse(null);
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now();
        updatedBy = TenantContextHolder.getContext()
            .map(ctx -> ctx.getUserId())
            .orElse(null);
    }
}
```

---

## 3. Pattern-Specific Service Examples

```java
// skeleton/modules/{{ values.moduleName }}/internal/service/{{ values.moduleName | capitalize }}Service.java

{% if values.modulePattern == 'clinical' %}
// Clinical-specific service methods
public PatientDto createPatient(PatientCreateDto dto) {
    // FHIR resource creation
    // ...
}

{% elif values.modulePattern == 'billing' %}
// Billing-specific service methods
{% if values.includePmJay %}
public PreAuthorizationDto createPreAuth(PreAuthCreateDto dto) {
    // PM-JAY pre-authorization workflow
    // ...
}
{% endif %}

{% elif values.modulePattern == 'inventory' %}
// Inventory-specific service methods
{% if values.includeFefo %}
public List<ItemDto> getItemsByFefo(UUID locationId) {
    // FEFO sorting logic
    // ...
}
{% endif %}

{% else %}
// Generic service methods
public void createExample() {
    // Generic implementation
    // ...
}
{% endif %}
```

---

## 4. Pattern-Specific Schema Templates

```sql
-- skeleton/backend-monolith/src/main/resources/db/migration/V001__create_{{ values.moduleName }}_schema.sql

{% if values.modulePattern == 'clinical' %}
-- Clinical schema with FHIR support
CREATE TABLE {{ values.moduleName }}.resources (
    -- FHIR-specific columns
    fhir_resource_type VARCHAR(50),
    fhir_resource_id VARCHAR(255),
    fhir_resource JSONB,
    -- ...
);

{% elif values.modulePattern == 'billing' %}
-- Billing schema with PM-JAY/NHCX support
CREATE TABLE {{ values.moduleName }}.records (
    {% if values.includePmJay %}
    beneficiary_id VARCHAR(50),
    family_id VARCHAR(50),
    scheme_code VARCHAR(50),
    {% endif %}
    {% if values.includeNhcx %}
    nhcx_bundle_id VARCHAR(255),
    nhcx_request_id VARCHAR(255),
    {% endif %}
    -- ...
);

{% elif values.modulePattern == 'inventory' %}
-- Inventory schema with FEFO/batch tracking
CREATE TABLE {{ values.moduleName }}.items (
    {% if values.includeFefo %}
    expiry_date DATE,
    manufacturing_date DATE,
    {% endif %}
    {% if values.includeBatchTracking %}
    batch_number VARCHAR(100),
    lot_number VARCHAR(100),
    {% endif %}
    -- ...
);

{% else %}
-- Generic schema
CREATE TABLE {{ values.moduleName }}.items (
    name VARCHAR(255),
    description TEXT,
    -- ...
);
{% endif %}
```

---

## Benefits of Single Template with All Patterns

### ✅ User Experience
- **One template to learn** - consistent across all domains
- **Pattern selection in UI** - feels composable
- **Conditional questions** - only see relevant fields

### ✅ Maintenance
- **Single source of truth** - fix once, applies to all
- **Consistent structure** - all modules follow same pattern
- **Shared code** - Core Kernel integration in one place

### ✅ Flexibility
- **Easy to add new patterns** - just add to oneOf
- **Easy to modify patterns** - update conditionals
- **Easy to test** - test all patterns in one template

---

## File Structure

```
hims-platform-monorepo-template/
├── template.yaml                    # ONE template with all patterns
└── skeleton/                        # ONE skeleton with conditionals
    ├── modules/
    │   └── {{ values.moduleName }}/
    │       ├── api/
    │       └── internal/
    │           ├── domain/
    │           │   └── {{ values.moduleName | capitalize }}Entity.java
    │           │       {% if values.modulePattern == 'clinical' %}...{% endif %}
    │           ├── service/
    │           │   └── {{ values.moduleName | capitalize }}Service.java
    │           │       {% if values.modulePattern == 'clinical' %}...{% endif %}
    │           └── ...
    └── db/migration/
        └── V001__create_{{ values.moduleName }}_schema.sql
            {% if values.modulePattern == 'clinical' %}...{% endif %}
```

---

## Summary

**YES, you can have ALL patterns in ONE template!**

**How:**
1. ✅ Single `template.yaml` with pattern selection (oneOf)
2. ✅ Single `skeleton/` directory with Nunjucks conditionals
3. ✅ Pattern-specific code wrapped in `{% if %}` blocks
4. ✅ User selects pattern → template generates domain-specific code

**This is the Composable-Monolithic Hybrid strategy - exactly what we should do!**

---

**Next Step**: Enhance the existing template with pattern selection instead of creating separate templates.

