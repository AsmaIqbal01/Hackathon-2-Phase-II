<!--
Sync Impact Report (2026-01-02)
─────────────────────────────────────────────────────────────────────────────
Version Change: INITIAL → 1.0.0
Rationale: First constitution for Phase II (MINOR bump from template baseline)

Modified Principles:
- NEW: I. Spec-Driven Development Only
- NEW: II. Reuse Over Reinvention
- NEW: III. Amendment-Based Development
- NEW: IV. Multi-User Data Ownership
- NEW: V. Stateless Authentication
- NEW: VI. Web-First Architecture
- NEW: VII. Test-Driven Development
- NEW: VIII. Observability & Error Handling

Added Sections:
- Core Principles (8 principles)
- Technology Stack
- Architectural Boundaries
- Authentication & Authorization
- Data Ownership & Isolation
- REST API Standards
- Database & Persistence
- Testing Philosophy
- Governance

Removed Sections:
- None (initial constitution)

Templates Requiring Updates:
✅ plan-template.md - Constitution Check section verified compatible
✅ spec-template.md - Requirements alignment verified
✅ tasks-template.md - Task categorization verified compatible

Follow-up TODOs:
- None - all placeholders resolved

Dependent Artifacts:
- Phase I Repository: https://github.com/AsmaIqbal01/Hackathon2-phase1
- Frontend Agent System: https://github.com/AsmaIqbal01/frontend_agent_system
- Backend Agent System: https://github.com/AsmaIqbal01/Backend_agent_system
─────────────────────────────────────────────────────────────────────────────
-->

# Evolution of Todo – Phase II Constitution

## Context & Scope

This constitution governs **Phase II** of the Evolution of Todo project: transforming the Phase I console-based interactive CLI into a **full-stack, multi-user web application** with persistent storage, authentication, and a RESTful API.

**Phase II is an ADDENDUM, not a replacement.**

All principles, patterns, and constraints from the following repositories remain **authoritative** and MUST be respected unless explicitly overridden in this document:

1. **Phase I Reference Implementation**: https://github.com/AsmaIqbal01/Hackathon2-phase1
2. **Frontend Agent System**: https://github.com/AsmaIqbal01/frontend_agent_system
3. **Backend Agent System**: https://github.com/AsmaIqbal01/Backend_agent_system

**Purpose**: Enable persistent, multi-user todo management via web interface while maintaining spec-driven, AI-generated-only development.

---

## Core Principles

### I. Spec-Driven Development Only

**Rule**: All code MUST originate from specifications. No manual coding is permitted.

- Every feature begins with a specification in `specs/<feature>/spec.md`
- Specifications are the single source of truth
- Implementation plans derived from specs via `/sp.plan`
- Tasks generated from plans via `/sp.tasks`
- Code generated only through spec-driven workflows
- All changes require spec amendments before implementation

**Rationale**: Ensures traceability, consistency, and AI-driven quality. Prevents drift between intent and implementation.

**Violation Detection**: Any code not traceable to a spec file or PHR constitutes a violation.

---

### II. Reuse Over Reinvention

**Rule**: Reuse existing logic, patterns, and intelligence from authoritative repositories before creating new implementations.

**MUST Reuse from Phase I**:
- Task CRUD logic (create, read, update, delete)
- Validation rules (title, description, status, priority, tags)
- Error messages and error handling patterns
- Business rules (status transitions, tag validation)

**MUST Reuse from Backend Agent System**:
- API error handling patterns
- Input validation strategies
- Service layer architecture
- Database interaction patterns
- Testing methodologies

**MUST Reuse from Frontend Agent System**:
- UI/UX interaction patterns
- Component composition strategies
- State management approaches
- API client patterns

**Rationale**: Proven patterns reduce bugs, accelerate development, and maintain consistency across phases.

**Violation Detection**: Creating new implementations when equivalent logic exists in authoritative repositories.

---

### III. Amendment-Based Development

**Rule**: Modify existing behavior ONLY where required for web architecture, persistence, or authentication. Do NOT re-specify unchanged behavior.

