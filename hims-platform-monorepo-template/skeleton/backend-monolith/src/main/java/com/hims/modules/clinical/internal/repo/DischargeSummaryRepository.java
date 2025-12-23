package com.hims.modules.clinical.internal.repo;

import com.hims.modules.clinical.internal.domain.DischargeSummary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for Discharge Summary entities.
 * 
 * This repository provides access to discharge summary data with automatic
 * tenant isolation via RLS policies at the database level.
 * 
 * All queries are automatically filtered by tenant_id through RLS.
 */
@Repository
public interface DischargeSummaryRepository extends JpaRepository<DischargeSummary, UUID> {
    
    /**
     * Find discharge summary by summary number (unique per tenant).
     * 
     * @param summaryNumber Summary number
     * @return Optional discharge summary
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.summaryNumber = :number")
    Optional<DischargeSummary> findBySummaryNumber(@Param("number") String summaryNumber);
    
    /**
     * Find all discharge summaries for a patient.
     * 
     * @param patientId Patient ID (soft FK)
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.patientId = :patientId ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByPatientId(@Param("patientId") UUID patientId);
    
    /**
     * Find all discharge summaries for an encounter.
     * 
     * @param encounterId Encounter ID (soft FK)
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.encounterId = :encounterId ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByEncounterId(@Param("encounterId") UUID encounterId);
    
    /**
     * Find all discharge summaries for an admission (IPD).
     * 
     * @param admissionId Admission ID (soft FK)
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.admissionId = :admissionId ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByAdmissionId(@Param("admissionId") UUID admissionId);
    
    /**
     * Find discharge summaries by discharge status.
     * 
     * @param dischargeStatus Discharge status
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.dischargeStatus = :status ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByDischargeStatus(@Param("status") DischargeSummary.DischargeStatus dischargeStatus);
    
    /**
     * Find discharge summaries by status (draft/final/amended).
     * 
     * @param status Summary status
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.status = :status ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByStatus(@Param("status") DischargeSummary.SummaryStatus status);
    
    /**
     * Find discharge summaries by author.
     * 
     * @param authorId Author ID (practitioner)
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.authorId = :authorId ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByAuthorId(@Param("authorId") UUID authorId);
    
    /**
     * Find discharge summaries by date range.
     * 
     * @param startDate Start date
     * @param endDate End date
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.dischargeDate BETWEEN :startDate AND :endDate ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByDischargeDateBetween(
        @Param("startDate") LocalDate startDate,
        @Param("endDate") LocalDate endDate
    );
    
    /**
     * Find discharge summaries linked to ABDM care context.
     * 
     * @param careContextId Care context ID
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.careContextId = :careContextId ORDER BY ds.dischargeDate DESC")
    List<DischargeSummary> findByCareContextId(@Param("careContextId") UUID careContextId);
    
    /**
     * Find discharge summaries requiring STG review.
     * 
     * @return List of discharge summaries
     */
    @Query("SELECT ds FROM DischargeSummary ds WHERE ds.stgReviewedBy IS NULL AND ds.status = 'FINAL' ORDER BY ds.dischargeDate ASC")
    List<DischargeSummary> findPendingStgReview();
    
    /**
     * Count discharge summaries by status for a patient.
     * 
     * @param patientId Patient ID
     * @param status Discharge status
     * @return Count
     */
    @Query("SELECT COUNT(ds) FROM DischargeSummary ds WHERE ds.patientId = :patientId AND ds.dischargeStatus = :status")
    long countByPatientIdAndDischargeStatus(
        @Param("patientId") UUID patientId,
        @Param("status") DischargeSummary.DischargeStatus status
    );
}

