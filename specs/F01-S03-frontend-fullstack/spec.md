# Feature Specification: Frontend Application & Full-Stack Integration

**Feature Branch**: `F01-S03-frontend-fullstack`
**Created**: 2026-01-30
**Status**: Draft
**Input**: User description: "Frontend Application & Full-Stack Integration (Next.js)"

## References

- **Spec 1**: `specs/F01-S01-backend-api-database/spec.md` — API contract, task entity, error responses
- **Spec 2**: `specs/F01-S02-auth-security/spec.md` — JWT structure, auth endpoints, token management

This spec does NOT restate definitions from Spec 1 or Spec 2. Refer to those documents for:
- Task CRUD endpoints and schemas (Spec 1: FR-001 to FR-033)
- JWT claims and token lifecycle (Spec 2: FR-006 to FR-016)
- Auth endpoints (Spec 2: FR-025 to FR-029)
- Error response structure (Spec 1: FR-025, Spec 2: FR-030)

---

## User Scenarios & Testing

### User Story 1 - Authenticated Task List View (Priority: P1)

As an authenticated user, I want to see my tasks on the dashboard so that I can manage my work.

**Why this priority**: Core value proposition. Without viewing tasks, no task management is possible.

**Independent Test**: Log in → navigate to dashboard → verify only authenticated user's tasks render.

**Acceptance Scenarios**:

1. **Given** authenticated user with 3 tasks, **When** dashboard loads, **Then** exactly 3 tasks display with title, status, priority visible.

2. **Given** authenticated user with 0 tasks, **When** dashboard loads, **Then** empty state message displays with prompt to create first task.

3. **Given** unauthenticated user, **When** navigating to dashboard URL, **Then** redirect to login page occurs immediately.

---

### User Story 2 - Task Creation (Priority: P1)

As an authenticated user, I want to create a new task so that I can track work items.

**Why this priority**: Creation is fundamental to todo app utility.

**Independent Test**: Open create form → submit valid data → verify task appears in list.

**Acceptance Scenarios**:

1. **Given** user on dashboard, **When** submitting task with valid title, **Then** task persists to backend and appears in list without page reload.

2. **Given** user submits empty title, **When** form validates, **Then** inline error displays before API call.

3. **Given** backend returns 400, **When** response received, **Then** error message displays matching backend error structure.

---

### User Story 3 - Task Update (Priority: P1)

As an authenticated user, I want to update task details so that I can refine or change status.

**Why this priority**: Task lifecycle management requires updates.

**Independent Test**: Click task → modify fields → save → verify changes persist.

**Acceptance Scenarios**:

1. **Given** existing task, **When** user changes status to "completed", **Then** PATCH request sent with only changed field, UI reflects update.

2. **Given** update fails with 403, **When** response received, **Then** access denied message displays, original state preserved.

---

### User Story 4 - Task Deletion (Priority: P2)

As an authenticated user, I want to delete tasks so that I can remove completed or irrelevant items.

**Why this priority**: Essential for list hygiene but not blocking core use.

**Independent Test**: Click delete → confirm → verify task removed from list.

**Acceptance Scenarios**:

1. **Given** existing task, **When** user confirms deletion, **Then** DELETE request sent, task removed from UI on success.

2. **Given** delete confirmation dialog open, **When** user cancels, **Then** no API call made, task remains.

---

### User Story 5 - Authentication Flow (Priority: P1)

As a visitor, I want to log in or register so that I can access my tasks.

**Why this priority**: Gate to all functionality.

**Independent Test**: Visit login → enter credentials → verify redirect to dashboard with tokens stored.

**Acceptance Scenarios**:

1. **Given** valid credentials, **When** login submitted, **Then** tokens stored, redirect to dashboard, user context available.

2. **Given** invalid credentials, **When** login submitted, **Then** 401 handled, generic error displayed ("Invalid credentials").

3. **Given** new user, **When** registration completed, **Then** account created, auto-login, redirect to dashboard.

4. **Given** registration with existing email, **When** submitted, **Then** 409 handled, error displayed ("Email already registered").

---

### User Story 6 - Session Persistence (Priority: P1)

As an authenticated user, I want my session to persist across page refreshes so that I don't re-login constantly.

