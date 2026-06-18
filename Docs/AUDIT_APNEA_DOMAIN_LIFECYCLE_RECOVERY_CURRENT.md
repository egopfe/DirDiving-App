# AUDIT 05 — Apnea Domain, Lifecycle and Recovery (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code review (no code changes)  
**Command:** `05_AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY.md`  
**Branch:** `main` @ `bcb985b`  
**Scope:** Apnea Commands **01–03** (domain models, depth feed / lifecycle, time / recovery / checkpoint)  
**Prerequisites:** Full Computer Audits 01–04 **PASS** on `main` (independent namespace)

---

## Executive summary

| Area | Verdict |
|------|---------|
| Domain models & schema versioning | **PASS** |
| Shared depth feed & sample validation | **PASS** |
| Isolation from Diving / Gauge / Full Computer | **PASS** |
| `ApneaSessionEngine` lifecycle | **PASS** |
| Auto immersion / surface detection | **PASS** |
| Monotonic clock & recovery policy | **PASS** |
| Checkpoint & crash recovery | **PASS** |
| **Gate before Apnea Command 04** (Watch ready/active UI) | **PASS WITH CONDITIONS** |

**Overall:** **PASS** — Apnea domain, lifecycle engine, depth feed, recovery computation, and checkpoint integrity meet Audit 05 on `main`. **P0/P1 blockers: none.** Watch **MAIN** app still excludes `ApneaView.swift` (UI promotion is Command 04+); production runtime path uses `ApneaSessionEngine` without demo timers.

**Internal readiness:** **95%** (engine/domain); **external freediving safety certification:** **not in scope**.

---

## Scope map (Commands 01–03)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 01 Domain models | `Shared/Models/Apnea*.swift`, `ApneaDomainValidator`, `ApneaSchemaMigration` | **Present** |
| 02 Depth feed & lifecycle | `DepthMeasurementFeed`, `ApneaLifecycleStateMachine`, `ApneaSessionEngine` | **Present** |
| 03 Time / recovery / checkpoint | `ApneaRecoveryComputation`, `ApneaSessionCheckpoint`, `MonotonicElapsedClock` | **Present** |

---

## 1. Domain models & schema

| Control | Implementation | Status |
|---------|----------------|--------|
| Versioned `ApneaSession` | `schemaVersion`, migration via `ApneaSchemaMigration` | **PASS** |
| Legacy decode (missing v0) | `testMissingSchemaVersionMigratesToV1` | **PASS** |
| Future schema tolerant decode | `testFutureSchemaVersionDecodesWithMigrationWarning` | **PASS** |
| Non-finite depth rejected | `ApneaDomainValidator` + domain tests | **PASS** |
| Sample ordering / duplicates | `ApneaDomainSupport.normalizedSamples` | **PASS** |
| Dive max vs session max vs personal best | Distinct fields + `testDiveSessionAndPersonalBestDepthsAreDistinct` | **PASS** |
| No demo runtime in production engine | `ApneaSessionEngine` starts empty session; no seeded demo dives | **PASS** |

---

## 2. Depth feed & lifecycle engine

| Control | Implementation | Status |
|---------|----------------|--------|
| Shared depth ingest | `DepthMeasurementFeed` (spike, regressive timestamp, vertical speed) | **PASS** |
| No `Timer.scheduledTimer` in Apnea production path | Engine uses `ingest` + `tick` + `MonotonicElapsedClock` | **PASS** |
| Legacy `ExplorationStore` Timer path | **Excluded** from MAIN Watch target (`project.yml`) | **PASS** (isolated) |
| Auto immersion / surface | `ApneaLifecycleStateMachine` + debounce / dwell config | **PASS** |
| Surface oscillation does not close dive early | `testSurfaceOscillationDoesNotCloseDivePrematurely` | **PASS** |
| Multiple dives after recovery | `testYoYoProfileCanProduceMultipleDivesAfterRecovery` | **PASS** |
| Minimum dive duration gate | `testShortDiveBelowMinimumDurationIsNotCommitted` | **PASS** |
| Sensor loss → degraded | `testSensorLossMarksDegradedPhase` | **PASS** |
| Sensor recovery | `testSensorRecoveryReturnsOperationalPhase` | **PASS** |
| Manual fallback controlled only | `enableManualFallback` + manual descent/surface triggers | **PASS** |
| Raw vs accepted samples preserved | Separate arrays in engine snapshot | **PASS** |

