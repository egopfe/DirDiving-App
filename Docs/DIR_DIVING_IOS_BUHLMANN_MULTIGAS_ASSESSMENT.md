# DIR Diving iOS Companion Buhlmann Multigas Assessment

## Executive Verdict

**Partial.** The iOS Companion MAIN branch has a hardened **reference planner shell** with gas validation, MOD/PPO2, END/EAD, density, CNS/OTU estimates, static stop templates, and a simplified N2-only Buhlmann-style NDL preview.

It does **not** contain a complete release-hard Buhlmann ZHL-16C multigas engine with Helium tissue loading, Trimix decompression, real Gradient Factor ceiling logic, or generated decompression schedules.

Verdict:

- Complete: no
- Partial: yes
- Placeholder only: no, because some real gas/reference math exists
- Not implemented: complete Buhlmann ZHL-16C + He + multigas decompression engine is not implemented

## Scope Confirmed

This audit is limited to:

- iOS Companion app only
- MAIN branch only
- No Apple Watch code
- No watchOS targets
- No experimental branches or experimental-only files
- No UI/UX/design changes
- No code changes during the audit

Repository state at audit time:

- Branch: `main`
- HEAD: `c61c507`
- Local `main` aligned with `origin/main`

The iOS target is `DIRDiving iOS` in `project.yml`. The project also contains Watch targets and experimental iOS files, but they are outside the scope of this assessment.

## Evidence Found

### iOS Target And Test Target

- `project.yml`
  - `DIRDiving iOS`
  - `DIRDiving iOS Algorithm Tests`
  - iOS experimental files excluded from the main iOS target:
    - `Models/ExplorationModels.swift`
    - `Models/BuddyExperimentalModels.swift`
    - `Services/ExplorationPlanningStore.swift`
    - `Services/BuddyExperimentalStore.swift`
    - `Views/ExplorationCenterView.swift`
    - `Views/ExperimentalFutureConceptsView.swift`
    - `Views/BuddyExperimentalView.swift`

### Planner And Gas Models

- `iOSApp/Models/GasPlan.swift`
  - `PlannerMode`
  - `SalinityMode`
  - `GasRole`
  - `PlanningDepthReference`
  - `GasMixKind`
  - `PlannerCylinderEntry`
  - `GasMix`
  - `Cylinder`
  - `TechnicalGasAnalysis`
  - `GasPlanInput`

- `iOSApp/Models/DivePlan.swift`
  - `DecoStop`
  - `DivePlanSegment`
  - `GFComparison`
  - `DivePlanResult`
  - `NDLPoint`
  - `BuhlmannPlanResult`

### Current Buhlmann-Related Code

- `iOSApp/Services/BuhlmannPlanner.swift`
  - Contains 16 N2 half-times.
  - Contains 16 N2 `a` coefficients.
  - Contains 16 N2 `b` coefficients.
  - Implements a simplified N2-only NDL-style calculation.
  - Explicitly rejects helium/trimix by returning `unsupportedTrimix`.

Important evidence:

- `halfTimesN2`
- `aN2`
- `bN2`
- `nitrogenFraction(oxygen:helium:)`
- `plan(depthMeters:o2Fraction:heliumFraction:)`
- `ndl(depthMeters:nitrogenFraction:)`

The file comment explicitly states that helium is not loaded into compartments.

### Planner Orchestration

- `iOSApp/Services/PlannerService.swift`
  - Calls `PlannerInputValidator`.
  - Calls `BuhlmannPlanner.plan`.
  - Calls `GasPlanningService.analyze`.
  - Calls `PlannerGasSchedule.buildDecoStops`.
  - Produces `DivePlanResult`.
  - Adds typed states such as `unsupportedTrimix`, `modelIncomplete`, `simplifiedReferenceOnly`.

### Gas Planning

- `iOSApp/Services/GasPlanningService.swift`
  - Computes PPO2.
  - Computes gas density.
  - Computes END.
  - Computes EAD for nitrox.
  - Computes gas consumption.
  - Computes rock-bottom style gas reserve estimate.
  - Computes CNS and OTU estimates.
  - Produces warnings and typed planner states.

