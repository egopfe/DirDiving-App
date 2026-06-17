# Command 04 — Watch Full Computer Runtime Engine Report

**Branch:** `integration/full-computer`  
**Scope:** Continuous Bühlmann decompressive runtime on watchOS, UI-independent, Gauge mode unchanged.

## Architecture

| Component | Path | Role |
|-----------|------|------|
| `BuhlmannRuntimeProjection` | `Shared/BuhlmannCore/` | Shared NDL/ceiling/TTS projection from arbitrary tissue state |
| `FullComputerRuntimePlan` | `Utils/` | Gas, GF, environment, ascent/stop configuration |
| `FullComputerRuntimeEngine` | `Services/` | Tissue integration, tick/sample ingest, gas switch |
| `DiveManager` hooks | `Services/DiveManager.swift` | Lifecycle owner; delegates FC math when `sessionDivingMode == .fullComputer` |

## Runtime state (`FullComputerRuntimeSnapshot`)

- 16-compartment N2/He tissue state (never reset mid-session)
- Active gas, GF Low/High, monotonic elapsed time
- Depth, ambient pressure bar
- NDL, raw ceiling, operational ceiling, controlling compartments
- TTS, deco stops, `BuhlmannModelState`, diagnostics
- Engine state: `valid` | `degraded` | `unavailable` | `recovered`

## Tick / profile policy

- Nominal 1 s tick via `DiveManager` runtime timer; always uses real `delta`
- Sub-steps capped at 30 s (`FullComputerRuntimeConfiguration.maxSubStepSeconds`)
- Multi-level Schreiner integration between depth samples (no preset levels)
- Missed ticks: constant-depth load, capped at 120 s, marks `degraded`
- Gas switch: immediate Bühlmann switch load + projection refresh

## Safety / startup

- Rejects non-finite depth and non-monotonic timestamps (tissues preserved)
- `FullComputerRuntimeEngine.canStart()` validates plan + `DiveAlgorithmSelfCheck`
- Engine does not start when plan/self-check fails (`unavailable` snapshot)
- Gauge dives unaffected (`sessionDivingMode == .gauge` skips engine)

## Draft recovery (schema v3)

`ActiveDiveDraft` stores `watchActivityMode` / `watchDivingMode`; on restore, FC engine replays sanitized samples.

## Tests

`Tests/WatchAlgorithmTests/FullComputerRuntimeEngineTests.swift` — tick, irregular delta, multi-level, descent/ascent, missed ticks, gas switch, replay recovery, planner parity, non-monotonic rejection, performance measure.

## Out of scope

- Full Computer live UI (NDL/ceiling/TTS presentation) — later commands
- Deco gas switching from planner sync — default air GF 30/70 only for now
