# Authentication Architecture – Phase II

## Overview

Phase II implements **JWT-based authentication** using **Better Auth** for token generation on the frontend and **JWT verification** on the backend. This architecture enables stateless, scalable authentication for a multi-user web application.

---

## Table of Contents

- [Authentication Flow](#authentication-flow)
- [Better Auth (Frontend)](#better-auth-frontend)
- [JWT Verification (Backend)](#jwt-verification-backend)
- [Security Model](#security-model)
- [User Registration Flow](#user-registration-flow)
- [User Login Flow](#user-login-flow)
- [Authenticated API Requests](#authenticated-api-requests)
- [Token Refresh Flow](#token-refresh-flow)
- [Error Handling](#error-handling)
- [Security Best Practices](#security-best-practices)
- [Implementation Checklist](#implementation-checklist)

---

## Authentication Flow

### High-Level Architecture

```
┌──────────────────────────────────────────────────────────────────┐
│                         Frontend (Next.js)                        │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      Better Auth                             │ │
│  │  • Issues JWT tokens on successful login                    │ │
│  │  • Stores tokens securely (httpOnly cookies)                │ │
│  │  • Manages token refresh before expiration                  │ │
│  │  • Handles user session state                               │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                      API Client                              │ │
│  │  • Includes JWT in Authorization header                     │ │
│  │  • Handles 401 (redirect to login)                          │ │
│  │  • Handles 403 (access denied)                              │ │
│  └─────────────────────────────────────────────────────────────┘ │
└───────────────────────────┬──────────────────────────────────────┘
                            │
                            │ Authorization: Bearer <JWT>
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                       Backend (FastAPI)                           │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                JWT Verification Middleware                   │ │
│  │  1. Extract Authorization header                            │ │
│  │  2. Verify JWT signature (shared secret)                    │ │
│  │  3. Decode token → extract user_id, email                   │ │
│  │  4. Attach user_id to request context                       │ │
│  │  5. Return 401 if token invalid/expired                     │ │
│  └─────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │                   API Endpoints                              │ │
│  │  • All endpoints require authenticated user_id              │ │
│  │  • Database queries scoped to user_id                       │ │
│  │  • Return 403 for cross-user access attempts                │ │
│  └─────────────────────────────────────────────────────────────┘ │
└───────────────────────────┬──────────────────────────────────────┘
                            │
                            │ SQL: WHERE user_id = ?
                            │
┌───────────────────────────▼──────────────────────────────────────┐
│                    Neon PostgreSQL                                │
│  • users table (id, email, created_at)                           │
│  • tasks table (id, user_id, title, description, ...)            │
│  • Index on tasks.user_id for performance                        │
└───────────────────────────────────────────────────────────────────┘
```

---

## Better Auth (Frontend)

### What is Better Auth?

[Better Auth](https://www.better-auth.com/) is a modern authentication library for Next.js that provides:

- JWT token generation and management
- Secure session handling
- Built-in token refresh mechanisms
- Integration with Next.js App Router
- Support for multiple authentication providers

### Configuration

```typescript
// frontend/lib/auth.ts
import { betterAuth } from "better-auth/client"

export const authClient = betterAuth({
  baseURL: process.env.NEXT_PUBLIC_AUTH_URL || "http://localhost:3000",
  storage: {
    type: "cookie",
    cookieOptions: {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 7 * 24 * 60 * 60, // 7 days
    },
  },
  jwt: {
    secret: process.env.NEXT_PUBLIC_JWT_SECRET!,
    expiresIn: "1h", // Access token expires in 1 hour
  },
  refreshToken: {
    enabled: true,
    expiresIn: "7d", // Refresh token expires in 7 days
  },
})
```

### Frontend Responsibilities

1. **User Registration**: Collect email/password, hash password, call backend `/auth/signup`
2. **User Login**: Collect credentials, call Better Auth login, receive JWT
3. **Token Storage**: Store JWT in httpOnly cookies (NOT localStorage)
4. **Token Refresh**: Automatically refresh tokens before expiration
5. **API Requests**: Include JWT in `Authorization: Bearer <token>` header
6. **Error Handling**: Handle 401 (redirect to login) and 403 (access denied)

---

## JWT Verification (Backend)

### JWT Structure

A JWT token consists of three parts:

```
HEADER.PAYLOAD.SIGNATURE
```

**Header** (algorithm and token type):
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

**Payload** (claims):
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "iat": 1704672000,
  "exp": 1704675600
}
```

**Signature** (HMAC SHA256 using shared secret):
```
HMACSHA256(
  base64UrlEncode(header) + "." + base64UrlEncode(payload),
  secret
)
```

### Backend JWT Verification Middleware

```python
# backend/src/auth/jwt_middleware.py
from fastapi import Request, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from datetime import datetime

JWT_SECRET = os.getenv("JWT_SECRET")  # MUST match Better Auth secret
JWT_ALGORITHM = "HS256"

security = HTTPBearer()

async def verify_jwt(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """
    Verify JWT token and extract user_id.

    Returns:
        str: Authenticated user_id

    Raises:
        HTTPException 401: Token missing, expired, or invalid
    """
    token = credentials.credentials

    try:
        # Verify signature and decode
        payload = jwt.decode(
            token,
            JWT_SECRET,
            algorithms=[JWT_ALGORITHM]
        )

        # Extract user_id from claims
        user_id = payload.get("user_id")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token: missing user_id claim"
            )

        # Check expiration (jwt.decode already does this, but explicit check)
        exp = payload.get("exp")
        if exp and datetime.fromtimestamp(exp) < datetime.now():
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token expired"
            )

        return user_id

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token expired"
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}"
        )
```

### Using JWT Middleware in Endpoints

```python
# backend/src/tasks/routes.py
from fastapi import APIRouter, Depends
from sqlmodel import Session
from ..auth.jwt_middleware import verify_jwt
from ..database import get_db

router = APIRouter(prefix="/api/tasks", tags=["tasks"])

@router.get("/")
async def list_tasks(
    user_id: str = Depends(verify_jwt),  # ← JWT verification
    db: Session = Depends(get_db)
):
    """
    List all tasks for authenticated user.

    CRITICAL: Query MUST filter by user_id from verified JWT.
    """
    tasks = db.query(Task).filter(Task.user_id == user_id).all()
    return tasks

@router.post("/")
async def create_task(
    task_data: TaskCreate,
    user_id: str = Depends(verify_jwt),  # ← JWT verification
    db: Session = Depends(get_db)
):
    """
    Create a new task for authenticated user.

    CRITICAL: Task MUST be assigned to user_id from verified JWT.
    """
    task = Task(
        **task_data.dict(),
        user_id=user_id  # ← From verified JWT, NOT from client
    )
    db.add(task)
    db.commit()
    db.refresh(task)
    return task
```

---

## Security Model

### Critical Security Rules

#### 1. Backend Verifies JWT

✅ **DO**: Verify JWT signature on every request
❌ **DON'T**: Trust client-provided `user_id` without JWT verification

```python
# ✅ CORRECT: user_id from verified JWT
user_id = verify_jwt(token)

# ❌ WRONG: user_id from request body (client can lie!)
user_id = request.json.get("user_id")
```

#### 2. User-Scoped Queries

✅ **DO**: Filter ALL database queries by authenticated `user_id`
❌ **DON'T**: Allow queries without user filtering

```python
# ✅ CORRECT: User-scoped query
tasks = db.query(Task).filter(Task.user_id == user_id).all()

# ❌ WRONG: Returns ALL users' tasks!
tasks = db.query(Task).all()
```

#### 3. Cross-User Access Prevention

✅ **DO**: Return 403 Forbidden for cross-user access attempts
❌ **DON'T**: Return 404 (information leak - confirms resource exists)

```python
# ✅ CORRECT: Explicit ownership check
task = db.query(Task).filter(
    Task.id == task_id,
    Task.user_id == user_id  # ← Ownership check
).first()

if not task:
    raise HTTPException(
        status_code=403,
        detail="Access denied: task not found or not owned by user"
    )
```

#### 4. Shared Secret Security

✅ **DO**: Store JWT secret in environment variables
✅ **DO**: Use strong, random secrets (min 256 bits)
✅ **DO**: Rotate secrets periodically
❌ **DON'T**: Hardcode secrets in source code
❌ **DON'T**: Commit secrets to version control

```bash
# .env (backend)
JWT_SECRET="your-super-secret-key-minimum-32-characters-long-and-random"

# .env.local (frontend - Better Auth)
NEXT_PUBLIC_JWT_SECRET="same-as-backend-secret"
```

#### 5. Token Expiration

✅ **DO**: Set short expiration times for access tokens (1 hour recommended)
✅ **DO**: Use refresh tokens for extended sessions (7 days recommended)
✅ **DO**: Reject expired tokens with 401 Unauthorized

---

## User Registration Flow

### Step-by-Step Process

```
┌─────────┐                        ┌─────────┐
│ Frontend│                        │ Backend │
└────┬────┘                        └────┬────┘
     │                                  │
     │ 1. POST /auth/signup             │
     │    {email, password}             │
     ├─────────────────────────────────>│
     │                                  │ 2. Validate email format
     │                                  │ 3. Check email not already registered
     │                                  │ 4. Hash password (bcrypt)
     │                                  │ 5. Create user in database
     │                                  │ 6. Generate JWT token
     │                                  │
     │ 7. Response:                     │
     │    {token, user_id, email}       │
     │<─────────────────────────────────┤
     │                                  │
     │ 8. Store token (httpOnly cookie) │
     │ 9. Redirect to dashboard         │
     │                                  │
```

### Frontend (Better Auth)

```typescript
// frontend/lib/api/auth.ts
import { authClient } from "@/lib/auth"

export async function signUp(email: string, password: string) {
  try {
    const response = await authClient.signUp({
      email,
      password,
    })

    // Better Auth handles JWT storage automatically
    return response
  } catch (error) {
    if (error.response?.status === 400) {
      throw new Error("Email already registered")
    }
    throw error
  }
}
```

### Backend (FastAPI)

```python
# backend/src/auth/routes.py
from fastapi import APIRouter, HTTPException, status
from sqlmodel import Session, select
from passlib.context import CryptContext
import jwt
from datetime import datetime, timedelta

router = APIRouter(prefix="/auth", tags=["auth"])
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

@router.post("/signup")
async def signup(
    user_data: UserSignup,
    db: Session = Depends(get_db)
):
    """Register a new user and return JWT token."""

    # Check if email already exists
    existing_user = db.exec(
        select(User).where(User.email == user_data.email)
    ).first()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )

    # Hash password
    hashed_password = pwd_context.hash(user_data.password)

    # Create user
    user = User(
        email=user_data.email,
        hashed_password=hashed_password
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    # Generate JWT token
    token = jwt.encode(
        {
            "user_id": str(user.id),
            "email": user.email,
            "iat": datetime.utcnow(),
            "exp": datetime.utcnow() + timedelta(hours=1)
        },
        JWT_SECRET,
        algorithm=JWT_ALGORITHM
    )

    return {
        "token": token,
        "user_id": str(user.id),
        "email": user.email
    }
```

---

## User Login Flow

### Step-by-Step Process

```
┌─────────┐                        ┌─────────┐
│ Frontend│                        │ Backend │
└────┬────┘                        └────┬────┘
     │                                  │
     │ 1. POST /auth/login              │
     │    {email, password}             │
     ├─────────────────────────────────>│
     │                                  │ 2. Find user by email
     │                                  │ 3. Verify password hash
     │                                  │ 4. Generate JWT token
     │                                  │
     │ 5. Response:                     │
     │    {token, user_id, email}       │
     │<─────────────────────────────────┤
     │                                  │
     │ 6. Store token (httpOnly cookie) │
     │ 7. Redirect to dashboard         │
     │                                  │
```

### Frontend (Better Auth)

```typescript
// frontend/lib/api/auth.ts
export async function signIn(email: string, password: string) {
  try {
    const response = await authClient.signIn({
      email,
      password,
    })

    return response
  } catch (error) {
    if (error.response?.status === 401) {
      throw new Error("Invalid email or password")
    }
    throw error
  }
}
```

### Backend (FastAPI)

```python
# backend/src/auth/routes.py
@router.post("/login")
async def login(
    credentials: UserLogin,
    db: Session = Depends(get_db)
):
    """Authenticate user and return JWT token."""

    # Find user by email
    user = db.exec(
        select(User).where(User.email == credentials.email)
    ).first()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Verify password
    if not pwd_context.verify(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )

    # Generate JWT token
    token = jwt.encode(
        {
            "user_id": str(user.id),
            "email": user.email,
            "iat": datetime.utcnow(),
            "exp": datetime.utcnow() + timedelta(hours=1)
        },
        JWT_SECRET,
        algorithm=JWT_ALGORITHM
    )

    return {
        "token": token,
        "user_id": str(user.id),
        "email": user.email
    }
```

---

## Authenticated API Requests

### Frontend API Client

```typescript
// frontend/lib/api-client.ts
import { authClient } from "@/lib/auth"

export async function fetchAPI(endpoint: string, options?: RequestInit) {
  // Get JWT token from Better Auth
  const session = await authClient.getSession()
  const token = session?.token

  if (!token) {
    // Redirect to login if no token
    window.location.href = "/login"
    throw new Error("Not authenticated")
  }

  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL}${endpoint}`,
    {
      ...options,
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${token}`,  // ← JWT in header
        ...options?.headers,
      },
    }
  )

  if (response.status === 401) {
    // Token expired or invalid - redirect to login
    window.location.href = "/login"
    throw new Error("Authentication required")
  }

  if (response.status === 403) {
    // Access denied (cross-user access attempt)
    throw new Error("Access denied")
  }

  if (!response.ok) {
    throw new Error(`API error: ${response.status}`)
  }

  return response.json()
}
```

### Usage Example

```typescript
// frontend/app/dashboard/page.tsx
import { fetchAPI } from "@/lib/api-client"

export default async function DashboardPage() {
  // Fetch user's tasks (automatically includes JWT)
  const tasks = await fetchAPI("/api/tasks")

  return (
    <div>
      <h1>My Tasks</h1>
      <TaskList tasks={tasks} />
    </div>
  )
}
```

---

## Token Refresh Flow

### Why Token Refresh?

- **Short-lived access tokens**: Reduce risk if token is stolen
- **Long-lived refresh tokens**: Avoid frequent re-authentication
- **Automatic refresh**: Seamless user experience

### Refresh Flow

```
┌─────────┐                        ┌─────────┐
│ Frontend│                        │ Backend │
└────┬────┘                        └────┬────┘
     │                                  │
     │ 1. API Request                   │
     │    Authorization: Bearer <JWT>   │
     ├─────────────────────────────────>│
     │                                  │ 2. JWT expired
     │                                  │
     │ 3. 401 Unauthorized              │
     │<─────────────────────────────────┤
     │                                  │
     │ 4. POST /auth/refresh            │
     │    {refresh_token}               │
     ├─────────────────────────────────>│
     │                                  │ 5. Validate refresh token
     │                                  │ 6. Generate new access token
     │                                  │
     │ 7. {token, expires_in}           │
     │<─────────────────────────────────┤
     │                                  │
     │ 8. Retry original API request    │
     │    Authorization: Bearer <NEW_JWT>
     ├─────────────────────────────────>│
     │                                  │ 9. Success
     │ 10. Response data                │
     │<─────────────────────────────────┤
     │                                  │
```

### Better Auth Automatic Refresh

Better Auth handles token refresh automatically:

```typescript
// Better Auth automatically refreshes tokens before expiration
// No manual implementation required!

// Configuration (frontend/lib/auth.ts)
export const authClient = betterAuth({
  refreshToken: {
    enabled: true,
    expiresIn: "7d",
    autoRefresh: true,  // ← Automatically refresh before expiration
  },
})
```

---

## Error Handling

### HTTP Status Codes

| Status Code | Meaning | Frontend Action |
|-------------|---------|-----------------|
| **401 Unauthorized** | Missing, expired, or invalid JWT | Redirect to login |
| **403 Forbidden** | Cross-user access attempt | Show "Access Denied" error |
| **400 Bad Request** | Invalid input (validation failure) | Show validation errors |
| **404 Not Found** | Resource doesn't exist | Show "Not Found" error |
| **500 Internal Server Error** | Unexpected server error | Show generic error message |

### Frontend Error Handling

```typescript
// frontend/lib/api-client.ts
export async function fetchAPI(endpoint: string, options?: RequestInit) {
  try {
    const response = await fetch(/* ... */)

    if (response.status === 401) {
      // Token expired - redirect to login
      window.location.href = "/login"
      throw new Error("Please log in again")
    }

    if (response.status === 403) {
      // Access denied
      throw new Error("You don't have permission to access this resource")
    }

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.detail || "An error occurred")
    }

    return response.json()
  } catch (error) {
    // Network errors, etc.
    console.error("API Error:", error)
    throw error
  }
}
```

### Backend Error Responses

```python
# backend/src/auth/jwt_middleware.py
from fastapi.responses import JSONResponse

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.status_code,
                "message": exc.detail,
            }
        }
    )
