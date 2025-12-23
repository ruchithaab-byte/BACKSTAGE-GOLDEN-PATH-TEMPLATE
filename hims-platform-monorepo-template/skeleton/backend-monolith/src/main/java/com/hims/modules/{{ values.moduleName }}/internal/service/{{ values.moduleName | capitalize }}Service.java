package com.hims.modules.{{ values.moduleName }}.internal.service;

import com.hims.core.audit.LogAudit;
import com.hims.core.events.EventPublisher;
import com.hims.core.events.EventMetadata;
import com.hims.core.tenant.TenantContext;
import com.hims.modules.{{ values.moduleName }}.api.spi.{{ values.moduleName | capitalize }}ServiceProvider;
import com.hims.modules.{{ values.moduleName }}.internal.repo.{{ values.moduleName | capitalize }}Repository;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * Service implementation for {{ values.moduleName }} module.
 * 
 * This is a placeholder - add actual business logic here.
 * 
 * Key Rules:
 * - Services MUST implement API interface
 * - Services MUST use Core Kernel (audit, events, tenant context)
 * - Services MUST NOT access other modules' internal packages
 */
@Service
public class {{ values.moduleName | capitalize }}Service implements {{ values.moduleName | capitalize }}ServiceProvider {

    private final {{ values.moduleName | capitalize }}Repository repository;
    private final EventPublisher eventPublisher;

    public {{ values.moduleName | capitalize }}Service(
            {{ values.moduleName | capitalize }}Repository repository,
            EventPublisher eventPublisher) {
        this.repository = repository;
        this.eventPublisher = eventPublisher;
    }

    /**
     * Example method showing Core Kernel integration.
     * 
     * Replace with actual business logic.
     */
    @LogAudit(
        action = "CREATE_{{ values.moduleName | upper }}",
        resourceType = "{{ values.moduleName | upper }}",
        description = "Create {{ values.moduleName }}"
    )
    public void createExample() {
        // Tenant context is automatically set by Core Kernel
        String tenantId = TenantContext.getTenantId();
        String userId = TenantContext.getUserId();
        
        // Placeholder - add actual business logic here
        
        // Publish event via Core Kernel
        eventPublisher.publish(
            "{{ values.moduleName }}.created",
            Map.of("id", "example-id"),
            EventMetadata.create()
                .withTenant(tenantId)
                .withUser(userId)
                .build()
        );
    }
}

