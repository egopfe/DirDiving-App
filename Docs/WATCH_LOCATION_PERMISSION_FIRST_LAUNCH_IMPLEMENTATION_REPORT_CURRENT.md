# Watch Location Permission First Launch — Implementation Report

**Status:** INTERNAL_READY · PHYSICAL_WATCH_QA_PENDING  
**Branch:** main  
**Baseline commit:** (record at merge)

## Summary

Conservative Watch-first-run location onboarding via existing `GPSManager`, non-blocking, When In Use only.

## Files added

| File | Role |
|------|------|
| `Utils/WatchLocationPermissionState.swift` | Permission state mapping |
| `Utils/WatchFirstLaunchLocationPermissionPolicy.swift` | One-time first-run policy |
| `Views/WatchFirstLaunchLocationPermissionView.swift` | Onboarding UI + host |
| `Views/WatchLocationPermissionNoticeView.swift` | Snorkeling notice + settings section |
| `Tests/WatchAlgorithmTests/WatchLocationPermissionStateTests.swift` | Mapping tests |
| `Tests/WatchAlgorithmTests/WatchFirstLaunchLocationPermissionPolicyTests.swift` | Policy tests |
| `Tests/WatchAlgorithmTests/GPSManagerAuthorizationPolicyTests.swift` | GPSManager + integration tests |

## Files updated

| File | Change |
|------|--------|
| `Services/GPSManager.swift` | `locationPermissionState`, refresh, onboarding request |
| `App/Info.plist` | Updated When In Use string |
| `App/LegalAcceptanceStore.swift` | `hasAccepted` |
| `Views/ContentView.swift` | First-launch host after companion disclaimer |
| `Views/SnorkelingView.swift` | GPS unavailable notice |
| `Views/SettingsView.swift` | Privacy & Location section |
| `Views/WatchActivitySettingsSections.swift` | Uses `locationPermissionState` |
| `Resources/{en,it}.lproj/Localizable.strings` | Watch location keys |
| `project.yml` | Test target sources for new utils |

## Verdict

```text
INTERNAL_READY
PHYSICAL_WATCH_QA_PENDING
WATCH_LOCATION_PERMISSION_FIRST_LAUNCH_READY
SNORKELING_GPS_DEGRADATION_READY
NO_ALWAYS_LOCATION
NO_BACKGROUND_LOCATION
NO_FAKE_GPS
```
