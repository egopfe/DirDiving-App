# AUDIT 08 — Apnea Release Gate (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code/doc review (no application code modified)  
**Command:** `08_AUDIT_APNEA_RELEASE_GATE.md`  
**Branch:** `main` @ `cbc485e` (committed HEAD)  
**Working tree:** **Dirty** — uncommitted Audit 07 remediation (sync negative tests, E2E harness, QA scaffolds, codec test hooks)  
**Scope:** Final independent Apnea release gate after Command 12 — lifecycle, sensor, recovery, alarms, Watch UI, logbook, iOS Companion, sync, performance, battery, Water Lock, gloves, privacy, safety wording, documentation, rollback; explicit Gauge + Full Computer non-regression check.

**Prerequisites:** Audits 05–07 **PASS**; Commands 05–12 implementation + release-hard tooling present on `main`.

---

## Executive summary

| Dimension | Readiness | Verdict |
|-----------|----------:|---------|
| **Internal code / architecture** | **98%** | Strong; Apnea isolated from Gauge/FC |
| **Automated tests (release-hard)** | **97%** | **2 failures** in suspend/resume suite during this audit |
| **Documentation** | **95%** | Complete but partially stale vs promoted MAIN |
| **Physical / device evidence** | **0%** | All 18 QA folders **PENDING** |
| **Overall internal readiness** | **96%** | |
| **External / TestFlight / App Store** | **0%** | **NO-GO** until physical QA + clean gate |

### Release decision

```
GO WITH CONDITIONS
```

| Audience | Decision |
|----------|----------|
| **Internal integration / continued development** | **GO WITH CONDITIONS** |
| **TestFlight (Apnea)** | **NO-GO** |
| **Production App Store (Apnea marketing)** | **NO-GO** |

### Conditions before external GO

1. Fix or quarantine `ApneaSuspendResumeLifecycleIntegrationTests` failures blocking `validate_apnea_release_readiness.sh`.
2. Commit Audit 07 remediation on a **clean** `main`; re-run release-hard script to exit 0.
3. Execute and sign physical QA matrices under `Docs/QA_EVIDENCE/APNEA_*` (minimum: sync, sensor/recovery, Watch UI, safety review).
4. Refresh stale docs (`DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md`, `SAFETY_DISCLAIMER.md` branch notes, `APNEA_RELEASE_CHECKLIST.md` promotion section).

---

## Audit context

| Item | Value |
|------|-------|
| Committed `HEAD` | `cbc485e` |
| `origin/main` | `cbc485e` (in sync) |
| Audit 06 remediation | Committed @ `2309320` (`ApneaWatchRuntimeStore`, Watch MAIN promotion) |
| Audit 07 remediation | **On disk, uncommitted** — see dirty-tree list below |
| Prior gate labels | Audit 05 → Command 04 **READY**; Audit 06 → Command 08 **READY**; Audit 07 → Command 12 **READY** (internal, pre-physical) |

**Dirty-tree files (uncommitted):** `project.yml`, codec test hooks, 10 new test files, `validate_apnea_release_readiness.sh`, audit/architecture docs, 7 new `Docs/QA_EVIDENCE/APNEA_*` folders, `APNEA_IOS_SYNC_END_TO_END_REMEDIATION_REPORT_V1.0.md`.

---

## 1. Lifecycle automatico

| Control | Implementation | Automated | Physical |
|---------|----------------|-----------|----------|
| State machine (idle → ready → dive → ascent → recovery → summary) | `ApneaSessionEngine`, `ApneaLifecycleStateMachine` | **PASS** — `ApneaLifecycleEngineTests` (17) | PENDING |
| Auto immersion / surface thresholds | `ApneaLifecycleConfiguration` | **PASS** | PENDING |
| Yo-yo multi-dive / min dive duration | Engine + policy | **PASS** | PENDING |
| Suspend / resume via checkpoint | `ApneaSessionCheckpoint` export/restore | **FAIL** — 2 tests in `ApneaSuspendResumeLifecycleIntegrationTests` (this audit) | PENDING |
| No silent session reset on restore | Policy + tests | **PARTIAL** — primary suspend test failing | PENDING |

