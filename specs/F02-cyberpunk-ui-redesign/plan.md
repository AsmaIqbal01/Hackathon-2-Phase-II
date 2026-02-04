# Implementation Plan: Cyberpunk UI Redesign

**Branch**: `F02-cyberpunk-ui-redesign` | **Date**: 2026-02-05 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/F02-cyberpunk-ui-redesign/spec.md`

## Summary

Transform the existing light-themed, minimal frontend into an immersive dark cyberpunk experience. The redesign touches every existing page (home, login, register, dashboard) and every component (TaskForm, TaskItem, TaskList) with a dark palette, neon accents, GSAP blob animations, Framer Motion page transitions, skeleton loaders, toast notifications, and confirmation modals — all while maintaining zero functional regressions to the existing JWT-authenticated task CRUD system.

## Technical Context

**Language/Version**: TypeScript (latest) on Next.js 16+ (App Router)
**Primary Dependencies**: Tailwind CSS v4, GSAP 3.14, Framer Motion 12.31, react-hot-toast 2.6 (all already installed)
**Storage**: N/A (frontend-only redesign; backend/database unchanged)
**Testing**: Manual visual testing; no automated E2E unless requested
**Target Platform**: Modern browsers (Chrome 90+, Firefox 90+, Safari 15+, Edge 90+)
**Project Type**: Web application (frontend only)
**Performance Goals**: 60fps blob animations on mid-range devices; <150ms transition times for hover/focus effects
**Constraints**: No backend changes; no new dependencies beyond Google Fonts; WCAG 2.1 AA contrast compliance; `prefers-reduced-motion` support
**Scale/Scope**: 4 pages, 3 components, ~6 new reusable UI components (skeleton, toast, modal, blob background, neon button, neon input)

## Constitution Check

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Spec-Driven Only | PASS | Spec exists at `specs/F02-cyberpunk-ui-redesign/spec.md` |
| II. Reuse Over Reinvention | PASS | Reusing existing components, API client, auth system; extending with visual layer |
| III. Amendment-Based | PASS | No business logic changes; visual-only amendments to existing pages/components |
| VI. Web-First Architecture | PASS | Frontend-only changes; backend boundary respected |
| VIII. Observability & Error Handling | PASS | Toast notifications enhance error visibility to users |
| IX. Agentic Execution Only | PASS | All implementation via Claude Code agents |
| X. Reviewability | PASS | PHRs created for spec and plan phases |

## Project Structure

### Documentation (this feature)

```text
specs/F02-cyberpunk-ui-redesign/
├── spec.md              # Feature specification
├── plan.md              # This file
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # To be generated via /sp.tasks
```

### Source Code (files to create or modify)

```text
frontend/
├── app/
│   ├── layout.tsx              # MODIFY: Add Google Fonts, Toaster provider, dark body class
│   ├── globals.css             # MODIFY: Add cyberpunk CSS custom properties, glow keyframes, skeleton shimmer
│   ├── page.tsx                # MODIFY: Apply dark theme to redirect page
│   ├── login/
│   │   └── page.tsx            # MODIFY: Full cyberpunk restyle with blob background, neon inputs
│   ├── register/
│   │   └── page.tsx            # MODIFY: Full cyberpunk restyle with blob background, neon inputs
│   └── dashboard/
│       └── page.tsx            # MODIFY: Full cyberpunk restyle with blob background, confirmation modal for logout
├── components/
│   ├── TaskForm.tsx            # MODIFY: Neon-styled input/button, toast on success/error
│   ├── TaskItem.tsx            # MODIFY: Cyberpunk card styling, neon glow hover, toast on actions, confirmation modal for delete
│   ├── TaskList.tsx            # MODIFY: Replace loading text with skeleton loaders
│   └── ui/                     # CREATE: New directory for reusable UI primitives
│       ├── BlobBackground.tsx  # CREATE: GSAP animated blob background component
│       ├── SkeletonCard.tsx    # CREATE: Skeleton loader with shimmer animation
│       ├── ConfirmModal.tsx    # CREATE: Accessible confirmation modal
│       ├── NeonButton.tsx      # CREATE: Reusable neon-glow button component
│       ├── NeonInput.tsx       # CREATE: Reusable neon-glow input component
│       └── PageTransition.tsx  # CREATE: Framer Motion page transition wrapper
└── lib/
    ├── api.ts                  # NO CHANGE
    ├── auth.ts                 # NO CHANGE
    └── types.ts                # NO CHANGE
