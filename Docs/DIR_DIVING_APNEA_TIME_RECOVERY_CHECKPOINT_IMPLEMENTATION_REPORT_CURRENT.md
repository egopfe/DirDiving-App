# DIR DIVING — Apnea Time, Recovery and Checkpoint Engine

**Command:** `03_APNEA_TIME_RECOVERY_AND_CHECKPOINT_ENGINE.md`  
**Date:** 2026-06-17  
**Branch:** `integration/full-computer`  
**Final result:** **PASS**

## Delivered
- Replaced Date/Timer counters with monotonic engine-driven values in `ApneaSessionEngine`.
- Added recovery policy modes: `informationalOnly`, `ratio1to1`, `ratio2to1`, `fixedDuration`, `customRatio`.
- Added persistent atomic checkpoint envelope with checksum, schema, and conservative recovery resume.
- Exposed presentation-ready values: dive/surface/session elapsed, total underwater, required/remaining recovery, completion state.

## Files
- `Shared/Models/ApneaRecoveryPolicy.swift`
- `Shared/Utils/ApneaSessionCheckpoint.swift`
- `Shared/Utils/ApneaSessionEngine.swift`
- `Shared/Utils/DepthMeasurementFeed.swift`
- `Tests/WatchAlgorithmTests/ApneaTimeRecoveryCheckpointEngineTests.swift`
- `project.yml`

## Notes
- No SwiftUI state logic added.
- No DiveManager/Gauge/Full Computer lifecycle changes.
- Recovery after restore remains conservative (no silent reset).
