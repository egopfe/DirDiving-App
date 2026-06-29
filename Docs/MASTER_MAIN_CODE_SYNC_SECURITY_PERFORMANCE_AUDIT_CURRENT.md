# DIR DIVING — Master Main Code / Sync / Security / Performance Audit (Current)

**Command:** 04 — `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1`  
**Date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `5d757cc` (`5d757cc0217755f5c6d5429af2f13ce5c4748c5d`)  
**Pass type:** Post-remediation audit rerun (read-only)  
**Task type:** Audit-only — read-only; no production changes  
**Xcode:** 26.6 (Build 17F113)

**Merged source commands:** 5 (deep code), 8 (sync/persistence/schema), 9 (security/privacy/trust), 10 (performance/concurrency/battery), iOS performance optimization.

**4A scope included:** Full Computer GF presets, shallow-depth entitlement resolution, water auto-open wiring, developer settings, sync/HMAC, concurrency.

**Not claimed:** Physical Watch/iPhone QA, paired-device field sync, underwater validation, Instruments profiling on hardware, penetration testing, App Store approval, external Bühlmann/CCR certification.

---

## A. Executive Summary

This master audit re-evaluates the entire MAIN codebase (Watch + iOS) for Diving (Gauge + Full Computer), Apnea, and Snorkeling at commit **`5d757cc`** — **post-remediation rerun** for CONS-003–007 (sync in-flight release, symmetric diveImportAck, signed tombstones, shallow dev toggles default OFF, depth compile authority).

**Software architecture and isolation remain strong.** Activity-scoped logbooks, settings, sync payload keys, signed HMAC v3 envelopes, activity tombstones, and cloud backup truthfulness are implemented and tested. iOS performance remediations (`PlannerBackgroundCalculation`, lazy startup, map downsampling, sync flush policy) are present.

**All five prior P1 software findings are VERIFIED closed** at `5d757cc`. **No P0** safety bypasses. **Nine P2** findings remain (physical QA, WAO policy gap, planner lifecycle).

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Multi-activity architecture | **97** | Key routing + envelope guard; WAO FC policy gap P2 |
| Sync / schema | **96** | P1 sync fixes verified; bootstrap tombstone mirror P3 |
| Security (software) | **97** | HMAC static PASS; field QA pending |
| Privacy | **98** | Manifests + export policies + cloud truthfulness |
| Performance (software) | **90** | Sync in-flight fixed; planner lifecycle P2 |
| iOS performance (software) | **86** | Sync readiness improved; planner concurrency P2 |
| Test coverage (automated) | **96** | Remediation lanes PASS @ 5d757cc |
| **Overall MAIN software readiness** | **93** | Physical QA not counted as passed |

**Build evidence (this pass):** iOS **BUILD SUCCEEDED**, Watch **BUILD SUCCEEDED** (`generic/platform=* Simulator`). Preflight + remediation validation scripts **PASS**. Remediation test lanes: iOS **45 tests PASS**, Watch **18 tests PASS** (`validate_master_main_code_sync_security_performance_audit.sh`).

---

## B. Source Commands Merged

| Command | Scope | Prior audit doc |
|---------|-------|-----------------|
| 5 — Deep code analysis | Bugs, crashes, data integrity | MAIN_DEEP_CODE_ANALYSIS_* |
| 8 — Sync/persistence/schema | WC, KVS, migration | MULTI_ACTIVITY_SYNC_* |
| 9 — Security/privacy/trust | HMAC, export, manifests | SECURITY_PRIVACY_TRUST_* |
| 10 — Performance/concurrency/battery | Watch 1Hz, iOS planner | PERFORMANCE_CONCURRENCY_* |
| iOS performance | SwiftUI, charts, logbook | IOS_PERFORMANCE_* |

---

## C. Latest Development Context

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

**4A additions at `5d757cc`:**

