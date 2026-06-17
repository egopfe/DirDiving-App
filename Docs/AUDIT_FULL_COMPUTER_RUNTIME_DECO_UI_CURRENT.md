# AUDIT 02 — Full Computer Runtime, Decompression and UI (read-only)

**Date:** 2026-06-17  
**Auditor:** Independent automated + manual code review (no code changes)  
**Command:** `02_AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI.md`  
**Branch:** `main` @ `a5392c5`  
**Prerequisite:** Audit 01 / remediation V1.1 **PASS** (`Docs/FULL_COMPUTER_FOUNDATIONS_REMEDIATION_REPORT_V1.1.md`)

---

## Executive summary

| Platform | Runtime / deco / live UI | Verdict |
|----------|--------------------------|---------|
| **Watch MAIN** (Full Computer mode) | Live Bühlmann runtime, prospective solver, stop state machine, `DiveLiveView` panels | **PASS** |
| **iOS Companion** | Pre-dive **planner** (`BuhlmannEngine.plan`) and logbook merge for FC metadata — **no** in-water FC runtime or deco UI | **N/A (by design)** |

**Overall:** **PASS** — Watch Full Computer runtime, decompression presentation, and UI meet Audit 02 scope on `main`. iOS correctly consumes the shared Bühlmann core for **planning** only; live NDL/TTS/ceiling/stop UX is Watch-exclusive.

---

## Scope map

| Audit area | Primary implementation | Watch | iOS |
|------------|------------------------|-------|-----|
| Bühlmann runtime | `Services/FullComputerRuntimeEngine.swift` + `Shared/BuhlmannCore/` | **Yes** | No live engine |
| Tissue integration (1 Hz nominal, real Δt) | `tick()`, `ingestSample()`, sub-steps in `FullComputerRuntimeConfiguration` | **Yes** | — |
| Multilevel / yo-yo profiles | `advanceTissuesLinear` + sample ingest | **Yes** | — |
| NDL / TTS / ceiling / controlling compartment | `BuhlmannEngine.runtimeProjection` | **Yes** | Planner only |
| Prospective solver (no live tissue mutation) | `Utils/FullComputerDecoSolver.swift` | **Yes** | — |
| Stop state machine | `Utils/FullComputerDecoStopStateMachine.swift` | **Yes** | — |
| Stop thresholds & hysteresis | `Utils/FullComputerDecoStopConfiguration.swift` | **Yes** | — |
| Live FC UI | `Views/FullComputerLivePanels.swift`, `Views/DiveLiveView.swift` | **Yes** | — |
| Stopwatch / manual controls in deco | `hideManualStopwatch` + `fullComputerHidesManualControls` | **Yes** | — |

---

## 1. Runtime Bühlmann (Watch)

### Architecture

- **Single canonical engine:** `Shared/BuhlmannCore/BuhlmannEngine.swift` (`runtimeProjection`, `noDecompressionLimit`, `gfAtDepth`, `plan`).
- **Watch orchestration:** `FullComputerRuntimeEngine` owns live `BuhlmannTissueState`, advances tissues on samples and 1 Hz ticks, projects via shared core, feeds `FullComputerDecoSolver` + `FullComputerDecoStopStateMachine`.
- **No duplicate decompression math** on Watch outside allowlisted Full Computer files (guarded by `FullComputerWatchArchitectureGuard`).

### Tissue update policy

| Invariant | Implementation | Status |
|-----------|----------------|--------|
| Nominal 1 s tick | `FullComputerRuntimeConfiguration.nominalTickSeconds = 1.0` | **PASS** |
| Real elapsed Δt on tick | `tick(now:)` uses `now.timeIntervalSince(lastComputedTimestamp)` | **PASS** |
| Constant-depth load between samples | `advanceTissuesConstant` when no fresh depth sample | **PASS** |
| Linear depth change on ingest | `advanceTissuesLinear` with fractional depth interpolation | **PASS** |
| Sub-step cap | `maxSubStepSeconds = 30` | **PASS** |
| Missed tick cap + degraded flag | `maxMissedTickSeconds = 120`; `missed_tick:` diagnostic when Δt > 2 s | **PASS** |
| Non-finite / negative depth rejected | `ingestSample` → `markUnavailable` / no tissue reset | **PASS** |
| Regressive timestamp rejected | `non_monotonic_timestamp` → degraded, tissues preserved | **PASS** |

