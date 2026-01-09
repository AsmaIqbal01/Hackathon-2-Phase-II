# Authentication Skill

## Responsibilities
- Prompt for credentials
- Validate credentials
- Create session context
- Expose authenticated user_id

## Functions
- authenticate_user()
- is_authenticated()
- get_current_user()

## Rules
- Authentication must occur before any task operation
- Session is valid for runtime duration
- On exit, session is destroyed

## Errors
- Invalid credentials
- Authentication required
