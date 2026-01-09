---
id: 002
title: Backend API Planning & Numbering System
stage: plan
date: 2026-01-09
surface: agent
model: claude-sonnet-4-5-20250929
feature: F01-S01-backend-api-database
branch: F01-S01-backend-api-database
user: system
command: /sp.plan
labels: ["backend", "api", "database", "planning", "architecture", "fastapi", "sqlmodel", "numbering-system", "refactoring"]
links:
  spec: specs/F01-S01-backend-api-database/spec.md
  ticket: null
  adr: null
  pr: null
files:
 - specs/F01-S01-backend-api-database/plan.md
 - specs/F01-S01-backend-api-database/research.md
 - specs/F01-S01-backend-api-database/spec.md (updated branch reference)
 - specs/F01-S01-backend-api-database/checklists/requirements.md (updated spec ID)
 - history/prompts/F01-S01-backend-api-database/001-backend-api-spec-creation.spec.prompt.md (updated feature/branch)
tests:
 - None (planning phase, no tests implemented)
---

## Prompt

User requested implementation planning via `/sp.plan` with the following description:

```
/sp.plan

Project: Todo Full-Stack Web Application – Spec 1: Backend API & Database

Objective:
Produce a complete, spec-driven backend design that defines the FastAPI application structure, RESTful endpoints, and database schema required to support a multi-user Todo application.

Planning approach:
- Follow Spec-Kit Plus methodology
- Derive all tasks directly from the approved specification
- Maintain strict separation from authentication and frontend concerns
- Use agentic execution only (no manual coding)

Plan outline:

1. Backend architecture definition
   - Define FastAPI application structure
   - Identify routing layers and module boundaries
   - Establish separation between API, models, and database layers

2. Data model design
   - Define SQLModel schemas for:
     - Task entity
     - User reference (logical ownership only)
   - Ensure all tasks are associated with a user_id
   - Specify required fields and constraints

3. Database integration planning
   - Define Neon PostgreSQL connection strategy
   - Specify environment-based configuration
   - Plan for schema initialization and migrations

4. REST API specification
   - Define endpoints for:
     - Listing tasks
     - Creating tasks
     - Retrieving task details
     - Updating tasks
     - Deleting tasks
     - Toggling task completion
   - Specify request/response formats
   - Define expected HTTP status codes

5. User data ownership modeling
   - Ensure API design supports user-scoped queries
   - Treat user_id as an external, trusted identifier
   - Defer validation and authorization to Spec 2

6. Readiness validation
   - Confirm backend is:
     - Functionally complete for Todo operations
     - Persisting data correctly
     - Structured to accept authentication middleware later

Deliverables:
- Approved backend specification
- Clear task breakdown for agentic execution
- Backend design ready for security integration in Spec 2
```

Additionally, user requested implementation of a structured feature numbering system to resolve conflicts:

```
NUMBERING STRATEGY:

1. FEATURE NUMBERING
   - Use a two-level structured ID: F<feature_number>-S<spec_number>
   - Example: F01-S01-backend-api-database

2. FEATURE → SPEC MAPPING (LOCKED):
   - F01-S01 → Backend API & Database
   - F01-S02 → Authentication & Security Integration
   - F01-S03 → Frontend Application & Full-Stack Integration

3. BRANCH NAMING RULE:
   - branch = feature id
   - Example: F01-S01-backend-api-database

4. SPEC ARTIFACT PATHS:
   - specs/F01-S01-backend-api-database/
```

## Response snapshot

### Part 1: Implementation Plan Creation

Created comprehensive implementation plan (`specs/F01-S01-backend-api-database/plan.md`) with:

**Constitution Check** (All gates ✅ PASS):
- Principle I: Spec-Driven Development Only
- Principle II: Reuse Over Reinvention
- Principle III: Amendment-Based Development
- Principle IV: Multi-User Data Ownership
- Principle V: Stateless Authentication (with justified exception for Spec 2 deferral)
- Principle VI: Web-First Architecture
- Principle VII: Test-Driven Development (architecture ready)
- Principle VIII: Observability & Error Handling
- Principle IX: Agentic Execution Only
- Principle X: Reviewability as First-Class

