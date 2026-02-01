# Tasks: Frontend Application & Full-Stack Integration

**Input**: Design documents from `/specs/F01-S03-frontend-fullstack/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/api-client-contract.md

**Tests**: Not requested in specification (constitution check: TDD DEFERRED)

**Organization**: Tasks grouped by user story for independent implementation and testing.

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1-US7)
- Paths use `frontend/` prefix per plan.md structure

---

## Phase 1: Setup (Project Initialization)

**Purpose**: Initialize Next.js project with required dependencies and configuration

- [ ] T001 Initialize Next.js 16+ project with App Router in frontend/ directory
- [ ] T002 Configure TypeScript with strict mode in frontend/tsconfig.json
- [ ] T003 [P] Install and configure Tailwind CSS in frontend/tailwind.config.ts
- [ ] T004 [P] Create .env.example with NEXT_PUBLIC_API_URL in frontend/.env.example
- [ ] T005 [P] Create .gitignore for Next.js project in frontend/.gitignore

---

## Phase 2: Foundational (Core Infrastructure)

**Purpose**: Shared modules required by ALL user stories - MUST complete before any story

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Type Definitions

- [ ] T006 [P] Create Task, TaskStatus, TaskPriority types in frontend/lib/types.ts
- [ ] T007 [P] Create User, AuthState, AuthTokens types in frontend/lib/types.ts
- [ ] T008 [P] Create ApiError, ApiErrorResponse types in frontend/lib/types.ts
- [ ] T009 [P] Create CreateTaskInput, UpdateTaskInput types in frontend/lib/types.ts
- [ ] T010 [P] Create LoginInput, RegisterInput, AuthResponse types in frontend/lib/types.ts

### API Client (FR-004 to FR-007)

- [ ] T011 Create base apiClient function with JWT header injection in frontend/lib/api-client.ts
- [ ] T012 Implement 401 handling with token refresh retry in frontend/lib/api-client.ts
- [ ] T013 Implement error response parsing (400, 403, 404, 5xx) in frontend/lib/api-client.ts

### UI Components

- [ ] T014 [P] Create Button component with loading state in frontend/components/ui/Button.tsx
- [ ] T015 [P] Create Input component with error display in frontend/components/ui/Input.tsx
- [ ] T016 [P] Create Spinner component for loading indicators in frontend/components/ui/Spinner.tsx
- [ ] T017 [P] Create Modal component for dialogs in frontend/components/ui/Modal.tsx

### App Shell

- [ ] T018 Create root layout with metadata in frontend/app/layout.tsx
- [ ] T019 Create landing page with redirect logic in frontend/app/page.tsx

**Checkpoint**: Foundation ready - user story implementation can begin

---

## Phase 3: User Story 5 - Authentication Flow (Priority: P1) 🎯 MVP

**Goal**: Enable visitors to log in or register to access tasks

**Independent Test**: Visit /login → enter credentials → verify redirect to dashboard with tokens stored

**Rationale**: Authentication is gate to all functionality; must complete first

### Auth Context (FR-008 to FR-013)

- [ ] T020 [US5] Create AuthContext with initial state in frontend/lib/auth-context.tsx
- [ ] T021 [US5] Implement login action calling POST /api/auth/login in frontend/lib/auth-context.tsx
- [ ] T022 [US5] Implement register action calling POST /api/auth/register in frontend/lib/auth-context.tsx
- [ ] T023 [US5] Implement logout action calling POST /api/auth/logout in frontend/lib/auth-context.tsx
- [ ] T024 [US5] Implement refreshToken action calling POST /api/auth/refresh in frontend/lib/auth-context.tsx
- [ ] T025 [US5] Store access token in memory (not localStorage) in frontend/lib/auth-context.tsx
- [ ] T026 [US5] Wrap root layout with AuthProvider in frontend/app/layout.tsx

### Auth Pages

- [ ] T027 [P] [US5] Create LoginForm component with email/password inputs in frontend/components/auth/LoginForm.tsx
- [ ] T028 [P] [US5] Create SignupForm component with email/password inputs in frontend/components/auth/SignupForm.tsx
- [ ] T029 [US5] Implement client-side validation (email format, password min 8 chars) in frontend/components/auth/LoginForm.tsx
- [ ] T030 [US5] Implement client-side validation for signup form in frontend/components/auth/SignupForm.tsx
- [ ] T031 [US5] Create login page using LoginForm in frontend/app/login/page.tsx
- [ ] T032 [US5] Create signup page using SignupForm in frontend/app/signup/page.tsx
- [ ] T033 [US5] Handle 401, 409, 429 error responses with user-friendly messages in auth forms

**Checkpoint**: Users can register and log in; tokens stored in memory

---

## Phase 4: User Story 6 - Session Persistence (Priority: P1)

**Goal**: Session persists across page refreshes without re-login

**Independent Test**: Log in → refresh page → verify still authenticated

**Depends On**: US5 (auth context exists)

### Route Protection (FR-001 to FR-003)

- [ ] T034 [US6] Create middleware.ts for server-side route protection in frontend/middleware.ts
- [ ] T035 [US6] Implement redirect to /login for unauthenticated /dashboard access in frontend/middleware.ts
- [ ] T036 [US6] Implement redirect to /dashboard for authenticated /login and /signup access in frontend/middleware.ts
- [ ] T037 [US6] Create protected dashboard layout in frontend/app/dashboard/layout.tsx
- [ ] T038 [US6] Add client-side auth check fallback in dashboard layout in frontend/app/dashboard/layout.tsx

### Session Hydration

- [ ] T039 [US6] Implement session hydration on mount (check for existing refresh token) in frontend/lib/auth-context.tsx
- [ ] T040 [US6] Handle expired tokens with automatic refresh on page load in frontend/lib/auth-context.tsx
- [ ] T041 [US6] Display "Session expired" message when both tokens invalid in frontend/lib/auth-context.tsx

**Checkpoint**: Session persists across refreshes; protected routes enforce auth

---

## Phase 5: User Story 1 - Authenticated Task List View (Priority: P1)

**Goal**: Authenticated users see their tasks on the dashboard

**Independent Test**: Log in → navigate to dashboard → verify only authenticated user's tasks render

**Depends On**: US5, US6 (auth and session persistence)

### Task Components

- [ ] T042 [P] [US1] Create TaskItem component displaying title, status, priority in frontend/components/tasks/TaskItem.tsx
- [ ] T043 [US1] Create TaskList component with loading, error, empty states in frontend/components/tasks/TaskList.tsx
- [ ] T044 [US1] Implement fetchTasks using GET /api/tasks in frontend/components/tasks/TaskList.tsx
- [ ] T045 [US1] Display empty state with "Create your first task" prompt in frontend/components/tasks/TaskList.tsx

### Dashboard Page (FR-014)

- [ ] T046 [US1] Create dashboard page with TaskList in frontend/app/dashboard/page.tsx
- [ ] T047 [US1] Implement loading spinner during task fetch in frontend/app/dashboard/page.tsx
- [ ] T048 [US1] Handle API errors (display inline message) in frontend/app/dashboard/page.tsx

**Checkpoint**: Authenticated users see their task list on dashboard

---

## Phase 6: User Story 2 - Task Creation (Priority: P1)

**Goal**: Authenticated users can create new tasks

**Independent Test**: Open create form → submit valid data → verify task appears in list

**Depends On**: US1 (task list exists to show created tasks)

### Task Form

- [ ] T049 [US2] Create TaskForm component for task creation in frontend/components/tasks/TaskForm.tsx
- [ ] T050 [US2] Implement title validation (required, max 255 chars) in frontend/components/tasks/TaskForm.tsx
- [ ] T051 [US2] Add optional description, status, priority, tags fields in frontend/components/tasks/TaskForm.tsx
- [ ] T052 [US2] Implement form submission calling POST /api/tasks in frontend/components/tasks/TaskForm.tsx
- [ ] T053 [US2] Display inline validation errors before API call in frontend/components/tasks/TaskForm.tsx
- [ ] T054 [US2] Display backend error messages (400 responses) in frontend/components/tasks/TaskForm.tsx

### Integration

- [ ] T055 [US2] Add "Create Task" button to dashboard page in frontend/app/dashboard/page.tsx
- [ ] T056 [US2] Show TaskForm in modal when Create button clicked in frontend/app/dashboard/page.tsx
- [ ] T057 [US2] Refresh task list after successful creation (no page reload) in frontend/app/dashboard/page.tsx

**Checkpoint**: Users can create tasks; new tasks appear in list

---

## Phase 7: User Story 3 - Task Update (Priority: P1)

**Goal**: Authenticated users can update task details and status

**Independent Test**: Click task → modify fields → save → verify changes persist

**Depends On**: US1 (task list), US2 (task form component reusable)

### Edit Functionality

- [ ] T058 [US3] Extend TaskForm to support edit mode with pre-filled values in frontend/components/tasks/TaskForm.tsx
- [ ] T059 [US3] Implement PATCH /api/tasks/{id} call with only changed fields in frontend/components/tasks/TaskForm.tsx
- [ ] T060 [US3] Add click handler to TaskItem for edit action in frontend/components/tasks/TaskItem.tsx
- [ ] T061 [US3] Handle 403 (access denied) response with inline error in frontend/components/tasks/TaskForm.tsx
- [ ] T062 [US3] Preserve original state on failed update in frontend/components/tasks/TaskForm.tsx

### Integration

- [ ] T063 [US3] Open TaskForm in edit mode when task clicked in frontend/app/dashboard/page.tsx
- [ ] T064 [US3] Update task in list after successful PATCH (no page reload) in frontend/app/dashboard/page.tsx

**Checkpoint**: Users can edit tasks; changes persist to backend

---

## Phase 8: User Story 4 - Task Deletion (Priority: P2)

**Goal**: Authenticated users can delete tasks with confirmation

**Independent Test**: Click delete → confirm → verify task removed from list

**Depends On**: US1 (task list exists)

### Delete Functionality

- [ ] T065 [P] [US4] Create DeleteConfirm modal component in frontend/components/tasks/DeleteConfirm.tsx
- [ ] T066 [US4] Implement DELETE /api/tasks/{id} call in delete confirmation in frontend/components/tasks/DeleteConfirm.tsx
- [ ] T067 [US4] Add delete button to TaskItem component in frontend/components/tasks/TaskItem.tsx
- [ ] T068 [US4] Handle 403 (access denied) response in frontend/components/tasks/DeleteConfirm.tsx
- [ ] T069 [US4] Handle 404 (not found) response in frontend/components/tasks/DeleteConfirm.tsx

### Integration

- [ ] T070 [US4] Show DeleteConfirm modal when delete button clicked in frontend/app/dashboard/page.tsx
- [ ] T071 [US4] Remove task from list on successful deletion (no page reload) in frontend/app/dashboard/page.tsx
- [ ] T072 [US4] Close modal without action when user cancels in frontend/app/dashboard/page.tsx

**Checkpoint**: Users can delete tasks with confirmation

---

## Phase 9: User Story 7 - Logout (Priority: P2)

**Goal**: Authenticated users can end their session

**Independent Test**: Click logout → verify tokens cleared, redirect to login

**Depends On**: US5 (auth context with logout action)

### Logout UI

- [ ] T073 [US7] Add logout button to dashboard layout navigation in frontend/app/dashboard/layout.tsx
- [ ] T074 [US7] Call logout action on button click in frontend/app/dashboard/layout.tsx
- [ ] T075 [US7] Clear tokens and redirect to /login after logout in frontend/lib/auth-context.tsx

**Checkpoint**: Users can log out; session ends properly

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Responsive design, final UI polish, validation

### Responsive Design (FR-027)

- [ ] T076 [P] Apply responsive Tailwind classes to LoginForm (320px, 768px, 1024px) in frontend/components/auth/LoginForm.tsx
- [ ] T077 [P] Apply responsive Tailwind classes to SignupForm in frontend/components/auth/SignupForm.tsx
- [ ] T078 [P] Apply responsive Tailwind classes to TaskList in frontend/components/tasks/TaskList.tsx
- [ ] T079 [P] Apply responsive Tailwind classes to TaskItem in frontend/components/tasks/TaskItem.tsx
- [ ] T080 [P] Apply responsive Tailwind classes to TaskForm in frontend/components/tasks/TaskForm.tsx
- [ ] T081 [P] Apply responsive Tailwind classes to dashboard layout in frontend/app/dashboard/layout.tsx

### Loading States (FR-028)

- [ ] T082 Ensure all async operations display Spinner component in all form/list components
- [ ] T083 Disable submit buttons during API operations in all form components

### Final Validation

- [ ] T084 Verify no user_id parameter in any API request (SC-008) via network inspection
- [ ] T085 Verify redirect timing <100ms for unauthenticated dashboard access (SC-001)
- [ ] T086 Verify task list loads within 2 seconds (SC-002)
- [ ] T087 Run quickstart.md validation steps

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (Setup)
    ↓
Phase 2 (Foundational) ← BLOCKS all user stories
    ↓
Phase 3 (US5: Auth) ← Gate to all functionality
    ↓
Phase 4 (US6: Session) ← Required for protected routes
    ↓
Phase 5 (US1: Task List) ← Core view
    ↓
Phase 6 (US2: Create) ← Depends on US1 for display
    ↓
Phase 7 (US3: Update) ← Depends on US1, reuses US2 form
    ↓
Phase 8 (US4: Delete) ← Depends on US1
    ↓
Phase 9 (US7: Logout) ← Uses US5 auth context
    ↓
Phase 10 (Polish) ← All stories complete
```

