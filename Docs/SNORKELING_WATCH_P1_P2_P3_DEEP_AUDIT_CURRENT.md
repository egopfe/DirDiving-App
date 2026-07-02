# Snorkeling Watch P1/P2/P3 Deep Audit Current

**Date:** 2026-07-02  
**Repository:** egopfe/DirDiving-App  
**Baseline commit audited:** `1272885` (main)  
**Audit type:** Read-only deep implementation audit (no production code changes)

---

## Executive Summary

| Dimension | Verdict |
|-----------|---------|
| **Overall** | **INTERNAL_READY** · **MANUAL_UI_QA_PENDING** · **NOT PRODUCTION_READY** |
| **P1** | **P1_PARTIAL** — sync protocol complete; UX visibility and E2E gaps remain |
| **P2** | **P2_PARTIAL** — premium runtime largely shipped; primary-action flag and settings re-apply gaps |
| **P3** | **P3_PARTIAL** — advanced features coded and unit-tested; heatmap/adherence score out of scope; all QA PENDING |
| **Non-regression** | **PASS (automated)** — isolated namespaces/stores/codecs; no Diving/Apnea/FC contamination in Snorkeling paths |

**Highest risks:** (1) all 54+ QA evidence folders still **PENDING**; (2) no WatchConnectivity E2E tests; (3) iOS route pending queue not persisted across relaunch; (4) per-session sync source not shown in logbook detail; (5) `returnIsPrimaryAction` computed but unused in Watch UI.

**Blocking issues for release sign-off:** Manual QA evidence; full regression test suite not executed in this audit window.

---

## Scope

Snorkeling Watch P1 (iOS ↔ Watch integration), P2 (premium runtime + iOS config), P3 (advanced navigation + analytics). Regression against Diving, Full Computer, Gauge, Apnea.

---

## Files Inspected

### Watch Snorkeling (mandatory + P3)

- `Services/SnorkelingWatchRuntimeStore.swift` — presentation pipeline, battery, micro-map, route apply
- `Views/SnorkelingView.swift` — ready panel, navigation, return, markers, micro-map
- `Views/SnorkelingWatchMicroMapView.swift` — P3 Canvas preview
- `Utils/SnorkelingWatchPresentation.swift` — stage/output mapping
- `Utils/SnorkelingWatchReadyPresentationPolicy.swift` — ready route/battery/precheck
- `Utils/SnorkelingWatchRouteSummaryPresentationPolicy.swift` — P2 route summary
- `Utils/SnorkelingWatchReturnPrimaryActionPolicy.swift` — P2 return primary
- `Utils/SnorkelingWatchMicroMapPresentationPolicy.swift` — P3 micro-map
- `Shared/Utils/SnorkelingSessionEngine.swift` — lifecycle, waypoint events, runtime summary
- `Shared/Models/SnorkelingSession.swift`, `SnorkelingTrackPoint.swift`, `SnorkelingGPSQuality.swift`
- `Services/SnorkelingImportedRouteStore.swift`, `SnorkelingRouteWatchReceiver.swift`
- `Services/WatchSyncService.swift`, `SnorkelingSessionSyncCodec.swift`
- `Shared/Utils/SnorkelingRouteSyncCodec.swift`
- `Services/GPSManager.swift`, `CompassManager.swift`, `SnorkelingLogbookStore.swift`
- `Shared/Utils/SnorkelingNavigationEngine.swift`, `SnorkelingReturnAdvisor.swift`
- `Shared/Utils/SnorkelingSessionMapPresentation.swift`
- `Utils/SnorkelingReleaseSelfCheck.swift`

### iOS Snorkeling

- `iOSApp/Views/Snorkeling/` — dashboard, planner, sessions, detail, settings, export
- `iOSApp/Services/IOSSnorkelingLogbookStore.swift`, `IOSSnorkelingWatchTransferService.swift`
- `iOSApp/Services/IOSSnorkelingSessionPhotoStore.swift`
- `iOSApp/Utils/SnorkelingPlannedVsActualAnalytics.swift`, `SnorkelingTrackQualityAnalytics.swift`, `SnorkelingWaypointReachedReport.swift`
- `iOSApp/Services/SnorkelingTrackGPXExportService.swift`, `SnorkelingTrackKMLExportService.swift`

