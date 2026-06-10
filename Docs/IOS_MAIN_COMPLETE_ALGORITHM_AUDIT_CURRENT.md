# DIR Diving iOS Complete Algorithm / Planner Readiness Audit — Current (CCR Updated)

**Audit date:** 2026-06-09  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `984a69b` (`984a69bc1f6e1c50b11cc2c02c0057b737a3c4c5`)  
**HEAD subject:** `fix(watch): harden compile-root guard to ignore comment-only tokens.`  
**Scope:** iOS Companion MAIN (`DIRDiving iOS`) only — Check_Math_iOS + v2 extensions + CCR / Rebreather  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`

**Integrated context (read, not re-executed):**

| Document | Status | Role in this audit |
|---|---|---|
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | Present @ `cc4d783` | Prior CCR-focused comprehensive baseline (91%) |
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_REMEDIATION_REPORT.md` | Present @ `d756a89` | Bühlmann comprehensive remediation deltas |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Present | Pre-remediation math baseline |
| `Docs/CCR_REBREATHER_LIMITATIONS.md` | Present | CCR scope / limitations |
| `Docs/CCR_REBREATHER_EXPORT_POLICY.md` | Present | CCR PDF/CSV export policy |
| `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` | Present | External CCR validation slots (**PENDING**) |
| `Docs/CCR_REBREATHER_VALIDATION_EVIDENCE.md` | Present | Evidence tracker (**mostly empty**) |
| `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | Present | External Bühlmann comparison (**PENDING**) |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Present | CSV policy; external steps **PENDING** |
| `Docs/WATCH_CSV_EXPORT_POLICY.md` | Present @ `984a69b` | Watch/iOS CSV divergence (Watch has no CCR metadata) |

**Actions in this audit pass:**

- Created this report only (read-only audit).
- No Swift, UI, localization, algorithm, sync, security, or test production code modified.
- No commit or push performed.

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified reference planner)**

MAIN @ `984a69b` delivers a coherent **dual-planner architecture**: open-circuit **Bühlmann ZH-L16C + GF** (Base / Deco / Technical), an isolated **CCR / Rebreather reference planner** (setpoint-inspired gas, dedicated engine/validator, heuristic bailout scenarios), **Ratio Deco as comparative heuristic only** (OC deco/technical; explicitly blocked in CCR mode), tissue/narcosis analytics with source footnotes (including `.ccrPlanned`), checklist↔planner gas sync (OC wired; CCR mapper present), manual dive entry with CCR logbook metadata, PDF/CSV export, and centralized unit conversion. macOS build and **540/540** iOS algorithm tests (13 skipped) pass on iPhone 17 Pro simulator.

**Not ready for:** certified decompression claims, certified CCR controller claims, external Bühlmann/CCR validation sign-off, iCloud two-device QA, paired Watch physical QA, Subsurface desktop round-trip sign-off, or App Store marketing without legal review.

### Readiness estimates

| Area | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall** | **92%** | High on OC + automated tests; medium on CCR external parity | External validation + physical QA |
| **Bühlmann (OC core)** | **94%** | High | External third-party profile comparison **PENDING** |
| **Ratio Deco** | **86%** | High on guardrails | Heuristic by design; OC-only; no CCR |
| **Gas Planning (OC)** | **90%** | High | Bailout schedule-only in Bühlmann engine |
| **Gas Roles** | **88%** | Medium-high | Checklist title inference edge cases |
| **MOD / PPO₂ / Dalton** | **93%** | High | PDF strict MOD vs validator asymmetry (documented) |
| **Tissue Loading** | **90%** | High | Logbook simulated segments footnoted |
| **Narcosis / END** | **88%** | Medium-high | CCR density estimator simplified |
| **Planner Modes** | **92%** | High | CCR isolated in `.ccr` mode |
| **Checklist Sync** | **82%** | Medium | **CCR export UI not wired** (mapper only) |
| **Manual Dive** | **88%** | Medium-high | Physical UX QA **PENDING** |
| **PDF / Share** | **90%** | High | CCR Dive Pack / Briefing OC-only by design |
| **CSV / Subsurface** | **85%** | Medium | External Subsurface validation **PENDING** |
| **Unit Conversion** | **92%** | High | Dual IOS/DIR stacks intentional |
| **CCR Overall** | **88%** | Medium-high | Heuristic bailout; external profiles **PENDING** |
| **Performance / Numerical** | **89%** | Medium | Long-profile stress partial |
| **Security / Privacy** | **88%** | Medium-high | iCloud opt-in visual QA **PENDING** |
| **Automated Tests** | **90%** | High | 540 XCTest; E2E/visual gaps |
| **Physical / External QA** | **45%** | — | Evidence folders mostly empty |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **Almost ready** — build + 540 tests green @ `984a69b` |
| Internal TestFlight (algorithm) | **Conditional yes** — document CCR reference-only + bailout heuristic + non-certified posture |
| External TestFlight / RC | **Not yet** — external math + iCloud + Watch physical QA **PENDING** |
| App Store (algorithm scope) | **Not yet** — same + legal/marketing disclaimer audit |
| Certified decompression planner | **Never** — remain non-certified reference-only |
| Certified CCR controller / life-support | **Never** — planning reference only |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No safety-critical algorithm defect identified |
| HIGH | 0 | No P0/P1 code blockers at HEAD |
| MEDIUM | 4 | CCR checklist UI gap; external validation; iCloud QA; Subsurface external |
| LOW | 6 | `runtimeSegments` reserved; loop volume unused; SCR absent; checklist inference; PDF MOD asymmetry; performance stress |
| INFO | 5 | Dual unit stacks; `rebreatherModel` metadata; Ratio Deco heuristic; Watch CSV divergence; narcosis O₂ weighting |

---

## B. Phase 0 — Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `984a69b` |
| Working tree at audit start | Clean |
| Remote | `origin/main` aligned after `git fetch` |
| iOS target | `DIRDiving iOS` (`project.yml`) |
| iOS test target | `DIRDiving iOS Algorithm Tests` |
| Watch runtime | **Out of scope** — not modified; referenced for sync/CSV policy only |

### Experimental exclusions (`project.yml`)

Confirmed excluded from `DIRDiving iOS`:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

### Build / test commands (exact)

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Build / test results

| Step | Result |
|---|---|
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build | **PASS** |
| `DIRDiving iOS Algorithm Tests` | **PASS** — **540 executed**, 13 skipped (keychain-dependent Watch sync), **0 failures** |

### Directories inspected

`iOSApp/Algorithms/Buhlmann/`, `iOSApp/Services/CCR/`, `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/RatioDecoPlanner.swift`, `iOSApp/Models/GasPlan.swift`, `iOSApp/Models/CCR/`, `iOSApp/Utils/PlannerModePolicy.swift`, `iOSApp/Utils/GasMixValidator.swift`, `iOSApp/Services/PlannerMODValidator.swift`, `iOSApp/Utils/ChecklistPlannerSyncMapper.swift`, `iOSApp/Views/PlannerView.swift`, `iOSApp/Views/ManualDiveEditorView.swift`, `iOSApp/Services/PDF/`, `iOSApp/Services/SubsurfaceExportService.swift`, `Tests/iOSAlgorithmTests/` (76 files), `Docs/CCR_*`, `Docs/QA_EVIDENCE/`

---

## C. Phase 1 — Original Check_Math_iOS Audit (Consolidated)

### Original scope coverage

| Domain | Status | Notes |
|---|---|---|
| Planner calculations | **Verified** | OC via `BuhlmannEngine`; CCR via `CCRPlannerEngine` |
| Bühlmann ZHL-16C | **Verified** | 16 compartments, N₂ + He, GF, Schreiner, multigas |
| Gas calculations | **Verified** | `GasMixValidator`, MOD, PPO₂, roles |
| CNS / OTU | **Verified** | NOAA CNS + Lambertsen OTU; CCR setpoint path |
| MOD / PPO₂ | **Verified** | Environment-aware ambient pressure |
| Unit conversions | **Verified** | `IOSUnitConversions` central path |
| Logbook / statistics | **Verified** | `DiveLogStore`, analysis services |
| CSV / PDF export math | **Verified** | Metric depth policy; monotonic `time_seconds` |
| Sync / cloud numerics | **Verified** | Conflict merge tests; CCR JSON round-trip |
| Import transformations | **Verified** | `DiveImportService`, CCR metadata keys |

### Original readiness (inherited + revalidated)

| Metric | Estimate |
|---|---:|
| Original Check_Math_iOS algorithm readiness | **88%** (baseline @ pre-remediation audits) |
| Current consolidated algorithm readiness | **92%** |
| Original TestFlight blockers | External validation, physical QA (unchanged) |
| Original App Store blockers | Legal/marketing + above (unchanged) |

**Original blockers not closed by code alone:** external Bühlmann comparison, external CCR profiles, iCloud two-device QA, Subsurface desktop validation.

---

## D. Phase 2 — Bühlmann Core Readiness

### Files inspected

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`

