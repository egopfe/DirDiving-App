# Command 03 — Shared Bühlmann Core Extraction Report

**Branch:** `integration/full-computer`  
**Scope:** Extract iOS-only Bühlmann planner math into a shared source group compilable by iOS and watchOS with zero intentional math changes.

## Mathematical changes

**None intentional.** Refactoring only:

- `IOSAlgorithmConfiguration` planner bounds → `BuhlmannCoreConfiguration` (same numeric values).
- `IOSUnitConversions` ambient/depth helpers → direct `AmbientPressureModel` calls (same formulas as `IOSUnitConversions` already delegated).
- `GasMixValidator.modMeters` in `BuhlmannGas` → inline `AmbientPressureModel.depthMeters` (same MOD math).

## File mapping (old → new)

| Old path | New path | Notes |
|----------|----------|-------|
| `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift` | `Shared/BuhlmannCore/BuhlmannConstants.swift` | `decoGasSwitchPPO2ToleranceBar` uses `BuhlmannCoreConfiguration` |
| `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift` | `Shared/BuhlmannCore/BuhlmannGas.swift` | `GasMix` initializer moved to iOS extension |
| `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift` | `Shared/BuhlmannCore/BuhlmannTissueModel.swift` | Unchanged math |
| `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift` | `Shared/BuhlmannCore/BuhlmannEngine.swift` | Config symbol rename only |
| `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift` | `Shared/BuhlmannCore/BuhlmannTissueHistory.swift` | Ambient pressure via `AmbientPressureModel` |
| `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift` | `Shared/BuhlmannCore/BuhlmannPlanPreflightValidator.swift` | Unchanged math |
| `iOSApp/Services/PlannerEnvironment.swift` | `Shared/BuhlmannCore/PlannerEnvironment.swift` | Moved with `AmbientPressureModel` / `WaterDensityModel` |
| — | `Shared/BuhlmannCore/BuhlmannCoreConfiguration.swift` | **New** shared planner bounds |
| `GasPlan.swift` (`SalinityMode`, `GasRole`) | `Shared/Models/SalinityMode.swift`, `Shared/Models/GasRole.swift` | Enum definitions extracted; iOS extensions remain in `GasPlan.swift` |
| `DivePlan.swift` (`DiveSegmentKind`) | `Shared/Models/DiveSegmentKind.swift` | Enum extracted; `runtimeRowTitle` extension in `DivePlan.swift` |
| `PlannerResultState.swift` (`BuhlmannModelState`) | `Shared/Models/BuhlmannModelState.swift` | Enum extracted |
| — | `iOSApp/Algorithms/Buhlmann/BuhlmannGas+GasMix.swift` | **New** iOS-only `GasMix` bridge |

**Unchanged (iOS-only):** `iOSApp/Services/BuhlmannPlanner.swift` and all `Tests/iOSAlgorithmTests/Buhlmann*.swift` golden suites.

## Project membership (`project.yml`)

- `path: Shared` added to **DIRDiving Watch App**, **DIRDiving iOS**, **DIRDiving Watch Algorithm Tests**, **DIRDiving iOS Algorithm Tests**.
- Removed per-file Bühlmann entries from iOS test target (replaced by `Shared`).

## Tests

| Suite | Target | Purpose |
|-------|--------|---------|
| Existing `BuhlmannGoldenFixtureTests` + comprehensive suites | iOS Algorithm Tests | Golden / regression parity |
| `BuhlmannCoreCrossTargetEquivalenceTests` | Watch Algorithm Tests | watchOS compile + deterministic NDL, Schreiner, ceiling, invalid input |

## Out of scope (later commands)

- Watch Full Computer runtime integration (no Bühlmann dive loop on Watch yet).
- UI changes.
