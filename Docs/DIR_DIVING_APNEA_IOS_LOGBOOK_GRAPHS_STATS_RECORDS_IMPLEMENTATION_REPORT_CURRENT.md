# DIR DIVING — iOS Apnea Logbook, Graphs, Statistics and Records

**Command:** `09_IOS_APNEA_LOGBOOK_GRAPHS_STATS_RECORDS.md`  
**Date:** 2026-06-17  
**Branch:** `main`  
**Result:** PASS

## Implemented
- Logbook list with navigation to session detail, quality warnings, and empty state.
- Session detail: summary metrics, dive list, charts tab (depth/time/recovery), optional GPS map with accuracy note.
- Dive detail: depth profile chart, descent/ascent speed, bottom time, temperature, markers, alarms, recovery intervals.
- Statistics tab: period filters, eligible-session filter, link to personal records.
- Personal records with automatic exclusion of simulated/degraded sessions and explicit override toggles.
- Record ties surfaced when multiple sessions share the same best value.

## Architecture
- Pure shared services: `ApneaRecordEligibilityPolicy`, `ApneaPersonalRecordsEngine`, `ApneaDiveAnalytics`, `ApneaSessionChartBuilder`, `ApneaSessionMapPresentation`.
- Presentation mapper: `IOSApneaLogbookPresentationMapper` (views read mapped output only).
- `IOSApneaLogbookStore` extended with session lookup, charts, dive metrics, and records helpers.

## Tests
- `IOSApneaLogbookAnalyticsTests.swift`: eligibility overrides, records/ties, dive analytics, chart builder, map availability, range filters, imperial presentation, chart performance.

## Localization
Added EN/IT keys for session/dive detail, charts, map, records, and data-quality warnings.

## Visual references used
- `APNEA_IOS_04_DIVE_DETAIL`
- `APNEA_IOS_05_SESSION_CHARTS`
- `APNEA_IOS_06_STATISTICS`
- `APNEA_IOS_09_SESSION_MAP`
- `APNEA_IOS_10_LOGBOOK`

Mockups used as hierarchy references; chart series and record eligibility follow tested services.