### Static Stop Scheduling

- `iOSApp/Services/PlannerGasSchedule.swift`
  - Builds role-aware travel/deco/bailout gas switch points.
  - Builds static stop templates.
  - Applies MOD caps.
  - Does not implement Buhlmann ceiling-based decompression stops.

### Validators And Shared Algorithm Utilities

- `iOSApp/Utils/PlannerResultState.swift`
  - `PlannerResultState`
  - `BuhlmannModelState`
  - `PlannerValidationResult`

- `iOSApp/Utils/PlannerInputValidator.swift`
  - Validates planner depth, time, SAC/RMV, cylinders, pressures, temperature, GF, gas mixes, altitude/density bounds.

- `iOSApp/Utils/GasMixValidator.swift`
  - Validates O2/He fractions.
  - Computes nitrogen fraction only for valid gas.
  - Computes actual PPO2.
  - Computes MOD.

- `iOSApp/Utils/IOSUnitConversions.swift`
  - Centralizes metric/imperial conversions and ambient pressure approximation.

### Tests Found

- `Tests/iOSAlgorithmTests/IOSAlgorithmTests.swift`
  - Air and nitrox planner reference outputs.
  - Invalid gas mix rejection.
  - Invalid planner input rejection.
  - Trimix does not use N2-only Buhlmann output.
  - Buhlmann no longer returns `999` as valid NDL.
  - PPO2, MOD, and gas density states.
  - Unit conversion round trips.
  - Import/export/sync/logbook/route data integrity.

These tests are useful for the current hardened reference planner, but they are not a complete decompression-engine test suite.

## Helium & Trimix Support Status

### Exists

- `GasMix` includes an explicit `helium` fraction.
- `GasMixKind` includes `trimix`.
- `GasMix.label` can display `TX O2/He`.
- `GasMixValidator` rejects impossible O2/He totals.
- Gas density accounts for helium through surface density.
- END calculation accounts for gas composition and oxygen narcotic assumption.
- Planner identifies trimix and marks it as unsupported/model-incomplete for Buhlmann.

### Missing

- Helium tissue half-times.
- Helium Buhlmann `a` coefficients.
- Helium Buhlmann `b` coefficients.
- Inspired helium pressure calculation.
- Helium tissue loading.
- Helium off-gassing.
- Mixed N2 + He compartment state.
- Weighted Buhlmann coefficients for mixed inert gas loading.
- Trimix decompression ceiling calculation.
- Trimix NDL calculation.
- Trimix decompression stop generation.
- Heliox support.
- Full multigas tissue-state transitions when switching gas.

### Current Safety Behavior

The current code intentionally blocks Trimix from receiving N2-only Buhlmann output. That is correct and conservative. It means the planner is safer than a misleading partial implementation, but it also means the requested complete Helium-capable engine is not yet implemented.

## Missing Components

Against a complete Buhlmann ZHL-16C + GF multigas planning reference engine, the following are missing.

### Core Model

- ZHL-16C He compartment constants.
- He half-times.
- He `a` and `b` coefficients.
- Tissue compartment state object.
- Initial tissue loading model.
- Per-compartment N2 and He inert gas pressures.
- Mixed inert gas coefficient calculation.

### Pressure Model

- Inspired N2 and He pressure abstraction.
- Segment-level ambient pressure calculation.
- Water vapour pressure model integrated across all inert gases.
- Altitude pressure model.
- Fresh/salt water pressure density policy if required.

### Tissue Loading

- Schreiner equation or equivalent for ascent/descent.
- Constant-depth loading equation.
- Separate N2 and He kinetics.
- Segment-based loading pipeline.
- On-gassing and off-gassing for both gases.
- Gas switch state transitions.

### Decompression

- Ceiling calculation.
- GF Low / GF High application.
- GF interpolation by ceiling/depth.
- First-stop determination.
- Stop depth rounding policy.
- Stop propagation.
- Final ascent logic.
- NDL search using tissue state.
- Runtime/TTS/TTR from the decompression engine.

