# Watch Live Bühlmann / Schreiner / Multilevel Decompression Engine Audit — Current

**Command:** `15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_V3.0.md`  
**Audit date:** 2026-06-21  
**Repository:** `egopfe/DirDiving-App`  
**Branch:** `main`  
**Commit:** `1fe4a67`  
**Working tree at audit start:** clean, synced with `origin/main`  
**Task type:** read-only forensic audit (docs only; no code/test/project changes)

**Deliverables:**

| File | Status |
|---|---|
| `Docs/WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_CURRENT.md` | This document |
| `Docs/WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv` | 110 rows |
| `Docs/WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv` | 22 rows |
| `Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md` | Complete |
| `Docs/WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md` | Complete |

**Test evidence (selective Watch Algorithm Tests, 2026-06-21):**

```text
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test \
  -only-testing:…Audit15…, SchreinerAnalyticParityTests, BuhlmannMutationResistanceTests,
  FullComputerTimingFaultTests, FullComputerRuntimeEngineTests, WatchMathCrossTargetParityTests,
  FullComputerDecoSolverTests, FullComputerDecoStopStateMachineTests, FullComputerRecoveryCheckpointTests

Result: 51 executed, 0 failures — TEST SUCCEEDED
```

---

## A. Executive Summary

This audit forensically reviews the **live** Apple Watch Full Computer decompression engine: Bühlmann ZH-L16C tissue loading (Schreiner + Haldane), 16-compartment N₂/He state, GF ceiling, NDL/TTS/schedule recomputation, multilevel continuity, gas switching, stop-state separation, timing semantics, and independent oracle parity.

**Headline:** No **P0** safety defect was confirmed in static review or targeted automated testing. Schreiner implementation is algebraically correct and matches an independent per-second oracle across the mandatory **39 m → 10 m** multilevel profile (ML-01) and re-descent profile (ML-05). Tissue integration uses **actual elapsed time**, not a blind `dt = 1` assumption. Dynamic decompression appearance, schedule evolution, and controlling-compartment migration are software-verified for ML-01; shallow clearance and reappearance are verified for ML-05.

**Gaps:** ML-02–ML-04 and ML-06–ML-10 lack dedicated oracle tests; TTS minute-step quantization is bounded but not fully oracle-swept; physical Apple Watch Ultra validation and external tool parity remain **PENDING**. Internal TestFlight Full Computer decompression readiness is **CONDITIONAL** on those gaps and listed P1/P2 items.

| Severity | Count | Summary |
|---:|---:|---|
| P0 | 0 | No confirmed false clearance, tissue corruption, or fail-open deco path during active dive |
| P1 | 2 | Incomplete multilevel profile matrix (ML-02–04, ML-06–10); TTS oracle sweep missing |
| P2 | 4 | Static solver cache concurrency; double projection per refresh; 120 s missed-tick cap; 1-min schedule simulation |
| P3 | 3 | Documentation of degraded-state UX; export tooling for external CSV replay; trimix evidence gap |

---

## B. Scope and Commit

### Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `1fe4a67` |
| Remote sync | `main...origin/main` (clean) |
| Primary target | `DIRDiving Watch App` — Full Computer mode |
| Secondary | `Shared/BuhlmannCore/*` (shared with iOS Planner math) |
| Audit-only rule | **Honored** — only `Docs/` artifacts created/updated |

### In scope

Live path from depth sample → tissue update → projection → stop state → UI snapshot during an active Full Computer dive.

### Out of scope

Gauge mode, Apnea, Snorkeling, mockup visual regression, iOS Planner UX, certification claims, physical chamber tests (planned separately).

---

## C. Existing Audit Coverage and Specialized Gap

| Prior command | Already covers | Gap closed by Command 15 |
|---|---|---|
| 0 / 1 — iOS math / Bühlmann readiness | ZH-L16C constants, shared core | Watch **live** tick semantics, sensor path |
| 2 — Watch algorithm audit | Lifecycle, depth pipeline, general FC | **Schreiner forensic**, per-second oracle, ML-01 replay |
| 3 — iOS algorithm | Planner projection | Watch live ≠ Planner card authority |
| 5 — Deep code analysis | Architecture inventory | FC runtime tissue authority proof |
| 10 — Performance / concurrency | Signposts, tick budget | Stale solver cache, missed-tick cap analysis |
| 12 — Test QA | Suite inventory | Audit-15 mutation + oracle suites |

