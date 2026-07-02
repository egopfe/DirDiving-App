# Snorkeling Planned vs Actual Analytics Policy

**Scope:** iOS Snorkeling session logbook detail.

## Data sources

- Planned distance: active `SnorkelingRoutePlan` waypoint chain.
- Actual distance: `session.statistics.totalDistanceMeters`.
- Route progress / max off-route / return alert: `session.runtimeSummary` when present.

## Summary keys

| Condition | Key |
|-----------|-----|
| No planned route | `snorkeling.logbook.planned_vs_actual.no_route` |
| No track distance | `snorkeling.logbook.planned_vs_actual.no_track` |
| Both available | `snorkeling.logbook.planned_vs_actual.available` |

## Forbidden

- Inventing planned routes or distances
- Safety-critical route validation claims