**Why this priority**: UX critical; without this, app is unusable.

**Independent Test**: Log in → refresh page → verify still authenticated.

**Acceptance Scenarios**:

1. **Given** valid session, **When** page refreshes, **Then** user remains authenticated, dashboard loads.

2. **Given** expired access token with valid refresh token, **When** API call made, **Then** token refreshed transparently, request succeeds.

3. **Given** both tokens expired, **When** any protected action attempted, **Then** redirect to login with "Session expired" message.

---

### User Story 7 - Logout (Priority: P2)

As an authenticated user, I want to log out so that I can end my session.

**Why this priority**: Security requirement but not blocking core task management.

**Independent Test**: Click logout → verify tokens cleared, redirect to login.

**Acceptance Scenarios**:

1. **Given** authenticated user, **When** logout clicked, **Then** logout API called, tokens cleared, redirect to login.

---

### Edge Cases

- **Token expiry during form submission**: Request fails with 401 → attempt refresh → retry original request OR redirect to login if refresh fails.
- **Network failure**: Display offline indicator, disable submit buttons, queue no requests.
- **Concurrent tab sessions**: Each tab manages its own token state; logout in one tab does not affect others until next API call.
- **Backend unavailable (5xx)**: Display generic "Service unavailable" message, no sensitive error details.
- **Malformed API response**: Log error, display generic failure message, do not crash UI.

---

## Requirements

### Functional Requirements

#### Routing & Navigation

- **FR-001**: System MUST implement protected routes that redirect unauthenticated users to `/login`.
- **FR-002**: System MUST redirect authenticated users from `/login` and `/signup` to `/dashboard`.
- **FR-003**: System MUST provide persistent navigation between dashboard and logout.

#### API Client

- **FR-004**: System MUST implement a single API client module for all backend requests.
- **FR-005**: System MUST attach `Authorization: Bearer <access_token>` header to all protected requests.
- **FR-006**: System MUST read `NEXT_PUBLIC_API_URL` from environment for backend base URL.
- **FR-007**: System MUST NOT send `user_id` as request parameter; backend extracts from JWT (per Spec 2: FR-017).

#### Authentication Integration

- **FR-008**: System MUST call `POST /api/auth/login` for login (per Spec 2: FR-026).
- **FR-009**: System MUST call `POST /api/auth/register` for registration (per Spec 2: FR-025).
- **FR-010**: System MUST call `POST /api/auth/logout` for logout (per Spec 2: FR-027).
- **FR-011**: System MUST call `POST /api/auth/refresh` when access token expires (per Spec 2: FR-028).
- **FR-012**: System MUST store access token in memory (not localStorage) per Spec 2 security guidance.
- **FR-013**: System MUST store refresh token in httpOnly cookie OR secure storage mechanism.

#### Task Operations Integration

- **FR-014**: System MUST call `GET /api/tasks` to list tasks (per Spec 1: FR-011).
- **FR-015**: System MUST call `POST /api/tasks` to create tasks (per Spec 1: FR-005).
- **FR-016**: System MUST call `PATCH /api/tasks/{id}` to update tasks (per Spec 1: FR-016).
- **FR-017**: System MUST call `DELETE /api/tasks/{id}` to delete tasks (per Spec 1: FR-020).

#### Error Handling

- **FR-018**: System MUST handle 401 by attempting token refresh; if refresh fails, redirect to login.
- **FR-019**: System MUST handle 403 by displaying "Access denied" message without redirect.
- **FR-020**: System MUST handle 404 by displaying "Not found" message.
- **FR-021**: System MUST handle 5xx by displaying generic "Service unavailable" message.
- **FR-022**: System MUST NOT display raw error objects, stack traces, or backend internals to users.

#### State Management

- **FR-023**: System MUST track loading state for all async operations.
- **FR-024**: System MUST track error state per operation (not global).
- **FR-025**: System MUST provide user context (id, email) to authenticated components.
- **FR-026**: System MUST NOT use optimistic updates; reflect backend state only after confirmation.

#### UI/UX

