package com.hims.modules.clinical.internal.web;

import com.hims.core.authz.RequirePermission;
import com.hims.modules.clinical.api.dto.PatientDTO;
import com.hims.modules.clinical.internal.domain.Patient;
import com.hims.modules.clinical.internal.service.PatientService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

/**
 * Patient REST Controller
 * 
 * Provides REST API endpoints for patient management.
 * 
 * Endpoints:
 * - POST /api/v1/patients - Register new patient
 * - GET /api/v1/patients/{id} - Get patient by ID
 * - GET /api/v1/patients/search?name={name} - Search patients by name
 * - GET /api/v1/patients/health - Health check
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
     * @param dto Patient registration data
     * @return Created patient
     */
    @PostMapping
    @RequirePermission(action = "create", resource = "patient")
    public ResponseEntity<Patient> registerPatient(@Valid @RequestBody PatientDTO dto) {
        Patient patient = patientService.registerPatient(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(patient);
    }

    /**
     * Get patient by ID.
     * 
     * @param id Patient UUID
     * @return Patient entity
     */
    @GetMapping("/{id}")
    @RequirePermission(action = "read", resource = "patient", resourceIdParam = "id")
    public ResponseEntity<Patient> getPatient(@PathVariable UUID id) {
        Patient patient = patientService.getPatient(id);
        return ResponseEntity.ok(patient);
    }

    /**
     * Search patients by name.
     * 
     * @param name Name to search for
     * @return List of matching patients
     */
    @GetMapping("/search")
    @RequirePermission(action = "read", resource = "patient")
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
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "healthy", "service", "clinical"));
    }
}