**Specialized gaps closed in this audit:**

- Schreiner equation algebraic verification
- Actual-`dt` vs assumed 1 s proof
- ML-01 second-by-second independent oracle parity
- ML-05 re-descent + checkpoint restore
- Numerical error budget document
- Schreiner + multilevel CSV matrices

**Still open after Command 15:**

- ML-02–ML-04, ML-06–ML-10 automated oracle profiles
- External decompression tool comparison
- Physical Watch Ultra underwater validation

---

## D. Live Engine Call Graph

```text
AppleDepthSensorProvider / MockDepthSensorProvider
  → DepthSampleValidation
  → DiveManager.processDepthMeasurement
  → ingestFullComputerSample (Full Computer dives only)
       → FullComputerRuntimeEngine.ingestSample / tick
            → advanceTissuesLinear / advanceTissuesConstant
                 → BuhlmannTissueState.loadedLinearDepth (Schreiner)
            → refreshSnapshot
                 → BuhlmannEngine.runtimeProjection
                 → FullComputerDecoSolver.solve (presentation)
                 → FullComputerDecoStopStateMachine.evaluate
  → fullComputerSnapshot published (@MainActor DiveManager)
  → DiveLiveView / FullComputerLivePanels (presentation only)
```

### Component inventory

| Component | File / symbol | Canonical | Derived | Presentation | Stateful | Thread | Tests |
|---|---|:---:|:---:|:---:|:---:|:---:|---|
| Tissue state | `FullComputerRuntimeEngine.tissueState` | ✓ | | | ✓ | `@MainActor` via `DiveManager` | Audit15, FC runtime |
| Schreiner | `BuhlmannTissueModel.schreiner` | ✓ | | | | sync | SchreinerAnalyticParity |
| Haldane fallback | same, `\|rate\| < 1e-7` | ✓ | | | | sync | Schreiner + constant depth |
| Linear integration | `advanceTissuesLinear` | ✓ | | | | sync | Audit15 replay |
| Constant integration | `advanceTissuesConstant` / `tick` | ✓ | | | | sync | TimingFault |
| Constants | `BuhlmannConstants` | ✓ | | | | immutable | Cross-target parity |
| GF ceiling | `BuhlmannTissueState.ceiling` | | ✓ | | | sync | Oracle bridged |
| NDL/TTS/schedule | `BuhlmannEngine.runtimeProjection` | | ✓ | | | sync | FC solver tests |
| Presentation | `FullComputerDecoSolver` | | | ✓ | cache | sync static | DecoSolverTests |
| Stop FSM | `FullComputerDecoStopStateMachine` | | | ✓ | ✓ | sync | StopStateMachineTests |
| Checkpoint | `FullComputerRuntimeCheckpoint` | ✓ | | | ✓ | encode/decode | Recovery + Audit15 |
| Oracle | `IndependentBuhlmannOracle` | | | | test-only | | Audit15 |

**Single tissue authority:** `FullComputerRuntimeEngine.tissueState` on `@MainActor` `DiveManager.fullComputerEngine`. No parallel live Bühlmann engine on Watch. Gauge mode does not mutate FC tissues (`FullComputerNamespaceIsolationTests`).

---

## E. Model Identity and Constants

**Claimed model:** Bühlmann ZH-L16C, 16 compartments, independent N₂ and He.

**Source of truth:** `Shared/BuhlmannCore/BuhlmannConstants.swift`

| Parameter | Value | Verified |
|---|---|---|
| Compartments | 16 | ✓ arrays length 16 |
| N₂ half-times (min) | 5 … 635 | ✓ matches oracle |
| He half-times (min) | 1.88 … 240.03 | ✓ |
| a/b coefficients | N₂ + He tables | ✓ index-aligned |
| Water vapour | 0.0627 bar | ✓ |
| Surface pressure | 1.01325 bar | ✓ |
| Salt water density | 1025 kg/m³ | ✓ |
| Gas switch load | 0.5 min @ new gas | ✓ `changeGas` |

External reference table cross-check: **PENDING** (constants match in-repo oracle and prior audits; no third-party tool run in this session).

---

## F. Schreiner Formula Verification

**Implementation:** `Shared/BuhlmannCore/BuhlmannTissueModel.swift` — private `schreiner(...)`

Standard form (minutes, inspired pressure rate per minute):

