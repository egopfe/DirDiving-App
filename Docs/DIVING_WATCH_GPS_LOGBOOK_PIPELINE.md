# Diving — Watch GPS → Logbook Pipeline

## Architecture

Diving uses **surface-only entry/exit GPS**, not a continuous track.

```
Watch GPSManager (When In Use)
    ↓ one-shot at dive start
DiveSession.entryGPS + entryGPSFixSource
    ↓ session + depth samples
DiveLogStore (Watch)
    ↓ WatchDiveSyncCodec (full DiveSession JSON)
iOS Dive logbook import
    ↓
DiveDetailView — Entry/Exit GPS status
```

## Capture policy

- **Entry:** best-effort ~6s surface fix when dive starts (pre-dive / surface)
- **Exit:** best-effort surface fix when dive ends / after resurfacing
- **Fallback:** last valid surface fix marked stale via `GPSFixSource.fallback`
- **No fix:** `entryGPSFixSource` / `exitGPSFixSource` = `.noFix`; coordinates nil
- **Never:** underwater continuous GPS, route track, fake coordinates

## Model fields

- `DiveSession.entryGPS` / `exitGPS` (`GPSPoint`)
- `DiveSession.entryGPSFixSource` / `exitGPSFixSource` (`GPSFixSource`)

## Runtime

- `DiveManager` + `GPSManager.captureBestEffortPoint`
- `DiveSessionMerge` preserves valid entry/exit GPS across merges

## Sync

- `WatchDiveSyncCodec` transports entire `DiveSession`
- Invalid coordinates stripped by validator; session remains valid

## Logbook policy

- Missing GPS does **not** invalidate a valid dive session
- Invalid coordinates sanitized/rejected, not stored as measured

## UI

- Watch + iOS dive detail: textual Entry/Exit GPS status
- Keys: `diving.logbook.gps.title`, `gps.entry`, `gps.exit`, `gps.status.*`

## Location privacy

- When In Use authorization only
- No Always Location, no generic background location

## Known limitations

- Poor sky view may yield no fix at start or end
- Stale fallback may be minutes old; UI marks as stale/not recent
- Physical Watch QA required for field validation
