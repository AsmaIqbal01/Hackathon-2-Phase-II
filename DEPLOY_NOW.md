# 🚀 Deploy Now - Action Steps

Your deployment files are ready and pushed to GitHub!
Follow these steps to get your app live in **~10 minutes**.

## ✅ Part 1: Deploy Backend to Hugging Face (5 min)

### Step 1: Create Hugging Face Space

1. **Open in browser**: https://huggingface.co/new-space
2. **Login** (or create account if needed)
3. **Fill the form**:
   - Space name: `todo-backend-api`
   - License: `MIT`
   - Select SDK: **Docker** ⚠️ Important!
   - Visibility: Public (or Private if you have Pro)
4. Click **"Create Space"**

### Step 2: Push Backend Code

Open your terminal and run:

```bash
cd E:/Hackathon\ 2/Phase-II/backend

# Initialize git in backend directory (if not already done)
git init

# Add Hugging Face as remote (replace YOUR_USERNAME)
git remote add hf https://huggingface.co/spaces/YOUR_USERNAME/todo-backend-api

# Commit and push
git add .
git commit -m "Initial Hugging Face deployment"
git push hf main
```

**Replace `YOUR_USERNAME`** with your actual Hugging Face username!

⏳ Wait 3-5 minutes for the build to complete. Watch the logs in your Space.

### Step 3: Configure Backend Environment Variables

1. Go to your Space page
2. Click **Settings** tab
3. Click **"Variables and secrets"**
4. Add these three variables:

**Variable 1:**
```
Name: ENVIRONMENT
Value: production
```

**Variable 2:**
```
Name: SECRET_KEY
Value: [Generate using command below]
```

To generate SECRET_KEY, run in terminal:
```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```
Copy the output and paste as the value.

**Variable 3:**
```
Name: CORS_ORIGINS
Value: [Leave blank for now, will add after Vercel deployment]
```

5. Click **"Save"**
6. Space will rebuild automatically

### Step 4: Note Your Backend URL

Your backend will be available at:
```
https://YOUR_USERNAME-todo-backend-api.hf.space
```

Test it by visiting:
```
https://YOUR_USERNAME-todo-backend-api.hf.space/docs
```

You should see the Swagger API documentation! ✅

---

## ✅ Part 2: Deploy Frontend to Vercel (5 min)

### Step 1: Import to Vercel

1. **Open in browser**: https://vercel.com/new
2. **Login** with GitHub (or create account)
3. Click **"Import Git Repository"**
4. Select repository: `AsmaIqbal01/Hackathon-2-Phase-II`
5. Click **"Import"**

### Step 2: Configure Vercel Project

In the configuration screen:

1. **Framework Preset**: Next.js (should auto-detect ✓)
2. **Root Directory**: Click "Edit" and enter: `Phase-II/frontend`
3. **Build Command**: `npm run build` (default)
4. **Output Directory**: `.next` (default)

### Step 3: Add Environment Variable

Still on the configuration screen:

1. Expand **"Environment Variables"** section
2. Add variable:
   - **Name**: `NEXT_PUBLIC_API_URL`
   - **Value**: `https://YOUR_USERNAME-todo-backend-api.hf.space/api`

   ⚠️ **Important**:
   - Replace `YOUR_USERNAME` with your HF username
   - Include `/api` at the end
   - No trailing slash after `/api`

### Step 4: Deploy!

1. Click **"Deploy"** button
2. ⏳ Wait 1-3 minutes for build
3. You'll get a URL like: `https://hackathon-2-phase-ii.vercel.app`

### Step 5: Update Backend CORS

Now go back to Hugging Face:

1. Go to your Space → Settings → Variables and secrets
2. Edit the `CORS_ORIGINS` variable
3. Set value to your Vercel URL:
   ```
   https://your-vercel-app.vercel.app
   ```
   (Use your actual Vercel URL from step 4.3)
4. Save

⏳ Space will rebuild (2-3 minutes)

---

## ✅ Part 3: Test Your Live App! (2 min)

### Open Your App

Visit your Vercel URL: `https://your-vercel-app.vercel.app`

### Test Flow