**Audit 05 verdict:** **PASS** (pre-remediation). **Regression observed** in suspend/resume integration during Audit 08 release-hard run.

---

## 2. Sensor faults

| Control | Status |
|---------|--------|
| 3 s depth timeout → `sensorDegraded` | **PASS** (automated) |
| Ready start blocked when degraded | **PASS** — `ApneaWatchPresentationTests`, `ApneaWatchRuntimeStoreTests` |
| Manual fallback explicit | **PASS** |
| Spike / regressive timestamp rejection | **PASS** — `DepthMeasurementFeed` tests |

**Physical:** `Docs/QA_EVIDENCE/APNEA_SENSOR_RECOVERY/` — **PENDING**

---

## 3. Recovery

| Control | Status |
|---------|--------|
| Policies 1:1, 2:1, fixed, informational | **PASS** — `ApneaRecoveryComputation` tests |
| Monotonic elapsed clock | **PASS** — mostly; large wall-clock jump test **FAIL** (suspend suite) |
| Checkpoint atomic write + corrupt reject | **PASS** — `ApneaCheckpointFailureInjectionTests` |
| Recovery overlays / haptics | **PASS** (automated presentation) |

---

## 4. Allarmi / marker / target

| Control | Status |
|---------|--------|
| Depth/time alarms, markers, targets | **PASS** — `ApneaOperationalEventEngineTests` |
| Target-not-reached negatives | **PASS** (Audit 06 remediation) |
| Haptics-off visual fallback | **PASS** |
| Mission Mode compatibility | **PASS** |

---

## 5. UI Watch

| Control | Status |
|---------|--------|
| Stage mapping (ready/dive/ascent/recovery/summary) | **PASS** — `ApneaWatchPresentationTests` (14) |
| `ApneaView` on Watch MAIN | **PASS** — `ApneaWatchMainPromotionTests`, `project.yml` |
| `ApneaWatchRuntimeStore` (no `DiveManager`) | **PASS** — architecture + runtime tests |
| Layout contract (41/45/49 mm) | **PASS** — `ApneaWatchLayoutContractTests` |
| Dynamic Type / accessibility hooks | **PASS** (static) — `ApneaWatchUIViewContractTests` |
| VoiceOver / haptics on device | **PENDING** — `APNEA_VOICEOVER`, `APNEA_HAPTICS` |

---

## 6. Logbook

| Control | Status |
|---------|--------|
| Watch `ApneaLogbookStore` isolated | **PASS** — no `DiveLogStore` writes |
| CRUD, merge, retention cap, corrupt quarantine | **PASS** — `ApneaLogbookStoreTests` |
| iOS `IOSApneaLogbookStore` import/merge | **PASS** — sync + merge integrity tests |
| Record eligibility (simulated/degraded excluded) | **PASS** |

---

## 7. iOS Companion

| Control | Status |
|---------|--------|
| Dashboard, profiles, planner, settings | **PASS** — `IOSApneaCompanionTests` (9) |
| Logbook, charts, statistics | **PASS** — `IOSApneaLogbookAnalyticsTests` (11) |
| Map, equipment, buddy, export | **PASS** — `IOSApneaMapEquipmentExportTests` (10) |
| Buddy disclaimer EN/IT | **PASS** — release-hard localization scan |
| Cloud backup opt-in stub (no false upload) | **PASS** — `ApneaCloudBackupStubTruthfulnessTests` |

---

## 8. Sync

| Control | Status |
|---------|--------|
| Plan package schema + checksum + ACK | **PASS** |
| Session transport v2 + HMAC + nonce replay | **PASS** (on disk; uncommitted negative-path tests) |
| Namespace isolation | **PASS** — `ApneaReleaseSelfCheck`, `FullComputerNamespaceIsolationTests` |
| Offline autonomy + pending queues | **PASS** (automated) |
| Offline→online E2E harness | **PASS** (on disk; uncommitted) |
| Physical pair/reachability/airplane/relaunch | **PENDING** — 7 sync QA folders |

---

## 9. Performance

