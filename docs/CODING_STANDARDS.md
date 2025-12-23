# HIMS Platform: Coding Standards

## Overview

This document defines the coding standards and best practices for the HIMS Platform development. All code must adhere to these standards to ensure consistency, maintainability, and compliance.

**Last Updated**: 2025-01-21  
**Version**: 1.0

---

## 1. Java Coding Standards

### 1.1 General Principles

- **Java Version**: Java 17 (LTS) minimum, Java 21 preferred
- **Spring Boot**: 3.2.x
- **Code Style**: Follow Google Java Style Guide with modifications below
- **IDE**: Use IntelliJ IDEA or VS Code with Java extensions

### 1.2 Package Structure

```
com.hims/
├── core/                    # Platform kernel (shared plumbing)
│   ├── auth/
│   ├── tenant/
│   ├── audit/
│   ├── config/
│   └── events/
└── modules/                 # Functional modules (business domains)
    └── {module-name}/
        ├── api/             # PUBLIC: Interfaces, DTOs, Events (visible to others)
        │   ├── dto/
        │   ├── event/
        │   └── spi/         # Service Provider Interfaces
        └── internal/        # PRIVATE: Implementation details (hidden)
            ├── domain/      # JPA entities
            ├── repo/        # Spring Data repositories
            ├── service/     # Business logic
            ├── web/         # REST controllers
            └── listeners/   # Event listeners
```

**Rules**:
- Never import from `*.internal.*` packages across modules
- Cross-module communication via `api/` interfaces only
- Use ArchUnit to enforce boundaries

### 1.3 Naming Conventions

