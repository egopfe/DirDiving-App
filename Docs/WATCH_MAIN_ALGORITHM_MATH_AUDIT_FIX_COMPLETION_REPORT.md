# Apple Watch MAIN Algorithm Math Audit — Fix Completion Report

**Date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch:** `main`  
**Audit source:** [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md)  
**Pre-remediation baseline:** `4b73954`  
**Target:** `DIRDiving Watch App` only  
**Validation:** macOS — Apple Watch Ultra 3 (49mm) simulator

---

## Executive verdict

**READY FOR INTERNAL TESTFLIGHT**

Watch MAIN P1/P2/P3 audit items are resolved or explicitly documented with safe bounded policy. Automated Watch Algorithm Tests pass (161 executed, 8 skipped, 0 failures). Physical Ultra QA (depth entitlement, underwater haptics, paired sync smoke) remains required before external TestFlight.

---

## P1 fixes completed

| ID | Issue | Resolution |
|---|---|---|
| WATCH-P1-001 | Pending sync may not dequeue after `transferUserInfo` | `WatchSyncPendingTransfer` metadata queue; dequeue **only** on verified signed ACK via `confirmSignedAck`; `transferUserInfo` marks delivery but never dequeues; bounded retention (7 days) and attempt budget (64); tombstone prevents re-send |
| WATCH-P1-002 | Mock depth fallback invisible | Localized EN/IT unavailable/simulation copy; `DepthSensorSourceResolution` labels; Settings/Info surface resolved source |
| WATCH-P1-003 | TestFlight simulation policy | Release sanitizes `.simulation` → `.automatic`; TestFlight QA doc; simulation copy visible when active |
| WATCH-P1-004 | Ascent haptic coordinator untested | `AscentSafetyHapticCoordinatorTests` (4 cases) |

### Sync pending queue policy (WATCH-P1-001)

1. Completed session enqueued as `WatchSyncPendingTransfer` with attempt/delivery metadata.
2. Reachable iPhone: `sendMessage` + signed ACK → `confirmSignedAck` dequeues exactly once.
3. Unreachable iPhone: `transferUserInfo` fallback; **does not dequeue** on delivery alone.
4. Duplicate userInfo delivery: session ID + companion-side codec idempotency; Watch retains until signed ACK.
5. Invalid/missing ACK: session stays queued; diagnostic status updated.
6. Peer secret mismatch: no dequeue; flush blocked until trust restored.
7. Retention: entries older than 7 days or exceeding 64 attempts log warning; not silently dropped without diagnostic.
8. Tombstoned/imported-from-companion sessions are not re-enqueued.

**Remaining limitation:** `transferUserInfo` cannot provide inline signed ACK in WC architecture; companion must ACK via `sendMessage` when reachable. Watch queue is safe and bounded until ACK arrives.

---

## P2 fixes completed

| ID | Issue | Resolution |
|---|---|---|
| WATCH-P2-001 | Silent persistence failures | `DiveLogStore.lastPersistenceError`; `save()` returns Bool; `DiveManager.lastDraftPersistenceError`; diagnostic logging |
| WATCH-P2-002 | Draft restore avg-depth tail | `draftRestoreAverageDepthMaxTailSeconds = 30`; restore caps offline tail |
| WATCH-P2-003 | Auto dive end integration | `DiveManagerAlgorithmIntegrationTests.testAutomaticSurfaceEndFinalizesDiveOnce`; lifecycle unit test for surface-rise cancel |
| WATCH-P2-004 | WatchSyncService integration tests | `WatchSyncServiceIntegrationTests` + `WatchSyncPendingQueueTests` |
| WATCH-P2-005 | App Intent legal gate E2E | `ActionButtonSafetyGate` adapter + `ActionButtonIntentsSafetyTests` |
| WATCH-P2-006 | HapticService throttle untested | `HapticServiceTests` with test hooks |
| WATCH-P2-007 | Companion photo WC trust | Option B: paired-device trust documented in `CompanionPhotoManagementSupport`; path validation + existing tests |
| WATCH-P2-008 | importedFromCompanionIDs order | Lexicographic UUID sort in `WatchDiveSyncCodec` |
| WATCH-P2-009 | GPSLifecycleTests placeholder | Real GPS lifecycle tests in `GPSLifecycleTests` |

---

## P3 items — fixed, tested, or documented

| ID | Item | Status |
|---|---|---|
| WATCH-P3-001 | 40 m safety vs ascent band split | Documented + `testAscentLimitAt40mRemainsTenAndAbove40UsesFallback` |
| WATCH-P3-002 | Double `classify()` in `DiveLogStore.add` | **Fixed** — duplicate removed |
| WATCH-P3-003 | Expired draft discard | **Fixed** — quarantine + diagnostic on expired active draft |
| WATCH-P3-004 | Temperature finite bounds | Existing validation in `DepthSampleValidation`; tests cover outliers |
| WATCH-P3-005 | DeveloperVersionUnlock DEBUG-only | Documented manual DEBUG QA in sensor policy docs |
| WATCH-P3-006 | TTV naming | Unchanged semantics; informational index only (not NDL/TTS/deco) |
| WATCH-P3-007 | DepthSafetySelfCheck not in CI | **Fixed** — `testDepthSafetySelfCheckHasNoMappingFailures` in CI suite |
| WATCH-P3-008 | CSV header-only direct call | Documented in `WATCH_CSV_EXPORT_POLICY.md` |

