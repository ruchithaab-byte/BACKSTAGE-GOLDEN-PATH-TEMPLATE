package com.hims.core.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Feature flags configuration.
 * 
 * Provides centralized access to feature flags.
 * Modules should use this instead of reading environment variables directly.
 * 
 * Key Rule: No module should read env vars directly.
 */
@Component
public class FeatureFlags {

    @Value("${feature.flags.clinical-module.enabled:true}")
    private boolean clinicalModuleEnabled;

    @Value("${feature.flags.billing-module.enabled:true}")
    private boolean billingModuleEnabled;

    @Value("${feature.flags.inventory-module.enabled:false}")
    private boolean inventoryModuleEnabled;

    @Value("${feature.flags.analytics-enabled:true}")
    private boolean analyticsEnabled;

    public boolean isClinicalModuleEnabled() {
        return clinicalModuleEnabled;
    }

    public boolean isBillingModuleEnabled() {
        return billingModuleEnabled;
    }

    public boolean isInventoryModuleEnabled() {
        return inventoryModuleEnabled;
    }

    public boolean isAnalyticsEnabled() {
        return analyticsEnabled;
    }
}