### Multigas

- Multiple bottom gases.
- Travel gas support in tissue loading.
- Deco gas support in tissue loading.
- Gas switch scheduling coupled to MOD and min operating depth.
- Oxygen-rich decompression gas handling.
- Hypoxic trimix minimum operating depth validation.
- Heliox behavior if desired.

### Safety And Technical Validation

- Known reference fixtures from a trusted implementation.
- Numerical tolerances.
- Round-trip validation for segment planner.
- Regression fixtures for air, nitrox, trimix, and multigas profiles.
- Explicit distinction between generated decompression schedule and existing static reference stops.

## Risk Matrix

| Priority | Risk | Area | Notes |
|---|---|---|---|
| P0 | No helium tissue loading | Trimix/Buhlmann | Blocks release-hard trimix planning. |
| P0 | No real multigas decompression schedule | Decompression | Current stops are static templates, not calculated ceilings. |
| P0 | GF values do not drive ceiling/stop math | Gradient Factors | GF exists as input/comparison but not as full decompression logic. |
| P1 | TTR/TTS is heuristic | Runtime schedule | Not generated from compartment ceilings. |
| P1 | No ascent/descent tissue segment engine | Core model | Required for realistic planning. |
| P1 | No reference fixture suite | Tests | Cannot claim release-hard math without validation vectors. |
| P2 | CNS/OTU are simplified estimates | Oxygen exposure | Useful reference, not full exposure model. |
| P2 | Salinity/altitude stored but not applied | Pressure model | Must be implemented or explicitly kept unsupported. |
| P2 | Static stops may appear operational | UX/legal | Existing disclaimers help, but complete engine work must preserve non-certified framing. |
| P3 | Engine not isolated as a domain module | Architecture | Current planner mixes reference outputs and service orchestration. |
| P4 | Documentation needs future validation chapter | Docs | Required before TestFlight/App Store claim upgrades. |

## iOS-Only Implementation Plan

This is an implementation-ready plan for a future task. It must not be executed as part of this audit.

### Phase 1 - Create An Isolated iOS Buhlmann Module

Likely files to create:

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissue.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannState.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannSegment.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPressureModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlannerEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanResult.swift`

The module should be pure Swift, deterministic, UI-free, and iOS-target-only.

### Phase 2 - Implement Constants And Gas Model

Add:

- ZHL-16C N2 half-times, a, b.
- ZHL-16C He half-times, a, b.
- Water vapour pressure constant/policy.
- Surface pressure policy.
- Ambient pressure conversion.
- Inspired inert gas pressure for N2 and He.
- Gas validation for air, nitrox, trimix, heliox.

### Phase 3 - Implement Tissue Loading

Add:

- Constant-depth loading.
- Schreiner ascent/descent loading.
- Per-segment loading API:
  - start depth
  - end depth
  - duration
  - gas
  - rate
- Initial tissue state policy.
- Repetitive dive hooks if desired later.

### Phase 4 - Implement Ceiling And GF Logic

Add:

- Ceiling calculation per compartment.
- Mixed N2/He coefficient weighting.
- GF Low / GF High interpolation.
- First-stop selection.
- Stop depth rounding.
- Ceiling clearance checks.

### Phase 5 - Implement Multigas Planner

Add:

- Descent segments.
- Bottom segment.
- Travel gas switches.
- Deco gas switches.
- MOD validation.
- Minimum hypoxic operating depth validation.
- Ascent rates.
- Stop schedule generation.
- TTS/TTR calculation.
- NDL search using binary search or bounded stepping.

### Phase 6 - Integrate Into Existing iOS Planner

Likely files to modify:

- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `project.yml`

Keep UI unchanged initially. Existing `PlannerView` should consume the same high-level result model, with additional fields if necessary.

### Phase 7 - Testing

Likely test files to create:

- `Tests/iOSAlgorithmTests/BuhlmannConstantsTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannGasValidationTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannTissueLoadingTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannCeilingTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannNDLTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannMultigasPlannerTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannReferenceFixtureTests.swift`

Minimum fixture set:

- Air 21% at 30 m.
- Nitrox 32 at 30 m.
- Air no-deco profile.
- Nitrox no-deco profile.
- Trimix bottom gas with EAN50 and oxygen deco.
- Hypoxic trimix minimum operating depth.
- Heliox unsupported or implemented explicitly.
- MOD exceeded.
- GF 30/70 vs 50/80.
- Gas switch too deep.
- Invalid O2 + He > 100%.

### Phase 8 - Documentation

Create/update:

- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`

