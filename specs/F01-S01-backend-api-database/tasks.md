# Implementation Tasks: Backend API & Database

**Feature**: F01-S01-backend-api-database
**Branch**: `F01-S01-backend-api-database`
**Date**: 2026-01-09

## Overview

This document breaks down the Backend API & Database feature into atomic, testable tasks organized by user story. Each user story represents an independently deliverable increment that can be implemented and tested in isolation.

**Technology Stack**:
- **Backend**: Python 3.12+, FastAPI 0.109.0, SQLModel 0.0.14, Pydantic 2.5.0
- **Database**: Neon Serverless PostgreSQL with psycopg2-binary 2.9.9
- **Server**: uvicorn[standard] 0.27.0
- **Testing**: pytest 7.4.4, httpx 0.26.0 (tests optional, not in this spec)

**Agentic Execution**: ALL tasks will be executed using Claude Code with specialized agents:
- `database-optimizer`: Schema, models, migrations
- `fastapi-backend-agent`: API endpoints, services, error handling

---

## Task Summary

| Phase | User Story | Task Count | Parallel Tasks | Status |
|-------|-----------|------------|----------------|--------|
| Phase 1 | Setup | 8 | 0 | Pending |
| Phase 2 | Foundational | 6 | 3 | Pending |
| Phase 3 | US1 + US5 (P1) | 10 | 4 | Pending |
| Phase 4 | US2 (P2) | 4 | 2 | Pending |
| Phase 5 | US3 (P2) | 3 | 1 | Pending |
| Phase 6 | US4 (P3) | 3 | 1 | Pending |
| Phase 7 | Polish | 4 | 2 | Pending |
| **Total** | | **38** | **13** | |

---

## Dependency Graph

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational: Database + Base Models)
    ↓
Phase 3 (US1 + US5: Create Tasks + Multi-User Isolation) ← MVP COMPLETE HERE
    ↓
    ├─→ Phase 4 (US2: Update Tasks) ─┐
    ├─→ Phase 5 (US3: Delete Tasks) ─┤
    └─→ Phase 6 (US4: Filter Tasks) ─┤
                                      ↓
                               Phase 7 (Polish)
