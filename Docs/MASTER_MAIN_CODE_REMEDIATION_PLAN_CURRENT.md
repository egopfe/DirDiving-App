# Master Main Code Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Branch:** `main` @ `1f62235`  
**Date:** 2026-06-22

---

## Executive summary

Re-audit of `main` @ `1f62235` consolidates five merged audit scopes. **No open P0 or P1 software defects** were identified. Prior remediations (deep code, sync/schema, security/privacy, performance/concurrency, iOS performance) are **present and verified** in source at this commit.

Remaining gaps are **physical QA**, **Instruments profiling**, and **external validation** — not implementation defects.

| Category | Software readiness | Blocker for external TestFlight |
|----------|-------------------|--------------------------------|
| Architecture / isolation | 100% | No |
| Sync / schema | 95% | Field tombstone/large-payload QA |
| Security / privacy | 98% | Paired-device SEC-NEG field |
| Performance (software) | 92% | Instruments + battery field |
| Test coverage (automated) | 95% | Physical matrices |

---

## Priority 0 — None open

No cross-activity corruption, HMAC bypass, simulation-in-release, or safety-critical stale-async defects found open at `1f62235`.

---

## Priority 1 — None open (software)

All prior P1 items closed including:

- Activity-scoped tombstones (`ActivitySyncTombstoneBroadcast`)
- Cloud backup truthfulness (`CloudBackupCapability`)
- iOS planner MainActor blocking (`PlannerBackgroundCalculation`)
- Sync backpressure (`WatchSyncPendingFlushPolicy` on iOS)
- Cross-decode rejection tests (`ActivitySyncCrossDecodeRejectionTests`)

---

## Priority 2 — Field QA (no code fix in this audit)

| ID | Action | Command / doc | Owner |
|----|--------|---------------|-------|
| MASTER-PERF-001 | Ultra 2-4h FC battery/thermal | MASTER_PHYSICAL_PERFORMANCE_QA_PLAN PHYS-W-FC-01/02 | QA |
| MASTER-PERF-002 | Paired sync under load | PHYS-PAIR-01/04 | QA |
| MASTER-PERF-003 | iPhone logbook scroll at cap | PHYS-I-03 | QA |
| MASTER-PERF-004 | Snorkeling long-route map | PHYS-W-SN-01/02, PHYS-I-04 | QA |
| MASTER-SEC-001 | Paired security matrix | SEC-NEG field + PHYS-PAIR-02 | QA |
| MASTER-SYNC-001 | Large payload file transfer | PHYS-PAIR-03 | QA |

---

## Priority 3 — Observability / accepted risks

| ID | Action | Type |
|----|--------|------|
| MASTER-IOS-001 | Cold-start Instruments profile | Profiling |
| MASTER-IOS-002 | Map Instruments profile | Profiling |
| MASTER-PERF-005 | Monitor FC solver budget regression | Accepted risk |
| MASTER-SEC-002 | Maintain TOFU documentation | Accepted risk |

---

## Priority 4 — Informational

- INFO-01..08 positive controls — maintain via regression gates
- MAIN-DCA-018 — populate QA_EVIDENCE when physical QA runs
- MAIN-DCA-032 — deferred reminder visibility indicator (product decision)

---

## Recommended remediation command sequence

1. **Physical paired-device QA command** — execute MASTER_PHYSICAL_PERFORMANCE_QA_PLAN (read-only evidence).
2. **Instruments iOS profiling command** — BUD-IOS-001/002/016 wall-clock capture.
3. **External Bühlmann/CCR validation command** — reference oracle only (no math changes).

---

## Non-regression requirements

Any future remediation MUST preserve:

- HMAC v3 envelope integrity
- Activity payload key isolation
- Signed import ACK dequeue policy
- Full Computer degraded-not-reset tick policy
- Diving-only cloud opt-in truthfulness
- App Store simulation block

---

## Validation after any fix

```bash
./Scripts/validate_master_main_code_sync_security_performance_audit.sh
./Scripts/validate_security_privacy_trust_readiness.sh
./Scripts/validate_ios_performance_readiness.sh
./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh
```

---

**No production code changes from this audit pass.**
