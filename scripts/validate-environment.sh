#!/bin/bash

# HIMS Platform: Environment Validation Script
# Phase 0.2: Environment Validation
# This script validates the local development environment

# Don't exit on errors - we want to collect all validation results
set +e

echo "=========================================="
echo "HIMS Platform: Environment Validation"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track validation results
PASSED=0
FAILED=0
WARNINGS=0

# Function to print success
success() {
    echo -e "${GREEN}✅ $1${NC}"
    ((PASSED++))
}

# Function to print failure
failure() {
    echo -e "${RED}❌ $1${NC}"
    ((FAILED++))
}

# Function to print warning
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

echo "1. Checking Prerequisites..."
echo "----------------------------------------"

# Check Java
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | sed '/^1\./s///' | cut -d'.' -f1)
    if [ "$JAVA_VERSION" -ge 17 ]; then
        success "Java $JAVA_VERSION installed"
    else
        failure "Java 17+ required (found: $JAVA_VERSION)"
    fi
else
    failure "Java not found"
fi

# Check Maven
if command -v mvn &> /dev/null; then
    Maven_OUTPUT=$(mvn -version 2>&1)
    if echo "$Maven_OUTPUT" | grep -q "Apache Maven"; then
        Maven_VERSION=$(echo "$Maven_OUTPUT" | head -n 1 | awk '{print $3}' || echo "unknown")
        success "Maven $Maven_VERSION installed"
    else
        warning "Maven found but JAVA_HOME not configured (non-blocking for Phase 0)"
    fi
else
    warning "Maven not found (optional for Phase 0, required for Phase 1)"
fi

# Check Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | awk '{print $3}' | sed 's/,//')
    success "Docker $DOCKER_VERSION installed"
    
    # Check if Docker daemon is running
    if docker info &> /dev/null; then
        success "Docker daemon is running"
    else
        failure "Docker daemon is not running"
    fi
else
    failure "Docker not found"
fi

# Check Docker Compose
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
    success "Docker Compose installed"
else
    failure "Docker Compose not found"
fi

# Check PostgreSQL client (optional)
if command -v psql &> /dev/null; then
    success "PostgreSQL client (psql) installed"
else
    warning "PostgreSQL client (psql) not found (optional)"
fi

# Check Node.js (for Backstage) - Optional for Phase 0
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    success "Node.js $NODE_VERSION installed"
else
    warning "Node.js not found (optional for Phase 0, required for Backstage templates in Phase 1)"
fi

# Check Yarn (for Backstage) - Optional for Phase 0
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    success "Yarn $YARN_VERSION installed"
else
    warning "Yarn not found (optional for Phase 0, required for Backstage templates in Phase 1)"
fi

echo ""
echo "2. Checking Project Structure..."
echo "----------------------------------------"

# Check template.yaml
if [ -f "template.yaml" ]; then
    success "template.yaml exists"
    
    # Basic YAML validation
    if command -v python3 &> /dev/null; then
        YAML_ERROR=$(python3 -c "import yaml; yaml.safe_load(open('template.yaml'))" 2>&1)
        if [ $? -eq 0 ]; then
            success "template.yaml is valid YAML"
        else
            warning "template.yaml YAML validation failed: $YAML_ERROR (may be due to Nunjucks syntax)"
            echo "   Note: This is expected if template.yaml contains Nunjucks syntax"
        fi
    fi
else
    failure "template.yaml not found"
fi

# Check skeleton directory
if [ -d "skeleton" ]; then
    success "skeleton directory exists"
    
    # Check for key files
    if [ -f "skeleton/pom.xml" ]; then
        success "skeleton/pom.xml exists"
    else
        failure "skeleton/pom.xml not found"
    fi
    
    if [ -d "skeleton/src/main/java" ]; then
        success "skeleton/src/main/java exists"
    else
        failure "skeleton/src/main/java not found"
    fi
else
    failure "skeleton directory not found"
fi

# Check documentation
if [ -d "docs" ]; then
    success "docs directory exists"
    
    REQUIRED_DOCS=(
        "PHASED_IMPLEMENTATION_PLAN.md"
        "PHASE_CHECKLIST.md"
        "COMPREHENSIVE_IMPLEMENTATION_PLAN.md"
    )
    
    for doc in "${REQUIRED_DOCS[@]}"; do
        if [ -f "$doc" ]; then
            success "$doc exists"
        else
            warning "$doc not found"
        fi
    done
else
    warning "docs directory not found (will be created)"
fi

echo ""
echo "3. Checking Docker Compose Setup..."
echo "----------------------------------------"

# Check if docker-compose.yml exists in hms-local-dev-env
if [ -f "../hms-local-dev-env/docker-compose.yml" ]; then
    success "hms-local-dev-env/docker-compose.yml exists"
    
    # Try to validate docker-compose syntax
    if docker compose -f ../hms-local-dev-env/docker-compose.yml config &> /dev/null; then
        success "docker-compose.yml is valid"
    else
        warning "docker-compose.yml validation failed (may need services running)"
    fi
    
    # Check for start script
    if [ -f "../hms-local-dev-env/start-service-and-ngrok.sh" ]; then
        success "start-service-and-ngrok.sh exists"
        echo "   Use './scripts/validate-infrastructure.sh' to test infrastructure only"
        echo "   Use '../hms-local-dev-env/start-service-and-ngrok.sh' to start full stack"
    else
        warning "start-service-and-ngrok.sh not found"
    fi
else
    warning "hms-local-dev-env/docker-compose.yml not found (expected at ../hms-local-dev-env/)"
fi

echo ""
echo "4. Checking Schema Files..."
echo "----------------------------------------"

# Check if schema directory exists (try multiple locations)
SCHEMA_FOUND=false
SCHEMA_PATHS=(
    "../HIMSPlatform Design/schema"
    "../Downloads/HIMSPlatform Design/schema"
    "../../Downloads/HIMSPlatform Design/schema"
)

for SCHEMA_PATH in "${SCHEMA_PATHS[@]}"; do
    if [ -d "$SCHEMA_PATH" ]; then
        success "Schema directory exists at $SCHEMA_PATH"
        SCHEMA_FOUND=true
        
        # Check for key schema files
        KEY_SCHEMAS=(
            "01_core_schema.sql"
            "03_clinical_schema.sql"
            "05_billing_schema.sql"
        )
        
        for schema in "${KEY_SCHEMAS[@]}"; do
            if [ -f "$SCHEMA_PATH/$schema" ]; then
                success "$schema exists"
            else
                warning "$schema not found"
            fi
        done
        break
    fi
done

if [ "$SCHEMA_FOUND" = false ]; then
    warning "Schema directory not found at expected locations (optional for Phase 0, will be needed in Phase 1)"
fi

echo ""
echo "=========================================="
echo "Validation Summary"
echo "=========================================="
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ Environment validation PASSED${NC}"
    exit 0
else
    echo -e "${RED}❌ Environment validation FAILED${NC}"
    echo "Please fix the failures above before proceeding."
    exit 1
fi

