# Deployment Fix Guide

## Issues Identified

### Backend (Render)
1. CORS not configured for production frontend URL
2. Database URL needs PostgreSQL connection string
3. JWT secret using default insecure value
4. Environment variables need proper setup

### Frontend (Vercel)
1. API URL hardcoded to localhost
2. Missing production environment variables

## Fix Steps

### 1. Backend Environment Variables (Render Dashboard)

Go to your Render service dashboard and set these environment variables:

```bash
# Database (Get from Neon dashboard)
DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require

# JWT Secret (Generate with: openssl rand -hex 32)
JWT_SECRET=<your-secure-random-secret-here>

# CORS Origins (Add your Vercel URL)
CORS_ORIGINS=https://your-app.vercel.app,http://localhost:3000

# Application Settings
ENVIRONMENT=production
DEBUG=False
LOG_LEVEL=INFO
```

### 2. Frontend Environment Variables (Vercel Dashboard)

Go to your Vercel project settings → Environment Variables and add:

```bash
# Your deployed Render backend URL
NEXT_PUBLIC_API_URL=https://your-backend.onrender.com/api
```

### 3. Generate JWT Secret

Run this command locally to generate a secure JWT secret:

```bash
openssl rand -hex 32
```

Copy the output and use it as JWT_SECRET in Render.

### 4. Get Neon Database URL

1. Go to your Neon dashboard
2. Copy the connection string
3. It should look like: `postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require`
4. Add it as DATABASE_URL in Render

### 5. Redeploy

After setting environment variables:
1. **Render**: Trigger manual deploy or push changes
2. **Vercel**: Redeploy from dashboard

## Verification Checklist

- [ ] Backend health check works: `https://your-backend.onrender.com/`
- [ ] Backend API docs accessible: `https://your-backend.onrender.com/docs`
- [ ] Frontend loads without errors
- [ ] Frontend can reach backend API
- [ ] CORS errors resolved
- [ ] Database connection successful
- [ ] Authentication works end-to-end

## Common Errors and Solutions

### Error: "CORS policy: No 'Access-Control-Allow-Origin'"
**Solution**: Add your Vercel URL to CORS_ORIGINS in Render environment variables

### Error: "Failed to fetch" or "Network error"
**Solution**: Check NEXT_PUBLIC_API_URL in Vercel points to correct Render URL

### Error: "Database connection failed"
**Solution**: Verify DATABASE_URL is correct PostgreSQL connection string from Neon

### Error: "JWT decode error"
**Solution**: Ensure JWT_SECRET is the same value used when tokens were generated

## URLs Reference

Replace these placeholders with your actual URLs:

- **Backend (Render)**: `https://todo-backend-api-xxxx.onrender.com`
- **Frontend (Vercel)**: `https://your-project-name.vercel.app`
- **Database (Neon)**: Connection string from Neon dashboard

## Need More Help?

If errors persist, check:
1. Render service logs: Dashboard → Logs tab
2. Vercel deployment logs: Deployment → Logs
3. Browser console for frontend errors
4. Network tab to see failed API calls