- **FR-027**: System MUST be responsive across mobile (320px), tablet (768px), desktop (1024px+).
- **FR-028**: System MUST display loading indicators during API operations.
- **FR-029**: System MUST display inline validation errors before form submission where applicable.
- **FR-030**: System MUST provide confirmation dialog before destructive actions (delete).

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: Unauthenticated access to `/dashboard` redirects to `/login` within 100ms.
- **SC-002**: Authenticated user sees task list within 2 seconds of dashboard load.
- **SC-003**: Task CRUD operations reflect backend state accurately (no stale data after operation completes).
- **SC-004**: 401 responses trigger automatic token refresh; user not interrupted if refresh succeeds.
- **SC-005**: 403 responses display access denied; user not redirected or logged out.
- **SC-006**: All forms validate required fields before API submission.
- **SC-007**: Application renders correctly at 320px, 768px, and 1024px widths.
- **SC-008**: No `user_id` parameter appears in any frontend-initiated request (verified via network inspection).

---

## Assumptions

- Backend (Spec 1) is deployed and accessible at `NEXT_PUBLIC_API_URL`.
- Auth endpoints (Spec 2) are deployed and functional.
- JWT verification and user_id extraction happen server-side (frontend trusts backend for user scoping).
- Single browser tab is primary use case; multi-tab sync not required.
- No offline support required.

---

## Dependencies

- **Spec 1**: Backend API endpoints for task CRUD.
- **Spec 2**: Auth endpoints for login, register, logout, refresh.
- **Environment**: `NEXT_PUBLIC_API_URL` configured.
- **Stack**: Next.js 16+, TypeScript, Tailwind CSS.

---

## Out of Scope

1. **Backend logic** — Covered in Spec 1.
2. **Auth token issuance** — Covered in Spec 2.
3. **UI animations or branding** — Visual polish deferred.
4. **SSR/SSG optimizations** — Performance tuning deferred.
5. **Caching or offline support** — Future enhancement.
6. **Accessibility audit (WCAG)** — Separate concern.
7. **Task filtering/sorting UI** — Can use Spec 1 query params but UI not mandated here.
8. **Dark mode** — Visual feature, not integration spec.
9. **Internationalization (i18n)** — English only.
10. **E2E testing** — Unless explicitly requested.

---

## Key Entities

Frontend-specific data structures (derived from Spec 1 and Spec 2):

### Task (Frontend Type)

```typescript
interface Task {
  id: string;           // UUID from backend
  title: string;        // max 255 chars
  description?: string; // max 5000 chars
  status: 'todo' | 'in-progress' | 'completed';
  priority: 'low' | 'medium' | 'high';
  tags?: string[];
  created_at: string;   // ISO 8601
  updated_at: string;   // ISO 8601
}
```

### User (Frontend Type)

```typescript
interface User {
  id: string;           // UUID from JWT sub claim
  email: string;        // From JWT email claim
}
```

### AuthState (Frontend Type)

```typescript
interface AuthState {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}
```

---

## Project Structure (Reference)

```
frontend/
├── app/
│   ├── layout.tsx           # Root layout with auth provider
│   ├── page.tsx             # Landing/redirect logic
│   ├── login/page.tsx       # Login form
│   ├── signup/page.tsx      # Registration form
│   └── dashboard/
│       ├── layout.tsx       # Protected layout
│       └── page.tsx         # Task list + CRUD
├── components/
│   ├── auth/                # LoginForm, SignupForm
│   ├── tasks/               # TaskList, TaskItem, TaskForm
│   └── ui/                  # Button, Input, Modal, etc.
├── lib/
│   ├── api-client.ts        # Centralized fetch with JWT
│   ├── auth-context.tsx     # Auth state provider
│   └── types.ts             # TypeScript interfaces
└── .env.local               # NEXT_PUBLIC_API_URL
```

---

## Termination Rules

1. **Contract violation**: If frontend behavior contradicts Spec 1 or Spec 2, halt implementation and report inconsistency.
2. **Missing endpoint**: If required endpoint not available in Spec 1/2, halt and clarify before proceeding.
3. **Security violation**: If implementation would expose `user_id` in request params or trust client-provided user identity, halt immediately.

---

**Next Steps**: Run `/sp.plan` to generate the implementation plan for this specification.
