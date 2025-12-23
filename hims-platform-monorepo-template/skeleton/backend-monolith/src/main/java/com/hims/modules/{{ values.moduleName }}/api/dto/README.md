# Module API - DTOs

This package contains Data Transfer Objects (DTOs) for the {{ values.moduleName }} module.

## Purpose

DTOs are used for:
- API request/response objects
- Cross-module communication
- Event payloads

## Rules

- DTOs MUST be immutable (use records or final classes)
- DTOs MUST NOT contain business logic
- DTOs MUST NOT reference internal package classes
- DTOs MAY reference other modules' API packages

## Example

```java
public record Create{{ values.moduleName | capitalize }}Request(
    String name,
    String description
) {}
```