```

---

## Security Best Practices

### 1. JWT Secret Management

✅ **DO**:
- Store JWT secret in environment variables
- Use strong, random secrets (minimum 256 bits / 32 characters)
- Rotate secrets periodically
- Use different secrets for dev, staging, prod

❌ **DON'T**:
- Hardcode secrets in source code
- Commit secrets to version control
- Share secrets across environments
- Use weak or predictable secrets

### 2. Token Storage

✅ **DO**:
- Store tokens in httpOnly cookies (NOT localStorage)
- Set secure flag in production (HTTPS only)
- Set sameSite flag to prevent CSRF
- Clear tokens on logout

❌ **DON'T**:
- Store tokens in localStorage (vulnerable to XSS)
- Store tokens in sessionStorage (vulnerable to XSS)
- Store sensitive data in JWT payload (it's base64, not encrypted!)

### 3. Token Expiration

✅ **DO**:
- Short-lived access tokens (1 hour recommended)
- Long-lived refresh tokens (7 days recommended)
- Implement automatic token refresh
- Revoke refresh tokens on logout

❌ **DON'T**:
- Long-lived access tokens (security risk if stolen)
- No expiration (tokens valid forever)
- Manual token refresh (poor UX)

### 4. Password Security

✅ **DO**:
- Hash passwords with bcrypt (or Argon2)
- Use salt rounds of at least 12
- Never log passwords (even hashed)
- Implement rate limiting on login attempts

❌ **DON'T**:
- Store passwords in plain text
- Use weak hashing algorithms (MD5, SHA1)
- Log passwords in any form
- Allow unlimited login attempts (brute force vulnerability)

### 5. HTTPS in Production

✅ **DO**:
- Enforce HTTPS in production
- Set secure flag on cookies
- Implement HSTS headers
- Use TLS 1.3 or higher

❌ **DON'T**:
- Allow HTTP in production (tokens exposed in transit)
- Mixed content (HTTPS page loading HTTP resources)

---

## Implementation Checklist

### Frontend (Next.js + Better Auth)

- [ ] Install Better Auth: `npm install better-auth`
- [ ] Configure Better Auth with JWT settings
- [ ] Create API client that includes JWT in headers
- [ ] Implement signup page (`/signup`)
- [ ] Implement login page (`/login`)
- [ ] Implement logout functionality
- [ ] Handle 401 errors (redirect to login)
- [ ] Handle 403 errors (show access denied)
- [ ] Store JWT in httpOnly cookies
- [ ] Implement automatic token refresh

### Backend (FastAPI + JWT)

- [ ] Install dependencies: `pyjwt`, `passlib[bcrypt]`
- [ ] Create JWT verification middleware
- [ ] Implement `/auth/signup` endpoint
- [ ] Implement `/auth/login` endpoint
- [ ] Implement `/auth/refresh` endpoint (optional)
- [ ] Hash passwords with bcrypt
- [ ] Store JWT secret in environment variable
- [ ] Apply JWT middleware to protected endpoints
- [ ] Extract `user_id` from verified JWT
- [ ] Filter ALL database queries by `user_id`
- [ ] Return 403 for cross-user access attempts
- [ ] Return 401 for missing/invalid tokens

### Database

- [ ] Create `users` table (id, email, hashed_password, created_at)
- [ ] Create `tasks` table with `user_id` foreign key
- [ ] Add index on `tasks.user_id` for performance
- [ ] Add unique constraint on `users.email`

### Security

- [ ] JWT secret is strong and random (min 32 chars)
- [ ] JWT secret stored in environment variables
- [ ] JWT secret NOT committed to version control
- [ ] Passwords hashed with bcrypt (NOT plain text)
- [ ] Access tokens expire in 1 hour
- [ ] Refresh tokens expire in 7 days
- [ ] HTTPS enforced in production
- [ ] httpOnly cookies used for token storage
- [ ] CORS configured correctly
- [ ] Rate limiting on login endpoint

---

## References

- **Better Auth Documentation**: https://www.better-auth.com/docs
- **JWT.io**: https://jwt.io/ (JWT debugger and documentation)
- **OWASP Authentication Cheat Sheet**: https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- **FastAPI Security**: https://fastapi.tiangolo.com/tutorial/security/

---

**Security is a journey, not a destination. Review and update these practices regularly.** 🔒
