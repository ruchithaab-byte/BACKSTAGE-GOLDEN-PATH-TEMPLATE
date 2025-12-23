package com.hims.core.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Module configuration.
 * 
 * Provides centralized module wiring configuration.
 * Modules should use this instead of reading configuration directly.
 */
@Component
@ConfigurationProperties(prefix = "modules")
public class ModuleConfig {

    private Map<String, ModuleSettings> settings;

    public Map<String, ModuleSettings> getSettings() {
        return settings;
    }

    public void setSettings(Map<String, ModuleSettings> settings) {
        this.settings = settings;
    }

    public static class ModuleSettings {
        private boolean enabled;
        private String version;
        private Map<String, String> properties;

        public boolean isEnabled() {
            return enabled;
        }

        public void setEnabled(boolean enabled) {
            this.enabled = enabled;
        }

        public String getVersion() {
            return version;
        }

        public void setVersion(String version) {
            this.version = version;
        }

        public Map<String, String> getProperties() {
            return properties;
        }

        public void setProperties(Map<String, String> properties) {
            this.properties = properties;
        }
    }
}

