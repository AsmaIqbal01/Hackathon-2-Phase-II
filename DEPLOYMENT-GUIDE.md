# 🚀 Production Deployment Guide

## Prerequisites

Before deploying, ensure you have:
- ✅ GitHub repository pushed with latest changes
- ✅ Neon PostgreSQL database created
- ✅ Accounts on Vercel and Render

---

## Step 1: Deploy Backend to Render

### 1.1 Create Neon Database

1. Go to https://neon.tech
2. Create a new project
3. Copy the connection string (it looks like):
   ```
   postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   ```

### 1.2 Deploy to Render

1. Go to https://render.com/dashboard
2. Click **"New +"** → **"Web Service"**
3. Connect your GitHub repository: `AsmaIqbal01/Hackathon-2-Phase-II`
4. Configure the service:
   - **Name**: `todo-backend-api` (or your preferred name)
   - **Region**: Oregon (or closest to you)
   - **Root Directory**: `backend`
   - **Runtime**: Python 3
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `uvicorn src.main:app --host 0.0.0.0 --port $PORT`
   - **Plan**: Free

5. Add Environment Variables (click "Advanced" → "Add Environment Variable"):

   ```bash
   # Required Environment Variables
   DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
   JWT_SECRET=2264d2687508b3ba5ebd564345977b91f2ebb582c56c07dfd925a7e8fc51daf5
   ENVIRONMENT=production
   DEBUG=False
   LOG_LEVEL=INFO
   CORS_ORIGINS=https://your-app.vercel.app,http://localhost:3000
   APP_NAME=Todo Backend API
   JWT_ALGORITHM=HS256
   JWT_ACCESS_EXPIRE_MINUTES=60
   JWT_REFRESH_EXPIRE_DAYS=7
   ```

   **Important**: Replace:
   - `DATABASE_URL`: Your actual Neon connection string
   - `CORS_ORIGINS`: Update after deploying frontend (add your Vercel URL)

6. Click **"Create Web Service"**

7. Wait for deployment to complete (5-10 minutes)

8. Copy your backend URL: `https://todo-backend-api-xxxx.onrender.com`

9. Test the backend:
   ```bash
   curl https://todo-backend-api-xxxx.onrender.com/
   # Should return: {"status":"healthy","service":"Todo Backend API",...}
   ```

---

## Step 2: Deploy Frontend to Vercel

### 2.1 Deploy to Vercel

1. Go to https://vercel.com/dashboard
2. Click **"Add New..."** → **"Project"**
3. Import your GitHub repository: `AsmaIqbal01/Hackathon-2-Phase-II`
4. Configure the project:
   - **Framework Preset**: Next.js
   - **Root Directory**: `frontend`
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm install`

5. Add Environment Variable:
   ```bash
   NEXT_PUBLIC_API_URL=https://todo-backend-api-xxxx.onrender.com/api
   ```

   **Important**: Replace with your actual Render backend URL + `/api`

6. Click **"Deploy"**

7. Wait for deployment to complete (2-5 minutes)

8. Copy your frontend URL: `https://your-app.vercel.app`

---

## Step 3: Update Backend CORS Settings

Now that you have your Vercel URL, update the backend CORS settings:

1. Go back to Render dashboard
2. Open your backend service
3. Go to **Environment**
4. Update `CORS_ORIGINS` variable:
   ```
   https://your-app.vercel.app,http://localhost:3000
   ```
5. Save changes (this will trigger a redeploy)

---

## Step 4: Verify Deployment

### 4.1 Test Backend

```bash
# Health check
curl https://todo-backend-api-xxxx.onrender.com/

# API docs
https://todo-backend-api-xxxx.onrender.com/docs
```

### 4.2 Test Frontend

1. Open your Vercel URL: `https://your-app.vercel.app`
2. Should see the cyberpunk-styled todo app
3. Try to register a new account
4. Try to login
5. Try creating a task

### 4.3 Expected Behavior

✅ **Frontend loads** with cyberpunk styling
✅ **Registration works** (creates user in Neon DB)
✅ **Login works** (returns JWT token)
✅ **Dashboard shows** user's tasks
✅ **CRUD operations work** (create, read, update, delete tasks)

---

## Common Issues & Solutions

### Issue 1: Backend "Not Found" Error

**Symptom**: Frontend shows "Failed to connect to server"

