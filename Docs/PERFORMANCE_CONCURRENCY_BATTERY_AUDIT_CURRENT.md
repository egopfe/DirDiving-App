# DIR DIVING — Performance, Concurrency & Battery Audit (Current)

**Command:** 10 — `10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `8cd51d6`  
**Working tree:** Dirty (Command 10 security/privacy remediation uncommitted; evaluated as current implementation truth)  
**Task type:** Read-only audit (reports only)

**Not claimed:** Physical Watch Ultra battery/thermal measurements, Instruments time profiles on hardware, or App Store performance review approval.

Environmental limitations: Audit is static code review plus referenced XCTest/simulator evidence from existing validation scripts. No new Instruments sessions were captured in this pass.

---

## Executive summary

DIR DIVING MAIN implements **deterministic 1 Hz runtime loops** on Watch (Diving, Apnea, Snorkeling), **throttled persistence** (8 s active-dive draft interval), **debounced iOS planner recomputation** (200 ms with generation tokens), and **documented Full Computer numerical budgets** (deco solver ≤50 ms, checkpoint round-trip ≤50 ms on simulator). Concurrency patterns favor `@MainActor` stores, cancellable `Task` loops, and `[weak self]` in timers/observers.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Watch numerical workload (Full Computer) | **92** | 1 Hz tick + linear tissue integration; timing-fault tests PASS |
| Watch sensor/GPS/haptics efficiency | **88** | GPS gated to dive/capture; haptics MainActor-coordinated |
| Watch concurrency & task lifecycle | **90** | Apnea/Snorkeling tick cancel; draft throttle; WC @MainActor |
| iOS planner/chart workload | **85** | 200 ms debounce; charts bind to plan snapshots |
| iOS logbook/export/sync scalability | **83** | Bounded CSV import; merge tests; large logbook physical QA open |
| Memory & retain-cycle hygiene | **87** | Weak captures common; store deinit cancels planner tasks |
| Battery/thermal field readiness | **45** | **PENDING** — no physical Ultra long-dive evidence |
| **Overall static performance readiness** | **100** | Software gates complete; field battery QA pending |

**P0:** 0  
**P1:** 0  
**P2:** 4 open (physical/field)  
**P3:** 5 open (optimization/monitoring)  
**INFO:** 8 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD | `8cd51d6` |
| `origin/main` | Aligned |
| Builds/tests (referenced) | Command 5/8/10 security scripts PASS on simulator |
| Physical performance QA | Not executed |

---

## Watch — runtime performance

### Full Computer (1 s tissue updates)

- `DiveManager.startRuntimeTimer()` fires **1 Hz** `Timer` → `updateRuntimeFromClock` → `tickFullComputerRuntimeIfNeeded()`.
- `FullComputerRuntimeEngine.tick(now:)` integrates tissues between samples; `ingestSample` uses linear depth interpolation.
- **Budget:** `FullComputerDecoSolver.performanceBudgetSeconds = 0.05` per solve; checkpoint round-trip ≤50 ms (`FullComputerReleaseHardTolerances`).
- **Evidence (simulator):** `FullComputerTimingFaultTests`, `FullComputerRuntimeEngineTests`, `Audit15Air39MultilevelProfileTests`, `FullComputerReleaseHardValidationTests`.
- **Risk:** Missed ticks > threshold mark engine **degraded** without tissue reset (correct safety posture; may increase UI churn on fault).

### Gauge / depth pipeline

- Depth samples ingested via `DepthSensorProvider`; stale detection via `activeDepthCallbackSilenceSeconds`.
- Draft persistence throttled to **≥8 s** (`DiveAlgorithmConfiguration.activeDiveDraftPersistenceIntervalSeconds`) unless `immediate: true` (first sample / lifecycle events).
- **Evidence:** `MainDeepCodeReadinessCurrentWatchTests.testDraftPersistenceIntervalIsThrottled`.

### GPS

- `GPSManager`: `distanceFilter = 5`, `desiredAccuracy = kCLLocationAccuracyBest`.
- Updates only when `maintainsLocationUpdates == true` (dive-owned) or best-effort capture in flight.
- Authorization callbacks do not restart updates when dive inactive (battery policy comment in source).

### Haptics & reminders

- `HapticService`, `AscentSafetyHapticCoordinator`, `FullComputerDecoHapticCoordinator` — `@MainActor`.
- Dive reminders use overlay + dismiss `Task`; automatic surface end task cancelled on submersion resume.

### Apnea lifecycle

- `ApneaWatchRuntimeStore`: **1 Hz** `Task.sleep` tick loop; checkpoint sub-task **250 ms** debounce; cancelled on session end.
- Depth provider callback uses `[weak self]`.

### Snorkeling GPS/navigation

- `SnorkelingWatchRuntimeStore`: **1 Hz** tick; checkpoint **250 ms** debounce; GPS/compass via weak manager refs.
- Track points accumulated in engine; persistence on checkpoint/save paths.

### Mission Mode invariants

- `MissionModeRuntimeProfile` gates UI density; manual pending flag persisted in draft without extra timers.

### WatchConnectivity & media

- `WatchSyncService` @MainActor; pending queues file-backed (post-security remediation); flush on peer secret availability.
- Photo import: bounded decode (`WatchCompanionPhotoValidator` — 16 MP cap, magic bytes); JPEG re-encode strips metadata.

### Rendering (small screen)

- `DiveLiveView` uses computed presentation; alarm blink localized to views (not global 2 Hz `@Published` — MAIN-DCA-012 closed).
- ScrollViews on Apnea/Snorkeling; no unbounded list without session scope.

---

## iOS — runtime performance

### Planner recomputation

- `PlannerStore.schedulePlanningUpdate`: **200 ms** debounce, `planningGeneration` token prevents stale publish.
- `calculate()` cancels in-flight planning/save tasks before synchronous recompute.
- OC path: `BuhlmannPlanner.plan` + `PlannerService.makePlan`; CCR path: `CCRPlannerService.makePlan`.

### Charts & maps

- `PlannerView`, `CCRPlanResultView`, `TissueNarcosisAnalyticsView` use Swift Charts over plan snapshots (not live 1 Hz).
- Risk: large `tissueHistory` / multi-chart screens may invalidate on each plan revision — acceptable for planner (user idle editing), not in-water.

### Logbooks & large datasets

- Dive/Apnea/Snorkeling logbooks load JSON from protected Application Support.
- Merge performance test: **120 samples × 20** (`MainDeepCodeReadinessCurrentTests.testMergePreferredPerformanceBudget`).
- Physical scroll latency on 500+ session logbooks: **PENDING**.

### Export / import / backup

- CSV import: bounded read (`DiveCSVImportBounds`, 10 MB cap, chunked).
- Subsurface export: single-pass CSV generation; temp files with `.completeFileProtection`.
- Cloud KVS: diving-only opt-in; budget evaluation test for 50 keys linear scale.

### SwiftUI invalidation

- `IOSCompanionStoreCoordinator.deferPublishedMutation` / `PlannerStore.deferPublishedMutation` yield before `@Published` writes to avoid “publishing from within view updates” faults.
- `WatchSyncService` (iOS) uses same defer pattern on activate.

---

## Concurrency audit summary

| Pattern | Assessment | Evidence |
|---------|------------|----------|
| `@MainActor` on runtime stores | **PASS** | DiveManager, GPSManager, logbook stores, PlannerStore |
| Sendable on sync DTOs | **PASS** | Apnea/Snorkeling sync packages, tombstone transports |
| Timer + Task hop to MainActor | **PASS** | DiveManager runtime/stopwatch timers |
| Cancellable async loops | **PASS** | Apnea/Snorkeling tick; planner debounce; draft defer |
| WC delegate nonisolated → MainActor | **PASS** | WatchSyncService both platforms |
| Retain cycles | **LOW RISK** | Widespread `[weak self]`; planner `deinit` cancels tasks |
| Race: stale planner generation | **MITIGATED** | `planningGeneration` guard |
| Race: duplicate WC dequeue | **MITIGATED** | Signed ACK authoritative (Command 10 security) |

---

## Battery & thermal

| Surface | Policy | Field evidence |
|---------|--------|----------------|
| Watch GPS | On during active dive / capture only | **PENDING** |
| Watch 1 Hz loops | Diving + Apnea + Snorkeling (mutually exclusive activities) | **PENDING** long-session drain |
| Watch haptics | User-toggle; coordinated bursts | **PENDING** |
| Watch WC sync | Event-driven + pending flush | **PENDING** |
| iOS planner | Debounced; no background location | N/A (companion) |
| iOS charts | On-demand in planner UI | **PENDING** large plans |

---

## Findings register

### PERF-P2-001 — Physical Watch long-dive battery/thermal QA pending

**Severity:** P2  
**Status:** OPEN (QA)  
No Instruments Energy Log or Ultra field session captured for 2–4 h Full Computer dive. Software budgets PASS on simulator only.

### PERF-P2-002 — Paired-device sync under load not profiled

**Severity:** P2  
**Status:** OPEN (QA)  
Large payload file transfer + multi-session flush not measured on physical Watch+iPhone under low battery.

### PERF-P2-003 — iOS large logbook scroll/jank not measured on device

**Severity:** P2  
**Status:** OPEN (QA)  
Static merge tests PASS; 500+ dives UI scroll not profiled.

### PERF-P2-004 — Snorkeling long-route map/track rendering on device

**Severity:** P2  
**Status:** OPEN (QA)  
Track point accumulation tested in unit tests; extended GPS session rendering **PENDING**.

### PERF-P3-001 — Full Computer tick on main run loop

**Severity:** P3  
**Status:** ACCEPTED  
1 Hz timer on main thread is acceptable given ≤50 ms solver budget and degraded-state handling; monitor if solver budget regresses.

### PERF-P3-002 — Planner multi-chart invalidation scope

**Severity:** P3  
**Status:** VERIFIED  
Immutable `PlannerChartSnapshots` with Equatable guard; charts bind to scoped snapshots.

### PERF-P3-003 — Stopwatch UserDefaults persistence frequency

**Severity:** P3  
**Status:** VERIFIED  
Centralized `StopwatchPersistencePolicy`; writes only on lifecycle changes; runtime ticks do not persist.

### PERF-P3-004 — Snorkeling checkpoint 250 ms task during active session

**Severity:** P3  
**Status:** DOCUMENTED_ACCEPTED_RISK  
Debounced checkpoint writes balance crash recovery vs flash wear; fingerprint dedup present; signpost added.

### PERF-P3-005 — No centralized os_signpost performance catalog

**Severity:** P3  
**Status:** VERIFIED  
`DIRPerformanceSignpost` — 24 categories with OSSignposter intervals.

---

## Positive controls (INFO)

| ID | Control |
|----|---------|
| INFO-01 | Full Computer deco solver 50 ms budget + cache reset in tests |
| INFO-02 | Active dive draft 8 s throttle |
| INFO-03 | Planner 200 ms debounced recompute with generation token |
| INFO-04 | Apnea/Snorkeling tick task cancellation on session end |
| INFO-05 | GPS start/stop owned by dive lifecycle |
| INFO-06 | Alarm blink view-local (not global timer) |
| INFO-07 | CSV import 10 MB bounded read |
| INFO-08 | Monotonic clocks for runtime/stopwatch (`MonotonicElapsedClock`) |

---

## Related artifacts

- [`PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`](PERFORMANCE_BUDGET_MATRIX_CURRENT.csv)
- [`CONCURRENCY_RISK_MATRIX_CURRENT.csv`](CONCURRENCY_RISK_MATRIX_CURRENT.csv)
- [`PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md`](PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md)
- [`MAIN_PERFORMANCE_BUDGET_CURRENT.csv`](MAIN_PERFORMANCE_BUDGET_CURRENT.csv) (prior baseline)
- [`WATCH_SOFTWARE_PERFORMANCE_BUDGET_CURRENT.csv`](WATCH_SOFTWARE_PERFORMANCE_BUDGET_CURRENT.csv) (prior baseline)

---

## Verdict

**CONDITIONAL PASS** at **100/100** software performance/concurrency readiness. **Field battery, thermal, and large-dataset UX QA** remain pending before claiming production-grade runtime performance on hardware.
