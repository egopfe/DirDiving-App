# iOS MAIN algorithm math audit — remediation report

**Date:** 2026-06-03  
**Branch:** `main`  
**Baseline audit:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)  
**Prior remediation:** `6a5054f` (full code audit P2/P3)  
**This pass commit base:** `3b7325b` (uncommitted working tree at report time)

## A. Branch confirmed

`main` — synced with `origin/main` at preflight.

## B. Commit confirmed

Working tree based on `3b7325b` (`docs: update iOS main algorithm audit report`). Remediation changes were applied locally and validated before commit.

## C. Target confirmed

**DIRDiving iOS** (iOS Companion MAIN) only. Shared sync codec strings localized on iOS; no Watch runtime algorithm changes.

## D. Experimental exclusions confirmed

Unchanged — no edits to:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

## E. Files modified

| Area | Files |
|------|-------|
| IOS-AUDIT-003 | `iOSApp/Services/BuhlmannPlanner.swift` |
| IOS-AUDIT-004 | `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift` |
| IOS-AUDIT-005 | `iOSApp/Services/GasPlanningService.swift` |
| IOS-AUDIT-006 | `iOSApp/Models/DiveSession.swift`, `iOSApp/Utils/PressureDisplayMath.swift`, `iOSApp/Views/ManualDiveEditorView.swift`, `iOSApp/Views/DiveDetailView.swift`, `iOSApp/Utils/DiveSessionMerge.swift`, `iOSApp/Utils/DiveProfileMath.swift` |
| IOS-AUDIT-008 | `iOSApp/Services/SubsurfaceExportService.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift`, `iOSApp/Services/WatchSyncService.swift`, `iOSApp/Resources/en.lproj/Localizable.strings`, `iOSApp/Resources/it.lproj/Localizable.strings` |
| IOS-AUDIT-010 | `iOSApp/Utils/AnalysisDashboardMath.swift` |
| IOS-AUDIT-011 | `iOSApp/Services/GasPlanningService.swift` |
| IOS-AUDIT-012 | `iOSApp/Services/ScheduleGasConsumptionService.swift` |
| Tests | `Tests/iOSAlgorithmTests/IOSMainAlgorithmAuditRemediationTests.swift` |
| Docs | This report, [`IOS_PLANNER_LIMITATIONS.md`](IOS_PLANNER_LIMITATIONS.md), [`SUBSURFACE_EXPORT_COMPATIBILITY_QA.md`](SUBSURFACE_EXPORT_COMPATIBILITY_QA.md), updates to [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) |

Prior pass (`6a5054f`) already addressed IOS-AUDIT-001, 002, 007 and partial 008/012.

## F. Issues fixed by ID

| ID | Status | Summary |
|----|--------|---------|
| **IOS-AUDIT-001** | Verified (prior pass) | Environment-aware MOD display/warnings via `modMeters(environment:)` paths; tests in `AuditRemediationTests.swift`. |
| **IOS-AUDIT-002** | Verified (prior pass) | Safe duplicate session dedup via `DiveSessionCollectionIntegrity`; no `Dictionary(uniqueKeysWithValues:)` traps. |
| **IOS-AUDIT-003** | **Fixed** | Preview NDL and `ndlCurve` seed `initialTissueState: .airSaturated(surfacePressureBar: environment.surfacePressureBar)`. |
| **IOS-AUDIT-004** | **Fixed** | `BuhlmannPlanPreflightValidator` extends engine validation with deco/travel gas band checks (switch → next switch/surface), ambiguous duplicate-name detection, deco PPO₂ tolerance aligned with engine. |
| **IOS-AUDIT-005** | **Fixed** | END/EAD convert equivalent ambient pressure through `AmbientPressureModel.depthMeters(...)` instead of fixed `× 10`. |
| **IOS-AUDIT-006** | **Fixed** | Manual pressures store canonical `entryPressureBar` / `exitPressureBar`; display converts to user units; legacy text infers `bar`/`psi` suffix. |
| **IOS-AUDIT-007** | Verified (prior pass) | CSV import: `temperature_c` optional. |
| **IOS-AUDIT-008** | **Fixed** | Remaining service-layer user-facing errors localized (Subsurface export, sync codec, sync activity summary). EN/IT parity 1016/1016 keys. |
| **IOS-AUDIT-009** | **Covered** | Internal regression tests added; external Subsurface import QA documented in [`SUBSURFACE_EXPORT_COMPATIBILITY_QA.md`](SUBSURFACE_EXPORT_COMPATIBILITY_QA.md) — **not executed in this environment**. |
| **IOS-AUDIT-010** | **Documented** | Analysis SAC/temperature remain **arithmetic means across sessions** (intentional); comments + tests. |
| **IOS-AUDIT-011** | **Fixed** | High-PPO₂ segments surface `.PPO2Exceeded` in planner states even when oxygen exposure extrapolation remains finite. |
| **IOS-AUDIT-012** | **Documented** | `unusedPlannedEntries` ledger semantics documented; consumption totals unchanged; tests in prior + new suites. |

