package com.hims.core.auth;

import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtValidationException;
import org.springframework.stereotype.Component;

/**
 * Validates JWT tokens from Scalekit.
 * 
 * This component is part of the Core Kernel and provides authentication
 * infrastructure. It does NOT make authorization decisions.
 * 
 * Key Rule: Auth sets context, it does not decide permissions.
 */
@Component
public class JwtTokenValidator {

    private final JwtDecoder jwtDecoder;

    public JwtTokenValidator(JwtDecoder jwtDecoder) {
        this.jwtDecoder = jwtDecoder;
    }

    /**
     * Validates and parses a JWT token.
     * 
     * @param token The JWT token string
     * @return The validated JWT
     * @throws JwtValidationException if the token is invalid
     */
    public Jwt validate(String token) {
        return jwtDecoder.decode(token);
    }

    /**
     * Extracts the user ID from a JWT token.
     * 
     * @param jwt The validated JWT
     * @return The user ID (from 'sub' claim or custom claim)
     */
    public String extractUserId(Jwt jwt) {
        return jwt.getSubject();
    }

    /**
     * Extracts the tenant ID from a JWT token.
     * 
     * @param jwt The validated JWT
     * @return The tenant ID (from 'org_id' claim or custom claim)
     */
    public String extractTenantId(Jwt jwt) {
        return jwt.getClaimAsString("org_id");
    }
}

