# Quick Fix Guide - Deployment Errors

## 🚨 If your deployment is showing errors, follow this guide

### The 3-Minute Fix

#### 1. Generate JWT Secret (30 seconds)
```bash
openssl rand -hex 32
```
Copy the output.

#### 2. Configure Render Backend (1 minute)

Go to: https://dashboard.render.com → Your Service → Environment

Add these variables:

| Variable | Value |
|----------|-------|
| `DATABASE_URL` | Your Neon PostgreSQL URL from Neon dashboard |
| `JWT_SECRET` | The output from step 1 |
| `CORS_ORIGINS` | `https://your-vercel-url.vercel.app,http://localhost:3000` |

Click **Save**. Wait for automatic redeployment.

#### 3. Configure Vercel Frontend (1 minute)

Go to: https://vercel.com/dashboard → Your Project → Settings → Environment Variables

Add this variable:

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_API_URL` | `https://your-render-backend.onrender.com/api` |

Click **Save**.

Go to: Deployments → Click latest → Redeploy

#### 4. Get Your URLs

**Find your Render backend URL:**
- Render Dashboard → Your Service
- URL at the top: `https://todo-backend-api-xxxx.onrender.com`

**Find your Vercel frontend URL:**
- Vercel Dashboard → Your Project
- Domains section: `https://your-project.vercel.app`

**Find your Neon database URL:**
- Neon Console → Your Project → Connection Details
- Format: `postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require`

### Test It Works

1. **Test backend:**
   ```bash
   curl https://your-backend-url.onrender.com/
   ```
   Should return: `{"status":"healthy",...}`

2. **Test frontend:**
   - Open: `https://your-vercel-url.vercel.app`
   - Should load without errors
   - Open DevTools (F12) → Console
   - Should see no red errors

3. **Test full flow:**
   - Click "Sign Up"
   - Create account
   - Log in
   - Create a task
   - Task should save ✓

## Common Errors & Quick Fixes

### ❌ "Failed to fetch"
**Fix:** Check `NEXT_PUBLIC_API_URL` in Vercel points to your Render URL + `/api`

### ❌ "CORS policy error"
**Fix:** Add your Vercel URL to `CORS_ORIGINS` in Render (no trailing slash)

### ❌ "Database connection failed"
**Fix:** Set `DATABASE_URL` in Render to your Neon PostgreSQL connection string

### ❌ "Backend returns 503"
**Fix:** Check Render logs for errors. Usually missing environment variables.

### ❌ "First load is very slow"
**Fix:** This is normal for Render free tier (cold start). Paid tier fixes this.

## Need More Help?

- **Detailed guide:** See `DEPLOYMENT-CHECKLIST.md`
- **Diagnostic tool:** Run `./diagnose-deployment.sh`
- **Setup helper:** Run `./setup-deployment.sh`

## Environment Variables Quick Reference

### Render (Backend)
```
DATABASE_URL=postgresql://...neon.tech/neondb?sslmode=require
JWT_SECRET=<32-byte-hex-from-openssl>
CORS_ORIGINS=https://your-app.vercel.app,http://localhost:3000
ENVIRONMENT=production
DEBUG=False
```

### Vercel (Frontend)
```
NEXT_PUBLIC_API_URL=https://your-backend.onrender.com/api
```

---

**That's it!** Your deployment should now work. If errors persist, check the detailed guide.