**Solution**:
- Verify backend is running: Visit `https://your-backend.onrender.com/`
- Check Render logs for errors
- Verify `NEXT_PUBLIC_API_URL` in Vercel includes `/api` suffix

### Issue 2: CORS Error

**Symptom**: Browser console shows CORS policy error

**Solution**:
- Add your Vercel URL to `CORS_ORIGINS` in Render
- Format: `https://your-app.vercel.app,http://localhost:3000`
- No trailing slashes
- Comma-separated, no spaces

### Issue 3: Database Connection Error

**Symptom**: Backend logs show "could not connect to database"

**Solution**:
- Verify `DATABASE_URL` is correct
- Ensure it includes `?sslmode=require`
- Check Neon dashboard - database should be active
- Test connection: `psql <DATABASE_URL>`

### Issue 4: JWT Token Error

**Symptom**: "Invalid token" or "Unauthorized" errors

**Solution**:
- Ensure `JWT_SECRET` matches between deployments
- Clear browser cookies/localStorage
- Try logging out and back in

### Issue 5: Render Free Tier Sleep

**Symptom**: First request takes 30+ seconds

**Solution**:
- Render free tier sleeps after inactivity
- First request wakes it up (slow)
- Subsequent requests are fast
- Upgrade to paid plan to avoid sleep

---

## Auto-Redeployment

### Automatic Redeployment on Git Push

Both Vercel and Render automatically redeploy when you push to GitHub:

**Vercel** (Frontend):
- Auto-redeploys on push to `main` branch
- Takes 2-5 minutes
- Check status at: https://vercel.com/dashboard

**Render** (Backend):
- Auto-redeploys on push to `main` branch
- Takes 5-10 minutes
- Check status at: https://render.com/dashboard

### Manual Redeployment

**Vercel**:
1. Go to project dashboard
2. Click **"Deployments"**
3. Click **"Redeploy"** on latest deployment

**Render**:
1. Go to service dashboard
2. Click **"Manual Deploy"** → **"Deploy latest commit"**

---

## Production Environment Variables Summary

### Backend (Render)

| Variable | Value | Description |
|----------|-------|-------------|
| `DATABASE_URL` | Neon connection string | PostgreSQL database |
| `JWT_SECRET` | `2264d2687508b3ba5ebd564345977b91f2ebb582c56c07dfd925a7e8fc51daf5` | JWT signing secret |
| `ENVIRONMENT` | `production` | Environment mode |
| `DEBUG` | `False` | Disable debug mode |
| `LOG_LEVEL` | `INFO` | Logging level |
| `CORS_ORIGINS` | `https://your-app.vercel.app,http://localhost:3000` | Allowed origins |
| `APP_NAME` | `Todo Backend API` | Application name |

### Frontend (Vercel)

| Variable | Value | Description |
|----------|-------|-------------|
| `NEXT_PUBLIC_API_URL` | `https://todo-backend-api-xxxx.onrender.com/api` | Backend API URL |

---

## Monitoring & Logs

### Render Logs
1. Go to service dashboard
2. Click **"Logs"** tab
3. Real-time logs show requests, errors, database queries

### Vercel Logs
1. Go to project dashboard
2. Click **"Deployments"**
3. Click on a deployment → **"View Function Logs"**

---

## Security Checklist

Before going to production:

- [ ] Use strong `JWT_SECRET` (minimum 32 characters)
- [ ] Never commit secrets to GitHub
- [ ] Set `DEBUG=False` in production
- [ ] Verify CORS only allows your domains
- [ ] Use HTTPS for all connections
- [ ] Enable Neon connection pooling if high traffic
- [ ] Set up database backups in Neon
- [ ] Monitor error rates and response times

---

## URLs to Save

After deployment, save these URLs:

- **Frontend**: https://your-app.vercel.app
- **Backend**: https://todo-backend-api-xxxx.onrender.com
- **API Docs**: https://todo-backend-api-xxxx.onrender.com/docs
- **Database**: Neon dashboard - https://console.neon.tech

---

## Next Steps

1. ✅ Deploy backend to Render
2. ✅ Deploy frontend to Vercel
3. ✅ Update CORS settings
4. ✅ Test full flow (register, login, create tasks)
5. ✅ Share your live app URL!

---

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review deployment logs (Render/Vercel dashboards)
3. Verify all environment variables are set correctly
4. Test backend health endpoint directly

**Your JWT Secret (save this)**: `2264d2687508b3ba5ebd564345977b91f2ebb582c56c07dfd925a7e8fc51daf5`
