#!/bin/bash
#
# Golden Path Auto-Wiring Script
# 
# Purpose: Automatically register a newly scaffolded service in the local development environment.
# This script eliminates the manual 2-hour process of editing docker-compose.yml, Kuma configs, etc.
#
# Usage: ./post-scaffold.sh <service-name> <service-port>
# Example: ./post-scaffold.sh hms-payment-service 8082
#
# What it does:
# 1. Injects service definition into docker-compose.yml (idempotent)
# 2. Injects Kuma sidecar definition
# 3. Creates Kuma dataplane YAML configuration
# 4. Appends Postgres database creation SQL
# 5. Generates Kuma authentication token (if Kuma is running)
#
# Author: HMS Platform Team
# Date: 2025-11-26
#

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================

SERVICE_NAME="${1}"
SERVICE_PORT="${2:-8080}"  # Default to 8080 if not provided
DB_NAME=$(echo "$SERVICE_NAME" | tr '-' '_')  # Convert hyphens to underscores for DB name

LOCAL_DEV_ENV_DIR="../hms-local-dev-env"
DOCKER_COMPOSE_FILE="$LOCAL_DEV_ENV_DIR/docker-compose.yml"
KUMA_DATAPLANE_DIR="$LOCAL_DEV_ENV_DIR/kuma/dataplanes"
KUMA_TOKEN_DIR="$LOCAL_DEV_ENV_DIR/kuma/tokens"
POSTGRES_INIT_DIR="$LOCAL_DEV_ENV_DIR/postgres/init"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================================
# VALIDATION
# ============================================================================

if [ -z "$SERVICE_NAME" ]; then
    echo -e "${RED}❌ Error: Service name is required${NC}"
    echo "Usage: $0 <service-name> [service-port]"
    echo "Example: $0 hms-payment-service 8082"
    exit 1
fi

if [ ! -d "$LOCAL_DEV_ENV_DIR" ]; then
    echo -e "${RED}❌ Error: Local dev environment not found at $LOCAL_DEV_ENV_DIR${NC}"
    echo "Make sure you're running this script from the backstage-golden-path-template directory"
    exit 1
fi

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}❌ Error: docker-compose.yml not found at $DOCKER_COMPOSE_FILE${NC}"
    exit 1
fi

echo -e "${BLUE}🚀 Registering service: ${GREEN}$SERVICE_NAME${NC}"
echo -e "${BLUE}   Port: ${GREEN}$SERVICE_PORT${NC}"
echo -e "${BLUE}   Database: ${GREEN}$DB_NAME${NC}"
echo ""

# ============================================================================
# STEP 1: UPDATE DOCKER-COMPOSE.YML
# ============================================================================

echo -e "${YELLOW}📝 Step 1: Updating docker-compose.yml...${NC}"

# Check if service already exists (idempotent check)
if grep -q "^  $SERVICE_NAME:" "$DOCKER_COMPOSE_FILE"; then
    echo -e "${YELLOW}⚠️  Service $SERVICE_NAME already exists in docker-compose.yml. Skipping injection.${NC}"
else
    # Append main service definition
    cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  # -----------------------------------------------
  # Service: $SERVICE_NAME
  # -----------------------------------------------
  $SERVICE_NAME:
    build:
      context: ../$SERVICE_NAME
      dockerfile: Dockerfile
    container_name: $SERVICE_NAME
    ports:
      - "$SERVICE_PORT:8080"  # Host:Container
    environment:
      - SERVER_PORT=8080
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/$DB_NAME
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=postgres
      - SCALEKIT_ENVIRONMENT_URL=\${SCALEKIT_ENVIRONMENT_URL}
      - SCALEKIT_CLIENT_ID=\${SCALEKIT_CLIENT_ID}
      - SCALEKIT_CLIENT_SECRET=\${SCALEKIT_CLIENT_SECRET}
      - SCALEKIT_WEBHOOK_SECRET=\${SCALEKIT_WEBHOOK_SECRET}
      - PERMIT_API_KEY=\${PERMIT_API_KEY}
      - PERMIT_PDP_URL=http://permit-pdp:7000
      - KAFKA_BOOTSTRAP_SERVERS=kafka:9092
      - SPRING_REDIS_HOST=redis
      - SPRING_REDIS_PORT=6379
      - OTEL_SERVICE_NAME=$SERVICE_NAME
      - OTEL_TRACES_EXPORTER=otlp
      - OTEL_METRICS_EXPORTER=otlp
      - OTEL_LOGS_EXPORTER=otlp
      - OTEL_EXPORTER_OTLP_ENDPOINT=http://tempo:4317
      - OTEL_EXPORTER_OTLP_PROTOCOL=grpc
      - JAVA_TOOL_OPTIONS=-javaagent:/app/opentelemetry-javaagent.jar
    networks:
      - hms-network
    depends_on:
      postgres:
        condition: service_healthy
      kafka:
        condition: service_started
      redis:
        condition: service_healthy
      kuma-cp:
        condition: service_started
