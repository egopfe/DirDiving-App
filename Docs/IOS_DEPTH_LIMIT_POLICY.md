# iOS Companion — Depth Limit Policy

**Scope:** `DIRDiving iOS` logbook, Watch sync codec (iOS side), CSV import/export, validators.

## Limits

| Constant | Meters | Use |
|----------|--------|-----|
| `maxPlannerDepthMeters` | 120 | Bühlmann reference planner input only |
| `maxStoredProfileDepthMeters` | 350 | Stored samples, sync validation, CSV import/export, logbook normalization |
| `supportedWatchDepthLimitMeters` | 40 | UI safety discouragement (Watch-aligned); not a hard sample cap |

`maxImportExportDepthMeters` and `maxSyncDepthMeters` are aliases of `maxStoredProfileDepthMeters` (350 m).

## Rationale

- Dives logged on Apple Watch may exceed 300 m while remaining within the app storage envelope (350 m).
- CSV round-trip uses the same cap as sync so a synced dive can be exported without silent failure.
- Planner recreational reference input remains capped at 120 m independently.

## User-facing behavior

- Samples above 350 m are rejected on import/validation with explicit errors.
- Export normalizes at 350 m; sessions within cap export all samples.
- Operational warnings at 35 / 38 / 40 m are unchanged (informational, non-certified).
