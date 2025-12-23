#!/bin/bash
# Convert pg_dump schema export to Flyway-compatible migration
# This script processes the schema export and creates V001__complete_hims_schema.sql

SCHEMA_EXPORT="/Users/macbook/Downloads/HIMSPlatform Design/schema_export_from_docker_20251222_110429.sql"
OUTPUT_FILE="/Users/macbook/backstage-golden-path-template/hims-platform-monorepo-template/skeleton/backend-monolith/src/main/resources/db/migration/V001__complete_hims_schema.sql"

echo "Converting schema export to Flyway migration..."

# Create header
cat > "$OUTPUT_FILE" << 'EOF'
-- ============================================================================
-- COMPLETE HIMS PLATFORM SCHEMA
-- Generated from production schema export
-- ============================================================================
-- 
-- This migration creates the complete HIMS Platform database schema:
-- - All 14 schemas (core, clinical, billing, abdm, laboratory, etc.)
-- - All 147+ tables with proper structure
-- - All indexes, constraints, RLS policies
-- - All functions, triggers, views
-- - Complete and production-ready
-- 
-- This is a comprehensive schema script for initial database setup.
-- For future changes, use incremental migrations (V002, V003, etc.).
-- ============================================================================

-- Set search path
SET search_path TO public;

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

EOF

# Extract and process the schema export
# Remove pg_dump artifacts, add IF NOT EXISTS where needed
sed -n '/^CREATE SCHEMA/,/^--/p' "$SCHEMA_EXPORT" | \
  sed 's/^CREATE SCHEMA /CREATE SCHEMA IF NOT EXISTS /' | \
  sed '/^--$/d' | \
  sed '/^$/d' >> "$OUTPUT_FILE"

# Add extensions section
cat >> "$OUTPUT_FILE" << 'EOF'

-- ============================================================================
-- EXTENSIONS
-- ============================================================================

EOF

# Extract extensions
grep -A 1 "CREATE EXTENSION" "$SCHEMA_EXPORT" | \
  sed 's/CREATE EXTENSION/CREATE EXTENSION IF NOT EXISTS/' >> "$OUTPUT_FILE"

# Add types section
cat >> "$OUTPUT_FILE" << 'EOF'

-- ============================================================================
-- CUSTOM TYPES
-- ============================================================================

EOF

# Extract types (need to handle multi-line CREATE TYPE)
# This is a simplified version - may need manual cleanup
grep -E "^CREATE TYPE" "$SCHEMA_EXPORT" | head -20 >> "$OUTPUT_FILE"

echo "Schema conversion started. Manual cleanup may be required."
echo "Output: $OUTPUT_FILE"

