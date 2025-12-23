package com.hims.core.auth;

import com.hims.core.audit.LogAudit;
import com.hims.core.events.EventPublisher;
import com.hims.core.events.EventMetadata;
import com.hims.core.tenant.TenantContext;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtValidationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.OffsetDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * Authentication Service
 * 
 * Provides authentication and user management services.
 * 
 * Responsibilities:
 * - Validate JWT tokens
 * - Map JWT subject to core.users
 * - Update user login tracking
 * - Provide user profile information
 * 
 * Key Rule: This service sets context, it does NOT make authorization decisions.
 * Authorization is handled by Permit.io (Policy Decision Point).
 */
@Service
public class AuthService {

    private final JwtTokenValidator jwtTokenValidator;
    private final UserContextExtractor userContextExtractor;
    private final EventPublisher eventPublisher;

    public AuthService(
            JwtTokenValidator jwtTokenValidator,
            UserContextExtractor userContextExtractor,
            EventPublisher eventPublisher) {
        this.jwtTokenValidator = jwtTokenValidator;
        this.userContextExtractor = userContextExtractor;
        this.eventPublisher = eventPublisher;
    }

    /**
     * Validates a JWT token and returns the authenticated user information.
     * 
     * This method:
     * 1. Validates the JWT token
     * 2. Extracts user and tenant information
     * 3. Maps JWT subject to core.users (if needed)
     * 4. Returns user profile
     * 
     * @param token The JWT token string
     * @return User profile information
     * @throws JwtValidationException if token is invalid
     */
    @LogAudit(
        action = "VALIDATE_TOKEN",
        resourceType = "AUTH",
        description = "Validate JWT token"
    )
    public UserProfile validateToken(String token) {
        // Validate token
        Jwt jwt = jwtTokenValidator.validate(token);
        
        // Extract user and tenant IDs
        String userId = jwtTokenValidator.extractUserId(jwt);
        String tenantId = jwtTokenValidator.extractTenantId(jwt);
        
        // Set tenant context (if not already set)
        if (tenantId != null && !TenantContext.isSet()) {
            TenantContext.setTenantId(tenantId);
            TenantContext.setUserId(userId);
        }
        
        // TODO: Map JWT subject to core.users table
        // For now, return profile from JWT claims
        // In production, query core.users table and return full user profile
        
        return UserProfile.builder()
            .id(UUID.fromString(userId))
            .tenantId(UUID.fromString(tenantId))
            .email(jwt.getClaimAsString("email"))
            .name(jwt.getClaimAsString("name"))
            .build();
    }

    /**
     * Gets the current authenticated user's profile.
     * 
     * This method extracts user information from the security context
     * and returns the user profile from core.users.
     * 
     * @return User profile from database
     * @throws IllegalStateException if user is not authenticated
     */
    @LogAudit(
        action = "GET_CURRENT_USER",
        resourceType = "USER",
        description = "Get current user profile"
    )
    @Transactional(readOnly = true)
    public UserProfile getCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof Jwt)) {
            throw new IllegalStateException("User is not authenticated");
        }
        
        Jwt jwt = (Jwt) authentication.getPrincipal();
        String userId = userContextExtractor.getCurrentUserId();
        String tenantId = userContextExtractor.getCurrentTenantId();
        
        if (userId == null || tenantId == null) {
            throw new IllegalStateException("User or tenant ID not found in token");
        }
        
        // TODO: Query core.users table to get full user profile
        // For now, return profile from JWT claims
        // In production: 
        // User user = userRepository.findByTenantIdAndId(UUID.fromString(tenantId), UUID.fromString(userId))
        //     .orElseThrow(() -> new UserNotFoundException("User not found"));
        
        return UserProfile.builder()
            .id(UUID.fromString(userId))
            .tenantId(UUID.fromString(tenantId))
            .email(jwt.getClaimAsString("email"))
            .name(jwt.getClaimAsString("name"))
            .build();
    }

    /**
     * Updates user login tracking information.
     * 
     * This method should be called after successful authentication
     * to update last_login_at, last_login_ip, etc. in core.users.
     * 
     * @param userId The user ID
     * @param ipAddress The IP address of the login
     */
    @LogAudit(
        action = "UPDATE_LOGIN_TRACKING",
        resourceType = "USER",
        description = "Update user login tracking"
    )
    @Transactional
    public void updateLoginTracking(String userId, String ipAddress) {
        // TODO: Update core.users table
        // userRepository.updateLastLogin(UUID.fromString(userId), OffsetDateTime.now(), ipAddress);
        
        // Publish event
        String tenantId = TenantContext.getTenantId();
        eventPublisher.publish(
            "auth.user.logged_in",
            Map.of("userId", userId, "ipAddress", ipAddress),
            EventMetadata.create()
                .withTenant(tenantId)
                .withUser(userId)
                .build()
        );
    }

    /**
     * User profile DTO.
     */
    public static class UserProfile {
        private UUID id;
        private UUID tenantId;
        private String email;
        private String name;
        private OffsetDateTime lastLoginAt;
        
        // Builder pattern
        public static UserProfileBuilder builder() {
            return new UserProfileBuilder();
        }
        
        // Getters and setters
        public UUID getId() { return id; }
        public void setId(UUID id) { this.id = id; }
        public UUID getTenantId() { return tenantId; }
        public void setTenantId(UUID tenantId) { this.tenantId = tenantId; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public OffsetDateTime getLastLoginAt() { return lastLoginAt; }
        public void setLastLoginAt(OffsetDateTime lastLoginAt) { this.lastLoginAt = lastLoginAt; }
        
        public static class UserProfileBuilder {
            private UserProfile profile = new UserProfile();
            
            public UserProfileBuilder id(UUID id) { profile.id = id; return this; }
            public UserProfileBuilder tenantId(UUID tenantId) { profile.tenantId = tenantId; return this; }
            public UserProfileBuilder email(String email) { profile.email = email; return this; }
            public UserProfileBuilder name(String name) { profile.name = name; return this; }
            public UserProfileBuilder lastLoginAt(OffsetDateTime lastLoginAt) { profile.lastLoginAt = lastLoginAt; return this; }
            public UserProfile build() { return profile; }
        }
    }
}

