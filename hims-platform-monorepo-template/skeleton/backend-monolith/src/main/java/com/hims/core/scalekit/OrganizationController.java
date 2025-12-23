package com.hims.core.scalekit;

import com.scalekit.grpc.scalekit.v1.organizations.Organization;
import com.scalekit.grpc.scalekit.v1.users.CreateUserAndMembershipResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.UUID;

/**
 * Organization & User Management Controller
 * 
 * Provides REST endpoints for managing organizations and users using Scalekit SDK.
 * 
 * CRITICAL: This controller ensures that when organizations/users are created in Scalekit,
 * they are ALSO synced to our local database tables (core.tenants, core.users).
 * 
 * Flow:
 * 1. Create Organization in Scalekit (via SDK) → Sync to core.organizations + core.tenants
 * 2. Create User in Scalekit (via SDK) → Sync to core.users under the tenant
 * 
 * The Scalekit org_id becomes the tenant_id for RLS enforcement.
 * 
 * Endpoints:
 * - POST /api/v1/organizations - Create organization (syncs to DB)
 * - GET /api/v1/organizations/{id} - Get organization
 * - POST /api/v1/organizations/{orgId}/users - Create user in organization (syncs to DB)
 */
@RestController
@RequestMapping("/api/v1/organizations")
public class OrganizationController {

    private static final Logger log = LoggerFactory.getLogger(OrganizationController.class);

    private final ScalekitService scalekitService;
    private final TenantSyncService tenantSyncService;

    public OrganizationController(ScalekitService scalekitService, TenantSyncService tenantSyncService) {
        this.scalekitService = scalekitService;
        this.tenantSyncService = tenantSyncService;
    }

