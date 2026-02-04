# Tasks: Frontend Application & Full-Stack Integration (Minimal)

**Input**: Design documents from `specs/F01-S03-frontend-fullstack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/
**Tests**: NOT requested (minimal hackathon scope)
**Agent**: `nextjs-frontend-optimizer` (all tasks)
**Updated**: 2026-02-01 (aligned with minimal scope)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US6)
- All paths relative to `frontend/` directory

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Initialize Next.js project with required dependencies

- [x] T001 Initialize Next.js 15+ project with App Router in frontend/ directory
- [x] T002 Configure TypeScript and Tailwind CSS in frontend/
- [x] T003 [P] Create .env.example with NEXT_PUBLIC_API_URL in frontend/
- [x] T004 [P] Create .gitignore to exclude node_modules, .next, .env.local in frontend/

**Checkpoint**: Next.js project structure ready

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Auth helpers and API client that ALL user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [x] T005 Create TypeScript types in frontend/lib/types.ts (Task, User, AuthResponse, ApiError)
- [x] T006 [P] Implement auth helpers in frontend/lib/auth.ts (getToken, setToken, clearToken, isAuthenticated)
- [x] T007 Implement API client in frontend/lib/api.ts with JWT header injection and 401 handling
- [x] T008 [P] Create root layout in frontend/app/layout.tsx with basic HTML structure
- [x] T009 Create redirect logic in frontend/app/page.tsx (authenticated → /dashboard, else → /login)

**Checkpoint**: Foundation ready - auth helpers and API client functional

---

## Phase 3: User Story 1 - Authentication Flow (Priority: P1) - MVP

**Goal**: User can login or register to access their tasks

**Independent Test**: Enter credentials → verify token stored → verify redirect to dashboard

**Acceptance Criteria**:
- Valid credentials → JWT stored in localStorage, redirect to /dashboard
- Invalid credentials → error message displayed, no redirect
- New user registration → account created, auto-login, redirect to /dashboard
- Already logged in → visiting /login redirects to /dashboard

### Implementation for US1

- [x] T010 [US1] Create login page in frontend/app/login/page.tsx with email/password form
- [x] T011 [P] [US1] Create register page in frontend/app/register/page.tsx with email/password form
- [x] T012 [US1] Implement login form submission with POST /api/auth/login, token storage, redirect
- [x] T013 [US1] Implement register form submission with POST /api/auth/register, token storage, redirect
- [x] T014 [US1] Add error handling and display for auth forms (401, 409 responses)
- [x] T015 [US1] Add loading state indicators to auth forms
- [x] T016 [US1] Implement authenticated user redirect from /login to /dashboard

**Checkpoint**: Users can register and login. US1 independently testable.

---

## Phase 4: User Story 2 - View Task List (Priority: P1)

**Goal**: Authenticated user can see their tasks on the dashboard

**Independent Test**: Log in → navigate to dashboard → verify only user's tasks render

**Acceptance Criteria**:
- Authenticated user with tasks → tasks display with title and status
- Authenticated user with no tasks → empty state message displays
- Unauthenticated user → redirect to /login

### Implementation for US2

- [x] T017 [US2] Create dashboard page in frontend/app/dashboard/page.tsx with auth check
- [x] T018 [US2] Implement task fetching from GET /api/tasks in dashboard page
- [x] T019 [P] [US2] Create TaskList component in frontend/components/TaskList.tsx
- [x] T020 [P] [US2] Create TaskItem component in frontend/components/TaskItem.tsx
- [x] T021 [US2] Implement loading state in TaskList component
- [x] T022 [US2] Implement empty state message when no tasks exist
- [x] T023 [US2] Implement error state display for failed task fetch

**Checkpoint**: Dashboard shows task list. US2 independently testable.

---

## Phase 5: User Story 3 - Create Task (Priority: P1)

**Goal**: Authenticated user can create a new task

**Independent Test**: Submit task form → verify task appears in list

**Acceptance Criteria**:
- Valid title submission → task appears in list after API success
- Empty title → error displayed, no API call

### Implementation for US3

- [x] T024 [US3] Create TaskForm component in frontend/components/TaskForm.tsx
- [x] T025 [US3] Implement client-side validation (required title) in TaskForm
- [x] T026 [US3] Implement form submission with POST /api/tasks
- [x] T027 [US3] Add new task to list state after successful creation
- [x] T028 [US3] Implement error handling and display for task creation

**Checkpoint**: Task creation works. US3 independently testable.

---

## Phase 6: User Story 4 - Toggle Task Status (Priority: P1)

**Goal**: Authenticated user can toggle task completion status

**Independent Test**: Click toggle → verify status changes

**Acceptance Criteria**:
- Task with "todo" status → toggle changes to "completed"
- Task with "completed" status → toggle changes to "todo"

### Implementation for US4

- [x] T029 [US4] Add toggle button to TaskItem component in frontend/components/TaskItem.tsx
- [x] T030 [US4] Implement status toggle with PATCH /api/tasks/{id}
- [x] T031 [US4] Update task status in list state after successful toggle
- [x] T032 [US4] Add loading state to toggle button during API call

**Checkpoint**: Task status toggle works. US4 independently testable.

---

## Phase 7: User Story 5 - Delete Task (Priority: P1)

**Goal**: Authenticated user can delete a task

**Independent Test**: Click delete → verify task removed from list

**Acceptance Criteria**:
- Delete clicked → DELETE request sent, task removed from list

### Implementation for US5

- [x] T033 [US5] Add delete button to TaskItem component in frontend/components/TaskItem.tsx
- [x] T034 [US5] Implement task deletion with DELETE /api/tasks/{id}
- [x] T035 [US5] Remove task from list state after successful deletion
- [x] T036 [US5] Add loading state to delete button during API call

**Checkpoint**: Task deletion works. US5 independently testable.

---

## Phase 8: User Story 6 - Logout (Priority: P2)

**Goal**: Authenticated user can log out

**Independent Test**: Click logout → verify token cleared, redirect to login

**Acceptance Criteria**:
- Logout clicked → token cleared from localStorage, redirect to /login

### Implementation for US6

- [x] T037 [US6] Add logout button to dashboard header in frontend/app/dashboard/page.tsx
- [x] T038 [US6] Implement logout logic (clear token, redirect to /login)

**Checkpoint**: Logout works. US6 independently testable.

---

## Phase 9: Polish & Documentation

**Purpose**: Final touches and documentation

- [x] T039 [P] Create README.md in frontend/ with setup and run instructions
- [x] T040 [P] Update .env.example with all required environment variables
- [x] T041 Add user-friendly styling with Tailwind CSS to all components
- [x] T042 Verify no secrets are committed (.env.local in .gitignore)
- [x] T043 Run manual integration test: register → login → create → toggle → delete → logout

**Checkpoint**: Frontend complete and documented.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup) → Phase 2 (Foundational) → User Stories (Phase 3-8) → Phase 9 (Polish)
```

