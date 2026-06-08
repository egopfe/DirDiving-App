# iOS Companion MAIN Branch — Complete Mathematical Functions / Algorithm Audit (CCR Updated)

**Audit date:** 2026-06-08  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main` only  
**Code baseline:** `b9f54a3` — `Skip iCloud KVS sync when no account is signed in.`  
**Prior audit baseline:** `32f8d3e` (superseded; no CCR module)  
**Primary target:** `DIRDiving iOS`  
**Secondary target:** Apple Watch companion/runtime (scoped features only)  
**Mode:** Read-only audit. No application code modified. No commit. No push.  
**Command:** `commands_for_cursor/0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED.md`

---

## Scope Confirmation (Phase 0)

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `b9f54a3` |
| Working tree at audit start | Clean except untracked `commands_for_cursor/` (audit command file) |
| Remote | `origin/main` @ `b9f54a3` |
| Experimental branches | Not modified |
| Audit type | Read-only — no code/logic changes |
| macOS build/test | Executed |

### Targets in `project.yml`

**DIRDiving iOS** — excludes experimental-only sources (Exploration, Buddy experimental views/stores).

**DIRDiving Watch App** — excludes buddy/apnea/snorkeling experimental surfaces.

**Test targets:** `DIRDiving iOS Algorithm Tests` (74 Swift test files), `DIRDiving Watch Algorithm Tests` (31 Swift test files).

### Build / test execution (Phase 17)

| Command | Destination | Result |
|---|---|---|
| `xcodegen generate` | — | **OK** |
| `DIRDiving iOS` build | iPhone 17 simulator (OS 26.5) | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | iPhone 17 simulator | **509 passed**, 13 skipped, **0 failures** |
| `DIRDiving Watch App` build | Apple Watch Series 11 (46mm) — Ultra 2 unavailable | **BUILD SUCCEEDED** |

Note: Requested `Apple Watch Ultra 2 (49mm)` simulator unavailable; **Apple Watch Series 11 (46mm)** used (OS 26.5). Watch algorithm tests not re-run in this pass (build-only per available time); prior baseline had 161 Watch tests green.

---

## A. Executive Summary

### Overall verdict

At `b9f54a3`, DIR DIVING `main` is a **coherent, non-certified reference diving companion** with:

- Real Bühlmann ZHL-16C + GF decompression engine for Open Circuit (Base / Deco / Technical)
- **New CCR / Rebreather reference planner** (isolated path, setpoint-based inspired gas, dedicated validator/engine)
- Ratio Deco as an explicitly labeled heuristic comparator with Bühlmann cross-validation
- Gas/MOD/PPO₂ validation, CNS/OTU exposure models, tissue/narcotic analytics with source footnotes (including `.ccrPlanned`)
- Equipment checklist with DIR/READY badges, CCR equipment template, PDF export/share, logbook CSV, Watch sync

**No P0 safety-critical algorithm defect** was found in static review or automated tests. **Internal algorithm validation is strong** (509 iOS XCTest). **External decompression validation, CCR manufacturer cross-checks, paired-device QA, and several CCR fidelity gaps** remain before claiming full mathematical certification.

### Readiness estimates

| Area | Readiness | Confidence | Notes |
|---:|---:|---:|---|
| **Overall mathematical readiness** | **87%** | High on OC code; medium on CCR fidelity | +CCR module since `32f8d3e` |
| **Mathematical robustness** | **88%** | Bühlmann + exposure real; Ratio Deco heuristic; CCR tissue trace diverges from engine | |
| **Planner confidence** | **90%** | Mode policy + engine integration solid; CCR isolated | |
| **Bühlmann readiness** | **94%** | Real Schreiner/GF schedule; external fixtures pending | unchanged core |
| **CCR / Rebreather readiness** | **76%** | Deco path sound; tissue trace + bailout heuristic weaken end-to-end | **NEW** |
| **Ratio Deco readiness** | **78%** | Heuristic by design; no API `.ccr` guard | |
| **Tissue / narcosis analytics** | **86%** | Planner + `.ccrPlanned` real; logbook simulated + footnotes | |
| **CNS / OTU readiness** | **91%** | NOAA/Lambertsen integrated; CCR setpoint path added | |
| **Checklist / equipment** | **72%** | OC gas sync strong; CCR template lacks diluent/bailout roles | |
| **PDF / share math output** | **82%** | OC + CCR PDF; CCR math text untested | |
| **Watch companion math/runtime** | **95%** | Depth/reminders tested; **no CCR runtime** (safe) | |
| **Sync / data math integrity** | **81%** | Generic CloudSync; CCR persistence untested E2E | |

### Release gates

| Gate | Status |
|---|---|
| **Compile / internal use** | **PASS** — builds green, 509 tests |
| **Internal TestFlight (algorithm)** | **PASS with caveats** — document CCR reference-only + external QA pending |
| **External TestFlight** | **BLOCKED** — physical iCloud two-device, paired Watch, CCR external validation |
| **App Store** | **BLOCKED** — same + App Store legal/screenshot review |

**TestFlight blockers:** External Bühlmann/CCR profile validation; iCloud two-device merge QA; CCR bailout heuristic not switch-simulated; tissue trace OC replay mismatch.

**App Store blockers:** All TestFlight blockers + certified-decompression wording audit on marketing materials.

---

## B. Algorithm Inventory (Phase 1)

### iOS Planner — Open Circuit

| Feature | Status | Primary files |
|---|---|---|
| Base / Deco / Technical modes | Implemented | `PlannerModePolicy.swift`, `PlannerModeLimits.swift` |
| Bühlmann ZHL-16C + GF | Implemented | `BuhlmannEngine.swift`, `BuhlmannTissueModel.swift` |
| Ratio Deco (heuristic) | Implemented | `RatioDecoPlanner.swift`, `RatioDecoValidator.swift` |
| Bühlmann vs Ratio comparison | Implemented | `PlannerService.makeRatioDecoBundle` |
| Ratio Deco presets | Implemented | `RatioDecoModels.swift` |
| Air / EAN / Trimix / O2 gas selector | Implemented | `GasPlan.swift`, `PlannerGasEditingSupport.swift` |
| PPO₂ step 0.1 | Implemented | `GasMixValidator`, UI steppers |
| MOD auto-update + Dalton validation | Implemented | `GasMixValidator.modMeters`, `PlannerMODValidator` |
| Switch depth clamp to MOD | Implemented | `GasPlanInput.normalizeSwitchDepthsToMOD` |
| Back / Travel / Deco / Bailout roles | Implemented | `GasRole`, `PlannerCylinderEntry` |
| Base no-deco via Bühlmann NDL | Implemented | `PlannerModeLimits.enforceInputLimits` |
| Deco max/average depth ≤ 40 m | Implemented | `PlannerModeLimits.validateDecoDepthLimits` |
| Technical unrestricted depth | Implemented | Policy bypass |
| CNS / OTU full plan + descent/bottom | Implemented | `OxygenExposureModels.swift`, `GasPlanningService` |
| Tissue analytics (planned) | Implemented | `TissueAnalyticsService.buildFromPlanner` |
| Gas consumption / SAC | Implemented | `ScheduleGasConsumptionService`, `GasPlanningService` |

### iOS Planner — CCR / Rebreather (NEW @ `3388790`)

| Feature | Status | Primary files |
|---|---|---|
| CCR mode (4th planner mode) | Implemented | `PlannerMode.ccr`, `PlannerRootView` |
| Setpoint low / high + switch depth | Implemented | `CCRSetpointProfile`, `CCRPlannerView` |
| Manual shallow-ascent low setpoint | Implemented | `CCRSetpointProfile.useLowSetpointOnShallowAscent` |
| Manual runtime segments field | **Model only — unused in engine** | `CCRSetpointProfile.runtimeSegments` |
| CCR diluent (Air/EAN/Trimix) | Implemented | `CCRDiluent`, `CCRPlanValidator` |
| CCR bailout gas list | Implemented | `CCRBailoutGas`, validator MOD checks |
| CCR inspired gas (setpoint PPO2) | Implemented | `CCRInspiredGasModel.inspiredPressures` |
| CCR Bühlmann deco loop | Implemented | `CCRPlannerEngine` (not `BuhlmannEngine.plan`) |
| CCR bailout scenario calculator | Implemented (heuristic) | `CCRBailoutScenarioCalculator` |
| CCR CNS/OTU (setpoint-based) | Implemented | `CCROxygenExposureIntegration` |
| CCR tissue analytics | Implemented | `TissueAnalyticsService.buildFromCCRPlan` |
| CCR PDF export | Implemented | `CCRPlannerPDFBuilder`, `PDFExportService.exportCCRPlan` |
| CCR safety disclaimers EN/IT | Implemented | Localizable.strings, UI + PDF |
| Scrubber / loop volume fields | **Stored only — no math** | `CCRPlanInput.loopVolumeLiters` |
| Average depth in CCR UI | **Collected — unused in engine** | `CCRPlanInput.averageDepthMeters` |

### iOS Checklist / Equipment

| Feature | Status |
|---|---|
| REC / TEC templates | Implemented |
| **CCR template (18 items)** | Implemented (`EquipmentStore`) |
| GAS switch conditional fields | Implemented |
| Planner ↔ Checklist guided sync | Implemented (OC cylinders) |
| **CCR Diluent / CCR Bailout gas roles** | **Not in `GasRole` enum** |
| DIR / READY badge logic | Implemented |

### iOS Logbook / Analytics

| Feature | Status |
|---|---|
| Manual dive entry | Implemented |
| **CCR logbook metadata fields** | Implemented (`ManualDiveEditorView`, `CCRLogbookMetadata`) |
| Tissue analytics (recorded/planned/simulated/**ccrPlanned**) | Implemented |
| CSV Subsurface export/import | Implemented + CCR `# dirdiving_ccr_*` lines |
| Manual profile synthetic builder | Implemented |

