# CODEX DIR DIVING Watch Algorithm and Mathematical Logic Audit

Audit date: 2026-05-26

Repository: `C:\Users\egopf\Documents\Codex\2026-05-08\puoi-prendere-il-codice-di-dirdiving\DirDiving-App`

Branch audited: `main`

HEAD audited: `20a665506fbae7b31e76f9964650317876138ad8`

Remote checked: `origin/main` at the same commit before this audit.

Scope: Apple Watch MAIN target only. iOS Companion code, experimental branches, Apnea, Snorkeling, Buddy Assist, and excluded experimental files were not audited except where `project.yml` was inspected to confirm they are excluded from the Watch MAIN target.

This is an audit/report only. No application code, UI, graphics, UX, navigation, business logic, mathematical logic, persistence model, or algorithm was modified.

## Executive Summary

The Watch MAIN code contains the core algorithmic pieces for a non-certified informational diving companion: CoreMotion water submersion depth samples, automatic event-based dive lifecycle, manual fallback, live runtime, stopwatch, average/max depth, TTV/index, ascent rate warnings, progressive depth safety states, temperature capture, compass/bearing support, GPS best-effort entry/exit capture, Mission Mode presentation state, log persistence, Watch-to-iPhone sync validation, and Subsurface CSV export.

The strongest parts are:

- Canonical internal depth storage is metric.
- Apple `CMWaterSubmersionManager` depth and temperature APIs are used directly instead of hand-rolled pressure conversion.
- Negative depth is clamped to zero before storage.
- The requested ascent bands are represented in `AscentRateLimits`.
- Depth safety thresholds at 35 m, 38 m, and 40 m are centralized.
- TTV/index is consistently implemented as `averageDepthMeters + elapsedMinutes` in live and saved sessions.
- Entry/exit GPS best-effort completion now prevents the previous stranded-completion bug.
- Mission Mode is presentation-only and does not alter dive math.

The main algorithmic risks are:

- **P0:** Automatic dive start/stop does not implement an explicit `depth > 1 m` threshold or debounce. It relies on CoreMotion `.submerged` / `.notSubmerged` events.
- **P0:** The depth pipeline has no explicit finite-value, stale-value, frozen-sensor, spike, or smoothing guard before publishing safety metrics.
- **P0:** Ascent warning haptic escalation is partly presentation-layer driven from `DiveLiveView`; the central algorithm updates blink state but does not centrally own the repeating haptic loop.
- **P1:** Average depth is a simple arithmetic mean of samples, not time-weighted.
- **P1:** Ascent rate is instantaneous over two consecutive raw samples, with no smoothing/windowing or noise rejection.
- **P1:** Live runtime and stopwatch use `Timer` increments and can drift or pause across lifecycle transitions; saved duration uses wall-clock `Date` difference, so live and saved values can diverge.
- **P1:** Water temperature display is fixed to Celsius in Live Dive even though the unit model supports Fahrenheit.
- **P2:** Active dive state and in-progress samples are not persisted mid-dive.
- **P2:** CSV export succeeds with a header-only file when samples are missing.
- **P2:** Imported/synced sessions are validated only at coarse session level; per-sample finite values, ordering, and consistency are not validated.
- **P3:** Constants and formulas are partly duplicated or scattered, and there is no XCTest target for algorithmic behavior.

Final algorithmic verdict: the code is coherent enough for internal testing as an informational Watch app after device validation, but it is not yet mathematically robust enough to call the Watch MAIN branch algorithmically release-hard without the P0/P1 issues below being addressed.

## Files Inspected

`project.yml` confirms that the Apple Watch MAIN target includes these roots: `App`, `Models`, `Services`, `Views`, `Utils`, and `Resources`, while excluding Apnea, Snorkeling, Buddy Assist, Exploration, and experimental concept files. The included Watch MAIN Swift file count is 61.

Primary algorithmic files inspected:

| File | Audit relevance |
|---|---|
| `Services/DiveManager.swift` | Depth sensor pipeline, dive lifecycle, runtime, TTV/index, average/max depth, ascent rate, alarms, Mission Mode, temperature capture. |
| `Models/DiveSample.swift` | Timestamped depth/temperature sample model. |
| `Models/DiveSession.swift` | Persisted dive summary and sample payload model. |
| `Models/AscentRateLimits.swift` | Configurable ascent-rate band thresholds. |
| `Models/AscentStatus.swift` | Ascent zone classification and default thresholds. |
| `Utils/DepthSafetyConfiguration.swift` | 35/38/40 m depth safety states. |
| `Utils/DepthSafetySelfCheck.swift` | Lightweight mapping helper for depth safety states. |
| `Services/DepthLimitHapticCoordinator.swift` | Depth warning haptic throttling. |
| `Services/GPSManager.swift` | Surface GPS authorization, current point, best-effort entry/exit capture, speed estimate. |
| `Services/CompassManager.swift` | Heading acquisition, true/magnetic fallback, bearing set/clear. |
| `Utils/DIRUnitPreference.swift` | Metric/imperial display conversions. |
| `Utils/WatchDepthFormatting.swift` | Watch depth display formatting. |
| `Utils/MissionModeRuntimeProfile.swift` | Mission Mode presentation profile. |
| `Services/DiveLogStore.swift` | Log storage, merge, 40-dive limit, cloud/local persistence. |
| `Utils/DiveSessionMerge.swift` | Merge rules for duplicated local/cloud sessions. |
| `Services/SubsurfaceExportService.swift` | CSV profile export. |
| `Services/WatchDiveSyncCodec.swift` | Watch sync payload validation limits. |
| `Services/WatchSyncService.swift` | Queueing, import, duplicate suppression, sync activity. |
| `Services/AscentRateSettingsStore.swift` | Persistence/sync of ascent-rate limits. |
| `Services/HapticService.swift` | Haptic throttling and ascent warning repeat interval. |
| `Services/ActionButtonIntents.swift` | Stopwatch/manual dive/bearing/alarm shortcut commands. |
| `Views/DiveLiveView.swift` | Live display formulas and ascent warning haptic loop trigger. |
| `Views/AscentGaugeView.swift` | Gauge scaling and rate pointer calculation. |
| `Views/AscentWarningBannerView.swift` | Ascent warning display rate formatting. |
| `Views/DepthSafetyLiveViews.swift` | Depth safety display states and positive-reinforcement suppression. |
| `Views/CompassView.swift` | Bearing delta wraparound, heading display, compass markers. |
| `Views/AlarmSettingsView.swift` | Alarm thresholds and range steppers. |
| `Views/AscentRateSettingsView.swift` | User-edited ascent-rate limits and unit conversion. |
| `Views/SettingsView.swift` | Mission Mode setting and algorithm-related settings reachability. |

