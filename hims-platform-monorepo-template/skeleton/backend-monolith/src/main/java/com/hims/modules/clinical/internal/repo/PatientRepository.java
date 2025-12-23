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
 * Patient Repository
 * 
 * Provides data access for Patient entities.
 * All queries automatically filter by tenant_id via RLS policies.
 */
@Repository
public interface PatientRepository extends JpaRepository<Patient, UUID> {

    /**
     * Find patient by MRN (unique per tenant).
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.mrn = :mrn AND p.isActive = true")
    Optional<Patient> findByMrn(@Param("mrn") String mrn);

    /**
     * Find all active patients for current tenant.
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.isActive = true ORDER BY p.createdAt DESC")
    List<Patient> findActivePatients();

    /**
     * Search patients by name (using generated search_name column).
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.searchName ILIKE %:name% AND p.isActive = true ORDER BY p.searchName")
    List<Patient> searchByName(@Param("name") String name);

    /**
     * Search patients by phone number.
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.searchPhone = :phone AND p.isActive = true")
    List<Patient> findByPhone(@Param("phone") String phone);

    /**
     * Find patient by ABHA number.
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.abhaNumber = :abhaNumber AND p.isActive = true")
    Optional<Patient> findByAbhaNumber(@Param("abhaNumber") String abhaNumber);

    /**
     * Find patient by ABHA address.
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.abhaAddress = :abhaAddress AND p.isActive = true")
    Optional<Patient> findByAbhaAddress(@Param("abhaAddress") String abhaAddress);

    /**
     * Find merged patients (patients that have been merged into another patient).
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.mergedIntoPatientId IS NOT NULL")
    List<Patient> findMergedPatients();

    /**
     * Find patients by general practitioner ID.
     * RLS ensures only patients for current tenant are returned.
     */
    @Query("SELECT p FROM Patient p WHERE p.generalPractitionerId = :practitionerId AND p.isActive = true")
    List<Patient> findByGeneralPractitionerId(@Param("practitionerId") UUID practitionerId);
}

