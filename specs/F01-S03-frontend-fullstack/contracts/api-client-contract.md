# API Client Contract (Minimal)

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-02-01
**Scope**: Minimal hackathon integration proof

## Overview

Frontend API client consumes backend endpoints defined in Spec 1 and Spec 2. This document specifies the client-side contract for the minimal scope.

## Base Configuration

```typescript
// Environment
const API_URL = process.env.NEXT_PUBLIC_API_URL; // Required

// Default headers
{
  'Content-Type': 'application/json'
}

// Authenticated request headers
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer <access_token>'
}
```

---

## Auth Endpoints

### POST /api/auth/login

**Request**:
```typescript
{
  email: string;
  password: string;
}
```

**Success (200)**:
```typescript
{
  user: { id: string; email: string; };
  access_token: string;
  refresh_token: string;  // Not used in minimal scope
  token_type: 'bearer';
  expires_in: number;
}
```

**Frontend Action**: Store `access_token` in localStorage.

**Errors**:
- 401: Invalid credentials → Display "Invalid email or password"

---

### POST /api/auth/register

**Request**:
```typescript
{
  email: string;
  password: string;
}
```

**Success (201)**:
```typescript
{
  user: { id: string; email: string; };
  access_token: string;
  refresh_token: string;  // Not used
  token_type: 'bearer';
  expires_in: number;
}
```

**Frontend Action**: Store `access_token` in localStorage, redirect to /dashboard.

**Errors**:
- 400: Invalid input → Display error message
- 409: Email exists → Display "Email already registered"

---

## Task Endpoints

All task endpoints require `Authorization: Bearer <token>` header.

### GET /api/tasks

**Success (200)**:
```typescript
Task[]  // Array of user's tasks
```

**Frontend Action**: Display in TaskList component.

**Errors**:
- 401: Unauthorized → Clear token, redirect to /login

---

### POST /api/tasks

**Request**:
```typescript
{
  title: string;        // required
  description?: string;
  priority?: 'low' | 'medium' | 'high';
  tags?: string[];
}
```

**Success (201)**:
```typescript
Task  // Created task with id
```

**Frontend Action**: Add to task list, clear form.

**Errors**:
- 400: Validation error → Display inline
- 401: Unauthorized → Redirect to /login

---

### PATCH /api/tasks/{id}

**Request**:
```typescript
{
  title?: string;
  status?: 'todo' | 'in-progress' | 'completed';
  priority?: 'low' | 'medium' | 'high';
}
```

**Success (200)**:
```typescript
Task  // Updated task
```

**Frontend Action**: Update task in list.

**Errors**:
- 401: Unauthorized → Redirect to /login
- 403: Not owner → Display "Access denied"
- 404: Not found → Display "Task not found"

---

### DELETE /api/tasks/{id}

**Success (204)**: No content

**Frontend Action**: Remove task from list.

**Errors**:
- 401: Unauthorized → Redirect to /login
- 403: Not owner → Display "Access denied"
- 404: Not found → Display "Task not found"

---

## Error Handling (Simplified)

| Status | Frontend Action |
|--------|-----------------|
| 401 | Clear localStorage token, redirect to /login |
| 403 | Display "Access denied" message |
| 400/422 | Display error message inline |
| 404 | Display "Not found" message |
| 5xx | Display "Service unavailable" |
| Network error | Display "Network error" |

---

## No user_id in Requests

Per spec FR-007:
- Frontend NEVER sends `user_id` parameter
- Backend extracts user identity from JWT
- All task operations scoped to authenticated user

---

## Not Implemented (Minimal Scope)

The following are NOT implemented:

- POST /api/auth/logout (token cleared client-side only)
- POST /api/auth/refresh (user re-logins on expiry)
- Token refresh retry logic
- Request queuing during refresh
