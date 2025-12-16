# {{ values.serviceName }}

{{ values.description }}

---

## 🚀 Quick Start

### Prerequisites
- Java 21 (Eclipse Temurin recommended)
- Docker & Docker Compose
- Maven 3.9+

### Local Development Setup

#### 1. Register Service in Local Environment

After scaffolding this service, run the auto-wiring script to register it in the local development environment:

```bash
cd ../backstage-golden-path-template
./post-scaffold.sh {{ values.serviceName }} {{ values.servicePort }}
```

This script will automatically:
- ✅ Add service definition to `docker-compose.yml`
- ✅ Create Kuma sidecar configuration
- ✅ Generate Kuma dataplane YAML
- ✅ Update Postgres database creation script
- ✅ Generate Kuma authentication token (if Kuma is running)

#### 2. Start Local Development Environment

```bash
cd ../hms-local-dev-env
docker-compose up -d
```

#### 3. Start This Service

```bash
docker-compose up -d {{ values.serviceName }}
```

#### 4. Verify Service is Running

```bash
curl http://localhost:{{ values.servicePort }}/actuator/health
```

Expected response:
```json
{
  "status": "UP"
}
```

---

## 📋 Service Configuration

| Property | Value |
|----------|-------|
| **Service Name** | `{{ values.serviceName }}` |
| **Pattern** | `{{ values.servicePattern }}` |
| **Local Port** | `{{ values.servicePort }}` |
| **Database** | `{{ values.postgresDbName }}` |
| **Owner** | `{{ values.owner }}` |
| **System** | `{{ values.system }}` |

---

## 🏗️ Architecture

This service follows the **{{ values.servicePattern }}** pattern and includes:

{% if values.servicePattern == 'saas-backend-for-frontend' %}
### BFF Pattern Features
- ✅ OAuth2 Resource Server + OIDC Client
- ✅ ScaleKit SSO integration
- ✅ Permit.io authorization
- ✅ Session management (Redis)
- ✅ User management foundation
{% endif %}

{% if values.includeFlowable %}
### Flowable Workflow Features
- ✅ BPMN 2.0 workflow engine
- ✅ Kafka event-driven triggers
- ✅ Process automation
{% endif %}

{% if values.includeOutbox %}
### Transactional Outbox Features
- ✅ Atomic database + Kafka publishing
- ✅ Debezium CDC integration
- ✅ Event sourcing support
{% endif %}

{% if values.includeKafkaConsumer %}
### CQRS Read-Side Features
- ✅ Kafka consumer for projections
- ✅ Redis caching layer
- ✅ Denormalized read models
{% endif %}

### Core Infrastructure (Always Included)
- ✅ Multi-tenancy (schema-per-tenant)
- ✅ OpenTelemetry observability
- ✅ Structured logging (JSON in production)
- ✅ Flyway database migrations
- ✅ Spring Boot Actuator health checks
- ✅ Kuma service mesh integration

---

## 🔧 Development

### Build

```bash
mvn clean install
```

### Run Locally (without Docker)

```bash
# Set environment variables
export SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/{{ values.postgresDbName }}
export SCALEKIT_ENVIRONMENT_URL=https://your-env.scalekit.com
export SCALEKIT_CLIENT_ID=your-client-id
export SCALEKIT_CLIENT_SECRET=your-secret
export PERMIT_API_KEY=your-permit-key

# Run
mvn spring-boot:run
```

### Run Tests

```bash
mvn test
```

---

## 📊 Observability

### Health Check
```bash
curl http://localhost:{{ values.servicePort }}/actuator/health
```

### Metrics
```bash
curl http://localhost:{{ values.servicePort }}/actuator/metrics
```

### Logs
Logs are automatically shipped to Loki via OpenTelemetry. View them in Grafana:
```
http://localhost:3000
```

### Traces
Distributed traces are sent to Tempo. View them in Grafana:
```
http://localhost:3000/explore
```

---

## 🗄️ Database

### Schema
Database: `{{ values.postgresDbName }}`

### Migrations
Flyway migrations are located in `src/main/resources/db/migration/`

To run migrations manually:
```bash
mvn flyway:migrate
```

---

## 🔐 Security

### Authentication
{% if values.servicePattern == 'saas-backend-for-frontend' %}
- **OIDC Client**: Handles user login via ScaleKit
- **Resource Server**: Validates JWT tokens
{% else %}
- **Resource Server**: Validates JWT tokens from upstream services
{% endif %}

### Authorization
- **Permit.io**: Fine-grained RBAC
- **Multi-Tenancy**: Automatic tenant isolation

---

## 📚 API Documentation

{% if values.includeOpenApiContract %}
### OpenAPI Specification
API contract: `src/main/resources/api/openapi.yaml`

View Swagger UI:
```
http://localhost:{{ values.servicePort }}/swagger-ui.html
```
{% else %}
API documentation coming soon.
{% endif %}

---

## 🐛 Troubleshooting

### Service won't start
1. Check Docker is running: `docker ps`
2. Check database is healthy: `docker-compose ps postgres`
3. Check logs: `docker-compose logs {{ values.serviceName }}`

### Database connection errors
1. Verify database exists: `docker exec -it postgres psql -U postgres -l`
2. Check connection string in `docker-compose.yml`

### Kuma sidecar issues
1. Verify token exists: `cat ../hms-local-dev-env/kuma/tokens/{{ values.serviceName }}-token`
2. Regenerate token if needed:
   ```bash
   docker exec kuma-cp kumactl generate dataplane-token \
     --name={{ values.serviceName }} \
     --mesh=default > ../hms-local-dev-env/kuma/tokens/{{ values.serviceName }}-token
   ```

---

## 📝 Next Steps

1. **Implement Business Logic**: Add your controllers, services, and domain models
2. **Write Tests**: Add unit and integration tests
3. **Update API Contract**: Define your OpenAPI specification
4. **Configure CI/CD**: Set up GitHub Actions workflows
5. **Deploy**: Push to staging environment

---

## 🤝 Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for development guidelines.

---

## 📄 License

Copyright © 2025 HMS Platform Team
