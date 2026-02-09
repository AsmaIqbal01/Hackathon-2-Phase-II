# 🔄 Redeploy to Existing URLs

## Current Status

### Backend (Render)
- ✅ **Active**: https://hackathon-2-phase-ii.onrender.com/
- Status: Healthy and responding
- Auto-deploys on git push to `main`

### Frontend (Vercel)
- ⚠️ **Not Found**: https://hackathon-2-phase-ii-psi.vercel.app/
- Status: Deployment not found (may need reconnection)

---

## Option 1: Automatic Redeployment (Recommended)

Both platforms are configured to auto-deploy when you push to GitHub `main` branch.

### What Just Happened
✅ We just pushed commits:
- `88479e7` - Deployment docs and error handling
- `e2205ba` - Repository cleanup

**Expected Behavior**:
- **Render**: Should auto-deploy within 5-10 minutes
- **Vercel**: Should auto-deploy within 2-5 minutes

### Check Deployment Status

**Render**:
1. Go to: https://dashboard.render.com/
2. Find service: `hackathon-2-phase-ii` or similar
3. Check "Events" tab for recent deployments
4. Look for: "Deploy started" or "Live"

**Vercel**:
1. Go to: https://vercel.com/dashboard
2. Find project: `hackathon-2-phase-ii-psi`
3. Click "Deployments" tab
4. Look for latest deployment with "Building" or "Ready"

---

## Option 2: Manual Redeployment

If auto-deployment doesn't trigger, manually redeploy:

### Redeploy Backend (Render)

1. **Login**: https://dashboard.render.com/
2. **Find Service**: Look for `hackathon-2-phase-ii` or your backend service
3. **Manual Deploy**:
   - Click on the service
   - Click **"Manual Deploy"** button (top right)
   - Select **"Deploy latest commit"**
   - Confirm deployment
4. **Monitor Logs**:
   - Click **"Logs"** tab
   - Watch for successful startup
   - Should see: `Uvicorn running on http://0.0.0.0:$PORT`
5. **Verify**:
   ```bash
   curl https://hackathon-2-phase-ii.onrender.com/
   # Should return: {"status":"healthy",...}
   ```

### Redeploy Frontend (Vercel)

#### If Project Exists:

1. **Login**: https://vercel.com/dashboard
2. **Find Project**: `hackathon-2-phase-ii-psi`
3. **Redeploy**:
   - Click on the project
   - Go to **"Deployments"** tab
   - Find latest deployment
   - Click **"..."** menu → **"Redeploy"**
   - Confirm redeployment
4. **Monitor**:
   - Watch build progress
   - Wait for "Ready" status (2-5 minutes)
5. **Verify**:
   - Visit: https://hackathon-2-phase-ii-psi.vercel.app/
   - Should see cyberpunk todo app

#### If Project Doesn't Exist (Reconnect):

1. **Login**: https://vercel.com/dashboard
2. **Import Project**:
   - Click **"Add New..."** → **"Project"**
   - Select **"Import Git Repository"**
   - Choose: `AsmaIqbal01/Hackathon-2-Phase-II`
   - Click **"Import"**
3. **Configure**:
   - **Framework Preset**: Next.js ✅ (auto-detected)
   - **Root Directory**: `frontend` ⚠️ **IMPORTANT**
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`
   - **Install Command**: `npm install`
4. **Environment Variables**:
   - Click **"Environment Variables"**
   - Add:
     ```
     NEXT_PUBLIC_API_URL=https://hackathon-2-phase-ii.onrender.com/api
     ```
5. **Deploy**:
   - Click **"Deploy"**
   - Wait for build to complete
6. **Get URL**:
   - After deployment, Vercel will assign a URL
   - To use custom domain `hackathon-2-phase-ii-psi.vercel.app`:
     - Go to **"Settings"** → **"Domains"**
     - Add domain if not already there

---

## Option 3: Quick Verification Commands

Run these to check current deployment status:

```bash
# Check backend (Render)
curl https://hackathon-2-phase-ii.onrender.com/

# Check API docs
curl https://hackathon-2-phase-ii.onrender.com/docs

