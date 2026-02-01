# Feature Specification: Authentication & Security Integration

**Feature Branch**: `F01-S02-auth-security`
**Created**: 2026-01-25
**Status**: Draft
**Input**: User description: "Authentication & Security Integration for Full-Stack Todo Application"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - User Registration (Priority: P1)

As a new user, I want to create an account with my email and password so that I can securely access and manage my personal todo tasks.

**Why this priority**: Registration is the entry point for all authenticated functionality. Without user accounts, no authenticated features can be accessed. This establishes the user identity that all other features depend on.

**Independent Test**: Can be fully tested by submitting a registration form with email and password, verifying account creation, and confirming the user can subsequently log in. Delivers immediate value by enabling user identity.

**Acceptance Scenarios**:

1. **Given** I am a new visitor on the registration page, **When** I submit a valid email and password (min 8 chars, at least one letter and one number), **Then** my account is created, I receive a success confirmation, and I am automatically logged in with valid tokens.

2. **Given** I am on the registration page, **When** I submit an email that already exists in the system, **Then** I receive a clear error message indicating the email is already registered, and no duplicate account is created.

3. **Given** I am on the registration page, **When** I submit a password that does not meet security requirements, **Then** I receive a clear error message listing the specific requirements not met.

4. **Given** I am on the registration page, **When** I submit an invalid email format, **Then** I receive a validation error before any server request is made.

---

### User Story 2 - User Login (Priority: P1)

As a registered user, I want to log in with my credentials so that I can access my personal todo tasks securely.

**Why this priority**: Login is equally critical as registration - it's the mechanism for returning users to access their data. Combined with US1, these form the authentication foundation.

**Independent Test**: Can be fully tested by entering valid credentials and verifying successful authentication with token issuance. Delivers immediate value by granting authenticated access.

**Acceptance Scenarios**:

1. **Given** I am a registered user on the login page, **When** I enter my correct email and password, **Then** I am authenticated, receive an access token and refresh token, and am redirected to my dashboard.

2. **Given** I am on the login page, **When** I enter an incorrect password for a valid email, **Then** I receive a generic error message "Invalid credentials" (not revealing whether email exists) and no tokens are issued.

3. **Given** I am on the login page, **When** I enter an email that doesn't exist, **Then** I receive the same generic error message "Invalid credentials" to prevent user enumeration.

4. **Given** I have failed 5 login attempts within 15 minutes for the same email, **When** I attempt another login, **Then** I am temporarily blocked with a message indicating when I can retry.

---

### User Story 3 - Token-Based Session Management (Priority: P1)

As an authenticated user, I want my session to persist across browser refreshes and be automatically renewed so that I don't need to log in repeatedly during normal use.

**Why this priority**: Token management is critical infrastructure for maintaining user sessions. Without it, users would lose authentication on every page refresh, making the app unusable.

**Independent Test**: Can be tested by logging in, refreshing the browser, and verifying the session persists. Also by waiting for access token expiry and verifying automatic renewal via refresh token.

**Acceptance Scenarios**:

1. **Given** I am logged in with valid tokens, **When** I refresh the browser or navigate to a new page, **Then** my session persists and I remain authenticated.

2. **Given** my access token has expired but my refresh token is valid, **When** I make an API request, **Then** the system automatically refreshes my access token and the request succeeds transparently.

3. **Given** my refresh token has expired, **When** I attempt any authenticated action, **Then** I am redirected to the login page with a message indicating my session has expired.

4. **Given** I am logged in, **When** I explicitly log out, **Then** both my access and refresh tokens are invalidated and cannot be reused.

---

### User Story 4 - Protected Resource Access (Priority: P1)

As an authenticated user, I want to access only my own tasks so that my data is protected from other users.

**Why this priority**: This is the core security requirement - ensuring user data isolation. It directly integrates with F01-S01 (Backend API) to enforce ownership.

**Independent Test**: Can be tested by creating tasks as User A, attempting to access them as User B, and verifying access is denied. Delivers the fundamental security guarantee.

**Acceptance Scenarios**:

1. **Given** I am authenticated as user "alice@example.com", **When** I request GET /api/tasks, **Then** I receive only tasks where user_id matches my authenticated identity.

2. **Given** I am authenticated as user "alice@example.com" and a task exists owned by "bob@example.com", **When** I attempt to GET/PATCH/DELETE that task by ID, **Then** I receive a 403 Forbidden response.

