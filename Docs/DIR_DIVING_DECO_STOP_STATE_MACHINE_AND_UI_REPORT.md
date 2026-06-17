# Command 06 — Deco Stop State Machine and UI Report

**Branch:** `integration/full-computer`

## State machine (`FullComputerDecoStopStateMachine`)

States: `approachingStop`, `holdingStop`, `tooShallow`, `tooDeep`, `ceilingViolation`, `stopRecalculation`, `stopCompleted`, `decoCompleted`.

### Stop depth thresholds (stop `D`)

| Zone | Rule |
|------|------|
| Valid window (timer accrues) | `D - 0.5 m` … `D + 1.0 m` |
| Too shallow | `< D - 0.5 m` — timer suspended, yellow down arrow |
| Too deep | `> D + 1.0 m` — timer suspended, yellow up arrow |
| Progress reset | `> D + 2.0 m` — invalidate progress, recalculate |
| Hysteresis | `0.15 m` (`FullComputerDecoStopConfiguration`) |

Timer remaining time follows Bühlmann model minutes while `holdingStop`; frozen when suspended.

**QA note (Audit 02):** the stop countdown is **projection-synchronized**, not a wall-clock stopwatch. During `holdingStop`, `stopRemainingSeconds` tracks `nextStopMinutes` from the solver refreshed each engine tick. Physical QA scripts must not expect independent chronometer behaviour.

## UI (mockup-aligned)

- Deco mode hides manual stopwatch and Start/Stop/Reset.
- Top metrics: **TTS | CEILING | Runtime**.
- Active gas badge.
- `FullComputerDecoStopStatePanel` — title, directional indicator, stop depth, remaining time, instruction, bottom row (remaining stops / ascent allowed).
- Green hold panel with horizontal left arrow and `MANTIENI LA PROFONDITÀ`.
- `DECOMPRESSIONE COMPLETATA` / `PUOI RISALIRE IN SUPERFICIE` (no celebratory animation).
- Normal deco status: `IN IMMERSIONE | DECOMPRESSIONE` (green), not a large red `FUORI CURVA` banner.

## Haptics

`FullComputerDecoHapticCoordinator` — distinct pulses on ceiling violation and stop recalculation.

## Tests

`FullComputerDecoStopStateMachineTests` — thresholds, hysteresis, ceiling priority, deco completed, engine integration, haptic routing.
