package com.hims.core.tenant;

import java.util.Objects;

/**
 * Thread-local tenant context.
 * 
 * This holds the current tenant ID for the request thread.
 * Must be set before any database access to ensure RLS policies work correctly.
 * 
 * Key Rule: Tenant context must be set BEFORE any DB access.
 */
public class TenantContext {

    private static final ThreadLocal<String> TENANT_ID = new ThreadLocal<>();
    private static final ThreadLocal<String> USER_ID = new ThreadLocal<>();

    /**
     * Sets the current tenant ID for this thread.
     * 
     * @param tenantId The tenant ID
     */
    public static void setTenantId(String tenantId) {
        TENANT_ID.set(tenantId);
    }

    /**
     * Gets the current tenant ID for this thread.
     * 
     * @return The tenant ID, or null if not set
     */
    public static String getTenantId() {
        return TENANT_ID.get();
    }

    /**
     * Sets the current user ID for this thread.
     * 
     * @param userId The user ID
     */
    public static void setUserId(String userId) {
        USER_ID.set(userId);
    }

    /**
     * Gets the current user ID for this thread.
     * 
     * @return The user ID, or null if not set
     */
    public static String getUserId() {
        return USER_ID.get();
    }

    /**
     * Clears the tenant context for this thread.
     * Should be called after request processing to prevent memory leaks.
     */
    public static void clear() {
        TENANT_ID.remove();
        USER_ID.remove();
    }

    /**
     * Checks if tenant context is set.
     * 
     * @return true if tenant ID is set
     */
    public static boolean isSet() {
        return Objects.nonNull(TENANT_ID.get());
    }
}

