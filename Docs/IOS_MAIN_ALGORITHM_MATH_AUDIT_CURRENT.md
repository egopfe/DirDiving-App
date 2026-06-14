# iOS Companion MAIN Branch - Complete Mathematical Functions / Algorithm Audit (CCR Updated V2.0)

**Audit date:** 2026-06-13  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main` only  
**HEAD audited:** `5b85505` (`comandi aggiornati`)  
**Remote alignment at audit start:** `main...origin/main = 0 / 0`  
**Command source:** `H:/My Drive/App/MAIN_COMANDI_TO_OBJECTIVE/0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V2.0.md`  
**Mode:** audit only. No source code, UI, business logic, Watch runtime, commits, or pushes were performed.

This report is based on static repository inspection on Windows. Apple tooling is not available in this environment, so `xcodegen`, `xcodebuild`, and XCTest execution were not run. The codebase contains a large iOS algorithm test suite, but this audit reports static correctness and release-readiness risks separately from macOS build/test evidence.

---

## Indice

### Metadati e sintesi

| Sezione | Contenuto |
|---|---|
| [A. Scope Confirmed](#a-scope-confirmed) | Ambito audit, esclusioni, preflight branch/repo |
| [B. Executive Verdict](#b-executive-verdict) | Verdetto esecutivo e readiness complessiva |
| [C. Readiness Matrix By Function](#c-readiness-matrix-by-function) | Matrice funzione × stato × readiness |
| [D. Files Inspected](#d-files-inspected) | Inventario file ispezionati (planner, CCR, sync, test) |

### Audit per area algoritmica

| Sezione | Contenuto |
|---|---|
| [E. Buhlmann ZHL-16C Engine Audit](#e-buhlmann-zhl-16c-engine-audit) | Costanti, tissue loading, ceiling, NDL, GF |
| [F. CCR / Rebreather Audit](#f-ccr--rebreather-audit) | Setpoint, density, CNS/OTU, bailout — finding P1/P2/P3 |
| [G. Ratio Deco Audit](#g-ratio-deco-audit) | Heuristic comparator, limiti e labeling |
| [H. Gas Planning / Gas Schedule Audit](#h-gas-planning--gas-schedule-audit) | Ruoli gas, schedule, ledger |
| [I. Emergency Gas / Rock Bottom / Minimum Gas Audit](#i-emergency-gas--rock-bottom--minimum-gas-audit) | Rock bottom, minimum gas, assunzioni |
| [J. Repetitive Dive / Residual Tissue Audit](#j-repetitive-dive--residual-tissue-audit) | Snapshot tessuti, off-gassing |
| [K. Unit Conversion / Ambient Pressure / Salinity / Altitude Audit](#k-unit-conversion--ambient-pressure--salinity--altitude-audit) | Unità, pressione ambiente, salinità, quota |
| [L. MOD / PPO2 / Dalton Law Audit](#l-mod--ppo2--dalton-law-audit) | Validazione MOD/PPO2, legge di Dalton |
| [M. Tissue Analytics / Narcosis / END / EAD / PPN2 Audit](#m-tissue-analytics--narcosis--end--ead--ppn2-audit) | Analytics tessuti, narcosi, END/EAD |
| [N. CNS / OTU Audit](#n-cns--otu-audit) | Esposizione ossigeno, hardening richiesto |
| [O. Logbook / Manual Dive / Import / Export / Sync Math Audit](#o-logbook--manual-dive--import--export--sync-math-audit) | Logbook, import CSV, sync |
| [P. PDF / Share / Planner Briefing Cards Audit](#p-pdf--share--planner-briefing-cards-audit) | Export PDF, briefing cards Watch |
| [Q. Structured Equipment / Checklist Audit](#q-structured-equipment--checklist-audit) | Equipment strutturato, checklist |
| [R. Watch Runtime / Watch Math Boundary Audit](#r-watch-runtime--watch-math-boundary-audit) | Confine iOS/Watch, nessuna autorità deco Watch |

### Finding CCR (sezione F)

| ID | Titolo |
|---|---|
| [CCR-P1-001](#finding-ccr-p1-001-gas-density-estimator-appears-not-pressure-scaled) | Gas density non scalata per pressione |
| [CCR-P1-002](#finding-ccr-p1-002-oxygen-exposure-failures-fall-back-to-zero) | CNS/OTU fallback a zero |
| [CCR-P3-001](#finding-ccr-p3-001-oxygen-exposure-synthetic-gas-labels-use-air-diluent) | Label gas diluent `.air` su trace CCR |
| [CCR-P2-001](#finding-ccr-p2-001-bailout-scenario-calculator-is-heuristic) | Bailout euristico |

### Chiusura audit

| Sezione | Contenuto |
|---|---|
| [S. Test Coverage Audit](#s-test-coverage-audit) | Inventario test, gap di copertura |
| [T. Findings And Priority Ranking](#t-findings-and-priority-ranking) | P0 / P1 / P2 / P3 — tabella finding ID |
| [U. Implementation Plan For Remaining Issues](#u-implementation-plan-for-remaining-issues) | Fasi 1–5 remediation |
| [V. Edge Cases To Keep Testing](#v-edge-cases-to-keep-testing) | Edge case da mantenere in test |
| [W. Documentation Alignment](#w-documentation-alignment) | Allineamento con altri doc repo |
| [X. Build / Test Execution Status](#x-build--test-execution-status) | Stato xcodegen/build/test |
| [Y. Release Gate Status](#y-release-gate-status) | Gate TestFlight / App Store / claim certificati |
| [Z. Final Verdict](#z-final-verdict) | Verdetto finale e prossimi passi |

### Finding ID (sezione T)

| Priorità | ID | Area |
|---|---|---|
| P1 | IOS-MATH-P1-001 | CCR gas density |
| P1 | IOS-MATH-P1-002 | CCR CNS/OTU failure fallback |
| P2 | IOS-MATH-P2-001 | CCR bailout heuristic |
| P2 | IOS-MATH-P2-002 | External fixture evidence |
| P2 | IOS-MATH-P2-003 | PDF/briefing render QA |
| P3 | IOS-MATH-P3-001 | CCR oxygen exposure label |
| P3 | IOS-MATH-P3-002 | Ratio Deco labeling |
| P3 | IOS-MATH-P3-003 | macOS build/test gate |

---

## A. Scope Confirmed

### In scope

- iOS Companion MAIN app only.
- iOS planner mathematics and algorithmic services.
- Buhlmann ZHL-16C, multigas, trimix, gradient factor, tissue history, NDL, decompression stops.
- CCR / rebreather planning reference logic.
- Ratio Deco compatibility logic.
- Gas planning, gas ledger, reserve, rock-bottom/minimum-gas logic.
- Planner ascent/descent timing and schedule-aware gas consumption.
- Repetitive planning and residual tissue snapshots.
- Manual dive, logbook-derived mathematics, import/export/sync validation where used by iOS.
- Structured equipment, checklist integration, CCR checklist import/export.
- Planner briefing cards and Watch transfer boundaries.
- Watch math/runtime only where relevant to confirm iOS changes do not imply Watch decompression authority.

### Out of scope

- No Watch runtime change.
- No experimental branch analysis beyond confirming MAIN target isolation.
- No UI/UX redesign.
- No code remediation.
- No commit/push.

### Branch and repository preflight

| Check | Result |
|---|---|
| Current branch | `main` |
| Remote | `https://github.com/egopfe/DirDiving-App.git` |
| Local HEAD | `5b85505` |
| Local vs remote | aligned at audit start (`0 / 0`) |
| Working tree before report update | clean |
| `project.yml` present | yes |
| Experimental iOS files excluded from MAIN target | yes |
| Experimental Watch files excluded from MAIN target | yes |

