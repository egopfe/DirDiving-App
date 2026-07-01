# Snorkeling — Watch GPS → Logbook Pipeline

## Architecture

Snorkeling uses a **surface GPS track** with quality classification; underwater samples are depth-only or marked unavailable.

```
WatchSurfaceLocationService / GPSManager (When In Use, low-frequency while active)
    ↓ ingest at session start + during session + at end
SnorkelingSessionEngine → trackPoints + entryPoint
    ↓
SnorkelingLogbookStore (Watch)
    ↓ SnorkelingSessionSyncCodec
IOSSnorkelingLogbookStore
    ↓
IOSSnorkelingSessionDetailView — GPS track card
```

## Capture policy

- **Entry:** one-shot surface fix at `startSession` → `entryPoint` + first track point if valid
- **During session:** periodic surface updates (prudent interval/distance); underwater → `isUnderwater = true`, no measured GPS without valid fix
- **Exit:** final surface fix appended at `endSession`
- **Quality:** `SnorkelingGPSQuality` measured / stale / unavailable
- **Never:** invented underwater coordinates, cross-save to Diving/Apnea

## Model fields

- `SnorkelingSession.entryPoint` (`SnorkelingTrackPoint?`)
- `SnorkelingSession.trackPoints` (`[SnorkelingTrackPoint]`)

## Statistics

- `SnorkelingDomainSupport.trackDistanceMeters` uses only valid measured/stale coordinates

## Sync

- Full `SnorkelingSession` via `SnorkelingSessionSyncCodec`
- Large tracks subject to existing payload caps

## Logbook policy

- Empty `trackPoints` may trigger incomplete GPS warning but session can remain valid/exportable

## UI

- iOS detail: track point counts (measured / stale / unavailable), distance
- Keys: `snorkeling.logbook.gps.title`, `gps.track_points`, etc.

## Location privacy

- When In Use only; updates started/stopped with active snorkeling session

## Known limitations

- Underwater segments have no measured GPS (by design)
- Physical Watch QA required for track accuracy and battery impact
