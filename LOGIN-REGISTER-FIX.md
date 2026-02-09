# Login & Register "Failed to Fetch" Fix

## Root Cause Analysis

The "Failed to fetch" error had **three root causes**:

### 1. ❌ Missing Network Error Handling (PRIMARY ISSUE)
**Location**: `frontend/lib/api.ts:37-40`

**Problem**: The `fetch()` API call was not wrapped in try-catch, so when the backend was unreachable, it threw an unhandled network error instead of a user-friendly message.

**Before**:
```typescript
const response = await fetch(url, {
  ...fetchOptions,
  headers,
});
```

**After**:
```typescript
let response: Response;
try {
  response = await fetch(url, {
    ...fetchOptions,
    headers,
  });
} catch (error) {
  // Network error (backend unreachable, CORS, etc.)
  console.error('Network error:', error);
  throw new Error('Failed to connect to server. Please ensure the backend is running.');
}
```

**Impact**: Now shows clear error message: *"Failed to connect to server. Please ensure the backend is running."*

---

### 2. ❌ Incorrect Frontend API URL
**Location**: `frontend/.env.local:1`

**Problem**: Missing `/api` suffix in the base URL.

**Before**:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

**After**:
```env
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

**Why**: Backend routes are mounted at `/api/auth/login` and `/api/auth/register` (see `backend/src/main.py:202-212`).

---

### 3. ❌ Backend Server Not Running
**Problem**: The FastAPI backend was not running, causing all API requests to fail with network errors.

**Solution**: Start the backend server before using the app.

---

## How to Fix

### Option 1: Use Automated Startup Script (RECOMMENDED)

**For Windows**:
```bash
# From Phase-II directory
start-dev.bat
```

This will:
- ✅ Create virtual environment (if needed)
- ✅ Install backend dependencies
- ✅ Start backend at `http://localhost:8000`
- ✅ Install frontend dependencies
- ✅ Start frontend at `http://localhost:3000`
- ✅ Open both in separate windows

**For Linux/Mac**:
```bash
chmod +x start-dev.sh
./start-dev.sh
```

---

### Option 2: Manual Startup

**Terminal 1 - Backend**:
```bash
cd "E:\Hackathon 2\Phase-II\backend"

# Create virtual environment (first time only)
python -m venv venv

# Activate virtual environment
# Windows (CMD):
venv\Scripts\activate.bat
# Windows (PowerShell):
venv\Scripts\Activate.ps1
# Windows (Git Bash):
source venv/Scripts/activate

# Install dependencies (first time only)
pip install -r requirements.txt

# Start backend server
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

**Terminal 2 - Frontend**:
```bash
cd "E:\Hackathon 2\Phase-II\frontend"

# Install dependencies (first time only)
npm install

# Start frontend server
npm run dev
```

---

## Verification Steps

1. **Check Backend is Running**:
   ```bash
   curl http://localhost:8000/
   ```
   Expected output: `{"status":"healthy","message":"Todo Backend API","version":"1.0.0"}`

2. **Check Auth Endpoints**:
   - Register: `http://localhost:8000/api/auth/register`
   - Login: `http://localhost:8000/api/auth/login`
   - Docs: `http://localhost:8000/docs` (interactive API documentation)

3. **Check Frontend**:
   - Open `http://localhost:3000`
   - Go to `/login` or `/register`
   - Try registering a new account
   - You should see success toast and redirect to dashboard

4. **Check Browser Console**:
   - Open DevTools (F12)
   - Go to Console tab
   - Should see API requests to `http://localhost:8000/api/auth/...`
   - No CORS errors
   - No network errors

---

## What Was Fixed

### File Changes

1. **`frontend/lib/api.ts`** (Lines 36-47)
   - ✅ Added try-catch around `fetch()` call
   - ✅ Clear error message for network failures
   - ✅ Console logging for debugging

2. **`frontend/.env.local`** (Line 1)
   - ✅ Changed `http://localhost:8000` → `http://localhost:8000/api`

3. **NEW: `start-dev.bat`**
   - ✅ Automated startup script for Windows

