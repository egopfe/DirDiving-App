# AUDIT 11 — Snorkeling iOS, Maps, Sync and Export

**Date:** 2026-06-18 (audit) · **Remediation:** 2026-06-19  
**Auditor:** Independent automated + manual code review  
**Command:** `11_AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT.md`  
**Scope:** Snorkeling iOS Commands **08–11**  
**Baseline:** Commands 08–10 @ `3d17c93`; Command 11 @ `4984230`; remediation on working tree  
**Remediation report:** [`SNORKELING_IOS_MAPS_SYNC_EXPORT_REMEDIATION_REPORT_V1.0.md`](SNORKELING_IOS_MAPS_SYNC_EXPORT_REMEDIATION_REPORT_V1.0.md)

---

## Executive summary (post-remediation)

| Area | Verdict |
|------|---------|
| Command 08 — Dashboard, profiles, route planner, MapKit, route sync | **PASS** |
| Command 09 — Logbook, graphs, stats, records, session map | **PASS** |
| Command 10 — Photos, equipment, buddy, export, privacy | **PASS** |
| Command 11 — Watch→iOS session sync protocol | **PASS** |
| Release validation script (08–11) | **PASS** |
| Crypto transport tests (no XCTSkip) | **PASS** |
| **Gate before Snorkeling Command 12** | **UNCONDITIONAL GO** |

**Overall internal code readiness:** **100%** (physical QA excluded).

---

## Gate decision

```
SNORKELING_IOS_MAPS_SYNC_EXPORT_INTERNAL_GO
READY_FOR_SNORKELING_COMMAND_12
```

| Audience | Decision |
|----------|----------|
| **Proceed to Command 12** | **YES** (unconditional) |
| **TestFlight / App Store** | **NO-GO** until physical QA evidence PASS |

### Findings — all closed (remediation V1.0)

| ID | Status |
|----|--------|
| AUDIT11-SNK-001 | **CLOSED** — validation script extended |
| AUDIT11-SNK-002 | **CLOSED** — deterministic crypto fixture |
| AUDIT11-SNK-003 | **CLOSED** — interrupted transfer, ACK, duplicateIgnored, v1 tests |
| AUDIT11-SNK-004 | **CLOSED** — dashboard gap-aware map preview |
| AUDIT11-SNK-005 | **CLOSED** — release self-check 08–11 |
| AUDIT11-SNK-006 | **CLOSED** — EXIF GPS byte-level tests |

---

## Original audit record (2026-06-18)

The sections below document the pre-remediation state at ~88% internal readiness.

### Original gate (superseded)

```
SNORKELING_IOS_MAPS_SYNC_EXPORT_INTERNAL_GO
READY_FOR_SNORKELING_COMMAND_12_WITH_CONDITIONS
```

### Original conditions (all closed)

| ID | Condition | Priority |
|----|-----------|----------|
| AUDIT11-SNK-001 | Extend `Scripts/validate_snorkeling_release_readiness.sh` to run iOS Command 08–11 focused suites | **P0** |
| AUDIT11-SNK-002 | Ensure `SnorkelingSessionSyncTransportNegativeTests` execute in CI (not XCTSkip); mirror Apnea peer-secret test fixture | **P0** |
| AUDIT11-SNK-003 | Add tests: interrupted pending transfer, route ACK round-trip, `duplicateIgnored` import, legacy v1 transport | **P1** |
| AUDIT11-SNK-004 | Align dashboard map preview with gap-segmented presentation (or hide preview when gaps exist) | **P2** |
| AUDIT11-SNK-005 | Extend `SnorkelingReleaseSelfCheck` file checklist to iOS 08–11 surfaces | **P2** |
| AUDIT11-SNK-006 | Photo EXIF GPS strip assertion test (or document limitation) | **P3** |

---

## Audit controls (Commands 08–11)

### Mock success states — **PASS**

