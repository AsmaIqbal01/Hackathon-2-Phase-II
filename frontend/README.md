# Frontend – Next.js 16+ App Router

**Phase II Full-Stack Web Application Frontend**

This is the frontend web application for the Evolution of Todo Phase II project, built with Next.js 16+, TypeScript, Tailwind CSS, and Better Auth.

---

## Overview

The frontend provides:

- **Responsive Web UI** built with Next.js App Router
- **JWT-based authentication** with Better Auth
- **Type-safe development** with TypeScript
- **Modern styling** with Tailwind CSS
- **API integration** with centralized client
- **Server Components** for optimal performance

---

## Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| Framework | **Next.js 16+** | React framework with App Router |
| Language | **TypeScript** | Type safety and developer experience |
| Styling | **Tailwind CSS** | Utility-first CSS framework |
| Authentication | **Better Auth** | JWT token management |
| State Management | **React Hooks** | useState, useContext, custom hooks |
| HTTP Client | **Fetch API** | Centralized API client with JWT |

---

## Project Structure (Planned)

```
frontend/
├── app/                              # Next.js App Router
│   ├── layout.tsx                    # Root layout
│   ├── page.tsx                      # Home page (/)
│   ├── login/
│   │   └── page.tsx                  # Login page
│   ├── signup/
│   │   └── page.tsx                  # Signup page
│   └── dashboard/
│       ├── layout.tsx                # Dashboard layout (protected)
│       ├── page.tsx                  # Dashboard page
│       └── tasks/
│           ├── page.tsx              # Task list
│           └── [id]/
│               └── page.tsx          # Task detail
├── components/
│   ├── ui/                           # Reusable UI components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Card.tsx
│   │   └── Modal.tsx
│   ├── tasks/                        # Task-specific components
│   │   ├── TaskList.tsx
│   │   ├── TaskItem.tsx
│   │   ├── TaskForm.tsx
│   │   └── TaskFilters.tsx
│   └── auth/                         # Auth-related components
│       ├── LoginForm.tsx
│       ├── SignupForm.tsx
│       └── ProtectedRoute.tsx
├── lib/
│   ├── api-client.ts                 # Centralized API client
│   ├── auth.ts                       # Better Auth configuration
│   └── utils.ts                      # Utility functions
├── types/
│   ├── task.ts                       # Task TypeScript types
│   └── user.ts                       # User TypeScript types
├── styles/
│   └── globals.css                   # Global styles (Tailwind)
├── public/                           # Static assets
├── .env.local.example                # Environment variables template
├── package.json
├── tsconfig.json
├── tailwind.config.js
├── next.config.js
└── README.md                         # This file
```

---

## Setup (To Be Implemented)

### Prerequisites

- **Node.js** 20+ (LTS recommended)
- **npm** or **yarn**

### Installation

```bash
cd frontend
npm install
# or
yarn install
```

### Configuration

Copy the example environment file:

```bash
cp .env.local.example .env.local
```

Edit `.env.local`:

```ini
# Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8000

# Better Auth Configuration
NEXT_PUBLIC_AUTH_URL=http://localhost:3000
NEXT_PUBLIC_JWT_SECRET=your-secret-key-must-match-backend

# Environment
NODE_ENV=development
```

**IMPORTANT**: `NEXT_PUBLIC_JWT_SECRET` MUST match the `JWT_SECRET` in the backend `.env`.

### Running Development Server

```bash
npm run dev
# or
yarn dev
```

