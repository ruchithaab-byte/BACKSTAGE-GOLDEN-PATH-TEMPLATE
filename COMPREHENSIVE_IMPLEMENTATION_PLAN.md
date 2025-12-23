# HIMS Platform: Comprehensive Implementation Plan

## Executive Summary

This document consolidates the repository structure review, Backstage Golden Path template strategy, schema design analysis, and agentic-coding-framework integration into a unified implementation roadmap for the HIMS Platform.

**Key Components:**
1. **Monorepo Structure** - Modular monolith with Spring Modulith
2. **Backstage Golden Path Templates** - Pattern-based service scaffolding
3. **Database Schema** - 13 schemas, 106+ tables, FHIR R4 compliant
4. **Agentic SDLC Framework** - Automated development lifecycle

**Current Status:**
- ✅ Schema Design: 72% complete (gap analysis identifies priorities)
- ✅ Repository Structure: Well-designed, aligned with Golden Path principles
- ⚠️ Backstage Templates: Need enhancement for monorepo support
- ⚠️ Schema-Template Integration: Missing automated schema scaffolding

---

## 1. Architecture Overview

### 1.1 System Architecture (C4 Level 2)

```
┌─────────────────────────────────────────────────────────────────--┐
│                    HIMS Platform Monorepo                         │
├───────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │              Frontend (Next.js)                            │   │
│  │  - Composable UI components                                │   │
│  │  - Feature-based organization (clinical, billing, etc.)    │   │
│  │  - ScaleKit authentication                                 │   │
│  └────────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐   │
│  │         Backend Monolith (Spring Modulith)                 │   │
│  │  ┌──────────────────────────────────────────────────────┐  │   │
│  │  │  Core Kernel (Platform Foundation)                   │  │   │
│  │  │  - auth/     (JWT, SecurityFilterChain)              │  │   │
│  │  │  - tenant/   (Multi-tenancy, RLS)                    │  │   │
│  │  │  - audit/    (@LogAudit, compliance)                 │  │   │
│  │  │  - config/   (Feature flags, module wiring)          │  │   │
│  │  │  - events/   (Event publisher utilities)             │  │   │
│  │  └──────────────────────────────────────────────────────┘  │   │
│  │                                                             │  │
│  │  ┌──────────────────────────────────────────────────────┐  │  │
│  │  │  Functional Modules (Business Domains)               │  │  │
│  │  │  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │  │  │
│  │  │  │  Clinical    │  │  Billing     │  │ Inventory │ │  │  │
│  │  │  │  - api/      │  │  - api/      │  │ - api/    │ │  │  │
│  │  │  │  - internal/ │  │  - internal/│  │ - internal│ │  │  │
│  │  │  └──────────────┘  └──────────────┘  └───────────┘ │  │  │
│  │  └──────────────────────────────────────────────────────┘  │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │         Analytics Worker (FastAPI)                         │  │
│  │  - Kafka consumer for events                               │  │
│  │  - ML model inference                                      │  │
│  │  - Analytics aggregation                                   │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │         Shared Contracts                                    │  │
│  │  - openapi/     (Versioned API specs)                      │  │
│  │  - events/      (Kafka event schemas)                      │  │
│  │  - permissions/ (Permission catalog)                      │  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │         Infrastructure as Code                             │  │
│  │  - docker/      (Local dev orchestration)                 │  │
│  │  - k8s/         (Kubernetes manifests)                    │  │
│  │  - terraform/   (Cloud provisioning)                      │  │
│  └────────────────────────────────────────────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
```

### 1.2 Database Architecture

```
PostgreSQL Database (13 Schemas, 106+ Tables)
├── core/              (21 tables) - Multi-tenancy, auth, audit
├── terminology/       (6 tables)  - SNOMED, LOINC, ICD-10, RxNorm
├── clinical/         (21 tables) - Patients, encounters, observations
├── inventory/        (9 tables)  - Items, batches, stock ledgers
├── billing/          (12 tables) - Invoices, payments, claims
├── scheduling/       (8 tables)  - Appointments, slots, queues
├── communication/    (6 tables)  - Notifications, templates
├── documents/        (4 tables)  - Document registry
├── integration/      (5 tables)  - Webhooks, HL7, endpoints
├── imaging/          (2 tables)  - Imaging orders, studies
├── abdm/             (3 tables)  - ABHA, care contexts, HIU
├── laboratory/       (3 tables)  - Samples, QC, alerts
└── blood_bank/       (4 tables)  - Donors, units, transfusions
```

