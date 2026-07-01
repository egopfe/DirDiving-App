# Watch GPS → Activity Logbook — Implementation Plan

**Date:** 2026-07-01  
**Baseline commit:** `f8457d7` (pre-GPS remediation)  
**Target verdict:** `INTERNAL_READY` / `PHYSICAL_QA_PENDING`

## Scope

End-to-end surface GPS capture on Apple Watch for Diving, Snorkeling, and Apnea, through activity-specific logbooks, sync, and iOS detail UI.

## Out of scope

- Bühlmann, GF, Full Computer, gas planner, CNS/OTU
- Snorkeling route planner logic (except logbook track attachment)
- Apnea recovery / medical logic
- Underwater entitlement, Watch auto-open
- Continuous underwater GPS (Diving, Apnea)
- Apnea runtime navigation / maps / waypoints
- Always Location, fake coordinates, safety-critical GPS claims

## Phases

### Phase 1 — Audit (complete)

- Dynamic search of GPS models, runtime, sync, logbook, UI
- Matrix in `WATCH_GPS_ACTIVITY_LOGBOOK_AUDIT_CURRENT.md`
- Gaps: Apnea runtime missing GPS; Snorkeling missing explicit start/end capture

### Phase 2 — Shared infrastructure

- `Services/WatchSurfaceLocationService.swift`
- `Shared/Utils/ActivityGPSLogbookPresentation.swift`
- When In Use only; wraps existing `GPSManager`; no fabricated coordinates

### Phase 3 — Activity runtimes

| Activity | Action |
|----------|--------|
| Diving | Confirm existing `DiveManager` entry/exit one-shot (no change to algorithm) |
| Snorkeling | Entry/exit surface capture in `SnorkelingWatchRuntimeStore`; track via engine ingest |
| Apnea | Wire `WatchSurfaceLocationService` in `ApneaWatchRuntimeStore`; capture at arm + save |

### Phase 4 — iOS logbook UI

- Snorkeling: GPS track counts card in session detail
- Apnea: Session location summary card
- Diving: existing GPS rows (status keys aligned)

### Phase 5 — Sync verification

- Confirm full-session transport in existing codecs (no schema change)
- Add encode/decode GPS field tests

### Phase 6 — Tests, localization, docs, QA

- Watch + iOS algorithm tests
- EN/IT localization keys
- Pipeline docs + implementation report
- QA evidence templates (default PENDING)

### Phase 7 — Build validation

- `xcodegen generate`
- iOS + Watch build
- iOS + Watch algorithm test schemes

## Acceptance mapping

See `WATCH_GPS_ACTIVITY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md` for final status.

## Physical QA

All `Docs/QA_EVIDENCE/WATCH_GPS_*` templates remain **PENDING** until executed on real Apple Watch + iPhone hardware.
