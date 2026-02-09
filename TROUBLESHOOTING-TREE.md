# Troubleshooting Decision Tree

Use this decision tree to quickly identify and fix deployment issues.

## Start Here: What's the error?

```
Is your deployment working?
│
├─ NO ──> Go to Section A: Deployment Issues
│
└─ YES ──> Go to Section B: Runtime Issues
```

---

## Section A: Deployment Issues

### A1. Backend (Render) not deploying

```
Can you access https://your-backend.onrender.com/ ?
│
├─ NO ──> Check Render deployment status
│         │
│         ├─ Status: "Failed" ──> Check Render logs
│         │                       └─> Common causes:
│         │                           • Missing requirements.txt
│         │                           • Wrong Python version
│         │                           • Syntax errors in code
│         │                           • Missing environment variables
│         │
│         ├─ Status: "Building" ──> Wait for build to complete (2-5 min)
│         │
│         └─ Status: "Live" but can't access ──> Check:
│                                                 • Correct URL format
│                                                 • No typos
│                                                 • Service is not suspended
│
└─ YES ──> Backend is deployed ✓
           Go to Section B: Runtime Issues
```

### A2. Frontend (Vercel) not deploying

```
Can you access https://your-app.vercel.app ?
│
├─ NO ──> Check Vercel deployment status
│         │
│         ├─ Status: "Error" ──> Check Vercel logs
│         │                      └─> Common causes:
│         │                          • Build failed (npm errors)
│         │                          • TypeScript errors
│         │                          • Missing dependencies
│         │                          • Out of memory
│         │
│         ├─ Status: "Building" ──> Wait for build (2-3 min)
│         │
│         └─ Status: "Ready" but can't access ──> Check:
│                                                  • Correct domain
│                                                  • DNS propagation (wait 5 min)
│
└─ YES ──> Frontend is deployed ✓
           Go to Section B: Runtime Issues
```

---

## Section B: Runtime Issues

### B1. Frontend loads but shows errors

```
Open browser DevTools (F12). What do you see in Console?
│
├─ "Failed to fetch" or "Network error"
│   └─> Problem: Frontend can't reach backend
│       │
│       └─> Solution:
│           1. Check NEXT_PUBLIC_API_URL in Vercel
│           2. Should be: https://your-backend.onrender.com/api
│           3. NOT: http://localhost:8000/api
│           4. Redeploy frontend after fixing
│
├─ "CORS policy: No 'Access-Control-Allow-Origin'"
│   └─> Problem: Backend blocking frontend requests
│       │
│       └─> Solution:
│           1. Check CORS_ORIGINS in Render
│           2. Should include: https://your-app.vercel.app
│           3. Format: https://your-app.vercel.app,http://localhost:3000
│           4. No trailing slashes
│           5. Wait for Render to redeploy
│
├─ "Unauthorized" or 401 errors
│   └─> Problem: Authentication issues
│       │
│       └─> Solution:
│           1. Check JWT_SECRET is set in Render
│           2. Should be secure random string (not default)
│           3. Generate: openssl rand -hex 32
│           4. Clear browser cookies and try again
│
└─ No errors in console
    └─> Go to B2: Check Network tab
```

### B2. No console errors but app not working

```
Open DevTools → Network tab. Try to sign up or log in. What happens?
│
├─ No API calls appear
│   └─> Problem: Frontend not making requests
│       │
│       └─> Solution:
│           1. Check if button clicks are working
│           2. Verify JavaScript is enabled
│           3. Check for frontend build errors
│           4. Try hard refresh (Ctrl+Shift+R)
│
├─ API calls show red (failed)
│   └─> Click on failed request. What's the status?
│       │
│       ├─ Status: (failed) or 0
│       │   └─> Problem: Can't reach backend
│       │       └─> Go back to B1: "Failed to fetch"
│       │
│       ├─ Status: 401
│       │   └─> Problem: Authentication
│       │       └─> Go back to B1: "Unauthorized"
│       │
│       ├─ Status: 403
│       │   └─> Problem: User not authorized for resource
│       │       └─> Solution: Check if user ID is correct
│       │
│       ├─ Status: 404
│       │   └─> Problem: Endpoint not found
│       │       └─> Solution:
│       │           • Check API URL is correct
│       │           • Verify endpoint exists in backend
│       │
│       ├─ Status: 500
│       │   └─> Problem: Backend error
│       │       └─> Go to B3: Backend issues
│       │
│       └─ Status: 503
│           └─> Problem: Service unavailable
│               └─> Solution:
│                   • Check Render service is "Live"
│                   • May be cold start (wait 30 sec, try again)
│                   • Check Render logs for errors
│
└─ API calls show green (200/201) but app not working
    └─> Problem: Logic or data issue
        └─> Solution:
            1. Check response data in Network tab
            2. Verify data format matches expectations
            3. Check browser console for logic errors
```

