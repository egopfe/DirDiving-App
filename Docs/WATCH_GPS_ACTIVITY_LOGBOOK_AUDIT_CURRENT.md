# Watch GPS → Activity Logbook Audit (Current)

**Baseline:** post Apnea UI visibility remediation  
**Date:** 2026-07-01  

## Summary matrix

| Activity | Model GPS fields | Runtime capture | Watch logbook | Watch → iOS sync | iOS logbook | iOS UI | Verdict | Fix required |
|----------|------------------|-----------------|---------------|------------------|-------------|--------|---------|--------------|
| **Diving** | `entryGPS`, `exitGPS`, fix sources | `DiveManager` + `GPSManager` one-shot at start/end | `DiveLogStore` | `WatchDiveSyncCodec` full session | `DiveLogStore` / iOS import | `DiveDetailView` GPS rows | **CONFIRMED** | Clarify UI labels only |
| **Snorkeling** | `entryPoint`, `trackPoints`, GPS quality | `SnorkelingWatchRuntimeStore` + engine ingest | `SnorkelingLogbookStore` | `SnorkelingSessionSyncCodec` | `IOSSnorkelingLogbookStore` | Detail map + runtime summary | **PARTIAL → CONFIRMED** | Entry/exit one-shot at start/end |
| **Apnea** | `surfaceGPSPoints`, `gpsUnavailable` warning | Was missing; added `WatchSurfaceLocationService` | `ApneaLogbookStore` | `ApneaSessionSyncCodec` | `IOSApneaLogbookStore` | Map tab + new summary card | **MISSING → REMEDIATED** | Wire capture at arm/save |

## Diving

| Stage | Finding | Verdict |
|-------|---------|---------|
| Model | `DiveSession.entryGPS/exitGPS`, `GPSFixSource` | CONFIRMED |
| Runtime | Best-effort 6s capture at dive start/end; no underwater GPS | CONFIRMED |
| Logbook | Persisted via `DiveManager.finalizeDive` → `DiveLogStore` | CONFIRMED |
| Sync | Full session JSON via signed `WatchDiveSyncCodec` | CONFIRMED |
| iOS UI | Start/end coordinates + fix source in dive detail | CONFIRMED |
| Gap | None functional; textual GPS status keys added | PARTIAL (labels) |

## Snorkeling

| Stage | Finding | Verdict |
|-------|---------|---------|
| Model | `SnorkelingTrackPoint`, `SnorkelingGPSQuality`, `entryPoint` | CONFIRMED |
| Runtime | Continuous surface updates via `GPSManager`; engine marks underwater / unavailable | CONFIRMED |
| Runtime gap | Explicit entry capture at `startSession`, exit fix at `endSession` | PARTIAL (fixed) |
| Logbook | `saveCompletedSession` stores engine session with track | CONFIRMED |
| Sync | Full session via `SnorkelingSessionSyncCodec` | CONFIRMED |
| iOS UI | Map + runtime summary; added GPS track counts card | PARTIAL → CONFIRMED |

## Apnea

| Stage | Finding | Verdict |
|-------|---------|---------|
| Model | `ApneaSurfaceGPSPoint`, `.gpsUnavailable` warning | CONFIRMED |
| Runtime (before) | No GPS manager attachment; `surfaceGPSPoints` never populated | MISSING |
| Runtime (after) | `WatchSurfaceLocationService` + capture at arm/save | REMEDIATED |
| Logbook | `saveCompletedSession` adds warning when empty | REMEDIATED |
| Sync | Full session via `ApneaSessionSyncCodec` | CONFIRMED (transport ready; fields were empty) |
| iOS UI | Map tab existed; summary GPS card added | PARTIAL → CONFIRMED |
| Policy | No route/navigation runtime; metadata only | CONFIRMED |

## Cross-activity

- GPS data remains in activity-specific models (no cross-logbook contamination).
- When In Use only; no Always Location; no fake coordinates.
- Missing GPS does not invalidate valid activity sessions.

## Risk levels

| Risk | Area | Level |
|------|------|-------|
| Apnea sessions saved without surface metadata | Apnea runtime | **High** (fixed) |
| Snorkeling entry without immediate fix | Snorkeling start | **Medium** (mitigated) |
| Diving GPS stale fallback misread as measured | Diving UI | **Low** |
| Sync payload size with large snorkel tracks | Snorkeling sync | **Low** (existing caps) |

## Fix plan

1. ✅ `WatchSurfaceLocationService` (activity-safe wrapper over `GPSManager`)
2. ✅ Apnea Watch runtime GPS at arm + save
3. ✅ Snorkeling start/end surface capture helpers
4. ✅ iOS logbook GPS status cards (Apnea, Snorkeling)
5. ✅ Tests + localization + QA templates
6. Physical Watch GPS QA — **PENDING**
