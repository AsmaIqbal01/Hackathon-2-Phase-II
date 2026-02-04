# Tasks: Cyberpunk UI Redesign

**Input**: Design documents from `specs/F02-cyberpunk-ui-redesign/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

**Tests**: No automated tests requested. Validation is manual visual/functional testing.

**Organization**: Tasks are grouped by plan phases, mapping to user stories for traceability. Each phase builds on the previous and can be validated independently at checkpoints.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1–US6)
- Exact file paths included in every task

## Path Conventions

- **Frontend**: `frontend/` at repository root
- All paths relative to `E:\Hackathon 2\Phase-II\frontend\`

---

## Phase 1: Design System Foundation (Setup)

**Purpose**: Establish the cyberpunk design tokens, typography, and global CSS that all subsequent tasks depend on.

**Maps to**: US1 (Cyberpunk Visual Theme Experience — P1)

- [ ] T001 [US1] Update `frontend/app/globals.css` — Add Tailwind v4 `@theme` block with cyberpunk color palette (11 colors: cyber-bg, cyber-surface, cyber-surface-hover, cyber-border, cyber-text, cyber-text-muted, neon-pink, neon-blue, neon-purple, neon-green, neon-red, neon-yellow), glow shadow tokens (glow-pink, glow-blue, glow-purple), font-family tokens (font-heading: Orbitron, font-body: Rajdhani). Add `@keyframes shimmer` (left-to-right gradient sweep) and `@keyframes neon-pulse` (subtle glow pulsing). Update `@layer base` to set `body` to dark background and light text. Add `@media (prefers-reduced-motion: reduce)` block to disable all custom animations and transitions.
  - **File**: `frontend/app/globals.css`
  - **Acceptance**: Tailwind utility classes `bg-cyber-bg`, `text-neon-pink`, `shadow-glow-pink`, `font-heading`, `font-body` resolve correctly. `prefers-reduced-motion` disables animations. No visual regressions on existing pages (they will still use old classes until redesigned).

- [ ] T002 [US1] Update `frontend/app/layout.tsx` — Import Orbitron and Rajdhani via `next/font/google`. Apply font CSS variables to `<html>` element via `className` and `style` attributes. Change `<body>` class from `min-h-screen bg-gray-50` to `min-h-screen bg-cyber-bg text-cyber-text font-body`. Add `<Toaster />` component from `react-hot-toast` inside `<body>` with cyberpunk-themed default options: position top-right, dark background (`#12121a`), neon border, custom success icon (neon-green), custom error icon (neon-red), duration 3000ms.
  - **File**: `frontend/app/layout.tsx`
  - **Depends on**: T001
  - **Acceptance**: All pages render with dark background, Rajdhani body font, and Orbitron available for headings. Toaster is mounted globally (test: `toast('test')` in browser console shows cyberpunk-styled toast).

**Checkpoint**: Design system foundation complete. All pages should have dark background and new fonts. No component changes yet.

---

## Phase 2: Reusable UI Components

**Purpose**: Build the shared UI primitives that page and component redesigns depend on.

**Maps to**: US1 (theme), US2 (animations), US3 (skeleton), US5 (modal)

- [ ] T003 [P] [US2] Create `frontend/components/ui/BlobBackground.tsx` — Client component. Render 3 absolutely-positioned `<div>` elements with large border-radius, gradient backgrounds using neon-pink, neon-blue, and neon-purple colors. Apply `position: fixed`, `z-index: 0`, `pointer-events: none`, `filter: blur(80px)`, `will-change: transform`, `opacity: 0.4`. On mount, initialize GSAP timeline: animate each blob's `x`, `y`, `scale`, and `borderRadius` with `gsap.to()` using `repeat: -1`, `yoyo: true`, duration 8–15s (different per blob) for organic morphing. On unmount, kill GSAP timeline via `tl.kill()` in cleanup function. Check `window.matchMedia('(prefers-reduced-motion: reduce)')` — if true, skip GSAP initialization and render static blobs.
  - **File**: `frontend/components/ui/BlobBackground.tsx` (new)
  - **Depends on**: T001 (uses theme colors)
  - **Acceptance**: Blobs render on screen with smooth morphing animation. No GSAP console errors. Memory cleanup on unmount (verify via React DevTools). Static blobs when prefers-reduced-motion is enabled.

