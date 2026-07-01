# DIR DIVING — Master Main Code / Sync / Security / Performance Audit (Current)

**Command:** 04 — `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.5` (LAUNCH ORDER 04)  
**Date:** 2026-07-01  
**Branch:** `main`  
**Commit:** `2c30412` (`2c30412e777e6ef40a688b9ac11215f32310764f`)  
**Pass type:** Full read-only audit @ V1.5 with Apnea first-class scope  
**Task type:** Audit-only — read-only; no production changes  
**Xcode:** 26.6 (Build 17F113)

**Merged source commands:** 5 (deep code), 8 (sync/persistence/schema), 9 (security/privacy/trust), 10 (performance/concurrency/battery), iOS performance optimization.

**Upstream audits:** 01 Watch FC @ `2c30412` (0 P0 FC; WFC-P2-005 routing); 02 iOS @ `2c30412` (1655 tests PASS); 03 UI/UX @ `2c30412` (CONS-046 V1.5 PASS).

**Not claimed:** Physical Watch/iPhone QA, paired-device field sync, underwater validation, Instruments profiling on hardware, penetration testing, App Store approval, external Bühlmann certification.

---

## A. Executive Summary

This master audit re-evaluates the entire MAIN codebase (Watch + iOS) for Diving (Gauge + Full Computer), **Apnea**, and Snorkeling at commit **`2c30412`**, after Apnea P1/P2/P3 (`76f3703`) and CONS-046 V1.5 command-integrity fix (`6a0005b`).

**Software architecture and activity isolation remain strong.** Activity-scoped logbooks, settings, sync payload keys, signed HMAC v3 envelopes, activity tombstones, cloud backup truthfulness, and Apnea/Snorkeling schema isolation are implemented with cross-decode rejection tests.

**Cross-cutting remediations CONS-001, CONS-003–007, CONS-027, CONS-046, CONS-049 verified.** **No P0** software safety bypass identified. **Audit 01 FC math: 0 P0.**

**Software gates improved since @451f8fb:**

1. **CONS-046 / MAIN-P1-001:** `validate_commands_for_cursor_integrity.sh` **PASS** @ V1.5.
2. **CONS-049 / MAIN-P2-001:** iOS Algorithm Tests **1655/1655 PASS** @ `2c30412`.
3. **NEW MAIN-P2-003 (WFC-P2-005):** Watch Algorithm Tests **1139/1152** — 13 routing test failures after Apnea wave; **zero FC algorithm failures**.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Multi-activity architecture | **98** | Key routing + envelope guard PASS |
| Sync / schema | **96** | Apnea isolation matrices complete |
| Security (software) | **96** | HMAC static PASS; field QA pending |
| Privacy | **98** | Manifests + export policies + cloud truthfulness |
| Performance (software) | **89** | Watch timing PASS; device profiling pending |
| iOS performance (software) | **88** | Full test lane green |
| Test coverage (automated) | **94** | iOS 1655 PASS; Watch 13 routing failures |
| **Overall MAIN software readiness** | **94** | Physical QA not counted as passed |

**Build evidence (this pass):** iOS MAIN **BUILD SUCCEEDED**, Watch MAIN **BUILD SUCCEEDED**. Preflight isolation/secrets/l10n **PASS**. Command integrity **PASS**. iOS Algorithm Tests **1655 PASS** (68.3 s). Watch Algorithm Tests **1139/1152 PASS** (658 s).

---

## B. Source Commands Merged

```text
5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md
8-DIR_DIVING_SYNC_PERSISTENCE_SCHEMA_AUDIT_V3.0.md
9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0.md
10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0.md
IOS_PERFORMANCE_OPTIMIZATION_AUDIT_COMMAND_V1.0.md
```

---

## C. Latest Development Context

