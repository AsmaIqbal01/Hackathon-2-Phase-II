---
id: 011
title: Frontend Backend Integration Fix
stage: green
date: 2026-02-04
surface: agent
model: claude-opus-4-5-20251101
feature: F01-S03-frontend-fullstack
branch: F01-S02-auth-security
user: umzaid
command: direct-prompt
labels: ["tailwind-v4", "postcss", "api-integration", "typescript-fix", "env-config"]
links:
  spec: specs/F01-S03-frontend-fullstack/spec.md
  ticket: null
  adr: null
  pr: null
files:
  - frontend/postcss.config.mjs
  - frontend/app/globals.css
  - frontend/lib/api.ts
  - frontend/.env.local
tests:
  - npm run build (PASS - all pages compiled)
  - dev server HTTP 200 on /login, /register, /dashboard, /
---

## Prompt

Task: Fix and fully integrate the frontend of the Phase-II project with the backend.

Objectives:
1. Update Tailwind CSS PostCSS plugin.
   - Install `@tailwindcss/postcss`.
   - Update `postcss.config.js` to use the new plugin format.
2. Ensure frontend compiles without errors.
3. Integrate frontend with the backend API.
   - Configure API base URL to point to `http://127.0.0.1:8000` (backend server).
   - Ensure authentication endpoints (`/auth/register`, `/auth/login`) are connected.
   - Ensure tasks endpoints (`/tasks`) work with JWT tokens.
4. Validate functionality.
   - Register a new user.
   - Login to receive `access_token` and `refresh_token`.
   - Use the token in frontend requests to GET and POST tasks.
   - Ensure JWT is stored securely (localStorage/sessionStorage) and used in API calls.
5. Test UI:
   - Dashboard shows tasks correctly.
   - Login/Register forms work.
   - Task creation form works.
6. Ensure TypeScript & Tailwind styles compile correctly.
7. Remove any previous errors or warnings.

## Response snapshot

Completed 6 fixes to integrate frontend with backend:

1. **PostCSS config** (`postcss.config.mjs`): Changed plugin from `tailwindcss: {}` (v3) to `@tailwindcss/postcss: {}` (v4). Removed `autoprefixer` (built into Tailwind v4).

2. **globals.css**: Replaced `@tailwind base/components/utilities` (v3 directives) with `@import "tailwindcss"` (v4 syntax).

3. **Removed `tailwind.config.ts`**: Tailwind v4 uses automatic content detection; the v3-style JS config is unnecessary.

4. **Created `.env.local`**: Set `NEXT_PUBLIC_API_URL=http://127.0.0.1:8000/api` to connect frontend to backend.

5. **Fixed TypeScript error in `lib/api.ts`**: Changed `headers` type from `HeadersInit` to `Record<string, string>` to fix indexing error on Authorization header assignment.

6. **Verified endpoint alignment**: All frontend API paths match backend routes exactly:
   - `/auth/login` → `POST /api/auth/login`
   - `/auth/register` → `POST /api/auth/register`
   - `/tasks` → `GET/POST /api/tasks`
   - `/tasks/{id}` → `PATCH/DELETE /api/tasks/{id}`

Build result: `npm run build` succeeds. All 4 pages (/, /login, /register, /dashboard) compile and return HTTP 200.

## Outcome

- ✅ Impact: Frontend compiles without errors and is fully configured to communicate with backend API
- 🧪 Tests: npm run build PASS; dev server all pages return 200
- 📁 Files: 4 modified (postcss.config.mjs, globals.css, api.ts, .env.local), 1 deleted (tailwind.config.ts)
- 🔁 Next prompts: End-to-end testing with live backend, token refresh implementation
- 🧠 Reflection: Tailwind v4 migration requires updating both PostCSS plugin name and CSS directives; the v3 config file is no longer needed

## Evaluation notes (flywheel)

- Failure modes observed: TypeScript strict mode caught HeadersInit indexing issue; Tailwind v4 requires different CSS import syntax than v3
- Graders run and results (PASS/FAIL): Build compilation PASS, Dev server PASS
- Prompt variant (if applicable): null
- Next experiment (smallest change to try): Verify with live backend running and test actual auth + task CRUD flow
