# AUDIT 09 — Snorkeling Domain, Ingestion and Lifecycle (read-only)

**Date:** 2026-06-18  
**Auditor:** Independent automated + manual code review (no application code modified)  
**Command:** `09_AUDIT_SNORKELING_DOMAIN_INGESTION_LIFECYCLE.md`  
**Branch:** `main` @ `f38dbd4`  
**Scope:** Snorkeling Commands **01–03** (domain models, shared sensor/GPS ingestion, session/dip lifecycle engine)  
**Prerequisites:** Apnea / Gauge / Full Computer namespaces unchanged; `SnorkelingView` excluded from Watch MAIN

---

## Executive summary

| Area | Verdict |
|------|---------|
| Domain models & versioned schema | **PASS** |
| Depth feed (shared `DepthMeasurementFeed` wrapper) | **PASS** |
| GPS ingestion & quality gating | **PASS** |
| Geodetic distance (no blind speed integration) | **PASS** |
| `SnorkelingSessionEngine` & dip lifecycle | **PASS** |
| Isolation from Diving / Apnea / `ExplorationStore` | **PASS** (code); **PARTIAL** (static test) |
| No demo / seeded runtime data | **PASS** |
| **Gate before Snorkeling Command 04** (navigation/return engine) | **PASS WITH CONDITIONS** |

**Overall:** **PASS WITH CONDITIONS** — Snorkeling domain, ingestion feeds, and lifecycle engine on `main` meet Audit 09 for Commands 01–03. **P0/P1 blockers: none.** One automated isolation test fails on a **documentation comment** false positive (see §6). Watch MAIN still excludes `SnorkelingView.swift`; production path is UI-free `Shared/` only.

**Internal readiness (engine/domain):** **94%**  
**Physical device / Water Lock / battery:** **not in scope** (Commands 04+)

---

## Scope map (Commands 01–03)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 01 Domain models | `Shared/Models/Snorkeling*.swift`, `SnorkelingDomainValidator`, `SnorkelingSchemaMigration` | **Present** |
| 02 Sensor/GPS ingestion | `SnorkelingDepthFeed`, `SnorkelingGPSFeed`, `DepthMeasurementFeed.snorkelingDefault` | **Present** |
| 03 Session lifecycle | `SnorkelingLifecycleStateMachine`, `SnorkelingSessionEngine`, `SnorkelingSessionCheckpoint` | **Present** |