**ADR Candidates Identified** (3 significant architectural decisions):
1. FastAPI with SQLModel for Backend API & Database
2. Temporary user_id Parameter Until JWT Authentication
3. Neon Serverless PostgreSQL for Persistent Storage

**Technical Context**:
- Language: Python 3.12+
- Dependencies: FastAPI, SQLModel, Pydantic v2, uvicorn, psycopg2-binary, python-dotenv
- Storage: Neon Serverless PostgreSQL
- Testing: pytest, httpx, pytest-asyncio
- Performance Goals: <200ms p95 latency, 100 concurrent users

**Project Structure Defined**:
- Backend layered architecture: API Layer → Service Layer → Model Layer → Database Layer
- Source structure: `backend/src/{main.py, config.py, database.py, models/, schemas/, api/, services/, utils/}`
- Test structure: `backend/tests/{conftest.py, integration/, unit/}`

**Phase 0: Research Questions** (8 areas identified):
1. FastAPI Best Practices for RESTful CRUD APIs
2. SQLModel Schema Definition and Relationships
3. Neon PostgreSQL Connection Patterns
4. User-Scoped Query Patterns
5. Pydantic V2 Validation and Error Messages
6. FastAPI Exception Handling
7. Database Indexing Strategy
8. Partial Update Handling (PATCH Semantics)

**Phase 1: Design Artifacts Planned**:
- Data Model: Task entity with 9 fields (id, user_id, title, description, status, priority, tags, created_at, updated_at)
- API Contracts: 5 REST endpoints (POST /api/tasks, GET /api/tasks, GET /api/tasks/{id}, PATCH /api/tasks/{id}, DELETE /api/tasks/{id})
- Schemas: TaskCreate, TaskUpdate, TaskResponse, ErrorResponse
- Quickstart Guide: Setup, configuration, development server, testing instructions

**Risks Identified** (3 with mitigations):
1. Temporary user_id Parameter Security (Critical risk, mitigated by clear documentation and Spec 2 implementation plan)
2. Database Connection Failures (Low risk, mitigated by connection pooling and retry logic)
3. Tag Deduplication Not Enforced (Low risk, documented as optional enhancement)

### Part 2: Technology Research Completed

Created comprehensive research document (`specs/F01-S01-backend-api-database/research.md`) with:

**Research Findings** (All 8 questions answered):

1. **FastAPI APIRouter with Layered Architecture**
   - Decision: Use APIRouter for modular endpoint organization
   - Service layer centralizes business logic and user-scoping
   - Code example provided for task endpoints

2. **SQLModel with Hybrid Models**
   - Decision: SQLModel `table=True` for database models, separate Pydantic models for API
   - UUID primary key with `uuid.uuid4()` default
   - PostgreSQL ARRAY for tags using `sa_column=Column(ARRAY(String))`

3. **Neon PostgreSQL Connection with Pooling**
   - Decision: `create_engine()` with `pool_pre_ping=True` for serverless reliability
   - Connection string format: `postgresql://user:password@host/database?sslmode=require`

4. **Service Layer with Mandatory user_id Filter**
   - Decision: All queries through `TaskService` class initialized with `user_id`
   - Return 403 Forbidden for cross-user access (not 404 to prevent info disclosure)

5. **Pydantic V2 Field Validators**
   - Decision: Use `@field_validator` for custom validation
   - `Field()` with `min_length`, `max_length` for declarative validation

6. **Global Exception Handlers with Structured Errors**
   - Decision: Custom exception classes + global handlers in `main.py`
   - Structured JSON error responses matching spec format

7. **Composite Index on user_id + status**
   - Decision: Single-column indexes on `user_id` and `status`
   - Consider composite index `(user_id, status)` for common queries

8. **Pydantic `model_dump(exclude_unset=True)`**
   - Decision: Use `exclude_unset=True` to distinguish "not provided" from "set to None"
   - Meets PATCH semantics requirement (FR-017)