---

## B. Executive Verdict

The iOS Companion MAIN algorithm stack is substantially mature and internally coherent for a **non-certified Buhlmann-based planning reference**. The open-circuit Buhlmann ZHL-16C path is implemented with nitrogen, helium, trimix, multigas, gradient factors, tissue-state NDL, and generated decompression stops. Planner validation, gas-role separation, MOD/PPO2 checks, schedule-aware gas ledger, repetitive tissue snapshots, PDF/share outputs, checklist mapping, and Watch briefing transfer support are present.

The main remaining algorithmic concerns are concentrated in the CCR/rebreather layer and evidence process:

1. **CCR gas density appears under-scaled** because the estimator returns a composition-weighted 1 bar style density instead of pressure-scaled density at depth.
2. **CCR CNS/OTU calculation failures currently fall back to zero**, which can make an unavailable exposure calculation look safe.
3. **CCR bailout is explicitly heuristic**, not a model-derived OC bailout decompression/gas simulation.
4. **External reference validation evidence remains required** before calling the Buhlmann/CCR planner release-hard for public TestFlight or App Store language.
5. **macOS build/test execution is still required** because this audit was performed on Windows.

### Overall readiness

| Area | Static readiness | Confidence | Blocker class |
|---|---:|---|---|
| Open-circuit Buhlmann planner | 92% | High | External fixtures / macOS tests |
| Trimix / helium model | 90% | High | External validation |
| CCR / rebreather planner | 74% | Medium | Gas density + exposure failure fallback |
| CCR setpoint and diluent math | 84% | Medium-high | External CCR fixture validation |
| CCR bailout scenarios | 70% | Medium | Heuristic by design |
| Ratio Deco | 84% | Medium-high | Heuristic, must remain labeled |
| Gas planning and gas ledger | 88% | High | Physical/review QA |
| Emergency / rock bottom | 82% | Medium-high | Assumptions require field policy validation |
| Schedule-aware gas consumption | 87% | High | External scenario validation |
| Repetitive dive residual tissues | 80% | Medium-high | Snapshot provenance and validation |
| Logbook/import/export math | 84% | Medium-high | CSV/PDF render QA |
| Planner briefing card transfer | 81% | Medium | Device transfer QA |
| Unit conversion / pressure model | 90% | High | macOS test run |
| Watch isolation from decompression logic | 98% | High | Physical QA only |
| Overall iOS math readiness | 83% | Medium-high | P1 CCR fixes + external validation |

