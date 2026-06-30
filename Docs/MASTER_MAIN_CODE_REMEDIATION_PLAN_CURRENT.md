# DIR DIVING — Master Main Code Remediation Plan (Current)

**Audit:** 04 @ `451f8fb` | **Date:** 2026-06-30

## Priority 0 — None

No open P0 software findings at `451f8fb`.

## Priority 1 — Before next trustworthy audit rerun

| ID | Action | Owner lane | Acceptance |
|----|--------|------------|------------|
| MAIN-P1-001 | Update `Scripts/validate_commands_for_cursor_integrity.sh` to reference V2.2/V1.2/V2.3 command filenames | Docs/scripts | Script exit 0 @ HEAD |

## Priority 2 — Before internal TestFlight confidence

| ID | Action | Owner lane | Acceptance |
|----|--------|------------|------------|
| MAIN-P2-001 | Fix `SnorkelingRouteProfileTests` / `SnorkelingDistanceCalculatorTests` to match `SnorkelingRoutePlannerDraft` API | Tests | iOS Algorithm Tests compile + SnorkelingRouteSyncCodecTests PASS |
| MAIN-P2-002 | Execute 12 `SNORKELING_*` physical QA folders with signed artifacts | QA | 12/12 PASS with device IDs |
| MAIN-PERF-001..004 | Run `MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md` scenarios on hardware | QA | Instruments/Energy logs attached |
| MAIN-SEC-001 | Paired-device tombstone/HMAC/large-payload field matrix | QA | SEC-NEG field pack signed |
| MAIN-WAO-002 | Submerged cold-launch physical QA | QA | WATCH_WATER_AUTO_OPEN artifacts |

## Priority 3 — Maintainability / observability

| ID | Action | Acceptance |
|----|--------|------------|
| MAIN-P3-001 | Cancel DiveManager GPS confirmation Task on dive end | Lifecycle test |
| MAIN-IOS-001/002 | Instruments startup/map profiling | BUD-IOS budgets measured |
| MAIN-SYNC-004 | Document legacy diving tombstone bootstrap mirror policy | Docs only |

## Verified — do not regress

CONS-003 in-flight release, CONS-004 symmetric ACK, CONS-005 signed tombstones, CONS-006/007 depth gating, CONS-019 WAO policy, CONS-027 planner deinit cancel.