3. **Given** I am not authenticated (no token), **When** I attempt to access any /api/tasks endpoint, **Then** I receive a 401 Unauthorized response.

4. **Given** I am authenticated with an expired access token and no valid refresh token, **When** I attempt to access protected resources, **Then** I receive a 401 Unauthorized response.

---

### User Story 5 - Secure Logout (Priority: P2)

As an authenticated user, I want to securely log out so that my session cannot be used by others if I leave a shared device.

**Why this priority**: Important for security but not blocking other functionality. Users can close browsers as a workaround, but explicit logout provides security assurance.

**Independent Test**: Can be tested by logging in, logging out, and verifying the tokens no longer grant access.

**Acceptance Scenarios**:

1. **Given** I am logged in, **When** I click the logout button, **Then** my access token and refresh token are invalidated server-side, tokens are removed from client storage, and I am redirected to the login page.

2. **Given** I have logged out, **When** I attempt to use my old access token, **Then** the request fails with 401 Unauthorized.

3. **Given** I have logged out, **When** I attempt to use my old refresh token to obtain new tokens, **Then** the request fails with 401 Unauthorized.

---

### User Story 6 - Get Current User Info (Priority: P2)

As an authenticated user, I want to retrieve my profile information so that I can verify my identity and see my account details.

**Why this priority**: Useful for UI personalization and identity confirmation, but not blocking core task management functionality.

**Independent Test**: Can be tested by logging in and calling the /api/auth/me endpoint to verify correct user info is returned.

**Acceptance Scenarios**:

1. **Given** I am authenticated, **When** I request GET /api/auth/me, **Then** I receive my user profile (id, email, created_at) without sensitive data (no password hash).

2. **Given** I am not authenticated, **When** I request GET /api/auth/me, **Then** I receive 401 Unauthorized.

---

### Edge Cases

- **Token Tampering**: What happens when a JWT signature is invalid? System MUST reject with 401 Unauthorized.
- **Concurrent Sessions**: What happens when user logs in from multiple devices? All sessions remain valid independently until tokens expire or explicit logout.
- **Clock Skew**: What happens when client/server clocks differ? System MUST allow 30-second tolerance for token expiration checks.
- **Refresh During Request**: What happens if refresh token expires mid-request? Request fails with 401; client must re-authenticate.
- **Case Sensitivity**: Email addresses are treated as case-insensitive for lookup (normalized to lowercase).
- **Empty/Null Tokens**: Requests with empty or null Authorization headers are treated as unauthenticated (401).
- **Malformed Tokens**: Tokens that are not valid JWTs return 401 with message "Invalid token format".
- **Rate Limiting Bypass**: What if attacker uses multiple IPs? Rate limiting is per-email, not per-IP, to protect against distributed attacks.

## Requirements *(mandatory)*

### Functional Requirements

#### User Management

- **FR-001**: System MUST allow users to register with email and password.
- **FR-002**: System MUST validate email format and uniqueness during registration.
- **FR-003**: System MUST enforce password requirements: minimum 8 characters, at least one letter and one number.
- **FR-004**: System MUST store passwords using bcrypt with a cost factor of at least 12.
- **FR-005**: System MUST normalize email addresses to lowercase before storage and comparison.

#### Authentication

- **FR-006**: System MUST authenticate users via email and password, returning JWT access and refresh tokens on success.
- **FR-007**: System MUST issue access tokens with 15-minute expiration.
- **FR-008**: System MUST issue refresh tokens with 7-day expiration.
- **FR-009**: System MUST include user_id and email claims in access token payload.
- **FR-010**: System MUST NOT include sensitive data (password hash, internal IDs beyond user_id) in JWT payload.
- **FR-011**: System MUST sign JWTs using HS256 algorithm with a secure secret key (minimum 32 characters).
- **FR-012**: System MUST return 401 Unauthorized for invalid, expired, or malformed tokens.

#### Token Management

- **FR-013**: System MUST provide a token refresh endpoint that issues new access tokens when given a valid refresh token.
- **FR-014**: System MUST invalidate refresh tokens on logout (token blacklist or database deletion).
- **FR-015**: System MUST reject refresh tokens that have been used after logout.
- **FR-016**: System MUST support refresh token rotation: issuing a new refresh token when refreshing, invalidating the old one.

#### Authorization

