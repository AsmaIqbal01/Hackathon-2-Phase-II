# Claude Code Rules – Phase II: Todo Full-Stack Web Application

## Project Overview

**Project Name**: Evolution of Todo – Phase II
**Phase Objective**: Transform the Phase I console-based Todo application into a modern, multi-user, full-stack web application with persistent storage, authentication, and a RESTful API.

**Critical Constraint**: ALL implementation MUST be done via Claude Code using an Agentic Dev Stack workflow. NO manual coding is permitted.

---

## Phase II Objective

Transform the console-based Todo application into a production-ready web application that:

1. **Multi-User Support**: Enable multiple users to manage their own todos independently
2. **Persistent Storage**: Store data in Neon Serverless PostgreSQL
3. **Web Interface**: Provide a responsive, modern UI built with Next.js 16+
4. **RESTful API**: Expose backend functionality via FastAPI REST endpoints
5. **Secure Authentication**: Implement JWT-based authentication with Better Auth
6. **Data Isolation**: Enforce user-scoped data access at the backend layer

**What Stays the Same from Phase I**:
- Task CRUD logic (create, read, update, delete)
- Validation rules (title, description, status, priority, tags)
- Business rules (status transitions, tag management)
- Error messages for business logic

**What Changes for Phase II**:
- Storage: In-memory → PostgreSQL
- Interface: Console CLI → Web UI
- API: Direct function calls → REST endpoints
- Users: Single-user → Multi-user with authentication
- Sessions: Ephemeral → Persistent

---

## Agentic Dev Stack Workflow

### Core Principle: Spec-Driven Development Only

ALL code originates from specifications. The workflow is:

```
User Request → Specification → Plan → Tasks → Implementation → Validation
```

### Workflow Steps

1. **Write Specification First**
   - Command: `/sp.specify` or use `sp.specify` skill
   - Create `specs/<feature>/spec.md`
   - Define requirements, acceptance criteria, constraints
   - Reference Phase I logic where applicable

2. **Generate Implementation Plan**
   - Command: `/sp.plan` or use `sp.plan` skill
   - Create `specs/<feature>/plan.md`
   - Make architectural decisions
   - Choose technologies and patterns
   - Document interfaces and contracts

3. **Break Plan into Atomic Tasks**
   - Command: `/sp.tasks` or use `sp.tasks` skill
   - Create `specs/<feature>/tasks.md`
   - Generate testable, atomic implementation tasks
   - Include acceptance criteria per task
   - Order tasks by dependencies

4. **Implement Tasks Using Claude Code + Skills**
   - Command: `/sp.implement` or manual task execution
   - Use specialized agents (see Agent Responsibility Map below)
   - Implement one task at a time
   - Validate acceptance criteria after each task

5. **Iterate via Prompts Only**
   - NO manual code edits allowed
   - All changes requested via Claude Code
   - Update specs first, then regenerate tasks if needed

### Knowledge Capture (PHR)

After EVERY user interaction, create a Prompt History Record (PHR):

**PHR Routing**:
- Constitution changes → `history/prompts/constitution/`
- Feature work → `history/prompts/<feature-name>/`
- General work → `history/prompts/general/`

**PHR Process**:
1. Detect stage: `constitution | spec | plan | tasks | red | green | refactor | explainer | misc | general`
2. Generate title (3–7 words)
3. Read PHR template from `.specify/templates/phr-template.prompt.md`
4. Fill ALL placeholders (ID, TITLE, STAGE, DATE, MODEL, FEATURE, BRANCH, USER, etc.)
5. Include full user input and key assistant output
6. Write to appropriate location
7. Validate no placeholders remain

### Architecture Decision Records (ADR)

When significant architectural decisions are made (typically during planning):

**Test for ADR Significance**:
- **Impact**: Long-term consequences? (framework, data model, API, security, platform)
- **Alternatives**: Multiple viable options considered?
- **Scope**: Cross-cutting and influences system design?

If ALL true, suggest:
```
📋 Architectural decision detected: [brief-description]
   Document reasoning and tradeoffs? Run `/sp.adr [decision-title]`
```

Wait for user consent; NEVER auto-create ADRs.

---

## Technology Stack