- [ ] T004 [P] [US1] Create `frontend/components/ui/NeonButton.tsx` — Client component. Props: `variant` ('primary' | 'secondary' | 'danger' | 'ghost', default 'primary'), `size` ('sm' | 'md' | 'lg', default 'md'), `loading` (boolean), plus all `ButtonHTMLAttributes`. Variant colors: primary=neon-pink, secondary=neon-blue, danger=neon-red, ghost=transparent. Default state: dark surface background, neon-colored text. Hover: neon glow box-shadow matching variant color, slightly lighter background. Focus: visible neon glow ring (2px outline-offset). Active: `scale(0.97)` transform. Disabled: muted colors (`opacity-50`), no glow, `cursor-not-allowed`. Loading: replace children with a small animated spinner (CSS border spinner in neon color). All transitions 150ms ease-out. Size variants: sm=`px-3 py-1 text-sm`, md=`px-5 py-2 text-base`, lg=`px-7 py-3 text-lg`.
  - **File**: `frontend/components/ui/NeonButton.tsx` (new)
  - **Depends on**: T001 (uses theme colors/shadows)
  - **Acceptance**: Button renders in all 4 variants and 3 sizes. Hover shows glow. Focus shows ring. Disabled shows muted state. Loading shows spinner. All transitions smooth at 150ms.

- [ ] T005 [P] [US1] Create `frontend/components/ui/NeonInput.tsx` — Client component. Props: `label` (optional string), `error` (optional string), plus all `InputHTMLAttributes`. Use `React.forwardRef` for ref forwarding. Default state: `bg-cyber-surface` background, `border-cyber-border` border, `text-cyber-text` text, `placeholder:text-cyber-text-muted`. Focus: `border-neon-blue`, `shadow-glow-blue` box-shadow. Error state (when `error` prop provided): `border-neon-red`, `shadow-glow-pink` glow, error message rendered below input in `text-neon-red text-sm`. Label: rendered above input in `font-heading text-sm uppercase tracking-wider text-cyber-text-muted`. Disabled: `opacity-50`. All transitions 150ms.
  - **File**: `frontend/components/ui/NeonInput.tsx` (new)
  - **Depends on**: T001 (uses theme colors/shadows)
  - **Acceptance**: Input renders with dark styling. Focus shows blue glow. Error prop shows red border + error message. Label displays above. Disabled is visually muted.

- [ ] T006 [P] [US3] Create `frontend/components/ui/SkeletonCard.tsx` — Server component (no `'use client'`). Props: `count` (number, default 3). Render `count` card-shaped placeholders matching TaskItem dimensions (~80px height each). Each skeleton card: `bg-cyber-surface` background, `border border-cyber-border rounded-lg p-4`. Inner placeholder blocks: title bar (60% width, 16px height), description bar (40% width, 12px height), status badge (80px width, 24px height), two action button placeholders (60px each). All placeholder blocks use a shimmer class that applies the `shimmer` keyframe animation from globals.css (background: `linear-gradient(90deg, var(--color-cyber-surface) 25%, var(--color-cyber-surface-hover) 50%, var(--color-cyber-surface) 75%)`, `background-size: 200% 100%`, `animation: shimmer 1.5s infinite`).
  - **File**: `frontend/components/ui/SkeletonCard.tsx` (new)
  - **Depends on**: T001 (uses theme colors and shimmer keyframe)
  - **Acceptance**: Renders correct number of skeleton cards. Shimmer animation is visible and smooth. Cards match approximate TaskItem dimensions. No "Loading..." text visible.

