package com.hims.core.auth;

import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

/**
 * Parses Scalekit-specific claims from JWT tokens.
 * 
 * This component extracts Scalekit-specific information from tokens
 * but does not make authorization decisions.
 */
@Component
public class ScalekitTokenParser {

    /**
     * Extracts the Scalekit user ID from a JWT.
     * 
     * @param jwt The validated JWT
     * @return The Scalekit user ID
     */
    public String extractScalekitUserId(Jwt jwt) {
        return jwt.getClaimAsString("scalekit_user_id");
    }

    /**
     * Extracts the Scalekit organization ID from a JWT.
     * 
     * @param jwt The validated JWT
     * @return The Scalekit organization ID
     */
    public String extractScalekitOrgId(Jwt jwt) {
        return jwt.getClaimAsString("org_id");
    }

    /**
     * Extracts the Scalekit session ID from a JWT.
     * 
     * @param jwt The validated JWT
     * @return The Scalekit session ID
     */
    public String extractSessionId(Jwt jwt) {
        return jwt.getClaimAsString("session_id");
    }
}