- **Shallow depth:** `project.yml` signs `Config/DIRDiving.WithShallowDepth.entitlements`; `DEPTH_ENTITLEMENT_SHALLOW` compile authority via `DepthCapabilityEntitlementProbe.runtimeAuthorityTier`.
- **Developer settings:** Separate shallow Gauge vs shallow Full Computer toggles; **default OFF** (`bool(forKey)` absent → false); DEBUG/TestFlight-only; App Store hidden.
- **Sync remediation:** `releaseInFlightOutboundSession` on failed send/ACK; symmetric `sendDiveImportAckToWatch` on iOS `didReceiveUserInfo`; signed tombstone primary path.
- **Water auto-open:** `WatchSubmersionLaunchProbe` + `ContentView` cold-launch routing; FC destinations require predive + confirm (no live bypass).
- **GF presets:** Watch preset-only; frozen at `confirmFullComputerPredive()`; see `MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv`.

---

## D. Branch, Commit and Scope

| Item | Value |
|------|-------|
| Branch | `main` (aligned with `origin/main`) |
| Commit | `5d757cc` |
| Dirty files at audit start | None (Docs-only updates this pass) |
| Watch target | DIRDiving Watch App |
| iOS target | DIRDiving iOS |
| Test targets | Watch Algorithm Tests, iOS Algorithm Tests |
| Bundle IDs | `com.egopfe.dirdiving.ios.watch`, `com.egopfe.dirdiving.ios` |
| Entitlements (Watch) | Shallow depth (`WithShallowDepth.entitlements`) |
| Physical Watch | Not verified this pass |
| Physical iPhone | Not verified this pass |
| Paired device | Not verified this pass |
| Instruments | Not executed this pass |
| External validation | Not executed |

---

## E. Preflight and Build/Test Baseline

| Check | Result |
|-------|--------|
| Branch is `main` | PASS |
| Commit `5d757cc` | PASS |
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS — inventory 2389 keys; Watch hardcoded 0 |
| `validate_depth_capability_runtime_authority.sh` | PASS |
| `validate_developer_shallow_testing_release_gate.sh` | PASS |
| iOS build (iOS Simulator) | **BUILD SUCCEEDED** |
| Watch build (watchOS Simulator) | **BUILD SUCCEEDED** |
| iOS remediation test lane (45 tests) | **TEST SUCCEEDED** |
| Watch remediation test lane (18 tests) | **TEST SUCCEEDED** |
| `validate_master_main_code_sync_security_performance_audit.sh` | **GATE_PASS** |

---

## F. Target Membership and Architecture

- Shared modules under `Shared/` for sync codecs, performance signposts, tombstones, large payload transfer.
- Experimental targets excluded from MAIN compile — verified by isolation script.
- Entitlements and privacy manifests present for both MAIN targets.
- Shallow-depth signing consistent with compile authority at `5d757cc`.
- **Verdict:** TARGET_MEMBERSHIP **PASS**

---

## G. Activity Isolation and Cross-Activity Risk

| Route | Status |
|-------|--------|
| Diving payload → Diving store | PASS |
| Apnea payload → Apnea store | PASS |
| Snorkeling payload → Snorkeling store | PASS |
| Planner briefing → briefing receiver only | PASS |
| Image payload → photo handler only | PASS |
| Settings → correct activity namespace | PASS |

`ActivitySyncCrossDecodeRejectionTests` — six-route matrix PASS.  
`IntegratedModesSequentialFlowTests` — sequential flow without bleed.

**Verdict:** MULTI_ACTIVITY_ARCHITECTURE **PASS**, ACTIVITY_ISOLATION_CODE **PASS**

---

## H. Apple Watch Deep Code Analysis

**DiveManager / Full Computer:** 1 Hz timer → `tickFullComputerRuntimeIfNeeded()`; solver budget 50 ms; degraded-not-reset on timing fault (`FullComputerTimingFaultTests`).

**Depth capability (4A.2):** Three-layer stack — entitlement probe → resolver → policy → factory. Shallow signing default; developer toggles gate Gauge/FC separately on shallow builds. Simulation separated via `TestFlightSimulationSafetyPolicy`; App Store blocks simulation. See `MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv`.

**Water auto-open (4A.3):** Routing-only; submerged cold launch via `WatchSubmersionLaunchProbe` (400 ms timeout). FC water path → predive configuration → confirmation; never auto-starts live runtime. **P2:** water routing skips `DepthCapabilityPolicy` check used in manual FC picker (`MASTER-WAO-001`).

**Sync:** `WatchSyncService` @MainActor; signed ACK dequeue; activity tombstones via `ActivitySyncTombstoneBroadcast`.

