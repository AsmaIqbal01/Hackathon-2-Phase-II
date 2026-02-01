# Data Model: Frontend Application

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-01-30

## Frontend Types

### Task

Derived from Spec 1 Task entity (FR-005, FR-006, FR-007).

```typescript
// types/task.ts
export type TaskStatus = 'todo' | 'in-progress' | 'completed';
export type TaskPriority = 'low' | 'medium' | 'high';

export interface Task {
  id: string;           // UUID from backend
  title: string;        // required, max 255 chars
  description?: string; // optional, max 5000 chars
  status: TaskStatus;   // required, default 'todo'
  priority: TaskPriority; // required, default 'medium'
  tags?: string[];      // optional
  created_at: string;   // ISO 8601
  updated_at: string;   // ISO 8601
}

export interface CreateTaskInput {
  title: string;        // required
  description?: string;
  status?: TaskStatus;
  priority?: TaskPriority;
  tags?: string[];
}

export interface UpdateTaskInput {
  title?: string;
  description?: string;
  status?: TaskStatus;
  priority?: TaskPriority;
  tags?: string[];
}
```

### User

Derived from Spec 2 JWT claims (FR-009).

```typescript
// types/user.ts
export interface User {
  id: string;    // UUID from JWT 'sub' claim
  email: string; // from JWT 'email' claim
}
```

### Auth State

Frontend auth context shape.

```typescript
// types/auth.ts
export interface AuthState {
  user: User | null;
  accessToken: string | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

export interface LoginInput {
  email: string;
  password: string;
}

export interface RegisterInput {
  email: string;
  password: string;
}

export interface AuthTokens {
  access_token: string;
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number; // seconds
}

export interface AuthResponse {
  user: User;
  access_token: string;
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number;
}
```

### API Error

Aligned with Spec 1 (FR-025) and Spec 2 (FR-030).

```typescript
// types/api.ts
export interface ApiErrorDetail {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

export interface ApiErrorResponse {
  error: ApiErrorDetail;
}

export class ApiError extends Error {
  constructor(
    public status: number,
    public code: string,
    message: string,
    public details?: Record<string, unknown>
  ) {
    super(message);
    this.name = 'ApiError';
  }
}
```

---

## State Shapes

### Auth Context State

```typescript
interface AuthContextValue {
  // State
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;

  // Actions
  login: (input: LoginInput) => Promise<void>;
  register: (input: RegisterInput) => Promise<void>;
  logout: () => Promise<void>;
  refreshToken: () => Promise<boolean>;
}
```

### Task List State (Component-local)

```typescript
interface TaskListState {
  tasks: Task[];
  isLoading: boolean;
  error: ApiError | null;
}

interface TaskFormState {
  isSubmitting: boolean;
  error: ApiError | null;
}
```

---

## Validation Rules (Client-side)

Per FR-029: inline validation before submission.

| Field | Rule | Error Message |
|-------|------|---------------|
| `title` | Required, non-empty | "Title is required" |
| `title` | Max 255 chars | "Title must be 255 characters or less" |
| `email` | Required, valid format | "Valid email is required" |
| `password` | Required, min 8 chars | "Password must be at least 8 characters" |

Note: Business rule validation (status transitions, tag uniqueness) deferred to backend (Spec 1 authority).

---

## Entity Relationships

```
User (from JWT)
  └── owns → Task[] (filtered by backend)

AuthState
  └── contains → User | null
  └── contains → accessToken | null

TaskListState
  └── contains → Task[]
```

---

## No Local Persistence

Per spec assumptions:
- No offline support required
- No local storage of tasks
- Access token in memory only
- Refresh token via httpOnly cookie (handled by Better Auth)