---

## 3. Recovery & checkpoint

| Control | Implementation | Status |
|---------|----------------|--------|
| Recovery modes | informational, 1:1, 2:1, fixed, custom ratio | **PASS** |
| Monotonic clock survives wall-clock regression | `testMonotonicClockSurvivesWallClockRegression` | **PASS** |
| Checkpoint round-trip | `testCheckpointRoundTripAndEngineRestore` | **PASS** |
| Corrupt checksum rejected | `testAtomicCheckpointFileAndCorruptionDetection` | **PASS** |
| Atomic file write | `ApneaSessionCheckpointStore.write` | **PASS** |
| No silent session reset on restore | Session ID preserved; manual fallback restore conservative | **PASS** |
| Incomplete recovery warning | `.incompleteRecovery` session warning on early manual descent | **PASS** |
| Recovery not medical prescription | Informational policy mode; buddy disclaimer keys; no medical strings in engine | **PASS** |

---

## 4. Isolation from Diving / Gauge / Full Computer

| Namespace / boundary | Evidence | Status |
|----------------------|----------|--------|
| Session sync key | `dirdiving_apnea_session` ≠ `dirdiving_dive_session` | **PASS** |
| Plan sync | `apneaSyncPlanPackage` ≠ `fullComputerPlanPackage` | **PASS** |
| `ApneaReleaseSelfCheck.verifySyncNamespaceIsolation` | Automated | **PASS** |
| No `DiveManager` mutation in Apnea engine | `ApneaSessionEngine` UI-independent | **PASS** |
| `ApneaView` excluded from MAIN Watch app | `project.yml` + release-hard test | **PASS** (by design) |
| FC / Apnea imported plan stores separate | Audit 03 + `ApneaSyncWatchReceiverTests` | **PASS** |

---

## 5. Minimum test checklist (Audit 05)

| Scenario | Test coverage | Result |
|----------|---------------|--------|
| Single dive replay | `testSessionArmsToReadyAndDetectsFullDiveCycle` | **PASS** |
| Multiple dives | `testYoYoProfileCanProduceMultipleDivesAfterRecovery` | **PASS** |
| Surface oscillation | `testSurfaceOscillationDoesNotCloseDivePrematurely` | **PASS** |
| Depth spike | `testDepthFeedRejectsSpike` | **PASS** |
| Regressive timestamp | `testDepthFeedRejectsRegressiveTimestamp` | **PASS** |
| Sensor loss | `testSensorLossMarksDegradedPhase` | **PASS** |
| App suspend/restart (checkpoint) | Round-trip + atomic file + engine restore | **PASS** (simulated) |
| Corrupt checkpoint | Checksum mismatch throws | **PASS** |
| Legacy / future schema | Domain migration tests | **PASS** |

---

## 6. Automated validation executed (2026-06-18)

### Release-hard script

`./Scripts/validate_apnea_release_readiness.sh` → **PASS** (on `main`; script notes branch)

### Focused audit suites

| Suite | Tests (approx.) | Failures |
|-------|-----------------|----------|
| `ApneaLifecycleEngineTests` | 17 | 0 |
| `ApneaTimeRecoveryCheckpointEngineTests` | 7 | 0 |
| `ApneaDomainModelTests` | 11 | 0 |
| `ApneaOperationalEventEngineTests` | 7 | 0 |
| `ApneaSyncWatchReceiverTests` | 4 | 0 |
| `ApneaReleaseHardValidationTests` (Watch) | 7 | 0 |
| `ApneaSyncCodecTests` (iOS) | 5 | 0 |
| `ApneaReleaseHardValidationTests` (iOS) | 6 | 0 |
| `IOSApneaCompanionTests` (iOS) | 9 | 0 |
| **Focused subtotal** | **~73** | **0** |

