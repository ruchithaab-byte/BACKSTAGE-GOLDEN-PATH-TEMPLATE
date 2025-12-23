package com.hims.modules.abdm.internal.domain;

import com.hims.core.tenant.TenantContext;
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
 * ABDM Care Context Entity
 * 
 * Represents a care context linked to ABDM (Ayushman Bharat Digital Mission).
 * Supports M2: Health Record Linking (Care Context) workflow.
 * 
 * This entity is part of the ABDM module and follows the Core Kernel patterns:
 * - Tenant isolation via tenant_id
 * - Audit columns (created_at, updated_at, created_by, updated_by)
 * - Compliance fields (encryption_key_id, data_sovereignty_tag, consent_ref)
 * - RLS policies enforce tenant isolation at database level
 */
@Entity
@Table(name = "care_contexts", schema = "abdm")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CareContext {
    
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
    // PATIENT AND ENCOUNTER REFERENCES (Soft FK - no cross-schema joins)
    // ============================================================================
    @Column(name = "patient_id", nullable = false)
    private UUID patientId; // Soft FK to clinical.patients(id)
    
    @Column(name = "encounter_id")
    private UUID encounterId; // Soft FK to clinical.encounters(id)
    
    // ============================================================================
    // CARE CONTEXT DETAILS (ABDM M2)
    // ============================================================================
    @Column(name = "care_context_reference", nullable = false, unique = true, length = 255)
    private String careContextReference; // ABDM Care Context ID (unique)
    
    @Column(name = "care_context_type", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private CareContextType careContextType; // "OPD", "IPD", "Emergency", "Diagnostic"
    
    // ============================================================================
    // LINKING STATUS
    // ============================================================================
    @Column(name = "linking_status", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private LinkingStatus linkingStatus = LinkingStatus.PENDING;
    
    @Column(name = "linked_at")
    private OffsetDateTime linkedAt;
    
    @Column(name = "delinked_at")
    private OffsetDateTime delinkedAt;
    
    @Column(name = "delink_reason", columnDefinition = "TEXT")
    private String delinkReason;
    
    // ============================================================================
    // ABDM GATEWAY INTEGRATION
    // ============================================================================
    @Column(name = "abdm_request_id", length = 255)
    private String abdmRequestId; // ABDM transaction ID
    
    @Column(name = "notification_sent_date")
    private OffsetDateTime notificationSentDate;
    
    @Column(name = "notification_status", length = 50)
    @Enumerated(EnumType.STRING)
    private NotificationStatus notificationStatus; // "sent", "delivered", "failed", "pending"
    
    @Column(name = "abdm_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object abdmResponse; // Full ABDM gateway response (JSONB)
    
    @Column(name = "abdm_error_code", length = 50)
    private String abdmErrorCode;
    
    @Column(name = "abdm_error_message", columnDefinition = "TEXT")
    private String abdmErrorMessage;
    
    // ============================================================================
    // HIP (Health Information Provider) DETAILS
    // ============================================================================
    @Column(name = "hip_id", length = 255)
    private String hipId; // Facility acting as HIP (HFR ID)
    
    @Column(name = "hip_name", length = 255)
    private String hipName;
    
    // ============================================================================
    // METADATA
    // ============================================================================
    @Column(name = "metadata", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object metadata; // Additional ABDM-specific metadata
    
    // ============================================================================
    // ENUMS
    // ============================================================================
    public enum CareContextType {
        OPD,
        IPD,
        Emergency,
        Diagnostic,
        Other
    }
    
    public enum LinkingStatus {
        PENDING,
        LINKED,
        DELINKED,
        FAILED
    }
    
    public enum NotificationStatus {
        PENDING,
        SENT,
        DELIVERED,
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

