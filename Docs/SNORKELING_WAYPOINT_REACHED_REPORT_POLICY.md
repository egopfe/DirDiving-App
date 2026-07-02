# Snorkeling Waypoint Reached Report Policy

**Scope:** iOS Snorkeling session logbook detail.

## Event source

- Primary: persisted `SnorkelingEvent` records with `kind == .waypointReached`.
- Engine appends events when `completedWaypointIDs` grows during navigation runtime updates.

## Conservative rules

- Never infer reached waypoints from track proximity alone in P3.
- If no events exist, report `reachedCount = 0` and `missedCount = planned waypoint count`.
- Do not mark waypoints reached without a matching event `relatedWaypointID`.

## Display

- Reached count, missed count (when planned route exists), reached waypoint names from events only.
