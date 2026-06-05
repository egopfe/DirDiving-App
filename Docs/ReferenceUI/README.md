# Reference UI assets (visual regression QA)

**Status:** PNG reference captures are **not** stored in this repository yet. Use this folder for mandatory baselines before App Store visual gate.

## Mandatory MAIN references (when captured)

| File | Purpose | Source |
|------|---------|--------|
| `Watch_LIVE_reference.png` | Apple Watch Live Dive — depth, TTV, inline ascent banner, compact GPS | `main` — DIRDiving Watch App sim 41/45/49 mm |
| `iOS_Companion_reference.png` | iOS Companion — Planner, Logbook, More tabs | `main` — DIRDiving iOS sim |

## Ascent / safety UX reference

| File | Purpose |
|------|---------|
| `ascent_warning_inline_reference.png` | Inline red ascent banner (non full-screen); depth/gauge/controls remain visible |

Policy: [`Docs/WATCH_MAIN_UX_CONVENTIONS.md`](../WATCH_MAIN_UX_CONVENTIONS.md)

## Experimental references (branch-specific — not MAIN runtime)

Capture from experimental branches only; do not merge experimental UI into MAIN docs as production-ready:

| File | Branch | Purpose |
|------|--------|---------|
| `Snorkeling_Live_reference.png` | `codex/experimental-features` | Snorkeling Live surface |
| `Snorkeling_Waypoint_Map_reference.png` | idem | Waypoint map |
| `Snorkeling_Return_Map_reference.png` | idem | Return map |
| `Apnea_Workflow_reference.png` | `codex/experimental-features` / `codex/ios-experimental-features` | Apnea workflow screens |

Mark all experimental captures **Experimental / not production** in commit messages and CSV `Notes`.

## How to create

1. Run **DIRDiving Watch App** on simulators: 41 mm, 45 mm, 49 mm — Live Dive with representative badges (mission, sync, GPS, stale depth optional).
2. Run **DIRDiving iOS** on iPhone SE and iPhone 17 — Planner, Logbook, More, Watch photo panel.
3. Save screenshots here without altering in-app copy.
4. Naming convention (exact for MAIN):
   - `Watch_LIVE_reference.png`
   - `iOS_Companion_reference.png`
5. Do **not** fabricate or AI-generate reference images.

## Text/clipping QA

Until PNGs exist, use the checklist in `Docs/MAIN_UI_TEXT_QA_CHECKLIST.md` for manual simulator passes.

**Terminology:** UI copy uses **BUSSOLA**, never COMPASSO.

Status: external screenshot QA required before App Store release gate can pass.