### User Story Dependencies

| Story | Priority | Depends On | Can Parallelize After |
|-------|----------|------------|----------------------|
| US5 (Auth) | P1 | Foundational | Foundational complete |
| US6 (Session) | P1 | US5 | US5 complete |
| US1 (List) | P1 | US5, US6 | US6 complete |
| US2 (Create) | P1 | US1 | US1 complete |
| US3 (Update) | P1 | US1, US2 | US2 complete |
| US4 (Delete) | P2 | US1 | US1 complete (parallel with US2, US3) |
| US7 (Logout) | P2 | US5 | US5 complete (parallel with US6+) |

### Parallel Opportunities

**Within Phase 2 (Foundational)**:
```
T006, T007, T008, T009, T010 (types) - all parallel
T014, T015, T016, T017 (UI components) - all parallel
```

**Within Phase 3 (US5)**:
```
T027, T028 (LoginForm, SignupForm) - parallel
```

**After US1 Complete**:
```
US2 (Create), US4 (Delete), US7 (Logout) can start in parallel
```

**Within Phase 10 (Polish)**:
```
T076, T077, T078, T079, T080, T081 (responsive) - all parallel
```

---

## Parallel Example: Foundational Phase

```bash
# Launch all type definition tasks in parallel:
Task: "Create Task, TaskStatus, TaskPriority types in frontend/lib/types.ts"
Task: "Create User, AuthState, AuthTokens types in frontend/lib/types.ts"
Task: "Create ApiError, ApiErrorResponse types in frontend/lib/types.ts"

# Launch all UI component tasks in parallel:
Task: "Create Button component with loading state in frontend/components/ui/Button.tsx"
Task: "Create Input component with error display in frontend/components/ui/Input.tsx"
Task: "Create Spinner component for loading indicators in frontend/components/ui/Spinner.tsx"
Task: "Create Modal component for dialogs in frontend/components/ui/Modal.tsx"
```

