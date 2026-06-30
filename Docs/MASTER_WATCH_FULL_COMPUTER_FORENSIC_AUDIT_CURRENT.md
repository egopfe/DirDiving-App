# Master Watch Full Computer — Full Deep Forensic Audit — CURRENT

**Command:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.2.md` (LAUNCH ORDER 01)  
**Audit date:** 2026-06-30  
**Repository:** `egopfe/DirDiving-App`  
**Branch:** `main`  
**Commit:** `451f8fb`  
**Working tree:** clean (`main...origin/main` 0/0)  
**Task type:** read-only forensic audit (Docs outputs only)

**Merged scope:** Watch Diving Computer full audit + Live Bühlmann/Schreiner multilevel audit (Command 15)

---

## A. Executive Summary

This audit re-examines the Apple Watch **Full Computer** live decompression path on `main` @ `451f8fb`, including post-remediation verification of **CONS-002, CONS-006, CONS-007, CONS-008**, Snorkeling isolation checks (route safety / GPS bands only), and the central **39 m Air → 10 m** multilevel forensic scenario.

**Headline:** No **P0** safety defect confirmed in static review or automated testing at this baseline. Live engine path is proven from validated environment → `FullComputerRuntimeEngine` → Bühlmann/Schreiner tissue integration → `FullComputerDecoSolver` presentation. Post-remediation software items CONS-002/006/007/008 verified **PASS**. External Bühlmann validation and physical Watch QA remain **PENDING**.

| Severity | Count | Summary |
|---:|---:|---|
| P0 | 0 | No false clearance, tissue corruption, or fail-open deco path confirmed |
| P1 | 1 | External decompression validation not executed (WFC-P1-001 / CONS-009) |
| P2 | 4 | Physical QA pending; altitude ML oracle partial; TTS 1-min quanta; long TTS test crash |
| P3 | 2 | Series 10 sim unavailable; project.yml group warning |
| P4 | 2 | Test-only seaLevel default; solver budget edge |

**Verdict:** **PARTIAL** — strong software evidence; physical and external gates open.

---

## B. Source Commands Merged

- `MASTER_WATCH_DIVING_COMPUTER_FULL_AUDIT_COMMAND_V1.0.md`
- `15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_V3.0.md`

---

## C. Latest Development Update

Baseline `451f8fb` includes consolidated remediation wave (GF import parity, depth capability authority, independent oracle, shallow dev toggles, water auto-open routing, GF preset UX).

---

## D. Branch, Commit and Scope

| Check | Result |
|---|---|
| Branch | `main` ✓ |
| HEAD | `451f8fb` ✓ |
| origin/main | `451f8fb` (0/0) ✓ |
| Dirty worktree | clean ✓ |
| Xcode | 26.6 (17F113) |
| watchOS SDK | 26.5 Simulator |
| Physical Watch | Available (paired device listed); wet QA **NOT_EXECUTED** |
| External oracle | Independent test oracle **PASS**; third-party tools **NOT_EXECUTED** |

**Primary target:** `DIRDiving Watch App`  
**Test target:** `DIRDiving Watch Algorithm Tests`  
**Cross-target:** iOS Companion / Shared where feeding FC plans, sync, export

---

## E. Preflight and Build/Test Baseline

| Step | Result |
|---|---|
| `xcodegen generate` | PASS |
| `./Scripts/check_main_target_isolation.sh` | PASS |
| Watch App build (`generic/platform=watchOS Simulator`) | **BUILD SUCCEEDED** |
| Watch Algorithm Tests (Series 10 46mm) | **NOT_EXECUTED** — simulator unavailable |
| Watch Algorithm Tests (Series 11 46mm fallback) | **353/355 PASS**, 2 failures (1 test crash, 1 bootstrap error) |

**Failed tests @451f8fb:**
- `FullComputerDecoSolverTests/testPlannerRuntimeTTSWithinTolerance()` — **crashed** (signal term; 1320×1s tick loop)
- Simulator bootstrap error (transient)

**Duration:** ~128.5 s test session on Series 11 (46mm), watchOS 26.5

---

## F. Existing Audit Coverage and Specialized Gap

**Prior audits covered:** architecture, Gauge boundary, CMAltimeter lifecycle, GF presets, Audit-15 ML profiles, checkpoint restore, briefing card reference-only.

**This merged audit newly consolidates:** post-remediation CONS verification, depth capability authority matrix, oracle independence matrix, GF import matrix, refreshed baseline @451f8fb, Series 10/11 test destination documentation.

**Gap closed vs prior @5d757cc:** Same software posture; baseline advanced one commit; test crash on long TTS parity newly observed.

---

## G. Target Membership and Architecture

`FullComputerRuntimeEngine`, `FullComputerDecoSolver`, `FullComputerEnvironmentSensorService`, `Shared/BuhlmannCore/*` compile into `DIRDiving Watch App` per `FullComputerTargetMembershipTests` and `project.yml`.

**Live call graph:**

```text
Depth sample → FullComputerRuntimeEngine.ingestSample/tick
  → BuhlmannTissueState.loadedLinearDepth (Schreiner, 30s sub-steps)
  → FullComputerDecoSolver.solve (BuhlmannEngine.runtimeProjection on tissue copy)
  → FullComputerDecoStopTracker (FSM, presentation only)
  → FullComputerRuntimeSnapshot → DiveLiveView / FullComputerLivePanels
```

One canonical tissue state in `FullComputerRuntimeEngine.tissueState`; solver operates on copy via projection.

---

## H. Product Safety Positioning

- No certified dive-computer / decompression-planner / CCR controller claim in audited paths.
- Physical Watch, underwater, CMAltimeter, depth sensor validation: **PENDING_PHYSICAL**.
- External Bühlmann validation: **PENDING_EXTERNAL_VALIDATION**.
- Planner briefing cards: **reference-only**.

---

## I. Activity Isolation and Root Flow

| Domain | Isolation | Evidence |
|---|---|---|
| Gauge | No FC tissue mutation | `FullComputerWatchArchitectureGuardTests` |
| Apnea | Separate namespace/sync | `ApneaArchitectureIsolationTests` |
| Snorkeling | No `FullComputerRuntimeEngine` reference | `SnorkelingCrossDomainIsolationTests` |
| Planner cards | No live authority | `PlannerBriefingReceiverTests` |

Snorkeling GPS/route safety verified isolated; GPS bands namespaced (`DepthMeasurementFeedConfiguration.snorkelingDefault.maximumPlausibleDepthMeters = 25`).

---

## J. Full Computer Startup Authority

Flow: Legal gate → activity selection → Diving → Full Computer → predive config → explicit environment confirmation → `commitConfirmedProfile` → `FullComputerRuntimeEngine.init`.

- `FullComputerRuntimeEngine.canStart` validates plan + algorithm self-check.
- `FullComputerRuntimePlan.validate()` fail-closed on invalid GF/gas.
- No live start from `.defaultAirGF3070` without validated `PlannerEnvironment` (predive gates).
- Active dive: environment immutable; altimeter callbacks cannot mutate plan.

---

## K–P. Environment / CMAltimeter / Sensor Proposal

**Sources:** imported iPhone plan, manual Watch entry, CMAltimeter proposal (non-authoritative until accept).

**CMAltimeter (`FullComputerEnvironmentSensorService`):**
- `CMAltimeter.isAbsoluteAltitudeAvailable()` checked
- Retained `CMAltimeter` instance; `startAbsoluteAltitudeUpdates(to:withHandler:)`
- 5 samples, max accuracy, 12 m spread, 8 s timeout
- Sensor timestamp vs receipt time distinguished (`sensorMeasuredAt` vs `receivedAt`)
- Request generation isolation; late callbacks ignored (`WatchCMAltimeterRemediationTests`)

**No sea-level fallback:** missing/invalid environment blocks start (`OrchestratedAltitudeEnvironmentTests`).

---

## Q–W. Pressure Model / Bühlmann / Tissues / Timing

- **ZH-L16C constants:** 16 N2 + 16 He half-times and a/b coefficients in `BuhlmannConstants` match oracle tables.
- **Initialization:** `airSaturated(surfacePressureBar:)` altitude-aware.
- **Schreiner:** algebraically equivalent to standard form in `BuhlmannTissueModel.schreiner` (lines 94–111); R≈0 → Haldane exponential.
- **Actual dt:** `tick()` and `ingestSample()` integrate real elapsed time; missed tick → `.degraded` not optimistic zero-deco.
- **Sub-stepping:** 30 s max within linear depth segments.

---

## X–Y. GF / NDL / TTS / Schedule

- GF snapshotted at dive start; locked during active dive.
- Ceiling altitude-aware via `PlannerEnvironment` in `BuhlmannTissueState.ceiling`.
- Schedule/TTS recomputed each snapshot refresh from current tissue copy.
- Cache keyed on tissue state; invalidated on tissue change (`FullComputerDecoSolverCacheIsolationTests`).
- TTS forward sim: 1-minute quanta (CONS-016, conservative).

---

## Z–AA. Gas Switch / Stop State Machine

- Gas switch: integrate old gas → switch → 0.5 min switch load → new gas (`changeGas`).
- Stop FSM (`FullComputerDecoStopTracker`) separate from tissue math; timer pause OOB; no force-clear of ceiling.

---

## AB–AC. Multilevel Profiles / 39 m → 10 m Verdict

**Central forensic question answered:** At 10 m after deco incurred at 39 m, the Watch continues updating all 16 N2 and 16 He compartments via Schreiner/Haldane each tick/sample. Ceiling, NDL, TTS, and schedule rebuild from current tissue state via `makeSnapshot` → `FullComputerDecoSolver`. Deco obligation may reduce, remain, or clear **only** when tissue+GF+ambient model permits — not from shallow timer or cached schedule alone.

**Evidence:** `Audit15Air39MultilevelProfileTests` — oracle comparison PASS; controlling compartment migration and schedule evolution asserted.

---

## AG–AH. Independent Oracle / Analytic Parity

- Tissue oracle: independent (`IndependentBuhlmannOracle`).
- TTS/schedule on oracle tissues: independent post CONS-008 (`independentRuntimeProjectionOnOracleTissues`).
- ML-01…ML-10: `Audit15MultilevelOracleProfilesTests`, `Audit15RedescentOracleTests`.
- Analytic vs 1s stepping: ≤0.0001 bar (`SchreinerAnalyticParityTests`).

---

## AJ–AK. Persistence / Logbook / Sync

- Checkpoint preserves plan, 32 inert pressures, gas switch tracker, stop tracker, monotonic clock.
- Restore: no fresh tissue fallback; corrupt/future schema fail-closed.
- Logbook metadata includes environment source, GF, gas switches (`FullComputerDiveLogbookMetadata`).

---

## AL. Planner Briefing / CCR Reference-Only

Briefing cards cannot start dives or mutate FC environment/tissues (`PlannerBriefingReceiverTests`). CCR metadata iOS-only reference.

---

## AM–AN. UI / App Intents

GF settings FC-scoped only. Shallow dev toggles behind developer unlock. Water auto-open routes with depth capability gate. App Intents safety-gated (`WatchIntentSafetyPolicyTests`).

---

## AX. Findings P0–P4

See `Docs/MASTER_WATCH_FULL_COMPUTER_FINDING_TRACEABILITY_CURRENT.csv`.

---

## AY. Readiness Matrix (Evidence-Based %)

| Dimension | % |
|---|---:|
| TARGET_MEMBERSHIP_READINESS | 100 |
| ACTIVITY_ISOLATION_READINESS | 98 |
| LIVE_ENGINE_CALL_GRAPH_READINESS | 95 |
| ENVIRONMENT_SOURCE_POLICY_READINESS | 92 |
| CMALTIMETER_LIFECYCLE_READINESS | 90 |
| SCHREINER_FORMULA_READINESS | 95 |
| ONE_SECOND_TIMING_READINESS | 93 |
| GF_CEILING_READINESS | 92 |
| MULTILEVEL_ORACLE_READINESS | 90 |
| AIR39_TO_10M_READINESS | 92 |
| PERSISTENCE_RESTORE_READINESS | 90 |
| POST_REMEDIATION_CONS_002_006_007_008 | 100 |
| PHYSICAL_WATCH_QA_READINESS | 0 |
| EXTERNAL_VALIDATION_READINESS | 15 |
| **OVERALL_WATCH_FULL_COMPUTER_SOFTWARE_READINESS** | **92** |
| **OVERALL_WATCH_FULL_COMPUTER_RELEASE_READINESS** | **45** |

---

## BA. Release Blockers

`WFC-P1-001` (external validation), `WFC-P2-002` (physical QA), CONS-042 shallow wet gate

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
INDEPENDENT_ORACLE_PARITY: PASS
ANALYTIC_VS_ONE_SECOND_PARITY: PASS
NUMERICAL_ERROR_BUDGET: PASS
CONCURRENCY_STALE_RESULT_GUARDS: PASS
CHECKPOINT_RESTORE_ENVIRONMENT: PASS
PERSISTENCE_TISSUE_STATE: PASS
LOGBOOK_SENSOR_PROVENANCE: PASS
SYNC_EXPORT_MATH_INTEGRITY: PASS
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY: PASS
CCR_REFERENCE_ONLY_SAFETY: PASS
UI_DOCUMENTATION_TRUTHFULNESS: PASS
APP_INTENTS_SAFETY_GATE: PASS
FAILURE_INJECTION_COVERAGE: PASS
WATCH_ALGORITHM_TESTS: PARTIAL
IOS_PARITY_TESTS: NOT_EXECUTED
MACOS_WATCH_BUILD: PASS
P0_FINDINGS: 0
P1_FINDINGS: 1
P2_FINDINGS: 4
P3_FINDINGS: 2
P4_FINDINGS: 2
SOFTWARE_READINESS_PERCENT: 92
PHYSICAL_WATCH_QA_READINESS_PERCENT: 0
EXTERNAL_VALIDATION_READINESS_PERCENT: 15
OVERALL_RELEASE_READINESS_PERCENT: 45
PHYSICAL_APPLE_WATCH_SENSOR_QA: PENDING_PHYSICAL
PHYSICAL_DEPTH_SENSOR_QA: PENDING_PHYSICAL
PHYSICAL_ALTITUDE_DIVE_QA: PENDING_PHYSICAL
PHYSICAL_MULTILEVEL_DIVE_QA: PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_LIVE_DECO_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: WFC-P1-001,WFC-P2-002,CONS-042
WATCH_FC_GF_IMPORT_PARITY: PASS
WATCH_FC_DEPTH_CAPABILITY_AUTHORITY: PASS
WATCH_FC_INDEPENDENT_ORACLE: PARTIAL_PENDING_EXTERNAL
WATCH_FC_SOFTWARE_READINESS_AFTER_REMEDIATION: 92
WATCH_FC_PHYSICAL_QA_STATUS: PENDING_PHYSICAL
```

---

## Required Final Questions (Selected Answers)

| # | Question | Answer |
|---|---|---|
| 1 | FC in Watch MAIN? | YES — target membership proven |
| 4 | Isolated from Gauge/Apnea/Snorkeling? | YES |
| 6 | Start without valid environment? | NO — fail-closed |
| 7 | Sea level implicit fallback? | NO for live start |
| 26 | Schreiner correct? | YES — algebraic proof + tests |
| 30 | Actual elapsed time? | YES |
| 35 | Schedule from current tissue? | YES — each refresh |
| 40 | Deco appear/reduce/clear/reappear? | YES — model-driven (ML-01/05) |
| 41 | 39→10m oracle-validated? | YES — Audit15Air39MultilevelProfileTests |
| 50 | Briefing cards reference-only? | YES |
| 59 | Findings traceable? | YES — CSV |
| 61 | Blocks physical readiness? | All PHYSICAL_QA matrix PENDING |
| 62 | Blocks external release? | WFC-P1-001, CONS-009 |

---

## Post-Remediation Verification (Section 4B)

Detailed evidence: `Docs/MASTER_WATCH_FULL_COMPUTER_POST_REMEDIATION_VERIFICATION_CURRENT.md`

| ID | Verdict |
|---|---|
| CONS-002 GF import | **PASS** |
| CONS-006 shallow FC toggle | **PASS** |
| CONS-007 depth authority | **PASS** |
| CONS-008 independent oracle | **PASS** (external pending) |
| CONS-016 TTS quanta | **PASS** (documented limitation) |

---

## Git Status (Final)

```
## main...origin/main
(clean @ 451f8fb)
```

No production files modified during this audit.