### Verified

| Item | Status |
|---|---|
| ZHL-16C compartment constants | OK |
| N₂ and He half-times / a,b coefficients | OK |
| Tissue initialization + surface pressure | OK |
| Descent/ascent segment integration (Schreiner) | OK |
| GF low/high interpolation | OK |
| Ceiling + stop generation (3 m intervals) | OK |
| NDL at gfHigh | OK |
| Multigas switches + dwell | OK |
| OC plan consistency | OK — tested extensively |
| Finite guards / deterministic output | OK |
| No fake/static Bühlmann output | OK |

### CCR compatibility note

**Bühlmann core is OC-only.** CCR reuses `BuhlmannTissueState` ceiling/GF primitives via `CCRInspiredGasModel` (`ccrLoadedLinearDepth`) — not mixed into `BuhlmannEngine`.

### Gaps

- External third-party profile sign-off **PENDING**
- OC bailout cylinders are schedule-only; not simulated in engine (by design)
- No CCR paths inside `Algorithms/Buhlmann/*` (correct separation)

**Bühlmann readiness: 94%**  
**CCR Bühlmann integration readiness: 87%** (parallel engine, not unified)

---

## E. Phase 2B — Ratio Deco Engine

### Files inspected

- `iOSApp/Services/RatioDecoPlanner.swift`
- `iOSApp/Services/RatioDecoValidator.swift`
- `iOSApp/Models/RatioDecoModels.swift`
- `iOSApp/Views/RatioDecoPlannerViews.swift`

