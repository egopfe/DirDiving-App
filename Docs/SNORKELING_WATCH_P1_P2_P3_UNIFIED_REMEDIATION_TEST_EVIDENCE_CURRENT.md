# Snorkeling Watch P1/P2/P3 — Unified Remediation Test Evidence

**Date:** 2026-06-17  
**Baseline:** `1272885` (audit) → remediation commit (see IMPLEMENTATION_REPORT)

## New tests

| Test file | Remediation | Cases |
|-----------|-------------|-------|
| `SnorkelingWatchRuntimeBatteryTests` | R1-003 | Policy mapping; runtime store wiring; unknown UI copy |
| `SnorkelingPendingRouteQueuePersistenceTests` | R1-007 | Round-trip; corrupt ignore; namespace; restore; ACK clear |
| `SnorkelingSessionLogbookSyncPresentationTests` | R1-005, R1-006 | Source labels; pending/failed badges; aggregate failure |

## Updated tests

| Test file | Remediation | Change |
|-----------|-------------|--------|
| `SnorkelingWatchUIViewContractTests` | R2-001, R2-005 | `returnIsPrimaryAction`; `routeCompactSummaryText` |
| `SnorkelingWatchReturnPrimaryActionTests` | R2-001 | Existing policy tests retained |
| `SnorkelingWatchReadyRoutePresentationTests` | R1-004 | Pending banner + a11y key |
| `IOSSnorkelingUIViewContractTests` | R1-001, R1-005, R2-002, R3-002 | Logbook sync; disclaimer; settings banner; stale revision |
| `SnorkelingRouteAckRoundTripTests` | R1-007 | Uses persistence-aware `testing_reset` |

## Existing suites (non-regression)

- `SnorkelingArchitectureIsolationTests`
- `SnorkelingCrossDomainIsolationTests`
- `SnorkelingReleaseHardValidationTests`
- `SnorkelingP3NoRegressionTests`

## Execution

See IMPLEMENTATION_REPORT section O for build/test/script results recorded at commit time.

## QA truthfulness

No manual, physical, paired-device, or open-water QA marked PASS. E2E harness documented only under `Docs/QA_EVIDENCE/SNORKELING_ROUTE_PUSH/PROCEDURE.md`.
