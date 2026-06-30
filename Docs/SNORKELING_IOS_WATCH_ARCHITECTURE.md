# Snorkeling iOS + Watch Architecture (P1/P2/P3)

**Branch:** `main`  
**Status:** Reference architecture — GPS orientation aid only. See [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md).

## Flow

```text
iOS Route Planner Draft
        ↓ validate (SnorkelingRouteValidator)
        ↓ build package (SnorkelingRoutePackageBuilder)
        ↓ WatchConnectivity transfer
Watch SnorkelingImportedRouteStore
        ↓ activate route + planning metadata
Watch SnorkelingWatchRuntimeStore / SnorkelingRouteRuntimeEvaluator
        ↓ session track + runtime evaluation
Watch SnorkelingLogbookStore
        ↓ session sync
iOS IOSSnorkelingLogbookStore + session detail / maps
```

## Layer map

| Layer | Key symbols | Location |
|-------|-------------|----------|
| Planner draft | `SnorkelingRoutePlannerDraft` | `Shared/Models/SnorkelingRoutePlannerDraft.swift` |
| Planning models | `SnorkelingRouteType`, `SnorkelingReturnAlertPolicy`, `SnorkelingRouteProfileKind` | `Shared/Models/SnorkelingRoutePlanningModels.swift` |
| Pure calculators | `SnorkelingDistanceCalculator`, `SnorkelingBearingCalculator`, `SnorkelingDurationEstimator` | `Shared/Utils/` |
| Validation | `SnorkelingRoutePlanValidator`, `SnorkelingRouteValidator` | `Shared/Utils/` |
| Route sync | `SnorkelingRouteSyncCodec`, `SnorkelingRouteSyncPackage` | `Shared/Utils/`, `Shared/Models/` |
| Watch import | `SnorkelingImportedRouteStore` | `Services/SnorkelingImportedRouteStore.swift` |
| Runtime evaluation | `SnorkelingRouteRuntimeEvaluator` | `Shared/Utils/SnorkelingRouteRuntimeEvaluator.swift` |
| GPS quality | `SnorkelingGPSQualityEvaluator` | `Shared/Utils/SnorkelingGPSQualityEvaluator.swift` |
| Progress / off-route | `SnorkelingRouteProgressCalculator`, `SnorkelingOffRouteDetector` | `Shared/Utils/` |
| Waypoints | `SnorkelingWaypointProgressTracker` | `Shared/Utils/SnorkelingWaypointProgressTracker.swift` |
| Return alert | `SnorkelingPlannedRouteReturnAlertEngine` | `Shared/Utils/SnorkelingPlannedRouteReturnAlertEngine.swift` |
| iOS UI | `IOSSnorkelingRoutePlannerView` | `iOSApp/Views/Snorkeling/` |
| Watch UI | `SnorkelingView`, `SnorkelingWatchPresentation` | `Views/`, `Utils/` |

## iOS vs Watch boundaries

**iOS owns:** editing entry/exit/waypoints, profile and checklist configuration, validation UX, export/share formatting, package creation, logbook import merge.

**Watch owns:** live GPS ingestion, quality band presentation, bearing/distance runtime, haptic alerts, off-route/progress during session, checkpoint and outbound session sync.

## Sync namespaces (isolation)

| Channel | Identifier |
|---------|------------|
| Route package | `snorkelingRoutePackage` |
| Route ACK | `snorkelingRoutePackageAck` |
| Session sync | `dirdiving_snorkeling_session_sync` |
| Checkpoint | `dirdiving_snorkeling_session` |

No collision with dive, apnea, Full Computer, or briefing sync keys (`SnorkelingCrossDomainIsolationTests`).

## GPS policy summary

- **When In Use** location only — no Always/background location for Snorkeling.
- Measured surface fixes only for distance/progress; underwater fixes excluded from track distance.
- GPS quality bands drive degraded UI and pause off-route warnings when unreliable.
- No simulated coordinates in production runtime paths.

## Limitations (explicit)

- Not a certified navigation or rescue system.
- Off-route distance uses local segment approximation — adequate for snorkeling orientation, not chart plotting.
- Physical QA required before external release claims.

## Related

- [`SNORKELING_ARCHITECTURE.md`](SNORKELING_ARCHITECTURE.md) — broader Snorkeling stack
- [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md)
- [`SNORKELING_WATCH_RETURN_TO_ENTRY.md`](SNORKELING_WATCH_RETURN_TO_ENTRY.md)