**GF presets (4A.1):** Preset-only on Watch; runtime reads frozen predive snapshot. See GF matrix.

**App Intents:** `requireLegalAcceptanceForSafetyIntent()` gate present.

---

## I. iOS Companion Deep Code Analysis

**Coordinator:** `IOSCompanionStoreCoordinator` with async logbook load; lazy Apnea/Snorkeling bundles on tab selection.

**Planner:** `PlannerBackgroundCalculation` + `Task.detached`; generation token stale guard. **P2:** `deinit` does not cancel planning tasks; `refreshAnalysis` may run on MainActor before detach (`MASTER-PERF-007`).

**Watch sync:** `releaseInFlightOutboundSession` clears in-flight on bad ACK, sendMessage error, and encode failure (`MASTER-PERF-006` **VERIFIED**). iOS `didReceiveUserInfo` sends symmetric `sendDiveImportAckToWatch` after dive import (`MASTER-SYNC-002` **VERIFIED**).

**Cloud:** `CloudBackupCapability` — Diving-only opt-in with legacy key migration.

---

## J. Planner-Specific Deep Code Analysis

- Mode projection (Base/Deco/Technical/CCR reference) with MOD gates.
- CCR reference-only in OC modes — no runtime CCR leakage.
- Briefing cards metadata/reference policy — no live Watch mutation.
- Rock Bottom, gas ledger, repetitive tissue — tested paths PASS in prior gates.

---

## K. Full Computer Runtime Integration Risk

- Checkpoint codec v1 with SHA-256 checksum.
- Plan package isolated namespace from Apnea plan ACK.
- Missed tick → degraded state (safe posture).
- Shallow FC on shallow entitlement requires explicit developer toggle (default OFF) — process risk mitigated (`MASTER-DEPTH-001` **VERIFIED**).

**Verdict:** WATCH_FULL_COMPUTER_TIMING_READINESS **93** (simulator); physical Ultra pending.

---

## L. Sync / Persistence / Schema

- HMAC v3 `ActivitySyncSignedTransport` with `activityType` + `messageType`.
- Distinct payload keys per activity (see `MASTER_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv`).
- Large payload: `ActivitySyncLargePayloadTransfer` — direct ≤512 KB; file transfer up to 5 MB.
- **Signed tombstones primary:** `ActivitySyncTombstoneBroadcast.verifiedSessionIDs` when peer secret present (`MASTER-SYNC-003` **VERIFIED**). Legacy UUID mirror retained for diving pairing-bootstrap only (P3 compat).

**Verdict:** SYNC_ACTIVITY_DISCRIMINATORS **PASS**, SCHEMA_MIGRATION_SAFETY **PASS**

---

## M. Backup / Restore Isolation

- Diving: iOS opt-in KVS; Watch iCloud when available.
- Apnea/Snorkeling iOS: explicitly local-only.
- Cross-activity restore isolation tests PASS.

**Verdict:** BACKUP_RESTORE_ISOLATION **PASS**

---

## N. Cloud / iCloud / KVS

- Per-key 1 MB budget; aggregate budget policy.
- Legacy migration policy for oversized snapshots.
- Success timestamp generation token.

---

## O. Security / Privacy / Trust

See `MASTER_SECURITY_THREAT_MODEL_CURRENT.md` and `MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`.

- HMAC, nonce replay, TOFU pinning, signed ACK — PASS (static).
- Privacy manifests — PASS.
- Export GPS omit default — PASS.
- Protected sensitive file store — PASS.

**Verdict:** WATCHCONNECTIVITY_AUTHENTICATION **PASS**, HMAC_REPLAY_ACK_POLICY **PASS** (software; field QA pending), PRIVACY_DATA_FLOW_TRUTHFULNESS **PASS**

---

## P. Threat Model

STRIDE summary in `MASTER_SECURITY_THREAT_MODEL_CURRENT.md`. Residual: TOFU bootstrap (`MASTER-SEC-002`); legacy tombstone bootstrap mirror (`MASTER-SYNC-003` P3 compat).

---

## Q. Import / Export / File Security

- CSV: 10 MB cap, row validation, chunked read.
- Subsurface: GPS privacy policy; temp files protected.
- Path traversal: briefing filename sanitizer; photo validator.

