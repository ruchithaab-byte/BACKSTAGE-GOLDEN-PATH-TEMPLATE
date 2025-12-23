package com.hims.core.scalekit;

import com.hims.core.authz.PermitService;
import com.scalekit.grpc.scalekit.v1.organizations.Organization;
import com.scalekit.grpc.scalekit.v1.users.CreateUserAndMembershipResponse;
import com.scalekit.grpc.scalekit.v1.users.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Tenant Synchronization Service
 * 
 * This service ensures that when an Organization/User is created in Scalekit,
 * the corresponding records are created in our local database tables:
 * 
 * Scalekit Organization → core.organizations + core.tenants
 * Scalekit User         → core.users (under the tenant)
 * 
 * This is critical for:
 * 1. RLS (Row Level Security) to work - needs tenant_id in DB
 * 2. User lookups - JWT contains Scalekit IDs, we need local mapping
 * 3. Audit trail - all operations need local tenant/user references
 * 
 * Key Design: Scalekit is the source of truth for AuthN.
 *            Our DB is the source of truth for business data.
 *            This service bridges the two.
 */
@Service
public class TenantSyncService {

    private static final Logger log = LoggerFactory.getLogger(TenantSyncService.class);

    private final JdbcTemplate jdbcTemplate;
    private final PermitService permitService;

    public TenantSyncService(JdbcTemplate jdbcTemplate, PermitService permitService) {
        this.jdbcTemplate = jdbcTemplate;
        this.permitService = permitService;
    }

    /**
     * Sync Scalekit Organization to local database.
     * 
     * Creates:
     * 1. core.organizations record (parent/holding company)
     * 2. core.tenants record (operating facility)
     * 
     * The Scalekit org_id becomes our tenant_id for RLS.
     * 
     * @param scalekitOrg The organization created in Scalekit
     * @return The tenant UUID (same as Scalekit org_id for simplicity, or generated)
     */
    @Transactional
    public UUID syncOrganizationToDatabase(Organization scalekitOrg) {
        String scalekitOrgId = scalekitOrg.getId();
        String displayName = scalekitOrg.getDisplayName();
        String externalId = scalekitOrg.getExternalId();
        
        log.info("Syncing Scalekit organization {} ({}) to local database", scalekitOrgId, displayName);
        
        // Step 1: Create or get parent organization in core.organizations
        UUID parentOrgId = syncParentOrganization(displayName, externalId);
        
        // Step 2: Create tenant in core.tenants using Scalekit org_id
        // We parse Scalekit ID or generate a new UUID
        UUID tenantId = parseOrGenerateUUID(scalekitOrgId);
        
        String insertTenantSql = """
            INSERT INTO core.tenants (id, organization_id, name, code, type, config)
            VALUES (?, ?, ?, ?, 'HOSPITAL', '{"scalekit_org_id": "%s"}'::jsonb)
            ON CONFLICT (id) DO UPDATE SET
                name = EXCLUDED.name,
                updated_at = NOW()
            RETURNING id
            """.formatted(scalekitOrgId);
        
        String tenantCode = externalId != null && !externalId.isBlank() 
            ? externalId 
            : scalekitOrgId.substring(0, Math.min(scalekitOrgId.length(), 20));
        
        UUID resultTenantId = jdbcTemplate.queryForObject(
            insertTenantSql,
            UUID.class,
            tenantId, parentOrgId, displayName, tenantCode
        );
        
        log.info("Synced organization to tenant_id: {} (Scalekit org_id: {})", resultTenantId, scalekitOrgId);
        
        // Step 3: Sync tenant to Permit.io for authorization
        permitService.syncTenant(resultTenantId.toString(), displayName);
        
        return resultTenantId;
    }
    
    /**
     * Sync Scalekit User to local database.
     * 
     * Creates core.users record under the specified tenant.
     * 
     * IMPORTANT: This must be called with tenant context set, OR
     * we bypass RLS by using superuser connection.
     * 
     * @param tenantId The tenant UUID (from syncOrganizationToDatabase)
     * @param scalekitResponse The user creation response from Scalekit
     * @return The user UUID
     */
    @Transactional
    public UUID syncUserToDatabase(UUID tenantId, CreateUserAndMembershipResponse scalekitResponse) {
        return syncUserToDatabase(tenantId, scalekitResponse, "receptionist"); // Default role
    }
    
    /**
     * Sync Scalekit User to local database with role assignment.
     * 
     * Creates core.users record under the specified tenant and assigns role in Permit.io.
     * 
     * @param tenantId The tenant UUID (from syncOrganizationToDatabase)
     * @param scalekitResponse The user creation response from Scalekit
     * @param role The role to assign (doctor, nurse, admin, receptionist)
     * @return The user UUID
     */
    @Transactional
    public UUID syncUserToDatabaseWithRole(UUID tenantId, CreateUserAndMembershipResponse scalekitResponse, String role) {
        return syncUserToDatabase(tenantId, scalekitResponse, role);
    }
    