---

## 2. Mathematical controls

| Control | Evidence | Status |
|---------|----------|--------|
| Haldane at constant pressure | `loadedConstantDepth` → Schreiner with zero rate | **PASS** |
| Schreiner on linear depth change | `BuhlmannTissueState.loadedLinearDepth` | **PASS** |
| Separate N₂ / He compartments | `BuhlmannTissueCompartment` + dual Schreiner | **PASS** |
| GF interpolation | `BuhlmannEngine.gfAtDepth` in shared core | **PASS** |
| Continuous ceiling vs operational stop depth | `rawCeilingMeters` vs `operationalCeilingMeters` in projection | **PASS** |
| Live tissue not mutated during TTS simulation | `FullComputerDecoSolver` receives `BuhlmannTissueState` by value; projection is read-only | **PASS** |
| Irregular Δt / missed ticks | `FullComputerRuntimeEngineTests` | **PASS** |
| Non-finite / regressive inputs | `FullComputerReleaseHardValidationTests` | **PASS** |
| 1 s tick vs sub-step convergence | Sub-step integration in engine; golden/planner tolerance tests | **PASS** |

---

## 3. NDL / TTS / ceiling / controlling compartment

- **NDL:** `projection.ndlMinutes` → no-deco presentation (`ndlDisplayMinutes`, accent thresholds).
- **TTS:** `projection.ttsMinutes` → deco top panel.
- **Ceiling:** exact (`ceilingMetersExact`) vs rounded display (`presentationCeilingMeters`); operational ceiling drives stop logic.
- **Controlling compartment:** `controllingCompartmentRaw` / `controllingCompartmentOperational` on snapshot.
- **Planner parity:** `testRuntimeMatchesPlannerForConstantDepthProfile`, `testPlannerRuntimeTTSWithinTolerance`, differential TTS tests in `FullComputerReleaseHardValidationTests`.

---

## 4. Prospective solver (`FullComputerDecoSolver`)

- Calls `BuhlmannEngine.runtimeProjection` on solver input tissue copy.
- **Cache** keyed by tissue, depth, gas, GF, runtime, gas signatures; **50 ms** performance budget with conservative fallback.
- **Mode split:** `.noDecompression` vs `.decompression` with atomic transition (no zero-NDL flash in deco).
- **Ceiling violation:** distinct from “outside stop window” — `depth + 0.35 m < ceilingExact` when deco required.

---

## 5. Stop state machine

### Configuration (`FullComputerDecoStopConfiguration`)

| Parameter | Value | Audit spec |
|-----------|-------|------------|
| Shallow margin | **0.5 m** (`D − 0.5`) | **PASS** |
| Deep margin | **1.0 m** (`D + 1.0`) | **PASS** |
| Reset / recalc margin | **2.0 m** (`D + 2.0`) | **PASS** |
| Hysteresis | **0.15 m** | **PASS** (within 0.1–0.2 m) |

### Behaviour

| Control | State / behaviour | Status |
|---------|-------------------|--------|
| Timer active in valid window | `.holdingStop`, `timerAccruing = true` | **PASS** |
| Timer suspended too shallow | `.tooShallow`, frozen remaining | **PASS** |
| Timer suspended too deep | `.tooDeep`, frozen remaining | **PASS** |
| Recalc beyond D+2 m | `.stopRecalculation`, `progressInvalidated` | **PASS** |
| Ceiling violation priority | `.ceilingViolation`, red panel | **PASS** |
| Deco completed | `.decoCompleted` when no stops remain | **PASS** |
| Engine integration | `testEngineIntegratesStopStateInSnapshot` | **PASS** |

