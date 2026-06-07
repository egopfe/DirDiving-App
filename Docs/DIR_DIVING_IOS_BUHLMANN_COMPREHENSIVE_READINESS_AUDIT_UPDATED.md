# DIR Diving iOS Bühlmann Comprehensive Readiness Audit — Updated

Date: 2026-06-07
Repository: `https://github.com/egopfe/DirDiving-App.git`
Audited branch: `main`
Audited HEAD: `93d632450c0579f9215c3f3e2eb78c06332c4847` (`93d6324`)
HEAD subject: `feat(ios): add tissue loading and narcosis analytics for planner and logbook`
Scope: iOS Companion MAIN branch, Planner only
Execution mode: Windows static analysis only; no `xcodegen` / `xcodebuild` execution on this host

## Executive Verdict

Status: **Almost ready**

The current iOS Companion Planner contains a coherent non-certified Bühlmann ZH-L16C reference engine with 16 nitrogen compartments, 16 helium compartments, trimix/helium support, gradient factors, tissue-state NDL, environment-aware pressure modeling, multigas runtime segments, decompression stops, tissue-history sampling, oxygen exposure estimates, localized CNS copy, and a large iOS algorithm test suite.

No fresh P0/P1 planner math blocker was found in this static pass. The earlier audit's OTU "inverted formula" concern should not be carried forward against current HEAD: `OxygenExposureModels.swift` now uses the monotonic Lambertsen-style `((PPO2 - 0.5) / 0.5)^(5/6)` form, and the repo has independent OTU fixture tests for that direction.

The planner is **not fully Ready** because current HEAD still needs macOS build/test validation, external decompression-planner comparison, simulator UI QA, and a few product-readiness fixes. The most important code-facing gap is presentational: the ascent/deco table uses real engine data but is not built in strict chronological order. The most important UI clarity gap is that the full-plan CNS dashboard tile stays green even when oxygen-exposure warnings exist elsewhere.

Recommended release posture:

- **Internal algorithm validation:** conditional yes after macOS `xcodegen` + iOS build + iOS algorithm tests pass on `93d6324` or newer.
- **Internal TestFlight planning:** almost ready after the P2 presentation/UI gaps are fixed or explicitly deferred in release notes.
- **Release candidate / App Store claim:** not ready until external mathematical validation, simulator/device QA, and documentation baselines are updated.

## Scope Confirmation

This audit intentionally inspected the iOS Companion Planner on MAIN only.

Included:

- iOS planner Swift code under `iOSApp/Algorithms/Buhlmann`, planner services, planner models, planner utilities, planner UI, planner localization, iOS algorithm tests, `project.yml`, and planner documentation.

Excluded:

- Apple Watch runtime algorithms, Watch UI, Watch targets, Watch-only tests, experimental branches, experimental files, generated Xcode project contents, and unrelated app features.

Actions taken:

- Created this updated report only.
- No Swift code was modified.
- No UI, algorithm, localization, or test files were modified.
- No commit or push was performed.

## Repository State

Preflight state:

- Current branch: `main`
- Upstream: `origin/main`
- Divergence: `0 ahead / 0 behind`
- Remote: `https://github.com/egopfe/DirDiving-App.git`
- Latest audited commit: `93d632450c0579f9215c3f3e2eb78c06332c4847`
- Commit date: `2026-06-06 22:34:33 +0200`
- Working environment: Windows 10 / PowerShell
- `xcodegen`: unavailable on this host
- `xcodebuild`: unavailable on this host

`project.yml` confirms the main iOS target `DIRDiving iOS`, the iOS algorithm test target `DIRDiving iOS Algorithm Tests`, and explicit exclusions for experimental iOS files. Watch targets exist in the repo, but were outside this audit scope.

## Files Inspected

Core Bühlmann engine:

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`

Planner services, models, utilities:

- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Services/TissueAnalyticsService.swift`
- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`
- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift`
- `iOSApp/Utils/PlannerCNSDescentBottomCheckSettings.swift`
- `iOSApp/Utils/PlannerGasEditingSupport.swift`

Planner UI and localization:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Views/PlannerCylinderGasEditorView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

Tests and fixtures:

- Static enumeration found **355** `func test` definitions under `Tests/iOSAlgorithmTests`.
- Key audited test files include `BuhlmannConstantsTests.swift`, `BuhlmannPressureModelTests.swift`, `BuhlmannTissueLoadingTests.swift`, `BuhlmannSchreinerEquationTests.swift`, `BuhlmannGradientFactorTests.swift`, `BuhlmannNDLTests.swift`, `BuhlmannTrimixHeliumTests.swift`, `BuhlmannMultigasPlannerTests.swift`, `BuhlmannReleaseHardeningTests.swift`, `BuhlmannReauditFixTests.swift`, `BuhlmannTissueHistoryTests.swift`, `PlannerCurveChartTests.swift`, `PlannerAscentTableTests.swift`, `PlannerDepthProfileTests.swift`, `CNSDescentBottomTests.swift`, `PlannerCNSCopyTests.swift`, `OxygenExposureDeepModelTests.swift`, `OTUCanonicalFixtureTests.swift`, `OTUIntegrationRefinementTests.swift`, `BuhlmannGoldenFixtureTests.swift`, and `Tests/iOSAlgorithmTests/Fixtures/*.json`.

Documentation:

- `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md`
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`
- `Docs/README.md`
- `README.md`

## Bühlmann Mathematical Model Assessment

| Area | Assessment | Evidence | Readiness |
| --- | --- | --- | --- |
| ZH-L16C compartments | 16 N2 and 16 He half-time tables are present. | `BuhlmannConstants.swift:3-50` | Good |
| Mixed inert coefficients | A/B coefficients are pressure-weighted by N2/He tissue pressures. | `BuhlmannConstants.swift:52-60`, `BuhlmannNumericalRobustnessTests.swift` | Good |
| Water vapor | Inspired inert pressure subtracts water vapor. | `BuhlmannGas.swift:65-79` | Good |
| Surface pressure | Planner environment uses barometric surface pressure; sea-level baseline is `1.01325 bar`. | `PlannerEnvironment.swift`, `BuhlmannConstants.swift` | Good |
| Tissue loading | Constant-depth and linear-depth loading use the shared tissue loaders. | `BuhlmannTissueModel.swift:38-68` | Good |
| Ceiling | Ceiling converts tolerated ambient pressure through the active `PlannerEnvironment`. | `BuhlmannTissueModel.swift:70-92` | Good |
| Gradient factors | GF Low/High interpolate by stop depth. | `BuhlmannEngine.swift:192-200` | Good, with policy note |
| NDL | Tissue-state NDL binary search returns finite values; tests reject fake `999`. | `BuhlmannEngine.swift:137-190`, `BuhlmannNDLTests.swift` | Good |
| Stops | First stop derives from GF Low ceiling; stop propagation checks next-depth ceiling. | `BuhlmannEngine.swift:294-407` | Good |
| Gas switching | Travel/deco switch points and PPO2 bounds are validated; higher O2 deco gas is preferred when valid. | `BuhlmannEngine.swift:554-679`, `BuhlmannEngine.swift:765-774` | Good |
| Gas identities | `gasMixId`, `cylinderId`, and `allocationKey` reduce duplicate-label ledger ambiguity. | `BuhlmannGas.swift:3-15`, `ScheduleGasConsumptionService.swift` | Good |
| Bailout | Bailout is intentionally schedule/ledger messaging only, not part of the primary Bühlmann schedule. | `BuhlmannPlanner.swift:257-287`, `PlannerGasSchedule.swift:157-163` | Acceptable if documented |

Policy note: code currently requires `gfLow < gfHigh` in both `PlannerInputValidator.swift:53-58` and `BuhlmannEngine.swift:210-216`. If the product requirement is truly "GF Low <= GF High", equality is rejected today. This is conservative fail-closed behavior, but it should be documented or adjusted.

## Tissue History / CURVA BÜHLMANN Assessment

The current CURVA BÜHLMANN implementation is materially stronger than an NDL-only chart.

| Question | Answer |
| --- | --- |
| Is the old NDL curve replacing tissue loading? | **No.** The primary chart uses `DivePlanResult.tissueHistory.groupedPoints`; the NDL curve is a secondary reference chart only when enabled. |
| Are all 16 compartments modeled? | **Yes.** The sampler emits 16 compartment samples per timestamp and tests assert the full `0..<16` set. |
| Are compartments grouped clearly? | **Yes.** Groups are `1-4`, `5-8`, `9-12`, and `13-16`, using max load per group. |
| Is tissue history derived from the actual plan? | **Yes.** `BuhlmannTissueHistorySampler` replays `BuhlmannEngineResult.segments` from the engine result. |
| Does chart sampling mutate decompression math? | **No evidence of mutation.** The engine builds an `engineResult` with empty history, samples afterward, then returns a copy with the same plan outputs. Tests compare fixture TTS/stops after adding sampling. |
| Does the chart fail safely? | **Mostly yes.** Invalid/blocking plans return empty history and the UI shows an empty state instead of substituting a misleading NDL-only primary chart. |

Evidence:

- Sampling is attached after plan construction: `BuhlmannEngine.swift:106-131`.
- Segment replay and grouped output: `BuhlmannTissueHistory.swift:36-122`.
- Group mapping: `BuhlmannTissueHistory.swift:247-254`.
- UI chart data source: `PlannerView.swift:2299-2341`.
- Tests: `BuhlmannTissueHistoryTests.swift` and `PlannerCurveChartTests.swift`.

Remaining concern: display metrics in `BuhlmannTissueHistory.swift:276-279` fall back to sea-level surface pressure if an ambient conversion unexpectedly returns nil. Since planner environment validation normally prevents that path, this is low risk, but a chart should preferably fail empty rather than silently use sea-level display math.

## Decompression Table / PIANO DI RISALITA Assessment

| Row type | Current source | Assessment |
| --- | --- | --- |
| Bottom | Real bottom segments at max bottom depth. | Good source. |
| Travel | Real `.descent` and `.ascent` runtime segments. | Real data, but row semantics/order are weak. |
| Deco stops | Real `DecoStop` values from the engine result. | Good source. |
| Surface | Static terminal row. | Acceptable. |
| PPO2 | Calculated from row gas and row depth; stops carry engine PPO2. | Good. |
| TTS | `DivePlanResult.ttsMinutes` comes from `BuhlmannEngineResult.ttsMinutes`. | Good. |
| Runtime/TTR wording | Dashboard shows separate `TTS` and `Runtime`; briefing copy says `TTS/TTR estimate` while receiving only `tts`. | Copy ambiguity; fix wording or data. |

P2 finding: `PlannerAscentTableBuilder.rows` appends bottom first, then every descent/ascent travel segment, then decompression stops, then surface (`PlannerAscentTableBuilder.swift:36-57`). Because `travelRows` filters both `.descent` and `.ascent` segments (`PlannerAscentTableBuilder.swift:87-108`), the table is based on real data but is not a clean chronological ascent/decompression briefing. Existing tests assert bottom/deco/surface presence and TTS mapping, but do not assert chronological row order.

Recommended future fix:

- Build table rows from engine segments in elapsed-time order, or explicitly split "descent/bottom" from "ascent/deco" so the PIANO DI RISALITA table reads as an ascent plan.
- Add tests for travel row order, ascent rows, PPO2 labels, and mixed travel/deco gas schedules.

## GRAFICI / Depth Profile Assessment

The depth profile chart is truthful in source and shape.

- `PlannerDepthProfileBuilder.points` walks `DivePlanSegment` values in order, starts at surface, appends start/end depth points, and ends at surface if needed.
- The chart in `PlannerView.swift` uses `store.plan.depthProfilePoints`.
- `PlannerDepthProfileTests.swift` checks that points derive from real plan segments and end at surface.

Readiness: **Good**, pending simulator visual QA to confirm chart framing, labels, and small-screen layout.

## CNS / OTU / 15% Rule Assessment

| Area | Assessment | Evidence |
| --- | --- | --- |
| Full-plan CNS | Integrated over the complete engine segment schedule. | `GasPlanningService.swift:131-132`, `OxygenExposureModels.swift:245-323` |
| Descent+bottom CNS | Separate planner-only metric filters `.descent` and `.bottom` only. | `OxygenExposureModels.swift:235-243` |
| Deco/ascent contribution | Displayed as derived `max(0, fullPlanCNS - descentBottomCNS)`. | `GasPlan.swift:446-451`, `PlannerCNSCopyTests.swift` |
| 15% threshold | Uses strict `> 15%`; exactly 15% is acceptable. | `OxygenExposureModels.swift:12-20`, `CNSDescentBottomTests.swift` |
| Toggle | Default-on setting in More. | `PlannerCNSDescentBottomCheckSettings.swift`, `MoreView.swift:254-267` |
| UI warning | Red tile/icon and red warning banner when enabled and threshold exceeded. | `PlannerView.swift:1142-1174`, `PlannerView.swift:1683-1699` |
| Localization | EN/IT keys exist for labels, footnotes, warning, hint, accessibility. | `PlannerCNSCopyTests.swift`, `Localizable.strings` |
| OTU direction | Current implementation is monotonic with PPO2 for fixed duration. | `OxygenExposureModels.swift:147-184`, `OTUCanonicalFixtureTests.swift` |
| O2 deco contribution | Full-profile tests include EAN50 and O2 stop segments increasing CNS/OTU over bottom-only. | `OxygenExposureDeepModelTests.swift:75-85` |

P2 UI clarity gap: the full-plan CNS dashboard tile is always green (`PlannerView.swift:1635-1640`) even when `GasPlanningService` has appended `.oxygenExposureElevated` (`GasPlanningService.swift:702-703`) and warning cards are shown elsewhere. The data is not lost, but the dashboard color can imply "safe" when the full-plan CNS is elevated.

## Algorithmic Consistency Assessment

Strong points:

- `PlannerService.makePlan` builds a single canonical `BuhlmannEngineResult` and derives stops, TTS, runtime, depth profile, ascent table, gas analysis, CNS/OTU, and tissue history from that result.
- Repetitive planning seeds `initialTissueState` before the canonical run rather than recomputing deco metrics from a clean-dive assumption.
- GF comparison helper plans are explicitly comparison outputs and use the seeded base request.
- Gas planning uses the same environment for ambient pressure, consumption, MOD, and oxygen exposure.
- Bailout exclusion is explicit and surfaced in UI hints rather than silently folded into decompression math.

Gaps:

- Ascent table presentation order is not canonical even though its data is real.
- The lightweight `BuhlmannPlanner.plan(...)` preview path builds an early validation request with `gfHigh: 85` before computing NDL with the supplied `gfHigh`; low risk, but confusing for auditability.
- GF equality policy should be decided and documented.

## Numerical Robustness Assessment

Positive evidence:

- Invalid depth/time/GF values fail closed.
- Max planner depth is capped at `120 m`.
- Gas fractions and PPO2 ranges are clamped/validated.
- NDL tests reject fake `999` fallbacks.
- Coefficient weighting handles zero inert gas without division by zero.
- Oxygen exposure rejects invalid segments and caps display values.
- Tissue chart values are finite and clamped to display range.

Residual risks:

- No current macOS XCTest execution was possible in this Windows session.
- No current independent external table/computer comparison was executed in this session.
- Chart display fallback to sea-level surface pressure should be made fail-explicit if it ever occurs.

## UX/UI Readiness Assessment

Ready aspects:

- Planner keeps reference-only/non-certified wording in UI and docs.
- Safety acknowledgment is versioned (`PlannerSafetyAcknowledgment.currentRevision = "2026-05-24"`).
- Tabs separate plan, Bühlmann/tissue curve, and charts.
- Italian and English planner labels exist for CNS, chart, ascent table, and Calculate Plan.
- More contains the CNS Descent + Bottom 15% toggle and explanatory copy.
- The legacy `GasMixCard` is an empty compatibility alias; the active editor is `PlannerCylinderGasEditorView`.

Not ready / needs validation:

- PIANO DI RISALITA order and row semantics should be corrected before relying on it as a briefing table.
- Full-plan CNS tile color should reflect elevated oxygen-exposure state.
- The briefing string `planner.briefing.gf_tts` says "TTS/TTR estimate" but receives only the TTS integer.
- Simulator screenshots and accessibility checks were not run on current HEAD.
- Dynamic Type, localization truncation, and small-screen table/chart behavior still require macOS simulator verification.

## CNS UI/UX Visibility Matrix

| Surface | What user sees | Status | Finding |
| --- | --- | --- | --- |
| Pre-calculation card | CNS bottom preview + footnote that full-plan CNS appears after Calculate Plan. | Good | Clear distinction. |
| Result dashboard | CNS full plan value. | Partial | Always green; should reflect elevated exposure. |
| Secondary metrics | CNS Descent + Bottom. | Good | Turns red with warning icon when >15% and toggle enabled. |
| Warning banner | Red warning and action hint. | Good | Localized and accessible. |
| Ascent/deco estimate | Derived difference from full-plan CNS. | Good | Footnote says reference estimate. |
| More settings | Toggle for 15% descent+bottom warning. | Good | Default on. |
| Export text | Full-plan, descent+bottom, and ascent/deco CNS lines. | Good from inspected code | Needs full export QA on macOS. |

## Chart Truthfulness Matrix

| Chart/table | Claimed meaning | Actual source | Truthfulness | Action |
| --- | --- | --- | --- | --- |
| CURVA BÜHLMANN primary | Sampled ZH-L16C tissue loading. | `BuhlmannEngineResult.tissueHistory.groupedPoints`. | Good | Keep; validate visually. |
| NDL reference curve | NDL minutes by depth. | `BuhlmannPlanner.ndlCurve`. | Good as secondary reference. | Keep secondary; do not promote as tissue loading. |
| Depth profile | Planned depth over elapsed runtime. | `DivePlanSegment` sequence. | Good | Simulator QA. |
| Ascent/deco table | Bottom/travel/deco/surface with PPO2. | Real engine rows and stops. | Partial | Reorder/label chronologically. |
| GF comparison | Alternative GF TTS/stops. | Separate seeded engine plans. | Good as comparison. | Ensure copy says comparison/reference. |

## Test Coverage Assessment

Static test inventory is strong for a project-level iOS planner reference engine:

- 355 iOS algorithm test functions were found under `Tests/iOSAlgorithmTests`.
- Fixtures cover air, nitrox, trimix, GF variants, altitude/fresh/salt differences, repetitive planning, duplicate labels, invalid gas, MOD violation, gas switch too deep, oxygen exposure deco, and lost deco gas.
- Tissue history tests cover non-empty history, 16 compartments per timestamp, four groups, finite values, plan-change sensitivity, fixture stability, and invalid-plan empty history.
- CNS tests cover segment filtering, ascent/deco exclusion for the 15% metric, exactly-15% boundary, disabled toggle behavior, nitrox/trimix profiles, invalid segments, and gas-switch exclusion.
- OTU tests cover canonical constant-depth direction, monotonicity, ramp behavior, daily/weekly carryover decay/reset, and O2 deco contribution.
- Ascent table tests cover bottom/deco/surface presence and TTS mapping, but not chronological order or travel-row semantics.

Not executed:

- No XCTest suite was run in this Windows session because Xcode is unavailable.
- No simulator visual/snapshot test was run.
- No external certified-tool comparison was run.

Recommended added tests:

- Chronological ascent-table order for descent, bottom, ascent travel, gas switches, deco stops, surface.
- PPO2 row values for travel/deco gases at switch/stop depths.
- Dashboard CNS color for elevated full-plan CNS.
- GF Low == GF High acceptance/rejection policy test.
- Tissue-history nil-environment/fallback behavior test.

## Documentation Assessment

Aligned:

- `Docs/IOS_PLANNER_CHART_TRUTHFULNESS.md` correctly describes tissue history as the primary CURVA BÜHLMANN source and NDL as secondary.
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md` describes full-profile CNS/OTU, descent+bottom CNS, 15% warning behavior, and EN/IT UI labels.
- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` documents non-certified positioning, canonical planner result derivation, gas identities, and bailout exclusion.
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` preserves reference-only limitations and CNS UI semantics.

