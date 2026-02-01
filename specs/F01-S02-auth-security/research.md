# Research: F01-S02 Authentication & Security Integration

**Feature**: F01-S02-auth-security
**Date**: 2026-01-25
**Status**: Complete

---

## 1. JWT Library Selection for FastAPI

### Decision
**PyJWT** (python-jose not needed for HS256)

### Rationale
- PyJWT is lightweight and sufficient for HS256 symmetric signing
- python-jose adds RSA/EC support not needed for this spec
- FastAPI documentation examples use PyJWT for simple JWT auth
- Smaller dependency footprint

### Alternatives Considered
| Library | Pros | Cons | Decision |
|---------|------|------|----------|
| PyJWT | Lightweight, well-maintained, sufficient for HS256 | No async support | **CHOSEN** |
| python-jose | More algorithms, used by FastAPI examples | Heavier, extra features unused | Rejected |
| authlib | Full OAuth support | Overkill for JWT-only auth | Rejected |

### Implementation Pattern
```python
import jwt
from datetime import datetime, timedelta, timezone

def create_access_token(data: dict, expires_delta: timedelta) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, settings.jwt_secret, algorithm=settings.jwt_algorithm)

def verify_token(token: str) -> dict:
    try:
        payload = jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")
```

---

## 2. Password Hashing with passlib

### Decision
**passlib[bcrypt]** with CryptContext and cost factor 12

### Rationale
- passlib provides a unified API for password hashing
- bcrypt is industry standard, recommended by OWASP
- Cost factor 12 balances security (~250ms hash time) with UX
- CryptContext enables future algorithm migration

### Implementation Pattern
```python
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)
```

### Security Configuration
- **Cost Factor**: 12 (spec requirement)
- **Algorithm**: bcrypt (2b prefix)
- **Salt**: Auto-generated per password (passlib default)

---

## 3. Refresh Token Strategy

### Decision
**Database-stored opaque tokens** with hash storage

### Rationale
- Enables immediate revocation (logout, security breach)
- Supports refresh token rotation (spec FR-016)
- Opaque tokens prevent information leakage
- Hash storage protects against database compromise

### Alternatives Considered
| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| JWT refresh tokens | Stateless, no DB lookup | Cannot revoke without blacklist | Rejected |
| Opaque tokens in DB | Revocable, rotatable, secure | DB lookup required | **CHOSEN** |
| Redis-backed tokens | Fast lookup, auto-expiry | New infrastructure dependency | Future consideration |

### Implementation Pattern
```python
import secrets
import hashlib

def generate_refresh_token() -> tuple[str, str]:
    """Returns (raw_token, hashed_token)"""
    raw_token = secrets.token_urlsafe(32)
    hashed_token = hashlib.sha256(raw_token.encode()).hexdigest()
    return raw_token, hashed_token

def verify_refresh_token(raw_token: str, stored_hash: str) -> bool:
    computed_hash = hashlib.sha256(raw_token.encode()).hexdigest()
    return secrets.compare_digest(computed_hash, stored_hash)
```

### Database Schema for RefreshToken
```sql
CREATE TABLE refresh_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,  -- SHA-256 hex
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    revoked_at TIMESTAMP,  -- NULL if active
    UNIQUE(token_hash)
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
```

---

## 4. Rate Limiting Implementation

### Decision
**In-memory dictionary** with sliding window per email

### Rationale
- Simple implementation, no external dependencies
- Sufficient for single-instance deployment
- Can be upgraded to Redis for horizontal scaling
- Meets spec requirement (5 attempts per email per 15 minutes)

### Alternatives Considered
| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| In-memory dict | Simple, no deps | Single instance only | **CHOSEN** (MVP) |
| Redis | Distributed, persistent | New dependency | Future upgrade |
| Database-backed | Persistent | Slow, DB load | Rejected |
| slowapi library | Feature-rich | Adds dependency | Rejected |