**Note:** Stop countdown is **model-synchronized** (remaining minutes from Bühlmann projection, refreshed each tick), not an independent wall-clock stopwatch. This matches decompression-computer semantics; frozen remaining is preserved when leaving the valid window.

---

## 6. UI controls (Watch `DiveLiveView`)

### Top metrics panel (`FullComputerTopMetricsPanel`)

| Mode | Layout | Status |
|------|--------|--------|
| No-deco | **NDL \| Runtime** | **PASS** |
| Deco | **TTS \| CEILING \| Runtime** | **PASS** |

### NDL accent colours

| Threshold | Colour | Test |
|-----------|--------|------|
| NDL > 10 | Green | `testNDLAccentThresholdsMatchCommandEleven` |
| 5 < NDL ≤ 10 | Yellow | same |
| NDL ≤ 5 | Red | same |

### Deco stop panel (`FullComputerDecoStopStatePanel`)

| Visual | Implementation | Status |
|--------|----------------|--------|
| Large deco panel | `showDecoProgressPanel` / `FullComputerDecoStopStatePanel` | **PASS** |
| Green horizontal arrow at stop depth | `.hold` → capsule + `arrow.left` | **PASS** |
| Yellow arrow down (too shallow) | `.descend` / `.tooShallow` | **PASS** |
| Yellow arrow up (too deep) | `.ascend` / `.tooDeep` | **PASS** |
| Red ceiling violation | banner + red accents | **PASS** |
| Atomic mode transition | `testAtomicTransitionToDecompressionNeverShowsZeroNDL` | **PASS** |

### Stopwatch and manual controls

- During deco states: `hideManualStopwatch = true` from state machine → `fullComputerHidesManualControls` hides stopwatch and lifecycle controls in `DiveLiveView`.
- **No-deco Full Computer:** manual stopwatch may still appear (audit scope: removal **in decompression** — satisfied).

### Mockup / chat references

- **No** “chat mockup” strings in Full Computer production Swift.
- External `FC_UI_*` PNGs indexed only in `Utils/FullComputerMockupReferenceMatrix.swift` (not embedded); `testNoRasterMockupEmbeddedInWatchBundle` **PASS**.

---

## 7. iOS Companion (audit boundary)

On `main`, iOS does **not** implement live Full Computer dive UI:

- **Planner:** `iOSApp/Services/BuhlmannPlanner.swift` → `BuhlmannEngine.plan` (shared core).
- **Logbook:** `FullComputerDiveLogbookMetadata` merge in `DiveSessionMerge`.
- **No** `FullComputerRuntimeEngine`, `FullComputerLivePanels`, or in-water NDL/TTS panels on iOS.

This is consistent with Watch MAIN as the decompression runtime surface. iOS mathematical parity is covered by existing iOS algorithm / golden fixture suites (Audit 01).

---

## 8. Minimum tests (Audit 02 checklist)

| Scenario | Test coverage | Result |
|----------|---------------|--------|
| Square / constant-depth profile | `testRuntimeMatchesPlannerForConstantDepthProfile` | **PASS** |
| Multilevel profile | `testMultiLevelProfileUpdatesTissues`, `testMultilevelProfileProducesFiniteDecoMetrics` | **PASS** |
| Yo-yo (descent/ascent) | `testDescentAndAscentProfile` | **PASS** |
| Single / multiple deco | `testDecoStopPanelAppearsWhenStopsExist`, planner differential tests | **PASS** |
| Oscillations near stop | `testHysteresisReducesOscillationAtShallowEdge` | **PASS** |
| Sample loss / missed ticks | `testMissedTicksStayConservativeWithoutResettingTissues` | **PASS** |
| Solver performance | `testDecoSolverRespectsPerformanceBudget`, `testProjectionPerformanceBudget` | **PASS** |
| Snapshot / state | `FullComputerRecoveryCheckpointTests`, `testCheckpointRoundTripWithinBudget` | **PASS** |
| UI state matrix (20 states) | `FullComputerUIStateMatrixTests`, `FullComputerLivePanelFixtures` | **PASS** |