EOF
    echo -e "${GREEN}✅ Main service definition added${NC}"
fi

# Check if sidecar already exists
if grep -q "^  $SERVICE_NAME-sidecar:" "$DOCKER_COMPOSE_FILE"; then
    echo -e "${YELLOW}⚠️  Sidecar $SERVICE_NAME-sidecar already exists. Skipping injection.${NC}"
else
    # Append Kuma sidecar definition
    cat >> "$DOCKER_COMPOSE_FILE" <<EOF

  $SERVICE_NAME-sidecar:
    image: kumahq/kuma-dp:2.8.3
    container_name: $SERVICE_NAME-sidecar
    environment:
      - KUMA_CONTROL_PLANE_URL=http://kuma-cp:5681
      - KUMA_DATAPLANE_RUNTIME_TOKEN_PATH=/kuma/token
      - KUMA_DATAPLANE_NAME=$SERVICE_NAME
      - KUMA_DATAPLANE_MESH=default
      - KUMA_DATAPLANE_ADMIN_PORT=9901
    volumes:
      - ./kuma/dataplanes/$SERVICE_NAME.yaml:/kuma/dataplane.yaml:ro
      - ./kuma/tokens/$SERVICE_NAME-token:/kuma/token:ro
    network_mode: "service:$SERVICE_NAME"
    depends_on:
      - kuma-cp
      - $SERVICE_NAME
EOF
    echo -e "${GREEN}✅ Kuma sidecar definition added${NC}"
fi

# ============================================================================
# STEP 2: CREATE KUMA DATAPLANE CONFIGURATION
# ============================================================================

echo -e "${YELLOW}📝 Step 2: Creating Kuma dataplane configuration...${NC}"

mkdir -p "$KUMA_DATAPLANE_DIR"

DATAPLANE_FILE="$KUMA_DATAPLANE_DIR/$SERVICE_NAME.yaml"

if [ -f "$DATAPLANE_FILE" ]; then
    echo -e "${YELLOW}⚠️  Dataplane config already exists at $DATAPLANE_FILE. Skipping.${NC}"
else
    cat > "$DATAPLANE_FILE" <<EOF
type: Dataplane
mesh: default
name: $SERVICE_NAME
networking:
  address: 127.0.0.1
  inbound:
    - port: 8080
      servicePort: 8080
      tags:
        kuma.io/service: $SERVICE_NAME
        kuma.io/protocol: http
EOF
    echo -e "${GREEN}✅ Kuma dataplane config created at $DATAPLANE_FILE${NC}"
fi

# ============================================================================
# STEP 3: UPDATE POSTGRES INIT SCRIPT
# ============================================================================

echo -e "${YELLOW}📝 Step 3: Updating Postgres init script...${NC}"

POSTGRES_INIT_FILE="$POSTGRES_INIT_DIR/01-create-databases.sql"

if [ ! -f "$POSTGRES_INIT_FILE" ]; then
    echo -e "${YELLOW}⚠️  Postgres init script not found. Creating new file...${NC}"
    mkdir -p "$POSTGRES_INIT_DIR"
    cat > "$POSTGRES_INIT_FILE" <<EOF
