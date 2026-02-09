@echo off
REM Development startup script for Todo App Phase II (Windows)
REM This script starts both backend and frontend servers

echo.
echo ========================================
echo 🚀 Starting Todo App Phase II
echo ========================================
echo.

REM Check if we're in the Phase-II directory
if not exist "backend" (
  echo ❌ Error: backend directory not found
  echo Must run this script from Phase-II directory
  pause
  exit /b 1
)
if not exist "frontend" (
  echo ❌ Error: frontend directory not found
  echo Must run this script from Phase-II directory
  pause
  exit /b 1
)

REM Start backend server
echo 📦 Starting Backend Server (FastAPI)...
cd backend

REM Check for virtual environment
if not exist "venv" (
  echo ⚠️  Creating virtual environment...
  python -m venv venv
)

REM Activate virtual environment
call venv\Scripts\activate.bat

REM Install dependencies if needed
if not exist ".deps_installed" (
  echo 📥 Installing backend dependencies...
  pip install -r requirements.txt
  echo. > .deps_installed
)

REM Start backend in new window
echo ✅ Starting backend at http://localhost:8000
start "Backend Server" cmd /k "venv\Scripts\activate.bat && uvicorn src.main:app --reload --host 0.0.0.0 --port 8000"

cd ..

REM Wait for backend to initialize
echo ⏳ Waiting for backend to start...
timeout /t 3 /nobreak >nul

REM Start frontend server
echo.
echo 🎨 Starting Frontend Server (Next.js)...
cd frontend

REM Check if node_modules exists
if not exist "node_modules" (
  echo 📥 Installing frontend dependencies...
  call npm install
)

REM Start frontend in new window
echo ✅ Starting frontend at http://localhost:3000
start "Frontend Server" cmd /k "npm run dev"

cd ..

echo.
echo ==========================================
echo ✨ Development servers started!
echo ==========================================
echo 📍 Frontend: http://localhost:3000
echo 📍 Backend:  http://localhost:8000
echo 📍 API Docs: http://localhost:8000/docs
echo ==========================================
echo.
echo Two new windows have opened:
echo   - Backend Server (FastAPI)
echo   - Frontend Server (Next.js)
echo.
echo Close those windows to stop the servers.
echo.
pause
