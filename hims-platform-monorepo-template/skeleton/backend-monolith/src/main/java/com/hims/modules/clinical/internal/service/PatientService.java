package com.hims.modules.clinical.internal.service;

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

/**
 * Patient Service Implementation
 * 
 * Pattern: Clinical Module
 * - Patient registration
 * - Patient search
 * - Patient updates
 * - ABHA integration
 */
@Service
public class PatientService {

    private final PatientRepository repository;
    private final EventPublisher eventPublisher;

    public PatientService(
            PatientRepository repository,
            EventPublisher eventPublisher) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
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
     * @return Created patient entity
     */
    @LogAudit(
        action = "CREATE_PATIENT",
        resourceType = "PATIENT",
        description = "Register new patient"
    )
    @Transactional
    public Patient registerPatient(PatientDTO dto) {
        String tenantId = TenantContext.getTenantId();
        String userId = TenantContext.getUserId();
        
        if (tenantId == null) {
            throw new IllegalStateException("Tenant context must be set");
        }
        
        // Check if MRN already exists
        UUID tenantUuid = UUID.fromString(tenantId);
        repository.findByTenantIdAndMrn(tenantUuid, dto.getMrn())
            .ifPresent(existing -> {
                throw new IllegalArgumentException("Patient with MRN " + dto.getMrn() + " already exists");
            });
        
        // Map DTO to Entity
        Patient patient = Patient.builder()
            .mrn(dto.getMrn())
            .name(dto.getName())
            .gender(dto.getGender())
            .birthDate(dto.getBirthDate())
            .telecom(dto.getTelecom())
            .address(dto.getAddress())
            .maritalStatus(dto.getMaritalStatus())
            .abhaNumber(dto.getAbhaNumber())
            .abhaAddress(dto.getAbhaAddress())
            .generalPractitionerId(dto.getGeneralPractitionerId())
            .managingOrganization(dto.getManagingOrganization())
            .isActive(true)
            .build();
        
        // Save to database
        // RLS will automatically enforce tenant_id
        Patient saved = repository.save(patient);
        
        // Verify tenant_id was set correctly
        if (!saved.getTenantId().toString().equals(tenantId)) {
            throw new IllegalStateException("Tenant ID mismatch - RLS may not be working correctly");
        }
        
        // Publish event
        eventPublisher.publish(
            "clinical.patient.created",
            Map.of(
                "patientId", saved.getId().toString(),
                "mrn", saved.getMrn(),
                "tenantId", tenantId
            ),
            EventMetadata.create()
                .withTenant(tenantId)
                .withUser(userId)
                .build()
        );
        
        return saved;
    }

    /**
     * Get patient by ID.
     * 
     * @param patientId Patient ID
     * @return Patient entity
     */
    @LogAudit(
        action = "GET_PATIENT",
        resourceType = "PATIENT",
        description = "Get patient by ID"
    )
    @Transactional(readOnly = true)
    public Patient getPatient(UUID patientId) {
        String tenantId = TenantContext.getTenantId();
        if (tenantId == null) {
            throw new IllegalStateException("Tenant context must be set");
        }
        
        return repository.findById(patientId)
            .filter(p -> p.getTenantId().toString().equals(tenantId))
            .orElseThrow(() -> new IllegalArgumentException("Patient not found"));
    }

    /**
     * Search patients by name.
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
        String tenantId = TenantContext.getTenantId();
        if (tenantId == null) {
            throw new IllegalStateException("Tenant context must be set");
        }
        
        return repository.findByNameContaining(UUID.fromString(tenantId), name);
    }
}