| Control | Status |
|---------|--------|
| Checkpoint round-trip ≤ 50 ms budget | **PASS** — `ApneaReleaseHardValidationTests.testCheckpointRoundTripWithinBudget` |
| Large session chart build | **PASS** — iOS analytics performance test |
| Full algorithm suites | Watch **587** / iOS **978** tests, 0 failures (full suite, prior remediation run); release-hard subset **2 failures** (this audit) |

---

## 10. Batteria

| Control | Status |
|---------|--------|
| Automated battery/thermal budget | **Not implemented** |
| Documented residual risk | Yes — `DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` |

**Physical:** not in QA matrix — **PENDING** / out of automated scope.

---

## 11. Water Lock

| Control | Status |
|---------|--------|
| Automated Water Lock handling | **Not implemented** |
| QA scaffold | `Docs/QA_EVIDENCE/APNEA_WATER_LOCK/README.md` — **PENDING** (6 scenarios) |

---

## 12. Guanti / wet interaction

| Control | Status |
|---------|--------|
| Matrix X-04 manual wet/glove | Documented in `APNEA_RELEASE_HARD_TEST_MATRIX.md` |
| QA scaffold | `Docs/QA_EVIDENCE/APNEA_WET_INTERACTION/` — **PENDING** |

---

## 13. Privacy

| Control | Status |
|---------|--------|
| GPX blocked without GPS acknowledgement | **PASS** |
| Export redaction (GPS + contacts) | **PASS** |
| Apnea session namespace ≠ dive session | **PASS** |
| No cloud upload from Apnea export toggle | **PASS** |

---

## 14. Safety wording

| Control | Status |
|---------|--------|
| `ApneaReleaseSelfCheck` forbidden phrases scan | **PASS** — no blackout/no-movement marketing strings in Apnea sources |
| `Docs/SAFETY_DISCLAIMER.md` Apnea section | **PASS** content; **P3** stale branch reference (`integration/full-computer`) |
| Non-certified positioning | **PASS** |
| Buddy not remote rescue | **PASS** — localized disclaimer |

**Physical:** `Docs/QA_EVIDENCE/APNEA_SAFETY_REVIEW/` — **PENDING**

---

## 15. Documentazione

| Document | Status |
|----------|--------|
| `APNEA_ARCHITECTURE.md` | **PASS** (updated on disk for MAIN promotion) |
| `APNEA_RELEASE_HARD_TEST_MATRIX.md` | **PASS** |
| `APNEA_RELEASE_CHECKLIST.md` | **PARTIAL** — promotion checklist still lists ApneaView exclusion (stale) |
| `DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` | **STALE** — pre–MAIN promotion |
| Audits 05–07 + remediation reports | **PASS** |
| `Docs/INDEX.md` | **PASS** @ `cbc485e` (pre–Audit 07 commit) |
| `Docs/QA_EVIDENCE/APNEA_*` (18 folders) | **PRESENT**, all **PENDING** |

---

## 16. Rollback

| Control | Status |
|---------|--------|
| Documented rollback (`APNEA_RELEASE_CHECKLIST.md`) | **PASS** — revert merge or exclude sources |
| Apnea sync keys namespaced | **PASS** — rollback does not affect Gauge/FC dive sync |
| FC rollback to Gauge default | Documented in `FULL_COMPUTER_RELEASE_CHECKLIST.md` (independent) |

---

## 17. Diving Gauge — regression confirmation

| Check | Result |
|-------|--------|
| `DiveManagerAlgorithmIntegrationTests` | **PASS** (15 tests, this audit) |
| Apnea production sources do not reference `DiveManager` | **PASS** — `ApneaArchitectureIsolationTests` |
| `dirdiving_dive_session` ≠ `dirdiving_apnea_session` | **PASS** — `ApneaReleaseSelfCheck` |
| Gauge mode does not start FC runtime | **PASS** — `testGaugeModeDoesNotStartFullComputerRuntime` |
| No mid-dive Gauge fallback (Audit 04 policy) | **PASS** — integration tests |
| `validate_main_release_readiness.sh` | Not re-run this audit; prior Audit 04 baseline **PASS** on FC-focused gate |