Stale or missing:

- `Docs/README.md` and root `README.md` still cite baseline `90dc3f5`, while audited HEAD is `93d6324`.
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md` footer says aligned with `caa55d2`.
- `Docs/DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md` is not present, although related verification docs exist.
- Some docs cite prior macOS validation runs; current HEAD still needs a fresh macOS pass.

## Risk Matrix

### P0 — Safety-critical blockers

None found in this static pass.

### P1 — Major algorithm correctness blockers

None found in this static pass.

### P2 — Must fix or explicitly defer before stronger TestFlight/readiness claims

| ID | Finding | Evidence | Impact | Recommendation |
| --- | --- | --- | --- | --- |
| IOS-BUH-P2-001 | PIANO DI RISALITA row order is not chronological. | `PlannerAscentTableBuilder.swift:36-57`, `:87-108` | A real-data table can still mislead as a briefing table. | Build rows in elapsed/ascent order; add order tests. |
| IOS-BUH-P2-002 | Full-plan CNS dashboard tile is always green. | `PlannerView.swift:1635-1640` | Elevated full-plan CNS may look safe at dashboard level. | Color/icon from oxygen warning state or threshold; add UI/unit test. |

### P3 — Should fix before release candidate

| ID | Finding | Evidence | Impact | Recommendation |
| --- | --- | --- | --- | --- |
| IOS-BUH-P3-001 | GF equality policy mismatch. | `PlannerInputValidator.swift:53-58`, `BuhlmannEngine.swift:210-216` | Requirement may say `<=`; code rejects equality. | Decide policy; update validation/tests or docs. |
| IOS-BUH-P3-002 | Briefing copy says `TTS/TTR` but receives only TTS. | `GasPlanningService.swift:509-518`, `Localizable.strings:1165` | Copy ambiguity. | Rename to TTS or pass true runtime/TTR value. |
| IOS-BUH-P3-003 | Tissue chart ambient fallback is silent. | `BuhlmannTissueHistory.swift:276-279` | Rare display-only fallback could hide invalid conversion. | Fail empty or surface a chart unavailable state. |
| IOS-BUH-P3-004 | Documentation baselines are stale. | `README.md`, `Docs/README.md`, oxygen model footer | Reviewers may audit the wrong baseline. | Update docs after macOS validation. |
| IOS-BUH-P3-005 | Missing CNS implementation audit doc. | `Docs/DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md` absent | Documentation traceability gap. | Create or remove references/expectation. |

### P4 — Polish / future hardening

| ID | Finding | Recommendation |
| --- | --- | --- |
| IOS-BUH-P4-001 | Constants file has values but not inline source citations. | Keep docs as authority or add concise references in code comments. |
| IOS-BUH-P4-002 | Heliox is compositionally supported but not a named UI mix kind. | Document as trimix/zero-N2 composition or add explicit UI support later. |
| IOS-BUH-P4-003 | Current report is static-only. | Attach macOS test/build logs once run. |

## Release Readiness Verdict

| Gate | Verdict | Rationale |
| --- | --- | --- |
| Internal algorithm review | **Almost ready** | Static code is coherent; macOS tests still required. |
| Internal TestFlight planning | **Almost ready / conditional** | Fix or document P2 UI/table gaps; run simulator QA. |
| External TestFlight | **Not yet** | Needs physical/simulator QA, current build validation, and doc baseline updates. |
| Release candidate | **Not ready** | Requires external mathematical comparison and complete release checklist evidence. |
| Certified decompression claim | **Never claimed / not ready** | App must remain non-certified reference-only unless a future certification process exists. |

## Implementation Plan

### Phase 0 — Validation first

1. On macOS, run `git pull --ff-only`.
2. Run `xcodegen generate`.
3. Build `DIRDiving iOS`.
4. Test `DIRDiving iOS Algorithm Tests`.
5. Save exact command logs and commit hash.

### Phase 1 — P2 readiness fixes

1. Rebuild PIANO DI RISALITA rows in chronological/ascent-briefing order.
2. Add tests for row order, travel/ascent semantics, gas labels, and PPO2 values.
3. Color/icon the full-plan CNS dashboard tile according to elevated oxygen exposure.
4. Add a test for full-plan CNS visibility state.

### Phase 2 — P3 consistency and docs

1. Decide GF equality policy and update validation/tests/docs.
2. Fix `TTS/TTR` briefing copy or pass an actual runtime/TTR value.
3. Replace tissue-history display fallback with explicit empty/error behavior.
4. Update `README.md`, `Docs/README.md`, oxygen model footer, and release docs to current HEAD.
5. Create `Docs/DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md` if that audit is expected in the doc set.

### Phase 3 — Release evidence

1. Add external Bühlmann comparison fixtures with documented tolerances.
2. Run simulator UI QA for compact/large devices, EN/IT, Dynamic Type, and accessibility.
3. Run TestFlight/device checks according to existing release checklists.
4. Keep all claims as non-certified reference-only.

## Protected Files / Areas

Do not change these areas during the next implementation pass unless explicitly requested:

- Watch app code, Watch targets, Watch algorithm tests, Watch sync/auth code.
- Experimental files and experimental branches.
- Generated `.xcodeproj` contents; regenerate with `xcodegen`.
- Legal/safety disclaimer positioning.
- Decompression constants or tissue equations without fixture-backed algorithm tests.
- Planner UI look/feel outside the specific P2/P3 fixes.

## Final Recommendations

Next Cursor/Codex command strategy:

1. First command should be a macOS validation request, not a code edit: run `xcodegen generate`, iOS build, and iOS algorithm tests on current `main`.
2. Second command should fix only the two P2 issues: ascent table order and full-plan CNS dashboard color.
3. Third command should update stale docs and attach validation evidence.
4. Keep each commit narrow: one docs audit commit, one P2 code/tests commit, one documentation/baseline update commit after validation.

Suggested commit strategy:

- Commit this report separately as `docs: update iOS Bühlmann readiness audit at 93d6324`.
- Do not bundle future Swift fixes with this audit report.
- After code fixes, run the full iOS algorithm test target on macOS before merging/pushing.

Final readiness statement: current MAIN iOS Planner is a strong non-certified Bühlmann reference implementation and is **almost ready** for internal validation, but it is not yet a release candidate until P2 UI/table issues, macOS validation, external comparison, and stale documentation are closed.
