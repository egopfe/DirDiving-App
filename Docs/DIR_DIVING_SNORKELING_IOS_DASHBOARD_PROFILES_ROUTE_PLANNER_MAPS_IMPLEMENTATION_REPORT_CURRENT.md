# DIR Diving — Snorkeling iOS Dashboard, Profiles, Route Planner and Maps (Command 08)

**Date:** 2026-06-18  
**Command:** `08_IOS_SNORKELING_DASHBOARD_PROFILES_ROUTE_PLANNER_MAPS.md`  
**Gate:** `READY_FOR_SNORKELING_COMMAND_09`

## Summary

Command 08 replaces the experimental Explore Lab mock flows with a production iOS Snorkeling companion (Apnea companion pattern). Users can review persisted session metrics, manage reusable profiles, plan routes on MapKit, save plans locally, and send routes to Apple Watch with signed ACK — no fake sync success.

## Delivered

### iOS companion shell

- `DIRActivityMode.snorkeling.isLaunchableOnIOSCompanionMAIN = true`
- `IOSSnorkelingRootView` with Dashboard, Route Planner, and Profiles tabs
- `DIRDivingiOSApp` routes `.snorkeling` to `IOSSnorkelingRootView()`
- `CompanionActivityPreferenceStore` + `IOSCompanionPostLegalEntry` snorkeling landing flag

### Dashboard

- Last session card (date, duration, max depth, distance) from `IOSSnorkelingLogbookStore`
- Metric grid: total distance, max depth, sessions, water time, sessions this month, average max depth
- Compact MapKit track preview when GPS track exists
- Watch connectivity + route sync status (pending / up to date / failed — no mock success)
- Primary action **NUOVA SESSIONE** → route planner

### Profiles

- Seven presets + custom: recreational, photographic, reef, coastal, boat, children, fauna
- `IOSSnorkelingProfileStore` with copy-before-edit for presets
- Limits, alarms, Mission Mode flag — no readiness/fatigue mock scores

### Route planner + maps

- `IOSSnorkelingRoutePlannerView` with MapKit map, entry/exit/waypoint tap modes, polyline overlay
- Distance/duration estimates, max-distance limit with caution
- Validation issues surfaced before send/save
- Map permission denied / unavailable states
- **INVIA AL WATCH** via `IOSSnorkelingWatchTransferService` (ACK-gated)
- **SALVA PIANO** local persistence in `IOSSnorkelingRoutePlannerStore`

### iOS → Watch route sync

- `SnorkelingRouteSyncPackage`, `SnorkelingRouteSyncCodec`, `SnorkelingRouteSyncTransferSupport`
- `SnorkelingImportedRouteStore` + `SnorkelingRouteWatchReceiver` on Watch
- `WatchSyncService` (iOS + Watch) wired for package transfer and signed ACK
- `SnorkelingView` sets `isSnorkelingSessionInProgress` and activates pending imports after session

### Shared models

- `SnorkelingCompanionProfile`, `SnorkelingCompanionProfilePresets`
- `SnorkelingRoutePlannerDraft`, `SnorkelingRoutePlanValidator`

### Localization

- EN/IT keys under `snorkeling.ios.*` and `snorkeling.preset.*` in `iOSApp/Resources`

### Tests (Command 08 focused)

| Suite | Count | Result |
|-------|------:|--------|
| `IOSSnorkelingCompanionTests` | 5 | PASS |
| `IOSSnorkelingRoutePlannerTests` | 6 | PASS |
| `SnorkelingRouteSyncCodecTests` | 4 | PASS |
| `IOSCompanionActivitySelectionTests` (updated) | 11 | PASS |
| **Total focused** | **26** | **PASS** |

Build: **DIRDiving iOS** — BUILD SUCCEEDED (iPhone 17 Simulator).

## Explicitly excluded

- `ExplorationCenterView` / `ExplorationStore` remain excluded from production targets
- No heatmap, readiness score, offline map, or bathymetry claims
- No second snorkeling runtime engine on iOS — Watch `SnorkelingSessionEngine` remains authoritative

## Gate

`READY_FOR_SNORKELING_COMMAND_09` — iOS companion preparatory UI and route transfer are in place; next command can wire session logbook sync and Watch route consumption in active navigation.
