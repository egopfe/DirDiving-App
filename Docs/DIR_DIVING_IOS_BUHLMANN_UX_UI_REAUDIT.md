# DIR Diving iOS Bühlmann UX/UI Re-Audit

Date: 2026-05-30  
Branch: `main` @ `3237262`  
Prior audit: [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](../DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) (2026-05-28, *Partially ready*)  
Fix commit: `3237262` — `fix(ios): resolve Bühlmann planner UX/UI readiness audit (P1–P3)`  
Verification: [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](../DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md)

## Executive Verdict

**READY**

All P1, P2, and P3 UX/UI readiness issues from the 2026-05-28 audit are resolved in the iOS Companion MAIN planner presentation layer. Algorithm math unchanged; safety positioning preserved.

## Scope

- iOS Companion MAIN only (`iOSApp/`)
- No Watch or experimental runtime changes in fix commit
- Presentation + copy + tests + docs only

## Issue Resolution Matrix

### P1 — Safety-critical UX

| ID | Original finding | Implemented solution | Files | Verification | Result |
|---|---|---|---|---|---|
| P1-1 | Repetitive planning logic existed but no UI controls/status | `repetitivePlanningCard`: toggle, SI minutes, snapshot status/timestamp/source, active vs rejected states, fail-closed warnings | `PlannerView.swift`, `PlannerStore.swift`, `PlannerService.swift`, `PlannerResultState.swift`, `DivePlan.swift`, localization | `BuhlmannUxReadinessTests` + UI review | **SOLVED** |
| P1-2 | Altitude/salinity copy contradicted active pressure model | Environment banner under profile; invalid environment blocking copy + corrective hints; validator aligned | `PlannerView.swift`, `PlannerInputValidator.swift`, `PlannerResultState.swift`, localization | `testEnvironmentInvalidMessageMatchesValidator`, `testEnvironmentActiveSummaryWhenAltitudeSet` | **SOLVED** |
| P1-3 | Schedule gas allocation not shown per cylinder | `gasLedgerCard` in results: per-gas/cylinder consumed L, remaining L/bar, reserve/minimum/lost-gas flags; visible allocation failure | `PlannerView.swift`, `PlannerService.swift`, `DivePlan.swift`, `PlannerResultState.swift`, localization | `testScheduleGasLedgerIsExposedPerCylinder`, `testGasLedgerFailureHasCorrectiveCopy` | **SOLVED** |

### P2 — Result clarity and accessibility

| ID | Original finding | Implemented solution | Files | Verification | Result |
|---|---|---|---|---|---|
| P2-4 | No-deco vs deco-required implicit only | `resultHeaderBadge` with `PlannerResultHeaderKind` + reference-only hint | `PlannerView.swift`, `PlannerResultState.swift`, `PlannerService.swift`, localization | `testNoDecoVersusDecoRequiredHeaders` | **SOLVED** |
| P2-5 | Typed states not mapped to distinct UX copy | `PlannerUserFacingCopy` for all `PlannerResultState` + snapshot/ledger failures | `PlannerResultState.swift`, `PlannerService.swift`, localization | `testAllPlannerResultStatesHaveUserFacingCopy`, `testSafetyCriticalStatesAreNotGeneric` | **SOLVED** |
| P2-6 | CNS/OTU without reference-only context | Disclaimer + daily CNS/OTU 24h summary + air-break note; comprehensive NOAA model @ `dae29b8` | `PlannerView.swift`, `OxygenExposureModels.swift`, localization | `OxygenExposureDeepModelTests`, `testOxygenExposureStateIncludesReferencePositioning` | **SOLVED** |
| P2-7 | Accessibility gaps on dense planner cards | VoiceOver labels/hints on environment, repetitive, warnings, ledger, header; non-truncating warning text | `PlannerView.swift` | Static a11y audit | **SOLVED** (physical VoiceOver walkthrough still recommended) |

### P3 — UI consistency and feedback states

| ID | Original finding | Implemented solution | Files | Verification | Result |
|---|---|---|---|---|---|
| P3-8 | New UX must reuse premium visual language | All new sections use `DIRCard`, `DIRMetricTile`, `DIRWarningBox` | `PlannerView.swift` | Code review | **SOLVED** |
| P3-9 | Missing feedback states (snapshot, ledger, environment, no-solution) | Typed presentation for all missing states; result warnings section | `PlannerResultState.swift`, `PlannerService.swift`, `PlannerView.swift` | State mapping tests + UI branches | **SOLVED** |

### Prior audit — supplementary gaps

| Area | Original finding | Result | Notes |
|---|---|---|---|
| Controlling-compartment visibility | Limited UI language for ceiling-specific warnings | **PARTIAL** | Engine exposes stops/segments; no separate compartment badge (not in fix scope) |
| Calculation loading/progress | No async progress indicator | **PARTIAL** | Calculation remains synchronous; acceptable for current performance |
| Dynamic Type on dense steppers | Crowding at large sizes | **PARTIAL** | `fixedSize` + scroll preserved; physical Dynamic Type QA still recommended |
| Fixture mismatch UI state | Not explicitly in original P1 list | **SOLVED** | Mapped via `modelIncomplete` / `noValidDecompressionSolution` where applicable |

## Readiness Matrix (Re-Audit)

| Area | Prior (2026-05-28) | Now (2026-05-30) |
|---|---|---|
| Planner entry points | READY | READY |
| Planner input UX | MINOR ISSUES | READY |
| Gas configuration UX | MAJOR ISSUES | READY |
| Bühlmann result UX | MINOR ISSUES | READY |
| Schedule gas consumption UX | MAJOR ISSUES | READY |
| Altitude/salinity UX | MAJOR ISSUES | READY |
| Repetitive dive UX | NOT READY | READY |
| CNS/OTU UX | MINOR ISSUES | READY |
| Error/warning UX | MAJOR ISSUES | READY |
| Cross-screen consistency | MAJOR ISSUES | READY |
| Accessibility/readability | MINOR ISSUES | ALMOST READY |
| Safety/legal positioning | READY | READY |
| UI regression vs premium style | MINOR ISSUES | READY |
| **Overall** | **PARTIALLY READY** | **READY** |

## Build/Test Evidence

macOS @ `3237262`:

- `xcodegen generate` — success
- `DIRDiving iOS` build — **BUILD SUCCEEDED**
- `DIRDiving iOS Algorithm Tests` — **TEST SUCCEEDED** (88 tests)

## Remaining Limitations

- Physical-device VoiceOver and large Dynamic Type walkthrough not automated in CI
- Repetitive snapshot seeds from prior calculated reference plan, not external dive-computer tissue state
- No async calculation progress UI (not required for sync compute)
- Trimix / external validation campaign limitations unchanged at algorithm level

## Safety Positioning (Unchanged)

DIR DIVING iOS remains a **non-certified informational companion**. The Bühlmann planner is a **planning reference only** — not certified decompression advice and not real-time dive-computer behavior.

---

## Addendum — Comprehensive Readiness UX (2026-05-29)

| Area | Update |
|---|---|
| Environment preview | NDL curve now uses same altitude/salinity as plan |
| Repetitive copy | Explicit “not from dive log” string; snapshot on Calculate only |
| Surface interval | `.surfaceIntervalRejected` surfaced in UI |
| Bailout | Schedule hint in plan result when bailout configured |
| Calculate UX | Progress indicator during synchronous calculation |
| GF charts | Cached comparisons — no output change |

Verdict unchanged for presentation layer: **READY**. Physical-device a11y remains manual QA per `DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md`.