**Explicit confirmation:** **No Gauge regression identified** from Apnea integration on `main` @ committed HEAD + dirty tree. Apnea remains namespace-isolated; `DiveManager` paths unchanged by Apnea runtime store.

---

## 18. Full Computer — regression confirmation

| Check | Result |
|-------|--------|
| `FullComputerNamespaceIsolationTests` | **PASS** (8/8, this audit) |
| Apnea plan ACK cannot parse as FC ACK | **PASS** |
| FC/Apnea imported-plan stores independent | **PASS** |
| Application context keys do not collide | **PASS** |
| Audit 04 FC release gate | **GO WITH CONDITIONS** @ 96% internal (independent of Apnea) |

**Explicit confirmation:** **No Full Computer regression identified** from Apnea work. FC and Apnea share only generic WatchConnectivity infrastructure with distinct transfer types and stores.

---

## Findings

### P0 — Blockers

None (no safety-critical code defect identified that would forbid internal development).

### P1 — Release gate blockers

| # | Finding | Evidence |
|---|---------|----------|
| 1 | **`validate_apnea_release_readiness.sh` exits non-zero** during Audit 08 | 2 failures in `ApneaSuspendResumeLifecycleIntegrationTests` |
| 2 | **All physical QA evidence PENDING** | 18/18 `Docs/QA_EVIDENCE/APNEA_*` folders unsigned |
| 3 | **Audit 07 remediation uncommitted** | Dirty tree; gate should not tag TestFlight on uncommitted SHA |

**Suspend/resume failures (reproducible this audit):**

| Test | Failure |
|------|---------|
| `testSuspendAndResumeRestoresApneaSessionWithoutSilentResetOrDuplicateDive` | Expected 1 dive after restore; got 0 |
| `testResumeAfterLargeWallClockJumpUsesMonotonicPolicy` | `sessionElapsedSeconds` &lt; 1.0 after +86 400 s wall-clock jump |

### P2

| # | Finding |
|---|---------|
| 1 | Documentation drift vs Watch MAIN promotion (`APNEA_RELEASE_CHECKLIST`, Command 12 validation report, `SAFETY_DISCLAIMER` branch note) |
| 2 | Battery/thermal not automated |
| 3 | Water Lock and glove/wet interaction manual-only |

### P3

| # | Finding |
|---|---------|
| 1 | HMAC transport tests skip when simulator keychain unavailable (~28 iOS / ~19 Watch skips in full suites) |
| 2 | Screenshot/layout regression on physical devices not captured |
| 3 | `APNEA_RELEASE_HARD_TEST_MATRIX` R-04 still references ApneaView excluded |

---

## Test execution (this audit)

### Release-hard script

```
./Scripts/validate_apnea_release_readiness.sh
→ FAIL (Watch test phase)
→ warning: working tree is not clean
→ builds: PASS
→ Watch release-hard suites: 160 executed, 2 failures, 3 skipped
```

### Targeted verification (this audit)

| Suite | Result |
|-------|--------|
| `ApneaReleaseHardValidationTests` + `ApneaArchitectureIsolationTests` + `FullComputerNamespaceIsolationTests` + `DiveManagerAlgorithmIntegrationTests` | **37/37 PASS** |
| `ApneaSuspendResumeLifecycleIntegrationTests` | **2/2 FAIL** (reproduced) |
| iOS Apnea release-hard subset (6 suites) | **36 tests, 0 failures, 3 skipped** |

### Documented full-suite baseline (remediation run, same dirty tree)

| Suite | Result |
|-------|--------|
| iOS full algorithm | **978** tests, **0** failures, 28 skipped |
| Watch full algorithm | **587** tests, **0** failures, 19 skipped |

*Note: full Watch suite passed earlier the same day; release-hard subset includes suspend/resume and failed consistently in Audit 08 runs.*

---

## Physical QA matrix