### Frontend

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Framework | Next.js | 16+ | App Router, Server Components |
| Language | TypeScript | Latest | Type safety |
| Styling | Tailwind CSS | Latest | Utility-first CSS |
| Authentication | Better Auth | Latest | JWT token generation |
| HTTP Client | Custom API Client | - | Centralized fetch with JWT headers |
| State Management | React Hooks | - | useState, useContext (no Redux unless required) |

**Frontend Responsibilities**:
- User authentication UI (Better Auth)
- Responsive UI rendering
- Form validation (client-side for UX only)
- API requests with JWT headers
- Error display to users

### Backend

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Framework | Python FastAPI | Latest | REST API server |
| ORM | SQLModel | Latest | Database models and queries |
| Database | Neon Serverless PostgreSQL | Latest | Persistent storage |
| Authentication | JWT Verification | - | Validate tokens from Better Auth |
| Validation | Pydantic (via SQLModel) | Latest | Request/response validation |
| Migrations | Alembic | Latest | Schema version control |

**Backend Responsibilities**:
- JWT verification and user extraction
- Data persistence (PostgreSQL)
- Business logic enforcement
- Server-side validation (authoritative)
- API endpoint implementation
- User-scoped database queries

### Deployment

| Component | Platform | Purpose |
|-----------|----------|---------|
| Frontend | Vercel (preferred) | Next.js-optimized hosting |
| Backend | Railway / Render | Python FastAPI hosting |
| Database | Neon | Managed PostgreSQL |

---

## Authentication Architecture (JWT + Better Auth)

### Authentication Flow

```
┌──────────┐          ┌──────────────┐          ┌──────────┐
│ Frontend │          │ Better Auth  │          │ Backend  │
│ (Next.js)│          │              │          │ (FastAPI)│
└────┬─────┘          └──────┬───────┘          └────┬─────┘
     │                       │                       │
     │ 1. Login Request      │                       │
     ├──────────────────────>│                       │
     │                       │                       │
     │ 2. JWT Token          │                       │
     │<──────────────────────┤                       │
     │                       │                       │
     │ 3. API Request        │                       │
     │ Authorization: Bearer <token>                 │
     ├───────────────────────────────────────────────>
     │                       │                       │
     │                       │   4. Verify JWT       │
     │                       │   Extract user_id     │
     │                       │                       │
     │                       │   5. Query DB         │
     │                       │   (scoped to user_id) │
     │                       │                       │
     │ 6. Response (user's data only)                │
     │<───────────────────────────────────────────────┤
     │                       │                       │
```

### Frontend (Better Auth)

- **Issues JWT tokens** on successful login/signup
- **Stores tokens** securely (httpOnly cookies preferred, not localStorage)
- **Includes JWT** in `Authorization: Bearer <token>` header for ALL API calls
- **Handles token refresh** before expiration

### Backend (JWT Verification)

1. **Extract** `Authorization` header from incoming request
2. **Verify** JWT signature using shared secret with Better Auth
3. **Decode** token to extract claims (especially `user_id`)
4. **Attach** authenticated `user_id` to request context
5. **Return 401** if token is missing, expired, or invalid
6. **Scope all queries** to authenticated `user_id`

### Critical Security Rules

- **NEVER trust client-provided `user_id`**: Always extract from verified JWT
- **Backend enforces authorization**: Frontend UI is NOT a security boundary
- **All queries MUST filter by `user_id`**: Prevent cross-user access
- **Cross-user access returns 403 Forbidden**: Even if resource ID is valid
- **No session storage**: Backend remains stateless

---

## Backend Architecture (FastAPI + SQLModel)

### REST API Standards

**Base Path**: `/api`

**Endpoint Naming**:
- Resource-oriented: `/api/tasks`, `/api/tasks/{id}`
- Plural nouns for collections
- No verbs in URLs (use HTTP methods)

**HTTP Methods**:
| Method | Endpoint | Purpose | Auth Required |
|--------|----------|---------|---------------|
| GET | `/api/tasks` | List all tasks for user | Yes |
| POST | `/api/tasks` | Create new task for user | Yes |
| GET | `/api/tasks/{id}` | Get task by ID (if owned) | Yes |
| PATCH | `/api/tasks/{id}` | Update task (if owned) | Yes |
| DELETE | `/api/tasks/{id}` | Delete task (if owned) | Yes |

