# Master Security Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.0  
**Branch:** `main` @ `7dfefe2`  
**Date:** 2026-06-28

---

## Executive summary

Software-verifiable security posture remains **strong** at `7dfefe2`. **Three P1** items affect sync integrity policy (in-flight stuck, ACK asymmetry, legacy tombstones). Remaining work includes **field QA** and **documented accepted risks**.

| Severity | Open (software) | Pending physical | Documented accepted |
|----------|-----------------|------------------|---------------------|
| P0 | 0 | 0 | 0 |
| P1 | 3 | 0 | 2 (depth process) |
| P2 | 0 | 2 | 0 |
| P3 | 0 | 0 | 2 |

---

## Open P1 (software)

| ID | Topic | Remediation |
|----|-------|-------------|
| MASTER-SYNC-002 | userInfo ACK asymmetry | Symmetric import-ACK on iOS userInfo path |
| MASTER-SYNC-003 | Legacy unsigned tombstones | Require signed tombstones; deprecate UUID list |
| MASTER-PERF-006 | Sync queue stuck (security-adjacent) | Clear in-flight on all error paths |

## Open P1 (process / depth)

| ID | Topic | Remediation |
|----|-------|-------------|
| MASTER-DEPTH-001 | Shallow FC on shallow build | TestFlight process + labeling |
| MASTER-DEPTH-002 | Tier metadata trust | CI signing manifest validation |

---

## Closed findings (verified at 7dfefe2)

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

---

**Remediation sequencing:** Sync P1 items first; then field SEC-NEG matrix; maintain TOFU documentation.
