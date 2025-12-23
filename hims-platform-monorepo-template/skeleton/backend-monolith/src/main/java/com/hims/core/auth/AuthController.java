package com.hims.core.auth;

import com.hims.core.audit.LogAudit;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Authentication REST Controller
 * 
 * Provides authentication endpoints:
 * - POST /api/v1/auth/login - Login endpoint (mock or real)
 * - GET /api/v1/auth/me - Get current user profile
 * 
 * Key Rule: These endpoints set context, they do NOT make authorization decisions.
 */
@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    /**
     * Login endpoint.
     * 
     * This endpoint can be:
     * 1. Mock implementation (for development)
     * 2. Real implementation (validate credentials, return JWT)
     * 
     * For now, this is a placeholder that returns a mock response.
     * In production, this should:
     * - Validate credentials against core.users
     * - Generate/return JWT token from Scalekit
     * - Update login tracking
     * 
     * @param request Login request (email/password or other credentials)
     * @param httpRequest HTTP request (for IP address)
     * @return Login response with token
     */
    @PostMapping("/login")
    @LogAudit(
        action = "LOGIN",
        resourceType = "AUTH",
        description = "User login attempt"
    )
    public ResponseEntity<Map<String, Object>> login(
            @RequestBody(required = false) Map<String, String> request,
            HttpServletRequest httpRequest) {
        
        // TODO: Implement actual login logic
        // For now, return mock response
        // In production:
        // 1. Validate credentials
        // 2. Get JWT from Scalekit
        // 3. Update login tracking
        // 4. Return token
        
        String ipAddress = httpRequest.getRemoteAddr();
        
        // Mock response
        Map<String, Object> response = Map.of(
            "token", "mock-jwt-token",
            "message", "Login successful (mock implementation)",
            "note", "Replace with actual Scalekit integration"
        );
        
        return ResponseEntity.ok(response);
    }

    /**
     * Get current user profile.
     * 
     * Returns the profile of the currently authenticated user.
     * The user is identified from the JWT token in the Authorization header.
     * 
     * This endpoint:
     * 1. Extracts user from security context (JWT)
     * 2. Queries core.users table
     * 3. Returns user profile
     * 
     * @return Current user profile
     */
    @GetMapping("/me")
    @LogAudit(
        action = "GET_CURRENT_USER",
        resourceType = "USER",
        description = "Get current user profile"
    )
    public ResponseEntity<AuthService.UserProfile> getCurrentUser() {
        // Get user profile from service
        AuthService.UserProfile profile = authService.getCurrentUser();
        
        return ResponseEntity.ok(profile);
    }

    /**
     * Health check endpoint for auth service.
     * 
     * @return Health status
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, String>> health() {
        return ResponseEntity.ok(Map.of("status", "healthy", "service", "auth"));
    }

    /**
     * Validate token endpoint (for testing).
     * 
     * This endpoint validates a JWT token and returns user information.
     * Useful for testing token validation logic.
     * 
     * @param token The JWT token to validate
     * @return User profile if token is valid
     */
    @PostMapping("/validate")
    @LogAudit(
        action = "VALIDATE_TOKEN",
        resourceType = "AUTH",
        description = "Validate JWT token"
    )
    public ResponseEntity<AuthService.UserProfile> validateToken(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        if (token == null || token.isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        
        AuthService.UserProfile profile = authService.validateToken(token);
        return ResponseEntity.ok(profile);
    }
}

