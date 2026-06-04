# DIR DIVING Watch MAIN Algorithm and Mathematical Logic Audit

Audit date: 2026-05-27  
Repository: `egopfe/DirDiving-App`  
Branch audited: `main`  
Scope: Apple Watch MAIN app only  
Mode: audit/report only; no application code changes

## Executive Summary

The Apple Watch MAIN branch now contains a substantially hardened algorithm layer for depth validation, automatic dive lifecycle, time-weighted average depth, runtime, stopwatch timing, ascent rate calculation, safety-depth states, compass normalization, GPS best-effort capture, logbook normalization, export validation, and sync payload validation.

No confirmed P0 safety-critical algorithm defects were found in the inspected Watch MAIN code. The core diving math is finite-safe, validated before use in the main live path, and generally conservative when data is missing, stale, invalid, or above the supported 40 m operating range.

The main remaining items are release-hardening refinements rather than immediate safety blockers:

- P2: `DiveLogStore.load()` and `reloadFromPersistence()` do not enforce the documented 40-session cap after local/cloud merge, although `add()` and `addFromCompanion()` do.
- P2/P3: water temperature validation rejects non-finite values but does not bound finite but physically implausible temperatures.
- P3: `SubsurfaceExportService.writeCSV()` correctly refuses empty profiles, but the lower-level `makeCSV()` API can still return a header-only CSV string if called directly.
- P3: ascent-rate depth-band boundary behavior is tested and deterministic, but the inclusive/exclusive convention at exactly 30 m, 20 m, and 6 m should be explicitly documented against the product requirement.
- P3: there is no explicit hysteresis state machine for ascent band transitions beyond validated samples, a rolling rate window, and green/yellow/red zone thresholds.
- P3: GPS capture validates coordinate shape but does not enforce a maximum age or maximum horizontal accuracy for fallback points.
- P3: some conversion constants remain outside a single unit-conversion module.
- P3: several important paths still lack direct unit tests, especially active-dive draft restoration, GPS capture replacement, sync codec corruption, haptic coordinators, and end-to-end `DiveManager` lifecycle.

Overall algorithm readiness assessment: **high for internal validation**, with the caveat that the app remains explicitly non-certified and informational. The remaining issues should be fixed or documented before claiming full production release-hardness.

## Files Inspected

Primary Watch algorithm and service files:

- `Utils/DiveAlgorithmConfiguration.swift`
- `Utils/DepthSampleValidation.swift`
- `Utils/DiveLifecycleAlgorithm.swift`
- `Utils/DiveSessionAlgorithmValidator.swift`
- `Utils/DiveSessionMerge.swift`
- `Utils/DepthSafetyConfiguration.swift`
- `Utils/DIRUnitPreference.swift`
- `Utils/MissionModeRuntimeProfile.swift`
- `Utils/DiveAlgorithmSelfCheck.swift`
- `Models/DiveSample.swift`
- `Models/DiveSession.swift`
- `Models/GPSPoint.swift`
- `Models/AscentRateLimits.swift`
- `Models/AscentStatus.swift`
- `Models/DiveMode.swift`
- `Models/DiveProfilePoint.swift`
- `Services/DiveManager.swift`
- `Services/GPSManager.swift`
- `Services/CompassManager.swift`
- `Services/DiveLogStore.swift`
- `Services/SubsurfaceExportService.swift`
- `Services/WatchDiveSyncCodec.swift`
- `Services/WatchSyncService.swift`
- `Services/AscentSafetyHapticCoordinator.swift`
- `Services/DepthLimitHapticCoordinator.swift`
- `Services/HapticService.swift`
- `Services/DiveManager.swift` (Mission Mode lifecycle)
- `Utils/MissionModeRuntimeProfile.swift`
- `Services/SettingsStore.swift`
- `Services/AlarmSettingsStore.swift`
- `Services/AscentSettingsStore.swift`

Test and project files:

- `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift`
- `project.yml`

