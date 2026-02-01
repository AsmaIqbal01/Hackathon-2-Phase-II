# ADR-002: Temporary user_id Parameter Until JWT Authentication

- **Status:** Accepted
- **Date:** 2026-01-24
- **Feature:** F01-S01-backend-api-database
- **Context:** Phase II requires multi-user data isolation (Principle IV) but JWT authentication is scoped to Spec 2. Need a mechanism to develop and test user-scoped functionality before authentication is implemented.

## Decision

Implement a **temporary user_id parameter** for all API endpoints:

- **Mechanism**: Accept `user_id` as query parameter (e.g., `?user_id=alice`) or header (`X-User-ID`)
- **Scope**: All `/api/tasks` endpoints require user_id
- **Validation**: Non-empty string required, returns 400 if missing
- **Enforcement**: All database queries filtered by provided user_id
- **Lifecycle**: TEMPORARY - will be replaced by JWT extraction in Spec 2

**Security Warning**: This is NOT production-safe. The `user_id` parameter can be spoofed by any client.

## Consequences

### Positive

- **Enables Multi-User Development**: Can build and test user isolation without auth complexity
- **Architecture Readiness**: Service layer designed with `current_user_id` parameter, ready for JWT
- **Independent Testing**: Can verify FR-030, FR-031, FR-032 (user isolation) before auth exists
- **Spec Separation**: Backend API spec stays focused; auth complexity isolated to Spec 2
- **Zero Refactoring Path**: JWT middleware will replace `get_user_id` dependency without changing service/endpoint code

### Negative

- **Security Risk**: Backend is vulnerable if deployed without Spec 2 authentication
- **Not Production-Ready**: Clear documentation required to prevent premature deployment
- **Technical Debt**: Temporary code that must be removed in Spec 2

## Alternatives Considered

**Alternative A: Implement JWT Immediately**
- Pros: Secure from start, no temporary code
- Cons: Mixes concerns between specs, delays backend API delivery, increases complexity
- Rejected: Violates spec separation; authentication is explicitly Spec 2 scope

**Alternative B: Skip Multi-User Until Auth**
- Pros: No temporary mechanism needed
- Cons: Cannot test user isolation, would require refactoring service layer later
- Rejected: User isolation is P1 requirement (US5), must be built into architecture from start

**Alternative C: Use Fixed Test Users**
- Pros: Simpler than parameter, predefined user set
- Cons: Less flexible for testing, still not secure
- Rejected: Parameter approach more flexible and mirrors future JWT extraction pattern

## Remediation Plan (Spec 2)

1. Add JWT verification middleware to `src/main.py`
2. Update `get_user_id` dependency in `src/api/deps.py` to extract from JWT token
3. Remove query parameter/header acceptance
4. Add 401 Unauthorized for missing/invalid tokens
5. Zero changes to task endpoints or service layer (architecture designed for this)

## References

- Feature Spec: `specs/F01-S01-backend-api-database/spec.md` (Assumptions section)
- Implementation Plan: `specs/F01-S01-backend-api-database/plan.md` (Constitution Check, Deviation 1)
- Related ADRs: None (Spec 2 will create auth ADR)
- Constitution: `.specify/memory/constitution.md` (Principle IV: Multi-User Data Ownership, Principle V: Stateless Authentication)
