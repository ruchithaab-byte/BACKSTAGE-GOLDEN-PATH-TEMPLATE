package com.hims.core.tenant;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.UUID;

/**
 * Servlet Filter that extracts X-Tenant-ID header and sets TenantContext.
 * 
 * This filter provides an alternative to JWT-based tenant identification.
 * It extracts the tenant ID from the X-Tenant-ID header and sets it in
 * the TenantContext ThreadLocal before any request processing.
 * 
 * Priority: This filter runs BEFORE Spring Security filters to ensure
 * tenant context is available for authentication.
 * 
 * Key Rule: Tenant context must be set BEFORE any database access.
 * 
 * Usage:
 * - For JWT-based auth: TenantAspect handles tenant extraction from JWT
 * - For header-based auth: This filter handles tenant extraction from header
 * - Both can coexist (filter sets from header, aspect can override from JWT)
 */
@Component
@Order(1) // Run before Spring Security filters
public class TenantFilter extends OncePerRequestFilter {

    private static final Logger log = LoggerFactory.getLogger(TenantFilter.class);
    private static final String TENANT_ID_HEADER = "X-Tenant-ID";
    private static final String USER_ID_HEADER = "X-User-ID"; // Optional, for non-JWT flows

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {
        
        try {
            // Extract tenant ID from header
            String tenantIdHeader = request.getHeader(TENANT_ID_HEADER);
            if (tenantIdHeader != null && !tenantIdHeader.isBlank()) {
                // Validate UUID format
                try {
                    UUID.fromString(tenantIdHeader);
                    TenantContext.setTenantId(tenantIdHeader);
                } catch (IllegalArgumentException e) {
                    // Invalid UUID format - log warning but continue
                    log.warn("Invalid tenant ID format in header: {}", tenantIdHeader);
                }
            }
            
            // Extract user ID from header (optional, for non-JWT flows)
            String userIdHeader = request.getHeader(USER_ID_HEADER);
            if (userIdHeader != null && !userIdHeader.isBlank()) {
                try {
                    UUID.fromString(userIdHeader);
                    TenantContext.setUserId(userIdHeader);
                } catch (IllegalArgumentException e) {
                    log.warn("Invalid user ID format in header: {}", userIdHeader);
                }
            }
            
            // Continue filter chain
            filterChain.doFilter(request, response);
            
        } finally {
            // Always clear context after request to prevent memory leaks
            TenantContext.clear();
        }
    }

    /**
     * Determines if this filter should be applied to the request.
     * 
     * Skip for actuator endpoints (they don't need tenant context).
     */
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.startsWith("/actuator");
    }
}