---

## C. Readiness Matrix By Function

| Function | Status | Readiness | Notes |
|---|---|---:|---|
| Buhlmann ZHL-16C constants | Implemented | 95% | 16 N2 and He compartments present. |
| Inspired inert gas pressure | Implemented | 91% | Water vapor subtraction and environment pressure present. |
| Tissue loading | Implemented | 90% | Constant-depth and Schreiner-style linear loading present. |
| Mixed N2/He coefficients | Implemented | 90% | Weighted by inert partial pressure. |
| Ceiling calculation | Implemented | 89% | GF ceiling and controlling compartment present. |
| GF Low/High interpolation | Implemented | 86% | Depth-progress interpolation present; external parity recommended. |
| NDL search | Implemented | 86% | Binary search tissue-state based; no fake `999` fallback observed in engine path. |
| Multigas switching | Implemented | 87% | Travel/deco gas switch scheduling and operational checks present. |
| Trimix validation | Implemented | 88% | O2/He composition and hypoxic/MOD checks present. |
| CCR setpoint tissue loading | Implemented | 82% | Dedicated CCR inspired gas path. |
| CCR gas density | Needs fix | 58% | Appears not pressure-scaled at depth. |
| CCR CNS/OTU failure semantics | Needs fix | 65% | Failure falls back to `0`. |
| CCR bailout scenarios | Heuristic | 70% | Labeled reference, not engine-simulated bailout plan. |
| Ratio Deco | Heuristic validated | 84% | Blocked in CCR, labeled comparator. |
| Planner gas schedule | Implemented | 86% | Role-aware bottom/travel/deco/bailout/CCR handling. |
| Gas ledger | Implemented | 88% | Schedule-aware consumption and warnings present. |
| Rock bottom / minimum gas | Implemented | 82% | Assumptions centralized but need field validation. |
| Repetitive planning | Implemented | 80% | Tissue snapshots/off-gassing present. |
| Manual dive math | Implemented | 86% | Manual and synthetic profile helpers present. |
| PDF/share exports | Implemented | 80% | Need render/snapshot QA on macOS. |
| Briefing cards to Watch | Implemented | 80% | Needs paired-device QA. |
| Structured equipment mapping | Implemented | 84% | CCR roles supported. |
| iOS/Watch sync math integrity | Implemented | 82% | Extensive validation tests listed, physical QA pending. |

---

## D. Files Inspected

### Planner / Buhlmann / gas planning

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/RatioDecoModels.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Services/PlannerAscentSpeedSettingsStore.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/RatioDecoPlanner.swift`
- `iOSApp/Services/RatioDecoValidator.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerModeLimits.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/PlannerResultState.swift`

### CCR / rebreather

- `iOSApp/Models/CCR/CCRModels.swift`
- `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`
- `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`
- `iOSApp/Services/CCR/CCRInspiredGasModel.swift`
- `iOSApp/Services/CCR/CCRPlannerEngine.swift`
- `iOSApp/Services/CCR/CCRPlannerService.swift`
- `iOSApp/Services/CCR/CCRPlanValidator.swift`
- `iOSApp/Services/CCR/CCRTissueHistorySampler.swift`

### Output / sync / checklist / briefing

- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/PDF/*.swift`
- `iOSApp/Services/PlannerBriefingImageExportService.swift`
- `iOSApp/Services/PlannerBriefingWatchTransferService.swift`
- `Models/PlannerBriefingCard.swift`
- `Services/PlannerBriefingCardStore.swift`
- `Services/PlannerBriefingWatchReceiver.swift`
- `iOSApp/Utils/EquipmentPlannerMapper.swift`
- `iOSApp/Utils/EquipmentChecklistGenerator.swift`
- `iOSApp/Utils/CCRChecklistExportCoordinator.swift`
- `iOSApp/Utils/CCRChecklistImportCoordinator.swift`

