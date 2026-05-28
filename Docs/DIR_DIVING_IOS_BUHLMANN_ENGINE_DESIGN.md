# DIR DIVING iOS Buhlmann Engine Design

Date: 2026-05-28  
Scope: iOS Companion MAIN only

## Purpose

DIR DIVING iOS includes an isolated pure Swift Buhlmann ZHL-16C multigas planning reference engine under `iOSApp/Algorithms/Buhlmann/`. The engine supports nitrogen and helium compartment loading for air, nitrox, trimix, heliox, travel gas, bottom gas, and decompression gas planning.

The engine is informational and non-certified. It must never be presented as a life-support system, a real-time decompression controller, or a substitute for certified dive computers, tables, training, or team procedures.

## Files

- `BuhlmannConstants.swift`: ZHL-16C N2/He constants, water vapor pressure, stop interval, ascent/descent assumptions.
- `BuhlmannGas.swift`: validated gas model, PPO2, MOD, minimum operating depth, gas labels, plan issues.
- `BuhlmannTissueModel.swift`: tissue compartments, Schreiner loading, mixed coefficient ceiling calculation.
- `BuhlmannEngine.swift`: request/result model, validation, NDL search, GF interpolation, multigas stop schedule.
- `BuhlmannPlanner.swift`: iOS planner adapter from `GasPlanInput` to the pure engine.

## Mathematical Model

- Surface pressure: `1.0 bar`.
- Depth conversion: project canonical `10 m/bar` approximation through `IOSUnitConversions`.
- Inspired inert gas pressure: `(ambient pressure - water vapor pressure) * inert fraction`.
- Tissue loading: exponential Haldane loading at constant depth and Schreiner-style loading for linear ascent/descent.
- Ceiling: per-compartment mixed N2/He a/b coefficients weighted by current inert gas tissue pressures.
- Gradient factors: GF Low at first stop, GF High at the surface, interpolated by depth.
- Stops: rounded to the configured 3 m interval and propagated until the next shallower stop is allowed.
- Optional multiple bottom segments: each segment carries its own depth, duration, and gas.

## Gas Strategy

- Bottom gas is used for descent and bottom loading unless travel gases are provided.
- Multiple bottom segments can be passed to the pure engine for staged bottom gas/time/depth loading.
- Travel gases are used during descent at configured switch depths.
- Deco gases are selected on ascent when the current stop depth is at or shallower than their switch depth and PPO2 is within bounds.
- Higher oxygen deco gases are preferred when validated at the current stop depth.

## Safety Validation

The engine fails closed for invalid profile or gas states:

- non-finite profile values
- invalid GF Low / GF High
- invalid O2 or He fractions
- O2 + He > 1.0
- bottom gas above MOD
- deco/travel gas switch deeper than MOD
- gas used shallower than minimum breathable PPO2
- schedule propagation limit reached

## Integration Boundary

The engine is iOS-only. It does not modify Apple Watch runtime behavior, watchOS targets, Watch connectivity runtime logic, dive telemetry, depth/ascent calculations, or experimental feature files.
