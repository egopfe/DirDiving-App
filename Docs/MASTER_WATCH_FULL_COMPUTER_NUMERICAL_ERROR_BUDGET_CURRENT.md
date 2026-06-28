# Master Watch Full Computer — Numerical Error Budget — CURRENT

**Audit command:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.0.md`  
**Audit date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `7dfefe2`  
**Authority:** `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracleTolerances.swift`; prior `WATCH_MATH_NUMERICAL_ERROR_BUDGET_CURRENT.md`

---

## Tolerance table

| Source_of_Error | Bound | Measured_Worst_Case | Safety_Direction | Accepted | Evidence |
|---|---:|---:|---|---|---|
| Schreiner analytic vs 1 s stepped integration (bar) | ±0.0005 | <1e-12 on representative segments | Neutral | YES | SchreinerAnalyticParityTests compartments 1/4/8/12/16 |
| Production vs independent oracle tissue N2/He (bar) | ±0.0002 | 0 failures ML-01 ~1005 s replay | Neutral | YES | Audit15Air39MultilevelProfileTests |
| Raw ceiling vs oracle (m) | ±0.2 | Within bound at decimated ML-01 samples | Neutral | YES | IndependentBuhlmannOracle decimated checks |
| NDL binary search floor (min) | ±0.6 | Not oracle-swept independently | Conservative if high | PARTIAL | BuhlmannEngine NDL path |
| TTS forward simulation (min) | ±3.0 | Sweep PASS ML-01/ML-03 via production projection | Conservative (1-min steps) | YES with doc | Audit15TTSScheduleOracleSweepTests |
| GF interpolation at stop boundary (m) | ±0.2 | Display rounding 0.1 m | Neutral | YES | FullComputerDecoSolverTests |
| 30 s Schreiner sub-step vs 1 s oracle step (bar) | ±0.0002 | Production mirrors oracle sub-stepping | Neutral | YES | IndependentBuhlmannOracle maxSubStepSeconds=30 |
| Long suspension integrate (121–1800 s) | Full elapsed integrated | Tissues load; degraded flag set | No under-exposure cap | YES | FullComputerTimingFaultTests |
| Float/Double serialization in checkpoint | Bit-equal restore | 0 restore failures Audit15/Recovery | Neutral | YES | FullComputerRecoveryCheckpointTests; Audit15RedescentOracleTests |
| NaN/Inf depth ingest | Reject sample | unavailable/degraded | Fail-closed | YES | FullComputerReleaseHardValidationTests |
| Altitude surface pressure ISA formula | ±0.02 bar vs PlannerEnvironment | Orchestrated import tests | Neutral | YES | OrchestratedAltitudeEnvironmentTests |

---

## Schreiner analytic vs one-second parity (Section AH)

Segments tested: surface→39 m, 39→10 m, 10→3 m, 3→surface, constant 39 m 120 s, Haldane R=0 parity.

| Comparison | Max compartment error (bar) | Ceiling error (m) | Accepted |
|---|---:|---:|---|
| A analytic vs B 1 s stepped oracle | <0.0005 | N/A at tissue-only check | YES |
| B 1 s stepped vs D production engine | <0.0002 | <0.2 decimated | YES |
| Full segment once vs split 1 s updates | <0.0005 | <0.2 | YES |

Accumulated error after 30/60/120/240 min: ML-01 oracle reports **0 tissue failures** over full profile; ceiling decimated checks within 0.2 m.

---

## Adversarial inputs (static + tests)

| Input | Behavior | Fail-open? |
|---|---|---|
| dt ≤ 0 duplicate timestamp | No double integration | NO |
| Out-of-order timestamp | Rejected degraded | NO |
| dt > 120 s | Full integrate + degraded | NO (conservative fallback presentation) |
| Invalid GF | Blocked at predive validation | NO |
| Corrupt checkpoint SHA256 | Reject restore | NO |
| Missing environment at start | runtimePlan nil → unavailable snapshot | NO |

---

## Justification

Tolerances are **not** chosen to force pass: they derive from (1) identical ZH-L16C constants in oracle and production, (2) matched 30 s sub-step integration policy, (3) documented 1-minute TTS simulation quanta with conservative bias, (4) independent analytic Schreiner reference for segment limits. External tool comparison remains **PENDING_EXTERNAL_VALIDATION** (MWFC-P1-002).
