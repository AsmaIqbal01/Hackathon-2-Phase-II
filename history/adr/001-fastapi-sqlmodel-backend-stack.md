# ADR-001: FastAPI with SQLModel for Backend API & Database

- **Status:** Accepted
- **Date:** 2026-01-24
- **Feature:** F01-S01-backend-api-database
- **Context:** Phase II requires a RESTful backend API with PostgreSQL persistence for the multi-user Todo application. Need to select a Python web framework and ORM that supports type safety, automatic validation, and OpenAPI documentation.

## Decision

Adopt **FastAPI with SQLModel** as the backend stack:

- **Framework**: FastAPI 0.109.0
- **ORM**: SQLModel 0.0.14 (combines SQLAlchemy + Pydantic)
- **Validation**: Pydantic v2 (bundled with FastAPI/SQLModel)
- **Server**: uvicorn 0.27.0 (ASGI)
- **Database Driver**: psycopg2-binary 2.9.9

## Consequences

### Positive

- **Type Safety**: SQLModel provides type hints for both database models and API schemas
- **Automatic OpenAPI**: FastAPI generates `/docs` endpoint with full API documentation (SC-007)
- **Unified Models**: SQLModel allows same class for database table and Pydantic validation
- **Modern Async Support**: FastAPI supports async/await for high concurrency
- **Dependency Injection**: Clean pattern for database sessions and user extraction (get_db, get_user_id)
- **Pydantic v2 Performance**: Faster validation than v1, native to FastAPI ecosystem

### Negative

- **SQLModel Maturity**: Newer than SQLAlchemy alone, smaller community
- **Learning Curve**: Team must learn FastAPI patterns if unfamiliar
- **Async Complexity**: psycopg2 is sync; would need asyncpg for full async (acceptable for MVP)

## Alternatives Considered

**Alternative A: Django REST Framework + Django ORM**
- Pros: Mature, large community, built-in admin
- Cons: Heavier, less type-safe, slower for API-only services
- Rejected: Overkill for API-only backend, less modern DX

**Alternative B: Flask + SQLAlchemy + Marshmallow**
- Pros: Lightweight, flexible, widely known
- Cons: No automatic OpenAPI, manual schema sync, more boilerplate
- Rejected: Too much manual wiring, no auto-docs

**Alternative C: Node.js + TypeORM + Express**
- Pros: JavaScript ecosystem, good TypeScript support
- Cons: Context switch from Python, different testing patterns
- Rejected: Constitution specifies Python FastAPI

## References

- Feature Spec: `specs/F01-S01-backend-api-database/spec.md`
- Implementation Plan: `specs/F01-S01-backend-api-database/plan.md`
- Related ADRs: ADR-003 (Neon PostgreSQL)
- Constitution: `.specify/memory/constitution.md` (Principle VI: Web-First Architecture)