### Verified

| Item | Status |
|---|---|
| Heuristic only — Bühlmann primary | OK |
| Does not override safety-critical Bühlmann warnings | OK |
| Presets 1:1 / 2:1 / Custom | OK |
| MOD / PPO₂ / gas / ceiling validation | OK |
| Comparison mode + overlay chart | OK |
| PDF integration | OK |
| Base mode blocked | OK |
| **CCR mode explicitly blocked** | OK — `.unavailableInCCRMode` |

### CCR Ratio Deco status

**Not supported — by design.** `PlannerService.makeRatioDecoBundle` returns `nil` when `mode == .ccr`. Tests in `CCRMathRemediationTests` lock rejection.

**Ratio Deco readiness: 86%**  
**CCR Ratio Deco readiness: N/A (unsupported, correctly gated)**

---

## F. Phase 2C — Tissue & Narcosis

### Files inspected

- `iOSApp/Services/TissueAnalyticsService.swift`
- `iOSApp/Utils/TissueAnalyticsSupport.swift` / `NarcosisAnalyticsSupport`
- `iOSApp/Models/TissueAnalyticsTrace.swift`
- `iOSApp/Services/CCR/CCRTissueHistorySampler.swift`

### Verified

| Item | OC | CCR |
|---|---|---|
| 16 compartments | OK | OK via shared tissue state |
| N₂ / He loading | OK | OK via inspired inert fractions |
| Controlling compartment / GF-relative loading | OK | OK |
| Timeline + runtime depth | OK | OK — `.ccrPlanned` source |
| Active gas / PPO₂ / PPN₂ / END | OK | OK — setpoint drives PPO₂ |
| Model-backed planner charts | OK | OK |
| No fake static chart data | OK | OK — footnotes on simulated segments |

### CCR-specific notes

- PPO₂ = setpoint; inert from diluent when ambient > setpoint
- Bailout switches to OC gas model in analytics paths where implemented
- Narcosis uses ppN₂ timeline; CCR density estimator simplified
- O₂ narcotic weighting not applied on CCR path (ppN₂ only)

