# Quickstart: Frontend Application

**Feature**: F01-S03-frontend-fullstack
**Date**: 2026-01-30

## Prerequisites

- Node.js 18+ installed
- Backend API running (Spec 1)
- Auth API running (Spec 2)
- Environment variable: `NEXT_PUBLIC_API_URL`

## Setup

```bash
# Navigate to frontend directory
cd frontend

# Install dependencies
npm install

# Configure environment
cp .env.example .env.local
# Edit .env.local:
# NEXT_PUBLIC_API_URL=http://localhost:8000

# Start development server
npm run dev
```

## Project Structure

```
frontend/
├── app/
│   ├── layout.tsx           # Root layout with AuthProvider
│   ├── page.tsx             # Landing → redirect
│   ├── login/page.tsx       # Login form
│   ├── signup/page.tsx      # Registration form
│   └── dashboard/
│       ├── layout.tsx       # Protected layout
│       └── page.tsx         # Task list + CRUD
├── components/
│   ├── auth/
│   │   ├── LoginForm.tsx
│   │   └── SignupForm.tsx
│   ├── tasks/
│   │   ├── TaskList.tsx
│   │   ├── TaskItem.tsx
│   │   └── TaskForm.tsx
│   └── ui/
│       ├── Button.tsx
│       ├── Input.tsx
│       └── Modal.tsx
├── lib/
│   ├── api-client.ts        # Centralized fetch
│   ├── auth-context.tsx     # Auth state provider
│   └── types.ts             # TypeScript interfaces
└── middleware.ts            # Route protection
```

## Key Files

### Environment

```env
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### API Client Usage

```typescript
import { apiClient } from '@/lib/api-client';
import { Task } from '@/lib/types';

// List tasks
const tasks = await apiClient<Task[]>('/api/tasks');

// Create task
const newTask = await apiClient<Task>('/api/tasks', {
  method: 'POST',
  body: JSON.stringify({ title: 'New task' }),
});

// Update task
const updated = await apiClient<Task>(`/api/tasks/${id}`, {
  method: 'PATCH',
  body: JSON.stringify({ status: 'completed' }),
});

// Delete task
await apiClient(`/api/tasks/${id}`, { method: 'DELETE' });
```

### Auth Context Usage

```typescript
import { useAuth } from '@/lib/auth-context';

function Component() {
  const { user, isAuthenticated, login, logout } = useAuth();

  if (!isAuthenticated) {
    return <p>Please log in</p>;
  }

  return <p>Welcome, {user.email}</p>;
}
```

## Routes

| Path | Auth | Description |
|------|------|-------------|
| `/` | No | Landing, redirects to dashboard or login |
| `/login` | No | Login form |
| `/signup` | No | Registration form |
| `/dashboard` | Yes | Task list and CRUD |

## Common Tasks

### Add a new task
1. Navigate to `/dashboard`
2. Click "Add Task"
3. Enter title (required)
4. Submit

### Mark task complete
1. Find task in list
2. Click status toggle or edit
3. Change status to "completed"

### Delete a task
1. Find task in list
2. Click delete button
3. Confirm in modal

## Testing

```bash
# Run tests
npm test

# Run dev server with backend
# Terminal 1: Backend (Spec 1 + Spec 2)
cd backend && uvicorn src.main:app --reload

# Terminal 2: Frontend
cd frontend && npm run dev
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Network error" | Check NEXT_PUBLIC_API_URL matches backend |
| 401 on all requests | Token expired; re-login |
| CORS errors | Backend must allow frontend origin |
| Build fails | Run `npm install` again |

## Integration Verification

1. Start backend at `http://localhost:8000`
2. Start frontend at `http://localhost:3000`
3. Register a new user
4. Create a task
5. Refresh page → task persists
6. Log out and log in → same tasks visible