**Status Codes**:
- **200 OK**: Successful GET/PATCH
- **201 Created**: Successful POST
- **204 No Content**: Successful DELETE
- **400 Bad Request**: Invalid input (validation failure)
- **401 Unauthorized**: Missing or invalid JWT
- **403 Forbidden**: Cross-user access attempt
- **404 Not Found**: Resource doesn't exist
- **422 Unprocessable Entity**: Business logic violation
- **500 Internal Server Error**: Unexpected server errors

**Error Response Format**:
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "User-friendly description",
    "details": {
      "field": "title",
      "constraint": "required"
    }
  }
}
```

### Database Schema

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) NOT NULL,
    priority VARCHAR(50),
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_tasks_user_id ON tasks(user_id);
```

### Data Ownership Rules

**CRITICAL**: Every task query MUST filter by authenticated `user_id`:

```python
# ✅ CORRECT
tasks = db.query(Task).filter(Task.user_id == current_user_id).all()

# ❌ VIOLATION - Returns all users' tasks!
tasks = db.query(Task).all()
```

**Enforcement Checklist**:
- [ ] All task queries include `WHERE user_id = <authenticated_user_id>`
- [ ] Backend extracts `user_id` from verified JWT (NOT from client input)
- [ ] Cross-user access attempts return 403 Forbidden
- [ ] Users can ONLY read/modify/delete their own tasks

---

## Frontend Architecture (Next.js App Router)

### Project Structure

```
frontend/
├── app/
│   ├── layout.tsx          # Root layout
│   ├── page.tsx            # Home page
│   ├── login/
│   │   └── page.tsx        # Login page
│   ├── signup/
│   │   └── page.tsx        # Signup page
│   └── dashboard/
│       ├── layout.tsx      # Dashboard layout
│       └── page.tsx        # Dashboard page (protected)
├── components/
│   ├── ui/                 # Reusable UI components
│   ├── tasks/              # Task-specific components
│   └── auth/               # Auth-related components
├── lib/
│   ├── api-client.ts       # Centralized API client with JWT
│   └── auth.ts             # Better Auth configuration
└── types/
    └── task.ts             # TypeScript types
```

### App Router Conventions

- **Server Components by default**: Use for static content, layouts
- **Client Components** (`'use client'`): Use for interactivity (forms, state)
- **Layouts**: Shared UI across routes (`layout.tsx`)
- **Loading States**: `loading.tsx` for route segments
- **Error Boundaries**: `error.tsx` for error handling
- **Dynamic Routes**: `[id]/page.tsx` for dynamic segments

### API Client Pattern

```typescript
// lib/api-client.ts
export async function fetchAPI(endpoint: string, options?: RequestInit) {
  const token = getAuthToken() // From Better Auth

  const response = await fetch(`${process.env.NEXT_PUBLIC_API_URL}${endpoint}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`,
      ...options?.headers,
    },
  })

  if (!response.ok) {
    // Handle errors (401, 403, etc.)
    throw new Error(`API error: ${response.status}`)
  }

  return response.json()
}
```

### Responsive Design

- **Mobile-first**: Design for smallest screens first
- **Tailwind Breakpoints**:
  - `sm`: 640px
  - `md`: 768px
  - `lg`: 1024px
  - `xl`: 1280px
  - `2xl`: 1536px
- **Example**: `<div className="w-full md:w-1/2 lg:w-1/3">`

---

## Database & Data Ownership Rules

### SQLModel ORM

- All models defined as SQLModel classes
- Type hints for all fields
- Relationships defined explicitly
- No raw SQL unless performance-critical (must document rationale)

### Migrations (Alembic)

- Schema changes via explicit migrations
- Migration scripts committed to repository
- Use `alembic revision --autogenerate -m "description"`
- Test migrations in dev before applying to prod

### No Global State

- No module-level database connections
- Database session per request (FastAPI dependency injection)
- No caching in global variables
- Stateless backend design

### User-Scoped Queries (CRITICAL)

**Every task query MUST**:
1. Extract `user_id` from verified JWT
2. Filter all queries by `user_id`
3. Return 403 for cross-user access attempts
4. Never trust client-provided `user_id`

**Example Service Pattern**:
```python
class TaskService:
    def __init__(self, db: Session, current_user_id: UUID):
        self.db = db
        self.current_user_id = current_user_id

    def get_tasks(self) -> List[Task]:
        return self.db.query(Task).filter(
            Task.user_id == self.current_user_id
        ).all()

    def get_task_by_id(self, task_id: UUID) -> Optional[Task]:
        task = self.db.query(Task).filter(
            Task.id == task_id,
            Task.user_id == self.current_user_id  # ← CRITICAL
        ).first()
        if not task:
            raise HTTPException(status_code=403, detail="Access denied")
        return task
```

