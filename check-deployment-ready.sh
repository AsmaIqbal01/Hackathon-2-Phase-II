#!/bin/bash

# Deployment Readiness Check Script
# Run this before deploying to ensure all files are in place

echo "================================================"
echo "🔍 Deployment Readiness Check"
echo "================================================"
echo ""

ERRORS=0
WARNINGS=0

# Check if we're in the right directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo "❌ ERROR: Must run from Phase-II directory"
    echo "   Current directory: $(pwd)"
    echo "   Expected: .../Phase-II/"
    exit 1
fi

echo "📁 Checking Backend Files..."
echo "----------------------------"

# Backend files
if [ -f "backend/Dockerfile" ]; then
    echo "✅ Dockerfile exists"
else
    echo "❌ Dockerfile missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "backend/app.py" ]; then
    echo "✅ app.py exists"
else
    echo "❌ app.py missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "backend/requirements.txt" ]; then
    echo "✅ requirements.txt exists"
else
    echo "❌ requirements.txt missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "backend/.dockerignore" ]; then
    echo "✅ .dockerignore exists"
else
    echo "⚠️  .dockerignore missing (optional but recommended)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "backend/README_HUGGINGFACE.md" ]; then
    echo "✅ README_HUGGINGFACE.md exists"
else
    echo "⚠️  README_HUGGINGFACE.md missing (optional)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "backend/src/main.py" ]; then
    echo "✅ src/main.py exists"
else
    echo "❌ src/main.py missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "📁 Checking Frontend Files..."
echo "----------------------------"

# Frontend files
if [ -f "frontend/package.json" ]; then
    echo "✅ package.json exists"
else
    echo "❌ package.json missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -f "frontend/vercel.json" ]; then
    echo "✅ vercel.json exists"
else
    echo "⚠️  vercel.json missing (optional but recommended)"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "frontend/next.config.ts" ]; then
    echo "✅ next.config.ts exists"
else
    echo "❌ next.config.ts missing"
    ERRORS=$((ERRORS + 1))
fi

if [ -d "frontend/app" ]; then
    echo "✅ app directory exists"
else
    echo "❌ app directory missing"
    ERRORS=$((ERRORS + 1))
fi

echo ""
echo "📁 Checking Documentation..."
echo "----------------------------"

if [ -f "DEPLOYMENT_GUIDE.md" ]; then
    echo "✅ DEPLOYMENT_GUIDE.md exists"
else
    echo "⚠️  DEPLOYMENT_GUIDE.md missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "DEPLOYMENT_QUICK_START.md" ]; then
    echo "✅ DEPLOYMENT_QUICK_START.md exists"
else
    echo "⚠️  DEPLOYMENT_QUICK_START.md missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "DEPLOY_NOW.md" ]; then
    echo "✅ DEPLOY_NOW.md exists"
else
    echo "⚠️  DEPLOY_NOW.md missing"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "🔧 Checking Environment Files..."
echo "----------------------------"

if [ -f "backend/.env.example" ]; then
    echo "✅ backend/.env.example exists"
else
    echo "⚠️  backend/.env.example missing"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "frontend/.env.example" ]; then
    echo "✅ frontend/.env.example exists"
else
    echo "⚠️  frontend/.env.example missing"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "📦 Checking Git Status..."
echo "----------------------------"

if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "✅ Git repository detected"

    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  Uncommitted changes detected"
        echo "   Run 'git status' to see changes"
        WARNINGS=$((WARNINGS + 1))
    else
        echo "✅ No uncommitted changes"
    fi

    # Check if remote is configured
    if git remote -v | grep -q "origin"; then
        echo "✅ Git remote 'origin' configured"
        ORIGIN_URL=$(git remote get-url origin)
        echo "   → $ORIGIN_URL"
    else
        echo "⚠️  No git remote 'origin' configured"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "⚠️  Not a git repository"
    WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "================================================"
echo "📊 Summary"
echo "================================================"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ ALL CHECKS PASSED!"
    echo ""
    echo "🚀 You're ready to deploy!"
    echo ""
    echo "Next steps:"
    echo "1. Open DEPLOY_NOW.md for step-by-step instructions"
    echo "2. Deploy backend to Hugging Face Spaces"
    echo "3. Deploy frontend to Vercel"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo "✅ No errors found"
    echo "⚠️  $WARNINGS warning(s) detected"
    echo ""
    echo "You can proceed with deployment, but review warnings above."
    echo ""
else
    echo "❌ $ERRORS error(s) found"
    echo "⚠️  $WARNINGS warning(s) detected"
    echo ""
    echo "Please fix errors before deploying."
    echo ""
    exit 1
fi

echo "================================================"
echo ""
echo "📝 Deployment Documentation:"
echo "   - DEPLOY_NOW.md         (Start here!)"
echo "   - DEPLOYMENT_GUIDE.md   (Detailed guide)"
echo "   - DEPLOYMENT_QUICK_START.md (Quick reference)"
echo ""
echo "================================================"
