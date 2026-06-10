# DIR DIVING MAIN Deep Code Analysis Remediation Report

Date: 2026-06-09  
Branch: `main`  
Starting commit: `a2733d2`  
Ending commit: (uncommitted working tree at remediation completion)  
Source audit: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md` (`dba1a22` baseline)

---

## A. Branch Confirmed

`main` — clean preflight, aligned with `origin/main`.

## B. Target Confirmation

- DIRDiving iOS (MAIN)
- DIRDiving Watch App (MAIN)
- DIRDiving iOS Algorithm Tests
- DIRDiving Watch Algorithm Tests
- Experimental targets excluded (Apnea, Snorkeling, Buddy Assist, Exploration Lab)

## C. Files Modified

| Area | Files |
|---|---|
| Planner MOD/cache/UI | `iOSApp/Views/PlannerView.swift`, `iOSApp/Services/PlannerStore.swift` |
| Watch sync ACK | `Services/WatchDiveSyncCodec.swift`, `Services/WatchSyncService.swift` |
| Watch cloud cap | `Services/CloudSyncStore.swift`, `Utils/DiveAlgorithmConfiguration.swift` |
| Watch merge | `Utils/DiveSessionMerge.swift` |
| Dive lifecycle | `Services/DiveManager.swift` |
| Sync security | `Services/WatchSyncAuth.swift`, `iOSApp/Services/WatchSyncAuth.swift`, `Utils/SyncNonceReplayCache.swift`, `iOSApp/Utils/SyncNonceReplayCache.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift` |
| CCR import | `iOSApp/Utils/ChecklistPlannerSyncMapper.swift` |
| Photo privacy | `iOSApp/Services/WatchSyncService.swift`, `Services/WatchSyncService.swift` |
| Tests | `Tests/iOSAlgorithmTests/MainDeepCodeRemediationDCATests.swift`, `Tests/WatchAlgorithmTests/MainDeepCodeRemediationDCATests.swift`, `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift`, `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift`, `Tests/WatchAlgorithmTests/WatchSyncServiceIntegrationTests.swift` |
| Docs | `Docs/WATCH_SYNC_SECURITY_THREAT_MODEL.md`, `Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md` |

## D. Issue Fixes

| ID | Status | Summary |
|---|---|---|
| MAIN-DCA-001 | **Fixed** | Watch `parseImportAck` + `didReceiveUserInfo` ACK handling |
| MAIN-DCA-002 | **Fixed** | Watch `CloudSyncStore` rejects payloads > `maxSyncPayloadBytes` |
| MAIN-DCA-003 | **Fixed** | Oversized remote KVS payloads ignored safely on load |
| MAIN-DCA-004 | **Fixed** | `liveMODIssues` uses `PlannerModePolicy.activePlanInput` |
| MAIN-DCA-005 | **Fixed** | `AnalysisCacheKey` includes SAC, planning ref, avg depth, projected cylinders |
| MAIN-DCA-006 | **Fixed** | Watch merge unions compatible samples; documents subset metadata policy |
| MAIN-DCA-007 | **Fixed** | `endManualDive()` works when `sessionStartedManually` after handoff |
| MAIN-DCA-008 | **Fixed** | Draft persistence coalesced (8s); immediate on start/first sample/end |
| MAIN-DCA-009 | **Fixed** | `missionModeManualPendingForSession` in draft schema v2 |
| MAIN-DCA-010 | **Fixed** | Base summary MOD tile shows MOD, not END |
| MAIN-DCA-011 | **Fixed** | Mode change reclamps switch depths; Technical env onChange retained |
| MAIN-DCA-012 | **Fixed** | Alarm blink timer 1.0s (was 0.45s) |
| MAIN-DCA-013 | **Fixed** | Threat model doc; publish secret only when no peer secret |
| MAIN-DCA-014 | **Fixed** | Replay cache persisted with complete file protection |
| MAIN-DCA-015 | **Fixed** | CCR bailout switch depth reconciled on checklist import |
| MAIN-DCA-016 | **Fixed** | Photo staging/temp files use complete file protection |
| MAIN-DCA-017 | **N/A** | `columnHeaders!` already safe in `tableColumnAccessibilityLabel` |
| MAIN-DCA-018 | **Updated** | QA matrices remain **PENDING** for physical/external gates |

## E. Tests Added

- `MainDeepCodeRemediationDCATests` (iOS): mode-projected MOD, cache invalidation, MOD/END semantics, CCR import clamp, replay persistence
- `MainDeepCodeRemediationDCATests` (Watch): userInfo ACK dequeue, cloud cap, merge, draft throttle
- `DiveManagerAlgorithmIntegrationTests.testEndManualDiveWorksAfterManualToAutomaticHandoff`
- `WatchSyncServiceIntegrationTests.testSignedImportAckPayloadParsesOnWatch`

## F. Tests Run

| Suite | Result | Passed | Skipped | Failed |
|---|---|---:|---:|---:|
| DIRDiving iOS Algorithm Tests (iPhone 17 Pro) | **PASS** | 561 | 13 | 0 |
| DIRDiving Watch Algorithm Tests (Ultra 3 49mm) | **PASS** | 192 | 16 | 0 |

## G. Build Results

| Target | Result |
|---|---|
| DIRDiving iOS | **BUILD SUCCEEDED** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |

## H. Remaining Blockers

- Paired Watch/iPhone physical sync QA
- iCloud two-device QA
- Watch Ultra underwater physical QA
- Subsurface external round-trip QA

## I. Remaining External QA

All rows in `Docs/WATCH_IOS_SYNC_QA_MATRIX.md`, `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md`, `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md` remain **PENDING** unless manually executed.

## J. Remaining App Store Blockers

- Physical/external QA evidence
- App Store privacy wording review
- TestFlight crash telemetry from external cohort

## K. Readiness After Remediation (estimate)

| Area | Before | After |
|---|---:|---:|
| Overall static code | 82% | **91%** |
| Watch MAIN | 86% | **92%** |
| iOS MAIN | 78% | **88%** |
| Bug risk | 80% | **90%** |
| Performance | 74% | **86%** |
| Security | 84% | **91%** |
| Privacy | 81% | **88%** |
| Data integrity | 76% | **90%** |
| Sync/cloud | 74% | **88%** |
| CCR/Rebreather | 83% | **90%** |
| Internal TestFlight | Not ready | **Near ready** (simulator QA smoke still advised) |
| External TestFlight | Not ready | **Not ready** |
| App Store | Not ready | **Not ready** |

## L. Confirmations

- MAIN only; experimental files untouched
- No UI redesign or visual identity change
- No Bühlmann / CCR / Ratio Deco math changes
- No certified dive-computer or CCR-controller claims
- No physical or external QA falsely marked complete
