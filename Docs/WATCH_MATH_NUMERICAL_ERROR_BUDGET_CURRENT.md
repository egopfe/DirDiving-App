# Watch Mathematical Functions — Numerical Error Budget — CURRENT

**Updated:** 2026-06-19  
**Branch:** `main` (remediation working tree @ `79e242e` base + uncommitted)  
**Authority:** `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracleTolerances.swift`

## Tolerance rationale

| Quantity | Tolerance | Rationale |
|---|---:|---|
| Compartment N2/He pressure (bar) | ±0.0002 | Independent oracle uses same ZH-L16C constants and production-equivalent 30 s sub-stepping; 1 s oracle steps are finer |
| Raw / operational ceiling (m) | ±0.2 | Production rounds display ceilings; GF interpolation at stop boundaries |
| NDL (min) | ±0.6 | Binary search floor to 0.1 min; ascent segment discretization |
| TTS (min) | ±3.0 | Schedule simulation step and stop rounding |
| Schreiner analytic vs 1 s steps (bar) | ±0.0005 | Documented discretization over linear depth segments |
| Controlling compartment slack (m) | ±0.05 | Tie-breaking when two compartments within numerical noise |

## Schreiner analytic parity

Representative compartments **1, 4, 8, 12, 16** (indices 0, 3, 7, 11, 15) compared for segments:

- 0 → 39 m (130 s)
- 39 → 10 m (194 s)
- 10 → 3 m (42 s)
- 3 → 0 m (20 s)

Analytic Schreiner over full segment must match repeated 1 s Schreiner steps within **±0.0005 bar**.

## Independent oracle assumptions

- Environment: `PlannerEnvironment.seaLevelSaltWater`
- Gas: Air (O2 0.21, N2 0.79, He 0)
- GF default: 30/70 (Audit-15 also validates project default via `.defaultAirGF3070`)
- Water vapour: 0.0627 bar
- Schreiner for linear segments; Haldane when inspired rate ≈ 0
- Does **not** call `BuhlmannTissueModel`, `BuhlmannTissueState.ceiling`, or `BuhlmannEngine` schedule generation

## Cross-target parity

Watch production vs independent oracle vs bridged `BuhlmannTissueState.ceiling` on oracle tissues: ceiling within ±0.2 m after identical 30 m constant-load profile with documented descent preamble.