### iOS PDF / Share

| Export | Math content |
|---|---|
| OC Plan / Briefing / Checklist / Dive Pack | TTS, stops, gases, MOD, CNS, Ratio Deco section |
| **CCR Plan PDF** | Setpoints, diluent, bailout, schedule, CNS/OTU, PPN2/END max |
| Share sheet | Precomputed values only (no PDF-layer recalculation) |

### Apple Watch (math/runtime scope)

| Feature | Status |
|---|---|
| Auto dive start > 1 m | Implemented |
| Depth / runtime / avg / max | Implemented |
| Ascent rate | Implemented |
| Configurable depth alarm (default off, 40 m default threshold) | Implemented |
| Runtime alarm (default 30 min) | Implemented |
| Dive reminders (up to 10, recurring/single) | Implemented |
| **CCR / setpoint / loop monitoring** | **Absent — by design** |

### Common / Shared

| Feature | Status |
|---|---|
| Metric / imperial | Implemented (`IOSUnitPreference`, `Formatters`) |
| EN/IT localization for math labels | Implemented (minor IT gaps) |
| CloudSync KVS | Implemented; guarded when no iCloud account (`b9f54a3`) |
| Watch sync payloads | Implemented |

---

## C. Planner Mode Audit (Phase 3)

### Base — **92%**