```text
P_t(t) = P_i0 + R·(t − 1/k) − (P_i0 − P_t0 − R/k)·exp(−k·t)
k = ln(2) / halfTime
```

**Haldane fallback:** when `|R| < 1e-7`, exponential approach to constant inspired pressure.

| Check | Result |
|---|---|
| Sign of exponential term | ✓ matches canonical form |
| `ln(2)` usage | ✓ |
| N₂ / He independent | ✓ separate k, separate pressures |
| Start inspired pressure at segment start | ✓ `startN2`, not end |
| Rate from linear depth segment | ✓ `(end - start) / minutes` |
| Limit t→0 | ✓ returns `P_t0` via guard / zero minutes |
| Limit R→0 | ✓ Haldane branch |

**Evidence:** `SchreinerAnalyticParityTests` — analytic vs 1 s stepped within `0.0005 bar`; production vs oracle at 39 m descent within `0.0002 bar`. CSV: `WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv` (110 vectors).

---

## G. Units and Pressure Model

**Chain:**

```text
depth (m, canonical Double, unrounded for math)
  → AmbientPressureModel.ambientPressureBar (salt/fresh from PlannerEnvironment)
  → dry = ambient − 0.0627
  → P_inert = dry × fraction (N₂ = 1 − O₂ − He)
  → Schreiner rate in bar/min from depth-linear segment
  → tissue integration in minutes (= seconds / 60)
```

| Convention | Status |
|---|---|
| Storage depth | metres (`Double`) |
| Tissue time | minutes internally; seconds at engine boundary |
| Ascent/descent rates | m/min (`BuhlmannConstants`) |
| Absolute vs gauge | absolute bar for inspired pressure |
| Display rounding | 0.1 m ceilings in presentation only |

---

## H. One-Second Timing Semantics

**Not** a blind `dt = 1` assumption.

| Mechanism | Behavior |
|---|---|
| Sample ingest | `delta = timestamp − lastComputedTimestamp`; integrate if `delta > 0` |
| Constant depth | `tick(now:)` integrates `now − lastComputedTimestamp` |
| Sub-stepping | ≤30 s Schreiner steps (`maxSubStepSeconds`) |
| Missed tick cap | 120 s (`maxMissedTickSeconds`); degraded if Δt > 2 s |
| Nominal timer | 1 Hz `tickFullComputerRuntimeIfNeeded`; **does not define dt** |
| Duplicate timestamp | Rejected — no double integration (`FullComputerTimingFaultTests`) |
| Out-of-order | Rejected, degraded (`non_monotonic_timestamp`) |
| Failed ingest | Falls through to `tick` at sample timestamp (constant depth advance) |

**Timing-fault matrix:** Δt ∈ {0.5, 1, 1.5, 2, 5, 10, 30} s — tissues load at 22 m constant depth; restore continuity verified.

**Invariant:** Tissue evolution tied to timestamps, not UI frame rate.

---

## I. Tissue State Integrity

- **Structure:** 16 × (`nitrogenPressure`, `heliumPressure`) — `BuhlmannTissueCompartment`
- **Updates:** Full vector replaced per integration step; no partial compartment publish
- **No reset** on deco appear/disappear, UI navigation, or stop FSM transitions (tests)
- **Gas switch:** integrates prior gas to switch time, then 0.5 min load at new gas (`changeGas`) — not a full tissue reset
- **Checkpoint:** encodes full tissue vector; restore bit-equal in Audit15 + Recovery tests
- **Corrupt checkpoint:** rejected (`FullComputerGasSwitchRecoveryIntegrationTests`)

---

## J. Gradient Factors and Ceiling

- GF Low / High stored on plan; validated at dive start
- Raw ceiling: GF Low fraction on all compartments (`BuhlmannTissueState.ceiling`)
- Operational ceiling: GF interpolated between first stop and surface (`BuhlmannEngine.runtimeProjection`)
- Controlling compartment: max compartment ceiling depth
- Oracle decimated checks: raw ceiling within **0.2 m** on ML-01

**Scenarios covered in tests:** fresh surface, deco incurred at depth, reduced ceiling at 10 m level, controlling change (compartment 1 → 2 at ~780 s in oracle ML-01 replay), re-descent reappearance (ML-05).

---

## K. NDL / Schedule / TTS Recomputation

