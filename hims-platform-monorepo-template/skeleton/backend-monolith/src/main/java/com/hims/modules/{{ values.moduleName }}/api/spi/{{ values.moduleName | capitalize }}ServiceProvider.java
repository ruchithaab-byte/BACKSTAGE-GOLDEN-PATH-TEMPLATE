package com.hims.modules.{{ values.moduleName }}.api.spi;

/**
 * Service Provider Interface for {{ values.moduleName }} module.
 * 
 * This interface defines the public API for this module.
 * Other modules can depend on this interface, but NOT on internal implementation.
 * 
 * Key Rule: API packages are public contracts; internal packages are private.
 */
public interface {{ values.moduleName | capitalize }}ServiceProvider {
    
    // Placeholder - add actual service methods here
    // Methods should use DTOs from api.dto package
    
}

