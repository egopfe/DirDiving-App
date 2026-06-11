# DIR Diving iOS — Planner Dive Runtime Sequential Order Remediation

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `276c300`  
**Status:** Implemented

## Implementation approach

**Option A (segment-based)** — primary.

`BuhlmannEngineResult.segments` already includes `.stop` segments in chronological order alongside `.ascent` and `.gasSwitch`. `PlannerAscentTableBuilder.postBottomRuntimeRows` iterates post-bottom segments in engine order and maps:

| Segment kind | Runtime row kind |
|--------------|------------------|
| `.ascent`, `.gasSwitch` | `.travel` |
| `.stop` | `.decoStop` (labels from matching `DecoStop`) |

**Hybrid fallback:** unmatched `decoStops` (rare) are appended once at the end of post-bottom rows so no stop is dropped.

No Bühlmann, CCR, or Ratio Deco calculation code was modified.

## Files modified

- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerAscentTableTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_DIVE_RUNTIME_PRESENTATION.md`

## Confirmations

- Bühlmann math unchanged
- CCR math unchanged
- Ratio Deco unchanged
- Stop depths unchanged (sourced from `decoStops` / engine stops)
- Stop times unchanged
- Gas switch calculations unchanged
- Only runtime **presentation ordering** changed
- Deco stops interleaved with travel rows per engine timeline
- Raw `decoStop` not user-facing

## Tests added/updated

- `testDecoStopsAreInterleavedWithTravelRows`
- `testRuntimeRowsFollowDescendingOperationalDepthsAfterBottom`
- `testEachDecoStopAppearsExactlyOnce`
- `testDecoStopDepthsAndTimesArePreserved`
- `testNoDecoPlanHasNoDecoStopRows`
- `testTechnicalMultigasRuntimeKeepsGasSwitchOrder`
- `testRuntimeSurfaceIsLast`
- `testRawDecoStopEnumNameIsNotPresented`
- Updated briefing footnote localization test

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build (Simulator, no signing) | **BUILD SUCCEEDED** |
| `PlannerAscentTableTests` | **TEST SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `PlannerModePolicyTests` | **TEST SUCCEEDED** |
| `BuhlmannEngineTests` / `BuhlmannPlannerTests` / `CCRPlannerTests` | **TEST SUCCEEDED** (exit 0) |

## Remaining limitations

- Unmatched deco stops (if engine/DecoStop mismatch) append at end of post-bottom block as safety fallback.
- CCR schedule was already chronological; no CCR engine changes required.
