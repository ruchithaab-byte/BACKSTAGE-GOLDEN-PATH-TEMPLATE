# Phase 3: Module Creation Guide

## Pattern Established ✅

**Two complete examples created**:
1. ✅ **inventory** - Complete (7 files)
2. ✅ **laboratory** - Complete (7 files)

---

## File Structure Pattern

Each module needs **7 files** with conditional filenames:

### 1. Entity (`internal/domain/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/internal/domain/{% if values.include<Module>Module %}<Module>Entity.java{% endif %}
```

**Content Pattern**:
- Core Kernel fields (tenant_id, audit columns, compliance)
- Pattern-specific fields
- Soft FKs
- Lifecycle callbacks

### 2. Repository (`internal/repo/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/internal/repo/{% if values.include<Module>Module %}<Module>Repository.java{% endif %}
```

**Content Pattern**:
- Extends JpaRepository
- Tenant isolation queries
- Pattern-specific queries

### 3. Service Provider Interface (`api/spi/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/api/spi/{% if values.include<Module>Module %}<Module>ServiceProvider.java{% endif %}
```

**Content Pattern**:
- Public API interface
- Method signatures (no implementation)

### 4. Service (`internal/service/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/internal/service/{% if values.include<Module>Module %}<Module>Service.java{% endif %}
```

**Content Pattern**:
- Implements ServiceProvider
- Pattern-specific methods
- Core Kernel integration (@LogAudit, EventPublisher)

### 5. Controller (`internal/web/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/internal/web/{% if values.include<Module>Module %}<Module>Controller.java{% endif %}
```

**Content Pattern**:
- REST endpoints
- Pattern-specific routes
- Uses ServiceProvider (not internal service)

### 6. Event (`api/event/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/api/event/{% if values.include<Module>Module %}<Module>Event.java{% endif %}
```

**Content Pattern**:
- Domain event structure
- Event types documented

### 7. Listener (`internal/listener/`)
**Filename Pattern**:
```
skeleton/modules/{% if values.include<Module>Module %}<module>{% endif %}/internal/listener/{% if values.include<Module>Module %}<Module>EventListener.java{% endif %}
```

**Content Pattern**:
- Kafka listeners
- Pattern-specific topics

---

## Pattern-Specific Code by Module

### Blood Bank
- Donor management fields
- Blood unit tracking
- Cross-matching fields
- Transfusion records

### Scheduling
- Appointment fields
- Slot management
- Queue/token system

### Communication
- Notification fields
- Template management
- Campaign tracking

### Documents
- Document metadata
- Version control
- Access control

### P2 Modules (Generic)
- Basic CRUD fields
- Standard structure
- Can reuse generic template

---

## Remaining Modules to Create

### P1: Important (4 modules × 7 files = 28 files)
1. blood_bank
2. scheduling
3. communication
4. documents

### P2: Generic (4 modules × 7 files = 28 files)
1. imaging
2. warehouse
3. terminology
4. integration

**Total**: 56 files remaining

---

## Quick Reference

**Checkbox Name → Module Name Mapping**:
- `includeBloodBankModule` → `blood_bank`
- `includeSchedulingModule` → `scheduling`
- `includeCommunicationModule` → `communication`
- `includeDocumentsModule` → `documents`
- `includeImagingModule` → `imaging`
- `includeWarehouseModule` → `warehouse`
- `includeTerminologyModule` → `terminology`
- `includeIntegrationModule` → `integration`

**Filename Example** (blood_bank):
```
skeleton/modules/{% if values.includeBloodBankModule %}blood_bank{% endif %}/internal/domain/{% if values.includeBloodBankModule %}BloodUnit.java{% endif %}
```

---

**Status**: Pattern established, ready to scale to all modules