Reference documentation inspected by filename where relevant:

- `Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`
- `Docs/CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`

## Algorithms Found

### Depth Sample Validation

Implemented through `DepthSampleValidationState` and `DiveAlgorithm` helpers.

Validation states found:

- `valid`
- `missing`
- `stale`
- `frozen`
- `spikeRejected`
- `nonFinite`
- `outOfRange`

Behavior:

- `nil`, `NaN`, and infinity depth values are rejected.
- Finite negative depth values are clamped to 0 m.
- Values above `maximumPlausibleDepthMeters` are rejected.
- Samples older than `staleDepthSampleSeconds` or too far in the future are rejected as stale.
- Frozen values are detected after sustained unchanged depth within tolerance.
- Extreme single-sample transitions are rejected via a maximum plausible depth-change rate.

Assessment: strong. The live metric path is protected from non-finite and extreme depth values.

### Automatic Dive Lifecycle

Implemented through `DiveLifecycleAlgorithm` and coordinated by `DiveManager`.

Behavior:

- Automatic start requires validated depth greater than 1.0 m.
- Start requires two consecutive samples above threshold.
- Automatic stop requires depth at or below 0.3 m plus an 8 s surface dwell.
- CoreMotion submersion events assist lifecycle state but do not start a dive without measured validated depth.
- Manual dive start is guarded against duplicate sessions.
- Manual lifecycle can transition cleanly to sensor-owned lifecycle after validated submerged depth is observed.

Assessment: strong. The lifecycle no longer depends only on CoreMotion `.submerged` / `.notSubmerged` events.

### Runtime and Stopwatch

Implemented in `DiveManager`.

Behavior:

- Dive runtime is derived from stored session start date and current clock delta.
- Runtime timer refreshes the displayed value rather than incrementing a counter blindly.
- Stopwatch uses accumulated elapsed time plus start/resume timestamp.
- Stopwatch state is persisted in UserDefaults and restored.

Assessment: strong. The implementation avoids classic `+= 1` drift and double-counting failure modes.

### Average Depth

Implemented by `DiveAlgorithm.timeWeightedAverageDepth(samples:endDate:)`.

Formula:

```text
weighted_average_depth = sum(depth_i * delta_time_i) / sum(delta_time_i)
```

Behavior:

- Samples are sanitized and sorted by timestamp.
- Invalid depth samples are removed.
- Irregular sample intervals are handled.
- Zero samples return 0.
- One sample returns that sample depth.
- Optional tail interval to end date is supported.
- The same helper is used for live values, final session values, merge, validation, and tests.

Assessment: strong.

### TTV / Index

Implemented by `DiveAlgorithm.ttvIndex(averageDepthMeters:durationSeconds:)`.

Formula found:

```text
TTV/index = max(0, finite_average_depth_m) + max(0, finite_duration_s) / 60
```

Assessment: deterministic and finite-safe. Dimensional meaning remains an app-specific index, not a decompression metric. The UI/legal copy should continue avoiding any implication that TTV is certified decompression guidance.

### Ascent Rate

Implemented by `DiveAlgorithm.ascentRateMetersPerMinute(samples:current:)` and `AscentStatus`.

Formula found:

```text
ascent_rate_m_min = max(0, (reference_depth_m - current_depth_m) / delta_seconds * 60)
```

Behavior:

- Uses sanitized samples only.
- Uses a rolling window of 5 s, falling back to the immediately previous sample if no window candidate exists.
- Requires at least 1 s delta to avoid timestamp amplification.
- Descent and stationary depth return 0.
- Output is clamped to the maximum plausible depth-change rate.
- Depth above 40 m uses conservative exceeded-range behavior through `AscentRateLimits`.
- Green/yellow/red zones are based on 70 percent and 100 percent of the active limit.

Band limits found:

- Depth greater than 40 m: conservative 1 m/min limit
- 40 m and 30..<40 m: 10 m/min
- 20..<30 m: 5 m/min
- 6..<20 m: 3 m/min
- 0..<6 m: 1 m/min

