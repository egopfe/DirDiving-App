# DIR DIVING iOS — Planner Ascent Speed Settings — Implementation Report

## Git context

| Item | Value |
|------|-------|
| Branch | `main` |
| Starting commit | `61c246e` |
| iOS build | **SUCCEEDED** |
| Targeted tests (61) | **SUCCEEDED** (1 skipped) |

## Files added

| File | Purpose |
|------|---------|
| `iOSApp/Models/PlannerAscentSpeedSettings.swift` | Model, band math, transit adjuster, `BuhlmannEngineResult` overlay |
| `iOSApp/Services/PlannerAscentSpeedSettingsStore.swift` | `@MainActor` persisted settings store |
| `iOSApp/Views/PlannerAscentSpeedSettingsView.swift` | Settings UI |
| `Tests/iOSAlgorithmTests/PlannerAscentSpeedSettingsTests.swift` | Core behavior tests |
| `Docs/DIR_DIVING_IOS_PLANNER_ASCENT_SPEED_SETTINGS.md` | Feature documentation |

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/IOSAlgorithmConfiguration.swift` | Min/max planner ascent speed (1–18 m/min) |
| `iOSApp/Services/ScheduleGasConsumptionService.swift` | Rock Bottom + ledger use banded ascent time |
| `iOSApp/Services/GasPlanningService.swift` | Operational engine plan for ledger; settings threading |
| `iOSApp/Services/PlannerService.swift` | Operational transit overlay; runtime rows / total runtime |
| `iOSApp/Services/PlannerStore.swift` | Settings notification + cache signature |
| `iOSApp/App/DIRDivingiOSApp.swift` | Environment object for settings store |
| `iOSApp/Views/MoreView.swift` | Navigation link to ascent speed settings |
| `iOSApp/Resources/en.lproj/Localizable.strings` | EN keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | IT keys |
| `project.yml` | Test target includes `PlannerAscentSpeedSettings.swift` |
| `Tests/iOSAlgorithmTests/ScheduleGasConsumptionServiceTests.swift` | Banded ascent expectations |
| `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift` | Settings presentation check |

## Default speeds (m/min)

| Band | Default |
|------|---------|
| > 40 m | 9 |
| 40–30 m | 9 |
| 30–20 m | 9 |
| 20–6 m | 6 |
| 6–0 m | 3 |

## Architecture

1. **Bühlmann engine** runs unchanged (`BuhlmannConstants.defaultAscentRateMetersPerMinute` for tissue/stop solving).
2. **`withPlannerTransitMinutes(using:)`** rebuilds only `.ascent` segment minutes from global band speeds; `.stop`, `.gasSwitch`, bottom, descent unchanged.
3. **Operational plan** drives runtime table, depth profile, gas ledger, and displayed total runtime.
4. **TTS and deco stops** remain from the original engine result.

## Confirmations

| Requirement | Status |
|-------------|--------|
| Bühlmann stop depths unchanged | Yes |
| Bühlmann stop minutes unchanged | Yes |
| CCR unchanged | Yes |
| Ratio Deco unchanged | Yes |
| Gas consumption formula unchanged | Yes (`SAC × ATA × minutes`) |
| Only transit segment minutes affected | Yes |
| Rock Bottom uses configured automatic ascent | Yes |
| Emergency extra minutes still applied | Yes |
| Watch ascent settings untouched | Yes |
| Reference-only planner | Yes |

## Tests added

`PlannerAscentSpeedSettingsTests`: defaults, bands, multi-band integration, Rock Bottom, gas ledger, Bühlmann stop invariance, runtime rows, localization, persistence/reset.

## Tests run

- `PlannerAscentSpeedSettingsTests` — pass
- `ScheduleGasConsumptionServiceTests` — pass
- `PlannerAscentTableTests` — pass (1 skip)
- `PlannerPresentationTests` — pass

## Known limitations

- Bühlmann **TTS** label still reflects engine elapsed time (decompression solving), while **total runtime** display uses operational transit minutes.
- Oxygen exposure / CNS full-plan paths still use original engine segments (tissue-accurate).
- PDF/briefing does not yet list per-band ascent speeds.
- Average ascent ATA for Rock Bottom remains midpoint depth (unchanged from Emergency pass).
