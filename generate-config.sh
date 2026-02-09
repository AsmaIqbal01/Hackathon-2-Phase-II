#!/bin/bash

# Non-interactive configuration generator
# Generates a configuration template you can fill in

set -e

echo "=================================================="
echo "Configuration Generator"
echo "=================================================="
echo ""

# Generate JWT Secret
echo "Generating secure JWT secret..."
JWT_SECRET=$(openssl rand -hex 32)

# Create configuration template
cat > DEPLOYMENT-CONFIG-TEMPLATE.txt << EOF
================================================
DEPLOYMENT CONFIGURATION TEMPLATE
================================================

🔐 GENERATED JWT SECRET:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
$JWT_SECRET
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 FILL IN YOUR URLS BELOW:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. RENDER BACKEND URL:
   Find in: Render Dashboard → Your Service
   Format: https://todo-backend-api-xxxx.onrender.com

   YOUR URL: _________________________________

2. VERCEL FRONTEND URL:
   Find in: Vercel Dashboard → Your Project → Domains
   Format: https://your-project-name.vercel.app

   YOUR URL: _________________________________

3. NEON DATABASE URL:
   Find in: Neon Console → Your Project → Connection Details
   Format: postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/neondb?sslmode=require

   YOUR URL: _________________________________


================================================
BACKEND (RENDER) ENVIRONMENT VARIABLES
================================================

Copy these to: Render Dashboard → Your Service → Environment

DATABASE_URL=[PASTE YOUR NEON DATABASE URL HERE]

JWT_SECRET=$JWT_SECRET

CORS_ORIGINS=[PASTE YOUR VERCEL URL HERE],http://localhost:3000
Example: https://my-app.vercel.app,http://localhost:3000

ENVIRONMENT=production

DEBUG=False

LOG_LEVEL=INFO

APP_NAME=Todo Backend API


================================================
FRONTEND (VERCEL) ENVIRONMENT VARIABLES
================================================

Copy these to: Vercel Dashboard → Your Project → Settings → Environment Variables

NEXT_PUBLIC_API_URL=[PASTE YOUR RENDER URL HERE]/api
Example: https://todo-backend-api-xxxx.onrender.com/api


================================================
DEPLOYMENT STEPS
================================================

STEP 1: Configure Backend (Render)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Go to https://dashboard.render.com
2. Click on your service: todo-backend-api
3. Click "Environment" tab
4. For each variable above:
   - Click "Add Environment Variable"
   - Enter Key (e.g., DATABASE_URL)
   - Enter Value (replace [PASTE...] with your actual URL)
   - Click "Save"
5. Click "Save Changes" at the bottom
6. Wait for automatic redeployment (2-5 minutes)

STEP 2: Configure Frontend (Vercel)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Go to https://vercel.com/dashboard
2. Click on your project
3. Go to "Settings" → "Environment Variables"
4. Click "Add New"
5. Enter:
   - Key: NEXT_PUBLIC_API_URL
   - Value: [Your Render URL]/api
   - Environment: All (Production, Preview, Development)
6. Click "Save"
7. Go to "Deployments" tab
8. Click on latest deployment
9. Click three dots (•••) → "Redeploy"
10. Wait for deployment (2-3 minutes)

STEP 3: Verify Deployment
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. Test backend health:
   curl [YOUR RENDER URL]/

   Expected: {"status":"healthy",...}

2. Test backend API docs:
   Open in browser: [YOUR RENDER URL]/docs

   Expected: Interactive API documentation

3. Test frontend:
   Open in browser: [YOUR VERCEL URL]

   Expected: Application loads without errors

4. Test full flow:
   - Click "Sign Up"
   - Create account with email/password
   - Log in
   - Create a task
   - Task should persist after page refresh


================================================
TROUBLESHOOTING
================================================

❌ "CORS policy error"
   → Check CORS_ORIGINS includes your Vercel URL (no trailing slash)
   → Format: https://your-app.vercel.app,http://localhost:3000

❌ "Failed to fetch"
   → Check NEXT_PUBLIC_API_URL in Vercel points to Render URL
   → Must include /api at the end
   → Example: https://your-backend.onrender.com/api

❌ "Database connection failed"
   → Verify DATABASE_URL is correct PostgreSQL string from Neon
   → Must include ?sslmode=require at the end

❌ "503 Service Unavailable"
   → Check all environment variables are set in Render
   → Wait for deployment to complete
   → Check Render logs for specific errors

❌ First load is slow (10-30 seconds)
   → This is normal for Render free tier (cold start)
   → Upgrade to paid tier or implement keep-alive


================================================
QUICK REFERENCE
================================================

Render Dashboard:      https://dashboard.render.com
Vercel Dashboard:      https://vercel.com/dashboard
Neon Console:          https://console.neon.tech

Need more help?
- Quick fix: QUICK-FIX-GUIDE.md
- Complete guide: DEPLOYMENT-CHECKLIST.md
- Troubleshooting: TROUBLESHOOTING-TREE.md
- Run diagnostics: ./diagnose-deployment.sh


================================================
⚠️  SECURITY WARNING
================================================

This file contains your JWT SECRET!

✅ DO:
- Keep this file secure
- Don't share it publicly
- Use it only for deployment setup
- Delete after deployment is complete

❌ DON'T:
- Commit to git (already in .gitignore)
- Share on Slack/Discord/email
- Post in screenshots
- Leave in shared folders

================================================

EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Configuration template created!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📄 File: DEPLOYMENT-CONFIG-TEMPLATE.txt"
echo ""
echo "🔐 JWT Secret generated: $JWT_SECRET"
echo ""
echo "Next steps:"
echo "1. Open DEPLOYMENT-CONFIG-TEMPLATE.txt"
echo "2. Fill in your deployment URLs"
echo "3. Copy environment variables to Render and Vercel"
echo "4. Follow the deployment steps in the file"
echo ""
echo "⚠️  Keep this file secure - it contains your JWT secret!"
echo ""