**Key Design Principles:**
- **Schema-per-Module**: Each module has its own PostgreSQL schema
- **Soft Foreign Keys**: Cross-module references use UUIDs (no DB constraints)
- **Row Level Security (RLS)**: All tenant-scoped tables enforce RLS
- **FHIR R4 Alignment**: Clinical tables map to FHIR resources
- **Compliance Overlay**: DPDP/HIPAA fields (encryption_key_id, data_sovereignty_tag, consent_ref)

---

## 2. Schema-Template Integration Strategy

### 2.1 Current Gap

**Problem**: The Backstage template scaffolds Java code but doesn't scaffold database schemas. Developers must manually create Flyway migrations.

**Impact**: 
- Inconsistent schema creation
- Missing compliance fields
- No enforcement of "soft FK" pattern
- Manual work increases cognitive load

### 2.2 Solution: Schema-Aware Template

#### 2.2.1 Template Enhancement: Schema Scaffolding

Add to `template.yaml`:
```yaml
- title: Database Schema Configuration
  properties:
    includeSchema:
      title: Generate Database Schema
      type: boolean
      default: true
    schemaName:
      title: Schema Name
      type: string
      description: PostgreSQL schema name (e.g., clinical, billing)
      pattern: '^[a-z][a-z0-9_]*$'
    includeComplianceFields:
      title: Include Compliance Fields (DPDP/HIPAA)
      type: boolean
      default: true
    fhirResourceType:
      title: FHIR Resource Type (if applicable)
      type: string
      enum: [Patient, Encounter, Observation, Condition, MedicationRequest, null]
      default: null
```

#### 2.2.2 Skeleton Structure for Schema

```
skeleton/src/main/resources/db/migration/
├── V001__create_{{ values.schemaName }}_schema.sql
└── {% if values.includeComplianceFields %}V002__add_compliance_fields.sql{% endif %}
```

**Template SQL File** (`V001__create_{{ values.schemaName }}_schema.sql`):
```sql
-- ============================================================================
-- {{ values.schemaName | upper }} SCHEMA
-- Generated by Backstage Golden Path Template
-- Module: {{ values.moduleName }}
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS {{ values.schemaName }};

-- ============================================================================
-- {{ values.entityName | title }} Table
-- {% if values.fhirResourceType %}FHIR Resource: {{ values.fhirResourceType }}{% endif %}
-- ============================================================================
CREATE TABLE {{ values.schemaName }}.{{ values.entityName | lower }}s (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL REFERENCES core.tenants(id),
    
    -- Business Fields (customize based on pattern)
    {% if values.servicePattern == 'modular-monolith-module' %}
    name VARCHAR(255) NOT NULL,
    description TEXT,
    {% endif %}
    
    -- Status
    is_active BOOLEAN NOT NULL DEFAULT true,
    
    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Row Level Security
ALTER TABLE {{ values.schemaName }}.{{ values.entityName | lower }}s ENABLE ROW LEVEL SECURITY;

CREATE POLICY tenant_isolation ON {{ values.schemaName }}.{{ values.entityName | lower }}s
    USING (tenant_id = current_setting('app.current_tenant', true)::UUID);

-- Indexes
CREATE INDEX idx_{{ values.entityName | lower }}s_tenant ON {{ values.schemaName }}.{{ values.entityName | lower }}s(tenant_id);
CREATE INDEX idx_{{ values.entityName | lower }}s_active ON {{ values.schemaName }}.{{ values.entityName | lower }}s(is_active) WHERE is_active = true;

{% if values.includeComplianceFields %}
-- ============================================================================
-- Compliance Fields (DPDP/HIPAA)
-- ============================================================================
ALTER TABLE {{ values.schemaName }}.{{ values.entityName | lower }}s
    ADD COLUMN encryption_key_id UUID,
    ADD COLUMN data_sovereignty_tag data_sovereignty_region NOT NULL DEFAULT 'INDIA_LOCAL',
    ADD COLUMN consent_ref UUID REFERENCES core.consent_logs(id);
{% endif %}
```

### 2.3 Schema Pattern Library

Create a library of common schema patterns that templates can reference:

```
backstage-golden-path-template/
├── schema-patterns/
│   ├── clinical-entity.sql.template      # Patient, Encounter patterns
│   ├── billing-entity.sql.template        # Invoice, Payment patterns
│   ├── inventory-entity.sql.template      # Item, Batch patterns
│   ├── audit-table.sql.template           # Audit log pattern
│   └── compliance-overlay.sql.template    # DPDP/HIPAA fields
```

**Usage in Template**:
```yaml
schemaPattern:
  title: Schema Pattern
  type: string
  enum:
    - clinical-entity
    - billing-entity
    - inventory-entity
    - custom
```

---

## 3. Module-Schema Mapping

### 3.1 Module to Schema Relationship

| Module | Schema | Key Tables | Template Pattern |
|--------|--------|------------|------------------|
| **Core** | `core` | tenants, users, roles, audit_logs | `core-kernel` |
| **Clinical** | `clinical` | patients, encounters, observations | `clinical-module` |
| **Billing** | `billing` | invoices, payments, claims | `billing-module` |
| **Inventory** | `inventory` | items, batches, stock_ledgers | `inventory-module` |
| **Scheduling** | `scheduling` | appointments, slots, queues | `scheduling-module` |
| **Laboratory** | `laboratory` | samples, quality_controls | `laboratory-module` |
| **Blood Bank** | `blood_bank` | donors, blood_units, transfusions | `blood-bank-module` |

### 3.2 Template Patterns for Each Module

#### Pattern: `clinical-module`
- Scaffolds: `modules/clinical/` structure
- Schema: `clinical` schema with FHIR-aligned tables
- Dependencies: `core` schema (tenants, users)
- Compliance: Full DPDP/HIPAA fields

#### Pattern: `billing-module`
- Scaffolds: `modules/billing/` structure
- Schema: `billing` schema with PM-JAY fields
- Dependencies: `core`, `clinical` (soft FKs)
- Compliance: Insurance claim fields, NHCX integration

#### Pattern: `inventory-module`
- Scaffolds: `modules/inventory/` structure
- Schema: `inventory` schema with FEFO support
- Dependencies: `core` (soft FKs to clinical for prescriptions)
- Compliance: Batch tracking, expiry management

---

## 4. Implementation Roadmap

### Phase 1: Foundation (Weeks 1-4)

#### 1.1 Monorepo Bootstrap Template
- [ ] Create `hims-platform-monorepo-template`
- [ ] Scaffold complete monorepo structure
- [ ] Include all three services (backend, worker, frontend)
- [ ] Add `docker-compose.yml` for local dev
- [ ] Test end-to-end scaffolding

**Deliverable**: Developers can scaffold entire monorepo in one click

#### 1.2 Schema Scaffolding Enhancement
- [ ] Add schema configuration to `template.yaml`
- [ ] Create schema template files in `skeleton/src/main/resources/db/migration/`
- [ ] Implement compliance field scaffolding
- [ ] Add FHIR resource mapping
- [ ] Test schema generation

**Deliverable**: Templates automatically generate Flyway migrations

#### 1.3 Module Template Enhancement
- [ ] Add `modular-monolith-module` pattern to existing template
- [ ] Update skeleton structure for Spring Modulith
- [ ] Add ArchUnit rules scaffolding
- [ ] Test module addition workflow

**Deliverable**: Developers can add new modules to monorepo

### Phase 2: Schema Gap Closure (Weeks 5-8)

#### 2.1 Critical Schema Gaps (P0)
Based on `Schema-Gap-Analysis.md`:

- [ ] **ABDM Care Context Linking**
  - Create `abdm_care_contexts` table
  - Add to template as `abdm-integration` pattern
  - Migration script: `V003__add_abdm_care_contexts.sql`

- [ ] **Pre-Authorization Workflow**
  - Create `billing.pre_authorizations` table
  - Add PM-JAY specific fields
  - Migration script: `V004__add_pre_authorizations.sql`

- [ ] **NHCX Integration Fields**
  - Enhance `billing.insurance_claims` table
  - Add NHCX bundle ID, CPD status, UTR fields
  - Migration script: `V005__enhance_insurance_claims.sql`

- [ ] **Discharge Summary with STG**
  - Create `clinical.discharge_summaries` table
  - Add STG adherence checklist
  - Migration script: `V006__add_discharge_summaries.sql`

- [ ] **Sample Collection Tracking**
  - Enhance `laboratory.samples` table
  - Add barcode, collection workflow fields
  - Migration script: `V007__enhance_laboratory_samples.sql`