### Watch cross-boundary files

- `Services/DiveManager.swift`
- `Services/WatchSyncService.swift`
- `Models/AscentRateLimits.swift`
- `Models/AscentStatus.swift`
- `Utils/DIRUnitConversions.swift`
- `Views/PlannerBriefingCardsView.swift`

### Tests inventory

Static count found:

- iOS algorithm test methods: **770**
- Watch algorithm test methods: **216**
- iOS algorithm test files: **124**
- Watch algorithm test files: **36**

---

## E. Buhlmann ZHL-16C Engine Audit

### Evidence found

`BuhlmannConstants.swift` defines:

- `compartmentCount = 16`
- N2 half-times:
  `5.0, 8.0, 12.5, 18.5, 27.0, 38.3, 54.3, 77.0, 109.0, 146.0, 187.0, 239.0, 305.0, 390.0, 498.0, 635.0`
- He half-times:
  `1.88, 3.02, 4.72, 6.99, 10.21, 14.48, 20.53, 29.11, 41.20, 55.19, 70.69, 90.34, 115.29, 147.42, 188.24, 240.03`
- ZHL-16C-style N2 and He `a` / `b` coefficient arrays.
- Water vapor pressure `0.0627 bar`.
- Sea-level surface pressure `1.01325 bar`.
- Stop interval `3 m`.

`BuhlmannEngine.swift` provides:

- Buhlmann plan request/result data structures.
- Full validation path.
- `noDecompressionLimit(...)`.
- `gfAtDepth(...)`.
- Tissue loading through descent, bottom, ascent, gas switch, and decompression schedule.
- Stop generation from tissue ceiling, not static templates.
- Multigas ascent gas selection.

`BuhlmannTissueModel.swift` provides:

- air saturation at surface pressure.
- constant-depth loading.
- linear-depth Schreiner-style loading.
- mixed inert gas ceiling calculation.

### Correctness assessment

The OC Buhlmann implementation is coherent and materially complete for a reference planner. The implementation does not appear to use static stop templates for the Buhlmann path. It validates gases, depth/time/GF bounds, MOD/hypoxic use, and operational gas range. It rejects invalid compositions and has calculation-limit guards.

### Remaining limitations

- This audit did not execute numerical fixture tests.
- External comparison against known planners/tables remains required before marketing as "release-hard".
- GF interpolation is plausible but should be compared to reference fixtures profile-by-profile.

---

## F. CCR / Rebreather Audit

### Evidence found

The CCR feature is implemented as a separate iOS planning path:

- `CCRPlannerEngine.swift` performs setpoint-profile tissue loading and decompression scheduling.
- `CCRInspiredGasModel.swift` computes inspired ppO2, ppN2, and ppHe from setpoint, diluent, and environment.
- `CCRPlanValidator.swift` validates setpoints, diluent, bailout gases, PPO2, hypoxic use, and MOD.
- `CCRPlannerService.swift` assembles result, CNS/OTU exposure, timeline data, tissue trace, bailout scenarios, warnings, depth profile, and Buhlmann state.
- `CCRTissueHistorySampler.swift` supports chart/tissue analytics.

### Positive findings

- CCR is iOS-only and does not contaminate Watch runtime.
- CCR has a dedicated model and validation layer.
- CCR uses setpoint-inspired inert pressures rather than directly feeding a tank gas as OC.
- CCR plan results carry explicit reference-only warnings.
- Bailout scenarios are clearly separated from active CCR decompression schedule.

### Finding CCR-P1-001: gas density estimator appears not pressure-scaled

**File:** `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`  
**Lines inspected:** 18-23  
**Severity:** P1 mathematical correctness / safety warning correctness

The estimator computes:

```swift
let o2Fraction = min(1, setpointBar / ambient)
let n2Fraction = inspired.ppN2 / ambient
let heFraction = inspired.ppHe / ambient
return o2Fraction * 1.429 + n2Fraction * 1.251 + heFraction * 0.1786
```

This is composition-weighted density using reference gas densities, but it does not appear to multiply by ambient or dry pressure. At depth, breathing gas density should rise approximately with absolute pressure. As written, CCR gas density warnings can be materially under-reported at depth.

**Impact:** Gas density timeline and warning thresholds can look safer than they are.