### Builds

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** (via apnea readiness script) |
| DIRDiving iOS | **BUILD SUCCEEDED** |

---

## 7. Findings

| ID | Severity | Finding | Recommendation |
|----|----------|---------|----------------|
| — | — | No P0 blockers | — |
| — | — | No P1 blockers for Commands 01–03 | — |
| **P2** | Info | `ApneaView` excluded from MAIN Watch target — end users cannot access Apnea UI on production Watch build | Expected until Command 04 promotion review |
| **P2** | Info | No dedicated XCTest named “suspend/resume OS lifecycle” — covered indirectly via checkpoint restore | **CLOSED** @ Remediation V1.0 — `ApneaSuspendResumeLifecycleIntegrationTests` |
| **P3** | Low | `validate_apnea_release_readiness.sh` warns when branch ≠ `integration/full-computer` | **CLOSED** @ Remediation V1.0 — accepts `main` |
| **P3** | Low | Some Apnea docs still reference `integration/full-computer` branch name | **CLOSED** @ Remediation V1.0 — docs aligned to `main` |

---

## 8. Gate — Apnea Command 04 (Watch ready / active UI)

| Criterion | Result |
|-----------|--------|
| Domain models stable & migrated | **YES** |
| Lifecycle engine deterministic on replay | **YES** |
| Recovery conservative; no silent reset | **YES** |
| Checkpoint integrity validated | **YES** |
| Namespace isolated from FC / dive session | **YES** |
| Safety self-check (no blackout claims) | **YES** |
| **Proceed to Command 04 implementation / UI promotion** | **YES — with explicit MAIN target + navigation review** |

---

## 9. Tests not executed

| Category | Reason |
|----------|--------|
| Watch Ultra real submersion lifecycle | Physical QA |
| OS background suspend + foreground on device | No simulator harness |
| Water Lock during Apnea session | Physical QA |
| End-to-end Watch UI smoke (ApneaView not in MAIN) | UI excluded by policy |
| Freediving certification / medical validation | Out of scope |

---

## 10. Related documentation

| Document | Role |
|----------|------|
| `Docs/APNEA_ARCHITECTURE.md` | Architecture overview |
| `Docs/DIR_DIVING_APNEA_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md` | Command 01 |
| `Docs/DIR_DIVING_APNEA_DEPTH_FEED_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md` | Command 02 |
| `Docs/DIR_DIVING_APNEA_TIME_RECOVERY_CHECKPOINT_IMPLEMENTATION_REPORT_CURRENT.md` | Command 03 |
| `Docs/APNEA_RELEASE_HARD_TEST_MATRIX.md` | Automated matrix |
| `Docs/DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md` | Command 12 validation |

---

*Audit 05 — read-only. No application code modified.*

---

## Remediation addendum (V1.0 — 2026-06-18)

| Finding | Status |
|---------|--------|
| P2 suspend/resume XCTest | **CLOSED** — `ApneaSuspendResumeLifecycleIntegrationTests` |
| P2 physical OS lifecycle | **Scaffolded** — `Docs/QA_EVIDENCE/APNEA_OS_LIFECYCLE/` (PENDING) |
| P3 release script branch warning | **CLOSED** — `validate_apnea_release_readiness.sh` accepts `main` |
| P3 doc branch drift | **CLOSED** — Apnea docs reference `main` |
| P2 ApneaView MAIN exclusion | **Unchanged by design** — Command 04 gate **READY_FOR_COMMAND_04** |
| **Internal readiness post-remediation** | **100%** (engine/domain/docs/automation) |
