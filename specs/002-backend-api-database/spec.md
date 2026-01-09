# Feature Specification: Backend API & Database

**Feature Branch**: `002-backend-api-database`
**Created**: 2026-01-09
**Status**: Draft
**Input**: User description: "Project: Todo Full-Stack Web Application – Spec 1: Backend API & Database"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and Persist Todo Tasks (Priority: P1)

As a backend client (future frontend), I need to create new todo tasks with title, description, priority, and tags that persist in the database so that tasks survive server restarts and can be retrieved later.

**Why this priority**: This is the foundational capability - without task creation and persistence, no other task management features can function. This establishes the core data model and database integration.

**Independent Test**: Can be fully tested by sending POST requests to `/api/tasks` and verifying data persists in Neon PostgreSQL by querying the database directly or via GET endpoints. Delivers immediate value by proving the backend-to-database integration works.

**Acceptance Scenarios**:

1. **Given** the backend server is running and connected to Neon PostgreSQL, **When** I POST a task with `{"title": "Buy groceries", "description": "Milk, eggs, bread", "priority": "high", "tags": ["shopping", "urgent"]}` to `/api/tasks` with a valid `user_id`, **Then** I receive a 201 Created response with the full task object including a generated UUID `id`, `created_at`, and `updated_at` timestamps, and the task persists in the database.

2. **Given** I have created a task with `user_id=user123`, **When** I restart the backend server and GET `/api/tasks?user_id=user123`, **Then** the previously created task is returned, proving persistence across server restarts.

3. **Given** I attempt to create a task without a required field (e.g., missing `title`), **When** I POST to `/api/tasks`, **Then** I receive a 400 Bad Request with a clear validation error message indicating which field is missing.

---

### User Story 2 - Update Existing Todo Tasks (Priority: P2)

As a backend client, I need to update task attributes (title, description, status, priority, tags) so that task details can be modified after creation and status can be tracked through completion.

**Why this priority**: While task creation (P1) proves the system works, task updates are essential for a functional todo system - marking tasks complete, changing priorities, or correcting details are core user needs.

**Independent Test**: Can be independently tested by first creating a task (using P1 capability), then sending PATCH requests to `/api/tasks/{id}` with updated fields, and verifying the changes persist. Delivers standalone value for task lifecycle management.

**Acceptance Scenarios**:

1. **Given** a task exists with `id=task-456` and `status=todo`, **When** I PATCH `/api/tasks/task-456` with `{"status": "completed"}` and valid `user_id`, **Then** I receive a 200 OK response with the updated task object showing `status=completed` and an updated `updated_at` timestamp.

2. **Given** a task exists for `user_id=user123`, **When** I PATCH the task with partial updates (e.g., only `{"priority": "low"}`), **Then** only the specified fields are updated, other fields remain unchanged, and `updated_at` is refreshed.

3. **Given** I attempt to update a task with an invalid `status` value, **When** I PATCH the task, **Then** I receive a 400 Bad Request with a validation error listing valid status values.

---

### User Story 3 - Delete Todo Tasks (Priority: P2)

As a backend client, I need to delete tasks by ID so that completed or unwanted tasks can be permanently removed from the database.

**Why this priority**: Deletion completes the basic CRUD operations alongside P1 (create) and P2 (update). While not as critical as creation, it's essential for users to manage their task lists and prevent database bloat.

**Independent Test**: Can be tested independently by creating a task (P1), then sending DELETE to `/api/tasks/{id}`, and verifying the task no longer exists via GET requests or direct database queries. Delivers standalone cleanup functionality.

**Acceptance Scenarios**:

1. **Given** a task exists with `id=task-789` for `user_id=user123`, **When** I DELETE `/api/tasks/task-789` with valid `user_id`, **Then** I receive a 204 No Content response and subsequent GET requests for that task return 404 Not Found.

2. **Given** a task has already been deleted, **When** I attempt to DELETE it again, **Then** I receive a 404 Not Found response with a clear error message.

3. **Given** I attempt to delete a task without providing `user_id`, **When** I send the DELETE request, **Then** I receive a 400 Bad Request indicating missing authentication parameter.

---

### User Story 4 - Filter and Query Tasks (Priority: P3)

As a backend client, I need to filter tasks by status, priority, and tags, and sort results by created date or priority so that large task lists can be organized and specific subsets retrieved efficiently.

**Why this priority**: While CRUD operations (P1, P2) are essential, filtering enhances usability but isn't required for a minimal viable product. Users can function with unfiltered lists initially, making this lower priority.

