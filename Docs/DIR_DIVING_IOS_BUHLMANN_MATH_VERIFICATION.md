# DIR DIVING iOS Buhlmann Math Verification

Date: 2026-05-29 (reaudit hardening pass)  
Scope: iOS Companion MAIN only

DIR DIVING iOS remains a non-certified informational planning reference. This verification documents the mathematical model used by the iOS-only Buhlmann ZHL-16C multigas engine and the static Windows verification performed in this repository pass.

## Reference Sources

The constants are the common Buhlmann ZHL-16C coefficient set used for N2 and He compartment modeling. The implemented tables are cross-checked against published ZHL-16C reference tables used by open decompression references such as:

- CMAS Buhlmann ZH-L fact sheet: `https://www.cmas.org/fact-sheets/b%C3%BChlmann-zh-l-fra.html`
- DecoTengu Buhlmann model documentation: `https://wrobell.dcmod.org/decotengu/model.html`

The implementation is not claimed to be exactly equivalent to any certified decompression computer.

## 1. ZHL-16C Constants

Implemented in `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`.

- 16 N2 half-times are present and ordered from fast to slow: `5.0 ... 635.0` minutes.
- 16 He half-times are present and ordered from fast to slow: `1.88 ... 240.03` minutes.
- 16 N2 `a` coefficients are present.
- 16 N2 `b` coefficients are present.
- 16 He `a` coefficients are present.
- 16 He `b` coefficients are present.
- `BuhlmannConstantsTests` verifies count and boundary values.

## 2. Inspired Gas Pressure Model

Implemented in `BuhlmannGas.inspiredPressure(depthMeters:inert:)`.

Formula:

```text
ambientPressureBar = surfacePressureBar + (waterDensity * g * depthMeters) / 100000
dryPressureBar = max(0, ambientPressureBar - waterVaporPressureBar)
inspiredN2Bar = dryPressureBar * nitrogenFraction
inspiredHeBar = dryPressureBar * heliumFraction
ceilingDepthMeters = AmbientPressureModel.depthMeters(ambientPressureBar: toleratedPamb, environment: plannerEnvironment)
```

Assumptions:

- Surface pressure: environment-derived barometric approximation (altitude-aware).
- Depth approximation: density-aware pressure/depth conversion (freshwater vs saltwater).
- Water vapour pressure: `0.0627 bar`.
- Oxygen is not loaded as an inert gas.
- Salinity and altitude are validated and applied through `PlannerEnvironment`; invalid environment values fail closed.

Covered by `BuhlmannPressureModelTests`.

## 3. Tissue Loading Math

Implemented in `BuhlmannTissueState.loadedConstantDepth` and `loadedLinearDepth`.

Constant-depth loading uses the zero-rate form:

```text
P(t) = Pi + (P0 - Pi) * e^(-k*t)
k = ln(2) / halfTime
```

Linear depth changes use the Schreiner-style form:

```text
P(t) = Pi0 + R * (t - 1/k) - (Pi0 - P0 - R/k) * e^(-k*t)
```

Validation:

- N2 and He are loaded independently.
- Gas switches preserve tissue state and change subsequent inspired pressures.
- Gas-switch dwell time is modeled as `0.5 min` at switch depth and contributes to runtime/TTS metrics.
- Zero, negative, or non-finite durations return the unchanged state.
- Valid inputs are expected to keep pressures finite and nonnegative.

Covered by `BuhlmannTissueLoadingTests` and `BuhlmannSchreinerEquationTests`.

## 4. Mixed Inert Gas Coefficients

Implemented in `BuhlmannConstants.coefficientA/B`.

Formula:

```text
a = (aN2 * PN2 + aHe * PHe) / max(PN2 + PHe, epsilon)
b = (bN2 * PN2 + bHe * PHe) / max(PN2 + PHe, epsilon)
```

Behavior:

- Pure N2 loading returns N2 coefficients.
- Pure He loading returns He coefficients.
- Mixed loading returns weighted coefficients.
- Zero total inert gas pressure returns zero weighted coefficients and does not divide by zero.

Covered by `BuhlmannConstantsTests` and `BuhlmannNumericalRobustnessTests`.

## 5. Ceiling And M-Value Math

Implemented in `BuhlmannTissueState.ceiling(gf:environment:)`.

