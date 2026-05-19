# Phase 0 — Pre-flight (MAIN only)

**Date:** 2026-05-19  
**Branch:** `main` (verified)  
**Scope:** Apple Watch MAIN + iOS Companion MAIN  

## Confirmed

1. Branch is **main** (`git rev-parse --abbrev-ref HEAD`).
2. **Experimental** files remain excluded in `project.yml`; no imports of `ExplorationCenterView`, `BuddyExperimentalView`, or related stores on MAIN navigation.
3. **Business logic** (deco, gas, TTV numbers, sync rules, sampling): **no edits** in this pass.
4. **Allowed:** UI layout, typography, contrast, copy, disclaimers, accessibility, empty states, Docs/README, build documentation.

## Plan (execution order)

| Step | Action |
|------|--------|
| P1 | Add `Docs/BUILD_VALIDATION.md` with real schemes from `project.yml` (`DIRDiving Watch App`, `DIRDiving iOS`). |
| P2 | iOS `ContentView`: **5 tabs** — Logbook, Analisi, Planner, Attrezzatura, Altro (Italian); remove separate Explore tab (route/GPS summary already in `AnalysisView`). |
| P3 | `LogbookView`: remove static “MAGGIO 2024”; group by month from data; fix date pill month abbreviation. |
| P4 | `PlannerView`: display-only labels **Semplice / Avanzato / Tecnico / Overhead** mapped to existing `PlannerMode` cases (**rawValue / Codable unchanged**). |
| P5 | Watch `AscentGaugeView`: VoiceOver labels (describe scale and bar, no medical advice). |
| P6 | Docs: `GLOSSARY.md`, `RELEASE_CHECKLIST.md`, `UI_UX_VISUAL_GUIDELINES.md`, `MAIN_UX_COMPLETION_REPORT.md`. |
| P7 | `README.md`: safety block + links; state that only UI/copy/a11y/docs changed. |

## Build validation on this host

- **Windows:** `xcodegen` / `xcodebuild` not in PATH — documented commands must be run on **macOS**; report will state “not executed here”.

## Visual references

- Watch: `Docs/ReferenceUI/Watch_LIVE_reference.png` (aligned to live dive reference).  
- iOS: `Docs/ReferenceUI/iOS_Companion_reference.png`.
