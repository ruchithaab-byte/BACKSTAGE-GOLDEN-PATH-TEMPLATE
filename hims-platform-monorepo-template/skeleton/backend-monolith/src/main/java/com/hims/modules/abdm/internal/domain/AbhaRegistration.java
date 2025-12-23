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
 * ABHA Registration Entity
 * 
 * Represents an ABHA (Ayushman Bharat Health Account) registration/creation
 * request and tracking. Supports ABDM M1: ABHA Creation & Verification workflow.
 * 
 * This entity is part of the ABDM module and follows the Core Kernel patterns:
 * - Tenant isolation via tenant_id
 * - Audit columns (created_at, updated_at, created_by, updated_by)
 * - Compliance fields (encryption_key_id, data_sovereignty_tag, consent_ref)
 * - RLS policies enforce tenant isolation at database level
 */
@Entity
@Table(name = "abha_registrations", schema = "abdm")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AbhaRegistration {
    
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
    // PATIENT REFERENCE (Soft FK - no cross-schema joins)
    // ============================================================================
    @Column(name = "patient_id")
    private UUID patientId; // Soft FK to clinical.patients(id)
    
    // ============================================================================
    // ABHA DETAILS
    // ============================================================================
    @Column(name = "abha_number", length = 20)
    private String abhaNumber; // ABHA number (14 digits)
    
    @Column(name = "abha_address", length = 100)
    private String abhaAddress; // ABHA address (username@abdm)
    
    // ============================================================================
    // CREATION METHOD
    // ============================================================================
    @Column(name = "creation_method", nullable = false, length = 50)
    @Enumerated(EnumType.STRING)
    private CreationMethod creationMethod; // "aadhaar_otp", "mobile_otp", "biometric", "driving_license"
    
    @Column(name = "aadhaar_number", length = 12)
    private String aadhaarNumber; // Encrypted Aadhaar number (12 digits)
    
    @Column(name = "mobile_number", length = 10)
    private String mobileNumber; // Mobile number used for creation
    
    @Column(name = "driving_license_number", length = 50)
    private String drivingLicenseNumber; // Driving license number (if used)
    
    // ============================================================================
    // KYC STATUS
    // ============================================================================
    @Column(name = "kyc_status", length = 50)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private KYCStatus kycStatus = KYCStatus.PENDING;
    
    @Column(name = "kyc_verified_at")
    private OffsetDateTime kycVerifiedAt;
    
    @Column(name = "kyc_verification_method", length = 50)
    private String kycVerificationMethod; // "aadhaar", "mobile", "biometric", "driving_license"
    
    @Column(name = "kyc_failure_reason", columnDefinition = "TEXT")
    private String kycFailureReason; // Reason if KYC failed
    
    // ============================================================================
    // ABDM GATEWAY RESPONSE
    // ============================================================================
    @Column(name = "abdm_request_id", length = 255)
    private String abdmRequestId; // ABDM transaction ID
    
    @Column(name = "abdm_response", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object abdmResponse; // Full ABDM gateway response
    
    @Column(name = "abdm_error_code", length = 50)
    private String abdmErrorCode;
    
    @Column(name = "abdm_error_message", columnDefinition = "TEXT")
    private String abdmErrorMessage;
    
    // ============================================================================
    // STATUS
    // ============================================================================
    @Column(name = "status", length = 50)
    @Enumerated(EnumType.STRING)
    @Builder.Default
    private RegistrationStatus status = RegistrationStatus.PENDING;
    
    // ============================================================================
    // GUARDIAN ABHA (for minors)
    // ============================================================================
    @Column(name = "guardian_abha_number", length = 20)
    private String guardianAbhaNumber; // Guardian ABHA number
    
    @Column(name = "guardian_abha_address", length = 100)
    private String guardianAbhaAddress; // Guardian ABHA address
    
    @Column(name = "guardian_relationship", length = 50)
    private String guardianRelationship; // "parent", "guardian", "spouse"
    
    // ============================================================================
    // VERIFICATION DETAILS
    // ============================================================================
    @Column(name = "verified_at")
    private OffsetDateTime verifiedAt;
    
    @Column(name = "verified_by")
    private UUID verifiedBy; // Soft FK to core.users(id)
    
    @Column(name = "verification_method", length = 50)
    private String verificationMethod; // "otp", "biometric", "qr_scan"
    
    // ============================================================================
    // QR CODE
    // ============================================================================
    @Column(name = "qr_code_data", columnDefinition = "TEXT")
    private String qrCodeData; // QR code data/URL for ABHA
    
    @Column(name = "qr_code_generated_at")
    private OffsetDateTime qrCodeGeneratedAt;
    
    // ============================================================================
    // METADATA
    // ============================================================================
    @Column(name = "metadata", columnDefinition = "JSONB")
    @JdbcTypeCode(SqlTypes.JSON)
    private Object metadata; // Additional ABDM-specific metadata
    
    // ============================================================================
    // ENUMS
    // ============================================================================
    public enum CreationMethod {
        AADHAAR_OTP,
        MOBILE_OTP,
        BIOMETRIC,
        DRIVING_LICENSE
    }
    
    public enum KYCStatus {
        PENDING,
        VERIFIED,
        FAILED,
        IN_PROGRESS
    }
    
    public enum RegistrationStatus {
        PENDING,
        CREATED,
        FAILED,
        VERIFIED,
        EXPIRED
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