- Projection strips to single bottom cylinder + standard GF (`PlannerModePolicy.activePlanInput`)
- `PlannerModeLimits` clamps to NDL-compatible depth/time
- Trimix bottom rejected in Base validation
- Bühlmann NDL enforcement via `.basicNoDecoLimitExceeded`
- CCR state does not affect Base (separate mode)
- Tests: `PlannerModePolicyTests`, `PlannerModeLimitsTests`

### Deco — **91%**

- Max depth ≤ 40 m, average depth ≤ 40 m enforced
- Trimix rejected; deco gas set projected
- Hidden Technical/CCR data does not affect Deco (separate `PlannerStore` mode)
- Tests: `PlannerModeLimitsTests`, depth limit validators

### Technical — **93%**

- Full multigas preserved; MOD/PPO₂ validations active
- Travel/deco/bailout logic active
- No artificial depth caps
- Tests: `BuhlmannMultigasPlannerTests`, `BailoutGasTests`

### CCR / Rebreather — **76%**

- **Not a decorative flag** — dedicated `CCRPlannerService` / `CCRPlannerEngine`
- OC `PlannerService.makePlan` bypassed when `mode.isCCR` (`PlannerStore.refreshCCRPlan`)
- Setpoint/diluent/bailout affect actual plan input and output
- Switching CCR ↔ OC via mode selection resets planning path (isolated state)
- Gaps: tissue trace OC replay; bailout heuristic; unused manual setpoint segments
- Tests: `CCRPlannerTests` (11 tests)

### Planner mode readiness aggregate — **90%**

---

## D. Bühlmann Mathematical Assessment (Phase 2)

### Implementation evidence

- ZHL-16C constants: `BuhlmannConstants.swift` (half-times, a/b N2/He)
- Schreiner loading: `BuhlmannTissueModel.swift`, `BuhlmannSchreinerEquationTests`
- GF interpolation: `BuhlmannEngine.gfAtDepth`, `BuhlmannGradientFactorTests`
- Ceiling / NDL / deco schedule: `BuhlmannEngine.swift`, `BuhlmannNDLTests`, `BuhlmannCeilingTests`
- Multigas + trimix helium: `BuhlmannMultigasPlannerTests`, `BuhlmannTrimixHeliumTests`
- Golden/reference fixtures: `BuhlmannGoldenFixtureTests`, `BuhlmannReferenceFixtureTests`
- External validation metadata tracked: `BuhlmannExternalValidationMetadataTests`

### Verification

| Check | Result |
|---|---|
| No fake/static Bühlmann outputs in planner | **PASS** |
| Charts labelled from engine trace | **PASS** (OC) |
| Non-certified wording | **PASS** — reference-only disclaimers |
| External third-party validation | **PENDING** |

