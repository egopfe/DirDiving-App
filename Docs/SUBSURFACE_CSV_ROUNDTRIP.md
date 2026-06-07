# Subsurface CSV round-trip (iOS Companion + Watch MAIN)

**Updated:** 2026-06-06  
**Baseline:** `main` @ post Watch remediation  
**Scope:** `SubsurfaceExportService` on iOS Companion MAIN and Watch MAIN; `DiveImportService` on iOS Companion MAIN only

## Overview

DIR DIVING exports Subsurface-compatible dive profile CSV with optional `# session_meta` comment lines. Re-import restores supported session metadata when the block is present. External Subsurface CSV without metadata still imports using legacy fallbacks.

**Watch alignment (2026-06-06):** Watch export uses the same profile column set and **first-sample-relative** monotonic `time_seconds` as iOS. See [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) for Watch-specific metadata differences.

## Export format

### Profile columns (required)

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes
```

`time_seconds` is **elapsed integer seconds from the first exported sample timestamp** (monotonic). Session wall-clock times remain in `# dirdiving_start_date` / `# dirdiving_end_date`.

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

## External Subsurface manual regression (LOW-004 — pending)

**Status:** Not automated; must be executed on a real Subsurface install before external TestFlight sign-off.

| Step | Action | Pass |
|---:|---|---|
| 1 | Export Watch-originated dive from iOS Logbook → CSV | ☐ |
| 2 | Export manual iOS dive (no profile) — export blocked or empty profile rejected | ☐ |
| 3 | Export imported dive with GPS/temperature metadata | ☐ |
| 4 | Import CSV into Subsurface desktop app | ☐ |
| 5 | Verify `time_seconds` monotonic from first sample; depth in meters | ☐ |
| 6 | Verify GPS columns and `# session_meta` dates unchanged | ☐ |
| 7 | Verify no duplicate/shifted timebase after re-export from Subsurface | ☐ |

Record build, commit, device, and Subsurface version in release notes when executed.

## Limitations

- Export uses **integer seconds** from the first profile sample (Subsurface compatibility); sub-second sample timing is not preserved on export.
- Watch exports omit iOS-only metadata fields (equipment, pressures, site, buddy); importers must tolerate empty columns.
- Depth validation uses centralized limits in `IOSAlgorithmConfiguration` (see planner/sync docs for operating vs import ranges).

## References

- [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) — Watch export policy
- [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md) — user workflow
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — B5 resolution
- [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) — WATCH-EXP-001
- Tests: `Tests/iOSAlgorithmTests/CSVMetadataRoundTripTests.swift`, `Tests/WatchAlgorithmTests/WatchSyncCodecAlgorithmTests.swift`
