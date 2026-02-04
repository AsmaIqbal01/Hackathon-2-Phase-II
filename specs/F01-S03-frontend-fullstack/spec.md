# Feature Specification: Frontend Application & Full-Stack Integration (Minimal)

**Feature Branch**: `F01-S03-frontend-fullstack`
**Created**: 2026-01-30
**Updated**: 2026-02-01
**Status**: Draft
**Scope**: Minimal hackathon integration proof
**Input**: User description: "Minimal frontend proving secure full-stack integration"

## References

- **Spec 1**: `specs/F01-S01-backend-api-database/spec.md` — Task CRUD endpoints
- **Spec 2**: `specs/F01-S02-auth-security/spec.md` — JWT authentication endpoints

This spec does NOT restate definitions from Spec 1 or Spec 2. Refer to those for API contracts.

---

## Target Audience

- Hackathon reviewers evaluating end-to-end correctness
- Technical evaluators verifying security integration
- Developers onboarding to the repository

---

## Scope Statement

**Goal**: Demonstrate secure full-stack integration between Next.js frontend and existing FastAPI backend.

**Success is proven when**:
1. User can register and login via backend
2. Frontend attaches JWT to all API requests
3. Authenticated user can view, create, toggle, and delete tasks
4. Unauthenticated users are redirected to login
5. User A cannot see User B's tasks (data isolation)

**Explicitly NOT in scope**:
- UI polish or responsive design
- Component libraries (MUI, ShadCN, etc.)
- Advanced state management (Redux, Zustand)
- SSR/SEO optimizations
- Mobile-first layouts
- Backend modifications

---

## User Scenarios & Testing

### User Story 1 - Authentication Flow (Priority: P1)

As a visitor, I want to login or register so that I can access my tasks.

**Why this priority**: Gate to all functionality. Nothing works without auth.

**Independent Test**: Enter credentials → verify token stored → verify redirect to dashboard.

**Acceptance Scenarios**:

1. **Given** valid credentials, **When** login submitted, **Then** JWT stored in localStorage, redirect to /dashboard.

2. **Given** invalid credentials, **When** login submitted, **Then** error message displayed, no redirect.

3. **Given** new user, **When** registration completed, **Then** account created, auto-login, redirect to /dashboard.

4. **Given** already logged in user, **When** visiting /login, **Then** redirect to /dashboard.

---

### User Story 2 - View Task List (Priority: P1)

As an authenticated user, I want to see my tasks on the dashboard.

**Why this priority**: Core value proposition. Must see tasks to manage them.

**Independent Test**: Log in → navigate to dashboard → verify only user's tasks render.

**Acceptance Scenarios**:

1. **Given** authenticated user with tasks, **When** dashboard loads, **Then** tasks display with title and status visible.

2. **Given** authenticated user with no tasks, **When** dashboard loads, **Then** empty state message displays.

3. **Given** unauthenticated user, **When** navigating to /dashboard, **Then** redirect to /login.

---

### User Story 3 - Create Task (Priority: P1)

As an authenticated user, I want to create a new task.

**Why this priority**: Fundamental CRUD operation.

**Independent Test**: Submit task form → verify task appears in list.

**Acceptance Scenarios**:

1. **Given** user on dashboard, **When** submitting task with valid title, **Then** task appears in list after API success.

2. **Given** user submits empty title, **When** form validates, **Then** error displayed, no API call.

---

### User Story 4 - Toggle Task Status (Priority: P1)

As an authenticated user, I want to toggle task completion status.

**Why this priority**: Core task lifecycle management.

**Independent Test**: Click toggle → verify status changes.

**Acceptance Scenarios**:

1. **Given** task with status "todo", **When** toggle clicked, **Then** PATCH request sent, status becomes "completed".

2. **Given** task with status "completed", **When** toggle clicked, **Then** PATCH request sent, status becomes "todo".

---

### User Story 5 - Delete Task (Priority: P1)

As an authenticated user, I want to delete a task.

**Why this priority**: Essential for list management.

**Independent Test**: Click delete → verify task removed from list.

**Acceptance Scenarios**:

1. **Given** existing task, **When** delete clicked, **Then** DELETE request sent, task removed from list.

---

### User Story 6 - Logout (Priority: P2)

As an authenticated user, I want to log out.

**Why this priority**: Security requirement but not blocking core features.

**Independent Test**: Click logout → verify token cleared, redirect to login.

**Acceptance Scenarios**:

1. **Given** authenticated user, **When** logout clicked, **Then** token cleared from localStorage, redirect to /login.

