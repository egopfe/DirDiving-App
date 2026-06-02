# Developer Sensor Source — Implementation Report

**Date:** 2026-06-02  
**Branch:** `main` (local, uncommitted)

## 1. Files created

| Path |
|------|
| `Utils/SensorSourceMode.swift` |
| `Utils/DeveloperSettings.swift` |
| `Utils/DeveloperVersionUnlock.swift` |
| `Services/DepthSensorProvider.swift` |
| `Services/AppleDepthSensorProvider.swift` |
| `Services/MockDepthSensorProvider.swift` |
| `Services/SensorProviderFactory.swift` |
| `Views/DeveloperSettingsView.swift` |
| `iOSApp/Utils/SensorSourceMode.swift` |
| `iOSApp/Utils/DeveloperSettings.swift` |
| `iOSApp/Utils/DeveloperVersionUnlock.swift` |
| `iOSApp/Utils/AppleDepthSensorAvailability.swift` |
| `iOSApp/Views/DeveloperSettingsView.swift` |
| `Tests/WatchAlgorithmTests/DeveloperSensorSourceTests.swift` |
| `Tests/iOSAlgorithmTests/DeveloperSensorSourceTests.swift` |
| `Documentation/DeveloperSensorSource.md` |
| `Documentation/DeveloperSensorSourceImplementationReport.md` |

## 2. Files modified

| Path | Change |
|------|--------|
| `Services/DiveManager.swift` | Lazy depth provider wiring; removed launch-time CoreMotion |
| `Views/SettingsView.swift` | Developer navigation when visible |
| `Views/InfoView.swift` | Version 7-tap unlock; no CoreMotion at render |
| `iOSApp/Views/MoreView.swift` | Developer link, About/version unlock |
| `project.yml` | New sources + iOS CoreMotion + test target files |
| `Resources/en.lproj/Localizable.strings` | Developer strings (Watch) |
| `Resources/it.lproj/Localizable.strings` | Developer strings (Watch) |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Developer + About strings |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Developer + About strings |

## 3. Watch implementation status

**Complete.** Settings → Developer → Sensor Source (when visible). `DiveManager` uses `SensorProviderFactory` with default **Simulation**. `AppleDepthSensorProvider` is lazy-only.

## 4. iOS implementation status

**Complete.** More → Developer → Sensor Source (when visible). Preference stored on iPhone only (no Watch sync). Apple Sensor selection uses availability probe with safe fallback.

## 5. Persistence verification

- Key: `developer.sensorSource`
- Default: `simulation` (when key absent)
- Unlock key: `developer.settings.unlocked`
- Unit tests: `DeveloperSensorSourceTests` (Watch + iOS)

## 6. Fallback verification

- **Apple Sensor** unavailable → warning string, persist `simulation`, `MockDepthSensorProvider` active (Watch `DiveManager.reloadDepthSensorConfiguration()`).
- **Automatic** unavailable → mock provider, no persist.
- Factory tests assert mock when Apple unavailable.

## 7. Build verification

| Check | Result |
|-------|--------|
| Watch app compile (simulator) | Pass |
| iOS app compile (simulator) | Pass |
| Watch algorithm tests | Pass |
| iOS algorithm tests | Pass |

## 8. Regression risks

| Risk | Mitigation |
|------|------------|
| Mock timer while idle | Surface 0 m only; no auto-dive pulse |
| Algorithm tests expecting no submersion manager | Tests use `testHook_processDepthMeasurement`; mock does not break hooks |
| `isDepthAutomationAvailable` semantics | `true` for simulation/automatic-with-mock; Apple-only false when apple mode without hardware (then fallback) |

## 9. Remaining manual tests

- [ ] Release build: Developer hidden until 7 version taps
- [ ] TestFlight build: Developer visible without tap
- [ ] Watch on real hardware without entitlement: launch, manual dive, logbook export
- [ ] Watch with entitlement: Apple Sensor + Automatic with real depth
- [ ] iOS: unlock gesture and persistence independent of Watch

## 10. Business logic

**Not modified:** Bühlmann, planner, gas, decompression, GPS, mission mode algorithms, logbook merge, TTV/ascent math.

## 11. UI/UX and graphics

**Not modified:** Existing layouts, icons, colors, onboarding flows. Added hidden Developer screens using existing Watch/iOS settings patterns only.

## 12. Entitlement statement

**The application can now be compiled, installed and tested on Apple Watch devices without the Submerged Depth and Pressure entitlement by using Simulation Mode and MockDepthSensorProvider.**
