# Event Contracts

This directory contains Kafka event schemas for all domain events.

## Structure

```
events/
├── clinical-events/
│   └── v1/
│       └── events.yaml
├── billing-events/
│   └── v1/
│       └── events.yaml
└── inventory-events/
    └── v1/
        └── events.yaml
```

## Schema Formats

Events can be defined in:
- JSON Schema
- Avro
- Protobuf

## Versioning

- Events are versioned by directory (v1, v2, etc.)
- Breaking changes require a new version
- Event schemas should be backward compatible when possible

