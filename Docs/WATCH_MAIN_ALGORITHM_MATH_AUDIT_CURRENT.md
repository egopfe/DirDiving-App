# DIR DIVING Watch MAIN Algorithm and Mathematical Functions Audit - Current

> **Indice:** [`INDEX.md`](INDEX.md) · **Parallelo iOS:** [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) · **PR:** [#10](https://github.com/egopfe/DirDiving-App/pull/10)

Date: 2026-05-31
Branch audited: `main`
Remote: `https://github.com/egopfe/DirDiving-App.git`
Scope: Apple Watch MAIN target only, `DIRDiving Watch App`
Mode: read-only source audit; no Swift/source behavior changed

## Phase 0 - Preflight

- Current branch before audit: `main`.
- Remote sync before audit: local `main` and `origin/main` were `0 / 0` ahead/behind.
- Initial working tree before report creation: clean.
- Stable Watch target: `DIRDiving Watch App`.
- Product position preserved: non-certified informational diving companion, not a primary dive computer, not NDL/TTS/decompression logic.

### Project Membership And Exclusions

`project.yml` includes these Watch target source roots: `App`, `Models`, `Services`, `Views`, `Utils`, and `Resources`.

The Watch MAIN target explicitly excludes:

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

Conclusion: Snorkeling, Apnea, Buddy, Explore Lab, and experimental feature files are excluded from the Watch MAIN build.

### Watch MAIN Swift Files Included In Build

`App/DIRAppLanguage.swift`, `App/DIRDivingApp.swift`, `App/LegalAcceptanceStore.swift`, `Models/AppPage.swift`, `Models/AscentRateLimits.swift`, `Models/AscentStatus.swift`, `Models/DiveSample.swift`, `Models/DiveSession.swift`, `Models/GPSPoint.swift`, `Services/ActionButtonIntents.swift`, `Services/AppNavigationStore.swift`, `Services/AscentRateSettingsStore.swift`, `Services/AscentSafetyHapticCoordinator.swift`, `Services/CloudSyncStore.swift`, `Services/CompassManager.swift`, `Services/DepthLimitHapticCoordinator.swift`, `Services/DiveLogStore.swift`, `Services/DiveManager.swift`, `Services/GPSManager.swift`, `Services/HapticService.swift`, `Services/SubsurfaceExportService.swift`, `Services/UserImageStore.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/WatchSyncAuth.swift`, `Services/WatchSyncService.swift`, `Utils/CloudSyncNotifications.swift`, `Utils/CompanionDisclaimerAcceptance.swift`, `Utils/DepthSafetyConfiguration.swift`, `Utils/DepthSafetySelfCheck.swift`, `Utils/DepthSampleValidation.swift`, `Utils/DIRUnitConversions.swift`, `Utils/DIRUnitPreference.swift`, `Utils/DiveAlgorithmConfiguration.swift`, `Utils/DiveAlgorithmSelfCheck.swift`, `Utils/DiveLifecycleAlgorithm.swift`, `Utils/DiveLogbookPolicy.swift`, `Utils/DiveSessionAlgorithmValidator.swift`, `Utils/DiveSessionMerge.swift`, `Utils/Formatters.swift`, `Utils/GeoMath.swift`, `Utils/GPSFallbackPolicy.swift`, `Utils/LegalDisclaimerScrollGate.swift`, `Utils/MissionModeRuntimeProfile.swift`, `Utils/WatchAlarmDefaults.swift`, `Utils/WatchDepthFormatting.swift`, `Utils/WatchDetailBackButton.swift`, `Utils/WatchModeSelectionPreferences.swift`, `Utils/WatchSubscreenBackToolbar.swift`, `Utils/WatchSyncKeys.swift`, `Utils/WatchSyncNotifications.swift`, `Views/AlarmSettingsView.swift`, `Views/AscentGaugeView.swift`, `Views/AscentRateSettingsView.swift`, `Views/AscentWarningBannerView.swift`, `Views/AscentWarningView.swift`, `Views/CompassView.swift`, `Views/ContentView.swift`, `Views/DepthSafetyLiveViews.swift`, `Views/DiveDetailView.swift`, `Views/DiveLiveView.swift`, `Views/DiveLogListView.swift`, `Views/DiveUIComponents.swift`, `Views/ExportView.swift`, `Views/InfoView.swift`, `Views/LaunchCompanionDisclaimerOverlay.swift`, `Views/MissionModeIndicatorView.swift`, `Views/ModeSelectionView.swift`, `Views/SettingsView.swift`, `Views/UserImagesView.swift`, `Views/WatchLegalOnboardingView.swift`.

### Files Inspected For This Audit

Primary algorithm files inspected: `Services/DiveManager.swift`, `Services/HapticService.swift`, `Services/AscentSafetyHapticCoordinator.swift`, `Services/DepthLimitHapticCoordinator.swift`, `Services/GPSManager.swift`, `Services/CompassManager.swift`, `Services/WatchSyncService.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/DiveLogStore.swift`, `Services/SubsurfaceExportService.swift`, `Services/AscentRateSettingsStore.swift`, `Models/DiveSession.swift`, `Models/DiveSample.swift`, `Models/GPSPoint.swift`, `Models/AscentRateLimits.swift`, `Models/AscentStatus.swift`, `Utils/DiveAlgorithmConfiguration.swift`, `Utils/DepthSampleValidation.swift`, `Utils/DiveLifecycleAlgorithm.swift`, `Utils/DepthSafetyConfiguration.swift`, `Utils/DIRUnitConversions.swift`, `Utils/DIRUnitPreference.swift`, `Utils/WatchDepthFormatting.swift`, `Utils/Formatters.swift`, `Utils/GPSFallbackPolicy.swift`, `Utils/DiveLogbookPolicy.swift`, `Utils/DiveSessionMerge.swift`, `Utils/DiveSessionAlgorithmValidator.swift`, `Views/DiveLiveView.swift`, `Views/AscentGaugeView.swift`, `Views/AscentWarningView.swift`, `Views/AscentWarningBannerView.swift`, `Views/DepthSafetyLiveViews.swift`, `Views/AlarmSettingsView.swift`, `Views/AscentRateSettingsView.swift`, `Views/CompassView.swift`, `Views/DiveDetailView.swift`, `Views/DiveLogListView.swift`, `Views/SettingsView.swift`, `Views/InfoView.swift`, `Services/ActionButtonIntents.swift`, `App/Info.plist`, `Config/DIRDiving.entitlements`, and Watch algorithm tests.

Narrow companion compatibility files inspected only for Watch sync numerical consistency: `iOSApp/Services/WatchDiveSyncCodec.swift`, `iOSApp/Utils/DiveSessionAlgorithmValidator.swift`, `iOSApp/Utils/DiveProfileMath.swift`, `iOSApp/Utils/IOSAlgorithmConfiguration.swift`, `iOSApp/Models/DiveSession.swift`, `iOSApp/Models/DiveSample.swift`, and `iOSApp/Models/GPSPoint.swift`.

## A. Executive Summary

Readiness estimates from static audit:

| Area | Score | Reason |
|---|---:|---|
| Watch MAIN algorithm readiness | 82% | Core formulas are centralized, deterministic, and unit-tested, but runtime sensor-loss and sync edge cases remain. |
| Mathematical robustness | 86% | Depth sanitization, average depth, ascent rate, TTV/index, unit conversions, compass normalization, and merge recomputation are generally strong. |
| Safety algorithm confidence | 78% | Depth thresholds and ascent alarms exist, but silent depth callback loss can leave stale live readings without a watchdog warning. |
| Persistence/export/sync consistency | 74% | Local Watch logs normalize values, but no-depth/manual and long-duration sessions can persist locally while export or iOS sync reject them. |
| Test readiness | 76% | Good pure-unit coverage exists, but physical Watch Ultra, underwater, background, haptic, and WatchConnectivity validation are still required. |

### Critical Blockers

No code-path issue reached `CRITICAL` in this static audit because the app is positioned as non-certified and already gates use with legal/safety disclaimers. However, one `HIGH` safety issue should be treated as a must-fix before broad testing.

### TestFlight Blockers

- `WMATH-HIGH-001`: No active watchdog for complete depth-callback silence during an active dive.
- `WMATH-HIGH-002`: GPS no-fix confirmation can be shown with green success styling and "saved" title.
- `WMATH-HIGH-003`: Watch manual/no-depth sessions are valid locally but can be rejected by iOS sync.

### App Store Blockers

- All TestFlight blockers above.
- Physical Apple Watch Ultra validation of CoreMotion underwater callbacks, haptic cadence, depth operating-range behavior, GPS entry/exit capture, background/foreground recovery, and WatchConnectivity signed sync.
- Evidence that simulator-only behavior is not being used to claim depth or pressure readiness.

## B. Algorithm Inventory

### 1. Depth Sensor / Underwater State Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveManager.configureSubmersion` | `CMWaterSubmersionManager.waterSubmersionAvailable` | `isDepthAutomationAvailable`, delegate setup | n/a | watchOS reports availability honestly; entitlement/provisioning are valid | UI shows sensor availability; automatic depth lifecycle depends on this. |
| `DiveManager.processDepthMeasurement` | Raw depth optional, timestamp, temperature | Validated sample or error message | meters, Celsius | Depth from CoreMotion is convertible to meters; timestamp default is receipt time | Feeds live depth, lifecycle, samples, alarms, draft persistence. |
| `DepthSampleValidationState.validate` | Optional raw depth, timestamp, receivedAt, optional temperature | `ValidatedDepthSample` | meters, Celsius, seconds | Valid sample must be finite, <= 350 m, timestamp fresh, transition plausible | Rejects missing, nonfinite, stale, frozen, spike, out-of-range. |
| `DiveAlgorithm.sanitizedDepthMeters` | Optional depth | Nonnegative depth or nil | meters | Negative finite readings represent near-zero noise | Used by storage, merge, export, validation. |
| `DiveAlgorithm.sanitizedTemperatureCelsius` | Optional temperature | Temperature or nil | Celsius | Plausible water range is -2 C...40 C | Used by live samples, session summary, merge, validation. |

### 2. Dive Lifecycle Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveLifecycleAlgorithm.evaluate` | Valid sample, active/manual flags, submersion observed | `.none`, `.startDive`, `.endDive` | meters, seconds | Auto start requires validated depth > 1.0 m, 2 samples; stop <= 0.3 m for 8 s | Protects from shallow/noisy starts and rapid surface oscillation. |
| `DiveManager.beginDiveIfNeeded` | Manual/automatic start | Active session state, entry GPS capture | Date, GPS | GPS is surface-only; session start is current `Date()` | Starts timers, haptics, active draft. |
| `DiveManager.endDiveIfNeeded` | Manual/automatic stop | Final GPS capture and session finalization | Date, GPS | End time is current `Date()`; best-effort GPS window is 6 s | Saves log, clears draft, syncs through log store. |
| `DiveManager.restoreActiveDiveDraftIfAvailable` | Draft JSON | Restored active dive | seconds | Draft is usable for 12 h | Protects app relaunch during active dive. |

### 3. Time / Runtime / Stopwatch Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveManager.updateRuntimeFromClock` | `sessionStart`, current `Date()` | `runtime`, live `ttv` | seconds | Wall clock moves monotonically enough for runtime | Drives runtime display and runtime alarm. |
| `DiveManager.startRuntimeTimer` | 1 s repeating timer | periodic runtime/alarm eval | seconds | Timer can pause in background but Date catch-up recovers elapsed wall time | Good for app suspension, weaker for clock changes. |
| `DiveManager.updateStopwatchFromClock` | accumulated time, startedAt `Date()` | `stopwatchTime` | seconds | Wall clock is stable | Stopwatch persists through relaunch via UserDefaults. |
| `Formatters.time` | `TimeInterval` | `MM:SS` or `HH:MM:SS` | seconds | Caller passes finite nonnegative interval | Used in live, log, sync summaries. |

### 4. Depth Statistics Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveAlgorithm.timeWeightedAverageDepth` | Sanitized samples, optional endDate | Average depth | meters | Samples sorted by timestamp; last sample can extend to endDate | Used live, final session, merge, tests. |
| `DiveManager.addSample` | Validated depth sample | current, average, max depth | meters | Sample transition is plausible | Updates live UI, safety state, alarms, draft. |
| `DiveManager.finalizeDive` | start/end, GPS, samples | `DiveSession` summary | meters, seconds, Celsius | Sanitized samples represent the profile | Saves max/avg/temp/TTV/exceeded flag. |
| `DiveSessionMerge.preferred` | Local and remote sessions | normalized session | meters, seconds | One canonical sample set is safer than unioning divergent profiles | Recomputes derived values before save/sync. |

### 5. Ascent-Rate Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveAlgorithm.ascentRateMetersPerMinute` | Samples and current sample | Nonnegative ascent rate | m/min | Ascent is depth decrease; descent is 0; 5 s window; min 1 s delta | Feeds gauge, warning banner, haptics. |
| `AscentRateLimits.limit` | Current depth | Rate limit | m/min | Depth bands are upper-band inclusive at 40, 30, 20, 6 m; > 40 m is conservative | User-configurable and persisted. |
| `AscentStatus.make` | Rate, depth, limits | green/yellow/red zone | m/min | Green <= 70% limit, yellow <= limit, red > limit | Used by UI and alarm state. |
| `AscentRateSettingsStore` | User limits, iCloud/defaults | normalized limits | m/min | Limits clamped to 0.5...20 m/min | Persists and reloads local/cloud settings. |

### 6. Alarm Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveManager.evaluateDepthAlarm` | max depth, threshold, setting | alarm banner/haptic | meters | Copy says `>`; exact threshold is not an alarm | Suppressed when depth safety is `.exceeded`. |
| `DiveManager.evaluateRuntimeAlarms` | runtime, battery, thresholds | alarm banner/haptic | minutes, percent | Copy says `>` time and `<` battery | Runtime/battery checks run from runtime timer. |
| `DiveManager.triggerAlarm` | message, last alarm date | banner, haptic, blink | seconds | 30 s per alarm cooldown, 15 s after dismiss | Handles non-ascent visual/haptic alarm. |
| `DiveManager.updateAscentRate` | current sample | ascent status, blink/haptic | m/min | Red zone means over-limit | Ascent alarm repeats while over limit. |

### 7. Depth Safety Limit Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DepthSafetyState.from` | depth | normal/caution/critical/exceeded | meters | 35 m caution, 38 m critical, 40 m exceeded | Drives banners, readout style, haptic escalation. |
| `DiveManager.updateDepthSafety` | current depth | state, exceeded flag, haptics | meters | Any sample >= 40 m persists exceeded flag | Saved in `DiveSession.exceededSupportedDepthRange`. |
| `DepthLimitHapticCoordinator.handle` | depth, haptic preference | throttled haptic pattern | seconds | caution 30 s, critical 15 s, exceeded 10 s repeats | Does not positively reinforce beyond supported range. |

### 8. TTV / Live Metric Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DiveAlgorithm.ttvIndex` | average depth, duration | informational index | meters + minutes | TTV means average depth plus runtime minutes | Not NDL, TTS, deco, or gas logic. |
| `DiveManager.updateRuntimeFromClock` | average depth, runtime | live TTV | index | Average depth has been updated by samples | Live UI and final session use same formula. |
| `DiveLiveView.ttvRuntimePanel` | live TTV/runtime | visible panel and a11y hint | index, time | Copy describes TTV as informational | Good semantic guard against decompression interpretation. |

### 9. Compass / Bearing Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `CompassManager.didUpdateHeading` | `CLHeading` true/magnetic heading | normalized heading | degrees | true heading preferred when available; magnetic fallback otherwise | UI heading and bearing actions. |
| `DiveAlgorithm.normalizedDegrees` | any finite degrees | 0..<360 | degrees | Nonfinite -> 0 | Used by heading, bearing, cardinal. |
| `DiveAlgorithm.signedBearingDeltaDegrees` | heading and bearing | -180...180 delta | degrees | shortest signed turn | Used by compass UI. |
| `CompassManager.cardinal` | heading | N/NE/E/SE/S/SW/W/NW | degrees | 8-point compass with 22.5 degree offset | Display only. |

### 10. GPS Entry/Exit Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `GPSFallbackPolicy.assess` | last GPS point | usable/stale/lowAccuracy/unavailable | seconds, meters | Usable point age <= 300 s, accuracy <= 50 m | Prevents stale/poor GPS from being used as fix. |
| `GPSManager.currentBestPoint` | lastPoint | usable GPS point or nil | lat/lon | Only structurally valid points can pass | Entry/exit fallback source. |
| `GPSManager.captureBestEffortPoint` | capture window | best usable point | seconds, meters | 0...60 s window; 6 s used by dive lifecycle | Improves entry/exit surface metadata. |
| `DiveManager.showGPSConfirmation` | start/end confirmation | transient banner | GPS | Banner is UI only; session stores point/source | See finding on no-fix styling. |

### 11. Unit Conversion / Formatting Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `DIRUnitConversions` | metric/imperial values | converted values | m/ft, C/F, bar/psi, m/min/ft/min | Canonical internal storage remains metric | Central conversion helpers. |
| `DIRUnitPreference` | stored preference | display values and unit labels | metric/imperial | Invalid storage falls back to metric | Watch presentation only; sync publishes units. |
| `WatchDepthFormatting.display` | meters and units | one-decimal display | m/ft | Caller gives finite values | Used live, alarm, log, compass. |
| `Formatters.one/zero/time` | number/time | strings | various | Caller sanitizes nonfinite values | Display formatting only. |

### 12. Haptic Timing / Throttle Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `HapticService.warnIfNeeded` | generic warning | failure haptic | seconds | 2 s throttle | Used by depth/runtime/battery alarms. |
| `HapticService.ascentAlarmTriggered/repeat` | over-limit state | failure haptic loop | seconds | repeat interval 1.75 s | Used by ascent coordinator. |
| `AscentSafetyHapticCoordinator` | over-limit boolean | repeat task start/clear | seconds | One active repeat task at a time | Decouples haptics from SwiftUI rendering. |
| `DepthLimitHapticCoordinator` | depth state | state-specific pattern | seconds | repeated thresholds are throttled | Depth safety haptics. |

### 13. Export / Sync / Persistence Algorithms

| File/function | Inputs | Outputs | Units | Assumptions | Persistence/UI/safety |
|---|---|---|---|---|---|
| `SubsurfaceExportService.makeCSV` | `DiveSession` | CSV rows | seconds, meters, Celsius, GPS | Empty profiles are not exportable | Export remains metric. |
| `DiveLogStore.add/addFromCompanion` | session | normalized log store | session fields | Merge normalization is enough before save | Saves local file, iCloud KVS, outbound sync. |
| `WatchDiveSyncCodec.makePayload/parsePayload` | session/payload | signed transport/session | encoded JSON | HMAC v2 shared secret; 512 KB max; 20,000 samples; 1 h skew | Sync numerical validation. |
| `WatchSyncService` | pending sessions, WCSession state | queued/sent/ack/imported state | counts, dates | Peer secret must exist for signed payload | Persists pending queue in Data Protection file. |

## C. Findings By Family

### WMATH-HIGH-001 - No Watchdog For Complete Depth Callback Silence

- Family: Depth sensor / underwater state / runtime consistency
- File/function: `Services/DiveManager.swift`, depth callback path and runtime timer
- Severity: HIGH
- User impact: During an active dive, if depth callbacks stop entirely, the live depth can remain at the last displayed value while runtime continues.
- Safety impact: A stale depth display can be mistaken for current depth. Existing stale/frozen checks only run when a measurement arrives; they do not detect total callback silence.
- Mathematical explanation: `DepthSampleValidationState.validate` rejects stale timestamps and exact frozen repeated samples, but it is called only from `processDepthMeasurement`. No timer compares `Date()` to the last accepted sample timestamp during active dives.
- Proposed solution: Add a source freshness watchdog driven by the runtime timer. If `isDiveActive` and latest sample age exceeds a threshold, mark depth stale/unavailable, show a persistent visual warning, suppress positive reinforcement, and avoid treating the last depth as fresh. Preserve existing depth, lifecycle, TTV, and safety semantics.
- Priority: Must fix before external TestFlight.
- Estimated code impact: small functional.

### WMATH-HIGH-002 - GPS No-Fix Confirmation Can Look Like Green Success

- Family: GPS entry/exit algorithms
- File/function: `Views/DiveLiveView.swift` GPS confirmation helpers, `Services/DiveManager.showGPSConfirmation`
- Severity: HIGH
- User impact: If no GPS point is captured, the banner can still use the non-fallback path, which maps to green success styling and the "GPS START/END SAVED" title while detail says unavailable.
- Safety impact: Users may believe a surface entry/exit fix was saved when it was not.
- Mathematical explanation: `DiveGPSConfirmation` carries `point` and `fallback`. Color is chosen only from `fallback`; `point == nil && fallback == false` becomes green. No-fix is a third state but UI currently compresses it into success/fallback.
- Proposed solution: Derive GPS banner state from `(point, fallback)` with three outcomes: fix = green, fallback last-known = yellow, no-fix = yellow/red and explicit no-fix title. Do not change GPS capture logic.
- Priority: Must fix before internal/external TestFlight.
- Estimated code impact: UI-only/copy-only.

### WMATH-HIGH-003 - Manual No-Depth Watch Sessions Can Fail iOS Companion Sync

- Family: Sync / serialization numerical consistency
- File/function: `Services/WatchDiveSyncCodec.swift`, `Services/DiveLogStore.swift`; companion compatibility in `iOSApp/Services/WatchDiveSyncCodec.swift`
- Severity: HIGH
- User impact: A manual session created when depth automation is unavailable can be saved on Watch as runtime/GPS-only, but iOS sync validation rejects empty sample profiles.
- Safety impact: Low direct safety risk, but high trust risk because the companion app can miss a log the Watch says exists.
- Mathematical explanation: Watch `DiveSessionAlgorithmValidator` permits zero samples; Watch export intentionally rejects empty profiles; iOS `WatchDiveSyncCodec.validateForSync` calls iOS validation with `allowEmptySamples: false`.
- Proposed solution: Choose one explicit policy and align both sides. Either allow manual no-depth sessions in iOS sync with clear `isManual/no-depth` semantics, or mark them local-only on Watch with truthful sync/export copy. Do not invent depth samples.
- Priority: Must fix before external TestFlight if manual fallback is advertised.
- Estimated code impact: small functional across Watch/iOS sync policy.

### WMATH-MED-004 - Auto-Start Sample Timestamp Can Precede `sessionStart`

- Family: Dive lifecycle / persistence / replay consistency
- File/function: `Services/DiveManager.processDepthMeasurement`, `beginDiveIfNeeded`, `DiveSessionMerge.preferred`
- Severity: MEDIUM
- User impact: The sample that triggers automatic start can be timestamped just before `sessionStart`, then later be dropped by merge filtering that requires sample timestamp >= startDate.
- Safety impact: Low to medium. It can understate early max/average depth for very short dives or sensor-sparse starts.
- Mathematical explanation: The validated sample timestamp is created before `beginDiveIfNeeded()` sets `sessionStart = Date()`. Later normalization filters samples outside `[startDate, endDate]`.
- Proposed solution: For automatic starts, set session start from the triggering validated sample timestamp or allow a small start epsilon during normalization. Preserve current start threshold and debounce semantics.
- Priority: Must fix before external TestFlight.
- Estimated code impact: small functional.

### WMATH-MED-005 - Local Persistence Can Accept Sessions That Sync/Export Reject

- Family: Persistence / export / sync consistency
- File/function: `Services/DiveLogStore.add`, `Utils/DiveSessionAlgorithmValidator`, `Services/SubsurfaceExportService`, `Services/WatchDiveSyncCodec`
- Severity: MEDIUM
- User impact: A session can be visible in Watch logs but fail export or sync later, especially empty/no-depth profiles or sessions beyond validator bounds.
- Safety impact: Low direct safety risk; medium data integrity risk.
- Mathematical explanation: `DiveLogStore.add` normalizes with `DiveSessionMerge` but does not call the validator before save. Export rejects empty profiles. Sync validates and may reject sessions after local persistence.
- Proposed solution: Add explicit local validation classes: full profile, manual no-depth profile, and invalid/unsyncable. Surface the class in UI and sync status.
- Priority: Must fix before external TestFlight.
- Estimated code impact: small functional.

### WMATH-MED-006 - Export CSV Time Origin Is First Sample, Not Session Start

- Family: Export calculations
- File/function: `Services/SubsurfaceExportService.makeCSV`
- Severity: MEDIUM
- User impact: CSV `time_seconds` starts at the first exportable sample even if the session started earlier.
- Safety impact: Low, but downstream analysis can differ from Watch log duration.
- Mathematical explanation: `firstTimestamp = samples.first?.timestamp`; every row uses `sample.timestamp - firstTimestamp`. Session `durationSeconds` and UI duration use `endDate - startDate`.
- Proposed solution: If Subsurface format allows, use `session.startDate` as time zero and keep nonnegative clamping. If the first-sample origin is intentional, document it and show export duration scope.
- Priority: Must fix or document before external TestFlight.
- Estimated code impact: small functional or copy-only.

### WMATH-MED-007 - Runtime And Stopwatch Use Wall Clock, Not Monotonic Time

- Family: Time/runtime/stopwatch algorithms
- File/function: `Services/DiveManager.updateRuntimeFromClock`, `updateStopwatchFromClock`
- Severity: MEDIUM
- User impact: A system clock adjustment can make runtime/stopwatch jump forward or clamp backward to zero.
- Safety impact: Medium for runtime alarms because a backward clock jump can delay a time alarm.
- Mathematical explanation: Runtime is `Date().timeIntervalSince(start)`. This is good for suspension catch-up but is not monotonic.
- Proposed solution: Keep Date-based persistence for relaunch, but add monotonic elapsed tracking during active process lifetime and reconcile conservatively on resume.
- Priority: Must fix before App Store; acceptable for controlled internal QA with known limitation.
- Estimated code impact: medium refactor.

### WMATH-MED-008 - Non-Ascent Alarm Blink Can Be Cleared By Normal Ascent Updates

- Family: Alarm logic / visual consistency
- File/function: `Services/DiveManager.triggerAlarm`, `updateAscentRate`, `stopBlinking`
- Severity: MEDIUM
- User impact: A depth/runtime/battery alarm banner can remain visible while the red blink stops after a normal ascent update.
- Safety impact: Low to medium. The banner remains, but visual urgency can be reduced unintentionally.
- Mathematical explanation: `triggerAlarm` starts one shared blink timer. `updateAscentRate` calls `stopBlinking()` whenever ascent is not over limit, without checking whether `alarmWarningMessage` is still active.
- Proposed solution: Track blink sources separately or keep blink active while any alarm source is active.
- Priority: Must fix before external TestFlight.
- Estimated code impact: small functional.

### WMATH-MED-009 - Haptics Re-Enabled During Active Ascent Alarm May Stay Silent

- Family: Haptic timing / throttle
- File/function: `Services/HapticService.swift`, `Services/AscentSafetyHapticCoordinator.swift`
- Severity: MEDIUM
- User impact: If haptics are disabled when ascent over-limit begins and later re-enabled while still over-limit, repeat haptics may not start until the condition clears and re-enters.
- Safety impact: Medium, because the user expects haptics to resume when enabled.
- Mathematical explanation: `HapticService.ascentAlarmTriggered` returns before setting `ascentAlarmSessionActive` when haptics are disabled, while `AscentSafetyHapticCoordinator` still marks its own alarm active and will not restart.
- Proposed solution: Decouple coordinator alarm state from haptic preference state, or have repeat calls initialize `ascentAlarmSessionActive` when haptics become enabled.
- Priority: Must fix before external TestFlight.
- Estimated code impact: small functional.

### WMATH-MED-010 - Ascent Gauge Visual Bands Do Not Match `AscentStatus` Zone Boundaries

- Family: Ascent gauge and warning thresholds
- File/function: `Views/AscentGaugeView.swift`, `Models/AscentStatus.swift`
- Severity: MEDIUM
- User impact: The gauge can color the pointer red near 75% of limit even though algorithmic red/over-limit starts only above 100% of limit.
- Safety impact: Low to medium. It is conservative visually, but can make red not mean the same thing across gauge, banner, and haptics.
- Mathematical explanation: `AscentStatus` uses green <= 70%, yellow <= 100%, red > 100%. `AscentGaugeView.pointerColor` uses green < 50%, yellow 50...75%, red >= 75%, and bar colors are quartered.
- Proposed solution: Align gauge color thresholds to `AscentStatus.zone`, or label gauge colors as relative load rather than alarm state.
- Priority: Must fix before external TestFlight.
- Estimated code impact: UI-only.

### WMATH-LOW-011 - Ascent Warning Banner Always Displays m/min

- Family: Unit conversion / formatter consistency
- File/function: `Views/AscentWarningBannerView.swift`, `Views/DiveLiveView.swift`
- Severity: LOW
- User impact: In imperial mode the gauge uses ft/min but the ascent alarm banner still formats the speed in m/min.
- Safety impact: Low, because internal thresholding remains metric and correct.
- Mathematical explanation: Banner receives only meters/minute and localizes `ascent_alarm_speed_unit` as `m/min`; it has no unit preference input.
- Proposed solution: Pass `DIRUnitPreference` into the banner and format using `ascentRateDisplay`, preserving metric internal storage.
- Priority: Must fix before App Store polish.
- Estimated code impact: UI-only.

### WMATH-LOW-012 - Delayed Depth-Limit Haptic Pulses Do Not Recheck Preference

- Family: Haptic timing / throttle
- File/function: `Services/DepthLimitHapticCoordinator.playHaptic`
- Severity: LOW
- User impact: If haptics are disabled immediately after a critical/exceeded transition, a scheduled second pulse can still play.
- Safety impact: Low; annoying more than dangerous.
- Mathematical explanation: `DispatchQueue.main.asyncAfter` captures `device` and does not re-read `hapticsEnabled`.
- Proposed solution: Route delayed pulses through `HapticService` or re-check preference before playback.
- Priority: Post-internal TestFlight.
- Estimated code impact: small functional.

### WMATH-INFO-013 - Temperature Samples Use Last Received Temperature Callback

- Family: Depth sensor / temperature aggregation
- File/function: `Services/DiveManager.didUpdate measurement: CMWaterTemperature`, `processDepthMeasurement`
- Severity: INFO
- User impact: A depth sample can be paired with the latest stored temperature rather than a timestamp-matched temperature measurement.
- Safety impact: Low. Temperature is logged/displayed, not used for safety calculations.
- Mathematical explanation: CoreMotion depth and temperature callbacks arrive separately. The code stores `currentTemperatureCelsius` and passes it into later depth samples.
- Proposed solution: For higher fidelity, track temperature timestamp/freshness and mark stale temperature as nil. Current behavior is acceptable if documented.
- Priority: Post-release improvement.
- Estimated code impact: small functional.

### WMATH-INFO-014 - Above-40 m Ascent Limit Policy Is Conservative But Boundary Copy Needs Care

- Family: Depth safety / ascent thresholds
- File/function: `Models/AscentRateLimits.swift`, `Utils/DepthSafetyConfiguration.swift`
- Severity: INFO
- User impact: At exactly 40.0 m, depth safety is `.exceeded` while ascent band policy still uses 10 m/min. Above 40.0 m, limit becomes conservative 1 m/min.
- Safety impact: Low because exceeded-depth warnings are active at 40.0 m.
- Mathematical explanation: This is documented in code/tests as upper-band inclusive at 40.0 m and conservative above 40.0 m.
- Proposed solution: No algorithm change unless product/safety policy decides 40.0 m should also use the exceeded conservative ascent limit. Keep copy explicit that 40.0 m is unsupported range.
- Priority: Monitor.
- Estimated code impact: copy-only if needed.

## D. Edge Case Matrix

Static audit status: "Observed" means behavior was derived from code. "Unit covered" means existing `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift` covers the pure helper behavior. No Xcode test run was executed in this Windows/Codex environment.

| Edge case | Expected behavior | Observed from code | Status |
|---|---|---|---|
| depth = nil | Reject sample; no math update | `.missing`, no sample | Unit covered |
| depth = NaN | Reject sample | `.nonFinite`, no sample | Unit covered |
| depth = +infinity | Reject sample | `.nonFinite`, no sample | Unit covered |
| depth < 0 | Clamp finite negative to 0 | `max(0, rawDepth)` | Unit covered |
| depth = 0 | Valid zero; no auto start | Valid sample, lifecycle no start | Unit covered |
| just below 1.0 m | No auto start | `>` threshold required | Unit covered |
| just above 1.0 m | Start only after 2 validated samples | start candidate count >= 2 | Unit covered |
| sudden depth jump | Reject if > 90 m/min equivalent | `.spikeRejected` | Unit covered |
| sensor sends stale timestamp | Reject if older than 8 s or >1 s future | `.stale` | Unit covered |
| sensor stops sending entirely | Show stale warning and do not trust depth | No active watchdog found | Finding HIGH-001 |
| stable identical depth >30 s | Frozen rejection | exact within 0.001 m after 30 s | Unit covered; physical QA needed |
| manual dive sensor unavailable | Runtime/GPS-only session possible | local log can save empty samples | Finding HIGH-003/MED-005 |
| automatic start sample timestamp | Included in saved profile | Can be earlier than sessionStart and later dropped | Finding MED-004 |
| auto surface <=0.3 m | End after 8 s dwell | lifecycle candidate and task | Unit covered |
| rapid surface/submerge | Cancel/end based on samples/events | candidate cleared when depth >0.3 | Unit covered; device QA needed |
| runtime at 0 | Display 00:00 | timer max(0) | Observed |
| runtime > 60 min | HH:MM:SS | `Formatters.time` supports hours | Observed |
| runtime > 24 h | Display hours; sync validator max 24 h | local save can exceed validator | Finding MED-005/MED-007 |
| system clock change | Runtime should not jump dangerously | Date-based runtime can jump/clamp | Finding MED-007 |
| no samples | Average 0; export should fail truthfully | average 0; export nil; sync mismatch with iOS | Finding HIGH-003 |
| one sample | Average = sample depth | helper returns sample depth | Unit covered |
| all zero samples | Average 0; no max | helper returns 0 | Observed |
| invalid samples in merge | Sanitize/reject | invalid depth dropped by sanitizer; validator rejects corruption | Unit covered |
| stationary depth | Ascent rate 0 | returns 0 | Unit covered |
| descending | Ascent rate 0 | max(0, rate) | Unit covered |
| slow ascent | Green/yellow/red by configured limit | `AscentStatus` correct | Unit covered |
| fast ascent | Red, banner, haptic | status red when > limit | Unit covered; haptic QA needed |
| noisy samples | Spike rejection + 5 s window | present | Unit covered partially |
| imperial depth display | Convert m to ft | `DIRUnitPreference.depthDisplay` | Unit covered |
| imperial ascent gauge | Convert m/min to ft/min | gauge does; banner does not | Finding LOW-011 |
| depth alarm exactly threshold | No alarm because copy says `>` | uses `maxDepthMeters > threshold` | Observed |
| depth alarm above threshold | Alarm unless exceeded range | triggerAlarm | Observed |
| runtime alarm exactly threshold | No alarm because copy says `>` | uses `runtime > threshold*60` | Observed |
| battery exactly threshold | No alarm because copy says `<` | uses `< threshold` | Observed |
| acknowledged alarm persists | Dismiss suppresses retrigger for 15 s | `lastAlarmDismissDate` | Observed |
| multiple alarms simultaneous | Shared message/blink | last trigger wins; blink source shared | Finding MED-008 |
| 34.9 m | normal | mapping helper | Unit/self-check |
| 35.0 m | caution | mapping helper | Unit/self-check |
| 38.0 m | critical | mapping helper | Unit/self-check |
| 40.0 m | exceeded | mapping helper | Unit covered |
| after returning below 40 m | state returns lower but exceeded session flag persists | code persists flag | Observed |
| TTV at zero depth/runtime | 0 | formula safe clamps | Unit covered |
| TTV active start | avg + runtime minutes | formula applied | Unit covered |
| TTV after surfacing | final session recomputes with duration and avg | observed | Observed |
| TTV presented as decompression | Should not | copy/a11y says not NDL/TTS/deco | Observed |
| heading 0/359 crossing | Normalize and delta shortest path | helper handles wrap | Unit covered |
| nil/unavailable heading | Status message; previous heading remains 0/default | observed | Device QA needed |
| invalid heading | message "unavailable"; no update | nonfinite guard | Observed |
| GPS fix | Store point/source fix | best-effort path | Device QA needed |
| GPS no fix | Truthful no-fix, no green success | detail says unavailable but title/color can be success | Finding HIGH-002 |
| stale GPS | Do not return point | policy rejects >300 s | Unit covered |
| low accuracy GPS | Do not return point | policy rejects >50 m | Unit covered |
| denied location | UI status denied; no GPS point | observed | Simulator/device QA needed |
| empty export | Fail, no header-only CSV | returns nil | Unit covered |
| export timing | Match session duration semantics | first sample origin, not startDate | Finding MED-006 |
| sync duplicate | Suppress/ignore imported IDs | implemented | Observed |
| tombstones | Delete and broadcast UUID strings | implemented | Observed |

## E. Unit / Integration Test Plan

| Priority | Feature | Input | Expected output | Pass/fail criteria |
|---|---|---|---|---|
| P0 | Depth silence watchdog | Active dive, last sample age > stale threshold, no callbacks | stale depth warning; no fresh-depth positive state | UI state and published stale flag appear within threshold. |
| P0 | GPS no-fix banner | `DiveGPSConfirmation.start(point:nil,fallback:false)` | no-fix copy and non-green styling | Snapshot/assert color/title state not success. |
| P0 | Manual no-depth sync policy | Watch `DiveSession(samples: [])` | explicit accepted manual sync or explicit local-only status | Watch and iOS tests agree. |
| P0 | Auto-start sample retention | triggering sample timestamp just before sessionStart | sample retained or startDate equals sample timestamp | normalized saved session includes trigger sample. |
| P1 | Export origin | session start at t0, first sample t5 | chosen policy verified | CSV either starts at t0 or docs/test assert first-sample origin. |
| P1 | Runtime monotonicity | injected clock backward/forward | conservative elapsed behavior | no negative or delayed alarm beyond policy. |
| P1 | Alarm blink source separation | runtime alarm active, normal ascent sample arrives | alarm blink remains active | `redWarningBlink` source remains until alarm dismissed/cleared. |
| P1 | Haptics re-enable during ascent alarm | haptics off, overlimit, haptics on | haptic repeat starts/resumes | repeat method called after preference enable. |
| P1 | Gauge zone alignment | 60%, 80%, 100%, 101% of limit | visual color agrees with algorithmic zone or documented scale | tests verify threshold mapping. |
| P2 | Imperial ascent banner | units imperial, rate 3 m/min | shows about 9.8 ft/min | no hard-coded m/min in imperial mode. |
| P2 | Long duration session | 24 h + 1 s | local validation prevents or labels unsyncable | no silent sync failure later. |
| P2 | Temperature freshness | temp callback old, depth new | temp omitted or marked stale | no stale temp is presented as current. |
| P2 | Delayed haptic preference | disable during delayed second pulse | second pulse suppressed | haptic preference respected at playback time. |

Recommended integration tests:

- Watch lifecycle with mocked depth callback stream: no samples, delayed samples, repeated exact samples, gaps, out-of-order timestamps, and sudden jumps.
- Watch log save -> merge -> export -> sync payload round-trip for normal profile, no-depth manual profile, max-depth exceeded profile, GPS no-fix profile, and long-duration profile.
- Watch/iOS sync compatibility tests using identical sample JSON fixtures on both sides.
- UI state tests for GPS banner state machine and alarm blink sources.

## F. Physical Watch Ultra Test Plan

| Priority | Test | Procedure | Expected result | Pass/fail |
|---|---|---|---|---|
| P0 | Entitlement and depth callback | Install TestFlight/dev build on Apple Watch Ultra, submerge in controlled shallow water | `isDepthAutomationAvailable` true and depth callbacks arrive | Fail if unavailable without truthful UI. |
| P0 | Depth callback loss | Start active dive, interrupt sensor path/background/relaunch scenarios | stale warning appears if callbacks stop | Fail if depth freezes silently. |
| P0 | Auto start threshold | Lower watch through 0.9, 1.1 m with controlled timing | no start below 1.0 m; start after 2 valid samples above | Fail if one noisy sample starts dive. |
| P0 | Surface stop dwell | Surface to <=0.3 m | auto end only after sustained 8 s dwell | Fail if rapid bobbing ends dive. |
| P0 | GPS no-fix | Deny location or test shielded sky | no green saved banner | Fail if success styling appears. |
| P1 | Entry/exit GPS fix | Start/end at open sky | fix source `.fix`, coords stored and visible | Fail if UI/log/export mismatch. |
| P1 | Haptic matrix | haptics on/off, re-enable during alarms | haptics respect preference and resume when enabled | Fail if missed/extra pulses occur. |
| P1 | Ascent warning cadence | Simulated/controlled ascent profile if safe | banner and haptics match over-limit state | Fail if haptic loop depends on view render. |
| P1 | Depth safety thresholds | Controlled sensor/simulator rig if available for 35/38/40 m equivalent | caution/critical/exceeded states exactly at thresholds | Fail if thresholds drift. |
| P2 | Background/relaunch draft | Start dive, background/relaunch within 12 h | active draft restored with correct runtime/sample stats | Fail if data loss or duplicate session. |
| P2 | Battery alarm | Lower battery or mock if possible | alarm below threshold only | Fail if stale/false alarm. |
| P2 | WatchConnectivity | Pair with iPhone app, sync normal and manual sessions | status truthful; no silent failures | Fail if Watch says delivered but iOS rejects. |

## G. Underwater Validation Plan

Only perform with certified redundant instruments and trained divers. DIR DIVING must not be used as the primary instrument.

1. Pool shallow-water validation, 0...3 m:
   - Verify no start below 1.0 m.
   - Verify start after validated samples above 1.0 m.
   - Verify average/max depth against certified reference within acceptable sensor tolerance.
   - Verify surface dwell stop at <=0.3 m after 8 s.

2. Controlled descent/ascent validation:
   - Hold stable depths for 30+ s to check frozen-depth false positives.
   - Use slow ascent profiles below limits and confirm no red alarm.
   - Use safe controlled ascent segments near configured thresholds and confirm exact green/yellow/red behavior.

3. Depth safety validation:
   - Treat 35/38/40 m tests as simulated or chamber/rig tests unless certified operational constraints permit.
   - Confirm warnings at 35.0, 38.0, and 40.0 m.
   - Confirm exceeded flag persists in log after returning shallower.

4. GPS surface metadata:
   - Start and end at surface with clear sky, poor sky, denied permission, and no-fix conditions.
   - Confirm banners, log detail, export CSV, and iOS companion agree.

5. Interruption validation:
   - App background/foreground while active.
   - Watch screen off/on.
   - iPhone unavailable then reachable.
   - WatchConnectivity delayed transfer and retry.

## H. Prioritized Roadmap

### 1. Must Fix Before Compile/Use

No compile-use blocker was found in static source review. A real Xcode build on macOS is still required because this environment did not run Xcode.

### 2. Must Fix Before Internal TestFlight

- `WMATH-HIGH-002`: GPS no-fix banner must not look like green success.
- Add a documented manual/no-depth sync policy so testers know what should happen.
- Run Watch algorithm unit tests on macOS/Xcode.

### 3. Must Fix Before External TestFlight

- `WMATH-HIGH-001`: depth callback silence watchdog.
- `WMATH-HIGH-003`: Watch/iOS sync alignment for manual/no-depth sessions.
- `WMATH-MED-004`: auto-start sample retention.
- `WMATH-MED-005`: local persistence versus sync/export validation alignment.
- `WMATH-MED-006`: export time-origin policy.
- `WMATH-MED-008`: independent alarm blink sources.
- `WMATH-MED-009`: haptics re-enable during active ascent alarm.
- `WMATH-MED-010`: ascent gauge visual threshold alignment.

### 4. Must Fix Before App Store

- `WMATH-MED-007`: monotonic runtime strategy or an explicit tested mitigation.
- `WMATH-LOW-011`: imperial ascent warning banner formatting.
- `WMATH-LOW-012`: delayed haptic preference re-check.
- Physical Watch Ultra validation evidence for CoreMotion depth, haptics, GPS, background/relaunch, and sync.
- App Store review copy must continue to say non-certified, not a dive computer, GPS surface-only, TTV informational.

### 5. Post-Release Improvements

- Timestamp/freshness tracking for water temperature.
- Optional richer GPS quality display in logs.
- Additional property-based tests for sample streams and merge policies.
- Dedicated instrumentation logs for sensor callback age, without logging private depth/GPS content.

## I. Final Verdict

### Mathematically Ready?

Partially. The pure mathematical helpers are mostly ready: depth sanitization, time-weighted average depth, TTV/index, ascent-rate calculation, ascent limit normalization, unit conversions, compass normalization, GPS fallback policy, and merge recomputation are coherent and already have useful unit coverage.

The runtime system is not at 100% algorithmic readiness because sensor silence, sync acceptance, export origin, and wall-clock assumptions still create edge-case inconsistencies.

### Safe Enough For Internal Test?

Yes, for controlled internal testing only, with certified redundant instruments and explicit tester notes. Internal testers must know that the app is not a dive computer, no-fix GPS feedback needs verification, and depth callback loss is a known high-priority audit item.

### Ready For TestFlight?

Not for broad/external TestFlight yet. The GPS no-fix feedback and depth-callback silence watchdog should be fixed first. Watch/iOS sync policy for manual/no-depth sessions should also be resolved before inviting testers who will rely on the companion app for log review.

### Ready For App Store?

No. App Store readiness requires the high/medium findings above, macOS/Xcode build and tests, and physical Apple Watch Ultra validation.

### What Blocks 100% Algorithmic Readiness?

- Lack of active freshness watchdog when depth callbacks stop entirely.
- GPS no-fix UI state compressed into the success/fallback path.
- Watch local log semantics not fully aligned with export and iOS sync validation.
- Auto-start timestamp ordering can exclude the first triggering sample.
- Wall-clock runtime/stopwatch assumptions under system time changes.
- Alarm/haptic source state not fully independent across simultaneous or preference-changing conditions.
- Physical-device validation is still required for CoreMotion underwater behavior, haptics, GPS, WatchConnectivity, and app lifecycle recovery.

