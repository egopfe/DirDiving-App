# DIR Diving iOS — Planner Buddy Comparison Removal

**Branch:** `main`  
**Scope:** Presentation-only cleanup

## Summary

The partial **Team Gas Match** / **Team Gas Matching** sections were removed from the main Planner UI and briefing PDF export.

## Reason

The previous comparison covered only:

- available gas
- SAC
- minimum gas / reserve status

That is not a complete buddy/team compatibility analysis and could be misread as full team validation.

## What remains

- Gas ledger
- Gas consumption and remaining gas
- Rock bottom / minimum gas logic
- Reserve warnings
- Bailout / standby gas listing
- All underlying `GasPlanningService.teamGasMatches` computation (reserved for future use)

## Future Team / Buddy Planning

A future module should be named along the lines of:

- Team / Buddy Planning
- Team Compatibility Check
- Team Gas & Deco Compatibility

It should compare at minimum:

- gas supply, SAC/RMV, runtime, max/average depth, TTS
- decompression stops, gas switches, MOD/PPO₂
- CNS/OTU, bailout/team gas, OC/CCR compatibility, profile compatibility

## Calculation boundaries

No Bühlmann, CCR, Ratio Deco, gas consumption, rock bottom, reserve, or bailout calculations were changed.