```

**Independence**: US2, US3, and US4 can be implemented in parallel after Phase 3 completes, as they don't depend on each other.

---

## Implementation Strategy

### MVP (Minimum Viable Product)
**Complete Phases 1-3 only** for a functional multi-user task creation API:
- ✅ Project setup with dependencies
- ✅ Database connection to Neon PostgreSQL
- ✅ Task model with user_id scoping
- ✅ POST /api/tasks (create) endpoint
- ✅ GET /api/tasks (list) endpoint
- ✅ Multi-user isolation enforced

**Value**: Proves backend-to-database integration, multi-user architecture, and delivers core task creation capability.

### Full Feature
Complete all phases (1-7) for complete CRUD operations with filtering.

---

## Phase 1: Setup & Configuration

**Goal**: Initialize Python backend project with FastAPI, SQLModel, and environment configuration.

**Prerequisites**: None (starting from scratch)

**Success Criteria**:
- Python virtual environment created
- All dependencies installed from requirements.txt
- Environment variables configured (.env file)
- Project structure matches plan.md specification
- Backend server starts without errors (`uvicorn src.main:app --reload`)

### Tasks

- [ ] T001 Create Python virtual environment in backend/ directory using `python -m venv venv`
- [ ] T002 Create backend/requirements.txt with dependencies: fastapi==0.109.0, sqlmodel==0.0.14, pydantic==2.5.0, uvicorn[standard]==0.27.0, psycopg2-binary==2.9.9, python-dotenv==1.0.0
- [ ] T003 Create backend/config/.env.example with DATABASE_URL template and configuration variables
- [ ] T004 Create backend/.env with actual Neon PostgreSQL connection string (DATABASE_URL=postgresql://...)
- [ ] T005 Create project structure: backend/src/ with subdirectories (models/, schemas/, api/, services/, utils/)
- [ ] T006 Create backend/src/__init__.py and all subdirectory __init__.py files for proper Python package structure
- [ ] T007 Create backend/src/config.py to load environment variables using pydantic-settings BaseSettings pattern
- [ ] T008 Install all dependencies with `pip install -r requirements.txt` and verify installation

---

## Phase 2: Foundational Infrastructure

**Goal**: Establish database connection, core models, and base API structure.

**Prerequisites**: Phase 1 complete

**Success Criteria**:
- Database connection to Neon PostgreSQL successful
- SQLModel engine and session factory configured
- Task model defined with all required fields
- Error handling utilities created
- FastAPI application initialized with CORS and basic routes

### Tasks

- [ ] T009 [P] Create backend/src/database.py with SQLModel engine creation, session factory, and get_db dependency injection function
- [ ] T010 [P] Create backend/src/models/task.py with Task SQLModel (table=True) including: id (UUID), user_id (str, indexed), title, description, status, priority, tags (ARRAY), created_at, updated_at
- [ ] T011 [P] Create backend/src/utils/errors.py with custom exception classes: TaskError, TaskNotFoundError, UnauthorizedAccessError
- [ ] T012 Create backend/src/main.py with FastAPI app initialization, CORS middleware, database lifecycle events (startup/shutdown)
- [ ] T013 Add global exception handlers to backend/src/main.py for TaskError, RequestValidationError, and generic Exception (structured JSON errors per spec)
- [ ] T014 Create database tables by running SQLModel.metadata.create_all(engine) in startup event or via python script

---

## Phase 3: User Story 1 + 5 (P1) - Create Tasks + Multi-User Isolation

**Goal**: Implement task creation endpoint with full multi-user data isolation.

**Prerequisites**: Phase 2 complete

**Independent Test Criteria**:
1. POST /api/tasks with valid data returns 201 Created with full task object including UUID id and timestamps
2. Created task persists in database (verified by restarting server and querying)
3. GET /api/tasks?user_id=alice returns only Alice's tasks (Bob's tasks excluded)
4. Attempting to create task without user_id returns 400 Bad Request
5. Missing required field (title) returns 400 Bad Request with clear error message
6. Cross-user access (Alice trying to read Bob's tasks) returns only Alice's data (403 if accessing specific task ID)

**User Story Mapping**:
- **US1**: Create and Persist Todo Tasks
- **US5**: Multi-User Task Isolation

### Tasks

- [ ] T015 [P] [US1] Create backend/src/schemas/task_schemas.py with TaskCreate schema (title required, description/status/priority/tags optional with defaults)
- [ ] T016 [P] [US1] Create backend/src/schemas/task_schemas.py with TaskResponse schema (all fields from Task model, config for ORM mode)
- [ ] T017 [P] [US1] Create backend/src/schemas/error_schemas.py with ErrorResponse schema (error object with code and message fields)
- [ ] T018 [US5] Create backend/src/api/deps.py with get_user_id dependency function (extracts user_id from query parameter or header, validates non-empty)
- [ ] T019 [US1] [US5] Create backend/src/services/task_service.py with TaskService class (constructor accepts db session and user_id, implements user-scoped query filtering)
- [ ] T020 [US1] Implement TaskService.create_task() method in backend/src/services/task_service.py (validates input, sets user_id, generates UUID, saves to DB)
- [ ] T021 [US5] Implement TaskService.list_tasks() method in backend/src/services/task_service.py with user_id filtering (WHERE user_id = ?)
- [ ] T022 [US1] Create backend/src/api/routes/tasks.py with POST /api/tasks endpoint (uses get_user_id and get_db dependencies, calls TaskService.create_task)
- [ ] T023 [US5] Add GET /api/tasks endpoint to backend/src/api/routes/tasks.py (uses get_user_id and get_db dependencies, calls TaskService.list_tasks with user_id filter)
- [ ] T024 [US1] [US5] Register tasks router in backend/src/main.py with /api prefix and verify both endpoints return correct responses

**Acceptance Validation** (Manual Testing):
```bash
# Test US1: Create task for user Alice
curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy groceries", "description": "Milk, eggs, bread", "priority": "high", "tags": ["shopping", "urgent"]}'
# Expected: 201 Created with full task object (id, created_at, updated_at)

