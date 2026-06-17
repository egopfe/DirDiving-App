# DIR Diving iOS — Planner Buddy Comparison Removal Report

**Date:** 2026-06-11  
**Branch:** `main`  
**Starting commit:** `ad654a7`  
**Status:** Implemented

## UI sections removed/hidden

| Section | Location | Action |
|---------|----------|--------|
| Team Gas Matching preview | Planner input (Technical) | Removed |
| Team Gas Match result card | Plan result (Technical) | Removed |
| Team briefing PDF block | BriefingPDFBuilder | Removed |

## Files modified

- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Services/PDF/BriefingPDFBuilder.swift`
- `iOSApp/Services/PlannerService.swift` (comment only)
- `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift`
- `Tests/iOSAlgorithmTests/BriefingPDFBuilderTests.swift`
- `Docs/DIR_DIVING_IOS_PLANNER_BUDDY_COMPARISON_REMOVAL.md`

## Confirmations

- Bühlmann unchanged
- CCR unchanged
- Ratio Deco unchanged
- Gas consumption unchanged
- Rock bottom unchanged
- Reserve warnings unchanged
- Bailout/standby gas unchanged
- Sync/persistence unchanged
- No experimental Buddy files touched
- `GasPlanningService.teamGasMatches` preserved for future Team/Buddy Planning

## Tests added/updated

- `testPlannerMainOutputDoesNotSurfaceTeamGasMatchSection`
- `testTechnicalPlannerStillShowsGasLedgerPresentationFlag`
- `testBriefingPDFOmitsPartialTeamGasMatchSection`

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `PlannerPresentationTests` | **TEST SUCCEEDED** |
| `PlannerModePolicyTests` | **TEST SUCCEEDED** |
| `BriefingPDFBuilderTests` | **TEST SUCCEEDED** |

## Future recommendation

Implement a dedicated **Team / Buddy Planning** module with full profile, deco, gas-switch, MOD/PPO₂, CNS/OTU, and OC/CCR compatibility before surfacing any team comparison in the main Planner again.
