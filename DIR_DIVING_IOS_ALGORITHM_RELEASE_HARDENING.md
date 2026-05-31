# DIR DIVING iOS Algorithm Release Hardening

Date: 2026-05-27
Branch scope: `main-iOS`
Target: iOS Companion MAIN app only

## Summary

This pass upgrades the iOS Companion MAIN branch from audit state to an algorithmically release-hard internal validation state. It addresses the P1, P2 and P3 findings from `DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md` without redesigning the UI, changing navigation, adding experimental features, or modifying Apple Watch code.

DIR DIVING iOS remains a non-certified informational companion. Planner output is a conservative reference for study and cross-checking only. It is not a certified decompression planner and must not be used as a primary life-support instrument.

## Strategy Chosen

The current iOS MAIN planner does not implement a full decompression engine. This hardening keeps the existing simplified nitrogen-only Buhlmann reference and makes it explicit and safe:

- Air and nitrox references are allowed only after full input validation.
- Trimix is rejected as `unsupportedTrimix` / `modelIncomplete` because the MAIN branch does not include a complete helium tissue model.
- Invalid input never returns a fake long NDL fallback.
- Simplified Buhlmann output is marked as `simplifiedReferenceOnly`.
- Decompression stops remain indicative UI output, not actionable certified decompression advice.

## P1 Issues Fixed

- Centralized iOS algorithm utilities in `IOSAlgorithmSupport.swift`.
- Centralized unit conversions for depth, pressure, volume, temperature, speed, kilometers, miles and ambient pressure.
- Centralized planner constants for depth limits, time limits, gas fraction ranges, PPO2 ranges, import/sync bounds and log count.
- Moved planner validation out of `PlannerView` into `PlannerInputValidator`.
- `PlannerService` refuses invalid programmatic or persisted planner inputs.
- Gas mixes now reject non-finite values, impossible fractions, O2 + He > 100%, and PPO2 outside supported bounds.
- Remaining gas no longer hides invalid cylinder size with artificial clamps.
- Negative remaining gas is represented as warning/result state.
- PPO2 stops expose actual PPO2 and max PPO2 separately; over-limit values are warned and not clipped.
- Trimix is not processed by the simplified N2-only Buhlmann reference.
- Fake `999 min` NDL fallback was removed.
- PPN2, EAD, END and gas density estimates are exposed through `GasAnalysis`.
- High gas density produces an explicit warning state.

## P2 Issues Fixed

- iOS logbook derived metrics use time-weighted average depth.
- Imported CSV profiles are sorted and sanitized deterministically.
- Invalid depths, non-finite values, invalid temperatures, invalid coordinates and impossible import bounds are rejected or skipped.
- Watch sync payloads are normalized through `DiveSessionAlgorithmValidator` before entering the logbook.
- Sync rejects invalid samples, invalid GPS, non-monotonic timestamps, inconsistent duration/max/avg/TTV, and unsupported profile sizes.
- Merge now selects a canonical sample set and recomputes duration, max depth, time-weighted average depth, TTV, temperature summary and exceeded-depth flag.
- iOS logbook enforces the centralized 40-session cap by newest start date.
- Subsurface CSV export rejects empty profiles, sorts valid samples, guarantees non-negative elapsed seconds and avoids header-only success.
- Route summaries reject invalid latitude/longitude and protect Haversine/bearing outputs from NaN.

## P3 Issues Fixed

- Removed duplicated conversion constants from formatter and model paths where they affected calculations.
- Added typed `PlannerResultState` and `BuhlmannModelState` so warnings can be carried consistently without implying certification.
- Added deterministic helpers for profile math, gas validation, planner validation, route validation and session validation.
- Added iOS unit test target wiring in `project.yml`.
- Added XCTest coverage for planner validation, gas analysis, simplified Buhlmann safety states, unit conversions, logbook math, import/export, sync validation, merge recomputation, log cap and route validation.

## Validation Rules

Planner validation rejects:

- NaN or infinite numeric fields
- depth below 1 m or above supported planner depth
- non-positive bottom time or excessive bottom time
- zero or negative cylinder volume
- start pressure less than or equal to reserve pressure
- negative reserve pressure
- zero or negative SAC/RMV
- invalid gas fractions
- O2 <= 0, O2 > 1, He < 0, or O2 + He > 1
- PPO2 outside the supported planner range
- planned depth deeper than bottom-gas MOD

Session and sync validation rejects:

- invalid dates or end before start
- non-finite duration, max depth, average depth or TTV
- samples outside session range
- non-finite, negative or out-of-range sample depths
- invalid or out-of-range temperatures
- non-monotonic sample timestamps
- invalid GPS coordinates or negative/invalid GPS accuracy
- derived metrics inconsistent with the canonical sample set

## Remaining Limitations

- Full Buhlmann ZH-L16C with helium compartments, gas switches, gradient factors and propagated decompression ceilings is not implemented in MAIN.
- Trimix is intentionally unsupported in MAIN planner calculations.
- Gas density is an estimate based on surface densities and ambient pressure; it is a warning aid, not a respiratory safety certification.
- Planner stops are still simplified reference output and remain non-certified.
- Device-level validation with Xcode, simulator and TestFlight is still required on macOS.

## Test Coverage Added

The new `DIRDiving iOS Tests` target covers:

- Air 21% and Nitrox 32 planner scenarios
- invalid gas fractions and invalid planner numeric inputs
- MOD rejection
- trimix unsupported/model-incomplete behavior
- no fake `999 min` NDL fallback
- actual stop PPO2 over-limit exposure
- PPN2/EAD/END/gas-density analysis
- unit conversion round trips
- time-weighted average depth with irregular samples
- sample sanitization
- merge recomputation
- 41st log trim behavior
- empty export rejection and sorted export elapsed seconds
- corrupted sync session rejection
- invalid GPS/route rejection
- malformed CSV import rejection

## Build Notes

`project.yml` now includes an iOS XCTest target. On a macOS development machine, regenerate and verify with:

```sh
xcodegen generate
xcodebuild test -scheme "DIRDiving iOS Tests" -destination 'platform=iOS Simulator,name=iPhone 15'
xcodebuild build -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator'
```

Windows cannot run XcodeGen/Xcodebuild locally in this workspace, so final compile/test validation must be completed on macOS.
