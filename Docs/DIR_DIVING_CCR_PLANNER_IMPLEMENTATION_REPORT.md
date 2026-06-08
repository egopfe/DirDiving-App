# DIR Diving CCR Planner Implementation Report

**Date:** 2026-06-08  
**Scope:** iOS Companion Planner — CCR module (V1 + V2)  
**Verdict:** **READY FOR INTERNAL VALIDATION — 100%**

## Summary

Implemented an isolated CCR planning path alongside the existing Open Circuit Base / Deco / Technical planner. The Bühlmann ZHL-16C engine internals were not modified; CCR tissue loading uses a dedicated inspired-gas model feeding the existing `BuhlmannTissueState` Schreiner path. Watch runtime code was not touched.

## Architecture

```
Planner tab
 └─ PlannerModeSelectionView (Base / Deco / Technical / CCR)
     ├─ PlannerView (OC — unchanged behavior)
     └─ CCRPlannerView → CCRPlanResultView
         ├─ TissueNarcosisAnalyticsView (CCR planned trace)
         ├─ CCR PDF export
         └─ CCRPlannerService → CCRPlannerEngine + CCRInspiredGasModel
```

## Files Created

| Path | Purpose |
|------|---------|
| `iOSApp/Models/CCR/CCRModels.swift` | CCR input/result/bailout/setpoint/logbook models |
| `iOSApp/Services/CCR/CCRInspiredGasModel.swift` | Setpoint-based inspired PN2/PHe + tissue loading |
| `iOSApp/Services/CCR/CCRPlanValidator.swift` | Diluent/setpoint/bailout validation |
| `iOSApp/Services/CCR/CCRPlannerEngine.swift` | CCR decompression schedule (reuses GF/ceiling) |
| `iOSApp/Services/CCR/CCRPlannerService.swift` | Plan orchestration, CNS/OTU, timelines |
| `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift` | Lost loop, flooded, hypoxia, hyperoxia, manual bailout |
| `iOSApp/Services/CCR/CCRGasDensityEstimator.swift` | Reference gas density approximation |
| `iOSApp/Services/PDF/CCRPlannerPDFBuilder.swift` | CCR plan PDF export |
| `iOSApp/Utils/CCRPlannerSettings.swift` | Feature flag storage key |
| `iOSApp/Views/CCR/PlannerRootView.swift` | Planner entry router |
| `iOSApp/Views/CCR/PlannerModeSelectionView.swift` | Mandatory mode selection |
| `iOSApp/Views/CCR/CCRPlannerView.swift` | CCR configuration UI |
| `iOSApp/Views/CCR/CCRPlanResultView.swift` | CCR results, charts, tissue analytics, PDF share |
| `Tests/iOSAlgorithmTests/CCRPlannerTests.swift` | CCR + OC regression guards |

## Files Modified

| Path | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | Added `PlannerMode.ccr` |
| `iOSApp/Services/PlannerStore.swift` | CCR state, persistence, isolated planning path |
| `iOSApp/Utils/PlannerModePolicy.swift` | CCR presentation; OC validation skip |
| `iOSApp/Utils/PlannerModeLimits.swift` | CCR limit bypass |
| `iOSApp/Views/PlannerView.swift` | Mode banner + back navigation (no inline CCR) |
| `iOSApp/Views/ContentView.swift` | `PlannerRootView` entry |
| `iOSApp/Views/ManualDiveEditorView.swift` | CCR logbook metadata fields |
| `iOSApp/Utils/ManualDiveEditorValidation.swift` | Persist `ccrLogbookMetadata` |
| `iOSApp/Models/DiveSession.swift` | `DiveGasLabel.ccr`, optional `CCRLogbookMetadata` |
| `iOSApp/Services/EquipmentStore.swift` | CCR checklist template |
| `iOSApp/Services/PDF/PDFExportService.swift` | `exportCCRPlan` / `canExportCCRPlan` |
| `iOSApp/Services/TissueAnalyticsService.swift` | CCR planned trace build/presentation |
| `iOSApp/Models/TissueAnalyticsTrace.swift` | `.ccrPlanned` source |
| `iOSApp/Services/SubsurfaceExportService.swift` | CCR metadata CSV export |
| `iOSApp/Services/DiveImportService.swift` | CCR metadata CSV import |
| `iOSApp/Views/ShareSheetView.swift` | `PDFShareActions.ccrContext` |
| `iOSApp/Resources/{en,it}.lproj/Localizable.strings` | EN/IT CCR strings + safety copy |
| `project.yml` | Test target CCR + PDF sources |
| `Tests/iOSAlgorithmTests/PDFExportServiceTests.swift` | CCR PDF tests |
| `Tests/iOSAlgorithmTests/TissueAnalyticsServiceTests.swift` | CCR tissue analytics test |
| `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift` | CCR CSV round-trip test |

## Safety Positioning

- All CCR outputs labelled **reference estimate only**
- Mandatory safety disclaimer on CCR input and results
- EN/IT copy per specification §17
- DIR Diving is **not** a certified dive computer; CCR planner is **not** certified decompression advice

## CCR Gas Model

At each depth sample:

- `Pamb` = ambient pressure (`PlannerEnvironment`)
- `PPO2` = active setpoint (not diluent FO2)
- `availableInert = max(Pamb - PPO2, 0)`
- `PN2 = availableInert × FN2(diluent)`, `PHe = availableInert × FHe(diluent)`

CNS/OTU integration uses setpoint-based PPO2 per segment, not diluent oxygen fraction.

## Feature Completeness (100%)

| Area | Status |
|------|--------|
| Models + engine | ✅ Setpoint switching, shallow-ascent manual mode, Bühlmann GF deco |
| UI workflow | ✅ Mode selection, input, results, tissue analytics entry |
| Bailout V1+V2 | ✅ Five scenario calculator + results card |
| Charts | ✅ Depth, PPO2, PPN2, END, gas density, CNS timeline |
| PDF | ✅ `CCRPlannerPDFBuilder` + share from results |
| Logbook | ✅ Manual editor CCR fields + CSV export/import round-trip |
| Tissue analytics | ✅ `.ccrPlanned` source with full presentation |
| Tests | ✅ Planner, PDF, tissue analytics, CSV round-trip, shallow ascent |
| OC regression | ✅ OC path unchanged |

## OC Regression Status

- OC `PlannerModePolicy` projection unchanged for `.base` / `.deco` / `.technical`
- CCR mode bypasses OC `PlannerService.makePlan`
- Existing Bühlmann engine files unmodified

## Remaining (Physical QA Only)

- On-device CCR planner walkthrough with real unit preferences
- Physical Watch QA unchanged (Watch not in scope)
- TestFlight reviewer notes for CCR disclaimer copy

**Final verdict:** **READY FOR INTERNAL VALIDATION — 100%** — all software deliverables for CCR V1+V2 are implemented; physical QA and App Store review remain.
