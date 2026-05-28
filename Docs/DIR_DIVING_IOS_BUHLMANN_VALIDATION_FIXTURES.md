# DIR DIVING iOS Buhlmann Validation Fixtures

Date: 2026-05-28  
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
| `BuhlmannTissueLoadingTests.swift` | air saturation, helium loading, finite Schreiner loading |
| `BuhlmannCeilingTests.swift` | GF ceiling behavior and mixed N2/He ceiling sanity |
| `BuhlmannNDLTests.swift` | tissue-state NDL, no fake 999-minute fallback, trimix preview |
| `BuhlmannGradientFactorTests.swift` | GF interpolation and GF 30/70 vs 50/80 behavior |
| `BuhlmannMultigasPlannerTests.swift` | trimix + EAN50 + O2 schedule, PlannerService integration |
| `BuhlmannTrimixHeliumTests.swift` | trimix fractions, heliox composition, valid helium planner output |
| `BuhlmannReferenceFixtureTests.swift` | air/nitrox ordering, trimix stop schedule, invalid fixture fail-closed |

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

## Acceptance Expectations

- Valid profiles return `validReference`.
- Invalid profiles return blocking issues and no generated stops.
- Trimix does not return `unsupportedTrimix` when mathematically valid.
- NDL values are finite or unavailable; `999` is never returned as a valid NDL.
- Deco stop PPO2 is actual PPO2 and never clipped to max PPO2.
- Stops are generated from compartment ceilings, not static templates.

## External Validation Still Required

These fixtures are deterministic regression fixtures for the project implementation. Before stronger release claims, compare output against a trusted independent ZHL-16C + GF implementation and preserve tolerances in this document.