**Bühlmann readiness: 94%**

---

## E. CCR / Rebreather Mathematical Assessment (Phase 2B)

### CCR model separation — **PASS**

```
Planner tab → PlannerModeSelectionView
  ├─ OC: PlannerView → PlannerService → BuhlmannEngine
  └─ CCR: CCRPlannerView → CCRPlannerService → CCRPlannerEngine + CCRInspiredGasModel
```

- `PlannerModePolicy.validate` skips OC validation for `.ccr`
- `PlannerStore.applyInputToPlanningOutputs` routes `mode.isCCR` to `refreshCCRPlan()`
- CCR tissue loading uses `ccrLoadedLinearDepth` / `ccrLoadedConstantDepth` — **not** OC `BuhlmannGas.inspiredPressure`

### Setpoint math — **85%**

**Correct:**
- `PPO2 = setpointBar` when ambient > setpoint (`CCRInspiredGasModel.inspiredPressures`)
- Inert = `(ambient − setpoint) × diluent fraction`
- Validator bounds: 0.5–1.7 bar (`CCRPlanValidator.minimumSetpointBar` / `maxPPO2Bar`)
- Low < high; surface ambient-below-setpoint guard
- Shallow-ascent manual low setpoint during ascent (`activeSetpointBar(depthMeters:isAscent:)`)
- CNS/OTU via `oxygenFraction = min(1, setpoint/ambient)` override

**Gaps (P1/P2):**
- `CCRSetpointProfile.runtimeSegments` unused in engine (P1-002)
- GF validation mislabeled as `.invalidSetpoint` (P2-001)
- No depth-specific high-setpoint feasibility beyond global 1.7 bar cap

### Diluent math — **78%**

**Correct:**
- Pure O2 diluent blocked
- Hypoxic diluent at max depth check
- Trimix helium path in inspired gas + `ccrLoaded*`

**Gaps:**
- CCR path omits water vapor subtraction (differs from OC Bühlmann)
- `labelGas` synthetic OC replay overestimates ppN2 vs true CCR model (~25% at 30 m example)
- Thin trimix diluent test coverage

### Bailout math — **55%**

**Correct preflight:**
- Bailout MOD via `GasMixValidator.modMeters`
- Switch depth clamped to MOD + 0.5 m tolerance
- O2 bailout switch depth ≤ 6 m rule

**Heuristic scenario calculator:**
- SAC × ascent + crude deco estimate — **not** Bühlmann-derived
- Not switch-simulated during ascent
- Reference-only status appropriate

### CCR Bühlmann integration — **80% (deco) / 45% (tissue trace UI)**

- Custom deco loop with standard ceiling/GF on `ccrLoaded*` state — **authoritative for TTS/stops**
- `BuhlmannTissueHistorySampler` replays segments with **OC loading** + `labelGas` — **diverges from engine final state** (P1-001)

### CCR CNS/OTU — **82%**

- Full plan + descent/bottom CNS via `CCROxygenExposureIntegration`
- CNS timeline cumulative from exposure segments
- Descent/bottom threshold warning integrated
- Missing golden fixtures vs external references

### CCR narcosis/END — **84%**

- END from CCR ppN2 in engine timeline and `TissueAnalyticsService.buildFromCCRPlan`
- Not using setpoint as narcotic gas — **correct**

### CCR output truthfulness — **PASS**

- UI: `ccr.reference_estimate_only`, `ccr.safety.disclaimer`
- PDF: `ccr.pdf.disclaimer`
- No live loop PPO2 monitoring claims
- No certified CCR controller claims

### CCR sub-readiness summary

| Sub-area | Readiness |
|---|---:|
| CCR mode | 76% |
| CCR setpoint | 85% |
| CCR diluent | 78% |
| CCR bailout | 55% |
| CCR Bühlmann deco | 80% |
| CCR tissue (deco engine) | 80% |
| CCR tissue (trace/UI) | 45% |
| CCR CNS/OTU | 82% |
| CCR narcosis/END | 84% |
| CCR export/share | 82% |
| **CCR external validation** | **PENDING** |

---

## F. Ratio Deco Assessment (Phase 5)

- Explicitly heuristic/comparative — disclaimers in UI and PDF
- Bühlmann remains primary schedule when `decompressionMethod == .buhlmann`
- `RatioDecoValidator` cross-checks ceiling/MOD violations
- Presets 1:1 / 2:1 / custom with persistence
- PDF + Dive Pack integration tested (`IOSMainAlgorithmMathRemediationTests`)

**Gaps:**
- **P1 RD-CCR-API:** `RatioDecoPlanner` blocks `.base` only — no `.ccr` guard at API level; isolation is UI/routing only
- Heuristic stop times — not tissue-loading-derived
- No Ratio Deco on CCR in UI (correct); direct API call could still produce bundle

