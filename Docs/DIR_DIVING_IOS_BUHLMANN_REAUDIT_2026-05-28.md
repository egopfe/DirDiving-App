# DIR DIVING iOS Buhlmann Re-Audit - 2026-05-28

## Scope

This report covers the iOS Companion MAIN branch Buhlmann / gas planner implementation only.

No code changes were made during this audit pass.

## Repository Version Check

- Repository: `C:\Users\egopf\Documents\Codex\2026-05-08\puoi-prendere-il-codice-di-dirdiving\DirDiving-App`
- Branch: `main`
- Local HEAD: `76fce90d52f4b582de970539109f89fc808844d3`
- Remote `origin/main`: `76fce90d52f4b582de970539109f89fc808844d3`
- Status: local tracked code is aligned with remote `origin/main`

Latest relevant commits observed:

- `76fce90 docs(ios): update gas and Buhlmann planner validation docs`
- `b1298b1 test(ios): add Buhlmann golden fixtures`
- `5747e77 feat(ios): formalize oxygen exposure calculations`
- `911b2a7 feat(ios): add repetitive Buhlmann planning references`
- `089f0de feat(ios): add altitude and salinity pressure model`

## Executive Verdict

The iOS Buhlmann planner is no longer placeholder-only. The codebase now contains an iOS-only ZHL-16C style planning reference engine with:

- nitrogen and helium compartment constants
- independent N2 / He tissue loading
- trimix-capable gas definitions
- gradient factor planning paths
- oxygen exposure support
- altitude and salinity environment hooks
- repetitive planning references
- schedule-based gas consumption ledger work
- golden fixture tests

However, the current implementation should not yet be considered fully release-hard. No immediate P0 blocker was found in static inspection, but several P1 and P2 issues remain before the planner can be treated as mathematically robust for serious internal validation.

## Files Inspected

- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `Tests/iOSAlgorithmTests/BuhlmannGoldenFixtureTests.swift`
- `Tests/iOSAlgorithmTests/PlannerRegressionFixtureTests.swift`
- `Tests/iOSAlgorithmTests/Fixtures/*.json`
- `project.yml`

## Positive Findings

- The Buhlmann engine is isolated under the iOS application area.
- Full N2 and He model structures are present.
- The planner has moved beyond static placeholder stops.
- Oxygen exposure is now represented as a formal model.
- Altitude and salinity are present as planner environment inputs.
- Repetitive dive planning references have been introduced.
- Fixture-based tests exist.
- No obvious merge conflict markers were found in the inspected files.
- No obvious `fatalError`, `try!`, or forced unsafe placeholder markers were found in the inspected Buhlmann planner files.

## P0 Findings

No P0 blocker was found during static inspection.

Important limitation: this audit was performed on Windows. XcodeGen, xcodebuild, and XCTest were not available in the environment, so macOS build/test verification is still required.

## P1 Findings

### P1.1 Environment-aware ceiling calculation is incomplete

`BuhlmannTissueModel.ceiling(gf:)` converts tolerated ambient pressure back to depth using the generic sea-level pressure conversion.

Impact:

- Tissue loading can use `PlannerEnvironment`, but ceiling depth conversion does not.
- Altitude and freshwater stop depths may be internally inconsistent.
- NDL and stop schedule behavior can diverge from the selected environment.

Recommended fix:

- Add an environment-aware ceiling function.
- Convert tolerated ambient pressure to depth using the same environment model used for loading.
- Require all planner paths to pass `PlannerEnvironment` into ceiling calculation.

### P1.2 NDL calculation ignores planner environment

Several NDL paths still use default sea-level saltwater assumptions.

Impact:

- NDL may be inconsistent with altitude or freshwater planner settings.
- The planner may show mixed-environment results in the same plan.

Recommended fix:

- Add environment to all NDL APIs.
- Remove default sea-level fallback from internal NDL calls.
- Add fixture tests for sea-level saltwater vs altitude freshwater NDL behavior.

### P1.3 Repetitive planning results are partially inconsistent

`PlannerService` can compute an engine plan from seeded repetitive tissue state, but then helper outputs such as stops, runtime segments, and GF comparisons are recomputed through unseeded helper calls.

Impact:

- TTS / NDL / stop schedule may not all come from the same tissue state.
- UI and exported plan values may mix clean-dive and repetitive-dive assumptions.

Recommended fix:

- Use one canonical `BuhlmannEngineResult` per planner run.
- Derive stops, runtime segments, TTS, NDL, and GF comparisons from the same seeded tissue state.
- Add tests comparing clean vs repetitive planning outputs.

### P1.4 Schedule gas allocation can crash with duplicate gas labels

`ScheduleGasConsumptionService` uses dictionary construction keyed by gas label.

Impact:

- Duplicate gas labels can trigger a runtime trap.
- Multiple cylinders/stages with the same gas are not safely represented.

Recommended fix:

- Replace label-keyed allocation with stable cylinder or gas IDs.
- Group duplicate labels safely when aggregation is intentional.
- Add duplicate-gas tests.

## P2 Findings

### P2.1 Multigas remaining pressure summary may be misleading

The schedule gas ledger exposes remaining pressure from the first sorted entry rather than explicitly selecting the bottom gas or showing per-gas results.

Recommended fix:

- Expose per-gas ledger values.
- Keep the summary tied to the bottom gas or explicitly label the selected gas.

### P2.2 Rock-bottom and gas planning still use legacy pressure assumptions in places

Some rock-bottom calculations still use sea-level pressure conversion rather than the planner environment.

Recommended fix:

- Route all pressure calculations through `PlannerEnvironment`.
- Add altitude/freshwater rock-bottom tests.

### P2.3 Planner environment validation and messaging are inconsistent

Validation copy still suggests salinity and altitude do not affect the model, even though environment hooks now exist.

Recommended fix:

- Update validation messages.
- Fail closed on invalid environment values instead of silently falling back to sea-level saltwater.

### P2.4 Surface interval off-gassing ignores environment

The repetitive dive surface interval model accepts an environment parameter but does not consistently pass it into tissue loading.

Recommended fix:

- Apply environment to surface interval off-gassing.
- Add altitude surface-interval tests.

## P3 Findings

### P3.1 Golden fixtures are not strong enough yet

Existing fixture tests are useful, but altitude, freshwater, and repetitive fixtures do not appear to encode enough environment or prior-tissue state data to truly validate those features.

Recommended fix:

- Extend fixture schema with environment, prior dive, expected controlling compartment, expected first stop, and expected TTS ranges.

### P3.2 Oxygen exposure model needs stronger external validation

The CNS / OTU model is now formalized. **Follow-up @ `dae29b8`:** comprehensive NOAA single/daily limits, surface/air-break recovery, REPEX OTU, snapshot v2 carryover — see [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) and `OxygenExposureDeepModelTests`.

Recommended fix (historical):

- ~~Add fixture tests for CNS / OTU.~~ → **Done @ `dae29b8`:** 14 cases in `OxygenExposureDeepModelTests`; suite **119/119** pass.
- Document source assumptions and tolerances.

### P3.3 Gas identity is too label-dependent

Gas labels are fragile when custom mixes or rounded percentages are used.

Recommended fix:

- Use stable IDs for gas plans and cylinders.
- Keep labels only for display.

## Recommended Implementation Plan

1. Make all ceiling calculations environment-aware.
2. Thread `PlannerEnvironment` through every NDL and GF comparison path.
3. Make `PlannerService` use one canonical engine result for all derived outputs.
4. Replace gas-label identity with stable gas/cylinder identity.
5. Make the gas ledger per-gas and bottom-gas-aware.
6. Route rock-bottom and reserve calculations through environment-aware pressure.
7. Remove silent environment fallback behavior.
8. Apply environment to repetitive surface interval off-gassing.
9. Strengthen fixtures for altitude, freshwater, repetitive dives, trimix, and oxygen exposure.
10. Run XcodeGen, iOS build, and iOS algorithm XCTest suite on macOS.

## Required macOS Validation

This audit could not execute Apple build tooling in the current Windows environment.

Required commands on macOS:

```sh
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Final Status

The repository code inspected is up to date with `origin/main`.

The Buhlmann implementation is substantially advanced and directionally correct, but further P1/P2 hardening is recommended before calling it fully release-hard.
