package com.hims.modules.{{ values.moduleName }}.internal.web;

import com.hims.modules.{{ values.moduleName }}.api.spi.{{ values.moduleName | capitalize }}ServiceProvider;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST controller for {{ values.moduleName }} module.
 * 
 * This is a placeholder - add actual endpoints here.
 * 
 * Key Rules:
 * - Controllers MUST use API interfaces (not internal classes)
 * - Controllers MUST be in internal package
 * - Controllers MUST NOT expose internal domain entities
 */
@RestController
@RequestMapping("/api/v1/{{ values.moduleName }}")
public class {{ values.moduleName | capitalize }}Controller {

    private final {{ values.moduleName | capitalize }}ServiceProvider service;

    public {{ values.moduleName | capitalize }}Controller({{ values.moduleName | capitalize }}ServiceProvider service) {
        this.service = service;
    }

    /**
     * Example endpoint - replace with actual endpoints.
     */
    @GetMapping("/health")
    public String health() {
        return "{{ values.moduleName }} module is healthy";
    }
}

