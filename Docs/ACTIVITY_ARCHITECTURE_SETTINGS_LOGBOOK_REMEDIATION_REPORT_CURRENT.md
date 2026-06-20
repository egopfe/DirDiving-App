# Activity Architecture Settings & Logbook Remediation Report (Current)

**Date:** 2026-06-20  
**Branch:** `main` @ `2aee901` (audit commit; remediation uncommitted)

---

## A. Executive Summary

All six software findings from `ACTIVITY_ARCHITECTURE_SETTINGS_LOGBOOK_AUDIT_CURRENT.md` are **closed**. Activity architecture, settings ownership, and logbook routing reach **100% software readiness**. Physical Watch crown-navigation QA remains **PENDING**.

## B. Source Audit Baseline

- Branch: `main` @ `8d65daf` (audit) → `2aee901` (audit docs)
- Findings: P0-LOGBOOK-WATCH-001, P0-TEST-GAP-001, P1-ENV-001, P1-SETTINGS-WATCH-001, P1-SETTINGS-IOS-001, P1-NAMING-001

## C. Current Baseline

- Branch: `main`
- Validation: `./Scripts/validate_activity_architecture_settings_logbook_readiness.sh` **PASS**
- Full iOS tests: **1381** executed, **0** failed, **0** skipped
- Full Watch tests: **902** executed, **0** failed, **0** skipped

## D. Findings Inventory

| ID | Severity | Status | Fix |
|----|----------|--------|-----|
| P0-LOGBOOK-WATCH-001 | P0 | FIXED | Conditional `DiveLogListView` + `WatchActivityPagePolicy` |
| P0-TEST-GAP-001 | P0 | FIXED | Watch + iOS route matrix tests |
| P1-ENV-001 | P1 | FIXED | `applyGlobalEnvironment` / `applyDivingEnvironment` split |
| P1-SETTINGS-WATCH-001 | P1 | FIXED | Activity-scoped GPS status rows |
| P1-SETTINGS-IOS-001 | P1 | FIXED | `IOSDivingSettingsStore` facade |
| P1-NAMING-001 | P1 | FIXED | `ActivitySettingsNamingMap` + doc updates |

## E. Watch Logbook P0 Root Cause

`DiveLogListView().tag(AppPage.diveLog)` was always mounted in `ContentView` TabView.

## F. Watch Logbook Routing Fix

- `Utils/WatchActivityPagePolicy.swift` — page inventory per activity
- `Views/ContentView.swift` — `if activitySelection.selectedActivity == .diving { DiveLogListView() }`
- `Services/AppNavigationStore.swift` — `clampSelectedPage(for:includeModeSelection:)` normalizes stale `.diveLog`
- Activity change handler in `ContentView` resets incompatible pages

## G. Six Forbidden Route Tests

- `Tests/WatchAlgorithmTests/WatchActivityLogbookRoutingTests.swift`
- `Tests/WatchAlgorithmTests/WatchActivityPageRestorationTests.swift`
- `Tests/iOSAlgorithmTests/IOSActivityLogbookRoutingTests.swift` + `IOSActivityLogbookRoutingPolicy`

## H. iOS Environment Injection Fix

`IOSCompanionStoreCoordinator`: `applyGlobalEnvironment` (no `DiveLogStore`) → `applyDivingEnvironment` adds diving stores; Apnea/Snorkeling use global layer only. `DIRDivingiOSApp` uses `applyDivingEnvironment` for Diving root.

## I. Watch GPS Settings Ownership

`SettingsView`: `divingSurfaceGPSStatusRow` (diving only), `snorkelingRouteGPSStatusRow` (snorkeling only), Apnea hidden. EN/IT a11y keys added.

## J. Diving Settings Consolidation

`IOSDivingSettingsStore` facade over `SharedIOSSettingsStore` + `PlannerAscentSpeedSettingsStore`; registry key `dirdiving.settings.diving.v1`.

## K. Naming Alignment

`ActivitySettingsNamingMap.swift`; matrices and `IOS_SETTINGS_OWNERSHIP_CURRENT.md` updated.

## L. Navigation Restoration Guards

`AppNavigationStore.clampSelectedPage` + `WatchActivityPagePolicy.normalizedPage`; tests for Apnea/Snorkeling stale `.diveLog`.

## M. Settings Registry

Extended `ActivitySettingsVisibility` with diving facade, pressure unit, CNS threshold, ascent rate keys.

## N. Logbook Data Isolation

`IOSActivityLogbookDataIsolationTests` — separate files, cross-delete isolation, diving storage key static check.

## O. Multi-Activity Regression

`IntegratedModesSequentialFlowTests` included in validation script — **PASS**.

## P. Accessibility and Localization

`settings.a11y.gps_surface.diving`, `settings.a11y.gps_route.snorkeling` (EN/IT).

## Q. Build/Test Results

| Gate | Result |
|------|--------|
| iOS MAIN build | PASS |
| Watch MAIN build | PASS |
| Activity architecture script | PASS |
| Full iOS tests | PASS (1381) |
| Full Watch tests | PASS (902) |

## R. Audit 15 Impact

**NOT_TOUCHED** — No Bühlmann/FC runtime changes.

## S. Audit 16 Result

**PASS** — `UIUXMainRemediationCurrentTests` in validation script (13 tests).

## T. Readiness Recalculation

All software dimensions **100%**. See audit doc executive summary.

## U. Physical QA Pending

See `ACTIVITY_ARCHITECTURE_EXTERNAL_QA_PENDING_CURRENT.md`.

## V. Changed Files

Production: `ContentView.swift`, `SettingsView.swift`, `AppNavigationStore.swift`, `WatchActivityPagePolicy.swift`, `IOSCompanionStoreCoordinator.swift`, `DIRDivingiOSApp.swift`, `IOSDivingSettingsStore.swift`, `ActivitySettingsNamingMap.swift`, `IOSActivityLogbookRoutingPolicy.swift`, `ActivitySettingsVisibility.swift`, `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`, `project.yml`

Tests: `WatchActivityLogbookRoutingTests.swift`, `IOSActivityLogbookRoutingTests.swift`, `IOSActivityLogbookDataIsolationTests.swift`, updates to `WatchActivitySettingsOwnershipTests`, `IOSActivitySettingsCoherenceTests`, `IOSCompanionStoreLifecycleTests`

Scripts: `validate_activity_architecture_settings_logbook_readiness.sh`

Docs: audit, remediation, traceability, matrices, `IOS_SETTINGS_OWNERSHIP_CURRENT.md`, INDEX update

## W. Final Git Status

Dirty working tree — intentional remediation; **not committed** per task instructions.

## X. Final Verdict

**ACTIVITY_ARCHITECTURE_REMEDIATION: PASS** — software gates closed; physical QA pending.
