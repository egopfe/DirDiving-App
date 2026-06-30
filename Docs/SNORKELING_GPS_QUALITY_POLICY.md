# Snorkeling GPS Quality Policy

**Applies to:** Snorkeling iOS maps and Apple Watch runtime presentation.  
**Not claimed:** Survey-grade positioning or safety-critical fix classification.

## Principles

1. **When In Use** location authorization only — no Always/background location for Snorkeling.
2. No fake or simulated coordinates in production runtime or real logbook persistence.
3. Degraded states must be visible; never imply precision when unavailable.
4. Underwater GPS fixes are not treated as measured surface navigation fixes.

## Watch presentation bands

Evaluated by `SnorkelingGPSQualityEvaluator` → `SnorkelingWatchGPSPresentationBand`:

| Band | Typical conditions (defaults) |
|------|-------------------------------|
| `good` | Horizontal accuracy ≤ 15 m AND fix age ≤ 10 s |
| `medium` | Horizontal accuracy ≤ 35 m AND fix age ≤ 20 s |
| `poor` | Coordinate present but outside good/medium thresholds |
| `lost` | No coordinate, missing accuracy, or fix age > 60 s |

Thresholds are configurable via `SnorkelingGPSQualityThresholds`.

## Runtime effects

| Feature | GPS requirement |
|---------|-----------------|
| Return-to-entry precise guidance | Good/medium preferred; degraded when lost |
| Off-route warning | Requires `good` or `medium`; paused when lost/poor |
| Waypoint auto-reached | Distance threshold 25 m; caution when GPS poor |
| Track distance accumulation | Measured surface fixes only (`SnorkelingDomainSupport.trackDistanceMeters`) |
| Map polyline / GPX | Measured surface fixes; gaps > 30 s split segments |

## Logbook

Session runtime summary (`SnorkelingSessionRuntimeSummary`) records:

- Final or dominant GPS quality band
- Track point count, gaps, average/max horizontal accuracy
- Route progress, off-route metrics, return alert fired flag

Displayed on iOS session detail — not a certification of fix quality.

## iOS permission denial

When location denied: show degraded state and link to Settings (`IOSSnorkelingLocationPermission`). Route planner map may be limited; validation does not invent coordinates.

## Tests

- `SnorkelingGPSQualityEvaluatorTests`
- `SnorkelingDistanceConsistencyTests`
- `SnorkelingReturnAlertRuntimeTests` (off-route paused when lost)

## Physical QA

- `Docs/QA_EVIDENCE/SNORKELING_WATCH_GPS_QUALITY/`
- `Docs/QA_EVIDENCE/SNORKELING_LOGBOOK_GPS_QUALITY/`
- `Docs/QA_EVIDENCE/WATCH_SNORKELING_GPS_UNAVAILABLE_DEGRADATION/` (existing)
