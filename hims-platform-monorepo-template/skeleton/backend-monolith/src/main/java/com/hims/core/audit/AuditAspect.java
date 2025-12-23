package com.hims.core.audit;

import com.hims.core.tenant.TenantContext;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Aspect that captures audit events from methods annotated with @LogAudit.
 * 
 * This captures facts about what happened and publishes them via AuditEventPublisher.
 * 
 * Key Rule: Audit captures FACTS, not interpretations.
 */
@Aspect
@Component
public class AuditAspect {

    private final AuditEventPublisher auditEventPublisher;

    public AuditAspect(AuditEventPublisher auditEventPublisher) {
        this.auditEventPublisher = auditEventPublisher;
    }

    @Around("@annotation(logAudit)")
    public Object logAudit(ProceedingJoinPoint joinPoint, LogAudit logAudit) throws Throwable {
        String action = logAudit.action();
        String resourceType = logAudit.resourceType();
        String description = logAudit.description();
        
        // Extract resource ID from method parameters (if available)
        String resourceId = extractResourceId(joinPoint.getArgs());
        
        // Extract metadata
        Map<String, Object> metadata = new HashMap<>();
        metadata.put("method", joinPoint.getSignature().toShortString());
        metadata.put("parameters", joinPoint.getArgs());
        
        try {
            Object result = joinPoint.proceed();
            
            // Capture return value if successful
            if (result != null) {
                metadata.put("result", result);
            }
            
            // Publish audit event
            AuditEvent event = new AuditEvent(
                action,
                resourceType,
                resourceId,
                TenantContext.getTenantId(),
                TenantContext.getUserId(),
                Instant.now(),
                metadata,
                description
            );
            
            auditEventPublisher.publish(event);
            
            return result;
        } catch (Throwable throwable) {
            // Capture exception in audit
            metadata.put("exception", throwable.getClass().getName());
            metadata.put("exceptionMessage", throwable.getMessage());
            
            AuditEvent event = new AuditEvent(
                action + "_FAILED",
                resourceType,
                resourceId,
                TenantContext.getTenantId(),
                TenantContext.getUserId(),
                Instant.now(),
                metadata,
                description + " - Failed: " + throwable.getMessage()
            );
            
            auditEventPublisher.publish(event);
            
            throw throwable;
        }
    }

    private String extractResourceId(Object[] args) {
        // Simple extraction: look for UUID or ID parameter
        for (Object arg : args) {
            if (arg instanceof String) {
                String str = (String) arg;
                // Check if it looks like a UUID
                if (str.matches("[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}")) {
                    return str;
                }
            }
        }
        return null;
    }
}