    /**
     * Create a new organization (tenant).
     * 
     * This endpoint:
     * 1. Creates organization in Scalekit via SDK
     * 2. Syncs to core.organizations and core.tenants tables
     * 3. Returns the tenant_id (which can be used for all future operations)
     * 
     * @param request Organization creation request
     * @return Created organization with tenant_id
     */
    @PostMapping
    public ResponseEntity<OrganizationResponse> createOrganization(@RequestBody CreateOrganizationRequest request) {
        log.info("Creating organization: {}", request.getDisplayName());
        
        // Step 1: Create in Scalekit via SDK
        Organization scalekitOrg = scalekitService.createOrganization(
                request.getDisplayName(),
                request.getExternalId()
        );
        
        // Step 2: Sync to local database
        UUID tenantId = tenantSyncService.syncOrganizationToDatabase(scalekitOrg);
        
        // Step 3: Build response with both Scalekit ID and local tenant_id
        OrganizationResponse response = new OrganizationResponse();
        response.setScalekitOrgId(scalekitOrg.getId());
        response.setTenantId(tenantId.toString());
        response.setDisplayName(scalekitOrg.getDisplayName());
        response.setExternalId(scalekitOrg.getExternalId());
        
        log.info("Organization created - Scalekit ID: {}, Tenant ID: {}", 
                scalekitOrg.getId(), tenantId);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Get organization by ID.
     * 
     * @param id Scalekit Organization ID
     * @return Organization
     */
    @GetMapping("/{id}")
    public ResponseEntity<OrganizationResponse> getOrganization(@PathVariable String id) {
        Organization scalekitOrg = scalekitService.getOrganization(id);
        
        // Look up local tenant_id
        UUID tenantId = tenantSyncService.getTenantIdByScalekitOrgId(id);
        
        OrganizationResponse response = new OrganizationResponse();
        response.setScalekitOrgId(scalekitOrg.getId());
        response.setTenantId(tenantId != null ? tenantId.toString() : null);
        response.setDisplayName(scalekitOrg.getDisplayName());
        response.setExternalId(scalekitOrg.getExternalId());
        
        return ResponseEntity.ok(response);
    }

    /**
     * Create a user in an organization.
     * 
     * This endpoint:
     * 1. Creates user in Scalekit via SDK
     * 2. Syncs to core.users table under the tenant
     * 3. Returns the user_id (which can be used for all future operations)
     * 
     * Note: Password is not set via this API. Users will receive an invitation email
     * to set their password.
     * 
     * @param orgId Scalekit Organization ID
     * @param request User creation request
     * @return Created user with user_id
     */
    @PostMapping("/{orgId}/users")
    public ResponseEntity<UserResponse> createUser(
            @PathVariable String orgId,
            @RequestBody CreateUserRequest request) {
        
        log.info("Creating user {} in organization {}", request.getEmail(), orgId);
        
        // Step 1: Create in Scalekit via SDK
        CreateUserAndMembershipResponse scalekitResponse;
        
        if (request.getFirstName() != null || request.getLastName() != null) {
            scalekitResponse = scalekitService.createUserWithProfile(
                    orgId,
                    request.getEmail(),
                    request.getFirstName(),
                    request.getLastName()
            );
        } else {
            scalekitResponse = scalekitService.createUserAndMembership(
                    orgId,
                    request.getEmail(),
                    request.isSendInvitationEmail()
            );
        }
        
        // Step 2: Get tenant_id for this organization
        UUID tenantId = tenantSyncService.getTenantIdByScalekitOrgId(orgId);
        if (tenantId == null) {
            log.error("Tenant not found for Scalekit org {}", orgId);
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(null);
        }
        
        // Step 3: Sync to local database AND assign role in Permit.io
        String role = request.getRole() != null ? request.getRole() : "receptionist";
        UUID userId = tenantSyncService.syncUserToDatabaseWithRole(tenantId, scalekitResponse, role);
        
        // Step 4: Build response
        UserResponse response = new UserResponse();
        response.setScalekitUserId(scalekitResponse.getUser().getId());
        response.setUserId(userId.toString());
        response.setTenantId(tenantId.toString());
        response.setEmail(scalekitResponse.getUser().getEmail());
        
        if (scalekitResponse.getUser().hasUserProfile()) {
            response.setFirstName(scalekitResponse.getUser().getUserProfile().getFirstName());
            response.setLastName(scalekitResponse.getUser().getUserProfile().getLastName());
        }
        response.setRole(role);
        
        log.info("User created - Scalekit ID: {}, User ID: {}, Tenant ID: {}, Role: {}", 
                scalekitResponse.getUser().getId(), userId, tenantId, role);
        
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    /**
     * Health check endpoint.
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "healthy", "service", "scalekit"));
    }

    // ========================================================================
    // Request DTOs
    // ========================================================================
    
    public static class CreateOrganizationRequest {
        private String displayName;
        private String externalId;

        public String getDisplayName() { return displayName; }
        public void setDisplayName(String displayName) { this.displayName = displayName; }
        public String getExternalId() { return externalId; }
        public void setExternalId(String externalId) { this.externalId = externalId; }
    }

    public static class CreateUserRequest {
        private String email;
        private String firstName;
        private String lastName;
        private boolean sendInvitationEmail = true;
        private String role = "receptionist"; // Default role for new users

        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public boolean isSendInvitationEmail() { return sendInvitationEmail; }
        public void setSendInvitationEmail(boolean sendInvitationEmail) { this.sendInvitationEmail = sendInvitationEmail; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }

    // ========================================================================
    // Response DTOs
    // ========================================================================
    
    /**
     * Organization response with both Scalekit ID and local tenant_id.
     */
    public static class OrganizationResponse {
        private String scalekitOrgId;
        private String tenantId;
        private String displayName;
        private String externalId;

        public String getScalekitOrgId() { return scalekitOrgId; }
        public void setScalekitOrgId(String scalekitOrgId) { this.scalekitOrgId = scalekitOrgId; }
        public String getTenantId() { return tenantId; }
        public void setTenantId(String tenantId) { this.tenantId = tenantId; }
        public String getDisplayName() { return displayName; }
        public void setDisplayName(String displayName) { this.displayName = displayName; }
        public String getExternalId() { return externalId; }
        public void setExternalId(String externalId) { this.externalId = externalId; }
    }
    
    /**
     * User response with both Scalekit ID and local user_id.
     */
    public static class UserResponse {
        private String scalekitUserId;
        private String userId;
        private String tenantId;
        private String email;
        private String firstName;
        private String lastName;
        private String role;

        public String getScalekitUserId() { return scalekitUserId; }
        public void setScalekitUserId(String scalekitUserId) { this.scalekitUserId = scalekitUserId; }
        public String getUserId() { return userId; }
        public void setUserId(String userId) { this.userId = userId; }
        public String getTenantId() { return tenantId; }
        public void setTenantId(String tenantId) { this.tenantId = tenantId; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getFirstName() { return firstName; }
        public void setFirstName(String firstName) { this.firstName = firstName; }
        public String getLastName() { return lastName; }
        public void setLastName(String lastName) { this.lastName = lastName; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
    }
}

