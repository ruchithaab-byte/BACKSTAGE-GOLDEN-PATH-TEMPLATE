package com.hims.core.tenant;

import org.springframework.stereotype.Component;

/**
 * Holder for tenant context operations.
 * 
 * Provides a component interface for setting tenant context
 * from authentication information.
 */
@Component
public class TenantContextHolder {

    /**
     * Sets the tenant context from the provided tenant and user IDs.
     * 
     * @param tenantId The tenant ID
     * @param userId The user ID
     */
    public void setContext(String tenantId, String userId) {
        TenantContext.setTenantId(tenantId);
        TenantContext.setUserId(userId);
    }

    /**
     * Clears the tenant context.
     */
    public void clear() {
        TenantContext.clear();
    }

    /**
     * Gets the current tenant ID.
     * 
     * @return The tenant ID, or null if not set
     */
    public String getTenantId() {
        return TenantContext.getTenantId();
    }

    /**
     * Gets the current user ID.
     * 
     * @return The user ID, or null if not set
     */
    public String getUserId() {
        return TenantContext.getUserId();
    }
}

