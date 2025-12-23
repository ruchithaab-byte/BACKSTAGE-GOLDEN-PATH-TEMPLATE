package com.hims.core.authz;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.aspectj.lang.reflect.MethodSignature;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.lang.reflect.Parameter;
import java.util.HashMap;
import java.util.Map;

/**
 * Aspect for enforcing Permit.io authorization checks.
 * 
 * This aspect intercepts methods annotated with @RequirePermission
 * and checks with Permit.io PDP before allowing execution.
 * 
 * Execution Order:
 * 1. TenantFilter sets tenant context (from X-Tenant-ID header)
 * 2. Spring Security validates JWT (from Scalekit)
 * 3. UserContextExtractor sets user context
 * 4. This aspect checks Permit.io for authorization
 * 5. Method executes if permitted
 * 
 * Order is set to run AFTER authentication but BEFORE method execution.
 */
@Aspect
@Component
@Order(100) // Run after security filters
public class PermitAuthorizationAspect {

    private static final Logger log = LoggerFactory.getLogger(PermitAuthorizationAspect.class);

    private final PermitService permitService;

    public PermitAuthorizationAspect(PermitService permitService) {
        this.permitService = permitService;
    }

    /**
     * Before advice that checks permissions using Permit.io.
     * 
     * @param joinPoint The join point
     * @param requirePermission The annotation
     */
    @Before("@annotation(requirePermission)")
    public void checkPermission(JoinPoint joinPoint, RequirePermission requirePermission) {
        String action = requirePermission.action();
        String resource = requirePermission.resource();
        String resourceIdParam = requirePermission.resourceIdParam();
        String[] contextPairs = requirePermission.context();

        // Extract resource ID from method parameters if specified
        String resourceId = null;
        if (!resourceIdParam.isBlank()) {
            resourceId = extractParameterValue(joinPoint, resourceIdParam);
        }

        // Build context map from annotation
        Map<String, Object> context = null;
        if (contextPairs.length > 0) {
            context = buildContextMap(contextPairs);
        }

        // Check permission with Permit.io
        boolean permitted = permitService.isPermitted(action, resource, resourceId, context);

        if (!permitted) {
            log.warn("Access denied: action={}, resource={}, resourceId={}", 
                    action, resource, resourceId);
            throw new AccessDeniedException(
                String.format("Access denied: You don't have permission to %s %s", action, resource)
            );
        }

        log.debug("Access granted: action={}, resource={}, resourceId={}", 
                action, resource, resourceId);
    }

    /**
     * Extract a parameter value from the method call by parameter name.
     */
    private String extractParameterValue(JoinPoint joinPoint, String paramName) {
        MethodSignature signature = (MethodSignature) joinPoint.getSignature();
        Method method = signature.getMethod();
        Parameter[] parameters = method.getParameters();
        Object[] args = joinPoint.getArgs();

        for (int i = 0; i < parameters.length; i++) {
            if (parameters[i].getName().equals(paramName)) {
                Object value = args[i];
                return value != null ? value.toString() : null;
            }
        }

        // Try to match by simple type if exact name match fails
        // This handles cases where parameter names are not preserved
        log.warn("Could not find parameter '{}' by name, checking by position", paramName);
        return null;
    }

    /**
     * Build context map from annotation string pairs.
     */
    private Map<String, Object> buildContextMap(String[] contextPairs) {
        Map<String, Object> context = new HashMap<>();
        
        for (String pair : contextPairs) {
            String[] parts = pair.split("=", 2);
            if (parts.length == 2) {
                context.put(parts[0].trim(), parts[1].trim());
            }
        }
        
        return context;
    }
}

