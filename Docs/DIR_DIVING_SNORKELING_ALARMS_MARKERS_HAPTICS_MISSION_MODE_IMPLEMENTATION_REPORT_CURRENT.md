# DIR DIVING — Snorkeling Alarms, Markers, Haptics and Mission Mode

**Command:** `05_SNORKELING_ALARMS_MARKERS_HAPTICS_MISSION_MODE.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** (event engine only; Watch MAIN UI not promoted)  
**Gate:** `READY_FOR_SNORKELING_COMMAND_06`

---

## Scope

UI-independent snorkeling operational event engine: configurable alarms, marker capture with explicit position quality, haptic cue emission with rate limiting, and Mission Mode presentation profile. Built on Commands 01–04 foundations.

---

## Architecture

| Layer | Location |
|-------|----------|
| Alarm kinds (extended) | `Shared/Models/SnorkelingAlarm.swift` |
| Marker position quality | `Shared/Models/SnorkelingMarkerPositionQuality.swift` |
| Marker model (optional coords) | `Shared/Models/SnorkelingMarker.swift` |
| Operational models | `Shared/Utils/SnorkelingOperationalModels.swift` |
| Alarm/GPS event engine | `Shared/Utils/SnorkelingOperationalEventEngine.swift` |
| Marker capture | `Shared/Utils/SnorkelingMarkerCaptureEngine.swift` |
| Session integration | `SnorkelingSessionEngine.saveMarker`, overlays, haptics |

---

## Alarms

Kinds: max depth, session duration, entry distance, dip duration, ascent rate, battery, temperature, GPS degraded/lost, sensor degraded.

Features: per-alarm hysteresis, minimum repeat interval, simultaneous alarm support, visual overlay fallback when haptics disabled.

---

## Markers

- Standard categories + custom label
- Explicit `SnorkelingMarkerPositionQuality` (measured / degraded / unavailable / noFix)
- Optional coordinates when policy allows save without fix
- Entry distance/bearing, depth, temperature, heading, photo reference ID
- Note length cap (120 chars)

---

## Haptics

Distinct patterns: marker saved, waypoint reached, return advised, alarm info/warning/critical. Global cooldown + per-alarm repeat limits. Disabled haptics still emit overlays.

---

## Mission Mode

`SnorkelingMissionModePresentationProfile` reduces animation and minimum presentation refresh interval. **Does not** disable alarms, haptics, sensor ingestion, or lifecycle evaluation.

---

## Tests

`SnorkelingAlarmsMarkersHapticsMissionModeTests` (12 tests): thresholds, hysteresis, simultaneous alarms, marker no-fix/custom category, haptics off, mission mode invariants, deterministic replay, session integration.

---

## Explicit non-goals

- Watch/iOS marker save UI screens
- `SnorkelingView` Watch MAIN promotion
- Photo capture implementation (reference ID only)
