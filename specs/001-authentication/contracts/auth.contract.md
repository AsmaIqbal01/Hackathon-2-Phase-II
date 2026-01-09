# Authentication Contracts

**Feature**: 001-authentication
**Date**: 2026-01-02
**Purpose**: Define function signatures and contracts for authentication system

---

## Module: auth.authenticator

### Function: authenticate_user

**Purpose**: Authenticate user with username and passphrase, create session on success

**Signature**:
```python
def authenticate_user(username: str, passphrase: str) -> bool:
    """
    Authenticate user with provided credentials.

    Args:
        username: User-provided username
        passphrase: User-provided passphrase

    Returns:
        True if authentication successful, False otherwise

    Raises:
        AuthenticationError: If credentials are invalid
        ConfigurationError: If credentials not configured in environment

    Side Effects:
        - Creates session context on success
        - Sets session.user_id, session.username, session.authenticated
    """
```

**Preconditions**:
- AUTH_USERNAME, AUTH_PASSPHRASE, AUTH_USER_ID configured in .env or environment
- username and passphrase are non-empty strings

**Postconditions**:
- If valid: session.authenticated == True, session.user_id == AUTH_USER_ID
- If invalid: AuthenticationError raised

**Example Usage**:
```python
try:
    authenticate_user("admin", "secret123")
    print("Authentication successful")
except AuthenticationError as e:
    print(f"Failed: {e}")
```

---

### Function: prompt_for_credentials

**Purpose**: Prompt user for username and passphrase with retry logic

**Signature**:
```python
def prompt_for_credentials(max_retries: int = 3) -> None:
    """
    Prompt user for credentials with retry/exit options.

    Args:
        max_retries: Maximum authentication attempts (default 3)

    Returns:
        None (exits application if authentication fails)

    Raises:
        SystemExit: On authentication failure after max retries or user exit

    Side Effects:
        - Prompts user for input via stdin
        - Calls authenticate_user() internally
        - Exits application on failure
    """
```

**Preconditions**:
- Terminal available for user input
- max_retries > 0

**Postconditions**:
- Session authenticated OR application exited

**Example Usage**:
```python
# On application startup
prompt_for_credentials()
# After this point, session is guaranteed to be authenticated
```

---

## Module: auth.session

### Function: is_authenticated

**Purpose**: Check if current session is authenticated

**Signature**:
```python
def is_authenticated() -> bool:
    """
    Check if user is currently authenticated.

    Returns:
        True if authenticated, False otherwise
    """
```

**Preconditions**: None

**Postconditions**: None (read-only)

**Example Usage**:
```python
if is_authenticated():
    print("User is logged in")
else:
    print("Please authenticate first")
```

---

### Function: get_current_user

**Purpose**: Get authenticated user's user_id

**Signature**:
```python
def get_current_user() -> str:
    """
    Get the current authenticated user's user_id.

    Returns:
        user_id string

    Raises:
        SessionError: If not authenticated
    """
```

**Preconditions**:
- Session must be authenticated (is_authenticated() == True)

**Postconditions**:
- Returns valid user_id string

**Example Usage**:
```python
try:
    user_id = get_current_user()
    print(f"Current user: {user_id}")
except SessionError:
    print("Not authenticated")
```

---

### Function: require_auth (Decorator)

**Purpose**: Decorator to enforce authentication for task operations

**Signature**:
```python
def require_auth(func: Callable) -> Callable:
    """
    Decorator to enforce authentication before function execution.

    Args:
        func: Function to wrap with authentication check

    Returns:
        Wrapped function

    Raises:
        AuthenticationError: If not authenticated when function called
    """
```

**Preconditions**: None

**Postconditions**:
- Wrapped function only executes if authenticated
- Raises AuthenticationError if not authenticated

**Example Usage**:
```python
@require_auth
def create_task(title: str, description: str) -> dict:
    user_id = get_current_user()
    # Create task with user_id
    return {"id": "task-1", "user_id": user_id, "title": title}
```

---

## Module: auth.credential_loader

### Function: load_credentials

**Purpose**: Load credentials from .env file or environment variables

**Signature**:
```python
def load_credentials() -> dict[str, str]:
    """
    Load user credentials from configuration.

    Returns:
        Dictionary with keys: 'username', 'passphrase', 'user_id'

    Raises:
        ConfigurationError: If any required credential missing
    """
```

**Preconditions**:
- .env file exists OR environment variables set
- AUTH_USERNAME, AUTH_PASSPHRASE, AUTH_USER_ID defined

**Postconditions**:
- Returns dictionary with all three credential fields

