# iOS Location Permission — First Launch

## Problem

Snorkeling Route Planner showed “GPS required” messaging but never invoked `CLLocationManager.requestWhenInUseAuthorization()`, so the native iOS permission dialog did not appear when status was `.notDetermined`.

## Solution

1. **`IOSLocationPermissionService`** — single iOS-only `@MainActor` service holding a live `CLLocationManager`, publishing `authorizationStatus` and `ApneaMapPermissionState`.
2. **`IOSFirstLaunchLocationPermissionPolicy`** — UserDefaults flag so the first-launch education sheet is shown once per install when status is `.notDetermined`.
3. **`IOSFirstLaunchLocationPermissionView` + `IOSFirstLaunchLocationPermissionHost`** — pre-mode onboarding sheet after legal acceptance; primary button triggers the system dialog from user action.
4. **Snorkeling / Apnea map views** — consume `@EnvironmentObject IOSLocationPermissionService`; Route Planner banners offer “Enable GPS” (`.notDetermined`) or “Open Settings” (`.denied` / `.restricted`).

## iOS limits

- Native dialog only when status is `.notDetermined`.
- After deny, only Settings can restore access — no repeated system prompts.
- **When In Use only** — no Always, no background location added.

## Privacy

- `NSLocationWhenInUseUsageDescription` in `iOSApp/App/Info.plist`.
- `PrivacyInfo-iOS.xcprivacy` already declares precise location for app functionality — no change required.

## QA

Physical iPhone QA required before marking PASS. See `Docs/QA_EVIDENCE/IOS_LOCATION_PERMISSION_FIRST_LAUNCH/`.
