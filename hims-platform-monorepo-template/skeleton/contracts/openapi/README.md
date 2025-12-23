# API Contracts

This directory contains versioned OpenAPI specifications for all services.

## Structure

```
openapi/
├── backend-api/
│   └── v1/
│       └── api.yaml
├── analytics-api/
│   └── v1/
│       └── api.yaml
└── frontend-api/
    └── v1/
        └── api.yaml
```

## Versioning

- APIs are versioned by directory (v1, v2, etc.)
- Breaking changes require a new version
- Non-breaking changes can be made to existing versions

## Usage

These contracts are used to:
- Generate API clients
- Validate API requests/responses
- Generate documentation
- Enforce API contracts in tests

