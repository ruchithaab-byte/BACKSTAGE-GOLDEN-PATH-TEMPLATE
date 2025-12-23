package com.hims.core.authz;

import com.hims.core.tenant.TenantContext;
import io.permit.sdk.Permit;
import io.permit.sdk.PermitConfig;
import io.permit.sdk.enforcement.Resource;
import io.permit.sdk.enforcement.User;
import io.permit.sdk.openapi.models.TenantCreate;
import io.permit.sdk.openapi.models.UserCreate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * Permit.io Authorization Service
 * 
 * Provides integration with Permit.io for fine-grained authorization.
 * 
 * Key Concepts:
 * - User: The authenticated user (from Scalekit)
 * - Tenant: The organization (mapped from Scalekit org)
 * - Resource: What the user wants to access (patient, appointment, etc.)
 * - Action: What the user wants to do (read, create, update, delete)
 * - Role: A set of permissions (doctor, nurse, admin, etc.)
 * 
 * Flow:
 * 1. Scalekit authenticates user and provides user_id + org_id
 * 2. TenantContext stores tenant_id (from Scalekit org)
 * 3. PermitService checks if user can perform action on resource
 * 4. Permit.io PDP makes decision based on policies defined in Permit.io dashboard
 */
@Service
public class PermitService {

    private static final Logger log = LoggerFactory.getLogger(PermitService.class);

    private Permit permit;

    @Value("${permit.api-key}")
    private String apiKey;

    @Value("${permit.pdp-url:https://cloudpdp.api.permit.io}")
    private String pdpUrl;

    @Value("${permit.environment:development}")
    private String environment;

    @PostConstruct
    public void init() {
        if (apiKey == null || apiKey.isBlank() || apiKey.equals("your-permit-api-key")) {
            log.warn("Permit.io API key not configured. Authorization checks will be bypassed.");
            return;
        }

        PermitConfig config = new PermitConfig.Builder(apiKey)
            .withPdpAddress(pdpUrl)
            .withDebugMode(true)
            .build();

        this.permit = new Permit(config);
        log.info("Permit.io initialized with PDP: {}", pdpUrl);
    }

    /**
     * Check if the current user is permitted to perform an action on a resource.
     * 
     * @param action Action to perform (e.g., "read", "create", "update", "delete")
     * @param resourceType Resource type (e.g., "patient", "appointment")
     * @return true if permitted, false otherwise
     */
    public boolean isPermitted(String action, String resourceType) {
        return isPermitted(action, resourceType, null, null);
    }

    /**
     * Check if the current user is permitted to perform an action on a specific resource instance.
     * 
     * @param action Action to perform
     * @param resourceType Resource type
     * @param resourceId Specific resource ID (for instance-level checks)
     * @return true if permitted, false otherwise
     */
    public boolean isPermitted(String action, String resourceType, String resourceId) {
        return isPermitted(action, resourceType, resourceId, null);
    }

    /**
     * Check if the current user is permitted with additional context.
     * 
     * @param action Action to perform
     * @param resourceType Resource type
     * @param resourceId Specific resource ID (nullable)
     * @param context Additional context attributes (nullable)
     * @return true if permitted, false otherwise
     */
    public boolean isPermitted(String action, String resourceType, String resourceId, Map<String, Object> context) {
        if (permit == null) {
            log.warn("Permit.io not configured - bypassing authorization check for {} {} {}", 
                    action, resourceType, resourceId);
            return true; // Bypass if not configured (for development)
        }

        String userId = TenantContext.getUserId();
        String tenantId = TenantContext.getTenantId();

        if (userId == null || userId.isBlank()) {
            log.warn("No user ID in context - denying access");
            return false;
        }

        try {
            // Build user with tenant context
            User user = User.fromString(userId);
            
            // Build resource
            Resource.Builder resourceBuilder = new Resource.Builder(resourceType);
            if (resourceId != null && !resourceId.isBlank()) {
                resourceBuilder.withKey(resourceId);
            }
            if (tenantId != null && !tenantId.isBlank()) {
                resourceBuilder.withTenant(tenantId);
            }
            if (context != null && !context.isEmpty()) {
                HashMap<String, Object> attrs = new HashMap<>(context);
                resourceBuilder.withAttributes(attrs);
            }
            Resource resource = resourceBuilder.build();

            // Check permission
            boolean permitted = permit.check(user, action, resource);
            
            log.debug("Permit.io check: user={}, action={}, resource={}, resourceId={}, tenant={} -> {}",
                    userId, action, resourceType, resourceId, tenantId, permitted ? "ALLOWED" : "DENIED");

            return permitted;

        } catch (Exception e) {
            log.error("Permit.io check failed for user={}, action={}, resource={}: {}", 
                    userId, action, resourceType, e.getMessage());
            // Fail closed - deny access on errors
            return false;
        }
    }

