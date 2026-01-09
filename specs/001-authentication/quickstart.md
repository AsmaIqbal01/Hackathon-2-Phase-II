# Quick Start: Authentication System

**Feature**: 001-authentication
**Date**: 2026-01-02
**Purpose**: Setup and usage guide for backend agent authentication

---

## Prerequisites

- Python 3.11 or higher
- Backend agent system installed
- Text editor for .env configuration

---

## Setup Instructions

### Step 1: Install Dependencies

```bash
pip install python-dotenv
```

**Note**: `getpass` is part of Python standard library (no installation needed)

### Step 2: Configure Credentials

Create a `.env` file in the backend project root:

```bash
# Navigate to backend directory
cd backend/

# Create .env file
touch .env
```

Edit `.env` with your credentials:

```ini
# .env - User credentials for authentication
AUTH_USERNAME=admin
AUTH_PASSPHRASE=mysecretpassphrase
AUTH_USER_ID=user-001
```

**Important**:
- Replace values with your desired credentials
- `AUTH_USER_ID` should be unique and stable
- `.env` file is gitignored (never commit this file)

### Step 3: Verify .gitignore

Ensure `.env` is in `.gitignore`:

```bash
# Check if .env is gitignored
cat .gitignore | grep ".env"
```

If not present, add it:

```bash
echo ".env" >> .gitignore
```

---

## Usage

### Basic Authentication Flow

When you start the backend agent application:

```
$ python app.py

Username: admin
Passphrase: (hidden input)

Authentication successful!
Welcome, admin

>
```

### Retry on Failure

If credentials are incorrect:

```
$ python app.py

Username: admin
Passphrase: (hidden input)

Error: Invalid username or passphrase
Retry? (y/n): y

Username: admin
Passphrase: (correct passphrase - hidden)

Authentication successful!
Welcome, admin

>
```

### Exit Option

```
Username: wronguser
Passphrase: (hidden input)

Error: Invalid username or passphrase
Retry? (y/n): n

Exiting application.
```

---

## Task Operations (After Authentication)

Once authenticated, all task operations automatically use your user_id:

### Create Task

```python
# Automatically assigns user_id from session
task = create_task(
    title="Complete authentication feature",
    description="Implement backend auth",
    priority="high"
)

# Result:
# {
#   "id": "task-123",
#   "user_id": "user-001",  # Auto-assigned
#   "title": "Complete authentication feature",
#   ...
# }
```

### List Tasks

```python
# Automatically filters by your user_id
tasks = list_tasks()

# Only shows tasks where task.user_id == "user-001"
```

### Update Task

```python
# Only succeeds if task.user_id matches your user_id
update_task("task-123", {"status": "in-progress"})

# Raises PermissionError if task belongs to another user
```

### Delete Task

```python
# Only succeeds if task.user_id matches your user_id
delete_task("task-123")

# Raises PermissionError if task belongs to another user
```

---

## Code Examples

### Application Startup (app.py)

```python
from auth.authenticator import prompt_for_credentials
from tasks.task_service import list_tasks, create_task

def main():
    # Prompt for authentication on startup
    prompt_for_credentials()

    # After this point, user is authenticated
    # All task operations will work

    # Example: List user's tasks
    tasks = list_tasks()
    print(f"You have {len(tasks)} tasks")

    # Example: Create a new task
    task = create_task(
        title="My first authenticated task",
        priority="medium"
    )
    print(f"Created task: {task['id']}")

if __name__ == "__main__":
    main()
```

### Custom Authentication Logic

```python
from auth.authenticator import authenticate_user
from auth.session import is_authenticated, get_current_user
from auth.exceptions import AuthenticationError

# Manual authentication
try:
    username = input("Username: ")
    passphrase = getpass.getpass("Passphrase: ")
    authenticate_user(username, passphrase)
except AuthenticationError as e:
    print(f"Failed: {e}")
    sys.exit(1)

# Check authentication status
if is_authenticated():
    user_id = get_current_user()
    print(f"Authenticated as: {user_id}")
```

### Protected Function Example

