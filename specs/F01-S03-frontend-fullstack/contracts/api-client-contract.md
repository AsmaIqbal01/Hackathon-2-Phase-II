# API Client Contract

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-01-30

## Overview

Frontend API client consumes backend endpoints defined in Spec 1 and Spec 2. This document specifies the client-side contract.

## Base Configuration

```typescript
// Environment
const API_URL = process.env.NEXT_PUBLIC_API_URL; // Required

// Headers (all requests)
{
  'Content-Type': 'application/json'
}

// Headers (authenticated requests)
{
  'Content-Type': 'application/json',
  'Authorization': 'Bearer <access_token>'
}
```

---

## Auth Endpoints (Spec 2 Reference)

### POST /api/auth/register

**Request**:
```typescript
{
  email: string;    // required, valid email format
  password: string; // required, min 8 chars
}
```

**Success (201)**:
```typescript
{
  user: { id: string; email: string; created_at: string; };
  access_token: string;
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number;
}
```

**Errors**:
- 400: Invalid email format or weak password
- 409: Email already registered

---

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
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number;
}
```

**Errors**:
- 401: Invalid credentials
- 429: Rate limit exceeded

---

### POST /api/auth/logout

**Headers**: `Authorization: Bearer <access_token>`

**Request**: None

**Success (204)**: No content

**Errors**:
- 401: Invalid or missing token

---

### POST /api/auth/refresh

**Request**:
```typescript
{
  refresh_token: string;
}
```

**Success (200)**:
```typescript
{
  access_token: string;
  refresh_token: string;
  token_type: 'bearer';
  expires_in: number;
}
```

**Errors**:
- 401: Invalid or expired refresh token

---

## Task Endpoints (Spec 1 Reference)

### GET /api/tasks

**Headers**: `Authorization: Bearer <access_token>`

**Success (200)**:
```typescript
Task[] // Array of tasks owned by authenticated user
```

**Errors**:
- 401: Missing or invalid token

---

### POST /api/tasks

**Headers**: `Authorization: Bearer <access_token>`

**Request**:
```typescript
{
  title: string;        // required
  description?: string;
  status?: 'todo' | 'in-progress' | 'completed';
  priority?: 'low' | 'medium' | 'high';
  tags?: string[];
}
```

**Success (201)**:
```typescript
Task // Created task with id, timestamps
```

**Errors**:
- 400: Validation error (missing title, invalid enum)
- 401: Missing or invalid token

---

### PATCH /api/tasks/{id}

**Headers**: `Authorization: Bearer <access_token>`

**Request**:
```typescript
{
  title?: string;
  description?: string;
  status?: 'todo' | 'in-progress' | 'completed';
  priority?: 'low' | 'medium' | 'high';
  tags?: string[];
}
```

**Success (200)**:
```typescript
Task // Updated task
```

**Errors**:
- 400: Validation error
- 401: Missing or invalid token
- 403: Task not owned by user
- 404: Task not found

---

### DELETE /api/tasks/{id}

**Headers**: `Authorization: Bearer <access_token>`

**Success (204)**: No content

**Errors**:
- 401: Missing or invalid token
- 403: Task not owned by user
- 404: Task not found

---

## Error Handling Contract

All errors follow this structure (per Spec 1 FR-025, Spec 2 FR-030):

```typescript
{
  error: {
    code: string;    // e.g., "VALIDATION_ERROR", "UNAUTHORIZED"
    message: string; // User-friendly message
    details?: {      // Optional field-level details
      field?: string;
      constraint?: string;
    };
  }
}
```

### Frontend Error Handling Rules

| Status | Action |
|--------|--------|
| 401 | Attempt token refresh; if fails, redirect to /login |
| 403 | Display "Access denied" inline; no redirect |
| 404 | Display "Not found" inline |
| 400 | Display validation error inline |
| 5xx | Display "Service unavailable" generic message |

---

## Request Flow

```
User Action
    ↓
Frontend validates (client-side)
    ↓
API Client attaches JWT
    ↓
Backend validates (server-side)
    ↓
Response
    ↓
  ┌─ 2xx: Update UI state
  ├─ 401: Refresh → Retry OR Redirect
  ├─ 403: Show access denied
  └─ 4xx/5xx: Show error inline
```

---

## No user_id in Requests

Per spec FR-007 and constitution principle IV:
- Frontend NEVER sends `user_id` parameter
- Backend extracts user identity from JWT
- This contract enforces that constraint