```

**Structure Decision**: Extend the existing `frontend/` structure by adding a `components/ui/` directory for new reusable primitives. No new top-level directories. All existing files retain their current exports and interfaces — modifications are visual-only. The `lib/` directory remains untouched.

## Complexity Tracking

No constitutional violations. All changes are visual/UX modifications to existing frontend components.

---

## Phase 0: Design System Foundation

### 0.1 Cyberpunk Color Palette & Design Tokens

Define the cyberpunk design system as CSS custom properties in `globals.css` using Tailwind CSS v4's `@theme` directive for seamless integration with utility classes.

**Color Palette**:

| Token | Value | Usage |
|-------|-------|-------|
| `--color-cyber-bg` | `#0a0a0f` | Page background (near-black) |
| `--color-cyber-surface` | `#12121a` | Card/container background |
| `--color-cyber-surface-hover` | `#1a1a2e` | Card hover state |
| `--color-cyber-border` | `#2a2a3e` | Default borders |
| `--color-cyber-text` | `#e0e0ff` | Primary text (light) |
| `--color-cyber-text-muted` | `#8888aa` | Secondary text |
| `--color-neon-pink` | `#ff2d7b` | Primary accent (CTA buttons, key highlights) |
| `--color-neon-blue` | `#00d4ff` | Secondary accent (links, info states) |
| `--color-neon-purple` | `#b44dff` | Tertiary accent (badges, gradients) |
| `--color-neon-green` | `#00ff88` | Success states |
| `--color-neon-red` | `#ff3355` | Error/destructive states |
| `--color-neon-yellow` | `#ffcc00` | Warning states |

**Glow Effects**:

| Token | Value | Usage |
|-------|-------|-------|
| `--glow-pink` | `0 0 15px rgba(255,45,123,0.5)` | Pink neon glow |
| `--glow-blue` | `0 0 15px rgba(0,212,255,0.5)` | Blue neon glow |
| `--glow-purple` | `0 0 15px rgba(180,77,255,0.5)` | Purple neon glow |

**Typography**:

| Token | Value | Usage |
|-------|-------|-------|
| `--font-heading` | `'Orbitron', sans-serif` | Headings (futuristic) |
| `--font-body` | `'Rajdhani', sans-serif` | Body text (readable futuristic) |

**Approach**: Use Tailwind v4's `@theme` block inside `globals.css` to register these as theme values. This makes them available as utility classes (e.g., `bg-cyber-bg`, `text-neon-pink`, `shadow-glow-pink`).

### 0.2 Global CSS Setup

In `globals.css`:
1. Import Google Fonts (Orbitron + Rajdhani) via `@import url(...)` at the top
2. Define `@theme` block with all design tokens
3. Define `@keyframes` for:
   - `shimmer`: Left-to-right gradient sweep for skeleton loaders
   - `neon-pulse`: Subtle pulsing glow for active elements
4. Define `@layer base` rules for `body`, `html` (dark background, light text)
5. Add `@media (prefers-reduced-motion: reduce)` block to disable/simplify all animations

### 0.3 Font Loading Strategy

Load Orbitron and Rajdhani via `next/font/google` in `layout.tsx` for optimal performance (Next.js handles preloading, font-display: swap, and subsetting automatically). This is preferred over raw `@import url(...)` for:
- Zero layout shift (font-display: swap is automatic)
- Automatic preload hints
- Self-hosted font files (no third-party requests at runtime)

**Decision**: Use `next/font/google` in `layout.tsx` and apply CSS variables for the font families. Reference these variables in `globals.css` `@theme` block.

---

## Phase 1: Reusable UI Components

### 1.1 BlobBackground Component

**File**: `components/ui/BlobBackground.tsx`
**Type**: Client component (`'use client'`)
**Library**: GSAP