**Tissue readiness: 90%**  
**Narcosis readiness: 88%**  
**CCR tissue readiness: 88%**  
**CCR narcosis readiness: 86%**

---

## G. Phase 3 — Gas Planning

### Files inspected

- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/CCR/CCRModels.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/GasMixValidator.swift`

### OC verified

Back Gas, Travel, Deco, Bailout roles; stable IDs; mode projection; gas ledger; schedule consumption; planner + checklist + PDF integration.

### CCR verified

| Capability | Status |
|---|---|
| Circuit type enum (OC/CCR/SCR) | **Partial** — `diveMode: String = "ccr"`; no SCR |
| Diluent gas (O₂/He/N₂) | OK |
| Low/high setpoint + switch depth | OK |
| Oxygen setpoint validation | OK via `CCRPlanValidator` |
| Bailout OC gases + switch depths | OK |
| CNS/OTU from setpoint | OK |
| Inert loading under CCR model | OK |
| Scrubber duration / metabolic O₂ / diluent consumption | **Not implemented** (no fake estimates) |
| `loopVolumeLiters` | Stored; **unused by engine** |
| `runtimeSegments` (manual setpoint timeline) | **Reserved; ignored by engine** |

**Gas Planning readiness: 90%**  
**Gas Role readiness: 88%**  
**CCR Gas Planning readiness: 86%**  
**Bailout readiness: 80%** (heuristic SAC — `CCRBailoutScenarioResult.isHeuristic`)

---

## H. Phase 3B — MOD / Dalton Validation

### Files inspected

- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Services/CCR/CCRPlanValidator.swift`

### Verified

| Rule | Status |
|---|---|
| MOD auto recalculation unified | OK — `GasMixValidator.modMeters` |
| PPO₂ step 0.1 | OK |
| Air / EAN / Trimix editing rules | OK |
| Displayed MOD == used MOD | OK |
| Switch depth clamp to MOD | OK — tested |
| PlannerEnvironment altitude/salinity | OK |
| CCR diluent hypoxic / bailout MOD | OK |
| Setpoint PPO₂ bounds | OK |

### Gaps

- `PlannerInputValidator` skips bottom MOD in some merge paths; `PlannerService` / PDF export stricter — asymmetry documented, not a math bug
- GF policy `gfLow >= gfHigh` rejection (intentional strictness)

**MOD/PPO₂ readiness: 93%**  
**Dalton readiness: 92%**  
**CCR MOD/Dalton readiness: 91%**

---

## I. Phase 4 — Planner Mode Architecture

### Modes: Base / Deco / Technical / CCR

| Mode | Real inputs | Gas set | Bühlmann display | CCR |
|---|---|---|---|---|
| Base | Stripped deco, depth limits | Air/EAN | Hidden/simplified | **Not exposed** |
| Deco | 1 deco cylinder cap | No trimix | Simplified | **Not exposed** |
| Technical | Full multigas + travel/bailout | Full | Full + GF compare | **Not exposed** |
| CCR | `CCRPlanInput` parallel model | Diluent + bailout | Via CCR engine | **Isolated** |

CCR only in `.ccr` mode — not in Base/Deco/Technical. `PlannerModePolicy.validate(.ccr)` skips OC validation and adds `.validReference` only; CCR math gated by `CCRPlanValidator`.

**Planner Mode readiness: 92%**  
**CCR mode-integration readiness: 90%**

---

## J. Phase 5 — Planner ↔ Checklist

### Verified (OC)

Import/export candidates, fingerprint dedup, role inference (EN/IT), `applyExport` / `applyImport` wired in `PlannerView.swift`, PDF checklist YES/NO boxes, equipment templates.

### CCR status

| Item | Status |
|---|---|
| `ccrChecklistItems` / `applyCCRExport` mapper | OK — tested |
| CCR equipment template (`scrubber`, cells, etc.) | OK in `EquipmentStore` |
| **UI wiring for CCR export** | **GAP** — `applyCCRExport` called only from **tests**, not `PlannerView` (OC uses `applyExport` @ ~1748) |

**Checklist readiness: 85%**  
**Planner Sync readiness: 83%**  
**CCR Checklist readiness: 75%** (mapper ready; UX path missing)

---

## K. Phase 6 — Manual Dive

### Verified

