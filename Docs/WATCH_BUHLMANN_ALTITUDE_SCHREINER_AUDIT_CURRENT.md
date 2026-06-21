# Watch Bühlmann Altitude + Schreiner Audit — Current

**Audit date:** 2026-06-21  
**Branch:** `main`  
**Audited commit:** `6cbba64948acfed1dccaf586adaeae58408d3fc9`  
**Initial working tree:** clean; identical to `origin/main` (`0/0` ahead/behind)  
**Audit type:** read-only static and evidence audit  
**Environment:** Windows 10; Xcode, XcodeGen, Apple simulators, physical Watch, and underwater validation unavailable

## A. Executive summary

The shared Bühlmann implementation is capable of altitude-aware calculation, but the live Apple Watch Full Computer product path is not altitude-safe end to end.

`PlannerEnvironment` validates −500…4,500 m, derives local surface pressure with a barometric formula, carries salinity/water density, and is consumed by tissue initialization, inspired pressure, Schreiner/Haldane loading, ceiling conversion, NDL, TTS, schedule construction, gas PPO2/MOD, and checkpoint restore. The iOS planner also places altitude and salinity in `DivePlanPackage`.

The safety-blocking break occurs when Watch activates that package. `FullComputerGasProfile(importing:)` copies gases and gradient factors but not `package.body.environment`; `FullComputerImportedPlanStore.activatePendingPlan` imports only that profile; `FullComputerPrediveConfigurationStore.runtimePlan()` constructs `FullComputerRuntimePlan(profile:)`, whose default environment is `.seaLevelSaltWater`. A live Watch dive planned at altitude is therefore silently initialized and calculated at sea level. The Watch predive surface has no independent altitude/surface-pressure input or explicit sea-level-only warning.

**Verdict:** FAIL. Two P0 manifestations share one environment-propagation root cause. No production code was changed.

## B. Branch, commit, and scope

Audited the Watch Full Computer data path from iOS planner package creation through Watch import, predive confirmation, runtime startup, tissue evolution, solver, checkpoint, logbook metadata, and visible claims. The current commit exactly matched `origin/main` before report generation.

Build/test execution was not possible on Windows. Existing macOS evidence proves sea-level/shared-core behavior but contains no complete Watch altitude profile suite.

## C. Altitude feature inventory

| Layer | Evidence | Result |
|---|---|---|
| iOS altitude input | `iOSApp/Views/PlannerView.swift` | Implemented |
| Canonical environment | `Shared/BuhlmannCore/PlannerEnvironment.swift` | Implemented |
| Signed plan payload | `iOSApp/Services/DivePlanPackageBuilder.swift`, `Shared/Models/DivePlanPackage.swift` | Altitude/salinity transported |
| Watch import | `FullComputerGasProfile.init(importing:)` | **Environment dropped** |
| Watch predive store | `Services/FullComputerPrediveConfigurationStore.swift` | Gas/GF only; no environment |
| Live runtime | `Services/FullComputerRuntimeEngine.swift` | Environment-aware if supplied |
| Deco solver | `Utils/FullComputerDecoSolver.swift` | Uses runtime plan environment |
| Checkpoint/restore | `Utils/FullComputerRuntimeCheckpoint.swift` | Preserves full plan environment |
| Logbook metadata | `Shared/Models/FullComputerDiveLogbookMetadata.swift` | Environment omitted |
| Independent altitude oracle | Watch tests | Missing; oracle reuses production pressure model |

## D. Canonical pressure model

Production uses:

```text
surfacePressureBar = 1.01325 × (1 − 2.25577e−5 × altitudeMeters)^5.25588
ambientPressureBar = surfacePressureBar + ρ × 9.80665 × depthMeters / 100000
inspired inert pressure = (ambientPressureBar − 0.0627) × inert fraction
```

Valid altitude is −500…4,500 m. Water density is 997 kg/m³ fresh and 1,025 kg/m³ salt. Invalid/non-finite altitude fails in `PlannerEnvironment.make`.

An independent ISA calculation produced 1.01325000, 0.95460835, 0.89874563, 0.84555994, 0.79495202, and 0.57728301 bar at 0, 500, 1,000, 1,500, 2,000, and 4,500 m respectively. This verifies the scalar formula only, not the missing Watch propagation.

## E. Altitude data flow

