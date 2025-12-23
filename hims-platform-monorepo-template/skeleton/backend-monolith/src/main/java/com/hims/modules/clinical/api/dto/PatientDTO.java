package com.hims.modules.clinical.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.util.UUID;

/**
 * Patient Data Transfer Object
 * 
 * Used for patient registration and updates.
 * 
 * Pattern: Clinical Module
 * - Input validation
 * - FHIR-aligned structure
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PatientDTO {
    
    private String mrn; // Medical Record Number
    
    private Object name; // FHIR HumanName JSON
    
    private String gender; // "male", "female", "other", "unknown"
    
    private LocalDate birthDate;
    
    private Object telecom; // FHIR ContactPoint array JSON
    
    private Object address; // FHIR Address array JSON
    
    private Object maritalStatus; // FHIR CodeableConcept JSON
    
    private String abhaNumber; // ABHA number (optional)
    
    private String abhaAddress; // ABHA address (optional)
    
    private UUID generalPractitionerId; // Soft FK to practitioners
    
    private String managingOrganization; // Organization identifier
}