| Folder | Status |
|--------|--------|
| `APNEA_WATCH_ULTRA` | PENDING |
| `APNEA_SENSOR_RECOVERY` | PENDING |
| `APNEA_OS_LIFECYCLE` | PENDING |
| `APNEA_UI_SMOKE` | PENDING |
| `APNEA_WATER_LOCK` | PENDING |
| `APNEA_WET_INTERACTION` | PENDING |
| `APNEA_HAPTICS` | PENDING |
| `APNEA_VOICEOVER` | PENDING |
| `APNEA_WATCH_LAYOUTS` | PENDING |
| `APNEA_MAIN_PROMOTION` | PENDING |
| `APNEA_IOS_WATCH_SYNC` | PENDING |
| `APNEA_OFFLINE_ONLINE` | PENDING |
| `APNEA_PAIR_UNPAIR` | PENDING |
| `APNEA_AIRPLANE_MODE` | PENDING |
| `APNEA_RELAUNCH` | PENDING |
| `APNEA_PLAN_PUSH` | PENDING |
| `APNEA_SESSION_PULL` | PENDING |
| `APNEA_SAFETY_REVIEW` | PENDING |

---

## Readiness matrix (0–100%)

| Domain | Code | Automated tests | Documentation | Physical evidence |
|--------|-----:|----------------:|--------------:|------------------:|
| Lifecycle automatico | 98 | 95 | 100 | 0 |
| Sensor faults | 100 | 100 | 100 | 0 |
| Recovery | 98 | 95 | 100 | 0 |
| Allarmi/marker/target | 100 | 100 | 100 | N/A |
| UI Watch | 100 | 98 | 100 | 0 |
| Logbook | 100 | 100 | 100 | N/A |
| iOS Companion | 100 | 100 | 100 | N/A |
| Sync | 100 | 98 | 100 | 0 |
| Performance | 95 | 97 | 100 | N/A |
| Batteria | N/A | 0 | 80 | 0 |
| Water Lock | N/A | 0 | 100 | 0 |
| Guanti | N/A | 0 | 100 | 0 |
| Privacy | 100 | 100 | 100 | N/A |
| Safety wording | 100 | 100 | 95 | 0 |
| Documentation | 95 | N/A | 95 | N/A |
| Rollback | 100 | N/A | 100 | N/A |
| Gauge non-regression | 100 | 100 | 100 | N/A |
| Full Computer non-regression | 100 | 100 | 100 | N/A |
| **Overall internal** | **98** | **97** | **95** | **0** |
| **Overall external release** | — | — | — | **0 → NO-GO** |

---

## Rischi residui

1. **Suspend/resume checkpoint regression** — blocks automated release-hard gate until fixed.
2. **Zero signed physical QA** — Watch Ultra depth, sensor loss, Water Lock, gloves, sync, safety review all unverified on hardware.
3. **Uncommitted remediation** — negative-path sync tests and E2E harness not on `origin/main`.
4. **Doc drift** — checklists still describe pre-promotion state; risk of operator error at release time.
5. **Battery/thermal** — no automated or physical evidence.
6. **Simulator keychain** — HMAC round-trip tests intermittently skipped.

---

## Related documentation

| Document | Role |
|----------|------|
| `AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md` | Audit 05 |
| `AUDIT_APNEA_WATCH_FEATURES_UI_LOGBOOK_CURRENT.md` | Audit 06 |
| `AUDIT_APNEA_IOS_SYNC_END_TO_END_CURRENT.md` | Audit 07 |
| `APNEA_IOS_SYNC_END_TO_END_REMEDIATION_REPORT_V1.0.md` | Audit 07 remediation (uncommitted) |
| `DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` | Command 12 |
| `AUDIT_FULL_COMPUTER_RELEASE_GATE_CURRENT.md` | FC gate (independent) |
| `Scripts/validate_apnea_release_readiness.sh` | Apnea release-hard automation |

---

## Final gate labels

| Label | Value |
|-------|-------|
| **Audit 08 decision** | **GO WITH CONDITIONS** (internal) |
| **TestFlight / App Store** | **NO-GO** |
| **Gauge regression** | **None identified** |
| **Full Computer regression** | **None identified** |
| **Command 12 (automated)** | **NOT READY** until suspend/resume failures resolved and script exits 0 on clean tree |

---

*Audit 08 — read-only. No application code modified. Report: `Docs/AUDIT_APNEA_RELEASE_GATE_CURRENT.md`.*
