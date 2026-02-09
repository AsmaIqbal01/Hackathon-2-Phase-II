#!/bin/bash

# Deployment Setup Script for Phase II Todo Application
# This script helps you configure deployment to Render (backend) and Vercel (frontend)

set -e

echo "=================================================="
echo "Phase II Todo Application - Deployment Setup"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
print_info "Checking required tools..."

if ! command -v openssl &> /dev/null; then
    print_error "openssl is not installed. Please install it first."
    exit 1
fi

print_info "✓ All required tools are installed"
echo ""

# Generate JWT Secret
print_info "Generating secure JWT secret..."
JWT_SECRET=$(openssl rand -hex 32)
echo ""
print_info "Generated JWT Secret:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "$JWT_SECRET"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Gather deployment information
echo "Please provide your deployment information:"
echo ""

# Backend URL
read -p "Enter your Render backend URL (e.g., https://todo-backend.onrender.com): " BACKEND_URL
BACKEND_URL=${BACKEND_URL%/}  # Remove trailing slash if present

# Frontend URL
read -p "Enter your Vercel frontend URL (e.g., https://your-app.vercel.app): " FRONTEND_URL
FRONTEND_URL=${FRONTEND_URL%/}  # Remove trailing slash if present

# Database URL
read -p "Enter your Neon PostgreSQL connection string: " DATABASE_URL

echo ""
print_info "Configuration Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Backend URL:  $BACKEND_URL"
echo "Frontend URL: $FRONTEND_URL"
echo "Database:     ${DATABASE_URL:0:30}..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Generate instructions
cat > DEPLOYMENT-CONFIG.txt << EOF
================================================
DEPLOYMENT CONFIGURATION
================================================

BACKEND (Render) Environment Variables:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

DATABASE_URL=$DATABASE_URL
JWT_SECRET=$JWT_SECRET
CORS_ORIGINS=$FRONTEND_URL,http://localhost:3000
ENVIRONMENT=production
DEBUG=False
LOG_LEVEL=INFO
APP_NAME=Todo Backend API

FRONTEND (Vercel) Environment Variables:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXT_PUBLIC_API_URL=$BACKEND_URL/api

DEPLOYMENT STEPS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. RENDER BACKEND:
   a. Go to https://dashboard.render.com
   b. Select your service: todo-backend-api
   c. Go to "Environment" tab
   d. Add each backend environment variable listed above
   e. Click "Save Changes"
   f. Render will automatically redeploy

2. VERCEL FRONTEND:
   a. Go to https://vercel.com/dashboard
   b. Select your project
   c. Go to "Settings" → "Environment Variables"
   d. Add the frontend environment variable listed above
   e. Click "Save"
   f. Go to "Deployments" tab
   g. Click "Redeploy" on the latest deployment

3. VERIFICATION:
   a. Backend health check: $BACKEND_URL/
   b. Backend API docs: $BACKEND_URL/docs
   c. Frontend: $FRONTEND_URL
   d. Test login/signup flow
   e. Check browser console for errors
   f. Verify API calls in Network tab

TROUBLESHOOTING:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you see CORS errors:
- Verify CORS_ORIGINS includes your Vercel URL
- Check for trailing slashes (should not have them)

If backend fails to start:
- Check Render logs for errors
- Verify DATABASE_URL is correct
- Ensure all required env vars are set

If frontend can't reach backend:
- Verify NEXT_PUBLIC_API_URL is correct
- Check Network tab in browser for API calls
- Ensure backend is running and healthy

================================================
EOF

print_info "Configuration saved to DEPLOYMENT-CONFIG.txt"
echo ""
print_info "Next steps:"
echo "1. Copy the environment variables from DEPLOYMENT-CONFIG.txt"
echo "2. Follow the deployment steps in the file"
echo "3. Verify your deployment is working"
echo ""
print_warning "IMPORTANT: Keep DEPLOYMENT-CONFIG.txt secure! It contains sensitive credentials."
print_warning "Add it to .gitignore and never commit it to version control."
echo ""

# Add to gitignore
if [ -f .gitignore ]; then
    if ! grep -q "DEPLOYMENT-CONFIG.txt" .gitignore; then
        echo "DEPLOYMENT-CONFIG.txt" >> .gitignore
        print_info "Added DEPLOYMENT-CONFIG.txt to .gitignore"
    fi
fi

print_info "✓ Setup complete! Check DEPLOYMENT-CONFIG.txt for your configuration."
