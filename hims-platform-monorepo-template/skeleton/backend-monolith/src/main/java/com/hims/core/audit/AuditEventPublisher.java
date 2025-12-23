package com.hims.core.audit;

/**
 * Interface for publishing audit events.
 * 
 * This is a domain-agnostic event publisher. The actual transport
 * (Kafka, outbox, etc.) is an implementation detail.
 * 
 * Key Rule: Core publishes events; modules define meaning.
 */
public interface AuditEventPublisher {

    /**
     * Publishes an audit event.
     * 
     * @param event The audit event to publish
     */
    void publish(AuditEvent event);
}

