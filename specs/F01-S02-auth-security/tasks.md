# Tasks: F01-S02 Authentication & Security Integration

**Input**: Design documents from `/specs/F01-S02-auth-security/`
**Prerequisites**: plan.md (complete), spec.md (complete), research.md (complete), data-model.md (complete), contracts/auth-api.yaml (complete)

**Tests**: Not explicitly requested in spec - implementation tasks only.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Web app**: `backend/src/`, `backend/tests/` (existing F01-S01 structure)
- Paths follow existing backend/ structure from F01-S01

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Configuration and dependency updates for authentication

- [X] T001 Add PyJWT and passlib[bcrypt] to backend/requirements.txt
- [X] T002 [P] Add JWT configuration settings (JWT_SECRET, JWT_ALGORITHM, JWT_ACCESS_EXPIRE_MINUTES, JWT_REFRESH_EXPIRE_DAYS) to backend/src/config.py
- [X] T003 [P] Update backend/config/.env.example with JWT environment variables

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core authentication infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 [P] Create User SQLModel in backend/src/models/user.py with id, email, password_hash, created_at, updated_at fields
- [X] T005 [P] Create RefreshToken SQLModel in backend/src/models/refresh_token.py with id, user_id, token_hash, expires_at, created_at, revoked_at fields
- [X] T006 [P] Create password hashing utilities (hash_password, verify_password) using passlib[bcrypt] in backend/src/utils/security.py
- [X] T007 [P] Create JWT utilities (create_access_token, verify_token) using PyJWT in backend/src/utils/security.py
- [X] T008 [P] Create refresh token utilities (generate_refresh_token, verify_refresh_token_hash) in backend/src/utils/security.py
- [X] T009 [P] Create login rate limiter class (LoginRateLimiter) in backend/src/utils/rate_limiter.py
- [X] T010 Create auth request schemas (RegisterRequest, LoginRequest, RefreshRequest) in backend/src/schemas/auth_schemas.py
- [X] T011 [P] Create auth response schemas (AuthResponse, TokenResponse, UserProfile) in backend/src/schemas/auth_schemas.py
- [X] T012 Update backend/src/models/__init__.py to export User and RefreshToken models
- [X] T013 Update backend/src/database.py to include User and RefreshToken tables in create_db_and_tables()

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - User Registration (Priority: P1)

**Goal**: Allow new users to create accounts with email and password

**Independent Test**: Submit registration form with valid credentials, verify account creation, and confirm user can log in afterward

### Implementation for User Story 1

- [X] T014 [US1] Implement email validation (format, normalization to lowercase) in backend/src/utils/security.py
- [X] T015 [US1] Implement password validation (min 8 chars, at least one letter and number) in backend/src/utils/security.py
- [X] T016 [US1] Create AuthService.register() method in backend/src/services/auth_service.py that validates input, checks email uniqueness, hashes password, creates user, and returns tokens
- [X] T017 [US1] Implement POST /api/auth/register endpoint in backend/src/api/routes/auth.py returning 201 with AuthResponse
- [X] T018 [US1] Add 400 error handling for invalid email format in register endpoint
- [X] T019 [US1] Add 400 error handling for weak password in register endpoint
- [X] T020 [US1] Add 409 error handling for duplicate email in register endpoint

**Checkpoint**: User Story 1 complete - registration works independently

---

## Phase 4: User Story 2 - User Login (Priority: P1)

**Goal**: Allow registered users to authenticate and receive tokens

**Independent Test**: Enter valid credentials for an existing user, verify successful authentication with token issuance

### Implementation for User Story 2

- [X] T021 [US2] Create AuthService.login() method in backend/src/services/auth_service.py that validates credentials, checks rate limiting, and returns tokens
- [X] T022 [US2] Implement POST /api/auth/login endpoint in backend/src/api/routes/auth.py returning 200 with AuthResponse
- [X] T023 [US2] Add 401 error handling for invalid credentials (generic message) in login endpoint
- [X] T024 [US2] Add 429 error handling with Retry-After header for rate-limited login attempts

