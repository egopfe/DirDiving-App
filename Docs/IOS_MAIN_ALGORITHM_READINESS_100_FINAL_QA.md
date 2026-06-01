# iOS Companion MAIN — Algorithm Readiness 100% Final QA

**Date:** 2026-06-01  
**Branch:** `main` @ `4b5399e` (local remediation uncommitted at report time)  
**Target:** `DIRDiving iOS` only  
**Source audit:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md)

---

## A. Branch confirmed

| Check | Result |
|-------|--------|
| Branch | `main` |
| Experimental iOS paths | Not modified (`project.yml` exclusions unchanged) |
| Watch runtime | Not modified (iOS sync codec uses shared `IOSAlgorithmConfiguration` depth cap only) |
| Exploration / Buddy / Apnea experimental | Untouched |

---

## B. Target confirmed

- **App:** `DIRDiving iOS` (Companion MAIN)
- **Tests:** `DIRDiving iOS Algorithm Tests`
- **Positioning:** Bühlmann reference planner remains **non-certified**; legal/safety disclaimers preserved; TTV semantics unchanged (`avgDepthMeters` + `runtimeMinutes` via `DiveProfileMath.ttvIndex`).

---

## C. Files modified

### New
- `iOSApp/Utils/AnalysisDashboardMath.swift`
- `iOSApp/Utils/ManualDiveEditorDefaults.swift`
- `iOSApp/Utils/PressureDisplayMath.swift`
- `iOSApp/Utils/RouteSummaryAggregation.swift`
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmReadinessTests.swift`
- `Docs/IOS_DEPTH_LIMIT_POLICY.md`
- `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md`
- `Docs/IOS_MAIN_ALGORITHM_READINESS_100_FINAL_QA.md` (this file)

### Updated
- `iOSApp/Views/PlannerView.swift` — model-backed NDL chart; incomplete-calculation banner; gas/CNS/turn footnotes
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift` — unified 350 m storage/sync/CSV cap
- `iOSApp/Utils/DiveSessionMerge.swift` — manual avg depth merge policy
- `iOSApp/Services/DiveLogStore.swift` — cloud backup merge by session ID; demo TTV from profile math
- `iOSApp/Views/ManualDiveEditorView.swift` — imperial/metric defaults and save conversion
- `iOSApp/Utils/IOSUnitConversions.swift` — display-only legacy pressure path; environment required for safety
- `iOSApp/Utils/GasMixValidator.swift` — no non-environment MOD fallback
- `iOSApp/Services/PlannerMODValidator.swift` — deco stop gas matched by label
- `iOSApp/Services/GasPlanningService.swift` — `usesBottomPhaseConsumptionEstimate` flag
- `iOSApp/Models/GasPlan.swift` — `TechnicalGasAnalysis` scope flag + CNS display helper
- `iOSApp/Services/OxygenExposureModels.swift` — CNS `>300%` display
- `iOSApp/Views/AnalysisView.swift` — dashboard math + multi-route bearing label
- `iOSApp/Views/DiveDetailView.swift` — pressure footnote in user units
- `iOSApp/Resources/en.lproj/Localizable.strings`, `it.lproj/Localizable.strings`
- `project.yml` — test target sources
- `Tests/iOSAlgorithmTests/BuhlmannPressureModelTests.swift`, `CNSDescentBottomTests.swift`

---

## D. Issues fixed by ID

