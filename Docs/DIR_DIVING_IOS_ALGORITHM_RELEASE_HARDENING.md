# DIR DIVING iOS Algorithm Release Hardening

Date: 2026-05-27
Scope: iOS Companion MAIN branch only

DIR DIVING iOS remains a non-certified informational diving companion. Planner, gas, NDL, CNS/OTU, END/EAD, route, import, export, and sync outputs must not be used as certified decompression or life-support advice.

## Summary

This hardening pass resolves the iOS algorithm and mathematical audit findings from `DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md` without changing the premium dark UI design, navigation, layout, colors, icons, animations, or Apple Watch code.

The implementation adds a central iOS algorithm layer for validation, unit conversion, planner states, profile math, session validation, and logbook limits. Services now reject invalid programmatic or persisted inputs before producing apparently valid planner, import, export, sync, or route outputs.

## P0 Issues Fixed

- Actionable-looking technical planner outputs are now tagged with typed states such as `simplifiedReferenceOnly`, `modelIncomplete`, `unsupportedTrimix`, `unavailable`, and `invalidInput`.
- Trimix no longer receives N2-only Buhlmann NDL output. If helium is present, Buhlmann returns `unsupportedTrimix` / `modelIncomplete` instead of a numeric NDL.
- Static stop and TTR content remains reference-only and non-certified.

## P1 Issues Fixed

- Manual dive TTV now uses the canonical DIR DIVING formula: `average depth + duration minutes`.
- Stop PPO2 is no longer clipped. Actual PPO2 is exposed separately from max allowed PPO2, and over-limit stops emit `PPO2Exceeded`.
- Buhlmann no longer returns `999` as a valid NDL. Unbounded or unavailable NDL states return unavailable/model state instead.
- Planner, gas planning, and persisted/programmatic planner inputs are validated centrally before calculation.
- CSV import and logbook-derived values now use time-weighted average depth from validated profile samples.

## P2 Issues Fixed

- Watch sync validation now normalizes or rejects sessions before logbook entry, including sample count, finite depths, temperature bounds, timestamp range, GPS validity, duration, max depth, average depth, and TTV consistency.
- Dive session merge no longer mixes unrelated derived values. Samples are timestamp-deduped, sorted, sanitized, and derived values are recomputed.
- Subsurface CSV export rejects empty profiles, validates and sorts samples, rejects invalid depths/temperatures, and guarantees nonnegative monotonic elapsed seconds.
- CSV import no longer uses negative GPS accuracy. Imported GPS fallback accuracy is explicit and nonnegative.
- Route distance/bearing validate latitude, longitude, accuracy, and finite values. Invalid routes return unavailable/zero-safe values instead of NaN.
- iOS logbook now enforces the documented newest-40-session cap after load, merge, import, sync, add, and reload.

## P3 Issues Fixed

- Unit conversions are centralized in `IOSUnitConversions`.
- Planner/import/export/sync/logbook thresholds are centralized in `IOSAlgorithmConfiguration`.
- Planner warnings are backed by typed `PlannerResultState` values.
- iOS algorithm XCTest coverage was added through `DIRDiving iOS Algorithm Tests`.
- Salinity and altitude remain stored fields but are explicitly marked as not applied by the current reference planner state.

## Planner Strategy

The project does not implement a full validated Buhlmann ZH-L16C decompression engine in iOS MAIN.

Chosen safe strategy:

- Air and Nitrox Buhlmann preview remains a simplified N2-only reference.
- Trimix returns `unsupportedTrimix` / `modelIncomplete`.
- NDL unavailable states do not return fake high values.
- GF comparisons and generated stops remain non-certified reference outputs.
- Planner output is blocked for invalid inputs and flagged for unsupported or model-incomplete inputs.

## Validation Rules

Central validators reject:

- NaN and infinity
- negative or unsupported depth
- zero or negative bottom time
- zero or negative cylinder volume
- zero or negative SAC/RMV
- start pressure less than or equal to reserve pressure
- negative pressure
- O2 less than or equal to zero
- O2 greater than 100%
- He less than zero
- O2 + He greater than 100%
- PPO2 outside supported bounds
- invalid gradient factors
- invalid finite temperatures outside plausible water bounds
- invalid GPS latitude, longitude, or horizontal accuracy
- oversized import/sync payloads and sample sets

## Logbook Math Policy

Validated profile samples are sorted and deduplicated by timestamp. Derived session values are recomputed from the canonical sample set:

- duration
- max depth
- time-weighted average depth
- TTV/index
- average temperature
- supported-depth exceeded flag

The newest 40 sessions are retained deterministically.

## Import, Export, and Sync Policy

CSV import:

- rejects empty profiles
- rejects invalid depth, temperature, timestamps, GPS, duration, and oversized profiles
- sorts profile rows deterministically
- stores normalized derived values

CSV export:

- rejects empty exports
- validates and sorts samples
- prevents header-only success
- guarantees monotonic nonnegative elapsed seconds
- preserves the existing CSV column format

Watch sync on iOS:

- preserves HMAC validation
- enforces payload size and issued-at skew
- rejects corrupted sessions before logbook entry
- recomputes derived values from validated samples

## Route Math Policy

Route distance uses Haversine only after GPS validation. Bearing returns unavailable for invalid or identical entry/exit points rather than emitting NaN.

## Test Coverage Added

`Tests/iOSAlgorithmTests/IOSAlgorithmTests.swift` covers:

- Air and Nitrox planner reference outputs
- Trimix unsupported/model-incomplete behavior
- invalid gas fractions
- invalid depth/time/cylinder/SAC/pressure inputs
- Buhlmann unavailable behavior and no `999` NDL fallback
- PPO2 and MOD exceeded states
- gas density states
- unit conversion round trips
- time-weighted profile average and canonical TTV
- CSV import sorting and GPS accuracy
- CSV export empty-profile rejection and monotonic elapsed seconds
- invalid depth, temperature, and GPS rejection
- merge recomputation
- 40-session logbook cap
- Watch sync session validation
- route invalid/identical GPS handling

## Remaining Limitations

- Full Buhlmann ZH-L16C with N2 + He tissue loading is not implemented in iOS MAIN.
- Salinity and altitude are persisted but not applied to ambient pressure in the reference planner.
- CNS/OTU remain simplified reference estimates.
- Static stop schedules remain reference-only and must not be treated as certified decompression plans.
- Physical-device and Xcode validation are still required on macOS with Xcode/XcodeGen.

## Release Position

With these changes, iOS MAIN is algorithmically hardened for internal validation: invalid inputs, corrupted profiles, unsupported trimix Buhlmann, fake NDL fallbacks, header-only exports, inconsistent merge math, invalid GPS, and unbounded log growth are blocked or converted into safe unavailable/reference-only states.
