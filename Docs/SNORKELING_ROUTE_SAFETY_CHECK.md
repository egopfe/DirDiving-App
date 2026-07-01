# Snorkeling Route Safety Check

**Purpose:** Document iOS route validation semantics before Watch transfer or export.  
**Not claimed:** Life-saving navigation approval or automatic go/no-go for open water.

## Validation pipeline

1. `SnorkelingRoutePlanValidator` — structural issues (name, entry, exit, coordinates, point count, user max distance limit).
2. `SnorkelingRouteValidator` — aggregates issues + profile-aware warnings into a `SnorkelingRouteValidationResult`.

## Status values

| Status | Meaning | Watch transfer |
|--------|---------|----------------|
| `ready` | Minimum geometry and naming satisfied; no blocking issues | Allowed |
| `warning` | Route usable but exceeds profile recommendations or spacing heuristics | Allowed |
| `incomplete` | Missing entry, exit (different-exit mode), or insufficient points | Blocked |
| `blocked` | Invalid or duplicate coordinates | Blocked |

`allowsWatchTransfer` is true only for `ready` or `warning`.

## Structural issues

| Issue | Trigger |
|-------|---------|
| `emptyName` | Trimmed route name empty |
| `missingEntry` | No entry point |
| `missingExit` | Different-exit mode without exit point |
| `insufficientPoints` | Fewer than 2 routing points or too many waypoints |
| `invalidCoordinate` | Latitude/longitude out of range or non-finite |
| `exceedsMaxDistance` | User-defined max distance limit exceeded |
| `duplicatePoint` | Reserved for duplicate detection (blocking when present) |

## Profile warnings

Computed when route geometry is otherwise valid:

| Warning | Trigger |
|---------|---------|
| `exceedsProfileDistance` | Route distance > profile or kind recommended max |
| `exceedsProfileDuration` | Estimated duration > profile or kind recommended max |
| `exitFarFromEntry` | Different exit separated far from entry (> max(100 m, 75% profile distance)) |
| `waypointSpacingLarge` | Adjacent waypoints > 250 m apart |

Warnings do not block transfer but must be visible in UI and export text.

## Round trip vs different exit

- **Round trip:** entry required; exit auto-derived as return leg to entry when not explicitly set.
- **Different exit:** entry and exit both required.

## UI section order (recommended)

1. Map  
2. Route points  
3. Route name + profile  
4. Route type, profile kind, return alert, checklist, return-to-entry preview, estimates  
5. **Route safety check** (immediately before Watch transfer)  
6. Watch transfer status  
7. Export / share  
8. Send to Watch / Save plan  

Safety check must appear **after** name and profile inputs so incomplete-state messaging reflects fields the user can still edit above the send action.

## Safety copy

All export and planner surfaces must include non-certified orientation language (`snorkeling.route.gps_orientation_aid`).

## Tests

- `SnorkelingRouteValidatorTests`
- `SnorkelingRouteProfileTests`
- `IOSSnorkelingRoutePlannerTests`

## Physical QA

- `Docs/QA_EVIDENCE/SNORKELING_IOS_ROUTE_SAFETY_CHECK/`
- `Docs/QA_EVIDENCE/SNORKELING_IOS_SEND_TO_WATCH_VALIDATION/`
