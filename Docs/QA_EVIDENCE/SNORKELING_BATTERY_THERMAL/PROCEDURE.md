# Snorkeling Battery and Thermal — Physical Procedure

**QA ID:** SNK-QA-009 (`SNORKELING_BATTERY_THERMAL`)  
**Status:** PENDING

## Thresholds

Use project tolerances from `SnorkelingReleaseHardTolerances` and release checklist only — do not invent new limits in the field.

## Devices

- Apple Watch Ultra (49 mm) — 60-minute surface session
- Smallest supported Watch (41 mm class) — 30-minute surface session
- Paired iPhone for end-of-session sync scenarios

## Scenarios

| ID | Scenario | Duration | Record |
|----|----------|----------|--------|
| BT-01 | Surface-only session | 30 min | Battery % before/after; thermal state notes |
| BT-02 | Surface + repeated dips | 45 min | GPS update feel; no runaway UI refresh |
| BT-03 | Waypoint navigation loop | 30 min | Compass/GPS duty cycle observation |
| BT-04 | Return-to-entry active | 20 min | Navigation panel stability |
| BT-05 | GPS degraded → reacquired | 15 min | Recovery without session reset |
| BT-06 | Offline route on Watch | 20 min | No WatchConnectivity retry storm |
| BT-07 | Mission Mode ON vs OFF | 30 min each | Compare drain (same location) |
| BT-08 | End-of-session sync | 10 min | Retry count acceptable; phone battery note |

## Instrumentation (development builds only)

- GPS update frequency within `SnorkelingReleaseHardTolerances`
- No verbose diagnostics in Release configuration

## Artifacts

- Battery before/after table in `README.md`
- watchOS Settings → Battery screenshot (optional)
- Thermal state observations (nominal/fair/serious/critical if visible)