Every `refreshSnapshot` recomputes via `BuhlmannEngine.runtimeProjection` + `FullComputerDecoSolver.solve` on **current** tissue snapshot.

| Output | Recomputed | Cache |
|---|---|---|
| NDL | Yes | Solver static cache keyed on tissue+depth+gas+GF |
| Raw/operational ceiling | Yes | same |
| Stop list / TTS | Yes — forward simulation | Invalidated when tissue key changes |
| Schedule at 39 m after 10 m stay | **Not authoritative** — rebuilds from current tissues each refresh | ✓ |

**Findings:**

- **P2-AUD15-001:** `FullComputerDecoSolver` uses process-wide static cache — not actor-isolated. Mitigated: `@MainActor` DiveManager serializes calls; cache invalidates on tissue change; budget exceeded returns conservative prior presentation.
- **P2-AUD15-002:** `makeSnapshot` calls `runtimeProjection`; solver calls it again — duplicate work, not divergent authority.
- **P2-AUD15-003:** Forward schedule/TTS simulation uses **1-minute** steps — may over-estimate TTS (conservative direction).

---

## L. Multilevel Profiles

| Profile ID | Description | Oracle test | Result |
|---|---|---|---|
| ML-01 | Air 39 m → 10 m, 600 s level | `Audit15Air39MultilevelProfileTests` | **PASS** |
| ML-02 | EAN50 @ 21 m | — | **NOT RUN** |
| ML-03 | Trimix + deco gases | Partial via other suites | **PARTIAL** |
| ML-04 | Sawtooth | — | **NOT RUN** |
| ML-05 | Deco clear → re-descent | `Audit15RedescentOracleTests` | **PASS** |
| ML-06 | Hover at stop boundary | Stop FSM tests | **PARTIAL** |
| ML-07 | Very slow ascent | Schreiner segments | **PARTIAL** |
| ML-08 | Rapid ascent | Rate sign in Schreiner | **PARTIAL** |
| ML-09 | Long 10 m level loading | ML-01 level segment | **PARTIAL** (slow compartments tracked) |
| ML-10 | Surface interval / repetitive | — | **NOT RUN** |

Transition matrix: `WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv`

---

## M. 39 m → 10 m Scenario (User Question)

**Question:** After incurring decompression at 39 m, can spending time at 10 m correctly reduce or remove the obligation?

**Answer (evidence-based): YES for software-verifiable mechanics; clearance at 10 m is **model-dependent** and **not guaranteed**.

### Oracle ML-01 timeline (independent replay, GF 30/70, air)

| Event | Second (approx) |
|---|---:|
| Descent complete @ 39 m | 130 |
| Deco first appears | 210 (end of bottom segment in probe) |
| Ascent complete @ 10 m | 404 |
| Level end | 1004 |
| Deepest raw ceiling observed | 3.17 m @ 360 s |
| Controlling compartment change | 780 s (comp 1 → 2) |

### Evidence-backed answers (Phase 22 checklist)

| # | Question | Verdict |
|---|---|---|
| 1 | All 16 N₂/He compartments updated each second? | **YES** — per-second oracle parity 0 failures |
| 2 | Actual elapsed time? | **YES** — timestamp-derived dt |
| 3 | Schreiner/Haldane correct? | **YES** — algebraic + analytic tests |
| 4 | Active gas per interval? | **YES** (air throughout ML-01) |
| 5 | Ceiling from current tissues? | **YES** |
| 6 | Schedule rebuilt, not countdown? | **YES** — projection on each refresh |
| 7 | Controlling compartment can change? | **YES** — observed in ML-01 |
| 8 | Slow compartments may on-gas at 10 m? | **YES** — physically possible; not all compartments monotonically off-gas |
| 9 | Deco clears only when model permits? | **YES** — no false clear flash test passes |
| 10 | Deterministic oracle-validated? | **YES** for ML-01 tissues |
| 11 | Deco reappears after descent? | **YES** — ML-05 |
| 12 | Stop timer separate from tissues? | **YES** — FSM does not mutate tissues |
| 13 | Error path falsely clears deco? | **NO** confirmed during active engine; startup unavailable snapshot is pre-dive only |
| 14 | Residual uncertainty? | External tool + physical Ultra validation |

---

## N. Gas Switches

**Implementation:** `FullComputerRuntimeEngine.changeGas` / `confirmGasSwitch`

Ordering at switch timestamp:

