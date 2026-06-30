# DIR DIVING — Master Main Code / Sync / Security / Performance Audit (Current)

**Command:** 04 — `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.2`  
**Date:** 2026-06-30  
**Branch:** `main`  
**Commit:** `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958`)  
**Pass type:** Full read-only audit rerun @ orchestrator V1.3 baseline  
**Task type:** Audit-only — read-only; no production changes  
**Xcode:** 26.6 (Build 17F113)

**Merged source commands:** 5 (deep code), 8 (sync/persistence/schema), 9 (security/privacy/trust), 10 (performance/concurrency/battery), iOS performance optimization.

**4A scope included:** Full Computer GF presets, shallow-depth entitlement resolution, water auto-open wiring, developer settings, sync/HMAC, concurrency, **Snorkeling P1/P2/P3 route/session sync**.

**Not claimed:** Physical Watch/iPhone QA, paired-device field sync, underwater validation, Instruments profiling on hardware, penetration testing, App Store approval, external Bühlmann/CCR certification.

---

## A. Executive Summary

This master audit re-evaluates the entire MAIN codebase (Watch + iOS) for Diving (Gauge + Full Computer), Apnea, and Snorkeling at commit **`451f8fb`**.

**Software architecture and activity isolation remain strong.** Activity-scoped logbooks, settings, sync payload keys, signed HMAC v3 envelopes, activity tombstones, cloud backup truthfulness, and Snorkeling route/session codecs are implemented with cross-decode rejection tests (where the iOS test target compiles).

**Cross-cutting remediations CONS-003–007, CONS-019, CONS-027 verified in code.** No P0 software safety bypass identified.

**Two software gates block full PASS:**

1. **MAIN-P1-001:** `validate_commands_for_cursor_integrity.sh` references superseded command filenames (V2.1/V1.1) — exits **FAIL** @ 451f8fb (CONS-046).
2. **MAIN-P2-001:** iOS Algorithm Tests target **compile failure** in `SnorkelingRouteProfileTests` blocks automated regression lane including Snorkeling sync tests.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Multi-activity architecture | **97** | Key routing + envelope guard PASS |
| Sync / schema | **95** | SnorkelingRouteSyncCodec v1 PASS static; iOS test compile blocked |
| Security (software) | **96** | HMAC static PASS; field QA pending |
| Privacy | **98** | Manifests + export policies + cloud truthfulness |
| Performance (software) | **89** | Watch timing PASS; device profiling pending |
| iOS performance (software) | **85** | Background planner PASS; test gate blocked |
| Test coverage (automated) | **88** | Watch subset PASS; iOS lane blocked by compile |
| **Overall MAIN software readiness** | **91** | Physical QA not counted as passed |

**Build evidence (this pass):** iOS MAIN **BUILD SUCCEEDED**, Watch MAIN **BUILD SUCCEEDED**. Preflight isolation/secrets/l10n **PASS**. Watch remediation subset **8 tests PASS**. iOS remediation subset **BLOCKED** (compile). Command integrity script **FAIL**.

---

## B–D. Source Commands / Context / Scope

See merged commands list in command file. Product architecture:

```text
DIR Diving
├── Diving (Gauge + Full Computer)
├── Apnea
└── Snorkeling
```

| Item | Value |
|------|-------|
| Branch | `main` (aligned with `origin/main`) |
| Commit | `451f8fb` |
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
| Commit `451f8fb` | PASS |
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS |
| `validate_commands_for_cursor_integrity.sh` | **FAIL** (stale paths) |
| iOS MAIN build | BUILD SUCCEEDED |
| Watch MAIN build | BUILD SUCCEEDED |
| Watch algorithm remediation subset | 8 tests PASS |
| iOS algorithm remediation subset | BLOCKED — compile fail |

---

## F–G. Architecture and Activity Isolation

**Verdict: PASS (software).** Diving, Apnea, and Snorkeling stores, settings namespaces, and WC payload keys are separated. `ActivitySyncCrossDecodeRejectionTests` matrix covers six cross-route rejection paths. `IntegratedModesSequentialFlowTests` validates sequential activity flow without shared mutable bleed.

Snorkeling additions @ 451f8fb:

- Session sync: `SnorkelingSessionSyncCodec` v3 + `dirdiving_snorkeling_session_sync`
- Route sync: `SnorkelingRouteSyncCodec` v1 + `snorkelingRoutePackage` userInfo transfer
- Logbook/checkpoint files activity-scoped per `MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`

---

## H–K. Watch / iOS / Planner / Full Computer

**Watch:** DiveManager 1Hz FC tick with degraded-on-miss policy; ActionButtonIntents legal gate; simulation blocked on App Store via `TestFlightSimulationSafetyPolicy`. **Water auto-open** routes through predive/confirm — never live FC runtime. **DepthCapabilityPolicy** applied in `resolveAutomaticStep` for water routing (CONS-019 FIXED).

