# Watch Full Computer — Numerical Error Budget — CURRENT

**Baseline:** `main` @ `451f8fb`  
**Audit date:** 2026-06-30  
**Authority:** `FullComputerReleaseHardTolerances.swift`, `IndependentBuhlmannOracleTolerances.swift`, Audit-15 test suites

---

## Acceptance Tolerances (Documented)

| Domain | Bound | Measured Worst Case | Safety Direction | Accepted | Evidence |
|---|---:|---:|---|---|---|
| Tissue pressure (N2/He bar) | 0.0001 | < 1e-5 in ML profiles | Either | YES | Audit15MultilevelOracleProfilesTests |
| Ceiling depth (m) | 0.5 | < 0.3 typical | Over-estimate safer | YES | SchreinerAnalyticParityTests |
| NDL (min) | 1.0 | ≤ 1 in oracle sweep | Under-estimate safer for NDL display | YES | IndependentBuhlmannOracle |
| TTS (min) | 3.0 | ≤ 3 in oracle sweep | Over-estimate safer | YES | Audit15TTSScheduleOracleSweepTests; FullComputerReleaseHardTolerances |
| Planner vs runtime TTS | 4.0 | NOT_MEASURED (test crash) | Over-estimate safer | PARTIAL | testPlannerRuntimeTTSWithinTolerance crashed |
| Schreiner analytic vs 1s stepping | 0.0001 bar | < 1e-6 compartments 1/4/8/12/16 | Bounded | YES | SchreinerAnalyticParityTests |
| Zero-rate Schreiner vs Haldane | 1e-10 | Exact match at R≈0 | N/A | YES | BuhlmannTissueModel.schreiner L104-106 |
| GF interpolation | [20,85] ordered low<high | Validated at plan start | Fail-closed invalid | YES | FullComputerRuntimePlan.validate |
| Sub-step integration (30s max) | 30s steps | Full interval integrated | No time loss | YES | FullComputerRuntimeEngine.advanceTissuesLinear |
| Serialization tissue precision | Double Codable | Full double preserved | N/A | YES | FullComputerRecoveryCheckpointTests |
| Presentation ceiling rounding | 0.1 m display | Exact kept internal | Rounding up safer | YES | FullComputerDecoSolver.presentationCeilingMeters |

---

## Error Sources

| Source_of_Error | Bound | Safety_Direction | Mitigation |
|---|---|---|---|
| Float vs Double | Production uses Double | N/A | BuhlmannConstants Double arrays |
| exp underflow near saturation | Clamped finite guards | Stable | schreiner guard k>0 finite |
| 1-min TTS forward quanta | +0–1 min TTS | Conservative | CONS-016 documented |
| 30s Schreiner sub-steps within linear segment | Sub-split of analytic segment | Bounded by segment splitting tests | maxSubStepSeconds=30 |
| Missed tick actual-dt integration | Full elapsed integrated | No under-exposure | tick() uses real delta |
| Display rounding vs canonical | 0.1 m ceiling display | Exact used for violations | ceilingViolation uses exact |
| Cache stale presentation on budget exceed | Prior presentation returned | Conservative | timingDegraded flag blocks optimistic |
| Altitude surface pressure ISA formula | ISA barometric | Standard model | AmbientPressureModel + oracle cross-check |

---

## Adversarial Inputs (Static Review)

| Input | Expected Behavior | Evidence |
|---|---|---|
| NaN/Inf depth | markUnavailable non_finite_depth | FullComputerRuntimeEngine.ingestSample |
| Negative depth | Rejected | ingestSample depth>=0 |
| dt <= 0 | No-op tick | tick guard delta>0 |
| dt > maxMissedTickSeconds (120s) | degraded state; tissues still integrated | FullComputerTimingFaultTests |
| Out-of-order timestamp | degraded non_monotonic_timestamp | ingestSample |
| Invalid GF | canStart fails invalid_gradient_factors | FullComputerRuntimePlan.validate |
| Corrupt checkpoint | throws on restore | FullComputerRecoveryCheckpointTests |
| Invalid gas switch | markDegraded invalid_gas_switch | changeGas |

---

## Gaps

- **External reference comparison:** PENDING_EXTERNAL_VALIDATION — no measured worst-case vs Subsurface/RatioDeco.
- **Physical sensor noise:** PENDING_PHYSICAL — simulator depth is idealized.
- **Long-run drift (>4h deco):** Bounded by maxScheduleMinutes=720 in constants; not oracle-swept beyond test profiles.