`ManualDiveEditorView` + validation; synthetic profile; CCR metadata fields (setpoints, diluent, bailout labels, scrubber/O₂/loop notes); imperial round-trip; `CCRLogbookMetadata` persistence; CSV `# dirdiving_ccr_*` export when present; explicit logbook-only disclosure (not live loop PPO₂).

### Gaps

- No E2E test: editor save → `DiveLogStore` full CCR payload
- Physical UX QA **PENDING**

**Manual Dive readiness: 88%**  
**CCR Manual Dive readiness: 86%**

---

## L. Phase 7 — Logbook / Analytics / Charts

### Verified

Logbook metrics, analysis dashboard, depth/tissue/narcotic charts, gas/PPO₂/ceiling timelines, planner vs logbook separation, demo-data isolation, CCR `.ccrPlanned` source labeling, footnotes on simulated segments.

### Gaps

- CCR bailout segment visualization partial
- Missing CCR fields do not create fake charts (OK)

**Logbook readiness: 87%**  
**Analytics readiness: 88%**  
**CCR Analytics readiness: 85%**

---

## M. Phase 8 — PDF / Share / Export

| Export | OC | CCR | Notes |
|---|---|---|---|
| Planner PDF | OK | Separate `CCRPlannerPDFBuilder` | Reference disclaimer |
| Briefing PDF | OK | **No** | OC only |
| Checklist PDF | OK | Via checklist content | CCR roles in lines |
| Dive Pack PDF | OK | **No** | Tested OC-only gate |
| Share sheet | OK | OK | System targets |
| CSV Subsurface | OK | `# dirdiving_ccr_*` when metadata present | Watch omits CCR by policy |

### CCR export labeling

PDF includes reference-only disclaimer, heuristic bailout block, narcosis footnote (EN/IT post-remediation). CSV keys documented in `CCR_REBREATHER_EXPORT_POLICY.md`.

**PDF readiness: 90%**  
**Share readiness: 90%**  
**Export readiness: 85%**  
**CCR PDF/Export readiness: 88%**  
**External Subsurface validation: 50%** (**PENDING** — not executed)

---

## N. Phase 9 — Unit Conversion

Central `IOSUnitConversions` + `IOSAlgorithmConfiguration`; safety paths use `ambientPressureBar(depthMeters:environment:)`. CCR switch depth imperial round-trip fixed in remediation.

| Conversion | Planner | Charts | Logbook | PDF | CSV | CCR |
|---|---|---|---|---|---|---|
| m ↔ ft | OK | OK | OK | OK | Metric policy | OK |
| bar ↔ psi | OK | OK | OK | OK | OK | Setpoint stays bar |
| °C ↔ °F | OK | OK | OK | OK | OK | OK |

**Unit Conversion readiness: 92%**  
**CCR Unit Conversion readiness: 92%**

---

## O. Phase 10 — CCR / Rebreather Dedicated Audit

### Classification

**Planner-integrated reference feature** — not a life-support controller, not certified decompression authority.

| Sub-area | Classification | Readiness |
|---|---|---:|
| Circuit type model | Partial (`diveMode` string; no SCR) | 70% |
| Setpoint model | Planner-integrated | 90% |
| Diluent model | Planner-integrated | 89% |
| Bailout model | Heuristic SAC (`isHeuristic`) | 78% |
| Bühlmann integration | Parallel CCR engine | 87% |
| Oxygen exposure (CNS/OTU) | Planner-integrated | 91% |
| Consumption model | Partial (bailout SAC only) | 65% |
| UI exposure | Technical/CCR tab only | 88% |
| Test coverage | 39+ CCR-focused tests | 86% |

### Term scan summary (iOSApp)

CCR-related implementation concentrated in `iOSApp/Services/CCR/*`, `iOSApp/Models/CCR/*`, `iOSApp/Views/CCR/*`, planner integration in `PlannerStore` / `PlannerView`. No solenoid/controller runtime. Scrubber appears in checklist template only — not calculated.

**CCR Overall readiness: 88%**

---

## P. Phase 11 — Performance / Numerical Robustness

| Area | Status |
|---|---|
| Bühlmann recomputation | Acceptable; tested fixtures |
| CCR setpoint timeline | Single switch model; no heavy timeline |
| Tissue / narcotic generation | Tested; long profiles partial stress |
| PDF generation | Unit-tested; no snapshot perf suite |
| Planner slider debouncing | Not fully benchmarked |
| MOD normalization loops | Tested via clamp suites |

