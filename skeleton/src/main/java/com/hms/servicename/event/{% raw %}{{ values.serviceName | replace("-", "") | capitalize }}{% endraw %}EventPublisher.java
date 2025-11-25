package com.hms.{{ values.serviceName | replace("-", "") }}.event;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.UUID;

/**
 * Service for publishing domain events to Kafka.
 * 
 * Usage Example:
 * <pre>
 * {@code
 * @Autowired private {{ values.serviceName | replace("-", "") | capitalize }}EventPublisher eventPublisher;
 * 
 * // In your service method:
 * MyDomainEvent event = new MyDomainEvent(userId, action);
 * eventPublisher.publish("hms.domain.myevent", event);
 * }
 * </pre>
 */
@Service
public class {{ values.serviceName | replace("-", "") | capitalize }}EventPublisher {
    
    private static final Logger log = LoggerFactory.getLogger({{ values.serviceName | replace("-", "") | capitalize }}EventPublisher.class);
    
    private final KafkaTemplate<String, Object> kafkaTemplate;
    
    public {{ values.serviceName | replace("-", "") | capitalize }}EventPublisher(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }
    
    /**
     * Publish an event to a specific Kafka topic.
     * 
     * @param topic The Kafka topic name (e.g., "hms.user.created")
     * @param event The event object to publish
     */
    public void publish(String topic, {{ values.serviceName | replace("-", "") | capitalize }}BaseEvent event) {
        // Set event metadata
        if (event.getEventId() == null) {
            event.setEventId(UUID.randomUUID().toString());
        }
        if (event.getEventType() == null) {
            event.setEventType(event.getClass().getSimpleName());
        }
        
        // Publish to Kafka
        kafkaTemplate.send(topic, event.getEventId(), event)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        log.error("Failed to publish event to topic={}: {}", topic, event, ex);
                    } else {
                        log.info("Published event to topic={}: eventId={}, eventType={}", 
                                topic, event.getEventId(), event.getEventType());
                    }
                });
    }
    
    /**
     * Publish an event with a specific partition key.
     * Useful for ensuring events for the same entity go to the same partition.
     * 
     * @param topic The Kafka topic name
     * @param partitionKey The key to determine partition (e.g., userId, tenantId)
     * @param event The event object to publish
     */
    public void publishWithKey(String topic, String partitionKey, {{ values.serviceName | replace("-", "") | capitalize }}BaseEvent event) {
        if (event.getEventId() == null) {
            event.setEventId(UUID.randomUUID().toString());
        }
        if (event.getEventType() == null) {
            event.setEventType(event.getClass().getSimpleName());
        }
        
        kafkaTemplate.send(topic, partitionKey, event)
                .whenComplete((result, ex) -> {
                    if (ex != null) {
                        log.error("Failed to publish event to topic={} with key={}: {}", 
                                topic, partitionKey, event, ex);
                    } else {
                        log.info("Published event to topic={} with key={}: eventId={}, eventType={}",
                                topic, partitionKey, event.getEventId(), event.getEventType());
                    }
                });
    }
}
