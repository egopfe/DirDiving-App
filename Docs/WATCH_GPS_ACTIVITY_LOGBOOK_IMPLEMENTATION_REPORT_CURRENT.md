# Watch GPS → Activity Logbook — Implementation Report (Current)

**Branch:** `main` (local, uncommitted)  
**Baseline commit:** `f8457d7` — *Wire Apnea checklist, session check, and readiness into iOS and Watch UI*  
**Date:** 2026-07-01  

## Final verdict (no physical Watch QA)

| Verdict | Status |
|---------|--------|
| `INTERNAL_READY` | ✅ |
| `PHYSICAL_QA_PENDING` | ✅ (all QA templates PENDING) |
| `WATCH_GPS_ACTIVITY_LOGBOOK_PIPELINE_READY` | ✅ |
| `DIVING_SURFACE_GPS_READY` | ✅ (pre-existing runtime confirmed) |
| `SNORKELING_TRACK_GPS_READY` | ✅ |
| `APNEA_SURFACE_GPS_READY` | ✅ |
| `NO_CROSS_ACTIVITY_CONTAMINATION` | ✅ |
| `NO_FAKE_COORDINATES` | ✅ |
| `NO_LOCATION_POLICY_REGRESSION` | ✅ |
| `NO_SAFETY_CLAIMS` | ✅ |

**Not declared:** `PHYSICAL_QA_PASS`

---

## Audit findings (summary)

See `WATCH_GPS_ACTIVITY_LOGBOOK_AUDIT_CURRENT.md`.

| Activity | Pre-fix | Post-fix |
|----------|---------|----------|
| Diving | CONFIRMED | CONFIRMED |
| Snorkeling | PARTIAL | CONFIRMED (entry/exit one-shot added) |
| Apnea | MISSING | REMEDIATED |

---

## Implementation

### Shared infrastructure

- `Shared/Utils/ActivityGPSQuality.swift` — shared GPS quality types
- `Utils/WatchSurfaceLocationBridge.swift` — Watch-only bridge/evaluator over `GPSManager`
- `Services/WatchSurfaceLocationService.swift` — When In Use wrapper; no fabricated coordinates
- `Shared/Utils/ActivityGPSLogbookPresentation.swift` — UI helpers + logbook policy checks

### Diving

- **No runtime change** — existing `DiveManager` + `GPSManager` entry/exit one-shot confirmed
- Sync via `WatchDiveSyncCodec` (full session)
- iOS detail already shows GPS; shared status keys added

### Snorkeling

- `SnorkelingWatchRuntimeStore` — `captureEntrySurfaceFix` / `captureExitSurfaceFix` at start/end
- Track ingest unchanged; underwater samples remain non-measured
- iOS `IOSSnorkelingSessionDetailView` — GPS track counts card

### Apnea

- `ApneaWatchRuntimeStore` — GPS attachment, start/end surface capture, `.gpsUnavailable` on save when empty
- `ApneaSessionEngine.appendSurfaceGPSPoint(_:)`
- `ApneaView` — attaches `GPSManager` to runtime
- iOS `IOSApneaSessionDetailView` — session location summary card
- **No** runtime navigation/map/bearing added

---

## Sync verification

Existing codecs transport full sessions unchanged:

- `WatchDiveSyncCodec` → `entryGPS` / `exitGPS`
- `SnorkelingSessionSyncCodec` → `trackPoints` / `entryPoint`
- `ApneaSessionSyncCodec` → `surfaceGPSPoints` / warnings

New encode/decode tests added (iOS + Watch).

---

## Tests added

| File | Scope |
|------|-------|
| `Tests/WatchAlgorithmTests/WatchSurfaceLocationServiceTests.swift` | Quality + bridge |
| `Tests/WatchAlgorithmTests/DivingWatchGPSCaptureTests.swift` | Diving GPS + merge |
| `Tests/WatchAlgorithmTests/SnorkelingWatchGPSCaptureTests.swift` | Track ingest |
| `Tests/WatchAlgorithmTests/ApneaWatchGPSCaptureTests.swift` | Surface metadata + warning |
| `Tests/iOSAlgorithmTests/DiveSessionGPSSyncTests.swift` | Dive sync round-trip |
| `Tests/iOSAlgorithmTests/SnorkelingSessionGPSSyncTests.swift` | Snorkel sync round-trip |
| `Tests/iOSAlgorithmTests/ApneaSessionGPSSyncTests.swift` | Apnea sync round-trip |
| `Tests/iOSAlgorithmTests/ActivityGPSLogbookPolicyTests.swift` | Cross-activity isolation |