For each compartment:

```text
M(Pamb) = a + Pamb / b
toleratedTissue = Pamb + GF * (M(Pamb) - Pamb)
Pamb = (Ptissue - GF * a) / (1 + GF * (1 / b - 1))
ceilingDepth = AmbientPressureModel.depthMeters(ambientPressureBar: toleratedPamb, environment: plannerEnvironment)
```

Behavior:

- The controlling compartment is the one producing the deepest ceiling.
- Ceilings are clamped to nonnegative depths and use environment-aware depth conversion (altitude + salinity).
- First stop depth is derived from the GF Low ceiling and rounded up to the configured 3 m interval.
- Stop schedules are generated from ceilings, not static templates.

Covered by `BuhlmannCeilingTests`, `BuhlmannPressureModelTests`, and `BuhlmannReauditFixTests`.

## 6. Gradient Factor Logic

Implemented in `BuhlmannEngine.gfAtDepth`.

Policy:

- GF Low applies at first stop depth.
- GF High applies at the surface.
- GF is linearly interpolated by current stop depth relative to first stop depth.
- Invalid GF values fail closed in `BuhlmannEngine.validate`.
- GF affects actual ceilings and stop propagation.

Covered by `BuhlmannGradientFactorTests`.

## 7. NDL Calculation

Implemented in `BuhlmannEngine.noDecompressionLimit`.

Policy:

- NDL is tissue-state based.
- Binary search finds the longest bottom time that can surface directly within GF High tolerance.
- Descent, bottom loading, and final ascent are simulated with the request `PlannerEnvironment`.
- Non-air-saturated initial tissue state can be supplied for repetitive/reference planning.
- Air, nitrox, trimix, and heliox use the same N2/He loading path.
- Fake high values such as `999` are not returned as valid NDL.

Covered by `BuhlmannNDLTests`, `BuhlmannReauditFixTests`, and `BuhlmannReferenceFixtureTests`.

## 11. Oxygen Exposure (CNS / OTU)

Implemented in `OxygenExposureModels.swift` (`NOAACNSLimitTable`, `NOAACNSDailyLimitTable`, `CNSRecoveryModel`, `OTUREPEXLimits`, `OTUModel`, `OxygenExposureModel`).

Assumptions:

- **CNS single:** NOAA 1991 piecewise-linear `Tlimit(PPO2)` segments. Constant depth uses `minutes / Tlimit × 100`. Descent/ascent ramps integrate in 0.05-minute steps along linear PPO2 change.
- **CNS daily (24 h):** NOAA daily limit table with linear interpolation between knots 1.0–1.6 bar; parallel accumulation using daily limits.
- **CNS recovery:** 90-minute half-time decay when inspired PPO₂ ≤ 0.5 bar (surface interval and in-water air breaks).
- **OTU dive:** Lambertsen UPTD — constant depth `((PPO2 − 0.5) / 0.5)^(5/6) × minutes` when PPO2 > 0.5 bar (0 otherwise); linear ramps use Baker Eq. 2 with PPO2 clipped at 0.5 bar when crossing the toxicity threshold. Independent fixtures: `OTUCanonicalFixtureTests.swift`.
- **OTU daily / weekly:** REPEX reference thresholds — dive OTU ≥ 300, daily 24 h ≥ 850, weekly ≥ 1 800; daily resets after 24 h SI, weekly after 7 d.
- **Repetitive carryover:** `TissueSnapshot` schema v2 stores `oxygenCarryover`; `PlannerService` applies surface-interval decay/resets before the next plan.
- Invalid segment depth/duration or non-finite results fail closed via `OxygenExposureWarningState.invalidExposureInput`.

Covered by `OxygenExposureDeepModelTests` (14 tests), `BuhlmannReauditFixTests`, and schedule-aware analysis in `GasPlanningService`.

## 8. Multigas Decompression Algorithm

Implemented in `BuhlmannEngine.plan`.

Flow:

1. Validate profile, GF, and gases.
2. Load descent segments, including travel gas switches.
3. Load one or more bottom segments.
4. Calculate first ceiling using GF Low.
5. Round first stop up to the 3 m stop interval.
6. Ascend to stop depths using configured ascent rate.
7. At each stop, select the highest oxygen deco gas that is allowed by switch depth, MOD, and minimum PPO2.
8. Hold until the next shallower stop is allowed by the current GF.
9. Continue until surface.