- Route transfer reaches `acknowledged` only after signed ACK verification (`IOSSnorkelingWatchTransferService.handleAck`, lines 99–120).
- Dashboard route line shows pending / failed / up-to-date from real `IOSSnorkelingWatchTransferService.state`, not hard-coded success (`IOSSnorkelingDashboardView`).
- Session import records `imported` / `merged` / `duplicateIgnored` / `failed` via `IOSSnorkelingSessionSyncService` — no unconditional success UI.
- Watch outbound session queue clears only on signed ACK (`Services/WatchSyncService.confirmSnorkelingSignedAck`).

### Heatmap / readiness / fatigue without backend — **PASS**

- No production snorkeling iOS views reference heatmap, readiness score, or fatigue models.
- Dashboard metrics derive from `IOSSnorkelingLogbookStore` and `SnorkelingLogbookAnalytics` only.
- Profiles expose limits, alarms, Mission Mode — not predictive wellness metrics.

### Maps with real coordinates — **PASS**

- Route planner uses `SnorkelingRoutePlanValidator` and `IOSSnorkelingLocationPermission` for permission states.
- Session detail map uses measured surface fixes only (`SnorkelingSessionMapPresentation.build`).
- Dashboard preview filters `point.gpsQuality.isMeasuredSurfaceFix` (`IOSSnorkelingDashboardPresentation.mapPreviewCoordinates`).

### Offline maps not declared if unimplemented — **PASS**

- Production route builder sets `offlineCacheReady: false` (`SnorkelingRoutePlannerDraft.buildRoutePlan`).
- `ExplorationCenterView` (mock offline badges) remains **excluded** from production snorkeling shell (`IOSSnorkelingRootView`).

### GPS gaps visible — **PARTIAL**

| Surface | Verdict | Evidence |
|---------|---------|----------|
| Session detail map | **PASS** | Segmented polylines, orange gap segments, gap count label (`IOSSnorkelingSessionMapView`, `SnorkelingSessionMapPresentation`, 30s threshold) |
| Dashboard map preview | **PARTIAL** | Single continuous `MapPolyline` over all surface points — no gap segmentation (`IOSSnorkelingDashboardView` map preview card) |
| Logbook analytics tests | **PASS** | `testMapPresentationSplitsGapsIntoSegments` |

### Export GPX / CSV / JSON / PDF — **PASS**

- All formats exposed in `IOSSnorkelingSessionExportView`; engines in `SnorkelingSessionExportEngine`.
- GPX requires measured surface track + location acknowledgement (`buildGPX`, `testPrivacyBlocksGPSWithoutAcknowledgement`, `testGPXExportWithoutFixReturnsNil`).
- PDF lines layout tested (`testPDFLinesLayoutContainsSessionMetrics`).
- Cloud backup toggle is preference-only with pending note — no fake upload.

### Coordinate redaction precision — **PASS**

- Three tiers: `removed` / `reduced` (3 decimal places) / `exact` (`SnorkelingExportPrivacyPolicy`).
- Buddy/emergency/group contact redaction (`testRedactedSessionRemovesGPSAndContacts`).
- Export blocked without acknowledgement when GPS present (`testPrivacyBlocksGPSWithoutAcknowledgement`).

### Sync versioned, idempotent, separated — **PASS** (tests **PARTIAL**)

| Mechanism | Evidence |
|-----------|----------|
| Versioning | Session sync transport v2 + legacy v1; future version rejected (`SnorkelingSessionSyncCodec.schemaVersion`) |
| HMAC + replay | Nonce replay cache on Watch and iOS codecs |
| Idempotency | `SnorkelingSessionSyncImportPolicy`, bounded `importedIDs`, `SnorkelingSessionMerge` |
| Namespace isolation | `dirdiving_snorkeling_session_sync` ≠ checkpoint `dirdiving_snorkeling_session` ≠ dive/apnea keys (`SnorkelingReleaseSelfCheck`, `SnorkelingCrossDomainIsolationTests`) |
| Route sync separation | `SnorkelingRouteSyncTransferSupport` distinct from session sync |
| ACK-gated retry | Watch pending queues persisted; flush on reconnect |