**Independent Test**: Can be tested independently by creating multiple tasks with different statuses, priorities, and tags (using P1), then sending GET requests with query parameters (e.g., `/api/tasks?user_id=user123&status=completed&priority=high`) and verifying correct filtering. Delivers standalone query optimization value.

**Acceptance Scenarios**:

1. **Given** multiple tasks exist with various statuses, **When** I GET `/api/tasks?user_id=user123&status=completed`, **Then** I receive only tasks with `status=completed`, excluding all others.

2. **Given** tasks with different priorities exist, **When** I GET `/api/tasks?user_id=user123&sort=priority`, **Then** tasks are returned sorted by priority (high → medium → low).

3. **Given** tasks with overlapping tags exist (e.g., `["work", "urgent"]` and `["work", "later"]`), **When** I filter by `tags=work`, **Then** both tasks are returned since they share the `work` tag.

---

### User Story 5 - Multi-User Task Isolation (Priority: P1)

As a backend system, I must ensure that each user's tasks are completely isolated from other users' tasks, even without authentication, by scoping all queries and operations by `user_id` to prevent data leakage and prepare for future JWT-based authentication.

**Why this priority**: This is P1 because multi-user data isolation is a **security and architecture requirement** that must be designed into the system from the start. Retrofitting this later would require significant refactoring. Even though we're not implementing JWT yet, the data model and service layer must support multi-tenancy.

**Independent Test**: Can be independently tested by creating tasks for `user_id=alice` and `user_id=bob`, then verifying that queries with `user_id=alice` return only Alice's tasks and queries with `user_id=bob` return only Bob's tasks, with zero overlap. Delivers standalone multi-user foundation.

**Acceptance Scenarios**:

1. **Given** tasks exist for `user_id=alice` and `user_id=bob`, **When** I GET `/api/tasks?user_id=alice`, **Then** only Alice's tasks are returned, Bob's tasks are excluded.

2. **Given** a task exists with `id=task-123` owned by `user_id=alice`, **When** I attempt to PATCH `/api/tasks/task-123` with `user_id=bob`, **Then** I receive a 403 Forbidden response indicating the task is not owned by Bob.

3. **Given** the database contains tasks for 100 different users, **When** I query `/api/tasks?user_id=alice`, **Then** the query is filtered at the database level (using `WHERE user_id = 'alice'`), not in application code, ensuring performance and security.

---

### Edge Cases

- **Empty title**: What happens when a task is created with `title=""` (empty string)? System MUST reject with 400 Bad Request indicating title is required.
- **Extremely long inputs**: How does the system handle a `description` field with 10,000+ characters? System MUST accept up to 5,000 characters for description, reject longer inputs with 400 Bad Request.
- **Invalid UUID format**: What happens when PATCH or DELETE requests use malformed task IDs (e.g., `task-abc`)? System MUST return 400 Bad Request with clear error message about invalid UUID format.
- **Duplicate tags**: How does the system handle tags array with duplicates (e.g., `["work", "work", "urgent"]`)? System SHOULD deduplicate tags before saving.
- **Null vs missing fields**: What happens when optional fields are explicitly set to `null` vs omitted entirely in PATCH requests? System MUST treat both as "no change" for optional fields.
- **Concurrent updates**: How does the system handle two simultaneous PATCH requests to the same task? Last write wins (no optimistic locking in this spec; can be added in future specs).
- **Database connection loss**: What happens when Neon PostgreSQL becomes unreachable during a request? System MUST return 500 Internal Server Error with generic error message (detailed error logged server-side).
- **Invalid `user_id` format**: What happens when `user_id` query parameter is missing or malformed? System MUST return 400 Bad Request indicating user_id is required and must be a non-empty string.
- **Cross-user update attempts**: What happens when `user_id=alice` attempts to PATCH or DELETE a task owned by `user_id=bob`? System MUST return 403 Forbidden (not 404) to prevent information disclosure about task existence.
- **Large result sets**: How does the system handle GET requests for users with 10,000+ tasks? System SHOULD implement pagination (offset/limit) to prevent performance degradation (optional in this spec, required in future scalability spec).

## Requirements *(mandatory)*

### Functional Requirements

#### API Contract

- **FR-001**: System MUST expose a RESTful API with base path `/api/tasks` accepting JSON request bodies and returning JSON responses.
- **FR-002**: System MUST implement HTTP methods: POST (create), GET (read), PATCH (update), DELETE (delete).
- **FR-003**: System MUST return appropriate HTTP status codes: 200 OK (successful read/update), 201 Created (successful creation), 204 No Content (successful deletion), 400 Bad Request (validation errors), 403 Forbidden (authorization failures), 404 Not Found (resource not found), 500 Internal Server Error (server errors).
- **FR-004**: System MUST accept a temporary `user_id` parameter (query param or header) on ALL requests to simulate authenticated user context until JWT authentication is implemented in Spec 2.

