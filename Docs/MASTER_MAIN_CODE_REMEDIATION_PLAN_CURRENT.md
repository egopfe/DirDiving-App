# DIR DIVING — Master Main Code Remediation Plan (Current)

**Audit:** 04 @ `2c30412` | **Date:** 2026-07-01

## Priority 0 — None

No open P0 software findings at `2c30412`. Audit 01 FC math: 0 P0.

## Priority 1 — None (software)

All P1 software remediations verified (CONS-003..007, CONS-046, CONS-049). Remaining P1 items are **PENDING_PHYSICAL** or **PENDING_EXTERNAL_VALIDATION** (WFC-P1-001, CONS-042).

## Priority 2 — Before full test suite green + TestFlight confidence

| ID | Action | Owner lane | Acceptance |
|----|--------|------------|------------|
| MAIN-P2-003 | Align `WatchWaterAutoOpenPolicyTests` / `WatchLaunchRoutingPolicyTests` with post-Apnea `divingModeSelection` routing (WFC-P2-005) | Tests | 1152/1152 Watch tests PASS |
| MAIN-P2-002 | Execute 12 `SNORKELING_*` physical QA folders with signed artifacts | QA | 12/12 PASS with device IDs |
| MAIN-PERF-001..004 | Run `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` on hardware | QA | Instruments/Energy logs attached |
| MAIN-SEC-001 | Paired-device tombstone/HMAC/large-payload field matrix | QA | SEC-NEG field pack signed |
| MAIN-WAO-002 | Submerged cold-launch physical QA | QA | WATCH_WATER_AUTO_OPEN artifacts |
| MAIN-APNEA-001 | Apnea wet auto-detection physical QA | QA | Signed Apnea field artifacts |

## Priority 3 — Maintainability / observability

| ID | Action | Acceptance |
|----|--------|------------|
| MAIN-P3-001 | Cancel DiveManager GPS confirmation Task on dive end | Lifecycle test |
| MAIN-IOS-001/002 | Instruments startup/map profiling | BUD-IOS budgets measured |
| MAIN-SYNC-004 | Document legacy diving tombstone bootstrap mirror policy | Docs only |
| SnorkelingRouteProgressCalculatorTests | Fix `testProgressAtStartIsNearZero` tolerance or fixture | 1 test green |

## Verified — do not regress

CONS-001/046 command integrity, CONS-003 in-flight release, CONS-004 symmetric ACK, CONS-005 signed tombstones, CONS-006/007 depth gating, CONS-019 WAO policy, CONS-027 planner deinit, CONS-049 iOS test lane, Apnea sync/schema isolation.
