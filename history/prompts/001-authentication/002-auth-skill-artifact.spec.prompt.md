---
id: 002
title: Auth Skill Artifact Creation
stage: spec
date: 2026-01-02
surface: agent
model: claude-sonnet-4-5
feature: 001-authentication
branch: 001-authentication
user: system
command: manual
labels: ["authentication", "reusable-intelligence", "skill-definition"]
links:
  spec: specs/001-authentication/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - reusable_intelligence/auth.skill.md
tests:
  - Skill definition captures frozen authentication scope
---

## Prompt

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

and save as reusable_intelligence/auth.skill.md

## Response snapshot

Created reusable intelligence artifact for authentication skill at `reusable_intelligence/auth.skill.md`.

**Skill Definition**:
- **Responsibilities**: Prompt, validate, create session, expose user_id
- **Functions**: authenticate_user(), is_authenticated(), get_current_user()
- **Rules**: Pre-task authentication, runtime session, exit destruction
- **Errors**: Invalid credentials, authentication required

This skill artifact captures the frozen authentication scope as a reusable intelligence component for the backend agent system.

## Outcome

- ✅ Impact: Created reusable intelligence artifact defining authentication skill interface
- 🧪 Tests: Skill definition aligns with frozen authentication scope (single user, backend agent, session-based)
- 📁 Files: reusable_intelligence/auth.skill.md (concise skill definition)
- 🔁 Next prompts: Ready for `/sp.plan` with skill artifact available for reference
- 🧠 Reflection: Skill definition provides clear contract for backend agent authentication implementation

## Evaluation notes (flywheel)

- Failure modes observed: None - straightforward artifact creation
- Graders run and results (PASS/FAIL): PASS - Skill definition complete and aligned with spec
- Prompt variant (if applicable): Standard skill artifact creation
- Next experiment (smallest change to try): Reference this skill artifact in implementation plan to ensure contract compliance