### Focused test execution (2026-06-17, simulators: iPhone 17 Pro, Apple Watch Ultra 3 49mm)

| Suite | Tests executed | Failures |
|-------|----------------|----------|
| `FullComputerRuntimeEngineTests` | 11 | 0 |
| `FullComputerDecoSolverTests` | 7 | 0 |
| `FullComputerDecoStopStateMachineTests` | 10 | 0 |
| `FullComputerUIStateMatrixTests` | 7 | 0 |
| `FullComputerReleaseHardValidationTests` | 15 | 0 |
| **Subtotal (Audit 02 core)** | **50** | **0** |

Related (foundations / architecture): `FullComputerWatchArchitectureGuardTests` (7), `BuhlmannCoreCrossTargetEquivalenceTests`, golden fixtures — all green on `main` per remediation V1.1.

### Builds

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS | **BUILD SUCCEEDED** |

---

## 9. Findings

| ID | Severity | Finding | Recommendation |
|----|----------|---------|----------------|
| — | — | No P1 blockers | — |
| **P2** | Info | iOS has no live FC runtime/deco UI | Document in Command 04+ if companion live mirror is ever required |
| **P3** | Low | `requiresDecompression` compares `ndlMinutes` to `decoCeilingEpsilonMeters` (0.05) — works for integer minutes but mixes units in source | Optional readability refactor (not required for correctness) |
| **P3** | Low | Stop timer display is projection-driven, not wall-clock | Acceptable; document for QA scripts |

---

## 10. Readiness matrix

| Area | Required | Result |
|------|----------|--------|
| Watch Bühlmann runtime | Live tissue + projection | **PASS** |
| 1 s nominal / real Δt integration | Engine tick + ingest | **PASS** |
| Multilevel / yo-yo tissues | Linear loading | **PASS** |
| NDL / TTS / ceiling / compartment | Snapshot fields | **PASS** |
| Prospective solver (no live mutation) | `FullComputerDecoSolver` | **PASS** |
| Stop zones D±0.5 / D+1.0 / D+2.0 | Configuration + tests | **PASS** |
| Hysteresis 0.1–0.2 m | 0.15 m | **PASS** |
| No-deco UI NDL \| Runtime | Top panel | **PASS** |
| Deco UI TTS \| CEILING \| Runtime | Top panel | **PASS** |
| NDL colour thresholds | Green / yellow / red | **PASS** |
| Deco panel + directional arrows | Stop state panel | **PASS** |
| Hide stopwatch in deco | `hideManualStopwatch` | **PASS** |
| No chat mockup in code | Static scan | **PASS** |
| Minimum test matrix | 50 core tests | **PASS** |
| iOS planner shared core | `BuhlmannPlanner` | **PASS** |
| **Ready for Command 04+** | — | **YES** |

---

## 11. Related documentation

| Document | Role |
|----------|------|
| `Docs/AUDIT_FULL_COMPUTER_FOUNDATIONS_CURRENT.md` | Audit 01 baseline |
| `Docs/FULL_COMPUTER_FOUNDATIONS_REMEDIATION_REPORT_V1.1.md` | Foundations remediation |
| `Docs/DIR_DIVING_NDL_TTS_CEILING_DECO_SOLVER_REPORT.md` | Solver design |
| `Docs/DIR_DIVING_DECO_STOP_STATE_MACHINE_AND_UI_REPORT.md` | Stop machine + UI |
| `Docs/FULL_COMPUTER_RELEASE_HARD_TEST_MATRIX.md` | 25 mockup index + test matrix |

---

*Audit 02 — read-only. No application code modified.*
