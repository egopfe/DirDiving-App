# DIR DIVING — Apnea Watch Ready and Active UI

**Command:** `05_WATCH_APNEA_READY_AND_ACTIVE_UI.md`  
**Date:** 2026-06-17  
**Branch:** `integration/full-computer`  
**Result:** PASS

## Implemented
- Rebuilt `ApneaView` into 3 clear states: Ready, Dive in progress, Ascent.
- Ready state now shows target, recovery policy, alarms, sensor status, buddy reminder, and `AVVIA SESSIONE` CTA.
- Active states now show hero depth, duration, max depth, vertical speed (direction text + value), temperature, dive index, and sensor badge.
- Ascent state emphasizes ascent speed and includes marker/target indicator chips.
- Added haptics-off and Mission Mode status badges.
- Added Dynamic Type bounds and VoiceOver labels/hints.

## Architecture
- Added pure mapping utility `Utils/ApneaWatchPresentation.swift`.
- View reads presentation output only; no business logic is embedded in SwiftUI hierarchy.

## Tests
- `ApneaWatchPresentationTests.swift`: state mapping and sensor-gating behavior.
- `ApneaWatchUIViewContractTests.swift`: dynamic type/accessibility and i18n key coverage.

## Localization
Added EN/IT keys for all new Apnea ready/dive/ascent labels and accessibility strings.

## Visual references used
- `APNEA_WATCH_01_READY`
- `APNEA_WATCH_02_DIVE_IN_PROGRESS`
- `APNEA_WATCH_03_ASCENT`

Mockups were used as reference only, while preserving safety logic and project design tokens.
