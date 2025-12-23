package com.hims.modules.billing.internal.domain;

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
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;

/**
 * Pre-Authorization Entity (PM-JAY)
 * 
 * Represents a pre-authorization request for insurance claims, specifically
 * designed for PM-JAY (Pradhan Mantri Jan Arogya Yojana) workflow.
 * 
 * This entity is part of the billing module and follows the Core Kernel patterns:
 * - Tenant isolation via tenant_id
 * - Audit columns (created_at, updated_at, created_by, updated_by)
 * - Compliance fields (encryption_key_id, data_sovereignty_tag, consent_ref)
 * - RLS policies enforce tenant isolation at database level
 */
@Entity
@Table(name = "pre_authorizations", schema = "billing")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PreAuthorization {
    
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
    
    @Column(name = "insurance_policy_id")
    private UUID insurancePolicyId; // Soft FK to billing.insurance_policies(id)
    
    @Column(name = "patient_id", nullable = false)
    private UUID patientId; // Soft FK to clinical.patients(id)
    
    // ============================================================================
    // REQUEST DETAILS
    // ============================================================================
    @Column(name = "preauth_number", nullable = false, length = 50)
    private String preauthNumber; // Unique pre-auth number
    
    @Column(name = "request_date", nullable = false)
    @Builder.Default
    private LocalDate requestDate = LocalDate.now();
    
    @Column(name = "amount_requested", nullable = false, precision = 14, scale = 2)
    private BigDecimal amountRequested;
    
    // ============================================================================
    // DIAGNOSIS & PROCEDURE
    // ============================================================================
    @Column(name = "diagnosis_codes", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> diagnosisCodes; // ICD-10 codes array
    
    @Column(name = "procedure_codes", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> procedureCodes; // CPT/HCPCS codes array
    
    @Column(name = "package_code", length = 50)
    private String packageCode; // HBP 2.0 package code
    
    // ============================================================================
    // CLINICAL JUSTIFICATION
    // ============================================================================
    @Column(name = "clinical_justification", columnDefinition = "TEXT")
    private String clinicalJustification;
    
    @Column(name = "estimated_duration_days")
    private Integer estimatedDurationDays;
    
    // ============================================================================
    // STATUS
    // ============================================================================
    @Column(name = "status", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private PreAuthStatus status = PreAuthStatus.PENDING;
    
    // ============================================================================
    // PROCESSING (PPD - Processing Doctor)
    // ============================================================================
    @Column(name = "ppd_id")
    private UUID ppdId; // Processing Doctor ID (soft FK to clinical.practitioners(id))
    
    @Column(name = "ppd_remarks", columnDefinition = "TEXT")
    private String ppdRemarks;
    
    @Column(name = "ppd_reviewed_at")
    private OffsetDateTime ppdReviewedAt;
    
    // ============================================================================
    // MANDATORY DOCUMENTS
    // ============================================================================
    @Column(name = "mandatory_docs_uploaded", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> mandatoryDocsUploaded; // Checklist of uploaded documents
    
    @Column(name = "documents", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private List<String> documents; // Document references (paths/URLs)
    
    // ============================================================================
    // PM-JAY SPECIFIC FIELDS
    // ============================================================================
    @Column(name = "beneficiary_id", length = 50)
    private String beneficiaryId; // PM-JAY/SECC beneficiary ID
    
    @Column(name = "family_id", length = 50)
    private String familyId; // Family floater ID
    
    @Column(name = "scheme_code", length = 50)
    private String schemeCode; // "PM-JAY", "CGHS", "ECHS"
    
    // ============================================================================
    // ENHANCEMENT REQUEST TRACKING
    // ============================================================================
    @Column(name = "enhancement_request_count")
    @Builder.Default
    private Integer enhancementRequestCount = 0;
    
    @Column(name = "enhancement_request_reason", columnDefinition = "TEXT")
    private String enhancementRequestReason;
    
    @Column(name = "last_enhancement_request_date")
    private OffsetDateTime lastEnhancementRequestDate;
    
    // ============================================================================
    // APPROVAL DETAILS
    // ============================================================================
    @Column(name = "approved_amount", precision = 14, scale = 2)
    private BigDecimal approvedAmount;
    
    @Column(name = "approved_date")
    private LocalDate approvedDate;
    
    @Column(name = "approved_by")
    private UUID approvedBy; // Soft FK to core.users(id)
    
    @Column(name = "approval_remarks", columnDefinition = "TEXT")
    private String approvalRemarks;
    
    // ============================================================================
    // REJECTION DETAILS
    // ============================================================================
    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;
    
    @Column(name = "rejected_at")
    private OffsetDateTime rejectedAt;
    
    @Column(name = "rejected_by")
    private UUID rejectedBy; // Soft FK to core.users(id)
    
    // ============================================================================
    // QUERY DETAILS
    // ============================================================================
    @Column(name = "query_remarks", columnDefinition = "TEXT")
    private String queryRemarks;
    
    @Column(name = "query_raised_at")
    private OffsetDateTime queryRaisedAt;
    
    @Column(name = "query_raised_by")
    private UUID queryRaisedBy; // Soft FK to core.users(id)
    
    @Column(name = "query_resolved_at")
    private OffsetDateTime queryResolvedAt;
    
    // ============================================================================
    // NHCX INTEGRATION FIELDS
    // ============================================================================
    @Column(name = "nhcx_bundle_id", length = 255)
    private String nhcxBundleId; // NHCX bundle ID for claim processing
    
    @Column(name = "nhcx_request_id", length = 255)
    private String nhcxRequestId; // NHCX request ID
    
    @Column(name = "nhcx_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object nhcxResponse; // NHCX gateway response
    
    // ============================================================================
    // BIS (Beneficiary Identification System) INTEGRATION
    // ============================================================================
    @Column(name = "bis_verification_status", length = 50)
    @Enumerated(EnumType.STRING)
    private BISVerificationStatus bisVerificationStatus; // "pending", "verified", "failed"
    
    @Column(name = "bis_verification_date")
    private OffsetDateTime bisVerificationDate;
    
    @Column(name = "bis_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object bisResponse; // BIS verification response
    
    // ============================================================================
    // METADATA
    // ============================================================================
    @Column(name = "metadata", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object metadata; // Additional PM-JAY/NHCX metadata
    
    // ============================================================================
    // ENUMS
    // ============================================================================
    public enum PreAuthStatus {
        PENDING,
        APPROVED,
        REJECTED,
        QUERY,
        ENHANCEMENT_REQUESTED,
        CANCELLED
    }
    
    public enum BISVerificationStatus {
        PENDING,
        VERIFIED,
        FAILED
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
        if (requestDate == null) {
            requestDate = LocalDate.now();
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

