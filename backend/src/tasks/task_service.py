"""
Task service with authentication integration.

This module demonstrates how Phase I task CRUD operations are modified
to integrate with Phase II authentication system.

IMPORTANT: These are MINIMAL STUB IMPLEMENTATIONS to show authentication
integration patterns. Full Phase I task logic should be imported from
the Phase I repository (https://github.com/AsmaIqbal01/Hackathon2-phase1).

Modifications from Phase I:
- Added @require_auth decorator to all CRUD operations
- Auto-assign user_id on task creation
- Filter tasks by user_id on list operations
- Verify task ownership on update/delete operations
"""

from auth.session import require_auth, get_current_user
from auth.exceptions import AuthenticationError


# In-memory task storage (Phase I would have actual persistence)
_tasks = []


@require_auth
def create_task(title: str, description: str = "", status: str = "pending",
                priority: str = "medium", tags: list = None) -> dict:
    """
    Create new task with automatic user_id assignment.

    Phase II Modification:
    - Added @require_auth decorator (T018)
    - Auto-assign user_id from get_current_user() (T019)

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

    Example:
        >>> task = create_task(title="Complete authentication feature")
        >>> print(task['user_id'])  # Auto-assigned from session
        user-001
    """
    # Get current authenticated user_id
    user_id = get_current_user()

    # Create task (Phase I logic would include full validation)
    task = {
        'id': f"task-{len(_tasks) + 1}",
        'user_id': user_id,  # NEW: Auto-assigned from session
        'title': title,
        'description': description,
        'status': status,
        'priority': priority,
        'tags': tags or [],
    }

    # Store task (Phase I would persist to database/file)
    _tasks.append(task)

    return task


@require_auth
def list_tasks(filters: dict = None) -> list:
    """
    List tasks filtered by current user_id.

    Phase II Modification:
    - Added @require_auth decorator (T020)
    - Auto-filter by user_id from get_current_user() (T021)

    Args:
        filters: Optional additional filters

    Returns:
        List of tasks owned by current user

    Raises:
        AuthenticationError: If not authenticated

    Example:
        >>> tasks = list_tasks()
        >>> # Only returns tasks where task['user_id'] matches current user
    """
    # Get current authenticated user_id
    user_id = get_current_user()

    # Filter tasks by user_id (Phase I logic would include additional filters)
    user_tasks = [
        task for task in _tasks
        if task.get('user_id') == user_id
    ]

    return user_tasks


@require_auth
def update_task(task_id: str, updates: dict) -> dict:
    """
    Update task if owned by current user.

    Phase II Modification:
    - Added @require_auth decorator (T022)
    - Verify task.user_id matches get_current_user() (T023)

    Args:
        task_id: Task ID to update
        updates: Fields to update

    Returns:
        Updated task dictionary

    Raises:
        AuthenticationError: If not authenticated
        PermissionError: If task.user_id != current user_id
        ValueError: If task not found

    Example:
        >>> update_task("task-1", {"status": "in-progress"})
        # Only succeeds if task belongs to current user
    """
    # Get current authenticated user_id
    user_id = get_current_user()

    # Find task (Phase I would query database/file)
    task = None
    for t in _tasks:
        if t['id'] == task_id:
            task = t
            break

    if not task:
        raise ValueError(f"Task not found: {task_id}")

    # Verify ownership (NEW: Phase II security check)
    if task.get('user_id') != user_id:
        raise PermissionError(f"Cannot modify task owned by another user")

    # Update task (Phase I logic would include validation)
    task.update(updates)

    return task


@require_auth
def delete_task(task_id: str) -> bool:
    """
    Delete task if owned by current user.

    Phase II Modification:
    - Added @require_auth decorator (T024)
    - Verify task.user_id matches get_current_user() (T025)

    Args:
        task_id: Task ID to delete

    Returns:
        True if deleted successfully

    Raises:
        AuthenticationError: If not authenticated
        PermissionError: If task.user_id != current user_id
        ValueError: If task not found

    Example:
        >>> delete_task("task-1")
        # Only succeeds if task belongs to current user
    """
    # Get current authenticated user_id
    user_id = get_current_user()

    # Find task (Phase I would query database/file)
    task = None
    task_index = None
    for i, t in enumerate(_tasks):
        if t['id'] == task_id:
            task = t
            task_index = i
            break

    if not task:
        raise ValueError(f"Task not found: {task_id}")

    # Verify ownership (NEW: Phase II security check)
    if task.get('user_id') != user_id:
        raise PermissionError(f"Cannot delete task owned by another user")

    # Delete task (Phase I logic would delete from database/file)
    _tasks.pop(task_index)

    return True