**Ratio Deco readiness: 78%**  
**Ratio Deco CCR compatibility: 95%** (UI-isolated; API gap only)

---

## G. Gas / MOD / PPO₂ / SAC Assessment (Phase 4)

| Check | Evidence | Result |
|---|---|---|
| MOD = maxPPO2 / FO2 × ambient | `GasMixValidator.modMeters` | PASS |
| Switch depth floor to MOD | `normalizeSwitchDepthsToMOD`, 12 clamp tests | PASS |
| PPO₂ step 0.1 | UI + validator tolerance centralized | PASS |
| O2 locks 100/0/0 | `GasMixKind.oxygen` | PASS |
| N2 = 100 − O2 − He | `GasMix` normalization | PASS |
| Bühlmann receives current UI gas | `PlannerService.makePlan` after projection | PASS |
| CCR setpoint ≠ FO2 MOD | Separate validator (`minimumSetpointBar = 0.5`) | PASS |
| CCR bailout MOD | `CCRPlanValidator` | PASS |

**Gas logic readiness: 86%**  
**CCR gas logic readiness: 78%**  
**MOD / PPO₂ / Dalton readiness: 91%**  
**Switch depth clamp readiness: 89%**  
**Unit conversion readiness: 85%** (P1 imperial CCR switch depth in manual dive — see M)

---

## H. Tissue & Narcosis Assessment (Phase 6)

### Sources (`TissueAnalyticsSource`)

| Source | Builder | Fidelity |
|---|---|---|
| `.planned` | OC planner tissue history | Real engine trace |
| `.ccrPlanned` | CCR plan + ppN2 timeline | Mixed — trace OC replay, ppN2 from engine |
| `.recorded` | Logbook replay | Real samples |
| `.simulated` | Manual / fallback | Labelled simulated |
| `.insufficientData` | < 2 samples | Empty state |

### Verification

- 16 compartments C1–C16: **PASS** (`TissueAnalyticsServiceTests.testPlannerTraceGeneratesSixteenCompartments`)
- Controlling compartment, M-value/GF-relative loading: **PASS**
- PPN2 / END tooltips: **PASS**
- CCR presentation test: **PASS** (`testCCRPlannerTraceGeneratesPresentation`)
- Logbook trimix without switch history → simulated: **PASS** (documented)

**Tissue loading readiness: 86%**  
**Narcosis / END readiness: 83%**  
**CCR tissue readiness: 70%** (trace mismatch)  
**CCR narcosis readiness: 84%**

---

## I. CNS / OTU Assessment (Phase 7)

- NOAA piecewise CNS + OTU ramp: `OxygenExposureModels.swift`
- Full plan + descent/bottom split: `GasPlanningService`, `CNSDescentBottomTests` (14 tests)
- 15% descent+bottom rule: `PlannerCNSDescentBottomCheckSettings`
- Carryover / surface interval: `RepetitiveDivePlannerService`
- CCR setpoint path: `CCROxygenExposureIntegration` — **PASS**
- CCR CNS timeline tracks full plan: **PASS** (`CCRPlannerTests.testCNSTimelineTracksExposure`)

**CNS/OTU readiness: 91%**  
**CCR CNS/OTU readiness: 82%**

---

## J. Charts / Tables Assessment (Phase 8)

### Open Circuit (PlannerView results)

- Depth profile, ascent table, Bühlmann curve, gas bars, Ratio Deco overlay — engine-backed
- PIANO / schedule tables from `PlannerService` output

### CCR (CCRPlanResultView)

| Chart | Data source | Truthful? |
|---|---|---|
| Depth profile | `depthProfilePoints` from engine segments | Yes |
| PPO2 timeline | `ppO2Timeline` (setpoint-based) | Yes |
| PPN2 timeline | `ppN2Timeline` | Yes |
| END timeline | `endTimeline` | Yes |
| Gas density | `gasDensityTimeline` (approximation labelled) | Yes (approx) |
| CNS timeline | `cnsTimeline` cumulative exposure | Yes |
| Bailout scenarios | Heuristic calculator | Labelled reference |

**Chart/table mathematical truthfulness: 88%**  
**CCR chart readiness: 85%**

---

## K. Checklist / Equipment Assessment (Phase 9)

- REC/TEC/custom templates: **PASS**
- CCR template 18 items (rebreather, loop, scrubber, O2/diluent/bailout cylinders): **PASS**
- GAS conditional fields: **PASS**
- Planner ↔ Checklist sync for OC cylinders: **PASS** (`ChecklistPlannerSyncMapperTests`)
- DIR badge required items: **PASS** (`DIRChecklistConfigurationEvaluatorTests`)
- **Gap:** CCR template gas rows lack `gasRole` / mix; no CCR Diluent role in `GasRole` enum
- **Gap:** Planner CCR → checklist sync not implemented (OC-only mapper)

