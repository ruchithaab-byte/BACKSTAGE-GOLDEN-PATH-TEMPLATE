package com.hims.core.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * Environment configuration.
 * 
 * Provides centralized access to environment-specific configuration.
 * Modules should use this instead of reading environment variables directly.
 * 
 * Key Rule: No module should read env vars directly.
 */
@Component
public class EnvironmentConfig {

    @Value("${spring.profiles.active:local}")
    private String activeProfile;

    @Value("${app.environment:development}")
    private String environment;

    @Value("${app.version:unknown}")
    private String version;

    public String getActiveProfile() {
        return activeProfile;
    }

    public String getEnvironment() {
        return environment;
    }

    public boolean isDevelopment() {
        return "development".equals(environment) || "local".equals(environment);
    }

    public boolean isProduction() {
        return "production".equals(environment);
    }

    public String getVersion() {
        return version;
    }
}

