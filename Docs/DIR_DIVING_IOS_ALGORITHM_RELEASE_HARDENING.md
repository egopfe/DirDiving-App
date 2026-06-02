# DIR DIVING iOS Algorithm Release Hardening

Date: 2026-05-29 (reaudit hardening pass)
Scope: iOS Companion MAIN branch only

DIR DIVING iOS remains a non-certified informational diving companion. Planner, gas, NDL, CNS/OTU, END/EAD, route, import, export, sync, and Buhlmann outputs must not be used as certified decompression or life-support advice.

## Summary

This pass upgrades iOS MAIN from a conservative safe-reference planner to an isolated Buhlmann ZHL-16C multigas planning reference engine with nitrogen and helium tissue loading. It preserves the premium dark UI, navigation, layout, colors, icons, Apple Watch code, watchOS targets, experimental files, and legal/safety positioning.

Additional hardening in this pass:

- schedule-based gas consumption ledger from generated runtime segments
- altitude/salinity planner environment pressure model with fail-closed validation
- repetitive planning reference seed via tissue snapshots and surface-interval off-gassing
- segment-based CNS/OTU accumulation with typed warning states
- golden/regression fixture framework (`Tests/iOSAlgorithmTests/Fixtures/*.json`)

## 2026-05-28 Reaudit Fixes (P1–P3)

| ID | Fix |
|---|---|
| P1.1 | Environment-aware ceiling depth conversion via `AmbientPressureModel` |
| P1.2 | `PlannerEnvironment` threaded through all NDL and GF comparison paths |
| P1.3 | Single canonical `BuhlmannEngineResult` per `PlannerService.makePlan` |
| P1.4 | Cylinder UUID ledger; duplicate gas labels no longer crash |
| P2.1 | Per-cylinder gas ledger + bottom-gas remaining pressure summary |
| P2.2 | Rock-bottom/reserve through `PlannerEnvironment` |
| P2.3 | Environment validation fail-closed; removed misleading “not applied” messaging |
| P2.4 | Surface-interval off-gassing uses `PlannerEnvironment` |
| P3.1 | Extended golden fixture schema + new altitude/fresh/repetitive/trimix/oxygen/duplicate-label fixtures |
| P3.2 | `OxygenExposureModel` CNS/OTU validation tests and fail-closed invalid input |
| P3.3 | Stable `gasMixId` / `cylinderId` on `BuhlmannGas`; labels display-only |

macOS validation (2026-05-29): `DIRDiving iOS` build succeeded; `DIRDiving iOS Algorithm Tests` — **TEST SUCCEEDED**.

## 2026-05-29 UX/UI Readiness Pass

Presentation-only updates (no Bühlmann/gas math changes):

- Repetitive planning controls and fail-closed snapshot status in `PlannerView`
- Schedule gas ledger result card (per-cylinder consumed/remaining/reserve flags)
- Environment pressure-model messaging aligned with active altitude/salinity behavior
- Typed `PlannerResultState` → title/message/severity/corrective-hint mapping
- Explicit result header badge (no-deco vs deco-required vs invalid vs repetitive vs environment-adjusted)
- CNS/OTU reference-only disclaimer where values appear
- VoiceOver labels and non-truncating warning copy on planner input/result flows

Warning taxonomy includes snapshot missing/stale/corrupt/schema mismatch, gas allocation incomplete, missing cylinder, no valid decompression solution, invalid environment, and elevated oxygen exposure. All safety-critical states expose corrective hints; none imply certified decompression authority or real-time dive-computer behavior.

See `DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md` for acceptance verification.

## 2026-05-31 Comprehensive CNS/OTU Model

Runtime implementation in `OxygenExposureModels.swift` (`dae29b8`):

