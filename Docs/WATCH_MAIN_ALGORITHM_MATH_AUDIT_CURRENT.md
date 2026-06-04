# Apple Watch MAIN Algorithm and Mathematical Functions Audit - Current

**Audit date:** 2026-06-03
**Repository:** DIR DIVING (`DirDiving-App`)
**Branch audited:** `main`
**Commit audited:** `3b7325bb54e02b9c5bb00ad2049c18eba1d6bdd0`
**Remote sync check:** `HEAD...origin/main = 0 0` after `git fetch origin`
**Target audited:** `DIRDiving Watch App` only
**Mode:** Read-only static audit on Windows. No code, UI, UX, business logic, persistence, sync, Watch algorithms, iOS algorithms, or experimental files were modified.

## A. Executive Summary

### Readiness Scores

| Dimension | Estimate | Notes |
|---|---:|---|
| Watch MAIN algorithm readiness | 90% | Strong validated pipeline, lifecycle debounce, time-weighted average, TTV/index, haptics and sync guards. One high lifecycle persistence issue remains. |
| Mathematical robustness | 92% | Finite guards, plausible bounds, 350 m hard cap, temperature bounds, monotonic elapsed clock, centralized unit conversions. |
| Safety algorithm confidence | 88% | Depth 35/38/40 m safety state, ascent-rate zones, haptic throttles and stale-depth banners are present; physical underwater QA still required. |
| Runtime/timer confidence | 91% | Runtime and stopwatch use elapsed clocks rather than simple counters; wall-clock skew is bounded. |
| Sync/export numerical confidence | 89% | Session validator, HMAC payloads, export-empty rejection and 40-log policy are present; invalid persisted queue/session filtering still deserves hardening. |
| Test coverage confidence | 88% | Watch algorithm tests cover many core paths; missing tests remain around finalization interruption, frozen-surface simulation and haptic delayed pulses. |

### Critical Blockers

No CRITICAL mathematical blocker was found for a non-certified informational companion app.

### Highest Priority Blocker

| ID | Severity | Topic |
|---|---|---|
| WATCHMATH-HIGH-001 | HIGH | Active dive draft can survive if the app is terminated during the 6-second exit GPS finalization window, allowing a finished dive to restore as active. |

### TestFlight Blockers

- Fix or explicitly mitigate `WATCHMATH-HIGH-001`.
- Run Watch algorithm tests on macOS/Xcode.
- Validate CoreMotion depth entitlement behavior on Apple Watch Ultra hardware.
- Validate GPS entry/exit capture on real device, including no-fix and fallback cases.
- Validate Watch-to-iPhone sync with physical paired devices.

### App Store Blockers

- Same TestFlight blockers above.
- Maintain explicit "NOT A DIVE COMPUTER" positioning.
- Keep TTV described as an informational index, not NDL/TTS/decompression guidance.
- Complete physical underwater QA for depth sensor, ascent warning, stale sensor and haptic behavior.

## B. Preflight and Files Inspected

### Branch and Repository

| Check | Result |
|---|---|
| Current branch | `main` |
| Local/remote divergence | `0 0` after fetch |
| Working tree before report write | clean |
| Watch target | `DIRDiving Watch App` |
| iOS scope | not audited except shared model/sync compatibility context |

### Experimental Exclusion

`project.yml` excludes the following from Watch MAIN:

- `Models/ExplorationModels.swift`
- `Models/BuddyAssistMessage.swift`
- `Models/BuddyPairingHandshake.swift`
- `Services/ExplorationStore.swift`
- `Services/BuddyAssistService.swift`
- `Services/BuddyAssistPeripheralService.swift`
- `Services/BuddyPairingKeyAgreement.swift`
- `Services/SecureBuddyStore.swift`
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`

### Primary Files Inspected

| Family | Files |
|---|---|
| Depth sensor and lifecycle | `Services/DiveManager.swift`, `Services/DepthSensorProvider.swift`, `Services/AppleDepthSensorProvider.swift`, `Services/MockDepthSensorProvider.swift`, `Services/SensorProviderFactory.swift`, `Utils/DepthSampleValidation.swift`, `Utils/DiveLifecycleAlgorithm.swift`, `Utils/DiveDepthMeasurementIngestion.swift`, `Utils/DiveAlgorithmConfiguration.swift` |
| Runtime/timers | `Services/DiveManager.swift`, `Utils/MonotonicElapsedClock.swift` |
| Depth statistics and TTV | `Utils/DiveAlgorithmConfiguration.swift`, `Models/DiveSample.swift`, `Models/DiveSession.swift`, `Utils/DiveSessionAlgorithmValidator.swift`, `Utils/DiveSessionMerge.swift` |
| Ascent rate and gauge | `Models/AscentRateLimits.swift`, `Models/AscentStatus.swift`, `Services/AscentRateSettingsStore.swift`, `Views/AscentGaugeView.swift`, `Views/AscentWarningView.swift`, `Views/AscentWarningBannerView.swift` |
| Alarms and haptics | `Services/HapticService.swift`, `Services/AscentSafetyHapticCoordinator.swift`, `Services/DepthLimitHapticCoordinator.swift`, `Views/AlarmSettingsView.swift`, `Views/DepthSafetyLiveViews.swift` |
| GPS | `Services/GPSManager.swift`, `Utils/GPSFallbackPolicy.swift`, `Utils/GPSConfirmationPresentation.swift`, `Models/GPSPoint.swift` |
| Compass/BUSSOLA | `Services/CompassManager.swift`, `Views/CompassView.swift` |
| Units/formatting | `Utils/DIRUnitPreference.swift`, `Utils/DIRUnitConversions.swift`, `Utils/WatchDepthFormatting.swift`, `Utils/Formatters.swift` |
| Logbook/export/sync | `Services/DiveLogStore.swift`, `Services/SubsurfaceExportService.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/WatchSyncService.swift`, `Services/WatchSyncAuth.swift`, `Utils/DiveLogbookPolicy.swift`, `Utils/DiveSessionPersistenceClass.swift` |
| Settings/shortcuts | `Views/SettingsView.swift`, `Views/AscentRateSettingsView.swift`, `Services/ActionButtonIntents.swift` |
| Tests | `Tests/WatchAlgorithmTests/*.swift` |

## C. Algorithm Inventory

### 1. Depth Sensor and Underwater State Algorithms

| Type/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `AppleDepthSensorProvider` | `CMWaterSubmersionMeasurement.depth`, `CMWaterTemperature` | depth measurement, temperature, submersion state | meters, Celsius | Apple API depth is converted to meters; timestamp is receipt `Date()` | feeds `DiveManager`; requires Apple underwater entitlement/hardware |
| `MockDepthSensorProvider` | timer | repeated 0 m, 20 C | meters, Celsius | simulation only | useful without entitlement, but exact repeated zero interacts with frozen detector |
| `DepthSampleValidationState.validate` | raw depth, timestamp, receivedAt, temp | `ValidatedDepthSample` with validity | meters, Celsius | finite depths; negative finite clamped to zero; max plausible 350 m | prevents invalid depth poisoning live metrics, logs and export |
| `DiveAlgorithm.sanitizedDepthMeters` | optional depth | finite nonnegative depth or nil | meters | rejects NaN/infinity and >350 m | reused by samples/session validation/export |
| `DiveAlgorithm.sanitizedTemperatureCelsius` | optional temp | temp or nil | Celsius | valid water temp -2...40 C | prevents implausible temp pollution |
| `DiveManager.evaluateDepthCallbackFreshness` | last accepted sample age | stale flags | seconds | silence >8 s is stale when depth automation active | UI stale banner and alarm suppression |

### 2. Dive Lifecycle Algorithms

| Type/function | Inputs | Outputs | Thresholds | Notes |
|---|---|---|---|---|
| `DiveLifecycleAlgorithm.evaluateStart` | valid depth samples | `.startDive` | depth >1.0 m, 2 samples | prevents one-sample accidental start |
| `DiveLifecycleAlgorithm.evaluateStop` | valid shallow sample | `.endDive` candidate | <=0.3 m | dwell-based end |
| `shouldEndAtSurface` | current depth and candidate date | Bool | <=0.3 m for 8 s | avoids shallow oscillation start/stop loops |
| `DiveManager.beginDiveIfNeeded` | manual/auto event | active dive state | one active dive only | captures entry GPS, resets metrics, starts runtime |
| `DiveManager.endDiveIfNeeded` | manual/auto end | finalization path | GPS capture 6 s | records exit GPS, finalizes log |

### 3. Time, Runtime and Stopwatch Algorithms

| Type/function | Inputs | Outputs | Robustness |
|---|---|---|---|
| `MonotonicElapsedClock.elapsed` | wall clock, system uptime | nondecreasing elapsed seconds | rejects large forward wall-clock skew and backward clock movement |
| `DiveManager.updateRuntimeFromClock` | active session anchor | runtime, TTV | uses clock elapsed, not `+= 1` counters |
| `DiveManager.startStopwatch/stopStopwatch/resetStopwatch` | user/App Intent actions | stopwatch state | persists accumulated time, startedAt and running flag |
| `Formatters.time` | TimeInterval | `MM:SS` or `HH:MM:SS` | integer truncation, nonnegative handled by callers |

### 4. Depth Statistics Algorithms

| Algorithm | Formula/behavior | Stored/displayed fields |
|---|---|---|
| Current depth | latest accepted validated sample | `currentDepthMeters` |
| Max depth | max accepted sample depth | `maxDepthMeters`, log max, export samples |
| Average depth | time-weighted integration over sorted sanitized samples; tail to end date if supplied | live `averageDepthMeters`, final `avgDepthMeters`, TTV input |
| Temperature summary | arithmetic over valid sample temperatures | avg/min/max water temp |
| Invalid samples | rejected before sample list | not stored/exported/synced |

### 5. Ascent-Rate Algorithms

| Algorithm | Inputs | Output | Rule |
|---|---|---|---|
| `DiveAlgorithm.ascentRateMetersPerMinute` | accepted sample window | ascent rate m/min | positive ascent only; descent/stationary -> 0; 5 s rolling window; minimum 1 s delta; capped at 90 m/min |
| `AscentRateLimits.limit(for:)` | depth | allowed m/min | >40 -> conservative 1; 40/30 upper-band inclusive; 20/6 boundaries as documented |
| `AscentStatus.zone` | current rate and depth limit | green/yellow/red | green <=70% limit; yellow <=100%; red >limit |
| `AscentGaugeView` | `AscentStatus` | visual gauge | displays in metric or imperial while internal math stays metric |

### 6. Alarm and Haptic Algorithms

| Component | Logic | Throttle |
|---|---|---|
| Ascent alarm | red zone triggers inline banner, blink and ascent haptic coordinator | repeat interval 1.75 s |
| Depth alarm | optional custom depth alarm if max depth is `>` threshold and not exceeded safety range | general alarm throttle 30 s |
| Runtime alarm | optional runtime alarm if runtime is `>` threshold minutes | general alarm throttle 30 s |
| Battery alarm | enabled by default, warns below configured percent | general alarm throttle 30 s |
| Depth-limit haptics | state-based caution/critical/exceeded haptics | 30/15/10 s by severity |
| Acknowledge | hides alarm warning and suppresses general alarm for 15 s | visual + haptic |

### 7. Depth Safety Algorithms

| State | Boundary | Behavior |
|---|---:|---|
| Normal | <35 m | normal display |
| Caution | >=35 m and <38 m | yellow warning |
| Critical | >=38 m and <40 m | orange warning |
| Exceeded | >=40 m | red warning, persisted `exceededSupportedDepthRange`, suppresses positive depth reinforcement |

### 8. TTV / Live Metric Algorithm

Current Watch MAIN semantics are explicit and consistent:

```text
TTV/index = timeWeightedAverageDepthMeters + runtimeMinutes
```

This is not NDL, TTS, decompression time or a certified dive-computer metric. It is persisted in `DiveSession.ttv`, recomputed in `DiveSessionMerge.preferred`, and shown in live and settings copy as an informational index.

### 9. Compass / Bearing Algorithms

| Component | Behavior |
---|---|
| Heading source | true heading if available, magnetic fallback otherwise |
| Normalization | `DiveAlgorithm.normalizedDegrees`, range `0..<360` |
| Bearing set | stores normalized current heading |
| Bearing delta | signed wraparound delta in `[-180, 180]` |
| Terminology | UI uses BUSSOLA, no COMPASSO regression found in inspected Watch MAIN files |

### 10. GPS Algorithms

| Component | Behavior |
---|---|
| `GPSFallbackPolicy` | accepts structurally valid point only if age <=300 s and accuracy <=50 m |
| `GPSManager.currentBestPoint` | returns usable fallback only and records quality |
| `captureBestEffortPoint` | starts updates, completes previous capture before replacement, waits up to 60 s clamped |
| Entry/exit source | `.fix`, `.fallback`, `.noFix` persisted and displayed |
| UI banner | green for fix, yellow for fallback, red for no fix |

### 11. Unit Conversion and Formatting

| Unit | Conversion |
---|---|
| meters <-> feet | `3.280839895` feet/m |
| Celsius <-> Fahrenheit | standard formula |
| bar <-> psi | `14.5037738` psi/bar |
| m/min <-> ft/min | uses meters/feet conversion |

Internal storage remains metric. Export remains metric by design.

### 12. Export, Sync and Persistence

| Family | Behavior |
---|---|
| Logbook persistence | JSON in documents with `.atomic` and complete file protection |
| Log cap | newest 40 sessions after local/cloud merge and tombstone filtering |
| Export | CSV rejects empty sample profile, sorts/sanitizes samples, writes protected temp file with opaque UUID name |
| Sync payload | HMAC, schema version, bundle check, issued-at skew, 512 KB payload cap, validator before sending/parsing |
| Tombstones | delete IDs persisted locally and via cloud key |

## D. Findings by Family

### WATCHMATH-HIGH-001 - Active dive draft can restore after termination during exit GPS finalization

**Family:** Dive lifecycle, persistence, GPS finalization
**File/function:** `Services/DiveManager.swift`, `endDiveIfNeeded`, `finalizeDive`, `persistActiveDiveDraft`, `restoreActiveDiveDraftIfAvailable`
**Severity:** HIGH
**Priority:** Must fix before internal/external TestFlight
**Estimated code impact:** small functional

**User impact:** If the app is terminated after `endDiveIfNeeded` starts but before the 6-second exit GPS capture completes, the final session may not be saved and the previous active-dive draft can still exist on disk. On next launch, `restoreActiveDiveDraftIfAvailable` can restore that already-ended dive as active.

**Safety impact:** Medium. It can mislead the user into seeing a stale active dive or duplicate/incorrect log lifecycle state. It does not change depth math directly, but it affects runtime/log trust.

**Mathematical explanation:** `endDiveIfNeeded` captures `end = Date()`, sets `isDiveActive = false`, clears in-memory session state, then waits for `gpsManager.captureBestEffortPoint(for: 6)` before calling `finalizeDive`, where `clearActiveDiveDraft()` is finally executed. If process termination occurs in that window, the active-dive draft remains valid for up to 12 hours.

**Proposed solution:** Persist an explicit finalizing state, or clear/convert the active draft before the asynchronous GPS wait and finalize with the best available exit GPS immediately, updating exit GPS later only if safe. Add tests that simulate termination during finalization and verify no active dive restores.

### WATCHMATH-MED-002 - Frozen-depth detection can create false warnings for exact stable surface/simulator readings

**Family:** Depth sensor / simulator fallback
**File/function:** `Utils/DepthSampleValidation.swift`, `Services/MockDepthSensorProvider.swift`, `Services/DiveManager.processDepthMeasurement`
**Severity:** MEDIUM
**Priority:** Must fix before broad TestFlight if simulation mode is used by testers
**Estimated code impact:** small functional

**User impact:** The default simulation provider emits exact `0 m` every second. After 30 seconds, the frozen-depth detector can classify the stream as `.frozen`, causing a "sensor stopped" style error while the user is simply waiting at the surface.

**Safety impact:** Low to medium. On real sensors, noise usually prevents exact 0.001 m equality for 30 seconds, but a very stable sensor or simulator can trigger a false stale/frozen warning.

**Mathematical explanation:** Frozen detection uses a 0.001 m tolerance and a 30 s window. This is mathematically useful for a stuck sensor but too strict for exact simulated zero and possibly for long flat stable depth.

**Proposed solution:** Gate frozen detection by source/state, suppress it for inactive surface simulation, or require active sensor-owned dive plus additional evidence before showing user-facing frozen warnings. Add pre-dive simulation and stable-depth tests.

### WATCHMATH-MED-003 - Invalid legacy sessions can remain visible after load even if export/sync validators reject them later

**Family:** Persistence / replay consistency
**File/function:** `Services/DiveLogStore.swift`, `Utils/DiveLogbookPolicy.swift`, `Utils/DiveSessionPersistenceClass.swift`
**Severity:** MEDIUM
**Priority:** Must fix before external TestFlight
**Estimated code impact:** small functional

**User impact:** Locally persisted legacy/corrupted sessions are normalized and capped during load, but the load path does not explicitly filter every session through `DiveSessionPersistenceClass.classify`. Invalid sessions can be visible in the log until export/sync paths reject them.

**Safety impact:** Low. This affects logbook trust and export consistency more than live safety.

**Mathematical explanation:** `add` validates through persistence classification, but `loadLocalSessions` maps decoded sessions through `DiveSessionMerge.preferred` and then policy-normalizes. Some invalid no-sample or inconsistent metadata shapes can survive display while later validators classify them invalid.

**Proposed solution:** Filter or quarantine invalid sessions during load/reload, set `loadErrorMessage`, and add tests for corrupted persisted JSON sessions.

### WATCHMATH-LOW-004 - Delayed depth-limit secondary haptics can fire after state changes

**Family:** Haptic timing / depth safety
**File/function:** `Services/DepthLimitHapticCoordinator.swift`, `playHaptic` delayed closures
**Severity:** LOW
**Priority:** Must fix before App Store polish
**Estimated code impact:** small functional

**User impact:** On first transition to critical/exceeded, a secondary delayed haptic can play after 0.25-0.35 s. The delayed closure checks whether haptics are enabled, but not whether the depth safety state is still the same.

**Safety impact:** Low. This can produce an extra warning pulse after the condition has already cleared.

**Mathematical explanation:** The haptic schedule is time-based but not token/state-bound. Rapid threshold crossing and immediate return can leave a pending delayed pulse.

**Proposed solution:** Store a state token or transition generation and verify it before playing delayed pulses. Add tests for rapid 38 m/40 m threshold crossing and return.

### WATCHMATH-LOW-005 - `DiveAlgorithmSelfCheck` has stale ascent-limit expectation

**Family:** Internal self-check / maintainability
**File/function:** `Utils/DiveAlgorithmSelfCheck.swift`, `ascentLimitFailures`
**Severity:** LOW
**Priority:** Must fix before App Store or remove from build surface
**Estimated code impact:** copy-only or small functional

**User impact:** None in normal app flow because this helper is not user-facing.

**Safety impact:** Low. A developer running the helper can receive a false failure because it expects `45 m -> 10 m/min`, while current release-hard logic and tests use conservative `>40 m -> 1 m/min`.

**Mathematical explanation:** `AscentRateLimits.standard.limit(for: 45)` returns 1 m/min by design, but the self-check still expects 10.

**Proposed solution:** Update the self-check expected case to match `DiveAlgorithmTests.testAscentLimitBandsAndZoneBoundaries`, or remove the helper if XCTest is the canonical validation path.

### WATCHMATH-INFO-006 - Alarm exact-boundary behavior uses strict greater-than

**Family:** Alarm logic
**File/function:** `Services/DiveManager.evaluateDepthAlarm`, `evaluateRuntimeAlarms`
**Severity:** INFO
**Priority:** Document and test
**Estimated code impact:** tests/copy-only unless product wants `>=`

**User impact:** Depth and runtime alarms trigger above the configured threshold, not exactly at it.

**Safety impact:** Low if this is intentional, because labels use `>` semantics.

**Mathematical explanation:** `maxDepthMeters > threshold` and `runtime > threshold * 60` are strict comparisons. This is mathematically consistent with current message copy, but boundary tests should lock it.

**Proposed solution:** Add explicit tests for threshold exactly reached, just below, and just above. Change only if product wants inclusive threshold semantics.

### WATCHMATH-INFO-007 - Mission Mode is correctly non-mathematical

**Family:** Simulator/real-device behavior assumptions
**File/function:** `Utils/MissionModeRuntimeProfile.swift`, `Services/DiveManager.swift`
**Severity:** INFO
**Priority:** Keep documented
**Estimated code impact:** none

Mission Mode only affects visual/decorative runtime profile flags and lifecycle activation source. Existing tests verify it does not alter TTV, average depth, depth safety thresholds or ascent-rate formulas.

## E. Edge Case Matrix

| Edge case | Expected behavior | Observed from code | Status |
|---|---|---|---|
| depth nil | reject sample as missing | `.missing` validity | covered |
| depth NaN/infinity | reject | `.nonFinite` | covered |
| depth <0 finite | clamp to 0 | `max(0, rawDepthMeters)` | covered |
| depth 0 while inactive | no auto start | lifecycle stays `.none` | covered |
| depth 0 repeated 30 s | no user-facing false error preferred | can become `.frozen` | finding |
| depth 0.9 | no start | below >1.0 threshold | covered |
| depth 1.1 once | no start | requires two samples | covered |
| sustained >1.0 | start | `.startDive` after two samples | covered |
| surface <=0.3 briefly | no end | dwell required | covered |
| surface <=0.3 for 8 s | end | `.endDive` | covered |
| app killed during active dive | restore draft | draft restore implemented | covered conceptually |
| app killed during finalization | should not restore active dive | draft can survive | finding |
| stable depth | ascent 0 | descent/stationary -> 0 | covered |
| fast ascent | red zone | over-limit red | covered |
| >40 m depth | exceeded safety and conservative ascent limit | state `.exceeded`, limit 1 if >40 | covered |
| exactly 40 m | exceeded safety, ascent limit 10 | current convention | covered |
| invalid temperature | rejected | temp sanitizer nil | covered |
| GPS stale | no usable fallback | `GPSFallbackQuality.stale` | covered |
| GPS poor accuracy | no usable fallback | `lowAccuracy` | covered |
| empty export | rejected | nil CSV/write URL | covered |
| invalid sync session | rejected | validator -> invalidSession | covered |
| haptics disabled | no haptic playback | haptic guards exist | partially covered |
| delayed haptic after condition clears | should not play stale pulse | state not rechecked | finding |
| exact alarm threshold | product-dependent | strict `>` | needs explicit test |

## F. Unit and Integration Test Plan

| Priority | Feature | Input | Expected output | Pass/fail criteria |
|---|---|---|---|---|
| P1 | Finalization persistence | start dive, trigger end, terminate before GPS completion | no active draft restore; session finalized or safely pending | no phantom active dive on relaunch |
| P1 | Active draft restore | app relaunch during active dive | active dive restores with samples and runtime | runtime, avg/max and samples consistent |
| P2 | Stable surface simulation | 0 m every second for >30 s while inactive | no scary frozen sensor warning | pre-dive UI remains truthful |
| P2 | Stable active depth | exact same valid depth for >30 s | policy-defined result | no false alarm if product suppresses frozen stable-depth |
| P2 | Load corrupted session | invalid persisted JSON session | filtered/quarantined with load error | not exportable/syncable/visible as normal |
| P2 | Depth alarm boundary | threshold, threshold +/- 0.1 | current strict `>` behavior locked | exact threshold does not fire unless product changes |
| P2 | Runtime alarm boundary | threshold seconds, +1 second | current strict `>` behavior locked | no off-by-one ambiguity |
| P2 | Depth haptic delayed pulse | cross 38/40 then immediately return normal | no stale delayed haptic after state clear | pulse token/state verified |
| P2 | Haptics disabled under active ascent alarm | disable then re-enable | disabled suppresses; re-enable resumes only if still over limit | no duplicate haptic spam |
| P2 | GPS entry/exit no fix | no location authorization/fix | `.noFix`, red banner, no crash | saved log has no invalid GPS |
| P2 | GPS fallback | fresh accurate point, stale point, low-accuracy point | usable/stale/lowAccuracy | matches `GPSFallbackPolicy` |
| P2 | Sync invalid payload | valid HMAC but corrupt session | parse rejects before log insertion | no invalid log |
| P3 | Export sorted profile | out-of-order samples | sorted nonnegative elapsed seconds | CSV monotonic |
| P3 | Unit conversions | metric/imperial round trips | values within tolerance | no display/storage mismatch |
| P3 | Compass wraparound | 350 -> 10 and 10 -> 350 | +20 and -20 | signed delta correct |

## G. Physical Watch Ultra Test Plan

| Priority | Scenario | Expected result |
|---|---|---|
| P1 | Real Apple Watch Ultra depth entitlement present | `AppleDepthSensorProvider.isAvailable` true in automatic/apple mode | no simulation fallback |
| P1 | No entitlement / unsupported device | simulation/manual fallback clearly shown | no misleading depth automation claim |
| P1 | Real submersion start | automatic start only after sustained >1 m | no start at shallow splashes |
| P1 | Real surfacing | end only after sustained <=0.3 m dwell | no rapid stop/start loop |
| P1 | Long flat depth | no false frozen warning from normal sensor behavior | stable reading handled truthfully |
| P1 | Fast ascent drill in controlled conditions | ascent banner + haptic fire | red warning, no full-screen takeover |
| P2 | 35/38/40 m boundary simulation or controlled bench feed | caution/critical/exceeded states | correct visual and haptic cadence |
| P2 | GPS start at surface | fix/fallback/no-fix banner truthful | entry GPS stored with correct source |
| P2 | GPS exit at surface | fix/fallback/no-fix banner truthful | exit GPS stored with correct source |
| P2 | Watch-to-iPhone sync | valid completed log syncs | no duplicates, ack handling correct |
| P2 | Offline sync queue | dive completed while iPhone unavailable | pending queue persists and retries |

## H. Underwater Validation Plan

1. Dry-run all settings before water: units, haptics, alarms, ascent limits, legal/safety copy.
2. Surface GPS fix test: wait for good fix, start/end manual no-depth log, verify stored entry/exit.
3. Shallow water test below 1 m: verify no automatic dive start.
4. Controlled descent past 1 m: verify auto start after two accepted samples.
5. Stable-depth hold: verify no false frozen/stale warnings on real sensor.
6. Slow ascent inside configured limits: verify green/yellow zones and no red haptics.
7. Simulated rapid ascent or bench-fed rapid sample changes: verify red warning and haptics.
8. Surface dwell: verify automatic end after dwell, no duplicate finalization.
9. App interruption during active dive: relaunch and confirm draft restore.
10. App interruption during finalization window: verify fixed behavior once `WATCHMATH-HIGH-001` is remediated.
11. Sync completed log to iPhone: verify max/avg depth, runtime, TTV, GPS and samples match.

## I. Prioritized Roadmap

### 1. Must Fix Before Compile/Use

No compile/use blocker was found by static inspection. Xcode build was not run on Windows.

### 2. Must Fix Before Internal TestFlight

1. `WATCHMATH-HIGH-001`: finalization-window draft restore risk.
2. Run `xcodegen generate` and Watch algorithm tests on macOS.
3. Validate AppleDepthSensorProvider availability on Watch Ultra with entitlement.

### 3. Must Fix Before External TestFlight

1. `WATCHMATH-MED-002`: frozen-depth false warning in simulation/stable zero path.
2. `WATCHMATH-MED-003`: filter/quarantine invalid loaded legacy sessions.
3. Add boundary tests for alarm strict `>` thresholds.
4. Add state-token tests for delayed depth-limit haptics.

### 4. Must Fix Before App Store

1. Complete underwater physical validation plan.
2. Complete paired Watch/iPhone sync validation on real devices.
3. Update or remove stale `DiveAlgorithmSelfCheck`.
4. Keep marketing and in-app copy clear that DIR DIVING is not a certified dive computer.

### 5. Post-Release Improvements

1. Add richer diagnostics for depth sensor unavailable/stale/frozen distinctions.
2. Add export round-trip verification with external tools.
3. Add optional debug telemetry for GPS fallback quality transitions.
4. Add additional App Intent tests for hardware action workflows.

## J. Final Verdict

### Mathematically Ready?

Mostly, but not 100%. Core formulas and validators are strong: validated depth pipeline, lifecycle debounce, time-weighted average depth, TTV/index, ascent-rate windows, safety states, unit conversions, export rejection and sync validation are all present. The finalization-window draft issue must be fixed before a full release-hard claim.

### Safe Enough for Internal Test?

Yes, for controlled internal testing with known caveats. Internal testers must know the app is non-certified and that physical Watch Ultra validation is still required.

### Ready for TestFlight?

Not yet for broad TestFlight. Fix `WATCHMATH-HIGH-001`, run macOS build/tests, and validate CoreMotion depth behavior on physical Watch Ultra first.

### Ready for App Store?

No. App Store readiness requires physical underwater validation, paired-device sync validation, completion of P1/P2 fixes, and continued non-certified safety positioning.

### What Blocks 100% Algorithmic Readiness?

1. Finalization-window persistence bug.
2. Frozen-depth false-positive policy for simulation/stable readings.
3. Invalid persisted-session filtering on load.
4. Physical Watch Ultra depth/GPS/sync validation.
5. macOS build and XCTest execution.
