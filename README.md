# Evolution of Todo – Phase II: Full-Stack Web Application

![Phase II](https://img.shields.io/badge/Phase-II-blue) ![Stack](https://img.shields.io/badge/Stack-Next.js%20%2B%20FastAPI-green) ![Auth](https://img.shields.io/badge/Auth-Better%20Auth%20%2B%20JWT-orange) ![Database](https://img.shields.io/badge/Database-Neon%20PostgreSQL-purple)

**Transform a console-based Todo application into a modern, multi-user, full-stack web application using Spec-Driven Development and the Agentic Dev Stack workflow.**

---

## Table of Contents

- [Overview](#overview)
- [Phase II Objectives](#phase-ii-objectives)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Authentication Flow](#authentication-flow)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)
- [Getting Started](#getting-started)
- [Documentation](#documentation)
- [Key Principles](#key-principles)
- [Contributing](#contributing)

---

## Overview

**Phase II** transforms the [Phase I console-based Todo CLI](https://github.com/AsmaIqbal01/Hackathon2-phase1) into a production-ready, multi-user web application with:

- **Multi-User Support**: Multiple users managing their own todos independently
- **Persistent Storage**: Data stored in Neon Serverless PostgreSQL
- **Modern Web UI**: Responsive interface built with Next.js 16+ App Router
- **RESTful API**: FastAPI backend exposing secure endpoints
- **JWT Authentication**: Better Auth for token-based authentication
- **Data Isolation**: User-scoped data access enforced at the backend

### What Stays the Same from Phase I

- Task CRUD logic (create, read, update, delete)
- Validation rules (title, description, status, priority, tags)
- Business rules (status transitions, tag management)
- Error messages for business logic

### What Changes for Phase II

| Aspect | Phase I | Phase II |
|--------|---------|----------|
| Interface | Console CLI | Web UI (Next.js) |
| Storage | In-memory | PostgreSQL (Neon) |
| API | Direct function calls | REST endpoints (FastAPI) |
| Users | Single-user | Multi-user with authentication |
| Sessions | Ephemeral | Persistent |
| Authentication | None | JWT-based (Better Auth) |

---

## Phase II Objectives

1. ✅ **Multi-User Capabilities**: Enable multiple users to use the system independently
2. ✅ **Persistent Data Storage**: Store tasks in PostgreSQL across sessions
3. ✅ **Responsive Web Interface**: Build a modern UI with Next.js 16+
4. ✅ **RESTful API**: Implement secure, well-documented API endpoints
5. ✅ **Secure Authentication**: JWT-based auth with Better Auth
6. ✅ **Data Isolation**: Enforce user-scoped access at the backend layer
7. ✅ **Spec-Driven Development**: All code generated from specifications
8. ✅ **No Manual Coding**: 100% AI-generated implementation via Claude Code

---

## Technology Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Next.js** | 16+ | App Router, Server Components, SSR |
| **TypeScript** | Latest | Type safety and developer experience |
| **Tailwind CSS** | Latest | Utility-first styling |
| **Better Auth** | Latest | JWT token generation and management |
| **React** | 19+ | UI components and state management |

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Python** | 3.12+ | Backend runtime |
| **FastAPI** | Latest | REST API framework |
| **SQLModel** | Latest | ORM for database operations |
| **Pydantic** | Latest | Request/response validation |
| **Alembic** | Latest | Database migrations |
| **JWT** | - | Token verification (shared secret with Better Auth) |

### Database & Infrastructure

| Technology | Purpose |
|------------|---------|
| **Neon PostgreSQL** | Serverless managed PostgreSQL |
| **Vercel** | Frontend deployment (Next.js optimized) |
| **Railway/Render** | Backend deployment (Python/FastAPI) |

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         User Browser                         │
└────────────┬────────────────────────────────────────────────┘
             │
             │ HTTPS
             ▼
┌─────────────────────────────────────────────────────────────┐
│                    Frontend (Next.js 16+)                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  • App Router (server + client components)             │ │
│  │  • Better Auth (JWT token management)                  │ │
│  │  • Tailwind CSS (responsive UI)                        │ │
│  │  • API client (with JWT headers)                       │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────┬────────────────────────────────────────────────┘
             │
             │ REST API (JSON)
             │ Authorization: Bearer <JWT>
             ▼
┌─────────────────────────────────────────────────────────────┐
│                     Backend (FastAPI)                        │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  • JWT Verification Middleware                         │ │
│  │  • RESTful API Endpoints (/api/tasks)                  │ │
│  │  • Pydantic Validation                                 │ │
│  │  • Service Layer (business logic)                      │ │
│  │  • SQLModel ORM                                        │ │
│  └────────────────────────────────────────────────────────┘ │
└────────────┬────────────────────────────────────────────────┘
             │
             │ SQL Queries
             ▼
┌─────────────────────────────────────────────────────────────┐
│                Neon Serverless PostgreSQL                    │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  Tables: users, tasks                                  │ │
│  │  • User-scoped queries (WHERE user_id = ?)            │ │
│  │  • Indexes on user_id for performance                 │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Key Architectural Principles

1. **Decoupled Frontend and Backend**: Clear separation of concerns
2. **API-First Design**: Frontend communicates via REST API only
3. **Stateless Backend**: No session storage, JWT-based authentication
4. **User-Scoped Data**: All queries filtered by authenticated user_id
5. **Security at Backend**: Authorization enforced server-side, not in UI

---

## Authentication Flow

### JWT-Based Authentication with Better Auth

```
┌──────────────┐           ┌──────────────┐           ┌──────────────┐
│   Frontend   │           │ Better Auth  │           │   Backend    │
│  (Next.js)   │           │              │           │  (FastAPI)   │
└──────┬───────┘           └──────┬───────┘           └──────┬───────┘
       │                          │                          │
       │ 1. POST /auth/login      │                          │
       │ {email, password}        │                          │
       ├─────────────────────────>│                          │
       │                          │                          │
       │ 2. Validate credentials  │                          │
       │ 3. Issue JWT token       │                          │
       │                          │                          │
       │ 4. JWT Token             │                          │
       │ { token, user_id, email} │                          │
       │<─────────────────────────┤                          │
       │                          │                          │
       │ 5. Store token securely  │                          │
       │    (httpOnly cookie)     │                          │
       │                          │                          │
       │ 6. API Request           │                          │
       │ GET /api/tasks           │                          │
       │ Authorization: Bearer <JWT>                         │
       ├─────────────────────────────────────────────────────>
       │                          │                          │
       │                          │    7. Verify JWT         │
       │                          │    (shared secret)       │
       │                          │    8. Extract user_id    │
       │                          │                          │
       │                          │    9. Query DB           │
       │                          │    WHERE user_id = ?     │
       │                          │                          │
       │ 10. Response (user's tasks only)                    │
       │<─────────────────────────────────────────────────────┤
       │                          │                          │
```

### Critical Security Rules

- ✅ **Backend verifies JWT**: Signature validated using shared secret
- ✅ **User ID from token**: Backend extracts `user_id` from verified JWT claims
- ✅ **Never trust client**: Backend IGNORES any `user_id` sent by client
- ✅ **User-scoped queries**: ALL database queries MUST filter by authenticated `user_id`
- ✅ **403 for cross-user access**: Attempting to access another user's data returns Forbidden
- ✅ **401 for invalid JWT**: Missing or invalid tokens return Unauthorized

---

## Project Structure

```
Phase-II/
├── .claude/                        # Agentic Dev Stack
│   ├── agents/                     # Specialized agents
│   │   ├── auth-agent.md           # Authentication validation
│   │   ├── database-optimizer.md   # Database schema & queries
│   │   ├── fastapi-backend-agent.md # Backend API implementation
│   │   └── nextjs-frontend-optimizer.md # Frontend UI/UX
│   ├── skills/                     # Reusable skills
│   │   ├── auth-skill/
│   │   ├── database-skill/
│   │   ├── backend-skill/
│   │   └── frontend-skill/
│   └── commands/                   # Spec-Kit Plus commands
│       ├── sp.specify.md           # Create specifications
│       ├── sp.plan.md              # Generate plans
│       ├── sp.tasks.md             # Generate tasks
│       └── sp.implement.md         # Execute implementation
├── .specify/                       # Spec-Kit Plus templates
│   ├── memory/
│   │   └── constitution.md         # Project principles
│   ├── templates/                  # Spec, plan, task templates
│   └── scripts/                    # Utility scripts
├── specs/                          # Feature specifications
│   └── <feature>/
│       ├── spec.md                 # Requirements
│       ├── plan.md                 # Architecture decisions
│       └── tasks.md                # Implementation tasks
├── history/                        # Knowledge capture
│   ├── prompts/                    # Prompt History Records (PHRs)
│   │   ├── constitution/
│   │   ├── <feature-name>/
│   │   └── general/
│   └── adr/                        # Architecture Decision Records
├── backend/                        # FastAPI backend
│   ├── src/
│   │   ├── main.py                 # FastAPI app entry
│   │   ├── auth/                   # Authentication logic
│   │   ├── tasks/                  # Task endpoints
│   │   ├── models/                 # SQLModel models
│   │   └── services/               # Business logic
│   ├── tests/                      # Backend tests
│   ├── requirements.txt
│   ├── .env.example
│   └── README.md
├── frontend/                       # Next.js frontend
│   ├── app/                        # App Router pages
│   │   ├── layout.tsx
│   │   ├── page.tsx
│   │   ├── login/
│   │   ├── signup/
│   │   └── dashboard/
│   ├── components/                 # React components
│   │   ├── ui/
│   │   ├── tasks/
│   │   └── auth/
│   ├── lib/                        # Utilities
│   │   ├── api-client.ts           # API client with JWT
│   │   └── auth.ts                 # Better Auth config
│   ├── types/                      # TypeScript types
│   ├── package.json
│   └── README.md
├── .gitignore
├── CLAUDE.md                       # Claude Code rules and workflow
├── AUTHENTICATION.md               # Detailed auth flow documentation
├── ARCHITECTURE.md                 # System architecture guide
└── README.md                       # This file
```

---

## Development Workflow

### Agentic Dev Stack: Spec-Driven Development

**ALL code is generated via Claude Code following this workflow:**

```
User Request → Specification → Plan → Tasks → Implementation → Validation
```

### Step-by-Step Process

1. **Create Specification**
   ```bash
   /sp.specify <feature-name>
   ```
   - Defines requirements, acceptance criteria, constraints
   - Stored in `specs/<feature>/spec.md`

2. **Generate Implementation Plan**
   ```bash
   /sp.plan <feature-name>
   ```
   - Makes architectural decisions
   - Documents API contracts and interfaces
   - Stored in `specs/<feature>/plan.md`

3. **Break Down into Tasks**
   ```bash
   /sp.tasks <feature-name>
   ```
   - Generates atomic, testable tasks
   - Includes acceptance criteria per task
   - Stored in `specs/<feature>/tasks.md`

4. **Implement with Agents**
   ```bash
   /sp.implement <feature-name>
   ```
   - Uses specialized agents:
     - `nextjs-frontend-optimizer`: Frontend UI/UX
     - `fastapi-backend-agent`: Backend APIs
     - `database-optimizer`: Database schema/queries
     - `auth-agent`: Authentication validation
   - Implements one task at a time
   - Validates acceptance criteria after each task

5. **Capture Knowledge**
   - **Prompt History Records (PHRs)**: Created automatically after every interaction
   - **Architecture Decision Records (ADRs)**: Suggested for significant decisions

### Available Commands

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

## Getting Started

### Prerequisites

- **Node.js** 20+ (for Next.js frontend)
- **Python** 3.12+ (for FastAPI backend)
- **PostgreSQL** (Neon account recommended)
- **Claude Code CLI** (for development workflow)

### Quick Start

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd Phase-II
```

#### 2. Backend Setup

```bash
cd backend
pip install -r requirements.txt
cp .env.example .env
# Edit .env with your database credentials and JWT secret
python -m src.main
```

See [backend/README.md](backend/README.md) for detailed setup.

#### 3. Frontend Setup

```bash
cd frontend
npm install
cp .env.local.example .env.local
# Edit .env.local with API URL and Better Auth config
npm run dev
```

See [frontend/README.md](frontend/README.md) for detailed setup.

#### 4. Database Setup

1. Create a Neon PostgreSQL database
2. Run migrations:
   ```bash
   cd backend
   alembic upgrade head
   ```

---

## Documentation

| Document | Description |
|----------|-------------|
| [CLAUDE.md](CLAUDE.md) | Claude Code rules, workflow, and agent documentation |
| [AUTHENTICATION.md](AUTHENTICATION.md) | Detailed JWT authentication flow and security |
| [ARCHITECTURE.md](ARCHITECTURE.md) | System architecture and design decisions |
| [.specify/memory/constitution.md](.specify/memory/constitution.md) | Project principles and constraints |
| [backend/README.md](backend/README.md) | Backend setup and API documentation |
| [frontend/README.md](frontend/README.md) | Frontend setup and component guide |

---

## Key Principles

### 1. Spec-Driven Development Only

✅ **ALL code originates from specifications**
❌ No manual coding permitted

### 2. Reuse Over Reinvention

✅ **Reuse Phase I task CRUD logic, validation, and error messages**
❌ Do not reinvent unchanged business logic

### 3. User-Scoped Data

✅ **ALL database queries MUST filter by authenticated `user_id`**
❌ Cross-user access returns 403 Forbidden

### 4. JWT from Better Auth

✅ **Frontend uses Better Auth for JWT generation**
✅ **Backend verifies JWT and extracts `user_id`**
❌ Never trust client-provided `user_id`

### 5. Stateless Backend

✅ **No session storage, no global state**
✅ **JWT-based authentication only**

### 6. Security at Backend

✅ **Backend enforces all authorization rules**
❌ Frontend UI is NOT a security boundary

### 7. Knowledge Capture

✅ **PHR (Prompt History Record) for every interaction**
✅ **ADR (Architecture Decision Record) for significant decisions**

---

## Contributing

### Development Rules

1. **No Manual Coding**: All implementation via Claude Code
2. **Spec First**: Create specification before implementation
3. **Use Agents**: Leverage specialized agents for implementation
4. **Capture Knowledge**: Create PHRs and ADRs consistently
5. **Commit Logically**: Clear, descriptive commit messages

### Workflow

1. Define feature in spec (`/sp.specify <feature>`)
2. Generate plan (`/sp.plan <feature>`)
3. Break into tasks (`/sp.tasks <feature>`)
4. Implement with agents (`/sp.implement <feature>`)
5. Create PHR for session
6. Suggest ADR if architecturally significant

---

## Phase II Success Criteria

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

## References

- **Phase I Repository**: [Hackathon2-phase1](https://github.com/AsmaIqbal01/Hackathon2-phase1)
- **Frontend Agent System**: [frontend_agent_system](https://github.com/AsmaIqbal01/frontend_agent_system)
- **Backend Agent System**: [Backend_agent_system](https://github.com/AsmaIqbal01/Backend_agent_system)
- **Spec-Kit Plus**: Project methodology for spec-driven development
- **Agentic Dev Stack**: AI-powered development workflow with specialized agents

---

## License

[Specify your license here]

---

## Contact

For questions or feedback, please open an issue on GitHub.

---

**Built with Spec-Driven Development and the Agentic Dev Stack** ✨