**Checklist math/gas readiness: 72%**  
**CCR checklist readiness: 65%**

---

## L. PDF / Share Assessment (Phase 10)

| Export | Gate | Math fidelity |
|---|---|---|
| OC Plan | Safety ack + valid plan + no MOD issues | Engine values via Formatters |
| Briefing | Same | TTS tested in PDF text |
| Checklist | Non-empty checklist | YES/NO fields, switch depth |
| Dive Pack | Plan + briefing + checklist | Ratio section tested |
| **CCR Plan** | Safety ack + valid CCR validation | Setpoints, schedule, CNS/OTU, PPN2 max |

**Gaps:**
- No CCR Dive Pack PDF (P2-001)
- CCR PDF math not asserted in tests (P2-002)
- `canExportCCRPlan` does not block `.unavailable` buhlmann state (P2-003)
- Bailout scenario status uses raw `status.rawValue` in PDF (P2-007)

**PDF/share mathematical output readiness: 82%**  
**CCR PDF/share readiness: 80%**

---

## M. Logbook / Manual Dive / Import Export Assessment (Phase 11)

- Manual dive synthetic profile: **PASS** (`ManualDiveEditorLogicTests`)
- CCR metadata fields when `gasLabel == .ccr`: **PASS**
- CSV CCR `# dirdiving_ccr_*` export/import: **PASS** (`testCCRMetadataRoundTrip`)
- `DiveProfileMath.normalizedSession` preserves `ccrLogbookMetadata`: **PASS** (@ `3388790`)

**P1-001 Imperial bug:** CCR setpoint switch depth stepper shows `m`/`ft` suffix but stores value directly as meters without `ManualDiveEditorDefaults.depthMeters` conversion (`ManualDiveEditorView.swift:162,184` vs depth fields:349–350).

**Gaps:**
- Partial CSV round-trip test (5 CCR note fields + switch depth untested)
- No CCR setpoint validation in manual dive (low ≤ high)
- `DiveDetailView` does not surface CCR metadata post-save

**Manual dive math readiness: 75%**  
**Import/export readiness: 85%**  
**CCR logbook readiness: 78%**

---

## N. Apple Watch Companion Assessment (Phase 12)

- **Zero CCR/rebreather/setpoint code in Watch target** — cannot imply live CCR monitoring
- Auto start > 1 m, depth metrics, ascent rate: tested (`DiveManagerAlgorithmIntegrationTests`)
- Depth alarm configurable, default threshold 40 m: tested
- Runtime alarm default 30 min: `WatchAlarmDefaults`
- Dive reminders: `DiveReminderEngineTests` (11), `DiveReminderIntegrationTests` (5)
- TTV informational only — not NDL/TTS

**Watch math/runtime readiness: 95%**  
**Watch CCR display safety readiness: 100%** (feature absent = safe)

---

## O. Sync / Persistence Assessment (Phase 13)

| Store | CCR support | Notes |
|---|---|---|
| `PlannerStore` | `PlannerState.ccrInput` Codable | CloudSync key `dirdiving_ios_experimental_planner_state` |
| `DiveLogStore` | `ccrLogbookMetadata` on session | Per-session merge before cloud write |
| `CloudSyncStore` | Generic JSON LWW | iCloud guarded when no account (`b9f54a3`) |
| CSV import/export | CCR metadata lines | Round-trip partial test |

**Gaps:** No dedicated `ccrInput` cloud round-trip test; cloud merge does not fuse divergent profiles silently (by design — conflict UI exists for sessions)

**Sync/data mathematical integrity readiness: 81%**  
**CCR persistence readiness: 78%**

---

## P. Localization / Accessibility for Math Outputs (Phase 14)

- EN/IT CCR strings: setpoint, diluent, bailout, disclaimers, PDF keys — **PASS**
- Tissue analytics `.ccrPlanned` source footnote — **PASS**
- Minor IT English leftovers on some equipment CCR items (P3-002)
- Chart accessibility summaries present in tissue analytics views
- CCR setpoint controls accessible via standard SwiftUI controls

**Localization readiness for math outputs: 88%**  
**Accessibility readiness for math outputs: 86%**

---

## Q. Findings by Priority (Phase 18)

### P0 — Safety-critical

*None identified* in static review or 509 automated tests. CCR reference-only positioning preserved. Watch has no live CCR monitoring.

### P1 — Math correctness / release-hard

