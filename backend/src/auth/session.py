"""
Session context management for authentication system.

Implements auth.skill.md session requirements:
- Create session context
- Expose authenticated user_id
- Session valid for runtime duration
- Session destroyed on exit
"""

from functools import wraps
from .exceptions import SessionError, AuthenticationError


class SessionContext:
    """
    Active authenticated session in backend agent.

    Attributes:
        user_id: Authenticated user's identifier (from AUTH_USER_ID)
        username: Authenticated user's username (for display/logging)
        authenticated: Whether user is currently authenticated

    Lifecycle:
        - Created: On successful authentication
        - Active: Throughout application lifetime while process runs
        - Destroyed: On application exit (no persistence)
    """

    def __init__(self):
        """Initialize empty session context."""
        self.user_id = None
        self.username = None
        self.authenticated = False

    def login(self, username: str, user_id: str):
        """
        Create authenticated session.

        Args:
            username: Authenticated username
            user_id: Authenticated user_id

        Side Effects:
            Sets authenticated=True, assigns username and user_id
        """
        self.username = username
        self.user_id = user_id
        self.authenticated = True

    def logout(self):
        """
        Destroy session context.

        Side Effects:
            Clears username, user_id, sets authenticated=False
        """
        self.username = None
        self.user_id = None
        self.authenticated = False


# Global session instance (module-level singleton)
# Session persists for application runtime, cleared on exit
_session = SessionContext()


def is_authenticated() -> bool:
    """
    Check if user is currently authenticated.

    Following auth.skill.md specification: is_authenticated() function.

    Returns:
        True if authenticated, False otherwise

    Example:
        >>> if is_authenticated():
        ...     print("User is logged in")
        ... else:
        ...     print("Please authenticate first")
    """
    return _session.authenticated


def get_current_user() -> str:
    """
    Get the current authenticated user's user_id.

    Following auth.skill.md specification: get_current_user() function.

    Returns:
        user_id string

    Raises:
        SessionError: If not authenticated

    Example:
        >>> try:
        ...     user_id = get_current_user()
        ...     print(f"Current user: {user_id}")
        ... except SessionError:
        ...     print("Not authenticated")
    """
    if not _session.authenticated:
        raise SessionError("No authenticated session - authentication required")
    return _session.user_id


def require_auth(func):
    """
    Decorator to enforce authentication before function execution.

    Following auth.skill.md rule: "Authentication must occur before any task operation"

    Args:
        func: Function to wrap with authentication check

    Returns:
        Wrapped function that checks authentication first

    Raises:
        AuthenticationError: If not authenticated when function called

    Example:
        >>> @require_auth
        ... def create_task(title: str) -> dict:
        ...     user_id = get_current_user()
        ...     return {"id": "task-1", "user_id": user_id, "title": title}
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        if not is_authenticated():
            raise AuthenticationError("Authentication required - please authenticate first")
        return func(*args, **kwargs)
    return wrapper


# Internal access to session for authenticator module
def _get_session() -> SessionContext:
    """
    Internal function to access session for login/logout operations.

    Note: This is for internal use by authenticator module only.
    External code should use is_authenticated() and get_current_user().
    """
    return _session
