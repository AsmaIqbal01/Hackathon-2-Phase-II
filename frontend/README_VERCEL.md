# Frontend Deployment on Vercel

This guide explains how to deploy the Next.js frontend to Vercel.

## Prerequisites

- A Vercel account (sign up at [vercel.com](https://vercel.com))
- Your backend deployed on Hugging Face Spaces
- Git repository with your code

## Deployment Steps

### 1. Push Your Code to Git

Make sure your frontend code is pushed to GitHub, GitLab, or Bitbucket.

```bash
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

### 2. Import Project to Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. Click "Import Project"
3. Connect your Git repository
4. Select the repository containing your frontend code
5. Vercel will auto-detect Next.js

### 3. Configure Project Settings

**Root Directory**: Set to `Phase-II/frontend` if deploying from monorepo

**Framework Preset**: Next.js (auto-detected)

**Build Command**: `npm run build` (default)

**Output Directory**: `.next` (default)

### 4. Configure Environment Variables

Add the following environment variable:

- **Key**: `NEXT_PUBLIC_API_URL`
- **Value**: `https://your-huggingface-space.hf.space/api`

Replace `your-huggingface-space` with your actual Hugging Face Space URL.

**Important**: Make sure there's no trailing slash in the URL.

### 5. Deploy

Click "Deploy" and wait for the build to complete (usually 1-2 minutes).

### 6. Update Backend CORS Settings

After deployment, you need to update your Hugging Face Space backend to allow requests from your Vercel domain:

1. Go to your Hugging Face Space settings
2. Add environment variable:
   - **Key**: `CORS_ORIGINS`
   - **Value**: `https://your-app.vercel.app`

Replace `your-app.vercel.app` with your actual Vercel domain.

## Custom Domain (Optional)

1. Go to your Vercel project settings
2. Navigate to "Domains"
3. Add your custom domain
4. Follow DNS configuration instructions
5. Update CORS_ORIGINS in backend to include your custom domain

## Updating Environment Variables

To update environment variables after deployment:

1. Go to your Vercel project settings
2. Navigate to "Environment Variables"
3. Add/edit/delete variables
4. Redeploy your application (Vercel > Deployments > Redeploy)

## Troubleshooting

### CORS Errors

If you see CORS errors in the browser console:

1. Verify `CORS_ORIGINS` in Hugging Face Space includes your Vercel URL
2. Make sure there are no trailing slashes
3. Check that the URL matches exactly (https vs http)

### API Connection Issues

1. Verify `NEXT_PUBLIC_API_URL` is set correctly
2. Test the API endpoint directly in browser
3. Check Network tab in browser DevTools for actual requests
4. Ensure the backend is running and accessible

### Build Failures

1. Check build logs in Vercel dashboard
2. Ensure all dependencies are in package.json
3. Verify Node.js version compatibility
4. Check for TypeScript errors

## Automatic Deployments

Vercel automatically deploys:
- **Production**: Every push to `main` branch
- **Preview**: Every push to other branches and pull requests

Each deployment gets a unique URL for testing.

## Monitoring

- View deployment logs in Vercel dashboard
- Check Analytics for performance metrics
- Use Vercel's built-in monitoring tools

## Environment-Specific URLs

- **Production**: https://your-app.vercel.app
- **Preview**: https://your-app-git-branch.vercel.app
- **Development**: http://localhost:3000 (local)

## Security Notes

- Never commit `.env.local` files
- All `NEXT_PUBLIC_*` variables are exposed to the browser
- Keep sensitive keys on the backend only
- Use Vercel's environment variables for secrets