| ID | Title | Target | Mode | File(s) |
|---|---|---|---|---|
| P1-001 | CCR tissue trace replays OC loading, diverges from `ccrLoaded*` deco state | iOS | CCR | `CCRPlannerEngine.swift`, `BuhlmannTissueHistory.swift` |
| P1-002 | `runtimeSegments` manual setpoint model unused in engine | iOS | CCR | `CCRModels.swift`, `CCRPlannerEngine.swift` |
| P1-003 | Bailout scenario calculator is SAC heuristic, not switch-simulated OC | iOS | CCR | `CCRBailoutScenarioCalculator.swift` |
| P1-004 | CCR inert model omits water vapor vs OC Bühlmann | iOS | CCR | `CCRInspiredGasModel.swift` |
| P1-005 | Imperial CCR switch depth stored as meters without conversion | iOS | Shared | `ManualDiveEditorView.swift:162,184` |
| P1-006 | Ratio Deco API lacks `.ccr` guard (UI-isolated only) | iOS | Shared | `RatioDecoPlanner.swift`, `PlannerService.swift` |

### P2 — UX clarity / validation / test gaps

| ID | Title | Severity area |
|---|---|---|
| P2-001 | No CCR Dive Pack PDF | PDF |
| P2-002 | CCR PDF math fidelity untested | Tests |
| P2-003 | `canExportCCRPlan` omits `.unavailable` gate | PDF |
| P2-004 | CSV CCR round-trip test incomplete | Tests |
| P2-005 | CCR checklist gas rows lack roles/mixes | Checklist |
| P2-006 | No `GasRole` for CCR Diluent | Checklist |
| P2-007 | CCR PDF bailout status not localized | PDF |
| P2-008 | No CCR setpoint validation in manual dive editor | Logbook |
| P2-009 | No `ccrInput` planner persistence round-trip test | Sync |
| P2-010 | `DiveDetailView` does not display CCR metadata | Logbook UI |
| P2-011 | `averageDepthMeters` unused in CCR engine | CCR |
| P2-012 | `enforceInputLimits` only in PlannerStore, not PlannerService | OC API |

### P3 — Documentation / polish

| ID | Title |
|---|---|
| P3-001 | GF validation mislabeled as setpoint error in CCR validator |
| P3-002 | Minor IT localization English leftovers on CCR equipment |
| P3-003 | END path split: gas tile vs tissue analytics ppN2-only |
| P3-004 | External Bühlmann/CCR validation still pending (process) |

### P4 — Nice-to-have

- CCR gas density documented as approximation (already labelled)
- Scrubber duration / loop volume modeling (future)
- CCR ↔ checklist guided sync

---

## R. Edge Case Matrix (selected)

| Scenario | Expected | Observed |
|---|---|---|
| Base plan exceeds NDL | Blocked / warning | Blocked via validation |
| Deco depth 41 m | Rejected | `.decoDepthLimitExceeded` |
| Switch depth > MOD | Floored to MOD | PASS + 12 tests |
| Pure O2 CCR diluent | Blocked | PASS |
| Ambient < low setpoint at surface | Warning/block | PASS |
| CCR mode + Ratio Deco API call | Should reject | **Not blocked at API** (P1-006) |
| No iCloud account | Local-only, no KVS error | PASS @ `b9f54a3` |
| Manual dive max < avg depth | Validation error | PASS |
| Imperial CCR switch depth 66 "ft" | Should store ~20 m | **Stores 66 m** (P1-005) |
| Trimix logbook without switch history | Simulated analytics | PASS + footnote |

---

## S. Test Plan (Phase 19 — selected high-priority)

| Priority | Feature | Input | Expected | Pass criteria |
|---|---|---|---|---|
| P0 | CCR ppN2 at 30 m air SP 1.3 | Hand calc vs engine | Match ±0.05 bar | Unit test |
| P0 | CCR tissue trace vs engine state | Same plan | Compartment loads match | Currently **would fail** — documents P1-001 |
| P1 | Ratio Deco + mode `.ccr` | API call | Reject or empty | Guard + test |
| P1 | Imperial CCR switch depth | 66 ft pref | ~20 m stored | Manual dive test |
| P1 | CCR PDF TTS | Known plan | PDF text contains TTS | PDF text test |
| P1 | CSV full CCR round-trip | All 10 fields | Import equals export | Extend existing test |
| P2 | CCR bailout MOD breach | Switch > MOD | Validation block | Unit test |
| P2 | CCR planner cloud round-trip | Save/load ccrInput | Identical input | Integration test |
| P2 | External Bühlmann profile | Published fixture | Schedule within tolerance | **Manual/external** |
| P2 | iCloud two-device CCR planner | Two simulators | Merge without data loss | **Physical QA** |
| P2 | Paired Watch + iOS sync | Real devices | Depth/runtime values match | **Physical QA** |

