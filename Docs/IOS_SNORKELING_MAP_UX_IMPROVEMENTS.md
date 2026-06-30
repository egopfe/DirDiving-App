# iOS Snorkeling Map UX Improvements

**Status:** INTERNAL_READY · PHYSICAL_QA_PENDING  
**Scope:** iOS Snorkeling Route Planner only

## Features

### 1. Center on current location (Map section)

- Button top-right on map: `location.north.fill`
- Uses existing `IOSLocationPermissionService` (no new CLLocationManager)
- Pure policy: `SnorkelingRoutePlannerMapCenterPolicy`
- Does not create waypoints or modify route points
- Does not use fake coordinates

| GPS state | Behavior |
|-----------|----------|
| Authorized + coordinate | Centers map with 0.006° span, animated |
| Authorized + no fix | Requests one-shot location; shows unavailable notice |
| Not determined | Uses existing permission request flow |
| Denied / restricted | Shows permission-required message |

### 2. Reset map (Route points section)

- Button top-right: **Reset map** with confirmation alert
- Clears: entry, waypoints, exit (polyline derived from points clears automatically)
- Does **not** clear: profile, plan name, map type, settings, logbook

Model method: `SnorkelingRoutePlannerDraft.resetMapPoints()`  
Store method: `IOSSnorkelingRoutePlannerStore.resetMapPoints()`

### 3. Section reorder

Order in Route Planner:

1. Map  
2. Route points  
3. Profiles (plan name + profile picker)  
4. Estimates, validation, transfer, actions  

## QA

Templates under `Docs/QA_EVIDENCE/IOS_SNORKELING_MAP_*` — all **PENDING**.

## Non-goals

- No Watch runtime changes
- No Diving / Apnea / Full Computer changes
- No GPS permission flow changes
- No background / Always location
