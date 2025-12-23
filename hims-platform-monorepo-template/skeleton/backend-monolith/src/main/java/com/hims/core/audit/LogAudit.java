package com.hims.core.audit;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to mark methods for audit logging.
 * 
 * When applied to a method, the AuditAspect will capture:
 * - Method name
 * - Parameters
 * - Return value (if successful)
 * - Exception (if failed)
 * - Tenant ID
 * - User ID
 * - Timestamp
 * 
 * Key Rule: Audit captures FACTS, not interpretations.
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface LogAudit {
    
    /**
     * The action being performed (e.g., "CREATE_PATIENT", "UPDATE_INVOICE").
     * 
     * @return The action name
     */
    String action();
    
    /**
     * The resource type being acted upon (e.g., "PATIENT", "INVOICE").
     * 
     * @return The resource type
     */
    String resourceType();
    
    /**
     * Optional description of the action.
     * 
     * @return The description
     */
    String description() default "";
}

