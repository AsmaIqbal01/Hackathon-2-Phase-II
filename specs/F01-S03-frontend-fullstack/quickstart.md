# Quickstart: Frontend Application (Minimal)

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-02-01
**Scope**: Minimal hackathon integration proof

## Prerequisites

- Node.js 18+ installed
- npm package manager
- Backend API running (see backend/README.md)

## Setup

### 1. Navigate to Frontend Directory

```bash
cd frontend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure Environment

Copy the example environment file:

```bash
cp .env.example .env.local
```

Edit `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### 4. Run Development Server

```bash
npm run dev
```

Frontend available at: http://localhost:3000

---

## Project Structure (Minimal)

```
frontend/
├── app/
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Redirect logic
│   ├── login/page.tsx       # Login form
│   ├── register/page.tsx    # Registration form
│   └── dashboard/page.tsx   # Task list + CRUD
├── lib/
│   ├── api.ts               # API client with JWT
│   └── auth.ts              # Token storage helpers
├── components/
│   ├── TaskList.tsx         # Task list component
│   ├── TaskItem.tsx         # Single task row
│   └── TaskForm.tsx         # Create task form
├── .env.example             # Environment template
└── README.md                # Setup documentation
```

---

## Key Files

### Environment Configuration

```env
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### API Client Usage

```typescript
import { apiClient } from '@/lib/api';
import { Task } from '@/lib/types';

// List tasks
const tasks = await apiClient<Task[]>('/api/tasks');

// Create task
const newTask = await apiClient<Task>('/api/tasks', {
  method: 'POST',
  body: JSON.stringify({ title: 'New task' }),
});

// Toggle task status
const updated = await apiClient<Task>(`/api/tasks/${id}`, {
  method: 'PATCH',
  body: JSON.stringify({ status: 'completed' }),
});

// Delete task
await apiClient(`/api/tasks/${id}`, { method: 'DELETE' });
```

### Auth Helpers Usage

```typescript
import { getToken, setToken, clearToken } from '@/lib/auth';

// Check if logged in
if (getToken()) {
  // User is authenticated
}

// After login
setToken(response.access_token);

// On logout
clearToken();
```

---

## Routes

| Path | Auth Required | Description |
|------|---------------|-------------|
| `/` | No | Redirects to /dashboard or /login |
| `/login` | No | Login form |
| `/register` | No | Registration form |
| `/dashboard` | Yes | Task list and CRUD |

---

## Integration Verification

### Start Backend

```bash
cd backend
source venv/bin/activate  # Windows: venv\Scripts\activate
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

### Start Frontend

```bash
cd frontend
npm run dev
```

### Verify Full Stack Works

1. Open http://localhost:3000
2. Register a new account
3. Create a task
4. Refresh page → task persists (SC-005)
5. Open incognito window
6. Register different account
7. Verify tasks are separate (SC-004)

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Network error" | Check NEXT_PUBLIC_API_URL matches backend |
| 401 Unauthorized | Token expired; re-login |
| CORS errors | Backend must allow frontend origin |
| Empty task list | Check backend connection |

---

## Build for Production

```bash
npm run build
npm start
```

---

## Notes for Reviewers

- JWT stored in localStorage (acceptable for demo)
- No token refresh - re-login on expiry
- No responsive design polish
- Focus is on proving integration correctness