Assessment: robust for noise compared with raw consecutive-sample math. Boundary inclusivity should be documented because exact 30 m, 20 m, and 6 m behavior is deterministic but may not match every literal reading of the product band text.

### Safety Depth States

Implemented through `DepthSafetyConfiguration` and `DepthSafetyState`.

Thresholds found:

- caution: 35 m
- critical: 38 m
- maximum supported: 40 m

Behavior:

- Depth at or above 40 m is marked as `exceeded`.
- The `DiveSession` model preserves or derives `exceededSupportedDepthRange`.
- Exceeded range suppresses positive depth reinforcement through state.

Assessment: strong. Values above the documented operating range are not treated as normal success states.

### Water Temperature

Implemented through CoreMotion water temperature delegate and `DiveAlgorithm.sanitizedTemperatureCelsius`.

Behavior:

- Celsius is canonical.
- Metric display uses Celsius.
- Imperial display uses Fahrenheit.
- Non-finite temperatures are rejected.
- Final session stores average/min/max temperature from sanitized sample temperatures.

Assessment: mostly good. The remaining weakness is that finite but implausible temperatures are not bounded.

### Compass / Bearing

Implemented by `CompassManager` and `DiveAlgorithm` degree helpers.

Behavior:

- True heading is preferred when available.
- Magnetic heading is used as fallback.
- Headings and bearings normalize to `0..<360`.
- Signed delta handles wraparound at 0/360.
- Negative heading accuracy produces calibration copy.

Assessment: strong.

### GPS Last Known Point

Implemented by `GPSManager`.

Behavior:

- Coordinates are validated for finite latitude/longitude.
- Latitude is constrained to -90...90.
- Longitude is constrained to -180...180.
- Horizontal accuracy must be finite and nonnegative.
- Entry and exit best-effort captures are bounded by a clamped capture duration.
- Replacing an in-flight best-effort capture finishes the previous one so no caller is stranded.

Assessment: good. Remaining limitation: fallback points do not have explicit maximum age or maximum horizontal accuracy thresholds.

### Mission Mode

Implemented by `DiveManager` and `MissionModeRuntimeProfile` (UI/runtime only; no dive math changes).

Behavior observed:

- Mission Mode is started/stopped with dive lifecycle.
- Runtime profile appears representational and battery/runtime-oriented.
- It does not appear to corrupt dive calculations.

Assessment: no mathematical blocker found.

### Logbook Consistency

Implemented by `DiveManager`, `DiveLogStore`, `DiveSessionMerge`, and `DiveSessionAlgorithmValidator`.

Behavior:

- Final sessions recompute duration, max depth, time-weighted average depth, TTV/index, temperature average/min/max, samples, GPS points, and exceeded-depth flag.
- Merge recomputes derived values instead of mixing unrelated derived fields.
- Sync/import validation rejects corrupted sessions before logbook insertion.
- `add()` and `addFromCompanion()` enforce the 40-session cap.

Assessment: strong with one P2 gap: `load()` and `reloadFromPersistence()` do not apply the same 40-session cap after local/cloud merge.

### Export / Profile Data

Implemented by `SubsurfaceExportService`.

Behavior:

- `writeCSV()` rejects empty exportable sample arrays.
- Export samples are sanitized and sorted.
- Elapsed seconds are nonnegative.
- CSV uses canonical metric depth values.
- Temporary exports are written atomically with complete file protection.

Assessment: good for the write path. Lower-level `makeCSV()` can still produce a header-only CSV if called directly.

### Watch Sync Payload Validation

Implemented by `WatchDiveSyncCodec` plus `DiveSessionAlgorithmValidator`.

Behavior:

- Payloads are normalized and validated before encoding.
- Incoming payloads are HMAC-verified and session-validated before returning.
- Invalid depth, impossible timestamps, invalid GPS, impossible duration, and inconsistent derived values are rejected through the validator.

Assessment: strong.