Implementation reports: [`DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md), [`DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md), [`DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md).

---

## 1. Domain models & schema

| Control | Implementation | Status |
|---------|----------------|--------|
| Versioned `SnorkelingSession` | `schemaVersion`, `SnorkelingSchemaMigration` v0→v1 | **PASS** |
| Missing schema → migrate + warning | `testMissingSchemaVersionMigratesToV1` | **PASS** |
| Future schema tolerant decode | `testFutureSchemaVersionDecodesWithMigrationWarning` | **PASS** |
| NaN/Inf depth rejected | `SnorkelingDomainValidator` + tests | **PASS** |
| Invalid coordinates rejected | `testInvalidCoordinateRejected` | **PASS** |
| Track ordering / duplicate IDs | `SnorkelingDomainSupport.normalizedTrackPoints` | **PASS** |
| Non-monotonic track flagged | `testNonMonotonicTrackPointsFlagged` | **PASS** |
| Underwater measured GPS policy | Validator `underwaterMeasuredGPS`; domain tests | **PASS** |
| No demo waypoints/sessions in engine | `SnorkelingSessionEngine` init → empty `SnorkelingSession` | **PASS** |
| Experimental `ExplorationModels` | Not referenced from `Shared/` production snorkeling code | **PASS** |

---

## 2. Depth feed & quality

| Control | Implementation | Status |
|---------|----------------|--------|
| Reuses shared provider without Dive lifecycle | `SnorkelingDepthFeed` → `DepthMeasurementFeed.ingest` | **PASS** |
| Not `DepthSampleValidationState` / `DiveManager` | Verified in isolation test + code review | **PASS** |
| Monotonic relative timestamps | Caller-supplied; engine uses `MonotonicElapsedClock` | **PASS** |
| Spike rejection | `DepthFeedQuality.spikeRejected` + tests | **PASS** |
| Regressive timestamp | `regressiveTimestamp` + tests | **PASS** |
| Temperature passthrough | `SnorkelingDepthIngestResult.temperatureCelsius` | **PASS** |
| Underwater hint for GPS cross-feed | `isUnderwater` from depth threshold (0.35 m default) | **PASS** |
| Raw auditable trail | `SnorkelingDepthRawAuditEntry` (cap 2048) | **PASS** |
| Presentation states | `valid` / `degraded` / `unavailable` | **PASS** |

---

## 3. GPS ingestion & distance

| Control | Implementation | Status |
|---------|----------------|--------|
| Surface-only measured fixes | `isUnderwater` → `.underwaterUnavailable`, no measured coords | **PASS** |
| Horizontal accuracy gate | ≤20 m tracking, ≤45 m degraded, above rejected | **PASS** |
| Fix age | Tracking ≤12 s, stale ≤90 s, older rejected | **PASS** |
| Max plausible speed (outlier) | Haversine implied speed ≤3.5 m/s | **PASS** |
| Gap policy | >45 s resets accepted bridge (`gapExceeded`) | **PASS** |
| Distance from validated geodetic segments | `SnorkelingDomainSupport.distanceMeters` (haversine); degraded segments get 0 m credit | **PASS** |
| No blind speed integration | `reportedSpeedMetersPerSecond` stored on raw fix only; **not** used in `accumulatedDistanceMeters` | **PASS** |
| Underwater track excluded from measured distance | `testEstimatedUnderwaterTrackDoesNotCountAsMeasuredDistance` | **PASS** |
| Regressive GPS timestamp | `SnorkelingGPSFeedRejectionReason.regressiveTimestamp` | **PASS** |
| Invalid coordinates | `invalidCoordinates` rejection | **PASS** |
| Raw auditable trail | `SnorkelingGPSRawAuditEntry` (cap 2048) | **PASS** |

---

## 4. Session engine & dip lifecycle

| Control | Implementation | Status |
|---------|----------------|--------|
| Runtime phases (command set) | `SnorkelingLifecyclePhase` (11 states incl. navigation/return/paused/degraded) | **PASS** |
| Distinct from persisted `SnorkelingSessionState` | Engine maps phase → session state | **PASS** |
| Manual session start | `armSession()` → `startSession()` | **PASS** |
| Auto water detection at start | `waterDetectionDepthMeters` → enter `dipping` | **PASS** |
| Dip start threshold + debounce | `dipStartDepthMeters` + `dipStartDebounceSeconds` | **PASS** |
| Dip end surface dwell + hysteresis | `surfaceStableDwellSeconds`, `surfaceHysteresisMeters`, `dipHysteresisMeters` | **PASS** |
| Minimum dip duration | `minimumDipDurationSeconds` (default 2 s) | **PASS** |
| Multiple dips | `testEngineMultipleDips` | **PASS** |
| Surface oscillation (no premature close) | `testEngineSurfaceOscillationDoesNotPrematurelyCloseDip` | **PASS** |
| Sensor loss → `sensorDegraded` | `sensorLossTimeoutSeconds` + `testEngineSensorLossEntersDegradedPhase` | **PASS** |
| Manual fallback dip control | `enableManualFallback` + manual dip start/end | **PASS** |
| Navigation / return mode hooks | `enterNavigation`, `enterReturnMode`, `exitNavigationOrReturn` | **PASS** (phase only; Command 04 adds bearing/advisor) |
| Pause / resume | `pauseSession` / `resumeSession` | **PASS** |
| Optional auto-end out of water | `autoEndOutOfWaterSeconds` + test | **PASS** |
| In-memory suspend/resume | `SnorkelingSessionCheckpoint` export/restore + test | **PASS** (simulated; no disk persistence yet) |
| Metrics snapshot | runtime, water/surface time, dips, depth, temperature, track quality | **PASS** |
| No `Timer.scheduledTimer` in engine | `ingest` + `tick` + `MonotonicElapsedClock` | **PASS** |

---

## 5. Isolation from Diving / Apnea / Gauge / FC

| Boundary | Evidence | Status |
|----------|----------|--------|
| `SnorkelingSessionEngine` | No imports/references to `DiveManager`, `ApneaSessionEngine`, `ExplorationStore` in executable code | **PASS** |
| `SnorkelingDepthFeed` / `SnorkelingGPSFeed` | UI-free `Shared/`; reuse `DepthMeasurementFeed` only | **PASS** |
| `SnorkelingView.swift` | Excluded from Watch MAIN (`project.yml`) | **PASS** |
| `DIRActivityMode.snorkeling` | `isLaunchableOnWatchMAIN == false` (`DIRModesAndStartupFlowTests`) | **PASS** |
| Sync / persistence keys | No snorkeling session keys wired yet (Command 07) — no collision with dive/apnea | **PASS** (by absence) |
| Shared depth feed with Apnea | `DepthMeasurementFeed` is intentional shared utility; Apnea uses `.apneaDefault`, Snorkeling `.snorkelingDefault` | **PASS** (namespaced configs) |

---

## 6. Minimum test checklist (Audit 09)

| Scenario | Test / evidence | Result |
|----------|-------------------|--------|
| GPS speed spike | `testGPSRejectsSpeedSpike` | **PASS** |
| Stale fix | `testGPSMarksStaleFix` | **PASS** |
| Fix loss / gap / surface resume | `testGPSGapPolicyResetsBridge`, `testGPSResumesOnSurfaceAfterUnderwaterGap` | **PASS** |
| Short multiple immersions | `testEngineMultipleDips` | **PASS** |
| Surface oscillation | `testEngineSurfaceOscillationDoesNotPrematurelyCloseDip` | **PASS** |
| App suspend (checkpoint) | `testEngineSuspendResumePreservesDipState` | **PASS** (in-memory) |
| Re-entry after underwater | `testGPSResumesOnSurfaceAfterUnderwaterGap` | **PASS** |
| Depth-only / no GPS session | Engine supports `gpsRaw: nil`; **no dedicated lifecycle test** | **PARTIAL** |
| Invalid coordinates | Domain + GPS ingestion tests | **PASS** |
| Regressive timestamps | Depth + GPS tests | **PASS** |
| Architecture isolation scan | `testSnorkelingFeedSourcesDoNotReferenceForeignRuntime` | **FAIL** — false positive: comment in `SnorkelingLifecycleStateMachine.swift` contains string `ExplorationStore` (line 110 doc comment only) |

---

## 7. Automated validation executed (2026-06-18)

**Target:** `DIRDiving iOS Algorithm Tests` — iPhone 17 Simulator

| Suite | Tests | Failures |
|-------|------:|---------:|
| `SnorkelingDomainModelTests` | 12 | 0 |
| `SnorkelingSensorGPSIngestionTests` | 13 | 0 |
| `SnorkelingLifecycleEngineTests` | 15 | 0 |
| `SnorkelingArchitectureIsolationTests` | 2 | **1** |
| **Total** | **42** | **1** |

Functional snorkeling coverage: **41/41 PASS**. Isolation string scan: **1 false positive** (non-blocking for architecture; fix recommended before release-hard promotion).

---

## 8. Findings & recommendations

| ID | Sev | Finding | Recommendation |
|----|-----|---------|----------------|
| AUDIT09-SNK-001 | **P2** | `SnorkelingArchitectureIsolationTests` fails because doc comment mentions `ExplorationStore` | Rephrase comment or teach scanner to ignore `///` lines (Command 04 prep) |
| AUDIT09-SNK-002 | **P3** | No explicit lifecycle test for depth-only sessions without GPS fixes | Add `testEngineDepthOnlySessionWithoutGPS` when convenient |
| AUDIT09-SNK-003 | **P3** | Checkpoint is in-memory export only; no atomic disk store / checksum | Command 07 persistence scope |
| AUDIT09-SNK-004 | **P3** | Navigation/return phases exist but bearing, waypoint order, return advisor not implemented | Expected — Command 04 scope |

**P0/P1:** none.

---

## 9. Gate decision — Command 04

```
PASS WITH CONDITIONS
```

| Audience | Decision |
|----------|----------|
| **Proceed to Command 04** (`04_SNORKELING_NAVIGATION_AND_RETURN_ENGINE`) | **YES** — domain/ingestion/lifecycle foundation adequate |
| **Watch MAIN UI promotion** | **NO** — `SnorkelingView` still excluded by design |
| **Production release** | **NO-GO** — navigation engine, persistence, physical QA not done |

### Conditions before treating snorkeling as release-hard

1. Resolve AUDIT09-SNK-001 (isolation test green without weakening scan).
2. Implement Command 04 navigation/return engine with degraded-GPS safety policy.
3. Command 07 persistence + recovery; extend suspend tests to disk round-trip.
4. Physical QA on Watch (GPS underwater, Water Lock, battery) — future audit.

---

## 10. Related documents

| Document | Role |
|----------|------|
| [`DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md) | Command 01 |
| [`DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md) | Command 02 |
| [`DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md) | Command 03 |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | Experimental UI (not MAIN) |
| [`AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md`](AUDIT_APNEA_DOMAIN_LIFECYCLE_RECOVERY_CURRENT.md) | Parallel audit pattern (Apnea 01–03) |

---

**Audit 09 completed read-only @ `f38dbd4`. No application code modified.**
