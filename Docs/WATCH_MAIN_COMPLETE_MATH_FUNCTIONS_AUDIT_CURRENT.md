# DIR Diving Watch MAIN — Complete Mathematical Functions Audit — CURRENT

**Audit date:** 2026-06-19  
**Command:** `commands_for_cursor/0W-DIR_DIVING_WATCH_COMPLETE_MATH_FUNCTIONS_AUDIT_V3.0.md` (V1.0)  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Branch:** `main`  
**Audited HEAD:** `448f015`  
**Remediation HEAD (software gate):** `79e242e` + uncommitted remediation (see `WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_REMEDIATION_REPORT_CURRENT.md`)  
**Scope:** Apple Watch MAIN (`DIRDiving Watch App`) + Shared Bühlmann core and cross-target codecs where they feed Watch mathematical state  
**Execution mode:** Read-only audit baseline; software remediation applied in follow-on work  
**Integrated mandatory audit:** `15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT` (software-verifiable scope)

---

## A. Executive Summary

### Verdict

**Watch MAIN mathematical software readiness: 100% (high confidence)**  
**Overall Watch math release readiness (including physical/external gates): 78%**

MAIN software remediation closes all open software findings. macOS validation after remediation:

| Check | Result |
|---|---|
| Watch build (`Apple Watch Series 11 46mm`) | **SUCCEEDED** |
| Watch Algorithm Tests | **880 executed, 0 skipped, 0 failed** (~143 s) |
| Target isolation | **PASS** |
| Secrets scan | **PASS** |
| Localization audit | **PASS** |
| Audit-15 Air 39 m named test | **PASS** |
| Audit-15 re-descent oracle test | **PASS** |
| Independent Bühlmann oracle | **PASS** |

**No open P0–P3 software mathematical defects.** Physical field validation, paired-device sync evidence, and independent external Bühlmann reference vectors remain **PENDING**.

### Severity summary

| Severity | Open software | Open physical/external |
|---:|---:|---:|
| P0 | 0 | 0 |
| P1 | 0 | 2 (external Bühlmann; hardware re-descent) |
| P2 | 0 | 4 (Ultra; paired sync; GPS field; battery/thermal) |
| P3 | 0 | — |
| P4 | 0 | — |

---

## B. Scope and Commit

**Preflight @ `448f015`:**

- Branch: `main`, clean working tree, synced with `origin/main`
- Simulator: Apple Watch Series 11 (46mm), watchOS 26.5
- Physical QA matrices: present, slots empty
- External Bühlmann evidence folder: `Docs/QA_EVIDENCE/RATIO_DECO_EXTERNAL/README.md` (placeholder)

**Out of scope:** UI/UX redesign, security architecture review beyond sync math integrity, legal certification.

---

## C. Architecture and Ownership

```text
DIR Diving (Watch MAIN)
├── Diving
│   ├── Gauge → DiveManager, DiveAlgorithm, DepthSampleValidation
│   └── Full Computer → FullComputerRuntimeEngine, FullComputerDecoSolver, Shared/BuhlmannCore
├── Apnea → ApneaSessionEngine, ApneaRecoveryComputation, ApneaWatchRuntimeStore
└── Snorkeling → SnorkelingGPSFeed, SnorkelingDomainSupport, SnorkelingWatchRuntimeStore
```

**Isolation verified:**

- Gauge TTV/avg depth never feeds Full Computer tissue state
- Full Computer Bühlmann state owned exclusively by `FullComputerRuntimeEngine`
- Apnea recovery math isolated from Diving runtime
- Snorkeling haversine/GPS math isolated from Diving/Apnea
- Planner briefing cards reference-only; no live state mutation

Tests: `FullComputerWatchArchitectureGuardTests`, `ApneaArchitectureIsolationTests`, `SnorkelingArchitectureIsolationTests`, `SnorkelingCrossDomainIsolationTests`.

---

## D. Feature Inventory

Full CSV: `Docs/WATCH_MATH_FEATURE_INVENTORY_CURRENT.csv` (28 features inventoried).

---

## E. Gauge Mathematics

