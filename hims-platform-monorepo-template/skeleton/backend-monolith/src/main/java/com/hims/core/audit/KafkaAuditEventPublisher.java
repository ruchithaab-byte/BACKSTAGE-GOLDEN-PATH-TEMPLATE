package com.hims.core.audit;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

/**
 * Kafka implementation of AuditEventPublisher.
 * 
 * Publishes audit events to Kafka topic "audit-events".
 * In production, this should use the transactional outbox pattern.
 */
@Component
public class KafkaAuditEventPublisher implements AuditEventPublisher {

    private static final Logger logger = LoggerFactory.getLogger(KafkaAuditEventPublisher.class);
    private static final String AUDIT_TOPIC = "audit-events";

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public KafkaAuditEventPublisher(
            KafkaTemplate<String, String> kafkaTemplate,
            ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    @Override
    public void publish(AuditEvent event) {
        try {
            String eventJson = objectMapper.writeValueAsString(event);
            kafkaTemplate.send(AUDIT_TOPIC, event.getTenantId(), eventJson)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        logger.warn("Failed to publish audit event {} to Kafka: {}. " +
                                   "In production, use transactional outbox pattern.",
                                   event.getAction(), ex.getMessage());
                    } else {
                        logger.debug("Published audit event: {}", event.getAction());
                    }
                });
        } catch (JsonProcessingException e) {
            logger.error("Failed to serialize audit event", e);
        } catch (Exception e) {
            // Gracefully handle Kafka unavailability
            logger.warn("Kafka unavailable - audit event {} not published: {}", event.getAction(), e.getMessage());
        }
    }
}

