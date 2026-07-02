# Snorkeling Logbook Track Quality Policy

Derived from persisted `trackPoints` only (no runtime engine access):

| Measured ratio | Label key |
|----------------|-----------|
| ≥ 75% | `track_quality.good` |
| ≥ 40% | `track_quality.degraded` |
| > 0 measured | `track_quality.sparse` |
| empty / 0 measured | `track_quality.unavailable` |

GPS quality band and route progress come from `runtimeSummary` when present.
