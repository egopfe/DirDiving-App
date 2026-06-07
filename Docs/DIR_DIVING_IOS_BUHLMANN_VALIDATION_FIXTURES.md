# DIR DIVING iOS Buhlmann Validation Fixtures

Date: 2026-05-29 (reaudit hardening pass)  
Scope: iOS Companion MAIN only

## Test Target

The Buhlmann engine is covered by `DIRDiving iOS Algorithm Tests`.

On macOS:

```sh
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

On Windows, Xcode tooling is unavailable; validation is limited to static code inspection.

## Fixture Groups

| Test File | Coverage |
|---|---|
| `BuhlmannConstantsTests.swift` | ZHL-16C N2/He constant counts and boundary values |
| `BuhlmannGasValidationTests.swift` | invalid gas mixes, MOD/PPO2, hypoxic gas, gas-switch depth |
| `BuhlmannPressureModelTests.swift` | ambient pressure, water vapor, inspired N2/He, oxygen non-inert handling |
| `BuhlmannTissueLoadingTests.swift` | air saturation, helium loading, finite Schreiner loading |
| `BuhlmannSchreinerEquationTests.swift` | zero/negative duration handling, on/off-gassing and gas-switch loading |
| `BuhlmannCeilingTests.swift` | GF ceiling behavior and mixed N2/He ceiling sanity |
| `BuhlmannNDLTests.swift` | tissue-state NDL, no fake 999-minute fallback, trimix preview |
| `BuhlmannGradientFactorTests.swift` | GF interpolation and GF 30/70 vs 50/80 behavior |
| `BuhlmannMultigasPlannerTests.swift` | trimix + EAN50 + O2 schedule, PlannerService integration |
| `BuhlmannTrimixHeliumTests.swift` | trimix fractions, heliox composition, valid helium planner output |
| `BuhlmannReferenceFixtureTests.swift` | air/nitrox ordering, trimix stop schedule, invalid fixture fail-closed |
| `BuhlmannGoldenFixtureTests.swift` | golden fixture parser + deterministic fixture execution and range validation |
| `PlannerRegressionFixtureTests.swift` | invalid-fixture fail-closed checks and GF conservatism regression |
| `BuhlmannNumericalRobustnessTests.swift` | invalid profile values, zero depth/time, invalid segments, finite outputs, unit round trips |
| `BuhlmannReauditFixTests.swift` | 2026-05-28 reaudit fixes: environment NDL/ceiling, repetitive canonical result, duplicate labels, rock-bottom, surface interval, oxygen exposure, GF seeded tissue |
| `BuhlmannReleaseHardeningTests.swift` | external reference envelopes, TTS/runtime split, residual tissue seed, full segment gas-operability checks, travel-gas ascent waypoints |
| `BuhlmannExternalValidationMetadataTests.swift` | fixture validationStatus/referenceSource/tolerance metadata; no certified-equivalence claims |
| `BuhlmannEngineCanonicalConsistencyTests.swift` | single canonical engine path; environment-aware preview NDL; mode projection; ascent table ↔ stops |

## Validation metadata (2026-06-07)

JSON fixtures may omit metadata fields; `PlannerFixture` decoder applies defaults:

| Field | Default when omitted |
|---|---|
| `validationStatus` | `internal_regression` |
| `referenceSource` | `internal-ios-buhlmann-suite` |
| `validationNotes` | Internal regression envelope; not third-party certified |
| `ascentDescentAssumptions` | Schreiner segments; sea-level salt unless `environment` set |

Allowed `validationStatus` values:

- `internal_regression` — XCTest range envelopes (current)
- `pending_external_validation` — placeholder until external reference captured
- `external_reference_validated` — **future only**; requires signed external campaign

See [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md).

## Extended Golden Fixture Schema (2026-05-29)

JSON fixtures under `Tests/iOSAlgorithmTests/Fixtures/` may include:

- `environment` (`altitudeMeters`, `salinity`)
- `priorDive` (depth, bottom time, surface interval) for repetitive seeding
- `expectedTTSRangeMinutes`, `expectedNDLRangeMinutes`, `expectedFirstStopDepthMeters`
- `gasMixId` / `cylinderId` on fixture gases for stable identity tests
- `toleranceMinutes` (required; malformed fixtures without it are rejected)

Additional profiles: `duplicate-gas-labels.json`, `oxygen-exposure-deco.json`.

Fixture JSON files are bundled as test resources via `project.yml` (`Tests/iOSAlgorithmTests/Fixtures`).

## Required Fixture Profiles

- Air 21% at 30 m.
- Nitrox 32 at 30 m.
- Trimix 18/45 bottom gas at 50 m.
- Multiple validated bottom gas segments.
- EAN50 decompression gas at 21 m.
- Oxygen decompression gas at 6 m.
- GF 30/70 compared with GF 50/80.
- Invalid O2 + He > 100%.
- MOD exceeded.
- Hypoxic gas used too shallow.
- Gas switch deeper than gas MOD.
- Helium tissue loading.
- Mixed N2/He ceiling calculation.
- External reference-envelope profiles generated with `decotengu 0.14.1`.
- Repetitive/reference planning seeded from a previous final tissue state.
- Segment gas validation across the full breathed depth range.
- Fixture sources/tolerances documented in `Docs/DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`.

## Acceptance Expectations

- Valid profiles return `validReference`.
- Invalid profiles return blocking issues and no generated stops.
- Trimix does not return `unsupportedTrimix` when mathematically valid.
- NDL values are finite or unavailable; `999` is never returned as a valid NDL.
- Deco stop PPO2 is actual PPO2 and never clipped to max PPO2.
- Stops are generated from compartment ceilings, not static templates.
- `ttsMinutes` is time to surface from end of bottom loading; `totalRuntimeMinutes` includes descent, bottom, validated ascent/travel/deco switches, ascent and stops.
- Gas-switch dwell contributes to tissue loading and runtime accounting.

## External Validation Still Required

These fixtures are deterministic regression fixtures for the project implementation. Before stronger release claims, compare output against a trusted independent ZHL-16C + GF implementation and preserve tolerances in this document.

## 2026-05-29 Fixture Extensions

New automated coverage in `BuhlmannComprehensiveReadinessFixTests`:

- Preview NDL vs plan NDL alignment (same environment, ±0.5 min).
- Altitude and salinity preview NDL divergence.
- Sea-level saturated tissue vs `PlannerEnvironment.seaLevelSaltWater`.
- Repetitive snapshot states: missing, stale, schema mismatch, surface interval rejected.
- GF comparison cache output stability.

External validation campaign checklist: `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`.