# Check frontend (Vercel)
curl -I https://hackathon-2-phase-ii-psi.vercel.app/
```

---

## Environment Variables Check

### Backend (Render)

Ensure these are set in Render dashboard:

```bash
DATABASE_URL=postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require
JWT_SECRET=2264d2687508b3ba5ebd564345977b91f2ebb582c56c07dfd925a7e8fc51daf5
ENVIRONMENT=production
DEBUG=False
LOG_LEVEL=INFO
CORS_ORIGINS=https://hackathon-2-phase-ii-psi.vercel.app,http://localhost:3000
APP_NAME=Todo Backend API
JWT_ALGORITHM=HS256
JWT_ACCESS_EXPIRE_MINUTES=60
JWT_REFRESH_EXPIRE_DAYS=7
```

**Critical**: Update `CORS_ORIGINS` to include your Vercel URL!

### Frontend (Vercel)

Ensure this is set in Vercel dashboard:

```bash
NEXT_PUBLIC_API_URL=https://hackathon-2-phase-ii.onrender.com/api
```

---

## Troubleshooting

### Issue 1: Render Backend Not Redeploying

**Symptoms**: No recent deployment in Render Events

**Solution**:
1. Check if auto-deploy is enabled:
   - Service → **Settings** → **Build & Deploy**
   - Ensure "Auto-Deploy" is **Yes**
   - Branch should be `main`
2. Manually trigger deploy (see Option 2 above)

### Issue 2: Vercel Frontend Not Found

**Symptoms**: `DEPLOYMENT_NOT_FOUND` error

**Solution**:
1. Check if project still exists in Vercel dashboard
2. If not, reimport project (see "If Project Doesn't Exist" above)
3. Ensure correct root directory: `frontend`
4. Ensure environment variable is set: `NEXT_PUBLIC_API_URL`

### Issue 3: CORS Error After Redeployment

**Symptoms**: Browser console shows CORS policy error

**Solution**:
1. Go to Render dashboard → Your service → **Environment**
2. Update `CORS_ORIGINS`:
   ```
   https://hackathon-2-phase-ii-psi.vercel.app,http://localhost:3000
   ```
3. Save (this triggers redeploy)

### Issue 4: Frontend Can't Connect to Backend

**Symptoms**: "Failed to connect to server" message

**Solution**:
1. Verify backend is running: `curl https://hackathon-2-phase-ii.onrender.com/`
2. Check Vercel environment variable:
   - Project → **Settings** → **Environment Variables**
   - Should be: `https://hackathon-2-phase-ii.onrender.com/api`
   - Note: **Must include `/api` suffix**
3. Redeploy frontend after fixing env var

---

## Expected Timeline

After pushing to GitHub:

| Platform | Auto-Deploy Time | Manual Deploy Time |
|----------|-----------------|-------------------|
| **Render** | 5-10 minutes | 5-10 minutes |
| **Vercel** | 2-5 minutes | 2-5 minutes |

**Total**: ~7-15 minutes for both platforms

---

## Verification Checklist

After redeployment, verify:

- [ ] Backend health: `curl https://hackathon-2-phase-ii.onrender.com/`
- [ ] Frontend loads: Visit https://hackathon-2-phase-ii-psi.vercel.app/
- [ ] Can access login page
- [ ] Can register new account
- [ ] Can login with credentials
- [ ] Can create/view/update/delete tasks
- [ ] No CORS errors in browser console

---

## Quick Commands

```bash
# Test backend
curl https://hackathon-2-phase-ii.onrender.com/

# Test backend API docs
open https://hackathon-2-phase-ii.onrender.com/docs

# Test frontend
open https://hackathon-2-phase-ii-psi.vercel.app/

# Check git status
git log --oneline -3
git status
```

---

## Current Git Commits

Your latest commits are:
- ✅ `e2205ba` - Repository cleanup (JUST PUSHED)
- ✅ `88479e7` - Deployment docs and error handling (JUST PUSHED)
- ✅ `ea8abc6` - Deployment action guide

Both Render and Vercel should detect these and auto-deploy.

---

## Next Steps

1. ✅ Code pushed to GitHub: **DONE**
2. ⏳ Wait 5-10 minutes for auto-deployment
3. 🔍 Check Render dashboard for deployment status
4. 🔍 Check Vercel dashboard for deployment status
5. ✅ Verify both URLs are working
6. 🎉 Test full application flow

---

## Support

If issues persist after 15 minutes:
1. Check deployment logs in Render/Vercel dashboards
2. Verify environment variables are correct
3. Manually trigger redeployment
4. Check this guide's troubleshooting section

**Your deployed URLs**:
- Backend: https://hackathon-2-phase-ii.onrender.com/
- Frontend: https://hackathon-2-phase-ii-psi.vercel.app/