# Test US1: Verify persistence (restart server, then query)
curl http://localhost:8000/api/tasks?user_id=alice
# Expected: 200 OK with array containing previously created task

# Test US5: Create task for user Bob
curl -X POST http://localhost:8000/api/tasks?user_id=bob \
  -H "Content-Type: application/json" \
  -d '{"title": "Write report", "priority": "medium"}'

# Test US5: Verify isolation - Alice's query shouldn't return Bob's tasks
curl http://localhost:8000/api/tasks?user_id=alice
# Expected: 200 OK with only Alice's tasks (Bob's task excluded)

# Test US1: Validation - missing title
curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"description": "No title provided"}'
# Expected: 400 Bad Request with validation error
```

---

## Phase 4: User Story 2 (P2) - Update Tasks

**Goal**: Implement task update endpoint with PATCH semantics (partial updates only).

**Prerequisites**: Phase 3 complete

**Independent Test Criteria**:
1. PATCH /api/tasks/{id} with valid user_id updates specified fields only
2. updated_at timestamp is refreshed on every update
3. Unspecified fields remain unchanged
4. Invalid status/priority values return 400 Bad Request with validation errors
5. Cross-user update attempt (Alice updating Bob's task) returns 403 Forbidden
6. Updating non-existent task returns 404 Not Found

**User Story Mapping**:
- **US2**: Update Existing Todo Tasks

### Tasks

- [ ] T025 [P] [US2] Create TaskUpdate schema in backend/src/schemas/task_schemas.py (all fields optional, supports PATCH semantics)
- [ ] T026 [P] [US2] Implement TaskService.get_task_by_id() method in backend/src/services/task_service.py with user_id verification (returns 403 if cross-user access)
- [ ] T027 [US2] Implement TaskService.update_task() method in backend/src/services/task_service.py using model_dump(exclude_unset=True) for partial updates
- [ ] T028 [US2] Add PATCH /api/tasks/{id} endpoint to backend/src/api/routes/tasks.py (validates UUID format, calls TaskService.update_task)

**Acceptance Validation** (Manual Testing):
```bash
# Create task first (use task ID from Phase 3 or create new one)
TASK_ID="<uuid-from-phase-3>"

# Test US2: Update status only
curl -X PATCH http://localhost:8000/api/tasks/$TASK_ID?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"status": "completed"}'
# Expected: 200 OK with updated task (only status changed, updated_at refreshed)

# Test US2: Invalid status value
curl -X PATCH http://localhost:8000/api/tasks/$TASK_ID?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"status": "invalid-status"}'
# Expected: 400 Bad Request with validation error

# Test US2: Cross-user update attempt
curl -X PATCH http://localhost:8000/api/tasks/$TASK_ID?user_id=bob \
  -H "Content-Type: application/json" \
  -d '{"title": "Trying to modify Alice'\''s task"}'
# Expected: 403 Forbidden
```

---

## Phase 5: User Story 3 (P2) - Delete Tasks

**Goal**: Implement task deletion endpoint with permanent removal.

**Prerequisites**: Phase 3 complete

**Independent Test Criteria**:
1. DELETE /api/tasks/{id} with valid user_id returns 204 No Content
2. Deleted task no longer exists (subsequent GET returns 404)
3. Cross-user delete attempt (Alice deleting Bob's task) returns 403 Forbidden
4. Deleting already-deleted task returns 404 Not Found
5. Missing user_id returns 400 Bad Request

**User Story Mapping**:
- **US3**: Delete Todo Tasks

### Tasks

- [ ] T029 [P] [US3] Implement TaskService.delete_task() method in backend/src/services/task_service.py with user_id verification and permanent deletion
- [ ] T030 [US3] Add DELETE /api/tasks/{id} endpoint to backend/src/api/routes/tasks.py (validates UUID, calls TaskService.delete_task, returns 204 on success)
- [ ] T031 [US3] Add error handling for TaskNotFoundError in DELETE endpoint (returns 404 with clear message if task doesn't exist)

**Acceptance Validation** (Manual Testing):
```bash
# Create task first
TASK_ID=$(curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"title": "Task to delete"}' | jq -r '.id')

