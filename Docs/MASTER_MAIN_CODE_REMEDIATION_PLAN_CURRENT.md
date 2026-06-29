# Master Main Code Remediation Plan (Current)

**Audit command:** 04 — MASTER MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT V1.1  
**Branch:** `main` @ `5d757cc`  
**Date:** 2026-06-28  
**Pass type:** Post-remediation audit rerun (read-only)

---

## Executive summary

Post-remediation re-audit at `5d757cc` confirms **all five prior P1 software findings (CONS-003–007 / MASTER-PERF-006, SYNC-002, SYNC-003, DEPTH-001, DEPTH-002) are VERIFIED** in code and automated test lanes. **Nine P2** findings remain open (physical QA + WAO policy + planner lifecycle).

| Category | Software readiness | Blocker for internal TestFlight |
|----------|-------------------|--------------------------------|
| Architecture / isolation | 97% | No |
| Sync / schema | 96% | No (P1 closed) |
| Security / privacy | 97% | No (P1 closed) |
| Performance (software) | 90% | P2 planner lifecycle |
| Depth / developer gates | 96% | Process QA pending only |
| Test coverage (automated) | 96% | Physical matrices |

---

## Priority 0 — None open

No cross-activity corruption, HMAC bypass, water-auto-open live-runtime bypass, or simulation-in-release defects at `5d757cc`.

---

## Priority 1 — Closed (verified @ 5d757cc)

| ID | Finding | Remediation verified | Evidence |
|----|---------|---------------------|----------|
| MASTER-PERF-006 / CONS-003 | iOS sync in-flight stuck | `releaseInFlightOutboundSession` on bad ACK, sendMessage error, encode error | Code review; sync remediation test lane PASS |
| MASTER-SYNC-002 / CONS-004 | Watch→iOS userInfo ACK gap | `sendDiveImportAckToWatch` after `importSessionPayload` in `didReceiveUserInfo` | Code review 5d757cc |
| MASTER-SYNC-003 / CONS-005 | Legacy unsigned tombstones | Signed primary via `ActivitySyncTombstoneBroadcast.verifiedSessionIDs`; bootstrap mirror P3 | ActivitySyncTombstoneTests PASS |
| MASTER-DEPTH-001 / CONS-006 | Shallow FC internal exposure | `resolvedShallowTestingFlag` default OFF; DEBUG/TestFlight-only | `validate_developer_shallow_testing_release_gate.sh` PASS |
| MASTER-DEPTH-002 / CONS-007 | Tier metadata trust | `runtimeAuthorityTier` + `DEPTH_ENTITLEMENT_SHALLOW` compile authority | `validate_depth_capability_runtime_authority.sh` PASS |

---

## Priority 2 — Open

| ID | Finding | Remediation |
|----|---------|-------------|
| MASTER-PERF-001..004 | Physical battery/sync/scroll/map | Execute `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` |
| MASTER-SEC-001 | Field sync security | Paired-device SEC-NEG matrix |
| MASTER-SYNC-001 | Large payload field | Paired 5MB round-trip |
| MASTER-WAO-001 | Water FC policy skip | Apply `DepthCapabilityPolicy` before FC water routing |
| MASTER-WAO-002 | Probe timeout | Physical submerged launch QA; evaluate adaptive timeout |
| MASTER-PERF-007 | Planner lifecycle | Cancel tasks in `deinit`; move `refreshAnalysis` off main |

---

## Priority 3 — Monitor / profiling

- MASTER-IOS-001/002 — Instruments startup and map profiling
- MASTER-PERF-005, MASTER-SEC-002, MASTER-DEPTH-003, MASTER-WAO-DOC — documented accepted risks
- Legacy diving UUID tombstone bootstrap mirror — P3 compat only

---

## Priority 4 — Positive controls (maintain)

INFO-01..10 — no action; regression tests on touch.

---

## Sequencing (updated)

1. **Complete:** P1 sync + depth fixes (CONS-003–007).
2. **Week 1–2:** WAO policy alignment (WAO-001); planner lifecycle (PERF-007).
3. **Week 2–3:** Physical QA plan execution.
4. **Ongoing:** Instruments profiling; external validation per roadmap.

---

**No production changes in this audit pass.** P1 software remediation verified; P2 physical/process gates remain.
