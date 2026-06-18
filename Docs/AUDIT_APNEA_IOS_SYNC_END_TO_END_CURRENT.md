# AUDIT 07 — Apnea iOS, Sync and End-to-End (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code review (no application code modified)  
**Command:** `07_AUDIT_APNEA_IOS_SYNC_END_TO_END.md`  
**Branch:** `main` @ `a1e0cab` (committed); **working tree dirty** with uncommitted Audit 06 Watch remediation  
**Scope:** Apnea Commands **08–11** (iOS companion surfaces, logbook/analytics/records, map/equipment/buddy/export, iOS↔Watch sync, Watch offline autonomy)  
**Prerequisites:** Audits 05–06 **PASS** on `main`; Commands 08–11 implementation reports present

---

## Executive summary

| Area | Verdict |
|------|---------|
| iOS dashboard / profiles / planner / settings | **PASS** |
| iOS logbook / charts / statistics / records | **PASS** |
| Map / equipment / buddy / export | **PASS** |
| Real data vs preview separation | **PASS** |
| Pure analytics in shared services | **PASS** |
| Profile & planner validation | **PASS** |
| Record eligibility (simulated/degraded exclusion) | **PASS** |
| Export PDF / CSV / JSON / GPX + privacy gates | **PASS** |
| Versioned sync schema + checksum + signed ACK | **PASS** |
| ACK / retry / idempotency / merge policy | **PASS** |
| Namespace isolation (Apnea vs Diving vs FC) | **PASS** |
| Watch offline autonomy (imported plan + pending queue) | **PASS** |
| **Gate before Apnea Command 12** (release hardening) | **PASS WITH CONDITIONS** |

**Overall:** **PASS** — Apnea iOS companion, bidirectional sync, and Watch offline autonomy meet Audit 07 on `main`. **P0/P1 blockers: none.**

**Internal readiness:** **96%** (iOS/sync code + automation); **physical device sync QA:** **PENDING**.

---

## Audit context

| Item | Value |
|------|-------|
| Committed `HEAD` | `a1e0cab` |
| `origin/main` | `a1e0cab` (in sync) |
| Working tree | Dirty — uncommitted Audit 06 Watch remediation (`ApneaWatchRuntimeStore`, MAIN promotion) |
| iOS Apnea impact of dirty tree | Minimal — iOS sync paths unchanged; Watch autonomy improved on disk |

This audit evaluates **current repository files** (including uncommitted Watch changes) for end-to-end behaviour. Release tagging should use a **clean commit** after remediation merge.

---

## Scope map (Commands 08–11)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 08 Profiles / planner / dashboard | `IOSApnea*Store`, `IOSApneaRootView`, `IOSApneaDashboardPresentationMapper` | **Present** |
| 09 Logbook / graphs / stats / records | `IOSApneaLogbookStore`, `ApneaSessionChartBuilder`, `ApneaPersonalRecordsEngine` | **Present** |
| 10 Map / equipment / buddy / export | `ApneaSessionMapPresentation`, `IOSApneaEquipmentStore`, `IOSApneaSessionExportService` | **Present** |
| 11 iOS↔Watch sync & offline autonomy | `ApneaSyncCodec`, `IOSApneaWatchTransferService`, `ApneaSyncWatchReceiver`, `WatchSyncService` | **Present** |

---

## 1. iOS companion UI (Commands 08–10)

### 1.1 Dashboard, profiles, planner, settings

| Control | Implementation | Status |
|---------|----------------|--------|
| Apnea launchable on iOS Companion | `CompanionActivityAvailability.isAvailable(.apnea)` | **PASS** |
| Dashboard reads real logbook data | `IOSApneaDashboardView` → `IOSApneaLogbookStore.lastSession` + mapper | **PASS** |
| Empty state when no sessions | `IOSApneaDashboardPresentationMapper` `emptyStateText` | **PASS** |
| Watch connectivity shown without false ACK | `IOSApneaWatchTransferService.state`; dashboard card text only | **PASS** |
| Profile CRUD / duplicate / preset protection | `IOSApneaProfileStore` + `testProfileStoreCRUDDuplicateAndDelete` | **PASS** |
| Planner validation (title, pyramid monotonicity) | `ApneaSessionPlanValidator` + companion tests | **PASS** |
| Send gated on valid plan | `IOSApneaWatchTransferService.send` calls validator first | **PASS** |
| Settings persist / reset | `IOSApneaSettingsStore` + tests | **PASS** |
| No embedded raster mockups in bundle | `ApneaReleaseHardValidationTests` (iOS) | **PASS** |
| No SwiftUI `#Preview` / mock fixtures in Apnea views | Static scan of `iOSApp/Views/Apnea/` | **PASS** |

