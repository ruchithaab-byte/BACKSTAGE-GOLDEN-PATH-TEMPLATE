package com.hims.modules.clinical.internal.domain;

import com.hims.core.tenant.TenantContext;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Patient Entity
 * 
 * Represents a patient in the clinical module.
 * 
 * Pattern: Clinical Module (FHIR-aligned)
 * - FHIR Patient resource mapping
 * - ABHA integration (ABHA number, ABHA address)
 * - Patient merge support
 * - Search optimization (search_name, search_phone)
 * 
 * Critical for patient care - all patient data must be properly isolated and audited.
 * 
 * Schema: clinical.patients
 * Composite Key: (tenant_id, id) - enforced by RLS policies
 */
@Entity
@Table(name = "patients", schema = "clinical")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Patient {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;
    
    // ============================================================================
    // TENANT ISOLATION (Core Kernel)
    // ============================================================================
    @Column(name = "tenant_id", nullable = false, updatable = false)
    private UUID tenantId;
    
    // ============================================================================
    // AUDIT COLUMNS (Core Kernel)
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
    // PATIENT IDENTITY
    // ============================================================================
    @Column(name = "mrn", nullable = false, length = 50)
    private String mrn; // Medical Record Number (unique per tenant)
    
    @Column(name = "identifiers", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    @Builder.Default
    private Object identifiers = "[]"; // FHIR Identifier array
    
    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;
    
    // ============================================================================
    // FHIR NAME STRUCTURE
    // ============================================================================
    @Column(name = "name", nullable = false, columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object name; // FHIR HumanName: {use, family, given[], prefix[], suffix[]}
    
    // ============================================================================
    // DEMOGRAPHICS
    // ============================================================================
    @Column(name = "gender", nullable = false, length = 20)
    private String gender; // FHIR gender enum: "male", "female", "other", "unknown"
    
    @Column(name = "birth_date", nullable = false)
    private LocalDate birthDate;
    
    @Column(name = "deceased", nullable = false)
    @Builder.Default
    private Boolean deceased = false;
    
    @Column(name = "deceased_date_time")
    private OffsetDateTime deceasedDateTime;
    
    // ============================================================================
    // CONTACT INFORMATION
    // ============================================================================
    @Column(name = "telecom", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    @Builder.Default
    private Object telecom = "[]"; // FHIR ContactPoint array: [{system, value, use}]
    
    @Column(name = "address", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    @Builder.Default
    private Object address = "[]"; // FHIR Address array
    
    @Column(name = "marital_status", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object maritalStatus; // FHIR CodeableConcept
    
    @Column(name = "photo_url", columnDefinition = "TEXT")
    private String photoUrl;
    
    // ============================================================================
    // RELATIONSHIPS
    // ============================================================================
    @Column(name = "contacts", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    @Builder.Default
    private Object contacts = "[]"; // FHIR PatientContact array
    
    @Column(name = "communication", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    @Builder.Default
    private Object communication = "[]"; // FHIR PatientCommunication array
    
    @Column(name = "general_practitioner_id")
    private UUID generalPractitionerId; // Soft FK to clinical.practitioners(id)
    
    @Column(name = "managing_organization", length = 255)
    private String managingOrganization; // Organization identifier
    
    // ============================================================================
    // ABHA INTEGRATION (ABDM)
    // ============================================================================
    @Column(name = "abha_number", length = 20)
    private String abhaNumber; // ABHA (Ayushman Bharat Health Account) number
    
    @Column(name = "abha_address", length = 100)
    private String abhaAddress; // ABHA address (e.g., "user@abdm")
    
    // ============================================================================
    // COMPLIANCE FIELDS (DPDP/HIPAA)
    // ============================================================================
    @Column(name = "encryption_key_id")
    private UUID encryptionKeyId;
    
    @Column(name = "data_sovereignty_tag", length = 50)
    @Builder.Default
    private String dataSovereigntyTag = "INDIA_LOCAL"; // "INDIA_LOCAL", "INDIA_GOVT", "EU_CENTRAL", "US_HIPAA"
    
    @Column(name = "consent_ref")
    private UUID consentRef; // FK to core.consent_logs(id)
    
    // ============================================================================
    // SEARCH OPTIMIZATION
    // ============================================================================
    @Column(name = "search_name", length = 500, insertable = false, updatable = false)
    private String searchName; // Generated column: family + ' ' + given[0]
    
    @Column(name = "search_phone", length = 20)
    private String searchPhone; // Extracted from telecom for search
    
    // ============================================================================
    // PATIENT MERGE SUPPORT
    // ============================================================================
    @Column(name = "merged_into_patient_id")
    private UUID mergedIntoPatientId; // If this patient was merged into another
    
    @Column(name = "merged_at")
    private OffsetDateTime mergedAt;
    
    @Column(name = "merged_by")
    private UUID mergedBy;
    
    // ============================================================================
    // LIFECYCLE CALLBACKS
    // ============================================================================
    @PrePersist
    protected void onCreate() {
        if (tenantId == null) {
            String tenantIdStr = TenantContext.getTenantId();
            if (tenantIdStr == null) {
                throw new IllegalStateException("Tenant context must be set");
            }
            tenantId = UUID.fromString(tenantIdStr);
        }
        if (createdAt == null) {
            createdAt = OffsetDateTime.now();
        }
        if (updatedAt == null) {
            updatedAt = OffsetDateTime.now();
        }
        if (createdBy == null) {
            String userIdStr = TenantContext.getUserId();
            if (userIdStr != null) {
                createdBy = UUID.fromString(userIdStr);
            }
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = OffsetDateTime.now();
        String userIdStr = TenantContext.getUserId();
        if (userIdStr != null) {
            updatedBy = UUID.fromString(userIdStr);
        }
    }
}