**Deliverable**: All P0 schema gaps closed, production-ready

### Phase 3: Template Pattern Library (Weeks 9-12)

#### 3.1 Clinical Module Template
- [ ] Create `clinical-module` template pattern
- [ ] Scaffold FHIR-aligned entities (Patient, Encounter, Observation)
- [ ] Include compliance fields automatically
- [ ] Add ArchUnit rules for module boundaries
- [ ] Test with real clinical workflows

#### 3.2 Billing Module Template
- [ ] Create `billing-module` template pattern
- [ ] Scaffold PM-JAY specific fields
- [ ] Include pre-authorization workflow
- [ ] Add NHCX integration fields
- [ ] Test with insurance claim processing

#### 3.3 Inventory Module Template
- [ ] Create `inventory-module` template pattern
- [ ] Scaffold FEFO batch tracking
- [ ] Include expiry management
- [ ] Add soft FK patterns to clinical
- [ ] Test with pharmacy workflows

#### 3.4 Support Module Templates
- [ ] Laboratory module template
- [ ] Blood bank module template
- [ ] Scheduling module template
- [ ] Communication module template

**Deliverable**: Complete pattern library for all modules

### Phase 4: Agentic Framework Integration (Weeks 13-16)

#### 4.1 ArchGuard Agent Enhancement
- [ ] ArchGuard generates ADRs in `docs/adr/`
- [ ] ArchGuard validates schema against HLD/LLD
- [ ] ArchGuard checks module boundaries
- [ ] Integration with Backstage catalog

#### 4.2 CodeCraft Agent Enhancement
- [ ] CodeCraft respects module boundaries
- [ ] CodeCraft generates schema migrations
- [ ] CodeCraft validates soft FK patterns
- [ ] CodeCraft enforces compliance fields

#### 4.3 DocuScribe Agent Enhancement
- [ ] DocuScribe generates schema documentation
- [ ] DocuScribe creates ER diagrams from schema
- [ ] DocuScribe updates API docs from OpenAPI
- [ ] DocuScribe maintains runbooks

**Deliverable**: Full SDLC automation with schema awareness

### Phase 5: Testing & Validation (Weeks 17-20)

#### 5.1 Template Testing
- [ ] Test all template patterns end-to-end
- [ ] Validate schema generation
- [ ] Verify compliance field inclusion
- [ ] Test module boundary enforcement
- [ ] Performance testing

#### 5.2 Schema Validation
- [ ] Validate all schemas against FHIR R4
- [ ] Test RLS policies
- [ ] Verify soft FK patterns
- [ ] Compliance audit (DPDP/HIPAA)
- [ ] Performance benchmarking

#### 5.3 Integration Testing
- [ ] Test monorepo bootstrap
- [ ] Test module addition
- [ ] Test schema migrations
- [ ] Test agentic framework integration
- [ ] End-to-end workflow testing

**Deliverable**: Production-ready platform with full automation

---

## 5. Schema-Template Mapping Matrix

### 5.1 Template Patterns → Schema Tables

| Template Pattern | Schema | Generated Tables | Compliance Level |
|-----------------|--------|------------------|------------------|
| `core-kernel` | `core` | tenants, users, roles, audit_logs | Full (DPDP/HIPAA) |
| `clinical-module` | `clinical` | patients, encounters, observations | Full (DPDP/HIPAA) |
| `billing-module` | `billing` | invoices, payments, claims, pre_authorizations | Full (PM-JAY, NHCX) |
| `inventory-module` | `inventory` | items, batches, stock_ledgers | Medium (FEFO, expiry) |
| `scheduling-module` | `scheduling` | appointments, slots, queues, tokens | Low |
| `laboratory-module` | `laboratory` | samples, quality_controls, alerts | Medium (NABL) |
| `blood-bank-module` | `blood_bank` | donors, blood_units, cross_matches, transfusions | Medium |
| `abdm-integration` | `abdm` | abha_registrations, care_contexts, hiu_requests | Full (ABDM M1/M2/M3) |

### 5.2 Compliance Field Matrix

| Field | Core | Clinical | Billing | Inventory | Other |
|-------|------|---------|---------|-----------|-------|
| `tenant_id` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `encryption_key_id` | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| `data_sovereignty_tag` | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| `consent_ref` | ✅ | ✅ | ✅ | ❌ | ⚠️ |
| `created_at` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `updated_at` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `created_by` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `updated_by` | ✅ | ✅ | ✅ | ✅ | ✅ |

