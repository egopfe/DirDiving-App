# DIR DIVING — Apnea Watch Surface, Recovery and Session Summary UI

**Command:** `06_WATCH_SURFACE_RECOVERY_SUMMARY_UI.md`  
**Date:** 2026-06-17  
**Branch:** `main`  
**Result:** PASS

## Implemented
- Extended `ApneaWatchPresentation` with `surfaceRecovery` and `sessionSummary` stages, recovery state mapping (in progress / completed / insufficient), overlay presentation, and session metrics.
- Added Surface/Recovery panel: hero surface timer, last apnea depth/duration, required/remaining recovery, dual text + colour state, recovery-complete haptic eligibility.
- Added Session summary panel: dive count, max depth, best/average time, underwater and session duration, warnings/data-quality footer, save/end and return actions.
- Added marker/target/alarm event overlays with dismiss-when-safe behaviour; overlays do not replace the underlying dive/recovery screen.
- Ready panel now lists configured alarm labels.
- Wired `DiveManager.apneaOperationalOverlay` for operational event display.

## Architecture
- Pure presentation mapping remains in `Utils/ApneaWatchPresentation.swift`; SwiftUI reads formatted output only.
- Recovery colour is always paired with localized state text for accessibility.
- No hardcoded user-facing strings in views.

## Tests
- `ApneaWatchPresentationTests.swift`: surface/recovery, summary, zero dives, long session, degraded data, overlays, alarms.
- `ApneaWatchUIViewContractTests.swift`: new panels/overlays, EN/IT localization key coverage.

## Localization
Added EN/IT keys for surface/recovery, summary, recovery states, overlays, and sample alarm label.

## Visual references used
- `APNEA_WATCH_04_SURFACE_RECOVERY`
- `APNEA_WATCH_05_SESSION_SUMMARY`
- `APNEA_WATCH_07_MARKER_REACHED`
- `APNEA_WATCH_08_TARGET_REACHED`

Mockups were used as reference only; safety logic, accessibility, and `DiveUI` tokens take priority.
