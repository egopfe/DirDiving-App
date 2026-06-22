# iOS Performance Optimization Audit — Current

**Command:** `IOS_PERFORMANCE_OPTIMIZATION_AUDIT_COMMAND_V1.0`  
**Repository:** `egopfe/DirDiving-App`  
**Branch:** `main`  
**Commit:** `07ec555`  
**Audit date:** 2026-06-22  
**Task type:** Audit-only — no production remediation  
**Xcode:** 26.5  

---

## A. Executive Summary

This audit inventories iOS Companion performance-sensitive surfaces across Diving, Apnea, and Snorkeling, identifies **28 findings** (P0=4, P1=11, P2=7, P3=6), documents budgets and signposts, and produces a remediation plan for a future implementation command.

**Key risks:** Diving Planner work runs entirely on `@MainActor` with multiplicative Bühlmann solves; Tissue Analytics is computed inside `PlannerView.body`; Snorkeling map downsampling exists but is not wired to UI; Settings tab eagerly creates both Apnea and Snorkeling store bundles; startup loads Diving logbook and activates Watch sync before the user selects an activity.

**Strengths:** `DIRPerformanceBudgets`, `DIRPerformanceSignpost`, and `PresentationSeriesDownsampler` infrastructure; OC planner charts capped at 2048 points; session caps (40 dive / 80 apnea-snorkeling); `PerformanceConcurrencyBatteryRemediationTests` covers debounce stress, 5k logbook decode, route sampling utility, and sync codec bounds.

**Overall software-verifiable readiness:** ~58%. Physical Instruments profiling and device QA remain **PENDING**.

---

## B. Branch, Commit and Scope

| Item | Value |
|------|-------|
| Branch | `main` |
| HEAD | `07ec555` |
| Scope | iOS Companion App only |
| Out of scope | Watch runtime, decompression math, sync schemas, production fixes |

Dirty worktree at audit time: untracked audit artifacts only (`Docs/IOS_PERFORMANCE_*`, validation script).

---

## C. Preflight State

| Check | Result |
|-------|--------|
| Branch is `main` | PASS |
| Xcode | 26.5 |
| Simulator destination | iPhone 17 Pro |
| iOS test scheme | `DIRDiving iOS Algorithm Tests` |
| Existing validation scripts | 22 readiness scripts; performance concurrency battery gate present |

---

## D. Current iOS Performance Architecture

```
DIRDivingiOSApp
└── IOSCompanionStoreCoordinator (@MainActor, eager Diving graph)
    ├── DiveLogStore (sync JSON load at init)
    ├── PlannerStore (debounced calc, @MainActor math)
    ├── CloudSyncStore (KVS on init)
    └── WatchSyncService (activates; creates lite Apnea+Snorkeling logbooks)

ContentView (lazy tab mount — positive)
├── Diving dashboard / planner / logbook
├── Apnea dashboard (lazy bundle on tab)
└── Snorkeling dashboard (lazy bundle on tab)

Settings paths
├── MoreView → applyCompanionSettingsSheetEnvironment (both activity bundles)
└── IOSCompanionSettingsRootView (same pattern)

Shared/Performance
├── DIRPerformanceBudgets.swift
├── DIRPerformanceSignpost.swift (24 categories)
├── PresentationSeriesDownsampler.swift (2048 default)
└── SnorkelingRoutePresentationSampling.swift (4096 cap, tested, unwired in UI)
```

Full surface inventory: `Docs/IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv` (30 surfaces).

---

## E. Startup and First Render

**Eager work at launch:**
- Full Diving coordinator: `PlannerStore`, `DiveLogStore`, equipment stores (`IOSCompanionStoreCoordinator.swift`).
- `DiveLogStore` decodes JSON, merges cloud snapshot, may persist — on main thread during init.
- `WatchSyncService.activate()` triggers lite Apnea and Snorkeling logbook creation for sync even for Diving-only users.

**Lazy patterns (positive):**
- Apnea/Snorkeling full UI bundles deferred until activity tab selected (except Settings path).
- `ContentView` tab content not all mounted simultaneously.

**Budgets:** BUD-IOS-001/002 — **NOT_MEASURED** (physical profiling pending).

**Findings:** IOS-PERF-P1-001, P1-002, P1-003, P3-005.

---

## F. SwiftUI Rendering and Body Recompute

