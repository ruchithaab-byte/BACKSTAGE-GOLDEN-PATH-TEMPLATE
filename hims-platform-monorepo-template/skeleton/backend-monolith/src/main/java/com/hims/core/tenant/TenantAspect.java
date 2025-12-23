package com.hims.core.tenant;

import com.hims.core.auth.UserContextExtractor;
import jakarta.servlet.http.HttpServletRequest;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

/**
 * Aspect that sets tenant context from JWT tokens before request processing.
 * 
 * This ensures tenant context is set BEFORE any database access,
 * enabling RLS policies to work correctly.
 * 
 * Key Rule: Tenant context must be set BEFORE any DB access.
 */
@Aspect
@Component
public class TenantAspect {

    private final UserContextExtractor userContextExtractor;
    private final TenantContextHolder tenantContextHolder;

    public TenantAspect(
            UserContextExtractor userContextExtractor,
            TenantContextHolder tenantContextHolder) {
        this.userContextExtractor = userContextExtractor;
        this.tenantContextHolder = tenantContextHolder;
    }

    /**
     * Sets tenant context from JWT token before controller method execution.
     * Clears context after execution to prevent memory leaks.
     */
    @Around("@within(org.springframework.web.bind.annotation.RestController) || " +
            "@within(org.springframework.stereotype.Controller)")
    public Object setTenantContext(ProceedingJoinPoint joinPoint) throws Throwable {
        try {
            // Extract tenant and user from JWT
            String tenantId = userContextExtractor.getCurrentTenantId();
            String userId = userContextExtractor.getCurrentUserId();
            
            if (tenantId != null && userId != null) {
                tenantContextHolder.setContext(tenantId, userId);
            }
            
            return joinPoint.proceed();
        } finally {
            // Always clear context after request
            tenantContextHolder.clear();
        }
    }
}

