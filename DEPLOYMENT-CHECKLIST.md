# Deployment Checklist - Phase II Todo Application

## Prerequisites

- [ ] Neon PostgreSQL database created
- [ ] Render account with backend service deployed
- [ ] Vercel account with frontend project deployed
- [ ] OpenSSL installed (for generating JWT secret)

## Step-by-Step Deployment Fix

### Step 1: Generate JWT Secret

```bash
# Run this command to generate a secure JWT secret
openssl rand -hex 32
```

**Copy the output** - you'll need it in Step 2.

### Step 2: Configure Backend (Render)

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your backend service (`todo-backend-api`)
3. Click on **"Environment"** tab in the left sidebar
4. Add/update these environment variables:

| Key | Value | Notes |
|-----|-------|-------|
| `DATABASE_URL` | `postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require` | Get from Neon dashboard |
| `JWT_SECRET` | `<your-generated-secret-from-step-1>` | Use output from openssl command |
| `CORS_ORIGINS` | `https://your-app.vercel.app,http://localhost:3000` | Replace with your Vercel URL |
| `ENVIRONMENT` | `production` | Should be set |
| `DEBUG` | `False` | Should be set |
| `LOG_LEVEL` | `INFO` | Optional |
| `APP_NAME` | `Todo Backend API` | Optional |

5. Click **"Save Changes"**
6. Render will automatically trigger a new deployment
7. Wait for deployment to complete (check "Events" tab)

### Step 3: Get Your Backend URL

1. In Render dashboard, find your service URL
2. It should look like: `https://todo-backend-api-xxxx.onrender.com`
3. **Copy this URL** - you'll need it for Step 4

**Test your backend:**
- Visit: `https://your-backend-url.onrender.com/`
- You should see: `{"status": "healthy", "service": "Todo Backend API", ...}`
- Visit: `https://your-backend-url.onrender.com/docs`
- You should see the interactive API documentation

### Step 4: Configure Frontend (Vercel)