**Issues identified:**
- `TissueAnalyticsService.presentationForPlanner` invoked from `PlannerView.body` on cache miss (IOS-PERF-P0-004).
- `companionSettingsScope` forwards `objectWillChange` to coordinator root (IOS-PERF-P2-001).
- `LogbookView` uses `ScrollView` + `ForEach` — all rows materialized (bounded by 40-session cap) (IOS-PERF-P1-010).
- Apnea/Snorkeling logbook rows call `refreshedStatistics()` per render (IOS-PERF-P1-011).

**Positive patterns:**
- Settings embeddable content (`IOSApneaSettingsContent`, `IOSSnorkelingSettingsContent`) avoids nested `Form` in `ScrollView`.
- `PlannerChartSnapshots` precomputes OC chart series outside hot body paths.

---

## G. Diving Planner Performance

| Aspect | Status |
|--------|--------|
| Debounce (200 ms) | Present for slider/text edits |
| Generation token / stale guard | Present |
| `calculate()` button | **Bypasses debounce** — immediate full solve (P0-003) |
| MainActor | **All Bühlmann engine work on main** (P0-001) |
| Multiplicative solves | Primary + contingency + GF + NDL per update (P0-002) |
| Init double-calc | Default `@Published` + deferred `calculate()` (P2-002) |

**Budget:** BUD-IOS-004 debounce stress test PASS; no wall-clock CI assertion (P1-005).

---

## H. Chart Rendering

| Chart surface | Downsampling | Signpost |
|---------------|--------------|----------|
| OC planner profile | 2048 via `PlannerChartSnapshots` | `chart_snapshot_prep` |
| Tissue Analytics | None — minute resolution | `tissueAnalyticsGeneration` **unused** |
| CCR plan result | Raw arrays | None |
| Apnea/Snorkeling stats | Bounded by session cap | None |

Findings: P0-004, P1-006, P1-007, P3-002.

---

## I. Logbook Scalability

**Runtime caps (by design):** 40 dive sessions, 80 Apnea/Snorkeling sessions (P3-003 DOCUMENTED_ACCEPTED_RISK).

**At cap behavior:**
- Full envelope decode on load — acceptable at cap sizes.
- Synthetic 5000-session decode budget test **PASS** (`testLogbookLoadBudgetSynthetic5000`).
- UI lists at cap: Diving non-lazy ScrollView; Apnea/Snorkeling per-row stats recompute.

**1k / 5k in-app sessions:** Not applicable under current caps. Scalability tests validate algorithms on synthetic data, not production UI at 5k.

---

## J. Export / Import Performance

| Path | Bounded | Cancellable | Notes |
|------|---------|-------------|-------|
| CSV import | 10 MB size cap | No | Row count validator exists but unused in parse (P2-005) |
| Subsurface export | Temp file cleanup | No | Sync on main |
| Apnea/Snorkeling PDF | Single session | No | In-memory (P2-006) |
| GPX export | Single session | No | Same |

Budgets BUD-IOS-011/012 — timing not measured in CI.

---

## K. WatchConnectivity and Sync Performance

**Strengths:** 512 KB payload codec roundtrip tests PASS; HMAC preserved in codec paths.

**Gaps:**
- iOS `WatchSyncService.flushOutboundTransfers` sends entire outbound queue without Watch-side `WatchSyncPendingFlushPolicy` backpressure (P1-009).
- Bulk flush of 40 full sessions — **NOT_MEASURED** (BUD-IOS-014).

Security: No recommendation weakens HMAC or payload integrity checks.

---

## L. Snorkeling Map and Route Performance

`SnorkelingRoutePresentationSampling` caps presentation to 4096 points and is **unit tested**. Dashboard and session detail views pass **full** coordinate arrays to `MapPolyline` (P1-008).

Track points append without persist cap in `SnorkelingSessionEngine` (P2-007).

Physical map QA: **PENDING** (P3-006).

---

## M. Apnea iOS Performance

- Logbook capped at 80 sessions; statistics views scan full in-memory array.
- Settings lazy except when opened via unified Settings tab (dual-bundle injection).
- Export PDF synchronous, no cancellation.
- No P0 findings specific to Apnea runtime math (recovery model untouched).

---

## N. Settings Mode Switch Performance

Mode switcher (`IOSCompanionSettingsModeSwitcher`) is UI-only scope — does not mutate runtime activity (functional tests PASS).

Performance concern: `applyCompanionSettingsSheetEnvironment` calls `ensureApneaStores` + `ensureSnorkelingStores` whenever Settings opens, creating both bundles regardless of displayed mode (P1-004). Required for crash fix (missing `@EnvironmentObject`).