**Technology Stack Finalized**:
- Core: fastapi==0.109.0, sqlmodel==0.0.14, pydantic==2.5.0, uvicorn[standard]==0.27.0
- Database: psycopg2-binary==2.9.9
- Dev: pytest==7.4.4, httpx==0.26.0, alembic==1.13.1

### Part 3: Structured Numbering System Implementation

**Problem Identified**:
- Conflicting identifiers: Constitution amendment (001), Backend API feature (002)
- Inconsistent references across artifacts
- Risk of ID conflicts between features and specs

**Solution Implemented**:
- **Feature ID Structure**: F<feature>-S<spec>-<description>
- **Scope Mapping Locked**:
  - F01-S01: Backend API & Database
  - F01-S02: Authentication & Security Integration (future)
  - F01-S03: Frontend Application & Full-Stack Integration (future)

**Changes Applied**:
1. **Branch Renamed**: `002-backend-api-database` → `F01-S01-backend-api-database`
2. **Directory Structure**:
   - `specs/002-backend-api-database/` → `specs/F01-S01-backend-api-database/`
   - `history/prompts/002-backend-api-database/` → `history/prompts/F01-S01-backend-api-database/`
3. **File Content Updates** (5 files):
   - spec.md: Feature Branch updated
   - plan.md: All references updated (14 occurrences)
   - checklists/requirements.md: Spec ID updated
   - research.md: Feature ID updated
   - PHR file: feature, branch, links, files updated (9 occurrences)

**Validation**:
- ✅ All directory renames completed via `git mv`
- ✅ All file content references updated via systematic Edit operations
- ✅ Git status verified before commit
- ✅ Comprehensive commit message documenting all changes

## Outcome

- ✅ Impact: Complete implementation plan created for Backend API & Database feature. Comprehensive Phase 0 research completed with 8 technology decisions documented. Structured numbering system (F01-S01) implemented across all artifacts, resolving ID conflicts and establishing scalable hierarchy for future specs.

- 🧪 Tests: No tests implemented (planning phase). Success criteria defined in plan with 10 measurable outcomes (SC-001 through SC-010). Test architecture planned (pytest, httpx, integration tests, unit tests).

- 📁 Files: 5 files created/updated (plan.md, research.md, spec.md, checklists/requirements.md, PHR file). All references updated to F01-S01 format. Branch and directory structure renamed.

- 🔁 Next prompts:
  1. Complete Phase 1: Create data-model.md, contracts/api-openapi.yaml, quickstart.md
  2. Run update-agent-context.ps1 to inform agents of technology choices
  3. Create ADRs for 3 significant architectural decisions (optional but recommended)
  4. Run /sp.tasks to generate atomic implementation tasks
  5. Begin implementation using fastapi-backend-agent and database-optimizer

- 🧠 Reflection: Planning phase successfully completed with comprehensive research and structured numbering system. All 10 constitutional principles verified as compliant. Temporary user_id deviation explicitly justified with clear remediation path in Spec 2. Research findings provide concrete implementation patterns for all 8 technical questions. Structured numbering system (F01-S01) provides clear hierarchy and prevents future ID conflicts. Ready for Phase 1 design artifacts and eventual task generation.

## Evaluation notes (flywheel)

- **Failure modes observed**: None during planning phase. Structured numbering system requirement emerged mid-session due to conflicting identifiers, handled systematically with todo tracking.

- **Graders run and results (PASS/FAIL)**:
  - Constitution Check: PASS (all 10 principles verified)
  - Quality Criteria: PASS (plan completeness verified)
  - Numbering System: PASS (all references updated, no conflicts)

- **Prompt variant (if applicable)**: Standard /sp.plan workflow with added structured numbering system refactoring. User provided detailed planning outline (6 sections) which guided plan structure.

- **Next experiment (smallest change to try)**:
  1. Complete Phase 1 artifacts (data-model.md, contracts/, quickstart.md) to validate research decisions
  2. Consider creating ADRs immediately after planning to capture architectural reasoning while fresh
  3. Validate that structured numbering system scales properly when F01-S02 (Authentication) is created