```python
from auth.session import require_auth, get_current_user

@require_auth
def my_protected_function():
    """This function requires authentication"""
    user_id = get_current_user()
    print(f"Hello, {user_id}!")
    # Function logic here

# Usage
try:
    my_protected_function()  # Works if authenticated
except AuthenticationError:
    print("Please authenticate first")
```

---

## Configuration Options

### Environment Variables (Alternative to .env)

Instead of `.env` file, set environment variables:

**Linux/macOS**:
```bash
export AUTH_USERNAME=admin
export AUTH_PASSPHRASE=mysecretpassphrase
export AUTH_USER_ID=user-001

python app.py
```

**Windows**:
```cmd
set AUTH_USERNAME=admin
set AUTH_PASSPHRASE=mysecretpassphrase
set AUTH_USER_ID=user-001

python app.py
```

**Windows PowerShell**:
```powershell
$env:AUTH_USERNAME="admin"
$env:AUTH_PASSPHRASE="mysecretpassphrase"
$env:AUTH_USER_ID="user-001"

python app.py
```

---

## Troubleshooting

### Error: "Configuration error - credentials not found"

**Cause**: .env file missing or AUTH_* variables not set

**Solution**:
1. Verify `.env` file exists in backend root
2. Check file contains AUTH_USERNAME, AUTH_PASSPHRASE, AUTH_USER_ID
3. Ensure python-dotenv is installed: `pip install python-dotenv`

### Error: "Invalid username or passphrase"

**Cause**: Provided credentials don't match .env configuration

**Solution**:
1. Double-check .env file for correct values
2. Verify no extra spaces or quotes around values in .env
3. Check case sensitivity (usernames are case-sensitive)

### Error: "Authentication required"

**Cause**: Attempting task operation before authentication

**Solution**:
1. Ensure `prompt_for_credentials()` called on app startup
2. Verify authentication succeeded before task operations
3. Check `is_authenticated()` returns True

### Error: "PermissionError: Task not owned by current user"

**Cause**: Attempting to modify/delete task belonging to different user_id

**Solution**:
- In single-user setup, this shouldn't happen
- If it does, check task.user_id matches AUTH_USER_ID in .env

---

## Security Best Practices

### DO:
- ✅ Keep .env file in .gitignore
- ✅ Use unique, strong passphrases
- ✅ Restrict .env file permissions: `chmod 600 .env` (Linux/macOS)
- ✅ Rotate credentials periodically

### DON'T:
- ❌ Commit .env file to version control
- ❌ Share .env file or passphrases
- ❌ Use simple/default passphrases in production
- ❌ Log or print passphrases

**Note**: This is plain passphrase storage (Phase II frozen scope). For production systems, migrate to hashed passwords + salt + JWT.

---

## Testing Your Setup

### Verify Configuration

```python
from auth.credential_loader import load_credentials

try:
    creds = load_credentials()
    print("Configuration loaded successfully!")
    print(f"Username: {creds['username']}")
    print(f"User ID: {creds['user_id']}")
    # Never print passphrase
except Exception as e:
    print(f"Configuration error: {e}")
```

### Test Authentication

```python
from auth.authenticator import authenticate_user
from auth.session import is_authenticated, get_current_user

# Test with correct credentials
try:
    authenticate_user("admin", "mysecretpassphrase")
    assert is_authenticated() == True
    assert get_current_user() == "user-001"
    print("✓ Authentication test passed")
except Exception as e:
    print(f"✗ Authentication test failed: {e}")
```

---

## Next Steps

After setup is complete:

1. **Run tests**: Execute authentication tests to verify setup
   ```bash
   pytest tests/auth/
   ```

2. **Implement tasks**: Use authenticated task operations
   - Create, read, update, delete tasks
   - All operations automatically scoped to your user_id

3. **Build features**: Authentication is ready for Phase II features
   - All task CRUD operations enforced
   - Session management handled automatically

---

## Support

For issues or questions:
- Review [spec.md](./spec.md) for requirements
- Check [contracts/auth.contract.md](./contracts/auth.contract.md) for function signatures
- Consult [data-model.md](./data-model.md) for entity details
- Review [research.md](./research.md) for design decisions
