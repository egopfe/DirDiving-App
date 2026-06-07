# Apple Watch MAIN — CSV Export Policy

**Updated:** 2026-06-06  
**Target:** `SubsurfaceExportService` on Watch MAIN  
**Related:** [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md), [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md)

---

## Alignment decision (WATCH-EXP-001)

Watch CSV export is **aligned with iOS hardened export** for profile columns and time-base policy. Intentional Watch differences are limited to metadata richness (Watch `DiveSession` lacks iOS-only fields).

---

## Profile columns

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes
```

| Column | Policy |
|---|---|
| `time_seconds` | Non-negative, monotonic; **elapsed seconds from first exported sample timestamp** (matches iOS) |
| `depth_m` | Metric, two decimal places |
| `temperature_c` | Celsius one decimal; empty if missing |
| GPS columns | Session entry/exit metadata repeated per row |
| `is_manual` | `1` or `0` |
| `equipment`, pressures, `deco_notes` | Empty on Watch (no model fields) |

---

## Metadata block

```csv
# session_meta
# dirdiving_session_id: <UUID>
# dirdiving_start_date: <ISO8601>
# dirdiving_end_date: <ISO8601>
# dirdiving_is_manual: 0|1
# dirdiving_watch_export: 1
# session_meta,<is_manual>,,,,
```

iOS exports additional `# dirdiving_*` lines (equipment, pressures, site, buddy, gas, SAC). Watch exports omit these; importers must tolerate absence.

---

## Export guards

| Condition | Behaviour |
|---|---|
| Empty samples | Export rejected (`nil` CSV / no file) |
| Manual no-depth session | No profile export (persistence class) |
| Samples sanitized | Via `DiveAlgorithm.sanitizedSamples` before export |
| File location | `tmp/DIRDiving_Export_<UUID>.csv`, complete file protection |
| Cleanup | Exports older than 24 h removed on next export |

---

## Regression tests

Locked in:

- `DiveAlgorithmTests.testExportRejectsEmptyAndSortsSamples`
- `WatchReadinessAlgorithmTests.testExportCSVUsesFirstSampleAsTimeOrigin`
- `WatchSyncCodecAlgorithmTests.testExportTimeSecondsRelativeToSessionStart`

---

## Historical note

Prior Watch-only policy used `session.startDate` as `time_seconds` origin. Remediation @ 2026-06-06 switched to **first-sample origin** for iOS parity. Subsurface import treats relative seconds; session wall times remain in `# dirdiving_start_date` / `# dirdiving_end_date`.

---

## P3 — Direct `makeCSV()` header-only call (WATCH-P3-008)

`SubsurfaceExportService.makeCSV()` is intended to be invoked only through the public export path that validates non-empty samples first. Calling it directly with an empty sample array produces a header/metadata-only artifact — not a supported user export. Export entry points reject empty sessions (`testExportRejectsEmptyAndSortsSamples`).
