# iOS MAIN Algorithm Math Audit — Remediation Report

**Remediation date:** 2026-06-08  
**Branch:** `main`  
**Starting commit:** `8e5b6a6` — docs: refresh iOS main algorithm math audit with CCR coverage  
**Ending state:** working tree (uncommitted remediation)  
**Primary target:** DIRDiving iOS  
**Secondary target:** Apple Watch — build-only verification; no runtime changes  
**Source audit:** `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` (baseline `b9f54a3`, 87% readiness)

---

## Scope confirmation

| Check | Result |
|---|---|
| Branch | `main` only |
| Experimental branches | Not modified |
| Watch runtime semantics | Unchanged |
| UI redesign | Not performed |
| Certified claims | Not introduced |
| External validation faked | No |

---

## Issues fixed by ID

### P1

| ID | Fix | Policy |
|---|---|---|
| **P1-001** | Added `CCRTissueHistorySampler`; `CCRPlannerEngine` now emits CCR tissue history from `ccrLoaded*` replay, not OC `BuhlmannTissueHistorySampler` | Option A — engine-aligned trace |
| **P1-002** | Documented `CCRSetpointProfile.runtimeSegments` as reserved/inactive; test proves segments do not alter output | Option B — quarantine |
| **P1-003** | Bailout calculator remains SAC heuristic; PDF/UI copy hardened to “heuristic reserve estimate”, not Bühlmann schedule | Option B — truthful heuristic |
| **P1-004** | CCR inspired inert gas now subtracts `BuhlmannConstants.waterVaporPressureBar` before setpoint allocation | Aligned with OC dry-gas assumption |
| **P1-005** | Manual dive CCR switch depth uses `ManualDiveEditorDefaults.depthMeters` / display round-trip like max/avg depth | Metric internal storage preserved |
| **P1-006** | `RatioDecoPlanner`, `RatioDecoValidator`, `PlannerService.makeRatioDecoBundle` reject `.ccr` at API level | Typed rejection via `.unavailableInCCRMode` |

### P2

| ID | Fix |
|---|---|
| **P2-002** | `CCRMathRemediationTests` + PDF builder localized bailout status |
| **P2-003** | `PDFExportService.canExportCCRPlan` blocks `.unavailable` |
| **P2-004** | CSV round-trip asserts setpoint switch depth; existing CCR metadata test extended |
| **P2-005 / P2-006** | Added `GasRole.ccrDiluent` / `.ccrBailout`; CCR template + `ChecklistPlannerSyncMapper.applyCCRExport` |
| **P2-007** | CCR PDF uses `CCRBailoutScenarioStatus.localizedTitle`, not `rawValue` |
| **P2-008 / P2-010** | `ManualDiveEditorValidation.ccrMetadataError`; `DiveDetailView` CCR logbook panel |
| **P2-009** | `CCRPlanInput` JSON round-trip test |
| **P2-011** | Average depth labeled reference-only in `CCRPlannerView` | Option B |
| **P2-012** | `PlannerService.makePlan` calls `PlannerModeLimits.enforceInputLimits` | Option A |

### P3

| ID | Fix |
|---|---|
| **P3-001** | GF validation uses `CCRPlanIssue.invalidGradientFactor` |
| **P3-002** | IT strings for CCR bailout scenarios, controller, wet notes |
| **P3-003** | END split documented in audit; tissue analytics remains ppN2-only END with existing footnotes |
| **P3-004** | External validation gates documented (pending) — see below |

### Not implemented (documented blockers)

| ID | Reason |
|---|---|
| P2-001 | CCR Dive Pack PDF — out of scope for math remediation pass; OC Dive Pack unchanged |
| P1-003 Option A | Full OC bailout switch simulation deferred — requires larger Bühlmann handoff architecture |

---

## Files modified (summary)

**New:** `iOSApp/Services/CCR/CCRTissueHistorySampler.swift`, `Tests/iOSAlgorithmTests/CCRMathRemediationTests.swift`

**Core math:** `CCRPlannerEngine.swift`, `CCRInspiredGasModel.swift`, `CCRBailoutScenarioCalculator.swift`, `CCRPlanValidator.swift`, `CCRModels.swift`, `RatioDecoPlanner.swift`, `RatioDecoValidator.swift`, `PlannerService.swift`, `PDFExportService.swift`, `CCRPlannerPDFBuilder.swift`

**Logbook / UI truthfulness:** `ManualDiveEditorView.swift`, `ManualDiveEditorDefaults.swift`, `ManualDiveEditorValidation.swift`, `DiveDetailView.swift`, `CCRPlannerView.swift`

**Checklist / roles:** `GasPlan.swift`, `EquipmentStore.swift`, `ChecklistPlannerSyncMapper.swift`, supporting MOD/gas switches

**Tests / project:** `project.yml`, `ManualDiveEditorLogicTests.swift`, `CSVMetadataRoundTripTests.swift`

---

## Tests

### Added

`Tests/iOSAlgorithmTests/CCRMathRemediationTests.swift` — imperial switch depth, Ratio Deco CCR rejection, tissue trace alignment, runtime segment quarantine, water vapor, export gate, checklist roles, persistence, service limits, GF validation label, PDF status localization.

### Run results (2026-06-08)

| Command | Destination | Result |
|---|---|---|
| `xcodegen generate` | — | OK |
| `DIRDiving iOS` build | iPhone 17 simulator | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | iPhone 17 simulator | **526 passed**, 13 skipped, **0 failures** |
| `DIRDiving Watch App` build | Apple Watch Series 11 (46mm) | **BUILD SUCCEEDED** |

Note: Ultra 2 simulator unavailable; Series 11 (46mm) used per prior audit convention.

---

## Remaining external validation (pending — not faked)

| Gate | Status |
|---|---|
| Bühlmann third-party profile comparison | **Pending** — see `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` |
| CCR profile external comparison | **Pending** — see `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` |
| iCloud two-device QA | **Pending** |
| Paired Watch/iPhone QA | **Pending** |
| Physical Watch Ultra QA | **Pending** |
| App Store legal/marketing review | **Pending** |

---

## Updated readiness estimate (post-remediation, excluding external QA)

| Area | Before | After | Notes |
|---:|---:|---:|---|
| **Overall math** | 87% | **93%** | Code-fixable P1/P2 closed |
| **Bühlmann (OC)** | 94% | **94%** | Unchanged core |
| **CCR / Rebreather** | 76% | **88%** | Tissue trace + vapor + truthfulness |
| **CCR setpoint** | 85% | **92%** | Imperial logbook fix |
| **CCR diluent** | 78% | **90%** | Vapor alignment |
| **CCR bailout** | 55% | **72%** | Heuristic labeled; not engine-simulated |
| **CCR tissue** | ~70% | **90%** | Engine-aligned sampler |
| **Ratio Deco** | 78% | **86%** | API `.ccr` guard |
| **Checklist** | 72% | **84%** | CCR gas roles + sync |
| **PDF / share** | 82% | **90%** | Export gate + localized bailout |
| **Sync / persistence** | 81% | **86%** | CCR JSON round-trip test |

**External TestFlight / App Store algorithm gates remain blocked** until external validation and physical QA evidence is collected.

---

## Confirmations

- MAIN-only scope on `main` branch
- iOS Companion primary; Watch build verified, runtime unchanged
- Experimental branches untouched
- Reference-only / non-certified disclaimers preserved
- No live CCR loop PPO2 monitoring claims introduced
- No certified decompression or CCR controller claims introduced