---

## Documents Inspected

| Document | Status |
|----------|--------|
| `Docs/SNORKELING_WATCH_P1_INTEGRATION_AUDIT_CURRENT.md` | Pre-remediation baseline (several items since fixed) |
| `Docs/SNORKELING_WATCH_P1_IMPLEMENTATION_REPORT_CURRENT.md` | Present |
| `Docs/SNORKELING_WATCH_P2_*` (audit, report, completeness) | Present |
| `Docs/SNORKELING_WATCH_P3_*` (audit, report, completeness) | Present |
| `Docs/SNORKELING_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md` | Present |
| `Docs/SNORKELING_IOS_WATCH_ARCHITECTURE.md` | Referenced |
| `Docs/WATCH_GPS_ACTIVITY_LOGBOOK_*` | Referenced |
| P1/P2/P3 QA evidence folders (54) | All **PENDING** |

Implementation command sources (`SNORKELING_WATCH_P1/P2/P3_*_AUDIT_IMPLEMENTATION.md`) were not found under `Docs/`; equivalent phase reports used instead.

---

## Tests Inspected

- **Watch:** 39 `Snorkeling*.swift` files under `Tests/WatchAlgorithmTests/`
- **iOS:** 50 `Snorkeling*.swift` + 11 `IOSSnorkeling*.swift` under `Tests/iOSAlgorithmTests/`
- See `Docs/SNORKELING_WATCH_P1_P2_P3_TEST_COVERAGE_MATRIX_CURRENT.csv`

---

