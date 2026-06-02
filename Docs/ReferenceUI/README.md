# Reference UI assets (visual regression QA)

**Status:** PNG reference captures are **not** stored in this repository.

## Required files (when available)

| File | Purpose |
|------|---------|
| `Watch_LIVE_reference.png` | Apple Watch Live Dive layout baseline (depth, TTV, badges, banners) |
| `iOS_Companion_reference.png` | iOS Companion primary tabs baseline |

## How to create

1. Run **DIRDiving Watch App** on simulators: 41 mm, 45 mm, 49 mm — Live Dive with representative badges (mission, sync, GPS, stale depth optional).
2. Run **DIRDiving iOS** on iPhone SE and iPhone 17 — Planner, Logbook, More.
3. Save screenshots here without altering in-app copy.
4. Naming convention (exact):
   - `Watch_LIVE_reference.png`
   - `iOS_Companion_reference.png`
5. Do **not** fabricate or AI-generate reference images.

## Text/clipping QA

Until PNGs exist, use the checklist in `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` (created with remediation QA report) for manual simulator passes.

Status: external screenshot QA required before App Store release gate can pass.
