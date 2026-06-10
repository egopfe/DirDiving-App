# Reference UI Screenshot Evidence

**Status: PENDING** — Do not mark PASS without attached files committed to the repository.

**Checklist:** [`Docs/MAIN_UI_TEXT_QA_CHECKLIST.md`](../../MAIN_UI_TEXT_QA_CHECKLIST.md)  
**Asset policy:** [`Docs/ReferenceUI/README.md`](../../ReferenceUI/README.md)

---

## Scope

Canonical simulator screenshots for visual regression and App Store readiness gating. Covers Apple Watch Live Dive and iOS Companion primary tabs in EN and IT locales. Evidence files live in `Docs/ReferenceUI/`; this folder holds session notes and sign-off only.

---

## Required device / simulator matrix

| Target | Simulators | Locales |
|--------|------------|---------|
| DIRDiving Watch App | 41 mm, 45 mm, 49 mm | EN, IT |
| DIRDiving iOS | iPhone SE (compact), iPhone 17 / 6.7" (large) | EN, IT |

Representative UI state: Live Dive with mission + sync + GPS badges; Planner, Logbook, More tabs; inline ascent banner (non full-screen).

---

## Required evidence files

Commit PNGs to `Docs/ReferenceUI/` (not here):

| File | Required sizes / notes |
|------|------------------------|
| `Watch_LIVE_reference.png` | 41 / 45 / 49 mm captures (separate files or suffixed variants) |
| `iOS_Companion_reference.png` | Planner, Logbook, More visible |
| `ascent_warning_inline_reference.png` | Inline red ascent banner; depth/gauge remain visible |
| `*_en.png` / `*_it.png` | Locale-specific variants where copy differs |

**Policy:** Do not fabricate or AI-generate reference images.

---

## Sign-off

| Field | Value |
|-------|-------|
| Tester | |
| Date | |
| Build / commit SHA | |
| Watch simulators exercised | 41 / 45 / 49 mm |
| iOS simulators exercised | SE + large |
| Locales verified | EN / IT |
| Pass/Fail | **PENDING** |

**Reference UI QA is not passed until PNG files are committed under `Docs/ReferenceUI/` and linked above.**