- [ ] T007 [P] [US5] Create `frontend/components/ui/ConfirmModal.tsx` — Client component using Framer Motion. Props: `isOpen` (boolean), `title` (string), `description` (string), `confirmLabel` (string, default "Confirm"), `cancelLabel` (string, default "Cancel"), `onConfirm` (callback), `onCancel` (callback), `variant` ('danger' | 'warning', default 'danger'). Render: overlay with `bg-black/60 backdrop-blur-sm fixed inset-0 z-50`. Modal card centered with `bg-cyber-surface border rounded-lg p-6 max-w-md w-full mx-4`. Title in `font-heading text-xl`. Description in `text-cyber-text-muted`. Cancel button: `NeonButton variant="ghost"`. Confirm button: `NeonButton variant="danger"` (or "secondary" for warning). Animation: wrap in Framer Motion `AnimatePresence`; modal uses `motion.div` with `initial={{ opacity: 0, scale: 0.95 }}`, `animate={{ opacity: 1, scale: 1 }}`, `exit={{ opacity: 0, scale: 0.95 }}`, `transition={{ duration: 0.2 }}`. Accessibility: `role="dialog"`, `aria-modal="true"`, `aria-labelledby="modal-title"`, `aria-describedby="modal-description"`. Focus trap: on open, focus first button; Tab cycles between Cancel and Confirm; Shift+Tab cycles back. Escape key calls `onCancel`. Backdrop click calls `onCancel`. Respect `prefers-reduced-motion`: if true, skip animation (render instantly).
  - **File**: `frontend/components/ui/ConfirmModal.tsx` (new)
  - **Depends on**: T001 (theme), T004 (NeonButton)
  - **Acceptance**: Modal opens/closes with animation. Focus is trapped. Escape closes. Backdrop click closes. ARIA attributes present. Confirm/Cancel callbacks fire correctly. Screen reader announces dialog.

- [ ] T008 [P] [US2] Create `frontend/components/ui/PageTransition.tsx` — Client component using Framer Motion. Props: `children` (ReactNode). Wrap children in `motion.div` with `initial={{ opacity: 0, y: 20 }}`, `animate={{ opacity: 1, y: 0 }}`, `transition={{ duration: 0.3, ease: 'easeOut' }}`. Check `prefers-reduced-motion`: if true, render children directly without `motion.div` wrapper.
  - **File**: `frontend/components/ui/PageTransition.tsx` (new)
  - **Depends on**: T001 (theme, though minimal)
  - **Acceptance**: Wrapped content fades in and slides up on mount. No animation when prefers-reduced-motion is enabled.

**Checkpoint**: All 6 UI primitives built. Each can be imported and tested in isolation. No existing pages modified yet.

---

## Phase 3: Page Redesigns

**Purpose**: Apply cyberpunk theme, blob backgrounds, neon components, toasts, and page transitions to all 4 pages.

**Maps to**: US1 (theme), US2 (animations), US4 (toasts)

- [ ] T009 [US1] Redesign `frontend/app/page.tsx` (Home/Redirect) — Import `PageTransition`. Wrap existing content in `PageTransition`. Change container classes to use dark theme: `bg-cyber-bg` (or inherit from body). Replace "Redirecting..." paragraph with a small neon spinner: a `<div>` with `w-8 h-8 border-2 border-neon-blue border-t-transparent rounded-full animate-spin`. Keep all redirect logic unchanged.
  - **File**: `frontend/app/page.tsx`
  - **Depends on**: T002 (layout with dark body), T008 (PageTransition)
  - **Acceptance**: Page shows dark background with neon spinner during redirect. Page transition animation plays on mount. Redirect to /dashboard or /login still works correctly.

- [ ] T010 [US1] Redesign `frontend/app/login/page.tsx` — Import `BlobBackground`, `NeonInput`, `NeonButton`, `PageTransition`, and `toast` from `react-hot-toast`. Add `<BlobBackground />` as first child (renders behind content via z-index). Wrap main content in `<PageTransition>`. Replace outer container: keep `flex min-h-screen items-center justify-center px-4` but ensure content is `relative z-10` (above blobs). Replace white card (`bg-white shadow-md rounded-lg`) with `bg-cyber-surface/80 backdrop-blur-md border border-cyber-border rounded-lg shadow-lg`. Replace `<h1>` with `font-heading text-2xl font-bold text-neon-blue text-center mb-6 uppercase tracking-wider`. Replace both `<input>` elements with `<NeonInput>` components (preserve `id`, `type`, `value`, `onChange`, `disabled`, `required` props; add `label` prop). Replace `<button type="submit">` with `<NeonButton variant="primary" type="submit" loading={submitting} className="w-full">`. Replace error div (`bg-red-50 border-red-200 text-red-700`) with `bg-neon-red/10 border border-neon-red/30 text-neon-red rounded p-3`. Replace register link styling to `text-neon-blue hover:text-neon-pink`. Add `toast.success('Logged in successfully')` after `setToken(response.access_token)`. Change `setError(...)` calls to also call `toast.error(message)`. Keep all auth logic, state management, and API calls unchanged.
  - **File**: `frontend/app/login/page.tsx`
  - **Depends on**: T001, T002, T003 (BlobBackground), T004 (NeonButton), T005 (NeonInput), T008 (PageTransition)
  - **Acceptance**: Login page has dark cyberpunk theme with blob background. Neon-styled inputs and button. Toast appears on login success. Toast appears on login error. Form validation still works. Redirect to dashboard after login still works. Link to register page works.

