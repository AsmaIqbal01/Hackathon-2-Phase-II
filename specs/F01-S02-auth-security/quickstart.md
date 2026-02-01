# Quickstart: F01-S02 Authentication Integration

**Feature**: F01-S02-auth-security
**Date**: 2026-01-25

This guide provides integration scenarios for the authentication system.

---

## Prerequisites

1. Backend server running on `http://localhost:8000`
2. PostgreSQL database configured with users and refresh_tokens tables
3. Environment variables set:
   ```bash
   JWT_SECRET=your-super-secret-key-minimum-32-characters
   JWT_ALGORITHM=HS256
   JWT_ACCESS_EXPIRE_MINUTES=15
   JWT_REFRESH_EXPIRE_DAYS=7
   ```

---

## Scenario 1: User Registration

### Request

```bash
curl -X POST http://localhost:8000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123"
  }'
```

### Expected Response (201 Created)

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "alice@example.com",
    "created_at": "2026-01-25T10:30:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "token_type": "bearer",
  "expires_in": 900
}
```

### Error Cases

**Duplicate Email (409)**
```json
{"error": {"code": 409, "message": "Email already registered"}}
```

**Weak Password (400)**
```json
{"error": {"code": 400, "message": "Password must be at least 8 characters with at least one letter and one number"}}
```

---

## Scenario 2: User Login

### Request

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "alice@example.com",
    "password": "SecurePass123"
  }'
```

### Expected Response (200 OK)

```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "alice@example.com"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
  "token_type": "bearer",
  "expires_in": 900
}
```

### Error Cases

**Invalid Credentials (401)**
```json
{"error": {"code": 401, "message": "Invalid credentials"}}
```

**Rate Limited (429)**
```json
{"error": {"code": 429, "message": "Too many login attempts. Try again in 847 seconds"}}
```

---

## Scenario 3: Accessing Protected Resources

### Request (with JWT)

```bash
# Save the access token from login
ACCESS_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# List user's tasks
curl -X GET http://localhost:8000/api/tasks \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### Expected Response (200 OK)

```json
[
  {
    "id": "task-uuid-here",
    "user_id": "550e8400-e29b-41d4-a716-446655440000",
    "title": "Buy groceries",
    "status": "todo",
    "priority": "high",
    "tags": ["shopping"],
    "created_at": "2026-01-25T10:30:00Z",
    "updated_at": "2026-01-25T10:30:00Z"
  }
]
```

### Error Cases

**Missing Token (401)**
```json
{"error": {"code": 401, "message": "Not authenticated"}}
```

**Expired Token (401)**
```json
{"error": {"code": 401, "message": "Token expired"}}
```

**Cross-User Access (403)**
```json
{"error": {"code": 403, "message": "Access denied"}}
```

---

## Scenario 4: Token Refresh

### Request

```bash
curl -X POST http://localhost:8000/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
  }'
```

### Expected Response (200 OK)

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "cm90YXRlZCByZWZyZXNoIHRva2VuLi4u",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Note**: Refresh token rotation - the old refresh token is invalidated, use the new one for future refreshes.

### Error Cases

**Invalid/Expired Refresh Token (401)**
```json
{"error": {"code": 401, "message": "Invalid or expired refresh token"}}
```

---

## Scenario 5: User Logout

### Request

```bash
curl -X POST http://localhost:8000/api/auth/logout \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### Expected Response (204 No Content)

Empty response body.

### Post-Logout Verification

After logout, both access and refresh tokens should be invalid:

```bash
# This should fail with 401
curl -X GET http://localhost:8000/api/tasks \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

---

## Scenario 6: Get Current User

### Request

```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $ACCESS_TOKEN"
```

### Expected Response (200 OK)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "alice@example.com",
  "created_at": "2026-01-25T10:30:00Z"
}
```

---

## Frontend Integration Example (TypeScript)

### API Client Setup

```typescript
// lib/api-client.ts
const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

let accessToken: string | null = null;
let refreshToken: string | null = null;

export function setTokens(access: string, refresh: string) {
  accessToken = access;
  refreshToken = refresh;
  // Store refresh token securely (httpOnly cookie preferred)
  localStorage.setItem('refresh_token', refresh);
}

export function clearTokens() {
  accessToken = null;
  refreshToken = null;
  localStorage.removeItem('refresh_token');
}

async function refreshAccessToken(): Promise<string> {
  const storedRefresh = refreshToken || localStorage.getItem('refresh_token');
  if (!storedRefresh) throw new Error('No refresh token');

  const response = await fetch(`${API_BASE}/api/auth/refresh`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ refresh_token: storedRefresh }),
  });

  if (!response.ok) {
    clearTokens();
    throw new Error('Session expired');
  }

  const data = await response.json();
  setTokens(data.access_token, data.refresh_token);
  return data.access_token;
}

export async function fetchAPI<T>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const makeRequest = async (token: string | null) => {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
      ...options.headers,
    };
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    return fetch(`${API_BASE}${endpoint}`, {
      ...options,
      headers,
    });
  };

  let response = await makeRequest(accessToken);

  // Auto-refresh on 401
  if (response.status === 401 && refreshToken) {
    try {
      const newToken = await refreshAccessToken();
      response = await makeRequest(newToken);
    } catch {
      clearTokens();
      window.location.href = '/login';
      throw new Error('Session expired');
    }
  }

  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error?.message || 'API Error');
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return response.json();
}
```

### Usage Examples

```typescript
// Register
const { user, access_token, refresh_token } = await fetchAPI('/api/auth/register', {
  method: 'POST',
  body: JSON.stringify({ email: 'alice@example.com', password: 'SecurePass123' }),
});
setTokens(access_token, refresh_token);

// Login
const authResult = await fetchAPI('/api/auth/login', {
  method: 'POST',
  body: JSON.stringify({ email: 'alice@example.com', password: 'SecurePass123' }),
});
setTokens(authResult.access_token, authResult.refresh_token);

// Get tasks (auto-includes JWT)
const tasks = await fetchAPI('/api/tasks');

// Create task
const newTask = await fetchAPI('/api/tasks', {
  method: 'POST',
  body: JSON.stringify({ title: 'New task', priority: 'high' }),
});

// Logout
await fetchAPI('/api/auth/logout', { method: 'POST' });
clearTokens();
```

---

## Testing Checklist

- [ ] Register new user with valid credentials → 201
- [ ] Register with existing email → 409
- [ ] Register with weak password → 400
- [ ] Login with valid credentials → 200
- [ ] Login with invalid credentials → 401
- [ ] Login after 5 failed attempts → 429
- [ ] Access /api/tasks without token → 401
- [ ] Access /api/tasks with valid token → 200
- [ ] Access /api/tasks with expired token → 401
- [ ] Refresh with valid refresh token → 200 + new tokens
- [ ] Refresh with expired refresh token → 401
- [ ] Refresh with revoked refresh token → 401
- [ ] Logout → 204
- [ ] Use old tokens after logout → 401
- [ ] Get /api/auth/me with valid token → 200
- [ ] Cross-user task access → 403
