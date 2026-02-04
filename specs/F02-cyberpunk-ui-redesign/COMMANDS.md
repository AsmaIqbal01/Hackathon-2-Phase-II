# Cyberpunk UI Redesign — Ready-to-Run Commands

**Feature Branch**: `F02-cyberpunk-ui-redesign`
**Working Directory**: `E:\Hackathon 2\Phase-II\frontend`

---

## Prerequisites Check

```bash
# Navigate to frontend directory
cd "E:\Hackathon 2\Phase-II\frontend"

# Verify dependencies (all should be installed)
npm ls gsap framer-motion react-hot-toast

# Expected output:
# ├── framer-motion@12.31.0
# ├── gsap@3.14.2
# └── react-hot-toast@2.6.0
```

**Status**: ✅ All dependencies already installed. No `npm install` needed.

---

## Development Server

```bash
# Start dev server (run in frontend directory)
npm run dev

# Server runs at: http://localhost:3000
# Hot reload enabled - changes appear instantly
```

---

## Task Execution Order

### Phase 1: Design System Foundation

```bash
# T001: Update globals.css (cyberpunk theme tokens)
# File: frontend/app/globals.css
# Checkpoint: Tailwind utilities like bg-cyber-bg, text-neon-pink resolve

# T002: Update layout.tsx (fonts + Toaster)
# File: frontend/app/layout.tsx
# Checkpoint: All pages have dark background, toast appears on console test
```

**Validation**:
```bash
# After T001-T002, open browser console and run:
# toast('Test notification')
# Should show cyberpunk-styled toast in top-right
```

### Phase 2: Reusable UI Components

```bash
# Create ui/ directory
mkdir -p components/ui

# T003: BlobBackground.tsx (GSAP blobs)
# T004: NeonButton.tsx (themed button)
# T005: NeonInput.tsx (themed input)
# T006: SkeletonCard.tsx (shimmer loader)
# T007: ConfirmModal.tsx (accessible modal)
# T008: PageTransition.tsx (Framer Motion wrapper)

# All files go in: frontend/components/ui/
```

**Validation**:
```bash
# Import any component in a page and render it
# Each should display with cyberpunk styling
```

### Phase 3: Page Redesigns

```bash
# T009: app/page.tsx (home/redirect)
# T010: app/login/page.tsx (full redesign)
# T011: app/register/page.tsx (full redesign)
# T012: app/dashboard/page.tsx (full redesign)
```

**Validation URLs**:
- Home: http://localhost:3000/
- Login: http://localhost:3000/login
- Register: http://localhost:3000/register
- Dashboard: http://localhost:3000/dashboard (requires auth)

### Phase 4: Task Component Redesigns

```bash
# T013: components/TaskForm.tsx
# T014: components/TaskItem.tsx
# T015: components/TaskList.tsx
```

**Validation**:
- Create a task → toast appears
- Toggle task status → toast appears
- Delete task → modal appears → confirm → toast appears

### Phase 5: Responsiveness & Polish

```bash
# T016-T017: Add responsive classes
# T018: Verify contrast (use browser dev tools)
# T019: Test prefers-reduced-motion
# T020: Final integration pass
```

**Responsive Testing**:
```bash
# Chrome DevTools: Ctrl+Shift+M (device toolbar)
# Test at: 320px, 640px, 768px, 1024px, 1280px, 2560px
# No horizontal scrollbar should appear at any width
```

**Reduced Motion Testing**:
```bash
# Chrome DevTools: Ctrl+Shift+P → "Reduce motion" → Enable
# Or: Windows Settings → Ease of Access → Display → Show animations = Off
# Verify: No blob animation, no page transitions, static UI
```

---

## Backend Server (Required for Full Testing)

```bash
# In a separate terminal, start the backend
cd "E:\Hackathon 2\Phase-II\backend"
python -m uvicorn src.main:app --reload --host 127.0.0.1 --port 8000

# API runs at: http://127.0.0.1:8000/api
# Docs at: http://127.0.0.1:8000/docs
```

---

## Git Workflow

```bash
# After each task or phase, commit
git add -A
git commit -m "T001: Add cyberpunk design tokens to globals.css"

# Push to feature branch
git push -u origin F02-cyberpunk-ui-redesign
```

---

## Quick Reference: File Locations

| Task | File Path |
|------|-----------|
| T001 | `frontend/app/globals.css` |
| T002 | `frontend/app/layout.tsx` |
| T003 | `frontend/components/ui/BlobBackground.tsx` |
| T004 | `frontend/components/ui/NeonButton.tsx` |
| T005 | `frontend/components/ui/NeonInput.tsx` |
| T006 | `frontend/components/ui/SkeletonCard.tsx` |
| T007 | `frontend/components/ui/ConfirmModal.tsx` |
| T008 | `frontend/components/ui/PageTransition.tsx` |
| T009 | `frontend/app/page.tsx` |
| T010 | `frontend/app/login/page.tsx` |
| T011 | `frontend/app/register/page.tsx` |
| T012 | `frontend/app/dashboard/page.tsx` |
| T013 | `frontend/components/TaskForm.tsx` |
| T014 | `frontend/components/TaskItem.tsx` |
| T015 | `frontend/components/TaskList.tsx` |

---

## Troubleshooting

**Issue**: Tailwind classes not applying
```bash
# Verify postcss.config.mjs has @tailwindcss/postcss
# Restart dev server after globals.css changes
npm run dev
```

**Issue**: GSAP animation not running
```bash
# Check browser console for errors
# Verify gsap is imported: import gsap from 'gsap'
# Check prefers-reduced-motion is not enabled
```

**Issue**: Toast not appearing
```bash
# Verify <Toaster /> is in layout.tsx inside <body>
# Check import: import { Toaster } from 'react-hot-toast'
```

**Issue**: Fonts not loading
```bash
# Verify next/font/google imports in layout.tsx
# Check font variable classes applied to <html>
```
