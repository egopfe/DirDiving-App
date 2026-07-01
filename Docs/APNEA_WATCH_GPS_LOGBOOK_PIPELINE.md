# Apnea — Watch GPS → Logbook Pipeline

## Architecture

Apnea uses **surface metadata only** — no runtime navigation, maps, waypoints, or route progress.

```
WatchSurfaceLocationService (When In Use)
    ↓ one-shot at arm/start + at save/end
ApneaSessionEngine.surfaceGPSPoints
    ↓ saveCompletedSession (+ gpsUnavailable warning if empty)
ApneaLogbookStore (Watch)
    ↓ ApneaSessionSyncCodec
IOSApneaLogbookStore
    ↓
IOSApneaSessionDetailView — Session location card
```

## Capture policy

- **Start:** surface fix appended when session armed/started (if permission + valid fix)
- **End:** final surface fix before logbook save; synchronous `lastKnownSurfaceFix` if async capture incomplete
- **No fix:** append `.gpsUnavailable` warning; empty `surfaceGPSPoints` is valid
- **Never:** route, bearing, waypoint, off-route, GPS as medical/safety logic, fake coordinates

## Model fields

- `ApneaSession.surfaceGPSPoints` (`[ApneaSurfaceGPSPoint]`)
- `ApneaSession.warnings` may include `.gpsUnavailable`

## Runtime

- `ApneaWatchRuntimeStore.attachSurfaceLocation(gps:)`
- `ApneaSessionEngine.appendSurfaceGPSPoint(_:)`

## Sync

- Full `ApneaSession` via `ApneaSessionSyncCodec`

## Logbook policy

- Empty surface GPS allowed with warning
- Session remains exportable when activity data valid

## UI

- iOS summary card: start/end GPS availability, point count
- Map tab may exist for historical view; **no runtime navigation UI added**
- Keys: `apnea.logbook.gps.title`, `apnea.logbook.gps.surface_points`

## Location privacy

- When In Use only; no continuous tracking except brief start/end capture

## Known limitations

- Indoor/pool sessions typically have no GPS
- Physical Watch QA required
