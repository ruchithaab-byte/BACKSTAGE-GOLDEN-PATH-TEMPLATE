package com.hims.modules.{{ values.moduleName }}.internal.repo;

import com.hims.modules.{{ values.moduleName }}.internal.domain.{{ values.moduleName | capitalize }}Entity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

/**
 * Repository for {{ values.moduleName }} entities.
 * 
 * This is a placeholder - add actual query methods here.
 * 
 * Key Rules:
 * - Repositories MUST be in internal package
 * - Repositories MUST NOT be exposed in API package
 * - Queries automatically filtered by tenant_id via RLS
 */
@Repository
public interface {{ values.moduleName | capitalize }}Repository extends JpaRepository<{{ values.moduleName | capitalize }}Entity, UUID> {
    
    // Placeholder - add actual query methods here
    // RLS policies ensure tenant isolation automatically
    
}

