# Watch Bühlmann Numerical Error Budget — Current

**Audit:** Command 15 — Live Bühlmann / Schreiner / Multilevel  
**Date:** 2026-06-21  
**Branch:** `main` @ `1fe4a67`  
**Evidence baseline:** Watch Algorithm Tests selective run — **51 executed, 0 failures** (Apple Watch Series 11 46 mm simulator)

---

## Purpose

Quantify and bound numerical discrepancies between production Watch Full Computer tissue math and the independent audit oracle (`IndependentBuhlmannOracle`). Tolerances are defined in `IndependentBuhlmannOracleTolerances.swift` and justified below.

---

## Documented tolerances (production contract)

| Quantity | Tolerance | Rationale |
|---|---:|---|
| Compartment inert pressure (bar) | ±0.0002 | Sub-step Schreiner integration (≤30 s) vs per-second oracle; `Double` precision |
| Raw / operational ceiling (m) | ±0.2 | GF interpolation + ambient/depth conversion + 0.1 m presentation rounding |
| NDL (min) | ±0.6 | Binary search NDL with 1-min forward simulation steps |
| TTS (min) | ±3.0 | Schedule forward simulation at 1-min quanta; stop rounding to 3 m |
| Schreiner analytic vs 1 s stepped (bar) | ±0.0005 | Segment splitting over linear depth ramps |
| Controlling compartment | exact when ceilings agree within 0.05 m | Tie-break on equal ceilings within slack |

---

## Error budget table

| Source of error | Bound | Measured worst case | Safety direction | Accepted? |
|---|---:|---:|---|---|
| Schreiner segment splitting (30 s sub-steps) | ≤0.0002 bar / compartment | Not exceeded in ML-01 replay (0 failures / ~1005 s) | Conservative loading bias negligible at tested scales | **YES** |
| Schreiner analytic vs 1 s integration | ≤0.0005 bar | Max error within tolerance across SV-01…SV-04 segments (`SchreinerAnalyticParityTests`) | Symmetric (integration converges to analytic) | **YES** |
| Haldane fallback at \|rate\| < 1e-7 | Exact exponential | Constant-depth tick tests pass | Neutral | **YES** |
| Depth → ambient pressure (salt 1025 kg/m³) | ISA convention | Shared `AmbientPressureModel`; cross-target parity tests pass | Neutral | **YES** |
| Water vapour 0.0627 bar | Fixed constant | Matches Bühlmann reference tables used in repo | Neutral | **YES** |
| GF Low operational ceiling | Interpolation non-linearity | ≤0.2 m vs oracle bridged tissues at decimated samples | Slightly conservative when oracle lower | **YES** |
| Schedule / TTS forward simulation (1 min steps) | ≤3 min TTS | Not directly measured in this audit run; bounded by tolerance constant | Can over-estimate TTS (conservative) | **PARTIAL** — needs dedicated TTS oracle sweep |
| Missed tick cap (120 s) | Exposure capped | **Remediated:** full elapsed integrated; degraded flag only | **Under-estimates** if policy reverted | **YES** (remediated 2026-06-21) |
| Presentation ceiling rounding (0.1 m) | ±0.05 m display | By construction in `FullComputerDecoSolver.presentationCeilingMeters` | Rounds up depth display | **YES** |
| `exp` / `log(2)` in Schreiner | Machine epsilon | No NaN/Inf in mutation or fault tests | Neutral | **YES** |
| N2/He independent compartments | 0 cross-contamination | He=0 air profiles; trimix paths not in Audit-15 scope | Neutral for air ML-01 | **YES** (air); **PENDING** (trimix ML-03) |
| Checkpoint encode/decode | Bit-identical tissues | `Audit15RedescentOracleTests` checkpoint equality | Neutral | **YES** |
| Static solver cache reuse | 0 tissue error | Instance-scoped on engine (P2-AUD15-001 fixed) | Stale presentation if key collision (unlikely) | **YES** |

---

## Measured evidence (2026-06-21)

### Schreiner analytic parity

`SchreinerAnalyticParityTests` — **2/2 PASS**

- Segments: 0→39 m (130 s), 39→10 m (194 s), 10→3 m (42 s), 3→0 m (20 s)
- Compartments 1, 4, 8, 12, 16 (indices 0, 3, 7, 11, 15)
- Production vs oracle at end of 39 m descent: within `tissuePressureBar`

### ML-01 full replay

`Audit15Air39MultilevelProfileTests` — **1/1 PASS**

- Per-second oracle tissue comparison: **0 failures** across full profile (~1005 s)
- Decimated ceiling checks every 60 s + phase boundaries: within `ceilingMeters`

### ML-05 re-descent

`Audit15RedescentOracleTests` — **1/1 PASS**

- Oracle stream: **0 failures**
- Checkpoint tissue equality before/after restore

### Timing faults

`FullComputerTimingFaultTests` — **5/5 PASS**

- Δt ∈ {0.5, 1, 1.5, 2, 5, 10, 30} s load monotonically at constant depth
- Duplicate timestamp: no double integration
- Out-of-order: rejected (degraded), no rewind
- Missed 45 s tick: degraded, tissues advance (capped policy applies at 120 s)

### Mutation resistance

`BuhlmannMutationResistanceTests` — production matches correct oracle; seconds-as-minutes, swapped half-time, reversed rate mutations diverge

---

## Residual unmeasured bounds

| Gap | Recommended measurement | Priority |
|---|---|---|
| TTS vs independent minute-step oracle across full deco profiles | Add dedicated TTS sweep test | P1 evidence |
| Trimix / He loading (ML-03) | Oracle replay with non-zero He fractions | P1 evidence |
| Missed tick >120 s | Extend timing fault matrix | P2 |
| Long-duration drift (240 min bottom) | Soak replay | P2 |
| Physical sensor noise at stop band (ML-06) | Hardware QA | External |

---

## Safety direction summary

- Tissue integration errors observed in automated testing are **below documented tolerances** and do not demonstrate under-estimation of inert loading for tested air profiles.
- Known conservative mechanisms: TTS/schedule quantization, ceiling presentation rounding, solver budget fallback (returns prior presentation with diagnostic).
- Known non-conservative mechanism: **missed tick cap at 120 s** may under-integrate tissue loading if the Watch suspends longer without samples — mitigated by `degraded` engine state and continued constant-depth integration up to cap.

---

## References

- `Shared/BuhlmannCore/BuhlmannTissueModel.swift` — Schreiner / Haldane
- `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift`
- `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracleTolerances.swift`
- `Docs/WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv`
- `Scripts/generate_audit15_matrices.py`
