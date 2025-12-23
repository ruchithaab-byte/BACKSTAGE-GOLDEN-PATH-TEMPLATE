package com.hims.modules.clinical.internal.web;

import com.hims.core.audit.LogAudit;
import com.hims.modules.clinical.api.dto.PatientDTO;
import com.hims.modules.clinical.internal.domain.Patient;
import com.hims.modules.clinical.internal.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * Patient REST Controller
 * 
 * Pattern: Clinical Module
 * - Patient registration
 * - Patient retrieval
 * - Patient search
 */
@RestController
@RequestMapping("/api/v1/patients")
public class PatientController {

    private final PatientService patientService;

    public PatientController(PatientService patientService) {
        this.patientService = patientService;
    }

    /**
     * Register a new patient.
     * 
     * POST /api/v1/patients
     * 
     * Input: PatientDTO
     * Logic: Validate -> Map to Entity -> Save to DB
     * Verify: RLS auto-populates tenant_id
     * 
     * @param dto Patient registration data
     * @return Created patient
     */
    @PostMapping
    @LogAudit(
        action = "CREATE_PATIENT",
        resourceType = "PATIENT",
        description = "Register new patient via API"
    )
    public ResponseEntity<Patient> registerPatient(@Valid @RequestBody PatientDTO dto) {
        Patient patient = patientService.registerPatient(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(patient);
    }

    /**
     * Get patient by ID.
     * 
     * GET /api/v1/patients/{id}
     * 
     * @param id Patient ID
     * @return Patient entity
     */
    @GetMapping("/{id}")
    @LogAudit(
        action = "GET_PATIENT",
        resourceType = "PATIENT",
        description = "Get patient by ID via API"
    )
    public ResponseEntity<Patient> getPatient(@PathVariable UUID id) {
        Patient patient = patientService.getPatient(id);
        return ResponseEntity.ok(patient);
    }

    /**
     * Search patients by name.
     * 
     * GET /api/v1/patients/search?name={name}
     * 
     * @param name Name to search for
     * @return List of matching patients
     */
    @GetMapping("/search")
    @LogAudit(
        action = "SEARCH_PATIENTS",
        resourceType = "PATIENT",
        description = "Search patients by name via API"
    )
    public ResponseEntity<List<Patient>> searchPatients(@RequestParam String name) {
        List<Patient> patients = patientService.searchPatientsByName(name);
        return ResponseEntity.ok(patients);
    }

    /**
     * Health check endpoint.
     * 
     * @return Health status
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("patient service is healthy");
    }
}