| Item | Baseline |
|------|----------|
| Apnea P1/P2/P3 | `76f3703` — training compound; isolation tests PASS |
| CONS-046 V1.5 | `6a0005b` — command integrity script aligned |
| Software remediation | `7a429a7` — iOS test lane restored |
| Docs baseline | `2c30412` |
| Watch FC forensic | 0 P0; WFC-P1-001 external pending; WFC-P2-005 routing |

---

## D. Branch, Commit and Scope

```text
DIR Diving
├── Diving (Gauge + Full Computer)
├── Apnea
└── Snorkeling
```

| Item | Value |
|------|-------|
| Branch | `main` (0/0 with `origin/main`) |
| Commit | `2c30412` |
| Watch target | DIRDiving Watch App |
| iOS target | DIRDiving iOS |
| Test targets | Watch Algorithm Tests, iOS Algorithm Tests |
| Entitlements (Watch) | Shallow depth (`WithShallowDepth.entitlements`) |
| Physical Watch/iPhone/paired/Instruments | **NOT_EXECUTED** this pass |

---

## E. Preflight and Build/Test Baseline

| Check | Result |
|-------|--------|
| Branch is `main` | PASS |
| Commit `2c30412` | PASS |
| `xcodegen generate` | PASS |
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS |
| `validate_commands_for_cursor_integrity.sh` | **PASS** (V1.5) |
| iOS MAIN build | BUILD SUCCEEDED |
| Watch MAIN build | BUILD SUCCEEDED |
| iOS Algorithm Tests (iPhone 17 Pro) | **1655/1655 PASS** (68.3 s) |
| Watch Algorithm Tests (Series 11 46mm) | **1139/1152 PASS** (658 s) — 13 routing failures |

**Watch failing tests (non-FC):** `WatchWaterAutoOpenPolicyTests` (9), `WatchLaunchRoutingPolicyTests` (3), `SnorkelingRouteProgressCalculatorTests` (1).

---

## F. Target Membership and Architecture

**Verdict: PASS.** `project.yml` glob policies isolate experimental targets. Shared code in `Shared/` compiles to both platforms with activity guards. `FullComputerTargetMembershipTests` confirms FC engine on Watch.

---

## G. Activity Isolation and Cross-Activity Risk

**Verdict: PASS (software).** Diving, Apnea, and Snorkeling stores, settings namespaces, and WC payload keys are separated. `ActivitySyncCrossDecodeRejectionTests` covers six cross-route rejection paths. `IntegratedModesSequentialFlowTests` validates sequential activity flow.

**Apnea isolation:** See `MASTER_MAIN_APNEA_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`.

---

## H. Apple Watch Deep Code Analysis

**Verdict: PASS (software).** DiveManager 1 Hz FC tick with degraded-on-miss; ActionButtonIntents legal gate; simulation blocked on App Store. Water auto-open routes through predive/confirm — never live FC runtime. DepthCapabilityPolicy in `resolveAutomaticStep`. Apnea runtime isolated from FC tissues.

---

## I. iOS Companion Deep Code Analysis

**Verdict: PASS.** Planner background calculation via `PlannerBackgroundCalculation` + generation tokens. Logbook caps and lazy loading. Cloud backup Diving-only opt-in. Apnea iOS cloud stub truthful.

---

## J. Planner-Specific Deep Code Analysis

**Verdict: PASS (software).** Bühlmann planner off main thread; CCR reference-only guards; GF preset parity with Watch (CONS-002 PASS). External validation pending.

---

## K. Full Computer Runtime Integration Risk

**Verdict: PASS (software) per audit 01 cross-read.** GF frozen at predive; briefing cards reference-only; checkpoint local-only. See `MASTER_MAIN_ALGORITHMIC_SAFETY_PROTECTION_GATE_CURRENT.md`.

---

## L. Sync / Persistence / Schema

**Verdict: PASS (software).** v3 signed transport with `activityType` discriminator. Apnea/Snorkeling codecs isolated. See matrices.

---

## M. Backup / Restore Isolation

