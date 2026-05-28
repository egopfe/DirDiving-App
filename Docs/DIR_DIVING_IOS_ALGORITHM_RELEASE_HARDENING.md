# DIR DIVING iOS Algorithm Release Hardening

Date: 2026-05-28
Scope: iOS Companion MAIN branch only

DIR DIVING iOS remains a non-certified informational diving companion. Planner, gas, NDL, CNS/OTU, END/EAD, route, import, export, sync, and Buhlmann outputs must not be used as certified decompression or life-support advice.

## Summary

This pass upgrades iOS MAIN from a conservative safe-reference planner to an isolated Buhlmann ZHL-16C multigas planning reference engine with nitrogen and helium tissue loading. It preserves the premium dark UI, navigation, layout, colors, icons, Apple Watch code, watchOS targets, experimental files, and legal/safety positioning.

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
- Salinity and altitude are still stored and documented, but not yet used to alter ambient pressure.
- CNS/OTU remain simplified reference estimates.
- Physical-device, Xcode, simulator, and TestFlight validation must run on macOS.

## Release Position

iOS MAIN can now be described as having a Buhlmann ZHL-16C N2+He multigas planning reference engine for internal validation, while still requiring external mathematical validation and App Store/TestFlight QA before release claims are broadened.
