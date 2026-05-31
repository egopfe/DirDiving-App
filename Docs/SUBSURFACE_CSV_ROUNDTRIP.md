# Subsurface CSV round-trip (iOS Companion MAIN)

**Updated:** 2026-05-31  
**Baseline:** `main` @ `dce89e7`  
**Scope:** `SubsurfaceExportService` + `DiveImportService` on iOS Companion MAIN only

## Overview

DIR DIVING exports Subsurface-compatible dive profile CSV with optional `# session_meta` comment lines. Re-import restores supported session metadata when the block is present. External Subsurface CSV without metadata still imports using legacy fallbacks.

## Export format

### Profile columns (required)

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
```

### Metadata block (DIR DIVING export)

Comment lines at the top of the file, before profile rows:

```csv
# session_meta
# dirdiving_session_id: <UUID>
# dirdiving_start_date: <ISO8601>
# dirdiving_end_date: <ISO8601>
# dirdiving_is_manual: true|false
# dirdiving_entry_pressure: <value>
# dirdiving_exit_pressure: <value>
# dirdiving_equipment: <text>
# dirdiving_gas: <text>
# dirdiving_notes: <text>
# dirdiving_source: <text>
# dirdiving_app_version: <semver>
# dirdiving_export_version: 1
```

Subsurface ignores `#` comment lines; DIR DIVING uses them for round-trip fidelity.

## Import behaviour

| Field | With metadata | Without metadata |
|-------|---------------|------------------|
| Session ID | Restored when safe | New UUID |
| Start / end date | From meta | Derived from samples or import time |
| Manual flag | From meta | Heuristic / default |
| Entry / exit pressure | From meta | Empty |
| Equipment / gas / notes | From meta | Empty |
| GPS | From CSV columns | From CSV columns |

## QA checklist

1. Export dive from Logbook → re-import on same or clean install → start date and notes match.
2. Manual dive with entry/exit pressure → round-trip preserves pressures.
3. Notes containing commas, quotes, or newlines → no CSV corruption.
4. Legacy CSV (no `# session_meta`) → import succeeds with fallback dates.
5. External Subsurface export → import succeeds; DIR-specific fields absent as expected.

## Limitations

- Export uses **integer seconds** from dive start (Subsurface compatibility); sub-second sample timing is not preserved on export.
- Depth validation uses centralized limits in `IOSAlgorithmConfiguration` (see planner/sync docs for operating vs import ranges).

## References

- [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md) — user workflow
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — B5 resolution
- Tests: `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`
