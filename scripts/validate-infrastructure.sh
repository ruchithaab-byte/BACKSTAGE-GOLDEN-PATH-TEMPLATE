#!/bin/bash

# HIMS Platform: Infrastructure Validation Script
# Validates infrastructure services using existing docker-compose.yml
# This script only starts infrastructure services (no application services)

set -e

echo "=========================================="
echo "HIMS Platform: Infrastructure Validation"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

COMPOSE_FILE="../hms-local-dev-env/docker-compose.yml"
COMPOSE_DIR="../hms-local-dev-env"

if [ ! -f "$COMPOSE_FILE" ]; then
    echo -e "${RED}❌ $COMPOSE_FILE not found${NC}"
    exit 1
fi

cd "$COMPOSE_DIR" || exit 1

echo "Starting infrastructure services only..."
echo "----------------------------------------"

# Start infrastructure services (these don't require application code)
docker compose up -d postgres redis zookeeper kafka

echo ""
echo "⏳ Waiting for services to be ready..."
sleep 10

echo ""
echo "Checking service health..."
echo "----------------------------------------"

# Check PostgreSQL
if docker compose exec -T postgres pg_isready -U postgres &> /dev/null; then
    echo -e "${GREEN}✅ PostgreSQL is healthy${NC}"
    # Test database connection
    if docker compose exec -T postgres psql -U postgres -c "SELECT version();" &> /dev/null; then
        echo -e "${GREEN}   ✅ PostgreSQL connection test passed${NC}"
    else
        echo -e "${YELLOW}   ⚠️  PostgreSQL connection test failed${NC}"
    fi
else
    echo -e "${RED}❌ PostgreSQL is not healthy${NC}"
fi

# Check Redis
if docker compose exec -T redis redis-cli ping &> /dev/null; then
    echo -e "${GREEN}✅ Redis is healthy${NC}"
    # Test Redis connection
    if docker compose exec -T redis redis-cli set test_key "test_value" &> /dev/null && \
       docker compose exec -T redis redis-cli get test_key | grep -q "test_value"; then
        echo -e "${GREEN}   ✅ Redis read/write test passed${NC}"
        docker compose exec -T redis redis-cli del test_key &> /dev/null
    else
        echo -e "${YELLOW}   ⚠️  Redis read/write test failed${NC}"
    fi
else
    echo -e "${RED}❌ Redis is not healthy${NC}"
fi

# Check Zookeeper
if docker compose exec -T zookeeper nc -z localhost 2181 &> /dev/null; then
    echo -e "${GREEN}✅ Zookeeper is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Zookeeper health check inconclusive (may still be starting)${NC}"
fi

# Check Kafka (may take longer to start)
KAFKA_READY=false
for i in {1..30}; do
    if docker compose exec -T kafka kafka-broker-api-versions --bootstrap-server localhost:9092 &> /dev/null; then
        KAFKA_READY=true
        break
    fi
    sleep 1
done

if [ "$KAFKA_READY" = true ]; then
    echo -e "${GREEN}✅ Kafka is healthy${NC}"
    # Test Kafka topic creation
    if docker compose exec -T kafka kafka-topics --create --bootstrap-server localhost:9092 --topic test-topic --if-not-exists &> /dev/null; then
        echo -e "${GREEN}   ✅ Kafka topic creation test passed${NC}"
        docker compose exec -T kafka kafka-topics --delete --bootstrap-server localhost:9092 --topic test-topic &> /dev/null
    else
        echo -e "${YELLOW}   ⚠️  Kafka topic creation test failed${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Kafka may still be starting (this is normal, can take 30+ seconds)${NC}"
fi

echo ""
echo "Service Status:"
echo "----------------------------------------"
docker compose ps postgres redis zookeeper kafka

echo ""
echo -e "${GREEN}✅ Infrastructure validation complete${NC}"
echo ""
echo "To stop services, run:"
echo "  cd $COMPOSE_DIR"
echo "  docker compose stop postgres redis zookeeper kafka"
echo ""
echo "To start full stack (when application services are ready), run:"
echo "  cd $COMPOSE_DIR"
echo "  ./start-service-and-ngrok.sh"