**Recommended fix:** Compute density from partial pressures, for example:

- `density = rhoO2At1Bar * ppO2 + rhoN2At1Bar * ppN2 + rhoHeAt1Bar * ppHe`
- Use dry gas partial pressures consistently.
- Add tests at 30 m, 60 m, air diluent, trimix diluent, and high setpoint.
- If the current value is intended to be "surface equivalent composition density", rename it and do not use it against depth gas-density thresholds.

### Finding CCR-P1-002: oxygen exposure failures fall back to zero

**File:** `iOSApp/Services/CCR/CCRPlannerService.swift`  
**Lines inspected:** 48-67  
**Severity:** P1 safety-state correctness

When `CCROxygenExposureIntegration.exposure(...)` fails, `cnsFull`, `otuFull`, and `cnsDB` are set to zero. That makes an unavailable/invalid exposure calculation appear safe.

**Impact:** Failed CNS/OTU calculation can be presented as 0% / 0 OTU instead of unavailable.

**Recommended fix:**

- Add typed exposure state: `.available`, `.unavailable(reason:)`, `.invalidSegments`, `.modelLimitReached`.
- Surface a warning and suppress safe-looking numeric values when unavailable.
- Add tests for invalid segment duration, invalid setpoint, invalid environment, and failed exposure integration.

### Finding CCR-P3-001: oxygen exposure synthetic gas labels use air diluent

**File:** `iOSApp/Services/CCR/CCRInspiredGasModel.swift`  
**Lines inspected:** 143-158  
**Severity:** P3 maintainability / trace semantics

`CCROxygenExposureIntegration.exposure(...)` builds an intermediate label gas using `diluent: .air`. Because `overridePPO2Gas(...)` drives oxygen exposure from the setpoint-derived oxygen fraction, this likely does not corrupt CNS/OTU math, but it can mislead trace labels and helium context.

**Recommended fix:** Pass actual diluent through exposure segments or remove label-gas dependency from oxygen exposure.

### Finding CCR-P2-001: bailout scenario calculator is heuristic

**File:** `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`  
**Lines inspected:** 39-43, 90-94  
**Severity:** P2 model completeness / release claims

The bailout calculator estimates required gas with SAC, ascent minutes, optional bottom fraction, and:

```swift
ceil(startDepth / stopIntervalMeters) * 3
```

This is a heuristic decompression-time proxy, not a Buhlmann OC bailout simulation from the current CCR tissue state.

**Impact:** Safe if labeled as heuristic; not sufficient for release-hard bailout planning claims.

**Recommended fix:** Either keep explicit heuristic labels everywhere or implement model-backed OC bailout simulation from CCR final/timeline tissue state with bailout gas switches.

---

## G. Ratio Deco Audit

### Evidence found

- `RatioDecoPlanner.swift` implements ratio presets, stop depth construction, stop minute distribution, gas assignment, depth profile rows, and ascent rows.
- `RatioDecoValidator.swift` validates the ratio schedule against planner/Buhlmann constraints.
- Tests cover 1:1, 2:1, custom preset, base-mode rejection, CCR-mode rejection, Buhlmann preservation, TTS units, and PDF inclusion.

### Assessment

Ratio Deco is implemented as a heuristic comparator, not an authoritative decompression model. This is acceptable if it remains clearly labeled and blocked from CCR mode.

### Remaining limitation

No external Ratio Deco fixture validation was executed in this environment.

---

## H. Gas Planning / Gas Schedule Audit

### Evidence found

- `GasPlanInput` supports Base, Deco, Technical, and CCR planner modes.
- Gas roles include bottom, travel, deco, bailout, CCR diluent, and CCR bailout.
- `PlannerGasSchedule` builds bottom gas, travel switches, deco gases, bailout availability warnings, and role schedule lines.
- `ScheduleGasConsumptionService` analyzes per-cylinder gas allocation, consumption, available pressure, reserve pressure, minimum gas, lost gas contingency, and warnings.
- Average-depth consumption is guarded by planner mode policy and does not appear to feed decompression math.

### Assessment

Gas planning is structurally strong. The planner avoids turning bailout gases into active decompression gases unless explicitly scheduled. It distinguishes CCR roles from OC roles.

### Remaining limitation

Rock-bottom/minimum-gas assumptions need field-policy validation. They are deterministic but should be reviewed by qualified diving experts before release claims.

---

## I. Emergency Gas / Rock Bottom / Minimum Gas Audit

### Evidence found

- `ScheduleGasConsumptionService.rockBottomLiters(...)`.
- `automaticAscentMinutes(...)` tied to planner ascent speed settings.
- Emergency extra minutes and team size normalization.
- Warning states for reserve breach, minimum gas breach, lost gas contingency failure, invalid allocation.