**Behavior**:
- Renders 3–4 absolutely-positioned `<div>` elements styled as large gradient blobs (CSS `border-radius: 50%`, gradient fills using neon colors)
- On mount, initializes GSAP timeline that continuously morphs blob positions, scale, and border-radius
- Uses `gsap.to()` with `repeat: -1`, `yoyo: true` for infinite smooth loops
- Each blob has different animation duration (8–15s) for organic feel
- Blobs are `position: fixed`, `z-index: 0`, `pointer-events: none` to sit behind content
- Applies `filter: blur(80px)` for soft diffused glow effect
- On unmount, kills GSAP timeline to prevent memory leaks
- Respects `prefers-reduced-motion`: if detected, renders static blobs (no GSAP animation)

**Props**: None (self-contained)

**Performance considerations**:
- Use `will-change: transform` on blob elements
- Limit to 3–4 blobs to keep GPU load manageable
- Use `gsap.ticker` for frame-rate limiting if needed

### 1.2 SkeletonCard Component

**File**: `components/ui/SkeletonCard.tsx`
**Type**: Server component (CSS-only animation)

**Behavior**:
- Renders a card-shaped placeholder matching the dimensions of a TaskItem
- Contains inner placeholder blocks for title, description, status badge, and action buttons
- Applies the `shimmer` keyframe animation via CSS class
- Background uses a moving linear gradient (dark → slightly lighter → dark) for shimmer effect
- Fully styled with cyberpunk theme (dark surface color, subtle border)

**Props**:
- `count?: number` — Number of skeleton cards to render (default: 3)

### 1.3 ConfirmModal Component

**File**: `components/ui/ConfirmModal.tsx`
**Type**: Client component (`'use client'`)
**Library**: Framer Motion (for enter/exit animation)

**Behavior**:
- Renders a modal overlay with backdrop blur and dark semi-transparent background
- Modal card centered on screen with cyberpunk styling (dark surface, neon border)
- Title and description text
- Two buttons: "Cancel" (ghost/outline style) and "Confirm" (neon-pink filled)
- **Accessibility**:
  - `role="dialog"`, `aria-modal="true"`
  - `aria-labelledby` pointing to title element
  - `aria-describedby` pointing to description element
  - Focus trap: tab cycles between Cancel and Confirm buttons only
  - Escape key closes modal
  - Focus returns to trigger element on close
- **Animation**: Framer Motion `AnimatePresence` for smooth enter (scale up + fade in) and exit (scale down + fade out)
- Backdrop click closes modal (same as Cancel)
- Respects `prefers-reduced-motion`: if detected, renders without animation

**Props**:
- `isOpen: boolean`
- `title: string`
- `description: string`
- `confirmLabel?: string` (default: "Confirm")
- `cancelLabel?: string` (default: "Cancel")
- `onConfirm: () => void`
- `onCancel: () => void`
- `variant?: 'danger' | 'warning'` (default: 'danger' — controls accent color)

### 1.4 NeonButton Component

**File**: `components/ui/NeonButton.tsx`
**Type**: Client component (`'use client'`)

**Behavior**:
- Styled button with cyberpunk aesthetic
- Default state: dark surface background, neon-colored text
- Hover: neon glow box-shadow, slightly lighter background
- Focus: visible neon glow ring (for keyboard users)
- Active: pressed scale transform
- Disabled: muted colors, no glow, `cursor-not-allowed`
- Loading state: replaces children with a small spinner animation
- Transition timing: 150ms for all state changes

**Props**:
- `variant?: 'primary' | 'secondary' | 'danger' | 'ghost'` — Controls accent color (pink, blue, red, transparent)
- `size?: 'sm' | 'md' | 'lg'`
- `loading?: boolean`
- `disabled?: boolean`
- `children: React.ReactNode`
- Standard `ButtonHTMLAttributes`

### 1.5 NeonInput Component

**File**: `components/ui/NeonInput.tsx`
**Type**: Client component (`'use client'`)

**Behavior**:
- Styled input with cyberpunk aesthetic
- Default state: dark surface background, subtle border, light text
- Focus: neon glow border and box-shadow (blue accent)
- Placeholder text in muted color
- Error state: neon-red border and glow
- Disabled: muted colors
- Label rendered above input in cyberpunk font

