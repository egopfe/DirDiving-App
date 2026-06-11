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
| Trasporto | Travel | Post-bottom ascent / gas switch segments |
| Sosta Deco | Deco Stop | Bühlmann decompression stops |
| Superficie | Surface | Terminal surface row |

## Modes

- **Deco / Technical:** Full runtime table with descent, bottom, travel, deco stops, surface.
- **CCR:** CCR schedule card uses the same runtime title; rows labeled via `DiveSegmentKind.runtimeRowTitle` from engine output.
- **Base:** No forced runtime table in result policy; if rows exist, no “Sosta Deco” unless real deco stops are present.

## Calculation boundaries

- Adding **Discesa** is a presentation projection from existing `BuhlmannEngineResult.segments`.
- **Bühlmann stop depths/times are unchanged.**
- **CCR setpoint / tissue / bailout math unchanged.**
- **Ratio Deco remains comparative heuristic** and does not replace Bühlmann runtime.

## Reference-only positioning

Planner output remains reference-only and non-certified. CCR runtime does not imply live loop PPO₂ monitoring or certified controller behavior.
