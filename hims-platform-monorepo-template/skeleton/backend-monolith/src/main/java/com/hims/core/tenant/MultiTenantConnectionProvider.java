package com.hims.core.tenant;

import org.hibernate.cfg.AvailableSettings;
import org.hibernate.engine.jdbc.connections.spi.AbstractDataSourceBasedMultiTenantConnectionProviderImpl;
import org.springframework.boot.autoconfigure.orm.jpa.HibernatePropertiesCustomizer;
import org.springframework.stereotype.Component;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Map;

/**
 * Hibernate multi-tenant connection provider that sets PostgreSQL session variables.
 * 
 * This sets `app.current_tenant` and `app.current_user` in PostgreSQL
 * before any queries execute, enabling RLS policies to work correctly.
 * 
 * Key Rule: RLS variables must be set BEFORE any queries.
 */
@Component
public class MultiTenantConnectionProvider
        extends AbstractDataSourceBasedMultiTenantConnectionProviderImpl
        implements HibernatePropertiesCustomizer {

    private final DataSource dataSource;

    public MultiTenantConnectionProvider(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    @Override
    protected DataSource selectAnyDataSource() {
        return dataSource;
    }

    @Override
    protected DataSource selectDataSource(String tenantIdentifier) {
        return dataSource;
    }

    @Override
    public void customize(Map<String, Object> hibernateProperties) {
        hibernateProperties.put(AvailableSettings.MULTI_TENANT_CONNECTION_PROVIDER, this);
        hibernateProperties.put(AvailableSettings.MULTI_TENANT_IDENTIFIER_RESOLVER, 
            new TenantIdentifierResolver());
    }

    public Connection getConnection(String tenantIdentifier) throws SQLException {
        Connection connection = selectDataSource(tenantIdentifier).getConnection();
        
        // Set PostgreSQL session variables for RLS
        try (Statement stmt = connection.createStatement()) {
            String tenantId = TenantContext.getTenantId();
            String userId = TenantContext.getUserId();
            
            if (tenantId != null) {
                stmt.execute("SET app.current_tenant = '" + tenantId + "'");
            }
            
            if (userId != null) {
                // Note: using current_user_id to avoid reserved keyword conflict
                stmt.execute("SET app.current_user_id = '" + userId + "'");
            }
        }
        
        return connection;
    }
}

