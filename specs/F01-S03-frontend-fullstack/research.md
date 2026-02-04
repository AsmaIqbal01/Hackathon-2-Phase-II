# Research: Frontend Application & Full-Stack Integration (Minimal)

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-02-01
**Status**: Complete
**Scope**: Minimal hackathon integration proof

## Research Questions

### Q1: Authentication Approach

**Decision**: Simple localStorage token storage with manual header injection.

**Rationale**:
- Minimal scope requires simplest possible solution
- localStorage is acceptable for hackathon demonstration
- No token refresh means no complex token management
- Reduces dependencies (no Better Auth SDK needed)

**Pattern**:
```typescript
// lib/auth.ts
const TOKEN_KEY = 'access_token';

export function getToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem(TOKEN_KEY);
}

export function setToken(token: string): void {
  localStorage.setItem(TOKEN_KEY, token);
}

export function clearToken(): void {
  localStorage.removeItem(TOKEN_KEY);
}
```

**Alternatives Considered**:
- Better Auth: Full-featured but adds complexity beyond minimal scope
- httpOnly cookies: More secure but requires server-side handling
- Session storage: Cleared on tab close; less convenient for demo

**Tradeoff Documented**: localStorage is vulnerable to XSS. Acceptable for hackathon; production would use httpOnly cookies.

---

### Q2: API Client Architecture

**Decision**: Single `api.ts` module with fetch wrapper.

**Rationale**:
- Native fetch sufficient for minimal scope
- No axios/tanstack-query dependencies
- Centralized JWT header injection
- Simple error handling (no retry logic)

**Pattern**:
```typescript
// lib/api.ts
const API_URL = process.env.NEXT_PUBLIC_API_URL;

export async function apiClient<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const token = getToken();

  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options.headers,
    },
  });

  if (response.status === 401) {
    clearToken();
    window.location.href = '/login';
    throw new Error('Unauthorized');
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error?.message || 'API Error');
  }

  if (response.status === 204) {
    return null as T;
  }

  return response.json();
}
```

**Alternatives Considered**:
- Axios: Adds dependency unnecessarily
- React Query/SWR: Adds caching complexity; spec excludes caching
- fetch without wrapper: Duplicates header logic across components

---

### Q3: State Management

**Decision**: Local component state only (useState).

**Rationale**:
- Spec explicitly excludes advanced state management
- Auth state can be derived from token presence
- Task list state local to dashboard page
- No cross-component state sharing needed

**Pattern**:
```typescript
// In dashboard/page.tsx
const [tasks, setTasks] = useState<Task[]>([]);
const [loading, setLoading] = useState(true);
const [error, setError] = useState<string | null>(null);

useEffect(() => {
  fetchTasks();
}, []);
```

**Alternatives Considered**:
- React Context: Overkill; no shared state needed
- Redux/Zustand: Explicitly excluded by spec
- Global variable: Anti-pattern; breaks React model

---

### Q4: Route Protection

**Decision**: Client-side check only (no middleware).

**Rationale**:
- Minimal scope; middleware adds complexity
- Dashboard page checks token on mount
- Redirect via router if not authenticated
- Simple and sufficient for demo

**Pattern**:
```typescript
// app/dashboard/page.tsx
'use client';

import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { getToken } from '@/lib/auth';

export default function DashboardPage() {
  const router = useRouter();

  useEffect(() => {
    if (!getToken()) {
      router.push('/login');
    }
  }, [router]);

  // ... rest of component
}
```

**Alternatives Considered**:
- Next.js middleware: More robust but adds complexity
- Server-side check: Requires cookie-based auth
- HOC wrapper: Adds indirection

**Tradeoff Documented**: Brief flash of content possible before redirect. Acceptable for demo.

---

### Q5: Form Validation

**Decision**: Required-field check only; defer to server for business rules.

**Rationale**:
- Spec FR-017 requires only basic validation
- Phase I rules enforced by backend
- Minimal client validation reduces code

**Pattern**:
```typescript
// In TaskForm.tsx
const [title, setTitle] = useState('');
const [error, setError] = useState<string | null>(null);

const handleSubmit = async (e: FormEvent) => {
  e.preventDefault();
  if (!title.trim()) {
    setError('Title is required');
    return;
  }
  // Submit to API
};
```

**Alternatives Considered**:
- Zod/Yup: Adds dependency; overkill for one required field
- React Hook Form: Adds complexity beyond minimal scope
- Full client validation: Duplicates Phase I logic

---

### Q6: Styling Approach

**Decision**: Tailwind CSS with inline classes; no component abstraction.

**Rationale**:
- Spec explicitly allows minimal styling
- No responsive breakpoint requirements
- Inline classes sufficient for small component count
- Functional appearance over polish

**Pattern**:
```tsx
<button
  className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
  onClick={handleClick}
>
  Submit
</button>
```

**Alternatives Considered**:
- Shadcn/UI: Explicitly excluded by spec
- CSS Modules: Adds file overhead for minimal benefit
- Separate component library: Overkill for minimal scope

---

## Technology Decisions Summary

| Area | Decision | Rationale |
|------|----------|-----------|
| Auth storage | localStorage | Simplest; acceptable for demo |
| API client | Native fetch wrapper | No dependencies; sufficient |
| State | Local useState only | Spec requirement |
| Routing | Client-side check | Minimal; no middleware |
| Validation | Required-field only | Defer to backend |
| Styling | Inline Tailwind | Functional; no polish needed |

---

## Dependencies Confirmed

From Spec 1 (Backend API):
- `GET /api/tasks` — List tasks
- `POST /api/tasks` — Create task
- `PATCH /api/tasks/{id}` — Update task
- `DELETE /api/tasks/{id}` — Delete task

From Spec 2 (Auth):
- `POST /api/auth/login` — Returns access_token
- `POST /api/auth/register` — Creates user, returns access_token

Note: refresh_token and /api/auth/refresh NOT used in minimal scope.

---

## Risks Identified

1. **XSS vulnerability with localStorage**: Documented tradeoff; acceptable for hackathon.

2. **No token refresh**: User must re-login on expiry. Document in README.

3. **CORS configuration**: Backend must allow frontend origin. Test early.

---

**Phase 0 Complete**. Proceed to implementation.