## Build/Test Commands Run

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild … "DIRDiving Watch App" … generic/platform=watchOS Simulator build` | **BUILD SUCCEEDED** |
| `xcodebuild … "DIRDiving iOS" … generic/platform=iOS Simulator build` | **BUILD SUCCEEDED** |
| Full Watch + iOS algorithm test schemes | **FULL_SUITE_NOT_RUN** (exceeded audit window) |
| Targeted P1/P2/P3 smoke (ready route, battery, return primary, micro-map, route sync status, planned-vs-actual, GPX, operational settings) | **TEST SUCCEEDED** |

---

## P1 Audit

### Route sync iOS → Watch

| Check | Verdict | Evidence |
|-------|---------|----------|
| iOS route planner + package builder | **IMPLEMENTED** | `IOSSnorkelingRoutePlannerView`, `SnorkelingRoutePackageBuilder` |
| Encode/decode/checksum/revision | **IMPLEMENTED** | `SnorkelingRouteSyncCodec`, `SnorkelingRouteSyncPackage` |
| WC transfer + applicationContext | **IMPLEMENTED** | `IOSSnorkelingWatchTransferService.send`, `WatchSyncService` |
| Watch receiver + validation | **IMPLEMENTED** | `SnorkelingRouteWatchReceiver.importPayload` |
| Signed ACK | **IMPLEMENTED** | `SnorkelingRouteSyncAckSigner`, `deliverAck` |
| Stale revision rejection | **IMPLEMENTED** | `SnorkelingImportedRouteStore` → `staleRevisionRejected` |
| Pending during active session | **IMPLEMENTED** | `pendingPackage`, `activatePendingIfNeeded()` |
| iOS sync status UI | **IMPLEMENTED** | `SnorkelingRouteSyncStatusPresentationPolicy`, planner transfer section, dashboard card |
| Watch route status UI | **IMPLEMENTED** | `SnorkelingView.readyGrid` — route name, revision, pending banner |
| WC E2E test | **MISSING** | Unit/codec tests only |

**Gap:** iOS pending route queue is in-memory (`IOSSnorkelingWatchTransferService.pendingQueue`) — not persisted across iOS relaunch.

### Watch runtime → iOS logbook sync

| Check | Verdict | Evidence |
|-------|---------|----------|
| Watch session save | **IMPLEMENTED** | `SnorkelingLogbookStore.add` |
| Session transfer + pending queue | **IMPLEMENTED** | `WatchSyncService.transferSnorkelingSession`, `SnorkelingSyncPendingTransfer` |
| Codec + signed envelope | **IMPLEMENTED** | `SnorkelingSessionSyncCodec` |
| iOS merge + dedup | **IMPLEMENTED** | `IOSSnorkelingLogbookStore.mergeImportedSession`, `SnorkelingSessionSyncImportPolicy` |
| Tombstone sync | **IMPLEMENTED** | `ActivitySyncTombstoneBroadcast`, `applyRemoteDeletedSessionIDs` |
| Dashboard sync status | **IMPLEMENTED** | `SnorkelingWatchSyncStatusPresentationPolicy`, `IOSSnorkelingDashboardView.syncStatusCard` |
| Watch save/sync footer | **PARTIAL** | `sessionSaveState` in summary only — no dedicated sync panel |
| Per-session sync source in logbook | **MISSING** | `SnorkelingSession.startMode` not surfaced in detail/list UI |
| Sync failure prominence | **PARTIAL** | State exists; no persistent error banner on session detail |

### Ready panel integration

| Field | Verdict | Evidence |
|-------|---------|----------|
| Route name / revision / pending | **IMPLEMENTED** | `SnorkelingView.readyGrid`, `SnorkelingWatchReadyPresentationPolicy` |
| GPS / depth / entry | **IMPLEMENTED** | readyGrid cells + precheck |
| Duration/distance limits | **IMPLEMENTED** | `targetDurationText`, `maxDistanceText` |
| Buddy / mission | **IMPLEMENTED** | `buddyText`, `missionModeText` |
| Battery | **IMPLEMENTED** | `updateBattery()` → `batteryFraction` → `batteryPresentation` |
| Route summary (P2 overlap) | **IMPLEMENTED** | `routeCompactSummaryText` in ready panel |

**Note:** P1 pre-audit doc flagged battery as hardcoded nil — **remediated** in current code (`SnorkelingWatchRuntimeStore.updateBattery`, lines ~465–671).

### Battery integration

| Layer | Verdict |
|-------|---------|
| Read `WKInterfaceDevice.current().batteryLevel` | **IMPLEMENTED** |
| Pass to `SnorkelingWatchPresentationInput.batteryFraction` | **IMPLEMENTED** |
| Display in ready grid | **IMPLEMENTED** |
| Runtime store unit test | **WIRED_BUT_UNTESTED** — `SnorkelingWatchBatteryPresentationTests` injects fraction only |
| Physical QA | **DOCUMENTED_ONLY** — `SNORKELING_P1_WATCH_BATTERY_PRESENTATION` PENDING |

### iOS logbook display

| Feature | Verdict |
|---------|---------|
| Track map + segments/gaps | **IMPLEMENTED** |
| Track quality + GPS breakdown | **IMPLEMENTED** |
| Markers + categories + photos | **IMPLEMENTED** |
| Dips timeline | **IMPLEMENTED** |
| Runtime summary / off-route | **IMPLEMENTED** |
| Planned vs actual (P3) | **IMPLEMENTED** |
| Sync source per session | **MISSING** |
| Dashboard sync line | **IMPLEMENTED** (aggregate, not per-entry) |

### P1 verdict

**P1_PARTIAL** — Protocol and core UI are production-grade at code level. Remaining gaps: per-session sync labeling, pending queue persistence, WC E2E tests, manual QA evidence, sync failure UX on detail.

---

## P2 Audit

### Return to Entry primary action

| Check | Verdict |
|-------|---------|
| Policy exists | **IMPLEMENTED** — `SnorkelingWatchReturnPrimaryActionPolicy` |
| Full-width first button in action row | **IMPLEMENTED** — `SnorkelingView.actionRow` |
| Disabled when entry unavailable | **IMPLEMENTED** — policy + presentation |
| `returnIsPrimaryAction` flag in output | **WIRED_BUT_UNTESTED** — computed in `SnorkelingWatchPresentation.make`, **never read in `SnorkelingView`** |
| Haptic escalation | **PARTIAL** — return advisor haptics exist; no dedicated primary-action haptic test |
| iOS return threshold config | **IMPLEMENTED** — settings + route metadata sync |

**Classification:** UI prominence is layout-implicit (first button), not policy-driven styling.

### iOS runtime configuration

| Setting | Persisted | Sync to Watch | Engine apply | Tests |
|---------|-----------|---------------|--------------|-------|
| Max duration | Yes | Via route metadata | Yes | Yes |
| Max distance | Yes | Via route metadata | Yes | Yes |
| Off-route threshold | Yes | Via route metadata | Yes | Yes |
| GPS quality threshold | Yes | Via route metadata | Yes | Partial |
| Return alert policy | Yes | Via route metadata | Yes | Yes |
| Buddy reminder | Yes | Partial | Yes | Partial |
| Mission mode / haptics | Yes | N/A / local | Yes | Partial |
| Map type | Yes | N/A | N/A | Yes |

**Gap:** Changing iOS settings without re-sending route does not update an already-imported Watch session — **PARTIAL**.

### Route summary before start

**IMPLEMENTED** — `SnorkelingWatchRouteSummaryPresentationPolicy` → `routeCompactSummaryText` on ready panel; tests in `SnorkelingWatchRouteSummaryPresentationTests`.

**Gap:** No Watch UI contract test asserting ready-panel visibility (WIRED_BUT_UNTESTED).

### Marker premium UX

**IMPLEMENTED** — Watch save-marker panel (category, GPS quality, distance); engine persistence; iOS logbook rows with GPS/distance/photo; tests in marker/haptics suites.

### iOS premium logbook detail

**IMPLEMENTED** — `IOSSnorkelingSessionDetailView` with map, charts, markers, planned-vs-actual, waypoint report, track quality analytics, export entry points.

### P2 verdict

**P2_PARTIAL** — Feature-complete at policy/UI level; `returnIsPrimaryAction` unused, settings re-apply gap, UI contract tests missing, all QA PENDING.

---

## P3 Audit

### Micro-map Watch

**IMPLEMENTED** — Canvas `SnorkelingWatchMicroMapView` alongside `DiveBearingRing`; policy hides when underwater/GPS unavailable; 4 unit tests PASS.

### Planned vs actual analysis

**IMPLEMENTED** — `SnorkelingPlannedVsActualAnalyticsPolicy` + detail card; map overlay via `SnorkelingSessionMapPresentation.plannedRouteCoordinates`; 3 tests.

**Gap:** No composite deviation metric or adherence **score** (only progress % and max off-route).

### GPX/KML export

**IMPLEMENTED** (P2 scope) — `SnorkelingTrackGPXExportService`, `SnorkelingTrackKMLExportService`, E2E export tests; privacy gates for location export.

### Photo marker integration

**IMPLEMENTED (iOS-only)** — `photoReferenceID`, `IOSSnorkelingSessionPhotoStore`, logbook thumbnails; Watch camera capture **NOT_APPLICABLE** (deferred per policy).

### Advanced analytics

| Feature | Verdict |
|---------|---------|
| Track quality analytics | **IMPLEMENTED** |
| Waypoint reached report | **IMPLEMENTED** (conservative, events-only) |
| GPS quality analysis | **IMPLEMENTED** (track point breakdown) |
| Route adherence score | **MISSING** (partial metrics only) |
| Heatmap | **NOT_APPLICABLE** — forbidden in Snorkeling production (`SnorkelingReleaseSelfCheck` scans for `heatmap`; only in experimental/exploration views) |
| Dip distribution / charts | **IMPLEMENTED** — `SnorkelingSessionChartBuilder` |
| Warning timeline | **PARTIAL** — warnings on session model; no dedicated timeline UI |

### P3 verdict

**P3_PARTIAL** — Shipped scope implemented and tested; heatmap and adherence score intentionally absent; manual QA entirely PENDING.

---

## Regression Audit

| Area | Verdict | Evidence |
|------|---------|----------|
| Diving runtime | **NOT_APPLICABLE contamination** | `SnorkelingArchitectureIsolationTests` |
| Apnea / Full Computer | **NOT_APPLICABLE contamination** | Separate sync keys in `SnorkelingReleaseSelfCheck` |
| Unified logbook | **IMPLEMENTED isolation** | Activity-scoped presentation builders |
| WatchSyncService queue | **PARTIAL shared transport** — shared service, separate payload keys/types |
| GPS permission policy | **IMPLEMENTED** — Snorkeling-scoped first-launch policies |
| UserDefaults namespaces | **IMPLEMENTED** — separate keys per activity |
| Snorkeling in Diving settings | **MISSING (good)** | No cross-links found |

**Non-regression status:** **PASS (automated unit level)** · physical cross-activity QA **PENDING**.

---

## Security / Privacy Audit

- Photo attachments stored as local files with optional metadata strip — **IMPLEMENTED**
- Session JSON stores photo UUID refs only — **IMPLEMENTED**
- No Always Location added in P1–P3 — **CONFIRMED**
- Signed ACK for route/session sync — **IMPLEMENTED**
- Export requires location acknowledgement — **IMPLEMENTED**

---

## UX Audit

- Ready panel information density: **IMPLEMENTED** (may be crowded on small Watch — manual QA needed)
- Return primary visual hierarchy: **PARTIAL** (first button, no `returnIsPrimaryAction` styling)
- Sync errors: **PARTIAL** (planner/dashboard only)
- Micro-map + bearing ring coexistence: **IMPLEMENTED**

---

## Localization Audit

- Watch EN/IT parity for snorkeling keys — **IMPLEMENTED** (`SnorkelingLocalizationParityTests`)
- iOS P3 keys added EN/IT — **IMPLEMENTED**
- P3 micro-map keys — **IMPLEMENTED**

---

## Persistence Audit

- Watch checkpoint namespace `dirdiving_snorkeling_session` — **IMPLEMENTED**
- iOS logbook `dirdiving_ios_snorkeling_sessions.json` — **IMPLEMENTED**
- Route pending on iOS transfer service — **PARTIAL** (memory-only queue)

---

## Sync Audit

See P1 sections. No fake coordinates detected. Stale revision handling **IMPLEMENTED**.

---

## Test Coverage Audit

- P1-critical paths: codec + presentation tests **IMPLEMENTED**; WC E2E **MISSING**
- P2-critical paths: policy tests **IMPLEMENTED**; UI contracts **PARTIAL**
- P3-critical paths: 6 dedicated files, 19 tests **IMPLEMENTED**
- Full suite count: not executed in this audit

---

## Gaps (Consolidated)

1. All QA evidence folders PENDING (54 Snorkeling + 8 iOS Snorkeling map)
2. No WatchConnectivity integration tests
3. iOS route pending queue not persisted
4. Per-session sync source not in logbook UI
5. `returnIsPrimaryAction` unused in Watch UI
6. iOS settings change without route re-send
7. Route adherence score and heatmap not shipped (latter by design)
8. Full algorithm test suites not run in audit window

---

## Final Verdict

| Phase | Verdict | Ready for manual QA? |
|-------|---------|----------------------|
| P1 | **P1_PARTIAL** | Yes — with known UX gaps documented |
| P2 | **P2_PARTIAL** | Yes |
| P3 | **P3_PARTIAL** | Yes |
| Release | **NOT PRODUCTION_READY** | Requires QA evidence PASS |

**Do not claim PRODUCTION_READY** until QA folders contain device evidence.

---

*Audit performed read-only. No Swift, test, project.yml, or localization files were modified.*