**Performance readiness: 89%**  
**Numerical robustness readiness: 91%**

---

## Q. Phase 12 — Security / Privacy / Safety Copy

| Area | Status |
|---|---|
| Dive profile / GPS protection | OK — file protection patterns tested |
| Gas / CCR checklist data in exports | OK — user-initiated share |
| iCloud backup opt-in | Implemented; two-device QA **PENDING** |
| PDF temp file handling | OK — cleanup tested |
| Malformed cloud payloads | Conflict tests present |

### CCR safety copy

`Docs/CCR_REBREATHER_LIMITATIONS.md`, localized `ccr.reference_estimate_only`, `ccr.pdf.disclaimer`, `TESTFLIGHT_REVIEW_NOTES.md` bailout heuristic disclosure. `SAFETY_DISCLAIMER.md` is app-wide — CCR specifics rely on CCR docs + in-app keys.

**Security readiness: 88%**  
**Privacy readiness: 87%**  
**CCR Safety Copy readiness: 90%**

---

## R. Phase 13 — Test Coverage

### Summary

- **76** test files under `Tests/iOSAlgorithmTests/`
- **540** tests executed, **13** skipped, **0** failures @ `984a69b`
- **~130** Bühlmann-focused tests across ~22 files
- **~39** CCR-focused tests across 3 files (`CCRPlannerTests`, `CCRMathRemediationTests`, `BuhlmannComprehensiveReadinessCCRRemediationTests`)
- **10** Ratio Deco tests (+ CCR rejection cases)

### Strong coverage

Bühlmann core, GF, trimix, altitude, MOD/PPO₂ clamp, Ratio Deco guards, CCR engine/validator/inspired gas/tissue sampler, checklist mapper (unit), manual dive validation, PDF builders, unit conversion, cloud conflicts, CCR CSV round-trip.

### Missing or weak

| Area | Gap |
|---|---|
| External Bühlmann fixtures | Process — not XCTest |
| CCR bailout Bühlmann simulation | Intentionally absent |
| Subsurface external round-trip | Manual **PENDING** |
| iCloud two-device merge | Manual **PENDING** |
| CCR checklist export UI | No integration test |
| Dedicated `SubsurfaceExportServiceTests` | Referenced in docs; no standalone file |
| CCR Dive Pack PDF | OC-only by design |
| Long-profile performance | Partial |

**Test Coverage readiness: 90%**  
**CCR Test Coverage readiness: 86%**

---

## S. Phase 14 — Release Hard Readiness Matrix

| Feature | Readiness |
|---|---:|
| Bühlmann | **94%** |
| Ratio Deco | **86%** |
| Gas Planning | **90%** |
| Gas Roles | **88%** |
| MOD/PPO2/Dalton | **93%** |
| Tissue Loading | **90%** |
| Narcosis | **88%** |
| Planner Modes | **92%** |
| Checklist | **85%** |
| Planner Sync | **83%** |
| Manual Dive | **88%** |
| PDF Export | **90%** |
| CSV/Subsurface | **85%** |
| Localization | **88%** |
| Units | **92%** |
| Performance | **89%** |
| Security/Privacy | **88%** |
| Documentation | **90%** |
| Internal TestFlight | **88%** |
| External TestFlight | **55%** |
| CCR Model | **86%** |
| CCR Setpoint | **90%** |
| CCR Diluent | **89%** |
| CCR Bailout | **78%** |
| CCR Bühlmann Integration | **87%** |
| CCR Oxygen Exposure | **91%** |
| CCR Consumption | **65%** |
| CCR UI Exposure | **88%** |
| CCR Test Coverage | **86%** |
| **Overall** | **92%** |

### Mandatory final verdicts

