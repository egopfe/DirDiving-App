# DIR DIVING — iOS Apnea Profiles, Planner and Dashboard

**Command:** `08_IOS_APNEA_PROFILES_PLANNER_AND_DASHBOARD.md`  
**Date:** 2026-06-17  
**Branch:** `integration/full-computer`  
**Result:** PASS

## Implemented
- Enabled Apnea as a launchable iOS Companion activity with dedicated root navigation.
- Dashboard: last session summary, metric grid, Watch connectivity state (no false ACK), empty state, `NUOVA SESSIONE` action.
- Profiles: six editable presets (recreational, depth, constant weight, free immersion, dynamic, photo) plus custom profiles with duplicate/delete.
- Session planner: pyramid/custom/repeated kinds, dive series, recovery estimate, validation gate before `INVIA AL WATCH`.
- Settings: detection thresholds, recovery minimum, units, haptics/sounds/Mission Mode, restore defaults.
- Sessions and statistics tabs backed by `IOSApneaLogbookStore` and `ApneaLogbookStatistics` (real data or empty states).

## Architecture
- Shared models: `ApneaCompanionProfile`, `ApneaSessionPlan`, `ApneaCompanionSettings`, presets and plan validator.
- iOS stores: `IOSApneaProfileStore`, `IOSApneaPlannerStore`, `IOSApneaLogbookStore`, `IOSApneaSettingsStore`, `IOSApneaWatchTransferService`.
- Pure presentation: `IOSApneaDashboardPresentationMapper`.
- SwiftUI views under `iOSApp/Views/Apnea/` read store output only.

## Tests
- `IOSApneaCompanionTests.swift`: profile CRUD/duplicate, planner validation, settings migration, dashboard mapping, apnea availability.
- Updated `IOSCompanionActivitySelectionTests` for Apnea availability.

## Localization
Added EN/IT keys for dashboard, profiles, planner, settings, statistics, presets and Watch transfer states.

## Visual references used
- `APNEA_IOS_01_DASHBOARD`
- `APNEA_IOS_02_PROFILES`
- `APNEA_IOS_03_SESSION_PLANNER`
- `APNEA_IOS_15_SETTINGS`

Mockups used as hierarchy references; business logic follows command requirements and tested services.
