package com.hims.modules.clinical.internal.domain;

import com.hims.core.tenant.TenantContext;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Discharge Summary Entity
 * 
 * Represents a discharge summary for a patient encounter, with PM-JAY STG
 * (Standard Treatment Guidelines) compliance tracking.
 * 
 * This entity is part of the clinical module and follows the Core Kernel patterns:
 * - Tenant isolation via tenant_id
 * - Audit columns (created_at, updated_at, created_by, updated_by)
 * - Compliance fields (encryption_key_id, data_sovereignty_tag, consent_ref)
 * - RLS policies enforce tenant isolation at database level
 */
@Entity
@Table(name = "discharge_summaries", schema = "clinical")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DischargeSummary {
    
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
    // COMPLIANCE FIELDS (DPDP/HIPAA)
    // ============================================================================
    @Column(name = "encryption_key_id")
    private String encryptionKeyId;
    
    @Column(name = "data_sovereignty_tag")
    private String dataSovereigntyTag;
    
    @Column(name = "consent_ref")
    private UUID consentRef;
    
    // ============================================================================
    // LINKS (Soft FK - no cross-schema joins)
    // ============================================================================
    @Column(name = "admission_id")
    private UUID admissionId; // Soft FK to clinical.encounters(id) for IPD
    
    @Column(name = "encounter_id")
    private UUID encounterId; // Soft FK to clinical.encounters(id)
    
    @Column(name = "patient_id", nullable = false)
    private UUID patientId; // Soft FK to clinical.patients(id)
    
    // ============================================================================
    // SUMMARY DETAILS
    // ============================================================================
    @Column(name = "summary_number", nullable = false, length = 50)
    private String summaryNumber; // Unique summary number
    
    @Column(name = "discharge_date", nullable = false)
    private LocalDate dischargeDate;
    
    @Column(name = "discharge_time")
    private LocalTime dischargeTime;
    
    // ============================================================================
    // DISCHARGE STATUS
    // ============================================================================
    @Column(name = "discharge_status", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private DischargeStatus dischargeStatus; // "stable", "referral", "death", "lama", "dama"
    
    @Column(name = "discharge_disposition", length = 100)
    private String dischargeDisposition; // "home", "transfer", "ama", "expired"
    
    // ============================================================================
    // DEATH DETAILS (if applicable)
    // ============================================================================
    @Column(name = "cause_of_death_icd10", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object causeOfDeathIcd10; // {coding: [{system: "ICD10", code: "...", display: "..."}]}
    
    @Column(name = "cause_of_death_text", columnDefinition = "TEXT")
    private String causeOfDeathText;
    
    @Column(name = "death_certificate_number", length = 100)
    private String deathCertificateNumber;
    
    // ============================================================================
    // CLINICAL SUMMARY
    // ============================================================================
    @Column(name = "admission_diagnosis", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> admissionDiagnosis; // Condition references (ICD-10 codes)
    
    @Column(name = "final_diagnosis", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> finalDiagnosis; // Final diagnosis codes
    
    @Column(name = "procedures_performed", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> proceduresPerformed; // Procedure codes (CPT/HCPCS)
    
    @Column(name = "course_of_treatment", columnDefinition = "TEXT")
    private String courseOfTreatment;
    
    @Column(name = "advice_on_discharge", columnDefinition = "TEXT")
    private String adviceOnDischarge;
    
    // ============================================================================
    // PM-JAY STG COMPLIANCE
    // ============================================================================
    @Column(name = "stg_adherence_checklist", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<Object> stgAdherenceChecklist; // [{guideline_id, guideline_name, adhered: true/false, remarks}]
    
    @Column(name = "stg_compliance_percentage", precision = 5, scale = 2)
    private BigDecimal stgCompliancePercentage; // Percentage of STG guidelines adhered to
    
    @Column(name = "stg_reviewed_by")
    private UUID stgReviewedBy; // Practitioner ID (soft FK)
    
    @Column(name = "stg_reviewed_at")
    private OffsetDateTime stgReviewedAt;
    
    // ============================================================================
    // MEDICATIONS ON DISCHARGE
    // ============================================================================
    @Column(name = "discharge_medications", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<Object> dischargeMedications; // MedicationRequest references
    
    // ============================================================================
    // FOLLOW-UP
    // ============================================================================
    @Column(name = "follow_up_required")
    @Builder.Default
    private Boolean followUpRequired = false;
    
    @Column(name = "follow_up_date")
    private LocalDate followUpDate;
    
    @Column(name = "follow_up_instructions", columnDefinition = "TEXT")
    private String followUpInstructions;
    
    // ============================================================================
    // REFERRAL
    // ============================================================================
    @Column(name = "referred_to_facility", length = 255)
    private String referredToFacility;
    
    @Column(name = "referral_reason", columnDefinition = "TEXT")
    private String referralReason;
    
    // ============================================================================
    // AUTHOR
    // ============================================================================
    @Column(name = "author_id", nullable = false)
    private UUID authorId; // Practitioner ID (soft FK)
    
    @Column(name = "co_author_ids", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<UUID> coAuthorIds; // Other practitioners (UUID array)
    
    // ============================================================================
    // STATUS
    // ============================================================================
    @Column(name = "status", length = 50)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private SummaryStatus status = SummaryStatus.DRAFT;
    
    @Column(name = "is_signed")
    @Builder.Default
    private Boolean isSigned = false;
    
    @Column(name = "signed_at")
    private OffsetDateTime signedAt;
    
    @Column(name = "signed_by")
    private UUID signedBy; // Soft FK to core.users(id)
    
    // ============================================================================
    // ABDM INTEGRATION
    // ============================================================================
    @Column(name = "care_context_id")
    private UUID careContextId; // Soft FK to abdm.care_contexts(id)
    
    @Column(name = "linked_to_abdm")
    @Builder.Default
    private Boolean linkedToAbdm = false;
    
    // ============================================================================
    // METADATA
    // ============================================================================
    @Column(name = "metadata", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object metadata; // Additional clinical metadata
    
    // ============================================================================
    // ENUMS
    // ============================================================================
    public enum DischargeStatus {
        STABLE,
        REFERRAL,
        DEATH,
        LAMA, // Left Against Medical Advice
        DAMA  // Discharged Against Medical Advice
    }
    
    public enum SummaryStatus {
        DRAFT,
        FINAL,
        AMENDED
    }
    
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
        if (dischargeDate == null) {
            dischargeDate = LocalDate.now();
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

