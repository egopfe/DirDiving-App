# Apple Watch MAIN — CSV Export Policy

**Updated:** 2026-06-02 (WATCH-EXP-001 remediation)  
**Target:** `SubsurfaceExportService` on Watch MAIN  
**Related:** [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md), [`WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`](WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md)

---

## Scope and safety posture

Watch CSV export is a **runtime / logging export only**. It records depth, temperature, GPS metadata, and session timing from a completed Watch dive session.

Watch CSV export is **not** a decompression plan, CCR log, or Bühlmann tissue-state export. Watch must never imply CCR, Bühlmann, Ratio Deco, setpoint, diluent, bailout, or decompression-authoritative metadata in CSV output.

---

## Intentional divergence from iOS CSV (WATCH-EXP-001)

Watch and iOS share **profile column headers** for Subsurface compatibility, but metadata blocks **intentionally differ**:

| Aspect | Watch MAIN | iOS |
|---|---|---|
| Export role | Companion dive logger | Full logbook + planner context |
| Depth units | Metric (`depth_m`) by policy | Metric (`depth_m`) |
| Metadata marker | `# dirdiving_watch_export: 1` | iOS-specific `# dirdiving_*` lines |
| CCR planner metadata | **Absent** — by design | May include `# dirdiving_ccr_*` when applicable |
| Bühlmann / Ratio Deco fields | **Absent** — Watch has no runtime | iOS planner-only |
| Equipment, gas, SAC, site, buddy | Omitted (no Watch model fields) | Present when available |

This divergence is **intentional and safe**. Importers and reviewers must not treat Watch CSV as carrying iOS CCR or decompression authority.

---

## Profile columns

```csv
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon,is_manual,equipment,entry_pressure,exit_pressure,deco_notes
```

| Column | Policy |
|---|---|
| `time_seconds` | Non-negative, monotonic; **elapsed seconds from first exported sample timestamp** |
| `depth_m` | Metric, two decimal places |
| `temperature_c` | Celsius one decimal; empty if missing |
| GPS columns | Session entry/exit metadata repeated per row |
| `is_manual` | `1` or `0` |
| `equipment`, pressures, `deco_notes` | Empty on Watch (no model fields; `deco_notes` is not a decompression schedule) |

---

## Metadata block (Watch only)

```csv
# session_meta
# dirdiving_session_id: <UUID>
# dirdiving_start_date: <ISO8601>
# dirdiving_end_date: <ISO8601>
# dirdiving_is_manual: 0|1
# dirdiving_watch_export: 1
# session_meta,<is_manual>,,,,
```

**Must not appear in Watch CSV:**

- `dirdiving_ccr`
- `buhlmann` / Bühlmann tissue or plan fields
- `ratio_deco` / Ratio Deco planner fields
- `setpoint`, `diluent`, `bailout` (CCR live-control semantics)
- Any decompression-authoritative metadata implying NDL, TTS, stops, or tissue loading

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
- `WatchCompleteAlgorithmAuditRemediationTests.testWatchCSVExportExcludesDecompressionAndCCRMetadata`

---

## Historical note

Prior Watch-only policy used `session.startDate` as `time_seconds` origin. Remediation @ 2026-06-06 switched to **first-sample origin** for profile time-base parity with iOS. Subsurface import treats relative seconds; session wall times remain in `# dirdiving_start_date` / `# dirdiving_end_date`.

---

## P3 — Direct `makeCSV()` header-only call (WATCH-P3-008)

`SubsurfaceExportService.makeCSV()` is intended to be invoked only through the public export path that validates non-empty samples first. Calling it directly with an empty sample array produces a header/metadata-only artifact — not a supported user export. Export entry points reject empty sessions (`testExportRejectsEmptyAndSortsSamples`).