**iOS:** Planner background calculation via `PlannerBackgroundCalculation` + generation tokens. Logbook caps and lazy loading present. Cloud backup Diving-only opt-in via `CloudBackupCapability`.

**Full Computer GF:** Watch preset-only; frozen at predive confirm; iOS plan GF override with fail-closed invalid pairs — see GF matrix.

---

## L. Sync / Persistence / Schema

**Verdict: PASS (software) / PARTIAL (automated evidence).**

- v3 signed transport with `activityType` discriminator for Diving/Apnea/Snorkeling sessions
- `SnorkelingRouteSyncCodec`: schema v1, SHA-256 checksum, TTL, route plan validation, capabilities bounds
- Large payload file transfer helper for >512KB packages
- Tombstones: signed per-activity keys; diving legacy UUID mirror bootstrap-only (P3)

See `MASTER_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv` and `MASTER_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv`.

---

## M. Backup / Restore Isolation

**Verdict: PASS.** Per-activity filenames, tombstone keys, and cloud opt-in controls documented in `MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`. Apnea/Snorkeling iOS cloud upload blocked with truthful UI stubs.

---

## N. Cloud / iCloud / KVS

Diving opt-in only. Apnea Watch iCloud optional; iOS Apnea stub honest. Snorkeling local-only cloud policy. Two-device merge field QA **PENDING** (CONS-029).

---

## O–P. Security / Privacy / Threat Model

**Verdict: PASS (software).** HMAC-SHA256 authenticated sync, peer secret pinning, signed ACKs, path-sanitized briefing cards and photos, Privacy Manifests on both targets. Threat model in `MASTER_SECURITY_THREAT_MODEL_CURRENT.md`. No penetration test executed.

---

## Q–R. Import/Export / Image / Briefing Card Routing

File import bounds (CSV 10MB/200k rows). Subsurface export single-pass. Companion photos validated (10MB/16MP). Briefing cards reference-only on Watch — no live runtime mutation.

---

## S. App Intents / Action Button / Developer Sensor

App Intents require legal acceptance for safety paths. Developer shallow Gauge/FC toggles default OFF; DEBUG/TestFlight visibility only. Simulation sensor not default in release builds.

---

## T–W. Performance / iOS / Watch / Snorkeling Map

Documented budgets in performance matrices. Watch FC solver budget 50ms; 1Hz tick DOCUMENTED_ACCEPTED_RISK. Snorkeling map downsampling to 4096 presentation points. Device Instruments profiling **PENDING** for logbook scroll, map FPS, long FC battery.

---

## X–Y. Logbook Scalability / Memory

iOS dive logbook cap 40 sessions with lazy list. Tissue analytics LRU cache (32). PlannerStore deinit cancels tasks (CONS-027 FIXED).

---

## Z. Concurrency / Stale Result Guards

Generation tokens on planner and sync paths. iOS sync in-flight session release on errors (CONS-003 FIXED). Remaining P3: GPS confirmation Task lifecycle (MAIN-P3-001).

---

## AA. Observability / Signposts

`Shared/Performance/DIRPerformanceSignpost.swift` provides categorized signposts. Catalog in `MASTER_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md`. No CI wall-clock enforcement.

---

## AB. Test Coverage and Evidence

See `MASTER_MAIN_REQUIREMENT_TEST_TRACEABILITY_CURRENT.csv`. **Blocker:** iOS test target compile failure prevents running Snorkeling route/sync regression suite until MAIN-P2-001 fixed.

---

## AC. Physical / Instruments / External QA Pending

All physical Watch, iPhone, paired-device, underwater, Instruments, and external Bühlmann validation gates remain **PENDING** unless signed artifacts exist. Snorkeling 12-folder physical QA gate **PENDING** (CONS-048).

---

## AD. Detailed Findings

| ID | Sev | Status | Summary |
|----|-----|--------|---------|
| MAIN-P1-001 | P1 | OPEN | Command integrity script stale filenames |
| MAIN-P2-001 | P2 | OPEN | iOS SnorkelingRouteProfileTests compile blocks test gate |
| MAIN-P2-002 | P2 | PENDING_PHYSICAL | Snorkeling 12 QA templates not executed |
| MAIN-PERF-001..004 | P2 | OPEN/PENDING | Device performance profiling gaps |
| MAIN-SEC-001 | P2 | PENDING_PHYSICAL | Paired sync security field QA |
| MAIN-WAO-002 | P2 | OPEN | Submersion probe 400ms timeout — physical QA |
| MAIN-PERF-006..007 | P1/P2 | VERIFIED | Sync in-flight + planner deinit remediated |
| MAIN-SYNC-002..003 | P1 | VERIFIED | Symmetric ACK + signed tombstones |
| MAIN-DEPTH-001..002 | P1 | VERIFIED | Shallow dev toggles + compile authority |
| MAIN-WAO-001 | P2 | VERIFIED | WAO DepthCapabilityPolicy gate |