| Verdict | Answer |
|---|---|
| Bühlmann | **Almost ready** — internal reference strong; external sign-off **PENDING** |
| Ratio Deco | **Ready as labeled heuristic** — OC only; blocked in CCR |
| Gas Planning | **Almost ready** — OC strong; CCR parallel model |
| Gas Role | **Almost ready** — inference edge cases |
| MOD/PPO2 | **Ready** — unified math; PDF stricter gate documented |
| Tissue | **Almost ready** — model-backed; simulated segments footnoted |
| Narcosis | **Almost ready** — CCR estimator simplified |
| Checklist | **Conditional** — OC wired; **CCR export UI missing** |
| PDF | **Almost ready** — CCR plan PDF OK; Dive Pack OC-only |
| Manual Dive | **Almost ready** — CCR logbook fields validated |
| Unit Conversion | **Ready** |
| CCR | **Reference-only almost ready** — heuristic bailout; external validation **PENDING** |
| Internal TestFlight | **Conditional yes** — disclose non-certified + CCR + bailout |
| External TestFlight | **No** — external math + iCloud + Watch physical QA |
| App Store | **No** — same + legal/marketing |

---

## T. Phase 15 — Action Plan

### Immediate blockers (P0)

**None.**

### Internal TestFlight blockers (P1)