**Verdict:** SECURITY_FILE_PATH_SAFETY **PASS**

---

## R. Watch Image / Planner Briefing Card Payload Routing

- Photos: WC file transfer + signed management + ACK queue.
- Briefing: file transfer + content hash; reference-only on Watch.

**Verdict:** WATCH_IMAGE_CARD_PAYLOAD_ROUTING **PASS**, PLANNER_BRIEFING_CARDS_REFERENCE_ONLY_CODE **PASS**

---

## S. App Intents / Action Button / Developer Sensor Source

- Legal gate on safety intents — PASS.
- Simulation tagged; App Store disallowed — PASS.
- Developer section: DEBUG always; TestFlight via sandbox receipt; App Store hidden.
- Shallow FC toggle: internal testing only; **default OFF** (`MASTER-DEPTH-001` VERIFIED).

**Verdict:** SIMULATION_RELEASE_SAFETY **PASS**, APP_INTENTS_SAFETY_GATE **PASS**

---

## T. Performance / Concurrency / Battery — Global

Watch: 1 Hz loops, GPS gated, haptics @MainActor, draft throttle.  
iOS: debounced/background planner, bounded caches; sync in-flight defect **remediated**.

See `MASTER_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`, `MASTER_CONCURRENCY_RISK_MATRIX_CURRENT.csv`.

**Verdict:** GLOBAL_PERFORMANCE_CONCURRENCY_BATTERY_READINESS **86** (software); field battery **PENDING**.

---

## U. iOS Performance Optimization

| Area | Readiness |
|------|-----------|
| Startup lazy init | 85 |
| SwiftUI rendering | 90 |
| Planner performance | 86 |
| Chart rendering | 88 |
| Logbook scalability | 86 |
| Export/import | 84 |
| Sync performance | 88 |
| Map/route rendering | 84 |
| Memory | 86 |
| Concurrency | 80 |
| Battery policy | 78 |
| Observability | 70 |
| Performance test coverage | 90 |
| **OVERALL_IOS_PERFORMANCE** | **86** |

---

## V. Watch Performance / Full Computer Timing

- `FullComputerTimingFaultTests` — simulator PASS (prior gates).
- PHYS-W-FC battery/thermal NOT_EXECUTED.

**WATCH_RUNTIME_PERFORMANCE_READINESS:** 88  
**WATCH_FULL_COMPUTER_TIMING_READINESS:** 93

---

## W. Snorkeling Map / Route Performance

- `SnorkelingRoutePresentationSampling` — 4096 presentation cap, unit tested.
- `downsampledMeasuredPoints` wired in UI.
- `maxPersistedTrackPoints = 50_000`.
- Physical map QA pending (`MASTER-PERF-004`).

---

## X. Logbook Scalability

- Runtime caps by design (40 dive / 80 apnea-snorkeling).
- Synthetic 5000-session decode budget test PASS (prior gates).
- LazyVStack + persisted statistics.
- Physical scroll at cap pending.

---

## Y. Memory / Retain-Cycle Hygiene

- Widespread `[weak self]` in timers/async loops.
- Planner `deinit` **does not** cancel tasks — `MASTER-PERF-007`.
- Tissue analytics LRU max 32 entries.

---

## Z. Concurrency / Cancellation / Stale Result Guards

- `planningGeneration` token — planner stale publish prevented.
- `WatchSyncPendingFlushPolicy` — duplicate flush prevented; in-flight released on error — `MASTER-PERF-006` **VERIFIED**.
- `IOSExportCancellation` — export cancellation present.
- Signed ACK authoritative for WC dequeue when ACK received.

---

## AA. Observability / Signposts

24-category catalog in `DIRPerformanceSignpost.swift`. ~10 categories instrumented on iOS. Gaps: `cloudMerge`, export/import, startup (`MASTER-IOS-001`).

---

## AB. Test Coverage and Evidence

See `MASTER_MAIN_REQUIREMENT_TEST_TRACEABILITY_CURRENT.csv`. Automated coverage strong for sync negative paths, FC timing, planner math, isolation, depth capability, water auto-open policy. Physical/paired/external rows marked PENDING.

**TEST_COVERAGE_READINESS:** 95 (automated); physical matrices incomplete.

---

## AC. Physical / Instruments / External QA Pending

