#!/bin/bash
# Development startup script for Todo App Phase II
# This script starts both backend and frontend servers

echo "🚀 Starting Todo App Phase II Development Servers..."
echo ""

# Check if we're in the Phase-II directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
  echo "❌ Error: Must run this script from Phase-II directory"
  exit 1
fi

# Start backend server in background
echo "📦 Starting Backend Server (FastAPI)..."
cd backend
if [ ! -d "venv" ]; then
  echo "⚠️  Virtual environment not found. Creating one..."
  python -m venv venv
fi

# Activate virtual environment
source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null || . venv/bin/activate

# Install dependencies if needed
if [ ! -f ".deps_installed" ]; then
  echo "📥 Installing backend dependencies..."
  pip install -r requirements.txt
  touch .deps_installed
fi

# Start backend server
echo "✅ Backend starting at http://localhost:8000"
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000 &
BACKEND_PID=$!
cd ..

# Wait a moment for backend to start
sleep 2

# Start frontend server
echo ""
echo "🎨 Starting Frontend Server (Next.js)..."
cd frontend

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo "📥 Installing frontend dependencies..."
  npm install
fi

echo "✅ Frontend starting at http://localhost:3000"
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "=========================================="
echo "✨ Development servers started!"
echo "=========================================="
echo "📍 Frontend: http://localhost:3000"
echo "📍 Backend:  http://localhost:8000"
echo "📍 API Docs: http://localhost:8000/docs"
echo ""
echo "Press Ctrl+C to stop both servers"
echo "=========================================="

# Wait for user interrupt
trap "echo ''; echo '🛑 Stopping servers...'; kill $BACKEND_PID $FRONTEND_PID 2>/dev/null; exit 0" INT
wait
