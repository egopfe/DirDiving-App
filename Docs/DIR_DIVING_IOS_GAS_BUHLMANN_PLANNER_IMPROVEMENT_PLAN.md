# DIR DIVING iOS Gas & Buhlmann Planner Improvement Plan

Date: 2026-05-28  
Scope: iOS Companion MAIN only  
Status: implementation plan, no code changes in this document

## Purpose

This document defines the implementation plan for the next comprehensive hardening pass of the DIR DIVING iOS Companion gas planner and Buhlmann ZHL-16C multigas planning reference engine.

The goal is to improve schedule-based gas consumption, altitude/salinity pressure modeling, repetitive dive planning, CNS/OTU formalization, and validation fixture coverage while preserving the existing premium UI, legal positioning, and project architecture.

DIR DIVING remains a non-certified informational diving companion. The planner must continue to be presented only as a Buhlmann-based planning reference and never as certified decompression advice or life-support instrumentation.

## Scope Guard

Allowed scope:

- `iOSApp/*`
- `Tests/iOSAlgorithmTests/*`
- `Docs/*`
- `README.md` only if documentation references need updating

Forbidden scope:

- Apple Watch code
- watchOS targets
- Watch views, managers, models, services, tests, entitlements
- experimental branches or experimental-only files
- UI redesign, colors, typography, icons, layout, visual identity, navigation
- legal disclaimer weakening or removal

All invalid or incomplete mathematical states must fail closed through typed warning/error states.

## Phase 1: Schedule-Based Gas Consumption

### Objective

Replace bottom-only gas usage estimates with gas consumption calculated from the generated Buhlmann runtime schedule.

### Proposed Components

- `ScheduleGasConsumptionService`
- `GasConsumptionLedger`
- `GasCylinderAllocation`
- `GasUsageWarningState`

### Functional Requirements

- Calculate gas consumption per generated segment using:
  - segment depth
  - segment duration
  - segment gas
  - SAC/RMV
  - ambient pressure
- Allocate usage to the correct gas/cylinder:
  - bottom gas
  - travel gas
  - deco gas
  - bailout gas where applicable
- Compute:
  - liters consumed per gas
  - remaining liters
  - remaining bar/psi
  - reserve breach
  - minimum gas / rock-bottom comparison
  - lost-gas contingency impact
- Replace planner summary values with schedule-aware values where possible.
- Preserve existing UI style and navigation.

### Tests

- Bottom gas only.
- Trimix bottom + EAN50 + O2.
- Travel gas usage on descent and ascent.
- Deco gas reserve breach.
- Negative remaining gas produces warning/error state.
- Missing matching cylinder fails closed.
- Unit conversion bar/psi consistency.

### Acceptance Criteria

- Planner gas numbers are derived from the actual generated schedule.
- No gas consumption result can be NaN, infinite, or silently clipped into validity.
- Gas reserve warnings are typed and deterministic.

## Phase 2: Altitude And Salinity Pressure Model

### Objective

Make altitude and salinity mathematically meaningful instead of reference-only fields.

### Proposed Components

- `AmbientPressureModel`
- `WaterDensityModel`
- `PlannerEnvironment`

### Functional Requirements

- Compute surface pressure from altitude.
- Compute water-column pressure from salinity/water density.
- Replace fixed sea-level saltwater assumptions where applicable.
- Ensure the same pressure model feeds:
  - Buhlmann inspired inert gas pressure
  - PPO2
  - MOD
  - END/EAD
  - gas density
  - CNS/OTU exposure pressure
- Add bounds validation for altitude and salinity.
- If environment values are invalid, fail closed with a typed state.

### Tests

- Sea-level saltwater remains close to current baseline.
- Freshwater and saltwater produce documented pressure differences.
- Altitude changes surface pressure and affects NDL/ceiling behavior.
- Invalid altitude fails closed.
- Invalid salinity/water mode fails closed.

### Acceptance Criteria

- Altitude and salinity are either used consistently in pressure math or explicitly blocked as unavailable.
- No silent unused mathematical environment fields remain.

## Phase 3: Repetitive Dive Planning Workflow

### Objective

Expose the existing residual tissue state capability through a controlled iOS planner workflow.

### Proposed Components

- `TissueSnapshot`
- `SurfaceIntervalModel`
- `RepetitiveDivePlannerService`
- Codable persistence for final tissue snapshots

### Functional Requirements

- Save final tissue state from generated reference plans/log-derived plans.
- Model surface interval off-gassing using air breathing at current surface pressure.
- Allow a new plan to seed `BuhlmannPlanRequest.initialTissueState`.
- Clearly mark repetitive planning output as reference-only.
- Reject stale or corrupted tissue snapshots.
- Preserve existing planner UI style; only add minimal existing-style controls/state if needed.

### Tests

- Second dive after zero-minute surface interval is more conservative than a clean dive.
- Longer surface interval reduces tissue loading.
- Corrupt tissue snapshot is rejected.
- Surface interval uses altitude-aware pressure if Phase 2 is implemented.
- Repetitive planning cannot proceed from missing or invalid tissue state without warning.

### Acceptance Criteria

