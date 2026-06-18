# DIR DIVING — Apnea Alarms, Targets, Markers, Haptics

**Command:** `04_APNEA_ALARMS_TARGETS_MARKERS_HAPTICS.md`  
**Date:** 2026-06-17  
**Branch:** `main`  
**Result:** PASS

## Scope implemented
- Operational apnea event engine for alarms, targets, markers with single-crossing firing and hysteresis re-arm.
- Distinct haptic cue taxonomy and non-overlap gating.
- Overlay payloads for visual fallback when haptics are disabled.
- Mission Mode compatibility (no reduction in event detection/output semantics).
- Deterministic replay tests for crossings, threshold oscillation, multiple markers, simultaneous alarms.

## Safety and policy notes
- No blackout/no-movement reliable detection claim introduced.
- Any safety heuristics remain explicit and non-lifesaving by design.
- Events are generated in pure shared logic (`Shared/Utils`) for deterministic testability.

## Files
- `Shared/Utils/ApneaOperationalEventEngine.swift`
- `Tests/WatchAlgorithmTests/ApneaOperationalEventEngineTests.swift`
- `project.yml`

## Visual references used
- `APNEA_WATCH_06_DEPTH_ALARMS`
- `APNEA_WATCH_07_MARKER_REACHED`
- `APNEA_WATCH_08_TARGET_REACHED`
- `APNEA_IOS_11_ALARMS`
- `APNEA_IOS_12_MARKERS`

These references were treated as visual guidance only, with logic/accessibility/safety requirements taking precedence.