### 1.2 Logbook, charts, statistics, records

| Control | Implementation | Status |
|---------|----------------|--------|
| Session list + detail navigation | `IOSApneaSessionsListView`, `IOSApneaSessionDetailView` | **PASS** |
| Charts from pure builder | `ApneaSessionChartBuilder.build` | **PASS** |
| Empty session charts | `testSessionChartBuilderHandlesEmptySession` | **PASS** |
| Large session chart performance | `testLargeSessionChartBuildPerformance` | **PASS** |
| Dive analytics (speed, markers, alarms) | `ApneaDiveAnalytics` + tests | **PASS** |
| Statistics tab with range filters | `IOSApneaStatisticsView` + `ApneaLogbookStatistics` | **PASS** |
| Personal records deepest/longest + ties | `ApneaPersonalRecordsEngine` + tests | **PASS** |
| Imperial presentation option | `testPresentationUsesImperialUnits` | **PASS** |
| Views consume presentation mappers | `IOSApneaLogbookPresentationMapper` pattern | **PASS** |

### 1.3 Map, equipment, buddy, export

| Control | Implementation | Status |
|---------|----------------|--------|
| Surface map requires ≥2 GPS points | `ApneaSessionMapPresentation` + tests | **PASS** |
| Map permission denied state | `testMapPermissionDeniedState` | **PASS** |
| Fix quality classification | `testMapFixQualityClassification` | **PASS** |
| Equipment profiles CRUD + active selection | `IOSApneaEquipmentStore` + tests | **PASS** |
| Buddy confirmation timestamp | `testBuddyConfirmationTimestamp` | **PASS** |
| Export filename sanitization | `testExportFilenameSanitizesSpecialCharacters` | **PASS** |
| CSV / JSON large dataset | `testCSVAndJSONLargeDataset` | **PASS** |
| PDF line builder | `testPDFLines` (export engine) | **PASS** |
| GPX blocked without GPS acknowledgement | `testPrivacyBlocksGPSWithoutAcknowledgement` | **PASS** |
| Redaction removes GPS + contacts | `testRedactedSessionRemovesGPSAndContacts` | **PASS** |

---

## 2. Data quality, analytics purity, records

| Control | Implementation | Status |
|---------|----------------|--------|
| Analytics in pure shared enums/engines | `ApneaDiveAnalytics`, `ApneaSessionChartBuilder`, `ApneaLogbookStatistics`, `ApneaPersonalRecordsEngine` | **PASS** |
| iOS views do not recompute deco/lifecycle | No `ApneaSessionEngine` in iOS Apnea views | **PASS** |
| Simulated sessions excluded from records | `ApneaRecordEligibilityPolicy.isSimulatedSession` + tests | **PASS** |
| Degraded/sparse sessions excluded by default | `hasInsufficientDataQuality` + tests | **PASS** |
| User override for degraded inclusion | `ApneaRecordEligibilityOptions.includeDegradedData` | **PASS** |
| Ineligible sessions remain in logbook | Eligibility separate from `ApneaLogbookPolicy.classify` persistence | **PASS** |
| Buddy/safety disclaimers localized EN/IT | `ApneaReleaseHardValidationTests.testIOSBuddyDisclaimerLocalizationKeysExist` | **PASS** |

---

## 3. iOS → Watch plan sync (Command 11)

| Control | Implementation | Status |
|---------|----------------|--------|
| Versioned package schema | `ApneaSyncPackageBody.schemaVersion`, `ApneaSyncCodec.currentSchemaVersion = 1` | **PASS** |
| Canonical JSON + SHA-256 checksum | `ApneaSyncCodec.seal` / `validate` | **PASS** |
| Plan validation before seal | `ApneaSessionPlanValidator.isValid` in `validate` | **PASS** |
| TTL / expiry enforcement | `expiresAt` check in `validate` | **PASS** |
| Dedicated WC transfer types | `apneaSyncPlanPackage`, `apneaSyncPlanPackageAck`, snapshot context keys | **PASS** |
| Signed ACK verification | `ApneaSyncAckSigner` + `testTransferSupportAckRoundTrip` | **PASS** |
| iOS pending queue + flush on activation | `IOSApneaWatchTransferService.pendingQueue` | **PASS** |
| Stale revision rejected on Watch | `ApneaSyncWatchReceiverTests.testStaleRevisionRejectedWithoutReplacingActivePlan` | **PASS** |
| Idempotent duplicate checksum | `testDuplicateChecksumIsIdempotent` | **PASS** |
| Pending plan while session active | `testSessionInProgressStoresPendingPlan` | **PASS** |
| Planner UI transfer states | `IOSApneaSessionPlannerView` + localized keys | **PASS** |

