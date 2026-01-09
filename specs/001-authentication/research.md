# Research: Authentication System Implementation

**Feature**: 001-authentication
**Date**: 2026-01-02
**Purpose**: Resolve technical decisions for backend agent authentication implementation

---

## Research Task 1: Python Authentication Best Practices for Backend Agents

### Decision: Use getpass + python-dotenv for credential management

**Rationale**:
- `getpass.getpass()` provides secure passphrase input (hidden from terminal)
- `python-dotenv` is industry standard for environment variable loading
- Simple, lightweight, no external authentication services required
- Aligns with frozen scope (single user, configuration-based)

**Implementation Approach**:
```python
import getpass
from dotenv import load_dotenv
import os

# Load credentials from .env file
load_dotenv()
STORED_USERNAME = os.getenv("AUTH_USERNAME")
STORED_PASSPHRASE = os.getenv("AUTH_PASSPHRASE")

# Prompt user
username = input("Username: ")
passphrase = getpass.getpass("Passphrase: ")

# Validate
if username == STORED_USERNAME and passphrase == STORED_PASSPHRASE:
    # Create session
    pass
```

**Alternatives Considered**:
1. **File-based JSON storage**: More complex, requires file I/O, no advantage for single user
2. **Hardcoded credentials**: Security anti-pattern, rejected
3. **System keyring**: Overkill for Phase II scope, adds dependency

**Best Practices Applied**:
- Never log or print passphrases
- Use getpass for hidden input
- Store credentials in .env (gitignored)
- Provide .env.example for setup guidance

---

## Research Task 2: Phase I Task CRUD Integration Points

### Decision: Decorator-based authentication enforcement

**Rationale**:
- Clean separation of authentication logic from business logic
- Reuses Phase I task CRUD without major refactoring
- Easy to apply to all task operations consistently
- Pythonic and maintainable

**Implementation Approach**:
```python
from functools import wraps

def require_auth(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not session.is_authenticated():
            raise AuthenticationError("Authentication required")
        return func(*args, **kwargs)
    return wrapper

# Apply to task operations
@require_auth
def create_task(title, description, ...):
    user_id = session.get_current_user()
    # Phase I logic + user_id
    pass

@require_auth
def list_tasks():
    user_id = session.get_current_user()
    # Filter by user_id
    pass
```

**Task Entity Modification**:
- Add `user_id` field to task data structure
- Modify task creation to auto-attach current user_id
- Modify task queries to filter by user_id
- Preserve Phase I validation rules (title, description, status, priority, tags)

**Alternatives Considered**:
1. **Middleware pattern**: Overkill for backend agent (no HTTP layer)
2. **Manual checks in each function**: Error-prone, violates DRY principle
3. **Aspect-oriented programming**: Too complex for scope

---

## Research Task 3: Error Handling Patterns from Backend Agent System

### Decision: Custom exception hierarchy with structured messages

**Rationale**:
- Follows Backend Agent System error handling patterns
- Clear distinction between error types (auth vs validation vs system)
- Enables retry logic for authentication failures
- User-friendly error messages

**Implementation Approach**:
```python
class AuthenticationError(Exception):
    """Raised when authentication fails"""
    pass

class SessionError(Exception):
    """Raised when session operations fail"""
    pass

# Usage in authenticator
def authenticate_user(username, passphrase):
    if not validate_credentials(username, passphrase):
        raise AuthenticationError("Invalid username or passphrase")
    create_session(username)
    return True

# Retry/exit flow
max_retries = 3
for attempt in range(max_retries):
    try:
        username = input("Username: ")
        passphrase = getpass.getpass("Passphrase: ")
        authenticate_user(username, passphrase)
        break
    except AuthenticationError as e:
        print(f"Error: {e}")
        if attempt < max_retries - 1:
            retry = input("Retry? (y/n): ").lower()
            if retry != 'y':
                sys.exit(0)
        else:
            print("Max retries exceeded. Exiting.")
            sys.exit(1)
```

**Error Messages**:
- `"Invalid username or passphrase"` - Authentication failure
- `"Authentication required"` - Unauthenticated task access attempt
- `"Session not found"` - Session context error
- `"Credentials not configured"` - Missing .env configuration

**Alternatives Considered**:
1. **HTTP status codes**: Not applicable (no HTTP layer in backend agent)
2. **Generic exceptions**: Less clear, harder to handle specific cases
3. **Error codes**: More complex than needed for scope

---

## Summary of Decisions

| Area | Decision | Rationale |
|------|----------|-----------|
| **Credential Storage** | python-dotenv + .env file | Industry standard, simple, gitignore-friendly |
| **Passphrase Input** | getpass.getpass() | Secure hidden input, no echo to terminal |
| **Session Management** | In-memory global session object | Simple, sufficient for single-user backend agent |
| **Auth Enforcement** | Decorator pattern (@require_auth) | Clean, reusable, Pythonic |
| **Task Integration** | Add user_id field + decorator checks | Minimal modification to Phase I logic |
| **Error Handling** | Custom exception hierarchy | Clear error types, structured messages, retry-friendly |
| **Retry Logic** | 3 attempts with y/n prompt | User-friendly, prevents lockout |

---

## Dependencies Finalized

- **python-dotenv**: ^1.0.0 (environment variable loading)
- **getpass**: Standard library (secure password input)
- **Phase I task CRUD**: Existing logic (to be modified)

No additional external dependencies required.

---

## Security Considerations

**Current Implementation** (aligned with frozen scope):
- Plain passphrase storage in .env (user explicitly accepted "plain for now")
- No password hashing
- No brute force protection
- No session persistence

**Acknowledged Limitations**:
- This is NOT production-ready authentication
- Suitable for single-user development/learning environment
- Future migration to hashed passwords, JWT, multi-user recommended

**Mitigations Applied**:
- .env file in .gitignore (prevent credential leakage)
- getpass for hidden input (prevent shoulder surfing)
- Clear error messages without exposing system details
- Retry limit to prevent indefinite attempts

---

## Next Steps

Proceed to Phase 1:
1. Generate data-model.md (User Credentials, Session Context, Task entities)
2. Generate contracts/auth.contract.md (function signatures)
3. Generate quickstart.md (setup and usage guide)
4. Update agent context with new dependencies