**Requires Amendment**:
- Adding persistence (in-memory → PostgreSQL)
- Adding authentication (single-user → multi-user)
- Adding web API (CLI → REST endpoints)
- Adding frontend UI (console → web interface)

**Does NOT Require Amendment** (inherit from Phase I):
- Task validation rules
- Status transition logic
- Tag management rules
- Priority constraints
- Error messages for business logic

**Rationale**: Minimizes specification overhead and prevents unintended behavioral drift.

**Violation Detection**: Specifications that redefine unchanged Phase I behavior.

---

### IV. Multi-User Data Ownership

**Rule**: Each task belongs to exactly one user. Cross-user access is forbidden.

**Ownership Enforcement**:
- Every task record MUST include `user_id` field
- All queries MUST filter by authenticated user's ID
- Users can ONLY read their own tasks
- Users can ONLY modify their own tasks
- Users can ONLY delete their own tasks
- Attempting cross-user access MUST return HTTP 403 Forbidden

**Backend Responsibility**:
- Extract `user_id` from verified JWT token
- Ignore any `user_id` passed directly by client
- Scope all database queries to authenticated user

**Rationale**: Ensures data privacy and isolation in multi-user environment.

**Violation Detection**: Any endpoint that returns or modifies tasks without user filtering, or accepts `user_id` from client input.

---

### V. Stateless Authentication

**Rule**: Backend remains stateless using JWT-based authentication. No session storage.

**Authentication Flow**:
1. Frontend: Better Auth issues JWT token on successful login
2. Frontend: Sends JWT in `Authorization: Bearer <token>` header for every backend request
3. Backend: Verifies JWT signature using shared secret
4. Backend: Extracts authenticated `user_id` from verified token
5. Backend: Uses extracted `user_id` to scope all operations

**JWT Requirements**:
- Tokens MUST be signed with HS256 or RS256
- Tokens MUST include `user_id` claim
- Backend MUST verify signature before processing requests
- Backend MUST reject expired or invalid tokens with HTTP 401 Unauthorized

**Rationale**: Enables horizontal scaling, simplifies backend logic, and follows modern authentication best practices.

**Violation Detection**: Backend storing session state, accepting unauthenticated requests, or trusting client-provided `user_id`.

---

### VI. Web-First Architecture

**Rule**: Application structured as decoupled frontend and backend with clear boundaries.

**Frontend (Next.js 16+)**:
- App Router architecture
- TypeScript for type safety
- Tailwind CSS for styling
- Better Auth for authentication
- Centralized API client module
- All backend calls include JWT token

**Backend (Python FastAPI)**:
- RESTful API under `/api` prefix
- SQLModel ORM for database access
- Neon Serverless PostgreSQL
- JWT verification middleware
- No global mutable state
- Stateless request handling

**Communication**:
- Frontend communicates with backend exclusively via REST API
- No direct database access from frontend
- No server-side rendering of user data (API-first)

**Rationale**: Clear separation of concerns, independent scaling, and technology flexibility.

**Violation Detection**: Frontend accessing database directly, backend rendering HTML, or stateful backend logic.

---

### VII. Test-Driven Development

**Rule**: Tests MUST be written first, MUST fail initially, then implementation MUST make them pass.

**Testing Discipline** (when tests are requested):
1. Write test cases for acceptance criteria
2. Verify tests FAIL (Red)
3. Get user approval of failing tests
4. Implement minimum code to pass tests (Green)
5. Refactor while keeping tests passing (Refactor)

**Test Categories**:
- **Contract Tests**: API endpoint contracts (input/output schemas)
- **Integration Tests**: End-to-end user journeys with database
- **Unit Tests**: Business logic in isolation (optional unless requested)

**Backend Testing**:
- Auth enforcement: Verify 401 for missing/invalid JWT
- User isolation: Verify 403 for cross-user access attempts
- CRUD operations: Verify create, read, update, delete with persistence
- Validation: Verify input validation and error messages

**Frontend Testing**:
- Component logic (no E2E required unless requested)
- API client error handling
- Form validation

**Rationale**: Prevents regressions, documents expected behavior, and ensures specification compliance.

