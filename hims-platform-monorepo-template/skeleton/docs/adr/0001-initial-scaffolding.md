# ADR-0001: Initial Platform Scaffolding

## Status
Accepted

## Context
This platform was scaffolded using the HIMS Platform Monorepo template on {{ "now" | date }}.

## Decision
- **Architecture**: Modular Monolith (Spring Modulith)
- **Backend**: Spring Boot 3.2, Java 17
- **Analytics**: FastAPI (Python 3.11)
- **Frontend**: Next.js 14
- **Database**: PostgreSQL 15
- **Message Broker**: Kafka 7.5.0
- **Cache**: Redis 7

## Consequences
- **Positive**: 
  - Follows organization's Golden Path patterns
  - Modular structure allows future extraction to microservices
  - Single deployment unit simplifies operations
  
- **Negative**: 
  - None identified

## Notes
- Initial scaffolding; ADRs should be added as architecture evolves
- Module boundaries enforced by ArchUnit
- Cross-module communication via service provider pattern

