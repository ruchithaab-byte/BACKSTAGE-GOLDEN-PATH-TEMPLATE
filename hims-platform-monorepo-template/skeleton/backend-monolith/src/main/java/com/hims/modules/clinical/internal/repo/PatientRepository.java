package com.hims.modules.clinical.internal.repo;

import com.hims.modules.clinical.internal.domain.Patient;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for Patient entity.
 * 
 * Pattern: Clinical Module
 * - Patient queries by MRN, name, phone
 * - Search optimization queries
 * - Active patients only
 */
@Repository
public interface PatientRepository extends JpaRepository<Patient, UUID> {
    
    // Tenant isolation
    List<Patient> findByTenantId(UUID tenantId);
    
    // Find by MRN (unique per tenant)
    Optional<Patient> findByTenantIdAndMrn(UUID tenantId, String mrn);
    
    // Find active patients
    List<Patient> findByTenantIdAndIsActive(UUID tenantId, Boolean isActive);
    
    // Search by name (using generated search_name column)
    @Query("SELECT p FROM Patient p WHERE p.tenantId = :tenantId AND LOWER(p.searchName) LIKE LOWER(CONCAT('%', :name, '%')) AND p.isActive = true")
    List<Patient> findByNameContaining(@Param("tenantId") UUID tenantId, @Param("name") String name);
    
    // Search by phone
    List<Patient> findByTenantIdAndSearchPhone(UUID tenantId, String searchPhone);
    
    // Find by ABHA number
    Optional<Patient> findByTenantIdAndAbhaNumber(UUID tenantId, String abhaNumber);
    
    // Find by ABHA address
    Optional<Patient> findByTenantIdAndAbhaAddress(UUID tenantId, String abhaAddress);
    
    // Find merged patients
    @Query("SELECT p FROM Patient p WHERE p.tenantId = :tenantId AND p.mergedIntoPatientId IS NOT NULL")
    List<Patient> findMergedPatients(@Param("tenantId") UUID tenantId);
    
    // Find by general practitioner
    List<Patient> findByTenantIdAndGeneralPractitionerId(UUID tenantId, UUID generalPractitionerId);
}

