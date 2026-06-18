# DIR Diving — Snorkeling iOS Logbook, Graphs, Statistics and Records (Command 09)

**Date:** 2026-06-18  
**Command:** `09_IOS_SNORKELING_LOGBOOK_GRAPHS_STATS_RECORDS.md`  
**Gate:** `READY_FOR_SNORKELING_COMMAND_10`

## Summary

Command 09 delivers production iOS Snorkeling logbook and analytics on top of the Command 08 companion shell. Pure shared services compute charts, map segments, dip surface association, aggregate statistics, and personal records. The UI follows Apnea companion patterns with session list/detail, statistics, records, and MapKit surface tracks that show GPS gaps without interpolating underwater positions as measured truth.

## Delivered

### Shared analytics (pure services)

- `SnorkelingRecordEligibilityPolicy` — simulated/degraded exclusion; statistics vs records eligibility
- `SnorkelingLogbookAnalytics` — range filtering (7D/30D/1Y/all) and `SnorkelingAggregateStatistics`
- `SnorkelingDipAnalytics` — dip metrics with surface association method and uncertainty
- `SnorkelingSessionChartBuilder` — depth, distance, speed, temperature, dip bars (measured surface only for distance/speed)
- `SnorkelingSessionMapPresentation` — segmented surface track with `hasGapBefore`, fix quality, sparse warnings
- `SnorkelingPersonalRecordsEngine` — deepest/longest dip, session depth/distance/dips/duration with ties

### iOS presentation and stores

- `IOSSnorkelingLogbookPresentation.swift` — session rows, summary, dip detail, personal records
- `IOSSnorkelingLogbookStore` — `charts(for:)`, `dipMetrics(for:)`, `aggregate(range:)`, `personalRecords(options:)`, `delete(id:)`
- Dashboard average max depth and sessions-this-month now use full logbook data

### iOS views

- `IOSSnorkelingSessionsListView` — logbook list with quality warnings
- `IOSSnorkelingSessionDetailView` — hero metrics, depth chart, surface map (gap segments), secondary charts, dips, markers, equipment, buddy
- `IOSSnorkelingStatisticsView` — range picker, eligible-only toggle, aggregate summary
- `IOSSnorkelingPersonalRecordsView` — filters for degraded/simulated, tie display
- `IOSSnorkelingRootView` — added **Logbook** and **Statistics** tabs (5 tabs total)

### Localization

- EN/IT keys under `snorkeling.ios.sessions.*`, `snorkeling.ios.session.*`, `snorkeling.ios.charts.*`, `snorkeling.ios.stats.*`, `snorkeling.ios.records.*`, `snorkeling.ios.dip.*`, `snorkeling.ios.map.*`, `snorkeling.ios.marker.*`

### Tests (Command 09 focused)

| Suite | Count | Result |
|-------|------:|--------|
| `IOSSnorkelingLogbookAnalyticsTests` | 12 | PASS |
| Prior Command 08 focused suites | 26 | PASS |
| **Total focused** | **38** | **PASS** |

Build: **DIRDiving iOS** — BUILD SUCCEEDED (iPhone 17 Simulator).

## Rules preserved

- Calculations in pure shared services; no underwater GPS interpolation as truth
- Dip surface position shows method (measured / last known / estimated / unavailable) and accuracy when present
- Simulated and low-quality sessions excluded from personal records by default (overridable)
- No second snorkeling runtime on iOS; Watch engine remains authoritative
- `ExplorationCenterView` remains excluded from production

## Gate

`READY_FOR_SNORKELING_COMMAND_10` — iOS logbook UI and analytics are ready for the next snorkeling iOS command in the chain.
