# DIR DIVING Watch MAIN Algorithm Release Hardening - Final

Date: 2026-05-27  
Branch: main  
Scope: Apple Watch MAIN algorithms only  
Product position: non-certified informational diving companion

## Summary

This document records the final Watch MAIN algorithm hardening pass after `DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`.

No UI, UX, graphics, color, layout, navigation, icon, animation, Apnea, Snorkeling, Buddy Assist, Exploration, iOS Companion, or experimental-branch behavior was intentionally changed.

DIR DIVING remains explicitly non-certified and informational. These changes improve deterministic math, validation, persistence integrity, and testability; they do not make the app a certified dive computer.

## P2 Fixes Completed

### Logbook 40-Session Cap

The Watch logbook cap is centralized in `DiveLogbookPolicy.maxSessions`.

Policy:

- Tombstone filtering is applied first.
- Local and cloud sessions are normalized and merged by session ID.
- Sessions are sorted deterministically by newest `startDate` first.
- Ties are resolved by UUID string for stable ordering.
- Only the newest 40 sessions are retained.

Applied to:

- `DiveLogStore.load()`
- `DiveLogStore.reloadFromPersistence()`
- `DiveLogStore.add(_:)`
- `DiveLogStore.addFromCompanion(_:)`

### Plausible Water Temperature Bounds

Canonical water temperature remains Celsius.

Accepted finite range:

- minimum: -2 C
- maximum: 40 C

Rejected:

- `nil`
- `NaN`
- infinity
- finite values below -2 C
- finite values above 40 C

Rejected temperatures do not feed:

- live sample temperature
- saved average temperature
- saved min/max temperature
- session validation
- merge recomputation
- export samples
- sync/import validation

## P3 Fixes Completed Or Locked As Intentional Policy

### Empty Export Policy

All public Watch export paths reject empty profiles.

`SubsurfaceExportService.makeCSV(for:)` now returns `nil` when there are no exportable samples. `writeCSV(for:)` also returns `nil` for empty profiles and cannot report a header-only CSV as success.

The valid CSV column format is unchanged:

```text
time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon
```

### Ascent Band Boundary Convention

The Watch MAIN ascent-rate band convention is intentionally upper-band inclusive:

- depth > 40 m: conservative 1 m/min
- 40.00 m and 30.00..<40.00 m: 10 m/min
- 20.00..<30.00 m: 5 m/min
- 6.00..<20.00 m: 3 m/min
- 0.00..<6.00 m: 1 m/min

Values just shallower than a boundary move to the slower band. Depth above 40 m uses conservative exceeded-range behavior.

No extra ascent-band hysteresis state was added in this pass. The existing release-hardening approach uses:

- validated depth samples
- spike rejection
- frozen/stale detection
- a 5 s rolling ascent-rate calculation window
- green/yellow/red zone thresholds
- conservative above-40 m behavior

This keeps the gauge deterministic and avoids adding hidden state that could obscure the current safety band.

### GPS Fallback Quality Policy

GPS fallback quality is now explicit and bounded.

Accepted fallback point:

- structurally valid latitude/longitude/accuracy
- age <= 300 s
- horizontal accuracy <= 50 m

Quality states:

- `unavailable`
- `usable`
- `stale`
- `lowAccuracy`

`GPSManager.currentBestPoint()` only returns a usable point. Best-effort GPS capture seeds and updates from usable points only. A stale or low-accuracy point is internally classified without UI redesign.

### Unit Conversion Centralization

Watch unit constants and conversion helpers are centralized in `DIRUnitConversions`.

Central conversions:

- meters to feet
- feet to meters
- Celsius to Fahrenheit
- Fahrenheit to Celsius
- bar to psi
- psi to bar
- m/min to ft/min
- ft/min to m/min

Display formatting and ascent-rate settings now use the canonical helper while preserving current values and formatting.

### Merge Sample Policy

The Watch MAIN merge policy intentionally keeps one canonical sample set rather than unioning partial profiles.

Reason:

- A timestamp-unioned profile can mix samples from partially divergent sessions and create an apparently precise profile that no single device actually recorded.
- The current policy favors mathematical consistency and deterministic derived values.
- After the canonical sample set is selected, duration, max depth, time-weighted average depth, TTV/index, temperature summary, GPS, and exceeded-depth flag are recomputed or normalized.

Complementary sample union can be reconsidered later only if explicit source/conflict metadata is added.

## Tests Added Or Extended

The Watch algorithm test target now covers:

- shallow samples below 1 m do not start an automatic dive
- manual lifecycle does not auto-end before sensor-owned submersion
- ascent limits at 40.01, 40.00, 30.00, 29.99, 20.00, 19.99, 6.00, 5.99, and 0.00 m
- temperature acceptance at -2 C and 40 C
- NaN/infinity temperature rejection
- finite below/above plausible temperature rejection
- average/min/max temperature ignoring rejected outliers
- unit conversion round trips
- empty CSV export rejected through `writeCSV`
- empty CSV export rejected through `makeCSV`
- valid CSV still preserves columns and monotonic nonnegative elapsed seconds
- session validation rejects implausible finite temperatures
- logbook policy keeps newest 40 sessions after normalization
- local/cloud merged sessions over cap drop oldest deterministically
- GPS fallback policy rejects unavailable, stale, low-accuracy, and structurally invalid points
- GPS fallback policy accepts fresh accurate points
- merge keeps canonical sample set and recomputes derived values

Existing tests continue to cover:

- missing, NaN, infinity, negative, stale, frozen, spike, and out-of-range depth handling
- lifecycle start debounce and surface dwell
- time-weighted average depth
- TTV/index
- ascent stationary/descent/ascent behavior
- compass normalization and wraparound
- corrupted session rejection
- impossible depth transition rejection
- merge recomputation

## Remaining Physical-Device Validation

The following cannot be fully proven by pure unit tests and remains required on Apple Watch Ultra hardware:

- CoreMotion underwater depth callback timing
- water temperature callback timing and sensor freshness
- watchOS background/foreground interruption behavior
- active-dive draft restore during real app lifecycle transitions
- GPS availability before and after water entry
- WatchConnectivity activation and signed sync transport on paired devices
- actual haptic playback, throttle feel, and disabled-haptics behavior
- water submersion entitlement behavior in TestFlight/App Store builds

## Final Assumptions

- Canonical storage remains metric.
- Watch MAIN export remains metric CSV.
- The 40 m supported-depth boundary is a safety/operating-range boundary, not an encouraged target.
- TTV/index remains an informational index: `time-weighted average depth + runtime minutes`.
- DIR DIVING is not a certified dive computer and must not be used as a primary life-support or decompression instrument.

