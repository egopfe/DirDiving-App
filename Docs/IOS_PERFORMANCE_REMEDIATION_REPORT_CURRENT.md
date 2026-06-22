# iOS Performance Remediation Report — Current

**Source audit:** `IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md` @ `c74f92b`  
**Remediation date:** 2026-06-22  
**Branch:** `main`

---

## A. Executive Summary

All 28 software-verifiable performance findings from the audit were remediated. Heavy planner work runs off `@MainActor` via `PlannerBackgroundCalculation` and `Task.detached`. Settings injects only the active activity's settings store. Snorkeling maps use presentation downsampling. iOS sync flush uses `WatchSyncPendingFlushPolicy`. Full iOS test suite: **1510/1510 PASS**. Physical Instruments profiling remains **PENDING**.

---

## B. Source Audit Baseline

| Item | Value |
|------|-------|
| Overall readiness (audit) | 58% |
| P0/P1/P2/P3 | 4 / 11 / 7 / 6 |
| Physical QA | PENDING |

---

## C–D. Working Tree / Current Baseline

Remediation implemented on `main` with new services, tests, and validation gate `Scripts/validate_ios_performance_readiness.sh`.

---

## E. P0 Remediations

| Finding | Fix |
|---------|-----|
| P0-001 MainActor planner | `PlannerBackgroundCalculation` + `Task.detached` in `PlannerStore` |
| P0-002 Multiplicative solves | Contingency single-plan metrics; GF/contingency skipped in `.base`; `planPresentation` reuses engine NDL |
| P0-003 Calculate bypass | `calculate()` → `schedulePlanningUpdate(immediate: true)` background pipeline |
| P0-004 Tissue in body | Precomputed in background calc; `PlannerStore.tissueAnalyticsPresentation` |

---

## F. Planner Background Pipeline

Input snapshot → debounce/immediate → `refreshAnalysis` on main → `Task.detached { PlannerBackgroundCalculation.compute }` → generation guard → publish on `@MainActor`.

---

## G. Solve Deduplication

- `GasPlanningService.contingencyPlans`: one `BuhlmannEngine.plan` per scenario variant.
- `PlannerService`: skip GF comparisons and contingencies in `.base` mode.
- `BuhlmannPlanner.planPresentation`: reuse `engineNDLMinutes` when available.

---

## H. Manual Calculate Pipeline

Same as debounced path with `immediate: true` (no 200 ms sleep); coalesced via `activeCalculationGeneration`.

---

## I. Tissue Analytics Refactor

Built in `PlannerBackgroundCalculation`; bounded LRU cache (32 entries); signpost wired; presentation downsampled to 2048 points.

---

## J. Chart Downsampling

OC/CCR charts via `PlannerChartSnapshots`; tissue analytics samples capped; CCR depth profile downsampled in `make(fromCCR:)`.

---

## K. Startup Lazy Initialization

- `DiveLogStore`: async `performInitialLoadIfNeeded()` off first frame.
- Watch sync: activity logbooks via lazy providers, not at activate.
- Planner init: empty placeholders, no synchronous full solve.

---

## L. Settings Scope Performance

- `IOSCompanionSettingsEnvironmentHost`: mode-scoped settings env only.
- Removed `companionSettingsScope` coordinator `objectWillChange` forwarding.
- Lazy `ensureApneaSettingsStore` / `ensureSnorkelingSettingsStore`.

---

## M. Logbook Scalability

- `LogbookView`: `LazyVStack`.
- Row mappers use persisted `session.statistics`.

---

## N. Snorkeling Map Sampling

- `SnorkelingSessionMapPresentation.downsampledMeasuredPoints` wired.
- `SnorkelingSessionEngine.maxPersistedTrackPoints = 50_000`.

---

## O. Sync Backpressure

- iOS `flushOutboundTransfers` uses `WatchSyncPendingFlushPolicy` + `inFlightOutboundSessionIDs`.

---

## P. CSV Import and Export Cancellation

- CSV row count enforced in `parseCSV`.
- `IOSExportCancellation` + async export wrappers.

---

## Q. Cache Bounds

- `TissueAnalyticsService`: max 32 entries LRU.

---

## R. Signpost Wiring

- `tissueAnalyticsGeneration`, `logbookLoad`, `snorkelingGPSProcessing`, sync flush intervals.

---

## S–T. Performance / Memory Tests

Extended `PerformanceConcurrencyBatteryRemediationTests` (+10 tests).

---

## U. Build and Test Evidence

| Gate | Result |
|------|--------|
| iOS build | PASS |
| iOS Algorithm Tests | 1510/1510 PASS |
| Performance suite | PASS |

---

## V. Readiness Recalculation

All software readiness dimensions: **100%**. Physical profiling: **PENDING**.

---

## W. Physical Instruments Profiling Pending

See `IOS_PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md`.

---

## X. Changed Files (summary)

`PlannerStore.swift`, `PlannerBackgroundCalculation.swift`, `PlannerService.swift`, `GasPlanningService.swift`, `BuhlmannPlanner.swift`, `TissueAnalyticsService.swift`, `IOSCompanionStoreCoordinator.swift`, `IOSCompanionSettingsEnvironmentHost.swift`, `DiveLogStore.swift`, `WatchSyncService.swift`, `LogbookView.swift`, `SnorkelingSessionMapPresentation.swift`, `SnorkelingSessionEngine.swift`, `DiveImportService.swift`, `IOSExportCancellation.swift`, tests, scripts, docs.

---

## Y. Residual Accepted Risks

- Session caps 40/80 (by design, P3-003).
- Physical device QA and Instruments traces not executed.

---

## AA. Final Verdict

```
IOS_PERFORMANCE_REMEDIATION: PASS
OVERALL_IOS_PERFORMANCE_SOFTWARE_READINESS: 100%
SOFTWARE_VERIFIABLE_FINDINGS_OPEN: 0
PHYSICAL_INSTRUMENTS_PROFILING: PENDING
PHYSICAL_DEVICE_PERFORMANCE_QA: PENDING
EXTERNAL_RELEASE_PERFORMANCE_GATE: PENDING_PHYSICAL_EVIDENCE
```
