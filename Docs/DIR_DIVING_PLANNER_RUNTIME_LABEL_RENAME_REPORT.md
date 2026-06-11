# DIR Diving iOS — Planner Runtime Label Rename

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `0064785`  
**Status:** Implemented

## Label renamed

| From (IT) | To (IT) | Key |
|-----------|---------|-----|
| Trasporto | Risalita | `planner.runtime.row.travel` |

English **Travel** unchanged. Internal enum case `.travel` unchanged.

## Files modified

- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerAscentTableTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_DIVE_RUNTIME_PRESENTATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_OUTPUT_UX_CLEANUP.md`

## Confirmations

- UI/localization-only change
- Runtime ordering unchanged
- Bühlmann, CCR, Ratio Deco, gas planning unchanged
- Gas role label `gas.role.travel` unchanged (separate concept)

## Build / test results

| Step | Result |
|------|--------|
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerAscentTableTests` | **TEST SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
