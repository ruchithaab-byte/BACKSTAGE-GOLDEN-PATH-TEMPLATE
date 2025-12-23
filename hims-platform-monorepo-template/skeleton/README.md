# {{ values.platformName | title }} Platform

{{ values.description }}

## Overview

This is a **modular monolith** platform built with:
- **Backend**: Spring Boot 3.2 + Spring Modulith (Java 17+)
- **Analytics Worker**: FastAPI (Python)
- **Frontend**: Next.js (TypeScript)
- **Database**: PostgreSQL 15+
- **Infrastructure**: Docker, Kubernetes, Terraform

## Architecture

```
{{ values.platformName }}/
├── backend-monolith/        # Spring Modulith application
├── analytics-worker/         # FastAPI worker (Kafka consumer)
├── frontend/                 # Next.js UI
├── contracts/                # Shared contracts (OpenAPI, events)
├── infra/                    # Infrastructure as code
├── docs/                     # Documentation
└── scripts/                  # Development scripts
```

## Quick Start

### Prerequisites
- Java 17+
- Maven 3.8+
- Node.js 20+
- Docker & Docker Compose
- PostgreSQL 15+

### Local Development

1. **Start Infrastructure**:
   ```bash
   cd infra/docker
   docker-compose up -d postgres redis kafka
   ```

2. **Start Backend**:
   ```bash
   cd backend-monolith
   mvn spring-boot:run
   ```

3. **Start Analytics Worker**:
   ```bash
   cd analytics-worker
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   uvicorn app.main:app --reload
   ```

4. **Start Frontend**:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

## Module Structure

### Backend Monolith (Spring Modulith)

```
backend-monolith/
├── core/                     # Platform kernel
│   ├── auth/                # Authentication & authorization
│   ├── tenant/              # Multi-tenancy
│   ├── audit/               # Audit logging
│   ├── config/              # Configuration
│   └── events/              # Event publishing
└── modules/                  # Business modules
    {% if values.includeClinicalModule %}
    ├── clinical/            # Clinical domain
    {% endif %}
    {% if values.includeBillingModule %}
    ├── billing/             # Billing domain
    {% endif %}
    {% if values.includeInventoryModule %}
    └── inventory/           # Inventory domain
    {% endif %}
```

**Key Rules**:
- Modules communicate via `api/` interfaces only
- No cross-module imports from `internal/`
- Use soft foreign keys (UUIDs) for cross-module references

## Contracts

- **OpenAPI**: `contracts/openapi/` - Versioned API specifications
- **Events**: `contracts/events/` - Kafka event schemas
- **Permissions**: `contracts/permissions/` - Permission catalog

## Documentation

- **ADRs**: `docs/adr/` - Architecture Decision Records
- **HLD**: `docs/hld/` - High-Level Design diagrams
- **API Docs**: `docs/api/` - API documentation
- **Runbooks**: `docs/runbooks/` - Operational procedures

## Development

### Adding a New Module

Use the Backstage template:
1. Go to Backstage → Create Component
2. Select "Modular Monolith Module" pattern
3. Follow the wizard

### Database Migrations

Migrations are in `backend-monolith/src/main/resources/db/migration/`

```bash
# Create new migration
cd backend-monolith
mvn flyway:migrate
```

## Testing

```bash
# Backend tests
cd backend-monolith
mvn test

# Frontend tests
cd frontend
npm test

# Analytics worker tests
cd analytics-worker
pytest
```

## Deployment

See `infra/k8s/` for Kubernetes manifests and `infra/terraform/` for cloud provisioning.

## Support

For questions, see:
- Architecture: `docs/hld/`
- Coding Standards: `docs/CODING_STANDARDS.md`
- API Documentation: `docs/api/`

---

**Owner**: {{ values.owner }}  
**System**: {{ values.system }}