**Violation Detection**: Code written before tests exist, passing tests without implementation, or missing coverage for critical paths.

---

### VIII. Observability & Error Handling

**Rule**: All errors MUST be logged, categorized, and returned with appropriate HTTP status codes and user-friendly messages.

**Error Taxonomy**:
- **400 Bad Request**: Invalid input (validation failures)
- **401 Unauthorized**: Missing or invalid JWT token
- **403 Forbidden**: Cross-user access attempt
- **404 Not Found**: Resource does not exist
- **422 Unprocessable Entity**: Business logic constraint violation
- **500 Internal Server Error**: Unexpected server errors

**Error Response Format**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly description",
    "details": {
      "field": "title",
      "constraint": "required"
    }
  }
}
```

**Logging Requirements**:
- All API requests logged with timestamp, user ID, endpoint, status code
- All errors logged with full context (request ID, user ID, stack trace)
- Structured logging in JSON format
- No sensitive data (passwords, tokens) in logs

**Rationale**: Enables debugging, monitoring, and operational visibility.

**Violation Detection**: Endpoints without error handling, generic error messages, or missing logs for failures.

---

## Technology Stack

### Frontend
- **Framework**: Next.js 16+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Authentication**: Better Auth (JWT enabled)
- **HTTP Client**: Centralized API client module
- **State Management**: React hooks (no Redux unless complexity demands)

### Backend
- **Framework**: Python FastAPI
- **ORM**: SQLModel
- **Database**: Neon Serverless PostgreSQL
- **Authentication**: JWT verification (shared secret with Better Auth)
- **Validation**: Pydantic models via SQLModel
- **Migration**: Alembic (if schema changes required)

### Deployment
- **Frontend**: Vercel (or similar Next.js-optimized platform)
- **Backend**: Railway, Render, or similar Python platform
- **Database**: Neon Serverless PostgreSQL (managed)

**Rationale**: Modern, production-ready stack with strong type safety, developer experience, and deployment simplicity.

---

## Architectural Boundaries

### Frontend Responsibilities
- User authentication (Better Auth)
- UI rendering and interaction
- Form validation (client-side for UX)
- API requests with JWT headers
- Error display to users

### Backend Responsibilities
- JWT verification and user extraction
- Data persistence (PostgreSQL)
- Business logic enforcement
- Server-side validation (authoritative)
- API endpoint implementation
- Database queries scoped to authenticated user

### Clear Separation
- Frontend NEVER accesses database directly
- Backend NEVER renders HTML or UI components
- Authentication credentials stored only in frontend (cookies/localStorage)
- Business logic duplicated in frontend only for UX (not security)

---

## Authentication & Authorization

### Better Auth (Frontend)
- Issues JWT tokens on successful login
- Stores tokens securely (httpOnly cookies preferred)
- Includes JWT in `Authorization: Bearer <token>` header for all API calls
- Handles token refresh before expiration

### Backend Verification
- Middleware extracts `Authorization` header
- Verifies JWT signature with shared secret
- Extracts `user_id` from verified token claims
- Attaches `user_id` to request context
- Returns 401 if token missing, expired, or invalid

### Protected Routes
- ALL API endpoints require valid JWT (except `/api/auth/*`)
- Unauthenticated requests return 401
- Cross-user access attempts return 403

---

## Data Ownership & Isolation

### Database Schema
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id),
    title VARCHAR NOT NULL,
    description TEXT,
    status VARCHAR NOT NULL,
    priority VARCHAR,
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
```

### Query Scoping
Every task query MUST include `WHERE user_id = <authenticated_user_id>`:
```python
# Correct
tasks = db.query(Task).filter(Task.user_id == current_user_id).all()

# VIOLATION
tasks = db.query(Task).all()  # Returns all users' tasks!
```

---

## REST API Standards

### Endpoint Naming
- Base path: `/api`
- Resource-oriented: `/api/tasks`, `/api/tasks/{id}`
- Plural nouns for collections
- No verbs in URLs (use HTTP methods)

### HTTP Methods
- **GET** `/api/tasks`: List all tasks for authenticated user
- **POST** `/api/tasks`: Create new task for authenticated user
- **GET** `/api/tasks/{id}`: Get task by ID (only if owned by user)
- **PATCH** `/api/tasks/{id}`: Update task (only if owned by user)
- **DELETE** `/api/tasks/{id}`: Delete task (only if owned by user)

### Request/Response Format
- Content-Type: `application/json`
- Request bodies use JSON
- Response bodies use JSON
- Timestamps in ISO 8601 format

### Status Code Usage
- **200 OK**: Successful GET/PATCH
- **201 Created**: Successful POST
- **204 No Content**: Successful DELETE
- **400 Bad Request**: Invalid input
- **401 Unauthorized**: Missing/invalid JWT
- **403 Forbidden**: Cross-user access attempt
- **404 Not Found**: Resource doesn't exist
- **422 Unprocessable Entity**: Business logic violation
- **500 Internal Server Error**: Unexpected errors

---

## Database & Persistence

### SQLModel ORM
- All models defined as SQLModel classes
- Type hints for all fields
- Relationships defined explicitly
- No raw SQL unless performance-critical (must document rationale)

### Migrations
- Alembic for schema changes
- Migration scripts committed to repository
- No implicit schema changes
- Database schema managed via explicit migrations

### No Global State
- No module-level database connections
- Database session per request (FastAPI dependency injection)
- No caching in global variables
- Stateless backend design

---

## Testing Philosophy

### Phase I Compatibility
Maintain Phase I test philosophy while adding web-specific tests:

**Backend Integration Tests** (when tests requested):
- Auth enforcement: Verify 401 for unauthenticated requests
- User isolation: Verify 403 for cross-user access
- CRUD operations: Verify create, read, update, delete with database persistence
- Validation: Verify Phase I validation rules still apply

**Frontend Component Tests** (when tests requested):
- Form validation logic
- API client error handling
- UI state management

**No E2E Required** (unless explicitly requested):
- Focus on integration tests over end-to-end browser tests
- Component logic tests sufficient for frontend

---

## Governance

### Constitutional Authority
1. This Phase II constitution takes precedence over general practices
2. Where Phase II is silent, Phase I constitution applies
3. Where Phase I is silent, authoritative repository constitutions apply (Frontend Agent System, Backend Agent System)

### Amendment Process
1. Identify need for amendment (architectural change, new constraint, etc.)
2. Document proposed change with rationale
3. Update constitution via `/sp.constitution` command
4. Increment version according to semantic versioning
5. Propagate changes to dependent templates
6. Commit amendment with ADR if architecturally significant

### Compliance Verification
- All PRs MUST verify constitutional compliance
- Complexity MUST be justified (see plan-template.md "Complexity Tracking")
- Violations MUST be documented and remediated
- Automated checks preferred (linting, tests)

### Version Control
- Semantic versioning: MAJOR.MINOR.PATCH
- MAJOR: Backward-incompatible governance changes
- MINOR: New principles or sections added
- PATCH: Clarifications, wording, typo fixes

---

## Success Criteria for Phase II

Phase II is complete when:

1. ✅ All Phase I features work via web UI
2. ✅ Data persists across sessions (PostgreSQL)
3. ✅ Multiple users can use the system independently
4. ✅ Authentication enforced on all endpoints
5. ✅ No manual code exists (all spec-driven)
6. ✅ Specs fully explain the system
7. ✅ Cross-user access returns 403
8. ✅ Invalid JWT returns 401
9. ✅ Frontend and backend decoupled
10. ✅ Task CRUD logic reused from Phase I

---

## What This Constitution Does NOT Do

This constitution does NOT:
- Redefine task CRUD logic (inherited from Phase I)
- Redefine CLI behavior (Phase I remains valid)
- Override Phase I business rules (status, priority, tags)
- Introduce chatbot functionality (Phase III scope)
- Change validation rules (inherited from Phase I)
- Modify error messages for unchanged logic (inherited from Phase I)

---

**Version**: 1.0.0 | **Ratified**: 2026-01-02 | **Last Amended**: 2026-01-02