Full traceability: `MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv`.

---

## AE. Readiness Matrix

See final verdict block below.

---

## AF–AG. Remediation Plans

Prioritized plans in `MASTER_MAIN_CODE_REMEDIATION_PLAN_CURRENT.md` and `MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md`.

**Immediate software batches:**

1. Update `validate_commands_for_cursor_integrity.sh` to V2.2/V1.2/V2.3 paths (MAIN-P1-001)
2. Repair `SnorkelingRouteProfileTests` / `SnorkelingDistanceCalculatorTests` fixtures (MAIN-P2-001)
3. Execute physical QA matrices without fabricating evidence

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
IOS_STARTUP_PERFORMANCE_READINESS: 72
IOS_SWIFTUI_RENDERING_READINESS: 78
IOS_PLANNER_PERFORMANCE_READINESS: 88
IOS_CHART_RENDERING_READINESS: 82
IOS_LOGBOOK_SCALABILITY_READINESS: 80
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS: 85
IOS_SYNC_PERFORMANCE_READINESS: 90
IOS_MAP_ROUTE_RENDERING_READINESS: 75
IOS_MEMORY_READINESS: 86
IOS_CONCURRENCY_READINESS: 88
IOS_BATTERY_POLICY_READINESS: 70
WATCH_RUNTIME_PERFORMANCE_READINESS: 85
WATCH_FULL_COMPUTER_TIMING_READINESS: 92
GLOBAL_SECURITY_READINESS: 96
GLOBAL_PRIVACY_READINESS: 98
GLOBAL_SYNC_SCHEMA_READINESS: 95
GLOBAL_PERFORMANCE_CONCURRENCY_BATTERY_READINESS: 87
TEST_COVERAGE_READINESS: 88
OVERALL_MAIN_CODE_READINESS: 91
P0_FINDINGS: 0
P1_FINDINGS: 1
P2_FINDINGS: 9
P3_FINDINGS: 7
PHYSICAL_WATCH_QA: PENDING_PHYSICAL
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_DEVICE_QA: PENDING_PHYSICAL
PHYSICAL_INSTRUMENTS_PROFILING: PENDING_INSTRUMENTS
EXTERNAL_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: MAIN-P1-001, MAIN-P2-001
MAIN_COMMAND_INTEGRITY: FAIL
MAIN_SYNC_SECURITY_REMEDIATION: PASS
MAIN_DEPTH_CAPABILITY_REMEDIATION: PASS
MAIN_SOFTWARE_READINESS_AFTER_REMEDIATION: 92
```

---

## Required Final Questions (summary)

1. **Architecture clean/isolated?** YES (software) — PASS  
2. **Diving/Apnea/Snorkeling separated?** YES — PASS  
3. **Sync payloads activity-discriminated?** YES — PASS  
4. **Schemas versioned/migration-safe?** YES — PASS (SnorkelingRouteSyncCodec v1 fail-closed)  
5. **Backup/restore isolated?** YES — PASS  
6. **WC authentication intact?** YES — PASS  
7. **HMAC/nonce/ACK safe?** YES (software) — PASS; field QA pending  
8. **Import/export paths safe?** YES — PASS  
9. **Images/cards path-safe?** YES — PASS  
10. **Privacy flows truthful?** YES — PASS  
11. **Simulation/dev release-safe?** YES — PASS  
12. **App Intents respect gates?** YES — PASS  
13. **iOS Planner performance-safe?** PARTIAL — background calc PASS; Instruments pending  
14. **Heavy compute off main?** PARTIAL — planner PASS; map build monitor  
15. **Stale async rejected?** YES — generation guards PASS  
16. **Charts/maps/logbooks bounded?** YES — caps/downsampling PASS  
17. **Sync queue backpressured?** YES — flush policy PASS  
18. **Caches bounded?** YES — LRU/caps PASS  
19. **Tasks cancellable?** YES — planner deinit PASS  
20. **Retain-cycle risks?** PARTIAL — MAIN-P3-001 GPS Task  
21. **Performance budgets documented?** YES — matrices present  
22. **Instruments complete?** NO — PENDING_INSTRUMENTS  
23. **Blocks 100% main-code readiness?** MAIN-P1-001, MAIN-P2-001, physical QA pending  
24. **Blocks 100% security readiness?** Paired-device field QA (MAIN-SEC-001)  
25. **Blocks 100% performance readiness?** Device profiling gaps (MAIN-PERF-001..004)  
26. **Blocks internal TestFlight?** MAIN-P1-001 script gate; MAIN-P2-001 test compile  
27. **Blocks external TestFlight?** All physical/external QA templates NOT_EXECUTED