# Test US3: Delete task
curl -X DELETE http://localhost:8000/api/tasks/$TASK_ID?user_id=alice
# Expected: 204 No Content

# Test US3: Verify deletion (should return 404)
curl -X DELETE http://localhost:8000/api/tasks/$TASK_ID?user_id=alice
# Expected: 404 Not Found

# Test US3: Cross-user delete attempt
BOB_TASK_ID=$(curl -X POST http://localhost:8000/api/tasks?user_id=bob \
  -H "Content-Type: application/json" \
  -d '{"title": "Bob'\''s task"}' | jq -r '.id')

curl -X DELETE http://localhost:8000/api/tasks/$BOB_TASK_ID?user_id=alice
# Expected: 403 Forbidden
```

---

## Phase 6: User Story 4 (P3) - Filter and Query Tasks

**Goal**: Add filtering and sorting capabilities to GET /api/tasks endpoint.

**Prerequisites**: Phase 3 complete

**Independent Test Criteria**:
1. Filtering by status returns only tasks with matching status
2. Filtering by priority returns only tasks with matching priority
3. Filtering by tags returns tasks containing any of the specified tags
4. Sorting by created_at returns tasks in chronological order
5. Sorting by priority returns tasks in priority order (high → medium → low)
6. Multiple filters can be combined (e.g., status=completed&priority=high)

**User Story Mapping**:
- **US4**: Filter and Query Tasks

### Tasks

- [ ] T032 [P] [US4] Extend TaskService.list_tasks() method in backend/src/services/task_service.py to accept optional filter parameters (status, priority, tags, sort)
- [ ] T033 [US4] Implement filtering logic in TaskService.list_tasks() using SQLModel select() with WHERE clauses for status, priority, and tags (PostgreSQL array contains)
- [ ] T034 [US4] Update GET /api/tasks endpoint in backend/src/api/routes/tasks.py to accept optional query parameters (status, priority, tags comma-separated, sort)

**Acceptance Validation** (Manual Testing):
```bash
# Create multiple tasks with different statuses and priorities
curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 1", "status": "todo", "priority": "high", "tags": ["work", "urgent"]}'

curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 2", "status": "completed", "priority": "low", "tags": ["personal"]}'

curl -X POST http://localhost:8000/api/tasks?user_id=alice \
  -H "Content-Type: application/json" \
  -d '{"title": "Task 3", "status": "in-progress", "priority": "high", "tags": ["work"]}'

# Test US4: Filter by status
curl "http://localhost:8000/api/tasks?user_id=alice&status=completed"
# Expected: 200 OK with only Task 2

# Test US4: Filter by priority
curl "http://localhost:8000/api/tasks?user_id=alice&priority=high"
# Expected: 200 OK with Task 1 and Task 3

# Test US4: Filter by tags
curl "http://localhost:8000/api/tasks?user_id=alice&tags=work"
# Expected: 200 OK with Task 1 and Task 3 (both have "work" tag)

# Test US4: Sort by priority
curl "http://localhost:8000/api/tasks?user_id=alice&sort=priority"
# Expected: 200 OK with tasks ordered: high, high, low
```

---

## Phase 7: Polish & Cross-Cutting Concerns

**Goal**: Add error handling, validation, indexes, and documentation.

**Prerequisites**: All user stories (Phases 3-6) complete

**Success Criteria**:
- Database indexes created on user_id and status columns
- FastAPI auto-generated docs accessible at /docs
- Edge cases handled (empty title, long descriptions, invalid UUIDs)
- Error responses follow structured format from spec
- README updated with setup instructions

### Tasks

- [ ] T035 [P] Add database indexes to backend/src/models/task.py using SQLModel Field(index=True) for user_id and status columns
- [ ] T036 [P] Add Pydantic field validators to TaskCreate schema in backend/src/schemas/task_schemas.py (title not empty, description max 5000 chars, deduplicate tags)
- [ ] T037 Add edge case handling to all endpoints: invalid UUID format (400), empty title (400), extremely long description (400), missing user_id (400)
- [ ] T038 Update backend/README.md with setup instructions, API endpoint documentation, environment variable configuration, and example curl commands

---

## Parallel Execution Opportunities

### Within Phase 2 (Foundational)
**Parallel Group A** (3 tasks, no dependencies):
- T009: Create database.py
- T010: Create models/task.py
- T011: Create utils/errors.py

### Within Phase 3 (US1 + US5)
**Parallel Group B** (4 tasks, no dependencies):
- T015: Create TaskCreate schema
- T016: Create TaskResponse schema
- T017: Create ErrorResponse schema
- T018: Create get_user_id dependency

### Within Phase 4 (US2)
**Parallel Group C** (2 tasks, no dependencies):
- T025: Create TaskUpdate schema
- T026: Implement get_task_by_id method

### Within Phase 5 (US3)
**Parallel Group D** (1 task):
- T029: Implement delete_task method (can start while other phases are in progress)

### Within Phase 6 (US4)
**Parallel Group E** (1 task):
- T032: Extend list_tasks with filtering (can start after T021 complete)

### Within Phase 7 (Polish)
**Parallel Group F** (2 tasks, no dependencies):
- T035: Add database indexes
- T036: Add field validators

---

## Agent Assignment Strategy

### Database-Optimizer Agent
Use for tasks involving database models, schema, and connections:
- T009 (database.py)
- T010 (models/task.py)
- T014 (create tables)
- T035 (add indexes)

### FastAPI-Backend-Agent
Use for tasks involving API endpoints, services, and schemas:
- T012 (main.py initialization)
- T013 (exception handlers)
- T015-T017 (schemas)
- T018 (dependencies)
- T019-T021 (TaskService)
- T022-T024 (POST and GET endpoints)
- T025-T028 (PATCH endpoint + schemas)
- T029-T031 (DELETE endpoint)
- T032-T034 (filtering and sorting)
- T036 (field validators)
- T037 (edge case handling)

### Manual/Configuration Tasks
Setup and configuration tasks (no agent):
- T001-T008 (environment setup, dependencies, project structure)
- T038 (README updates)

---

## Success Validation Checklist

After completing all phases, verify:

- [ ] All 5 user stories have passing acceptance tests
- [ ] Multi-user isolation enforced (Alice cannot access Bob's tasks)
- [ ] All CRUD operations functional (Create, Read, Update, Delete)
- [ ] Filtering and sorting work correctly
- [ ] Database indexes exist on user_id and status
- [ ] Error responses follow structured JSON format
- [ ] FastAPI docs accessible at /docs
- [ ] Backend survives server restart (persistence verified)
- [ ] Constitution Principle IV (Multi-User Data Ownership) validated
- [ ] Ready for Spec 2 (Authentication) integration

---

## Notes

- **Tests**: No test tasks included in this breakdown per spec (tests not requested). Success criteria defined for manual validation.
- **Alembic Migrations**: Optional for this spec. Using SQLModel.metadata.create_all() for simplicity.
- **API Versioning**: Not required for this spec. Base path is /api/tasks.
- **Pagination**: Deferred to future spec per out-of-scope section.
- **Soft Deletes**: Not required. DELETE is permanent removal.

---

**Next Steps**: Begin Phase 1 (Setup) using manual configuration, then use specialized agents for Phases 2-7 implementation.
