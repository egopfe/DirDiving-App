# Command 05 — NDL / TTS / Ceiling / Deco Solver Report

**Branch:** `integration/full-computer`

## Solver (`FullComputerDecoSolver`)

UI-independent presentation solver operating on tissue copies via `BuhlmannEngine.runtimeProjection` without mutating live runtime state.

### NDL

- Shown only in `.noDecompression` mode when `requiresDecompression` is false.
- Accent thresholds: `>10` green, `≤10` yellow, `≤5` red.
- Atomic transition: when deco is required, `ndlDisplayMinutes` is `nil` (never stale `NDL 0`).

### Ceiling

- `ceilingMetersExact` — continuous operational GF-adjusted value (unrounded).
- `ceilingMetersRounded` — presentation rounding to 0.1 m via `presentationCeilingMeters(_:)`.
- Distinct from `nextStopDepthMeters` (discrete Bühlmann stop).

### TTS

- Simulated on tissue copy through shared `runtimeProjection` (ascent, transfers, stop times, surface).
- Live tissue state in `FullComputerRuntimeEngine` is unchanged by solver work.

### Performance

- Cache keyed by tissue state, depth, gas, GF, runtime, switch gases.
- Budget default 50 ms; conservative fallback bumps TTS and marks `usedConservativeFallback`.

## UI (mockup-aligned)

- `FullComputerTopMetricsPanel` — NDL|Runtime (no-deco) or TTS|Ceiling|Runtime (deco).
- `FullComputerDecoStopPanel` — next stop depth/time, remaining stops, ascent permission.
- `FullComputerCeilingViolationBanner` — critical shallow-ascent warning.
- `DiveLiveView` switches panels when `sessionDivingMode == .fullComputer`; Gauge layout unchanged.

## Tests

`FullComputerDecoSolverTests` — thresholds, atomic NDL→deco transition, ceiling rounding, cache, planner TTS parity, deco stop panel, ceiling violation.
