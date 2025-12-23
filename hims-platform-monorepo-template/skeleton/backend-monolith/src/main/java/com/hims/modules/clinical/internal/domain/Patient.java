package com.hims.modules.clinical.internal.domain;

import com.hims.core.tenant.TenantContext;
import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.LocalDate;
import java.time.OffsetDateTime;
import java.util.UUID;

/**
 * Patient Entity
 * 
 * Represents a patient in the clinical module.
 * Matches the clinical.patients table schema exactly.
 * 
 * Features:
 * - FHIR-aligned structure (name, telecom, address as JSONB)
 * - ABHA integration (abha_number, abha_address)
 * - Patient merge support
 * - Search optimization (search_name, search_phone)
 * - Compliance fields (encryption_key_id, data_sovereignty_tag, consent_ref)
 * - Tenant isolation via RLS
 * - Audit columns (created_at, updated_at, created_by, updated_by)
 */
@Entity
@Table(name = "patients", schema = "clinical")
public class Patient {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(name = "id", updatable = false, nullable = false)
    private UUID id;

    @Column(name = "tenant_id", nullable = false, updatable = false)
    private UUID tenantId;

    @Column(name = "mrn", length = 50, nullable = false)
    private String mrn;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "identifiers", columnDefinition = "jsonb DEFAULT '[]'::jsonb")
    private String identifiers = "[]";

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "name", nullable = false, columnDefinition = "jsonb")
    private String name; // FHIR HumanName as JSON

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "telecom", columnDefinition = "jsonb DEFAULT '[]'::jsonb")
    private String telecom = "[]"; // FHIR ContactPoint[] as JSON

    // PostgreSQL enum - stored as string, converted in SQL
    @Enumerated(EnumType.STRING)
    @Column(name = "gender", nullable = false)
    @org.hibernate.annotations.ColumnTransformer(
        read = "gender::text",
        write = "?::public.fhir_gender"
    )
    private Gender gender;

    @Column(name = "birth_date", nullable = false)
    private LocalDate birthDate;

    @Column(name = "deceased", nullable = false)
    private Boolean deceased = false;

    @Column(name = "deceased_date_time")
    private OffsetDateTime deceasedDateTime;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "address", columnDefinition = "jsonb DEFAULT '[]'::jsonb")
    private String address = "[]"; // FHIR Address[] as JSON

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "marital_status", columnDefinition = "jsonb")
    private String maritalStatus;

    @Column(name = "photo_url")
    private String photoUrl;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "contacts", columnDefinition = "jsonb DEFAULT '[]'::jsonb")
    private String contacts = "[]";

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "communication", columnDefinition = "jsonb DEFAULT '[]'::jsonb")
    private String communication = "[]";

    @Column(name = "general_practitioner_id")
    private UUID generalPractitionerId;

    @Column(name = "managing_organization", length = 255)
    private String managingOrganization;

    @Column(name = "abha_number", length = 20)
    private String abhaNumber;

    @Column(name = "abha_address", length = 100)
    private String abhaAddress;

    @Column(name = "encryption_key_id")
    private UUID encryptionKeyId;

    // PostgreSQL enum - stored as string, converted in SQL
    @Enumerated(EnumType.STRING)
    @Column(name = "data_sovereignty_tag", nullable = false)
    @org.hibernate.annotations.ColumnTransformer(
        read = "data_sovereignty_tag::text",
        write = "?::public.data_sovereignty_region"
    )
    private DataSovereigntyRegion dataSovereigntyTag = DataSovereigntyRegion.INDIA_LOCAL;

    @Column(name = "consent_ref")
    private UUID consentRef;

    @Column(name = "search_name", length = 500, insertable = false, updatable = false)
    private String searchName; // Generated column

    @Column(name = "search_phone", length = 20)
    private String searchPhone;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "created_by")
    private UUID createdBy;

    @Column(name = "updated_by")
    private UUID updatedBy;

    @Column(name = "merged_into_patient_id")
    private UUID mergedIntoPatientId;

    @Column(name = "merged_at")
    private OffsetDateTime mergedAt;

    @Column(name = "merged_by")
    private UUID mergedBy;

    public enum Gender {
        male, female, other, unknown
    }

    // Must match PostgreSQL enum: public.data_sovereignty_region
    public enum DataSovereigntyRegion {
        INDIA_LOCAL, INDIA_GOVT, EU_CENTRAL, US_HIPAA
    }

    @PrePersist
    protected void onCreate() {
        if (tenantId == null) {
            tenantId = UUID.fromString(TenantContext.getTenantId());
        }
        if (createdBy == null && TenantContext.getUserId() != null) {
            createdBy = UUID.fromString(TenantContext.getUserId());
        }
        if (updatedBy == null && TenantContext.getUserId() != null) {
            updatedBy = UUID.fromString(TenantContext.getUserId());
        }
        OffsetDateTime now = OffsetDateTime.now();
        createdAt = now;
        updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        if (updatedBy == null && TenantContext.getUserId() != null) {
            updatedBy = UUID.fromString(TenantContext.getUserId());
        }
        updatedAt = OffsetDateTime.now();
    }

    // Getters and Setters
    public UUID getId() { return id; }
    public void setId(UUID id) { this.id = id; }
    public UUID getTenantId() { return tenantId; }
    public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }
    public String getMrn() { return mrn; }
    public void setMrn(String mrn) { this.mrn = mrn; }
    public String getIdentifiers() { return identifiers; }
    public void setIdentifiers(String identifiers) { this.identifiers = identifiers; }
    public Boolean getIsActive() { return isActive; }
    public void setIsActive(Boolean isActive) { this.isActive = isActive; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getTelecom() { return telecom; }
    public void setTelecom(String telecom) { this.telecom = telecom; }
    public Gender getGender() { return gender; }
    public void setGender(Gender gender) { this.gender = gender; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public Boolean getDeceased() { return deceased; }
    public void setDeceased(Boolean deceased) { this.deceased = deceased; }
    public OffsetDateTime getDeceasedDateTime() { return deceasedDateTime; }
    public void setDeceasedDateTime(OffsetDateTime deceasedDateTime) { this.deceasedDateTime = deceasedDateTime; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getMaritalStatus() { return maritalStatus; }
    public void setMaritalStatus(String maritalStatus) { this.maritalStatus = maritalStatus; }
    public String getPhotoUrl() { return photoUrl; }
    public void setPhotoUrl(String photoUrl) { this.photoUrl = photoUrl; }
    public String getContacts() { return contacts; }
    public void setContacts(String contacts) { this.contacts = contacts; }
    public String getCommunication() { return communication; }
    public void setCommunication(String communication) { this.communication = communication; }
    public UUID getGeneralPractitionerId() { return generalPractitionerId; }
    public void setGeneralPractitionerId(UUID generalPractitionerId) { this.generalPractitionerId = generalPractitionerId; }
    public String getManagingOrganization() { return managingOrganization; }
    public void setManagingOrganization(String managingOrganization) { this.managingOrganization = managingOrganization; }
    public String getAbhaNumber() { return abhaNumber; }
    public void setAbhaNumber(String abhaNumber) { this.abhaNumber = abhaNumber; }
    public String getAbhaAddress() { return abhaAddress; }
    public void setAbhaAddress(String abhaAddress) { this.abhaAddress = abhaAddress; }
    public UUID getEncryptionKeyId() { return encryptionKeyId; }
    public void setEncryptionKeyId(UUID encryptionKeyId) { this.encryptionKeyId = encryptionKeyId; }
    public DataSovereigntyRegion getDataSovereigntyTag() { return dataSovereigntyTag; }
    public void setDataSovereigntyTag(DataSovereigntyRegion dataSovereigntyTag) { this.dataSovereigntyTag = dataSovereigntyTag; }
    public UUID getConsentRef() { return consentRef; }
    public void setConsentRef(UUID consentRef) { this.consentRef = consentRef; }
    public String getSearchName() { return searchName; }
    public void setSearchName(String searchName) { this.searchName = searchName; }
    public String getSearchPhone() { return searchPhone; }
    public void setSearchPhone(String searchPhone) { this.searchPhone = searchPhone; }
    public OffsetDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(OffsetDateTime createdAt) { this.createdAt = createdAt; }
    public OffsetDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(OffsetDateTime updatedAt) { this.updatedAt = updatedAt; }
    public UUID getCreatedBy() { return createdBy; }
    public void setCreatedBy(UUID createdBy) { this.createdBy = createdBy; }
    public UUID getUpdatedBy() { return updatedBy; }
    public void setUpdatedBy(UUID updatedBy) { this.updatedBy = updatedBy; }
    public UUID getMergedIntoPatientId() { return mergedIntoPatientId; }
    public void setMergedIntoPatientId(UUID mergedIntoPatientId) { this.mergedIntoPatientId = mergedIntoPatientId; }
    public OffsetDateTime getMergedAt() { return mergedAt; }
    public void setMergedAt(OffsetDateTime mergedAt) { this.mergedAt = mergedAt; }
    public UUID getMergedBy() { return mergedBy; }
    public void setMergedBy(UUID mergedBy) { this.mergedBy = mergedBy; }
}