## G. Tests added

`Tests/iOSAlgorithmTests/IOSMainAlgorithmAuditRemediationTests.swift`:

- NDL environment tissue seeding (sea vs altitude, curve, engine alignment)
- Ascent/deco preflight (O₂ too deep, duplicate label same composition)
- END ambient model vs legacy `×10` approximation
- Manual pressure bar storage / legacy inference / invalid strings
- Analysis arithmetic mean semantics
- High-PPO₂ `.PPO2Exceeded` dominance
- Subsurface export metadata, monotonic seconds, empty profile rejection

Existing `AuditRemediationTests.swift` covers 001, 002, 004 (partial), 007, 012.

## H. Tests run

```
xcodegen generate                          PASS
xcodebuild DIRDiving iOS                   PASS (iPhone 17 Simulator)
xcodebuild test DIRDiving iOS Algorithm Tests   PASS
  Executed 229 tests, 3 skipped, 0 failures
```

Watch build/tests **not re-run** — no Watch runtime/shared codec model changes beyond iOS-localized error strings in shared sync files (compatible).

## I. Build results

| Step | Result |
|------|--------|
| `xcodegen generate` | PASS |
| `xcodebuild` **DIRDiving iOS** | PASS |
| `xcodebuild test` **DIRDiving iOS Algorithm Tests** | PASS (229 / 3 skipped) |

## J. Localization validation results

- iOS EN keys: **1016**
- iOS IT keys: **1016**
- Parity mismatch: **0**

New keys under `/* iOS MAIN algorithm audit remediation 2026-06-02 */` in both `en.lproj` and `it.lproj`.

## K. Remaining external QA

| Gate | Status |
|------|--------|
| Subsurface desktop import of exported CSV | **Not executed** — manual steps in [`SUBSURFACE_EXPORT_COMPATIBILITY_QA.md`](SUBSURFACE_EXPORT_COMPATIBILITY_QA.md) |
| External Bühlmann/planner fixture comparison | Not executed |
| Paired Watch/iPhone field sync | Not executed |
| Apple Watch Ultra physical QA | Not executed |

## L. Remaining risks

1. **Preflight deco bands** use engine-aligned PPO₂ tolerance; exotic switch schedules may still hit runtime `gasNotOperationalInSegment` as fail-safe.
2. **Legacy pressure text** without unit suffix relies on inference or current unit preference when bar fields absent.
3. **END at altitude** can be numerically close to sea-level END for some mixes because narcotic pressure scales with ambient model — environment still applied consistently.
4. **Subsurface compatibility** validated internally only until external import is run.

## M. Final readiness estimate

| Scope | Estimate |
|-------|----------|
| iOS MAIN algorithmic (code + unit tests) | **Release-hard for internal validation** |
| TestFlight broad gate | **Ready pending standard device QA** |
| App Store | **Blocked on external Subsurface QA + physical matrices** |

## N. Confirmation

- [x] MAIN branch only  
- [x] iOS MAIN primary (shared sync string localization only)  
- [x] Experimental untouched  
- [x] Watch runtime untouched  
- [x] No UI redesign  
- [x] No certified decompression claim  
- [x] Planner remains reference-only  
- [x] TTV unchanged  
- [x] Safety/legal disclaimers preserved  