#### Task Creation

- **FR-005**: System MUST accept POST requests to `/api/tasks` with JSON body containing: `title` (required, string, max 255 chars), `description` (optional, string, max 5000 chars), `status` (optional, enum, default "todo"), `priority` (optional, enum, default "medium"), `tags` (optional, array of strings).
- **FR-006**: System MUST validate that `status` is one of: `todo`, `in-progress`, `completed`.
- **FR-007**: System MUST validate that `priority` is one of: `low`, `medium`, `high`.
- **FR-008**: System MUST generate a UUID `id` for each new task automatically.
- **FR-009**: System MUST record `created_at` and `updated_at` timestamps (ISO 8601 format) automatically on task creation.
- **FR-010**: System MUST associate each task with the `user_id` provided in the request and store it in the `user_id` column.

#### Task Retrieval

- **FR-011**: System MUST support GET `/api/tasks` to list all tasks for the specified `user_id`.
- **FR-012**: System MUST support GET `/api/tasks/{id}` to retrieve a single task by UUID, scoped to the specified `user_id`.
- **FR-013**: System MUST return 404 Not Found if a task with the specified `id` does not exist for the given `user_id`.
- **FR-014**: System MUST support query parameters for filtering: `status`, `priority`, `tags` (comma-separated list).
- **FR-015**: System MUST support query parameter `sort` with values: `created_at`, `priority` (ascending order by default).

#### Task Update

- **FR-016**: System MUST accept PATCH requests to `/api/tasks/{id}` with partial JSON body containing any subset of task fields to update.
- **FR-017**: System MUST update only the fields provided in the PATCH request body, leaving other fields unchanged.
- **FR-018**: System MUST refresh the `updated_at` timestamp on every successful update.
- **FR-019**: System MUST enforce `user_id` scoping: users can only update their own tasks (403 Forbidden for cross-user attempts).

#### Task Deletion

- **FR-020**: System MUST accept DELETE requests to `/api/tasks/{id}` to permanently remove tasks from the database.
- **FR-021**: System MUST return 204 No Content on successful deletion.
- **FR-022**: System MUST enforce `user_id` scoping: users can only delete their own tasks (403 Forbidden for cross-user attempts).

#### Validation & Error Handling

- **FR-023**: System MUST validate all required fields on creation and return 400 Bad Request with clear error messages listing missing/invalid fields.
- **FR-024**: System MUST validate data types and constraints (e.g., string lengths, enum values) and reject invalid requests with 400 Bad Request.
- **FR-025**: System MUST return JSON error responses with structure: `{"error": {"code": 400, "message": "Descriptive error"}}`.
- **FR-026**: System MUST log all server errors (500) with full stack traces to server logs while returning generic error messages to clients (no stack traces exposed).

#### Persistence

- **FR-027**: System MUST persist all tasks to Neon Serverless PostgreSQL using SQLModel ORM.
- **FR-028**: System MUST ensure tasks survive server restarts (data persists in external database).
- **FR-029**: System MUST use parameterized queries (via SQLModel) to prevent SQL injection vulnerabilities.

#### Multi-User Support

- **FR-030**: System MUST filter ALL database queries by `user_id` to ensure users can only access their own data.
- **FR-031**: System MUST return 403 Forbidden (not 404) when a user attempts to access/modify another user's task to prevent information disclosure.
- **FR-032**: System MUST support multiple concurrent users with zero data leakage between users.

#### Performance

- **FR-033**: System MUST create database indexes on `user_id` and `status` columns to optimize common queries.

### Key Entities *(include if feature involves data)*

- **Task**: Represents a single todo item with the following attributes:
  - `id` (UUID, primary key, auto-generated): Unique identifier for the task
  - `user_id` (string, required, indexed): Owner of the task (foreign key concept, though user table not in this spec)
  - `title` (string, required, max 255 characters): Short description of the task
  - `description` (string, optional, max 5000 characters): Detailed task description
  - `status` (enum, required, default "todo"): Current state of the task (todo, in-progress, completed)
  - `priority` (enum, required, default "medium"): Task priority level (low, medium, high)
  - `tags` (array of strings, optional): Categorization labels for filtering
  - `created_at` (datetime, auto-generated): Timestamp when task was created
  - `updated_at` (datetime, auto-updated): Timestamp when task was last modified