Budget BUD-IOS-003 — **NOT_MEASURED**.

---

## O. Memory and Retain-Cycle Hygiene

- `TissueAnalyticsService` static dictionary cache unbounded (P2-004).
- Export paths hold full PDF/GPX in memory.
- No automated leak smoke test on iOS navigation paths.
- Combine subscriptions in coordinator appear scoped; no proven retain cycle found in audit (manual review).

---

## P. Concurrency and Cancellation

| Pattern | Assessment |
|---------|------------|
| Planner debounce + generation token | Good |
| Export/import | No cooperative cancellation (P2-006) |
| MainActor planner math | Over-broad (P0-001) |
| Task in onAppear | Limited audit evidence of unbounded accumulation |

BUD-IOS-018 task cancellation — **NOT_MEASURED**.

---

## Q. Battery Impact

iOS is companion-only; primary battery risks:
- Foreground sync flush bursts (sync-triggered).
- Repeated statistics recomputation on scroll (user-triggered).
- Cloud KVS synchronize on init (startup).

No evidence of runaway background loops in code review. Energy Log profiling **PENDING** (REQ-IOS-PERF-021).

---

## R. Observability and Signposts

**Present:** 24 signpost categories in `DIRPerformanceSignpost.swift`; catalog in `Docs/IOS_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md`.

**Gaps:** Startup, settings switch, map simplification categories missing or unused; `tissueAnalyticsGeneration` defined but never `begin()` (P2-003, P3-001).

Budget registry in `DIRPerformanceBudgets.swift` — registry completeness test PASS; enforcement sparse.

---

## S. Existing Test Coverage

| Suite | Relevance |
|-------|-----------|
| `PerformanceConcurrencyBatteryRemediationTests` | Debounce, downsample, 5k decode, route sampling |
| `LogbookScalabilitySupportTests` | Sort/filter bounds |
| `ActivitySyncLargePayloadTransferTests` | 512 KB codec |
| `IOSActivitySettings*Tests` | Settings routing/visibility |
| `IOSSnorkelingDashboardMapGapTests` | Gap segmentation |

Full matrix: `Docs/IOS_PERFORMANCE_REQUIREMENT_TEST_MATRIX_CURRENT.csv` (22 requirements).

---

## T. Missing Performance Tests

1. Startup wall-clock / coordinator lazy-init integration test  
2. Planner OC calculation hard limit (BUD-IOS-004 enforcement)  
3. Tissue analytics point cap + timing  
4. Settings mode switch latency  
5. iOS `WatchSyncService` flush backpressure  
6. Map UI integration with 50k points  
7. Export cancellation mid-flight  
8. CSV row count enforcement in parse path  
9. iOS `DiveLogStore` unit tests (Watch-only today)  
10. Memory leak smoke (navigation cycles)  

---

## U. Budget Matrix Summary

20 budgets defined in `Docs/IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`:

| Status | Count |
|--------|-------|
| PASS | 3 (BUD-008, 013, partial 004) |
| FAIL / OPEN | 5 |
| PENDING_PHYSICAL | 8 |
| CAP_BOUNDED / N/A | 4 |

---

## V. Findings

Full traceability: `Docs/IOS_PERFORMANCE_FINDING_TRACEABILITY_CURRENT.csv`

| Severity | Count | Representative |
|----------|-------|----------------|
| P0 | 4 | MainActor planner, multi-solve, Calculate bypass, tissue in body |
| P1 | 11 | Eager startup, settings dual-bundle, map unwired, sync flush |
| P2 | 7 | Cache, CSV rows, export cancel, track cap |
| P3 | 6 | Signposts, caps accepted, missing tests, physical pending |

---

## W. Prioritized Remediation Plan

### Wave 1 — P0 (planner + charts)
1. Move Bühlmann engine solves off main actor with generation-token publish-back (no math changes).
2. Collapse multiplicative solves — lazy contingency/GF derivatives from primary solve.
3. Route Calculate through debounced/background pipeline with progress UI.
4. Precompute tissue analytics in `PlannerStore` / `chartSnapshots`; instrument signpost.

