# Backend API - v1

This directory contains OpenAPI 3.0 specifications for the HIMS Platform backend API v1.

## API Specifications

### Authentication API (`auth-api.yaml`)
- **Base Path**: `/api/v1/auth`
- **Endpoints**:
  - `POST /login` - User login
  - `GET /me` - Get current user profile
  - `POST /validate` - Validate JWT token
  - `GET /health` - Health check

### Clinical API (`clinical-api.yaml`)
- **Base Path**: `/api/v1/patients`
- **Endpoints**:
  - `POST /` - Register new patient
  - `GET /{id}` - Get patient by ID
  - `GET /search?name={name}` - Search patients by name
  - `GET /health` - Health check

## Contract-First Development

These OpenAPI specs are the **source of truth** for API contracts. All controllers must conform to these specifications.

### Validation
- Controllers are validated against these specs at runtime
- API documentation is auto-generated from these specs
- Client SDKs can be generated from these specs

### Versioning
- Breaking changes require a new version (v2, v3, etc.)
- Non-breaking changes can be made to existing versions
- Version is specified in the URL path (`/api/v1/...`)

## Usage

### View API Documentation
1. Start the backend service
2. Navigate to: `http://localhost:8080/swagger-ui.html`
3. Select API group: "Authentication API" or "Clinical API"

### Generate Client SDKs
```bash
# Using openapi-generator
openapi-generator generate \
  -i contracts/openapi/backend-api/v1/auth-api.yaml \
  -g java \
  -o generated-clients/auth-api-client
```

### Validate API Contracts
```bash
# Using spectral
spectral lint contracts/openapi/backend-api/v1/*.yaml
```

## Testing

See `docs/API_TESTING.md` for curl commands and test scenarios.