**Props**:
- `label?: string`
- `error?: string` — If provided, shows error message below input in neon-red
- Standard `InputHTMLAttributes`

### 1.6 PageTransition Component

**File**: `components/ui/PageTransition.tsx`
**Type**: Client component (`'use client'`)
**Library**: Framer Motion

**Behavior**:
- Wraps page content with Framer Motion `motion.div`
- Entry animation: fade in + slight slide up (y: 20 → 0, opacity: 0 → 1)
- Exit: fade out (opacity: 1 → 0)
- Duration: 300ms
- Respects `prefers-reduced-motion`: if detected, renders children without animation wrapper

**Props**:
- `children: React.ReactNode`

---

## Phase 2: Global Layout & Theme Application

### 2.1 Root Layout Updates (`app/layout.tsx`)

1. Import `next/font/google` for Orbitron and Rajdhani
2. Apply font CSS variables to `<html>` element
3. Set `<body>` class to use dark background (`bg-cyber-bg text-cyber-text`)
4. Add `<Toaster>` component from `react-hot-toast` with cyberpunk-themed default options:
   - Dark background, neon border
   - Position: top-right
   - Custom success/error icons in neon colors
5. Update `<html>` element with `className="dark"` and font variable classes

### 2.2 Global CSS Updates (`app/globals.css`)

1. Add `@import url(...)` for Google Fonts (fallback for any non-Next.js font loading edge cases)
2. Add `@theme` block with all cyberpunk design tokens (colors, shadows, fonts)
3. Add `@keyframes shimmer` for skeleton loaders
4. Add `@keyframes neon-pulse` for subtle glow pulsing
5. Update `@layer base` to set `body` background and text color defaults
6. Add `@media (prefers-reduced-motion: reduce)` to disable animations globally
7. Add utility classes for common glow effects if not expressible via Tailwind `@theme` alone

---

## Phase 3: Page Redesigns

### 3.1 Home/Redirect Page (`app/page.tsx`)

- Wrap content with `PageTransition`
- Apply dark background
- Replace "Redirecting..." text with a subtle neon spinner animation
- Minimal changes (this page is barely visible)

### 3.2 Login Page (`app/login/page.tsx`)

- Add `BlobBackground` component behind the form
- Replace white card with cyberpunk-styled card (dark surface, neon border, glow on hover)
- Replace heading with Orbitron-styled "LOGIN" text
- Replace inputs with `NeonInput` components
- Replace submit button with `NeonButton variant="primary"`
- Replace error alert with cyberpunk-styled inline error (neon-red text/border)
- Replace link to register with neon-blue styled link
- Add toast notification on successful login
- Add toast notification on login error
- Wrap with `PageTransition`

### 3.3 Register Page (`app/register/page.tsx`)

- Mirror login page cyberpunk styling (same pattern as 3.2)
- Add `BlobBackground` component
- Replace all inputs/buttons with neon variants
- Add toast notifications for success and error
- Wrap with `PageTransition`

### 3.4 Dashboard Page (`app/dashboard/page.tsx`)

- Add `BlobBackground` component
- Replace white container with cyberpunk-styled container (dark surface, border glow)
- Replace "My Tasks" heading with Orbitron-styled text
- Replace logout button with `NeonButton variant="danger"`
- Add `ConfirmModal` for logout action (currently uses no confirmation)
- Wrap with `PageTransition`
- Pass toast notifications down to TaskForm and TaskList via existing callback patterns

---

## Phase 4: Component Redesigns

### 4.1 TaskForm Component

- Replace text input with `NeonInput` component
- Replace "Add Task" button with `NeonButton variant="primary"`
- Replace error display with cyberpunk-styled inline error
- Add `toast.success()` on successful task creation
- Add `toast.error()` on failed task creation
- Maintain existing `onTaskCreated` callback (no interface change)

### 4.2 TaskItem Component

- Restyle card with cyberpunk aesthetic (dark surface, neon border, glow on hover)
- Restyle status badge with neon colors (green for completed, yellow for in-progress, purple for todo)
- Replace "Complete"/"Undo" button with `NeonButton variant="secondary"`
- Replace "Delete" button with `NeonButton variant="danger"`
- Replace `window.confirm()` with `ConfirmModal` for delete action
- Add `toast.success()` on successful toggle/delete
- Add `toast.error()` on failed toggle/delete
- Add Framer Motion `motion.div` wrapper for enter/exit animation when tasks are added/removed
- Truncate long titles with `truncate` Tailwind class (FR-016)

