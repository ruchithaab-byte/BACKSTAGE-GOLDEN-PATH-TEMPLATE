# Core Kernel Scope Declaration

## Purpose

This document defines **exactly** what the Core Kernel IS and IS NOT. This prevents kernel bloat and ensures clean module boundaries.

**Date**: 2025-01-21  
**Phase**: 1.2  
**Status**: Active

---

## 🎯 Core Kernel IS (What It Does)

### 1. Cross-Cutting Infrastructure
- **Purpose**: Provides shared infrastructure that ALL modules need
- **Examples**: 
  - Security filters
  - Context propagation
  - Event publishing transport
  - Configuration management

### 2. Security Plumbing
- **Purpose**: Authentication and authorization infrastructure
- **Scope**:
  - JWT validation
  - Scalekit token parsing
  - User + tenant extraction from tokens
  - Security filter chain setup
- **Key Rule**: Auth **sets context**, it does NOT decide permissions

### 3. Context Propagation
- **Purpose**: Thread-safe context management
- **Scope**:
  - `TenantContext` (ThreadLocal / Reactor context)
  - PostgreSQL session variables (`app.current_tenant`, `app.current_user`)
  - Request context propagation
- **Key Rule**: Context must be set **before any DB access**

### 4. Compliance Hooks
- **Purpose**: Audit and compliance infrastructure
- **Scope**:
  - `@LogAudit` annotation
  - Audit event publisher (Kafka / outbox)
  - Compliance metadata capture
- **Key Rule**: Audit captures **facts**, not interpretations

### 5. Configuration Management
- **Purpose**: Centralized configuration access
- **Scope**:
  - Feature flags
  - Module wiring
  - Environment profiles
  - Property resolution
- **Key Rule**: No module should read env vars directly

### 6. Event Transport
- **Purpose**: Domain-agnostic event publishing
- **Scope**:
  - Event publisher interface
  - Kafka transport
  - Event metadata (tenant, user, timestamp)
- **Key Rule**: Core publishes events; modules define meaning

---

## 🚫 Core Kernel IS NOT (What It Does NOT Do)

### 1. Business Logic
- ❌ No business rules
- ❌ No domain workflows
- ❌ No feature behavior
- ❌ No business entities

### 2. Domain-Specific Code
- ❌ No module-specific repositories
- ❌ No module-specific services
- ❌ No module-specific DTOs
- ❌ No module-specific configurations

### 3. Permission Decisions
- ❌ No role-based access control (RBAC) logic
- ❌ No permission checks (Permit.io handles that)
- ❌ No authorization decisions
- ✅ Only provides context for authorization

### 4. Schema Generation
- ❌ No database schema definitions
- ❌ No migration scripts
- ❌ No entity mappings (except audit tables)
- ✅ Only provides RLS context variables

### 5. Event Schemas
- ❌ No domain event definitions
- ❌ No event schemas (those live in `/contracts`)
- ✅ Only provides transport + metadata

---

## 📦 Core Kernel Package Structure

```
core/
├── auth/              # Authentication infrastructure
│   ├── JwtTokenValidator
│   ├── ScalekitTokenParser
│   ├── UserContextExtractor
│   └── SecurityConfig
│
├── tenant/            # Multi-tenancy infrastructure
│   ├── TenantContext
│   ├── TenantContextHolder
│   ├── MultiTenantConnectionProvider
│   └── TenantAspect
│
├── audit/             # Audit logging infrastructure
│   ├── LogAudit (annotation)
│   ├── AuditAspect
│   ├── AuditEventPublisher
│   └── AuditEvent
│
├── config/            # Configuration management
│   ├── FeatureFlags
│   ├── ModuleConfig
│   └── EnvironmentConfig
│
└── events/            # Event publishing infrastructure
    ├── EventPublisher
    ├── KafkaEventPublisher
    └── EventMetadata
```

---

## 🔒 ArchUnit Rules (Boundary Enforcement)

### Rule 1: Core Cannot Depend on Modules
```java
@ArchTest
static final ArchRule coreShouldNotDependOnModules = 
    noClasses()
        .that().resideInAPackage("com.hims.core..")
        .should().dependOnClassesThat()
        .resideInAPackage("com.hims.modules..");
```

### Rule 2: Modules May Depend on Core
```java
@ArchTest
static final ArchRule modulesMayDependOnCore = 
    classes()
        .that().resideInAPackage("com.hims.modules..")
        .should().onlyDependOnClassesThat()
        .resideInAnyPackage(
            "com.hims.modules..",
            "com.hims.core..",
            "java..",
            "org.springframework.."
        );
```

### Rule 3: Core Cannot Have Business Entities
```java
@ArchTest
static final ArchRule coreShouldNotHaveBusinessEntities = 
    noClasses()
        .that().resideInAPackage("com.hims.core..")
        .should().beAnnotatedWith(Entity.class)
        .orShould().beAnnotatedWith(Table.class);
```

---

## ✅ Phase 1.2 Completion Criteria

Phase 1.2 is complete when:

- [x] Core kernel compiles
- [x] App starts with no modules present
- [x] Tenant context is correctly set
- [x] RLS variables are injected
- [x] Audit hook is callable (even if no real sink yet)
- [x] ArchUnit rules enforce boundaries:
  - Core cannot depend on modules
  - Modules may depend on core
  - Core cannot have business entities

---

## 🎯 Design Principles

### 1. Thin & Stable
- Core kernel should be **boring**
- Changes should be rare
- Stability over features

### 2. Infrastructure Only
- No business semantics
- No domain knowledge
- Pure plumbing

### 3. Context Provider
- Sets context for modules
- Does not make decisions
- Provides hooks, not logic

### 4. Testable
- All components unit testable
- No external dependencies in tests
- Mock-friendly interfaces

---

## 📝 Notes

- **Kernel Bloat Prevention**: If you find yourself adding business logic to core, STOP and move it to a module
- **Extraction Path**: Core should be extractable to a shared library if needed
- **Versioning**: Core changes should be backward compatible
- **Documentation**: Every core component must have clear javadoc explaining its purpose

---

**This scope is LOCKED for Phase 1.2. Any changes must be approved and documented.**