## Mathematical Formulas Found

### Time-Weighted Average Depth

```text
avg_depth_m = sum(depth_i_m * interval_i_s) / sum(interval_i_s)
```

Used for:

- live average depth
- restored active draft average depth
- final saved session average depth
- TTV/index input
- merge normalization
- validation

### TTV / Index

```text
ttv = avg_depth_m + duration_s / 60
```

This is an app-specific index. It is not a decompression calculation.

### Ascent Rate

```text
rate_m_min = max(0, (reference_depth_m - current_depth_m) / delta_s * 60)
```

This converts upward depth change over elapsed seconds into meters per minute.

### Depth Transition Plausibility

```text
abs(current_depth_m - previous_depth_m) / delta_s * 60 <= 90 m/min
```

### Runtime

```text
runtime_s = max(0, now - session_start)
```

### Stopwatch

```text
display_stopwatch_s = accumulated_s + max(0, now - stopwatch_started_at)
```

### Temperature Conversion

```text
fahrenheit = celsius * 9 / 5 + 32
```

### Distance and Speed From GPS

GPS speed uses CoreLocation distance divided by timestamp delta:

```text
speed_m_s = max(0, distance_m / delta_s)
```

### Compass Normalization

```text
normalized_degrees = ((degrees % 360) + 360) % 360
```

### Signed Bearing Delta

```text
delta = bearing - heading
if delta > 180: delta -= 360
if delta < -180: delta += 360
```

### Unit Conversions

Found through `DIRUnitPreference`:

- meters to feet: `m * 3.280839895`
- Celsius to Fahrenheit: `C * 9 / 5 + 32`
- bar to psi: `bar * 14.5037738`

## Constants and Thresholds Found

### Depth Lifecycle

- automatic start depth: 1.0 m
- automatic start required samples: 2
- automatic stop/surface depth: 0.3 m
- automatic stop dwell: 8 s

### Depth Validation

- stale depth sample: 8 s
- maximum future skew: 1 s
- frozen depth timeout: 30 s
- frozen tolerance: 0.001 m
- maximum plausible depth: 350 m
- maximum plausible depth-change rate: 90 m/min

### Ascent

- rolling rate window: 5 s
- minimum ascent delta: 1 s
- deep limit: 10 m/min
- mid limit: 5 m/min
- shallow limit: 3 m/min
- surface limit: 1 m/min
- above supported range: conservative 1 m/min
- green/yellow threshold: 70 percent of limit
- red threshold: over 100 percent of limit

### Supported Depth Safety

- caution: 35 m
- critical: 38 m
- exceeded: 40 m

### Logbook / Persistence

- active dive draft expiration: 12 h
- logbook cap: 40 sessions
- session validator max duration: 86,400 s
- session validator max samples: 20,000
- sync payload max bytes: 512,000
- sync date skew tolerance: 3,600 s

### Export

- temporary CSV cleanup: older than 86,400 s

## Detailed Correctness Assessment By Audit Area

### 1. Depth Sensor Logic

Status: pass with minor limitations.

Strengths:

- Missing, non-finite, stale, frozen, out-of-range, and spike samples are identified before live metrics.
- Negative finite depth clamps safely to 0.
- Current depth, average depth, max depth, ascent rate, TTV/index, logbook, merge, validator, sync, and export all use sanitized values or normalized sessions.
- Shallow oscillation is handled by lifecycle hysteresis and dwell rules.

Remaining risks:

- The 350 m maximum plausible depth is much higher than the documented 40 m supported range. This is acceptable because values above 40 m are marked as exceeded, but it should remain documented as "accepted for conservative warning/logging, not supported operation."
- Stale/frozen invalid samples during an active dive set error state but do not themselves create a dedicated safety haptic. This is conservative because the app avoids calculating from bad data, but the user feedback model should be validated on device.

### 2. Dive Start / Stop Algorithm

Status: pass.

Strengths:

- Automatic start is based on validated measured depth greater than 1 m, not only CoreMotion submersion state.
- Start debounce requires sustained samples.
- Stop uses surface threshold plus dwell.
- Manual and automatic lifecycles are prevented from duplicating sessions.
- Manual lifecycle transitions to sensor-owned lifecycle when validated submerged depth arrives.

Remaining risks:

- The exact session start timestamp is the time `beginDiveIfNeeded()` runs, not necessarily the timestamp of the first above-threshold sample. The skew should be small, but it is a measurable timing convention.

### 3. Dive Runtime / Chronometer

Status: pass.

Strengths:

- Runtime is clock-derived.
- Stopwatch uses start/resume timestamps and accumulated time.
- State is persisted and restored.

Remaining risks:

- Tests do not directly exercise app lifecycle transitions around active-dive draft restore and stopwatch restore.

### 4. Average Depth

Status: pass.

Strengths:

- Uses time-weighted average.
- Handles irregular intervals.
- Uses validated samples.
- Shared helper reduces divergence between live, saved, merged, and validated values.

Remaining risks:

- None confirmed in formula. End-to-end tests through `DiveManager` finalization are still missing.

### 5. TTV / Index

Status: pass, with legal/safety positioning caveat.

Strengths:

- Formula is centralized and finite-safe.
- Live and saved calculations are consistent with time-weighted average depth and runtime.

Remaining risks:

- `TTV = average depth + dive time minutes` is dimensionally an app-specific index, not a decompression or time-to-surface calculation. It must remain clearly documented and labeled as informational.

### 6. Ascent Rate Algorithm

Status: pass with P3 clarification.

Strengths:

- Rolling-window calculation reduces single-sample noise.
- Duplicate/near-zero timestamp amplification is avoided.
- Descent/stationary movement returns 0.
- Above 40 m uses conservative behavior.
- Safety haptics are coordinated outside the view layer.

Remaining risks:

- Exact depth-band boundaries follow the existing code/tests: 30 m belongs to the 10 m/min band, 20 m to 5 m/min, and 6 m to 3 m/min. If the product requirement intended exact 30 m to be capped at 5 m/min, exact 20 m at 3 m/min, and exact 6 m at 1 m/min, this is a calculation-correctness mismatch.
- There is no explicit hysteresis state around band boundary transitions. Windowing helps rate stability, but limit selection itself can still change immediately as depth crosses a boundary.

### 7. Maximum Supported Depth / Safety States

Status: pass.

Strengths:

- 35/38/40 m states are centralized.
- `exceededSupportedDepthRange` is persisted and derived safely.
- Above-limit values do not produce positive reinforcement.
- Above 40 m ascent limit becomes conservative.

Remaining risks:

- `DepthSafetyState.from(depthMeters:)` itself does not explicitly guard `NaN`, but normal call paths feed it sanitized finite depths. Consider adding a direct finite guard for defensive completeness.

### 8. Water Temperature

Status: partial pass.

Strengths:

- Non-finite values are rejected.
- Celsius is canonical.
- Metric/imperial display conversion exists.
- Saved logs compute average/min/max from sanitized sample temperatures.

Remaining risks:

- Finite but implausible temperatures are accepted. A corrupted finite value can pollute average/min/max temperature values.
- Temperature samples use the latest known water temperature alongside depth samples; timestamp alignment is approximate because CoreMotion reports temperature and depth through separate callbacks.

### 9. Compass / Bearing / Waypoint Logic

Status: pass.

Strengths:

- True heading preference and magnetic fallback are implemented.
- Heading and bearing normalization are centralized.
- Signed delta correctly handles 0/360 wraparound.
- Calibration unavailable state is exposed through heading accuracy message.

Remaining risks:

- Physical-device testing is still required for magnetic interference, calibration behavior, and underwater usability.

### 10. GPS Last Known Point

Status: pass with quality limitation.

Strengths:

- GPS coordinates and horizontal accuracy are validated for finite/ranged values.
- Best-effort capture replacement completes the previous caller rather than stranding it.
- No crash path found for unavailable GPS.