**Verdict: PASS.** Per-activity filenames, tombstone keys, cloud opt-in controls in `MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`.

---

## N. Cloud / iCloud / KVS

Diving opt-in only. Apnea Watch iCloud optional; iOS Apnea stub honest. Snorkeling local-only. Two-device merge field QA **PENDING** (CONS-029).

---

## O–P. Security / Privacy / Threat Model

**Verdict: PASS (software).** HMAC-SHA256, peer secret pinning, signed ACKs, path-sanitized briefing cards and photos, Privacy Manifests. Threat model in `MASTER_SECURITY_THREAT_MODEL_CURRENT.md`.

---

## Q–R. Import/Export / Image / Briefing Card Routing

File import bounds (CSV 10MB/200k rows). Subsurface export single-pass. Companion photos validated (10MB/16MP). Briefing cards reference-only on Watch.

---

## S. App Intents / Action Button / Developer Sensor

App Intents require legal acceptance. Developer shallow toggles default OFF; DEBUG/TestFlight visibility. Simulation sensor not default in release.

---

## T–W. Performance / iOS / Watch / Snorkeling Map

Documented budgets in performance matrices. Watch FC solver budget 50ms; 1 Hz tick DOCUMENTED_ACCEPTED_RISK. Snorkeling map downsampling to 4096 points. Device profiling **PENDING**.

---

## X–Y. Logbook Scalability / Memory

iOS dive logbook cap 40 sessions. Tissue analytics LRU cache (32). PlannerStore deinit cancels tasks (CONS-027 FIXED).

---

## Z. Concurrency / Stale Result Guards

Generation tokens on planner and sync paths. iOS sync in-flight release on errors (CONS-003 FIXED). P3: GPS confirmation Task (MAIN-P3-001).

---

## AA. Observability / Signposts

`Shared/Performance/DIRPerformanceSignpost.swift` — 24 categories including Apnea. Catalog in `MASTER_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md`.

---

## AB. Test Coverage and Evidence

See `MASTER_MAIN_REQUIREMENT_TEST_TRACEABILITY_CURRENT.csv`. iOS full lane green. Watch routing tests blocked by WFC-P2-005.

---

## AC. Physical / Instruments / External QA Pending

Physical Watch, iPhone, paired-device, underwater, Instruments, external Bühlmann, Snorkeling 12-folder QA, Apnea wet QA — **PENDING** unless signed artifacts exist.

---

## AD. Detailed Findings

| ID | Sev | Status | Summary |
|----|-----|--------|---------|
| MAIN-P1-001 | P1 | VERIFIED | Command integrity — CONS-046 V1.5 PASS |
| MAIN-P2-001 | P2 | VERIFIED | iOS test compile — CONS-049; 1655 PASS |
| MAIN-P2-003 | P2 | OPEN | WFC-P2-005 — 13 Watch routing test failures |
| MAIN-P2-002 | P2 | PENDING_PHYSICAL | Snorkeling 12 QA templates |
| MAIN-PERF-001..004 | P2 | OPEN/PENDING | Device performance profiling |
| MAIN-SEC-001 | P2 | PENDING_PHYSICAL | Paired sync security field QA |
| MAIN-WAO-002 | P2 | OPEN | Submersion probe 400ms — physical QA |
| MAIN-PERF-006..007 | P1/P2 | VERIFIED | Sync in-flight + planner deinit |
| MAIN-SYNC-002..003 | P1 | VERIFIED | Symmetric ACK + signed tombstones |
| MAIN-DEPTH-001..002 | P1 | VERIFIED | Shallow dev toggles + compile authority |
| MAIN-WAO-001 | P2 | VERIFIED | WAO DepthCapabilityPolicy gate |

Full traceability: `MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv`.

---

## AE–AG. Remediation Plans

See `MASTER_MAIN_CODE_REMEDIATION_PLAN_CURRENT.md`, `MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md`.

