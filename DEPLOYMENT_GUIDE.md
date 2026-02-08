# Deployment Guide: Vercel + Hugging Face

Complete guide to deploy the Phase II Todo Application with frontend on Vercel and backend on Hugging Face Spaces.

## Architecture Overview

```
┌─────────────────┐         ┌─────────────────────┐
│   Vercel        │         │  Hugging Face      │
│   (Frontend)    │ ──────> │  (Backend API)     │
│   Next.js       │  HTTPS  │  FastAPI           │
└─────────────────┘         └─────────────────────┘
```

## Prerequisites

- [GitHub](https://github.com) account (for code hosting)
- [Vercel](https://vercel.com) account (for frontend)
- [Hugging Face](https://huggingface.co) account (for backend)
- Git installed locally
- Your application code ready

## Part 1: Deploy Backend to Hugging Face Spaces

### Step 1: Prepare Backend Files

The following files have been created for Hugging Face deployment:
- `backend/Dockerfile` - Container configuration
- `backend/app.py` - Entry point for HF Spaces
- `backend/README_HUGGINGFACE.md` - HF Space README
- `backend/.dockerignore` - Files to exclude from Docker build

### Step 2: Create Hugging Face Space

1. Go to [huggingface.co/new-space](https://huggingface.co/new-space)
2. Fill in the details:
   - **Space name**: `todo-backend-api` (or your preferred name)
   - **License**: MIT
   - **SDK**: Docker
   - **Space visibility**: Public (or Private if you have Pro)
3. Click "Create Space"

### Step 3: Initialize Git Repository

```bash
# Navigate to backend directory
cd Phase-II/backend

# Initialize git (if not already done)
git init

# Add Hugging Face remote
git remote add hf https://huggingface.co/spaces/YOUR_USERNAME/todo-backend-api

# Add all files
git add .

# Commit
git commit -m "Initial backend deployment"

# Push to Hugging Face
git push hf main
```

Replace `YOUR_USERNAME` with your Hugging Face username.

### Step 4: Configure Environment Variables

In your Hugging Face Space settings, add these environment variables:

1. Go to your Space → Settings → Variables and secrets
2. Add the following:

| Variable | Value | Description |
|----------|-------|-------------|
| `ENVIRONMENT` | `production` | Sets production mode |
| `SECRET_KEY` | `<generate-secure-key>` | JWT secret (see below) |
| `CORS_ORIGINS` | `https://your-app.vercel.app` | Frontend URL (add after Vercel deployment) |

**Generate SECRET_KEY:**
```bash
python -c "import secrets; print(secrets.token_urlsafe(32))"
```

### Step 5: Wait for Build

- Hugging Face will automatically build and deploy your Docker container
- Build typically takes 3-5 minutes
- Watch the build logs in the Space interface
- Once complete, your API will be available at: `https://YOUR_USERNAME-todo-backend-api.hf.space`

### Step 6: Test Backend API

Open in browser: `https://YOUR_USERNAME-todo-backend-api.hf.space/docs`

You should see the Swagger UI documentation.

## Part 2: Deploy Frontend to Vercel

### Step 1: Prepare Frontend

The following files have been created/updated:
- `frontend/vercel.json` - Vercel configuration with env variables
- `frontend/README_VERCEL.md` - Detailed Vercel deployment guide

### Step 2: Push Code to GitHub

```bash
# From project root
git add .
git commit -m "Prepare for deployment"
git push origin main
```

### Step 3: Import to Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. Click "Import Git Repository"
3. Select your GitHub repository
4. Configure project:
   - **Framework Preset**: Next.js (auto-detected)
   - **Root Directory**: `Phase-II/frontend` (if in monorepo)
   - **Build Command**: `npm run build`
   - **Output Directory**: `.next`

### Step 4: Configure Environment Variables

Add environment variable in Vercel:

- **Name**: `NEXT_PUBLIC_API_URL`
- **Value**: `https://YOUR_USERNAME-todo-backend-api.hf.space/api`

**Important**:
- Replace `YOUR_USERNAME` with your actual Hugging Face username
- No trailing slash
- Must include `/api` at the end

### Step 5: Deploy

1. Click "Deploy"
2. Wait for build to complete (1-3 minutes)
3. Vercel will provide your deployment URL: `https://your-app.vercel.app`

### Step 6: Update Backend CORS

Now that you have your Vercel URL, update the backend:

1. Go to Hugging Face Space → Settings → Variables
2. Update `CORS_ORIGINS` to: `https://your-app.vercel.app`
3. Space will automatically rebuild

**For multiple origins:**
```
https://your-app.vercel.app,https://custom-domain.com
```

### Step 7: Test Complete Application

1. Visit your Vercel URL: `https://your-app.vercel.app`
2. Try registering a new user
3. Login and create a todo
4. Verify all CRUD operations work

## Part 3: Verification Checklist

Use this checklist to ensure everything is working:

### Backend (Hugging Face)
- [ ] Space is running (green status)
- [ ] API docs accessible at `/docs`
- [ ] Health check returns 200: `GET /`
- [ ] Register endpoint works: `POST /api/register`
- [ ] Login endpoint works: `POST /api/login`
- [ ] CORS is configured correctly

### Frontend (Vercel)
- [ ] Site is live and accessible
- [ ] Registration page works
- [ ] Login page works
- [ ] Dashboard loads after login
- [ ] Can create todos
- [ ] Can edit todos
- [ ] Can delete todos
- [ ] No CORS errors in browser console

### Integration
- [ ] Frontend successfully calls backend API
- [ ] JWT tokens are stored and sent correctly
- [ ] User authentication flows work end-to-end
- [ ] All CRUD operations function properly

## Troubleshooting

### CORS Errors

**Symptom**: Browser console shows CORS errors

**Solution**:
1. Check `CORS_ORIGINS` in Hugging Face Space settings
2. Ensure it matches your Vercel URL exactly (including https://)
3. No trailing slashes
4. Wait for Space to rebuild after changes

### API Connection Failed

**Symptom**: Frontend can't reach backend

**Solution**:
1. Verify `NEXT_PUBLIC_API_URL` in Vercel environment variables
2. Test backend URL directly in browser
3. Ensure backend Space is running (not in build/error state)
4. Check Network tab in browser DevTools for actual error

### Backend Build Failures

**Symptom**: Hugging Face Space shows build errors

**Solution**:
1. Check build logs in Space interface
2. Verify all files are committed and pushed
3. Ensure `requirements.txt` has all dependencies
4. Check `Dockerfile` syntax

### Frontend Build Failures

**Symptom**: Vercel deployment fails

**Solution**:
1. Check build logs in Vercel dashboard
2. Ensure all dependencies are in `package.json`
3. Verify TypeScript has no errors
4. Check Node.js version compatibility

### JWT Token Issues

**Symptom**: Authentication doesn't persist or fails

**Solution**:
1. Verify `SECRET_KEY` is set in Hugging Face Space
2. Clear browser localStorage and cookies
3. Check token expiration settings
4. Verify Authorization header is being sent

## Monitoring and Maintenance

### Hugging Face Spaces

- Check Space status: Space dashboard
- View logs: Space → Settings → Logs
- Resource usage: Space → Settings → Usage
- Rebuild Space: Space → Settings → Factory reboot

### Vercel

- View deployments: Project → Deployments
- Check analytics: Project → Analytics
- View logs: Deployment → View Function Logs
- Redeploy: Deployments → Three dots → Redeploy

## Updating Your Application

### Backend Updates

```bash
cd Phase-II/backend
# Make changes
git add .
git commit -m "Update backend"
git push hf main
```

Hugging Face will automatically rebuild.

### Frontend Updates

```bash
# Make changes
git add .
git commit -m "Update frontend"
git push origin main
```

Vercel will automatically deploy from your GitHub repository.

## Custom Domains

### Vercel Custom Domain

1. Vercel → Project → Settings → Domains
2. Add your domain
3. Configure DNS as instructed
4. Update backend CORS_ORIGINS

### Hugging Face Custom Domain

Hugging Face Spaces don't support custom domains directly. Use a reverse proxy or API gateway if needed.

## Cost Considerations

### Hugging Face Spaces
- **Free Tier**: CPU-based Spaces (sufficient for small apps)
- **Paid**: Upgraded hardware if needed
- **Limits**: Check [pricing](https://huggingface.co/pricing)

### Vercel
- **Hobby**: Free for personal projects
- **Pro**: $20/month for commercial use
- **Limits**: 100GB bandwidth, 6000 build minutes/month on free tier

## Security Best Practices

1. **Never commit secrets**: Use environment variables
2. **Use HTTPS**: Both platforms provide this by default
3. **Set strong SECRET_KEY**: Use cryptographically secure random string
4. **Limit CORS origins**: Only allow your actual frontend domains
5. **Keep dependencies updated**: Regularly update packages
6. **Monitor logs**: Check for suspicious activity
7. **Use environment-specific configs**: Different keys for dev/prod

## Additional Resources

- [Hugging Face Spaces Documentation](https://huggingface.co/docs/hub/spaces)
- [Vercel Documentation](https://vercel.com/docs)
- [FastAPI Deployment](https://fastapi.tiangolo.com/deployment/)
- [Next.js Deployment](https://nextjs.org/docs/deployment)

## Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review platform-specific logs
3. Test endpoints individually
4. Check browser DevTools Network tab
5. Verify all environment variables are set correctly

## Quick Reference

### Backend URL Format
```
https://YOUR_USERNAME-SPACE_NAME.hf.space
```

### Frontend URL Format
```
https://PROJECT_NAME.vercel.app
```

### Key Environment Variables

**Backend (Hugging Face):**
- `ENVIRONMENT=production`
- `SECRET_KEY=<secure-random-string>`
- `CORS_ORIGINS=https://your-app.vercel.app`

**Frontend (Vercel):**
- `NEXT_PUBLIC_API_URL=https://your-space.hf.space/api`

---

**Deployment Status**:
- Backend: Hugging Face Spaces (Docker)
- Frontend: Vercel (Next.js)
- Database: SQLite (included with backend)

**Next Steps**:
1. Deploy backend to Hugging Face following Part 1
2. Deploy frontend to Vercel following Part 2
3. Complete verification checklist in Part 3
4. Enjoy your live application! 🚀
