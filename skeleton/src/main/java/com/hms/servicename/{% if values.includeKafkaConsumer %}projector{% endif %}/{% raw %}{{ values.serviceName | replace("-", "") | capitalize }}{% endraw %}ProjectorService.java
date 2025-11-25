package com.hms.{{ values.serviceName | replace("-", "") }}.projector;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;
import java.util.logging.Logger;

@Service
public class {{ values.serviceName | replace("-", "") | capitalize }}ProjectorService {

    private static final Logger LOGGER = Logger.getLogger({{ values.serviceName | replace("-", "") | capitalize }}ProjectorService.class.getName());
    private static final String VIEW_KEY_PREFIX = "{{ values.serviceName }}_view:";

    @Autowired
    private RedisTemplate<String, Object> redisTemplate;

    // This listener consumes events (e.g., from the Debezium outbox)
    @KafkaListener(topics = "{{ values.kafkaTopicName | default('domain-events') }}", 
                   groupId = "{{ values.kafkaGroupId | default('projector-group') }}")
    public void handleEvent(String eventPayload) {
        // In a real app, you'd deserialize this JSON event payload
        // into a rich domain event object.
        LOGGER.info("Received event: " + eventPayload);
        
        // TODO:
        // 1. Deserialize eventPayload to a domain event
        // 2. Get the ID from the event.
        // 3. Create/update a View DTO.
        // 4. Save it to Redis.
        
        // Example:
        // View view = buildView(event);
        // String key = VIEW_KEY_PREFIX + view.getId();
        // redisTemplate.opsForValue().set(key, view);
        
        LOGGER.info("View projection updated in Redis.");
    }
}