---

## Agent & Skill Responsibility Map

### Agents (Located in `.claude/agents/`)

Agents are specialized sub-processes that handle complex, multi-step tasks autonomously.

#### 1. nextjs-frontend-optimizer

**When to Use**:
- Creating or updating Next.js pages and components
- Implementing responsive designs
- Optimizing rendering performance
- Setting up App Router routing and layouts
- Improving accessibility and UX
- Refactoring frontend code

**Responsibilities**:
- Next.js App Router file structure
- Server Components vs Client Components decisions
- Responsive design (Tailwind CSS)
- Performance optimization (memoization, lazy loading)
- Accessibility (WCAG 2.1 AA compliance)
- Component architecture and reusability

**Invocation**:
```
Use the Task tool with subagent_type="nextjs-frontend-optimizer"
```

---

#### 2. fastapi-backend-agent

**When to Use**:
- Implementing or updating FastAPI REST API endpoints
- Validating request/response schemas with Pydantic
- Integrating authentication mechanisms (JWT)
- Connecting endpoints to databases
- Writing database queries or transactions
- Optimizing backend performance
- Ensuring FastAPI best practices

**Responsibilities**:
- RESTful API endpoint implementation
- Pydantic request/response validation
- JWT authentication and authorization
- Database integration via SQLModel
- Service layer architecture
- Error handling and logging
- Transaction management

**Invocation**:
```
Use the Task tool with subagent_type="fastapi-backend-agent"
```

---

#### 3. database-optimizer

**When to Use**:
- Planning or implementing database schema changes
- Applying database migrations
- Investigating slow query performance
- Optimizing existing queries or database structures
- Validating database changes against specifications
- Setting up serverless database deployments (Neon)

**Responsibilities**:
- Schema design and normalization
- Index strategy and optimization
- Migration script creation (Alembic)
- Query performance analysis
- Serverless database configuration (connection pooling)
- Data integrity and constraints

**Invocation**:
```
Use the Task tool with subagent_type="database-optimizer"
```

---

#### 4. auth-agent

**When to Use**:
- Implementing signup or login features
- Validating authentication flows
- Ensuring password hashing and JWT handling follow best practices
- Integrating Better Auth with backend
- Validating user credentials and token integrity
- Ensuring authentication compliance with security standards

**Responsibilities**:
- Authentication flow validation
- Password hashing verification (bcrypt, Argon2)
- JWT token generation and verification
- Better Auth integration
- Security best practices enforcement
- Input validation for auth endpoints

**Invocation**:
```
Use the Task tool with subagent_type="auth-agent"
```

---

### Skills (Located in `.claude/skills/`)

Skills provide reusable functionality that can be invoked by any agent.

#### 1. auth-skill

**Purpose**: Implement secure authentication systems

**Capabilities**:
- User signup with password hashing
- User signin with credential validation
- JWT token generation and verification
- Password reset mechanisms
- Authentication middleware integration

**Used By**: auth-agent, fastapi-backend-agent

---

#### 2. database-skill

**Purpose**: Manage database operations and schema design

**Capabilities**:
- Schema design and normalization
- Table creation with proper constraints
- Database migrations (Alembic)
- Index and relationship management
- Query optimization suggestions

**Used By**: database-optimizer, fastapi-backend-agent

---

#### 3. frontend-skill

**Purpose**: Build responsive and modular frontend UIs with Next.js

**Capabilities**:
- Page creation (App Router)
- Component development (reusable, modular)
- Layout and styling (Tailwind CSS)
- Responsive design patterns
- Frontend best practices

**Used By**: nextjs-frontend-optimizer

---

#### 4. backend-skill

**Purpose**: Implement FastAPI backend endpoints and business logic

**Capabilities**:
- REST API endpoint implementation
- Request/response validation
- Database integration
- Error handling
- Service layer architecture

**Used By**: fastapi-backend-agent

---

### Agent Selection Guide

Use this decision tree to choose the right agent:

```
Is it frontend work (UI, pages, components)?
├─ YES → nextjs-frontend-optimizer
└─ NO
    │
    Is it backend API work (endpoints, validation, auth)?
    ├─ YES → fastapi-backend-agent
    └─ NO
        │
        Is it database work (schema, migrations, queries)?
        ├─ YES → database-optimizer
        └─ NO
            │
            Is it authentication-specific validation?
            └─ YES → auth-agent
```

**Multi-Agent Tasks**:
- **Full Feature Implementation**: Use multiple agents sequentially
  1. database-optimizer: Design schema
  2. fastapi-backend-agent: Implement API endpoints
  3. nextjs-frontend-optimizer: Build UI
  4. auth-agent: Validate auth flows (if auth-related)

---

## Development Constraints

### MUST Follow

1. **Spec-Driven Only**: No code without a specification
2. **Reuse Phase I Logic**: Do NOT reinvent task CRUD, validation, or error messages
3. **User-Scoped Queries**: ALL database queries MUST filter by authenticated `user_id`
4. **JWT from Better Auth**: Frontend uses Better Auth for JWT generation
5. **Backend Verifies JWT**: Backend verifies JWT signature and extracts `user_id`
6. **Stateless Backend**: No session storage, no global state
7. **No Manual Coding**: ALL implementation via Claude Code
8. **PHR for Every Interaction**: Create Prompt History Records consistently

### MUST NOT Do

1. **Do NOT invent APIs**: Reference specs or ask clarifying questions
2. **Do NOT hardcode secrets**: Use `.env` files
3. **Do NOT trust client `user_id`**: Always extract from verified JWT
4. **Do NOT skip user filtering**: Every task query MUST include `user_id` filter
5. **Do NOT create ADRs without consent**: Always suggest first
6. **Do NOT refactor unrelated code**: Smallest viable change only
7. **Do NOT assume without verification**: Use MCP tools and CLI commands to verify

### Error Handling Standards

**Backend**:
- Use structured error responses with error codes
- Log errors with full context (request ID, user ID, stack trace)
- Never expose internal errors to clients
- Implement global exception handlers

**Frontend**:
- Display user-friendly error messages
- Handle 401 (redirect to login)
- Handle 403 (show access denied message)
- Handle network errors gracefully

### Testing Philosophy (When Tests Requested)

**Backend Integration Tests**:
- Auth enforcement (401 for missing JWT)
- User isolation (403 for cross-user access)
- CRUD operations with database persistence
- Validation rules from Phase I

**Frontend Component Tests**:
- Form validation logic
- API client error handling
- UI state management

**No E2E Required** (unless explicitly requested)

---

## Execution Contract for Every Request

For every user request, you MUST:

1. **Confirm Surface and Success Criteria** (one sentence)
2. **List Constraints, Invariants, Non-Goals**
3. **Produce Artifact with Acceptance Checks**
4. **Add Follow-Ups and Risks** (max 3 bullets)
5. **Create PHR** in appropriate subdirectory
6. **Surface ADR Suggestion** if architecturally significant decisions were made

### Minimum Acceptance Criteria

- Clear, testable acceptance criteria included
- Explicit error paths and constraints stated
- Smallest viable change; no unrelated edits
- Code references to modified/inspected files where relevant
- Constitutional compliance verified

---

## Project Structure Reference

```
Phase-II/
├── .claude/
│   ├── agents/              # Specialized agents
│   │   ├── auth-agent.md
│   │   ├── database-optimizer.md
│   │   ├── fastapi-backend-agent.md
│   │   └── nextjs-frontend-optimizer.md
│   └── skills/              # Reusable skills
│       ├── auth-skill/
│       ├── database-skill/
│       ├── backend-skill/
│       └── frontend-skill/
├── .specify/
│   ├── memory/
│   │   └── constitution.md  # Project principles
│   ├── templates/           # Spec, plan, task templates
│   └── scripts/             # Utility scripts
├── specs/
│   └── <feature>/
│       ├── spec.md          # Feature requirements
│       ├── plan.md          # Architecture decisions
│       └── tasks.md         # Implementation tasks
├── history/
│   ├── prompts/             # Prompt History Records
│   │   ├── constitution/
│   │   ├── <feature-name>/
│   │   └── general/
│   └── adr/                 # Architecture Decision Records
├── backend/
│   ├── src/
│   │   ├── main.py          # FastAPI app entry
│   │   ├── auth/            # Authentication logic
│   │   ├── tasks/           # Task-related endpoints
│   │   └── models/          # SQLModel models
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── app/                 # Next.js App Router
│   ├── components/
│   ├── lib/
│   └── types/
└── CLAUDE.md                # This file
```