---

### Edge Cases

- **Token expired during use**: 401 response → redirect to login.
- **Network failure**: Display error message, do not crash.
- **Backend unavailable (5xx)**: Display "Service unavailable" message.

---

## Requirements

### Functional Requirements

#### Authentication

- **FR-001**: System MUST store JWT in localStorage after successful login.
- **FR-002**: System MUST attach `Authorization: Bearer <token>` header to all API requests.
- **FR-003**: System MUST redirect unauthenticated users from /dashboard to /login.
- **FR-004**: System MUST redirect authenticated users from /login to /dashboard.
- **FR-005**: System MUST clear token on logout and redirect to /login.

#### API Integration

- **FR-006**: System MUST call POST /api/auth/login for login.
- **FR-007**: System MUST call POST /api/auth/register for registration.
- **FR-008**: System MUST call GET /api/tasks to list tasks.
- **FR-009**: System MUST call POST /api/tasks to create tasks.
- **FR-010**: System MUST call PATCH /api/tasks/{id} to update tasks.
- **FR-011**: System MUST call DELETE /api/tasks/{id} to delete tasks.
- **FR-012**: System MUST read API base URL from NEXT_PUBLIC_API_URL environment variable.

#### Error Handling

- **FR-013**: System MUST handle 401 by redirecting to /login.
- **FR-014**: System MUST display user-friendly error messages for API failures.
- **FR-015**: System MUST NOT display raw error objects or stack traces.

#### UI (Minimal)

- **FR-016**: System MUST display loading state during API operations.
- **FR-017**: System MUST provide basic form validation (required title).
- **FR-018**: System MUST display task title and status in list view.

---

## Success Criteria

### Measurable Outcomes

- **SC-001**: Unauthenticated access to /dashboard redirects to /login.
- **SC-002**: Login with valid credentials stores JWT and redirects to /dashboard.
- **SC-003**: All task API requests include Authorization header (verified via network inspection).
- **SC-004**: User A cannot see User B's tasks (verified by logging in as different users).
- **SC-005**: Task CRUD operations persist to backend (verified by refreshing page).
- **SC-006**: No secrets appear in committed code (verified by repository audit).
- **SC-007**: README documents setup and run steps.

---

## Assumptions

- Backend API (Spec 1) is deployed and accessible.
- Auth endpoints (Spec 2) are deployed and functional.
- JWT verification happens server-side; frontend trusts backend.
- Single browser tab is primary use case.
- Reviewer prioritizes correctness over UI sophistication.

---

## Constraints

- **Framework**: Next.js (App Router)
- **Language**: TypeScript
- **Styling**: Minimal Tailwind CSS only
- **API Client**: Native fetch only
- **State Management**: Local component state only (useState)
- **Token Storage**: localStorage (acceptable for hackathon scope)
- **Environment**: .env.local for configuration

---

## Key Entities (Frontend Types)

```typescript
interface Task {
  id: string;
  title: string;
  description?: string;
  status: 'todo' | 'in-progress' | 'completed';
  priority?: 'low' | 'medium' | 'high';
  tags?: string[];
  created_at: string;
  updated_at: string;
}

interface User {
  id: string;
  email: string;
}

interface AuthResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  token_type: string;
  expires_in: number;
}
```

---

## Project Structure (Minimal)

```
frontend/
├── app/
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Redirect to /dashboard or /login
│   ├── login/page.tsx       # Login form
│   ├── register/page.tsx    # Registration form
│   └── dashboard/page.tsx   # Task list + CRUD
├── lib/
│   ├── api.ts               # Centralized fetch with JWT
│   └── auth.ts              # Token storage helpers
├── components/
│   ├── TaskList.tsx         # Task list component
│   ├── TaskItem.tsx         # Individual task row
│   └── TaskForm.tsx         # Create task form
├── .env.local               # NEXT_PUBLIC_API_URL
└── README.md                # Setup documentation
```

---

## Out of Scope

1. Responsive design polish
2. UI component libraries
3. Advanced state management
4. Token refresh flow (page reload is acceptable for hackathon)
5. Optimistic updates
6. Dark mode
7. Internationalization
8. E2E testing
9. SSR/SSG optimizations
10. Backend modifications

---

## Termination Rules

1. **Backend unavailable**: Cannot proceed if API endpoints don't respond.
2. **Contract mismatch**: If API response differs from Spec 1/2, halt and report.
3. **Security violation**: If implementation would expose tokens insecurely, halt.

---

**Next Steps**: Run `/sp.plan` to generate the implementation plan.