### Wave 2 — P1 (startup, settings, map, sync)
5. Split coordinator init — defer Diving stores until Diving route.
6. Lazy logbook load on first Logbook tab access.
7. Defer lite Apnea/Snorkeling logbooks until first sync message for activity.
8. Lazy `applyCompanionSettingsSheetEnvironment` per displayed mode (preserve env objects).
9. Wire `SnorkelingRoutePresentationSampling` into dashboard + detail maps.
10. Port `WatchSyncPendingFlushPolicy` to iOS flush path.
11. Add CI planner timing assertion for BUD-IOS-004.

### Wave 3 — P2/P3
12. LRU cap on `TissueAnalyticsService` cache.
13. Enforce CSV row count in parse; Task-based cancellable export.
14. Track point persist cap; LazyVStack/List for logbook.
15. Cache row statistics on session model.
16. Add startup/settings/map signposts; execute Instruments plan.

---

## X. Instruments Profiling Plan

See `Docs/IOS_PERFORMANCE_PROFILING_PLAN_CURRENT.md`.

**Status:** Plan complete; **no `.trace` files collected in this audit**.

---

## Y. Physical / External QA Pending

See `Docs/IOS_PERFORMANCE_EXTERNAL_QA_PENDING_CURRENT.md`.

| QA item | Status |
|---------|--------|
| Cold start on iPhone 14 class | PENDING |
| Planner slider 100 ms budget on device | PENDING |
| Settings switch ×50 | PENDING |
| Map 50k points frame rate | PENDING |
| Export PDF memory peak | PENDING |
| Sync burst 40 sessions | PENDING |
| Energy Log background cycles | PENDING |

---

## Z. Build and Test Evidence

Phase 19 executed via `Scripts/validate_ios_performance_audit_readiness.sh` on 2026-06-22.

| Step | Result |
|------|--------|
| `xcodegen generate` | PASS |
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS |
| Build `DIRDiving iOS` (generic iOS Simulator) | PASS (~2 min) |
| Test `DIRDiving iOS Algorithm Tests` | **53 passed, 0 failed, 0 skipped** (~32 s) |

**Suites executed:** `PerformanceConcurrencyBatteryRemediationTests` (13), `MainDeepCodeReadinessCurrentTests` (20), `IOSActivitySettingsRoutingTests` (6), `IOSActivitySettingsContentVisibilityTests` (8), `IOSActivitySettingsModeSwitchTests` (4), `ActivitySyncLargePayloadTransferTests` (2).

**Destination:** `platform=iOS Simulator,name=iPhone 17 Pro`

**Gate output:** `IOS_PERFORMANCE_OPTIMIZATION_AUDIT_GATE_PASS`

**Limitation:** Subset of iOS Algorithm Tests only; full 1510-test iOS suite not run in this gate. Physical Instruments not executed.

---

## AA. Readiness Scores

Evidence-based; no score claims physical profiling complete.

| Metric | Score |
|--------|-------|
| IOS_STARTUP_PERFORMANCE_READINESS | 55% |
| IOS_SWIFTUI_RENDERING_READINESS | 58% |
| IOS_PLANNER_PERFORMANCE_READINESS | 45% |
| IOS_CHART_RENDERING_READINESS | 55% |
| IOS_LOGBOOK_SCALABILITY_READINESS | 72% |
| IOS_EXPORT_IMPORT_PERFORMANCE_READINESS | 60% |
| IOS_SYNC_PERFORMANCE_READINESS | 55% |
| IOS_MAP_ROUTE_RENDERING_READINESS | 42% |
| IOS_MEMORY_READINESS | 58% |
| IOS_CONCURRENCY_READINESS | 52% |
| IOS_BATTERY_POLICY_READINESS | 65% |
| IOS_OBSERVABILITY_READINESS | 75% |
| IOS_PERFORMANCE_TEST_COVERAGE_READINESS | 62% |
| **OVERALL_IOS_PERFORMANCE_READINESS** | **58%** |

---

## AB. Final Verdict

