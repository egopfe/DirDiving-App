# DIR Diving iOS — UI Label Rename Report

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `5a2bb2f`  
**Status:** Implemented

## Labels renamed

| From (IT) | To (IT) | Key |
|-----------|---------|-----|
| Tappe decompressive | Tappe Decompressione | `planner.deco_stops.title` |
| Tappe decompressive CCR | Tappe Decompressione CCR | `ccr.deco_stops.title` |
| Immagini attrezzatura | Gestione Immagini Su Apple Watch | `equipment.images.section` |

English labels unchanged (`Deco Stops`, `Equipment images`, etc.).

## Files modified

- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_OUTPUT_UX_CLEANUP.md`
- `Docs/DIR_DIVING_IOS_PLANNER_DIVE_RUNTIME_PRESENTATION.md`

## Confirmations

- UI/localization-only change
- Planner logic unchanged
- Bühlmann, CCR, Ratio Deco, gas planning unchanged
- Equipment image logic and Apple Watch sync unchanged
- No experimental files touched

## Build / test results

| Step | Result |
|------|--------|
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `IOSEquipmentChecklistTabSplitTests` | **TEST SUCCEEDED** |
