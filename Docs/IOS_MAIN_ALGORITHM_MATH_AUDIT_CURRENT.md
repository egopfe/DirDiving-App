# iOS Companion MAIN Algorithm and Mathematical Functions Audit — Current

**Audit date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main`  
**Code baseline:** `81f2d7f` (`docs(ios): update Bühlmann planner implementation completion report`)  
**Target audited:** `DIRDiving iOS` only  
**Mode:** Read-only audit. No code, UI, Watch runtime, or experimental targets were modified. No commit. No push.

**Supersedes:** prior revision @ `ecad0d9` (2026-06-05).

---

## Scope Confirmation

### Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `81f2d7f` |
| Remote | `origin/main` — aligned |
| Working tree | Clean at audit time |
| OS | macOS (Darwin) — build/test executed |
| Experimental exclusions in `project.yml` | Confirmed for `DIRDiving iOS` |
| Apple Watch runtime | Out of scope except shared models/codec consumed by iOS |
| Build | `DIRDiving iOS` — **BUILD SUCCEEDED** (iPhone 17 simulator) |
| Tests | `DIRDiving iOS Algorithm Tests` — **363 passed**, 5 skipped, 0 failures |

### iOS MAIN target exclusions (`project.yml`)

Not in `DIRDiving iOS` build (not audited):

- `iOSApp/Models/ExplorationModels.swift`, `BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`, `BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`

### Primary references

- [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) @ `21a5858`
- [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) @ `81f2d7f`
- [`IOS_PLANNER_CHART_TRUTHFULNESS.md`](IOS_PLANNER_CHART_TRUTHFULNESS.md)

---

## A. Executive Summary

### Overall verdict

The iOS Companion MAIN target at `81f2d7f` is a **coherent non-certified Bühlmann ZHL-16C reference planner** with real three-mode architecture (Base / Deco / Technical), post-plan tissue-history charting, schedule-aware gas ledger, NOAA/Lambertsen oxygen exposure, logbook analytics, CSV import/export, Watch sync codec validation, and iCloud KVS merge. Recent P2/P3 fixes (ascent table briefing order, full-plan CNS warning tile, GF/TTS copy, tissue chart fail-explicit) are present and tested.

**No P0 safety-critical algorithm blocker** was found in this pass. **Internal validation readiness is achieved** on macOS build/test evidence. External decompression comparison, simulator/device QA, and documentation baseline refresh remain before stronger TestFlight or App Store claims.

### Readiness estimates

| Area | Readiness | Notes |
|---:|---:|---|
| **Overall mathematical robustness** | **92%** | Core Bühlmann + exposure models sound; integration edge cases remain |
| **Planner confidence (calculation path)** | **93%** | `PlannerService.makePlan` uses mode-projected active input |
| **Planner three-mode readiness** | **90%** | Real policy projection; Base still runs full engine internally (UI gated) |
| **Bühlmann ZHL-16C engine** | **94%** | Real tissue model; external reference campaign pending |
| **Bühlmann curve / tissue history** | **93%** | Primary chart truthful; NDL secondary only |
| **PIANO DI RISALITA table** | **91%** | Post-P2 briefing order; travel/deco not interleaved per stop |
| **GRAFICI depth profile** | **92%** | Real segment-derived profile (Technical Charts tab) |
| **CNS / OTU** | **91%** | Full plan + descent/bottom + 15% rule; weekly OTU not shown in UI |
| **Gas planning / consumption** | **90%** | Ledger + MOD/PPO₂; bailout schedule-only by design |
| **Logbook derived math** | **92%** | Centralized profile math; no post-dive CNS/OTU |
| **CSV import/export** | **90%** | Bounded guards; DIR CSV not Subsurface XML |
| **Watch sync validation on iOS** | **89%** | Strong codec/auth; service integration undertested |
| **Cloud merge / iCloud KVS** | **87%** | LWW merge; profile merge semantics need QA |
| **Documentation accuracy** | **78%** | Several README baselines still cite `90dc3f5` |
| **Automated algorithm tests** | **94%** | 363 XCTest pass @ `81f2d7f` |

### Critical blockers

| Gate | Status |
|---|---|
| **Internal algorithm validation** | **Ready** — macOS build + 363 tests pass |
| **Internal TestFlight planning** | **Almost ready** — P2 doc/QA items below |
| **External TestFlight** | **Not yet** — device QA + external Bühlmann comparison |
| **App Store** | **Not yet** — legal/external QA + stale doc baselines |
| **Certified decompression claim** | **Never claimed / not supported** |

---

## B. Algorithm Inventory

Grouped inventory of iOS Companion MAIN mathematical/algorithmic components. Internal storage is metric unless noted.

### 1. Planner mode architecture

| Component | File | Input → Output | Modes | Safety |
|---|---|---|---|---|
| Mode enum | `GasPlan.swift` | — | Base, Deco, Technical | Policy |
| Active input projection | `PlannerModePolicy.activePlanInput` | Draft `GasPlanInput` → projected copy | Per mode | **Critical** |
| Mode validation merge | `PlannerModePolicy.validate` | Draft + mode → `PlannerValidationResult` | Per mode | **Critical** |
| Mode limits (NDL clamp, 40 m deco cap) | `PlannerModeLimits` | Input clamp/validate | Base, Deco | **Critical** |
| Result presentation flags | `PlannerResultPresentation` | Mode → UI/chart gates | All | UX/safety copy |
| Mode guidance (Base deco exceedance) | `PlannerModePolicy.modeGuidance` | Engine result → warning string | Base | Informational |

### 2. Planner / dive planning

| Component | File | Notes |
|---|---|---|
| Plan orchestration | `PlannerService.makePlan` | Single canonical `BuhlmannEngineResult` → all derived outputs |
| Plan store / recalc | `PlannerStore` | Draft vs projected preview; mode switch preserves hidden cylinders |
| Input validation | `PlannerInputValidator` | Depth, time, SAC, GF (Technical), environment, cylinders |
| Completeness resolver | `PlanCalculationCompletenessResolver` | Suppresses partial stop presentation |
| Result states | `PlannerResultState` | Typed fail-closed states incl. `oxygenExposureElevated` |
| Briefing text | `GasPlanningService.makeBriefing` | TTS-only wording post-P3 fix |
| Contingency / team match | `PlannerService` | Technical-only sections |
| GF comparisons | `BuhlmannPlanner.gfComparisons` | Technical Charts tab |

### 3. Bühlmann / decompression

| Component | File | Notes |
|---|---|---|
| Constants ZHL-16C | `BuhlmannConstants.swift` | 16 N₂ + 16 He compartments |
| Tissue loaders | `BuhlmannTissueModel.swift` | Schreiner + constant depth |
| Engine | `BuhlmannEngine.swift` | NDL search, GF ceiling, stop schedule, multigas |
| Preflight | `BuhlmannPlanPreflightValidator.swift` | Fail-closed before plan |
| Planner adapter | `BuhlmannPlanner.swift` | `GasPlanInput` → `BuhlmannPlanRequest` |
| Tissue history sampler | `BuhlmannTissueHistory.swift` | Post-plan visualization only; fail-explicit @ invalid ambient |

### 4. Gas / environment / exposure

| Component | File | Notes |
|---|---|---|
| Gas analysis | `GasPlanningService.swift` | PPO₂, density, END, CNS/OTU, states |
| Oxygen exposure | `OxygenExposureModels.swift` | NOAA CNS + Lambertsen OTU |
| Schedule consumption | `ScheduleGasConsumptionService.swift` | Per-cylinder ledger |
| MOD validation | `PlannerMODValidator.swift` | Switch depth vs MOD |
| Environment | `PlannerEnvironment.swift`, `AmbientPressureModel` | Altitude, salinity, no silent fallback in validated paths |
| Gas mix validation | `GasMixValidator.swift` | O₂+He fractions, hypoxic MOD |

### 5. Charts / profiles

| Component | File | Notes |
|---|---|---|
| Ascent table | `PlannerAscentTableBuilder.swift` | Bottom → post-bottom travel → deco → surface |
| Depth profile | `PlannerDepthProfileBuilder` | Segment staircase + surface terminus |
| Tissue analytics (logbook) | `TissueAnalyticsService.swift` | Simulated replay; GF 0.85 assumption |

### 6. Logbook / analysis / import / export / sync

| Component | File | Notes |
|---|---|---|
| Profile math | `DiveProfileMath.swift` | Time-weighted avg depth/temp |
| CSV import | `DiveImportService.swift` | Bounded parser, metadata, validation |
| CSV export | `SubsurfaceExportService.swift` | DIR CSV + metadata round-trip |
| Watch sync codec | `WatchDiveSyncCodec.swift`, `WatchSyncService.swift` | Signed payloads, conflict diff |
| Cloud merge | `CloudSyncStore.swift`, `DiveSessionMerge.swift` | LWW KVS, conflict detection |
| Analysis dashboard | `AnalysisDashboardMath.swift` | Arithmetic means (documented) |

### 7. Units / formatters

| Component | File | Notes |
|---|---|---|
| Conversions | `IOSUnitConversions.swift` | m/ft, bar/psi, °C/°F, L/cu ft |
| Display | `Formatters.swift`, `IOSUnitPreference` | UI/export formatting |

---

## C. Planner Mode Audit

### Mode semantics matrix

| Dimension | Base | Deco | Technical |
|---|---|---|---|
| **Intent** | No-deco recreational | Deco to 40 m | Full multigas technical |
| **Active cylinders** | Bottom only | Bottom + max 1 deco | All roles (travel, deco×n, bailout) |
| **Mix kinds (UI)** | Air, EAN | All (trimix blocked in validation) | All incl. trimix |
| **Travel / bailout** | Hidden/disabled | Hidden/disabled | Allowed |
| **GF** | Fixed 30/80 (projected) | Presets only | Manual sliders |
| **GF validation** | Not validated (fixed) | Not validated (presets) | Strict `gfLow < gfHigh` |
| **Depth limit** | NDL-compatible clamp | 40 m hard cap | Global max (120 m) |
| **Bottom time limit** | NDL clamp | Global max | Global max |
| **Avg depth / planning ref** | Hidden | Shown | Shown |
| **Altitude / salinity** | Hidden | Hidden | Shown |
| **Repetitive planning** | Hidden | Hidden | Shown |
| **Engine path** | Full Bühlmann on projected input | Same | Same (+ repetitive seed) |

### Result section matrix

| Section | Base | Deco | Technical |
|---|---|---|---|
| Result tabs: PIANO | ✓ | ✓ | ✓ |
| Result tabs: CURVA | ✗ | ✓ (simplified tissue) | ✓ (full + NDL ref) |
| Result tabs: GRAFICI | ✗ | ✗ | ✓ |
| Ascent table | Hidden | Simplified table | Full table |
| Gas ledger | ✗ | ✓ | ✓ |
| Briefing | ✗ | ✓ | ✓ |
| Contingency / team | ✗ | ✗ | ✓ |
| Tissue analytics entry | ✗ | ✓ | ✓ |
| Base compatibility card | ✓ | ✗ | ✗ |

### Mode switching policy

- Draft `GasPlanInput` retains hidden Technical cylinders when switching to Base/Deco (`PlannerModePolicyTests`).
- Calculations always use **projected** active input, not raw draft (`PlannerService.makePlan` L4–5 flow).
- **Mismatch (P2):** Base mode still executes full Bühlmann engine internally when bottom time exceeds NDL; UI shows guidance via `modeGuidanceMessage` but user may not expect engine deco output in Base tab. Documented as informational, not algorithm bug.

---

## D. Bühlmann Mathematical Assessment

| Area | Verdict | Evidence |
|---|---|---|
| ZH-L16C constants | **Pass** | `BuhlmannConstants.swift`; `BuhlmannConstantsTests` |
| N₂/He tissue loading | **Pass** | Schreiner + constant depth; `BuhlmannSchreinerEquationTests` |
| Mixed a/b coefficients | **Pass** | Pressure-weighted; `BuhlmannNumericalRobustnessTests` |
| Environment / inspired gas | **Pass** | `PlannerEnvironment`, water vapor subtraction |
| GF interpolation | **Pass** | `BuhlmannEngine.gfAtDepth`; strict `<` enforced |
| Ceiling / stops | **Pass** | Compartment-based; not static templates |
| NDL | **Pass** | Tissue-state search; no fake 999 |
| Multigas / trimix | **Pass** | He loading; `BuhlmannTrimixHeliumTests`, golden fixtures |
| Repetitive seeding | **Pass** | `initialTissueState` before canonical plan |
| External validation | **Pending** | No certified third-party equivalence campaign |

**GF policy:** `gfLow < gfHigh` strictly (Technical validator + engine). Equality rejected — `BuhlmannGradientFactorTests.testEqualGradientFactorsAreRejectedByPlannerValidator`.

---

## E. Tissue History / CURVA BÜHLMANN Assessment

| Check | Result |
|---|---|
| Sampled from engine segments post-plan | **Yes** — `BuhlmannTissueHistorySampler` |
| Sampling mutates stop math | **No** — fixture regression tests |
| 16 compartments per timestamp | **Yes** — `BuhlmannTissueHistoryTests` |
| Groups 1–4 / 5–8 / 9–12 / 13–16 max load | **Yes** — `aggregationMethod = max_load_percent_per_group` |
| Primary chart source | `tissueHistory.groupedPoints` — not NDL |
| NDL chart | Secondary, Technical only, with disclaimer |
| Invalid plan | Empty history + UI empty state |
| Invalid ambient (display) | `compartmentMetrics` returns nil; no sea-level fallback |
| Base mode curve | Hidden (`.buhlmannPresentation = .hidden`) |
| Deco mode curve | Simplified (no NDL reference overlay) |
| Technical mode curve | Full curve + optional NDL reference |

---

## F. Decompression Table / PIANO DI RISALITA Assessment

| Check | Result |
|---|---|
| Columns depth / time / gas / PPO₂ | **Yes** |
| Bottom row from real bottom segments | **Yes** |
| Travel rows | Post-bottom **ascent + gasSwitch** only (descent excluded) — post-P2 fix |
| Deco rows from engine stops | **Yes**, engine order |
| Surface row last | **Yes** — tested |
| PPO₂ from gas + depth + environment | **Yes** |
| Incomplete plan | `presentationStops = []` + UI banner |
| TTS label | Maps to `enginePlan.ttsMinutes` |
| TTR wording | Removed from briefing (TTS-only post-P3) |
| Row interleaving | All travel rows before all deco rows (briefing style, not stop-interleaved) |

---

## G. GRAFICI / Depth Profile Assessment

| Check | Result |
|---|---|
| Depth-vs-time chart | **Yes** — Technical Charts tab |
| Data source | `PlannerDepthProfileBuilder.points(from: segments)` |
| Ends at surface | **Yes** — `PlannerDepthProfileTests` |
| Segment timeline | Technical Charts tab |
| GF comparison | Technical Charts tab |
| Base/Deco visibility | Charts tab hidden (mode policy) |

---

## H. CNS / OTU / 15% Rule Assessment

| Check | Result |
|---|---|
| Full-plan CNS includes deco/ascent | **Yes** — full engine segments |
| CNS descent+bottom separate | **Yes** — `.descent` + `.bottom` filter only |
| 15% threshold strict `> 15%` | **Yes** — `CNSDescentBottomTests` |
| Toggle in More | **Yes**, default on |
| Red warning banner | **Yes** when threshold exceeded |
| Full-plan CNS hero tile warning | **Yes** when `oxygenExposureElevated` — post-P2 fix |
| OTU Lambertsen direction | **Yes** — `OTUCanonicalFixtureTests` |
| OTU monotonicity with PPO₂ | **Yes** |
| Weekly OTU computed | **Yes** in model |
| Weekly OTU displayed | **No** — P2 UX gap |
| Logbook/analysis CNS/OTU | **N/A** — not stored post-dive |
| Reference-only disclaimers | **Present** in UI strings |

---

## I. Gas Planning / MOD / PPO₂ / SAC Assessment

| Area | Verdict |
|---|---|
| Schedule gas ledger | **Pass** — role-aware, excludes bailout from Bühlmann optimization |
| MOD / PPO₂ validation | **Pass** — `PlannerMODValidator`, segment PPO₂ checks |
| SAC / RMV consumption | **Pass** — schedule-aware when segments available |
| Reserve / rock bottom | **Pass** — typed warning states |
| END / EAD / density | **Pass** — environment-aware |
| Hypoxic gas rules | **Pass** — minimum operating depth validation |
| Duplicate gas label disambiguation | **Pass** — `gasMixId`, `cylinderId` |
| Mode inactive gas exclusion | **Pass** — projection strips unused cylinders |

---

## J. Logbook / Analysis / Import / Export / Sync Assessment

| Area | Verdict | Notes |
|---|---|---|
| Logbook stats | **Pass** | Time-weighted depth; demo isolation |
| Manual dive editor | **Pass** | Validated via `DiveSessionAlgorithmValidator` |
| Analysis dashboard | **Pass** | No CNS/OTU; arithmetic averages documented |
| CSV import | **Pass** | Size/row limits, metadata, fail-closed |
| CSV export | **Pass** | Round-trip metadata tests |
| Watch sync | **Pass** | Codec + conflict diff + auth pinning |
| Cloud KVS merge | **Partial** | LWW works; profile merge can silently prefer cloud samples (P2) |
| Tissue analytics (logbook) | **Informational** | Simulated GF 0.85; labelled simulated |

---

## K. Unit Conversion / Formatter Assessment

| Check | Result |
|---|---|
| Central conversion helpers | **Yes** — `IOSUnitConversions` |
| Internal metric storage | **Preserved** |
| Display preference | `IOSUnitPreference` |
| Nil/NaN guards in formatters | Present in algorithm validators |
| Planner under imperial | Uses formatters consistently in audited paths |

---

## L. Findings by Family

### P0 — Safety-critical

**None identified @ `81f2d7f`.**

### P1 — Major algorithm / release-hard

| ID | Title | Family | File | Mode | Priority | Impact |
|---|---|---|---|---|---|---|
| IOS-MAIN-P1-001 | External Bühlmann validation campaign not executed | Bühlmann | Docs + fixtures | Shared | P1 | Cannot claim equivalence to reference planners |
| IOS-MAIN-P1-002 | No certified third-party stop/TTS regression suite | Bühlmann | `Fixtures/*.json` | Shared | P1 | Internal tests pass; external tolerance undocumented |

### P2 — UX / validation / data integrity

| ID | Title | Family | File | Mode | Proposed fix | Code impact |
|---|---|---|---|---|---|---|
| IOS-MAIN-P2-001 | Cloud profile merge may silently overwrite local samples | Sync | `DiveSessionMerge.swift`, `CloudSyncStore` | Shared | Document policy or surface conflict UI | Small functional |
| IOS-MAIN-P2-002 | Weekly OTU warning not shown in planner UI | CNS/OTU | `PlannerView.swift`, `GasPlan.swift` | Shared | Display `otuWeekly` + warning when elevated | UI-only |
| IOS-MAIN-P2-003 | Oxygen warnings collapsed to single state | CNS/OTU | `GasPlanningService.exposurePlannerStates` | Shared | Optional granular states or copy | Small functional |
| IOS-MAIN-P2-004 | Logbook tissue analytics uses fixed GF 0.85 simulation | Analytics | `TissueAnalyticsService.swift` | Shared | Document limitation; future recorded gas timeline | Docs / medium |
| IOS-MAIN-P2-005 | Ascent table travel rows precede all deco rows (not interleaved) | Table | `PlannerAscentTableBuilder.swift` | Deco/Tech | Accept as briefing style or interleave at stop boundaries | Small functional |
| IOS-MAIN-P2-006 | `CloudSyncStore.load()` merge branches undertested | Sync | `CloudSyncStore.swift` | Shared | Add integration tests | Test-only |
| IOS-MAIN-P2-007 | `WatchSyncService` service layer undertested | Sync | `WatchSyncService.swift` | Shared | Add integration tests | Test-only |

### P3 — Documentation / polish

| ID | Title | Family | File | Proposed fix |
|---|---|---|---|---|
| IOS-MAIN-P3-001 | README/Docs README baseline still `90dc3f5` | Docs | `README.md`, `Docs/README.md` | Update to `81f2d7f` + test count 363 |
| IOS-MAIN-P3-002 | `IOS_PLANNER_CHART_TRUTHFULNESS.md` travel row wording stale | Docs | Chart truthfulness doc | Update post-P2 ascent table semantics |
| IOS-MAIN-P3-003 | Missing `DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md` | Docs | Docs/ | Create or remove references |
| IOS-MAIN-P3-004 | Duplicate root `Services/` tree may drift from `iOSApp/Services/` | Maintainability | Repo layout | Confirm canonical path in docs |
| IOS-MAIN-P3-005 | `DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md` predates tissue history | Docs | Docs/ | Mark superseded @ `81f2d7f` |

### P4 — Post-release / external QA

| ID | Title | Proposed action |
|---|---|---|
| IOS-MAIN-P4-001 | External Bühlmann comparison with reference tools | Execute validation plan |
| IOS-MAIN-P4-002 | Physical Dynamic Type / VoiceOver / paired-device QA | Run QA matrices |
| IOS-MAIN-P4-003 | Subsurface third-party CSV regression | Manual fixture pass |
| IOS-MAIN-P4-004 | Simulator screenshot evidence for Charts tab | TestFlight gate |

---

## M. Edge Case Matrix

| Scenario | Expected behavior | Observed @ 81f2d7f |
|---|---|---|
| Invalid gas fractions | Fail closed `.invalidInput` | **Pass** |
| GF Low == GF High | Rejected (Technical) | **Pass** |
| Bottom time > NDL in Base | Validation error + guidance | **Pass** |
| Deco depth > 40 m | `.decoDepthLimitExceeded` | **Pass** |
| Calculation limit reached | Empty stops + incomplete banner | **Pass** |
| Empty tissue history | Chart empty state, not NDL substitute | **Pass** |
| Invalid ambient for chart sample | Skip sample / nil metrics | **Pass** |
| CNS exactly 15% descent+bottom | Acceptable | **Pass** |
| CSV > 10 MB | Rejected | **Pass** |
| Duplicate session ID sync | Conflict detection | **Pass** |
| Demo dive isolation | Excluded from sync push patterns | **Pass** |

---

## N. Unit / Integration Test Plan (summary)

| Priority | Test | Input | Pass criteria |
|---|---|---|---|
| P1 | External fixture TTS/stops | Golden JSON profiles | Within documented tolerance |
| P1 | GF 30/70 vs 50/80 TTS ordering | Trimix deco plan | Conservative ≥ aggressive TTS |
| P2 | Cloud load cloud-newer-wins | Mock KVS payloads | Correct merge + no data loss |
| P2 | Watch sync round-trip | Sample session | Depth profile preserved ±ε |
| P2 | Weekly OTU UI | Plan with elevated weekly OTU | Warning visible |
| P3 | Imperial display round-trip | Unit preference toggle | Consistent labels |

**Current automated coverage:** 363 `func test` definitions across 58 files in `Tests/iOSAlgorithmTests/`.

---

## O. Planner Mode Regression Test Plan

| Test | Base | Deco | Technical |
|---|---|---|---|
| `PlannerModePolicyTests` projection | ✓ | ✓ | ✓ |
| `PlannerModeLimitsTests` NDL/40 m | ✓ | ✓ | — |
| `PlannerAscentTableTests` table order | — | ✓ | ✓ |
| `PlannerCurveChartTests` tissue vs NDL | — | ✓ | ✓ |
| `PlannerDepthProfileTests` | — | — | ✓ |
| `CNSDescentBottomTests` | — | ✓ | ✓ |
| `BuhlmannMultigasPlannerTests` | — | — | ✓ |

---

## P. Paired Watch/iPhone Test Plan

1. Record dive on Watch → sync to iOS → verify depth samples, duration, max depth match.
2. Edit metadata on iOS → verify no spurious profile overwrite from cloud.
3. Delete dive on one device → tombstone propagates.
4. Manual iOS dive → verify Watch exclusion rules unchanged.
5. Photo transfer ACK path (out of algorithm scope but sync-adjacent).

---

## Q. CSV Import/Export Regression Plan

1. Export session → re-import → UUID/metadata preserved (`CSVMetadataRoundTripTests` baseline).
2. Malformed rows → bounded errors, no partial corrupt session.
3. Large file rejection > 10 MB.
4. Legacy `# session_meta` header compatibility.
5. Manual pressure bar fields round-trip.

---

## R. Cloud Merge Validation Plan

1. Local newer `modifiedAt` → push to iCloud.
2. Cloud newer → merge into local logbook.
3. Decode failure → retain local with `lastDecodeError`.
4. Duplicate session IDs → conflict detector fires.
5. Profile sample divergence → verify documented merge policy (P2-001).

---

## S. Planner Boundary Validation Plan

1. Base at NDL boundary ± 1 min.
2. Deco at 40.0 m vs 40.1 m.
3. Technical 120 m cap.
4. Hypoxic trimix MOD violation.
5. Gas switch deeper than MOD.
6. Incomplete calculation limit profile (120 m / 120 min air).

---

## T. Prioritized Roadmap

1. **Before compile/use:** None blocking @ `81f2d7f`.
2. **Before internal TestFlight:** Refresh README baselines; optional weekly OTU UI; cloud merge QA.
3. **Before external TestFlight:** External Bühlmann comparison; simulator EN/IT screenshots; paired-device sync QA.
4. **Before App Store:** Full release checklist; physical accessibility QA; legal review unchanged.
5. **Post-release:** Heliox UI mix kind; travel-gas switch depth model; granular oxygen warning states.

---

## U. Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Yes for internal reference validation** — core models coherent; external comparison still required for public claims. |
| **Are Base/Deco/Technical modes real?** | **Yes** — projection, validation, and UI gating are mode-aware; engine is shared with projected inputs. |
| **Is tissue-history Bühlmann curve truthful?** | **Yes** — primary chart uses real sampled tissue history; NDL is secondary only. |
| **Is decompression table complete and real?** | **Yes** — real engine data; post-P2 briefing order; incomplete plans suppressed safely. |
| **Are CNS/OTU and 15% rule correct?** | **Yes** — tested NOAA/Lambertsen integration; UI labelling and warnings present; weekly OTU display gap remains. |
| **Planner safe enough for internal test?** | **Yes** — with reference-only disclaimers intact. |
| **Sync/data ready?** | **Mostly** — strong codecs; cloud profile merge needs explicit QA (P2-001). |
| **Ready for TestFlight?** | **Internal: almost ready.** External: not yet. |
| **Ready for App Store?** | **No.** |
| **What blocks 100% algorithmic readiness?** | External Bühlmann validation, cloud merge integration tests, device QA, documentation baseline refresh. |

### Certification statement

This audit was performed by static inspection and macOS build/test execution on `main` @ `81f2d7f`. **No code was modified. No commit. No push.** Apple Watch runtime code was not modified. Experimental targets were not audited. The product remains a **non-certified Bühlmann-based planning reference**, not a dive computer substitute.

---

*End of audit — `IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` @ baseline `81f2d7f`.*
