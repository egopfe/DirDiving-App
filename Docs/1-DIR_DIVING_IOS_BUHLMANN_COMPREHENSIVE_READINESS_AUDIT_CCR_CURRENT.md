# DIR Diving iOS Buhlmann Comprehensive Readiness Audit - CCR Updated V2.0

**Audit date:** 2026-06-13  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `fedf4eb` (`docs: update iOS math audit report`)  
**Scope:** iOS Companion MAIN target only: `DIRDiving iOS`  
**Task type:** deep audit only  
**Command source:** `H:/My Drive/App/MAIN_COMANDI_TO_OBJECTIVE/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V2.0.md`  
**Execution environment:** Windows 10.0.26200.0. Apple build tools unavailable.

No Swift source, UI, business logic, algorithms, sync model, security model, Watch runtime, or experimental files were modified. This report is the only intended artifact.

### Post-audit remediation status (2026-06-02)

| Item | Audit baseline (`fedf4eb`) | Code after remediation (`8147b3f` → `b48f268`) |
|---|---|---|
| IOS-CCR-P1-001 gas density pressure scaling | Open | **Fixed** — partial-pressure formula in `CCRGasDensityEstimator` |
| IOS-CCR-P1-002 CNS/OTU failure-to-zero | Open | **Fixed** — `CCROxygenExposureState` unavailable semantics |
| IOS-MATH-P2-001 bailout heuristic metadata | Partial | **Fixed** — `CCRBailoutScenarioResult.method/limitations/assumptions` |
| IOS-MATH-P3-001 synthetic `.air` diluent trace | Open | **Fixed** — actual `CCRDiluent` through exposure/trace |

Internal code readiness for the above items is **100%** at `b48f268`. External Bühlmann/CCR/Subsurface validation and physical QA remain **PENDING**. See `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_REPORT_V1.0.md`.

---

## Indice

### Metadati e sintesi