---

## T. Readiness Matrix (Phase 20 — mandatory)

| Feature | Readiness |
|---|---:|
| Bühlmann | 94% |
| CCR / Rebreather | 76% |
| CCR Setpoint | 85% |
| CCR Diluent | 78% |
| CCR Bailout | 55% |
| Ratio Deco | 78% |
| Gas Planning | 86% |
| MOD / PPO2 / Dalton | 91% |
| Switch Depth Clamp | 89% |
| Tissue Loading | 86% |
| Narcosis / END | 83% |
| CNS / OTU | 91% |
| Checklist Gas Sync | 72% |
| Manual Dive Math | 75% |
| PDF / Share Math Output | 82% |
| CSV / Subsurface Math Output | 85% |
| Watch Math Runtime | 95% |
| Sync / Persistence Math Integrity | 81% |
| Unit Conversion | 85% |
| **Overall Math Readiness** | **87%** |

---

## U. Prioritized Roadmap

1. **Must fix before compile/use** — None (builds green)
2. **Must fix before internal TestFlight** — Document CCR reference-only; fix P1-005 imperial switch depth; consider P1-001 tissue trace alignment
3. **Must fix before external TestFlight** — P1-001, P1-003, P1-006; external Bühlmann validation; iCloud two-device QA; CCR profile external check
4. **Must fix before App Store** — All external QA matrices; marketing non-certified review
5. **Post-release** — Scrubber modeling, CCR Dive Pack PDF, checklist CCR roles, manual setpoint segments

---

## V. Final Verdict

| Question | Answer |
|---|---|
| Mathematically ready? | **Yes for internal reference use at 87%** — not for certified decompression claims |
| Base/Deco/Technical modes real? | **Yes** — enforced in policy, limits, engine, tests |
| CCR mathematically coherent? | **Mostly yes for deco schedule** — tissue trace + bailout weaken coherence |
| CCR clearly reference-only? | **Yes** — UI, PDF, docs disclaimers present |
| Ratio Deco safely comparative? | **Yes in UI** — API `.ccr` guard missing |
| Bühlmann truthful? | **Yes** — real engine, 118+ Bühlmann tests |
| Tissue/narcosis charts truthful? | **Yes for OC planned; CCR trace overstated** |
| CNS/OTU correct? | **Yes** — including CCR setpoint path |
| Checklist ready for gas/math sync? | **OC yes; CCR partial** |
| PDFs/share mathematically truthful? | **Yes by design** — CCR PDF tests thin |
| Watch reminders/start dive ready? | **Yes** |
| Sync/data ready? | **Yes locally; iCloud physical QA pending** |
| Internal TestFlight? | **Yes with documented CCR limitations** |
| External TestFlight? | **No** — external validation + P1 items |
| App Store? | **No** |
| What blocks 100%? | CCR tissue trace OC replay; bailout heuristic; external validation; physical QA; imperial CCR manual depth; API Ratio Deco guard; checklist CCR roles |

---

## Documentation cross-reference (Phase 16)

| Document | Status |
|---|---|
| `Docs/DIR_DIVING_CCR_PLANNER_IMPLEMENTATION_REPORT.md` | Current @ 100% software deliverables |
| `Docs/SAFETY_DISCLAIMER.md` | Aligns with non-certified positioning |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Should note CCR `# dirdiving_ccr_*` keys (verify update) |
| Prior `IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md` | OC remediation complete; CCR post-dates |

---

## Test coverage summary (Phase 15)

| Suite area | Approx. tests | CCR coverage |
|---|---:|---|
| Bühlmann `Buhlmann*.swift` | 118 | N/A |
| Planner mode policy/limits | 27 | CCR skip tests |
| Ratio Deco | 10 | No `.ccr` rejection |
| CCR planner | 11 | Core paths |
| Tissue analytics | 10 | `.ccrPlanned` test added |
| PDF export | 13 | CCR generation smoke |
| CSV metadata | 6 | Partial CCR round-trip |
| Manual dive | 8 | No CCR |
| CNS/OTU | 40+ | OC primary |
| **Total iOS** | **509** | Growing |

**Flagged missing tests:** CCR ppN2 golden values; CCR tissue trace vs engine; Ratio Deco `.ccr` API; CCR PDF text; full CSV CCR fields; manual dive CCR imperial; `ccrInput` cloud round-trip; CCR bailout validator scenarios.

---

*Audit performed read-only per command specification. No code, logic, sync, or Watch runtime was modified. External validation and physical QA items are explicitly marked PENDING — not passed.*