- Repetitive planning is deterministic and traceable.
- Residual tissue state is never silently assumed.
- Output remains non-certified and informational.

## Phase 4: CNS / OTU Formalization

**Status: ✅ Implemented @ `dae29b8` (2026-05-31)**

### Objective

Formalize oxygen exposure calculations as documented, segment-based reference estimates.

### Implemented Components

- `OxygenExposureModels.swift` — `NOAACNSLimitTable`, `NOAACNSDailyLimitTable`, `CNSRecoveryModel`, `OTUREPEXLimits`, `OTUModel`, `OxygenExposureModel`, `OxygenExposureCarryover`
- `OxygenExposureWarningState` — elevated single/daily CNS, dive/daily/weekly OTU
- `TissueSnapshot` schema v2 — optional `oxygenCarryover`
- `PlannerService` / `GasPlanningService` — full-profile exposure with repetitive carryover

### Functional Requirements (met)

- Accumulate CNS (single + daily) and OTU per generated segment with ramp integration on descent/ascent
- 90 min half-time CNS recovery during surface interval and in-water air breaks (PPO₂ ≤ 0.5 bar)
- REPEX reference thresholds: dive OTU ≥ 300, daily 24 h ≥ 850, weekly ≥ 1800
- Typed warnings for elevated exposure; fail-closed on invalid segments
- Documented in `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` and `DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` §11
- Reference-only positioning preserved in UI (`planner.oxygen_exposure.*`)

### Tests (`OxygenExposureDeepModelTests`, 14 cases)

- NOAA table sanity; surface-interval decay; daily vs single limit at 1.4 bar
- Air-break recovery; repetitive carryover; REPEX daily OTU warning
- Snapshot v2 carryover; schema v1 backward compatibility

### Acceptance Criteria

- ✅ Schedule-aware, deterministic, documented
- ✅ No NaN/infinite results on valid input; invalid input fails closed
- ✅ **119/119** `DIRDiving iOS Algorithm Tests` pass on iPhone 17 sim

## Phase 5: Golden Fixtures And Regression Suite

### Objective

Move from broad reference envelopes to fixture-backed regression validation.

### Proposed Files

- `Tests/iOSAlgorithmTests/Fixtures/*.json`
- `Tests/iOSAlgorithmTests/BuhlmannGoldenFixtureTests.swift`
- `Tests/iOSAlgorithmTests/PlannerRegressionFixtureTests.swift`
- `Docs/DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`

### Fixture Matrix

- Air 21% at 18 m, 30 m, 40 m.
- Nitrox 32 at 30 m.
- Trimix bottom gas.
- Trimix + EAN50.
- Trimix + EAN50 + O2.
- GF 30/70 vs GF 50/80.
- Altitude profile.
- Freshwater vs saltwater profile.
- Repetitive dive with surface interval.
- Lost deco gas.
- Invalid gas composition.
- MOD violation.
- Hypoxic gas used too shallow.
- Gas switch too deep.

### Validation Rules

- Each fixture must document:
  - model assumptions
  - gas set
  - gradient factors
  - ascent/descent rates
  - water/altitude assumptions
  - expected stops/TTS/NDL range
  - tolerance
  - source or rationale
- Do not claim exact decompression equivalence unless source assumptions and tolerances are fully documented.

### Tests

- Fixture parser rejects malformed fixture files.
- Valid fixtures run deterministically.
- Stops and TTS remain within documented tolerance.
- Invalid fixtures fail closed.
- No fixture path returns fake `999` NDL.
- No fixture path produces NaN or infinity.

### Acceptance Criteria

- Regression tests protect key gas/Buhlmann behavior.
- Fixture source documentation is committed.
- External comparisons are traceable and conservative.

## Documentation Updates

Update or create:

- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`
- `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`

Documentation must state:

- schedule-based gas consumption assumptions
- altitude/salinity pressure assumptions
- repetitive dive tissue-state assumptions
- CNS/OTU source assumptions
- fixture sources and tolerances
- remaining limitations
- non-certified, reference-only positioning

## Build And Test Commands

Run on macOS only:

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

On Windows:

- do not run Xcode tooling
- perform static Swift inspection
- run Git and repository consistency checks
- document that build/test validation must be completed on macOS

## Final Acceptance Criteria

The implementation is complete only when:

- iOS Algorithm Tests compile and pass on macOS.
- iOS app builds on macOS.
- Gas consumption is schedule-aware and per-cylinder.
- Altitude and salinity affect pressure math or fail closed.
- Repetitive planning uses validated tissue snapshots.
- CNS/OTU are segment-based and documented.
- Golden fixtures exist with source notes and tolerances.
- No Apple Watch files are modified.
- No experimental files are modified.
- UI/UX/graphics remain unchanged.
- DIR DIVING remains non-certified and informational.

## Recommended Commit Strategy

Use separate commits:

1. `feat(ios): add schedule-based gas consumption ledger`
2. `feat(ios): add altitude and salinity pressure model`
3. `feat(ios): add repetitive Buhlmann planning references`
4. `feat(ios): formalize oxygen exposure calculations`
5. `test(ios): add Buhlmann golden fixtures`
6. `docs(ios): update gas and Buhlmann planner validation docs`