Excluded by `project.yml` and not treated as Watch MAIN algorithms:

- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Models/ExplorationModels.swift`
- `Models/BuddyAssistMessage.swift`
- `Models/BuddyPairingHandshake.swift`
- `Services/ExplorationStore.swift`
- `Services/BuddyAssistService.swift`
- `Services/BuddyAssistPeripheralService.swift`
- `Services/BuddyPairingKeyAgreement.swift`
- `Services/SecureBuddyStore.swift`
- `Utils/ExperimentalFeatures.swift`

## Algorithms Found

| Area | Current implementation | Correctness assessment |
|---|---|---|
| Depth acquisition | `CMWaterSubmersionManagerDelegate.didUpdate measurement` reads `measurement.depth?.converted(to: .meters).value`; missing depth falls back to `currentDepthMeters`. | Partial. Correct API use, but no finite/stale/frozen/spike validation. |
| Depth storage | `DiveSample(depthMeters: max(0, depthMeters))`. | Partial. Negative clamped, but no NaN/infinity guard. |
| Automatic dive start | `.submerged` event calls `beginDiveIfNeeded()` when inactive. | Fails the explicit audit requirement if requirement is truly `depth > 1 m`; no explicit threshold/debounce. |
| Automatic dive stop | `.notSubmerged` event calls `endDiveIfNeeded()` unless manual session has never observed submersion. | Partial. No dwell debounce or shallow oscillation protection visible. |
| Manual dive start | `startManualDive()` calls `beginDiveIfNeeded(isManual: true)`. | Mostly correct. Guard prevents duplicate active dive. |
| Manual/auto interaction | If submerged during manual dive, manual flag is cleared; manual end then disabled. | Correct conflict prevention, but can surprise user; behavior should be test-covered. |
| Runtime | `Timer.scheduledTimer(1s)` increments `runtime += 1`; saved duration uses `end.timeIntervalSince(start)`. | Partial. Saved duration is more authoritative; live runtime may drift under app lifecycle transitions. |
| Stopwatch | Separate 1-second `Timer` increments `stopwatchTime += 1`. | Partial. Simple and reachable, but not monotonic/persisted. |
| Average depth | Arithmetic sample mean: `sum(depths) / count`. | Partial. Not time-weighted; irregular sample intervals bias the result. |
| Max depth | Running `max(maxDepthMeters, sample.depthMeters)`; saved recomputes `depths.max()`. | Mostly correct for finite samples. |
| TTV/index | Live: `averageDepthMeters + runtime / 60`; saved: `avgDepth + duration / 60`. | Consistent with current stated formula, but dimensionally an index, not time-to-surface/decompression. |
| Ascent rate | Consecutive raw sample delta: `max(0, (previousDepth - currentDepth) / deltaTime * 60)`. | Partial. Correct sign and units, but no smoothing/noise rejection. |
| Ascent zones | Green <= 70% of limit, yellow <= limit, red > limit. | Logical and clear, but should be tested at boundaries. |
| Depth safety states | Normal <35, caution >=35, critical >=38, exceeded >=40. | Correct and centralized. |
| Depth warning haptics | Caution 30s, critical 15s, exceeded 10s throttles; extra initial pulses. | Mostly correct, physical QA needed. |
| Water temperature | Separate `CMWaterTemperature` delegate stores Celsius; samples use latest value at depth sample time. | Partial. Missing/stale temp handled as nil/current, but no unit conversion in live temperature display. |
| Compass heading | Uses true heading if >=0, otherwise magnetic heading. | Mostly correct; no explicit normalization/calibration-quality handling. |
| Bearing set/clear | Saves current heading as `bearingDegrees`; clear nils it. | Correct for current session. Not persisted. |
| Bearing delta | `bearing - heading`, adjusted once when >180 or <-180. | Correct for normalized headings; fragile if heading outside 0...359. |
| GPS best effort | Captures current point, updates best by accuracy for 6 seconds, always finishes previous in-flight capture before replacing. | Improved and mostly correct; no stale max-age filter. |
| Mission Mode | Auto-enabled at dive start if setting true, disabled at dive end; affects animations/decorative effects only. | Correctly isolated from math. |
| Log limit | Saves max 40 sessions, sorted by start date. | Correct for limit, but overflow behavior is silent. |
| Export | CSV rows use seconds from first sample and metric depth/temp/GPS. | Partial. No sample sorting/empty rejection. |
| Sync validation | Duration 0...86400, max depth 0...350, <=20000 samples, end >= start. | Partial. Missing per-sample and internal formula consistency validation. |

## Mathematical Formulas Found

| Formula | Location | Assessment |
|---|---|---|
| `depthMeters = measurement.depth?.converted(to: .meters).value ?? currentDepthMeters` | `Services/DiveManager.swift:403-406` | Uses Apple unit conversion. Missing depth becomes duplicate current depth, which can bias averages/rates. |
| `sampleDepth = max(0, depthMeters)` | `Services/DiveManager.swift:262-265` | Negative depth is handled conservatively as surface. No explicit finite guard. |
| `averageDepthMeters = depths.reduce(0,+) / Double(count)` | `Services/DiveManager.swift:236`, `:268-269` | Arithmetic mean, not time-weighted. |
| `maxDepthMeters = max(maxDepthMeters, sample.depthMeters)` | `Services/DiveManager.swift:270` | Correct for valid finite samples. |
| `durationSeconds = end.timeIntervalSince(start)` | `Services/DiveManager.swift:239` | Wall-clock duration is authoritative for saved log. |
| `runtime += 1` each Timer tick | `Services/DiveManager.swift:189-194` | Susceptible to timer suspension/drift. |
| `stopwatchTime += 1` each Timer tick | `Services/DiveManager.swift:129-130` | Susceptible to timer suspension/drift; not persisted. |
| `ttv = averageDepthMeters + runtime / 60` | `Services/DiveManager.swift:193`, `:271` | Current TTV/index formula; mixes meters and minutes by design, so must remain clearly labeled informational. |
| `savedTTV = avgDepth + duration / 60` | `Services/DiveManager.swift:250` | Consistent with current formula, but may differ from live value if Timer drifted. |
| `deltaTime = max(sample.timestamp - previous.timestamp, 0.001)` | `Services/DiveManager.swift:341` | Prevents divide-by-zero but can produce huge rates from near-duplicate timestamps. |
| `rate = max(0, (previousDepth - currentDepth) / deltaTime * 60)` | `Services/DiveManager.swift:342-343` | Correct m/min sign convention; raw instantaneous value. |
| `limit(depth)` bands: `30...40 -> 10`, `20..<30 -> 5`, `6..<20 -> 3`, `0..<6 -> 1`, default -> fallback | `Models/AscentRateLimits.swift:18-25` | Matches requested bands for 0...40 m. Default fallback may be too permissive outside validated range. |
| `zone = green if rate <= 0.70*limit; yellow if <=limit; red otherwise` | `Models/AscentStatus.swift:30-34` | Clear and testable. |
| `DepthSafetyState.from`: 35/38/40 thresholds | `Utils/DepthSafetyConfiguration.swift:16-28` | Correct progressive safety mapping. |
| `feet = meters * 3.280839895` | `Utils/DIRUnitPreference.swift:45-49`, `:77-80` | Correct display conversion. |
| `meters = feet / 3.280839895` | `Utils/DIRUnitPreference.swift:56-60` | Correct input conversion. |
| `fahrenheit = celsius * 9/5 + 32` | `Utils/DIRUnitPreference.swift:63-67` | Correct conversion but not used by Live Dive temperature text. |
| `psi = bar * 14.5037738` | `Utils/DIRUnitPreference.swift:70-74` | Correct approximate conversion; pressure not used in Watch dive math. |
| `GPS speed = distance / delta` | `Services/GPSManager.swift:62-70` | Basic speed estimate; no accuracy filtering. |
| Haversine distance with earth radius `6_371_000 m` | `Utils/GeoMath.swift:3-13` | Standard formula, but utility is not central to current Watch MAIN diving flow. |
| Initial bearing formula via `atan2(y,x)` | `Utils/GeoMath.swift:16-24` | Standard initial bearing formula; only normalizes negative to positive once. |
| Compass delta wrap: adjust >180 by -360, <-180 by +360 | `Views/CompassView.swift:266-282` | Correct for normalized heading/bearing. |
| CSV sample seconds = `Int(sample.timestamp - firstTimestamp)` | `Services/SubsurfaceExportService.swift:7-14` | Simple elapsed seconds; assumes sample order and nonnegative timestamps. |
| Dive merge duration/max/ttv use max; avg/samples chosen by larger sample count | `Utils/DiveSessionMerge.swift:11-28` | Can create internally inconsistent merged sessions. |

## Constants and Thresholds Found

| Constant | Value | Location | Notes |
|---|---:|---|---|
| Depth safety caution | 35 m | `Utils/DepthSafetyConfiguration.swift:5` | Progressive warning begins. |
| Depth safety critical | 38 m | `Utils/DepthSafetyConfiguration.swift:6` | Near supported max. |
| Maximum supported depth | 40 m | `Utils/DepthSafetyConfiguration.swift:7` | `>=40` becomes exceeded. |
| Standard ascent deep band | 10 m/min | `Models/AscentRateLimits.swift:10-15` | 40-30 m target. |
| Standard ascent mid band | 5 m/min | `Models/AscentRateLimits.swift:10-15` | 30-20 m target. |
| Standard ascent shallow band | 3 m/min | `Models/AscentRateLimits.swift:10-15` | 20-6 m target. |
| Standard ascent surface band | 1 m/min | `Models/AscentRateLimits.swift:10-15` | 6-0 m target. |
| Standard fallback ascent limit | 10 m/min | `Models/AscentRateLimits.swift:15` | Used outside bands; can be too permissive >40 m. |
| Ascent green boundary | 70% of limit | `Models/AscentStatus.swift:33` | Yellow from >70% to <=100%. |
| Ascent delta minimum | 0.001 s | `Services/DiveManager.swift:341` | Prevents divide-by-zero; can amplify duplicate sample jitter. |
| Runtime tick | 1 s | `Services/DiveManager.swift:189` | Timer-based live runtime. |
| Stopwatch tick | 1 s | `Services/DiveManager.swift:129` | Timer-based stopwatch. |
| Blink timer | 0.45 s | `Services/DiveManager.swift:354` | Visual warning blink. |
| Ascent haptic repeat | 1.75 s | `Services/HapticService.swift:15` | Presentation-driven loop. |
| General warning haptic throttle | 2 s | `Services/HapticService.swift:26` | Prevents rapid haptic spam. |
| Alarm post-dismiss quiet period | 15 s | `Services/DiveManager.swift:328` | Suppresses alarms after dismiss. |
| Alarm repeat throttle | 30 s | `Services/DiveManager.swift:329` | Per-alarm throttle. |
| GPS capture window | 6 s | `Services/DiveManager.swift:172`, `:221` | Entry/exit best effort. |
| GPS desired accuracy | `kCLLocationAccuracyBest` | `Services/GPSManager.swift:17` | Surface GPS. |
| GPS distance filter | 5 m | `Services/GPSManager.swift:18` | Location update threshold. |
| GPS speed delta minimum | >0.25 s | `Services/GPSManager.swift:63-70` | Avoids very small speed intervals. |
| Runtime alarm default | 30 min | `Utils/WatchAlarmDefaults.swift:5` | Settings range 10...240. |
| Depth alarm default | 40 m | `Services/DiveManager.swift:44-47`; `Views/AlarmSettingsView.swift:8` | Depth alarm is disabled by default; depth safety is independent. |
| Battery alarm default | 20% | `Services/DiveManager.swift:52-60` | Enabled by default. |
| Log limit | 40 sessions | `Services/DiveLogStore.swift:19` | Oldest sessions dropped silently after sort. |
| Export cleanup age | 86,400 s | `Services/SubsurfaceExportService.swift:46` | 24 h temp cleanup. |
| Sync max payload | 512,000 bytes | `Services/WatchDiveSyncCodec.swift:8` | WatchConnectivity payload hardening. |
| Sync max samples | 20,000 | `Services/WatchDiveSyncCodec.swift:9` | Import validation only. |
| Sync max imported depth | 350 m | `Services/WatchDiveSyncCodec.swift:10` | Transport validation, not safety limit. |
| Sync max issued-at skew | 3,600 s | `Services/WatchDiveSyncCodec.swift:11` | Replay/stale guard. |
| Sync max duration | 86,400 s | `Services/WatchDiveSyncCodec.swift:163-166` | Import validation. |
| Imported session ID memory | 128 IDs | `Services/WatchDiveSyncCodec.swift:128-130` | Duplicate suppression ring. |
| Unit conversion feet per meter | 3.280839895 | `Utils/DIRUnitPreference.swift` | Correct. |
| Unit conversion psi per bar | 14.5037738 | `Utils/DIRUnitPreference.swift` | Correct approximate. |
| Earth radius | 6,371,000 m | `Utils/GeoMath.swift:5` | Standard mean radius. |
| Compass heading filter | 1 degree | `Services/CompassManager.swift:18` | Good resolution; physical QA needed. |

## Detailed Audit by Area

### 1. Depth Sensor Logic

Pipeline:

1. `CMWaterSubmersionManager` is created if `CMWaterSubmersionManager.waterSubmersionAvailable` is true.
2. CoreMotion depth measurement arrives in `manager(_:didUpdate measurement: CMWaterSubmersionMeasurement)`.
3. Code reads `measurement.depth?.converted(to: .meters).value`.
4. If depth is nil, it reuses `currentDepthMeters`.
5. `addSample` clamps negative depth to zero and appends a `DiveSample`.

Assessment:

- There is no hand-rolled pressure-to-depth conversion, which is good. Apple API depth values are treated as authoritative.
- Units are canonical metric in storage.
- Display conversion for depth/ascent rate exists for imperial.
- There is no smoothing, filtering, rolling window, median filter, debounce, spike rejection, or frozen-value detection.
- There is no explicit `isFinite` guard for `Double.nan`, `Double.infinity`, or values outside plausible physical range.
- Missing depth produces a repeated sample using `currentDepthMeters`, which can bias average depth, max depth, and ascent rate.
- Sample timestamp is created with `Date()` at ingestion time, not taken from a sensor-provided timestamp. If sensor delivery is delayed, ascent-rate timing can be distorted.
- Display precision is one decimal for Watch depth and two decimals in CSV export. Stored values retain raw `Double` precision.

Priority:

- P0: Add explicit finite/stale/frozen/debounce guards before publishing depth into live safety metrics.
- P1: Add filtering/smoothing for ascent-related depth values while preserving raw profile samples if desired.

### 2. Dive Start / Stop Algorithm

Automatic start:

- Code starts a dive on CoreMotion `.submerged` event.
- It does not check `depth > 1 m`.
- It does not implement threshold hysteresis or debounce around 1 m.

Automatic stop:

- Code ends a dive on `.notSubmerged`.
- It does not implement a surface dwell period.
- Shallow oscillation around the event boundary is delegated entirely to CoreMotion event semantics.

Manual start:

- Manual start is reachable and guarded by `guard !isDiveActive, !isFinalizingDive`.
- Manual start does not disable automatic start.
- If actual submersion is later observed during a manual session, the manual flag is cleared.

Persistence:

- Active dive state, session start, and samples are in memory only.
- If the Watch app is terminated/interrupted before `endDiveIfNeeded`, the in-progress dive can be lost.

Priority:

- P0: Implement or explicitly document the automatic start rule. If the requirement is `depth > 1 m`, the current implementation does not meet it.
- P0: Add start/stop debounce or surface dwell protection.
- P2: Persist active dive state and samples mid-dive.

### 3. Dive Runtime / Chronometer

Runtime:

- Live runtime increments by scheduled `Timer` every second.
- Saved session duration is computed as `end.timeIntervalSince(start)`.
- This means saved duration can be more accurate than live runtime if timers pause, skip, or drift.

Stopwatch:

- Stopwatch is independent of dive runtime.
- It increments by scheduled `Timer` every second.
- It is not persisted across app lifecycle transitions.
- Reset has a UI confirmation when nonzero.
- App Intents expose toggle/reset.

Priority:

- P1: Use monotonic/wall-clock delta for live runtime and stopwatch display rather than incrementing counters.
- P2: Persist stopwatch/running state if it is expected to survive app lifecycle interruptions.

### 4. Average Depth

Current formula:

`averageDepthMeters = sum(sample.depthMeters) / sampleCount`

Assessment:

- It is consistent between live calculation and saved final calculation.
- It is not time-weighted.
- It includes all active-dive samples, including possible repeated missing-depth fallback samples and any surface samples that arrive before `.notSubmerged`.
- It does not reject spikes.
- It is biased if CoreMotion sample intervals are irregular.

Priority:

- P1: Use a time-weighted average based on sample intervals for the persisted average depth.
- P1: Keep raw samples but calculate displayed/saved averages from validated samples.

### 5. TTV / Index

Current formula:

- Live: `ttv = averageDepthMeters + runtime / 60.0`
- Saved: `ttv = avgDepth + duration / 60.0`

Assessment:

- This is consistently applied in `DiveManager`.
- It is dimensionally mixed: meters plus minutes. It is therefore an index, not a physical time-to-surface or decompression value.
- UI copy correctly says it is informational and not decompressive.
- `DiveSessionMerge` uses `max(winner.ttv, loser.ttv)`, which can make merged TTV inconsistent with the merged average depth/duration.

Priority:

- P1: Rename or document internally as an index to prevent future decompression confusion.
- P2: Recompute TTV/index after merge instead of taking max.

### 6. Ascent Rate Algorithm

Current formula:

`rateMetersPerMinute = max(0, (previousDepth - currentDepth) / deltaSeconds * 60)`

Band limits:

- 40-30 m: 10 m/min
- 30-20 m: 5 m/min
- 20-6 m: 3 m/min
- 6-0 m: 1 m/min

Assessment:

- Band thresholds match the requested values in the 0...40 m domain.
- Descent and stationary depth are clamped to zero ascent rate.
- It uses raw consecutive samples.
- It uses the current sample depth to select the active band.
- It has no rolling time window, no smoothing, no hysteresis at band boundaries, and no sensor-noise tolerance.
- The `0.001 s` delta floor avoids divide-by-zero but can produce extreme rates from duplicate/near-duplicate timestamps.
- Values above 40 m use fallback limit, which defaults to 10 m/min and is user-editable. From a safety perspective, exceeded-range readings should probably be treated conservatively, not fallback-normal.
- Repeating ascent haptics are managed by `DiveLiveView`, not centrally by `DiveManager`.

Priority:

- P0: Move safety-critical ascent haptic state out of the view layer or guarantee it fires regardless of selected page/lifecycle.
- P1: Add smoothing/windowing and boundary hysteresis.
- P1: Define conservative behavior for depth > 40 m.

### 7. Maximum Supported Depth / Safety States

Current states:

- `<35 m`: normal
- `>=35 m`: caution
- `>=38 m`: critical
- `>=40 m`: exceeded

Assessment:

- Mapping is centralized and clear.
- Negative values are clamped to zero before state mapping.
- Exceeded state suppresses positive depth summary reinforcement in the live UI.
- Session model preserves `exceededSupportedDepthRange`.
- Decode/init also marks exceeded if `maxDepthMeters >= 40`.
- No explicit non-finite handling exists.

Priority:

- P0: Non-finite depth must become an error/sensor-invalid state, not a normal calculation path.
- P1: Add tests for all threshold edges and for >40 m export/log behavior.

### 8. Water Temperature

Current behavior:

- CoreMotion temperature delegate stores `currentTemperatureCelsius`.
- Each depth sample stores the latest known temperature.
- Saved log stores average, min, and max of non-nil temperatures.

Assessment:

- Missing temperature is represented as nil and live display uses `--.- C`.
- Early depth samples can have nil temperature.
- Samples can use stale temperature if depth updates arrive after temperature stops updating.
- Live display is always Celsius and does not use `DIRUnitPreference.temperatureDisplay`.
- No finite guard exists for temperature.

Priority:

- P1: Apply metric/imperial temperature display consistently.
- P2: Track temperature timestamp/staleness if temperature is used in logs.

### 9. Compass / Bearing / Waypoint Logic

Current behavior:

- `CompassManager` requests location authorization and starts heading updates if available.
- Heading uses true north when `trueHeading >= 0`, else magnetic heading.
- Bearing saves current heading.
- Bearing delta wraps across +/-180 degrees.

Assessment:

- Magnetic/true fallback is reasonable.
- Heading normalization is implicit; there is no explicit clamp/modulo in `CompassManager`.
- `CompassView` delta logic works if heading and bearing are in 0...359 degrees.
- No calibration quality or `headingAccuracy` warning is evaluated.
- Bearing is not persisted across restart.
- No waypoint or return-bearing algorithm is active in Watch MAIN diving flow beyond bearing set/clear and display.

Priority:

- P1: Normalize heading to 0..<360 at ingestion.
- P1: Use heading accuracy/calibration status for warnings.
- P2: Persist bearing if expected by user workflow.

### 10. GPS Last Known Point

Current behavior:

- GPS is started at dive begin.
- Entry GPS uses `currentBestPoint()` immediately and a 6-second best-effort capture.
- Exit GPS uses `currentBestPoint()` immediately and a 6-second best-effort capture.
- Best point improves when accuracy is better or when previous accuracy is unknown and new point is newer.
- Starting a new capture completes the previous capture first, preventing stranded completion.

Assessment:

- Good protection against no GPS: nil is handled.
- Permission request is explicit.
- Coordinates are saved with 6-decimal display precision.
- There is no stale-point maximum age.
- There is no explicit rejection of poor horizontal accuracy.
- GPS speed estimate is basic and not used by core dive math.

Priority:

- P2: Add stale-age/accuracy quality labels for entry/exit GPS.
- P2: Unit test overlapping capture completion behavior.

### 11. Mission Mode

Current behavior:

- Setting key: `dirdiving.missionMode.autoEnableOnDiveStart`.
- If enabled, Mission Mode turns on at dive start and off at dive end.
- Runtime profile disables animations/decorative effects but keeps UI refresh interval at 1 second.
- Code comment explicitly says Mission Mode never changes dive math, sampling, logging, or alerts.

Assessment:

- Correctly isolated from business/math logic.
- Manual setting is available in Watch Settings.
- It is representational/presentation-only as requested.

Priority:

- P3: Add regression tests or static assertions around Mission Mode not affecting sampling/logging if a test target is created.

### 12. Logbook Algorithmic Consistency

Saved values:

- Max depth: recomputed from saved samples.
- Average depth: arithmetic sample mean.
- Runtime: wall-clock duration from start/end date.
- TTV/index: `avgDepth + duration/60`.
- Temperature: average/min/max from non-nil temperatures.
- GPS: entry/exit point and fix source.
- Samples: raw appended samples in arrival order.
- Exceeded state: computed from active state or max depth >= 40.

Assessment:

- Saved values are mostly internally consistent for local sessions with valid samples.
- Sample interval is sensor-event driven, not fixed.
- 40-dive log limit is implemented.
- Deletion/tombstone behavior exists.
- In-progress dives are not persisted.
- Merge logic can produce inconsistent sessions by mixing max duration, max depth, max TTV, and samples/average from whichever side has more samples.

Priority:

- P2: Persist in-progress dive state and sample buffer.
- P2: Recompute derived fields after merge rather than mixing derived values.

### 13. Export / Profile Data

Current CSV:

`time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon`

Assessment:

- Metric-only export is consistent with stored canonical units.
- CSV assumes samples are already ordered.
- It returns header-only CSV when `session.samples.first` is nil, and `writeCSV` treats it as success.
- It does not validate nonnegative elapsed seconds.
- It does not sanitize imported bad samples before export.

Priority:

- P2: Reject empty-sample exports with a user-visible failure.
- P2: Sort samples or validate timestamp ordering before export.
- P2: Validate sample values before export.

### 14. Mathematical Robustness

Strengths:

- Most divide-by-zero paths are avoided.
- Negative depth is clamped.
- Unit conversions are centralized for display.
- Depth safety thresholds are centralized.
- Ascent limits are user-configurable and persisted.

Risks:

- No explicit `isFinite` checks for depth, temperature, duration, average, max, TTV, GPS coordinates, or imported samples.
- No smoothing/noise model for depth or ascent rate.
- Raw event frequency controls average-depth weighting.
- Runtime and stopwatch use Timer increments rather than elapsed time from a stored start/resume timestamp.
- Ascent rate minimum delta avoids zero division but can amplify timestamp jitter.
- TTV/index is dimensionally mixed by design and must never be treated as decompression/time-to-surface data.
- Constants are scattered across models, views, services, and settings.
- Some formulas are duplicated: ascent band logic exists in both `AscentStatus.limit(for:)` and `AscentRateLimits.limit(for:)`.
- No XCTest target was found.

## Safety-Critical Issues

| Priority | Issue | Evidence | Impact | Recommended fix |
|---|---|---|---|---|
| P0 | Automatic start does not implement explicit `depth > 1 m` rule. | `DiveManager` starts on `.submerged` event, not measured depth threshold. | Lifecycle may not match documented requirement; no audit-visible debounce around shallow oscillation. | Define canonical start/stop algorithm with threshold, hysteresis, and dwell time, or update requirement/docs to event-based behavior. |
| P0 | Depth values are not explicitly validated for finite/stale/frozen/spike states. | `addSample` clamps negative only. | Invalid sensor values can poison display, averages, ascent rate, logs, or export. | Add central sample validator before live metrics; quarantine invalid samples. |
| P0 | Ascent haptic escalation depends partly on `DiveLiveView`. | Repeating ascent haptics are started in `DiveLiveView.manageAscentAlarmHaptics`. | If the view is not active or lifecycle changes, safety haptics can be unreliable. | Centralize safety haptics in `DiveManager` or a safety alarm coordinator. |
| P1 | Ascent rate uses raw consecutive samples with no smoothing. | `updateAscentRate` uses only previous/current depth. | Sensor noise can cause false warnings or unstable readings. | Use validated windowed ascent rate with noise tolerance/hysteresis. |
| P1 | Average depth is not time-weighted. | Simple arithmetic sample mean. | Irregular sample intervals bias average and TTV/index. | Use time-weighted integration over sample intervals. |
| P1 | Live runtime/stopwatch can drift. | Timer counters increment by 1. | Display can diverge from saved duration or user expectation. | Compute live elapsed time from stored start timestamps. |
| P1 | Temperature unit preference not applied in live header. | `DiveLiveView.temperatureText` always returns Celsius. | Imperial mode is inconsistent. | Use `DIRUnitPreference.temperatureDisplay`. |
| P2 | Active dive not persisted mid-dive. | `sessionStart` and `samples` are in-memory private vars. | Interruption can lose a dive. | Persist active dive draft periodically. |
| P2 | Header-only CSV export succeeds. | `makeCSV` returns header if no samples. | User can export malformed/empty dive profile as success. | Reject or clearly label empty-profile export. |
| P2 | Merge can create internally inconsistent sessions. | `DiveSessionMerge` mixes max duration/max TTV and sample-count-selected avg/samples. | Log values after cloud conflict can disagree mathematically. | Recompute derived fields after choosing source samples/start/end. |

## Edge Cases

| Edge case | Current behavior | Risk |
|---|---|---|
| Depth around 0 m | Negative clamped to zero; surface event ends dive. | No dwell debounce; shallow oscillation delegated to CoreMotion. |
| Depth around 1 m | No explicit threshold in code. | Requirement mismatch if `>1 m` is mandatory. |
| Missing depth | Reuses current depth and appends a sample. | Can bias average/rate and hide sensor dropout. |
| Frozen depth | No detection. | Runtime continues while stale values look valid. |
| Delayed sensor delivery | Sample timestamp uses ingestion time. | Ascent rate can be distorted. |
| Rapid descent | Ascent rate clamps negative to zero. | OK for ascent warning, but descent speed not tracked. |
| Rapid ascent | Immediate raw rate can trigger warning. | Correct direction, but no smoothing/noise handling. |
| Band boundary at 30/20/6 m | Current sample depth selects band. | Can oscillate limits across boundary with noisy depth. |
| Depth >=40 m | Safety state exceeded; ascent fallback still defaults to 10 m/min. | Safety state is conservative, ascent limit fallback may not be. |
| No temperature | Displays placeholder; saved temp nil. | OK, but stale temp not differentiated. |
| Imperial mode | Depth/ascent convert; temperature live does not. | Inconsistent unit system. |
| Heading wrap 359->0 | Delta formula handles normalized wrap. | No issue for normal CoreLocation headings. |
| Heading out of range | No central normalization. | One-step delta wrap can fail if heading/bearing not normalized. |
| GPS denied/unavailable | Nil point handled, banner says unavailable. | No stale/accuracy-quality warning for old point. |
| Empty samples | Log can save duration with zero samples; export writes header only. | Data integrity/export issue. |
| App background during dive | In-memory state/timers can pause or be lost. | Runtime/samples/log can diverge or disappear. |
| Corrupted imported sample | Session-level validation only. | Bad samples can enter log/export. |

## Missing Tests

No XCTest Swift test files were found in the repository. `Utils/DepthSafetySelfCheck.swift` provides a lightweight mapping helper, but it is not an automated test target.

Recommended test cases:

### Depth sensor and sample validation

- Negative depth sample becomes 0 and does not trigger exceeded state.
- NaN depth is rejected and does not poison averages/TTV/ascent/export.
- Infinite depth is rejected and raises sensor-invalid state.
- Missing depth does not silently add repeated samples without a stale marker.
- Frozen depth over a configurable timeout is detected.
- Shallow oscillation around 0...1 m does not start/stop repeatedly.

### Dive lifecycle

- Automatic start only after the approved start condition.
- If requirement remains `depth > 1 m`, start does not occur at 0.9 m and does occur after debounce at 1.1 m.
- Surface stop requires dwell/debounce.
- Manual start while inactive creates one active session.
- Submerged event during manual session does not create a duplicate session.
- Manual end is disabled/handled once auto submersion owns lifecycle.
- Background/foreground transition preserves active dive state.

### Runtime and stopwatch

- Runtime after 90 real seconds is 90 seconds even if timer ticks are delayed.
- Saved duration equals wall-clock duration.
- Stopwatch does not double-count after start/stop/start.
- Stopwatch reset confirmation path resets once only.
- App Intent toggle/reset maps to the same state transitions as UI controls.

### Average depth and TTV/index

- Constant-depth regular samples produce expected average.
- Irregular sample intervals expose difference between arithmetic and time-weighted average.
- Zero samples produce clear no-profile state.
- TTV/index at zero depth/time is zero.
- Saved TTV/index equals recomputed formula after finalize.
- Merged sessions recompute TTV/index from final selected data.

### Ascent rate

- Stationary depth produces 0 m/min.
- Descent produces 0 m/min ascent.
- 1 m ascent in 30 s produces 2 m/min.
- Threshold boundaries at 30, 20, 6, and 0 m select correct bands.
- Rates exactly at 70%, 100%, and just above 100% classify green/yellow/red correctly.
- Sensor jitter does not create false red warnings after smoothing is implemented.
- Depth >40 m uses conservative exceeded-range behavior.

### Depth safety

- 34.99 m normal.
- 35.00 m caution.
- 37.99 m caution.
- 38.00 m critical.
- 39.99 m critical.
- 40.00 m exceeded.
- Above 40 m remains exceeded.
- Exceeded state suppresses positive depth summary reinforcement.

### Temperature

- Nil temperature remains nil in samples and logs.
- Celsius-to-Fahrenheit display conversion works in imperial mode.
- Stale temperature is not treated as fresh after timeout.
- Average/min/max temperatures ignore nil but reject non-finite values.

### Compass

- True heading used when valid.
- Magnetic heading used when true heading is negative.
- Heading normalization handles -1, 0, 359, 360, 721.
- Bearing delta wrap works for 350 to 10 and 10 to 350.
- Denied permission produces warning state.
- Bad heading accuracy produces calibration warning.

### GPS

- Best-effort capture returns nil when no point exists.
- Better horizontal accuracy replaces previous best point.
- Newer unknown accuracy replaces older unknown accuracy.
- Starting capture B finishes capture A completion.
- Stale last point is marked fallback/stale.
- Entry and exit GPS retain timestamp and 6-decimal coordinate precision.

### Log/export/sync

- 41st log drops only the oldest after sort, with expected behavior.
- Deletion writes tombstone and removes session.
- Empty samples cannot export as successful profile.
- Export sorts or rejects unsorted sample timestamps.
- Imported session with invalid duration/max depth/sample count is rejected.
- Imported session with invalid sample depth/timestamp is rejected.
- Exported CSV time_seconds is nonnegative and monotonic.

## Recommended Fixes

### P0 safety-critical

1. Define one canonical automatic lifecycle algorithm:
   - start threshold, for example depth > 1 m;
   - start debounce, for example sustained depth over threshold for N seconds or N samples;
   - stop threshold and surface dwell;
   - clear behavior for CoreMotion event vs measured depth conflicts.
2. Add a central `ValidatedDepthSample` path:
   - finite check;
   - plausible range check;
   - stale/frozen sensor detection;
   - spike detection;
   - validity state surfaced to UI/log/export.
3. Move ascent safety haptic loop out of `DiveLiveView` into a central safety coordinator so warnings are independent of current page/render lifecycle.

### P1 calculation correctness

1. Replace arithmetic average depth with a time-weighted average for persisted and displayed average depth.
2. Use a rolling ascent-rate window or low-pass filter with hysteresis at band boundaries.
3. Compute live runtime and stopwatch from start/resume timestamps rather than incrementing counters.
4. Apply unit preference to water temperature display.
5. Normalize compass heading and bearing to 0..<360 at ingestion and persistence boundaries.
6. Treat depth >40 m ascent-rate limit conservatively rather than through general fallback.

### P2 data integrity

1. Persist active dive drafts periodically during a dive.
2. Reject empty-profile export or label it as summary-only, not profile export.
3. Validate imported/synced sessions at per-sample level.
4. Recompute derived fields after merge.
5. Add stale GPS age and horizontal accuracy quality metadata.
6. Add sample ordering checks before export.

### P3 maintainability

1. Create an XCTest target for Watch algorithm units.
2. Centralize constants in typed configuration modules.
3. Remove duplicate ascent-limit logic by making `AscentStatus` depend only on `AscentRateLimits`.
4. Document TTV/index naming and ensure it cannot be confused with decompression time.
5. Add fixture-based tests for normal/shallow/rapid ascent/corrupted data scenarios.

## Priority Ranking

| Priority | Definition | Items |
|---|---|---|
| P0 safety-critical | Can affect safety-significant state, warning reliability, or lifecycle correctness. | Automatic start/stop threshold mismatch; missing finite/stale/frozen depth validation; view-driven ascent haptic loop. |
| P1 calculation correctness | Can produce materially incorrect values while app still appears functional. | Non-time-weighted average; raw instantaneous ascent rate; Timer drift; temperature unit inconsistency; compass normalization; >40 m ascent fallback. |
| P2 data integrity | Can corrupt, lose, or misrepresent persisted/logged/exported data. | No active-dive persistence; header-only export success; weak per-sample import validation; inconsistent merge-derived fields; no GPS stale-quality checks. |
| P3 maintainability | Makes future correctness harder to preserve. | No XCTest target; scattered constants; duplicated ascent limit formula; TTV/index naming ambiguity. |

## Final Verdict

The Watch MAIN branch has a coherent first-pass algorithmic implementation, but it is not yet mathematically or safety-state robust enough to consider the algorithms complete. The most important gap is not UI: it is the lack of a validated sample pipeline and explicit lifecycle threshold/debounce logic. The next engineering pass should focus on P0 and P1 items before additional feature work.

No fixes were applied in this audit.