- **FR-017**: System MUST extract user_id from verified JWT and inject it into all protected endpoint handlers.
- **FR-018**: System MUST filter all task queries by the authenticated user_id (integration with F01-S01).
- **FR-019**: System MUST return 403 Forbidden when a user attempts to access resources owned by another user.
- **FR-020**: System MUST return 401 Unauthorized for requests without valid authentication.

#### Security Controls

- **FR-021**: System MUST implement login rate limiting: max 5 failed attempts per email per 15 minutes.
- **FR-022**: System MUST log all authentication events (login success, login failure, logout, token refresh).
- **FR-023**: System MUST return generic error messages for authentication failures to prevent user enumeration.
- **FR-024**: System MUST use secure HTTP-only cookies OR Authorization header for token transmission (Authorization header chosen for API-first architecture).

#### API Contract

- **FR-025**: System MUST expose POST /api/auth/register for user registration.
- **FR-026**: System MUST expose POST /api/auth/login for user authentication.
- **FR-027**: System MUST expose POST /api/auth/logout for session termination.
- **FR-028**: System MUST expose POST /api/auth/refresh for token renewal.
- **FR-029**: System MUST expose GET /api/auth/me for retrieving authenticated user profile.
- **FR-030**: System MUST return consistent JSON error responses with structure: `{"error": {"code": int, "message": string}}`.

### Key Entities *(include if feature involves data)*

- **User**: Represents an authenticated user in the system.
  - `id` (UUID, primary key): Unique identifier for the user
  - `email` (string, unique, indexed): User's email address (normalized to lowercase)
  - `password_hash` (string): Bcrypt-hashed password (never exposed via API)
  - `created_at` (datetime): Account creation timestamp
  - `updated_at` (datetime): Last profile update timestamp

- **RefreshToken**: Represents an active refresh token for session management.
  - `id` (UUID, primary key): Unique identifier for the token record
  - `user_id` (UUID, foreign key → User): Owner of the token
  - `token_hash` (string): Hashed refresh token for secure storage
  - `expires_at` (datetime): Token expiration timestamp
  - `created_at` (datetime): Token issuance timestamp
  - `revoked_at` (datetime, nullable): Revocation timestamp (null if active)

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete registration in under 30 seconds with valid inputs.
- **SC-002**: Users can log in and receive tokens in under 2 seconds under normal load.
- **SC-003**: Token refresh completes transparently without user-visible delay (< 500ms).
- **SC-004**: 100% of unauthenticated requests to protected endpoints return 401.
- **SC-005**: 100% of cross-user access attempts return 403.
- **SC-006**: System correctly blocks login after 5 failed attempts within 15 minutes.
- **SC-007**: All passwords are stored using bcrypt with no plaintext storage.
- **SC-008**: Logged-out users cannot reuse their previous tokens for any operation.
- **SC-009**: Token expiration is enforced: expired access tokens are rejected immediately.
- **SC-010**: Integration with F01-S01 is seamless: replacing temporary user_id parameter with JWT-based authentication requires no changes to task business logic.

## Assumptions

- **Database Availability**: PostgreSQL (Neon) is provisioned and accessible.
- **Frontend Ready for Integration**: Next.js frontend will implement token storage (memory for access token, httpOnly cookie or localStorage for refresh token based on security requirements).
- **HTTPS in Production**: All authentication traffic will use HTTPS in production (HTTP acceptable for local development only).
- **Single-tenant**: This spec assumes single-tenant operation; multi-tenant support would require additional scoping.
- **Email as Identifier**: Email serves as the unique user identifier; username-based login is not supported.
- **No Email Verification**: Email verification is deferred to a future spec; registration is immediate.
- **No Password Recovery**: Password reset flows are deferred to a future spec.
- **Server Clock Accuracy**: Server time is reasonably accurate (within 30 seconds of actual time) for token expiration.

## Dependencies

- **F01-S01 Backend API & Database**: Task endpoints from Spec 1 must be updated to use JWT authentication instead of temporary user_id parameter.
- **Python Libraries**: PyJWT for token handling, bcrypt/passlib for password hashing.
- **Environment Configuration**: JWT_SECRET must be configured in environment variables.

## Out of Scope

The following features are explicitly OUT OF SCOPE for this specification:

1. **OAuth/Social Login**: Google, GitHub, or other third-party authentication.
2. **Multi-Factor Authentication (MFA)**: 2FA/TOTP/SMS verification.
3. **Email Verification**: Confirming email ownership before account activation.
4. **Password Recovery**: Forgot password / reset password flows.
5. **Admin Roles**: Role-based access control beyond owner-based authorization.
6. **Account Deletion**: User self-service account deletion.
7. **Profile Updates**: Changing email or other profile fields.
8. **Session Management UI**: Viewing/revoking sessions from other devices.
9. **Advanced Rate Limiting**: Distributed rate limiting, CAPTCHA integration.
10. **Audit Logging UI**: Viewing authentication history.