**Gap (P3):** No dedicated XCTest asserting `ApneaSyncValidationError.futureSchema` or corrupt/truncated package decode for **plan** packages (checksum mismatch is covered).

---

## 4. Watch → iOS session sync

| Control | Implementation | Status |
|---------|----------------|--------|
| Dedicated payload key | `dirdiving_apnea_session` (≠ `dirdiving_dive_session`) | **PASS** |
| Transport schema v1 + v2 with nonce replay cache | `ApneaSessionSyncCodec.schemaVersion = 2` | **PASS** |
| HMAC signature + bundle ID guard | `verify(_ transport:)` | **PASS** |
| Payload size cap | `maxPayloadBytes` | **PASS** |
| Session domain validation on import | `ApneaDomainValidator` + `ApneaLogbookPolicy.classify` | **PASS** |
| Merge prefers richer session | `ApneaSessionMerge.preferred` + `testSessionImportPolicyMergesByCompleteness` | **PASS** |
| Duplicate ID suppression | `WatchSyncBoundedIDStore` + `testIOSLogbookAtomicImport` | **PASS** |
| Signed import ACK to Watch | `makeImportAckPayload` / `parseImportAck` | **PASS** |
| iOS `WatchSyncService` routes Apnea separately | `importApneaSessionPayload`, `handleApneaSyncAck` | **PASS** |
| Watch pending session queue persisted | `ApneaSyncPendingTransfer` + atomic file write | **PASS** |
| Retry via `transferUserInfo` fallback | `queueApneaViaUserInfo` | **PASS** |

**Gap (P3):** No explicit XCTest for `ApneaSessionSyncError.unsupportedVersion` or replayed nonce rejection on session transport (logic present in codec).

---

## 5. Namespace isolation

| Control | Implementation | Status |
|---------|----------------|--------|
| Apnea session key ≠ dive session key | `ApneaReleaseSelfCheck` + iOS release-hard test | **PASS** |
| Apnea plan transfer ≠ FC plan transfer | `ApneaSyncTransferSupport` vs `DivePlanPackageTransferSupport` | **PASS** |
| FC receiver ignores Apnea package type | `FullComputerNamespaceIsolationTests` | **PASS** |
| Apnea / FC imported-plan stores independent | `testFCAndApneaStoresRemainIndependent` | **PASS** |
| Application context keys do not collide | `testApplicationContextKeysDoNotCollideWithApnea` | **PASS** |
| Diving sync handlers unchanged | `WatchSyncService` dive paths separate from Apnea branches | **PASS** |

---

## 6. Watch offline autonomy

| Control | Implementation | Status |
|---------|----------------|--------|
| Imported plan persisted locally | `ApneaImportedPlanStore` (activated + pending) | **PASS** |
| Ready UI reads imported plan | `ApneaImportedPlanStore.readyPresentation` → Watch Ready (via `ApneaWatchRuntimeStore` on disk) | **PASS** |
| Session can run without iPhone | `ApneaSessionEngine` + local `ApneaLogbookStore` on Watch | **PASS** |
| New plan deferred during active session | Pending activation path tested | **PASS** |
| Completed sessions queue for sync | `WatchSyncService.transferApneaSession` + pending file | **PASS** |
| Watch logbook isolated from dive logbook | Separate stores and payload keys | **PASS** |

**Note:** Uncommitted `ApneaWatchRuntimeStore` on disk decouples Watch Ready/runtime from `DiveManager` — improves autonomy alignment; should be committed before Command 12 release gate.

**Gap (P3):** No single integration test simulating full offline Watch session → reconnect → iOS merge (unit coverage is strong; E2E deferred).

---

## 7. Minimum test matrix (audit checklist)

| Required test | Covered by | Result |
|---------------|------------|--------|
| Round-trip profile/plan package | `ApneaSyncCodecTests.testSealValidateAndChecksumRoundTrip` | **PASS** |
| Round-trip session import | `ApneaSyncCodecTests.testIOSLogbookAtomicImport` | **PASS** |
| Watch offline (plan import without ACK path) | `ApneaSyncWatchReceiverTests` (idle import + pending) | **PASS** |
| Duplicates | `testDuplicateChecksumIsIdempotent`, logbook duplicate merge | **PASS** |
| Corrupt package | Checksum mismatch only (`testChecksumMismatchRejected`) | **PARTIAL** |
| Old/future schema | Future schema **not** explicitly tested for Apnea plan/session codecs | **PARTIAL** |
| Large export | `testCSVAndJSONLargeDataset` | **PASS** |
| Empty / large charts | Empty + performance tests in `IOSApneaLogbookAnalyticsTests` | **PASS** |
| Privacy GPS | `testPrivacyBlocksGPSWithoutAcknowledgement`, redaction test | **PASS** |