**Next software batch:** Align `WatchWaterAutoOpenPolicyTests` with post-Apnea `divingModeSelection` routing (MAIN-P2-003 / WFC-P2-005).

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
IOS_STARTUP_PERFORMANCE_READINESS: 74
IOS_SWIFTUI_RENDERING_READINESS: 80
IOS_PLANNER_PERFORMANCE_READINESS: 90
IOS_CHART_RENDERING_READINESS: 84
IOS_LOGBOOK_SCALABILITY_READINESS: 82
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS: 86
IOS_SYNC_PERFORMANCE_READINESS: 92
IOS_MAP_ROUTE_RENDERING_READINESS: 76
IOS_MEMORY_READINESS: 88
IOS_CONCURRENCY_READINESS: 90
IOS_BATTERY_POLICY_READINESS: 72
WATCH_RUNTIME_PERFORMANCE_READINESS: 86
WATCH_FULL_COMPUTER_TIMING_READINESS: 92
GLOBAL_SECURITY_READINESS: 96
GLOBAL_PRIVACY_READINESS: 98
GLOBAL_SYNC_SCHEMA_READINESS: 96
GLOBAL_PERFORMANCE_CONCURRENCY_BATTERY_READINESS: 88
TEST_COVERAGE_READINESS: 94
OVERALL_MAIN_CODE_READINESS: 94
P0_FINDINGS: 0
P1_FINDINGS: 0
P2_FINDINGS: 8
P3_FINDINGS: 7
PHYSICAL_WATCH_QA: PENDING_PHYSICAL
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_DEVICE_QA: PENDING_PHYSICAL
PHYSICAL_INSTRUMENTS_PROFILING: PENDING_INSTRUMENTS
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: MAIN-P2-003, MAIN-P2-002, MAIN-SEC-001, CONS-042, WFC-P1-001
MAIN_COMMAND_INTEGRITY: PASS
MAIN_SYNC_SECURITY_REMEDIATION: PASS
MAIN_DEPTH_CAPABILITY_REMEDIATION: PASS
MAIN_SOFTWARE_READINESS_AFTER_REMEDIATION: 96
```

---

## Required Final Questions (summary)

1. **Architecture clean/isolated?** YES — PASS  
2. **Diving/Apnea/Snorkeling separated?** YES — PASS  
3. **Sync payloads activity-discriminated?** YES — PASS  
4. **Schemas versioned/migration-safe?** YES — PASS  
5. **Backup/restore isolated?** YES — PASS  
6. **WC authentication intact?** YES — PASS  
7. **HMAC/nonce/ACK safe?** YES (software) — PASS; field QA pending  
8. **Import/export paths safe?** YES — PASS  
9. **Images/cards path-safe?** YES — PASS  
10. **Privacy flows truthful?** YES — PASS  
11. **Simulation/dev release-safe?** YES — PASS  
12. **App Intents respect gates?** YES — PASS  
13. **iOS Planner performance-safe?** PARTIAL — background PASS; Instruments pending  
14. **Heavy compute off main?** YES — planner PASS  
15. **Stale async rejected?** YES — generation guards PASS  
16. **Charts/maps/logbooks bounded?** YES — PASS  
17. **Sync queue backpressured?** YES — PASS  
18. **Caches bounded?** YES — PASS  
19. **Tasks cancellable?** YES — PASS  
20. **Retain-cycle risks?** PARTIAL — MAIN-P3-001  
21. **Performance budgets documented?** YES — PASS  
22. **Instruments complete?** NO — PENDING  
23. **Blocks 100% main-code readiness?** WFC-P2-005 routing tests; physical QA pending  
24. **Blocks 100% security readiness?** Paired-device field QA  
25. **Blocks 100% performance readiness?** Device profiling gaps  
26. **Blocks internal TestFlight?** Watch routing test green + physical QA packs  
27. **Blocks external TestFlight?** All physical/external QA NOT_EXECUTED
