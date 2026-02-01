---
id: 002
title: Auth Security Implementation Plan
stage: plan
date: 2026-01-25
surface: agent
model: claude-opus-4-5-20251101
feature: F01-S02-auth-security
branch: F01-S02-auth-security
user: AsmaIqbal01
command: /sp.plan
labels: ["planning", "authentication", "jwt", "architecture", "security"]
links:
  spec: specs/F01-S02-auth-security/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/F01-S02-auth-security/plan.md (created)
  - specs/F01-S02-auth-security/research.md (created)
  - specs/F01-S02-auth-security/data-model.md (created)
  - specs/F01-S02-auth-security/contracts/auth-api.yaml (created)
  - specs/F01-S02-auth-security/quickstart.md (created)
tests:
  - Constitution Check: 10/10 principles PASS
  - Post-Design Gate: ALL PASS
---

## Prompt

/sp.plan

Execute the implementation planning workflow for F01-S02-auth-security using the plan template to generate design artifacts.

## Response snapshot

**Implementation Plan Created: F01-S02 Authentication & Security Integration**

### Phase 0: Research (Complete)

Created `research.md` with decisions for:
1. **JWT Library**: PyJWT (lightweight, sufficient for HS256)
2. **Password Hashing**: passlib[bcrypt] with cost factor 12
3. **Refresh Token Strategy**: Database-stored opaque tokens with hash storage
4. **Rate Limiting**: In-memory dictionary (5 attempts/email/15 min)
5. **F01-S01 Integration**: Minimal dependency replacement strategy

### Phase 1: Design & Contracts (Complete)

**data-model.md**:
- User entity (id, email, password_hash, timestamps)
- RefreshToken entity (id, user_id, token_hash, expires_at, revoked_at)
- SQLModel definitions and migration scripts
- Query patterns for auth operations

**contracts/auth-api.yaml** (OpenAPI 3.1):
- POST /api/auth/register (201/400/409)
- POST /api/auth/login (200/401/429)
- POST /api/auth/logout (204/401)
- POST /api/auth/refresh (200/401)
- GET /api/auth/me (200/401)
- Full request/response schemas with examples

**quickstart.md**:
- 6 integration scenarios with curl examples
- Frontend TypeScript API client example
- Testing checklist with expected responses

### Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| JWT Library | PyJWT | Lightweight, sufficient for HS256 |
| Password Hashing | passlib[bcrypt] cost 12 | Industry standard, OWASP recommended |
| Refresh Tokens | DB-stored opaque | Enables revocation and rotation |
| Rate Limiting | In-memory dict | MVP-appropriate, upgradeable to Redis |
| F01-S01 Integration | Dependency replacement | Preserves TaskService unchanged |

### Constitution Compliance

Pre-Phase 0 Gate: ALL PASS (10/10 principles)
Post-Phase 1 Gate: ALL PASS (10/10 principles)

### Source Code Structure

```
backend/src/
├── models/user.py          # NEW: User + RefreshToken models
├── schemas/auth_schemas.py # NEW: Auth request/response schemas
├── api/
│   ├── deps.py             # UPDATE: Replace get_user_id with get_current_user
│   └── routes/auth.py      # NEW: Auth endpoints
├── services/auth_service.py # NEW: Auth business logic
└── utils/security.py       # NEW: JWT + password utilities
```

### Integration with F01-S01

**Changes Required**:
1. config.py: Add JWT settings
2. deps.py: Replace get_user_id with JWT verification
3. routes/tasks.py: Update dependency injection
4. main.py: Add auth router

**Preserved** (No Changes):
- task_service.py, models/task.py, schemas/task_schemas.py, database.py

## Outcome

- Impact: Complete implementation plan with research, data model, API contracts, and integration guide
- Tests: Constitution gates PASS (pre and post design)
- Files: 5 created (plan.md, research.md, data-model.md, auth-api.yaml, quickstart.md)
- Next prompts: /sp.tasks to generate implementation task breakdown
- Reflection: Comprehensive planning with clear F01-S01 integration path

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Constitution Check PASS (20/20 total checks)
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): Validate task generation produces ordered implementation steps
