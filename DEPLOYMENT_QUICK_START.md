# Quick Start Deployment Guide

Fast-track deployment instructions for Vercel (frontend) + Hugging Face (backend).

## Prerequisites
- GitHub account
- Vercel account
- Hugging Face account

## 🚀 Backend Deployment (5 minutes)

### 1. Create Hugging Face Space
- Go to: https://huggingface.co/new-space
- Name: `todo-backend-api`
- SDK: **Docker**
- Click "Create Space"

### 2. Push Code
```bash
cd Phase-II/backend
git init
git remote add hf https://huggingface.co/spaces/YOUR_USERNAME/todo-backend-api
git add .
git commit -m "Initial deployment"
git push hf main
```

### 3. Set Environment Variables
Go to Space → Settings → Variables:

```
ENVIRONMENT=production
SECRET_KEY=<run: python -c "import secrets; print(secrets.token_urlsafe(32))">
CORS_ORIGINS=https://your-app.vercel.app (add after Vercel deployment)
```

### 4. Get Your Backend URL
```
https://YOUR_USERNAME-todo-backend-api.hf.space
```

Test at: `https://YOUR_USERNAME-todo-backend-api.hf.space/docs`

## 🌐 Frontend Deployment (3 minutes)

### 1. Import to Vercel
- Go to: https://vercel.com/new
- Import your GitHub repository
- Root Directory: `Phase-II/frontend`
- Framework: Next.js (auto-detected)

### 2. Add Environment Variable
```
NEXT_PUBLIC_API_URL=https://YOUR_USERNAME-todo-backend-api.hf.space/api
```

### 3. Deploy
- Click "Deploy"
- Get your URL: `https://your-app.vercel.app`

### 4. Update Backend CORS
Go back to Hugging Face Space → Settings → Variables:

Update `CORS_ORIGINS` to:
```
https://your-app.vercel.app
```

## ✅ Verify

1. Visit your Vercel URL
2. Register a new user
3. Login
4. Create a todo
5. Done! 🎉

## 📝 Files Created

**Backend (Hugging Face):**
- `backend/Dockerfile` - Container config
- `backend/app.py` - Entry point
- `backend/README_HUGGINGFACE.md` - HF readme
- `backend/.dockerignore` - Build exclusions

**Frontend (Vercel):**
- `frontend/vercel.json` - Updated with env vars
- `frontend/README_VERCEL.md` - Detailed guide

**Documentation:**
- `DEPLOYMENT_GUIDE.md` - Complete deployment guide
- `DEPLOYMENT_QUICK_START.md` - This file

## 🔧 Troubleshooting

**CORS errors?**
→ Check `CORS_ORIGINS` matches your Vercel URL exactly

**API not connecting?**
→ Verify `NEXT_PUBLIC_API_URL` includes `/api` at the end

**Build failed?**
→ Check build logs in the respective platform dashboard

## 📚 Full Documentation
See `DEPLOYMENT_GUIDE.md` for detailed instructions and troubleshooting.

## 🆘 Quick Fixes

```bash
# Regenerate SECRET_KEY
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Check backend health
curl https://YOUR_USERNAME-todo-backend-api.hf.space/

# View Vercel logs
vercel logs <deployment-url>
```

## Next Steps After Deployment

1. Add custom domain (optional)
2. Set up monitoring
3. Configure analytics
4. Enable automatic deployments from Git
5. Set up staging environment (optional)

---

**Need help?** Check the full `DEPLOYMENT_GUIDE.md` or platform documentation.
