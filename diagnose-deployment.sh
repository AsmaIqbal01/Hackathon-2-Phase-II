#!/bin/bash

# Deployment Diagnostics Script
# Helps identify specific deployment issues

set -e

echo "=================================================="
echo "Deployment Diagnostics"
echo "=================================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_check() {
    echo -e "${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Get URLs from user
read -p "Enter your Render backend URL (e.g., https://todo-backend.onrender.com): " BACKEND_URL
read -p "Enter your Vercel frontend URL (e.g., https://your-app.vercel.app): " FRONTEND_URL

BACKEND_URL=${BACKEND_URL%/}
FRONTEND_URL=${FRONTEND_URL%/}

echo ""
echo "Testing deployments..."
echo ""

# Test 1: Backend Health Check
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 1: Backend Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

BACKEND_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/" || echo "000")
BACKEND_CODE=$(echo "$BACKEND_RESPONSE" | tail -n 1)
BACKEND_BODY=$(echo "$BACKEND_RESPONSE" | sed '$d')

if [ "$BACKEND_CODE" = "200" ]; then
    print_check "Backend is responding (Status: 200)"
    echo "Response: $BACKEND_BODY"
else
    print_fail "Backend health check failed (Status: $BACKEND_CODE)"
    echo "Response: $BACKEND_BODY"
    echo ""
    print_warning "Possible issues:"
    echo "  - Backend service is not running"
    echo "  - Build failed during deployment"
    echo "  - Start command is incorrect"
    echo "  - Check Render logs for errors"
fi
echo ""

# Test 2: Backend API Docs
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 2: Backend API Documentation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

DOCS_RESPONSE=$(curl -s -w "\n%{http_code}" "$BACKEND_URL/docs" || echo "000")
DOCS_CODE=$(echo "$DOCS_RESPONSE" | tail -n 1)

if [ "$DOCS_CODE" = "200" ]; then
    print_check "API docs accessible at $BACKEND_URL/docs"
else
    print_fail "API docs not accessible (Status: $DOCS_CODE)"
fi
echo ""

# Test 3: Database Connection (via signup attempt)
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 3: Database Connection (Signup Endpoint)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

SIGNUP_RESPONSE=$(curl -s -w "\n%{http_code}" \
    -X POST "$BACKEND_URL/api/signup" \
    -H "Content-Type: application/json" \
    -d '{"email":"test@example.com","password":"test123"}' || echo "000")
SIGNUP_CODE=$(echo "$SIGNUP_RESPONSE" | tail -n 1)
SIGNUP_BODY=$(echo "$SIGNUP_RESPONSE" | sed '$d')

if [ "$SIGNUP_CODE" = "200" ] || [ "$SIGNUP_CODE" = "409" ]; then
    print_check "Database connection successful"
    if [ "$SIGNUP_CODE" = "409" ]; then
        echo "Note: User already exists (expected)"
    fi
else
    print_fail "Database connection issue (Status: $SIGNUP_CODE)"
    echo "Response: $SIGNUP_BODY"
    echo ""
    print_warning "Possible issues:"
    echo "  - DATABASE_URL not set or incorrect"
    echo "  - Neon database not accessible"
    echo "  - Database tables not created"
fi
echo ""

# Test 4: CORS Configuration
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 4: CORS Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CORS_HEADERS=$(curl -s -I \
    -H "Origin: $FRONTEND_URL" \
    -H "Access-Control-Request-Method: POST" \
    -H "Access-Control-Request-Headers: Content-Type" \
    "$BACKEND_URL/api/signup" | grep -i "access-control" || echo "")

if [ -n "$CORS_HEADERS" ]; then
    print_check "CORS headers present"
    echo "$CORS_HEADERS"
else
    print_fail "CORS headers missing"
    echo ""
    print_warning "Possible issues:"
    echo "  - CORS_ORIGINS not set in Render"
    echo "  - Frontend URL not included in CORS_ORIGINS"
    echo "  - Format should be: $FRONTEND_URL,http://localhost:3000"
fi
echo ""

# Test 5: Frontend Accessibility
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Test 5: Frontend Accessibility"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

FRONTEND_RESPONSE=$(curl -s -w "\n%{http_code}" "$FRONTEND_URL" || echo "000")
FRONTEND_CODE=$(echo "$FRONTEND_RESPONSE" | tail -n 1)

if [ "$FRONTEND_CODE" = "200" ]; then
    print_check "Frontend is accessible"
else
    print_fail "Frontend not accessible (Status: $FRONTEND_CODE)"
    echo ""
    print_warning "Possible issues:"
    echo "  - Build failed during deployment"
    echo "  - Check Vercel deployment logs"
fi
echo ""

# Summary
echo "=================================================="
echo "DIAGNOSTIC SUMMARY"
echo "=================================================="
echo ""

if [ "$BACKEND_CODE" = "200" ] && [ "$FRONTEND_CODE" = "200" ]; then
    print_check "Both deployments are up and running"
    echo ""
    echo "If you're still experiencing errors:"
    echo "1. Check browser console (F12) for JavaScript errors"
    echo "2. Check Network tab for failed API requests"
    echo "3. Verify NEXT_PUBLIC_API_URL in Vercel settings"
    echo "4. Ensure it's set to: $BACKEND_URL/api"
else
    print_fail "One or more deployments have issues"
    echo ""
    echo "Next steps:"
    echo "1. Check deployment logs:"
    echo "   - Render: https://dashboard.render.com → Logs"
    echo "   - Vercel: https://vercel.com/dashboard → Deployments → View Logs"
    echo "2. Verify environment variables are set correctly"
    echo "3. Try redeploying after fixing issues"
fi
echo ""
