# Data Model: Authentication System

**Feature**: 001-authentication
**Date**: 2026-01-02
**Purpose**: Define entities, relationships, and validation rules for authentication

---

## Entity 1: User Credentials (Configuration/Environment)

**Description**: User credentials stored in configuration file (.env) or environment variables for authentication validation.

**Storage**: `.env` file (development) or environment variables (production)

**Attributes**:

| Attribute | Type | Required | Validation | Description |
|-----------|------|----------|------------|-------------|
| `AUTH_USERNAME` | string | Yes | Non-empty, max 255 chars | Username for authentication |
| `AUTH_PASSPHRASE` | string | Yes | Non-empty, max 255 chars | Passphrase for authentication (plain text) |
| `AUTH_USER_ID` | string | Yes | Non-empty, unique identifier | Stable user identifier for task ownership |

**Validation Rules**:
- `AUTH_USERNAME` must not be empty
- `AUTH_PASSPHRASE` must not be empty
- `AUTH_USER_ID` must be unique and stable (does not change)
- All values must be present in .env or environment

**Example Configuration**:
```ini
# .env file
AUTH_USERNAME=admin
AUTH_PASSPHRASE=secret123
AUTH_USER_ID=user-001
```

**Security Notes**:
- Plain passphrase storage (acknowledged limitation per frozen scope)
- .env file MUST be in .gitignore
- No password hashing in Phase II
- Future migration: replace with hashed passwords + salt

---

## Entity 2: Session Context (In-Memory Runtime State)

**Description**: Active authenticated session maintained in backend agent memory during application runtime.

**Storage**: In-memory global state (Python module-level variable or singleton)

**Attributes**:

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `user_id` | string | No | None | Authenticated user's identifier (from AUTH_USER_ID) |
| `authenticated` | boolean | Yes | False | Whether user is currently authenticated |
| `username` | string | No | None | Authenticated user's username (for display/logging) |

**Validation Rules**:
- `authenticated` starts as False on application start
- `user_id` and `username` are None until authentication succeeds
- Once authenticated, `user_id` and `username` must not be None
- Session is cleared on application exit

**State Transitions**:
```
[Not Authenticated] -> authenticate_user(valid credentials) -> [Authenticated]
[Authenticated] -> application exit -> [Session Destroyed]
```

**Lifecycle**:
1. **Created**: On successful authentication via `authenticate_user()`
2. **Active**: Throughout application lifetime while process runs
3. **Destroyed**: On application exit (no persistence)

**Implementation Example**:
```python
class SessionContext:
    def __init__(self):
        self.user_id = None
        self.username = None
        self.authenticated = False

    def login(self, username, user_id):
        self.username = username
        self.user_id = user_id
        self.authenticated = True

    def logout(self):
        self.username = None
        self.user_id = None
        self.authenticated = False

    def is_authenticated(self):
        return self.authenticated

    def get_current_user(self):
        if not self.authenticated:
            raise SessionError("No authenticated session")
        return self.user_id

# Global session instance
session = SessionContext()
```

---

## Entity 3: Task (Modified from Phase I)

**Description**: Task entity from Phase I with added user ownership for authentication enforcement.

**Storage**: Backend task storage (inherited from Phase I - file-based or in-memory)

**Attributes** (NEW/MODIFIED only):

| Attribute | Type | Required | Validation | Description |
|-----------|------|----------|------------|-------------|
| `user_id` | string | Yes | Must match authenticated user | Owner identifier (from session.user_id) |

**Existing Phase I Attributes** (UNCHANGED):
- `id`: Unique task identifier
- `title`: Task title (required, non-empty)
- `description`: Task description (optional)
- `status`: Task status (e.g., "pending", "in-progress", "completed")
- `priority`: Task priority (e.g., "low", "medium", "high")
- `tags`: List of tags (optional)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

**Validation Rules** (NEW):
- `user_id` MUST be set to `session.get_current_user()` on task creation
- `user_id` MUST NOT be modifiable by user input (security - prevent task hijacking)
- Task queries MUST filter by `user_id == session.get_current_user()`

**Authorization Rules**:
- CREATE: Auto-assign current user_id, require authentication
- READ: Filter by current user_id, require authentication
- UPDATE: Verify user_id matches current user, require authentication
- DELETE: Verify user_id matches current user, require authentication

**Example Task Data**:
```python
{
    "id": "task-123",
    "user_id": "user-001",  # NEW - from session
    "title": "Complete authentication feature",
    "description": "Implement backend agent authentication",
    "status": "in-progress",
    "priority": "high",
    "tags": ["authentication", "phase-ii"],
    "created_at": "2026-01-02T10:00:00Z",
    "updated_at": "2026-01-02T10:30:00Z"
}
```

---

## Relationships

```
User Credentials (1) --authenticates--> (1) Session Context
Session Context (1) --owns--> (*) Task
```

**Relationship Rules**:
1. **User Credentials → Session Context**: One set of credentials creates one session (single user)
2. **Session Context → Task**: One session can own many tasks (1:N relationship)
3. **User Credentials → Task** (indirect): Tasks are associated with user_id from credentials

**Cardinality**:
- One user (credentials) → One session (at a time)
- One session (user_id) → Many tasks

---

## Data Flow

### Authentication Flow
```
1. Application starts
2. Load credentials from .env (User Credentials entity)
3. Prompt user for username + passphrase
4. Validate against User Credentials
5. On success: Create Session Context with user_id
6. Session Context becomes active
```

### Task Operation Flow
```
1. User requests task operation (create/read/update/delete)
2. Check Session Context.authenticated == True
3. If False: Raise AuthenticationError
4. If True: Get Session Context.user_id
5. Execute task operation with user_id:
   - CREATE: Auto-assign user_id
   - READ: Filter by user_id
   - UPDATE/DELETE: Verify task.user_id == session.user_id
6. Return result
```

---

## Validation Summary

| Entity | Validation Type | Rules |
|--------|----------------|-------|
| User Credentials | Configuration | Non-empty username, passphrase, user_id |
| Session Context | State | authenticated, user_id, username consistency |
| Task | Authorization | user_id matches session, authentication required |

---

## Migration Considerations (Future)

To support multi-user in future phases:
1. Replace User Credentials entity with database Users table
2. Add password hashing + salt to Users table
3. Modify Session Context to support concurrent sessions (JWT tokens)
4. Task user_id already compatible with multi-user (no changes needed)

---

## Next Steps

Proceed to contracts generation (Phase 1):
- Define function signatures for authenticate_user(), is_authenticated(), get_current_user()
- Define task operation signatures with authentication requirements