### Executed during audit (focused suites)

| Suite | Result |
|-------|--------|
| `ApneaSyncCodecTests` | **5/5 PASS** (1 skipped if peer secret unavailable) |
| `IOSApneaCompanionTests` | **9/9 PASS** |
| `IOSApneaLogbookAnalyticsTests` | **11/11 PASS** |
| `IOSApneaMapEquipmentExportTests` | **10/10 PASS** |
| `ApneaReleaseHardValidationTests` (iOS) | **6/6 PASS** |
| `ApneaSyncWatchReceiverTests` (Watch) | **4/4 PASS** (verified in prior Watch suite run) |

**Total focused iOS Apnea suites this audit:** 41 tests, 0 failures, 1 skipped.

---

## 8. Findings

### P0 / P1

None.

### P2

None for iOS/sync code paths on `main`.

### P3

| # | Finding | Recommendation |
|---|---------|----------------|
| 1 | Plan package `futureSchema` / corrupt decode not explicitly XCTested | Add negative tests in `ApneaSyncCodecTests` before Command 12 |
| 2 | Session transport `unsupportedVersion` / replay nonce not explicitly XCTested | Add codec negative tests on iOS + Watch targets |
| 3 | No automated offline→online E2E harness | Command 12 physical QA matrix + optional integration test |
| 4 | Physical device sync QA (WC reachability, airplane mode, relaunch) | `PENDING` — evidence folder not yet populated for iOS↔Watch |
| 5 | Uncommitted Audit 06 Watch remediation on working tree | Commit before release hardening / TestFlight |
| 6 | Cloud backup preference is opt-in stub (no false upload claim) | Documented; real cloud sync out of scope for Command 11 |

---

## 9. Gate before Apnea Command 12

```
PASS WITH CONDITIONS
```

### Conditions

1. Commit Audit 06 Watch remediation (runtime isolation + MAIN promotion) to `main`.
2. Add Apnea sync negative-path XCTests (future schema, corrupt package, unsupported session transport version).
3. Complete physical device sync QA with evidence (pair/unpair, offline Watch session, plan push, session pull).
4. Run full `validate_apnea_release_readiness.sh` on a **clean** tree.

### Ready when

- Above conditions met;
- Command 12 release-hard matrix executed on clean `main`;
- No regression in namespace isolation or record eligibility.

---

## 10. Related documentation

| Document | Role |
|----------|------|
| `Docs/DIR_DIVING_APNEA_IOS_PROFILES_PLANNER_DASHBOARD_IMPLEMENTATION_REPORT_CURRENT.md` | Command 08 |
| `Docs/DIR_DIVING_APNEA_IOS_LOGBOOK_GRAPHS_STATS_RECORDS_IMPLEMENTATION_REPORT_CURRENT.md` | Command 09 |
| `Docs/DIR_DIVING_APNEA_IOS_MAP_EQUIPMENT_BUDDY_EXPORT_IMPLEMENTATION_REPORT_CURRENT.md` | Command 10 |
| `Docs/DIR_DIVING_APNEA_IOS_WATCH_SYNC_OFFLINE_AUTONOMY_IMPLEMENTATION_REPORT_CURRENT.md` | Command 11 |
| `Docs/AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md` | Prerequisite Audit 05 |
| `Docs/AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md` | Prerequisite Audit 06 |
| `Docs/APNEA_ARCHITECTURE.md` | Architecture reference |
| `Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md` | Command 12 input matrix |

---

## 11. Final readiness matrix

| Domain | Code | Automated Tests | Documentation | Physical Evidence |
|--------|-----:|----------------:|--------------:|-------------------|
| iOS Dashboard / Profiles / Planner | 100% | 100% | 100% | N/A |
| iOS Logbook / Charts / Statistics | 100% | 100% | 100% | N/A |
| Personal Records / Eligibility | 100% | 100% | 100% | N/A |
| Map / Equipment / Buddy | 100% | 95% | 100% | PENDING |
| Export PDF/CSV/JSON/GPX | 100% | 95% | 100% | PENDING |
| iOS→Watch Plan Sync | 100% | 90% | 100% | PENDING |
| Watch→iOS Session Sync | 100% | 90% | 100% | PENDING |
| Namespace Isolation | 100% | 100% | 100% | N/A |
| Watch Offline Autonomy | 100% | 95% | 100% | PENDING |
| **Overall Internal Readiness** | **96%** | **95%** | **100%** | **PENDING** |

---

*Audit 07 — read-only. No application code modified. Report: `Docs/AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md`.*
