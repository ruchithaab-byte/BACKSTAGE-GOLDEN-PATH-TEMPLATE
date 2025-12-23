package com.hims.core.events;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * Kafka implementation of EventPublisher.
 * 
 * Publishes events to Kafka topics. The topic name is derived from
 * the event type (e.g., "patient.created" -> "patient-events").
 * 
 * Key Rule: Core publishes events; modules define meaning.
 */
@Component
public class KafkaEventPublisher implements EventPublisher {

    private static final Logger logger = LoggerFactory.getLogger(KafkaEventPublisher.class);

    private final KafkaTemplate<String, String> kafkaTemplate;
    private final ObjectMapper objectMapper;

    public KafkaEventPublisher(
            KafkaTemplate<String, String> kafkaTemplate,
            ObjectMapper objectMapper) {
        this.kafkaTemplate = kafkaTemplate;
        this.objectMapper = objectMapper;
    }

    @Override
    public void publish(String eventType, Object eventData, Map<String, Object> metadata) {
        try {
            String topic = deriveTopic(eventType);
            String eventJson = objectMapper.writeValueAsString(eventData);
            
            // Extract tenant ID from metadata for partitioning
            String tenantId = (String) metadata.getOrDefault("tenantId", "unknown");
            
            // Use async send with error handling to avoid blocking
            kafkaTemplate.send(topic, tenantId, eventJson)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        logger.warn("Failed to publish event {} to Kafka (topic: {}): {}. " +
                                   "Event will NOT be retried - consider enabling transactional outbox pattern for production.",
                                   eventType, topic, ex.getMessage());
                    } else {
                        logger.debug("Published event: {} to topic: {}", eventType, topic);
                    }
                });
        } catch (JsonProcessingException e) {
            logger.error("Failed to serialize event: {}", eventType, e);
            // In production, consider using transactional outbox pattern
        } catch (Exception e) {
            // Gracefully handle Kafka unavailability
            logger.warn("Kafka unavailable - event {} not published: {}", eventType, e.getMessage());
        }
    }

    private String deriveTopic(String eventType) {
        // Extract domain from event type (e.g., "patient.created" -> "patient-events")
        String[] parts = eventType.split("\\.");
        if (parts.length > 0) {
            return parts[0] + "-events";
        }
        return "domain-events";
    }
}