```
IOS_PERFORMANCE_OPTIMIZATION_AUDIT: PARTIAL
IOS_STARTUP_PERFORMANCE_READINESS: 55%
IOS_SWIFTUI_RENDERING_READINESS: 58%
IOS_PLANNER_PERFORMANCE_READINESS: 45%
IOS_CHART_RENDERING_READINESS: 55%
IOS_LOGBOOK_SCALABILITY_READINESS: 72%
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS: 60%
IOS_SYNC_PERFORMANCE_READINESS: 55%
IOS_MAP_ROUTE_RENDERING_READINESS: 42%
IOS_MEMORY_READINESS: 58%
IOS_CONCURRENCY_READINESS: 52%
IOS_BATTERY_POLICY_READINESS: 65%
IOS_OBSERVABILITY_READINESS: 75%
IOS_PERFORMANCE_TEST_COVERAGE_READINESS: 62%
OVERALL_IOS_PERFORMANCE_READINESS: 58%
P0_FINDINGS: 4
P1_FINDINGS: 11
P2_FINDINGS: 7
P3_FINDINGS: 6
PHYSICAL_INSTRUMENTS_PROFILING: PENDING
PHYSICAL_DEVICE_PERFORMANCE_QA: PENDING
EXTERNAL_RELEASE_PERFORMANCE_GATE: PENDING_PHYSICAL_EVIDENCE
```

---

## Phase 21 — Required Questions (20)

1. **Does iOS startup initialize too much work eagerly?**  
   **Yes.** Full Diving coordinator, sync logbook load, and both lite activity logbooks for Watch sync run before activity selection (P1-001/002/003).

2. **Are Apnea and Snorkeling stores lazily initialized correctly?**  
   **Partially.** Tab paths lazy-load full bundles; Settings tab eagerly creates both via `applyCompanionSettingsSheetEnvironment` (P1-004).

3. **Does Settings mode switch cause unnecessary global invalidation?**  
   **Yes, moderately.** `companionSettingsScope` forwards `objectWillChange` to coordinator root (P2-001); dual-bundle env adds cost (P1-004).

4. **Are any heavy computations performed inside SwiftUI body?**  
   **Yes.** Tissue analytics presentation on cache miss in `PlannerView.body` (P0-004).

5. **Is the Diving Planner debounced and cancellation-safe?**  
   **Debounced for edits; not for Calculate.** Generation token prevents stale display; `calculate()` bypasses debounce (P0-003). Cancellation on mode change partially covered by debounce tests.

6. **Are charts downsampled or bounded?**  
   **Partially.** OC planner charts yes (2048); Tissue Analytics and CCR charts no (P1-006, P1-007).

7. **Can logbook lists handle 1,000 / 5,000 sessions?**  
   **Not in production UI.** Caps are 40/80. Synthetic 5k decode test passes; UI not designed for 1k+ (P3-003).

8. **Do list rows avoid decoding full profile data?**  
   **Mostly at cap sizes.** Rows avoid full profile decode but Apnea/Snorkeling recompute statistics per row (P1-011).

9. **Can Snorkeling route previews handle 10k / 50k points?**  
   **Not reliably in UI.** Utility downsamples to 4096 but is unwired (P1-008). Physical QA pending (P3-006).

10. **Are PDF/CSV exports bounded and cancellable?**  
    **Bounded by single-session scope; not cancellable** (P2-006).

11. **Are imports streaming or memory-bounded?**  
    **Memory-bounded by 10 MB file cap; not fully streaming.** Row count cap not enforced in parse (P2-005).

12. **Are sync queues bounded and backpressured?**  
    **Payload size bounded; iOS outbound flush lacks backpressure policy** (P1-009).

13. **Are HMAC/security checks preserved under performance constraints?**  
    **Yes.** Remediation recommendations do not weaken HMAC or codec integrity.

14. **Are Combine subscriptions and Tasks cancellable?**  
    **Partially.** Planner debounce cancellable; export/import paths lack cooperative cancellation (P2-006).

15. **Are static caches bounded?**  
    **No.** `TissueAnalyticsService` static cache unbounded (P2-004).

16. **Are there retain-cycle risks?**  
    **No proven cycles found** in audit code review; no automated leak smoke test.

17. **Is there performance instrumentation?**  
    **Yes, partial.** Signposts and budgets exist; gaps in startup, settings, map, tissue analytics usage (P2-003, P3-001).

18. **Are performance budgets documented?**  
    **Yes.** `DIRPerformanceBudgets.swift` + `IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv`; CI enforcement sparse (P1-005).

19. **What tests are missing?**  
    See Section T — startup timing, planner wall-clock, tissue cap, settings latency, iOS sync flush, map UI 50k, export cancel, CSV rows, iOS DiveLogStore unit tests.

20. **What blocks iOS performance readiness from 100%?**  
    Four P0 planner/chart issues; eleven P1 startup/settings/map/sync issues; missing physical profiling; incomplete CI budget enforcement; unwired map downsampler; export cancellation gaps.

---

*Audit-only deliverable. Do not commit unless explicitly requested.*