4. **NEW: `start-dev.sh`**
   - ✅ Automated startup script for Linux/Mac

---

## Expected Request Flow

### Registration Flow
```
User clicks "Register"
    ↓
Frontend: POST http://localhost:8000/api/auth/register
    Body: { "email": "user@example.com", "password": "password123" }
    ↓
Backend: Validates email/password
    ↓
Backend: Hashes password with bcrypt
    ↓
Backend: Creates user in database
    ↓
Backend: Generates JWT access token
    ↓
Backend: Returns 201 Created
    Body: { "user": {...}, "access_token": "...", ... }
    ↓
Frontend: Stores token in localStorage
    ↓
Frontend: Redirects to /dashboard
    ↓
Success! ✅
```

### Login Flow
```
User clicks "Login"
    ↓
Frontend: POST http://localhost:8000/api/auth/login
    Body: { "email": "user@example.com", "password": "password123" }
    ↓
Backend: Finds user by email
    ↓
Backend: Verifies password hash
    ↓
Backend: Generates JWT access token
    ↓
Backend: Returns 200 OK
    Body: { "user": {...}, "access_token": "...", ... }
    ↓
Frontend: Stores token in localStorage
    ↓
Frontend: Redirects to /dashboard
    ↓
Success! ✅
```

---

## Common Errors & Solutions

### Error: "Failed to connect to server"
**Cause**: Backend is not running
**Solution**: Start backend with `uvicorn src.main:app --reload`

### Error: "404 Not Found"
**Cause**: Wrong API endpoint URL
**Solution**: Verify `.env.local` has `/api` suffix

### Error: CORS policy error
**Cause**: Backend CORS not configured for frontend origin
**Solution**: Check `backend/.env` has `CORS_ORIGINS=http://localhost:3000`

### Error: "Email already registered"
**Cause**: User already exists in database
**Solution**: Use different email or delete `backend/todo.db` to reset

### Error: "Invalid credentials"
**Cause**: Wrong email or password
**Solution**: Verify credentials or register new account

---

## Technical Details

### Backend API Structure
```
FastAPI App (main.py)
├── / (health check)
└── /api
    ├── /auth (auth.router)
    │   ├── POST /register
    │   ├── POST /login
    │   ├── POST /logout
    │   ├── POST /refresh
    │   └── GET /me
    └── /tasks (tasks.router)
        ├── GET /tasks
        ├── POST /tasks
        ├── GET /tasks/{id}
        ├── PATCH /tasks/{id}
        └── DELETE /tasks/{id}
```

### Frontend API Client
- **Location**: `frontend/lib/api.ts`
- **Base URL**: `NEXT_PUBLIC_API_URL` from `.env.local`
- **Features**:
  - Automatic JWT injection (Authorization header)
  - 401 handling (auto-redirect to /login)
  - Network error handling (NEW!)
  - Centralized error responses

---

## Testing Checklist

- [ ] Backend starts without errors
- [ ] Frontend starts without errors
- [ ] Can access `http://localhost:3000`
- [ ] Can access `http://localhost:8000/docs`
- [ ] Register form works (creates account)
- [ ] Login form works (authenticates user)
- [ ] Dashboard loads after login
- [ ] No console errors in browser
- [ ] Clear error messages on failures

---

## Next Steps

1. **Test authentication thoroughly**
   - Register multiple users
   - Login/logout flows
   - Token persistence

2. **Verify user isolation**
   - Each user should only see their own tasks
   - Cross-user access should return 403

3. **Test error cases**
   - Invalid email format
   - Weak passwords
   - Duplicate registration
   - Wrong credentials

4. **Deploy to production**
   - Update environment variables
   - Use production database (Neon PostgreSQL)
   - Enable HTTPS
   - Rotate JWT secrets

---

## Additional Resources

- **Backend Docs**: http://localhost:8000/docs
- **Backend README**: `backend/README.md`
- **Frontend README**: `frontend/README.md`
- **API Documentation**: http://localhost:8000/redoc

---

**Status**: ✅ FIXED
**Date**: 2026-02-09
**Files Modified**: 2
**Files Created**: 3
