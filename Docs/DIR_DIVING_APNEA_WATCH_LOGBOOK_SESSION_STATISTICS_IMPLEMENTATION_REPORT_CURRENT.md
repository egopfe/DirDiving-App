# DIR DIVING — Apnea Watch Logbook and Session Statistics

**Command:** `07_APNEA_WATCH_LOGBOOK_AND_SESSION_STATISTICS.md`  
**Date:** 2026-06-17  
**Branch:** `integration/full-computer`  
**Result:** PASS

## Implemented
- Separate Apnea logbook storage (`ApneaLogbookStore`) isolated from `DiveLogStore`.
- Versioned checksum envelope persistence with atomic writes and corrupt-file quarantine.
- Logbook policy: validation, deduplication, merge preference, retention cap (80 sessions).
- Extended `ApneaSessionStatistics` with best duration, cumulative depth, average recovery, apnea/recovery ratio, event count and session duration.
- `ApneaLogbookStatistics` aggregate engine with time-range filtering (7d / 30d / 1y / all).
- `ApneaExplorationSessionBridge` to persist Watch exploration sessions into domain `ApneaSession` records.
- Watch session summary save now writes to Apnea logbook and shows a compact saved confirmation.

## Architecture
- Pure statistics and policy utilities live under `Shared/Utils/`.
- `ApneaLogbookStore` handles CRUD and persistence only; no SwiftUI business logic.
- Export-ready serialization via `ApneaLogbookFileEnvelope`.

## Tests
- `ApneaLogbookStoreTests.swift`: CRUD, merge/dedup, retention, corrupt quarantine, large sessions, known aggregates, export round-trip, legacy stats migration, exploration bridge, range filters.
- Updated `ApneaDomainModelTests` for extended session statistics.

## Localization
Added EN/IT keys for logbook saved confirmation (`apnea.logbook.saved`).

## Visual references used
- `APNEA_WATCH_05_SESSION_SUMMARY`
- `APNEA_IOS_04_DIVE_DETAIL`
- `APNEA_IOS_05_SESSION_CHARTS`
- `APNEA_IOS_06_STATISTICS`
- `APNEA_IOS_10_LOGBOOK`
- `APNEA_IOS_13_PERSONAL_RECORDS`

iOS logbook/detail/charts UI will consume the shared store and statistics services in a follow-up command; this pass delivers the tested storage and computation layer plus Watch save integration.