### 4.3 TaskList Component

- Replace "Loading tasks..." text with `SkeletonCard count={3}`
- Restyle error state with cyberpunk colors (neon-red border/text on dark surface)
- Restyle empty state with cyberpunk colors and neon accent text
- Use Framer Motion `AnimatePresence` + `motion.div` with `layout` prop for smooth task add/remove animations

---

## Phase 5: Responsiveness & Polish

### 5.1 Responsive Breakpoints

Apply responsive adjustments across all pages:

| Breakpoint | Layout Changes |
|------------|----------------|
| < 640px (mobile) | Single column, full-width cards, stacked form (input above button), larger touch targets (min 44px), padding adjustments |
| 640px–1024px (tablet) | Medium-width centered column, slight padding increase |
| > 1024px (desktop) | Max-width container (max-w-4xl), centered layout, comfortable spacing |

Key responsive targets:
- Login/Register forms: full width on mobile, `max-w-md` on tablet+
- Dashboard container: full width with padding on mobile, `max-w-4xl` on desktop
- TaskForm: stack input + button vertically on mobile, horizontal on tablet+
- TaskItem: stack title + actions vertically on mobile, horizontal on tablet+
- BlobBackground: reduce blob count or size on mobile for performance

### 5.2 Accessibility Audit

- Verify all text meets 4.5:1 contrast ratio against dark backgrounds
- Verify neon colors have sufficient contrast (may need to lighten some neon values)
- Verify all focus states are visible (neon glow ring)
- Verify ConfirmModal focus trap works correctly
- Verify ARIA labels on toasts, modals, and dynamic content
- Verify `prefers-reduced-motion` disables all animations

### 5.3 Performance Optimization

- Ensure GSAP animations use `will-change: transform` and GPU-accelerated properties only (transform, opacity)
- Ensure blob `filter: blur()` is applied via CSS (not animated) to avoid per-frame repaints
- Lazy-load BlobBackground component if it causes hydration performance issues
- Verify Framer Motion animations use `layout` prop efficiently (no unnecessary re-renders)

---

## Implementation Sequence

The phases are designed to build on each other:

1. **Phase 0** (Foundation) — Must come first. All subsequent phases depend on the design tokens and CSS setup.
2. **Phase 1** (UI Components) — Must come before page/component redesigns. These are the building blocks.
3. **Phase 2** (Global Layout) — Apply the theme globally before touching individual pages.
4. **Phase 3** (Page Redesigns) — Restyle each page using the components from Phase 1.
5. **Phase 4** (Component Redesigns) — Restyle the task components. Depends on Phase 1 (NeonButton, NeonInput, SkeletonCard, ConfirmModal) and Phase 3 (dashboard context).
6. **Phase 5** (Polish) — Final pass for responsiveness, accessibility, and performance. Must come last.

```
Phase 0 ──→ Phase 1 ──→ Phase 2 ──→ Phase 3 ──→ Phase 4 ──→ Phase 5
 (tokens)   (components)  (layout)    (pages)    (task UI)   (polish)
```

---

## Interfaces & Contracts

### Component Interfaces (TypeScript)

```typescript
// BlobBackground — no props
interface BlobBackgroundProps {}

// SkeletonCard
interface SkeletonCardProps {
  count?: number; // default: 3
}

// ConfirmModal
interface ConfirmModalProps {
  isOpen: boolean;
  title: string;
  description: string;
  confirmLabel?: string;  // default: "Confirm"
  cancelLabel?: string;   // default: "Cancel"
  onConfirm: () => void;
  onCancel: () => void;
  variant?: 'danger' | 'warning'; // default: 'danger'
}

// NeonButton
interface NeonButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
}

// NeonInput
interface NeonInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

// PageTransition
interface PageTransitionProps {
  children: React.ReactNode;
}
```

### Existing Interfaces (NO CHANGES)

