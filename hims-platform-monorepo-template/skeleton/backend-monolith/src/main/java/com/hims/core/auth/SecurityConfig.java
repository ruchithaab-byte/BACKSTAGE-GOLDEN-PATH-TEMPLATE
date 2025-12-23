package com.hims.core.auth;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.web.SecurityFilterChain;

/**
 * Security configuration for the platform.
 * 
 * This configures JWT validation and security filter chain.
 * Authorization decisions are handled by Permit.io (not here).
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    /**
     * Configures the security filter chain.
     * 
     * This sets up:
     * - JWT validation for all requests
     * - Stateless session management
     * - CORS configuration
     * 
     * Note: Authorization is handled by Permit.io, not Spring Security.
     */
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> 
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/actuator/health", "/actuator/info").permitAll()
                .anyRequest().authenticated())
            .oauth2ResourceServer(oauth2 -> oauth2
                .jwt(jwt -> jwt.decoder(jwtDecoder())));
        
        return http.build();
    }

    /**
     * Creates a JWT decoder for Scalekit tokens.
     * 
     * In production, this should be configured with:
     * - JWK Set URI from Scalekit
     * - Issuer validation
     * - Audience validation
     */
    @Bean
    public JwtDecoder jwtDecoder() {
        // TODO: Configure with actual Scalekit JWK Set URI
        // For now, this is a placeholder
        // In production: NimbusJwtDecoder.withJwkSetUri("https://scalekit.io/.well-known/jwks.json")
        return NimbusJwtDecoder.withJwkSetUri("https://scalekit.io/.well-known/jwks.json");
    }
}

