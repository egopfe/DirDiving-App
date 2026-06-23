# Master Watch Full Computer — Full Deep Forensic Audit — CURRENT

**Command:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.0.md`  
**Audit date:** 2026-06-22  
**Repository:** `egopfe/DirDiving-App`  
**Branch:** `main`  
**Commit:** `1f62235`  
**Working tree:** clean (`main...origin/main` 0/0)  
**Task type:** read-only forensic audit (Docs outputs only)

**Merged scope:** Watch Diving Computer full audit + Live Bühlmann/Schreiner multilevel audit (Command 15)

**Deliverables:** 12 files under `Docs/MASTER_WATCH_FULL_COMPUTER_*_CURRENT.*`

---

## A. Executive Summary

This merged forensic audit re-examines the Apple Watch **Full Computer** live decompression path on `main` @ `1f62235`: environment authority, CMAltimeter predive flow, Bühlmann ZH-L16C Schreiner/Haldane tissue integration, multilevel schedule recomputation, checkpoint/restore, and reference-only planner/CCR isolation.

**Headline:** No **P0** safety defect confirmed in static review or targeted automated testing at this baseline. Prior altitude sea-level fallback issues (ALT-P0) are **verified FIXED** — `runtimePlan()` returns `nil` without validated environment; imported plans propagate altitude. ML-01 through ML-10 oracle profiles **PASS** in Audit-15 suites. The central **39 m Air → 10 m** scenario is answered from tissue state: ceiling reduces, controlling compartment migrates, schedule rebuilds each refresh; clearance at 10 m is model-dependent, not timer-driven.

**Gaps:** TTS/schedule oracle uses production projection (MWFC-P1-001); external tool validation **PENDING**; physical Watch QA **PENDING**; full Watch Algorithm Tests session incomplete in audit run (507 tests, 0 failures, no final banner).

| Severity | Count | Summary |
|---:|---:|---|
| P0 | 0 | No confirmed false clearance, tissue corruption, or fail-open active-dive deco path |
| P1 | 2 | Hybrid TTS oracle; external validation not executed |
| P2 | 4 | Physical QA pending; altitude ML replay partial; TTS 1-min quanta; test session incomplete |
| P3 | 3 | Dead deltaSeconds in stop FSM; logbook provenance edge; project.yml explicit list |
| P4 | 2 | Test-only seaLevel defaults; external CSV scaffold fill pending |

**Verdict:** **PARTIAL** — strong software evidence; physical and external gates open.

---

## B. Source Commands Merged

- `MASTER_WATCH_DIVING_COMPUTER_FULL_AUDIT_COMMAND_V1.0.md` (architecture, lifecycle, isolation)
- `15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_V3.0.md` (Schreiner, oracle, ML profiles)

---

## C. Latest Development Update

Respected current architecture: Settings mode switch, activity isolation, Watch FC altitude/environment policy, CMAltimeter proposal flow, multilevel Bühlmann/Schreiner runtime, live decompression state, planner briefing cards reference-only, no cross-activity leakage.

---

## D. Branch, Commit and Scope

| Check | Result |
|---|---|
| Branch | `main` ✓ |
| Commit | `1f62235` |
| origin/main | synced 0/0 |
| Primary target | `DIRDiving Watch App` — Full Computer |
| Test target | `DIRDiving Watch Algorithm Tests` |
| Xcode | 26.5 (17F42) |
| Physical Watch | **Not available** — PENDING_PHYSICAL |
| External oracle tool | **Not executed** — PENDING_EXTERNAL_VALIDATION |

---

## E. Preflight and Build/Test Baseline

```text
git branch --show-current → main
git rev-parse --short HEAD → 1f62235
xcodegen generate → SUCCESS
```

**Watch Algorithm Tests:**

| Attempt | Result |
|---|---|
| 1 (default DerivedData) | **NOT_EXECUTED** — build.db locked |
| 2 (isolated DerivedData /tmp/DIRDiving-Audit-DD) | **PARTIAL** — 507 tests executed, 0 failures; Audit15 + FC suites PASS; no TEST SUCCEEDED banner (session incomplete) |

**Confirmed PASS suites (log evidence):** Audit15Air39MultilevelProfileTests, Audit15MultilevelOracleProfilesTests (ML-02..ML-10), Audit15RedescentOracleTests, Audit15TTSScheduleOracleSweepTests, SchreinerAnalyticParityTests, FullComputerTimingFaultTests, OrchestratedAltitudeEnvironmentTests.

**iOS parity tests:** **NOT_EXECUTED** in this session.

---

## F. Existing Audit Coverage and Specialized Gap

| Prior audit | Covered | This audit adds |
|---|---|---|
| WATCH_MAIN_ALGORITHM_MATH_AUDIT | Gauge lifecycle, depth pipeline | FC live tissue authority proof |
| WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL | ML-01/05, Schreiner, timing | **Re-audit @ 1f62235**, ML-02..10 confirmation, merged master matrices |
| WATCH_CMALTIMETER_* | Sensor lifecycle | Integrated failure injection + startup authority |
| WATCH_BUHLMANN_ALTITUDE (ALT-P0) | Reported sea-level fallback | **Verified FIXED** at current baseline |

**Still open:** external tool parity, physical Ultra QA, altitude ML oracle at elevation, fully independent TTS schedule oracle.

---

## G. Target Membership and Architecture

**Watch App compiles:** `FullComputerRuntimeEngine.swift`, `FullComputerEnvironmentSensorService.swift`, `FullComputerPrediveConfigurationStore.swift`, `Shared/BuhlmannCore/*`, FC views/utils, co-resident Gauge/Apnea/Snorkeling.

**Single tissue authority:** `FullComputerRuntimeEngine.tissueState` on `@MainActor` `DiveManager` when `sessionDivingMode == .fullComputer`.

**iOS:** Does not compile FC runtime engine (by design).

Evidence: `project.yml`, `FullComputerTargetMembershipTests`, `FullComputerWatchArchitectureGuard`.

---

## H. Product Safety Positioning

- No certified dive-computer / decompression-planner / CCR controller claim verified.
- Physical Apple Watch QA: **PENDING_PHYSICAL**
- External Bühlmann validation: **PENDING_EXTERNAL_VALIDATION**
- Planner briefing cards: **reference-only** verified

---

## I. Activity Isolation and Root Flow

```text
Launch → legal gate → activity Diving → Full Computer
  → Predive Settings → Confirmation → commitConfirmedProfile
  → runtimePlan() → FullComputerRuntimeEngine.init
  → ingestSample/tick → refreshSnapshot → UI
```

Gauge/Apnea/Snorkeling do not mutate FC tissues (`FullComputerNamespaceIsolationTests`, architecture guard).

---

## J. Full Computer Startup Authority

- `runtimePlan()` requires validated `confirmedEnvironment ?? draftEnvironment` — **no silent sea level**
- `legacyUnknown` source not authorized for live start
- `fullComputerPrediveConfirmed` gate in `DIRActivitySelectionStore`
- Active dive: `canEdit == false` — environment immutable

---

## K–P. Environment, CMAltimeter, Canonical Record

**Policy:** imported plan / manual Watch / sensor proposal (explicit accept only). No implicit sea-level fallback on live path.

**CMAltimeter:** `AppleWatchAbsoluteAltitudeProvider` — 5 samples, ±12 m spread, 8 s timeout, accuracy ≤30 m, requestGeneration isolation, fail-closed nil-data (3-strike), late error cannot overwrite `proposalReady`.

Evidence: `WatchCMAltimeterLifecycleTests`, `WatchCMAltimeterRemediationTests`, WCMA findings FIXED.

**FullComputerEnvironmentRecord:** schema v1, altitude, surface pressure, salinity, water density, source, capturedAt, sensor metadata; `validateForLiveStart()`.

---

## Q–S. Pressure Model, Constants, Tissue Init

**Chain:** depth → `AmbientPressureModel` → inspired inert → Schreiner/Haldane.

**ZH-L16C:** 16 compartments, N₂/He half-times and a/b in `BuhlmannConstants.swift` — index-aligned, immutable during dive.

**Init:** `PN2/He_initial = (surfacePressure - 0.0627) × fraction` using accepted environment.

---

## T–U. Schreiner and Haldane

**Schreiner** (`BuhlmannTissueModel.schreiner`): canonical form with `k = ln(2)/halfTime`; R→0 → Haldane.

110 vectors in `MASTER_WATCH_FULL_COMPUTER_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv` — all PASS.

---

## V–W. Timing and Tissue Integrity

- **Actual dt:** timestamp-derived; not blind 1 s
- Sub-step cap 30 s; degraded if Δt > 2 s; full integrate (no cap) on long suspension
- 16×N₂ + 16×He updated atomically; no reset on deco appear/disappear or stop FSM

---

## X–Y. GF, NDL, Schedule, TTS

Every `refreshSnapshot` → `BuhlmannEngine.runtimeProjection` + `FullComputerDecoSolver.solve` on current tissues.

Schedule at 39 m **not** authoritative after 10 m stay — rebuilds from tissues each refresh.

---

## Z–AA. Gas Switch and Stop FSM

Gas switch: integrate old gas to timestamp → 0.5 min load at new gas → rebuild schedule.

Stop FSM: model-synchronized timer; **does not** mutate tissues; completing displayed stop does not force-clear positive ceiling.

---

## AB. Multilevel Profiles ML-01..ML-10

| Profile | Oracle test | Result @ 1f62235 |
|---|---|---|
| ML-01 | Audit15Air39MultilevelProfileTests | **PASS** |
| ML-02 | testML02EAN50SwitchAt21m | **PASS** |
| ML-03 | testML03TrimixWithHeliumCompartments | **PASS** |
| ML-04 | testML04SawtoothMultilevelContinuity | **PASS** |
| ML-05 | Audit15RedescentOracleTests | **PASS** |
| ML-06..ML-10 | Audit15MultilevelOracleProfilesTests | **PASS** |

---

## AC. 39 m → 10 m Scenario Verdict

**Answer:** YES — software mechanics derive deco evolution from 16-compartment state.

| Event | ~Second |
|---|---:|
| Deco first appears @ 39 m | 210 |
| Deepest ceiling | 3.17 m @ 360 |
| Arrival @ 10 m | 404 |
| Controlling compartment 1→2 | 780 |
| Ceiling @ end of 10 m level | 0.98 m @ 1004 (not cleared — model-dependent) |

Deco obligation **may reduce** at 10 m; **does not disappear** merely from shallow time in ML-01; **may reappear** after re-descent (ML-05).

---

## AD–AF. Matrices

See CSV deliverables: altitude, Schreiner vectors, multilevel transitions.

---

## AG–AH. Independent Oracle and Analytic Parity

**Oracle:** `IndependentBuhlmannOracle.swift` — independent tissue Schreiner/Haldane; **does not** call production tissue update.

**Limitation (P1):** TTS sweep uses `productionProjectionOnOracleTissues` → MWFC-P1-001.

Analytic vs 1 s stepped: ≤0.0005 bar; production vs oracle tissues: ≤0.0002 bar.

---

## AI. Cross-Engine Parity

Shared `BuhlmannCore` between Watch live and iOS Planner math. Planner cards are **not** live authority. Watch live path isolated in `FullComputerRuntimeEngine`.

---

## AJ–AK. Persistence, Logbook, Sync

Checkpoint: SHA256, full tissue vector, environment, GF, gas, stop state. Restore fail-closed on corrupt.

Logbook metadata includes environment fields when provided (`FullComputerDiveLogbookMetadata`).

---

## AL. Planner Briefing / CCR Reference-Only

`PlannerBriefingCard.referenceOnly` enforced by freshness policy. No FC engine references to briefing cards.

---

## AM–AN. UI Truthfulness and App Intents

Environment source shown in predive UI; degraded timing banner; legal gate on intents (`LegalAcceptanceGateTests`, `ActionButtonIntentsSafetyTests`).

Physical small-screen VoiceOver/haptic priority: **PENDING_PHYSICAL**.

---

## AO–AQ. Failure, Edge, Requirement Matrices

See CSV files. Software failure paths fail-closed; no optimistic zero-deco on active dive errors confirmed.

---

## AR. Numerical Error Budget

See `MASTER_WATCH_FULL_COMPUTER_NUMERICAL_ERROR_BUDGET_CURRENT.md`.

---

## AS–AT. Concurrency and Performance

`@MainActor` DiveManager serializes tissue updates; instance-scoped solver cache (P2-AUD15-001 FIXED). Solver budget 50 ms → conservative fallback.

---

## AU. Test Coverage

Strong FC coverage: runtime, timing faults, deco solver/stop FSM, recovery, CMAltimeter, Audit15 oracle, mutation resistance, altitude orchestration.

**Mutation tests:** reversed rate, seconds-as-minutes detected.

---

## AV–AW. Physical QA and External Validation

All physical scenarios **PENDING_PHYSICAL**. External plan **PLANNED** — see dedicated docs.

---

## AX. Findings P0–P4

See `MASTER_WATCH_FULL_COMPUTER_FINDING_TRACEABILITY_CURRENT.csv`.

---

## AY. Readiness Matrix (evidence-based %)

| Gate | Readiness % |
|---|---:|
| TARGET_MEMBERSHIP | 98 |
| ACTIVITY_ISOLATION | 98 |
| ENVIRONMENT_SOURCE_POLICY | 95 |
| CMALTIMETER_LIFECYCLE (software) | 94 |
| SCHREINER_FORMULA | 99 |
| ONE_SECOND_TIMING / ACTUAL_DT | 97 |
| MULTILEVEL_ORACLE (ML-01..10) | 96 |
| ALTITUDE_AWARENESS (env path) | 90 |
| ALTITUDE_AWARENESS (full ML oracle) | 65 |
| INDEPENDENT_ORACLE (tissue) | 97 |
| INDEPENDENT_ORACLE (TTS) | 70 |
| PERSISTENCE_RESTORE | 96 |
| PHYSICAL_WATCH_QA | 0 |
| EXTERNAL_VALIDATION | 15 |
| OVERALL_WATCH_FULL_COMPUTER_SOFTWARE_READINESS | **88** |
| OVERALL_WATCH_FULL_COMPUTER_RELEASE_READINESS | **42** |

---

## AZ. Prioritized Remediation Plan

1. **MWFC-P1-002:** Execute external validation plan (Subsurface spot checks + ML-01 CSV).
2. **MWFC-P2-001:** Complete physical QA matrix on Ultra hardware.
3. **MWFC-P1-001:** Independent TTS/schedule forward simulator or documented third-party acceptance.
4. **MWFC-P2-002:** Altitude ML oracle replay campaign at 500–2000 m.
5. **MWFC-P3-001..003:** Maintainability items (non-blocking).

---

## BA. Release Blockers

- MWFC-P1-001, MWFC-P1-002 (external/TTS independence)
- MWFC-P2-001 (physical QA)
- All PENDING_PHYSICAL / PENDING_EXTERNAL_VALIDATION gates for external release

---

## BB. Final Verdict

```text
MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT: PARTIAL
BASELINE_CURRENT_AND_CLEAN: PASS
TARGET_MEMBERSHIP: PASS
LIVE_ENGINE_PATH_PROVEN: PASS
SINGLE_CANONICAL_TISSUE_STATE: PASS
ACTIVITY_ISOLATION: PASS
LEGAL_SAFETY_GATE: PASS
FULL_COMPUTER_STARTUP_AUTHORITY: PASS
ENVIRONMENT_SOURCE_POLICY: PASS
NO_EXPLICIT_OR_IMPLICIT_SEA_LEVEL: PASS
WATCH_CMALTIMETER_PREDIVE_ACQUISITION: PASS
CMALTIMETER_LIFECYCLE_AND_CANCELLATION: PASS
REQUEST_GENERATION_ISOLATION: PASS
LATE_CALLBACK_ISOLATION: PASS
SENSOR_SAMPLE_QUALITY_AND_FRESHNESS: PASS
EXPLICIT_SENSOR_PROPOSAL_ACCEPTANCE: PASS
IMPORTED_AND_MANUAL_SOURCE_PRESERVATION: PASS
CANONICAL_ENVIRONMENT_VALIDATION: PASS
SURFACE_PRESSURE_DERIVATION: PASS
WATER_DENSITY_SALINITY_CONSISTENCY: PASS
ACTIVE_DIVE_ENVIRONMENT_IMMUTABLE: PASS
ZH_L16C_CONSTANTS: PASS
TISSUE_INITIALIZATION_ALTITUDE_AWARE: PASS
ALL_16_N2_COMPARTMENTS: PASS
ALL_16_HE_COMPARTMENTS: PASS
HALDANE_PARITY: PASS
SCHREINER_FORMULA_VERIFIED: PASS
SCHREINER_UNIT_RATE_CONVENTIONS: PASS
SCHREINER_PARITY: PASS
ONE_SECOND_UPDATE_SEMANTICS: PASS
TIMING_ACTUAL_DT: PASS
TISSUE_STATE_INTEGRITY: PASS
GF_CEILING_ALTITUDE_AWARE: PASS
NDL_ALTITUDE_AWARE: PASS
TTS_ALTITUDE_AWARE: PASS
LIVE_DECO_SCHEDULE_RECOMPUTATION: PASS
GAS_SWITCH_ORDERING: PASS
STOP_STATE_SEPARATION: PASS
MULTILEVEL_ORACLE_PROFILES: PASS
AIR39_TO_10M_PROFILE: PASS
DYNAMIC_DECO_REDUCTION: PASS
DYNAMIC_DECO_DISAPPEARANCE_WHEN_MODEL_PERMITS: PASS
DECO_REAPPEARANCE_AFTER_REDESCENT: PASS
TRIMIX_HELIUM_PROFILE: PASS
INDEPENDENT_ORACLE_PARITY: PARTIAL
ANALYTIC_VS_ONE_SECOND_PARITY: PASS
NUMERICAL_ERROR_BUDGET: PASS
CONCURRENCY_STALE_RESULT_GUARDS: PASS
CHECKPOINT_RESTORE_ENVIRONMENT: PASS
PERSISTENCE_TISSUE_STATE: PASS
LOGBOOK_SENSOR_PROVENANCE: PARTIAL
SYNC_EXPORT_MATH_INTEGRITY: PARTIAL
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY: PASS
CCR_REFERENCE_ONLY_SAFETY: PASS
UI_DOCUMENTATION_TRUTHFULNESS: PASS
APP_INTENTS_SAFETY_GATE: PASS
FAILURE_INJECTION_COVERAGE: PARTIAL
WATCH_ALGORITHM_TESTS: PARTIAL
IOS_PARITY_TESTS: NOT_EXECUTED
MACOS_WATCH_BUILD: NOT_EXECUTED
P0_FINDINGS: 0
P1_FINDINGS: 2
P2_FINDINGS: 4
P3_FINDINGS: 3
P4_FINDINGS: 2
SOFTWARE_READINESS_PERCENT: 88
PHYSICAL_WATCH_QA_READINESS_PERCENT: 0
EXTERNAL_VALIDATION_READINESS_PERCENT: 15
OVERALL_RELEASE_READINESS_PERCENT: 42
PHYSICAL_APPLE_WATCH_SENSOR_QA: PENDING_PHYSICAL
PHYSICAL_DEPTH_SENSOR_QA: PENDING_PHYSICAL
PHYSICAL_ALTITUDE_DIVE_QA: PENDING_PHYSICAL
PHYSICAL_MULTILEVEL_DIVE_QA: PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_LIVE_DECO_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: MWFC-P1-001, MWFC-P1-002, MWFC-P2-001, MWFC-P2-002
```

---

## Required Final Questions (summary)

| # | Question | Verdict |
|---|---|---|
| 1–4 | FC in Watch MAIN; live path; single tissue; isolation | **YES** |
| 5–7 | No unsafe start; valid env required; no sea-level fallback | **YES** |
| 8–15 | CMAltimeter lifecycle; explicit accept; no bypass | **YES** (software) |
| 16–20 | Frozen env; altitude pressure; salinity | **YES** |
| 21–29 | ZH-L16C; 16 N2/He; Schreiner/Haldane | **YES** |
| 30–32 | Actual dt; suspension; atomic tissues | **YES** |
| 33–40 | GF/NDL/TTS/schedule; gas switch; multilevel dynamics | **YES** |
| 41–44 | ML profiles; analytic parity | **YES** (TTS oracle partial) |
| 45–49 | Tolerances; checkpoint; logbook/sync | **PARTIAL** |
| 50–51 | Briefing/CCR reference-only | **YES** |
| 52–58 | UI truth; performance; fail-open | **PARTIAL** / **PENDING_PHYSICAL** |
| 59–62 | Traceability; blockers | Documented in this report |

---

## Git Status (audit end)

Production code: **unchanged**. Only `Docs/MASTER_WATCH_FULL_COMPUTER_*` files written.

**Audit-only rule: honored.**
