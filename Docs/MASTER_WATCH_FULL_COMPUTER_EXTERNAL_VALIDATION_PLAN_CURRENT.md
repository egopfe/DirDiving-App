# Watch Full Computer External Validation Plan (V1.7)

**Status:** `PENDING_EXTERNAL_VALIDATION`

## Scope
- Independent Buehlmann replay (sea level + altitude)
- Air/Nitrox/Trimix vectors including 39m -> 10m multilevel profile
- Gas-switch and re-descent scenarios
- TTS/schedule parity checks with explicit tolerance table

## Minimum package
1. Export replay CSV timelines (`depth, timestamp, gas, environment`).
2. Run against independent implementation/tooling with documented assumptions.
3. Compare per-second tissues, ceiling, controller, TTS, schedule transitions.
4. Triage discrepancies by source (pressure model, GF interpolation, switch ordering, stop-state behavior).
5. Obtain independent reviewer sign-off.

## Governance constraints
- No EN13319/medical/certification claims from internal-only evidence.
- Simulator results are supplementary, not external validation.
- Physical pressure-pot/chamber/controlled-water evidence tracked separately.