- [ ] T011 [US1] Redesign `frontend/app/register/page.tsx` — Apply identical cyberpunk restyling pattern as T010 (login page). Import `BlobBackground`, `NeonInput`, `NeonButton`, `PageTransition`, and `toast`. Add blob background, page transition wrapper, dark card, neon inputs, neon button, cyberpunk error styling, neon link to login. Add `toast.success('Account created successfully')` on successful registration. Add `toast.error(message)` on registration error. Keep all auth logic, state management, and API calls unchanged.
  - **File**: `frontend/app/register/page.tsx`
  - **Depends on**: T001, T002, T003, T004, T005, T008
  - **Acceptance**: Register page visually matches login page cyberpunk styling. Toasts for success/error. All auth functionality preserved. Link to login works.

- [ ] T012 [US1] Redesign `frontend/app/dashboard/page.tsx` — Import `BlobBackground`, `NeonButton`, `ConfirmModal`, `PageTransition`, and `toast`. Add `<BlobBackground />` as first child. Wrap main content in `<PageTransition>`. Replace outer container: change `bg-gray-50` to inherit from body (dark). Replace inner container: change `bg-white shadow rounded-lg p-6` to `bg-cyber-surface/80 backdrop-blur-md border border-cyber-border rounded-lg p-6 relative z-10`. Replace "My Tasks" heading with `font-heading text-2xl font-bold text-neon-blue uppercase tracking-wider`. Replace logout button with `<NeonButton variant="danger" size="sm" onClick={() => setShowLogoutModal(true)}>Logout</NeonButton>`. Add `ConfirmModal` state: `const [showLogoutModal, setShowLogoutModal] = useState(false)`. Add `<ConfirmModal isOpen={showLogoutModal} title="Confirm Logout" description="Are you sure you want to log out?" confirmLabel="Logout" onConfirm={() => { handleLogout(); setShowLogoutModal(false); }} onCancel={() => setShowLogoutModal(false)} />`. Add `toast.success('Logged out')` inside `handleLogout` before `router.push('/login')`. Keep all task fetching, auth checks, and existing component rendering unchanged.
  - **File**: `frontend/app/dashboard/page.tsx`
  - **Depends on**: T001, T002, T003, T004, T007 (ConfirmModal), T008
  - **Acceptance**: Dashboard has dark cyberpunk theme with blob background. Logout shows confirmation modal. Confirming modal logs out with toast. Canceling modal stays on dashboard. Task fetching still works. Auth redirect still works.

**Checkpoint**: All 4 pages redesigned with cyberpunk theme. Blob backgrounds on login, register, and dashboard. Toasts for auth actions. Confirmation modal for logout. All existing functionality preserved. TaskForm/TaskItem/TaskList still use old styling at this point.

---

## Phase 4: Task Component Redesigns

**Purpose**: Restyle the task CRUD components with cyberpunk aesthetics, skeleton loaders, toasts, and confirmation modals.

**Maps to**: US1 (theme), US2 (animations), US3 (skeleton), US4 (toasts), US5 (modal)

- [ ] T013 [US4] Redesign `frontend/components/TaskForm.tsx` — Import `NeonInput`, `NeonButton`, and `toast` from `react-hot-toast`. Replace `<input type="text">` with `<NeonInput placeholder="Enter task title..." value={title} onChange={...} disabled={submitting} />` (remove `label` prop since form context is clear). Replace `<button type="submit">` with `<NeonButton variant="primary" type="submit" loading={submitting}>Add Task</NeonButton>`. Replace error div (`bg-red-50 border-red-200 text-red-700`) with `bg-neon-red/10 border border-neon-red/30 text-neon-red rounded p-2 text-sm`. Add `toast.success('Task created')` after `onTaskCreated()` call (inside try block, after clearing form). Replace `setError(...)` to also call `toast.error(message)`. Keep `onTaskCreated` callback and all form logic unchanged.
  - **File**: `frontend/components/TaskForm.tsx`
  - **Depends on**: T004 (NeonButton), T005 (NeonInput)
  - **Acceptance**: Form uses neon-styled input and button. Success toast on task creation. Error toast on failure. Form still creates tasks via API. Input clears after success.

