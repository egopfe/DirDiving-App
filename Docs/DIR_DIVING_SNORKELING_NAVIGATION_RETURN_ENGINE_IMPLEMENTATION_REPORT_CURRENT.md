# DIR DIVING — Snorkeling Navigation and Return Engine

**Command:** `04_SNORKELING_NAVIGATION_AND_RETURN_ENGINE.md`  
**Date:** 2026-06-18  
**Branch:** `main`  
**Final result:** **PASS** (engine only; Watch MAIN UI not promoted)

---

## Scope

UI-independent surface navigation and return-to-entry advisor for Snorkeling, built on Commands 01–03 foundations. No `SnorkelingView` promotion, no `ExplorationStore`, no foreign runtime coupling.

---

## Architecture

| Layer | Location |
|-------|----------|
| Geodesy helpers | `SnorkelingDomainSupport` (`bearingDegrees`, `signedAngularDeltaDegrees`, `orderedWaypoints`) |
| Models / snapshots | `SnorkelingNavigationModels.swift` |
| Waypoint navigation | `SnorkelingNavigationEngine.swift` |
| Return advisor | `SnorkelingReturnAdvisor.swift` |
| Session integration | `SnorkelingSessionEngine` (`waypointNavigation`, `returnNavigation` snapshots) |
| Checkpoint | `SnorkelingSessionCheckpoint.navigationRuntimeState` |

---

## Navigation features

- Ordered waypoints (`routeOrder`, deterministic sort)
- Geodetic bearing and distance from accepted surface position
- Heading input with stale-age policy
- Signed angular delta → `turnLeft` / `turnRight` / `onLine` / `unavailable`
- Auto-advance to next waypoint (configurable)
- Skip waypoint and manual waypoint selection
- Waypoint reached only on measured surface GPS within radius
- Degraded/stale/underwater GPS disables precise turn guidance

---

## Return features

- Entry point capture from first measured surface fix (or override)
- Optional alternate safe target
- Distance/bearing to entry
- Return advisor reasons: distance, duration, battery, manual activation
- Informational message keys only (reference-only, non-prescriptive)
- Degraded GPS/heading states exposed explicitly

---

## Session engine API

- `setRoutePlans(_:activePlanID:)`, `setActiveRoutePlan(id:)`
- `selectWaypoint(id:)`, `skipWaypoint(id:)`
- `overrideEntryPoint(_:)`, `setAlternateReturnTarget(_:)`
- `updateHeading(degrees:ageSeconds:)`, `updateBatteryFraction(_:)`
- Existing lifecycle: `enterNavigation`, `enterReturnMode`, `exitNavigationOrReturn`

---

## Tests

`SnorkelingNavigationReturnEngineTests` (18 tests):

- Dateline bearing, wrap, normalize degrees
- No-fix / stale heading / underwater policies
- Route reorder, auto-switch, skip/manual selection
- Return thresholds (distance, duration, battery)
- Session engine integration + checkpoint round trip

All Snorkeling focused suites: **103 tests PASS** (iOS Algorithm Tests).

---

## Explicit non-goals (this command)

- Watch MAIN UI / `SnorkelingView` promotion
- Disk persistence beyond checkpoint field (Command 07)
- Physical Watch GPS QA

---

## Related docs

- [`SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md`](SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md)
- [`DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md`](DIR_DIVING_SNORKELING_SESSION_LIFECYCLE_IMPLEMENTATION_REPORT_CURRENT.md)
