# DIR Diving iOS — Planner Dedicated Deco Stops Section

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `05cc3d1`  
**Status:** Implemented

## Affected modes

| Mode | Section visibility |
|------|-------------------|
| Base | Hidden (no fake stops) |
| Deco | Shown when `decoStops` non-empty; optional no-stops note when empty |
| Technical | Shown when `decoStops` non-empty |
| CCR | Shown when `CCRPlanResult.decoStops` non-empty |

## Stop data source

- **OC Deco / Technical:** `DivePlanResult.decoStops` via `DecoStopsPresentationBuilder`
- **CCR:** `CCRPlanResult.decoStops` (engine-mapped stops, not bailout heuristic)

## Files modified

- `iOSApp/Services/DecoStopsPresentationBuilder.swift` (new)
- `iOSApp/Views/DecoStopsSectionView.swift` (new)
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_DIVE_RUNTIME_PRESENTATION.md`

## Confirmations

- Bühlmann math unchanged
- CCR math unchanged
- Ratio Deco unchanged
- Runtime table unchanged
- Deco Stops section is filtered presentation only
- Stop depths, times, gas labels, PPO₂ unchanged
- No fake stops for Base
- Bailout heuristic not treated as deco stop
- Planner remains reference-only

## Tests added

- `testDecoStopsSectionShowsOnlyDecoStops`
- `testDecoStopsSectionPreservesDepthTimeGasPPO2`
- `testDecoStopsSectionHiddenForNoDecoBase`
- `testDecoStopsSectionVisibleForDecoPlanWithStops`
- `testDecoStopsSectionVisibleForTechnicalPlanWithStops`
- `testRuntimeAndDecoStopsSectionAreIndependent`
- `testDecoStopsTitleLocalization`
- `testRawDecoStopEnumNameIsNotPresentedInDecoStopsSection`
- `testCCRDecoStopsSectionUsesPlannerStopsNotBailoutHeuristic`

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `PlannerAscentTableTests` | **TEST SUCCEEDED** |
| `PlannerModePolicyTests` | **TEST SUCCEEDED** |
| `CCRPlannerTests` | **TEST SUCCEEDED** |

## Limitations

- PDF exports unchanged (UI-only addition).
- CCR section title uses `ccr.deco_stops.title` while sharing OC column/subtitle keys.