- [ ] T014 [US1] Redesign `frontend/components/TaskItem.tsx` — Import `NeonButton`, `ConfirmModal`, `motion` from `framer-motion`, and `toast` from `react-hot-toast`. Wrap the entire card in `<motion.div layout initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0, x: -20 }} transition={{ duration: 0.2 }}>`. Replace card styling: change `bg-white border-gray-200` to `bg-cyber-surface border border-cyber-border hover:border-neon-purple/50 hover:shadow-glow-purple`. Replace title `<h3>`: add `truncate` class for ellipsis on long titles (FR-016). Keep description styling but change to `text-cyber-text-muted`. Replace status badge colors: completed=`bg-neon-green/20 text-neon-green`, in-progress=`bg-neon-yellow/20 text-neon-yellow`, todo=`bg-neon-purple/20 text-neon-purple`. Replace priority text to `text-cyber-text-muted`. Replace "Complete"/"Undo" button with `<NeonButton variant="secondary" size="sm" loading={toggling} disabled={toggling || deleting}>`. Replace "Delete" button with `<NeonButton variant="danger" size="sm" loading={deleting} disabled={toggling || deleting}>`. Replace `window.confirm(...)` with `ConfirmModal`: add state `const [showDeleteModal, setShowDeleteModal] = useState(false)`. Change delete button `onClick` to `() => setShowDeleteModal(true)`. Add `<ConfirmModal isOpen={showDeleteModal} title="Delete Task" description="Are you sure you want to delete this task? This action cannot be undone." confirmLabel="Delete" onConfirm={() => { setShowDeleteModal(false); executeDelete(); }} onCancel={() => setShowDeleteModal(false)} />`. Refactor `handleDelete`: remove the `window.confirm` check; rename to `executeDelete` and call it from modal confirm. Add `toast.success('Task completed')` / `toast.success('Task reopened')` after toggle success. Add `toast.success('Task deleted')` after delete success. Add `toast.error(...)` in catch blocks (replacing `console.error`). All transitions 150ms.
  - **File**: `frontend/components/TaskItem.tsx`
  - **Depends on**: T004 (NeonButton), T007 (ConfirmModal)
  - **Acceptance**: Task cards are dark-themed with neon borders. Hover shows purple glow. Long titles truncate with ellipsis. Status badges use neon colors. Delete shows ConfirmModal instead of browser confirm. Toasts for toggle/delete success/error. Framer Motion entry animation plays. All CRUD operations still work via API.

- [ ] T015 [US3] Redesign `frontend/components/TaskList.tsx` — Import `SkeletonCard`, `AnimatePresence` and `motion` from `framer-motion`. Replace loading state: change `<p className="text-gray-500">Loading tasks...</p>` with `<SkeletonCard count={3} />`. Replace error state styling: change `bg-red-50 border-red-200 text-red-700` to `bg-neon-red/10 border border-neon-red/30 text-neon-red`. Replace error heading to `text-neon-red font-heading`. Replace empty state styling: change `bg-gray-50 border-gray-200 text-gray-500` to `bg-cyber-surface border border-cyber-border text-cyber-text-muted` with `font-heading` on the message. Wrap the task list `<div className="space-y-2">` with `<AnimatePresence mode="popLayout">` so TaskItem exit animations play when tasks are removed. Convert TaskList to client component by adding `'use client'` directive (needed for AnimatePresence).
  - **File**: `frontend/components/TaskList.tsx`
  - **Depends on**: T006 (SkeletonCard), T014 (TaskItem must be motion-wrapped)
  - **Acceptance**: Loading state shows 3 skeleton cards with shimmer. Error state is cyberpunk-styled. Empty state is cyberpunk-styled. Tasks animate in and out on add/remove. All task rendering still works.

**Checkpoint**: All task components redesigned. Full cyberpunk experience: theme, animations, skeletons, toasts, modals. All CRUD operations functional. Time for responsiveness and polish.

---