    private UUID syncUserToDatabase(UUID tenantId, CreateUserAndMembershipResponse scalekitResponse, String role) {
        User user = scalekitResponse.getUser();
        String scalekitUserId = user.getId();
        String email = user.getEmail();
        
        // Extract profile info if available
        String fullName = null;
        if (user.hasUserProfile()) {
            String firstName = user.getUserProfile().getFirstName();
            String lastName = user.getUserProfile().getLastName();
            if (firstName != null || lastName != null) {
                fullName = ((firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "")).trim();
            }
        }
        
        log.info("Syncing Scalekit user {} ({}) to local database under tenant {}", 
                scalekitUserId, email, tenantId);
        
        // Generate or parse user ID
        UUID userId = parseOrGenerateUUID(scalekitUserId);
        
        // Extract username from email (part before @)
        String username = email.contains("@") ? email.substring(0, email.indexOf("@")) : email;
        
        // We need to temporarily set tenant context for the INSERT
        // because core.users has RLS trigger that requires it
        jdbcTemplate.execute("SET LOCAL app.current_tenant = '" + tenantId.toString() + "'");
        
        String insertUserSql = """
            INSERT INTO core.users (id, tenant_id, username, email, full_name, status)
            VALUES (?, ?, ?, ?, ?, 'ACTIVE')
            ON CONFLICT (tenant_id, email) DO UPDATE SET
                full_name = COALESCE(EXCLUDED.full_name, core.users.full_name),
                updated_at = NOW()
            RETURNING id
            """;
        
        UUID resultUserId = jdbcTemplate.queryForObject(
            insertUserSql,
            UUID.class,
            userId, tenantId, username, email, fullName
        );
        
        log.info("Synced user to user_id: {} (Scalekit user_id: {})", resultUserId, scalekitUserId);
        
        // Step 3: Sync user to Permit.io for authorization with role
        String firstName = null;
        String lastName = null;
        if (user.hasUserProfile()) {
            firstName = user.getUserProfile().getFirstName();
            lastName = user.getUserProfile().getLastName();
        }
        
        // Sync user AND assign role in Permit.io
        permitService.syncUserWithRole(resultUserId.toString(), email, firstName, lastName, tenantId.toString(), role);
        
        log.info("User {} assigned role '{}' in tenant {} (Permit.io)", resultUserId, role, tenantId);
        
        return resultUserId;
    }
    
    /**
     * Get tenant ID from Scalekit organization ID.
     * 
     * Looks up the local tenant record that maps to the Scalekit org.
     * 
     * @param scalekitOrgId Scalekit organization ID (e.g., "org_123456789")
     * @return Tenant UUID or null if not found
     */
    public UUID getTenantIdByScalekitOrgId(String scalekitOrgId) {
        String sql = """
            SELECT id FROM core.tenants 
            WHERE config->>'scalekit_org_id' = ?
            """;
        
        try {
            return jdbcTemplate.queryForObject(sql, UUID.class, scalekitOrgId);
        } catch (Exception e) {
            log.warn("No tenant found for Scalekit org_id: {}", scalekitOrgId);
            return null;
        }
    }
    
    /**
     * Get user ID from Scalekit user ID.
     * 
     * @param tenantId Tenant UUID
     * @param email User email
     * @return User UUID or null if not found
     */
    public UUID getUserIdByEmail(UUID tenantId, String email) {
        // Temporarily set tenant context for RLS
        jdbcTemplate.execute("SET LOCAL app.current_tenant = '" + tenantId.toString() + "'");
        
        String sql = "SELECT id FROM core.users WHERE tenant_id = ? AND email = ?";
        
        try {
            return jdbcTemplate.queryForObject(sql, UUID.class, tenantId, email);
        } catch (Exception e) {
            log.warn("No user found for email {} in tenant {}", email, tenantId);
            return null;
        }
    }
    
    // ========================================================================
    // Private Helpers
    // ========================================================================
    
    private UUID syncParentOrganization(String name, String externalId) {
        String sql = """
            INSERT INTO core.organizations (name, domain, status)
            VALUES (?, ?, 'ACTIVE')
            ON CONFLICT (domain) DO UPDATE SET
                name = EXCLUDED.name,
                updated_at = NOW()
            RETURNING id
            """;
        
        String domain = externalId != null && !externalId.isBlank() 
            ? externalId + ".hims.local" 
            : name.toLowerCase().replaceAll("[^a-z0-9]", "") + ".hims.local";
        
        return jdbcTemplate.queryForObject(sql, UUID.class, name, domain);
    }
    
    private UUID parseOrGenerateUUID(String scalekitId) {
        // Scalekit IDs are like "org_123456789" or "user_123456789"
        // We need UUIDs for our database
        // Strategy: Try to parse as UUID, or generate deterministic UUID from Scalekit ID
        
        try {
            // If it's already a UUID string
            return UUID.fromString(scalekitId);
        } catch (IllegalArgumentException e) {
            // Generate deterministic UUID from Scalekit ID using UUID v5 (name-based)
            return UUID.nameUUIDFromBytes(scalekitId.getBytes());
        }
    }
}