| Sezione | Contenuto |
|---|---|
| [A. Executive Summary](#a-executive-summary) | Verdetto, readiness, blocker TestFlight/App Store |
| [B. Scope Confirmation](#b-scope-confirmation) | Preflight git, target, build/test, documenti sorgente |
| [C. Architecture Inventory](#c-architecture-inventory) | Stack iOS, moduli CCR, quarantena, snapshot test |

### Audit per area algoritmica

| Sezione | Contenuto |
|---|---|
| [D. Bühlmann Core Audit](#d-buhlmann-core-audit) | Costanti, tissue, ceiling, NDL, GF |
| [E. Planner Base / Deco / Technical](#e-planner-base--deco--technical-audit) | Modalità OC, proiezione mode |
| [F. CCR / Rebreather Audit](#f-ccr--rebreather-audit) | Setpoint, density P1, CNS/OTU P1, bailout P2 |
| [G. Ratio Deco Audit](#g-ratio-deco-audit) | Heuristic comparator, blocco CCR |
| [H. Gas Role Audit](#h-gas-role-audit) | Ruoli OC e CCR |
| [I. MOD / PPO2 / Dalton / Switch Depth](#i-mod--ppo2--dalton--switch-depth-audit) | Validazione MOD, clamp switch |
| [J. Emergency / Rock Bottom](#j-emergency--rock-bottom-audit) | Minimum gas, assunzioni |
| [K. Ascent Speed / Runtime / Deco Stops](#k-ascent-speed--dive-runtime--deco-stops-audit) | TTS, stop canonici |
| [L. Schedule-Aware Gas Consumption](#l-schedule-aware-gas-consumption--gas-ledger-audit) | Ledger, consumo per segmento |
| [M. Technical Average-Depth Toggle](#m-technical-average-depth-gas-toggle-audit) | Toggle profondità media |
| [N. Repetitive Dive / Residual Tissue](#n-repetitive-dive--residual-tissue-audit) | Snapshot tessuti |
| [O. Tissue Loading](#o-tissue-loading-audit) | Caricamento N2/He |
| [P. Narcotic Loading](#p-narcotic-loading-audit) | END, PPN2, narcosi |
| [Q. CNS / OTU Audit](#q-cns--otu-audit) | Esposizione ossigeno |
| [R. Planner ↔ Checklist / Equipment](#r-planner-to-checklist--structured-equipment-audit) | Sync gas, equipment strutturato |
| [S. Manual Dive / Logbook](#s-manual-dive--logbook-audit) | Immersioni manuali, logbook |
| [T. PDF / Share / Briefing / CSV](#t-pdf--share--briefing-card--csv--subsurface-audit) | Export, briefing Watch, Subsurface |
| [U. Unit Conversion](#u-unit-conversion-audit) | Metrico/imperiale, pressione |
| [V. Cloud / Sync / Persistence](#v-cloud--sync--persistence-audit) | iCloud, persistenza |
| [W. Test Coverage Audit](#w-test-coverage-audit) | Inventario test, gap |

### Finding CCR prioritari (sezione F)

| ID | Titolo |
|---|---|
| [P1 — Gas density estimator](#p1-issue-ccr-gas-density-estimator) | Densità gas non scalata per pressione |
| [P1 — CNS/OTU failure fallback](#p1-issue-ccr-cnsotu-failure-fallback) | Fallback CNS/OTU a zero |
| [P2 — Bailout scenario model](#p2-issue-ccr-bailout-scenario-model) | Bailout euristico |

### Chiusura audit

| Sezione | Contenuto |
|---|---|
| [X. Release Hard Matrix](#x-release-hard-matrix) | Matrice gate release |
| [Y. Detailed Action Plan](#y-detailed-action-plan) | P0 / P1 / P2 / P3 / P4 |
| [Z. 7-Day / 14-Day Readiness Plan](#z-7-day--14-day-readiness-plan) | Piano 7 e 14 giorni |
| [AA. Recommended Cursor Remediation Commands](#aa-recommended-cursor-remediation-commands) | Bozze comandi Cursor |
| [AB. Final Verdict](#ab-final-verdict) | Verdetto finale e domande gate |

### Piano azioni per priorità (sezione Y)

| Priorità | Focus |
|---|---|
| P0 | Blocker critici immediati |
| P1 | Fix prima TestFlight interno (CCR visibile) |
| P2 | Fix prima TestFlight esterno |
| P3 | Fix prima App Store |
| P4 | Ottimizzazioni post-release |

---

## A. Executive Summary

### Overall verdict

DIR DIVING iOS MAIN contains a mature, non-certified Buhlmann-based reference planner. The open-circuit Buhlmann ZHL-16C implementation is substantially complete for internal validation: 16 N2 and He compartments, mixed-gas tissue loading, GF Low/High, NDL search, multigas runtime/decompression stops, MOD/PPO2 checks, gas-role projection, schedule-aware gas consumption, tissue/narcosis analytics, PDF/share export, CSV round-trip metadata, structured equipment/checklist mapping, and Watch briefing card transfer support are all present.

CCR / Rebreather support is implemented as an iOS-only reference planner with dedicated setpoint/diluent/bailout models, a CCR tissue engine, CCR validation, CCR checklist import/export, CCR PDF, and heuristic bailout scenarios. It remains reference-only and not a CCR controller. **Post-audit remediation (`8147b3f`) closed the two former P1 code defects** (pressure-scaled gas density; CCR CNS/OTU unavailable semantics). See post-audit status table above and `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_REPORT_V1.0.md`.

Physical and external validation gates are still pending: third-party Bühlmann profile comparison, CCR external profile evidence, Subsurface desktop import validation, iCloud two-device QA, paired Watch transfer QA, and App Store/legal copy review.

### Readiness estimates

| Area | Readiness | Confidence | Primary blockers |
|---|---:|---|---|
| Overall iOS algorithm readiness | 84% | Medium-high | CCR P1 fixes, macOS tests, external validation |
| Buhlmann readiness | 92% | High | External reference fixtures pending |
| Planner Base/Deco/Technical readiness | 91% | High | macOS current-HEAD test run pending |
| CCR / Rebreather readiness | 74% | Medium | Gas density, oxygen exposure failure semantics, external CCR evidence |
| Ratio Deco readiness | 84% | Medium-high | Heuristic by design, external reference not applicable |
| MOD/PPO2/Dalton readiness | 91% | High | Need current-HEAD test run |
| Tissue loading readiness | 88% | High | External profile parity pending |
| Narcosis readiness | 83% | Medium-high | CCR density estimator limitation |
| Checklist readiness | 85% | Medium-high | Role inference and paired workflow QA |
| Manual Dive readiness | 86% | Medium-high | Physical/logbook workflow QA |
| PDF/export readiness | 82% | Medium | Render QA and Subsurface desktop validation |
| Unit conversion readiness | 90% | High | macOS tests pending |
| Cloud/sync readiness | 82% | Medium | iCloud two-device and paired Watch QA |
| Test coverage readiness | 86% | High inventory, not executed here | Apple tooling unavailable on Windows |

### Critical blockers

No P0 compile/use blocker was confirmed from static inspection. The current blockers are P1/P2 readiness items, not source-control or branch blockers.

### TestFlight blockers

- P1: CCR gas density pressure scaling must be fixed or explicitly downgraded from threshold classification.
- P1: CCR CNS/OTU exposure failure must not display as zero.
- P2: macOS `xcodegen`, iOS app build, and iOS Algorithm Tests must be run on current HEAD.
- P2: external Buhlmann and CCR validation evidence remains pending.
- P2: paired iPhone/Watch briefing-card transfer QA remains pending.

### App Store blockers

- All TestFlight blockers.
- App Store/legal review for non-certified, reference-only language.
- No certified dive computer, decompression authority, or CCR controller claims.
- External Subsurface import/export regression evidence remains pending.

---

## B. Scope Confirmation

### Git preflight

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `fedf4eb` |
| Remote | `origin https://github.com/egopfe/DirDiving-App.git` |
| Remote alignment after fetch | `main...origin/main = 0 / 0` |
| Working tree before report creation | clean |
| Required branch satisfied | yes |

### Target confirmation

`project.yml` defines:

- `DIRDiving iOS`: iOS application target.
- `DIRDiving Watch App`: Watch application target.
- `DIRDiving iOS Algorithm Tests`: iOS unit-test target.
- `DIRDiving Watch Algorithm Tests`: watchOS unit-test target.

`DIRDiving iOS` source membership includes:

- `Models/PlannerBriefingCard.swift`
- `iOSApp`

The iOS MAIN target explicitly excludes:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

### Build/test status

| Command | Status | Notes |
|---|---|---|
| `xcodegen generate` | Not run | Windows environment, `xcodegen` unavailable |
| iOS app build | Not run | Windows environment, `xcodebuild` unavailable |
| iOS Algorithm Tests | Not run | Windows environment, `xcodebuild` unavailable |
| Static code scan | Completed | `rg`, `git`, and direct file inspection |

### Source context documents

| Document | Status |
|---|---|
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md` | Missing |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md` | Found |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Found |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Found |
| `Docs/DIR_Diving_Planner_Tabs_Implementation_Plan.md` | Found |
| `Docs/DIR_Diving_Planner_Tabs_Implementation_Report.md` | Found |
| `Docs/IOS_PLANNER_LIMITATIONS.md` | Found |
| `Docs/IOS_PLANNER_MOD_SWITCH_DEPTH_AUTOCLAMP_REPORT.md` | Found |
| `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md` | Found |
| `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` | Found |
| `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | Found |
| `Docs/CSV_IMPORT_EXPORT_POLICY.md` | Found |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Found |
| `Docs/RELEASE_CHECKLIST.md` | Found |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Found |
| `Docs/UI_UX_MAIN_AUDIT_CURRENT.md` | Found |
| `Docs/UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md` | Found |

---

## C. Architecture Inventory

| Family | Files | Implemented | Reachable | Tested | Readiness | Notes |
|---|---|---:|---:|---:|---:|---|
| Buhlmann core | `BuhlmannConstants`, `BuhlmannEngine`, `BuhlmannTissueModel`, `BuhlmannGas` | Yes | Yes | Yes | 92% | Real 16 compartment N2+He model |
| Planner modes | `GasPlan`, `PlannerModePolicy`, `PlannerService`, `PlannerStore` | Yes | Yes | Yes | 91% | Base/Deco/Technical/CCR policies present |
| Gas roles | `GasRole`, `PlannerGasSchedule`, `ScheduleGasConsumptionService` | Yes | Yes | Yes | 88% | Bottom/travel/deco/bailout/CCR roles |
| MOD/PPO2/Dalton | `PlannerMODValidator`, `GasMixValidator`, `BuhlmannGas` | Yes | Yes | Yes | 91% | Environment-aware checks present |
| Ratio Deco | `RatioDecoPlanner`, `RatioDecoValidator`, models/views/PDF tests | Yes | Yes | Yes | 84% | Heuristic comparator only |
| Tissue loading | `BuhlmannTissueHistory`, `TissueAnalyticsService`, `CCRTissueHistorySampler` | Yes | Yes | Yes | 88% | Planner/logbook/CCR traces |
| Narcotic loading | `TissueAnalyticsSupport`, `CCRInspiredGasModel`, END/PPN2 tests | Yes | Yes | Yes | 83% | CCR density issue affects confidence |
| CCR/Rebreather | `CCRModels`, `CCRPlannerEngine`, `CCRPlannerService`, `CCRPlanValidator` | Yes | Yes | Yes | 74% | Reference planner, not controller |
| Planner to checklist | `ChecklistPlannerSyncMapper`, CCR import/export coordinators | Yes | Yes | Yes | 85% | Role preservation tested |
| Manual dive | `ManualDiveEditorView`, defaults/validation, logbook math | Yes | Yes | Yes | 86% | Manual CCR metadata exists |
| PDF/share | `PlannerPDFBuilder`, `BriefingPDFBuilder`, `CCRPlannerPDFBuilder`, `DivePackPDFBuilder` | Yes | Yes | Yes | 82% | Render QA pending |
| CSV/Subsurface | `SubsurfaceExportService`, `DiveImportService`, CSV docs/tests | Yes | Yes | Yes | 83% | External Subsurface pending |
| Unit conversion | `IOSUnitConversions`, formatters, pressure unit tests | Yes | Yes | Yes | 90% | Broad coverage |
| Emergency/Rock Bottom | `ScheduleGasConsumptionService`, settings/tests | Yes | Yes | Yes | 82% | Agency policy review pending |
| Transit timing/runtime | `PlannerAscentSpeedSettings`, `PlannerAscentTableBuilder` | Yes | Yes | Yes | 86% | Derived from engine rows |
| Gas ledger/reserve | `GasLedgerDisplayFormatter`, ledger models/tests | Yes | Yes | Yes | 87% | Liters/bar equivalent displayed |
| Repetitive dive | `RepetitiveDivePlannerService`, tissue snapshot tests | Yes | Yes | Yes | 80% | External profile validation pending |
| Structured Equipment | `EquipmentStructuredModels`, mapper/generator/PDF | Yes | Yes | Yes | 84% | Workflow QA pending |
| Briefing card export | `PlannerBriefingCard`, image export, Watch transfer/receiver | Yes | Yes | Yes | 80% | Paired-device QA pending |

Static test inventory:

- iOS Algorithm Tests: 124 Swift files.
- iOS test methods found by `rg "func test"`: 770.
- Watch Algorithm Tests are not in scope except for briefing-card receiving and isolation.

---

## D. Buhlmann Core Audit

### Evidence

`iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift` defines:

- 16 N2 half-times.
- 16 He half-times.
- N2 and He `a`/`b` coefficients.
- water vapor pressure `0.0627 bar`.
- sea-level pressure `1.01325 bar`.
- stop interval `3 m`.
- gas switch duration.

`BuhlmannEngine.swift` implements:

- request/result models;
- validation;
- tissue-state NDL search;
- GF interpolation;
- descent/bottom/ascent segment loading;
- gas switch handling;
- decompression schedule generation from ceilings;
- stop depth rounding;
- calculation limit handling.

`BuhlmannTissueModel.swift` implements constant-depth loading, linear-depth loading, Schreiner-style equation, mixed N2/He coefficient weighting, and ceiling calculation.

### Assessment

The Buhlmann engine is real and model-backed, not a static-table placeholder. Trimix/helium paths are implemented rather than using a N2-only fallback. Tests include constants, pressure model, tissue loading, Schreiner equation, GF, NDL, multigas/trimix, numerical robustness, fixture metadata, and golden fixture execution.

### Gaps

- External third-party validation is still documented as pending.
- macOS test execution was not run in this audit environment.
- Current report depends on static inspection and existing tests, not fresh XCTest results.

---

## E. Planner Base / Deco / Technical Audit

### Base

Evidence: `PlannerModePolicyTests` include Base projection using one bottom gas, excluding hidden deco/bailout cylinders, Base result presentation hiding technical sections, Base no-deco guidance, and altitude/environment rejection.

Readiness: **90%**

### Deco

Evidence: `PlannerModePolicy` and tests show Deco projection allows one deco gas, ignores extra deco gases, provides simplified presentation, and keeps Buhlmann summary limited.

Readiness: **89%**

### Technical

Evidence: Technical preserves all configured gases, supports travel/deco/bailout separation, manual GF, full Buhlmann schedule, tissue charts, gas ledger, emergency/Rock Bottom, average-depth gas toggle, runtime table, and dedicated deco stop section.

Readiness: **92%**

### Mode projection verdict

The mode architecture appears real, not decorative. Presentation builders are correctly secondary to canonical `PlannerService`, `BuhlmannPlanner`, and `BuhlmannEngine` outputs.

---

## F. CCR / Rebreather Audit

### Implemented CCR components

- `CCRPlanInput`, `CCRDiluent`, `CCRBailoutGas`, `CCRSetpointProfile`.
- `CCRPlanValidator`.
- `CCRInspiredGasModel`.
- `CCRPlannerEngine`.
- `CCRTissueHistorySampler`.
- `CCRPlannerService`.
- `CCRBailoutScenarioCalculator`.
- `CCRGasDensityEstimator`.
- `CCRPlannerView`, `CCRPlanResultView`, checklist import/export sheets.
- `CCRPlannerPDFBuilder`.

### Positive findings

- CCR is isolated in iOS; Watch is not a CCR controller.
- Setpoint low/high and switch depth are modeled.
- Diluent gas is modeled and validates O2/He/MOD/hypoxic constraints.
- CCR tissue loading uses setpoint/diluent inspired inert pressures.
- CCR result carries reference-only disclaimers.
- Ratio Deco rejects CCR mode.
- CCR checklist import/export preserves roles.
- CCR PDF includes bailout heuristic wording.

### P1 issue: CCR gas density estimator

**File:** `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`  
**Evidence:** lines 20-23 compute composition-weighted density:

```swift
let o2Fraction = min(1, setpointBar / ambient)
let n2Fraction = inspired.ppN2 / ambient
let heFraction = inspired.ppHe / ambient
return o2Fraction * 1.429 + n2Fraction * 1.251 + heFraction * 0.1786
```

This appears to miss pressure scaling from partial pressures. The value resembles density at 1 bar for the inspired composition, not actual gas density at depth. If threshold colors/warnings use this value, density risk is under-reported.

Priority: **P1 before internal TestFlight if CCR density is visible or classified.**

### P1 issue: CCR CNS/OTU failure fallback

**File:** `iOSApp/Services/CCR/CCRPlannerService.swift`  
**Evidence:** exposure failure branches set `cnsFull = 0`, `otuFull = 0`, and `cnsDB = 0`.

An unavailable oxygen exposure calculation should not be displayed as a safe zero exposure. It should produce an unavailable/error state and warning.

Priority: **P1 before internal TestFlight.**

### P2 issue: CCR bailout scenario model

**File:** `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`  
**Evidence:** bailout gas is estimated using SAC, ascent minutes, optional bottom fraction, and a heuristic deco estimate:

```swift
ceil(startDepth / BuhlmannConstants.stopIntervalMeters) * 3
```

This is acceptable only as a heuristic reserve estimate. It is not a Buhlmann OC bailout schedule generated from CCR tissue state.

Priority: **P2 before external TestFlight unless kept explicitly heuristic.**

### CCR verdict

CCR is implemented and safe to expose only as reference-only after P1 corrections. It is not safe to describe as release-hard CCR bailout/decompression planning until external CCR fixtures and either heuristic disclosure or model-backed bailout simulation are complete.

---

## G. Ratio Deco Audit

Ratio Deco is implemented through `RatioDecoPlanner` and `RatioDecoValidator`. Evidence includes tests for 1:1, 2:1, custom presets, Base rejection, CCR rejection, MOD incompatibility, Buhlmann compatibility, TTS unit parity, and PDF inclusion.

Readiness: **84%**

Blockers:

- It remains heuristic by design.
- It must remain presented as comparative/supporting, not certified decompression math.
- No external Ratio Deco reference campaign is present, which is acceptable if no stronger claim is made.

---

## H. Gas Role Audit

Roles found:

- Bottom/back gas.
- Travel gas.
- Deco gas.
- Bailout gas.
- CCR diluent.
- CCR bailout.

`PlannerGasSchedule`, `BuhlmannPlanner.makeRequest`, `ScheduleGasConsumptionService`, and checklist mappers preserve role separation. Tests confirm bailout is excluded from planned Buhlmann schedule and appears as standby/unused or CCR bailout where appropriate.

Readiness: **88%**

Primary gap: role inference from checklist/free text can always have edge cases; structured roles are preferred.

---

## I. MOD / PPO2 / Dalton / Switch Depth Audit

Evidence:

- `PlannerMODValidator`
- `GasMixValidator`
- `BuhlmannGas.ppO2`
- `BuhlmannGas.modMeters`
- `PlannerSwitchDepthMODClampTests`
- `PressureModelUnificationTests`
- `PPO2DisplayTests`

Findings:

- MOD uses environment-aware pressure.
- Non-bottom gas switch depth clamps to MOD.
- User can choose shallower than MOD.
- Unsafe persisted switch depths are normalized before plan generation.
- Actual over-limit PPO2 is not clipped in display tests.

Readiness: **91%**

No new P1 issue found in OC path.

---

## J. Emergency / Rock Bottom Audit

Evidence:

- `ScheduleGasConsumptionService.rockBottomLiters`.
- `normalizedEmergencyExtraMinutes`.
- `normalizedTeamSize`.
- `PlannerAscentSpeedSettings`.
- `ScheduleGasConsumptionServiceTests`.

Assessment:

Rock Bottom/emergency calculations are deterministic, settings-aware, environment-aware in tests, and isolated from normal planned consumption. The model remains a planning reference and needs expert field-policy review before stronger claims.

Readiness: **82%**

---

## K. Ascent Speed / Dive Runtime / Deco Stops Audit

Evidence:

- `PlannerAscentSpeedSettings`
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- `PlannerAscentTableTests`
- `PlannerPresentationTests`

Assessment:

Runtime rows are presentation builders derived from engine segments. The dedicated deco-stop section uses canonical deco stops rather than raw enum names or heuristic bailout rows. Presentation is not credited as a separate decompression engine.

Readiness: **86%**

---

## L. Schedule-Aware Gas Consumption / Gas Ledger Audit

Evidence:

- `ScheduleGasConsumptionService`
- `GasLedgerDisplayFormatter`
- `GasQuantityMetricTile`
- `GasLedgerDisplayFormatterTests`
- `ScheduleGasConsumptionServiceTests`
- `PlannerTechnicalAverageDepthGasConsumptionTests`

Assessment:

Gas consumption is segment/schedule-aware and distinguishes planned consumed cylinders from unused/bailout roles. Liters and cylinder-equivalent bar display are present. Duplicate gas labels are tested.

Readiness: **87%**

---

## M. Technical Average-Depth Gas Toggle Audit

Evidence:

- `GasPlanInput.useAverageDepthForGasConsumption`
- `GasPlanInput.gasConsumptionReferenceDepthMeters`
- `PlannerAverageDepthPolicyTests`
- `PlannerTechnicalAverageDepthGasConsumptionTests`

Assessment:

The average-depth toggle is limited to Technical gas-consumption estimation. Tests verify decompression sources do not reference the gas-consumption toggle and that Buhlmann/deco remain based on maximum/planned profile depth.

Readiness: **91%**

---

## N. Repetitive Dive / Residual Tissue Audit

Evidence:

- `RepetitiveDivePlannerService`
- `TissueSnapshot`
- `SurfaceIntervalModel`
- tests for canonical engine result, surface interval off-gassing, stale/missing/schema mismatch snapshots.

Assessment:

Residual tissue planning is explicit and fail-closed for invalid/stale/corrupt snapshots. External multi-dive validation remains pending.

Readiness: **80%**

---

## O. Tissue Loading Audit

Evidence:

- `BuhlmannTissueModel`
- `BuhlmannTissueHistorySampler`
- `TissueAnalyticsService`
- `CCRTissueHistorySampler`
- tests for 16 compartments, groups 1-4/5-8/9-12/13-16, controlling compartment, chart source, CCR trace.

Assessment:

Tissue loading is model-backed for planner and CCR. Logbook/manual sessions use recorded replay or explicit simulated/estimated source where full gas history is unavailable.

Readiness: **88%**

---

## P. Narcotic Loading Audit

Evidence:

- `TissueAnalyticsSupport`
- `NarcosisAnalyticsSupport`
- `CCRInspiredGasModel.ppN2Bar`
- `CCRInspiredGasModel.endMeters`
- `TissueAnalyticsServiceTests` for PPN2 and END.

Assessment:

END/PPN2 are real/model-backed for OC and CCR-inspired gas paths. CCR density limitation reduces confidence in density warnings, not necessarily END/PPN2.

Readiness: **83%**

---

## Q. CNS / OTU Audit

Evidence:

- `OxygenExposureModels.swift`
- `OxygenExposureDeepModelTests`
- `OTUCanonicalFixtureTests`
- `CNSDescentBottomTests`
- `CCROxygenExposureIntegration`

Assessment:

The oxygen exposure core is strong: NOAA/Lambertsen-style exposure, CNS/OTU monotonicity, daily/weekly handling, and planner warning copy are tested. The CCR service fallback issue is the main gap.

Readiness: **84%**

P1: replace CCR exposure failure-to-zero behavior with unavailable/warning state.

---

## R. Planner to Checklist / Structured Equipment Audit

Evidence:

- `EquipmentStructuredModels`
- `EquipmentStructuredSupport`
- `EquipmentPlannerMapper`
- `EquipmentChecklistGenerator`
- `ChecklistPlannerSyncMapper`
- `CCRChecklistImportCoordinator`
- `CCRChecklistExportCoordinator`
- `EquipmentSetupPDFBuilder`
- tests for equipment mapping, checklist generator, CCR role preservation, import/export, DIR checklist evaluator.

Assessment:

Planner/checklist integration is mature and mode-aware. Structured data is safer than free text; role inference edge cases should stay documented.

Readiness: **85%**

---

## S. Manual Dive / Logbook Audit

Evidence:

- `ManualDiveEditorView`
- `ManualDiveEditorDefaults`
- `ManualDiveEditorValidation`
- `DiveLogStore`
- `DiveProfileMath`
- `DiveSessionAlgorithmValidator`
- manual dive and sync tests.

Assessment:

Manual dive and logbook derived math are well represented in tests: time-weighted profile math, canonical TTV, invalid depth/temperature/GPS rejection, merge recomputation, and log cap. CCR metadata round-trip exists.

Readiness: **86%**

---

## T. PDF / Share / Briefing Card / CSV / Subsurface Audit

### PDF/share

Evidence:

- `PlannerPDFBuilder`
- `BriefingPDFBuilder`
- `CCRPlannerPDFBuilder`
- `DivePackPDFBuilder`
- `ChecklistPDFBuilder`
- `PDFExportService`
- tests for briefing PDF, CCR PDF fields, Ratio Deco PDF, equipment/checklist PDF.

Readiness: **82%**

### Planner briefing cards / Watch transfer

Evidence:

- `PlannerBriefingCard`
- `PlannerBriefingImageExportService`
- `PlannerBriefingWatchTransferService`
- `PlannerBriefingCardStore`
- `PlannerBriefingWatchReceiver`
- tests for image export, metadata, hash/manifest validation, ACK state.

Readiness: **80%**

Remaining QA: paired iPhone/Watch transfer and stale-card overwrite behavior on real devices.

### CSV/Subsurface

Evidence:

- `SubsurfaceExportService`
- `DiveImportService`
- `CSVMetadataRoundTripTests`
- `SUBSURFACE_CSV_ROUNDTRIP.md`

Readiness: **83%**

External Subsurface desktop regression remains pending.

---

## U. Unit Conversion Audit

Evidence:

- `IOSUnitConversions`
- `PressureDisplayMath`
- planner pressure unit preference tests.
- tests for meters/feet, bar/psi, ambient pressure, altitude, salinity/freshwater, switch depth, gas ledger bar equivalent.

Assessment:

Metric internal storage and display conversion policies are coherent. CCR setpoint remains PPO2 bar rather than tank pressure unit, as expected.

Readiness: **90%**

---

## V. Cloud / Sync / Persistence Audit

Evidence:

- `CloudSyncStore`
- `DiveLogStore`
- `WatchSyncService`
- `WatchDiveSyncCodec`
- `WatchSyncAuth`
- `SyncNonceReplayCache`
- tests for KVS disabled/no account, conflict detection, tombstones, HMAC/signature, duplicate suppression, bounded imported IDs, sync application-context gate.

Assessment:

Sync/data integrity is strong by static inspection. iCloud two-device and paired Watch physical QA remain necessary external gates.

Readiness: **82%**

---

## W. Test Coverage Audit

### Automated inventory

- iOS algorithm test files: 124.
- iOS `func test...` methods found: 770.

### Strong areas

- Buhlmann constants, pressure, tissue, GF, NDL, multigas, trimix.
- Planner modes and projections.
- MOD/PPO2 and switch-depth clamp.
- Schedule gas consumption and Rock Bottom.
- Technical average-depth gas toggle isolation.
- Repetitive tissue snapshots.
- Ratio Deco guardrails.
- CCR planner, CCR remediation, CCR PDF, CCR checklist roles.
- Manual dive/logbook/import/export/sync.
- PDF/share/briefing card metadata.
- Localization/accessibility guard tests.

### Gaps

- Tests were not executed on current HEAD in this Windows environment.
- CCR gas density pressure scaling should get direct numerical tests.
- CCR oxygen exposure failure-to-unavailable behavior needs tests after remediation.
- External Buhlmann and CCR fixture evidence remains pending.
- External Subsurface desktop import validation remains pending.

---

## X. Release Hard Matrix

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Buhlmann | 92% | External reference validation, macOS current tests | P2 |
| Planner Base/Deco/Technical | 91% | macOS current tests | P2 |
| CCR / Rebreather | 74% | Gas density, CNS/OTU fallback, external CCR evidence | P1 |
| Ratio Deco | 84% | Heuristic by design, ongoing wording discipline | P3 |
| Gas Roles | 88% | Free-text checklist inference edge cases | P3 |
| Emergency / Rock Bottom | 82% | Expert policy validation | P2 |
| Ascent / Descent Transit Timing | 86% | Device/user-facing QA | P3 |
| Dive Runtime / Deco Stops | 86% | Visual/render QA | P3 |
| Schedule-Aware Gas Consumption | 87% | External scenario validation | P2 |
| Gas Ledger / Reserve Display | 87% | Bar-equivalent field QA | P3 |
| Technical Average-Depth Gas Toggle | 91% | macOS tests | P2 |
| Repetitive Dive / Residual Tissues | 80% | External multi-dive profile validation | P2 |
| MOD/PPO2/Dalton | 91% | macOS current tests | P2 |
| Switch Depth Clamp | 90% | macOS current tests | P2 |
| Tissue Loading | 88% | External Buhlmann parity | P2 |
| Narcosis | 83% | CCR density limitation | P1/P2 |
| CNS/OTU | 84% | CCR failure fallback | P1 |
| Checklist Sync | 85% | Round-trip real workflow QA | P3 |
| Structured Equipment Mapping | 84% | Equipment profile field QA | P3 |
| CCR Checklist Import / Export | 84% | Role preservation physical workflow QA | P3 |
| CCR Bailout Scenario | 70% | Heuristic not engine-simulated bailout | P2 |
| CCR Gas Density | 58% | Appears not pressure-scaled | P1 |
| Manual Dive | 86% | Physical workflow QA | P3 |
| PDF Export | 82% | Render QA and PDF text checks | P3 |
| Planner Briefing Card / Watch Transfer | 80% | Paired Watch QA | P2 |
| CSV/Subsurface | 83% | External Subsurface validation | P2 |
| Unit Conversion | 90% | macOS tests | P2 |
| Cloud/Sync | 82% | iCloud two-device QA | P2 |
| Test Coverage | 86% | Not executed in this environment | P2 |
| Overall | 84% | CCR P1 fixes, external/macOS validation | P1/P2 |

---

## Y. Detailed Action Plan

### P0

No P0 action identified from static inspection.

### P1 - must fix before internal TestFlight if CCR remains visible

#### IOS-CCR-P1-001 - Pressure-scale CCR gas density

- **Area:** CCR / Rebreather, Narcotic Loading, Gas Density.
- **Files likely involved:** `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`, tests in `Tests/iOSAlgorithmTests`.
- **Description:** Current estimator appears to return composition-density rather than density at pressure.
- **User impact:** Gas density warnings may look safer than reality.
- **Safety impact:** Medium/high for CCR planner interpretation.
- **Implementation order:** Fix estimator, add tests, update docs.
- **Tests required:** air diluent at 10/30/60 m, trimix diluent at 30/60 m, high and low setpoint, invalid input returns unavailable.
- **Acceptance criteria:** density increases with pressure and is lower for helium-rich mixes at same ambient pressure.

#### IOS-CCR-P1-002 - Replace CCR CNS/OTU failure-to-zero

- **Area:** CCR / Oxygen Exposure.
- **Files likely involved:** `CCRPlannerService.swift`, `CCRModels.swift`, `CCRPlanResultView.swift` only if existing warning surface is reused, tests.
- **Description:** Failed exposure integration returns zero values.
- **User impact:** invalid/unavailable exposure may appear safe.
- **Safety impact:** High.
- **Implementation order:** add typed state or warning, suppress safe-looking zero on failure, update tests.
- **Tests required:** invalid segment/setpoint/environment, empty/invalid exposure segments, warning propagation.
- **Acceptance criteria:** no failed exposure path displays 0 CNS/OTU without an unavailable warning.

### P2 - must fix before external TestFlight

#### IOS-EXT-P2-001 - Run macOS build and tests on current HEAD

- **Commands:** `xcodegen generate`, iOS app build, iOS Algorithm Tests.
- **Acceptance criteria:** green build/tests or failure report without source modification.

#### IOS-EXT-P2-002 - External Buhlmann validation

- **Docs:** `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`.
- **Acceptance criteria:** selected reference profiles recorded with tolerance and source metadata.

#### IOS-CCR-P2-003 - External CCR validation

- **Docs:** `Docs/CCR_REBREATHER_VALIDATION_EVIDENCE.md`.
- **Acceptance criteria:** CCR-01 through CCR-04 plus CCR-07 pass or are explicitly waived with rationale.

#### IOS-CCR-P2-004 - Bailout truthfulness

- **Option A:** Keep heuristic and strengthen disclosure/tests.
- **Option B:** Implement model-backed OC bailout schedule from CCR tissue state and bailout gas switches.
- **Acceptance criteria:** no output implies Buhlmann bailout schedule unless generated by model.

#### IOS-EXPORT-P2-005 - External Subsurface validation

- **Docs:** `Docs/SUBSURFACE_CSV_ROUNDTRIP.md`.
- **Acceptance criteria:** export/import verified on Subsurface desktop and evidence recorded.

#### IOS-BRIEF-P2-006 - Paired Watch briefing card QA

- **Files:** Planner briefing export/transfer/receiver.
- **Acceptance criteria:** current plan exports, transfers, imports, rejects stale/invalid packages, displays reference-only.

### P3 - must fix before App Store

- App Store marketing/legal copy review.
- PDF render snapshots for OC and CCR.
- Checklist import/export real workflow QA.
- Role inference edge-case documentation.
- Accessibility/localization re-check after CCR P1 changes.

### P4 - post-release optimization

- Optional model-backed CCR bailout planner.
- Scrubber duration and CO2 warning model, if product scope expands.
- Additional third-party reference fixtures.
- More granular visual snapshot tests.

---

## Z. 7-Day / 14-Day Readiness Plan

### 7-day plan

1. Fix CCR gas density pressure scaling.
2. Fix CCR CNS/OTU failure semantics.
3. Add focused tests for both P1 items.
4. Run macOS `xcodegen`, iOS build, iOS Algorithm Tests.
5. Update this report or add a remediation report with exact test results.
6. Execute quick PDF smoke verification for OC, Technical, CCR.
7. Prepare external validation fixture list and data-capture template.

### 14-day plan

1. Complete Buhlmann external validation sample profiles.
2. Complete CCR external validation evidence CCR-01 through CCR-04 and CCR-07.
3. Complete Subsurface desktop round-trip.
4. Complete paired iPhone/Watch briefing card QA.
5. Complete iCloud two-device sync QA.
6. Run accessibility/localization pass on CCR planner outputs.
7. Final App Store copy/legal review for non-certified wording.

---

## AA. Recommended Cursor Remediation Commands

Do not run these during this audit.

### 1. Buhlmann core validation command

```text
Audit and execute external-reference fixture capture for the iOS-only Buhlmann ZHL-16C engine. Do not modify Watch code. Add only fixture metadata/tests/docs required to record external validation evidence. Preserve reference-only positioning.
```

### 2. CCR / Rebreather hardening command

```text
Fix CCR gas density pressure scaling and CCR CNS/OTU unavailable-state handling in iOS MAIN only. Do not redesign UI. Add deterministic tests and update CCR validation docs. Preserve reference-only CCR positioning.
```

### 3. Ratio Deco remediation command

```text
Re-audit Ratio Deco presentation and API guardrails. Ensure Ratio Deco remains a heuristic comparator and cannot be used in CCR mode or as certified decompression output. Add tests only where gaps exist.
```

### 4. MOD/PPO2/switch-depth remediation command

```text
Run targeted current-HEAD validation for MOD/PPO2/switch-depth normalization across Base, Deco, Technical, export, PDF, checklist and briefing card outputs. Fix only confirmed inconsistencies.
```

### 5. Tissue/Narcosis analytics remediation command

```text
Validate tissue, PPN2, END and gas-density presentation against canonical Buhlmann and CCR engines. Fix source labels and unavailable states without changing UI design.
```

### 6. Checklist/PDF/manual-dive/export remediation command

```text
Run a consistency pass on planner-to-checklist, CCR checklist import/export, manual dive CCR metadata, PDF/export fields, CSV/Subsurface metadata and Watch briefing card values. Preserve all algorithms unless a confirmed mismatch is found.
```

### 7. Unit conversion and test coverage command

```text
Run iOS Algorithm Tests on macOS current HEAD and add missing tests for CCR density, CCR oxygen exposure unavailable states, Subsurface evidence and briefing-card paired transfer.
```

---

## AB. Final Verdict

| Question | Answer |
|---|---|
| Is Buhlmann ready? | Yes for internal reference validation; external validation still pending. |
| Is the Planner ready? | Yes for Base/Deco/Technical internal use; macOS current tests pending. |
| Is CCR implemented, partial, or absent? | Implemented as iOS-only reference planner, not a live CCR controller. |
| Is CCR safe to expose? | Conditional: safe as reference-only after P1 density and CNS/OTU fallback fixes. |
| Is Ratio Deco ready? | Yes as labeled heuristic comparator, not as certified model. |
| Is tissue loading real/model-backed? | Yes. |
| Is narcotic loading real/model-backed? | Mostly yes; CCR gas density needs correction. |
| Are MOD/PPO2 and switch-depth rules consistent? | Yes by static inspection and test inventory. |
| Are manual dives integrated? | Yes, including validation and metadata paths. |
| Are exports reliable? | Internally yes; external Subsurface/render QA pending. |
| Is it safe for internal TestFlight? | Not with CCR exposed until P1 items are fixed or CCR density/exposure sections are hidden/flagged unavailable. |
| Is it safe for external TestFlight? | No, external validation and physical QA pending. |
| Is it ready for App Store? | No, external/physical/legal evidence pending. |
| Are Rock Bottom/emergency calculations conservative and correct? | Deterministic and isolated; expert policy validation pending. |
| Are ascent/descent speeds and runtime totals coherent? | Yes by static inspection and tests. |
| Does the deco-stop section match canonical schedule? | Yes, it derives from plan stops and tests cover separation from runtime rows. |
| Is schedule-aware gas consumption correct by segment and role? | Yes by static inspection and tests; scenario validation pending. |
| Is Technical average-depth toggle isolated to gas estimation? | Yes. |
| Are repetitive-dive residual tissues coherent and explicit? | Yes, with stale/corrupt guards; external multi-dive validation pending. |
| Are gas ledger liters/bar values truthful? | Yes by current architecture; field QA pending. |
| Are structured Equipment mappings safe? | Yes, with role-aware mapping; free-text edge cases remain. |
| Does CCR checklist import/export preserve roles? | Yes by static inspection and test inventory. |
| Are CCR bailout and gas-density estimates traceable? | Bailout is traceable as heuristic; gas density requires P1 correction. |
| Are Planner briefing cards numerically faithful and reference-only? | Architecturally yes; paired-device QA pending. |
| What blocks 100% readiness? | CCR P1 fixes, macOS test execution, external Buhlmann/CCR/Subsurface validation, iCloud/Watch physical QA, App Store legal review. |
| What must be fixed first? | CCR gas density and CCR oxygen exposure failure semantics. |

This audit modified documentation only: `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`.
