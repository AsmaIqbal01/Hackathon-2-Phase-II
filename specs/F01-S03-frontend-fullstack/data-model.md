# Data Model: Frontend Application (Minimal)

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-02-01
**Scope**: Minimal hackathon integration proof

## Frontend Types

### Task

Derived from Spec 1 Task entity.

```typescript
// lib/types.ts

export type TaskStatus = 'todo' | 'in-progress' | 'completed';
export type TaskPriority = 'low' | 'medium' | 'high';

export interface Task {
  id: string;           // UUID from backend
  title: string;        // required
  description?: string; // optional
  status: TaskStatus;   // required
  priority?: TaskPriority;
  tags?: string[];
  created_at: string;   // ISO 8601
  updated_at: string;   // ISO 8601
}

export interface CreateTaskInput {
  title: string;        // required
  description?: string;
  priority?: TaskPriority;
  tags?: string[];
}
```

### User

Derived from Spec 2 auth response.

```typescript
export interface User {
  id: string;    // UUID
  email: string;
}
```

### Auth Response

Response from login/register endpoints.

```typescript
export interface AuthResponse {
  user: User;
  access_token: string;
  refresh_token: string;  // Not used in minimal scope
  token_type: string;
  expires_in: number;
}
```

### API Error

Error response structure from backend.

```typescript
export interface ApiErrorResponse {
  error: {
    code: number | string;
    message: string;
    details?: Record<string, unknown>;
  };
}
```

---

## Component State Shapes

### Dashboard Page State

```typescript
// Local state in dashboard/page.tsx
interface DashboardState {
  tasks: Task[];
  loading: boolean;
  error: string | null;
}
```

### Task Form State

```typescript
// Local state in TaskForm.tsx
interface TaskFormState {
  title: string;
  submitting: boolean;
  error: string | null;
}
```

### Login/Register Form State

```typescript
// Local state in login/page.tsx and register/page.tsx
interface AuthFormState {
  email: string;
  password: string;
  submitting: boolean;
  error: string | null;
}
```

---

## Validation Rules (Client-side)

Minimal validation per spec FR-017.

| Field | Rule | Error Message |
|-------|------|---------------|
| `title` (task) | Required, non-empty | "Title is required" |
| `email` (auth) | Required | "Email is required" |
| `password` (auth) | Required | "Password is required" |

Note: All other validation (email format, password strength, status transitions) deferred to backend.

---

## No Local Persistence

Per minimal scope:
- Access token in localStorage (cleared on logout/401)
- No task caching
- No offline support
- No refresh token handling