Remaining risks:

- No maximum age threshold is applied to `lastPoint` fallback.
- No maximum horizontal accuracy threshold is applied to classify a point as too weak for entry/exit confidence.

### 11. Mission Mode

Status: pass.

Strengths:

- Mission Mode starts/stops with dive lifecycle.
- No evidence found that Mission Mode state alters depth, runtime, average depth, TTV/index, ascent rate, or persistence calculations.

Remaining risks:

- Behavior still needs on-device confirmation because watchOS power modes and entitlements can vary by hardware/OS.

### 12. Logbook Algorithmic Consistency

Status: pass with P2 cap issue.

Strengths:

- Finalization recomputes derived values from sanitized samples.
- Merge recomputes derived values.
- Sessions preserve exceeded-depth state.
- Add paths enforce 40-dive limit.

Remaining risks:

- `load()` and `reloadFromPersistence()` can expose more than 40 sessions after local/cloud merge because they sort but do not apply the `maxSessions` prefix.
- Merge chooses a canonical sample set rather than unioning complementary sample arrays. This preserves consistency but can discard complementary profile data if two devices hold different parts of a session.

### 13. Export / Profile Data

Status: pass for write path; minor API edge.

Strengths:

- Export writing refuses empty exportable profiles.
- Samples are sorted and sanitized.
- Elapsed seconds are nonnegative.
- CSV remains metric and stable.

Remaining risks:

- Direct callers of `makeCSV()` can receive header-only CSV for an empty profile.
- Export does not include gas fields. This appears acceptable for Watch MAIN because gas planning is not a Watch MAIN algorithm, but the omission should remain documented.

### 14. Mathematical Robustness

Status: mostly pass.

Strengths:

- Main formulas guard non-finite inputs.
- Division-by-zero and near-zero timestamp amplification are avoided.
- Samples are sorted and sanitized before major calculations.
- Derived values are recomputed during merge and validation.
- Unit conversions are deterministic.

Remaining risks:

- Unit conversion constants are not all housed in one canonical conversion module.
- Some constants are duplicated across validator/sync/config layers.
- Plausible temperature bounds are missing.

### 15. Test Coverage

Status: partial pass.

Existing tests cover:

- missing, NaN, infinity, and out-of-range depth rejection
- finite negative depth clamp
- stale, frozen, and spike depth detection
- automatic lifecycle debounce and surface dwell
- time-weighted average depth for zero, one, and irregular samples
- TTV/index recomputation
- ascent stationary/descent/ascent behavior
- ascent limit and zone boundaries
- depth safety exceeded state
- temperature display conversion and non-finite rejection
- compass normalization and bearing delta wraparound
- empty export rejection through `writeCSV()`
- export sample sorting through `makeCSV()`
- corrupted session rejection
- impossible transition rejection
- merge recomputation of derived values

Missing or limited test coverage:

- end-to-end `DiveManager` automatic start, finalization, and logbook persistence
- manual start/end and transition from manual to sensor-owned lifecycle
- active-dive draft restore after app restart
- runtime/stopwatch restore across lifecycle transitions
- depth safety haptic coordinator throttling
- ascent haptic coordinator throttling
- GPS unavailable, stale fallback, and best-effort capture replacement
- `WatchDiveSyncCodec` corrupt payload rejection and signed payload handling
- `DiveLogStore.load()` and `reloadFromPersistence()` 40-session cap behavior
- temperature plausible-range filtering
- ascent band boundary behavior if product chooses lower-band inclusivity
- direct `SubsurfaceExportService.makeCSV()` empty-profile behavior

## Safety-Critical Issues

### P0 Safety-Critical

No confirmed P0 defects were found in the audited Apple Watch MAIN algorithm code.

Reasons:

- Invalid depth values are rejected before they drive live metrics.
- Automatic dive start requires validated measured depth.
- Runtime and stopwatch are clock-derived.
- Average depth is time-weighted.
- Ascent rate is windowed and finite-safe.
- Above-supported-depth behavior is conservative.
- Safety haptics are coordinated outside view rendering.
- Sync payloads are validated before logbook insertion.

### Safety-Critical Caveats

- The app must continue presenting itself as a non-certified informational companion, not as a certified dive computer.
- On-device validation remains mandatory for CoreMotion underwater sensor behavior, haptics, GPS availability, and watchOS lifecycle interruptions.
- The water submersion entitlement remains an external release dependency.

## Edge Cases Reviewed

### Handled

- Missing depth sample
- NaN/infinite depth
- Negative finite depth
- Out-of-range extreme depth
- Stale depth timestamp
- Future-skewed timestamp
- Frozen sample stream
- Sudden implausible depth spike
- One-sample and zero-sample average depth
- Irregular sample intervals
- Stationary depth ascent rate
- Descending depth ascent rate
- Near-zero ascent delta
- Depth above 40 m
- Compass wraparound
- GPS unavailable completion path
- Empty export through `writeCSV`
- Corrupted session import/sync validation

### Partially Handled / Needs More Validation

- Finite but implausible temperature values
- More than 40 sessions after local/cloud load merge
- Stale or inaccurate GPS fallback quality
- Exact ascent band inclusivity at 30/20/6 m
- Full active-dive restoration after app restart
- watchOS background/foreground transition timing
- Complementary sample arrays during merge

## Priority Ranking

### P0 - Safety-Critical

None confirmed.

### P1 - Calculation Correctness

No confirmed P1 defects under the current code and existing tests.

Conditional P1:

- **Ascent band boundary convention**: if the product requirement intends exact 30 m to use the 5 m/min band, exact 20 m to use the 3 m/min band, and exact 6 m to use the 1 m/min band, current code/tests should be changed. If the current upper-band inclusive convention is intended, this is documentation-only.

### P2 - Data Integrity

1. **Logbook cap not enforced on load/reload**
   - Area: `DiveLogStore`
   - Impact: local/cloud merge can expose more than the documented latest 40 dives.
   - Recommendation: apply the same sorted `prefix(maxSessions)` normalization in `load()` and `reloadFromPersistence()` after tombstone filtering.

2. **Implausible finite temperature values accepted**
   - Area: `DiveAlgorithm.sanitizedTemperatureCelsius`
   - Impact: corrupted finite temperature can pollute average/min/max saved log values and export.
   - Recommendation: add documented plausible water temperature bounds, or mark finite outliers unavailable.

### P3 - Maintainability / Release Hardening

1. **`makeCSV()` can return header-only CSV**
   - Area: `SubsurfaceExportService`
   - Impact: direct callers could treat a header-only string as export content.
   - Recommendation: make empty-profile behavior explicit, or keep `makeCSV()` private/internal behind `writeCSV()`.

2. **No explicit ascent-band hysteresis**
   - Area: `AscentRateLimits` / `AscentStatus`
   - Impact: limit can change immediately near 30/20/6 m boundaries.
   - Recommendation: document current behavior or introduce tested hysteresis if product wants reduced flicker.

3. **GPS fallback lacks quality threshold**
   - Area: `GPSManager`
   - Impact: a valid but old or weak point can be used as fallback.
   - Recommendation: add max-age and max-horizontal-accuracy policy, or surface fallback confidence clearly.

4. **Unit conversion constants are not fully centralized**
   - Area: `DIRUnitPreference`, algorithm config, validators
   - Impact: low current risk, but future drift risk.
   - Recommendation: centralize all unit conversion constants and add round-trip tests.

5. **Merge does not union complementary sample arrays**
   - Area: `DiveSessionMerge`
   - Impact: consistent derived values are preserved, but complementary profile data can be discarded.
   - Recommendation: decide whether this conservative choice is intentional; if not, create a timestamp-deduped sample union and recompute values.