**Legend:**
- ✅ Always included
- ⚠️ Optional (configurable)
- ❌ Not applicable

---

## 6. Key Integration Points

### 6.1 Backstage Template → Schema

**Flow**:
1. Developer selects template pattern (e.g., `clinical-module`)
2. Template scaffolds Java code (`modules/clinical/`)
3. Template generates Flyway migration (`V001__create_clinical_schema.sql`)
4. Migration creates schema + tables with compliance fields
5. Template generates ArchUnit rules for module boundaries

**Automation**: Template automatically includes schema based on pattern

### 6.2 Schema → Agentic Framework

**Flow**:
1. CodeCraft agent reads schema files
2. Generates JPA entities matching schema
3. Validates soft FK patterns
4. Ensures compliance fields present
5. ArchGuard validates against HLD/LLD

**Automation**: Agents are schema-aware and enforce patterns

### 6.3 Agentic Framework → Backstage

**Flow**:
1. ArchGuard creates ADR for new module
2. DocuScribe generates schema documentation
3. CodeCraft scaffolds code + schema
4. QualityGuard validates compliance
5. Component registered in Backstage catalog

**Automation**: Full SDLC automation with Backstage integration

---

## 7. Success Metrics

### 7.1 Template Effectiveness
- **Time to First Module**: < 5 minutes (from template selection to running service)
- **Schema Compliance**: 100% of generated schemas include compliance fields
- **Module Boundary Violations**: 0 (enforced by ArchUnit)
- **Developer Satisfaction**: > 4.5/5 (survey)

### 7.2 Schema Quality
- **FHIR R4 Compliance**: 100% for clinical resources
- **ABDM Compliance**: 100% for M1/M2/M3 milestones
- **PM-JAY Compliance**: 100% for billing modules
- **RLS Coverage**: 100% for tenant-scoped tables

### 7.3 Automation Coverage
- **Schema Generation**: 100% automated
- **Compliance Fields**: 100% automated
- **Module Boundaries**: 100% enforced
- **Documentation**: 90% automated

---

## 8. Risk Mitigation

### 8.1 Schema Evolution
**Risk**: Schema changes break existing modules

**Mitigation**:
- Versioned migrations (Flyway)
- Backward-compatible changes only
- Schema versioning in templates
- Automated migration testing

### 8.2 Template Complexity
**Risk**: Templates become too complex to maintain

**Mitigation**:
- Pattern library approach (reusable components)
- Clear documentation
- Regular template reviews
- Community feedback loop

### 8.3 Compliance Gaps
**Risk**: Missing compliance fields in generated schemas

**Mitigation**:
- Mandatory compliance fields in templates
- Automated compliance checks
- Regular compliance audits
- Integration with compliance tools

---

## 9. Next Steps (Immediate Actions)

### Week 1-2: Planning & Setup
1. **Review this plan** with architecture team
2. **Prioritize phases** based on business needs
3. **Assign ownership** for each phase
4. **Create GitHub issues** for tracking
5. **Set up project boards** in Backstage

### Week 3-4: Phase 1 Start
1. **Begin monorepo bootstrap template** (highest priority)
2. **Start schema scaffolding enhancement**
3. **Set up testing infrastructure**
4. **Create initial documentation**

### Ongoing: Continuous Improvement
1. **Gather developer feedback** on templates
2. **Iterate on schema patterns** based on usage
3. **Enhance agentic framework** integration
4. **Update documentation** as patterns evolve

---

## 10. References

### Documents
- `REPOSITORY_STRUCTURE_REVIEW.md` - Monorepo structure analysis
- `TEMPLATE_ENHANCEMENT_ROADMAP.md` - Template enhancement details
- `HIMS Platform 1.0 - High Level Design (HLD).md` - Architecture overview
- `HIMS Platform 1.0 - Data Model (LLD).md` - Data modeling strategy
- `Schema-Gap-Analysis.md` - Schema completeness analysis
- `Backstage Golden Path Template Creation.docx` - Template principles

### Code Repositories
- `backstage-golden-path-template/` - Backstage templates
- `hms-local-dev-env/` - Local development environment
- `hms-platform-libraries/` - Shared libraries
- `agentic-coding-framework/` - SDLC automation

---

**Document Version**: 1.0  
**Last Updated**: 2025-01-21  
**Status**: Draft for Review  
**Next Review**: 2025-01-28

