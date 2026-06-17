# DIR Diving iOS — Planner Gas Section Label Rename

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `fa5adfa`  
**Status:** Implemented

## Label renamed

| From (IT) | To (IT) | Keys |
|-----------|---------|------|
| Gas disponibile | Pianificazione Gas | `planner.available_gas.title`, `planner.gas_ledger.title` |

English **Available Gas** unchanged.

## Files modified

- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_OUTPUT_UX_CLEANUP.md`
- `Docs/DIR_DIVING_IOS_PLANNER_OUTPUT_UX_CLEANUP_REMEDIATION_REPORT.md`

## Confirmations

- UI/localization-only change
- Planner logic and gas math unchanged
- Reserve/minimum gas warning labels unchanged
- Liters/bar display unchanged
- Bühlmann, CCR, Ratio Deco unchanged
- Sync and persistence unchanged

## Build / test results

| Step | Result |
|------|--------|
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `GasLedgerDisplayFormatterTests` | **TEST SUCCEEDED** |