The following interfaces remain unchanged:
- `TaskFormProps` — `{ onTaskCreated: () => void }`
- `TaskItemProps` — `{ task: Task; onUpdate: () => void }`
- `TaskListProps` — `{ tasks: Task[]; loading: boolean; error: string | null; onTaskUpdate: () => void }`
- `ApiClientOptions` — `extends RequestInit { requiresAuth?: boolean }`
- All types in `lib/types.ts` — `Task`, `CreateTaskInput`, `User`, `AuthResponse`, `ApiErrorResponse`

### API Contracts (NO CHANGES)

All backend API endpoints remain unchanged. The frontend redesign does not introduce any new API calls or modify existing request/response shapes.

---

## Risk Analysis & Mitigation

### Risk 1: GSAP Bundle Size Impact

**Impact**: GSAP adds ~30KB gzipped to the client bundle. On low-bandwidth connections, this could delay first paint.
**Mitigation**: GSAP is already installed and tree-shakeable. Import only `gsap` core (no plugins). BlobBackground uses dynamic import to avoid blocking initial page load. If bundle analysis shows concern, we can lazy-load the BlobBackground component.
**Blast radius**: Only affects pages with blob backgrounds (home, login, register, dashboard).

### Risk 2: Contrast Compliance with Neon Colors

**Impact**: Neon colors on dark backgrounds may fail WCAG 2.1 AA contrast requirements. Pure neon (#00d4ff, #ff2d7b) against near-black (#0a0a0f) likely passes, but neon on dark surface (#12121a) may be borderline.
**Mitigation**: Validate all color combinations with a contrast checker during Phase 5. Adjust neon values (lighten slightly) if any fail the 4.5:1 threshold. Prioritize readability over pure aesthetic.
**Kill switch**: If neon colors fail accessibility, fall back to brighter pastel-neon variants that maintain the cyberpunk feel.

### Risk 3: Animation Performance on Low-End Devices

**Impact**: GSAP blob animations + Framer Motion transitions + CSS shimmer effects could cause jank on low-end devices.
**Mitigation**: Respect `prefers-reduced-motion`. Use GPU-accelerated properties only (transform, opacity). Static `filter: blur()` (not animated). Limit blob count. Test on simulated low-end device (Chrome DevTools CPU throttling).
**Kill switch**: BlobBackground can be conditionally disabled based on device capability detection (`navigator.hardwareConcurrency < 4`).

---

## Non-Functional Requirements

| Category | Target | Measurement |
|----------|--------|-------------|
| Performance | 60fps blob animations on mid-range devices | Chrome DevTools Performance panel |
| Performance | <150ms hover/focus transition time | CSS `transition-duration` value |
| Accessibility | WCAG 2.1 AA contrast (4.5:1 normal text, 3:1 large text) | Contrast checker tool |
| Accessibility | Full keyboard navigation for modal | Manual testing (Tab, Escape) |
| Responsiveness | No horizontal overflow 320px–2560px | Manual browser resize testing |
| Compatibility | Chrome 90+, Firefox 90+, Safari 15+, Edge 90+ | Manual cross-browser testing |
| Bundle | No new npm dependencies (only Google Fonts CDN) | `npm ls` verification |

---

## Definition of Done

- [ ] All pages use dark cyberpunk palette — no white/light backgrounds remain
- [ ] Orbitron font applied to all headings; Rajdhani to body text
- [ ] Blob backgrounds animate smoothly on landing and dashboard pages
- [ ] All buttons use NeonButton component with hover/focus glow
- [ ] All inputs use NeonInput component with focus glow
- [ ] Skeleton loaders replace all "Loading..." text indicators
- [ ] Toast notifications fire for all user actions (CRUD + auth)
- [ ] Confirmation modal blocks delete and logout actions
- [ ] Confirmation modal is accessible (ARIA, focus trap, Escape key)
- [ ] Page transitions animate on route changes
- [ ] Layout is responsive across mobile, tablet, desktop with no overflow
- [ ] `prefers-reduced-motion: reduce` disables all animations
- [ ] All text passes WCAG 2.1 AA contrast requirements
- [ ] All existing task CRUD and auth functionality works without regression
- [ ] Long task titles truncate with ellipsis
