# Implementation Plan: Authentication System

**Branch**: `001-authentication` | **Date**: 2026-01-02 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-authentication/spec.md`

**Note**: This plan implements the FROZEN authentication scope for Phase II.

## Summary

Implement minimal authentication layer for backend agent system with single local user support. Backend agent will prompt for username/passphrase on startup, validate against configuration/environment storage, create session context, and enforce authentication for all task CRUD operations. Session persists for application lifetime with user_id attached to all task operations.

**Frozen Scope**:
- Single local user only
- Backend agent system
- Username + passphrase authentication
- Configuration/environment credential storage
- All task operations require authentication

## Technical Context

**Language/Version**: Python 3.11+ (backend agent system)
**Primary Dependencies**:
- python-dotenv (environment variable loading)
- getpass (secure passphrase input)
- Phase I task CRUD logic (to be modified)

**Storage**: Configuration file (.env) or environment variables for credentials; in-memory session context
**Testing**: pytest for backend agent authentication tests
**Target Platform**: Backend agent runtime environment (console/API-driven)
**Project Type**: Single project - backend agent enhancement
**Performance Goals**: <1s authentication prompt, <1s credential validation
**Constraints**: Single-user only, runtime session only (no persistence), configuration-based credentials
**Scale/Scope**: Single local user, backend agent system only

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### Phase II Constitution Compliance

**I. Spec-Driven Development Only**: ✅ PASS
- Specification created and frozen at `specs/001-authentication/spec.md`
- All implementation traceable to spec requirements

**II. Reuse Over Reinvention**: ✅ PASS
- Reusing Phase I task CRUD logic (modified with user_id filtering)
- Reusing Backend Agent System patterns for validation and error handling
- Auth skill artifact defined in `reusable_intelligence/auth.skill.md`

**III. Amendment-Based Development**: ✅ PASS
- Only modifying task operations to add authentication checks
- Not re-implementing existing task validation or business logic

**IV. Multi-User Data Ownership**: ⚠️ DEFERRED
- Constitution mandates multi-user with user-scoped queries
- **Frozen scope limits to single user** (architectural decision)
- **Justification**: Phase II authentication is intentionally minimal; full multi-user deferred
- Task entity will include user_id field for future multi-user support

**V. Stateless Authentication**: ⚠️ DEFERRED
- Constitution mandates JWT-based stateless auth
- **Frozen scope uses in-memory session context** (architectural decision)
- **Justification**: Session-based auth simpler for single-user backend agent
- No JWT, no Better Auth integration in this phase

**VI. Web-First Architecture**: ⚠️ DEFERRED
- Constitution mandates Next.js frontend + FastAPI backend
- **Frozen scope is backend agent only** (no web UI)
- **Justification**: Authentication implemented in backend agent system first
- Web layer integration deferred to future phase

**VII. Test-Driven Development**: ✅ PASS (when tests requested)
- Tests written first, verified to fail, then implementation
- Contract and integration tests for auth enforcement

**VIII. Observability & Error Handling**: ✅ PASS
- Clear error messages for invalid credentials
- Authentication required errors for unauthenticated access
- Structured error handling following Backend Agent System patterns

### Complexity Justification

| Constitutional Principle | Frozen Scope Deviation | Justification |
|--------------------------|------------------------|---------------|
| IV. Multi-User Data Ownership | Single user only | Intentional simplification - multi-user deferred; task model includes user_id for future expansion |
| V. Stateless Authentication | Session-based (in-memory) | Single-user backend agent doesn't require JWT; session simpler and sufficient |
| VI. Web-First Architecture | Backend agent only | Authentication logic implemented in backend first; web UI integration deferred |

**Overall Gate Status**: ✅ **PASS WITH JUSTIFICATIONS**
- Core principles (I, II, III, VII, VIII) compliant
- Deviations (IV, V, VI) justified by frozen architectural scope
- Future migration path clear (multi-user, JWT, web UI)

## Project Structure

### Documentation (this feature)

```text
specs/001-authentication/
├── plan.md              # This file
├── spec.md              # Feature specification (frozen)
├── research.md          # Phase 0 output (research findings)
├── data-model.md        # Phase 1 output (entities and relationships)
├── quickstart.md        # Phase 1 output (how to use authentication)
├── contracts/           # Phase 1 output (auth function contracts)
│   └── auth.contract.md
└── checklists/
    └── requirements.md  # Spec quality checklist (all passed)
```

### Source Code (repository root)

```text
backend/
├── src/
│   ├── auth/
│   │   ├── __init__.py
│   │   ├── authenticator.py      # Core authentication logic
│   │   ├── session.py             # Session context management
│   │   └── credential_loader.py   # Load credentials from config/env
│   ├── tasks/
│   │   └── task_service.py        # Modified with auth checks
│   └── config/
│       └── .env.example           # Example credentials file
└── tests/
    ├── auth/
    │   ├── test_authenticator.py
    │   ├── test_session.py
    │   └── test_credential_loader.py
    └── integration/
        └── test_auth_enforcement.py
```

**Structure Decision**: Single project structure with backend agent enhancements. Authentication module (`backend/src/auth/`) contains authenticator, session management, and credential loading. Task service modified to enforce authentication via session checks. Configuration stored in `.env` file following python-dotenv patterns.

## Phase 0: Research & Resolution

### Research Tasks

1. **Python authentication best practices for backend agents**
   - How to securely prompt for passphrases (getpass module)
   - Environment variable loading patterns (python-dotenv)
   - Session context management in Python applications

2. **Phase I task CRUD integration points**
   - Identify where to inject authentication checks
   - How to modify task operations to include user_id
   - Task filtering patterns for user-scoped queries

3. **Error handling patterns from Backend Agent System**
   - Authentication error message standards
   - Retry/exit flow implementation
   - Error propagation to task operations

### Research Findings

See [research.md](./research.md) for detailed findings.

## Phase 1: Design & Contracts

### Data Model

See [data-model.md](./data-model.md) for complete entity definitions.

**Key Entities**:
1. **User Credentials** (configuration/environment)
2. **Session Context** (in-memory runtime state)
3. **Task** (modified with user_id)

### API Contracts

See [contracts/auth.contract.md](./contracts/auth.contract.md) for function signatures.

**Core Functions**:
- `authenticate_user(username: str, passphrase: str) -> bool`
- `is_authenticated() -> bool`
- `get_current_user() -> str`

### Quick Start

See [quickstart.md](./quickstart.md) for usage instructions.

---

**Plan Status**: Ready for Phase 0 (Research)
**Next Command**: Continue with research.md generation