| Component | Description |
|---|---|
| `NOAACNSLimitTable` | NOAA 1991 single-exposure piecewise-linear limits |
| `NOAACNSDailyLimitTable` | 24 h daily CNS limits with interpolation 1.0–1.6 bar |
| `CNSRecoveryModel` | 90 min half-time decay during surface interval and segments with PPO₂ ≤ 0.5 bar |
| `OTUModel` | Lambertsen UPTD; constant depth and Baker Eq. 2 ramp integration |
| `OTUREPEXLimits` | Elevated dive OTU ≥ 300; daily 24 h ≥ 850; weekly ≥ 1800; reset windows 24 h / 7 d |
| `OxygenExposureCarryover` | Repetitive state: single/daily CNS, daily/weekly OTU |
| `TissueSnapshot` v2 | Optional `oxygenCarryover` persisted on Calculate |
| `PlannerService` | Applies surface-interval decay/resets before next plan |

Tests: `OxygenExposureDeepModelTests` (14 cases). Suite total: **119/119** pass on iPhone 17 sim.

Positioning unchanged: reference planning only — not certified oxygen exposure guidance.

## Planner CNS/OTU UI (2026-06-02)

- Result screen labels: **CNS (full plan)**, **CNS Descent + Bottom**, **CNS ascent/deco (est.)**, **OTU** in the existing PLAN tab metric grid.
- Pre-calculation label: **CNS (bottom preview)** with footnote before full plan calculation.
- EN/IT footnotes state full-plan CNS includes decompression segments; descent+bottom excludes ascent/deco stops.
- 15% warning: red tile + localized warning + action hint + VoiceOver label/hint when threshold exceeded.
- Tests: `PlannerCNSCopyTests`, `CNSDescentBottomTests` (math unchanged).

## Buhlmann Engine Status

Implemented in `iOSApp/Algorithms/Buhlmann/`:

- ZHL-16C nitrogen half-times and a/b coefficients.
- ZHL-16C helium half-times and a/b coefficients.
- Independent nitrogen and helium compartment loading.
- Water vapor pressure correction.
- Ambient pressure/depth conversion through `IOSUnitConversions`.
- Constant-depth loading.
- Schreiner linear-depth loading for descent/ascent segments.
- Mixed N2/He coefficient weighting.
- Ceiling calculation with gradient factor.
- Tissue-state NDL search.
- GF Low / GF High interpolation from first stop to surface.
- Stop rounding to 3 m increments.
- Staged decompression stop generation from compartment ceilings.
- Travel, bottom, deco, oxygen, nitrox, trimix, and heliox gas support when inputs validate.

The engine is a planning reference only. It is not a certified decompression computer.

## P0 / P1 Issues Fixed

- Trimix no longer receives N2-only Buhlmann output.
- Valid trimix now uses helium tissue loading and mixed N2/He ceilings.
- Full gas validation fails closed for invalid O2/He fractions, MOD violations, gas-switch depth violations, and hypoxic gas use.
- Decompression stops are generated from tissue ceilings instead of static stop templates.
- GF Low / GF High now drive ceiling and stop propagation math.
- NDL is tissue-state based and never returns fake `999` values.
- TTS is separated from total runtime; total runtime includes descent, bottom, gas-switch dwell, ascent and stops.
- PPO2 is exposed as actual PPO2 with max PPO2 separate; over-limit values are not clipped.
- Gas validation now checks the whole breathed segment range, not only isolated switch/depth points.
- Repetitive/reference planning can be seeded with a non-air-saturated initial tissue state.
- Gas-switch dwell is modeled in tissue loading and runtime accounting.
- External reference-envelope values are documented from `decotengu 0.14.1`.

## P2 / P3 Hardening Kept

- Planner, gas, import/export, sync, route, and logbook validation remain centralized.
- Time-weighted logbook average depth remains in `DiveProfileMath`.
- Sync/import/export reject corrupted data deterministically.
- Unit conversions remain centralized in `IOSUnitConversions`.
- Planner warnings are typed through `PlannerResultState`, including `nonCertifiedReference`.

## Planner Strategy

The current iOS MAIN planner uses a complete ZHL-16C N2+He compartment engine for reference planning, while still presenting every output as non-certified:

- Air and nitrox plans use N2 tissue loading.
- Trimix and heliox plans use N2+He tissue loading.
- Travel and deco gases alter tissue loading after gas switches, including validated ascent gas switches on no-stop returns.
- Gas switches are validated against MOD and minimum PPO2.
- Static stop templates are no longer the source of planner decompression stops.
- CNS/OTU and gas-density values remain separate reference estimates.

## Validation Rules

Central validators and the Buhlmann engine reject or flag:

- NaN and infinity.
- Unsupported depth or bottom time.
- Invalid gradient factors.
- O2 <= 0 or O2 > 1.
- He < 0 or O2 + He > 1.
- PPO2 outside configured gas limits.
- Bottom-gas MOD exceeded.
- Deco/travel gas switch deeper than MOD.
- Hypoxic gas used shallower than breathable PPO2.
- Gas not operational across the full breathed segment.
- Invalid cylinder, SAC/RMV, pressure, GPS, sample, import, export, and sync values from the previous hardening pass.

## Test Coverage Added

The `DIRDiving iOS Algorithm Tests` target now includes:

- `BuhlmannConstantsTests`
- `BuhlmannGasValidationTests`
- `BuhlmannPressureModelTests`
- `BuhlmannTissueLoadingTests`
- `BuhlmannSchreinerEquationTests`
- `BuhlmannCeilingTests`
- `BuhlmannNDLTests`
- `BuhlmannGradientFactorTests`
- `BuhlmannMultigasPlannerTests`
- `BuhlmannTrimixHeliumTests`
- `BuhlmannReferenceFixtureTests`
- `BuhlmannNumericalRobustnessTests`
- `BuhlmannReleaseHardeningTests`

Coverage includes air, nitrox 32, trimix bottom gas, EAN50 deco gas, oxygen deco gas, GF 30/70 vs 50/80, invalid O2+He mixes, MOD exceeded, hypoxic gas use, gas switch too deep, helium tissue loading, mixed N2/He ceilings, pressure model checks, Schreiner loading checks, no fake 999-minute NDL, invalid segment handling, zero/negative/unsupported profile values, full-segment gas operability, external reference envelopes, residual tissue seed, and tolerance-based numerical checks.

## Remaining Limitations

- This is a reference planner, not a certified decompression engine or dive computer.
- A first external reference-envelope cross-check is documented; a larger independent validation campaign is still required before any stronger claim.
- Salinity and altitude are applied via `PlannerEnvironment` to ambient pressure, NDL, ceiling, consumption, and preview paths when valid.
- CNS/OTU remain simplified reference estimates.
- Physical-device, Xcode, simulator, and TestFlight validation must run on macOS.

## Release Position

iOS MAIN can now be described as having a Buhlmann ZHL-16C N2+He multigas planning reference engine for internal validation, while still requiring external mathematical validation and App Store/TestFlight QA before release claims are broadened.

## 2026-05-29 Comprehensive Readiness Pass

| ID | Item | Resolution |
|---|---|---|
| P1-1 | External validation campaign | Documented — `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` |
| P1-2 | Dual surface-pressure baseline | Fixed — unified `1.01325 bar` in Bühlmann constants and `airSaturated()` |
| P2-1 | Preview ignores planner environment | Fixed — `PlannerStore` passes `PlannerEnvironment` |
| P2-2 | Repetitive snapshot semantics | UI/docs clarify prior reference plan; snapshot persists on Calculate only |
| P2-3 | `surfaceIntervalRejected` never emitted | Fixed — `invalidSurfaceInterval` error mapped |
| P2-4 | Physical accessibility QA | Checklist — `DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md` |
| P2-5 | CNS/OTU model simplicity | Documented in limitations |
| P3-1 | Bailout not in engine schedule | Documented + UI hint |
| P3-2 | Legacy 10 m/bar fallback | Replaced in Bühlmann paths |
| P3-3 | GF comparison performance | In-memory cache (outputs unchanged) |
| P3-4 | Calculation progress | Progress indicator on Calculate button |
| P4-1 | Logbook tissue seed | Documented future enhancement |
| P4-2 | Team gas matching | Existing polish; no algorithm change |

New test file: `BuhlmannComprehensiveReadinessFixTests.swift`.
