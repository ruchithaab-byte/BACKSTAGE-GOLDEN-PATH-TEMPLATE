package com.hims.modules.abdm.internal.repo;

import com.hims.modules.abdm.internal.domain.AbhaRegistration;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Repository for ABHA Registration entities.
 * 
 * This repository provides access to ABHA registration data with automatic
 * tenant isolation via RLS policies at the database level.
 * 
 * All queries are automatically filtered by tenant_id through RLS.
 */
@Repository
public interface AbhaRegistrationRepository extends JpaRepository<AbhaRegistration, UUID> {
    
    /**
     * Find ABHA registration by ABHA number (unique per tenant).
     * 
     * @param abhaNumber ABHA number
     * @return Optional ABHA registration
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.abhaNumber = :number")
    Optional<AbhaRegistration> findByAbhaNumber(@Param("number") String abhaNumber);
    
    /**
     * Find ABHA registration by ABHA address.
     * 
     * @param abhaAddress ABHA address (username@abdm)
     * @return Optional ABHA registration
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.abhaAddress = :address")
    Optional<AbhaRegistration> findByAbhaAddress(@Param("address") String abhaAddress);
    
    /**
     * Find all ABHA registrations for a patient.
     * 
     * @param patientId Patient ID (soft FK)
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.patientId = :patientId ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByPatientId(@Param("patientId") UUID patientId);
    
    /**
     * Find ABHA registrations by status.
     * 
     * @param status Registration status
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.status = :status ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByStatus(@Param("status") AbhaRegistration.RegistrationStatus status);
    
    /**
     * Find ABHA registrations by KYC status.
     * 
     * @param kycStatus KYC status
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.kycStatus = :kycStatus ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByKycStatus(@Param("kycStatus") AbhaRegistration.KYCStatus kycStatus);
    
    /**
     * Find ABHA registration by ABDM request ID (for gateway integration).
     * 
     * @param abdmRequestId ABDM request ID
     * @return Optional ABHA registration
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.abdmRequestId = :requestId")
    Optional<AbhaRegistration> findByAbdmRequestId(@Param("requestId") String abdmRequestId);
    
    /**
     * Find ABHA registrations by creation method.
     * 
     * @param creationMethod Creation method
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.creationMethod = :method ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByCreationMethod(@Param("method") AbhaRegistration.CreationMethod creationMethod);
    
    /**
     * Find ABHA registrations by mobile number.
     * 
     * @param mobileNumber Mobile number
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.mobileNumber = :mobile ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByMobileNumber(@Param("mobile") String mobileNumber);
    
    /**
     * Find ABHA registrations by guardian ABHA number.
     * 
     * @param guardianAbhaNumber Guardian ABHA number
     * @return List of ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.guardianAbhaNumber = :guardianAbha ORDER BY ar.createdAt DESC")
    List<AbhaRegistration> findByGuardianAbhaNumber(@Param("guardianAbha") String guardianAbhaNumber);
    
    /**
     * Find pending ABHA registrations requiring verification.
     * 
     * @return List of pending ABHA registrations
     */
    @Query("SELECT ar FROM AbhaRegistration ar WHERE ar.status = 'PENDING' OR ar.kycStatus = 'PENDING' ORDER BY ar.createdAt ASC")
    List<AbhaRegistration> findPendingForVerification();
    
    /**
     * Count ABHA registrations by status for a patient.
     * 
     * @param patientId Patient ID
     * @param status Registration status
     * @return Count
     */
    @Query("SELECT COUNT(ar) FROM AbhaRegistration ar WHERE ar.patientId = :patientId AND ar.status = :status")
    long countByPatientIdAndStatus(
        @Param("patientId") UUID patientId,
        @Param("status") AbhaRegistration.RegistrationStatus status
    );
}

