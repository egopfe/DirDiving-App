# DIR Diving iOS — Bühlmann Comprehensive Readiness Audit (CCR Updated V3.0)

**Audit date:** 2026-06-19  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `c120771` (`Remediate iOS MAIN algorithm math findings to 100% software readiness.`)  
**Scope:** iOS Companion MAIN target `DIRDiving iOS` + Shared Bühlmann core consumed by iOS Planner and Watch Full Computer (read-only cross-reference)  
**Task type:** deep audit only — **no production code modified**  
**Command source:** `commands_for_cursor/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md`

**Supersedes:** V2.0 report @ `fedf4eb` and interim updates through `8147b3f`. This V3.0 pass re-audits `main` after Command 0 math audit (`ddb1a5f`) and math remediation (`c120771`).

---

## Indice

| Sezione | Contenuto |
|---|---|
| [A. Executive Summary](#a-executive-summary) | Verdetto, readiness, blocker |
| [B. Scope Confirmation](#b-scope-confirmation) | Preflight, build/test, docs |
| [C. Architecture Inventory](#c-architecture-inventory) | Stack, famiglie, test |
| [D–V. Area Audits](#d-buhlmann-core-audit) | Bühlmann → Sync |
| [W. Test Coverage](#w-test-coverage-audit) | Matrice test |
| [X. Release Hard Matrix](#x-release-hard-matrix) | Gate release |
| [Y. Action Plan](#y-detailed-action-plan) | P0–P4 |
| [Z. 7/14-Day Plan](#z-7-day--14-day-readiness-plan) | Roadmap |
| [AA. Future Commands](#aa-recommended-cursor-remediation-commands) | Bozze |
| [AB. Final Verdict](#ab-final-verdict) | Domande gate |

---

## A. Executive Summary

### Overall verdict

DIR DIVING iOS MAIN contains a **mature, non-certified Bühlmann ZH-L16C reference planner** with Base / Deco / Technical open-circuit modes and a **reference-only CCR / Rebreather planner**. Shared `BuhlmannCore` implements 16 N2/He compartments, Schreiner loading, GF Low/High, NDL, multilevel runtime, decompression stops, gas-switch ordering, and environment-aware pressure. iOS layers add schedule-aware gas consumption, rock bottom, gas ledger, repetitive-dive tissue seeding, tissue/narcosis analytics, CNS/OTU, structured equipment/checklist mapping, PDF/share/briefing export, and Watch transfer.

**Software-verifiable readiness is high.** Prior CCR P1 defects (gas density scaling, CNS/OTU unavailable semantics) remain **closed**. Post-audit math remediation @ `c120771` closed Apnea recovery desync, OC descent+bottom CNS unavailable coercion, and archived legacy `ExplorationStore`.

**External and physical gates remain open:** third-party Bühlmann profile evidence, CCR external validation, PDF render QA, Subsurface desktop import, iCloud two-device QA, paired Watch transfer QA, App Store/legal copy review.

### Readiness estimates (internal software + documented gates)

| Area | Readiness | Confidence | Primary blockers |
|---|---:|---|---|
| **Overall iOS algorithm readiness** | **92%** | High | External validation; 13 unrelated Snorkeling l10n test-host failures |
| Bühlmann readiness | 95% | High | External reference fixtures PENDING |
| Planner Base/Deco/Technical | 94% | High | External Bühlmann evidence |
| CCR / Rebreather | 90% | High | External CCR evidence; heuristic bailout by design |
| Ratio Deco | 86% | Medium-high | Heuristic by design; external simulator PENDING |
| MOD/PPO2/Dalton | 94% | High | — |
| Switch depth clamp | 93% | High | — |
| Emergency / Rock Bottom | 92% | High | Physical workflow QA |
| Ascent / transit / runtime | 93% | High | — |
| Schedule-aware gas consumption | 93% | High | — |
| Gas ledger / reserve display | 91% | High | Formatter edge tests expanded @ c120771 |
| Technical average-depth toggle | 94% | High | Isolated to gas estimate |
| Repetitive dive / residual tissue | 92% | High | Golden tests added @ c120771 |
| Tissue loading analytics | 90% | High | Logbook replay not full Bühlmann |
| Narcosis / END | 89% | Medium-high | CCR density presentation separate from OC |
| CNS / OTU | 93% | High | OC unavailable state fixed @ c120771 |
| Checklist sync | 88% | Medium-high | Paired workflow QA |
| Structured equipment | 87% | Medium-high | Role inference QA |
| CCR checklist import/export | 88% | Medium-high | Round-trip tests present |
| Manual dive / logbook | 88% | Medium-high | Physical logbook QA |
| PDF / export / briefing | 85% | Medium | Physical render QA PENDING |
| CSV / Subsurface | 84% | Medium | Desktop import PENDING |
| Unit conversion | 93% | High | — |
| Cloud / sync | 86% | Medium | Two-device QA PENDING |
| Test coverage (inventory) | 91% | High | Snorkeling l10n test bundle gap |

### Critical blockers

| Priority | Blocker | Status |
|---|---|---|
| — | No P0 compile/runtime Bühlmann or CCR defect identified | — |
| External | Bühlmann third-party profile comparison | **PENDING** |
| External | CCR external reference evidence | **PENDING** |
| Physical | PDF render / share sheet QA | **PENDING** |
| Physical | Subsurface desktop import validation | **PENDING** |
| Physical | iCloud two-device + paired Watch QA | **PENDING** |

### TestFlight / App Store

| Gate | Verdict |
|---|---|
| Internal TestFlight (software) | **CONDITIONAL GO** — reference-only disclaimers required |
| External TestFlight | **NO-GO** until external Bühlmann/CCR evidence + PDF QA |
| App Store | **NO-GO** until physical QA + legal/certification review |

---

## B. Scope Confirmation

### Product architecture (V3.0)

```text
DIR Diving
├── Diving (Gauge + Full Computer)
├── Apnea
└── Snorkeling
```

This audit focuses on **Diving / Planner / Bühlmann / CCR** on iOS. Apnea and Snorkeling math isolation verified via prior Command 0 audit; not re-expanded here except where shared settings/sync could affect Diving payloads.

### Preflight

| Check | Result |
|---|---|
| Branch | `main` ✓ |
| HEAD | `c120771` |
| Working tree | Clean at audit start |
| Remote | `main...origin/main` aligned |
| iOS target | `DIRDiving iOS` confirmed in `project.yml` |
| Experimental exclusions | Confirmed (see below) |
| `./Scripts/check_main_target_isolation.sh` | **PASS** |
| `./Scripts/check_secrets.sh` | **PASS** |

### Build / test commands executed

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
# 1298 executed, 28 skipped, 13 failed (~110s)

# Focused Bühlmann/CCR suites (same session):
# BuhlmannComprehensiveReadinessCCRRemediationTests + CCRMathAuditRemediationV1Tests
# + CCRPlannerTests + BuhlmannGoldenFixtureTests → ** TEST SUCCEEDED **
```

### Test failure summary (full suite)

All **13 failures** are in **Snorkeling Watch presentation/localization tests** running under the iOS Algorithm Tests host (`SnorkelingLocalizationParityTests`, `SnorkelingWatchPresentationTests`). Keys exist in `Resources/en.lproj/Localizable.strings` but `String(localized:)` in the test bundle returns raw keys. **Not a Bühlmann/CCR/Planner regression.** Tracked as **IOS-BUH-P2-001**.

### iOS experimental exclusions (confirmed in `project.yml`)

| Path | On disk | In MAIN target |
|---|---|---|
| `iOSApp/Models/ExplorationModels.swift` | Yes | Excluded |
| `iOSApp/Models/BuddyExperimentalModels.swift` | Yes | Excluded |
| `iOSApp/Services/ExplorationPlanningStore.swift` | Yes | Excluded |
| `iOSApp/Services/BuddyExperimentalStore.swift` | Yes | Excluded |
| `iOSApp/Views/ExplorationCenterView.swift` | Yes | Excluded |
| `iOSApp/Views/ExperimentalFutureConceptsView.swift` | Yes | Excluded |
| `iOSApp/Views/BuddyExperimentalView.swift` | Yes | Excluded |

### Documentation found / missing

| Document | Status |
|---|---|
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Found (Command 0 @ ddb1a5f, updated post-remediation) |
| `Docs/IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md` | Found (@ c120771) |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_REPORT_V1.0.md` | Found (CCR P1 fixes) |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md` | Found (prior V3 pass) |
| `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md` | Template only — **PENDING** |
| `Docs/QA_EVIDENCE/CCR_EXTERNAL/README.md` | Template only — **PENDING** |
| `Docs/QA_EVIDENCE/PDF_RENDER/README.md` | Template only — **PENDING** |
| `Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/README.md` | Template only — **PENDING** |

---

## C. Architecture Inventory

| Family | Key files | Implemented | Reachable | Tested | Readiness | Notes |
|---|---|---:|---:|---:|---:|---|
| Bühlmann core | `Shared/BuhlmannCore/*`, `iOSApp/Services/BuhlmannPlanner.swift` | Yes | Yes | Yes (24 suites) | 95% | Shared with Watch Full Computer |
| Planner modes | `PlannerModePolicy`, `PlannerView`, `PlannerService` | Yes | Yes | Yes | 94% | Base/Deco/Technical + CCR entry |
| CCR / Rebreather | `iOSApp/Services/CCR/*`, `iOSApp/Views/CCR/*` | Yes | Yes | Yes (5+ suites) | 90% | Reference-only |
| Ratio Deco | `RatioDecoPlanner`, `RatioDecoValidator` | Yes | Yes | Partial | 86% | Comparator heuristic |
| Gas roles | `GasRole`, `PlannerGasSchedule`, equipment mappers | Yes | Yes | Partial | 91% | OC + CCR diluent/bailout |
| MOD/PPO2/Dalton | `PlannerMODValidator`, `GasMixValidator`, `CCRMODTolerancePolicy` | Yes | Yes | Yes | 94% | Fail-closed validation |
| Rock Bottom | `ScheduleGasConsumptionService`, `GasPlanningService` | Yes | Yes | Yes | 92% | Schedule-aware ascent |
| Ascent/runtime/deco stops | `PlannerAscentTableBuilder`, `DecoStopsPresentationBuilder` | Yes | Yes | Yes | 93% | Presentation separated from physics |
| Schedule gas / ledger | `ScheduleGasConsumptionService`, `GasLedgerDisplayFormatter` | Yes | Yes | Yes | 93% | Liters canonical |
| Repetitive dive | `RepetitiveDivePlannerService` | Yes | Yes | Yes | 92% | Staleness boundary tested |
| Tissue loading | `TissueAnalyticsService`, charts | Yes | Yes | Yes | 90% | Logbook replay simulated |
| Narcosis / END | `TissueAnalyticsService`, gas density | Yes | Yes | Partial | 89% | CCR density separate path |
| CNS / OTU | `OxygenExposureModels`, `GasPlanningService`, `CCROxygenExposureState` | Yes | Yes | Yes | 93% | Unavailable ≠ zero |
| Checklist / equipment | `EquipmentStore`, PDF builders, CCR coordinators | Yes | Yes | Yes | 88% | Structured + legacy |
| Manual dive / logbook | `ManualDiveEditorView`, `DiveLogStore`, import/export | Yes | Yes | Partial | 88% | |
| PDF / briefing / share | `PDFExportService`, `BriefingPDFBuilder`, Watch transfer | Yes | Yes | Partial | 85% | Render QA pending |
| CSV / Subsurface | `SubsurfaceExportService`, metadata tests | Yes | Yes | Partial | 84% | Desktop QA pending |
| Unit conversion | `IOSUnitConversions`, `Formatters`, `DIRUnitConversions` | Yes | Yes | Yes | 93% | Metric canonical |
| Cloud / sync | `CloudSyncStore`, `WatchSyncService`, codecs | Yes | Yes | Partial | 86% | Two-device QA pending |

---

## D. Bühlmann Core Audit

**Verdict: PASS (software) — external reference PENDING**

| Requirement | Evidence | Status |
|---|---|---|
| ZH-L16C 16 N2 + 16 He compartments | `Shared/BuhlmannCore/BuhlmannTissueModel.swift`, `BuhlmannConstants.swift` | PASS |
| Schreiner integration | `BuhlmannSchreinerEquationTests`, `BuhlmannTissueLoadingTests` | PASS |
| GF Low/High ceiling | `BuhlmannGradientFactorTests`, `BuhlmannCeilingTests` | PASS |
| NDL search | `BuhlmannNDLTests`, golden fixtures | PASS |
| Multilevel continuity | `BuhlmannMultigasPlannerTests`, `BuhlmannGoldenFixtureTests` | PASS |
| Decompression schedule | `BuhlmannEngine`, `DecoStopsPresentationBuilder` | PASS |
| Environment (altitude/salinity) | `PlannerEnvironment`, `BuhlmannPressureModelTests` | PASS |
| External reference parity | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` | **PENDING** |

No false clearing of decompression observed in code review. Stale-result rejection and fail-closed patterns present in engine and planner store paths.

---

## E. Planner Base / Deco / Technical Audit

**Verdict: PASS (software)**

- `PlannerModePolicy` projects mode-specific inputs; Base restricts deco, Technical enables full gas schedule.
- `PlannerInputValidator` + `PlanCalculationCompleteness` gate partial/invalid plans.
- `PlannerView` surfaces reference-only disclaimers and mode-correct tiles.
- MOD/switch-depth auto-clamp policy preserved (`PlannerSwitchDepthMODClampTests`).
- CNS descent+bottom tile uses `cnsDescentBottomPercentDisplay` with availability flag (@ c120771).

---

## F. CCR / Rebreather Audit

**Verdict: IMPLEMENTED — reference-only — external validation PENDING**

| Component | File | Status |
|---|---|---|
| Setpoint / inspired gas | `CCRInspiredGasModel.swift` | PASS |
| Tissue engine | `CCRPlannerEngine.swift` | PASS |
| Validation | `CCRPlanValidator.swift` | PASS |
| Gas density | `CCRGasDensityEstimator.swift` | PASS (P1 fixed) |
| Oxygen exposure | `CCROxygenExposureState.swift` | PASS (P1 fixed) |
| Bailout heuristic | `CCRBailoutScenarioCalculator.swift` | PASS (metadata disclosed) |
| UI | `CCRPlannerView.swift`, `PlannerRootView.swift` | PASS |
| PDF | `CCRPlannerPDFBuilder.swift` | PASS (render QA pending) |
| Checklist I/E | `CCRChecklistImportCoordinator`, export coordinator | PASS |

**Closed findings:** IOS-CCR-P1-001, IOS-CCR-P1-002, IOS-MATH-P2-001, IOS-MATH-P3-001 (@ 8147b3f / verified by `CCRMathAuditRemediationV1Tests`).

**Open:** IOS-CCR-P2-003 external CCR validation evidence.

CCR is **not safe to expose as a controller** — reference planner only per `Docs/CCR_REBREATHER_LIMITATIONS.md`.

---

## G. Ratio Deco Audit

**Verdict: PASS (heuristic scope)**

- `RatioDecoPlanner` + `RatioDecoValidator` provide comparator-only heuristic; blocked for CCR mode.
- `RatioDecoPlannerTests` cover validation paths.
- External simulator evidence: **PENDING** (`Docs/QA_EVIDENCE/RATIO_DECO_SIMULATOR/`).

---

## H. Gas Role Audit

**Verdict: PASS**

- `GasRole` distinguishes bottom/travel/deco/bailout/ccrDiluent/ccrBailout.
- `PlannerGasSchedule` orders switches; equipment mapper preserves roles through checklist sync.
- CCR diluent/bailout remain separate in ledger and exposure traces.

---

## I. MOD / PPO2 / Dalton / Switch Depth Audit

**Verdict: PASS**

- `PlannerMODValidator` + `GasMixValidator` enforce limits with tolerance constants.
- Switch-depth auto-clamp prevents MOD violations on gas changes.
- CCR MOD tolerance policy separate but consistent (`CCRMODTolerancePolicy`).
- Tests: `PlannerSwitchDepthMODClampTests`, `PPO2DisplayTests`, `PlannerBaseMODUXTests`.

---

## J. Emergency / Rock Bottom Audit

**Verdict: PASS (software)**

- Rock bottom computed in `ScheduleGasConsumptionService` using schedule-aware ascent/transit minutes + emergency SAC.
- Surfaced in `TechnicalGasAnalysis.rockBottomLiters` / `minimumGasBar`.
- Contingency warnings (`ContingencyEngineTests`) for reserve/minimum gas breaches.

---

## K. Ascent Speed / Dive Runtime / Deco Stops Audit

**Verdict: PASS**

- `PlannerAscentSpeedSettings` persisted; feeds transit minute projection.
- `PlannerAscentTableBuilder` + `DecoStopsPresentationBuilder` build runtime/deco-stop presentation from canonical engine segments.
- Stop-state separated from tissue physics (audit-15 policy preserved on Watch consumer).

---

## L. Schedule-Aware Gas Consumption / Gas Ledger Audit

**Verdict: PASS**

- `ScheduleGasConsumptionService` aggregates by segment and role; warnings for reserve/minimum/lost-gas contingency.
- `GasLedgerDisplayFormatter` presents liters primary, bar/PSI secondary; cylinder-specific pressure equivalence.
- Tests expanded @ c120771 (`GasLedgerDisplayFormatterTests`).

---

## M. Technical Average-Depth Gas Toggle Audit

**Verdict: PASS**

- Toggle affects gas consumption reference depth only (`PlannerTechnicalAverageDepthGasConsumptionTests`).
- Does not alter Bühlmann planning depth or tissue loading depth.

---

## N. Repetitive Dive / Residual Tissue Audit

**Verdict: PASS**

- `RepetitiveDivePlannerService` snapshots tissue + optional oxygen carryover; 14-day staleness policy.
- Missing snapshot fails closed (no silent fresh tissues).
- `RepetitiveDiveMathematicalTests` added @ c120771.

---

## O. Tissue Loading Audit

**Verdict: PASS (analytics) — logbook replay limitation noted**

- `TissueAnalyticsService` charts compartment loading from planner/logbook inputs.
- Logbook replay uses simplified replay path (**IOS-BUH-P2-002**) — not full Bühlmann re-simulation.

---

## P. Narcotic Loading Audit

**Verdict: PASS**

- END/EAD/PPN2 from gas mix and depth; CCR gas density uses dedicated estimator.
- Presentation distinguishes reference-only analytics.

---

## Q. CNS / OTU Audit

**Verdict: PASS**

- OC: `OxygenExposureModels` + `GasPlanningService`; `cnsDescentBottomAvailable` distinguishes valid zero vs unavailable (@ c120771).
- CCR: `CCROxygenExposureState` unavailable semantics; PDF export gating.
- Tests: `CNSDescentBottomTests`, `CCRMathAuditRemediationV1Tests`, `GasPlanningOxygenExposureUnavailableTests`.

---

## R. Planner ↔ Checklist / Structured Equipment Audit

**Verdict: PASS (software)**

- `EquipmentPlannerMapper`, `ChecklistPlannerSyncMapper`, structured models round-trip gases and CCR metadata.
- `ChecklistPlannerSyncMapperTests`, `EquipmentPlannerMapperTests`, CCR checklist coordinators tested.

---

## S. Manual Dive / Logbook Audit

**Verdict: PASS (software)**

- `ManualDiveEditorView` + `ManualDiveEditorLogicTests`; integrates with logbook store and analytics.
- Import/export paths guarded; no Bühlmann auto-deco from manual entries unless explicitly planned.

---

## T. PDF / Share / Briefing Card / CSV / Subsurface Audit

**Verdict: CONDITIONAL PASS — physical QA PENDING**

- PDF builders gate on completeness (`PDFExportGate`); CCR unavailable exposure not rendered as zero.
- Briefing card + Watch transfer services present; numerical fidelity tests in `CCRPlannerBriefingExportTests`.
- Subsurface CSV metadata round-trip tested; **desktop import not executed** this pass.

---

## U. Unit Conversion Audit

**Verdict: PASS**

- Metric canonical storage; imperial presentation via `Formatters` / `IOSUnitConversions`.
- Pressure display math isolated (`PressureDisplayMath`).

---

## V. Cloud / Sync / Persistence Audit

**Verdict: CONDITIONAL PASS — two-device QA PENDING**

- Tombstone/conflict policy in sync codecs; activity-isolated payload keys (Apnea/Snorkeling/Diving separated).
- Tests: `CloudSyncStoreLoadTests`, `WatchSyncServiceIntegrationTests`, `WatchSyncConflictTests`.

---

## W. Test Coverage Audit

| Category | iOS test files (approx.) | Executed this pass | Failures |
|---|---|---:|---|
| Bühlmann | 24 | Yes | 0 |
| CCR | 6 | Yes | 0 |
| Gas planning / CNS / OTU | 10+ | Yes | 0 |
| Ratio Deco | 1 | Yes | 0 |
| Repetitive dive | 1+ | Yes | 0 |
| PDF / export | 3+ | Yes | 0 |
| Equipment / checklist | 9+ | Yes | 0 |
| Snorkeling (in iOS host) | 4+ | Yes | **13** (bundle l10n) |
| **Full suite** | — | **1298** | **13** |

**Gap:** Snorkeling localization tests need Watch bundle in test host or move to Watch scheme (**IOS-BUH-P2-001**).

---

## X. Release Hard Matrix

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | 95% | External reference PENDING | P2 |
| Planner Base/Deco/Technical | 94% | External Bühlmann | P2 |
| CCR / Rebreather | 90% | External CCR evidence | P2 |
| Ratio Deco | 86% | External simulator PENDING | P3 |
| Gas Roles | 91% | — | — |
| Emergency / Rock Bottom | 92% | Physical QA | P3 |
| Ascent / Descent Transit Timing | 93% | — | — |
| Dive Runtime / Deco Stops | 93% | — | — |
| Schedule-Aware Gas Consumption | 93% | — | — |
| Gas Ledger / Reserve Display | 91% | — | — |
| Technical Average-Depth Gas Toggle | 94% | — | — |
| Repetitive Dive / Residual Tissues | 92% | — | — |
| MOD/PPO2/Dalton | 94% | — | — |
| Switch Depth Clamp | 93% | — | — |
| Tissue Loading | 90% | Logbook replay simulated | P2 |
| Narcosis | 89% | — | — |
| CNS/OTU | 93% | — | — |
| Checklist Sync | 88% | Paired QA | P3 |
| Structured Equipment Mapping | 87% | — | — |
| CCR Checklist Import / Export | 88% | — | — |
| CCR Bailout Scenario | 88% | Heuristic by design | INFO |
| CCR Gas Density | 92% | — | — |
| Manual Dive | 88% | Physical QA | P3 |
| PDF Export | 85% | Render QA PENDING | P2 |
| Planner Briefing Card / Watch Transfer | 86% | Device QA PENDING | P2 |
| CSV/Subsurface | 84% | Desktop QA PENDING | P2 |
| Unit Conversion | 93% | — | — |
| Cloud/Sync | 86% | Two-device QA | P2 |
| **Overall** | **92%** | External + physical gates | — |

---

## Y. Detailed Action Plan

### P0 — none identified

No compile blockers or safety-critical Bühlmann/CCR code defects open on `main`.

### P1 — before external TestFlight messaging

| ID | Title | Files | Effort | Tests |
|---|---|---|---|---|
| — | (none open) | — | — | CCR P1 closed |

### P2 — before external TestFlight / broad beta

| ID | Title | Area | Action |
|---|---|---|---|
| IOS-BUH-P2-001 | Snorkeling l10n tests fail in iOS host | Tests | Load Watch `Resources` in test bundle or relocate suites to Watch target |
| IOS-BUH-P2-002 | Logbook tissue replay not Bühlmann-backed | Tissue | Document limitation or add optional full replay (future) |
| IOS-BUH-P2-003 | External Bühlmann validation | External QA | Populate `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` |
| IOS-CCR-P2-003 | External CCR validation | External QA | Populate `Docs/QA_EVIDENCE/CCR_EXTERNAL/` |
| IOS-BUH-P2-004 | PDF render QA | Physical QA | Populate `Docs/QA_EVIDENCE/PDF_RENDER/` |
| IOS-BUH-P2-005 | Subsurface desktop import | External QA | Execute CSV round-trip on Subsurface desktop |

### P3 — before App Store

| ID | Title | Area |
|---|---|---|
| IOS-BUH-P3-001 | GF Low == GF High policy UX | Planner |
| IOS-BUH-P3-002 | Briefing TTS/TTR copy polish | Briefing |
| IOS-BUH-P3-003 | Tissue chart sea-level fallback label | Analytics |
| IOS-BUH-P3-004 | `project.yml` stale `ExplorationStore.swift` exclude path | Docs/config |

### P4 — post-release

- Ratio Deco screenshot/regression gallery
- Checklist PDF unit presentation polish
- Manual dive trapezoid profile enhancement

---

## Z. 7-Day / 14-Day Readiness Plan

### 7 days (software + evidence scaffolding)

1. Fix **IOS-BUH-P2-001** test host localization (Snorkeling suites).
2. Populate Bühlmann + CCR external evidence templates with first profile runs.
3. Physical PDF render pass on representative OC + CCR plans.
4. Re-run `./Scripts/validate_ios_main_algorithm_math_readiness.sh` + full iOS suite.

### 14 days (external beta readiness)

1. Complete Bühlmann external comparison (≥3 profiles).
2. Complete CCR external comparison (setpoint + bailout scenarios).
3. Subsurface desktop import of exported CSV.
4. iCloud two-device + Watch briefing transfer QA.
5. Legal/copy review for reference-only positioning.

---

## AA. Recommended Cursor Remediation Commands

Draft only — **do not execute during this audit:**

1. `commands_for_cursor/…-BUHLMANN_EXTERNAL_EVIDENCE_CAMPAIGN.md`
2. `commands_for_cursor/…-CCR_EXTERNAL_EVIDENCE_CAMPAIGN.md`
3. `commands_for_cursor/…-PDF_RENDER_PHYSICAL_QA.md`
4. `commands_for_cursor/…-SNORKELING_L10N_TEST_HOST_FIX.md`
5. `commands_for_cursor/…-LOGBOOK_TISSUE_BUHLMANN_REPLAY.md` (optional)

---

## AB. Final Verdict

| Question | Answer |
|---|---|
| Is Bühlmann ready (software)? | **Yes** — 95% internal; external reference PENDING |
| Is the Planner ready (software)? | **Yes** — 94%; reference-only disclaimers in place |
| Is CCR implemented? | **Yes** — partial/reference planner, not controller |
| Is CCR safe to expose? | **As reference-only** — not as dive computer replacement |
| Is Ratio Deco ready? | **Yes** within heuristic scope |
| Is tissue loading model-backed? | **Yes** in planner; logbook replay simplified |
| Is narcotic loading model-backed? | **Yes** for OC; CCR uses dedicated density path |
| MOD/PPO2/switch-depth consistent? | **Yes** |
| Manual dives integrated? | **Yes** |
| Exports reliable (software)? | **Yes** — render/desktop QA PENDING |
| Internal TestFlight safe? | **Conditional GO** with reference-only labeling |
| External TestFlight safe? | **NO-GO** until P2 external/physical gates |
| App Store ready? | **NO-GO** |
| Rock Bottom conservative? | **Yes** — schedule-aware, tested |
| Ascent/runtime/deco coherent? | **Yes** |
| Deco-stop section matches schedule? | **Yes** (presentation builder) |
| Schedule gas consumption correct? | **Yes** by segment/role |
| Technical avg-depth toggle isolated? | **Yes** |
| Repetitive tissues explicit? | **Yes** — fail-closed on missing/stale |
| Gas ledger truthful? | **Yes** — liters canonical |
| Equipment mappings safe? | **Yes** — tested mappers |
| CCR checklist I/E preserves roles? | **Yes** — coordinator tests |
| CCR bailout/density traceable? | **Yes** — metadata + unavailable states |
| Briefing cards faithful? | **Yes** (software) — device QA PENDING |
| What blocks 100%? | External Bühlmann/CCR/PDF/Subsurface/device QA; Snorkeling l10n test infra |
| Fix first? | External evidence campaigns + IOS-BUH-P2-001 test host |

---

**Audit artifact:** this file only. No production source modified.  
**Next inspection:** populate `Docs/QA_EVIDENCE/*` and re-run full iOS suite after IOS-BUH-P2-001 fix.
