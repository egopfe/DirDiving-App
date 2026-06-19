# iOS MAIN Algorithm Math — Remediation Report (Current)

## A. Executive Summary

Software-verifiable findings from audit baseline `ddb1a5f` (88% internal readiness) are remediated on `main`. Internal mathematical readiness is recalculated at **100%** for software gates. External Bühlmann/CCR validation, physical PDF render QA, and device QA remain **PENDING**.

## B. Source Baseline

- Branch: `main`
- Audited HEAD: `9b65ba8` / audit report `ddb1a5f`
- Internal readiness before: **88%**

## C. Current Baseline

- Remediation implements P1/P2/P3 software findings and expands deterministic test coverage for Apnea recovery, OC oxygen exposure unavailable state, repetitive dive, gas ledger, and Snorkeling distance consistency.
- Legacy `ExplorationStore` archived under `Legacy/Experimental/`.

## D. Findings Inventory

| ID | Status |
|----|--------|
| IOS-MATH-APNEA-P1-001 | VERIFIED |
| IOS-MATH-P2-004 | VERIFIED |
| IOS-MATH-P2-005 | VERIFIED |
| IOS-MATH-P3-004 | VERIFIED |
| IOS-MATH-P2-002 | PENDING_EXTERNAL_VALIDATION |
| IOS-MATH-P2-003 | PENDING_PHYSICAL_QA |
| IOS-MATH-P3-002 | PENDING_EXTERNAL_VALIDATION |

## E. Apnea Recovery Root Cause

`ApneaLifecycleStateMachine` completed `.recovery` using `configuration.recoveryMinimumSeconds` instead of `ApneaRecoveryComputation.requiredRecoverySeconds` from the active policy snapshot.

## F. Recovery Lifecycle Remediation

- `ApneaLifecycleTracker.recoveryRequiredSeconds` stores canonical duration at recovery start.
- `ApneaLifecycleMachineInput.requiredRecoverySeconds` and `allowEarlyDiveWhenIncomplete` drive completion and early immersion.
- `ApneaSessionEngine` passes policy-derived duration on every machine tick.

## G. Early-Dive Gating

- `canStartDiveDespiteRecovery` blocks manual descent when policy disallows early dive.
- `ApneaWatchPresentation` disables start with `apnea.ready.recovery_incomplete` when recovery is incomplete.

## H. Oxygen Exposure Result State

- `TechnicalGasAnalysis.cnsDescentBottomAvailable` distinguishes valid zero from unavailable.
- Preview path adds `.calculationIncomplete` when descent+bottom integration fails.
- Planner UI uses `cnsDescentBottomPercentDisplay`.

## I–L. Test Expansions

- `ApneaRecoveryPolicyLifecycleTests`
- `GasPlanningOxygenExposureUnavailableTests`
- `RepetitiveDiveMathematicalTests`
- Extended `GasLedgerDisplayFormatterTests`
- `SnorkelingDistanceConsistencyTests`
- `LegacyExplorationStoreIsolationTests`

## M. Full Test Matrix

Run: `./Scripts/validate_ios_main_algorithm_math_readiness.sh`

## N. Audit 15 Impact

**NOT_TOUCHED** — no changes to `Shared/BuhlmannCore` or Full Computer runtime.

## O. Audit 16 Impact

Minimal Planner/Apnea presentation changes for truthful unavailable/recovery states only.

## P. Software Readiness Recalculation

**100%** internal mathematical readiness (software gates).

## Q. External QA Still Pending

See `Docs/IOS_MAIN_ALGORITHM_MATH_EXTERNAL_QA_PENDING_CURRENT.md`.

## R. Changed Files

Production: Apnea lifecycle/engine/presentation, GasPlanningService, GasPlan, PlannerView, ApneaWatchRuntimeStore, ExplorationStore archive.

## S. Final Git Status

Recorded at commit time.

## T. Final Verdict

**SOFTWARE GATE PASS** — external/physical evidence remains pending by design.