- **User** (reference only, not implemented in this spec): Represents a user in the system. The `user_id` field in Task will reference this entity once authentication is implemented in Spec 2. For now, `user_id` is a plain string parameter.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All CRUD operations (Create, Read, Update, Delete) are functional and pass integration tests against Neon PostgreSQL.
- **SC-002**: Tasks persist across server restarts, verified by creating a task, restarting the backend, and successfully retrieving the task.
- **SC-003**: Multi-user isolation is enforced: User A cannot access, modify, or delete User B's tasks (verified by test cases with multiple `user_id` values).
- **SC-004**: API returns correct HTTP status codes for all success and error scenarios as defined in FR-003.
- **SC-005**: Input validation rejects invalid requests (missing required fields, invalid enums, oversized strings) with 400 Bad Request and clear error messages.
- **SC-006**: Database queries are filtered by `user_id` at the SQL level (verified by examining SQLModel queries or database logs).
- **SC-007**: API documentation is auto-generated by FastAPI and accessible at `/docs` endpoint showing all available endpoints, request schemas, and response schemas.
- **SC-008**: Filtering by status, priority, and tags returns correct subsets of tasks (verified by creating diverse test data and asserting filter results).
- **SC-009**: Concurrent requests for different users do not interfere with each other (verified by parallel test execution).
- **SC-010**: Backend startup succeeds when DATABASE_URL is configured and fails gracefully with clear error message when database is unreachable.

## Assumptions

- **Temporary Authentication Mechanism**: This spec assumes `user_id` will be provided as a query parameter (e.g., `?user_id=alice`) or custom header (e.g., `X-User-ID: alice`) on ALL requests. This is a **temporary mechanism** for development and testing. Spec 2 (Authentication) will replace this with JWT token extraction.
- **Database Connectivity**: Neon Serverless PostgreSQL is already provisioned with a valid connection string stored in `.env` as `DATABASE_URL`.
- **No User Registration Yet**: This spec does NOT implement user signup/login. Any `user_id` string is accepted. User management will be added in Spec 2.
- **No Pagination**: While large result sets are mentioned as an edge case, pagination (limit/offset) is NOT required in this spec. It can be added in a future scalability-focused spec.
- **No Authentication Errors**: Since authentication is deferred to Spec 2, this spec does NOT return 401 Unauthorized errors. Missing `user_id` returns 400 Bad Request.
- **UTC Timestamps**: All timestamps (`created_at`, `updated_at`) are stored in UTC.
- **JSON Only**: API only accepts `Content-Type: application/json` and only returns JSON responses.
- **No Soft Deletes**: DELETE operations permanently remove tasks from the database (no `deleted_at` column or soft delete mechanism).
- **English Language**: All error messages and API documentation are in English.
- **Single Region**: No geographic distribution or multi-region concerns in this spec.

## Dependencies

- **Neon Serverless PostgreSQL**: Database service must be provisioned before backend can start.
- **Python 3.12+**: Backend runtime environment.
- **FastAPI**: Web framework for building the REST API.
- **SQLModel**: ORM for database operations and schema definitions.
- **Pydantic**: Request/response validation (bundled with FastAPI).
- **Alembic**: Database migration tool (for schema version control).
- **uvicorn**: ASGI server for running FastAPI in development.

## Out of Scope

The following features are explicitly OUT OF SCOPE for this specification and will be addressed in future specs:

1. **Authentication & Authorization** (Spec 2): JWT token generation, verification, user signup/login, password hashing.
2. **User Management** (Spec 2): User table, user CRUD operations, email validation, user profiles.
3. **Pagination** (Future Spec): Limit/offset or cursor-based pagination for large result sets.
4. **Search** (Future Spec): Full-text search across task titles and descriptions.
5. **Subtasks** (Future Spec): Hierarchical task relationships (parent/child tasks).
6. **Due Dates & Reminders** (Future Spec): Temporal task management features.
7. **File Attachments** (Future Spec): Uploading files or images associated with tasks.
8. **Real-Time Updates** (Future Spec): WebSocket or SSE for live task updates.
9. **Audit Logs** (Future Spec): Tracking who modified what and when for compliance.
10. **Soft Deletes** (Future Spec): Recoverable task deletion with `deleted_at` column.
11. **Bulk Operations** (Future Spec): Creating/updating/deleting multiple tasks in a single request.
12. **Task Sharing** (Future Spec): Sharing tasks between users or making tasks public.
13. **Export/Import** (Future Spec): Exporting tasks to CSV/JSON or importing from external sources.
14. **Rate Limiting** (Future Spec): Throttling requests to prevent abuse.
15. **Caching** (Future Spec): Redis or in-memory caching for frequently accessed tasks.

---

**Next Steps**: Run `/sp.plan` to generate the implementation plan for this specification.