---

## Build & test results

| Step | Result |
|------|--------|
| `xcodegen generate` | ✅ |
| iOS build (`DIRDiving iOS`) | ✅ |
| Watch build (`DIRDiving Watch App`) | ✅ |
| iOS Algorithm Tests (iPhone 17 sim) | ✅ |
| Watch Algorithm Tests (Apple Watch Series 11 46mm) | ✅ (full suite) |
| `./Scripts/check_secrets.sh` | ✅ |
| `./Scripts/audit_localization.sh` | ✅ PASS |
| `./Scripts/check_main_target_isolation.sh` | ✅ |
| `./Scripts/validate_snorkeling_release_readiness.sh` | ⚠️ pre-existing catalog drift (unrelated snorkel QA folders) |

---

## Localization

EN/IT keys added: `gps.*`, `diving.logbook.gps.title`, `snorkeling.logbook.gps.title`, `apnea.logbook.gps.*`

---

## Documentation created

- `Docs/WATCH_GPS_ACTIVITY_LOGBOOK_AUDIT_CURRENT.md`
- `Docs/WATCH_GPS_ACTIVITY_LOGBOOK_IMPLEMENTATION_PLAN.md`
- `Docs/DIVING_WATCH_GPS_LOGBOOK_PIPELINE.md`
- `Docs/SNORKELING_WATCH_GPS_LOGBOOK_PIPELINE.md`
- `Docs/APNEA_WATCH_GPS_LOGBOOK_PIPELINE.md`
- `Docs/WATCH_GPS_ACTIVITY_LOGBOOK_IMPLEMENTATION_REPORT_CURRENT.md` (this file)

## QA templates created (all PENDING)

- `Docs/QA_EVIDENCE/WATCH_GPS_DIVING_ENTRY_FIX/`
- `Docs/QA_EVIDENCE/WATCH_GPS_DIVING_EXIT_FIX/`
- `Docs/QA_EVIDENCE/WATCH_GPS_SNORKELING_ENTRY_POINT/`
- `Docs/QA_EVIDENCE/WATCH_GPS_SNORKELING_TRACK_POINTS/`
- `Docs/QA_EVIDENCE/WATCH_GPS_SNORKELING_EXIT_POINT/`
- `Docs/QA_EVIDENCE/WATCH_GPS_APNEA_START_SURFACE_FIX/`
- `Docs/QA_EVIDENCE/WATCH_GPS_APNEA_END_SURFACE_FIX/`
- `Docs/QA_EVIDENCE/WATCH_GPS_SYNC_TO_IOS_LOGBOOKS/`
- `Docs/QA_EVIDENCE/WATCH_GPS_NO_CROSS_ACTIVITY_CONTAMINATION/`
- `Docs/QA_EVIDENCE/WATCH_GPS_NO_FAKE_COORDINATES/`

---

## Files changed (summary)

**New:** `WatchSurfaceLocationService.swift`, `WatchSurfaceLocationBridge.swift`, `ActivityGPSQuality.swift`, `ActivityGPSLogbookPresentation.swift`, 8 test files, 6 docs, 10 QA templates  

**Modified:** `ApneaWatchRuntimeStore.swift`, `SnorkelingWatchRuntimeStore.swift`, `ApneaSessionEngine.swift`, `ApneaView.swift`, iOS detail views, localization, `project.yml`

---

## Known limitations

- Apnea start GPS capture is async; end save uses synchronous `lastKnownSurfaceFix` when needed
- Snorkeling tracks may be sparse indoors / poor sky view
- Diving entry/exit may be stale fallback; UI marks quality
- Physical Apple Watch GPS accuracy not validated in this report

---

## Physical QA status

**PENDING** — requires real Apple Watch + iPhone field sessions per `Docs/QA_EVIDENCE/WATCH_GPS_*` templates.
