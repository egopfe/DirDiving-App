# DIR Diving — Full Computer Persistence, Logbook & Recovery (Command 10)

## Delivered

### Atomic checkpoint (draft v5)
- `FullComputerRuntimeCheckpoint` stores schema, session ID, diving mode, tissue state, GF/plan, gas switch + deco stop trackers, depth/ceiling/NDL/TTS snapshot fields, monotonic clock snapshot, timestamps, SHA-256 checksum.
- Persisted in `ActiveDiveDraft` (`schemaVersion` 5) on each active draft write for Full Computer dives.

### Recovery
- Restore prefers validated checkpoint over depth-only replay; never cold-starts tissues when checkpoint is valid.
- Corrupt/future schema/checksum failures quarantine checkpoint payload and fall back to legacy replay + gas tracker.
- Conservative catch-up advances tissues at last known depth (capped) before resuming samples.
- `isFullComputerRecoveryActive` + minimal `RECOVERY ATTIVO` / `RECOVERY ACTIVE` banner on Watch Live.
- Engine `recoverySelfCheckDiagnostics` blocks checkpoint restore when tissues appear reset at depth.

### Logbook
- `FullComputerDiveLogbookMetadata` on completed `DiveSession` (GF, gas events, NDL/ceiling/TTS extremes, stops, violations, unavailable gases, recovery events, algorithm version).
- `FullComputerRuntimeLogbookAccumulator` tracks extremes during the dive.

### Sync / merge
- Optional `fullComputerLogbookMetadata` on Watch and iOS `DiveSession` (backward compatible decode).
- Watch `DiveSessionMerge` preserves `watchActivityMode`, `watchDivingMode`, and FC logbook metadata.
- iOS `DiveSessionMerge` merges FC logbook metadata by richer recovery record.

### Tests
- `Tests/WatchAlgorithmTests/FullComputerRecoveryCheckpointTests.swift` — round-trip, checksum, merge, accumulator.

## Files
- `Utils/FullComputerRuntimeCheckpoint.swift`
- `Utils/FullComputerRuntimeLogbookAccumulator.swift`
- `Shared/Models/FullComputerDiveLogbookMetadata.swift`
- `Services/FullComputerRuntimeEngine.swift`, `Services/DiveManager.swift`
- `Models/DiveSession.swift`, `Utils/DiveSessionMerge.swift`
- `iOSApp/Models/DiveSession.swift`, `iOSApp/Utils/DiveSessionMerge.swift`
- `Views/DiveLiveView.swift`
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
