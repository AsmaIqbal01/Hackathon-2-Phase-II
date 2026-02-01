# Research: Frontend Application & Full-Stack Integration

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-01-30
**Status**: Complete

## Research Questions

### Q1: Better Auth Integration Pattern

**Decision**: Use Better Auth's React SDK with Next.js App Router.

**Rationale**:
- Better Auth provides official Next.js adapter
- Handles token storage (memory for access, httpOnly cookie for refresh)
- Built-in session management compatible with App Router
- Reduces custom auth code

**Alternatives Considered**:
- Custom JWT handling: More control but duplicates existing solution
- NextAuth.js: Mature but heavier; Better Auth specified in project constitution

---

### Q2: API Client Architecture

**Decision**: Single `api-client.ts` module with automatic token injection and refresh.

**Rationale**:
- Centralized error handling (401 → refresh → retry)
- Single point of JWT header injection
- Consistent response parsing
- Testable in isolation

**Pattern**:
```typescript
// lib/api-client.ts
export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<T> {
  const token = getAccessToken();
  const response = await fetch(`${API_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
      ...options?.headers,
    },
  });

  if (response.status === 401) {
    // Attempt refresh, retry, or redirect to login
  }

  if (!response.ok) {
    throw new ApiError(response.status, await response.json());
  }

  return response.json();
}
```

**Alternatives Considered**:
- Axios: Adds dependency; fetch is sufficient for this scope
- React Query: Adds caching complexity; spec excludes caching
- SWR: Same as React Query

---

### Q3: State Management Approach

**Decision**: React Context for auth state; local component state for UI.

**Rationale**:
- Auth state needed globally (user, token, isAuthenticated)
- Task state local to dashboard (no cross-page sharing needed)
- Spec explicitly excludes optimistic updates
- Avoids Redux/Zustand overhead for simple state

**Pattern**:
```typescript
// lib/auth-context.tsx
const AuthContext = createContext<AuthState>(null);

export function AuthProvider({ children }) {
  const [state, setState] = useState<AuthState>(initialState);
  // Token refresh, user hydration on mount
  return <AuthContext.Provider value={state}>{children}</AuthContext.Provider>;
}
```

**Alternatives Considered**:
- Redux: Overkill; spec has no complex state flows
- Zustand: Simpler than Redux but still adds dependency
- Jotai/Recoil: Atomic state unnecessary for this scope

---

### Q4: Protected Route Implementation

**Decision**: Middleware + client-side check hybrid.

**Rationale**:
- Middleware provides server-side redirect (fast)
- Client-side check provides fallback for edge cases
- Spec requires immediate redirect (<100ms)

**Pattern**:
```typescript
// middleware.ts
export function middleware(request: NextRequest) {
  const token = request.cookies.get('refresh_token');
  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}

// app/dashboard/layout.tsx
export default function DashboardLayout({ children }) {
  const { isAuthenticated, isLoading } = useAuth();
  if (isLoading) return <LoadingSpinner />;
  if (!isAuthenticated) redirect('/login');
  return children;
}
```

**Alternatives Considered**:
- Server-only (middleware): Misses client-side token expiry
- Client-only (useEffect): Slower; shows protected content briefly

---

### Q5: Error Handling Strategy

**Decision**: Centralized error boundary + per-operation error state.

**Rationale**:
- Global boundary catches unexpected crashes
- Per-operation state enables inline error display (spec FR-024)
- No silent failures (spec FR-026)

**Pattern**:
```typescript
// Per-operation pattern
const [error, setError] = useState<ApiError | null>(null);
const [loading, setLoading] = useState(false);

async function createTask(data) {
  setLoading(true);
  setError(null);
  try {
    await apiClient('/tasks', { method: 'POST', body: JSON.stringify(data) });
  } catch (e) {
    setError(e);
  } finally {
    setLoading(false);
  }
}
```

**Alternatives Considered**:
- Toast notifications only: Misses persistent error display requirement
- Global error state: Overwrites errors from concurrent operations

---

### Q6: Form Validation Approach

**Decision**: Client-side validation before submit; server response as source of truth.

**Rationale**:
- Spec FR-029 requires inline validation before submission
- Server validation is authoritative (Phase I rules)
- No optimistic updates means we wait for server confirmation

**Pattern**:
- Required field check: client-side (immediate feedback)
- Business rule validation: server-side (authoritative)
- Display server errors inline after submission failure

**Alternatives Considered**:
- Server-only: Poor UX; users must submit to see basic errors
- Full client-side replication: Duplicates Phase I logic; violates constitution

---

### Q7: Responsive Design Breakpoints

**Decision**: Use Tailwind defaults with mobile-first approach.

**Rationale**:
- Spec requires 320px, 768px, 1024px support
- Tailwind breakpoints: sm:640px, md:768px, lg:1024px
- Mobile-first aligns with spec order

**Pattern**:
```tsx
<div className="w-full md:w-1/2 lg:w-1/3">
  {/* Mobile: full width, tablet: half, desktop: third */}
</div>
```

**Alternatives Considered**:
- Custom breakpoints: Adds complexity; Tailwind defaults sufficient
- CSS-in-JS: Adds dependency; Tailwind already in stack

---

## Technology Decisions Summary

| Area | Decision | Rationale |
|------|----------|-----------|
| Auth | Better Auth React SDK | Official Next.js support, handles tokens |
| API | Custom fetch client | Minimal, centralized, testable |
| State | React Context + local | Simplest for scope |
| Routing | Middleware + client hybrid | Fast + reliable |
| Errors | Per-operation state | Inline display per spec |
| Forms | Client + server validation | UX + authority balance |
| CSS | Tailwind mobile-first | Spec breakpoints covered |

---

## Dependencies Confirmed

From Spec 1 (Backend API):
- `GET /api/tasks` — List tasks (FR-011)
- `POST /api/tasks` — Create task (FR-005)
- `PATCH /api/tasks/{id}` — Update task (FR-016)
- `DELETE /api/tasks/{id}` — Delete task (FR-020)
- Error format: `{"error": {"code": "...", "message": "..."}}`

From Spec 2 (Auth):
- `POST /api/auth/login` — Returns access_token, refresh_token (FR-026)
- `POST /api/auth/register` — Creates user, returns tokens (FR-025)
- `POST /api/auth/logout` — Invalidates tokens (FR-027)
- `POST /api/auth/refresh` — Renews access_token (FR-028)
- JWT claims: `sub` (user_id), `email`, `exp`

---

## Risks Identified

1. **Token refresh race condition**: Multiple concurrent requests during refresh could cause issues.
   - Mitigation: Queue requests during refresh; retry after new token obtained.

2. **Better Auth version compatibility**: Next.js 16+ is recent.
   - Mitigation: Pin version; test during implementation.

3. **Middleware cold start**: Serverless middleware may add latency.
   - Mitigation: Monitor; fallback to client-side if needed.

---

**Phase 0 Complete**. Proceed to Phase 1: Design & Contracts.