1. **Register**: Click "Register" → Create new account
2. **Login**: Use your credentials to login
3. **Create Todo**: Add a new todo item
4. **Edit Todo**: Modify the todo
5. **Delete Todo**: Remove the todo
6. **Check Console**: Press F12, check no CORS errors

### Success! 🎉

If all the above works, your app is successfully deployed!

---

## 🐛 Troubleshooting

### Issue: CORS Error in Browser Console

**Symptom**: Red errors mentioning CORS or "Access-Control-Allow-Origin"

**Fix**:
1. Go to HF Space → Settings → Variables
2. Check `CORS_ORIGINS` matches your Vercel URL **exactly**
3. Ensure it starts with `https://` (not `http://`)
4. No trailing slash
5. Wait for Space to rebuild

### Issue: Can't Connect to Backend

**Symptom**: "Failed to fetch" or "Network error"

**Fix**:
1. Check backend is running: Visit `https://YOUR_USERNAME-todo-backend-api.hf.space/`
2. Should see: `{"status":"healthy",...}`
3. If Space shows error, check build logs
4. Verify `NEXT_PUBLIC_API_URL` in Vercel settings

### Issue: Backend Build Failed

**Symptom**: HF Space shows "Build failed" or error status

**Fix**:
1. Check Space logs for specific error
2. Ensure all files were pushed: `git log --oneline -5`
3. Verify Dockerfile syntax is correct
4. Check requirements.txt has all dependencies

### Issue: Frontend Build Failed

**Symptom**: Vercel deployment shows red "Error"

**Fix**:
1. Click on failed deployment → View build logs
2. Common issues:
   - Wrong root directory (should be `Phase-II/frontend`)
   - Missing environment variable
   - Node version mismatch
3. Redeploy after fixing: Deployments → Redeploy

### Issue: Login Doesn't Work

**Symptom**: Can't login or token errors

**Fix**:
1. Verify `SECRET_KEY` is set in HF Space
2. Clear browser cookies and localStorage
3. Try registering a new user
4. Check Network tab in DevTools for actual error

---

## 📝 Quick Reference

### Your URLs

- **Backend API**: `https://YOUR_USERNAME-todo-backend-api.hf.space`
- **API Docs**: `https://YOUR_USERNAME-todo-backend-api.hf.space/docs`
- **Frontend**: `https://your-vercel-app.vercel.app`
- **GitHub**: `https://github.com/AsmaIqbal01/Hackathon-2-Phase-II`

### Commands

**Generate SECRET_KEY:**
```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

**Test backend health:**
```bash
curl https://YOUR_USERNAME-todo-backend-api.hf.space/
```

**View git log:**
```bash
cd Phase-II/backend
git log --oneline -5
```

---

## 🎯 Next Steps After Deployment

1. ✅ Share your live app URL
2. 📊 Monitor performance in Vercel Analytics
3. 🔒 Add custom domain (optional)
4. 📈 Set up error tracking (optional)
5. 🔄 Set up CI/CD (already automatic with Git!)

---

## 📚 Documentation Files

- `DEPLOYMENT_GUIDE.md` - Complete detailed guide
- `DEPLOYMENT_QUICK_START.md` - Quick reference
- `backend/README_HUGGINGFACE.md` - Backend deployment details
- `frontend/README_VERCEL.md` - Frontend deployment details

---

## ✨ Summary

**What you're deploying:**
- ✅ FastAPI backend with JWT authentication
- ✅ Next.js frontend with modern UI
- ✅ Full CRUD todo application
- ✅ User registration and login
- ✅ Secure API communication

**Deployment platforms:**
- 🚀 Backend: Hugging Face Spaces (Docker)
- 🌐 Frontend: Vercel (Next.js)
- 💾 Database: SQLite (included with backend)

**Estimated total time**: ~10 minutes
**Cost**: $0 (Free tier for both platforms)

---

## 🆘 Need Help?

If you get stuck:
1. Check the troubleshooting section above
2. Review platform-specific logs
3. Ensure all environment variables are set correctly
4. Test each component independently
5. Check `DEPLOYMENT_GUIDE.md` for detailed instructions

---

**Ready? Start with Part 1 above! 🚀**

Remember to replace `YOUR_USERNAME` with your actual Hugging Face username throughout!