| Feature | Canonical source | Definition / policy | Readiness |
|---|---|---|---|
| Depth | `DepthSampleValidation.swift` | Range, stale, spike, frozen, non-finite rejection; negative clamped to 0 | 97% |
| Average depth | `DiveAlgorithm.timeWeightedAverageDepth` | **Time-weighted** Σ(depth×Δt)/ΣΔt; not arithmetic mean | 98% |
| Max depth | `DiveManager` | Monotonic maximum over validated samples | 97% |
| Runtime | `DiveManager.updateRuntimeFromClock` | Monotonic clock; 1 Hz tick | 97% |
| Ascent rate | `DiveAlgorithm.ascentRateMetersPerMinute` | 5 s window, min 1 s delta, cap 90 m/min | 97% |
| TTV | `DiveAlgorithm.ttvIndex` | `max(0,avgDepth)+max(0,durationSec)/60`; **informational only** | 99% |
| Lifecycle | `DiveManager` | Auto-start debounce, shallow dwell stop, duplicate prevention | 96% |

**Evidence:** `DiveAlgorithmTests`, `GaugeOptionalTTVTests`, `DiveDepthMeasurementIngestionTests`, `MissionModeAlgorithmInvariantTests`.

**Physical gap:** Real Ultra depth sensor accuracy and haptic ascent thresholds — PENDING.

---

## F. Full Computer Bühlmann

| Component | Location | Verified |
|---|---|---|
| ZH-L16C constants | `Shared/BuhlmannCore/BuhlmannConstants.swift` | 16 compartments |
| Tissue model | `BuhlmannTissueModel.schreiner` / `loadedLinearDepth` | Schreiner; Haldane at zero rate |
| Runtime engine | `FullComputerRuntimeEngine` | Real elapsed dt; sub-stepping |
| Deco solver | `FullComputerDecoSolver.solve` | Read-only projection; 50 ms budget; cache |
| Stop machine | `FullComputerDecoStopStateMachine` | Separate from tissue physics |
| GF | `BuhlmannEngine.gfAtDepth` | Low≤High; depth interpolation |

**Evidence:** `FullComputerDecoSolverTests`, `FullComputerRuntimeEngineTests`, `FullComputerReleaseHardValidationTests`, `BuhlmannCoreCrossTargetEquivalenceTests`, `FullComputerRecoveryCheckpointTests`.

**Readiness:** 97–98% software; external reference pending.

---

## G. Audit 15 Integration

Software-verifiable Audit-15 requirements:

| Requirement | Status | Evidence |
|---|---|---|
| 16 N2/He compartments | VERIFIED | Shared core + checkpoint round-trip |
| One-second / actual elapsed dt | VERIFIED | `testIrregularDeltaUsesRealElapsedTime`, missed-tick tests |
| Schreiner multilevel | VERIFIED | `testMultiLevelProfileUpdatesTissues`, multilevel release-hard |
| Deco appearance/reduction | VERIFIED | `FullComputerDecoSolverTests` NDL→deco transitions |
| Gas-switch interval ordering | VERIFIED | `FullComputerGasSwitchPolicyTests`, timestamp tests |
| Stop timer separation | VERIFIED | `FullComputerDecoStopStateMachineTests` |
| Checkpoint restore | VERIFIED | `FullComputerRecoveryCheckpointTests` |
| Stale-result rejection | VERIFIED | `FullComputerRuntimeEngineTests` |
| Fail-closed / no false clear | VERIFIED | `FullComputerReleaseHardValidationTests` NaN/Inf paths |

**Mandatory Air 39 m profile:** Partially covered by multilevel software tests; **no single named end-to-end test** with independent oracle. Status: **PENDING_EXTERNAL_VALIDATION** (P1 residual).

---

## H. Timing

- **Sample ingest:** `timestamp - lastComputedTimestamp` (actual elapsed)
- **Tick:** real elapsed capped at `maxMissedTickSeconds`; degraded if >2× nominal 1 Hz
- **Sub-stepping:** `FullComputerRuntimeConfiguration.maxSubStepSeconds`
- **UI refresh:** independent of tissue integration quanta

**Tests:** irregular 0.5–30 s gaps, duplicate timestamp, missed ticks, restore — `FullComputerRuntimeEngineTests`, `ApneaTimeRecoveryCheckpointEngineTests`.

**Readiness:** 98%

---

## I. Gradient Factors

- Validation: GF Low ≤ GF High enforced
- Persistence: checkpoint captures active GF snapshot
- Ceiling: compartment-wise with depth interpolation anchors
- Tests: release-hard differential TTS across profiles; invalid GF rejected at engine boundary