    /**
     * Sync a user to Permit.io when they are created in Scalekit.
     * 
     * @param userId User ID
     * @param email User email
     * @param firstName First name
     * @param lastName Last name
     */
    public void syncUser(String userId, String email, String firstName, String lastName) {
        syncUserWithRole(userId, email, firstName, lastName, null, null);
    }
    
    /**
     * Sync a user to Permit.io AND assign a role when they are created in Scalekit.
     * 
     * This is the recommended method for new user creation as it ensures users
     * are properly set up with permissions from the start.
     * 
     * @param userId User ID (from local database)
     * @param email User email
     * @param firstName First name
     * @param lastName Last name
     * @param tenantId Tenant ID (for role assignment)
     * @param role Role to assign (doctor, nurse, admin, receptionist)
     */
    public void syncUserWithRole(String userId, String email, String firstName, String lastName, 
                                  String tenantId, String role) {
        if (permit == null) {
            log.warn("Permit.io not configured - skipping user sync");
            return;
        }

        try {
            // Step 1: Sync the user to Permit.io
            UserCreate userCreate = new UserCreate(userId)
                .withEmail(email);
            
            if (firstName != null) {
                userCreate = userCreate.withFirstName(firstName);
            }
            if (lastName != null) {
                userCreate = userCreate.withLastName(lastName);
            }

            permit.api.users.sync(userCreate);
            log.info("Synced user {} ({}) to Permit.io", userId, email);

            // Step 2: Assign role if provided
            if (role != null && !role.isBlank() && tenantId != null && !tenantId.isBlank()) {
                assignRole(userId, role, tenantId);
                log.info("Assigned role '{}' to user {} in tenant {}", role, userId, tenantId);
            }

        } catch (Exception e) {
            log.error("Failed to sync user {} to Permit.io: {}", userId, e.getMessage());
        }
    }

    /**
     * Sync a tenant to Permit.io when an organization is created in Scalekit.
     * 
     * @param tenantId Tenant ID (same as local tenant_id)
     * @param name Tenant/Organization name
     */
    public void syncTenant(String tenantId, String name) {
        if (permit == null) {
            log.warn("Permit.io not configured - skipping tenant sync");
            return;
        }

        try {
            TenantCreate tenantCreate = new TenantCreate(tenantId, name);
            permit.api.tenants.create(tenantCreate);
            log.info("Synced tenant {} ({}) to Permit.io", tenantId, name);

        } catch (Exception e) {
            log.error("Failed to sync tenant {} to Permit.io: {}", tenantId, e.getMessage());
        }
    }

    /**
     * Assign a role to a user within a tenant.
     * 
     * @param userId User ID
     * @param roleKey Role key (e.g., "doctor", "nurse", "admin")
     * @param tenantId Tenant ID
     */
    public void assignRole(String userId, String roleKey, String tenantId) {
        if (permit == null) {
            log.warn("Permit.io not configured - skipping role assignment");
            return;
        }

        try {
            permit.api.users.assignRole(userId, roleKey, tenantId);
            log.info("Assigned role {} to user {} in tenant {}", roleKey, userId, tenantId);

        } catch (Exception e) {
            log.error("Failed to assign role {} to user {}: {}", roleKey, userId, e.getMessage());
        }
    }

    /**
     * Get permitted actions for the current user on a resource type.
     * 
     * @param resourceType Resource type
     * @return Map of action -> permitted
     */
    public Map<String, Boolean> getPermittedActions(String resourceType) {
        Map<String, Boolean> permissions = new HashMap<>();
        String[] actions = {"read", "create", "update", "delete"};
        
        for (String action : actions) {
            permissions.put(action, isPermitted(action, resourceType));
        }
        
        return permissions;
    }
}