### Assessment

The implementation is conservative enough for planning reference if disclaimers remain visible. The model is not equivalent to a training-agency gas planning standard by itself.

### Recommendations

- Add scenario fixtures for common DIR team gas assumptions.
- Document which rock-bottom philosophy is used.
- Keep gas results as reference, not certification/training replacement.

---

## J. Repetitive Dive / Residual Tissue Audit

### Evidence found

- `RepetitiveDivePlannerService` defines `TissueSnapshot` and `SurfaceIntervalModel`.
- It validates snapshot missing/corrupted/stale/schema mismatch/environment/surface interval states.
- It can seed follow-up Buhlmann requests from valid residual tissue state.

### Assessment

The architecture is coherent and avoids silently trusting stale or invalid snapshots. External validation should confirm residual tissue behavior over multi-dive profiles.

---

## K. Unit Conversion / Ambient Pressure / Salinity / Altitude Audit

### Evidence found

- `IOSUnitConversions.swift` centralizes common conversions.
- `PlannerEnvironment` and `AmbientPressureModel` are used by Buhlmann/CCR pressure paths.
- `BuhlmannGas.ambientPressureBar(...)` uses `IOSUnitConversions.ambientPressureBar` when environment is supplied and sea-level fallback otherwise.
- Tests include pressure model unification and altitude behavior.

### Assessment

Unit discipline is strong. The main caveat is CCR density calculation, which uses ambient to compute fractions but not pressure-scaled density.

---

## L. MOD / PPO2 / Dalton Law Audit

### Evidence found

- `BuhlmannGas.ppO2(...)`.
- `BuhlmannGas.modMeters(...)`.
- `GasMixValidator.modMeters(...)`.
- `PlannerMODValidator`.
- `BuhlmannEngine.operationalIssues(...)`.
- `PPO2DisplayTests`.

### Assessment

Open-circuit MOD/PPO2 handling appears correct and fail-closed. Gas switch validation checks hypoxic shallow use and PPO2 at depth.

### Recommendation

Retain actual PPO2 display and separate max PPO2. Do not reintroduce clipping.

---

## M. Tissue Analytics / Narcosis / END / EAD / PPN2 Audit

### Evidence found

- Tissue analytics support for planned Buhlmann, recorded sessions, manual estimates, CCR planned traces.
- `CCRInspiredGasModel.ppN2Bar(...)` and `endMeters(...)`.
- `NarcosisAnalyticsSupport.endMeters(...)`.
- Tests include PPN2 and END checks.

### Assessment

Open-circuit tissue and narcosis analytics are coherent. CCR END appears based on ppN2, but CCR gas density needs correction before density warnings can be relied upon.

---

## N. CNS / OTU Audit

### Evidence found

- `OxygenExposureModel` and related tests for CNS/OTU.
- CCR uses `CCROxygenExposureIntegration.exposure(...)`.
- Planner service includes descent+bottom CNS warning logic.

### Assessment

The base oxygen exposure model appears well covered. The CCR service-level failure fallback to zero is the main issue.

### Required hardening

- Do not display failed CNS/OTU as zero.
- Add unavailable/warning result state.
- Test invalid CCR exposure segment handling.

---

## O. Logbook / Manual Dive / Import / Export / Sync Math Audit

### Evidence found

- `DiveProfileMath`, `DiveImportService`, `SubsurfaceExportService`, `DiveSessionMerge`, and Watch sync codecs are included in iOS algorithm test target.
- Tests cover time-weighted average, empty profile rejection, out-of-order timestamps, invalid depths, invalid GPS, merge recomputation, 41st log behavior, and sync validation.
- Manual dive validation/defaults are present.

### Assessment

The iOS logbook/import/export math has strong automated coverage by static inventory. macOS test execution is still required to verify pass/fail on current HEAD.

---

## P. PDF / Share / Planner Briefing Cards Audit

### Evidence found

- `PlannerPDFBuilder`, `BriefingPDFBuilder`, `CCRPlannerPDFBuilder`, `DivePackPDFBuilder`, `ChecklistPDFBuilder`.
- `PDFExportService.canExportPlan(...)` and `canExportCCRPlan(...)`.
- `PlannerBriefingImageExportService`.
- `PlannerBriefingWatchTransferService`.
- Shared `PlannerBriefingCard` model with hashing, manifest encoding, metadata validation, package size limits.
- Watch receiver validates file type, package metadata, hash, and manifest/card matching.

### Assessment