Runtime policy:

- `ttsMinutes`: time from end of bottom loading to surface.
- `totalRuntimeMinutes`: descent + bottom + gas-switch dwell + ascent/stops.
- `bottomMinutes`: planned bottom loading time only.
- `descentMinutes`: modeled descent time.

Covered by `BuhlmannMultigasPlannerTests` and `BuhlmannTrimixHeliumTests`.

## 9. Numerical Robustness

The engine validates:

- finite depth, time, GF, rates, stop interval, and gas values
- depth range
- bottom time range
- O2 and He fractions
- O2 + He <= 1.0
- bottom segment duration/depth/gas
- MOD and minimum operating PPO2
- gas switch depths
- full respired segment gas range: the gas must remain breathable at the shallow end and below max PPO2 at the deep end

Invalid states return typed blocking issues and `modelState == invalidInput` or `modelIncomplete`.

Covered by `BuhlmannNumericalRobustnessTests`.

## 10. Safety Positioning

The planner must remain:

- "Buhlmann ZHL-16C N2+He multigas reference-only"
- non-certified
- not a primary life-support instrument
- not real-time decompression control

Existing disclaimer and safety documentation remain in force.

## macOS Verification (2026-05-29)

- `xcodegen generate`
- `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build` — succeeded
- `xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test` — succeeded

## Remaining Required Validation

Before release claims are broadened:

- Run `xcodegen generate` on macOS.
- Build `DIRDiving iOS` on macOS.
- Run `DIRDiving iOS Algorithm Tests` on macOS.
- Expand the independent ZHL-16C + GF reference fixture set beyond the current Air/Nitrox/Trimix external envelopes and document tighter tolerances.

## 11. Environment Baseline Unification (2026-05-29)

| Item | Before | After |
|---|---|---|
| Default `airSaturated()` surface pressure | `1.0 bar` via `IOSAlgorithmConfiguration` | `1.01325 bar` via `BuhlmannConstants.seaLevelSurfacePressureBar` |
| Preview NDL environment | Default sea-level only (ignored planner altitude/salinity) | Same `PlannerEnvironment` as `PlannerService.makePlan` |
| Nil-environment Bühlmann gas pressure | Legacy `IOSUnitConversions.ambientPressureBar(depthMeters:)` | ISA sea-level saltwater constants in `BuhlmannGas` |

Verified by `BuhlmannComprehensiveReadinessFixTests` and `BuhlmannConstantsTests.testSeaLevelSurfacePressureMatchesPlannerEnvironment`.

## 12. Tissue History Display Metrics (2026-06-02)

Visualization-only sampling in `BuhlmannTissueHistorySampler` (does not feed back into stop calculation):

```text
totalInert = PN2 + PHe (compartment)
M = a + b * ambientPressureBar
loadPercent_display = clamp(0, 100, (totalInert / M) * 100)
supersaturationPercent_display = clamp(0, 100, ((totalInert - inspiredInert) / (M - inspiredInert)) * 100)
```

Grouped chart value at time `t`: **max** `loadPercent_display` among compartments in each group {1–4, 5–8, 9–12, 13–16}.

Verified by `BuhlmannTissueHistoryTests` (finite values, 16 compartments, golden fixture TTS/stop stability).

## 13. Canonical Engine Consistency (2026-06-07)

Hardening pass verifies one canonical `BuhlmannEngine.plan` result feeds all derived outputs:

| Check | Test |
|---|---|
| `PlannerService` TTS matches `BuhlmannPlanner.enginePlan` | `testPlannerServiceTTSMatchesEnginePlan` |
| Preview NDL uses `PlannerEnvironment` (not silent sea-level) | `testPreviewNDLUsesPlannerEnvironment` |
| Full-plan CNS ≥ descent+bottom on deco profile | `testFullPlanCNSIncludesDecoAndExceedsDescentBottom` |
| Base mode excludes inactive deco cylinders from projection | `testBaseModeStripsDecoCylindersFromProjection` |
| Ascent table deco rows match `plan.decoStops` | `testAscentTableDecoRowsMatchEngineStops` |

Suite: `BuhlmannEngineCanonicalConsistencyTests.swift`.
