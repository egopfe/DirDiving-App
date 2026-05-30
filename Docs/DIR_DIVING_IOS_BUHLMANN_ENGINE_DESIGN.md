# DIR DIVING iOS Buhlmann Engine Design

Date: 2026-05-29 (reaudit hardening pass)  
Scope: iOS Companion MAIN only

## Purpose

DIR DIVING iOS includes an isolated pure Swift Buhlmann ZHL-16C multigas planning reference engine under `iOSApp/Algorithms/Buhlmann/`. The engine supports nitrogen and helium compartment loading for air, nitrox, trimix, heliox, travel gas, bottom gas, and decompression gas planning.

The engine is informational and non-certified. It must never be presented as a life-support system, a real-time decompression controller, or a substitute for certified dive computers, tables, training, or team procedures.

## Files

- `BuhlmannConstants.swift`: ZHL-16C N2/He constants, water vapor pressure, stop interval, ascent/descent assumptions.
- `BuhlmannGas.swift`: validated gas model, PPO2, MOD, minimum operating depth, gas labels, plan issues.
- `BuhlmannTissueModel.swift`: tissue compartments, Schreiner loading, mixed coefficient ceiling calculation.
- `BuhlmannEngine.swift`: request/result model, validation, NDL search, GF interpolation, multigas stop schedule, runtime/TTS accounting, residual tissue seed.
- `BuhlmannPlanner.swift`: iOS planner adapter from `GasPlanInput` to the pure engine.

## Mathematical Model

- Surface pressure: environment-derived from altitude (`PlannerEnvironment` / `AmbientPressureModel`).
- Depth conversion: water-column pressure derived from water density (fresh vs salt) with legacy fallback where environment is unavailable.
- Inspired inert gas pressure: `(ambient pressure - water vapor pressure) * inert fraction`.
- Tissue loading: exponential Haldane loading at constant depth and Schreiner-style loading for linear ascent/descent.
- Ceiling: per-compartment mixed N2/He a/b coefficients weighted by current inert gas tissue pressures; tolerated ambient pressure is converted back to depth with `AmbientPressureModel.depthMeters` using the same `PlannerEnvironment` as tissue loading (no sea-level-only fallback in ceiling paths).
- Gradient factors: GF Low at first stop, GF High at the surface, interpolated by depth.
- NDL: tissue-state search uses `PlannerEnvironment` for descent, bottom, ascent, and ceiling checks; no silent sea-level saltwater fallback in engine NDL paths.
- Stops: rounded to the configured 3 m interval and propagated until the next shallower stop is allowed.
- Optional multiple bottom segments: each segment carries its own depth, duration, and gas.
- Gas-switch dwell: `0.5 min` at switch depth, included in tissue loading and runtime accounting.
- Runtime semantics: `ttsMinutes` is time-to-surface from the end of bottom loading; `totalRuntimeMinutes` includes descent, bottom, gas switches, ascent and stops.
- Initial tissue state: air-saturated by default; `BuhlmannPlanRequest.initialTissueState` can seed repetitive/reference planning.
- Repetitive planning reference: optional `TissueSnapshot` + `SurfaceIntervalModel` off-gassing seed for subsequent plans.

## Gas Strategy

- Bottom gas is used for descent and bottom loading unless travel gases are provided.
- Multiple bottom segments can be passed to the pure engine for staged bottom gas/time/depth loading.
- Travel gases are used during descent at configured switch depths.
- Travel and deco gases are selected on ascent when the current segment/stop depth is at or shallower than their switch depth and PPO2 is within bounds, including no-stop returns and decompression ascents between stops (travel switch depths are honored as ascent waypoints).
- Higher oxygen deco gases are preferred when validated at the current stop depth.

## PlannerService Canonical Result

`PlannerService.makePlan` runs one `BuhlmannEngine.plan` per request. Stops, runtime segments, TTS, NDL, GF comparisons, and gas-consumption inputs are derived from that single engine result. Repetitive planning seeds `initialTissueState` before the canonical run; helper paths must not recompute deco metrics from a clean-dive assumption.

## Gas Identity And Ledger

- `BuhlmannGas` carries stable `gasMixId` and optional `cylinderId`; `allocationKey` is used internally for consumption ledgers.
- Display labels are not used as algorithmic identity.
- `ScheduleGasConsumptionService` allocates consumption per cylinder UUID, allowing duplicate display labels.
- `GasPlanningService.analyze(input:enginePlan:)` exposes per-cylinder ledger entries and uses bottom-gas remaining pressure in summaries.

## Planner UX Presentation (2026-05-29)

UI surfaces engine outputs without changing math:

- **Repetitive planning:** toggle, surface-interval minutes, snapshot timestamp/source, applied vs rejected states, and typed snapshot failures (missing/stale/corrupt/schema/environment mismatch).
- **Schedule gas ledger:** per-cylinder consumed liters, remaining liters/bar, reserve/minimum-gas/lost-gas flags; allocation failures fail visibly instead of showing aggregate-only bottom estimates.
- **Environment:** active altitude/salinity copy states they adjust ambient pressure, ceiling, NDL, consumption, and surface-interval math; invalid environment blocks planning with corrective hints.
- **Result header:** explicit reference-only badge for no-deco, deco-required, repetitive, environment-adjusted, invalid, unsupported profile, and no-solution states.
- **CNS/OTU:** NOAA piecewise single-exposure CNS limits (seven segments, Baker/NOAA Diving Manual) with ramp integration on descent/ascent segments; Lambertsen OTU (UPTD) with Baker Eq. 2 for linear PPO2 ramps. Still reference-only — not certified exposure limits.

Remaining UX limitations: calculation is synchronous (no progress spinner); Dynamic Type stress on dense stepper cards may still require scrolling; physical-device VoiceOver walkthrough recommended before release.

## Safety Validation

The engine fails closed for invalid profile or gas states:

- non-finite profile values
- invalid GF Low / GF High
- invalid O2 or He fractions
- O2 + He > 1.0
- bottom gas above MOD
- deco/travel gas switch deeper than MOD
- gas used shallower than minimum breathable PPO2
- gas that is not operational across the full breathed segment
- schedule propagation limit reached

## Integration Boundary

The engine is iOS-only. It does not modify Apple Watch runtime behavior, watchOS targets, Watch connectivity runtime logic, dive telemetry, depth/ascent calculations, or experimental feature files.

## Comprehensive Readiness Implementation (2026-05-29)

### Environment consistency

- `BuhlmannConstants.seaLevelSurfacePressureBar` = `1.01325` bar aligns with `PlannerEnvironment.seaLevelSaltWater`.
- `BuhlmannTissueState.airSaturated()` uses that constant by default.
- `BuhlmannGas` nil-environment ambient pressure uses ISA sea-level saltwater formula — not legacy `1.0 bar + 10 m/bar`.
- `PlannerStore` passes `PlannerEnvironment` into preview `BuhlmannPlanner.plan` so NDL curve matches plan environment.

### Repetitive planning

- Snapshot persists only on explicit **Calculate Plan** — not on every input keystroke.
- Snapshot source: prior calculated reference plan output (not dive log).
- `.surfaceIntervalRejected` emitted for invalid surface interval minutes.

### Bailout

- Bailout role remains outside primary `BuhlmannEngine` schedule; documented and surfaced in UI hint.

### Performance

- GF comparison results cached in-memory (`GFComparisonCache`) — outputs unchanged, repeat calls faster.
