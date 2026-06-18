# DIR DIVING — Snorkeling Session and Dip Lifecycle Engine

**Command:** `03_SNORKELING_SESSION_AND_DIP_LIFECYCLE_ENGINE.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** (lifecycle engine only; UI not activated)

---

## Scope

Deterministic `SnorkelingSessionEngine` separate from `ExplorationStore` — integrates Command 01 domain models and Command 02 depth/GPS feeds. No SwiftUI, no persistence wiring (Command 07).

---

## Architecture

| Layer | Location |
|-------|----------|
| Lifecycle phases | `SnorkelingLifecyclePhase` in `SnorkelingLifecycleStateMachine.swift` |
| Pure state machine | `SnorkelingLifecycleStateMachine` |
| Session engine | `SnorkelingSessionEngine.swift` |
| Suspend snapshot | `SnorkelingSessionCheckpoint` |
| Depth/GPS feeds | `SnorkelingDepthFeed`, `SnorkelingGPSFeed` |

Runtime phases (command): `idle`, `ready`, `surfaceActive`, `dipping`, `resurfacing`, `navigation`, `returnMode`, `paused`, `ended`, `sensorDegraded`, `recovered`.

Persisted `SnorkelingSessionState` is updated by the engine (`planned` → `active` / `navigation` / `returnMode` / `paused` / `completed`).

---

## Detection policy

| Feature | Behaviour |
|---------|-----------|
| Manual session start | `armSession()` → `startSession()` |
| Auto water detection | `startSession()` enters `dipping` when depth ≥ threshold |
| Dip start | Depth > `dipStartDepthMeters` + debounce, or manual fallback |
| Dip end | Surface dwell after `resurfacing` phase |
| Dip count | Auto on `dipEnded` events ≥ `minimumDipDurationSeconds` |
| Auto end out of water | Optional `autoEndOutOfWaterSeconds` on `surfaceActive` |
| Manual fallback | `enableManualFallback()` + `triggerManualDipStart/End()` |
| Sensor loss | `sensorDegraded` after timeout; `recovered` on feed resume |
| Navigation / return | `enterNavigation()`, `enterReturnMode()`, `exitNavigationOrReturn()` |

---

## Metrics (`SnorkelingSessionEngineSnapshot`)

- Session runtime, surface time, water/underwater time
- Dip count, active dip elapsed, last dip
- Session max/average depth, temperature
- Accumulated GPS distance, track quality, GPS/depth presentation states
- Sensor health (`available` / `degraded` / `manualFallback`)

---

## Tests

`Tests/WatchAlgorithmTests/SnorkelingLifecycleEngineTests.swift` — 15 tests:

- State machine debounce, surface dwell, manual dip end
- Short/long sessions, multiple dips, surface oscillation
- Sensor loss, manual fallback, suspend/resume checkpoint
- Water detection at start, navigation/return, pause/resume
- GPS concurrent track building, auto end out of water

Architecture isolation extended in `SnorkelingArchitectureIsolationTests`.

---

## Next commands

- `07_SNORKELING_PERSISTENCE_RECOVERY_AND_WATCH_LOGBOOK`
- Watch/iOS UI integration (later commands)

---

## Related docs

- [`DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_DOMAIN_MODELS_IMPLEMENTATION_REPORT_CURRENT.md)
- [`DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SENSOR_GPS_INGESTION_IMPLEMENTATION_REPORT_CURRENT.md)
- [`SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`](SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md)
- [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md)
- [`SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md`](SNORKELING_DOMAIN_INGESTION_LIFECYCLE_REMEDIATION_REPORT_V1.0.md)

---

## Remediation V1.0 (2026-06-18)

Depth-only/no-GPS lifecycle (`SnorkelingDepthOnlyLifecycleTests`), checkpoint foundation (7 tests), Command 04 gate hooks verified. In-memory checkpoint only — disk persistence deferred to Command 07 contract.
