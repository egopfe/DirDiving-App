# DIR DIVING — Shared Depth Feed and Apnea Lifecycle Engine

**Command:** `02_SHARED_DEPTH_FEED_AND_APNEA_LIFECYCLE_ENGINE.md`  
**Date:** 2026-06-17  
**Branch:** `main`  
**Final result:** **PASS**

---

## Scope

Extract a reusable depth measurement feed and implement a UI-independent `ApneaSessionEngine` with a pure lifecycle state machine. **No SwiftUI**, **no DiveManager changes**, **no Diving lifecycle reuse**.

---

## Architecture

```text
DepthMeasurementRaw
  → DepthMeasurementFeed.ingest (shared)
  → DepthFeedIngestResult (raw + quality + optional accepted)
  → ApneaLifecycleStateMachine.evaluate (pure)
  → ApneaSessionEngine (orchestration, MonotonicElapsedClock, domain models)
  → ApneaSessionEngineSnapshot (semantic states for future UI)
```

| Component | Path |
|-----------|------|
| Shared depth feed | `Shared/Utils/DepthMeasurementFeed.swift` |
| Lifecycle config + phases | `Shared/Utils/ApneaLifecycleStateMachine.swift` |
| Session engine | `Shared/Utils/ApneaSessionEngine.swift` |
| Domain models (Command 01) | `Shared/Models/Apnea*.swift` |

---

## Lifecycle phases (runtime)

`idle` → `ready` → `surface` → `descending` → `submerged` → `ascending` → `surfaced` → `recovery` → `surface` (repeat) → `ended`

Sensor paths: `sensorDegraded` ↔ `recovered` (restores prior operational phase)

Distinct from persisted `ApneaSessionState` (`planned`, `active`, `completed`, …).

---

## Detection behaviour

| Feature | Implementation |
|---------|----------------|
| Immersion threshold | `ApneaLifecycleConfiguration.immersionStartDepthMeters` |
| Temporal debounce | `immersionCandidateSince` + `immersionDebounceSeconds` |
| Immersion/surface hysteresis | `immersionHysteresisMeters`, `surfaceHysteresisMeters` |
| Descent/ascent from vertical speed | Signed speed from feed; ascent when `speed <= -threshold` |
| Dive close after stable surface | `surfaceDwellSince` + `surfaceStableDwellSeconds` |
| Manual fallback | `enableManualFallback()` + `triggerManualDescent/Surface()` |
| Sensor loss | `sensorLossTimeoutSeconds` → `sensorDegraded` |
| Raw vs accepted samples | `rawSamples` (all qualities) + per-dive accepted samples |

---

## Depth feed

`DepthMeasurementFeed` validates:

- missing / non-finite / out-of-range depth
- regressive sensor timestamps
- spike rejection via max ascent/descent rate

Maps `DepthFeedQuality` → `ApneaDataQuality` for domain samples.

**Not wired into `DiveManager`** in this command — feed is shared infrastructure for future coordinator work.

---

## Files added

| File | Purpose |
|------|---------|
| `Shared/Utils/DepthMeasurementFeed.swift` | Reusable raw/accepted depth ingestion |
| `Shared/Utils/ApneaLifecycleStateMachine.swift` | Pure state machine + configuration |
| `Shared/Utils/ApneaSessionEngine.swift` | UI-independent session engine |
| `Tests/WatchAlgorithmTests/ApneaLifecycleEngineTests.swift` | 15 unit/replay tests |
| `Docs/DIR_DIVING_APNEA_DEPTH_FEED_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md` | This report |

---

## Tests (15/15 PASS)

| Area | Tests |
|------|-------|
| Depth feed | spike, regressive timestamp, vertical speed |
| State machine | surface dwell finish, manual surface from descending |
| Engine replay | full dive cycle, yo-yo, oscillation, short dive |
| Sensor | loss → degraded, recovery → surface |
| Manual fallback | controlled descent/surface |
| Data | raw vs accepted separation |
| Depth semantics | dive max vs session max vs personal best |

---

## Build results

| Target | Result |
|--------|--------|
| Watch Algorithm Tests (`ApneaLifecycleEngineTests`) | **PASS** |
| iOS Algorithm Tests (`ApneaLifecycleEngineTests` + `ApneaDomainModelTests`) | **PASS** |
| DIRDiving iOS | **BUILD SUCCEEDED** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |

---

## Not modified

- `DiveManager`, `DiveLifecycleAlgorithm`, Gauge/Full Computer runtime
- `ExplorationStore`, `ApneaView` (experimental, still excluded)
- SwiftUI views and Watch sensor provider ownership

---

## Rollback

Revert command commit and run `xcodegen generate`. No persistence keys written by this command.

**Final result: PASS**