The architecture is sound. Remaining risk is render and device transfer QA, not core math.

### Recommendations

- Run PDF snapshot/render checks on macOS.
- Pair iPhone/Watch and verify briefing card transfer, import, reject, ACK, and display.

---

## Q. Structured Equipment / Checklist Audit

### Evidence found

- `EquipmentPlannerMapper` maps equipment profiles to planner input while filtering unsupported roles by mode.
- `EquipmentChecklistGenerator` generates structured checklist items for OC and CCR configurations.
- `CCRChecklistExportCoordinator` and `CCRChecklistImportCoordinator` support CCR gas/checklist synchronization.
- UI/UX remediation tests mention CCR import role preservation.

### Assessment

Checklist-to-planner integration is mathematically relevant because it can seed gases and cylinders. The role filter appears appropriate.

### Recommendation

Add explicit release QA for round-trip checklist export/import with trimix diluent and multiple bailout gases.

---

## R. Watch Runtime / Watch Math Boundary Audit

### Evidence found

- Watch algorithm tests cover depth validation, lifecycle, haptics, GPS, log cap, temperature bounds, merge, export, sync, reminders, and App Intents.
- Watch documentation states no CCR, no Buhlmann, no Ratio Deco runtime.
- `project.yml` keeps iOS algorithm files in iOS target and Watch runtime isolated.
- Planner briefing cards are visual/reference artifacts, not live decompression runtime.

### Assessment

The Watch remains an informational dive companion/logging runtime. The iOS CCR/Buhlmann planner does not appear to add live decompression authority to Watch MAIN.

---

## S. Test Coverage Audit

### Static test inventory

- iOS algorithm test methods: **770**
- Watch algorithm test methods: **216**

### Areas with strong listed coverage

- Buhlmann constants, pressure model, tissue loading, Schreiner equation.
- Ceiling, GF, NDL, multigas, trimix/helium, reference fixtures.
- Planner validation, MOD/PPO2, gas density scenarios, CNS/OTU.
- Ratio Deco heuristic validation.
- Planner ascent settings and gas ledger.
- Import/export/sync validation.
- Manual dive and logbook math.
- PDF/briefing output assertions.
- Watch algorithm isolation and runtime safety.

### Areas needing added/confirmed coverage

- CCR gas density pressure scaling at multiple depths and diluents.
- CCR oxygen exposure failure surfaces unavailable, not zero.
- CCR bailout model limitation tests remain explicit and visible.
- Full external fixture parity with third-party Buhlmann/CCR references.
- macOS/Xcode build and test evidence on current HEAD.

---

## T. Findings And Priority Ranking

### P0 - safety-critical blockers

No direct P0 code issue was confirmed from static inspection. The app still must not be marketed as certified or life-supporting.

### P1 - critical algorithmic correctness

| ID | Title | File | Impact | Recommended action |
|---|---|---|---|---|
| IOS-MATH-P1-001 | CCR gas density appears not pressure-scaled | `iOSApp/Services/CCR/CCRGasDensityEstimator.swift` | Density warnings can under-report at depth | Compute density from partial pressures and add tests. |
| IOS-MATH-P1-002 | CCR CNS/OTU exposure failure falls back to zero | `iOSApp/Services/CCR/CCRPlannerService.swift` | Unavailable exposure can appear safe | Add unavailable state and warning; suppress safe-looking zero. |

### P2 - data integrity / model completeness

| ID | Title | File | Impact | Recommended action |
|---|---|---|---|---|
| IOS-MATH-P2-001 | CCR bailout remains heuristic | `CCRBailoutScenarioCalculator.swift` | Not release-hard bailout decompression planning | Keep disclosure or implement OC bailout simulation. |
| IOS-MATH-P2-002 | External Buhlmann/CCR fixture evidence pending | `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` and test docs | Cannot claim external parity | Run documented fixture validation and store evidence. |
| IOS-MATH-P2-003 | PDF/briefing output needs render/device QA | PDF and briefing services | Math may be correct but user artifacts must be verified | Run macOS render and paired Watch QA. |

### P3 - maintainability / clarity

| ID | Title | File | Impact | Recommended action |
|---|---|---|---|---|
| IOS-MATH-P3-001 | CCR oxygen exposure label uses `.air` diluent | `CCRInspiredGasModel.swift` | Trace/label semantics can confuse future maintenance | Pass actual diluent or decouple label gas. |
| IOS-MATH-P3-002 | Ratio Deco requires ongoing heuristic labeling | `RatioDecoPlanner.swift` | Could be misread as decompression authority | Keep warnings and tests. |
| IOS-MATH-P3-003 | Windows audit cannot replace macOS build/test | repo process | Release gate incomplete | Run `xcodegen` and `xcodebuild test` on macOS. |

