package com.hims.modules.clinical.internal.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.hims.core.audit.LogAudit;
import com.hims.core.events.EventPublisher;
import com.hims.core.events.EventMetadata;
import com.hims.core.tenant.TenantContext;
import com.hims.modules.clinical.api.dto.PatientDTO;
import com.hims.modules.clinical.internal.domain.Patient;
import com.hims.modules.clinical.internal.repo.PatientRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Patient Service
 * 
 * Business logic for patient management.
 * Integrates with Core Kernel for tenant isolation, audit logging, and event publishing.
 */
@Service
@Transactional
public class PatientService {

    private final PatientRepository patientRepository;
    private final EventPublisher eventPublisher;
    private final ObjectMapper objectMapper;

    public PatientService(
            PatientRepository patientRepository,
            EventPublisher eventPublisher,
            ObjectMapper objectMapper) {
        this.patientRepository = patientRepository;
        this.eventPublisher = eventPublisher;
        this.objectMapper = objectMapper;
    }

    /**
     * Register a new patient.
     * 
     * This method:
     * 1. Validates input
     * 2. Maps DTO to Entity
     * 3. Saves to database
     * 4. Verifies RLS auto-populates tenant_id
     * 5. Publishes event
     * 
     * @param dto Patient registration data
     * @return Registered patient entity
     */
    @LogAudit(
        action = "REGISTER_PATIENT",
        resourceType = "PATIENT",
        description = "Register new patient"
    )
    public Patient registerPatient(PatientDTO dto) {
        // Validate MRN uniqueness per tenant
        patientRepository.findByMrn(dto.getMrn())
            .ifPresent(existing -> {
                throw new IllegalArgumentException("Patient with MRN " + dto.getMrn() + " already exists");
            });

        // Map DTO to Entity
        Patient patient = new Patient();
        patient.setMrn(dto.getMrn());
        patient.setGender(Patient.Gender.valueOf(dto.getGender().toLowerCase()));
        patient.setBirthDate(dto.getBirthDate());
        patient.setIsActive(true);

        // Map JSON fields
        try {
            patient.setName(objectMapper.writeValueAsString(dto.getName()));
            if (dto.getTelecom() != null) {
                patient.setTelecom(objectMapper.writeValueAsString(dto.getTelecom()));
            }
            if (dto.getAddress() != null) {
                patient.setAddress(objectMapper.writeValueAsString(dto.getAddress()));
            }
            if (dto.getMaritalStatus() != null) {
                patient.setMaritalStatus(objectMapper.writeValueAsString(dto.getMaritalStatus()));
            }
            if (dto.getContacts() != null) {
                patient.setContacts(objectMapper.writeValueAsString(dto.getContacts()));
            }
            if (dto.getCommunication() != null) {
                patient.setCommunication(objectMapper.writeValueAsString(dto.getCommunication()));
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to serialize patient data", e);
        }

        // Set optional fields
        patient.setPhotoUrl(dto.getPhotoUrl());
        patient.setAbhaNumber(dto.getAbhaNumber());
        patient.setAbhaAddress(dto.getAbhaAddress());
        patient.setManagingOrganization(dto.getManagingOrganization());
        if (dto.getGeneralPractitionerId() != null) {
            patient.setGeneralPractitionerId(UUID.fromString(dto.getGeneralPractitionerId()));
        }
        if (dto.getEncryptionKeyId() != null) {
            patient.setEncryptionKeyId(UUID.fromString(dto.getEncryptionKeyId()));
        }
        if (dto.getConsentRef() != null) {
            patient.setConsentRef(UUID.fromString(dto.getConsentRef()));
        }
        if (dto.getDataSovereigntyTag() != null) {
            patient.setDataSovereigntyTag(Patient.DataSovereigntyRegion.valueOf(dto.getDataSovereigntyTag()));
        }

        // Extract phone from telecom for search
        if (dto.getTelecom() != null && !dto.getTelecom().isEmpty()) {
            dto.getTelecom().stream()
                .filter(t -> "phone".equals(t.getSystem()))
                .findFirst()
                .ifPresent(t -> patient.setSearchPhone(t.getValue()));
        }

        // Save patient (RLS will auto-populate tenant_id)
        Patient saved = patientRepository.save(patient);

        // Verify tenant_id was set (RLS enforcement)
        if (saved.getTenantId() == null) {
            throw new IllegalStateException("Tenant ID was not set by RLS. This should never happen.");
        }

        // Publish event
        eventPublisher.publish(
            "clinical.patient.created",
            Map.of(
                "patientId", saved.getId().toString(),
                "mrn", saved.getMrn(),
                "tenantId", saved.getTenantId().toString()
            ),
            EventMetadata.create()
                .withTenant(TenantContext.getTenantId())
                .withUser(TenantContext.getUserId())
                .build()
        );

        return saved;
    }

    /**
     * Get patient by ID.
     * 
     * RLS ensures only patients for current tenant are returned.
     * 
     * @param patientId Patient UUID
     * @return Patient entity
     */
    @LogAudit(
        action = "GET_PATIENT",
        resourceType = "PATIENT",
        description = "Get patient by ID"
    )
    @Transactional(readOnly = true)
    public Patient getPatient(UUID patientId) {
        return patientRepository.findById(patientId)
            .orElseThrow(() -> new IllegalArgumentException("Patient not found: " + patientId));
    }

    /**
     * Search patients by name.
     * 
     * Uses the generated search_name column for efficient searching.
     * RLS ensures only patients for current tenant are returned.
     * 
     * @param name Name to search for
     * @return List of matching patients
     */
    @LogAudit(
        action = "SEARCH_PATIENTS",
        resourceType = "PATIENT",
        description = "Search patients by name"
    )
    @Transactional(readOnly = true)
    public List<Patient> searchPatientsByName(String name) {
        return patientRepository.searchByName(name);
    }
}

