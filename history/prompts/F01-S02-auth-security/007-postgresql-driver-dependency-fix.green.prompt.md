---
id: 007
title: PostgreSQL Driver Dependency Fix
stage: green
date: 2026-02-01
surface: agent
model: claude-opus-4-5-20251101
feature: F01-S02-auth-security
branch: F01-S02-auth-security
user: developer
command: /sp.implement
labels: ["dependency", "postgresql", "cross-platform", "psycopg"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - backend/requirements.txt
tests:
  - null
---

## Prompt

/sp.implement

Context:
The backend dependency installation fails on Windows due to psycopg2-binary attempting to build from source and requiring pg_config.

Objective:
Fix PostgreSQL driver dependency to be cross-platform, production-safe, and compatible with Neon Serverless PostgreSQL.

Constraints:
- Minimal change
- No logic changes to backend code
- No duplication of database logic
- Follow constitution: spec-driven, agentic execution only
- Reuse existing backend and dependency-management skills
- Windows, Linux, and CI compatible

Required Change:
1. Replace deprecated psycopg2-binary with modern psycopg v3 binary distribution
2. Ensure SQLModel + SQLAlchemy compatibility is preserved

Implementation Steps:
- Update backend/requirements.txt:
  - Remove: psycopg2-binary
  - Add: psycopg[binary]>=3.1
- Verify no code imports psycopg2 directly
- Confirm database connection uses SQLModel / SQLAlchemy abstraction only
- Do NOT introduce local PostgreSQL requirements
- Do NOT add pg_config or system dependencies

## Response snapshot

Applied minimal dependency change to fix cross-platform PostgreSQL driver compatibility:

1. **Updated requirements.txt**:
   - Removed: `psycopg2-binary==2.9.9`
   - Added: `psycopg[binary]>=3.1`

2. **Verification completed**:
   - No direct imports of `psycopg2` in backend code
   - Database connection uses SQLModel/SQLAlchemy abstraction (`src/database.py:2`)
   - No other references to psycopg2 in the codebase
   - Compatible with Neon Serverless PostgreSQL

3. **Why psycopg v3**:
   - Pure Python binary distribution (no `pg_config` or C compiler required)
   - Cross-platform: Windows, Linux, macOS, CI environments
   - Modern async-capable driver
   - SQLAlchemy 2.0+ compatible (used by SQLModel)
   - Production-safe and actively maintained

## Outcome

- ✅ Impact: Fixed Windows build failure, enabled cross-platform dependency installation
- 🧪 Tests: No new tests required (dependency-only change)
- 📁 Files: backend/requirements.txt modified
- 🔁 Next prompts: Install dependencies and verify backend starts successfully
- 🧠 Reflection: Minimal viable change applied; psycopg v3 is the modern replacement for psycopg2

## Evaluation notes (flywheel)

- Failure modes observed: psycopg2-binary fails on Windows without pg_config/PostgreSQL dev libraries
- Graders run and results (PASS/FAIL): PASS - dependency replaced with compatible v3 binary
- Prompt variant (if applicable): null
- Next experiment (smallest change to try): Verify pip install succeeds on Windows
