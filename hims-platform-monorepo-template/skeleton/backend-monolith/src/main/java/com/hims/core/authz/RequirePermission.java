package com.hims.core.authz;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to enforce authorization checks using Permit.io.
 * 
 * Usage:
 * <pre>
 * {@code
 * @RequirePermission(action = "read", resource = "patient")
 * public Patient getPatient(UUID id) { ... }
 * 
 * @RequirePermission(action = "create", resource = "patient")
 * public Patient registerPatient(PatientDTO dto) { ... }
 * 
 * @RequirePermission(action = "update", resource = "patient", resourceIdParam = "patientId")
 * public Patient updatePatient(@PathVariable UUID patientId, @RequestBody PatientDTO dto) { ... }
 * }
 * </pre>
 * 
 * The aspect will:
 * 1. Extract user from TenantContext (set by JWT/Scalekit authentication)
 * 2. Extract tenant from TenantContext
 * 3. Call Permit.io PDP for authorization decision
 * 4. Throw AccessDeniedException if not permitted
 */
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface RequirePermission {
    
    /**
     * The action being performed (e.g., "read", "create", "update", "delete")
     */
    String action();
    
    /**
     * The resource type (e.g., "patient", "appointment", "prescription")
     */
    String resource();
    
    /**
     * Optional: Parameter name that contains the resource ID for instance-level checks.
     * If provided, the resource ID will be extracted from method parameters.
     */
    String resourceIdParam() default "";
    
    /**
     * Optional: Additional context attributes as key=value pairs.
     * Example: {"department=cardiology", "sensitivity=high"}
     */
    String[] context() default {};
}