**Gaps:** no XCTest for legacy v1 transport import, interrupted transfer persistence, or iOS route `handleAck` round-trip.

---

## Feature inventory

| Command | Production surfaces | Shared engines / stores |
|---------|-------------------|-------------------------|
| 08 | `IOSSnorkelingDashboardView`, `IOSSnorkelingProfilesView`, `IOSSnorkelingRoutePlannerView`, `IOSSnorkelingRootView` | `SnorkelingRouteSyncCodec`, `IOSSnorkelingWatchTransferService`, `SnorkelingRoutePlanValidator` |
| 09 | `IOSSnorkelingSessionsListView`, `IOSSnorkelingSessionDetailView`, statistics/records views | `SnorkelingLogbookAnalytics`, `SnorkelingSessionChartBuilder`, `SnorkelingPersonalRecordsEngine`, `SnorkelingSessionMapPresentation` |
| 10 | `IOSSnorkelingSessionPhotosView`, equipment/buddy views, `IOSSnorkelingSessionExportView`, `IOSSnorkelingSettingsView` | `SnorkelingExportPrivacyPolicy`, `SnorkelingSessionExportEngine`, `SnorkelingEquipmentCatalog`, `SnorkelingBuddySafety` |
| 11 | Dashboard dual sync card (route + sessions), `WatchSyncService` import path | `SnorkelingSessionSyncCodec`, `SnorkelingSessionMerge`, `SnorkelingSyncPendingTransfer` |

---

## Minimal test matrix (audit spec)

| Required test | Status | Evidence |
|---------------|--------|----------|
| Empty route | **PASS** | `IOSSnorkelingRoutePlannerTests.testEmptyRouteRejected` |
| Invalid coordinates | **PASS** | `IOSSnorkelingRoutePlannerTests.testInvalidCoordinateRejected` |
| Reorder waypoints | **PASS** | `IOSSnorkelingRoutePlannerTests.testReorderWaypoints` |
| Map permissions | **PASS** | `testMapPermissionStatesExist`, `testMapPermissionDeniedState` |
| No GPS | **PARTIAL** | Watch: `SnorkelingDepthOnlyLifecycleTests`; iOS: `testMapPresentationRequiresAtLeastTwoMeasuredPoints` — no dedicated no-GPS session UI test |
| Large track | **PASS** | `testCSVAndJSONLargeDataset`, `testLargeSessionChartBuildPerformance` |
| Privacy scrub | **PASS** | `testRedactedSessionRemovesGPSAndContacts`, `testReducedPrecisionRoundsCoordinates` |
| Export | **PARTIAL** | Engine-level PDF/CSV/JSON/GPX; no full `IOSSnorkelingSessionExportService` E2E per format |
| Duplicate sync | **PARTIAL** | `testDuplicatePendingQueueReplacesBySessionID`; import tests `.merged` not `.duplicateIgnored` |
| Interrupted transfer | **FAIL** | Code in `WatchSyncService` pending queues; no XCTest |
| Schema old | **PARTIAL** | Session decode v0 in `SnorkelingDomainModelTests`; sync legacy v1 accepted in code, not XCTested |
| Schema future | **PARTIAL** | `testFutureSessionVersionIsRejected` (may XCTSkip without peer secret); session `testFutureSchemaVersionDecodesWithMigrationWarning` |

---

## Focused automated suites (Commands 08–11)