- **Classes**: PascalCase (`PatientService`, `InvoiceController`)
- **Methods**: camelCase (`createPatient`, `calculateTotal`)
- **Variables**: camelCase (`patientId`, `invoiceNumber`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_RETRY_ATTEMPTS`)
- **Packages**: lowercase (`com.hims.clinical.api`)

### 1.4 Code Organization

#### Controllers
- **Purpose**: Parse HTTP requests, validate input
- **Rules**:
  - No business logic in controllers
  - Never call repositories directly
  - Always use DTOs (never return entities)
  - Use `@Valid` for input validation

```java
@RestController
@RequestMapping("/api/v1/patients")
public class PatientController {
    
    private final PatientService patientService;
    
    @PostMapping
    public ResponseEntity<PatientDto> createPatient(
            @Valid @RequestBody CreatePatientRequest request) {
        PatientDto patient = patientService.createPatient(request);
        return ResponseEntity.ok(patient);
    }
}
```

#### Services
- **Purpose**: Business logic, orchestration
- **Rules**:
  - All business logic in services
  - Use `@Transactional` for database operations
  - Map entities to DTOs
  - Use service provider pattern for cross-module calls

```java
@Service
@Transactional
public class PatientService {
    
    private final PatientRepository patientRepository;
    private final TenantContext tenantContext;
    
    public PatientDto createPatient(CreatePatientRequest request) {
        Patient patient = new Patient();
        patient.setName(request.getName());
        patient.setTenantId(tenantContext.getCurrentTenantId());
        // ... set other fields
        
        Patient saved = patientRepository.save(patient);
        return toDto(saved);
    }
    
    private PatientDto toDto(Patient patient) {
        // Map entity to DTO
    }
}
```

#### Repositories
- **Purpose**: Data access only
- **Rules**:
  - Extend `JpaRepository` or `PagingAndSortingRepository`
  - Use `@Query` for complex queries
  - Always filter by `tenant_id` (RLS handles this, but be explicit)

```java
@Repository
public interface PatientRepository extends JpaRepository<Patient, UUID> {
    
    @Query("SELECT p FROM Patient p WHERE p.tenantId = :tenantId AND p.isActive = true")
    List<Patient> findActiveByTenant(@Param("tenantId") UUID tenantId);
}
```

### 1.5 DTOs (Data Transfer Objects)

**Mandatory**: Never return JPA entities directly from controllers.

```java
public class PatientDto {
    private UUID id;
    private String name;
    private LocalDate dateOfBirth;
    // ... other fields
    
    // Getters and setters
}
```

**Rules**:
- Separate DTOs for request and response
- Use `@JsonInclude(JsonInclude.Include.NON_NULL)` for optional fields
- Validate input DTOs with Bean Validation (`@NotNull`, `@Size`, etc.)

### 1.6 Error Handling

- Use `@ControllerAdvice` for global exception handling
- Create custom exceptions for business logic errors
- Return appropriate HTTP status codes
- Include error details in response

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleNotFound(EntityNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

---

## 2. Database Standards

### 2.1 Schema Design

- **Schema-per-Module**: Each module has its own PostgreSQL schema
- **No Cross-Schema FKs**: Use soft foreign keys (UUIDs) instead
- **RLS Policies**: All tenant-scoped tables must have RLS enabled
- **Naming**: Use snake_case for tables and columns

### 2.2 Migration Standards

- **Tool**: Flyway
- **Naming**: `V{version}__{description}.sql`
- **Versioning**: Sequential integers (V001, V002, etc.)
- **Rules**:
  - All migrations must be idempotent (use `IF NOT EXISTS`)
  - Never modify existing migrations
  - Always include rollback script in comments

```sql
-- V001__create_patients_table.sql
CREATE TABLE IF NOT EXISTS clinical.patients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES core.tenants(id),
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE clinical.patients ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON clinical.patients
    USING (tenant_id = current_setting('app.current_tenant', true)::UUID);
```

### 2.3 Compliance Fields

All PHI/PII tables must include:

```sql
tenant_id UUID NOT NULL REFERENCES core.tenants(id)
encryption_key_id UUID                    -- KMS key for encryption
data_sovereignty_tag data_sovereignty_region  -- INDIA_LOCAL, EU_CENTRAL, etc.
consent_ref UUID REFERENCES core.consent_logs(id)
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
created_by UUID
updated_by UUID
```

---

## 3. Module Boundaries

### 3.1 Service Provider Pattern

**Rule**: Cross-module calls must use interfaces defined in the consuming module.

**Example**: Billing module needs inventory information

```java
// In billing module (consumer)
public interface InventoryProvider {
    boolean isStockAvailable(String sku, int quantity);
}

// In inventory module (provider)
@Service
public class InventoryProviderImpl implements InventoryProvider {
    // Implementation
}
```

### 3.2 ArchUnit Rules

Enforce module boundaries with ArchUnit tests:

```java
@ArchTest
static final ArchRule noInternalImports = 
    noClasses()
        .that().resideInAPackage("..modules..api..")
        .should().dependOnClassesThat()
        .resideInAPackage("..modules..internal..");
```

---

## 4. Testing Standards

### 4.1 Unit Tests

- **Coverage**: > 80% for business logic
- **Framework**: JUnit 5
- **Mocking**: Mockito
- **Naming**: `{ClassName}Test.java`

```java
@ExtendWith(MockitoExtension.class)
class PatientServiceTest {
    
    @Mock
    private PatientRepository patientRepository;
    
    @InjectMocks
    private PatientService patientService;
    
    @Test
    void shouldCreatePatient() {
        // Test implementation
    }
}
```

### 4.2 Integration Tests

- **Framework**: `@SpringBootTest`
- **Database**: Testcontainers (PostgreSQL)
- **Naming**: `{ClassName}IntegrationTest.java`

```java
@SpringBootTest
@Testcontainers
class PatientControllerIntegrationTest {
    
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:15");
    
    @Autowired
    private TestRestTemplate restTemplate;
    
    @Test
    void shouldCreatePatient() {
        // Test implementation
    }
}
```

### 4.3 ArchUnit Tests

- **Purpose**: Enforce architectural rules
- **Location**: `src/test/java/com/hims/arch/`
- **Run**: In CI pipeline

---

## 5. Security Standards

### 5.1 Authentication & Authorization

- **Authentication**: ScaleKit JWT validation
- **Authorization**: Permit.io (sidecar)
- **Tenant Context**: Always set via `TenantContext`
- **RLS**: Database-level enforcement

### 5.2 Data Protection

- **Encryption**: Application-level encryption for sensitive fields
- **Key Management**: AWS KMS or HashiCorp Vault
- **Audit Logging**: All PHI/PII access logged
- **Compliance**: DPDP/HIPAA fields mandatory

---

## 6. Documentation Standards

### 6.1 Code Documentation

- **JavaDoc**: Required for public APIs
- **Comments**: Explain "why", not "what"
- **README**: Each module must have README.md

### 6.2 API Documentation

- **OpenAPI**: All REST APIs must have OpenAPI specs
- **Versioning**: APIs versioned (v1, v2, etc.)
- **Location**: `contracts/openapi/{service-name}/{version}/api.yaml`

### 6.3 Architecture Documentation

- **ADRs**: Architecture Decision Records in `docs/adr/`
- **HLD**: High-Level Design in `docs/hld/`
- **Runbooks**: Operational procedures in `docs/runbooks/`

---

## 7. Git Workflow

### 7.1 Branching Strategy

- **main**: Production-ready code
- **develop**: Integration branch
- **feature/{name}**: Feature development
- **fix/{name}**: Bug fixes

### 7.2 Commit Messages

Follow Conventional Commits:

```
feat: add patient creation endpoint
fix: correct tenant isolation in RLS policy
docs: update API documentation
refactor: extract common validation logic
test: add integration tests for billing module
```

### 7.3 Pull Requests

- **Title**: Clear, descriptive
- **Description**: What, why, how
- **Reviewers**: At least 2 approvals
- **CI**: All checks must pass

---

## 8. Code Review Checklist

### Before Submitting PR

- [ ] Code follows naming conventions
- [ ] No business logic in controllers
- [ ] DTOs used (no entities returned)
- [ ] Module boundaries respected
- [ ] Tests written (unit + integration)
- [ ] ArchUnit tests pass
- [ ] Documentation updated
- [ ] Migration scripts tested
- [ ] RLS policies verified
- [ ] Compliance fields included (if PHI/PII)

---

## 9. Tools & Plugins

### Required IDE Plugins

- **IntelliJ IDEA**:
  - Lombok
  - Spring Boot
  - ArchUnit
  - SonarLint

- **VS Code**:
  - Java Extension Pack
  - Spring Boot Extension Pack
  - SonarLint

### Build Tools

- **Maven**: Primary build tool
- **Spotless**: Code formatting
- **Checkstyle**: Code style validation
- **PMD**: Code quality checks

---

## 10. References

- [Google Java Style Guide](https://google.github.io/styleguide/javaguide.html)
- [Spring Boot Best Practices](https://spring.io/guides)
- [ArchUnit User Guide](https://www.archunit.org/userguide/html/000_Index.html)
- [FHIR R4 Specification](https://www.hl7.org/fhir/R4/)

---

**Questions?** Contact the Platform Team or create an issue in the project board.