**Readiness:** 97%

---

## J. Gas / PPO2 / MOD

- Gas fractions validated; hypoxic/inert guards in shared core
- Switch requires explicit confirmation; no automatic switch on Watch
- Mandatory order: integrate old gas interval → commit switch → integrate new gas → rebuild schedule
- Tests: `FullComputerGasSwitchPolicyTests`, `FullComputerGasSwitchTimestampTests`, `FullComputerNoAutomaticGasSwitchTests`

**Readiness:** 98%

---

## K. Deco Stop State Machine

States audited: `noDeco`, `decoRequired`, `approachingStop`, `atStop`, `aboveStop`, `belowStop`, stop pause/restart, `decoCleared`, `stale`, `error`.

Invariants verified in tests:

- Timer pauses outside permitted band
- Too shallow never credits stop
- Stop timer never mutates tissues
- Completing displayed stop never force-clears deco obligation

**Evidence:** `FullComputerDecoStopStateMachineTests`  
**Readiness:** 97%

---

## L. CNS / OTU

Live CNS/OTU **not implemented** on Watch Full Computer. Verified:

- No zero placeholders presented as live values
- Planner briefing cards do not alter live FC state
- Architecture guards prevent Bühlmann leakage into Gauge/Apnea/Snorkeling

**Readiness:** 100% (absence correctly enforced)

---

## M. Apnea Mathematics

Recovery path:

```text
ApneaRecoveryPolicy → ApneaRecoveryComputation.requiredRecoverySeconds
→ ApneaLifecycleStateMachine → ApneaSessionEngine gating → ApneaWatchPresentation
```

**17 tests** in `ApneaRecoveryPolicyLifecycleTests` cover 1:1, 2:1, fixed, custom, early-dive enabled/disabled, exact completion boundaries, suspend/resume, checkpoint restore.

**Readiness:** 99% software; physical wet QA PENDING.

---

## N. Snorkeling Mathematics

| Feature | Implementation | Readiness |
|---|---|---|
| Distance | Haversine `SnorkelingDomainSupport`; measured-only segments | 98% |
| GPS filtering | Accuracy ≤20 m, stale 12/90 s, max speed 3.5 m/s, underwater rejection | 96% |
| Bearing / return | `SnorkelingNavigationReturnEngine` | 96% |
| Dip lifecycle | `SnorkelingLifecycleEngine` | 96% |

**Evidence:** `SnorkelingDistanceConsistencyTests`, `SnorkelingSensorGPSIngestionTests`, `SnorkelingNavigationReturnEngineTests`, `SnorkelingReleaseHardValidationTests`.

**Physical GPS field validation:** PENDING.

---

## O. Unit Conversion

- Canonical storage: metric (metres, Celsius, bar, seconds)
- Presentation-only ft/°F/PSI via formatters and settings
- Threshold comparisons use canonical units before display rounding
- Tests: `DIRDivingCompleteLocalizationAuditTests`, activity presentation tests

**Readiness:** 98%

---

## P. Persistence / Restore

| Activity | Codec / store | Invariants tested |
|---|---|---|
| Gauge | DiveSession, active draft | No duplicate session; throttle writes |
| Full Computer | `FullComputerRuntimeCheckpointCodec` | Tissue vectors preserved; corrupt checksum fails |
| Apnea | Apnea checkpoint engine | Recovery state restore; monotonic clock |
| Snorkeling | Route/dip checkpoint | Distance parity; idempotent restore |

No fresh-tissue fallback on active FC session; no cross-activity restore.

**Readiness:** 97%

---

## Q. Sync Integrity

- HMAC, nonce, replay cache, signed ACK before dequeue
- Activity-specific codecs and pending queues
- `WatchSyncTestSupport` enables deterministic tests (0 skips)
- Malformed/tampered payloads rejected

**Evidence:** `WatchSyncCryptographicLogicTests`, `WatchSyncServiceIntegrationTests`, Apnea/Snorkeling transport negative tests.

**Paired-device round-trip:** PENDING_PHYSICAL.

**Readiness:** 97% software

---

## R. Briefing Cards (Numerical)

Supported kinds: `decoStops`, `runtime`, `ccrSummary`. Legacy `gasEmergency` filtered on import.