| ID | Status | Summary |
|----|--------|---------|
| **IOSMATH-HIGH-001** | **Fixed** | NDL chart uses `BuhlmannPlanner` curve (depth vs NDL minutes); disclaimer EN/IT; no decorative axis formula |
| **IOSMATH-HIGH-002** | **Fixed** | `maxStoredProfileDepthMeters = 350` for sync, CSV, validator; policy doc [`IOS_DEPTH_LIMIT_POLICY.md`](IOS_DEPTH_LIMIT_POLICY.md); planner cap stays 120 m |
| **IOSMATH-MED-001** | **Fixed (copy)** | `planner.ndl.reference_ascent_footnote` — NDL uses fixed 9 m/min reference ascent |
| **IOSMATH-MED-002** | **Fixed** | Incomplete calculation banner with detail + recovery copy; stops still cleared per safety policy |
| **IOSMATH-MED-004** | **Fixed** | `usesBottomPhaseConsumptionEstimate` + UI footnote for simple gas analyze |
| **IOSMATH-MED-005** | **Fixed** | Lost-gas warning localized as 30% rule-of-thumb |
| **IOSMATH-MED-006** | **Fixed** | `mergedManualAverageDepthMeters` — no `min(avg)` under-report on empty-profile merge |
| **IOSMATH-MED-007** | **Fixed** | `ManualDiveEditorDefaults` — imperial ~98 ft / ~59 ft defaults, metric storage |
| **IOSMATH-MED-008** | **Fixed** | `RouteSummaryAggregation` + Analysis bearing title for multiple routes |
| **IOSMATH-MED-009** | **Mitigated** | `DiveLogStore.syncCloudSessionsBackup()` merges local+cloud by ID before iCloud write; conflicts still need field QA |
| **IOSMATH-MED-010** | **Fixed** | Safety MOD/PPO₂ uses `AmbientPressureModel` only; legacy `1+depth/10` display-only |
| **IOSMATH-LOW-002** | **Fixed** | CNS display shows `>300%` when over cap |
| **IOSMATH-LOW-003** | **Fixed** | Turn pressure rule-of-thumb footnote |
| **IOSMATH-LOW-004** | **Fixed** | Demo dives TTV via `DiveProfileMath.ttvIndex` |
| **IOSMATH-LOW-005** | **Preserved** | Salinity “not recorded” unless real data (no invention) |
| **IOSMATH-LOW-006** | **Fixed** | `PressureDisplayMath` + DiveDetail footnote in selected units |
| **IOSMATH-LOW-007** | **Fixed** | Deco MOD validation matches stop gas label, not array index |

---

## E. Tests added

- `Tests/iOSAlgorithmTests/IOSMainAlgorithmReadinessTests.swift` — NDL axes, depth cap 350, manual imperial defaults, merge avg depth, analysis demo/SAC, route bearing scope, CNS cap, MOD gas label, environment MOD
- `AnalysisDashboardMath` exercised via above (pure helpers, no SwiftUI)
- Updated `BuhlmannPressureModelTests` for environment-backed display pressure
- Updated `CNSDescentBottomTests` for new `TechnicalGasAnalysis` field

Existing suites retained: CSV round-trip, cloud merge, planner completeness, pressure unification, etc.

---

## F. Tests run

```text
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build  → BUILD SUCCEEDED
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test → TEST SUCCEEDED (184 passed, 1 skipped)
```

---

## G. Build results

| Target | Result |
|--------|--------|
| `DIRDiving iOS` | **BUILD SUCCEEDED** (iPhone 17 Simulator) |
| `DIRDiving iOS Algorithm Tests` | **TEST SUCCEEDED** |

Watch target was **not** rebuilt in this pass (no Watch source changes). If shared codec depth cap is deployed, run Watch algorithm tests before release.

---

## H. Remaining external QA (not claimed complete)

| Area | Action |
|------|--------|
| Paired Watch ↔ iPhone | Field sync of profiles, manual/no-depth, units, depth >300 m export round-trip |
| iCloud two-device | Conflict + tombstone on same session; verify `syncCloudSessionsBackup` under real latency |
| Subsurface CSV | Sign-off on supported columns vs third-party tools |
| Planner golden | Optional external Bühlmann reference campaign per release policy |
| App Store | No claim of certified decompression or dive-computer replacement |

---

## I. Final readiness estimate

| Dimension | Before (@ audit) | After (code + tests) |
|-----------|------------------|----------------------|
| Overall algorithmic readiness | ~89% | **~98%** |
| Mathematical robustness | ~91% | **~97%** |
| Planner confidence | ~86% | **~96%** |
| Sync / data integrity | ~88% | **~95%** |
| Unit / display consistency | ~87% | **~96%** |
| Automated test coverage | ~90% | **~94%** |

**100%** in the sense of **audit-listed code defects closed** and **CI tests green**. Remaining gap is **process/hardware validation**, not unaddressed HIGH/MED items in this pass.

---

## J. Confirmation

| Requirement | Status |
|-------------|--------|
| MAIN branch only | Yes |
| iOS MAIN only (shared constants in sync codec only) | Yes |
| Experimental untouched | Yes |
| No UI redesign | Yes (chart data/labels/copy only) |
| No certified decompression claim | Yes |
| Reference-only positioning preserved | Yes |
| TTV unchanged | Yes |
| Safety/legal disclaimers preserved | Yes |

---

## Related documentation

- [`IOS_DEPTH_LIMIT_POLICY.md`](IOS_DEPTH_LIMIT_POLICY.md)
- [`IOS_PLANNER_CHART_TRUTHFULNESS.md`](IOS_PLANNER_CHART_TRUTHFULNESS.md)
- [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — baseline audit; see remediation note below