```text
iOS manual altitude/salinity
→ PlannerEnvironment
→ DivePlanEnvironmentPayload
→ signed/checksummed DivePlanPackage
→ Watch FullComputerImportedPlanStore
→ FullComputerGasProfile(importing:)       ← environment discarded
→ FullComputerPrediveConfigurationStore
→ FullComputerRuntimePlan(profile:)         ← defaults to sea-level salt water
→ live tissues / ceiling / NDL / TTS / schedule
```

The payload’s optional `surfacePressureBar` is not populated by `DivePlanPackageBuilder`; recalculation from altitude would be sufficient, but no Watch activation code performs it.

## F. Tissue initialization and pressure propagation

The mathematical primitives are correct when explicitly given a `PlannerEnvironment`:

- `BuhlmannTissueState.airSaturated(surfacePressureBar:)` subtracts water-vapour pressure and seeds N2; He starts at zero for air equilibrium.
- all N2/He loading calls accept the environment;
- the runtime engine initializes from `plan.plannerEnvironment.surfacePressureBar`;
- ambient pressure, gas PPO2, ceiling, NDL, TTS, schedule, and surfacing criterion use that same environment;
- the checkpoint serializes the entire runtime plan and therefore preserves an already-correct environment.

These facts do not close the product defect: the Watch’s normal plan construction never supplies the imported altitude environment.

## G. Schreiner, Haldane, and all compartments

Shared code updates all 16 N2 and all 16 He compartments and is parameterized by `PlannerEnvironment`. Existing Audit 15 evidence covers actual elapsed time, multilevel transitions, gas switching, schedule rebuilding, re-descent, and fail-closed degraded states at sea level. No evidence executes the mandatory altitude matrix through the real Watch activation path.

End-to-end altitude verdicts are therefore FAIL even though the lower-level functions are environment-capable.

## H. GF ceiling, NDL, TTS, schedule, and surfacing

The solver converts tolerated ambient pressure back to depth with local `environment.surfacePressureBar` and water density. NDL projections, TTS, decompression stops, active-gas PPO2, and surfacing all receive the plan environment. With the actual Watch plan, however, that environment is silently sea level. This can create optimistic or otherwise incorrect altitude decompression output and satisfies the command’s P0 definition.

## I. Product policy, persistence, restore, and exports

- iOS altitude source: manual planner input.
- Watch altitude source: none after activation; implicit sea-level default.
- Active-dive snapshot: the runtime plan is frozen and checkpointed.
- Restore: preserves whatever environment was in the plan; it cannot recover the discarded imported environment.
- Logbook: Full Computer metadata records GF, stops, violations, gases, recovery, and algorithm version but not altitude, surface pressure, salinity, density, source, or fallback confidence.
- UI/documentation: iOS explains environment-aware planning; Watch predive does not disclose that live runtime discards imported altitude.

## J. Test coverage and execution

Existing iOS tests cover pressure-model scalar behavior at 1,500/3,000 m and invalid altitude. Existing Watch Audit 15 tests are predominantly sea-level. `IndependentBuhlmannOracle` accepts an environment but calls production `AmbientPressureModel`, so it is not an independent oracle for the altitude-pressure formula.

The required builds, iOS/Watch test schemes, and deterministic altitude profiles were not runnable in the Windows environment. No physical altitude dive or external Bühlmann altitude validation evidence exists.

## K. Findings

### ALT-P0-001 — Imported altitude environment is dropped

- **Evidence:** `DivePlanPackageBuilder` writes altitude/salinity; `FullComputerGasProfile(importing:)` omits them; activation imports only the profile.
- **Impact:** a Watch dive can present live decompression computed with an environment different from the accepted iOS plan.
- **Required remediation:** resolve and validate `PlannerEnvironment` during Watch import, persist it with the confirmed predive configuration, and make activation fail closed on invalid/missing environment.
- **Acceptance:** a 0–4,500 m signed package produces an identical frozen environment in runtime, checkpoint, restore, logbook, and UI; missing/corrupt/future environment cannot start Full Computer.

### ALT-P0-002 — Watch runtime silently defaults to sea level

- **Evidence:** `runtimePlan()` calls `FullComputerRuntimePlan(profile:)`; its default parameter is `.seaLevelSaltWater`; Watch has no altitude control or explicit sea-level-only warning.
- **Impact:** false altitude support and potentially unsafe ceiling/NDL/TTS/schedule.
- **Required remediation:** remove implicit safety-path defaulting; require a validated environment snapshot for live Full Computer.
- **Acceptance:** no production live-start path can construct a Full Computer runtime plan without an explicit validated environment.