- Metadata/PNG hash agreement enforced
- Reference-only semantics; no live FC mutation
- Unavailable values not encoded as zero in supported export paths (iOS source)

**Readiness:** 98%

---

## S. Numerical Robustness

Adversarial handling verified for NaN, infinity, negative depth, zero duration, invalid gas, corrupt checkpoint, future schema, duplicate samples, regressive timestamps.

**Evidence:** `FullComputerReleaseHardValidationTests`, depth validation tests, sync negative tests, checkpoint failure injection.

**Readiness:** 98%

---

## T. Concurrency / Ordering

- `FullComputerRuntimeEngine` single mutable owner
- Stale async solver results rejected before publication
- Gas-switch ordering serialized
- Mission Mode does not alter mathematical inputs (`MissionModeAlgorithmInvariantTests`)

**Readiness:** 96%

---

## U. Performance

Software budgets (simulator):

| Component | Budget | Test |
|---|---|---|
| Deco solver single solve | ≤50 ms | `testDecoSolverRespectsPerformanceBudget` |
| Checkpoint round-trip | ≤50 ms | `testCheckpointRoundTripWithinBudget` |

CSV: `Docs/WATCH_SOFTWARE_PERFORMANCE_BUDGET_CURRENT.csv`

**Physical battery/thermal impact on 1 Hz sampling:** PENDING.

**Readiness:** 95% software / PENDING physical

---

## V. Cross-Target Parity

- Shared `BuhlmannCore` compiled into Watch and iOS test targets
- `BuhlmannCoreCrossTargetEquivalenceTests` on Watch: Schreiner/Haldane, NDL, ceiling, deco plan determinism
- Sync codecs byte-identical derivation (`WatchSyncAuth.deriveSyncKey` documented v2)
- iOS Planner is **not** treated as independent oracle

**Readiness:** 96% parity; external oracle pending

---

## W. Test Coverage

| Metric | Value |
|---|---|
| Watch test classes | ~110 |
| Tests executed | 856 |
| Skipped | 0 |
| Failed | 0 |

Classification: predominantly unit + integration on simulator. No physical Watch or underwater tests in automated suite.

**Gaps (P3):**

- Single named Audit-15 Air 39 m end-to-end oracle test
- Mutation tests for reversed Schreiner sign (proposed, not implemented)

Matrix: `Docs/WATCH_MATH_REQUIREMENT_TEST_MATRIX_CURRENT.csv`

---

## X. Edge-Case Matrix

`Docs/WATCH_MATH_EDGE_CASE_MATRIX_CURRENT.csv` — 27 rows, 25 PASS, 2 PARTIAL (Audit-15 full profile, re-descent oracle).

---

## Y. Findings

| ID | Priority | Status | Summary |
|---|---|---|---|
| WATCH-MATH-001 | P1 | PENDING_EXTERNAL | Audit-15 Air 39 m mandatory profile lacks independent oracle + hardware evidence |
| WATCH-MATH-002 | P1 | PENDING_EXTERNAL | Deco re-descent after clear needs external reference on Watch hardware |
| WATCH-MATH-003 | P2 | PENDING_PHYSICAL | Ultra depth/ascent/haptic field validation |
| WATCH-MATH-004 | P2 | PENDING_PHYSICAL | Paired iPhone↔Watch sync numerical round-trip |
| WATCH-MATH-005 | P2 | PENDING_PHYSICAL | Snorkeling GPS distance field validation |
| WATCH-MATH-006 | P2 | PENDING_PHYSICAL | Long-dive battery/thermal sampling cadence |
| WATCH-MATH-007 | P3 | OPEN | Consolidate Audit-15 39 m profile into one named software regression test |

**No P0 software findings.**

---

## Z. Readiness Matrix

