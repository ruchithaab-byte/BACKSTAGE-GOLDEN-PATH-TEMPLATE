#!/bin/bash

# Reset database for local development
# WARNING: This will drop and recreate the database

set -e

DB_NAME="{{ values.postgresDbName }}"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

echo "⚠️  WARNING: This will drop and recreate the database: $DB_NAME"
read -p "Are you sure? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo "Dropping database..."
PGPASSWORD=postgres psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "DROP DATABASE IF EXISTS $DB_NAME;"

echo "Creating database..."
PGPASSWORD=postgres psql -h $DB_HOST -p $DB_PORT -U $DB_USER -c "CREATE DATABASE $DB_NAME;"

echo "Running migrations..."
cd backend-monolith
mvn flyway:migrate

echo "✅ Database reset complete!"

