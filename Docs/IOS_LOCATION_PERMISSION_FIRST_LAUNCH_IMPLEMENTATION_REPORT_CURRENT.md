# iOS Location Permission First Launch — Implementation Report

**Status:** INTERNAL_READY · PHYSICAL_IOS_DEVICE_QA_PENDING  
**Branch:** main  
**Baseline commit:** (record at merge)

## Summary

Centralized iOS location permission handling with first-launch flow independent of activity mode (Diving / Full Computer / Apnea / Snorkeling).

## Files added

| File | Role |
|------|------|
| `iOSApp/Services/IOSLocationPermissionService.swift` | Central `CLLocationManager` + delegate |
| `iOSApp/Utils/IOSFirstLaunchLocationPermissionPolicy.swift` | First-launch UserDefaults policy |
| `iOSApp/Utils/IOSLocationSettingsOpener.swift` | Open iOS Settings (iOS-only) |
| `iOSApp/Views/IOSFirstLaunchLocationPermissionView.swift` | First-launch UI + host modifier |
| `Tests/iOSAlgorithmTests/IOSLocationPermissionServiceTests.swift` | Mapping tests |
| `Tests/iOSAlgorithmTests/IOSFirstLaunchLocationPermissionPolicyTests.swift` | Policy tests |
| `Tests/iOSAlgorithmTests/IOSSnorkelingLocationPermissionTests.swift` | Source contract tests |

## Files updated

| File | Change |
|------|--------|
| `iOSApp/App/DIRDivingiOSApp.swift` | Inject service; wrap root in first-launch host |
| `iOSApp/App/Info.plist` | Updated When In Use usage string |
| `iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift` | EnvironmentObject + actionable banners |
| `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift` | EnvironmentObject |
| `iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift` | EnvironmentObject |
| `iOSApp/Utils/IOSSnorkelingLocationPermission.swift` | Delegate mapping to central service |
| `iOSApp/Utils/IOSApneaLocationPermission.swift` | Delegate mapping to central service |
| `iOSApp/Resources/{it,en}.lproj/Localizable.strings` | New `ios.location.permission.*` keys |

## Behavior

1. Fresh install → legal onboarding (if required) → first-launch location sheet (if `.notDetermined` and flag unset).
2. “Consenti posizione” → `requestWhenInUseFromUserAction()` + mark presented + dismiss sheet.
3. “Non ora” → mark presented + dismiss (no system prompt).
4. Snorkeling Route Planner: `.notDetermined` shows enable CTA; denied/restricted shows Settings CTA.

## Not modified

- Diving / apnea / snorkeling algorithms and runtime
- Watch target
- Background location or Always authorization

## Verdict

```text
INTERNAL_READY
PHYSICAL_IOS_DEVICE_QA_PENDING
IOS_LOCATION_PERMISSION_FIRST_LAUNCH_READY
SNORKELING_ROUTE_PLANNER_PERMISSION_FIX_READY
NO_ALWAYS_LOCATION
NO_BACKGROUND_LOCATION
```