**Example Usage**:
```python
try:
    creds = load_credentials()
    print(f"Loaded credentials for user: {creds['username']}")
except ConfigurationError as e:
    print(f"Configuration error: {e}")
    sys.exit(1)
```

---

## Exception Contracts

### AuthenticationError

**Purpose**: Raised when authentication fails due to invalid credentials

**Usage**:
```python
class AuthenticationError(Exception):
    """Authentication failed - invalid username or passphrase"""
    pass
```

**When Raised**:
- Username does not match AUTH_USERNAME
- Passphrase does not match AUTH_PASSPHRASE
- Credentials validation fails

---

### SessionError

**Purpose**: Raised when session operations fail (e.g., accessing user_id when not authenticated)

**Usage**:
```python
class SessionError(Exception):
    """Session operation failed - not authenticated"""
    pass
```

**When Raised**:
- get_current_user() called when not authenticated
- Session state inconsistency detected

---

### ConfigurationError

**Purpose**: Raised when credential configuration is missing or invalid

**Usage**:
```python
class ConfigurationError(Exception):
    """Configuration error - credentials not found"""
    pass
```

**When Raised**:
- AUTH_USERNAME, AUTH_PASSPHRASE, or AUTH_USER_ID not found
- .env file missing and environment variables not set
- Invalid credential format

---

## Task Operation Contracts (Modified from Phase I)

### Function: create_task

**Modified Signature**:
```python
@require_auth
def create_task(title: str, description: str = "", status: str = "pending",
                priority: str = "medium", tags: list[str] = None) -> dict:
    """
    Create new task with automatic user_id assignment.

    Args:
        title: Task title (required)
        description: Task description (optional)
        status: Task status (default "pending")
        priority: Task priority (default "medium")
        tags: Task tags (optional)

    Returns:
        Created task dictionary with user_id

    Raises:
        AuthenticationError: If not authenticated
        ValidationError: If validation fails (Phase I rules)
    """
```

**NEW Behavior**:
- Auto-assigns `user_id = get_current_user()`
- Requires authentication via @require_auth decorator

---

### Function: list_tasks

**Modified Signature**:
```python
@require_auth
def list_tasks(filters: dict = None) -> list[dict]:
    """
    List tasks filtered by current user_id.

    Args:
        filters: Optional additional filters

    Returns:
        List of tasks owned by current user

    Raises:
        AuthenticationError: If not authenticated
    """
```

**NEW Behavior**:
- Auto-filters by `user_id == get_current_user()`
- User cannot see tasks from other users

---

### Function: update_task

**Modified Signature**:
```python
@require_auth
def update_task(task_id: str, updates: dict) -> dict:
    """
    Update task if owned by current user.

    Args:
        task_id: Task ID to update
        updates: Fields to update

    Returns:
        Updated task dictionary

    Raises:
        AuthenticationError: If not authenticated
        PermissionError: If task.user_id != current user_id
        NotFoundError: If task not found
    """
```

**NEW Behavior**:
- Verifies `task.user_id == get_current_user()` before update
- Raises PermissionError if user doesn't own task

---

### Function: delete_task

**Modified Signature**:
```python
@require_auth
def delete_task(task_id: str) -> bool:
    """
    Delete task if owned by current user.

    Args:
        task_id: Task ID to delete

    Returns:
        True if deleted successfully

    Raises:
        AuthenticationError: If not authenticated
        PermissionError: If task.user_id != current user_id
        NotFoundError: If task not found
    """
```

**NEW Behavior**:
- Verifies `task.user_id == get_current_user()` before deletion
- Raises PermissionError if user doesn't own task

---

## Contract Summary

| Module | Function | Authentication Required | Returns | Raises |
|--------|----------|------------------------|---------|--------|
| authenticator | authenticate_user | No | bool | AuthenticationError, ConfigurationError |
| authenticator | prompt_for_credentials | No | None | SystemExit |
| session | is_authenticated | No | bool | None |
| session | get_current_user | Yes | str | SessionError |
| session | require_auth | - | Callable | AuthenticationError |
| credential_loader | load_credentials | No | dict | ConfigurationError |
| tasks | create_task | Yes | dict | AuthenticationError, ValidationError |
| tasks | list_tasks | Yes | list | AuthenticationError |
| tasks | update_task | Yes | dict | AuthenticationError, PermissionError, NotFoundError |
| tasks | delete_task | Yes | bool | AuthenticationError, PermissionError, NotFoundError |

---

## Next Steps

Proceed to quickstart.md generation (Phase 1):
- Setup instructions (.env configuration)
- Usage examples
- Troubleshooting guide
