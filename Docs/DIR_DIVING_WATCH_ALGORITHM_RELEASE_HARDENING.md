# DIR DIVING Watch Algorithm Release Hardening

Date: 2026-05-26

Scope: Apple Watch MAIN branch algorithmic hardening only. The app remains a non-certified informational diving companion and is not a certified dive computer.

## What Changed

- Added a canonical validated depth sample pipeline with explicit validity states: `valid`, `missing`, `stale`, `frozen`, `spikeRejected`, `nonFinite`, `outOfRange`.
- Added a pure automatic dive lifecycle algorithm using validated depth samples, `> 1.0 m` start threshold, start debounce and sustained surface dwell before automatic end.
- Centralized time-weighted average depth, TTV/index, ascent-rate, compass normalization and depth/sample sanitization helpers.
- Moved ascent warning haptic escalation out of `DiveLiveView` and into a manager-owned safety haptic coordinator.
- Reworked runtime and stopwatch state to derive from stored timestamps instead of relying on timer `+= 1` counters.
- Hardened logbook merge, pending sync queue normalization, Watch sync validation and Subsurface CSV export.
- Added Watch algorithm XCTest coverage for validator, lifecycle, math, ascent bands, temperature conversion, compass wraparound, export, sync validation and merge consistency.

## P0 Issues Fixed

- Automatic dive start now requires validated measured depth above `1.0 m` with debounce; CoreMotion submersion events no longer bypass the measured-depth rule.
- Depth values now pass through a central validator before they can affect live depth, max depth, average depth, ascent rate, TTV/index, safety state, logs, sync or export.
- Invalid depth states are quarantined and surfaced internally without silently reusing stale `currentDepthMeters`.
- Ascent warning haptic escalation is coordinated outside the SwiftUI view layer, so it does not depend on `DiveLiveView` being rendered.

## P1 Issues Fixed

- Average depth is time-weighted from validated samples and reused consistently for live display, saved sessions and TTV/index input.
- Ascent rate is calculated from validated samples using a rolling time window and rejects divide-by-zero, duplicate timestamp amplification, NaN and infinity.
- Runtime and stopwatch display are derived from timestamps and persisted state, reducing drift and lifecycle divergence.
- Live temperature display uses canonical Celsius storage plus `DIRUnitPreference` conversion for Celsius/Fahrenheit presentation.
- Compass heading and bearing values are normalized to `0..<360`, with robust wraparound delta calculation.
- Ascent-rate limits use one shared `AscentRateLimits` source of truth; `AscentStatus` depends on it.
- Depth above the documented supported range is treated conservatively through the existing depth safety state and the ascent limit falls back to the most restrictive surface-band value.

## Final Algorithmic Assumptions

- Canonical depth storage is meters.
- Canonical temperature storage is Celsius.
- TTV remains an informational DIR DIVING index: `timeWeightedAverageDepthMeters + runtimeMinutes`. It is not decompression, no-stop, time-to-surface or life-support logic.
- Automatic start threshold is strictly greater than `1.0 m`.
- Automatic surface/end threshold is below start threshold and requires dwell time to avoid shallow oscillation.
- Export remains metric CSV for Subsurface compatibility.
- The Watch water-depth entitlement and physical sensor behavior must still be validated on Apple Watch Ultra hardware.

## Remaining Limitations

- This hardening does not certify DIR DIVING as a dive computer.
- Frozen-depth detection is conservative and intended to quarantine exact repeated sensor values after a timeout; real hardware QA must confirm it does not over-trigger during stable hovering.
- XCTest files are added, but full build/test execution requires macOS with Xcode/XcodeGen and a watchOS-capable simulator or device.
- Device validation is still required for CoreMotion water submersion, haptics cadence, GPS best-effort capture and WatchConnectivity behavior.

## Test Coverage Summary

Added `DIRDiving Watch Algorithm Tests` with coverage for:

- finite, missing, NaN, infinity, negative, stale, frozen and spike depth samples
- automatic start debounce and surface dwell stop
- no start below `1.0 m`
- time-weighted average depth
- zero/one-sample average behavior
- TTV/index recomputation
- ascent rate for stationary, descent and ascent cases
- ascent band and green/yellow/red classification boundaries
- depth > 40 m exceeded-state behavior
- Celsius/Fahrenheit conversion and invalid temperature rejection
- compass normalization and bearing wraparound
- empty export rejection and sorted export rows
- corrupted imported session rejection
- merge-derived value recomputation

## Release-Hard Verdict

Within the Apple Watch MAIN codebase, the P0 and P1 algorithmic issues from `CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md` have been addressed in code. The branch is algorithmically release-hard for internal validation, subject to successful Xcode build, XCTest execution and Apple Watch Ultra device QA.
