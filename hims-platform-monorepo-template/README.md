# HIMS Platform Monorepo Template

A Backstage Golden Path template for creating the complete HIMS Platform monorepo structure.

## Overview

This template scaffolds a complete monorepo with:
- **Backend Monolith**: Spring Boot 3.2 + Spring Modulith (Java 17+)
- **Analytics Worker**: FastAPI (Python 3.11)
- **Frontend**: Next.js 14 (TypeScript)
- **Infrastructure**: Docker Compose, Kubernetes, Terraform
- **Contracts**: OpenAPI, Kafka events, permissions
- **Documentation**: ADRs, HLDs, runbooks

## Usage

### In Backstage

1. Go to **Create Component** in Backstage
2. Select **"HIMS Platform Monorepo"** template
3. Fill in the wizard:
   - **Monorepo Setup**: Platform name, description, owner, system
   - **Initial Modules**: Select which modules to include (clinical, billing, inventory)
   - **Database Configuration**: PostgreSQL database name
   - **Repository Location**: GitHub/GitLab repository URL
4. Click **Create**

### Manual Execution

```bash
# Clone this template
git clone <template-repo>
cd hims-platform-monorepo-template

# Execute template (requires Backstage CLI or manual Nunjucks processing)
# See Backstage documentation for template execution
```

## Template Structure

```
hims-platform-monorepo-template/
├── template.yaml              # Backstage template definition
└── skeleton/                  # Template source code
    ├── backend-monolith/      # Spring Modulith application
    ├── analytics-worker/      # FastAPI worker
    ├── frontend/               # Next.js application
    ├── contracts/             # API/event contracts
    ├── infra/                  # Infrastructure as code
    ├── docs/                   # Documentation
    ├── scripts/                # Development scripts
    ├── docker-compose.yml      # Local orchestration
    └── catalog-info.yaml       # Backstage catalog entry
```

## Generated Structure

After execution, the template creates:

```
{{ values.platformName }}/
├── backend-monolith/
│   ├── src/main/java/com/hims/
│   │   ├── PlatformApplication.java
│   │   ├── core/              # Platform kernel (to be added in Phase 1.2)
│   │   └── modules/           # Business modules
│   ├── pom.xml
│   └── Dockerfile
├── analytics-worker/
│   ├── app/
│   ├── requirements.txt
│   └── Dockerfile
├── frontend/
│   ├── src/
│   ├── package.json
│   └── Dockerfile
├── contracts/
│   ├── openapi/
│   └── events/
├── infra/
│   ├── docker/
│   ├── k8s/
│   └── terraform/
├── docs/
│   ├── adr/
│   ├── hld/
│   └── runbooks/
├── scripts/
│   └── dev/
├── docker-compose.yml
└── README.md
```

## Parameters

### Required
- `platformName`: Name of the platform (kebab-case)
- `description`: Platform description
- `owner`: Backstage group/team owner
- `system`: Backstage system this belongs to
- `postgresDbName`: PostgreSQL database name
- `repoUrl`: Git repository URL

### Optional
- `includeClinicalModule`: Include clinical module (default: true)
- `includeBillingModule`: Include billing module (default: true)
- `includeInventoryModule`: Include inventory module (default: false)
- `includeSchemaInit`: Include initial schema migrations (default: true)

## Next Steps After Scaffolding

1. **Start Infrastructure**:
   ```bash
   docker-compose up -d postgres redis kafka
   ```

2. **Run Migrations**:
   ```bash
   cd backend-monolith
   mvn flyway:migrate
   ```

3. **Start Services**:
   ```bash
   # Backend
   cd backend-monolith
   mvn spring-boot:run
   
   # Analytics Worker
   cd analytics-worker
   python -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   uvicorn app.main:app --reload
   
   # Frontend
   cd frontend
   npm install
   npm run dev
   ```

4. **Add Core Kernel** (Phase 1.2):
   - Use the "Core Kernel" template to add auth, tenant, audit, config, events

5. **Add Modules** (Phase 1.4):
   - Use the "Modular Monolith Module" template to add business modules

## Dependencies

- Java 17+
- Maven 3.8+
- Node.js 20+
- Python 3.11+
- Docker & Docker Compose
- PostgreSQL 15+

## Related Templates

- **Core Kernel Template**: Adds platform kernel (auth, tenant, audit)
- **Modular Monolith Module Template**: Adds business modules
- **Schema Scaffolding**: Generates Flyway migrations

## Support

For questions or issues:
- See `docs/` in the generated repository
- Check Backstage documentation
- Contact platform team

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-21  
**Status**: Phase 1.1 Complete

