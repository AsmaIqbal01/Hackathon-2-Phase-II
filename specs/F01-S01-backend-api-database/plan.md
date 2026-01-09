# Implementation Plan: Backend API & Database

**Branch**: `F01-S01-backend-api-database` | **Date**: 2026-01-09 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/F01-S01-backend-api-database/spec.md`

## Summary

Build a RESTful backend API using FastAPI with SQLModel ORM and Neon Serverless PostgreSQL to provide full CRUD operations for a multi-user todo task management system. The backend will enforce user-scoped data access (multi-user isolation) at the database layer while using a temporary `user_id` parameter until JWT authentication is implemented in Spec 2. This establishes the foundational data layer and API contract for the full-stack todo application.

**Primary Technical Approach**: FastAPI application with:
- SQLModel for type-safe ORM and Pydantic validation
- Neon Serverless PostgreSQL for persistent storage
- RESTful endpoints under `/api/tasks` prefix
- User-scoped queries filtering all operations by `user_id`
- Database indexes on `user_id` and `status` for query performance
- Structured JSON error responses with appropriate HTTP status codes

## Technical Context

**Language/Version**: Python 3.12+
**Primary Dependencies**: FastAPI, SQLModel, Pydantic (v2), uvicorn, psycopg2-binary, python-dotenv
**Storage**: Neon Serverless PostgreSQL (external managed service)
**Testing**: pytest, httpx (for FastAPI TestClient), pytest-asyncio
**Target Platform**: Linux server (Railway/Render deployment) with Python runtime
**Project Type**: Web backend (RESTful API)
**Performance Goals**: <200ms p95 latency for CRUD operations, support 100 concurrent users
**Constraints**: Stateless design (no server-side sessions), user-scoped queries only, no authentication logic in this spec
**Scale/Scope**: Single backend service, 5 API endpoints, 1 database table (tasks), support for unlimited users

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### ✅ Principle I: Spec-Driven Development Only
- **Status**: PASS
- **Verification**: This plan derived from approved specification at `specs/F01-S01-backend-api-database/spec.md`. All requirements traceable to spec functional requirements FR-001 through FR-033.

### ✅ Principle II: Reuse Over Reinvention
- **Status**: PASS
- **Verification**:
  - Reusing Phase I validation rules (status, priority, tags) without redefinition
  - Reusing Backend Agent System patterns for FastAPI routing and service layer architecture
  - No duplication of existing agents (will use `fastapi-backend-agent` and `database-optimizer`)

### ✅ Principle III: Amendment-Based Development
- **Status**: PASS
- **Verification**:
  - Adding persistence (in-memory → PostgreSQL) - REQUIRES AMENDMENT ✓
  - Adding web API (CLI → REST) - REQUIRES AMENDMENT ✓
  - NOT redefining task validation rules (inherited from Phase I) ✓
  - NOT redefining status transitions (inherited from Phase I) ✓

### ✅ Principle IV: Multi-User Data Ownership
- **Status**: PASS
- **Verification**:
  - Task model includes `user_id` field (required, indexed)
  - All queries filtered by `user_id` at database level (WHERE clause)
  - Cross-user access returns 403 Forbidden (per FR-031)
  - Backend enforces authorization logic (per spec, even with temporary auth)

### ✅ Principle V: Stateless Authentication
- **Status**: PASS (with noted exception)
- **Verification**:
  - Backend designed as stateless (no session storage)
  - Temporary `user_id` parameter used until JWT in Spec 2 (documented in spec assumptions)
  - Architecture ready to accept JWT middleware without refactoring
  - **Exception**: JWT not implemented in this spec (deferred to Spec 2 per constitution and spec out-of-scope)

### ✅ Principle VI: Web-First Architecture
- **Status**: PASS
- **Verification**:
  - Backend structured as RESTful API under `/api` prefix
  - FastAPI framework per constitution's technology stack
  - SQLModel ORM per constitution's backend requirements
  - Neon PostgreSQL per constitution's database choice
  - Stateless request handling (FastAPI dependency injection for DB sessions)

### ✅ Principle VII: Test-Driven Development
- **Status**: PASS (tests not requested yet, but architecture ready)
- **Verification**:
  - Success criteria SC-001 through SC-010 define testable outcomes
  - Architecture supports contract tests (API schemas), integration tests (database persistence), and unit tests (business logic)
  - When tests are requested, TDD workflow will be followed

### ✅ Principle VIII: Observability & Error Handling
- **Status**: PASS
- **Verification**:
  - Error taxonomy defined in spec (400, 401, 403, 404, 422, 500)
  - Structured JSON error responses (per FR-025: `{"error": {"code": 400, "message": "..."}}`)
  - Server errors logged with stack traces but not exposed to clients (per FR-026)
  - All API endpoints will include error handling

### ✅ Principle IX: Agentic Execution Only
- **Status**: PASS
- **Verification**:
  - Implementation will use `fastapi-backend-agent` for backend API code generation
  - Implementation will use `database-optimizer` for schema and migration creation
  - No manual code edits permitted
  - PHRs will be created for all implementation sessions

### ✅ Principle X: Reviewability as First-Class
- **Status**: PASS
- **Verification**:
  - This plan is being tracked in `specs/F01-S01-backend-api-database/plan.md`
  - PHR will be created documenting this planning session
  - Future implementation tasks will have corresponding PHRs
  - ADR candidates identified (see below)

### 📋 ADR Candidates (Significant Architectural Decisions)

Per constitution, the following decisions meet the three-part test (Impact + Alternatives + Scope) and should be documented via `/sp.adr`:

1. **"FastAPI with SQLModel for Backend API & Database"**
   - **Impact**: Long-term framework choice affecting all backend development
   - **Alternatives**: Django REST Framework, Flask + SQLAlchemy, Node.js + TypeORM
   - **Scope**: Cross-cutting decision affecting API design, ORM patterns, testing, deployment

2. **"Temporary user_id Parameter Until JWT Authentication"**
   - **Impact**: Security architecture decision affecting all API endpoints
   - **Alternatives**: Implement JWT immediately, use session-based auth, skip multi-user isolation
   - **Scope**: Cross-cutting decision affecting API contract, security model, and Spec 2 integration

3. **"Neon Serverless PostgreSQL for Persistent Storage"**
   - **Impact**: Database choice affecting data persistence, scalability, deployment
   - **Alternatives**: Self-hosted PostgreSQL, SQLite, other managed PostgreSQL (Supabase, AWS RDS)
   - **Scope**: Cross-cutting decision affecting deployment, cost, operational complexity

**Recommendation**: Document all three decisions after completing this planning phase.

### ⚠️ Constitution Deviations (Justified)

**Deviation 1**: Spec 2 (Authentication) not implemented yet
- **Principle**: V. Stateless Authentication requires JWT verification
- **Justification**: Explicit spec requirement to defer authentication to Spec 2. Temporary `user_id` parameter documented in spec assumptions. Architecture designed to accept JWT middleware without refactoring.
- **Remediation Plan**: Spec 2 will implement JWT verification middleware that extracts `user_id` from token and replaces temporary parameter.

**No other deviations detected.**

## Project Structure

### Documentation (this feature)

```text
specs/F01-S01-backend-api-database/
├── plan.md              # This file (/sp.plan command output)
├── spec.md              # Feature specification (already complete)
├── checklists/
│   └── requirements.md  # Quality checklist (already complete)
├── research.md          # Phase 0 output (to be created)
├── data-model.md        # Phase 1 output (to be created)
├── quickstart.md        # Phase 1 output (to be created)
├── contracts/           # Phase 1 output (to be created)
│   └── api-openapi.yaml # OpenAPI 3.1 schema for REST API
└── tasks.md             # Phase 2 output (/sp.tasks command - NOT created by /sp.plan)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── main.py                      # FastAPI app entry point, CORS, startup/shutdown
│   ├── config.py                    # Environment variable loading (DATABASE_URL, etc.)
│   ├── database.py                  # SQLModel engine, session factory, get_db dependency
│   ├── models/
│   │   ├── __init__.py
│   │   └── task.py                  # Task SQLModel (table=True)
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── task_schemas.py          # TaskCreate, TaskUpdate, TaskResponse Pydantic models
│   │   └── error_schemas.py         # ErrorResponse Pydantic model
│   ├── api/
│   │   ├── __init__.py
│   │   ├── deps.py                  # Common dependencies (get_user_id from query/header)
│   │   └── routes/
│   │       ├── __init__.py
│   │       └── tasks.py             # Task CRUD endpoints (/api/tasks)
│   ├── services/
│   │   ├── __init__.py
│   │   └── task_service.py          # Business logic for task operations
│   └── utils/
│       ├── __init__.py
│       └── errors.py                # Custom exception classes
├── tests/
│   ├── conftest.py                  # Pytest fixtures (test DB, test client)
│   ├── integration/
│   │   ├── __init__.py
│   │   └── test_tasks_api.py        # Integration tests for /api/tasks endpoints
│   └── unit/
│       ├── __init__.py
│       └── test_task_service.py     # Unit tests for task service logic
├── alembic/                         # Database migrations (optional for this spec)
│   ├── versions/
│   └── env.py
├── config/
│   └── .env.example                 # Example environment variables
├── requirements.txt                 # Python dependencies
├── .env                             # Environment variables (gitignored)
└── README.md                        # Backend documentation (already exists)
```

**Structure Decision**: Web application structure with backend-only focus. Frontend is out of scope for this spec. Backend follows layered architecture:
- **API Layer** (`api/routes/`): FastAPI routers, request validation, response formatting
- **Service Layer** (`services/`): Business logic, user-scoped queries, error handling
- **Model Layer** (`models/`): SQLModel table definitions
- **Database Layer** (`database.py`): Connection management, session handling

This structure enables clear separation of concerns and prepares for future JWT middleware integration (middleware will be added to `main.py` and `api/deps.py` in Spec 2).

## Complexity Tracking

> **No violations detected. This section intentionally left empty.**

All constitutional requirements are met. The temporary `user_id` parameter is explicitly justified as a spec-defined deviation with clear remediation path in Spec 2.

---

## Phase 0: Research & Technology Decisions

### Research Questions

Based on Technical Context and spec requirements, the following areas require research:

1. **FastAPI Best Practices for RESTful CRUD APIs**
   - Question: What are FastAPI conventions for CRUD endpoint structure, error handling, and dependency injection?
   - Why: Ensure API follows FastAPI idioms and best practices for maintainability

2. **SQLModel Schema Definition and Relationships**
   - Question: How to define SQLModel table models with UUID primary keys, timestamps, and array fields (tags)?
   - Why: Task model requires UUID generation, datetime handling, and PostgreSQL array column

3. **Neon PostgreSQL Connection Patterns**
   - Question: What connection string format and pooling strategies work best with Neon Serverless PostgreSQL?
   - Why: Need reliable connection handling for serverless database

4. **User-Scoped Query Patterns**
   - Question: What are best practices for filtering all queries by user_id at the ORM level?
   - Why: Critical security requirement (FR-030, FR-031, FR-032)

5. **Pydantic V2 Validation and Error Messages**
   - Question: How to customize Pydantic v2 validation errors for clear client-facing messages?
   - Why: Spec requires clear error messages for validation failures (FR-023, FR-024)

6. **FastAPI Exception Handling**
   - Question: What patterns exist for global exception handlers and structured error responses?
   - Why: Need consistent error format per FR-025

7. **Database Indexing Strategy**
   - Question: How to create indexes in SQLModel/Alembic for user_id and status columns?
   - Why: Performance requirement (FR-033)

8. **Partial Update Handling (PATCH semantics)**
   - Question: How to implement PATCH endpoints that update only provided fields in FastAPI/Pydantic?
   - Why: FR-017 requires partial updates without overwriting unspecified fields

### Research Output

All research findings will be documented in `specs/F01-S01-backend-api-database/research.md` with:
- Decision made
- Rationale
- Alternatives considered
- Code examples where applicable

---

## Phase 1: Design & Contracts

### Data Model Design

**Output File**: `specs/F01-S01-backend-api-database/data-model.md`

#### Entity: Task

Derived from spec entity definition and functional requirements FR-005 through FR-010:

**Fields**:
- `id` (UUID, primary key, auto-generated via `uuid4()`)
- `user_id` (String/VARCHAR, required, indexed, foreign key concept to future users table)
- `title` (String/VARCHAR(255), required, not null)
- `description` (String/TEXT, optional, nullable, max 5000 chars)
- `status` (Enum: "todo" | "in-progress" | "completed", required, default "todo")
- `priority` (Enum: "low" | "medium" | "high", required, default "medium")
- `tags` (Array[String], optional, PostgreSQL TEXT[] type)
- `created_at` (DateTime, auto-generated, UTC timezone, not null)
- `updated_at` (DateTime, auto-updated on modification, UTC timezone, not null)

**Validation Rules** (inherited from Phase I where applicable):
- `title`: Required, non-empty string, max 255 characters
- `description`: Optional, max 5000 characters
- `status`: Must be one of: "todo", "in-progress", "completed"
- `priority`: Must be one of: "low", "medium", "high"
- `tags`: Optional array, each tag is a string

**Indexes**:
- Primary key index on `id` (automatic)
- Index on `user_id` for user-scoped queries (per FR-033)
- Index on `status` for filtering queries (per FR-033)

**Relationships**:
- Logical relationship to User entity (not implemented in this spec, deferred to Spec 2)
- `user_id` will become foreign key to `users.id` in Spec 2

**State Transitions** (inherited from Phase I):
- Any status can transition to any other status (no constraints in this spec)
- Transitions tracked via `updated_at` timestamp

### API Contracts

**Output File**: `specs/F01-S01-backend-api-database/contracts/api-openapi.yaml`

OpenAPI 3.1 specification defining:

#### Endpoints

1. **POST /api/tasks** - Create Task
   - Request Body: `TaskCreate` schema (title, description?, status?, priority?, tags?)
   - Query Param: `user_id` (required, string)
   - Response 201: `TaskResponse` schema (full task object)
   - Response 400: `ErrorResponse` (validation errors)

2. **GET /api/tasks** - List Tasks
   - Query Params: `user_id` (required), `status` (optional), `priority` (optional), `tags` (optional, comma-separated), `sort` (optional: "created_at" | "priority")
   - Response 200: Array of `TaskResponse`
   - Response 400: `ErrorResponse` (missing user_id)

3. **GET /api/tasks/{id}** - Get Task by ID
   - Path Param: `id` (UUID)
   - Query Param: `user_id` (required)
   - Response 200: `TaskResponse`
   - Response 400: `ErrorResponse` (invalid UUID)
   - Response 403: `ErrorResponse` (task not owned by user)
   - Response 404: `ErrorResponse` (task not found)

4. **PATCH /api/tasks/{id}** - Update Task
   - Path Param: `id` (UUID)
   - Query Param: `user_id` (required)
   - Request Body: `TaskUpdate` schema (all fields optional)
   - Response 200: `TaskResponse` (updated task)
   - Response 400: `ErrorResponse` (validation errors)
   - Response 403: `ErrorResponse` (task not owned by user)
   - Response 404: `ErrorResponse` (task not found)

5. **DELETE /api/tasks/{id}** - Delete Task
   - Path Param: `id` (UUID)
   - Query Param: `user_id` (required)
   - Response 204: No Content
   - Response 400: `ErrorResponse` (invalid UUID)
   - Response 403: `ErrorResponse` (task not owned by user)
   - Response 404: `ErrorResponse` (task not found)

#### Schemas

**TaskCreate** (Request):
```json
{
  "title": "string (required, max 255)",
  "description": "string (optional, max 5000)",
  "status": "enum (optional, default 'todo')",
  "priority": "enum (optional, default 'medium')",
  "tags": "array of strings (optional)"
}
```

**TaskUpdate** (Request):
```json
{
  "title": "string (optional, max 255)",
  "description": "string (optional, max 5000)",
  "status": "enum (optional)",
  "priority": "enum (optional)",
  "tags": "array of strings (optional)"
}
```

**TaskResponse** (Response):
```json
{
  "id": "uuid",
  "user_id": "string",
  "title": "string",
  "description": "string | null",
  "status": "enum",
  "priority": "enum",
  "tags": "array of strings",
  "created_at": "datetime (ISO 8601)",
  "updated_at": "datetime (ISO 8601)"
}
```

**ErrorResponse** (Response):
```json
{
  "error": {
    "code": "integer (400, 403, 404, 422, 500)",
    "message": "string (user-friendly description)"
  }
}
```

### Quickstart Guide

**Output File**: `specs/F01-S01-backend-api-database/quickstart.md`

Step-by-step guide for:
1. Setting up Python virtual environment
2. Installing dependencies from `requirements.txt`
3. Configuring `.env` file with `DATABASE_URL`
4. Creating database tables (SQLModel.metadata.create_all or Alembic)
5. Running development server (`uvicorn src.main:app --reload`)
6. Testing endpoints with curl/httpx examples
7. Verifying multi-user isolation with sample data

### Agent Context Update

After Phase 1 design completes, run:
```bash
cd "E:\Hackathon 2\Phase-II"
powershell.exe -ExecutionPolicy Bypass -File .specify/scripts/powershell/update-agent-context.ps1 -AgentType claude
```

This will update `.claude/agents/` context files with:
- FastAPI as backend framework
- SQLModel as ORM
- Neon PostgreSQL as database
- RESTful API patterns for task management

---

## Phase 2: Task Breakdown (Handled by /sp.tasks)

Phase 2 (task generation) is **NOT** performed by this `/sp.plan` command. After this plan is approved, run:

```bash
/sp.tasks
```

This will generate `specs/F01-S01-backend-api-database/tasks.md` with atomic, testable tasks derived from this plan.

Expected task categories:
1. **Environment Setup**: Dependencies, .env configuration, database connection
2. **Database Layer**: Task model, migrations, indexes
3. **Service Layer**: Task service with user-scoped queries
4. **API Layer**: FastAPI routers, endpoints, error handlers
5. **Validation**: Pydantic schemas, custom validators
6. **Testing**: Integration tests for each endpoint, multi-user isolation tests
7. **Documentation**: Auto-generated OpenAPI docs, README updates

---

## Post-Planning Actions

After this plan is approved:

1. **Review Constitution Check**: Verify all gates passed (all ✅ above)
2. **Create ADRs** (recommended): Document the 3 significant architectural decisions
3. **Run /sp.tasks**: Generate atomic task breakdown
4. **Begin Implementation**: Use `fastapi-backend-agent` and `database-optimizer` agents

---

## Architectural Notes

### Separation of Concerns

This backend is designed as a standalone API service:
- **No frontend code**: Frontend will be in separate spec
- **No authentication logic**: JWT verification deferred to Spec 2
- **No user management**: User CRUD deferred to Spec 2

### Integration Points (Future Specs)

**Spec 2 (Authentication & Authorization)**:
- Add JWT verification middleware to `src/main.py`
- Replace `get_user_id` dependency in `src/api/deps.py` to extract from JWT instead of query param
- Add User model and user CRUD endpoints
- Zero changes required to task endpoints or service layer (architecture designed for this)

**Spec 3 (Frontend)**:
- Frontend will call these API endpoints with JWT in `Authorization: Bearer <token>` header
- Backend returns JSON responses (no HTML rendering)

### Database Schema Evolution

Current schema (this spec):
```sql
CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR NOT NULL,  -- String, not foreign key yet
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL DEFAULT 'todo',
    priority VARCHAR(50) NOT NULL DEFAULT 'medium',
    tags TEXT[],
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
```

Future schema changes (Spec 2):
- Add `users` table with `id UUID PRIMARY KEY`
- Convert `tasks.user_id` from VARCHAR to UUID
- Add foreign key constraint: `REFERENCES users(id) ON DELETE CASCADE`

### Error Handling Strategy

**400 Bad Request**: Invalid input
- Missing required fields
- Invalid enum values
- String length violations
- Invalid UUID format

**403 Forbidden**: Authorization failure
- User attempting to access another user's task
- Returned even if task doesn't exist (prevents information disclosure per FR-031)

**404 Not Found**: Resource doesn't exist
- Task ID not found for the authenticated user
- Only returned after verifying user owns the resource

**422 Unprocessable Entity**: Business logic violation
- Reserved for future use (e.g., invalid status transitions)

**500 Internal Server Error**: Unexpected errors
- Database connection failures
- Unhandled exceptions
- Logged with full stack trace, generic message to client (per FR-026)

### Performance Considerations

**Database Indexes** (FR-033):
- `user_id` index: Optimizes user-scoped queries (most common operation)
- `status` index: Optimizes filtering by status (common filter)

**Query Optimization**:
- All queries filtered at database level (WHERE clause), not in Python
- Avoid N+1 queries (single query per operation, no loops)
- Use connection pooling via SQLModel/SQLAlchemy engine

**Scalability**:
- Stateless design enables horizontal scaling
- No server-side caching (can be added in future spec if needed)
- Database is the only stateful component (managed by Neon)

---

## Risks & Mitigations

### Risk 1: Temporary `user_id` Parameter Security

**Risk**: Temporary `user_id` parameter is insecure and could be exploited if this backend is deployed without Spec 2 authentication.

**Likelihood**: High if deployed prematurely
**Impact**: Critical (data breach, cross-user access)

**Mitigation**:
- Document clearly in README and API docs that this is NOT production-ready
- Add warning in `/docs` endpoint (FastAPI auto-generated docs)
- Ensure Spec 2 (Authentication) is implemented before any deployment
- Architecture designed so JWT middleware can replace temporary parameter without refactoring

### Risk 2: Database Connection Failures

**Risk**: Neon Serverless PostgreSQL might have intermittent connectivity issues or rate limits.

**Likelihood**: Low (managed service with SLA)
**Impact**: Medium (API returns 500 errors)

**Mitigation**:
- Connection pooling via SQLAlchemy engine
- Retry logic for transient failures (can be added if needed)
- Clear error messages in logs for debugging
- Health check endpoint to verify database connectivity

### Risk 3: Tag Deduplication Not Enforced

**Risk**: Edge case where duplicate tags (e.g., `["work", "work"]`) are stored without deduplication.

**Likelihood**: Low (client-side can prevent)
**Impact**: Low (minor data quality issue)

**Mitigation**:
- Documented in spec edge cases as "SHOULD deduplicate"
- Can be implemented in `TaskCreate` Pydantic validator if needed
- Not critical for MVP (deferred unless user requests)

---

## Success Metrics

This plan is complete when:

1. ✅ All Phase 0 research questions answered in `research.md`
2. ✅ Data model documented in `data-model.md` with Task entity fully specified
3. ✅ OpenAPI contract generated in `contracts/api-openapi.yaml` with all 5 endpoints
4. ✅ Quickstart guide created in `quickstart.md` with setup instructions
5. ✅ Agent context updated with FastAPI, SQLModel, Neon PostgreSQL technologies
6. ✅ Constitution Check passes with no unresolved violations
7. ✅ ADR candidates identified (3 significant architectural decisions)
8. ✅ Plan reviewed and approved by user
9. ✅ Ready for `/sp.tasks` to generate atomic task breakdown

---

**Next Command**: `/sp.tasks` (after user approves this plan)