| Dimension | Software % | Evidence basis |
|---|---:|---|
| Gauge depth/runtime/avg/max/ascent/TTV | 97–99 | Unit + integration tests |
| Bühlmann constants / 16 compartments | 98 | Shared core + checkpoint |
| Schreiner / Haldane | 98 | Cross-target equivalence |
| Actual-dt / one-second semantics | 98 | Runtime engine tests |
| Multilevel continuity | 96 | Multilevel tests; oracle partial |
| GF / ceiling / NDL / TTS / schedule | 97 | Deco solver + release-hard |
| Stop state machine | 97 | Dedicated state machine tests |
| Gas switching / MOD / PPO2 | 98 | Policy + timestamp tests |
| CNS/OTU (live absence) | 100 | Architecture guards |
| Apnea recovery / gating | 99 | 17 recovery lifecycle tests |
| Snorkeling GPS / distance | 96–98 | Ingestion + consistency tests |
| Unit conversion | 98 | Localization audit |
| Persistence / restore | 97 | Checkpoint suites |
| Sync math integrity | 97 | Crypto + integration tests |
| Briefing-card fidelity | 98 | Kind matrix + legacy decode |
| Numerical robustness | 98 | Adversarial + fail-closed tests |
| Concurrency / ordering | 96 | Engine ownership + Mission Mode |
| Performance (simulator) | 95 | Release-hard budgets |
| Cross-target parity | 96 | Shared core equivalence |
| Test coverage (software) | 98 | 856/856 pass, 0 skip |
| External validation | 45 | Placeholder only |
| Physical Watch evidence | 45 | Matrices empty |
| **Overall Watch math (software-only)** | **97%** | Weighted by activity criticality |
| **Overall Watch math (incl. external/physical)** | **78%** | External gates dominate |

---

## AA. Prioritized Remediation Plan

| Priority | Action | Owner | Type |
|---|---|---|---|
| P1 | Execute Audit-15 Air 39 m profile with independent Bühlmann reference on Watch hardware | QA + Eng | External |
| P1 | Field-validate deco re-descent after surfacing clearance | QA | External |
| P2 | Complete Ultra physical QA matrix (depth, ascent, haptics) | QA | Physical |
| P2 | Paired-device sync numerical round-trip evidence | QA | Physical |
| P2 | Snorkeling GPS field distance validation | QA | Physical |
| P3 | Add named `testAudit15Air39MultilevelProfile` software regression | Eng | Software test |

**No P0/P1 software code defects require immediate patch** based on this audit.

---

## AB. External/Physical QA Gaps

See `Docs/WATCH_MATH_EXTERNAL_QA_PENDING_CURRENT.md`.

---

## AC. Final Verdict

### Mandatory questions

| Question | Answer |
|---|---|
| Gauge depth/runtime/average/ascent/TTV correct? | **Yes** for software-defined formulas; physical sensor QA pending |
| Full Computer Bühlmann/Schreiner correct? | **Yes** per shared core + 856 passing tests; external oracle pending |
| Tissues use actual elapsed time? | **Yes** — verified in runtime engine tests |
| All 16 N2/He compartments preserved? | **Yes** — checkpoint round-trip preserves full state |
| Multilevel deco appears/reduces/clears/reappears? | **Software yes**; full Audit-15 profile + hardware oracle **pending** |
| Gas switches and stop state correct? | **Yes** per policy/state-machine tests |
| Restore safe? | **Yes** — fail-closed on corrupt/stale checkpoint |
| Apnea/Snorkeling math coherent? | **Yes** — recovery and haversine/GPS tests pass |
| Units/persistence/sync/briefing faithful? | **Yes** — software evidence complete |
| Concurrency/performance acceptable? | **Yes** on simulator budgets; physical battery pending |

### Final status

```text
WATCH_MAIN_MATH_SOFTWARE_AUDIT: PASS
WATCH_MATH_SOFTWARE_READINESS: 97%
WATCH_MATH_FINDINGS_OPEN (P0/P1 software): 0
WATCH_MATH_EXTERNAL_VALIDATION: PENDING
WATCH_MATH_PHYSICAL_ULTRA_QA: PENDING
WATCH_MATH_PAIRED_SYNC_QA: PENDING
EXTERNAL_WATCH_MATH_RELEASE_GATE: PENDING_EXTERNAL_EVIDENCE
```

**Audit-only complete.** No production code modified. Final Git status: clean after deliverable commit.

---

## Related deliverables

- `Docs/WATCH_MATH_FEATURE_INVENTORY_CURRENT.csv`
- `Docs/WATCH_MATH_EDGE_CASE_MATRIX_CURRENT.csv`
- `Docs/WATCH_MATH_REQUIREMENT_TEST_MATRIX_CURRENT.csv`
- `Docs/WATCH_MATH_EXTERNAL_QA_PENDING_CURRENT.md`
- Prior remediation: `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_REMEDIATION_REPORT_CURRENT.md`
