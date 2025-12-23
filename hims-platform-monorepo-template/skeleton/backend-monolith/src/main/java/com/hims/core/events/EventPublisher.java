package com.hims.core.events;

import java.util.Map;

/**
 * Domain-agnostic event publisher interface.
 * 
 * This provides event publishing infrastructure. Event schemas
 * are defined in /contracts, not here.
 * 
 * Key Rule: Core publishes events; modules define meaning.
 */
public interface EventPublisher {

    /**
     * Publishes a domain event.
     * 
     * @param eventType The event type (e.g., "patient.created")
     * @param eventData The event data
     * @param metadata Additional metadata (tenant, user, timestamp)
     */
    void publish(String eventType, Object eventData, Map<String, Object> metadata);
}

