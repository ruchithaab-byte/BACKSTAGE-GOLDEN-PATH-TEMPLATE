package com.hims.modules.{{ values.moduleName }}.internal.listener;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

/**
 * Kafka event listener for {{ values.moduleName }} module.
 * 
 * This is a placeholder - add actual event listeners here.
 * 
 * Key Rules:
 * - Listeners MUST be in internal package
 * - Listeners MUST handle events from other modules
 * - Listeners MUST use Core Kernel for tenant context
 */
@Component
public class {{ values.moduleName | capitalize }}EventListener {

    /**
     * Example listener - replace with actual event handling.
     */
    @KafkaListener(topics = "{{ values.moduleName }}-events", groupId = "{{ values.platformName }}-{{ values.moduleName }}")
    public void handleEvent(String eventJson) {
        // Placeholder - add actual event handling logic here
        // Tenant context is automatically set by Core Kernel
    }
}

