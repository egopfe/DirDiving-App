# Watch Location Permission — First Launch

## Why

Watch Snorkeling route, waypoint, return guidance, and logbook GPS metadata need location permission. Previously the native prompt appeared only when runtime GPS started. Early onboarding explains the purpose and lets the user trigger the When In Use dialog after legal acceptance.

## Non-blocking design

- **Not now** dismisses the sheet and does not block Diving Gauge, Full Computer, or Apnea.
- Denied/restricted states show Settings guidance without repeated system prompts.
- Onboarding permission request does **not** start continuous location updates.

## GPS uses (When In Use only)

- Entry / exit capture
- Snorkeling route and waypoints
- Return-to-entry / return-to-exit guidance
- Logbook GPS metadata when available

## Privacy

- `NSLocationWhenInUseUsageDescription` in `App/Info.plist`
- No Always permission
- No background location mode added
- `PrivacyInfo-Watch.xcprivacy` already declares precise location for app functionality

## Behavior by state

| State | First launch | Snorkeling GPS features |
|-------|--------------|-------------------------|
| notDetermined | Sheet + Enable GPS | Notice + Enable GPS |
| authorized | No sheet | Normal behavior |
| denied / restricted | Continue + guidance | Settings guidance, no re-prompt |

## Unchanged

- Decompression / Bühlmann / GF / Full Computer runtime
- Apnea algorithms
- iOS location permission flow
- Activity-specific logbook ownership

## QA

Physical Apple Watch QA required. See `Docs/QA_EVIDENCE/WATCH_LOCATION_PERMISSION_FIRST_LAUNCH/`.
