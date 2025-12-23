package com.hims.core.events;

import java.time.Instant;
import java.util.HashMap;
import java.util.Map;

/**
 * Event metadata builder.
 * 
 * Provides a convenient way to build event metadata with
 * tenant, user, and timestamp information.
 */
public class EventMetadata {

    private final Map<String, Object> metadata = new HashMap<>();

    public static EventMetadata create() {
        return new EventMetadata();
    }

    public EventMetadata withTenant(String tenantId) {
        metadata.put("tenantId", tenantId);
        return this;
    }

    public EventMetadata withUser(String userId) {
        metadata.put("userId", userId);
        return this;
    }

    public EventMetadata withTimestamp(Instant timestamp) {
        metadata.put("timestamp", timestamp.toString());
        return this;
    }

    public EventMetadata withProperty(String key, Object value) {
        metadata.put(key, value);
        return this;
    }

    public Map<String, Object> build() {
        // Ensure timestamp is always set
        if (!metadata.containsKey("timestamp")) {
            metadata.put("timestamp", Instant.now().toString());
        }
        return new HashMap<>(metadata);
    }
}