---

## P4 physical QA (not automated)

See [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md) and [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md).

---

## Files modified

| File |
|---|
| `Resources/en.lproj/Localizable.strings` |
| `Resources/it.lproj/Localizable.strings` |
| `Services/ActionButtonIntents.swift` |
| `Services/DiveLogStore.swift` |
| `Services/DiveManager.swift` |
| `Services/HapticService.swift` |
| `Services/WatchDiveSyncCodec.swift` |
| `Services/WatchSyncService.swift` |
| `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift` |
| `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift` |
| `Tests/WatchAlgorithmTests/GPSLifecycleTests.swift` |
| `Utils/CompanionPhotoManagementSupport.swift` |
| `Utils/DepthSensorSourceResolution.swift` |
| `Utils/DiveAlgorithmConfiguration.swift` |
| `Utils/DiveLifecycleAlgorithm.swift` |
| `Utils/LegalAcceptanceGate.swift` |
| `project.yml` |

## Files created

| File |
|---|
| `Services/WatchSyncPendingTransfer.swift` |
| `Tests/WatchAlgorithmTests/ActionButtonIntentsSafetyTests.swift` |
| `Tests/WatchAlgorithmTests/AscentSafetyHapticCoordinatorTests.swift` |
| `Tests/WatchAlgorithmTests/DiveLogStoreTests.swift` |
| `Tests/WatchAlgorithmTests/HapticServiceTests.swift` |
| `Tests/WatchAlgorithmTests/WatchSyncPendingQueueTests.swift` |
| `Tests/WatchAlgorithmTests/WatchSyncServiceIntegrationTests.swift` |
| `Docs/WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md` |
| `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md` (this file) |

## Tests added/updated

**New test files (7):** ActionButtonIntentsSafetyTests, AscentSafetyHapticCoordinatorTests, DiveLogStoreTests, HapticServiceTests, WatchSyncPendingQueueTests, WatchSyncServiceIntegrationTests, plus WatchSyncPendingTransfer support.

**Updated:** DiveAlgorithmTests (+ depth safety self-check, 40 m band, draft tail cap, surface candidate clear), DiveManagerAlgorithmIntegrationTests (+ auto surface end), GPSLifecycleTests (placeholder replaced).

**Suite result:** 161 executed, 8 skipped (keychain peer-secret integration), **0 failures**.

---

## Docs updated

| Document | Change |
|---|---|
| `WATCH_MAIN_ALGORITHM_MATH_AUDIT_FIX_COMPLETION_REPORT.md` | Created (this report) |
| `WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Updated with P1–P3 audit IDs |
| `WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Updated baseline + test counts |
| `WATCH_SENSOR_SOURCE_RELEASE_POLICY.md` | Expanded simulation/release policy |
| `WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md` | Created |
| `WATCH_IOS_SYNC_QA_MATRIX.md` | Pending queue + ACK scenarios |
| `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` | Post-remediation gate notes |
| `WATCH_GPS_LIFECYCLE_POLICY.md` | Test coverage reference |
| `WATCH_CSV_EXPORT_POLICY.md` | P3 CSV call-path note |
| `WATCH_MANUAL_NODEPTH_SYNC_POLICY.md` | Sync queue cross-reference |
| `MISSION_MODE_MAIN_WATCH.md` | Invariants unchanged confirmation |

---

## Build / test results

```
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
→ BUILD SUCCEEDED

xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
→ TEST SUCCEEDED — 161 executed, 8 skipped, 0 failures
```

Simulator: **Apple Watch Ultra 3 (49mm)**

---

## Scope confirmations

| Constraint | Status |
|---|---|
| iOS Companion planner / Bühlmann / CNS / OTU / gas planning | **Not modified** |
| Experimental Watch files | **Not modified** |
| TTV semantic change | **None** — informational live index only |
| Mission Mode business logic | **None** — UI/runtime profile only |
| Decompression / Bühlmann math | **Not touched** |
| Legal / safety disclaimers | **Preserved or strengthened** |
| BUSSOLA terminology | **Preserved** (no COMPASSO) |
| UI redesign | **None** — copy/diagnostics only |

---

## Remaining limitations / blockers

1. **Physical QA required:** Ultra submersion depth entitlement, underwater ascent/depth-limit haptics, paired Watch↔iPhone sync smoke (see QA matrices).
2. **Peer-secret integration tests:** 8 tests skip when keychain peer secret unavailable in simulator CI; policy logic covered by unit tests.
3. **transferUserInfo ACK:** No inline signed ACK; companion must ACK when reachable; queue bounded until then.
4. **Companion photo delete:** Paired-device WC trust model (Option B); not HMAC-signed to preserve iOS compatibility.

---

## Readiness ladder

| Gate | Status |
|---|---|
| Compile / simulator tests | **Pass** |
| Internal TestFlight | **Ready** (with documented physical smoke) |
| External TestFlight | **Blocked on physical QA matrices** |
| App Store | **Blocked on external TestFlight + full physical checklist** |
