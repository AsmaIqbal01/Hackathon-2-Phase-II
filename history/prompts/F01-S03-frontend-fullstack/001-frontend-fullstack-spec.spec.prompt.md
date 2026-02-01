---
id: 001
title: Frontend Fullstack Integration Spec
stage: spec
date: 2026-01-30
surface: agent
model: claude-opus-4-5-20251101
feature: F01-S03-frontend-fullstack
branch: F01-S02-auth-security
user: hackathon-user
command: /sp.specify
labels: ["frontend", "integration", "nextjs", "spec"]
links:
  spec: specs/F01-S03-frontend-fullstack/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - specs/F01-S03-frontend-fullstack/spec.md
tests:
  - N/A (specification phase)
---

## Prompt

/sp.specify

Project: Todo Full-Stack Web Application
Spec 3: Frontend Application & Full-Stack Integration (Next.js)

Mentor Mode:
- Act as a truthless mentor.
- Prefer correction over encouragement.
- Eliminate ambiguity, redundancy, and excess verbosity.
- Optimize for reviewer clarity and minimum token usage.

Context:
- Specs completed:
  - Spec 1: Backend API & Database
  - Spec 2: Authentication & Security (JWT via Better Auth)
- This spec integrates—not reinvents—existing systems.

Stack:
- Frontend: Next.js 16+ (App Router)
- Auth: Better Auth (JWT-based)
- Backend: FastAPI (already implemented)
- API Contract: Defined in Spec 1
- Security Model: Defined in Spec 2

Constraints:
- No manual coding
- Claude Code only
- Reuse existing `.claude/agents` and `.claude/skills`
- Do NOT restate backend or auth behavior unless referenced
- Do NOT duplicate API definitions

## Response snapshot

Created `specs/F01-S03-frontend-fullstack/spec.md` with:

1. **References section** linking to Spec 1 and Spec 2 instead of restating definitions
2. **7 User Stories** (P1/P2 prioritized):
   - US1: Authenticated Task List View (P1)
   - US2: Task Creation (P1)
   - US3: Task Update (P1)
   - US4: Task Deletion (P2)
   - US5: Authentication Flow (P1)
   - US6: Session Persistence (P1)
   - US7: Logout (P2)
3. **30 Functional Requirements** covering:
   - Routing & Navigation (FR-001 to FR-003)
   - API Client (FR-004 to FR-007)
   - Auth Integration (FR-008 to FR-013)
   - Task Operations (FR-014 to FR-017)
   - Error Handling (FR-018 to FR-022)
   - State Management (FR-023 to FR-026)
   - UI/UX (FR-027 to FR-030)
4. **8 Success Criteria** (SC-001 to SC-008)
5. **Key Entities** (TypeScript interfaces: Task, User, AuthState)
6. **Project Structure** reference
7. **Termination Rules** for contract violations
8. **Out of Scope** list (10 items)

Key design decisions:
- No `user_id` in frontend requests (backend extracts from JWT)
- Access token in memory only (not localStorage)
- No optimistic updates (reflect backend state only)
- Single API client module for all requests

## Outcome

- Impact: Created integration spec that references Spec 1/2 without duplication
- Tests: N/A (specification phase)
- Files: 1 created (spec.md)
- Next prompts: `/sp.plan` to generate implementation plan
- Reflection: Spec is minimal and reference-oriented per mentor mode constraints

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): N/A
- Prompt variant (if applicable): mentor-mode-minimal
- Next experiment: Validate spec references are correctly linked during planning phase