### ALT-P1-001 — No independent Watch altitude profile suite

- **Evidence:** no Watch altitude test files; existing independent oracle delegates ambient/depth conversion to production code.
- **Acceptance:** independent pressure formula plus all 16 N2/He profiles at 0/500/1,000/1,500/2,000/4,500 m, invalid values, Air/Nitrox/Trimix, fresh/salt, restore, gas switch, clear, and re-descent.

### ALT-P1-002 — Completed dive metadata loses environment

- **Evidence:** `FullComputerDiveLogbookMetadata` and its accumulator export no altitude/surface-pressure/salinity fields.
- **Acceptance:** logbook, sync, CSV/PDF, and restore evidence preserve and disclose the frozen environment with schema migration tests.

### ALT-P1-003 — Watch UI/documentation does not disclose live limitation

- **Evidence:** imported plan visibly contains environment data, but Watch predive confirmation exposes no environment/fallback truthfulness state.
- **Acceptance:** until end-to-end support is fixed, altitude plans are rejected or explicitly blocked as unsupported; after remediation, source and frozen values are visible.

## L. Readiness matrix

| Area | Readiness | Evidence |
|---|---:|---|
| Canonical pressure formula | 85% | Static source + independent scalar calculation; no external validation |
| iOS planner propagation | 90% | Input, validation, engine, payload |
| Watch package activation | 0% | Environment discarded |
| Tissue initialization | 20% | Correct function, unreachable altitude input |
| Schreiner/Haldane | 25% | Parameterized core; no product-path altitude suite |
| 16 N2/He compartments | 25% | Core capability only |
| GF ceiling / NDL / TTS / schedule | 20% | Correct parameter path with wrong live input |
| Persistence / restore | 45% | Checkpoint preserves plan; initial environment wrong |
| Logbook / export | 10% | Environment absent |
| Cross-target parity | 10% | iOS altitude vs Watch sea-level mismatch |
| Independent oracle | 10% | Pressure conversion not independent |
| Physical/external evidence | 0% | Pending |
| **Overall software readiness** | **28%** | P0 end-to-end break |

## M. Final verdict

```text
WATCH_BUHLMANN_ALTITUDE_AUDIT: FAIL
ALTITUDE_SUPPORTED: PARTIAL
ALTITUDE_SOURCE: MIXED
SURFACE_PRESSURE_ALTITUDE_AWARE: FAIL
TISSUE_INITIALIZATION_ALTITUDE_AWARE: FAIL
SCHREINER_ALTITUDE_AWARE: FAIL
HALDANE_ALTITUDE_AWARE: FAIL
ALL_16_N2_COMPARTMENTS_ALTITUDE_AWARE: FAIL
ALL_16_HE_COMPARTMENTS_ALTITUDE_AWARE: FAIL
AMBIENT_PRESSURE_ALTITUDE_AWARE: FAIL
INSPIRED_GAS_PRESSURE_ALTITUDE_AWARE: FAIL
GF_CEILING_ALTITUDE_AWARE: FAIL
NDL_ALTITUDE_AWARE: FAIL
TTS_ALTITUDE_AWARE: FAIL
DECO_SCHEDULE_ALTITUDE_AWARE: FAIL
SURFACING_CRITERION_ALTITUDE_AWARE: FAIL
MULTILEVEL_ALTITUDE_PROFILE: FAIL
AIR39_TO_10M_ALTITUDE_PROFILE: FAIL
TRIMIX_ALTITUDE_PROFILE: FAIL
INDEPENDENT_ORACLE_PARITY: FAIL
PERSISTENCE_ALTITUDE_AWARE: FAIL
RESTORE_ALTITUDE_AWARE: FAIL
CROSS_TARGET_PARITY: FAIL
DOCUMENTATION_TRUTHFULNESS: FAIL
P0_FINDINGS: 2
P1_FINDINGS: 3
P2_FINDINGS: 0
P3_FINDINGS: 0
ALTITUDE_BUHLMANN_SOFTWARE_READINESS: 28%
PHYSICAL_ALTITUDE_DIVE_QA: PENDING
EXTERNAL_BUHLMANN_ALTITUDE_VALIDATION: PENDING
```