| Suite | Tests | In `project.yml` | In validate script |
|-------|------:|:----------------:|:------------------:|
| `IOSSnorkelingCompanionTests` | 5 | Yes | **No** |
| `IOSSnorkelingRoutePlannerTests` | 6 | Yes | **No** |
| `SnorkelingRouteSyncCodecTests` | 4 | Yes | **No** |
| `IOSSnorkelingLogbookAnalyticsTests` | 12 | Yes | **No** |
| `IOSSnorkelingMapEquipmentExportTests` | 11 | Yes | **No** |
| `SnorkelingSessionSyncCodecTests` | 2 | Yes | **No** |
| `SnorkelingSessionSyncTransportNegativeTests` | 5 | Yes | **No** |
| `SnorkelingSessionSyncTransportNegativeWatchTests` | 2 | Watch folder | **No** |
| `SnorkelingCrossDomainIsolationTests` | 6 | Watch folder | Yes |
| **iOS focused subtotal** | **45** | | |
| **Command 11 sync subtotal** | **9** | | |

**Build verified (audit session):** DIRDiving iOS — BUILD SUCCEEDED.  
**Tests verified (audit session):** 10 PASS Command 11 suites + 6 isolation; 5 transport negative tests may XCTSkip when peer keychain unavailable.

---

## Findings register

| ID | Severity | Status | Summary |
|----|----------|--------|---------|
| AUDIT11-SNK-001 | **High** | **OPEN** | `validate_snorkeling_release_readiness.sh` runs Watch 04–07 suites only — no iOS 08–11 gate |
| AUDIT11-SNK-002 | **High** | **OPEN** | Crypto session transport tests XCTSkip without peer secret in simulator keychain |
| AUDIT11-SNK-003 | **Medium** | **OPEN** | Missing interrupted transfer, route ACK, legacy v1 transport, `duplicateIgnored` tests |
| AUDIT11-SNK-004 | **Low** | **OPEN** | Dashboard map preview does not segment GPS gaps (session detail does) |
| AUDIT11-SNK-005 | **Low** | **OPEN** | `SnorkelingReleaseSelfCheck` still scoped to Commands 04–07 |
| AUDIT11-SNK-006 | **Low** | **OPEN** | Photo strip-location re-encode without byte-level EXIF assertion |
| AUDIT11-SNK-007 | **Info** | **ACCEPTED** | Duplicate Watch/iOS `SnorkelingSessionSyncCodec` (mirrors Apnea pattern) |
| AUDIT11-SNK-008 | **Info** | **ACCEPTED** | Physical VoiceOver / wet-glove / device sync QA pending (same as Audit 10) |

---

## Rules preserved (audit confirmation)

- No second snorkeling runtime on iOS; Watch engine authoritative during session.
- No fake sync success; ACK-gated transfers for route and session.
- No underwater GPS interpolation as export truth; GPX uses measured surface fixes.
- Cross-domain WatchConnectivity isolation maintained.
- `ExplorationCenterView` excluded from production snorkeling companion.

---

## References

- [`DIR_DIVING_SNORKELING_IOS_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS_IMPLEMENTATION_REPORT_CURRENT.md)
- [`DIR_DIVING_SNORKELING_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md)
- [`DIR_DIVING_SNORKELING_IOS_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_PHOTOS_GEAR_BUDDY_EXPORT_PRIVACY_IMPLEMENTATION_REPORT_CURRENT.md)
- [`DIR_DIVING_SNORKELING_IOS_WATCH_SYNC_PROTOCOL_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_IOS_WATCH_SYNC_PROTOCOL_IMPLEMENTATION_REPORT_CURRENT.md)
- [`AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md`](AUDIT_SNORKELING_NAV_UI_PERSISTENCE_CURRENT.md) (prior Watch 04–07 gate)

---

## Gate (authoritative)

```
SNORKELING_IOS_MAPS_SYNC_EXPORT_INTERNAL_GO
READY_FOR_SNORKELING_COMMAND_12_WITH_CONDITIONS
```

Close **AUDIT11-SNK-001** and **AUDIT11-SNK-002** before treating Command 12 as release-hard or removing `_WITH_CONDITIONS`.
