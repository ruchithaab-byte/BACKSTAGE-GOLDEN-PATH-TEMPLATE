package com.hims.modules.abdm.internal.repo;

import com.hims.modules.abdm.internal.domain.CareContext;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ABDM Care Context entities.
 * 
 * This repository provides access to care context data with automatic
 * tenant isolation via RLS policies at the database level.
 * 
 * All queries are automatically filtered by tenant_id through RLS.
 */
@Repository
public interface CareContextRepository extends JpaRepository<CareContext, UUID> {
    
    /**
     * Find care context by ABDM care context reference (unique per tenant).
     * 
     * @param careContextReference ABDM care context reference
     * @return Optional care context
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.careContextReference = :reference")
    Optional<CareContext> findByCareContextReference(@Param("reference") String careContextReference);
    
    /**
     * Find all care contexts for a patient.
     * 
     * @param patientId Patient ID (soft FK)
     * @return List of care contexts
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.patientId = :patientId ORDER BY cc.createdAt DESC")
    List<CareContext> findByPatientId(@Param("patientId") UUID patientId);
    
    /**
     * Find all care contexts for an encounter.
     * 
     * @param encounterId Encounter ID (soft FK)
     * @return List of care contexts
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.encounterId = :encounterId ORDER BY cc.createdAt DESC")
    List<CareContext> findByEncounterId(@Param("encounterId") UUID encounterId);
    
    /**
     * Find care contexts by linking status.
     * 
     * @param linkingStatus Linking status
     * @return List of care contexts
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.linkingStatus = :status ORDER BY cc.createdAt DESC")
    List<CareContext> findByLinkingStatus(@Param("status") CareContext.LinkingStatus linkingStatus);
    
    /**
     * Find care contexts by ABDM request ID (for gateway integration).
     * 
     * @param abdmRequestId ABDM request ID
     * @return Optional care context
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.abdmRequestId = :requestId")
    Optional<CareContext> findByAbdmRequestId(@Param("requestId") String abdmRequestId);
    
    /**
     * Find care contexts by HIP ID.
     * 
     * @param hipId HIP ID (HFR ID)
     * @return List of care contexts
     */
    @Query("SELECT cc FROM CareContext cc WHERE cc.hipId = :hipId ORDER BY cc.createdAt DESC")
    List<CareContext> findByHipId(@Param("hipId") String hipId);
    
    /**
     * Count care contexts by linking status for a patient.
     * 
     * @param patientId Patient ID
     * @param linkingStatus Linking status
     * @return Count
     */
    @Query("SELECT COUNT(cc) FROM CareContext cc WHERE cc.patientId = :patientId AND cc.linkingStatus = :status")
    long countByPatientIdAndLinkingStatus(
        @Param("patientId") UUID patientId,
        @Param("status") CareContext.LinkingStatus linkingStatus
    );
}