| ID | Sev | Pri | Area | Finding | Proposed fix | Tests |
|---|---|---|---|---|---|---|
| IOS-EXT-BM-001 | MED | P1 | Bühlmann | External profile comparison not executed | Run `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`; attach evidence to `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Manual evidence pack |
| IOS-EXT-CCR-001 | MED | P1 | CCR | CCR-01…07 slots empty | Run `CCR_REBREATHER_VALIDATION_PLAN.md` | Manual — **do not mark PASS without files** |
| IOS-ICLOUD-001 | MED | P1 | Cloud | Two-device QA not recorded | Execute `ICLOUD_TWO_DEVICE_QA_MATRIX.md` | Manual |
| IOS-BAILOUT-DOC-001 | LOW | P1 | CCR | Heuristic bailout must stay disclosed | Keep `TESTFLIGHT_REVIEW_NOTES.md` + PDF labels | Review only |

### External TestFlight blockers (P2)

| ID | Sev | Pri | Area | Finding | Proposed fix | Tests |
|---|---|---|---|---|---|---|
| IOS-CHK-CCR-001 | MED | P2 | Checklist | `applyCCRExport` not called from `PlannerView` | Wire CCR calculate → checklist export sheet (mirror OC flow) | UI/integration test |
| IOS-SUB-001 | MED | P2 | CSV | Subsurface desktop round-trip **PENDING** | Execute `SUBSURFACE_CSV_ROUNDTRIP.md` steps 4–10 | Manual + `Docs/QA_EVIDENCE/SUBSURFACE_CSV/` |
| IOS-WATCH-SYNC-001 | MED | P2 | Sync | Paired Watch physical QA **PENDING** | `WATCH_IOS_SYNC_QA_MATRIX.md` + evidence folder | Manual |
| IOS-CCR-PDF-001 | LOW | P2 | PDF | CCR Dive Pack not offered (by design) | Document or add CCR briefing variant if product requires | Product decision |

### App Store blockers (P3)

| ID | Sev | Pri | Area | Finding | Proposed fix |
|---|---|---|---|---|---|
| IOS-LEGAL-001 | MED | P3 | Marketing | App Store copy vs non-certified posture | Legal/marketing review |
| IOS-VISUAL-001 | LOW | P3 | UX | Dynamic Type / VoiceOver matrices | `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` |

### Post-release (P4)

| ID | Sev | Pri | Area | Finding | Proposed fix |
|---|---|---|---|---|---|
| IOS-CCR-RUNTIME-001 | LOW | P4 | CCR | `runtimeSegments` reserved unused | Implement or permanent doc + quarantine test |
| IOS-CCR-LOOP-001 | INFO | P4 | CCR | `loopVolumeLiters` unused | Implement or remove from model |
| IOS-BAILOUT-ENG-001 | INFO | P4 | CCR | Optional Bühlmann OC bailout simulation | Major scope — separate command |
| IOS-PERF-001 | INFO | P4 | Perf | Long-profile benchmarks | Profiling harness |

---

## U. External / Physical QA Gates (All PENDING)

| Gate | Matrix / doc | Evidence folder | Status |
|---|---|---|---|
| External Bühlmann validation | `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` | **PENDING** |
| External CCR validation | `CCR_REBREATHER_VALIDATION_PLAN.md` | `Docs/QA_EVIDENCE/CCR_EXTERNAL/` | **PENDING** |
| Subsurface CSV external | `SUBSURFACE_CSV_ROUNDTRIP.md` | `Docs/QA_EVIDENCE/SUBSURFACE_CSV/` | **PENDING** |
| iCloud two-device | `ICLOUD_TWO_DEVICE_QA_MATRIX.md` | `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | **PENDING** |
| Watch Ultra physical | `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | `Docs/QA_EVIDENCE/WATCH_ULTRA/` | **PENDING** |
| Watch-iOS sync | `WATCH_IOS_SYNC_QA_MATRIX.md` | `Docs/QA_EVIDENCE/WATCH_IOS_SYNC/` | **PENDING** |

**Explicit statement:** No physical or external QA was executed or marked passed in this audit.

---

## V. Recommended Next Cursor Commands (draft — do not execute)

1. **`4-DIR_DIVING_IOS_COMPLETE_ALGORITHM_REMEDIATION_CCR_UPDATED.md`** — wire CCR checklist export UI; Subsurface evidence harness; optional `runtimeSegments` decision.
2. **`2-DIR_DIVING_IOS_BUHLMANN_CORE_EXTERNAL_VALIDATION_EVIDENCE.md`** — external Bühlmann comparison evidence pack.
3. **`3-DIR_DIVING_IOS_CCR_HARDENING_AND_BAILOUT_TRUTHFULNESS.md`** — bailout engine vs enhanced heuristic (product decision).
4. **`5-DIR_DIVING_IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md`** — autoclamp visual matrix.
5. **`8-DIR_DIVING_IOS_UNIT_TEST_COVERAGE_AND_ICLOUD_E2E.md`** — two-device tests + `SubsurfaceExportServiceTests`.

---

## W. Final Verdict

| Question | Answer |
|---|---|
| Is Bühlmann ready? | **Yes for internal reference** (94%); external certification sign-off **PENDING**. |
| Is the Planner ready? | **Yes** for Base/Deco/Technical (92%); CCR mode isolated (88%). |
| Is CCR implemented? | **Yes** — reference planner; **not** a live loop controller. |
| Is CCR safe to expose? | **Yes with disclaimers** — bailout heuristic; no monitoring claims. |
| Is Ratio Deco ready? | **Yes as heuristic comparator** (86%) — OC only. |
| Is tissue/narcosis model-backed? | **Yes** with CCR simplifications footnoted. |
| Are MOD/PPO₂ rules consistent? | **Yes** across OC + CCR setpoint paths. |
| Are manual dives integrated? | **Yes** (88%) — CCR logbook metadata supported. |
| Are exports reliable? | **Mostly** (90% PDF, 85% CSV) — external Subsurface **PENDING**. |
| Safe for internal TestFlight? | **Conditional yes** — document CCR + bailout + non-certified posture. |
| Safe for external TestFlight? | **No** — external math + iCloud + Watch physical QA **PENDING**. |
| Ready for App Store? | **No** — same gates + legal/marketing review. |
| Certified decompression / CCR controller? | **Never** without separate certification and product scope change. |
| What blocks 100%? | External validation evidence, physical QA matrices, CCR checklist UI gap, heuristic bailout (by design), Subsurface external sign-off. |

### Static tooling scan

| Scan | Result |
|---|---|
| `try!` in iOS algorithm paths (spot check) | Not elevated to P0 |
| CCR Swift module files | 7+ under `iOSApp/Services/CCR/` + models/views |
| Watch CCR runtime | **0** — Watch remains non-decompression logger |

---

## X. Phase 13 Validation Checklist

| Check | Result |
|---|---|
| Report file exists | **YES** — this file |
| Report not empty | **YES** |
| Check_Math_iOS + v2 + CCR merged | **YES** |
| Release Hard Matrix | **YES** — Section S |
| Action plan | **YES** — Section T |
| No source code modified | **YES** (audit pass) |
| Physical/external QA marked PENDING | **YES** |
| Git status | New report file only expected |

---

*End of audit @ `984a69b`. Prior comprehensive CCR audit: `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` @ `cc4d783` (91%, 526 tests). Bühlmann remediation @ `d756a89`. Watch remediation @ `984a69b` (no iOS algorithm change). This complete algorithm audit overall: **92%**.*