6. **Important paths lack tests**
   - Area: tests
   - Impact: regression risk.
   - Recommendation: add direct tests listed below.

## Recommended Fixes

### Before Internal Release Validation

1. Enforce the 40-session cap during `DiveLogStore.load()` and `reloadFromPersistence()`.
2. Add plausible temperature bounds or an explicit unavailable state for physically impossible finite temperatures.
3. Confirm and document ascent band boundary inclusivity.
4. Add tests for active-dive draft restore and manual-to-sensor lifecycle transition.

### Before TestFlight

1. Add direct tests for `WatchDiveSyncCodec` corrupted payload rejection.
2. Add GPS best-effort capture tests, including replacing an in-flight capture.
3. Add tests for GPS unavailable and stale/low-accuracy fallback handling.
4. Add haptic coordinator throttling tests.
5. Add direct export tests for empty `makeCSV()` behavior or hide that API behind `writeCSV()`.

### Before App Store

1. Complete on-device underwater QA on Apple Watch Ultra hardware.
2. Validate CoreMotion depth and temperature callback timing under real sensor conditions.
3. Validate haptic behavior when the live dive view is not visible.
4. Validate watchOS background/foreground behavior and active-dive draft restoration.
5. Confirm all safety/legal copy remains non-certified and informational.

## Missing Unit Tests To Add

Recommended test scenarios:

- normal dive start, sample accumulation, finalization, and saved log values
- shallow dive that never crosses the sustained 1 m threshold
- rapid descent rejected only when transition is implausible
- rapid ascent rate calculated from rolling window
- oscillation around 1 m does not repeatedly start/end sessions
- missing depth stream during active dive
- frozen depth stream during active dive
- corrupted profile samples loaded from local persistence
- depth above supported 40 m range remains exceeded and conservative
- app background/foreground draft restoration
- metric/imperial conversion round trips
- compass wraparound around 359/0/1 deg
- GPS unavailable entry/exit capture
- GPS fallback older than policy threshold
- GPS horizontal accuracy above policy threshold
- manual start followed by validated submerged depth
- manual end only when manual lifecycle is still active
- 41st log session dropped deterministically
- local/cloud reload over 40 sessions capped deterministically
- `WatchDiveSyncCodec` rejects invalid signature
- `WatchDiveSyncCodec` rejects corrupted session
- haptics disabled setting suppresses noncritical haptics
- ascent and depth haptic coordinator throttle behavior
- empty export rejected by every public export path
- `makeCSV()` empty-profile behavior locked by test

## Final Verdict

### Ready To Compile?

Algorithm audit cannot prove compilation in this Windows environment. The `project.yml` includes a `DIRDiving Watch Algorithm Tests` target, and the inspected Swift code is internally coherent. Xcode/XcodeGen compilation should still be run on macOS/Xcode.

### Ready For Internal QA?

Yes, from an algorithm-audit perspective, with the listed P2/P3 fixes recommended before claiming full release-hardness.

### Ready For Average User?

Not solely based on this audit. Algorithm logic is strong, but average-user readiness also depends on device QA, entitlement availability, onboarding/legal review, UI checks, and App Store/TestFlight process validation.

### Ready For TestFlight?

Close, but recommended first:

- fix or document the P2 logbook cap load/reload behavior
- fix or document plausible temperature bounds
- run Watch build and algorithm tests on macOS/Xcode
- complete physical Apple Watch Ultra QA

### Ready For App Store?

Not yet by audit alone. App Store readiness still requires physical-device validation, entitlement confirmation, legal/safety review, and release process checks.

### What Blocks 100 Percent Algorithmic Release-Hardness?

1. P2 logbook cap inconsistency on load/reload.
2. P2/P3 lack of plausible finite temperature bounds.
3. Conditional ascent-band boundary clarification.
4. Missing tests for end-to-end lifecycle, persistence restore, GPS, sync codec, and haptics.
5. Physical-device validation for CoreMotion underwater behavior and watchOS lifecycle interruptions.