### Implementation Pattern
```python
from datetime import datetime, timedelta
from collections import defaultdict
import threading

class LoginRateLimiter:
    def __init__(self, max_attempts: int = 5, window_minutes: int = 15):
        self.max_attempts = max_attempts
        self.window = timedelta(minutes=window_minutes)
        self.attempts = defaultdict(list)  # email -> list of timestamps
        self.lock = threading.Lock()

    def is_allowed(self, email: str) -> bool:
        now = datetime.utcnow()
        cutoff = now - self.window

        with self.lock:
            # Remove old attempts
            self.attempts[email] = [t for t in self.attempts[email] if t > cutoff]
            return len(self.attempts[email]) < self.max_attempts

    def record_attempt(self, email: str):
        now = datetime.utcnow()
        with self.lock:
            self.attempts[email].append(now)

    def get_retry_after(self, email: str) -> int:
        """Returns seconds until oldest attempt expires"""
        if not self.attempts[email]:
            return 0
        oldest = min(self.attempts[email])
        retry_at = oldest + self.window
        return max(0, int((retry_at - datetime.utcnow()).total_seconds()))

rate_limiter = LoginRateLimiter()
```

---

## 5. F01-S01 Integration Strategy

### Decision
**Minimal dependency replacement** - keep TaskService unchanged

### Current State (F01-S01)
```python
# backend/src/api/deps.py
def get_user_id(
    user_id_query: Optional[str] = Query(None, alias="user_id"),
    x_user_id: Optional[str] = Header(None, alias="X-User-ID")
) -> str:
    # Returns user_id from param or header (insecure)
```

### Target State (F01-S02)
```python
# backend/src/api/deps.py
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security)
) -> User:
    """Extract user from verified JWT token."""
    token = credentials.credentials
    payload = verify_token(token)  # Raises 401 on failure

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token payload")

    # Optionally fetch user from DB to verify existence
    return User(id=user_id, email=payload.get("email"))
```

### Changes Required

| File | Change | Impact |
|------|--------|--------|
| `config.py` | Add JWT settings | Low |
| `deps.py` | Replace `get_user_id` with `get_current_user` | Medium |
| `routes/tasks.py` | Change dependency injection | Low |
| `main.py` | Add auth router | Low |

### Preserved (No Changes)

| File | Reason |
|------|--------|
| `task_service.py` | Accepts user_id parameter - source changes, not logic |
| `models/task.py` | Task model unchanged |
| `schemas/task_schemas.py` | Request/response unchanged |
| `database.py` | Connection management unchanged |

### Migration Path
1. Add `get_current_user` dependency alongside `get_user_id`
2. Update task routes to use `get_current_user`
3. Remove deprecated `get_user_id` function
4. Update .env.example with JWT settings

---

## 6. Email Normalization

### Decision
**Lowercase normalization** before storage and comparison

### Rationale
- Prevents duplicate accounts with case variations
- Consistent with spec FR-005
- Simple implementation

### Implementation Pattern
```python
def normalize_email(email: str) -> str:
    return email.strip().lower()
```

---

## 7. Token Claims Structure

### Decision
**Minimal claims** with user_id as subject

### Access Token Claims
```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "type": "access",
  "iat": 1706178600,
  "exp": 1706179500
}
```

### Rationale
- `sub` (subject) is standard JWT claim for user identifier
- `email` included for convenience (display purposes)
- `type` distinguishes access from refresh tokens
- No sensitive data (password hash, internal IDs)

---

## 8. Error Response Consistency

### Decision
**Unified error format** matching F01-S01 ErrorResponse schema

### Pattern
```python
from src.schemas.error_schemas import ErrorResponse, ErrorDetail

def auth_error_response(code: int, message: str) -> JSONResponse:
    return JSONResponse(
        status_code=code,
        content=ErrorResponse(
            error=ErrorDetail(code=code, message=message)
        ).model_dump()
    )
```

### Standard Auth Errors
| Code | Message | When |
|------|---------|------|
| 400 | "Invalid email format" | Malformed email |
| 400 | "Password must be at least 8 characters..." | Weak password |
| 401 | "Invalid credentials" | Wrong email/password |
| 401 | "Token expired" | Expired JWT |
| 401 | "Invalid token" | Malformed/invalid JWT |
| 409 | "Email already registered" | Duplicate registration |
| 429 | "Too many login attempts. Try again in X seconds" | Rate limited |

---

## Summary

| Research Area | Decision | Confidence |
|---------------|----------|------------|
| JWT Library | PyJWT | High |
| Password Hashing | passlib[bcrypt], cost 12 | High |
| Refresh Tokens | DB-stored opaque tokens | High |
| Rate Limiting | In-memory dict | Medium (upgradeable) |
| F01-S01 Integration | Dependency replacement | High |
| Email Normalization | Lowercase | High |
| Token Claims | sub, email, type, iat, exp | High |
| Error Responses | Unified ErrorResponse schema | High |

**All NEEDS CLARIFICATION items resolved. Ready for Phase 1.**
