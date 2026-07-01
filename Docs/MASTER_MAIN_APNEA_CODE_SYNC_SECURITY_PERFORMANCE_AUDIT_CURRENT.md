# Master Main Code — Apnea Sync / Security / Performance Audit (Current)

**Command:** 04 — V1.5 Apnea first-class scope  
**Date:** 2026-07-01  
**Branch:** `main`  
**Commit:** `2c30412`  
**Apnea wave baseline:** `76f3703` (P1/P2/P3 training compound features)  
**Task type:** Read-only cross-cutting audit (Apnea isolation within main audit)

---

## Executive summary

Apnea is audited as a **first-class activity** with separate logbook, settings, sync namespace, checkpoint files, and privacy posture. **No decompression wording, GF, gas, MOD, or PPO2** appear in Apnea production paths reviewed. Cross-decode rejection tests confirm Diving and Snorkeling payloads **cannot** ingest into Apnea stores.

**Verdict:** **PASS (software)** — isolation intact; physical wet/auto-detection QA **PENDING**.

| Area | Verdict |
|------|---------|
| Code / store isolation | PASS |
| Settings ownership | PASS |
| Logbook ownership | PASS |
| Sync namespace isolation | PASS |
| Schema migration | PASS |
| Privacy / data flow | PASS |
| Performance / concurrency | PASS (simulator) |
| Physical wet QA | PENDING_PHYSICAL |

---

## Scope verified

- Apnea root/dashboard, live session, auto-detection, depth/time profile, descent/ascent metrics
- Surface interval, recovery countdown, targets, alarms, markers
- Statistics, records, logbook ownership, settings ownership
- iOS Settings mode switch, Watch in-mode settings
- Water auto-open routing (does **not** auto-start session)
- Action Button / Digital Crown policy (router-only; no deco)
- Sync/persistence/schema isolation
- Apnea P1/P2/P3 @ `76f3703` — training compound features; architecture isolation tests **PASS**

---

## Mandatory truthfulness

| Claim | Status |
|-------|--------|
| No decompression wording in Apnea | **PASS** — `ApneaTruthfulnessCopyTests` |
| No GF/gas/MOD/PPO2 in Apnea | **PASS** — settings namespace isolated |
| No medical guarantee for recovery | **PASS** — copy reviewed |
| Auto-detection physically validated | **NOT CLAIMED** — PENDING_PHYSICAL |
| Water auto-open starts Apnea session | **NOT CLAIMED** — routes to ready, not live start |
| Cross-activity logbook leakage | **REJECTED** — `ActivitySyncCrossDecodeRejectionTests` |

---

## Sync / schema isolation

See `MASTER_APNEA_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv` and `MASTER_APNEA_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv`.

- Payload key: `dirdiving_apnea_session`
- Tombstones: `dirdiving_deleted_apnea_session_tombstones`
- Plan transfer: `apneaSyncPlanPackage` / `dirdiving_apnea_plan_snapshot` — isolated from FC `fullComputerPlanPackage`
- HMAC v3 envelope with `activityType=apnea`
- Apnea checkpoint: `dirdiving_apnea_session_checkpoint.json` — not merged into Diving FC checkpoint

---

## Security / privacy

See `MASTER_APNEA_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv`.

- Session metrics local + optional Watch iCloud
- iOS Apnea cloud upload **blocked** with truthful stub (`ApneaCloudBackupStubTruthfulnessTests`)
- Recovery intervals treated as health-like — no third-party export without user action
- No exact-coordinate requirement (Apnea is depth/time focused)

---

## Performance / concurrency

See `MASTER_APNEA_PERFORMANCE_CONCURRENCY_MATRIX_CURRENT.csv`.

- 1 Hz tick with cancellable `Task` on session end
- 250 ms checkpoint debounce
- Signposts: `apnea_sample_process`, `apnea_checkpoint`
- Device battery profiling **PENDING_INSTRUMENTS**

---

## Water auto-open boundary (WFC-P2-005 cross-read)

After Apnea P1/P2/P3, **13 Watch routing tests fail** because startup inserts `divingModeSelection` before direct ready/predive destinations. Production routing does **not** auto-start Apnea sessions; failures are **test alignment**, not Apnea store corruption. See `MASTER_WATCH_APNEA_WATER_AUTO_OPEN_BOUNDARY_MATRIX_CURRENT.csv`.

---

## Findings (Apnea-specific in main audit)

| ID | Sev | Status | Summary |
|----|-----|--------|---------|
| MAIN-APNEA-001 | P2 | PENDING_PHYSICAL | Apnea auto-detection wet QA not executed |
| MAIN-APNEA-002 | P2 | OPEN | WFC-P2-005 routing test drift affects Apnea preferred-destination tests |
| MAIN-APNEA-003 | P3 | DOCUMENTED_ACCEPTED_RISK | iOS Apnea iCloud stub — by design (CONS-039) |

---

## Verdict

```text
MAIN_APNEA_CODE_SYNC_SECURITY_PERFORMANCE: PASS (software)
APNEA_ACTIVITY_ISOLATION: PASS
APNEA_SYNC_SCHEMA_ISOLATION: PASS
APNEA_SETTINGS_LOGBOOK_OWNERSHIP: PASS
APNEA_PRIVACY_TRUTHFULNESS: PASS
APNEA_PHYSICAL_WET_QA: PENDING_PHYSICAL
P0_FINDINGS: 0
P1_FINDINGS: 0
P2_FINDINGS: 2
P3_FINDINGS: 1
```
