# DIR Diving iOS — Planner Output UX Cleanup Remediation Report

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `1f97627`  
**Status:** Implemented

## Prior work (already on main)

| Item | Commit area |
|------|-------------|
| Runtime sequential ordering | `05cc3d1` |
| Dedicated Deco Stops section | `ad654a7` |
| Buddy comparison removal | `1f97627` |

## This pass — gas UX

### Files modified

- `iOSApp/Services/GasLedgerDisplayFormatter.swift` (new)
- `iOSApp/Views/Components/GasQuantityMetricTile.swift` (new)
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/GasLedgerDisplayFormatterTests.swift` (new)
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `project.yml`

### Gas section rename

- `planner.available_gas.title` → **Pianificazione Gas** (IT) / **Available Gas** (EN)
- Reserve card and gas ledger card use this title
- `planner.card.reserve` / reserve warning keys unchanged for true reserve concepts

### Gas display

- `GasQuantityMetricTile`: liters primary, `≈` pressure secondary
- `GasLedgerDisplayFormatter`: cylinder-specific bar conversion for display only

## Confirmations

- Bühlmann, CCR, Ratio Deco, gas math unchanged
- Rock bottom / reserve warnings unchanged
- MOD/PPO₂ unchanged
- Planner mode policy unchanged (except prior buddy visibility flags)
- Sync/persistence unchanged
- Presentation-only

## Tests

- `GasLedgerDisplayFormatterTests` (new)
- `testGasLedgerSectionTitleIsAvailableGas`
- Existing runtime, deco stops, buddy removal tests on main

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `PlannerAscentTableTests` | **TEST SUCCEEDED** |
| `GasLedgerDisplayFormatterTests` | **TEST SUCCEEDED** |
| `BriefingPDFBuilderTests` | **TEST SUCCEEDED** |
| `PlannerModePolicyTests` | **TEST SUCCEEDED** |
| `BuhlmannUxReadinessTests` | **TEST SUCCEEDED** |

## Limitations

- PDF gas ledger labels not updated in this pass (UI-focused).
- Turn pressure shown as liters + bar equivalent on reserve card for consistency.
