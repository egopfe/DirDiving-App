# Master Security Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.1  
**Branch:** `main` @ `5d757cc`  
**Date:** 2026-06-28  
**Pass type:** Post-remediation audit rerun (read-only)

---

## Executive summary

Software-verifiable security posture **strong** at `5d757cc`. **All three P1 sync integrity items closed** (in-flight release, symmetric userInfo ACK, signed tombstone primary path). Remaining work: **field QA** and **documented accepted risks**.

| Severity | Open (software) | Pending physical | Documented accepted |
|----------|-----------------|------------------|---------------------|
| P0 | 0 | 0 | 0 |
| P1 | 0 | 0 | 1 (legacy tombstone bootstrap mirror P3) |
| P2 | 0 | 2 | 0 |
| P3 | 0 | 0 | 2 |

---

## Closed P1 (verified @ 5d757cc)

| ID | Topic | Remediation verified |
|----|-------|---------------------|
| MASTER-SYNC-002 / CONS-004 | userInfo ACK asymmetry | `sendDiveImportAckToWatch` on iOS `didReceiveUserInfo` |
| MASTER-SYNC-003 / CONS-005 | Tombstone HMAC | Signed primary via `ActivitySyncTombstoneBroadcast.verifiedSessionIDs` |
| MASTER-PERF-006 / CONS-003 | Sync queue stuck | `releaseInFlightOutboundSession` on all error paths |
| MASTER-DEPTH-001 / CONS-006 | Shallow FC dev toggles | Default OFF; TestFlight opt-in |
| MASTER-DEPTH-002 / CONS-007 | Depth tier authority | `runtimeAuthorityTier` compile flags |

---

## Closed findings (verified)

| ID | Topic | Status | Evidence |
|----|-------|--------|----------|
| SEC-P1-001 | Privacy manifests | FIXED | PrivacyInfo-Watch/iOS.xcprivacy |
| SEC-P2-004 | Simulation release safety | FIXED | TestFlightSimulationSafetyPolicy |
| SEC-P2-005 | Protected sync queues | FIXED | ProtectedSensitiveFileStore |
| INFO-06 | App Intent legal gate | PASS | ActionButtonIntents |
| INFO-09 | Water auto-open predive gate | PASS | DIRModesAndStartupFlowTests |

---

## Pending physical (P2)

| ID | Topic |
|----|-------|
| MASTER-SEC-001 | Paired tombstone/HMAC/replay field verification |
| MASTER-SYNC-001 | Large payload paired round-trip |

---

## Documented accepted risks (P3)

| ID | Topic |
|----|-------|
| MASTER-SEC-002 | TOFU peer secret via WC applicationContext |
| MASTER-DEPTH-003 | DEBUG depth API bypass |
| MASTER-SYNC-003-residual | Legacy diving UUID tombstone bootstrap mirror when peer secret absent |

---

**Remediation sequencing:** P1 sync/depth closed; execute field SEC-NEG matrix; maintain TOFU documentation.
