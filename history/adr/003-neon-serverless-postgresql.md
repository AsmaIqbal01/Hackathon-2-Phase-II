# ADR-003: Neon Serverless PostgreSQL for Persistent Storage

- **Status:** Accepted
- **Date:** 2026-01-24
- **Feature:** F01-S01-backend-api-database
- **Context:** Phase II transforms in-memory storage to persistent database. Need a managed PostgreSQL service compatible with SQLModel ORM, suitable for hackathon demo, and deployable without infrastructure management.

## Decision

Adopt **Neon Serverless PostgreSQL** as the database platform:

- **Service**: Neon (neon.tech)
- **Database**: PostgreSQL (latest stable)
- **Connection**: Standard PostgreSQL connection string via `DATABASE_URL`
- **Driver**: psycopg2-binary for Python connectivity
- **Pooling**: Neon's built-in connection pooling for serverless workloads

## Consequences

### Positive

- **Zero Infrastructure Management**: Fully managed, no server provisioning
- **Serverless Scaling**: Auto-scales compute, pay-per-use model
- **PostgreSQL Compatibility**: Full PostgreSQL feature set (ARRAY types for tags, UUID generation)
- **Free Tier**: Generous free tier suitable for hackathon demo
- **Branching**: Database branching for development/testing (optional)
- **Fast Cold Starts**: Optimized for serverless workloads with quick connection establishment
- **Standard Protocol**: Works with any PostgreSQL client/ORM (SQLModel, psycopg2)

### Negative

- **Vendor Lock-in**: Neon-specific features (branching) not portable
- **Cold Start Latency**: First request after idle may have slight delay
- **Geographic Limitations**: Limited regions compared to major cloud providers
- **New Service**: Less battle-tested than AWS RDS or Cloud SQL

## Alternatives Considered

**Alternative A: Self-Hosted PostgreSQL (Docker)**
- Pros: Full control, no vendor lock-in, free
- Cons: Requires infrastructure management, not suitable for deployed demo
- Rejected: Adds operational complexity, not demonstrable in hackathon

**Alternative B: Supabase PostgreSQL**
- Pros: Managed PostgreSQL, includes auth features, good free tier
- Cons: Auth features overlap with Better Auth (Spec 2), adds complexity
- Rejected: Auth bundling conflicts with spec separation; Neon is more focused

**Alternative C: AWS RDS PostgreSQL**
- Pros: Enterprise-grade, proven reliability, AWS ecosystem
- Cons: More complex setup, higher cost, requires AWS account configuration
- Rejected: Overkill for hackathon, slower to provision

**Alternative D: SQLite (File-Based)**
- Pros: Zero setup, embedded, no network latency
- Cons: Not suitable for multi-user concurrent access, no ARRAY type support
- Rejected: Doesn't support PostgreSQL features (ARRAY for tags), not scalable

## Configuration

```env
# .env
DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
```

## References

- Feature Spec: `specs/F01-S01-backend-api-database/spec.md` (Dependencies section)
- Implementation Plan: `specs/F01-S01-backend-api-database/plan.md` (Technical Context)
- Related ADRs: ADR-001 (FastAPI + SQLModel)
- Constitution: `.specify/memory/constitution.md` (Technology Stack: Neon Serverless PostgreSQL)
