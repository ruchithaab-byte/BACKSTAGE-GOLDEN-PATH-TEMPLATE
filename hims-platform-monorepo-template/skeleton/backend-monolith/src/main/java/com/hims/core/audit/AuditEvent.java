package com.hims.core.audit;

import java.time.Instant;
import java.util.Map;

/**
 * Represents an audit event.
 * 
 * This is a domain-agnostic audit event that captures facts about
 * what happened, not business interpretations.
 * 
 * Key Rule: Audit captures FACTS, not interpretations.
 */
public class AuditEvent {

    private final String action;
    private final String resourceType;
    private final String resourceId;
    private final String tenantId;
    private final String userId;
    private final Instant timestamp;
    private final Map<String, Object> metadata;
    private final String description;

    public AuditEvent(
            String action,
            String resourceType,
            String resourceId,
            String tenantId,
            String userId,
            Instant timestamp,
            Map<String, Object> metadata,
            String description) {
        this.action = action;
        this.resourceType = resourceType;
        this.resourceId = resourceId;
        this.tenantId = tenantId;
        this.userId = userId;
        this.timestamp = timestamp;
        this.metadata = metadata;
        this.description = description;
    }

    public String getAction() {
        return action;
    }

    public String getResourceType() {
        return resourceType;
    }

    public String getResourceId() {
        return resourceId;
    }

    public String getTenantId() {
        return tenantId;
    }

    public String getUserId() {
        return userId;
    }

    public Instant getTimestamp() {
        return timestamp;
    }

    public Map<String, Object> getMetadata() {
        return metadata;
    }

    public String getDescription() {
        return description;
    }
}