## Phase 5: Responsiveness & Polish

**Purpose**: Ensure responsive layouts across all viewports and accessibility compliance.

**Maps to**: US6 (Responsive Layout), cross-cutting (US1 contrast, US2 reduced-motion)

- [ ] T016 [US6] Add responsive styles to login and register pages — In `frontend/app/login/page.tsx` and `frontend/app/register/page.tsx`: ensure form container is `w-full max-w-md` (already correct for tablet+). Add `px-4 sm:px-6` padding for mobile. Ensure card has `mx-4 sm:mx-auto` for edge spacing on mobile. Verify inputs and button are `w-full`. Verify all touch targets are at least 44px (NeonButton md size satisfies this). No changes needed if current layout is already responsive — validate and confirm.
  - **Files**: `frontend/app/login/page.tsx`, `frontend/app/register/page.tsx`
  - **Depends on**: T010, T011
  - **Acceptance**: Login/Register pages render without horizontal overflow from 320px to 2560px. Forms are full-width on mobile, centered on tablet+. Touch targets meet 44px minimum.

- [ ] T017 [US6] Add responsive styles to dashboard and task components — In `frontend/app/dashboard/page.tsx`: ensure container has `max-w-4xl mx-auto px-4 sm:px-6 lg:px-8` for progressive padding. In `frontend/components/TaskForm.tsx`: change flex layout to `flex flex-col sm:flex-row gap-2` so input stacks above button on mobile. In `frontend/components/TaskItem.tsx`: change the flex layout to `flex flex-col sm:flex-row sm:items-start sm:justify-between gap-3` so title/description stacks above action buttons on mobile. Ensure action buttons wrap correctly: `flex flex-wrap items-center gap-2`.
  - **Files**: `frontend/app/dashboard/page.tsx`, `frontend/components/TaskForm.tsx`, `frontend/components/TaskItem.tsx`
  - **Depends on**: T012, T013, T014
  - **Acceptance**: Dashboard renders without horizontal overflow from 320px to 2560px. TaskForm stacks vertically on mobile, horizontal on tablet+. TaskItem stacks vertically on mobile, horizontal on tablet+. No content clipping or overflow.

- [ ] T018 [P] [US1] Verify WCAG 2.1 AA contrast compliance — Check all color combinations used in the UI against WCAG 2.1 AA requirements (4.5:1 for normal text, 3:1 for large text). Key pairs to verify: `cyber-text (#e0e0ff)` on `cyber-bg (#0a0a0f)`, `cyber-text` on `cyber-surface (#12121a)`, `neon-pink (#ff2d7b)` on `cyber-surface`, `neon-blue (#00d4ff)` on `cyber-surface`, `neon-green (#00ff88)` on `cyber-surface`, `neon-red (#ff3355)` on `cyber-surface`, `cyber-text-muted (#8888aa)` on `cyber-bg`, `cyber-text-muted` on `cyber-surface`. If any pair fails 4.5:1, adjust the color value in `globals.css` `@theme` block (lighten text or darken background as needed). Document final verified color values.
  - **File**: `frontend/app/globals.css` (modify if adjustments needed)
  - **Depends on**: T001
  - **Acceptance**: All text/background combinations pass WCAG 2.1 AA contrast ratio (4.5:1 normal, 3:1 large). Verified with contrast calculation.

- [ ] T019 [P] [US2] Verify prefers-reduced-motion across all components — Test with `prefers-reduced-motion: reduce` enabled (via browser dev tools or OS settings). Verify: BlobBackground renders static blobs (no GSAP animation), PageTransition renders children without animation, ConfirmModal opens/closes instantly, shimmer keyframe stops on skeleton cards (via CSS media query in globals.css), NeonButton hover/focus transitions still work (these are not motion, they are color/shadow changes). Fix any component that still animates under reduced-motion.
  - **Files**: All `frontend/components/ui/*.tsx`, `frontend/app/globals.css`
  - **Depends on**: T003, T006, T007, T008
  - **Acceptance**: No motion animations play when prefers-reduced-motion is enabled. Color transitions (hover, focus) still work. UI is fully functional without animation.