- **Setup (Phase 1)**: No dependencies - start immediately
- **Foundational (Phase 2)**: Depends on Setup - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational completion
  - US1 (Auth) should complete first (enables all other stories)
  - US2-6 can proceed after US1
- **Polish (Phase 9)**: Depends on all user stories

### User Story Dependencies

| Story | Depends On | Can Start After |
|-------|------------|-----------------|
| US1 (Auth) | Foundational | Phase 2 complete |
| US2 (View List) | US1 (need to be logged in) | US1 complete |
| US3 (Create) | US2 (need list to add to) | US2 complete |
| US4 (Toggle) | US2 (need task to toggle) | US2 complete |
| US5 (Delete) | US2 (need task to delete) | US2 complete |
| US6 (Logout) | US1 (need to be logged in) | US1 complete |

### Within Each User Story

1. Component creation (if new component)
2. API integration
3. State updates
4. Error handling
5. Loading states

### Parallel Opportunities

**Phase 1 (Setup)**:
- T003, T004 can run in parallel

**Phase 2 (Foundational)**:
- T006, T008 can run in parallel after T005

**Phase 3 (US1)**:
- T010, T011 can run in parallel (different pages)

**Phase 4 (US2)**:
- T019, T020 can run in parallel (different components)

**After US2 Complete**:
- US3, US4, US5 can run in parallel (different operations on same components)
- US6 can run in parallel with US3-5

**Phase 9 (Polish)**:
- T039, T040 can run in parallel

---

## Parallel Example: After Foundational Phase

```bash
# After Phase 2, launch US1 tasks:
T010: "Create login page in frontend/app/login/page.tsx"
T011: "Create register page in frontend/app/register/page.tsx"

# After US2, these can run in parallel:
T024: "Create TaskForm component (US3)"
T029: "Add toggle button to TaskItem (US4)"
T033: "Add delete button to TaskItem (US5)"
T037: "Add logout button to dashboard (US6)"
```

---

## Implementation Strategy

### MVP First (US1 + US2 Only)

1. Complete Phase 1: Setup (4 tasks)
2. Complete Phase 2: Foundational (5 tasks)
3. Complete Phase 3: US1 - Authentication (7 tasks)
4. Complete Phase 4: US2 - View Task List (7 tasks)
5. **STOP and VALIDATE**: Can login, register, view tasks
6. Demo MVP to reviewers

### Full Implementation (All Stories)

1. MVP (above)
2. Add US3: Create Task (5 tasks)
3. Add US4: Toggle Status (4 tasks)
4. Add US5: Delete Task (4 tasks)
5. Add US6: Logout (2 tasks)
6. Phase 9: Polish (5 tasks)

---

## Task Summary

| Phase | User Story | Task Count |
|-------|------------|------------|
| 1 | Setup | 4 |
| 2 | Foundational | 5 |
| 3 | US1 (Auth) | 7 |
| 4 | US2 (View List) | 7 |
| 5 | US3 (Create) | 5 |
| 6 | US4 (Toggle) | 4 |
| 7 | US5 (Delete) | 4 |
| 8 | US6 (Logout) | 2 |
| 9 | Polish | 5 |
| **Total** | | **43 tasks** |

### Parallel Opportunities: 12 tasks marked [P]

### Suggested MVP Scope: Phase 1-4 (23 tasks)
- Users can register, login, and view their tasks
- Proves authentication and data isolation

---

## Success Criteria Mapping

| Success Criteria | Verified By |
|------------------|-------------|
| SC-001: Unauthenticated /dashboard redirects | T017 (auth check in dashboard) |
| SC-002: Login stores JWT, redirects | T012 (login submission) |
| SC-003: All API requests include Authorization | T007 (API client) |
| SC-004: User A can't see User B's tasks | T018 (backend enforces via JWT) |
| SC-005: CRUD operations persist | T043 (manual integration test) |
| SC-006: No secrets committed | T042 (verify .gitignore) |
| SC-007: README documents setup | T039 (create README) |

---

## Notes

- All tasks use `nextjs-frontend-optimizer` agent
- No tests included (per minimal scope)
- Focus on proving integration correctness, not UI polish
- Each checkpoint allows for demo/validation
- Commit after each task or logical group
- Simplified from 87 tasks (full scope) to 43 tasks (minimal scope)