---

## U. Implementation Plan For Remaining Issues

### Phase 1 - CCR safety math corrections

1. Update `CCRGasDensityEstimator` to compute g/L from partial pressures.
2. Add tests:
   - air diluent at 10, 30, 60 m.
   - trimix diluent at 30 and 60 m.
   - high setpoint vs low setpoint.
   - invalid setpoint/depth returns unavailable.
3. Update CCR result warnings when density exceeds thresholds.

### Phase 2 - CCR oxygen exposure failure semantics

1. Add a typed CCR oxygen exposure state.
2. Replace zero fallback with unavailable/warning state.
3. Ensure UI existing layout can show warning without visual redesign.
4. Add tests for invalid segment, invalid setpoint, invalid environment, and empty segment behavior.

### Phase 3 - CCR bailout truthfulness

Choose one policy:

- **Policy A:** Keep heuristic. Strengthen labels, tests, and docs.
- **Policy B:** Implement model-backed OC bailout schedule from CCR tissue state and bailout gas switches.

For release-hard math claims, Policy B is preferable but larger.

### Phase 4 - External validation evidence

1. Run reference profiles against trusted external planner(s).
2. Store expected values and tolerance ranges.
3. Add or update fixture tests.
4. Record evidence in Docs QA folders.

### Phase 5 - macOS validation

Run on macOS:

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

---

## V. Edge Cases To Keep Testing

- Invalid gas O2 + He > 100%.
- Hypoxic trimix at surface.
- Oxygen deco gas too deep.
- GF low equals/high exceeds policy.
- Altitude pressure model with MOD/ceiling.
- Very shallow stop rounding near 3 m.
- NDL at zero/min depth.
- Calculation-limit profiles.
- CCR setpoint higher than dry ambient.
- CCR gas density at high pressure.
- CCR oxygen exposure invalid segment failure.
- Empty profile export.
- Out-of-order profile import.
- Sync payload with invalid GPS or sample timestamps.
- Repetitive dive stale/corrupt tissue snapshot.
- Watch briefing card oversized/hash mismatch.

---

## W. Documentation Alignment

The repository already contains substantial documentation for current state:

- `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`
- `Docs/CCR_REBREATHER_VALIDATION_PLAN.md`
- `Docs/CCR_REBREATHER_EXPORT_POLICY.md`
- `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md`
- `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_CURRENT.md`
- `Docs/WATCH_CSV_EXPORT_POLICY.md`
- `Docs/UI_UX_MAIN_AUDIT_CURRENT.md`

This report supersedes the older `IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` snapshot for the current HEAD and date.

---

## X. Build / Test Execution Status

| Command | Status | Reason |
|---|---|---|
| `xcodegen generate` | Not run | Windows environment; Apple tooling unavailable. |
| iOS build | Not run | Windows environment; Apple tooling unavailable. |
| iOS Algorithm Tests | Not run | Windows environment; Apple tooling unavailable. |
| Static code inventory | Done | `rg`, `git`, and file inspection. |
| Branch/remote alignment | Done at audit start | `main...origin/main = 0 / 0`. |

---

## Y. Release Gate Status

| Gate | Verdict |
|---|---|
| Ready for local macOS compile attempt | Yes |
| Ready for internal engineering review | Yes |
| Ready for internal TestFlight with CCR hidden/flagged as reference | Conditional |
| Ready to claim OC Buhlmann reference planner maturity | Conditional on external fixtures |
| Ready to claim CCR release-hard mathematical planner | No, not until P1 CCR fixes and external fixtures |
| Ready to claim certified dive computer/decompression authority | No, and must never do so without certification |
| Ready for App Store math claims | Not yet; needs legal and validation evidence |

---

## Z. Final Verdict

The current MAIN iOS Companion code is working from the latest local/remote-aligned repository snapshot and contains a mature algorithmic base. The open-circuit Buhlmann ZHL-16C multigas planner is materially implemented. CCR/rebreather planning is present and isolated, but **two P1 issues remain before it can be described as algorithmically release-hard**:

1. CCR gas density must be pressure-scaled or explicitly downgraded to a non-threshold reference metric.
2. CCR CNS/OTU exposure failures must not fall back to zero.

After those fixes, the next release-hard milestone is not more UI work; it is **validation evidence**: run macOS tests, compare Buhlmann/CCR fixtures against external references, and capture paired iPhone/Watch briefing transfer QA.

No code was changed by this audit beyond updating this Markdown report.
