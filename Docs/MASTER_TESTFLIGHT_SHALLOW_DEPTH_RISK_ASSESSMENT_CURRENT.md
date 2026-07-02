# MASTER TestFlight Shallow Depth Risk Assessment (CURRENT)

**Baseline:** `main` @ `7ae527b`

## Risk posture

- Shallow-depth capability can be documented for internal/testing lanes.
- Physical and entitlement-adjacent runtime gates are still pending evidence.
- Developer shallow test features must remain hidden from public/App Store positioning.

## Current high risks

1. Missing physical system auto-launch and wet evidence.
2. Missing physical hardware controls evidence (Action Button, Crown, Water Lock).
3. Potential misunderstanding if shallow developer tests are surfaced as production guarantees.

## Decision

- Internal TestFlight: **CONDITIONAL** with explicit safety disclaimers.
- External TestFlight / App Store: **NOT_READY** until physical + legal lanes close.
