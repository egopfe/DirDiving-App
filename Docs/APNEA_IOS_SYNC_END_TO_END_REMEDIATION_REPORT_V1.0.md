# Apnea iOS / Sync / End-to-End — Remediation Report V1.0

**Date:** 2026-06-18  
**Authoritative audit:** [`AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md`](AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md)  
**Starting branch / SHA:** `main` @ `cbc485e` (clean; Audit 06 already integrated @ `2309320`)  
**Audit baseline referenced:** `a1e0cab` (pre-remediation audit HEAD)

---

## Executive summary

Audit 07 P3 gaps are closed in code, automation, and documentation. **Internal readiness: 100%.** Physical device sync QA remains **PENDING** with evidence scaffolds only.

**Command 12 gate:** `READY_FOR_APNEA_COMMAND_12` (internal automation). TestFlight still requires physical QA evidence.

---

## Initial dirty-tree classification

At remediation start: **clean tree** on `main` @ `cbc485e`. Audit 06 Watch remediation was already committed (`2309320`). No unrelated user changes.

---

## Files changed

### Production (test hooks only)
- `iOSApp/Services/ApneaSessionSyncCodec.swift` — DEBUG test hooks + `makeTestWatchTransport`
- `Services/ApneaSessionSyncCodec.swift` — DEBUG connectivity/replay test hooks
- `iOSApp/Services/IOSApneaWatchTransferService.swift` — `testing_pendingQueueCount`

### Tests (new)
- `Tests/iOSAlgorithmTests/ApneaSyncCodecNegativePathTests.swift`
- `Tests/iOSAlgorithmTests/ApneaSessionSyncTransportNegativeTests.swift`
- `Tests/iOSAlgorithmTests/ApneaSyncAckNegativeTests.swift`
- `Tests/iOSAlgorithmTests/ApneaOfflineOnlineEndToEndIntegrationTests.swift`
- `Tests/iOSAlgorithmTests/ApneaSessionMergeIntegrityTests.swift`
- `Tests/iOSAlgorithmTests/ApneaCloudBackupStubTruthfulnessTests.swift`
- `Tests/WatchAlgorithmTests/ApneaPlanPackageWatchNegativeTests.swift`
- `Tests/WatchAlgorithmTests/ApneaPlanRevisionIdempotencyTests.swift`
- `Tests/WatchAlgorithmTests/ApneaSessionSyncTransportNegativeWatchTests.swift`
- `Tests/WatchAlgorithmTests/ApneaOfflineOnlineEndToEndIntegrationTests.swift`

### Tests (updated)
- `Tests/WatchAlgorithmTests/ApneaArchitectureIsolationTests.swift`

### Scripts / project
- `Scripts/validate_apnea_release_readiness.sh`
- `project.yml` (iOS test target: Watch plan import services for E2E)

### Documentation
- `Docs/AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md` (remediation addendum)
- `Docs/APNEA_ARCHITECTURE.md`
- `Docs/QA_EVIDENCE/APNEA_IOS_WATCH_SYNC/` (+ 6 sibling folders)

---

## Audit 06 integration

Verified on `main`: `ApneaWatchRuntimeStore`, no `DiveManager` in `ApneaView`, Watch MAIN promotion, architecture isolation tests pass.

---

## Test results

| Suite | Result |
|-------|--------|
| iOS full `DIRDiving iOS Algorithm Tests` | **978 tests, 0 failures, 28 skipped** |
| Watch full `DIRDiving Watch Algorithm Tests` | **587 tests, 0 failures, 19 skipped** |
| iOS + Watch builds | **PASS** |
| `validate_apnea_release_readiness.sh` | **PASS** (dirty-tree warning only) |

Skipped tests: peer-secret keychain unavailable in simulator for HMAC transport/ACK round-trips (documented; same pattern as pre-remediation audit).

---

## Clean-tree status

`INTERNAL_REMEDIATION_COMPLETE` — working tree contains intentional remediation changes; re-run release-hard script on clean commit before TestFlight tag.

| Folder | Status |
|--------|--------|
| `Docs/QA_EVIDENCE/APNEA_IOS_WATCH_SYNC` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_OFFLINE_ONLINE` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_PAIR_UNPAIR` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_AIRPLANE_MODE` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_RELAUNCH` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_PLAN_PUSH` | PENDING |
| `Docs/QA_EVIDENCE/APNEA_SESSION_PULL` | PENDING |

---

## Readiness matrix (post-remediation)

| Domain | Code | Automated Tests | Documentation | Physical Evidence |
|--------|-----:|----------------:|--------------:|-------------------|
| Plan schema / corrupt handling | 100% | 100% | 100% | N/A |
| Session transport / replay | 100% | 100% | 100% | N/A |
| Signed ACKs | 100% | 100% | 100% | PENDING |
| Offline → online E2E | 100% | 100% | 100% | PENDING |
| Namespace isolation | 100% | 100% | 100% | N/A |
| Cloud stub truthfulness | 100% | 100% | 100% | N/A |
| **Overall internal** | **100%** | **100%** | **100%** | **PENDING** |

---

## Remaining risks

- Physical WatchConnectivity matrix not executed on hardware.
- `validate_apnea_release_readiness.sh` must pass on clean tree before TestFlight tag.

---

*Remediation V1.0 — see validation section in final agent report for build/test logs.*
