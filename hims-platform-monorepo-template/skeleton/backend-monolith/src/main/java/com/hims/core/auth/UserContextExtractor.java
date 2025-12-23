package com.hims.core.auth;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

/**
 * Extracts user context from the security context.
 * 
 * This component provides user and tenant information to other
 * components. It does NOT make authorization decisions.
 */
@Component
public class UserContextExtractor {

    private final JwtTokenValidator jwtTokenValidator;
    private final ScalekitTokenParser scalekitTokenParser;

    public UserContextExtractor(
            JwtTokenValidator jwtTokenValidator,
            ScalekitTokenParser scalekitTokenParser) {
        this.jwtTokenValidator = jwtTokenValidator;
        this.scalekitTokenParser = scalekitTokenParser;
    }

    /**
     * Extracts the current user ID from the security context.
     * 
     * @return The user ID, or null if not authenticated
     */
    public String getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof Jwt)) {
            return null;
        }
        
        Jwt jwt = (Jwt) authentication.getPrincipal();
        return jwtTokenValidator.extractUserId(jwt);
    }

    /**
     * Extracts the current tenant ID from the security context.
     * 
     * @return The tenant ID, or null if not authenticated
     */
    public String getCurrentTenantId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof Jwt)) {
            return null;
        }
        
        Jwt jwt = (Jwt) authentication.getPrincipal();
        return jwtTokenValidator.extractTenantId(jwt);
    }

    /**
     * Gets the full JWT token from the security context.
     * 
     * @return The JWT, or null if not authenticated
     */
    public Jwt getCurrentJwt() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !(authentication.getPrincipal() instanceof Jwt)) {
            return null;
        }
        
        return (Jwt) authentication.getPrincipal();
    }
}