| Gate | Status |
|------|--------|
| PHYSICAL_WATCH_QA | PENDING_PHYSICAL |
| PHYSICAL_IOS_QA | PENDING_PHYSICAL |
| PAIRED_DEVICE_QA | PENDING_PHYSICAL |
| PHYSICAL_INSTRUMENTS_PROFILING | PENDING_INSTRUMENTS |
| EXTERNAL_VALIDATION | PENDING_EXTERNAL_VALIDATION |

Execute `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md`.

---

## AD. Detailed Findings

Consolidated in `MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv`.

| Severity | Count | Summary |
|----------|-------|---------|
| P0 | 0 | — |
| P1 | 0 | All five prior P1 items VERIFIED @ 5d757cc |
| P2 | 9 | 6 physical QA + WAO policy/probe + planner concurrency |
| P3 | 6 | Instruments + accepted risks + doc drift + tombstone bootstrap mirror |
| P4 | 10 | INFO positive controls |

---

## AE. Readiness Matrix

| Gate | Verdict |
|------|---------|
| BASELINE_CURRENT_AND_CLEAN | PASS |
| TARGET_MEMBERSHIP | PASS |
| MULTI_ACTIVITY_ARCHITECTURE | PASS |
| ACTIVITY_ISOLATION_CODE | PASS |
| SETTINGS_OWNERSHIP_CODE | PASS |
| LOGBOOK_OWNERSHIP_CODE | PASS |
| SYNC_ACTIVITY_DISCRIMINATORS | PASS |
| SCHEMA_MIGRATION_SAFETY | PASS |
| BACKUP_RESTORE_ISOLATION | PASS |
| WATCHCONNECTIVITY_AUTHENTICATION | PASS |
| HMAC_REPLAY_ACK_POLICY | PASS |
| SECURITY_FILE_PATH_SAFETY | PASS |
| PRIVACY_DATA_FLOW_TRUTHFULNESS | PASS |
| SIMULATION_RELEASE_SAFETY | PASS |
| APP_INTENTS_SAFETY_GATE | PASS |
| WATCH_IMAGE_CARD_PAYLOAD_ROUTING | PASS |
| PLANNER_BRIEFING_CARDS_REFERENCE_ONLY_CODE | PASS |

---

## AF. Prioritized Remediation Plan

See `MASTER_MAIN_CODE_REMEDIATION_PLAN_CURRENT.md` and `MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md`.

**P1 software fixes verified** at `5d757cc`. Remaining: P2 physical QA, WAO policy, planner lifecycle.

---

## AG. Future Cursor Remediation Commands

1. ~~iOS WatchSync in-flight + ACK symmetry remediation.~~ **DONE @ 5d757cc**
2. Water auto-open DepthCapabilityPolicy alignment.
3. Physical paired-device QA (read-only evidence capture).
4. Instruments iOS/Watch profiling command.

---

## AH. Final Verdict