---

## Implementation Strategy

### MVP First (Auth + Task List)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: US5 (Auth Flow)
4. Complete Phase 4: US6 (Session Persistence)
5. Complete Phase 5: US1 (Task List View)
6. **STOP and VALIDATE**: User can log in, see tasks
7. Deploy/demo if ready

### Full Feature Delivery

1. MVP (above)
2. Add Phase 6: US2 (Create) → Test independently
3. Add Phase 7: US3 (Update) → Test independently
4. Add Phase 8: US4 (Delete) → Test independently
5. Add Phase 9: US7 (Logout) → Test independently
6. Complete Phase 10: Polish → Final validation

---

## Summary

| Category | Count |
|----------|-------|
| **Total Tasks** | 87 |
| Setup (Phase 1) | 5 |
| Foundational (Phase 2) | 14 |
| US5 Auth (Phase 3) | 14 |
| US6 Session (Phase 4) | 8 |
| US1 List (Phase 5) | 7 |
| US2 Create (Phase 6) | 9 |
| US3 Update (Phase 7) | 7 |
| US4 Delete (Phase 8) | 8 |
| US7 Logout (Phase 9) | 3 |
| Polish (Phase 10) | 12 |

**Parallel Opportunities**: 25+ tasks can run in parallel within their phases

**MVP Scope**: Phases 1-5 (US5, US6, US1) = 48 tasks

**Agent**: All tasks → `nextjs-frontend-optimizer`