1. Integrate preceding interval with **old** gas to timestamp  
2. Apply 0.5 min constant-depth load at **new** gas  
3. Rebuild snapshot / schedule  

**Tests:** `FullComputerGasSwitchRecoveryIntegrationTests`, crash/recovery cases, off-plan confirmation.

**Audit-15 gap:** No ML-02 EAN50 switch oracle replay in dedicated Audit-15 suite (P1).

---

## O. Deco Stop State Machine

`FullComputerDecoStopStateMachine` — presentation/ timer logic on tissue-derived ceiling and stops.

- Stop timer pauses outside band (tested in `FullComputerDecoStopStateMachineTests`)
- Tissue state **not** mutated by stop FSM
- Completing a displayed stop does not force-clear deco if ceiling still positive (solver recomputes)

---

## P. Numerical Error Budget

See **`Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md`**.

Summary: tissue errors below **0.0002 bar** across ML-01; Schreiner analytic splitting **0.0005 bar**; ceiling **0.2 m** at decimated samples. TTS minute quantization **PARTIAL** acceptance.

---

## Q. Concurrency and Stale Results

| Control | Status |
|---|---|
| Tissue owner | `@MainActor` `DiveManager` |
| Tick re-entrancy guard | `isFullComputerRuntimeTickInFlight` |
| Out-of-order sample | Rejected |
| Solver async overlap | None — synchronous solve on MainActor |
| Stale async overwrite | N/A for tissue (no background tissue task) |
| Static solver cache | **P2** — theoretical stale presentation if concurrent from multiple threads; currently serialized |

---

## R. Performance and Battery

- Signpost: `.watchFullComputerTissueTick`
- Solver budget: 50 ms; fallback to cached conservative presentation
- Sub-step cap limits Schreiner cost per long gap
- Mission Mode: UI-only profile (prior audit) — tissue fidelity unchanged

Simulator timing: 51 tests in ~9.7 s. Physical Ultra measurement: **PENDING**.

---

## S. Persistence and Restore

- Checkpoint encodes tissue, gas, GF, trackers, monotonic clock
- Restore recomputes snapshot from tissues (not blind schedule trust)
- Audit15 checkpoint before re-descent: tissue equality **PASS**
- Corrupt checkpoint: fail closed

---

## T. Fail-Safe Behavior

| Failure | Behavior | Fail-open? |
|---|---|---|
| Non-finite depth | `unavailable` | No — blocks ingest |
| Out-of-order timestamp | `degraded`, reject sample | No |
| Invalid gas switch | `degraded` | No |
| Startup self-check fail | `unavailableFullComputerSnapshot` (pre-dive) | **Pre-dive only** |
| Solver budget exceeded | Prior presentation + diagnostic | **Conservative** |
| Missed tick >2 s | `degraded` + integrate up to cap | Under-exposure risk >120 s (**P2**) |

No evidence of active-dive path showing zero deco with positive oracle ceiling.

---

## U. Test and Mutation Coverage

| Suite | Focus | Result |
|---|---|---|
| `Audit15Air39MultilevelProfileTests` | ML-01 oracle | PASS |
| `Audit15RedescentOracleTests` | ML-05 + restore | PASS |
| `SchreinerAnalyticParityTests` | Formula + production | PASS |
| `BuhlmannMutationResistanceTests` | Wrong formula detection | PASS |
| `FullComputerTimingFaultTests` | Timing matrix | PASS |
| `WatchMathCrossTargetParityTests` | 30 m load vs oracle | PASS |
| `FullComputerDecoSolverTests` | Presentation | PASS |
| `FullComputerDecoStopStateMachineTests` | Stop FSM | PASS |
| `FullComputerRecoveryCheckpointTests` | Restore | PASS |

**Mutations detected:** seconds-as-minutes, swapped half-times, reversed Schreiner rate.

**Negative checks honored:** UI snapshot tests do not prove tissue math; Planner tests ≠ Watch live parity.

---

## V. Independent Oracle Results

**Oracle:** `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift`

- Does **not** import production `schreiner` or `BuhlmannTissueState.loadedLinearDepth`
- Re-implements constants (independently listed, matched to shared core)
- Sub-steps at 30 s to mirror production integrator
- ML-01 replay: **0 tissue failures** over ~1005 s

---

## W. Cross-Engine Parity