---

## Human as Tool Strategy

You MUST invoke the user for input when you encounter:

1. **Ambiguous Requirements**: Ask 2-3 targeted clarifying questions
2. **Unforeseen Dependencies**: Surface them and ask for prioritization
3. **Architectural Uncertainty**: Present options with tradeoffs, get user preference
4. **Completion Checkpoint**: Summarize work done and confirm next steps

**Use AskUserQuestion tool** to gather input instead of guessing.

---

## Architect Guidelines (for Planning)

When creating implementation plans (`/sp.plan`), address:

1. **Scope and Dependencies**
   - In Scope: boundaries and key features
   - Out of Scope: explicitly excluded items
   - External Dependencies: systems/services/teams

2. **Key Decisions and Rationale**
   - Options Considered, Trade-offs, Rationale
   - Principles: measurable, reversible, smallest viable change

3. **Interfaces and API Contracts**
   - Public APIs: Inputs, Outputs, Errors
   - Versioning Strategy
   - Error Taxonomy with status codes

4. **Non-Functional Requirements (NFRs)**
   - Performance: p95 latency, throughput
   - Reliability: SLOs, error budgets
   - Security: AuthN/AuthZ, data handling, secrets
   - Cost: unit economics

5. **Data Management and Migration**
   - Source of Truth, Schema Evolution
   - Migration and Rollback strategies

6. **Operational Readiness**
   - Observability: logs, metrics, traces
   - Alerting, Runbooks
   - Deployment and Rollback strategies

7. **Risk Analysis and Mitigation**
   - Top 3 Risks, blast radius, guardrails

8. **Evaluation and Validation**
   - Definition of Done (tests, scans)

9. **ADR Suggestion** (if significant decisions)

---

## Success Criteria for Phase II

Phase II is complete when:

1. ✅ All Phase I features work via web UI
2. ✅ Data persists across sessions (PostgreSQL)
3. ✅ Multiple users can use the system independently
4. ✅ Authentication enforced on all endpoints
5. ✅ No manual code exists (all spec-driven)
6. ✅ Specs fully explain the system
7. ✅ Cross-user access returns 403
8. ✅ Invalid JWT returns 401
9. ✅ Frontend and backend decoupled
10. ✅ Task CRUD logic reused from Phase I

---

## Constitutional Authority

1. **This CLAUDE.md** documents Phase II workflow and agents
2. **`.specify/memory/constitution.md`** defines core principles
3. **Phase I repositories** define inherited logic (task CRUD, validation)
4. **Where Phase II is silent, Phase I applies**
5. **All amendments require updating constitution via `/sp.constitution`**

---

## Version Control & Governance

**Version**: 1.0.0 (Phase II)
**Last Updated**: 2026-01-30

**Amendment Process**:
1. Identify need for amendment
2. Document proposed change with rationale
3. Update constitution via `/sp.constitution`
4. Increment version (semantic versioning)
5. Propagate changes to dependent templates
6. Commit amendment with ADR if architecturally significant

---

## Quick Reference Commands

| Command | Purpose |
|---------|---------|
| `/sp.specify` | Create/update feature specification |
| `/sp.plan` | Generate implementation plan from spec |
| `/sp.tasks` | Generate atomic tasks from plan |
| `/sp.implement` | Execute tasks from tasks.md |
| `/sp.constitution` | Update project constitution |
| `/sp.adr <title>` | Create Architecture Decision Record |
| `/sp.phr` | Manually create Prompt History Record |
| `/sp.clarify` | Ask clarification questions about spec |

---

## Final Notes

This project is a demonstration of **Agentic Dev Stack** methodology:
- Specification-driven (not code-driven)
- AI-generated implementation (no manual coding)
- Traceable and auditable (PHRs, ADRs)
- Modular and composable (agents, skills)
- Reusable intelligence (Phase I logic, agent systems)

**Your role as Claude Code**: Execute this workflow precisely, use agents appropriately, capture all work in PHRs, and deliver a production-ready multi-user Todo web application that adheres to all constitutional principles.

---

**For detailed principles and constraints, see**: `.specify/memory/constitution.md`
