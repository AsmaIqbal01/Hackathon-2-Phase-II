---
id: 002
title: Repository Hygiene and Release Hardening
stage: misc
date: 2026-02-01
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: F01-S02-auth-security
user: system
command: /sp.task (repository hygiene audit)
labels: ["hygiene", "documentation", "release-hardening"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .gitignore
  - README.md
  - backend/README.md
tests:
  - none
---

## Prompt

/sp.task

Role:
- Act as a truthless mentor and release hardener.
- Assume core implementation is correct.
- Make only necessary changes.
- Avoid duplication at all costs.
- Prefer edits over new files.
- Reuse existing agents, skills, and sub-agents.

Context:
- Project: Todo Full-Stack Web Application (Hackathon Phase II)
- Repository: Already pushed to GitHub
- Backend (Spec 1): Complete
- Auth & Security (Spec 2): Complete
- Frontend (Spec 3): Setup-only, not fully implemented

Objective:
After GitHub update, ensure the repository is:
- Internally consistent
- Documentation-accurate
- Reviewer-safe
- Explicit about scope boundaries
- Free of hygiene issues

Steps:
1. Repository Hygiene Audit
2. Documentation Consistency Check
3. Frontend Scope Declaration
4. Spec Integrity Check

## Response snapshot

Executed 4-step repository audit:

**Step 1 - Repository Hygiene:**
- Found `backend/todo.db` (SQLite file) tracked in git
- Removed from git index with `git rm --cached backend/todo.db`
- Added `*.db` and `backend/todo.db` to `.gitignore`

**Step 2 - Documentation Consistency:**
- Fixed `backend/README.md` contradictions:
  - Removed outdated "Temporary user_id parameter" references
  - Updated API endpoint examples to use JWT `Authorization: Bearer` header
  - Removed `?user_id=xxx` from all example curl commands
  - Updated error codes to include 401 (Unauthorized)
  - Changed note from "JWT will be added" to "JWT is fully implemented"

**Step 3 - Frontend Scope Declaration:**
- `frontend/README.md` already correctly states "STATUS: Not yet implemented"
- Updated main `README.md` to show 🚧 (construction) instead of ✅ for:
  - "Responsive Web Interface" - noted as "setup complete, UI implementation deferred"
  - "All Phase I features work via web UI" - noted as "backend ready, frontend UI deferred"

**Step 4 - Spec Integrity:**
- Verified all 3 specs exist:
  - F01-S01-backend-api-database (spec.md, plan.md, tasks.md) ✓
  - F01-S02-auth-security (spec.md, plan.md, tasks.md) ✓
  - F01-S03-frontend-fullstack (spec.md, plan.md, tasks.md) ✓
- Numbering consistent, no orphaned references

## Outcome

- ✅ Impact: Repository hygiene improved, documentation now accurately reflects implementation state
- 🧪 Tests: None required (documentation-only changes)
- 📁 Files: 3 modified (.gitignore, README.md, backend/README.md), 1 removed from tracking (backend/todo.db)
- 🔁 Next prompts: Commit changes, push to GitHub
- 🧠 Reflection: Documentation drift is common when implementation progresses faster than docs; regular audits prevent reviewer confusion

## Evaluation notes (flywheel)

- Failure modes observed: None - straightforward audit
- Graders run and results (PASS/FAIL): N/A (documentation task)
- Prompt variant (if applicable): standard /sp.task
- Next experiment (smallest change to try): Consider automated doc-sync checks in CI
