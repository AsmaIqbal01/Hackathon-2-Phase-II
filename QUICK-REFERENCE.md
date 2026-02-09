# Quick Reference Guide

## 🚀 Start Development Servers

### Option 1: Use Startup Scripts (Recommended)

**Windows**:
```bash
start-dev.bat
```

**Linux/Mac**:
```bash
./start-dev.sh
```

### Option 2: Manual Start

**Backend** (from `/backend` directory):
```bash
# Activate virtual environment
source venv/bin/activate  # Linux/Mac
venv\Scripts\activate.bat # Windows

# Start server
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

**Frontend** (from `/frontend` directory):
```bash
npm run dev
```

---

## 📍 Local URLs

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

---

## 🌐 Production URLs

- **Frontend**: https://hackathon-2-phase-ii-psi.vercel.app/
- **Backend**: https://hackathon-2-phase-ii.onrender.com/
- **API Docs**: https://hackathon-2-phase-ii.onrender.com/docs

---

## 🔧 Common Commands

### Backend

```bash
# Install dependencies
pip install -r requirements.txt

# Run tests (if available)
pytest

# Check database
python -c "from src.database import engine; print(engine.url)"
```

### Frontend

```bash
# Install dependencies
npm install

# Build for production
npm run build

# Run production build
npm start

# Type check
npm run type-check

# Lint
npm run lint
```

---

## 🗂️ Project Structure

```
Phase-II/
├── backend/
│   ├── src/
│   │   ├── main.py          # ✅ Entry point (uvicorn src.main:app)
│   │   ├── api/             # REST API routes
│   │   ├── models/          # Database models (SQLModel)
│   │   ├── services/        # Business logic
│   │   └── utils/           # Utilities
│   ├── requirements.txt
│   └── render.yaml          # Render deployment config
├── frontend/
│   ├── app/                 # Next.js App Router
│   ├── components/          # React components
│   ├── lib/                 # API client, utilities
│   ├── package.json
│   └── vercel.json          # Vercel deployment config
└── README.md
```

---

## 🔐 Environment Variables

### Backend (`.env`)

```bash
DATABASE_URL=postgresql://user:password@host/db?sslmode=require
JWT_SECRET=your-secret-key-min-32-chars
ENVIRONMENT=development
DEBUG=True
CORS_ORIGINS=http://localhost:3000
```

### Frontend (`.env.local`)

```bash
NEXT_PUBLIC_API_URL=http://localhost:8000/api
```

---

## 📚 Key Documentation

- **README.md** - Full project documentation
- **QUICK-START.md** - Quick setup guide
- **DEPLOYMENT-GUIDE.md** - Production deployment
- **CLAUDE.md** - Agentic Dev Stack workflow

---

## ⚠️ Important Notes

### Backend Entry Point
- ✅ **Correct**: `uvicorn src.main:app`
- ❌ **Wrong**: `uvicorn app:app` (app.py was removed)

### Vercel Root Directory
- Must be set to: `frontend`
- Not: `.` or empty

### CORS Configuration
- Backend must include frontend URL in CORS_ORIGINS
- Format: `https://your-app.vercel.app,http://localhost:3000`

---

## 🐛 Troubleshooting

**"Could not import module 'app'"**
→ Use `uvicorn src.main:app` not `uvicorn app:app`

**"Failed to connect to server"**
→ Check backend is running on port 8000

**CORS errors in browser**
→ Check backend CORS_ORIGINS includes frontend URL

**Vercel "DEPLOYMENT_NOT_FOUND"**
→ Check Root Directory is set to `frontend` in Vercel settings
