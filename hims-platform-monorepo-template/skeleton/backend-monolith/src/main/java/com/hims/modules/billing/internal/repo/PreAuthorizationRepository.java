package com.hims.modules.billing.internal.repo;

import com.hims.modules.billing.internal.domain.PreAuthorization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for Pre-Authorization entities.
 * 
 * This repository provides access to pre-authorization data with automatic
 * tenant isolation via RLS policies at the database level.
 * 
 * All queries are automatically filtered by tenant_id through RLS.
 */
@Repository
public interface PreAuthorizationRepository extends JpaRepository<PreAuthorization, UUID> {
    
    /**
     * Find pre-authorization by pre-auth number (unique per tenant).
     * 
     * @param preauthNumber Pre-auth number
     * @return Optional pre-authorization
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.preauthNumber = :number")
    Optional<PreAuthorization> findByPreauthNumber(@Param("number") String preauthNumber);
    
    /**
     * Find all pre-authorizations for a patient.
     * 
     * @param patientId Patient ID (soft FK)
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.patientId = :patientId ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByPatientId(@Param("patientId") UUID patientId);
    
    /**
     * Find all pre-authorizations for an encounter.
     * 
     * @param encounterId Encounter ID (soft FK)
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.encounterId = :encounterId ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByEncounterId(@Param("encounterId") UUID encounterId);
    
    /**
     * Find all pre-authorizations for an admission (IPD).
     * 
     * @param admissionId Admission ID (soft FK)
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.admissionId = :admissionId ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByAdmissionId(@Param("admissionId") UUID admissionId);
    
    /**
     * Find pre-authorizations by status.
     * 
     * @param status Pre-authorization status
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.status = :status ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByStatus(@Param("status") PreAuthorization.PreAuthStatus status);
    
    /**
     * Find pre-authorizations by beneficiary ID (PM-JAY).
     * 
     * @param beneficiaryId Beneficiary ID
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.beneficiaryId = :beneficiaryId ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByBeneficiaryId(@Param("beneficiaryId") String beneficiaryId);
    
    /**
     * Find pre-authorizations by NHCX bundle ID.
     * 
     * @param nhcxBundleId NHCX bundle ID
     * @return Optional pre-authorization
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.nhcxBundleId = :bundleId")
    Optional<PreAuthorization> findByNhcBundleId(@Param("bundleId") String nhcxBundleId);
    
    /**
     * Find pre-authorizations by PPD (Processing Doctor) ID.
     * 
     * @param ppdId Processing Doctor ID
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.ppdId = :ppdId ORDER BY pa.createdAt DESC")
    List<PreAuthorization> findByPpdId(@Param("ppdId") UUID ppdId);
    
    /**
     * Find pre-authorizations by date range.
     * 
     * @param startDate Start date
     * @param endDate End date
     * @return List of pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.requestDate BETWEEN :startDate AND :endDate ORDER BY pa.requestDate DESC")
    List<PreAuthorization> findByRequestDateBetween(
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate
    );
    
    /**
     * Count pre-authorizations by status for a patient.
     * 
     * @param patientId Patient ID
     * @param status Pre-authorization status
     * @return Count
     */
    @Query("SELECT COUNT(pa) FROM PreAuthorization pa WHERE pa.patientId = :patientId AND pa.status = :status")
    long countByPatientIdAndStatus(
        @Param("patientId") UUID patientId,
        @Param("status") PreAuthorization.PreAuthStatus status
    );
    
    /**
     * Find pending pre-authorizations requiring PPD review.
     * 
     * @return List of pending pre-authorizations
     */
    @Query("SELECT pa FROM PreAuthorization pa WHERE pa.status = 'PENDING' OR pa.status = 'QUERY' ORDER BY pa.createdAt ASC")
    List<PreAuthorization> findPendingForReview();
}