**Checkpoint**: User Story 2 complete - login works independently

---

## Phase 5: User Story 3 - Token-Based Session Management (Priority: P1)

**Goal**: Enable session persistence via token refresh with rotation

**Independent Test**: Log in, wait for access token expiry, call refresh endpoint, verify new tokens are issued

### Implementation for User Story 3

- [X] T025 [US3] Create AuthService.refresh_tokens() method in backend/src/services/auth_service.py that validates refresh token, rotates it, and returns new token pair
- [X] T026 [US3] Implement POST /api/auth/refresh endpoint in backend/src/api/routes/auth.py returning 200 with TokenResponse
- [X] T027 [US3] Add 401 error handling for invalid or expired refresh token

**Checkpoint**: User Story 3 complete - token refresh works independently

---

## Phase 6: User Story 4 - Protected Resource Access (Priority: P1)

**Goal**: Integrate JWT authentication with existing task endpoints from F01-S01

**Independent Test**: Create tasks as User A, attempt to access them as User B, verify 403 Forbidden. Attempt without token, verify 401 Unauthorized.

### Implementation for User Story 4

- [X] T028 [US4] Create get_current_user() dependency in backend/src/api/deps.py that extracts and verifies JWT from Authorization header
- [X] T029 [US4] Add AuthError custom exception class in backend/src/utils/errors.py for 401 errors
- [X] T030 [US4] Add global exception handler for AuthError in backend/src/main.py
- [X] T031 [US4] Update backend/src/api/routes/tasks.py to use get_current_user dependency instead of get_user_id
- [X] T032 [US4] Pass user.id (as string) to TaskService methods in task routes
- [X] T033 [US4] Verify 401 response for missing Authorization header on task endpoints
- [X] T034 [US4] Verify 401 response for expired/invalid JWT on task endpoints
- [X] T035 [US4] Verify 403 response for cross-user task access attempts

**Checkpoint**: User Story 4 complete - protected resource access works with JWT

---

## Phase 7: User Story 5 - Secure Logout (Priority: P2)

**Goal**: Allow users to securely invalidate their tokens

**Independent Test**: Log in, call logout endpoint, attempt to use old tokens, verify 401 Unauthorized

### Implementation for User Story 5

- [X] T036 [US5] Create AuthService.logout() method in backend/src/services/auth_service.py that revokes all refresh tokens for user
- [X] T037 [US5] Implement POST /api/auth/logout endpoint in backend/src/api/routes/auth.py returning 204 No Content
- [X] T038 [US5] Add 401 error handling for invalid token on logout

**Checkpoint**: User Story 5 complete - logout works independently

---

## Phase 8: User Story 6 - Get Current User Info (Priority: P2)

**Goal**: Allow authenticated users to retrieve their profile information

**Independent Test**: Log in, call /api/auth/me endpoint, verify correct user profile is returned without sensitive data

### Implementation for User Story 6

- [X] T039 [US6] Create AuthService.get_user_profile() method in backend/src/services/auth_service.py returning UserProfile
- [X] T040 [US6] Implement GET /api/auth/me endpoint in backend/src/api/routes/auth.py returning 200 with UserProfile
- [X] T041 [US6] Verify password_hash is NOT included in response

**Checkpoint**: User Story 6 complete - user profile endpoint works

---

## Phase 9: Polish & Cross-Cutting Concerns

**Purpose**: Final integration and documentation updates