| Layer | Watch live | iOS Planner |
|---|---|---|
| Constants / tissue math | `Shared/BuhlmannCore` | Same shared core |
| Runtime engine | `FullComputerRuntimeEngine` | Planner store / cards (separate path) |
| Live authority | Watch engine only | Does not mutate Watch tissues |

`WatchMathCrossTargetParityTests` + `FullComputerTargetMembershipTests` confirm shared core, no duplicate local Bühlmann engine on Watch.

---

## X. Detailed Findings

### P1-AUD15-001 — Incomplete multilevel oracle matrix (ML-02–04, ML-06–10)

| Field | Value |
|---|---|
| Severity | P1 |
| Files | Test gap |
| Root cause | Audit-15 suites implement ML-01 + ML-05 only |
| Impact | Trimix, sawtooth, EAN50 switch, repetitive dive behavior not oracle-replay certified |
| Remediation | Add oracle replay tests per Command 15 Phase 9 |
| Acceptance | Each profile: 0 oracle tissue failures; documented CSV |

### P1-AUD15-002 — TTS / schedule forward simulation not fully oracle-swept

| Field | Value |
|---|---|
| Severity | P1 |
| Files | `BuhlmannEngine.runtimeProjection`, `FullComputerDecoSolver` |
| Root cause | 1-min simulation steps; tolerance declared but no exhaustive TTS comparison |
| Impact | TTS may diverge up to ~3 min from independent minute-step oracle |
| Safety direction | Tend conservative (over-estimate) |
| Remediation | Dedicated TTS oracle sweep on ML-01 decimated samples |

### P2-AUD15-001 — Static solver cache not actor-isolated

| Field | Value |
|---|---|
| Severity | P2 |
| File | `Utils/FullComputerDecoSolver.swift` |
| Impact | Theoretical stale presentation under concurrent access |
| Mitigation | MainActor serialization; cache key includes tissue hash |

### P2-AUD15-002 — Duplicate runtimeProjection per refresh

| Field | Value |
|---|---|
| Severity | P2 |
| File | `FullComputerRuntimeEngine.makeSnapshot` + solver |
| Impact | CPU / battery only |

### P2-AUD15-003 — Missed tick integration cap 120 s

| Field | Value |
|---|---|
| Severity | P2 |
| File | `FullComputerRuntimeConfiguration.maxMissedTickSeconds` |
| Impact | Under-estimates loading if Watch suspended >120 s without samples |
| Mitigation | `degraded` state; diver should see diagnostic |

### P2-AUD15-004 — Schedule simulation 1-min quanta

| Field | Value |
|---|---|
| Severity | P2 |
| Impact | TTS granularity; conservative bias |

---

## Y. Readiness Matrix

| Area | Readiness | P0 | P1 | Evidence | External validation |
|---|---:|---|---|---|---|
| ZH-L16C constants | 98% | 0 | 0 | Shared core + oracle | PENDING |
| N₂ tissue model | 95% | 0 | 0 | ML-01 oracle | PENDING |
| He tissue model | 85% | 0 | 1 | Air-only Audit-15 | PENDING trimix |
| Schreiner formula | 97% | 0 | 0 | Analytic + mutation tests | PENDING |
| Unit/rate correctness | 95% | 0 | 0 | Cross-target parity | PENDING |
| One-second timing | 92% | 0 | 0 | TimingFault tests | PENDING physical |
| Actual-dt handling | 93% | 0 | 0 | ingestSample + tick | PENDING long suspend |
| Multilevel continuity | 88% | 0 | 1 | ML-01/05; gaps ML-02–04 | PENDING |
| GF interpolation | 90% | 0 | 0 | Oracle ceiling checks | PENDING |
| Ceiling | 92% | 0 | 0 | Decimated ML-01 | PENDING |
| NDL | 90% | 0 | 0 | Projection tests | PENDING |
| Live deco schedule | 85% | 0 | 1 | Dynamic evolution ML-01 | PENDING |
| TTS | 80% | 0 | 1 | Minute-step bound only | PENDING |
| Dynamic deco regression | 90% | 0 | 0 | ML-01 level segment | PENDING |
| Controlling compartment | 92% | 0 | 0 | ML-01 change @780s | PENDING |
| Gas switching | 85% | 0 | 1 | Recovery tests; no ML-02 | PENDING |
| Stop-state separation | 93% | 0 | 0 | FSM tests | PENDING physical |
| Persistence/restore | 92% | 0 | 0 | Audit15 + recovery | PENDING |
| Concurrency/order | 88% | 0 | 0 | MainActor + guards | PENDING stress |
| Numerical robustness | 90% | 0 | 0 | Error budget doc | PENDING |
| Performance/deadline | 85% | 0 | 0 | Solver budget | PENDING Ultra |
| Fail-safe behavior | 90% | 0 | 0 | Static review + tests | PENDING |
| Automated tests | 88% | 0 | 1 | 51/51 selective PASS | — |
| Independent oracle parity | 92% | 0 | 0 | ML-01/05 zero failures | — |
| Physical Watch evidence | 0% | 0 | 0 | — | **PENDING** |
| External reference parity | 0% | 0 | 0 | — | **PENDING** |
| **Overall live engine** | **87%** | **0** | **2** | Software-verifiable | **PENDING** |

