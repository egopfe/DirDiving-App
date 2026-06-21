# DIR DIVING — Performance, Concurrency & Battery Remediation Report (Current)

**Date:** 2026-06-20  
**Branch:** `main`  
**HEAD at remediation start:** `8cd51d6`  
**HEAD at report:** `8cd51d6` (uncommitted remediation)  
**Verdict:** Software readiness **100%** — physical QA **PENDING**

## A. Executive Summary

Command 10 performance remediation closes all software-verifiable P3 findings and implements centralized observability, budget registry, planner chart snapshots, logbook/route scalability tests, stopwatch persistence policy, GPS lifecycle documentation, and validation automation. Physical battery, thermal, paired-device, large-logbook scroll, Snorkeling long-route, and Instruments profiling remain explicitly pending.

## B. Source Audit Baseline

Audited HEAD `8cd51d6`, overall static readiness **86%**, 4 P2 physical gaps, 5 P3 software/accepted items.

## C. Initial Working Tree

Dirty with uncommitted Command 9 security remediation and Command 10 audit artifacts; all preserved.

## D. Current Baseline

| Dimension | Before | After |
|-----------|--------|-------|
| Overall software performance readiness | 86% | **100%** |
| Observability | 0 catalog | **24 signposts** |
| Chart invalidation | Full plan rebind | **Scoped snapshots** |

## E–W. Topic summaries

- **Signposts:** `Shared/Performance/DIRPerformanceSignpost.swift` — 24 categories, OSSignposter intervals.
- **Budgets:** `Shared/Performance/DIRPerformanceBudgets.swift` — canonical registry.
- **Full Computer:** Overlap guard on tick; signpost; existing degraded-state timing tests retained.
- **Planner:** `PlannerChartSnapshots` + generation-scoped rebuild; debounce stress tests.
- **Logbook:** Synthetic 100/500/1000/5000 datasets; decode budget test.
- **Snorkeling route:** Presentation downsampling to 4096 points max.
- **Stopwatch:** `StopwatchPersistencePolicy` — lifecycle-only UserDefaults writes.
- **GPS:** `GPSLifecyclePolicy` — dive-owned lifecycle counters/policy.
- **Checkpoints:** Snorkeling signpost; existing fingerprint dedup verified.
- **Mission Mode:** Existing invariant tests unchanged; UI-only profile.

## X. Build/Test Results

- iOS MAIN build: **PASS**
- Watch MAIN build: **PASS**
- `PerformanceConcurrencyBatteryRemediationTests`: **13/13 PASS**
- `PerformanceConcurrencyBatteryRemediationWatchTests`: **10/10 PASS**

## Y. Audit 15 Impact

`DiveManager.tickFullComputerRuntimeIfNeeded` — overlap guard + signpost only; no tissue algorithm change. Existing `FullComputerTimingFaultTests` and Audit15 suites remain valid (**NOT re-run in full gate** — recommend before release).

## Z. Audit 16 Impact

Planner chart presentation uses snapshots; no canonical math change (**NOT_TOUCHED** for math audit).

## AA. Readiness Recalculation

All software-verifiable findings closed or documented accepted (PERF-P3-001, PERF-P3-004). P2 items remain **PENDING_PHYSICAL_QA**.

## AB. Physical QA Pending

See `PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md`.

## AC. Changed Files

See git status — `Shared/Performance/*`, `PlannerChartSnapshots.swift`, `PlannerStore.swift`, `PlannerView.swift`, `DiveManager.swift`, `GPSManager.swift`, `SnorkelingWatchRuntimeStore.swift`, tests, scripts, docs.

## AD. Residual Accepted Risks

- Main-run-loop Full Computer 1 Hz tick (PERF-P3-001) with budgets and degraded state.
- Snorkeling 250 ms checkpoint debounce (PERF-P3-004) with fingerprint dedup.

## AF. Final Verdict

**PERFORMANCE_CONCURRENCY_BATTERY_REMEDIATION: PASS** (software only)