---

## API Contract Details

### POST /api/auth/register

**Description**: Register a new user account.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Response (201 Created)**:
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com",
    "created_at": "2026-01-25T10:30:00Z"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Error Responses**:
- 400 Bad Request: Invalid email format or weak password
- 409 Conflict: Email already registered

---

### POST /api/auth/login

**Description**: Authenticate user and issue tokens.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Response (200 OK)**:
```json
{
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "email": "user@example.com"
  },
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Error Responses**:
- 401 Unauthorized: Invalid credentials
- 429 Too Many Requests: Rate limit exceeded

---

### POST /api/auth/logout

**Description**: Invalidate current session tokens.

**Headers**:
```
Authorization: Bearer <access_token>
```

**Request Body**: None required (can optionally include refresh_token for explicit revocation)

**Response (204 No Content)**: Empty body

**Error Responses**:
- 401 Unauthorized: Invalid or missing token

---

### POST /api/auth/refresh

**Description**: Obtain new access token using refresh token.

**Request**:
```json
{
  "refresh_token": "dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4..."
}
```

**Response (200 OK)**:
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "refresh_token": "bmV3IHJlZnJlc2ggdG9rZW4...",
  "token_type": "bearer",
  "expires_in": 900
}
```

**Error Responses**:
- 401 Unauthorized: Invalid or expired refresh token

---

### GET /api/auth/me

**Description**: Get current authenticated user profile.

**Headers**:
```
Authorization: Bearer <access_token>
```

**Response (200 OK)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "created_at": "2026-01-25T10:30:00Z"
}
```

**Error Responses**:
- 401 Unauthorized: Invalid or missing token

---

## JWT Structure

### Access Token Payload

```json
{
  "sub": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "type": "access",
  "iat": 1706178600,
  "exp": 1706179500
}
```

**Claims**:
- `sub` (subject): User ID (UUID)
- `email`: User's email address
- `type`: Token type ("access" or "refresh")
- `iat` (issued at): Unix timestamp of token creation
- `exp` (expiration): Unix timestamp of token expiry

### Refresh Token

Refresh tokens are opaque strings stored hashed in the database, not JWTs. This allows for:
- Immediate revocation (database lookup)
- No sensitive data exposure if token is intercepted
- Rotation tracking (old tokens invalidated on refresh)

---

## Integration with F01-S01 (Backend API & Database)

### Migration from Temporary user_id to JWT

**Current State (F01-S01)**:
```python
# All endpoints accept user_id as query param or header
def get_user_id(
    user_id: str | None = Query(None),
    x_user_id: str | None = Header(None, alias="X-User-ID")
) -> str:
    # Returns user_id from param or header
```

**Target State (F01-S02)**:
```python
# All endpoints extract user_id from verified JWT
def get_current_user(
    authorization: str = Header(..., alias="Authorization")
) -> User:
    # Verify JWT, extract user_id, return User object
```

### Changes Required in F01-S01

1. **Replace `get_user_id` dependency** with `get_current_user` that extracts from JWT
2. **Update all task endpoints** to use the new dependency (signature change only)
3. **TaskService** remains unchanged - it already accepts `user_id` parameter
4. **No business logic changes** - service layer isolation preserved

---

## Security Considerations

### Token Storage (Frontend)

**Recommendation**:
- **Access Token**: Store in memory (JavaScript variable) - never persists beyond session
- **Refresh Token**: Store in httpOnly cookie with `Secure`, `SameSite=Strict` flags

**Rationale**: Prevents XSS attacks from accessing tokens. Refresh tokens in httpOnly cookies are not accessible to JavaScript.

### Brute Force Protection

- Rate limiting: 5 attempts per email per 15-minute window
- Generic error messages prevent user enumeration
- Logging of failed attempts enables monitoring and incident response

### Token Security

- Access tokens expire quickly (15 min) limiting exposure window
- Refresh token rotation prevents token reuse after refresh
- Token blacklist/revocation on logout ensures immediate session termination
- No sensitive data in JWT payload (password hash, internal details)

---

**Next Steps**: Run `/sp.plan` to generate the implementation plan for this specification.