Visit [http://localhost:3000](http://localhost:3000)

---

## Features (To Be Implemented)

### 1. Authentication

- **Signup**: User registration with email and password
- **Login**: JWT-based authentication via Better Auth
- **Protected Routes**: Dashboard and task pages require authentication
- **Auto Redirect**: Redirect to login if not authenticated

### 2. Task Management

- **List Tasks**: View all tasks for authenticated user
- **Create Task**: Add new task with title, description, priority, tags
- **Update Task**: Edit task details and status
- **Delete Task**: Remove task from list
- **Filter Tasks**: Filter by status, priority, tags
- **Search Tasks**: Search by title or description

### 3. Responsive Design

- **Mobile-First**: Designed for mobile, tablet, and desktop
- **Tailwind CSS**: Utility-first styling
- **Breakpoints**: sm (640px), md (768px), lg (1024px), xl (1280px)

### 4. API Integration

- **Centralized Client**: Single API client with JWT headers
- **Error Handling**: Handle 401 (redirect to login), 403 (access denied)
- **Type Safety**: TypeScript types for requests and responses

---

## API Client Pattern (To Be Implemented)

```typescript
// lib/api-client.ts
import { authClient } from '@/lib/auth'

export async function fetchAPI(endpoint: string, options?: RequestInit) {
  const session = await authClient.getSession()
  const token = session?.token

  if (!token) {
    window.location.href = '/login'
    throw new Error('Not authenticated')
  }

  const response = await fetch(
    `${process.env.NEXT_PUBLIC_API_URL}${endpoint}`,
    {
      ...options,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
        ...options?.headers,
      },
    }
  )

  if (response.status === 401) {
    window.location.href = '/login'
    throw new Error('Authentication required')
  }

  if (response.status === 403) {
    throw new Error('Access denied')
  }

  if (!response.ok) {
    throw new Error(`API error: ${response.status}`)
  }

  return response.json()
}
```

---

## Better Auth Configuration (To Be Implemented)

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth/client"

export const authClient = betterAuth({
  baseURL: process.env.NEXT_PUBLIC_AUTH_URL || "http://localhost:3000",
  storage: {
    type: "cookie",
    cookieOptions: {
      httpOnly: true,
      secure: process.env.NODE_ENV === "production",
      sameSite: "lax",
      maxAge: 7 * 24 * 60 * 60, // 7 days
    },
  },
  jwt: {
    secret: process.env.NEXT_PUBLIC_JWT_SECRET!,
    expiresIn: "1h",
  },
  refreshToken: {
    enabled: true,
    expiresIn: "7d",
    autoRefresh: true,
  },
})
```

---

## Development Workflow

### Agentic Dev Stack

This frontend will be implemented using the **Agentic Dev Stack** workflow:

1. **Create Specification**: Define frontend requirements
2. **Generate Plan**: Architecture decisions and component structure
3. **Break into Tasks**: Atomic implementation tasks
4. **Implement with Agent**: Use `nextjs-frontend-optimizer` agent

### Agent: nextjs-frontend-optimizer

The `nextjs-frontend-optimizer` agent handles:

- Next.js App Router file structure
- Server Components vs Client Components decisions
- Responsive design with Tailwind CSS
- Performance optimization (memoization, lazy loading)
- Accessibility (WCAG 2.1 AA compliance)
- Component architecture and reusability

---

## Building for Production

```bash
npm run build
# or
yarn build
```

### Start Production Server

```bash
npm run start
# or
yarn start
```

---

## Deployment

### Vercel (Recommended)

1. Push code to GitHub
2. Connect repository to Vercel
3. Configure environment variables
4. Deploy

### Environment Variables (Production)

```ini
NEXT_PUBLIC_API_URL=https://your-backend-api.railway.app
NEXT_PUBLIC_AUTH_URL=https://your-frontend.vercel.app
NEXT_PUBLIC_JWT_SECRET=your-production-secret-key
NODE_ENV=production
```

---

## References

- **Next.js Documentation**: https://nextjs.org/docs
- **Tailwind CSS**: https://tailwindcss.com/docs
- **Better Auth**: https://www.better-auth.com/docs
- **TypeScript**: https://www.typescriptlang.org/docs

---

## Implementation Status

🚧 **STATUS**: Not yet implemented

The frontend will be implemented following the **Spec-Driven Development** workflow:

1. Create frontend specification
2. Generate implementation plan
3. Break into atomic tasks
4. Implement using `nextjs-frontend-optimizer` agent

See [../CLAUDE.md](../CLAUDE.md) for development workflow details.

---

**To be built with Next.js 16+, TypeScript, and Tailwind CSS** ⚛️
