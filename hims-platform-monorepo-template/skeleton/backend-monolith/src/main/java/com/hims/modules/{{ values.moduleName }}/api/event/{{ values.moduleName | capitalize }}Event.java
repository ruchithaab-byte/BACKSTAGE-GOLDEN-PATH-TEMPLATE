package com.hims.modules.{{ values.moduleName }}.api.event;

import java.time.Instant;
import java.util.Map;

/**
 * Domain event for {{ values.moduleName }} module.
 * 
 * This is a placeholder - replace with actual event structure.
 * Events are published via core.events.EventPublisher.
 * 
 * Key Rule: Events define meaning; Core provides transport.
 */
public record {{ values.moduleName | capitalize }}Event(
    String eventType,
    String resourceId,
    Map<String, Object> data,
    Instant timestamp
) {
    // Placeholder - no business logic
}