- [X] T042 Register auth router with /api/auth prefix in backend/src/main.py
- [X] T043 [P] Add authentication event logging (login success, login failure, logout, token refresh) in auth_service.py
- [X] T044 [P] Update backend/README.md with auth endpoint documentation and JWT setup instructions
- [X] T045 Remove deprecated get_user_id function from backend/src/api/deps.py (replaced by get_current_user)
- [X] T046 Run quickstart.md validation scenarios manually to verify all endpoints work as documented

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3-8)**: All depend on Foundational phase completion
  - US1 (Registration) can start after Foundational
  - US2 (Login) can start after Foundational (independent of US1)
  - US3 (Token Refresh) can start after Foundational (independent)
  - US4 (Protected Access) should start after US1/US2 for complete testing
  - US5 (Logout) should start after US3 for token context
  - US6 (Get User) can start after US4 (uses same auth dependency)
- **Polish (Phase 9)**: Depends on all user stories being complete

### User Story Dependencies

| Story | Depends On | Can Start After |
|-------|------------|-----------------|
| US1 (Registration) | Foundational | Phase 2 complete |
| US2 (Login) | Foundational | Phase 2 complete |
| US3 (Token Refresh) | Foundational | Phase 2 complete |
| US4 (Protected Access) | Foundational, ideally US1+US2 | Phase 2, best after Phase 4 |
| US5 (Logout) | Foundational, ideally US3 | Phase 2, best after Phase 5 |
| US6 (Get User) | US4 (get_current_user dep) | Phase 6 complete |

### Within Each User Story

- Service methods before route handlers
- Validation before business logic
- Happy path before error handling
- Core implementation before edge cases

### Parallel Opportunities

**Phase 1 (Setup)**:
- T002 and T003 can run in parallel

**Phase 2 (Foundational)**:
- T004, T005, T006, T007, T008, T009 can all run in parallel (different files)
- T010 and T011 can run in parallel (same file but different sections)

**Across User Stories (after Phase 2)**:
- US1, US2, US3 can start in parallel (different endpoints, services)
- US5, US6 can run in parallel after US4

---

## Parallel Example: Foundational Phase

```bash
# Launch all model creation tasks together:
Task: "Create User SQLModel in backend/src/models/user.py"
Task: "Create RefreshToken SQLModel in backend/src/models/refresh_token.py"

# Launch all utility tasks together:
Task: "Create password hashing utilities in backend/src/utils/security.py"
Task: "Create JWT utilities in backend/src/utils/security.py"
Task: "Create refresh token utilities in backend/src/utils/security.py"
Task: "Create login rate limiter in backend/src/utils/rate_limiter.py"
```

---

## Implementation Strategy

### MVP First (US1 + US2 + US4)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: User Story 1 (Registration)
4. Complete Phase 4: User Story 2 (Login)
5. Complete Phase 6: User Story 4 (Protected Access)
6. **STOP and VALIDATE**: Test registration → login → access tasks
7. Deploy/demo if ready (minimal viable auth)

### Full Implementation

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Registration works
3. Add User Story 2 → Login works
4. Add User Story 3 → Token refresh works
5. Add User Story 4 → Task endpoints use JWT
6. Add User Story 5 → Logout works
7. Add User Story 6 → User profile endpoint works
8. Complete Polish → Documentation and cleanup

---

## Summary

| Phase | Tasks | Parallel | Stories |
|-------|-------|----------|---------|
| 1. Setup | 3 | 2 | - |
| 2. Foundational | 10 | 8 | - |
| 3. US1 Registration | 7 | - | US1 |
| 4. US2 Login | 4 | - | US2 |
| 5. US3 Token Refresh | 3 | - | US3 |
| 6. US4 Protected Access | 8 | - | US4 |
| 7. US5 Logout | 3 | - | US5 |
| 8. US6 Get User | 3 | - | US6 |
| 9. Polish | 5 | 2 | - |
| **TOTAL** | **46** | **12** | **6** |

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence

---

## Implementation Complete

**Status**: ALL 46 TASKS COMPLETED ✓

All authentication and security integration tasks have been successfully implemented:
- JWT-based authentication system
- User registration and login
- Token refresh with rotation
- Secure logout
- Protected task endpoints
- User profile retrieval

The authentication service and logging have been integrated throughout the codebase.