- [ ] T020 [US1] Final visual integration pass — Review all pages end-to-end in the browser. Verify: no white/light backgrounds remain anywhere (SC-001). All headings use Orbitron font. All body text uses Rajdhani font. Blob backgrounds render on login, register, dashboard. All buttons are NeonButton. All inputs are NeonInput. Skeleton loaders show during data fetch. Toasts fire for all user actions. Confirmation modals block destructive actions. Page transitions play on navigation. No console errors. No visual regressions to existing functionality (task CRUD, auth flow). Fix any issues found during review.
  - **Files**: All frontend files
  - **Depends on**: All previous tasks (T001–T019)
  - **Acceptance**: All 15 items in plan.md "Definition of Done" checklist pass. Zero functional regressions to task CRUD and authentication.

**Checkpoint**: Feature complete. All user stories (US1–US6) satisfied. Ready for demonstration.

---

## Dependencies & Execution Order

### Phase Dependencies

```
Phase 1 (T001–T002) ──→ Phase 2 (T003–T008) ──→ Phase 3 (T009–T012) ──→ Phase 4 (T013–T015) ──→ Phase 5 (T016–T020)
```

- **Phase 1** (T001–T002): No external dependencies. T002 depends on T001.
- **Phase 2** (T003–T008): All depend on T001. T007 depends on T004. All marked [P] can run in parallel (except T007 which needs T004).
- **Phase 3** (T009–T012): Depend on Phase 2 components. Can run in parallel within phase (different files).
- **Phase 4** (T013–T015): Depend on Phase 2 components and Phase 3 dashboard. T015 depends on T014.
- **Phase 5** (T016–T020): T016–T017 depend on Phase 3–4. T018–T019 can run in parallel. T020 depends on everything.

### Task Dependency Graph

```
T001 ──→ T002 ──→ T009 (home page)
  │
  ├──→ T003 [P] (BlobBackground) ──→ T010, T011, T012
  ├──→ T004 [P] (NeonButton) ──→ T007 (ConfirmModal) ──→ T012, T014
  ├──→ T005 [P] (NeonInput) ──→ T010, T011, T013
  ├──→ T006 [P] (SkeletonCard) ──→ T015
  └──→ T008 [P] (PageTransition) ──→ T009, T010, T011, T012

T010 (login) ──→ T016 (responsive auth)
T011 (register) ──→ T016 (responsive auth)
T012 (dashboard) ──→ T017 (responsive dashboard)
T013 (TaskForm) ──→ T017 (responsive tasks)
T014 (TaskItem) ──→ T015 (TaskList) ──→ T017 (responsive tasks)

T018 [P] (contrast) ← runs in parallel with T016–T017
T019 [P] (reduced-motion) ← runs in parallel with T016–T017

T016, T017, T018, T019 ──→ T020 (final integration)
```

### Parallel Opportunities

```bash
# After T001 completes, launch all Phase 2 components in parallel:
T003, T004, T005, T006, T008  # All [P], different files

# After T004 completes, T007 can start (needs NeonButton)

# After Phase 2 completes, launch all page redesigns in parallel:
T009, T010, T011, T012  # All different files

# After Phase 3–4, launch polish tasks in parallel:
T016, T017, T018, T019  # Different concerns, different files
```

---

## Implementation Strategy

### Recommended Execution Order (Single Developer)

1. T001 (globals.css) → T002 (layout.tsx) — Foundation
2. T004 (NeonButton) + T005 (NeonInput) + T006 (SkeletonCard) + T008 (PageTransition) — Parallel components
3. T003 (BlobBackground) — Can run with above
4. T007 (ConfirmModal) — Needs T004
5. T010 (Login) → T011 (Register) — Auth pages (similar pattern)
6. T012 (Dashboard) — Dashboard page
7. T009 (Home) — Quick change
8. T013 (TaskForm) → T014 (TaskItem) → T015 (TaskList) — Task components in order
9. T016 + T017 — Responsiveness
10. T018 + T019 — Accessibility/motion checks
11. T020 — Final integration pass

### MVP Milestone (Minimum Viable Cyberpunk)

After completing T001–T002 + T004–T005 + T010, you have:
- Dark cyberpunk-themed login page with neon inputs and button
- Proof of concept for the entire design system

### Notes

- Commit after each task or logical group of parallel tasks
- [P] tasks = different files, safe to run in parallel
- All existing API calls, auth logic, and component interfaces are preserved
- No backend changes required for any task
- Total: **20 tasks** across **5 phases**
