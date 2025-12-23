-- ============================================================================
-- POSTGRES INITIALIZATION SCRIPT
-- This script runs on first database startup
-- ============================================================================

-- Create application database (if not exists)
-- Note: The database itself is created by POSTGRES_DB environment variable
-- This script is for schema initialization

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";  -- For fuzzy text search

-- Note: Actual schema creation is handled by Flyway migrations
-- This script is for extensions and initial setup only

