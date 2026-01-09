---
id: 001
title: Phase II Constitution Creation
stage: constitution
date: 2026-01-02
surface: agent
model: claude-sonnet-4-5
feature: none
branch: main
user: system
command: /sp.constitution
labels: ["constitution", "phase-ii", "initialization", "governance"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
tests:
  - Constitution template validation (all placeholders resolved)
  - Template consistency verification (plan, spec, tasks)
  - Sync Impact Report generation
---

## Prompt

/sp.constitution

Title: Evolution of Todo – Phase II Constitution Addendum (Web Application)

Context
You are continuing the "Evolution of Todo" project.
Phase I (In-Memory Interactive CLI) is complete and approved.

This Phase II constitution is an ADDENDUM, not a replacement.

You MUST reuse and respect all existing constitutions, agent systems, and reusable intelligence defined in the following repositories:

Primary Reusable Intelligence Sources
1. Frontend Agent System
   https://github.com/AsmaIqbal01/frontend_agent_system

2. Backend Agent System
   https://github.com/AsmaIqbal01/Backend_agent_system

3. Phase I Reference Implementation
   https://github.com/AsmaIqbal01/Hackathon2-phase1

All principles, patterns, and constraints defined in these repositories are considered authoritative unless explicitly overridden in this document.

---

## Purpose of Phase II

Transform the Phase I console-based todo application into a **full-stack, multi-user web application** with:

- Persistent storage
- Authentication
- RESTful API
- Responsive frontend UI

The application must remain **spec-driven and AI-generated only**.

---

## Phase II Core Constraints

1. **Spec-Driven Development Only**
   - No manual coding
   - All changes must originate from specifications
   - Specs remain the single source of truth

2. **Reuse Over Reinvention**
   - Reuse task CRUD logic from Phase I
   - Reuse validation, error handling, and business rules from Backend Agent System
   - Reuse UI/interaction patterns from Frontend Agent System

3. **Amendment-Based Development**
   - Modify existing behavior ONLY where required for:
     - Web architecture
     - Persistence
     - Authentication
   - Do NOT re-specify unchanged behavior

---

## Technology Stack (Phase II)

Frontend:
- Next.js 16+ (App Router)
- TypeScript
- Tailwind CSS
- Better Auth (JWT enabled)

Backend:
- Python FastAPI
- SQLModel ORM
- Neon Serverless PostgreSQL

Authentication:
- Better Auth (Frontend)
- JWT verification in FastAPI backend

---

## Architectural Rules

### Frontend
- Follow all rules from `frontend_agent_system`
- UI must be responsive and accessible
- API calls must be centralized via a client module
- JWT token must be attached to every backend request

### Backend
- Follow all rules from `Backend_agent_system`
- All routes must be under `/api`
- SQLModel is mandatory for persistence
- No global mutable state
- Task ownership MUST be enforced per user

---

## Authentication & Authorization

1. Better Auth issues JWT tokens on login
2. Frontend sends JWT in:
   Authorization: Bearer <token>
3. Backend:
   - Verifies JWT using shared secret
   - Extracts authenticated user ID
   - Ignores any user_id passed directly by client
4. All task queries MUST be scoped to authenticated user

---

## Data Ownership Rules

- Each task belongs to exactly one user
- Users can only:
  - Read their own tasks
  - Modify their own tasks
  - Delete their own tasks
- Cross-user access is forbidden and must return 403

---

## REST API Rules

- Endpoints remain logically equivalent to Phase I operations
- All endpoints require authentication
- Stateless backend (JWT-based)

---

## Database Rules

- PostgreSQL via Neon
- SQLModel used for all models
- Migrations handled explicitly (no implicit schema changes)
- No database logic in route handlers

---

## Testing & Validation

- Maintain Phase I test philosophy
- Add backend integration tests for:
  - Auth enforcement
  - User isolation
  - CRUD operations
- Frontend behavior tested via component logic (no E2E required)

---

## What This Constitution Does NOT Do

- It does NOT redefine task CRUD logic
- It does NOT redefine CLI behavior
- It does NOT override Phase I business rules
- It does NOT introduce chatbot functionality (Phase III)

---

## Success Criteria for Phase II

Phase II is complete when:

- All Phase I features work via web UI
- Data persists across sessions
- Multiple users can use the system independently
- Authentication is enforced everywhere
- No manual code exists
- Specs fully explain the system

## Response snapshot

Successfully created Phase II Constitution v1.0.0 with the following components:

**Core Principles (8)**:
1. Spec-Driven Development Only
2. Reuse Over Reinvention
3. Amendment-Based Development
4. Multi-User Data Ownership
5. Stateless Authentication
6. Web-First Architecture
7. Test-Driven Development
8. Observability & Error Handling

**Key Sections**:
- Technology Stack (Frontend: Next.js 16+/TypeScript/Tailwind/Better Auth; Backend: FastAPI/SQLModel/Neon PostgreSQL)
- Architectural Boundaries (clear frontend/backend separation)
- Authentication & Authorization (JWT-based with Better Auth)
- Data Ownership & Isolation (user-scoped queries, 403 for cross-user access)
- REST API Standards (resource-oriented, `/api` prefix, proper HTTP methods)
- Database & Persistence (SQLModel ORM, Alembic migrations, no global state)
- Testing Philosophy (TDD, contract/integration/unit tests, Phase I compatibility)
- Governance (amendment process, compliance verification, semantic versioning)

**Database Schema**:
- `users` table (id, email, created_at)
- `tasks` table (id, user_id, title, description, status, priority, tags, created_at, updated_at)
- Index on `tasks.user_id` for query performance

**Success Criteria**: 10 measurable checkpoints for Phase II completion

**Sync Impact Report**: Embedded as HTML comment with version change, modified principles, added sections, template compatibility verification, and dependent artifacts.

## Outcome

- ✅ Impact: Created comprehensive Phase II constitution (v1.0.0) with 8 core principles, technology stack, architectural boundaries, and governance rules. All placeholders resolved. Templates verified compatible.
- 🧪 Tests: Constitution template validation passed (no unresolved placeholders), template consistency verified (plan-template.md, spec-template.md, tasks-template.md all compatible)
- 📁 Files: Modified `.specify/memory/constitution.md` (530 lines, complete constitution with Sync Impact Report)
- 🔁 Next prompts: Ready for feature specification via `/sp.specify <feature-description>`, then planning via `/sp.plan`, then task generation via `/sp.tasks`
- 🧠 Reflection: Constitution successfully balances reuse from authoritative repositories (Phase I, Frontend/Backend Agent Systems) with Phase II-specific amendments for web architecture, persistence, and multi-user authentication. Clear violation detection criteria enable enforcement.

## Evaluation notes (flywheel)

- Failure modes observed: None - constitution creation completed successfully with all requirements met
- Graders run and results (PASS/FAIL): PASS - All placeholders resolved, PASS - Template consistency verified, PASS - Sync Impact Report generated, PASS - Version semantics correct (1.0.0 for initial constitution)
- Prompt variant (if applicable): Standard `/sp.constitution` workflow with comprehensive Phase II context
- Next experiment (smallest change to try): Validate constitution gates during first `/sp.plan` execution to ensure Constitution Check section integrates correctly with new principles
