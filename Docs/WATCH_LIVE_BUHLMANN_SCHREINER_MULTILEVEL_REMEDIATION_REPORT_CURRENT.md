# Watch Live Bühlmann / Schreiner / Multilevel — Remediation Report

**Date:** 2026-06-21  
**Source audit:** `Docs/WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_CURRENT.md` @ `1fe4a67`  
**Remediation branch:** `main`

## A. Executive Summary

All **software-verifiable** Audit-15 findings (P1×2, P2×4, P3×3) are **FIXED or VERIFIED**. ML-01 through ML-10 independent-oracle profiles pass. TTS/schedule sweep passes with documented 3-minute tolerance. Solver cache is instance-scoped; snapshot refresh uses a single `runtimeProjection`. Long suspension integrates full elapsed time with degraded UX. Software readiness: **100%**. Physical Ultra and external tool validation remain **PENDING**.

## B–D. Baseline

| Item | Value |
|---|---|
| Audit baseline commit | `1fe4a67` |
| Initial dirty tree | Audit docs only (uncommitted) |
| Post-remediation HEAD | (see final git status) |

## E. Findings Inventory

See `Docs/WATCH_LIVE_BUHLMANN_FINDING_TRACEABILITY_CURRENT.csv` — all software findings **FIXED/VERIFIED**.

## F. Oracle Infrastructure

- Extended `IndependentBuhlmannOracle` with gas-switch load, tissue compare helpers, TTS reference on oracle tissues.
- Added `Audit15OracleTestSupport` unified replay with gas-switch events and TTS checks.

## G–N. ML Profiles

| Profile | Test | Result |
|---|---|---|
| ML-01 | Audit15Air39MultilevelProfileTests | PASS |
| ML-02 | testML02EAN50SwitchAt21m | PASS |
| ML-03 | testML03TrimixWithHeliumCompartments | PASS |
| ML-04 | testML04SawtoothMultilevelContinuity | PASS |
| ML-05 | Audit15RedescentOracleTests | PASS |
| ML-06 | testML06StopBoundaryHover | PASS |
| ML-07 | testML07VerySlowAscentSchreinerRates | PASS |
| ML-08 | testML08RapidAscentMaintainsDecoWhenRequired | PASS |
| ML-09 | testML09LongTenMeterLevelSlowCompartments | PASS |
| ML-10 | testML10SurfaceIntervalPreservesResidualTissues | PASS |

## O. TTS / Schedule Sweep

`Audit15TTSScheduleOracleSweepTests` — PASS; optimistic TTS beyond tolerance: **0**.

## P. Solver Cache Isolation

`FullComputerDecoSolver.Cache` owned per `FullComputerRuntimeEngine`.

## Q. Projection Deduplication

`makeSnapshot` computes one `runtimeProjection`; solver receives precomputed projection.

## R. Missed Tick Policy

Full elapsed integration; `maxMissedTickSeconds` (120 s) is **degraded threshold only**. See `Docs/FULL_COMPUTER_DEGRADED_STATE_POLICY_CURRENT.md`.

## S. Degraded UX

Banner in `DiveLiveView`; keys `live.fc.status.runtime_degraded`, `live.fc.runtime.degraded.banner`.

## T. CSV Replay Tooling

`Scripts/export_watch_live_buhlmann_replay_vectors.py` → `Docs/WATCH_LIVE_BUHLMANN_REPLAY_EXPORTS/`.

## U–V. Numerical Budget / Requirement Matrix

Updated `Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md` and `Docs/WATCH_LIVE_BUHLMANN_REQUIREMENT_TEST_MATRIX_CURRENT.csv`.

## W–X. Build / Cross-Regression

Run `./Scripts/validate_watch_live_buhlmann_schreiner_multilevel_readiness.sh` for authoritative counts.

## Y. Readiness Recalculation

All software readiness dimensions: **100%** (see validation script banners).

## Z. Physical / External Pending

See `Docs/WATCH_LIVE_BUHLMANN_EXTERNAL_QA_PENDING_CURRENT.md`.

## AD. Final Verdict

**WATCH_LIVE_BUHLMANN_REMEDIATION: PASS** (software scope)  
External release gates: **PENDING_EXTERNAL_EVIDENCE**