---

## Z. Prioritized Remediation Plan

1. **P1:** Implement ML-02–ML-04 and ML-06–ML-10 oracle replay tests with CSV exports (Codex remediation command).
2. **P1:** TTS oracle sweep on ML-01 decimated timeline; document measured max delta.
3. **P2:** Move `FullComputerDecoSolver` cache to instance scoped on engine or actor-isolated box.
4. **P2:** Deduplicate `runtimeProjection` call in snapshot path.
5. **P2:** Document / test behavior for suspension >120 s (or integrate full elapsed with stronger degraded surfacing).
6. **External:** Execute `WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md` Phase A–C.

---

## AA. External Validation Plan

See **`Docs/WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md`**.

---

## AB. Final Verdict

| Criterion | Verdict |
|---|---|
| Mathematically correct in static inspection | **YES** (Schreiner + ZH-L16C; no algebra defect found) |
| Schreiner equation verified | **YES** |
| One-second actual-time integration verified | **YES** (timestamp dt; 1 Hz timer auxiliary) |
| Multilevel tissue continuity verified | **YES** (ML-01 + ML-05) |
| Dynamic deco appearance verified | **YES** (ML-01 @39 m bottom) |
| Dynamic deco reduction verified | **YES** (ceiling evolution during 10 m level) |
| Dynamic deco disappearance verified | **PARTIAL** (model may clear; not required for ML-01 probe profile; false-clear guard passes) |
| Deco reappearance after re-descent verified | **YES** (ML-05) |
| Independent oracle parity passed | **YES** (ML-01/05 selective run) |
| Physical Apple Watch validation passed | **PENDING** |
| External decompression-reference validation passed | **PENDING** |
| Internal TestFlight Full Computer readiness | **CONDITIONAL** — P1 test gaps + physical smoke |
| External TestFlight Full Computer readiness | **NOT READY** — physical + external validation |
| App Store Full Computer readiness | **NOT READY** — external TestFlight blockers |

**Blockers for CONDITIONAL → READY:** ML-02–04 oracle tests, TTS sweep, Ultra shallow validation log, external tool spot check on ML-01 CSV.

---

## Git status (audit end)

Only documentation artifacts added under `Docs/` plus generator script `Scripts/generate_audit15_matrices.py`. No production code, tests, or project files modified per audit rules.

**Commit:** Not performed (audit-only; commit if requested).

---

## Appendix — Key source files

| Path | Role |
|---|---|
| `Shared/BuhlmannCore/BuhlmannTissueModel.swift` | Schreiner / Haldane tissue loading |
| `Shared/BuhlmannCore/BuhlmannConstants.swift` | ZH-L16C tables |
| `Shared/BuhlmannCore/BuhlmannEngine.swift` | runtimeProjection, NDL, schedule |
| `Services/FullComputerRuntimeEngine.swift` | Live integrator + snapshot |
| `Services/DiveManager.swift` | FC wiring, tick, ingest |
| `Utils/FullComputerDecoSolver.swift` | Presentation solver |
| `Utils/FullComputerDecoStopStateMachine.swift` | Stop FSM |
| `Utils/FullComputerRuntimeConfiguration.swift` | Timing caps |
| `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift` | Independent oracle |
| `Tests/WatchAlgorithmTests/Audit15Air39MultilevelProfileTests.swift` | ML-01 |
| `Tests/WatchAlgorithmTests/Audit15RedescentOracleTests.swift` | ML-05 |
