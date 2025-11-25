package com.hms.{{ values.serviceName | replace("-", "") }}.event;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;

/**
 * Base event for all HMS domain events.
 * Follows CloudEvents specification for event metadata.
 */
public abstract class {{ values.serviceName | replace("-", "") | capitalize }}BaseEvent {
    
    @JsonProperty("event_id")
    private String eventId;
    
    @JsonProperty("event_type")
    private String eventType;
    
    @JsonProperty("event_time")
    private Instant eventTime;
    
    @JsonProperty("tenant_id")
    private String tenantId;
    
    @JsonProperty("correlation_id")
    private String correlationId;
    
    protected {{ values.serviceName | replace("-", "") | capitalize }}BaseEvent() {
        this.eventTime = Instant.now();
    }
    
    // Getters and setters
    public String getEventId() { return eventId; }
    public void setEventId(String eventId) { this.eventId = eventId; }
    
    public String getEventType() { return eventType; }
    public void setEventType(String eventType) { this.eventType = eventType; }
    
    public Instant getEventTime() { return eventTime; }
    public void setEventTime(Instant eventTime) { this.eventTime = eventTime; }
    
    public String getTenantId() { return tenantId; }
    public void setTenantId(String tenantId) { this.tenantId = tenantId; }
    
    public String getCorrelationId() { return correlationId; }
    public void setCorrelationId(String correlationId) { this.correlationId = correlationId; }
}