The app must continue to say:

- not a certified dive computer
- not real-time decompression control
- not a substitute for training, certified tables, certified computers, or instructor guidance
- Buhlmann-based planning reference only

### Build/Test Commands

Run on macOS with Xcode/XcodeGen:

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

### Rollback Strategy

- Keep the new engine isolated behind a planner strategy enum or feature flag.
- Preserve current safe `unsupportedTrimix` fallback until fixture tests pass.
- Do not replace `BuhlmannPlanner` output in production UI until the new engine passes all reference fixtures.
- Revert only iOS algorithm files if validation fails.
- Do not touch Watch targets during rollback.

## Files to Protect

The following must not be modified for this iOS-only engine task:

- `App/*` at repository root
- `Models/*` at repository root
- `Services/*` at repository root
- `Views/*` at repository root
- `Utils/*` at repository root
- `Resources/*` at repository root
- `Config/DIRDiving.entitlements`
- Watch target settings in `project.yml`
- `DIRDiving Watch App`
- `DIRDiving Watch Algorithm Tests`
- WatchConnectivity runtime behavior unless a separate sync task explicitly authorizes it

Experimental iOS files also remain protected unless the task explicitly targets experimental branches:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

## Acceptance Criteria

The iOS Companion planner can be considered release-hard as a Buhlmann-based multigas planning reference only when:

- ZHL-16C N2 and He constants are implemented.
- Tissue loading supports N2 and He independently.
- Descent, bottom, ascent, and stop segments update tissue state.
- GF Low/High control ceilings and stop schedule.
- NDL is derived from tissue state, not a simplified shortcut.
- Trimix no longer returns `unsupportedTrimix`.
- Multigas switches alter tissue loading.
- Static stop templates are removed or clearly separated from engine-generated stops.
- Known external fixture outputs match within documented tolerances.
- Invalid gas/depth/GF inputs fail closed.
- Hypoxic gas minimum operating depth is validated.
- MOD/PPO2 constraints are enforced.
- Tests cover air, nitrox, trimix, multigas deco, helium tissue handling, invalid inputs, and numerical tolerances.
- UI and exports continue to state that DIR DIVING is non-certified and reference-only.

## Recommended Next Cursor/Codex Command

**NOT TO RUN DURING THIS AUDIT:**

```text
Implement the iOS-only Buhlmann ZHL-16C multigas reference engine described in Docs/DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md.

Scope:
- iOS Companion MAIN only.
- Do not touch Apple Watch files or targets.
- Do not touch experimental files or branches.
- Preserve current UI/UX/graphics/navigation.
- Keep all planner outputs non-certified/reference-only.

Implementation:
- Create isolated pure Swift modules under iOSApp/Algorithms/Buhlmann.
- Add N2 and He ZHL-16C constants.
- Implement inspired inert gas pressure, N2/He tissue loading, Schreiner ascent/descent loading, mixed-gas ceiling calculation, GF Low/High interpolation, NDL search, first-stop selection, staged decompression, and multigas gas switching.
- Integrate into PlannerService only after tests pass.
- Preserve the current unsupportedTrimix fallback until the full engine is validated.

Testing:
- Add deterministic iOS XCTest fixtures for air, nitrox, trimix, heliox if supported, multigas deco, GF variants, MOD/min operating depth, invalid inputs, and known reference outputs with tolerances.

Acceptance:
- iOS MAIN builds.
- iOS algorithm tests pass.
- No Watch or experimental files modified.
- Documentation updated with validation limits and non-certified positioning.
```