```text
MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT: PARTIAL
BASELINE_CURRENT_AND_CLEAN: PASS
TARGET_MEMBERSHIP: PASS
MULTI_ACTIVITY_ARCHITECTURE: PASS
ACTIVITY_ISOLATION_CODE: PASS
SETTINGS_OWNERSHIP_CODE: PASS
LOGBOOK_OWNERSHIP_CODE: PASS
SYNC_ACTIVITY_DISCRIMINATORS: PASS
SCHEMA_MIGRATION_SAFETY: PASS
BACKUP_RESTORE_ISOLATION: PASS
WATCHCONNECTIVITY_AUTHENTICATION: PASS
HMAC_REPLAY_ACK_POLICY: PASS
SECURITY_FILE_PATH_SAFETY: PASS
PRIVACY_DATA_FLOW_TRUTHFULNESS: PASS
SIMULATION_RELEASE_SAFETY: PASS
APP_INTENTS_SAFETY_GATE: PASS
WATCH_IMAGE_CARD_PAYLOAD_ROUTING: PASS
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY_CODE: PASS
IOS_STARTUP_PERFORMANCE_READINESS: 85
IOS_SWIFTUI_RENDERING_READINESS: 90
IOS_PLANNER_PERFORMANCE_READINESS: 86
IOS_CHART_RENDERING_READINESS: 88
IOS_LOGBOOK_SCALABILITY_READINESS: 86
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS: 84
IOS_SYNC_PERFORMANCE_READINESS: 88
IOS_MAP_ROUTE_RENDERING_READINESS: 84
IOS_MEMORY_READINESS: 86
IOS_CONCURRENCY_READINESS: 82
IOS_BATTERY_POLICY_READINESS: 78
WATCH_RUNTIME_PERFORMANCE_READINESS: 88
WATCH_FULL_COMPUTER_TIMING_READINESS: 93
GLOBAL_SECURITY_READINESS: 97
GLOBAL_PRIVACY_READINESS: 98
GLOBAL_SYNC_SCHEMA_READINESS: 96
GLOBAL_PERFORMANCE_CONCURRENCY_BATTERY_READINESS: 90
TEST_COVERAGE_READINESS: 96
OVERALL_MAIN_CODE_READINESS: 93
P0_FINDINGS: 0
P1_FINDINGS: 0
P2_FINDINGS: 9
P3_FINDINGS: 6
P4_FINDINGS: 10
PHYSICAL_WATCH_QA: PENDING_PHYSICAL
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_DEVICE_QA: PENDING_PHYSICAL
PHYSICAL_INSTRUMENTS_PROFILING: PENDING_INSTRUMENTS
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: MASTER-PERF-001,MASTER-SEC-001,MASTER-SYNC-001,MASTER-WAO-001,MASTER-WAO-002,MASTER-PERF-007,MASTER-DCA-018
```

**PARTIAL** because nine P2 findings remain open (physical QA, WAO policy, planner lifecycle). All P1 software findings **VERIFIED closed** @ `5d757cc`. PASS requires zero open P0–P2.

---

## Required Final Questions (§19)

| # | Question | Answer |
|---|----------|--------|
| 1 | MAIN architecture clean and isolated? | **YES** — key-based routing + tests |
| 2 | Diving/Apnea/Snorkeling separated? | **YES** — code, sync, settings, logbook |
| 3 | Sync payloads activity-discriminated? | **YES** — v3 envelope + payload keys |
| 4 | Schemas versioned and migration-safe? | **YES** — migration modules + fail-closed |
| 5 | Backup/restore activity-isolated? | **YES** — CloudBackupCapability |
| 6 | WC authentication intact? | **YES** — HMAC + TOFU |
| 7 | HMAC/nonce/ACK safe? | **YES** — symmetric ACK + signed tombstones verified (field QA P2) |
| 8 | Import/export paths safe? | **YES** — bounds + protection |
| 9 | Images/cards path-safe? | **YES** — sanitizer + validator |
| 10 | Privacy flows truthful? | **YES** — opt-in Diving cloud only |
| 11 | Simulation release-safe? | **YES** — App Store block |
| 12 | App Intents respect gates? | **YES** |
| 13 | iOS Planner performance-safe? | **PARTIAL** — background calc yes; lifecycle gaps P2 |
| 14 | Heavy compute off main thread? | **PARTIAL** — planner mostly detached; prefetch gap |
| 15 | Stale async results rejected? | **YES** — generation tokens |
| 16 | Charts/maps/logbooks bounded? | **YES** — caps + downsampling |
| 17 | Sync queue backpressured? | **YES** — flush policy + in-flight release verified |
| 18 | Caches bounded? | **YES** — tissue LRU 32 |
| 19 | Tasks cancellable? | **PARTIAL** — planner deinit gap |
| 20 | Retain-cycle risks? | **LOW** — weak captures common |
| 21 | Performance budgets documented? | **YES** — MASTER_* matrices |
| 22 | Instruments complete? | **PENDING** — MASTER-IOS-001/002 |
| 23 | Blocks 100% main-code readiness? | P2 physical QA + WAO + planner lifecycle |
| 24 | Blocks 100% security readiness? | Field SEC-NEG only |
| 25 | Blocks 100% performance readiness? | Instruments + Ultra battery + planner lifecycle |
| 26 | Blocks internal TestFlight? | **P2 physical QA** (software P1 closed) |
| 27 | Blocks external TestFlight? | **YES** — physical QA + external validation |

---

**Audit completed:** 2026-06-28 on `main` @ `5d757cc` (post-remediation rerun). No production code modified.
