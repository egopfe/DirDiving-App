# DIR Diving iOS — Planner Dive Runtime Presentation

**Branch:** `main`  
**Scope:** iOS Companion planner UI/export presentation only

## Summary

The former **Piano di risalita** / **Ascent Plan** section is now **Runtime immersione** / **Dive Runtime**.

It presents the full operational runtime sequence of a dive, not only ascent/decompression:

| Phase (IT) | Phase (EN) | Source |
|------------|------------|--------|
| Discesa | Descent | Bühlmann engine descent segments |
| Fondo | Bottom | Bühlmann bottom segment |
| Risalita | Travel | Post-bottom ascent / gas switch segments |
| Sosta Deco | Deco Stop | Bühlmann decompression stops |
| Superficie | Surface | Terminal surface row |

## Modes

- **Deco / Technical:** Full runtime table with descent, bottom, travel, deco stops, surface.
- **CCR:** CCR schedule card uses the same runtime title; rows labeled via `DiveSegmentKind.runtimeRowTitle` from engine output.
- **Base:** No forced runtime table in result policy; if rows exist, no “Sosta Deco” unless real deco stops are present.

## Sequential runtime ordering

Runtime rows after bottom follow the **operational sequence** from `BuhlmannEngineResult.segments`:

- Ascent and gas-switch segments → **Risalita / Travel** (internal row kind `.travel`)
- Stop segments (`.stop`) → **Sosta Deco / Deco Stop**, enriched from Bühlmann `decoStops` for gas/PPO₂ labels
- Rows are **interleaved** (travel → deco stop → travel → …) rather than grouped by kind

The runtime table does **not** recalculate decompression. Stop depths, stop times, gas switches, and PPO₂ values come from the existing engine output.

CCR schedule rows remain ordered by `CCRPlannerEngine` output where supported.

## Dedicated deco stops summary

**Runtime immersione / Dive Runtime** is the complete operational sequence (descent, bottom, travel, interleaved deco stops, surface).

**Tappe Decompressione / Deco Stops** is a separate compact section listing only Bühlmann-generated decompression stops:

- Stop number, depth, time, gas, PPO₂
- Sourced from `DivePlanResult.decoStops` (OC Deco/Technical) or `CCRPlanResult.decoStops` (CCR)
- Hidden for Base/no-deco plans
- Bailout heuristic rows are not deco stops

No calculations are changed. The planner remains reference-only and non-certified.

## Calculation boundaries

- Adding **Discesa** is a presentation projection from existing `BuhlmannEngineResult.segments`.
- **Bühlmann stop depths/times are unchanged.**
- **CCR setpoint / tissue / bailout math unchanged.**
- **Ratio Deco remains comparative heuristic** and does not replace Bühlmann runtime.

## Reference-only positioning

Planner output remains reference-only and non-certified. CCR runtime does not imply live loop PPO₂ monitoring or certified controller behavior.