-- Auto-generated database creation script
-- This file is managed by post-scaffold.sh

EOF
fi

# Check if database already exists in init script
if grep -q "CREATE DATABASE $DB_NAME" "$POSTGRES_INIT_FILE"; then
    echo -e "${YELLOW}⚠️  Database $DB_NAME already exists in init script. Skipping.${NC}"
else
    cat >> "$POSTGRES_INIT_FILE" <<EOF

-- Database for $SERVICE_NAME
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO postgres;
EOF
    echo -e "${GREEN}✅ Database creation SQL appended${NC}"
fi

# ============================================================================
# STEP 4: GENERATE KUMA TOKEN
# ============================================================================

echo -e "${YELLOW}📝 Step 4: Generating Kuma authentication token...${NC}"

mkdir -p "$KUMA_TOKEN_DIR"

TOKEN_FILE="$KUMA_TOKEN_DIR/$SERVICE_NAME-token"

if [ -f "$TOKEN_FILE" ]; then
    echo -e "${YELLOW}⚠️  Token already exists at $TOKEN_FILE. Skipping.${NC}"
else
    # Check if Kuma control plane is running
    if docker ps --format '{{.Names}}' | grep -q '^kuma-cp$'; then
        echo -e "${BLUE}   Generating token from running Kuma control plane...${NC}"
        docker exec kuma-cp kumactl generate dataplane-token \
            --name="$SERVICE_NAME" \
            --mesh=default > "$TOKEN_FILE" 2>/dev/null
        
        if [ -s "$TOKEN_FILE" ]; then
            echo -e "${GREEN}✅ Kuma token generated successfully${NC}"
        else
            echo -e "${RED}❌ Failed to generate token. File is empty.${NC}"
            rm -f "$TOKEN_FILE"
            echo -e "${YELLOW}⚠️  You'll need to generate the token manually after starting Kuma.${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Kuma control plane is not running.${NC}"
        echo -e "${YELLOW}   Token generation skipped. Generate it manually after starting the stack:${NC}"
        echo -e "${BLUE}   docker exec kuma-cp kumactl generate dataplane-token --name=$SERVICE_NAME --mesh=default > $TOKEN_FILE${NC}"
        
        # Create placeholder file
        echo "# Placeholder - generate token manually" > "$TOKEN_FILE"
    fi
fi

# ============================================================================
# SUMMARY
# ============================================================================

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Service $SERVICE_NAME successfully registered!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   ${GREEN}✓${NC} Service definition added to docker-compose.yml"
echo -e "   ${GREEN}✓${NC} Kuma sidecar configuration added"
echo -e "   ${GREEN}✓${NC} Kuma dataplane YAML created"
echo -e "   ${GREEN}✓${NC} Postgres database creation SQL added"
if [ -f "$TOKEN_FILE" ] && [ -s "$TOKEN_FILE" ] && ! grep -q "Placeholder" "$TOKEN_FILE"; then
    echo -e "   ${GREEN}✓${NC} Kuma authentication token generated"
else
    echo -e "   ${YELLOW}⚠${NC} Kuma token needs manual generation"
fi
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo ""
echo -e "   ${YELLOW}1.${NC} Start the local development environment:"
echo -e "      ${BLUE}cd $LOCAL_DEV_ENV_DIR${NC}"
echo -e "      ${BLUE}docker-compose up -d${NC}"
echo ""
echo -e "   ${YELLOW}2.${NC} If Kuma token wasn't generated, run:"
echo -e "      ${BLUE}docker exec kuma-cp kumactl generate dataplane-token --name=$SERVICE_NAME --mesh=default > kuma/tokens/$SERVICE_NAME-token${NC}"
echo ""
echo -e "   ${YELLOW}3.${NC} Start your service:"
echo -e "      ${BLUE}docker-compose up -d $SERVICE_NAME${NC}"
echo ""
echo -e "   ${YELLOW}4.${NC} Verify service is running:"
echo -e "      ${BLUE}curl http://localhost:$SERVICE_PORT/actuator/health${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