1. Go to [Vercel Dashboard](https://vercel.com/dashboard)
2. Click on your frontend project
3. Go to **"Settings"** → **"Environment Variables"**
4. Add this environment variable:

| Key | Value |
|-----|-------|
| `NEXT_PUBLIC_API_URL` | `https://your-backend-url.onrender.com/api` |

**Important:**
- Use your actual Render URL from Step 3
- Include `/api` at the end
- No trailing slash after `/api`

5. Click **"Save"**

### Step 5: Redeploy Frontend

1. Still in Vercel dashboard, go to **"Deployments"** tab
2. Find the latest deployment
3. Click the three dots menu (•••) on the right
4. Click **"Redeploy"**
5. Check **"Use existing Build Cache"** (optional for faster deploy)
6. Click **"Redeploy"**
7. Wait for deployment to complete

### Step 6: Update CORS in Backend (If Needed)

If you haven't done this yet or need to update:

1. Go back to Render dashboard
2. Find your Vercel frontend URL
   - In Vercel: Project → Settings → Domains
   - Example: `https://my-todo-app.vercel.app`
3. Update `CORS_ORIGINS` in Render environment variables:
   ```
   https://my-todo-app.vercel.app,http://localhost:3000
   ```
4. Save changes and wait for redeployment

### Step 7: Get Neon Database URL

If you haven't set this up yet:

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project
3. Go to **"Dashboard"** or **"Connection Details"**
4. Copy the **"Connection string"**
5. It should look like:
   ```
   postgresql://user:password@ep-random-id.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```
6. Use this as `DATABASE_URL` in Render (Step 2)

## Verification

### ✓ Backend Verification

```bash
# Health check
curl https://your-backend-url.onrender.com/

# Expected response:
# {"status":"healthy","service":"Todo Backend API","version":"1.0.0",...}

# API docs (open in browser)
https://your-backend-url.onrender.com/docs
```

### ✓ Frontend Verification

1. Open your Vercel URL in browser: `https://your-app.vercel.app`
2. Open browser DevTools (F12)
3. Go to **Console** tab
4. Look for errors (there should be none)
5. Go to **Network** tab
6. Try to sign up or log in
7. Check API calls:
   - Should go to your Render backend URL
   - Should not show CORS errors
   - Should return successful responses

### ✓ Full Integration Test

1. Open frontend in browser
2. Click **"Sign Up"**
3. Enter email and password
4. Click **"Sign Up"** button
5. Should successfully create account
6. Should redirect to dashboard or login page
7. Log in with credentials
8. Should see dashboard with task list
9. Try creating a task
10. Task should save successfully

## Common Errors and Solutions

### Error: "Failed to fetch" / Network Error

**Symptoms:**
- Frontend shows "Failed to fetch" errors
- Network tab shows failed requests
- Requests are going to wrong URL

**Solution:**
1. Check `NEXT_PUBLIC_API_URL` in Vercel
2. Should be: `https://your-backend-url.onrender.com/api`
3. Should NOT be: `http://localhost:8000/api`
4. Redeploy frontend after fixing

### Error: "CORS policy: No 'Access-Control-Allow-Origin'"

**Symptoms:**
- Browser console shows CORS error
- API request fails with CORS message
- Backend is responding but browser blocks it

**Solution:**
1. Check `CORS_ORIGINS` in Render environment variables
2. Should include your Vercel URL: `https://your-app.vercel.app`
3. No trailing slashes
4. Comma-separated if multiple: `https://your-app.vercel.app,http://localhost:3000`
5. Save and wait for Render to redeploy

### Error: "Database connection failed" / "could not connect to server"

**Symptoms:**
- Backend logs show database connection errors
- Signup/login fails with 500 error
- Health check works but API calls fail

**Solution:**
1. Check `DATABASE_URL` in Render
2. Should be PostgreSQL connection string from Neon
3. Should include `?sslmode=require` at the end
4. Format: `postgresql://user:password@host/database?sslmode=require`
5. Verify Neon database is active
6. Check Neon connection limits

### Error: "JWT decode error" / "Invalid token"

**Symptoms:**
- Login successful but subsequent requests fail
- "Unauthorized" errors after login
- Token validation fails

**Solution:**
1. Check `JWT_SECRET` is set in Render
2. Should be a secure random string (use `openssl rand -hex 32`)
3. Must be the same value across deployments
4. Don't use default value: `change-this-secret-key-in-production`

### Error: Backend takes long time to respond (Cold starts)

**Symptoms:**
- First request after inactivity is slow (10-30 seconds)
- Subsequent requests are fast
- "Loading..." state lasts long on first visit

**Solution:**
This is normal for Render free tier (cold starts). Options:
1. Upgrade to paid tier for always-on instances
2. Implement a keep-alive ping service
3. Add loading states in frontend
4. Show user-friendly messages during cold starts

### Error: "Application failed to respond" / 503 Service Unavailable

**Symptoms:**
- Backend URL returns 503 error
- Render dashboard shows "Failed" deployment
- Build or start fails

**Solution:**
1. Check Render deployment logs:
   - Dashboard → Your Service → Logs tab
2. Look for error messages in logs
3. Common issues:
   - Python version mismatch
   - Missing dependencies in requirements.txt
   - Wrong start command
   - Environment variable issues
4. Fix the issue and redeploy

## Quick Reference URLs

| Service | Purpose | URL Format |
|---------|---------|------------|
| Backend | API Server | `https://todo-backend-api-xxxx.onrender.com` |
| Backend Docs | API Documentation | `https://todo-backend-api-xxxx.onrender.com/docs` |
| Frontend | Web Application | `https://your-project.vercel.app` |
| Database | PostgreSQL | `postgresql://...@ep-xxx...neon.tech/neondb` |

## Environment Variables Summary

### Backend (Render)
```bash
DATABASE_URL=postgresql://...neon.tech/neondb?sslmode=require
JWT_SECRET=<secure-random-32-byte-hex>
CORS_ORIGINS=https://your-app.vercel.app,http://localhost:3000
ENVIRONMENT=production
DEBUG=False
LOG_LEVEL=INFO
```

### Frontend (Vercel)
```bash
NEXT_PUBLIC_API_URL=https://your-backend.onrender.com/api
```

## Helper Scripts

We've created helper scripts to make deployment easier:

### Setup Deployment
```bash
./setup-deployment.sh
```
Generates secure JWT secret and creates configuration file with all your environment variables.

### Diagnose Issues
```bash
./diagnose-deployment.sh
```
Tests your deployment and identifies specific issues:
- Backend health check
- Database connection
- CORS configuration
- Frontend accessibility

## Need More Help?

### Check Logs

**Render (Backend):**
1. Dashboard → Your Service
2. Click "Logs" tab
3. Filter by time or search for errors

**Vercel (Frontend):**
1. Dashboard → Your Project
2. Click "Deployments" tab
3. Click on a deployment
4. Click "View Function Logs" or "Build Logs"

**Browser (Frontend):**
1. Press F12 to open DevTools
2. Check "Console" tab for JavaScript errors
3. Check "Network" tab for failed API calls
4. Look for red entries or CORS errors

### Common Debugging Steps

1. **Backend not responding:**
   - Check Render service is "Live" (not "Suspended")
   - Check deployment succeeded
   - Look at Render logs for errors
   - Try redeploying

2. **Frontend can't reach backend:**
   - Verify NEXT_PUBLIC_API_URL is correct
   - Check it includes `/api` at the end
   - No typos in the URL
   - Redeploy after changing

3. **CORS errors persist:**
   - Double-check CORS_ORIGINS format
   - No trailing slashes
   - Comma-separated (no spaces)
   - Includes your exact Vercel URL
   - Wait for Render to finish redeploying

4. **Authentication not working:**
   - JWT_SECRET must be set
   - Must be secure (not default value)
   - Same secret across all instances
   - Check browser cookies are enabled

## Success Criteria

Your deployment is successful when:

- [ ] Backend health check returns 200 OK
- [ ] Backend API docs are accessible
- [ ] Frontend loads without errors
- [ ] Can sign up new user
- [ ] Can log in with credentials
- [ ] Can create tasks
- [ ] Tasks persist after refresh
- [ ] No CORS errors in console
- [ ] No "Failed to fetch" errors
- [ ] API calls reach correct backend URL

## Maintenance

### Updating Environment Variables

**After changing environment variables:**
1. Backend (Render): Automatically redeploys
2. Frontend (Vercel): Must manually redeploy

### Monitoring

**Check regularly:**
- Render service status
- Neon database connection limits
- Vercel deployment status
- Error logs in both platforms

### Security

**Important:**
- Never commit `.env` files
- Use secure JWT secrets (not defaults)
- Rotate JWT secrets periodically
- Use HTTPS URLs only (no HTTP)
- Keep dependencies updated

---

**Last Updated:** 2026-02-09