### B3. Backend issues (500 errors)

```
Check Render logs (Dashboard → Logs). What error do you see?
│
├─ "Database connection failed" or "could not connect to server"
│   └─> Problem: Can't connect to Neon database
│       │
│       └─> Solution:
│           1. Check DATABASE_URL is set in Render
│           2. Format: postgresql://user:password@host/db?sslmode=require
│           3. Must include ?sslmode=require at the end
│           4. Verify database in Neon dashboard is active
│           5. Check connection limits not exceeded
│
├─ "ModuleNotFoundError" or "ImportError"
│   └─> Problem: Missing Python package
│       │
│       └─> Solution:
│           1. Check requirements.txt includes all dependencies
│           2. Verify package versions are correct
│           3. Redeploy after updating requirements.txt
│
├─ "JWT decode error" or token validation errors
│   └─> Problem: JWT secret mismatch
│       │
│       └─> Solution:
│           1. Check JWT_SECRET is set in Render
│           2. Should be secure random string
│           3. Generate: openssl rand -hex 32
│           4. Don't use: "change-this-secret-key-in-production"
│
├─ "relation does not exist" or table errors
│   └─> Problem: Database tables not created
│       │
│       └─> Solution:
│           1. Check startup logs in Render
│           2. Should see: "Creating database tables..."
│           3. If not, check database URL is correct
│           4. May need to run migrations manually
│
└─ Other errors
    └─> Solution:
        1. Read full error message in logs
        2. Check if environment variables are set
        3. Verify all required vars from QUICK-FIX-GUIDE.md
        4. Try redeploying after fixing
```

---

## Section C: Performance Issues

### C1. First load is very slow (10-30 seconds)

```
Problem: Render free tier cold starts
│
└─> This is NORMAL behavior for Render free tier
    │
    Solutions:
    ├─ Acceptable: Add loading states in frontend
    ├─ Better: Implement keep-alive service (pings backend every 10 min)
    └─ Best: Upgrade to Render paid tier (no cold starts)
```

### C2. Subsequent requests are slow

```
Check what's slow:
│
├─ API requests slow
│   └─> Solutions:
│       1. Check database query performance
│       2. Add indexes to database tables
│       3. Implement caching
│       4. Optimize backend code
│
└─ Page loads slow
    └─> Solutions:
        1. Optimize images (use Next.js Image)
        2. Code splitting
        3. Enable caching
        4. Check bundle size
```

---

## Quick Command Reference

### Test backend health
```bash
curl https://your-backend.onrender.com/
```

### Test backend API
```bash
curl https://your-backend.onrender.com/docs
```

### Generate JWT secret
```bash
openssl rand -hex 32
```

### Run diagnostics
```bash
./diagnose-deployment.sh
```

### Setup configuration
```bash
./setup-deployment.sh
```

---

## Still stuck?

1. **Run diagnostics:**
   ```bash
   ./diagnose-deployment.sh
   ```

2. **Check logs:**
   - Render: Dashboard → Your Service → Logs
   - Vercel: Dashboard → Deployments → View Logs
   - Browser: F12 → Console and Network tabs

3. **Verify environment variables:**
   - Compare with QUICK-FIX-GUIDE.md
   - Ensure no typos
   - Check formatting (no extra spaces, trailing slashes)

4. **Start fresh:**
   - Delete all environment variables
   - Run ./setup-deployment.sh
   - Set variables from generated config
   - Redeploy both services

5. **Review documentation:**
   - QUICK-FIX-GUIDE.md (3 min)
   - DEPLOYMENT-CHECKLIST.md (complete guide)
   - DEPLOYMENT-SOLUTION-SUMMARY.md (what was fixed)

---

**Last Resort:** If nothing works:
1. Check Render and Vercel status pages (not an outage)
2. Delete and recreate services from scratch
3. Verify you're using supported regions
4. Contact platform support with logs
