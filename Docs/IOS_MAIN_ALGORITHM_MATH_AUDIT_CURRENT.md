# iOS Companion MAIN Algorithm and Mathematical Functions Audit — Current

**Audit date:** 2026-06-05  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main`  
**Code baseline:** `ecad0d9`  
**Target audited:** `DIRDiving iOS` only  
**Mode:** Read-only static audit. No code, UI, Watch runtime, or experimental targets were modified.

---

## Scope Confirmation

### Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `ecad0d9` |
| Working tree | Clean at audit time |
| Experimental exclusions in `project.yml` | Confirmed for `DIRDiving iOS` |
| Apple Watch runtime | Out of scope except shared models/codec consumed by iOS |
| Build/test executed | `DIRDiving iOS Algorithm Tests` — **287 passed**, 4 skipped, 0 failures (iPhone 17 Pro sim) |

### iOS MAIN target exclusions (`project.yml`)

These files are **not** in the `DIRDiving iOS` build and were not audited:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

### Primary files inspected

Planner / three-mode architecture, Bühlmann, gas, logbook, sync, import/export, formatters, analysis, manual dive, equipment, and the full `Tests/iOSAlgorithmTests/*` suite (52 files).

---

## A. Executive Summary

### Overall verdict

The iOS Companion MAIN target contains a **substantive, non-placeholder algorithm layer**: ZHL-16C N2/He Bühlmann reference engine, mode-aware planner projection (`PlannerModePolicy`), gas validation and consumption ledger, oxygen exposure (CNS/OTU), time-weighted dive profile math, CSV import/export guards, Watch sync codec validation, and cloud merge with conflict detection.

The **three-tab Planner architecture (Base / Deco / Technical) is materially functional**, not decorative. Mode selection affects visible inputs, active gas projection, validation rules, calculation inputs, result section gating, Bühlmann display level, warning scope, localization, and accessibility summaries. Automated coverage exists in `PlannerModePolicyTests.swift` and related planner tests.

Remaining gaps are primarily **integration consistency** (preview widgets vs projected plan input, cloud profile merge semantics, PPO₂ tolerance fragmentation) and **physical/external QA**, not missing core math.

### Readiness estimates

| Area | Readiness | Notes |
|---:|---:|---|
| **Overall mathematical robustness** | **91%** | Core engine and validators are sound; integration edge cases remain |
| **Planner confidence (calculation path)** | **92%** | `PlannerService.makePlan` uses projected active input correctly |
| **Planner three-mode readiness** | **88%** | Real architecture; preview/export/copy gaps |
| **Bühlmann ZHL-16C engine** | **93%** | Real tissue model; display gating by mode is correct |
| **Gas planning / consumption** | **90%** | Ledger excludes unused/bailout by design; mode projection respected in plan path |
| **Logbook derived math** | **92%** | Centralized `DiveProfileMath`; demo isolation present |
| **CSV import/export** | **89%** | Guards present; external Subsurface regression still manual |
| **Watch sync validation on iOS** | **90%** | HMAC + math validation; unsigned ack path for some deliveries |
| **Cloud merge / iCloud KVS** | **86%** | Metadata conflicts detected; profile sample merge is silent |
| **Unit conversion consistency** | **89%** | Central helpers; manual pressure unit semantics ambiguous |
| **Automated algorithm tests** | **93%** | 287 XCTest pass; mode-specific preview tests still thin |

### Severity summary

| Severity | Count | Summary |
|---:|---:|---|
| CRITICAL | 0 | No immediate certified-decompression authority blocker |
| HIGH | 2 | Silent cloud profile merge; NDL preview uses draft not projected input |
| MEDIUM | 6 | PPO₂ tolerance fragmentation, export mode label, Base/Deco env validation gap, analysis preview path, share copy scope, Watch delivery ack |
| LOW | 4 | Deco NDL tab scope, bailout ledger clarity, localized service strings, Subsurface external regression |
| INFO | 3 | Base runs full engine internally (UI gated); arithmetic analysis averages; OTU extrapolation positioning |

### Blockers

| Gate | Blockers |
|---|---|
| **Compile / use** | None identified |
| **Internal TestFlight** | HIGH-002 (misleading NDL preview in Deco when draft GF/gases differ from projection) — recommend fix or copy disclaimer before wide internal use |
| **External TestFlight** | HIGH-001 (cloud profile merge without conflict UX) + physical Watch round-trip QA |
| **App Store** | External TestFlight blockers + documented Subsurface CSV regression + paired-device sync matrix |

---

## B. Algorithm Inventory

Grouped by audit families. **Mode column:** Base / Deco / Technical / shared.

### 1. Planner mode architecture

| Component | File | Inputs → outputs | Mode | Safety |
|---|---|---|---|---|
| `PlannerMode` enum + legacy decode | `iOSApp/Models/GasPlan.swift` | persisted raw → `.base`/`.deco`/`.technical` | shared | Low |
| `PlannerModePolicy.activePlanInput` | `iOSApp/Utils/PlannerModePolicy.swift` | draft `GasPlanInput` → projected input | Base: bottom only + std GF; Deco: bottom + ≤1 deco; Technical: full draft | **High** |
| `PlannerModePolicy.validate` | same | draft + mode → `PlannerValidationResult` | Mode-specific trimix rules | High |
| `PlannerModePolicy.modeGuidance` | same | engine plan + stops → Base-only “exceeds mode” warning | Base | High |
| `PlannerResultPresentation` | same | mode → UI section flags | Per-mode gating matrix | High |
| `visiblePlannerCylinders` | `iOSApp/Views/PlannerView.swift` | draft cylinders → visible subset | Mirrors projection in UI | Medium |
| Mode picker + localized descriptions | `PlannerView.swift`, `Resources/*.lproj` | user tab → `store.mode` | shared | Medium |

### 2. Planner / dive planning algorithms

| Component | File | Notes | Mode |
|---|---|---|---|
| `PlannerService.makePlan` | `iOSApp/Services/PlannerService.swift` | Projects input, validates, runs Bühlmann, builds result | Uses active projection per mode |
| `BuhlmannPlanner.makeRequest` | `iOSApp/Services/BuhlmannPlanner.swift` | Builds multigas request from projected cylinders | shared engine |
| `PlanCalculationCompletenessResolver` | `iOSApp/Utils/PlanCalculationCompleteness.swift` | Incomplete calc states | shared |
| `PlannerAscentTableBuilder` | `iOSApp/Services/PlannerAscentTableBuilder.swift` | Ascent table rows | Full (Technical), simplified (Deco), hidden (Base) |
| `PlannerDepthProfileBuilder` | `iOSApp/Services/PlannerDepthProfileBuilder.swift` | Depth/time profile points | shared |
| `PlannerGasSchedule` | `iOSApp/Services/PlannerGasSchedule.swift` | Role schedule lines, PPO₂ at switch | Technical multigas; Deco limited |
| `PlannerStore.applyInputToPlanningOutputs` | `iOSApp/Services/PlannerStore.swift` | Keeps plan + preview in sync | **Preview path does not project mode** |

### 3. Bühlmann / decompression display

| Component | File | Implementation | Display by mode |
|---|---|---|---|
| `BuhlmannEngine` | `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift` | ZHL-16C N2/He, GF, multigas schedule | Engine always runs on projected input |
| `BuhlmannTissueHistory` | `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift` | Compartment load samples | Hidden Base; simplified Deco; full Technical |
| `BuhlmannPlanPreflightValidator` | `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift` | Pre-schedule gas envelope | shared |
| `BuhlmannPlanner.plan` (NDL curve) | `iOSApp/Services/BuhlmannPlanner.swift` | Depth vs NDL reference curve | Deco + Technical tabs only |
| Tissue chart UI | `iOSApp/Views/PlannerView.swift` (`PlanResultView`) | Swift Charts, disclaimers | `.hidden` / `.simplifiedSummary` / `.fullCurve` |

### 4. Gas planning algorithms

| Component | File | Role | Mode |
|---|---|---|---|
| `GasPlanningService.analyze` | `iOSApp/Services/GasPlanningService.swift` | PPO₂, END, EAD, density, rock bottom, CNS/OTU | Plan path uses projected input; preview property uses draft |
| `GasPlanningService.contingencyPlans` | same | Lost-gas scenarios | Technical only (UI gated) |
| `GasPlanningService.teamGasMatches` | same | Team gas matching | Technical only |
| `ScheduleGasConsumptionService` | `iOSApp/Services/ScheduleGasConsumptionService.swift` | Consumption ledger from engine segments | Deco/Technical result; unused/bailout separate |

### 5. PPO₂ / MOD / gas safety

| Component | File | Thresholds |
|---|---|---|
| `GasMixValidator` | `iOSApp/Utils/GasMixValidator.swift` | O₂/He fractions, max PPO₂ |
| `PlannerMODValidator` | `iOSApp/Services/PlannerMODValidator.swift` | Cylinder MOD vs planned depth |
| `BuhlmannGas.isOperationalBetween` | `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift` | +0.0001 bar tolerance (strict) |
| Preflight deco switch | `BuhlmannPlanPreflightValidator` | +0.02 bar (`decoGasSwitchPPO2ToleranceBar`) |
| `IOSAlgorithmConfiguration` | `iOSApp/Utils/IOSAlgorithmConfiguration.swift` | min PPO₂ 1.0 bar surface legacy display path |

### 6. SAC / gas consumption

| Component | File | Formula semantics |
|---|---|---|
| Bottom consumption estimate | `GasPlan.swift` | `SAC × ambientPressure × bottomMinutes` (L) |
| Rock bottom | `GasPlanningService.rockBottomLiters` | 9 m/min ascent assumption (shared constant) |
| Schedule ledger | `ScheduleGasConsumptionService` | Segment ATA × SAC; excludes unscheduled cylinders |

### 7. CNS / OTU / oxygen exposure

| Component | File | Notes |
|---|---|---|
| `OxygenExposureModel` | `iOSApp/Services/OxygenExposureModels.swift` | NOAA-style tables; extrapolation above limits |
| Descent+bottom vs full plan CNS | `GasPlanningService` + result | Separate labels in UI and export |
| Monotonicity tests | `Tests/iOSAlgorithmTests/OTU*` | OTU increases with PPO₂ |

### 8–21. Remaining families (summary)

| # | Family | Primary files | Assessment |
|---|---|---|---|
| 8 | Dive log statistics | `DiveLogStore`, `DiveProfileMath`, `IOSDiveLogbookPolicy` | Sound; demo dives flagged |
| 9 | Depth profile / charts | `DiveDetailView`, `PlannerDepthProfileBuilder` | Negative depth convention consistent |
| 10 | Analysis dashboard | `AnalysisDashboardMath`, `AnalysisView` | Arithmetic session averages (documented INFO) |
| 11 | Manual dive edit | `ManualDiveEditorView`, `ManualDiveSampleBuilder` | Validation + sample synthesis |
| 12 | CSV import | `DiveImportService` | Size cap, row validation, optional temperature |
| 13 | CSV / Subsurface export | `SubsurfaceExportService` | Metric export; empty profile rejected |
| 14 | Subsurface compatibility | import + export pair | Needs external tool regression |
| 15 | Watch sync | `WatchSyncService`, `WatchDiveSyncCodec` | HMAC, numeric validation, tombstones |
| 16 | Cloud merge / KVS | `CloudSyncStore`, `DiveSessionMerge`, `DiveSessionMergeConflict` | Metadata conflicts; silent profile merge |
| 17 | Unit conversion / formatters | `IOSUnitConversions`, `Formatters` | Internal metric storage |
| 18 | GPS / route | `RouteMath` (if referenced by analysis) | Haversine, bearing normalization |
| 19 | Equipment / checklist | `EquipmentStore`, `EquipmentView` | Completion counts; cloud merge |
| 20 | Demo isolation | `DemoDiveCatalog`, `AnalysisDemoIsolationTests` | Demo excluded when real dives exist |
| 21 | Edge / empty paths | validators + `unavailablePlan` | Finite-safe fallbacks |

---

## C. Planner Mode Audit

### Architecture verdict

**Base, Deco, and Technical are real modes.** Policy is centralized in `PlannerModePolicy.swift`, enforced in `PlannerService.makePlan`, mirrored in `PlannerView` UI gating, and covered by unit tests.

### A. UI inputs matrix

| Field / control | Base | Deco | Technical |
|---|---|---|---|
| Bottom gas card | ✓ visible (1) | ✓ visible | ✓ visible |
| Deco gas card(s) | ✗ hidden | ✓ ≤1 visible (+ add deco button) | ✓ multiple |
| Travel gas | ✗ hidden | ✗ hidden | ✓ |
| Bailout gas | ✗ hidden | ✗ hidden | ✓ |
| Role / tank size pickers | ✗ fixed bottom | ✗ fixed roles | ✓ editable |
| GF manual controls | ✗ hidden (forced std on calc) | ✗ presets only | ✓ manual |
| SAC emergency / team | ✗ hidden | ✓ reserve card tiles | ✓ full |
| Repetitive planning | ✗ | ✗ | ✓ |
| Environment (altitude/salinity) | stored, **not validated** | stored, **not validated** | ✓ validated |
| Trimix mix kind in gas card | ✗ disallowed | ✗ disallowed | ✓ allowed |

Hidden Technical cylinders **remain in draft** when switching to Base/Deco; UI filters via `visiblePlannerCylinders`.

### B. Active calculation input

| Mode | `activePlanInput` behavior | Verified |
|---|---|---|
| Base | Single bottom cylinder; GF 30/80 preset | ✓ tests |
| Deco | Bottom + max one deco (deepest switch first) | ✓ tests |
| Technical | Full `plannerCylinders` draft | ✓ tests |

`PlannerService.makePlan` always plans from **projected** `activeInput`. Hidden travel/bailout/extra deco gases are **not** passed to Bühlmann in Base/Deco.

**Gap:** `PlannerStore` NDL preview (`store.buhlmann`) uses **draft** `input.gfHigh` and `input.buhlmannBackGas`, not projected active input (see HIGH-002).

### C. Validation rules

| Rule | Base | Deco | Technical |
|---|---|---|---|
| Trimix bottom | Rejected | Rejected | Allowed |
| Air/EAN bottom | Allowed | Allowed | Allowed |
| Multiple deco | N/A (0) | ≤1 active | Unlimited |
| Travel/bailout in draft | Ignored for calc | Ignored | Used |
| Average depth required | No | Yes | Yes |
| Environment bounds | Skipped | Skipped | Validated |
| PPO₂/MOD / hypoxic | On active gases | On active gases | Full multigas |

### D. Result sections matrix

| Section | Base | Deco | Technical |
|---|---|---|---|
| Full ascent table | ✗ | ✗ | ✓ |
| Simplified ascent table | ✗ | ✓ | ✗ |
| Gas ledger | ✗ | ✓ | ✓ |
| Contingency / team match | ✗ | ✗ | ✓ |
| GF comparison | ✗ | ✗ | ✓ |
| Segment timeline | ✗ | ✓ | ✓ |
| Bühlmann tissue chart | hidden | simplifiedSummary | fullCurve |
| NDL reference curve tab | ✗ | ✓ | ✓ |
| Charts tab (extra) | ✗ | ✗ | ✓ |
| Mode guidance (deco obligation) | ✓ when stops/NDL exceeded | ✗ | ✗ |

### E. Mode switching data policy

| Policy | Status |
|---|---|
| Technical config preserved in draft on Base/Deco switch | ✓ verified in tests |
| Base calc ignores inactive Technical data | ✓ projection |
| Switch Technical → Base → Technical restores cylinders | ✓ draft untouched |
| GF reset on Base projection | ✓ forced standard preset |

### F. Localization and accessibility

| Item | Status |
|---|---|
| Tab titles + mode descriptions | Localized keys present (`planner.mode.*`) |
| Base exceeds-mode warning | Localized (`planner.base.exceeds_mode.*`) |
| Reference-only disclaimers | Present on planner input and Bühlmann charts |
| Bühlmann chart a11y summaries | `planner.buhlmann.tissue_chart.a11y.*` |
| Export share a11y | `planner.export.share.a11y` |
| **Export text includes active mode label** | **Missing** (MED-003) |

### Gas availability matrix

| Gas role | Base | Deco | Technical |
|---|---|---|---|
| Bottom | 1 | 1 | 1+ |
| Deco | 0 | ≤1 | many |
| Travel | 0 | 0 | optional |
| Bailout | 0 | 0 | optional |

### Output matrix (calculation vs display)

| Output | Base calc | Base display | Deco calc | Technical |
|---|---|---|---|---|
| Bühlmann schedule | full engine on projected input | minimal hero + warnings | simplified tables + ledger | full |
| Deco stops in result | computed | not shown as actionable table | shown (simplified) | full table |
| CNS/OTU | computed | secondary metrics gated | shown | full + export |
| Gas consumption detail | bottom estimate only in input | reserve hidden | ledger | ledger + contingency |

---

## D. Findings by Family

### HIGH-001 — Cloud merge silently fuses divergent dive profiles

| Field | Value |
|---|---|
| **ID** | HIGH-001 |
| **Title** | Profile samples merged without conflict detection |
| **Family** | Cloud merge / iCloud KVS |
| **File/function** | `iOSApp/Utils/DiveSessionMerge.swift` — `preferred`, `mergedSamples` |
| **Severity** | HIGH |
| **Planner mode** | shared |
| **User impact** | Two devices editing the same dive can produce a hybrid depth profile not matching either edit |
| **Safety impact** | Max/average depth and TTV recomputed from merged samples may misrepresent the dive |
| **Mathematical explanation** | `DiveSessionMergeConflictDetector` compares metadata (site, notes, pressure text, dates) but **not** `samples`. `DiveSessionMerge.preferred` unions samples by timestamp, keeping deeper sample at each key, then recomputes summary statistics |
| **Proposed solution** | Detect sample-array divergence as conflict, or LWW on entire session including profile; document merge policy |
| **Priority** | Before external TestFlight |
| **Code impact** | small functional |

### HIGH-002 — NDL preview widget uses draft input, not mode-projected input

| Field | Value |
|---|---|
| **ID** | HIGH-002 |
| **Title** | Bühlmann NDL curve preview bypasses `activePlanInput` |
| **Family** | Planner mode architecture |
| **File/function** | `iOSApp/Services/PlannerStore.swift` — `applyInputToPlanningOutputs`; `BuhlmannPlanner.plan` |
| **Severity** | HIGH |
| **Planner mode** | Deco, Technical (NDL tab visible) |
| **User impact** | NDL reference curve can reflect draft GF or stale configuration not used by the computed plan |
| **Safety impact** | User may compare NDL chart against a plan computed with different GF/gases |
| **Mathematical explanation** | Plan path: `PlannerModePolicy.activePlanInput` + projected GF. Preview path: `input.buhlmannBackGas`, `input.gfHigh` from full draft |
| **Proposed solution** | Run preview through `activePlanInput(from:mode:)` or label curve as draft/discrepancy |
| **Priority** | Before wide internal TestFlight |
| **Code impact** | small functional |

### MED-001 — PPO₂ tolerance fragmentation across layers

| Field | Value |
|---|---|
| **ID** | MED-001 |
| **Title** | Inconsistent PPO₂ epsilon (0.02 vs 0.0001 bar) |
| **Family** | PPO₂ / MOD / gas safety |
| **File/function** | `BuhlmannPlanPreflightValidator`, `BuhlmannGas`, `GasPlanningService.segmentsExceedGasPPO2Limit` |
| **Severity** | MEDIUM |
| **Planner mode** | shared (Technical multigas most affected) |
| **User impact** | Gas may pass preflight at switch depth but flag strict over-limit in runtime segments (or vice versa near boundary) |
| **Safety impact** | Boundary ambiguity at 1.4 vs 1.42 bar effective |
| **Mathematical explanation** | Deco switch tolerance `decoGasSwitchPPO2ToleranceBar = 0.02`; runtime segment check uses `+ 0.0001` |
| **Proposed solution** | Centralize tolerance policy with documented rationale per phase (preflight vs display vs runtime) |
| **Priority** | Before App Store |
| **Code impact** | small functional |

### MED-002 — Base and Deco skip planner environment validation

| Field | Value |
|---|---|
| **ID** | MED-002 |
| **Title** | Altitude/salinity validated only in Technical mode |
| **Family** | Planner / environment |
| **File/function** | `iOSApp/Utils/PlannerInputValidator.swift` lines 61–70 |
| **Severity** | MEDIUM |
| **Planner mode** | Base, Deco |
| **User impact** | Invalid altitude stored but plan may still run with fallback `.seaLevelSaltWater` in some paths |
| **Safety impact** | MOD/PPO₂ at altitude may be wrong if invalid env silently falls back |
| **Mathematical explanation** | `PlannerInputValidator` gates `PlannerEnvironment.make` failure handling on `mode == .technical` |
| **Proposed solution** | Validate environment for all modes or block calculate with explicit error |
| **Priority** | Before external TestFlight |
| **Code impact** | small functional |

### MED-003 — Planner share/export omits active mode label

| Field | Value |
|---|---|
| **ID** | MED-003 |
| **Title** | Export text does not state Base/Deco/Technical |
| **Family** | Planner output / localization |
| **File/function** | `iOSApp/Views/PlannerView.swift` — `planShareText` |
| **Severity** | MEDIUM |
| **Planner mode** | shared |
| **User impact** | Shared plan text lacks mode context; CNS labels may be misread outside app |
| **Safety impact** | Indirect — reference-only footer exists but mode scope unclear |
| **Proposed solution** | Prefix export with `store.mode.localizedTabTitle` and mode-specific disclaimer |
| **Priority** | Before external TestFlight |
| **Code impact** | copy-only |

### MED-004 — `GasPlanningService.analyze(input:)` always validates as Technical

| Field | Value |
|---|---|
| **ID** | MED-004 |
| **Title** | Input-screen analysis uses `.technical` validator default |
| **Family** | Gas planning |
| **File/function** | `GasPlanningService.analyze(input:)` → `PlannerInputValidator.validate(input)` |
| **Severity** | MEDIUM |
| **Planner mode** | Deco (reserve card uses `store.analysis`) |
| **User impact** | Reserve/consumption tiles may reflect validation paths that differ from mode-scoped plan validation |
| **Safety impact** | Low if tiles hidden in Base; possible inconsistency in Deco reserve card |
| **Proposed solution** | Thread `PlannerMode` into preview analysis or use projected input |
| **Priority** | Post-internal TestFlight |
| **Code impact** | small functional |

### MED-005 — Watch session delivery without signed ack (fallback path)

| Field | Value |
|---|---|
| **ID** | MED-005 |
| **Title** | Some Watch deliveries lack signed ack confirmation |
| **Family** | Watch sync |
| **File/function** | `iOSApp/Services/WatchSyncService.swift` (~line 671) |
| **Severity** | MEDIUM |
| **Planner mode** | shared |
| **User impact** | Session may remain queued if Watch does not return `ackSignature` |
| **Safety impact** | Data consistency, not dive math |
| **Proposed solution** | Physical paired QA; clarify queue UX |
| **Priority** | Before external TestFlight |
| **Code impact** | external QA/process |

### MED-006 — iCloud KVS payload size vs Watch 512 KB cap asymmetry

| Field | Value |
|---|---|
| **ID** | MED-006 |
| **Title** | iOS cloud backup lacks explicit size guard matching Watch codec |
| **Family** | Cloud merge |
| **File/function** | `CloudSyncStore`, `WatchDiveSyncCodec` |
| **Severity** | MEDIUM |
| **Planner mode** | shared |
| **User impact** | Very large logbooks may fail sync opaquely on one side |
| **Safety impact** | Data loss risk, not calculation error |
| **Proposed solution** | Align caps and surface user-visible errors |
| **Priority** | Before App Store |
| **Code impact** | small functional |

### LOW-001 — Deco mode shows NDL reference tab (expected simplified scope)

| Field | Value |
|---|---|
| **ID** | LOW-001 |
| **Title** | Deco NDL tab visible while full compartment chart remains simplified |
| **Family** | Bühlmann display |
| **Severity** | LOW |
| **Planner mode** | Deco |
| **Notes** | Aligns with audit spec “simplified Bühlmann”; disclaimers present. Not a bug — document expected behavior |

### LOW-002 — Bailout cylinders excluded from consumption ledger totals

| Field | Value |
|---|---|
| **ID** | LOW-002 |
| **Title** | Unused/bailout in `unusedPlannedEntries` only |
| **Family** | Gas consumption |
| **File/function** | `ScheduleGasConsumptionService` / `GasConsumptionLedger` |
| **Severity** | LOW |
| **Planner mode** | Technical |
| **Notes** | Intentional; UI should keep bailout labelled separately |

### LOW-003 — Residual hardcoded service strings

| Field | Value |
|---|---|
| **ID** | LOW-003 |
| **Title** | Mixed IT/EN in some service statuses |
| **Severity** | LOW |
| **Planner mode** | shared |

### LOW-004 — Subsurface external regression not automated

| Field | Value |
|---|---|
| **ID** | LOW-004 |
| **Title** | Export/import fidelity vs Subsurface app |
| **Severity** | LOW |
| **Planner mode** | shared |

### INFO-001 — Base mode runs full Bühlmann engine internally

| Field | Value |
|---|---|
| **ID** | INFO-001 |
| **Notes** | Engine computes deco obligation; UI hides technical sections and shows `modeGuidance` recommending Deco/Technical. Correct product semantics |

### INFO-002 — Analysis dashboard uses arithmetic session averages

| Field | Value |
|---|---|
| **ID** | INFO-002 |
| **File** | `AnalysisDashboardMath.swift` |
| **Notes** | Documented intentional semantics |

### INFO-003 — OTU extrapolation above NOAA table limits

| Field | Value |
|---|---|
| **ID** | INFO-003 |
| **File** | `OxygenExposureModels.swift` |
| **Notes** | Finite values + `PPO2Exceeded` warnings should dominate UI |

---

## E. Edge Case Matrix

| Edge case | Expected | Observed (code) | Test status |
|---|---|---|---|
| Base, one air gas | Single-gas NDL/rec plan | Projected bottom only | Tested |
| Base with Nitrox | Allowed EAN | Allowed | Tested |
| Base with deco obligation | Warning to switch mode | `modeGuidance` warning | Tested (policy) |
| Base with hidden Technical gases | Ignored in calc | Projection strips extras | Tested |
| Deco, no deco gas | Bottom-only plan | Valid | Partial |
| Deco, two deco in draft | One used | `prefix(1)` | Tested |
| Deco with hidden bailout from Technical | Ignored | Projection strips | Static ✓ |
| Technical full multigas | Full schedule + ledger | Engine multigas | Tested |
| Technical hypoxic bottom | MOD/MOD warnings | Validators + engine | Tested |
| Technical → Base → Technical | Draft preserved | Draft unchanged | Tested |
| Depth = 0 | Rejected | `minPlannerDepthMeters` | Tested |
| Very long bottom time | Capped/rejected | `maxBottomTimeMinutes` | Tested |
| Imperial display | Formatted ft/psi | `Formatters` + metric storage | Tested |
| Empty logbook stats | Zero/empty state | Analysis guards | Tested |
| Demo on/off | Demo isolated | Policy + tests | Tested |
| Cloud divergent profiles | User should choose | **Silent merge** | **Untested UX** |
| CSV no temperature column | Import OK | Supported | Tested |
| NDL preview after GF change in Deco | Match plan | **May diverge** | **Gap** |
| Invalid altitude in Base | Block or warn | **May fallback** | Gap |

---

## F. Unit / Integration Test Plan

| Feature | Input | Expected | Priority |
|---|---|---|---|
| Mode projection | Technical draft → Base | 1 bottom cylinder in engine request | P0 |
| Mode projection | 2 deco draft → Deco | 1 deco in engine request | P0 |
| Base exceeds mode | Profile with stops | `modeGuidance` warning state | P0 |
| NDL preview parity | Deco + custom GF | Preview GF = projected GF | P0 |
| PPO₂ boundary | 1.40 max @ switch | Consistent preflight/runtime flag | P1 |
| Environment Base | Invalid altitude | Validation error before plan | P1 |
| Gas ledger | Technical + bailout | Bailout in unused, not consumed total | P1 |
| Cloud profile conflict | Divergent samples same ID | Conflict surfaced | P0 |
| Export mode label | Share from Base | Text includes "Base" | P2 |
| OTU monotonicity | Rising PPO₂ segments | OTU non-decreasing | P1 (exists) |
| CSV round-trip | Subsurface fixture | Depth/time preserved | P1 |
| Manual pressure units | Save bar, switch to PSI display | Correct label | P1 |

---

## G. Planner Mode Regression Test Plan

| Test | Mode | Pass criteria |
|---|---|---|
| UI cylinder count | Base / Deco / Technical | Visible cards match policy |
| Result section flags | each | Match `PlannerResultPresentation` |
| Bühlmann visibility | Base hidden, Deco simplified, Technical full | UI + a11y labels |
| Calculate with hidden bailout | Base | Bailout not in engine gases |
| Switch mode preserve draft | Technical → Base → Technical | Cylinder count restored |
| Share export | each | Mode label + disclaimer (after fix) |
| GF preset Base | any draft GF | Plan uses 30/80 |
| Trimix rejection | Base / Deco | `.unsupportedTrimix` |

---

## H. Paired Watch/iPhone Test Plan

| Scenario | Expected | Priority |
|---|---|---|
| Watch dive → iOS | Samples, depth, GPS, duration match codec | P0 |
| iOS manual → Watch | Round-trip fields preserved | P0 |
| Edited manual sync | Pressure text + bar values consistent | P1 |
| Delete tombstone | Dive stays deleted on both sides | P0 |
| Duplicate session ID | No crash; conflict or dedup | P0 |
| Large profile near 512 KB | Graceful error | P1 |
| Unsigned ack path | Queue message visible | P1 |

---

## I. CSV Import/Export Regression Plan

| Case | Pass criteria |
|---|---|
| Valid Subsurface CSV | Sessions imported, dates preserved |
| No temperature column | Import succeeds |
| Invalid depth row | Row skipped/reported, no crash |
| Duplicate file import | No duplicate sessions |
| Export manual dive | Metric depths, monotonic times |
| Export with special chars in notes | Escaped correctly |
| Empty profile export | Rejected |

---

## J. Cloud Merge Validation Plan

| Case | Pass criteria |
|---|---|
| Metadata conflict (notes) | Shown in `sessionMergeConflicts` |
| Profile sample divergence | **Should flag conflict (currently fails)** |
| Keep local resolution | Local profile intact |
| Use cloud resolution | Cloud profile intact |
| Tombstone + live cloud copy | Deleted stays deleted |
| Malformed JSON | Decode error logged / visible |

---

## K. Planner Boundary Validation Plan

| Boundary | Input | Expected |
|---|---|---|
| Min depth | 0 m | Invalid |
| Max depth | > cap | `.unsupportedDepth` |
| Max bottom time | > cap | Invalid |
| O₂ fraction | 0, 1.2 | Rejected |
| Hypoxic at surface | FO₂ < 16% shallow | Warning/error |
| EAN50 switch | Too deep | `.gasSwitchTooDeep` / PPO₂ |
| GF invalid | low ≥ high | Invalid (Technical); reset (Deco projection) |

---

## L. Prioritized Roadmap

### 1. Must fix before compile/use
- None

### 2. Must fix before internal TestFlight
- HIGH-002 — NDL preview / projected input parity (or prominent disclaimer)

### 3. Must fix before external TestFlight
- HIGH-001 — Cloud profile merge conflict detection
- MED-002 — Environment validation for Base/Deco
- MED-003 — Export mode label
- MED-005 — Watch sync paired QA sign-off

### 4. Must fix before App Store
- MED-001 — PPO₂ tolerance unification
- MED-006 — Cloud payload size policy
- LOW-004 — Subsurface external regression documented
- Full physical QA matrices (Watch, iCloud two-device)

### 5. Post-release improvements
- MED-004 — Mode-aware preview analysis
- LOW-003 — Service string localization
- INFO-002 — Optional duration-weighted analysis averages

---

## M. Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Yes for internal reference use**, at ~91% static readiness. Core Bühlmann, gas, exposure, and logbook math are sound and well-tested. |
| **Are Base / Deco / Technical real and correct?** | **Yes.** Modes materially change inputs, projection, validation, results, and Bühlmann display. Minor preview/export inconsistencies remain. |
| **Planner safe enough for internal test?** | **Yes**, with reference-only disclaimers and Base mode guidance when deco is required. Fix or disclaim NDL preview drift (HIGH-002) before broad internal distribution. |
| **Sync/data ready?** | **Mostly.** Codec and tombstones are strong; **cloud profile silent merge (HIGH-001)** blocks external confidence. |
| **Ready for TestFlight?** | **Internal: yes with caveats.** **External: no** until HIGH-001 and paired Watch QA complete. |
| **Ready for App Store?** | **No** — external TestFlight blockers plus Subsurface regression and tolerance hardening remain. |
| **What blocks 100% algorithmic readiness?** | (1) Cloud profile merge conflict gap, (2) planner preview vs projected input parity, (3) PPO₂ tolerance unification, (4) Base/Deco environment validation, (5) physical paired-device QA evidence, (6) external CSV compatibility proof. |

---

## Appendix — Build and test evidence

```
Branch: main @ ecad0d9
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
Result: 287 tests passed, 4 skipped, 0 failures — TEST SUCCEEDED
```

Key mode tests: `PlannerModePolicyTests` (projection, trimix rejection, presentation flags, localization keys).

---

*Previous audit baseline `6a5054f` (2026-06-03) predated the three-tab Planner architecture and UI readiness work @ `ecad0d9`. This document supersedes that revision for planner mode scope.*
