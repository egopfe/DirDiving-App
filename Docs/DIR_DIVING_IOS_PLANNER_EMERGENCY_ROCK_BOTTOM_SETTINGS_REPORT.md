# DIR DIVING iOS — Emergency / Rock Bottom Settings — Implementation Report

## Git context

| Item | Value |
|------|-------|
| Branch | `main` |
| Starting commit | `4d19910` |
| Build | **DIRDiving iOS** — succeeded |
| Targeted tests | **26 tests — succeeded** (ScheduleGasConsumption, PlannerPresentation, Rock Bottom regression) |
| Full Algorithm Tests suite | 712 executed, **11 failures** (pre-existing: PDF export, CCR PDF disclaimers, localization key assertions, cloud merge, analysis-cache DCA — unrelated to this change) |

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | Added `emergencyExtraMinutes`; Codable migration defaults to 3.0 |
| `iOSApp/Utils/IOSAlgorithmConfiguration.swift` | Defaults/limits for extra minutes and team size |
| `iOSApp/Services/ScheduleGasConsumptionService.swift` | New Rock Bottom helpers + formula update |
| `iOSApp/Utils/PlannerInputValidator.swift` | Validates extra emergency minutes for reserve modes |
| `iOSApp/Services/PlannerStore.swift` | Analysis cache key includes emergency Rock Bottom inputs |
| `iOSApp/Views/PlannerView.swift` | New `emergencyCard`; removed duplicate emergency SAC from cylinders card |
| `iOSApp/Resources/en.lproj/Localizable.strings` | `planner.emergency.*` keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `planner.emergency.*` keys |
| `Tests/iOSAlgorithmTests/ScheduleGasConsumptionServiceTests.swift` | **New** — Rock Bottom parameterization tests |
| `Tests/iOSAlgorithmTests/PlannerPresentationTests.swift` | Emergency section + localization tests |
| `Docs/DIR_DIVING_IOS_PLANNER_EMERGENCY_ROCK_BOTTOM_SETTINGS.md` | Feature documentation |
| `Docs/DIR_DIVING_IOS_PLANNER_EMERGENCY_ROCK_BOTTOM_SETTINGS_REPORT.md` | This report |

## Model fields

- **Added:** `GasPlanInput.emergencyExtraMinutes: Double` (default `3.0`)
- **Existing (now surfaced in Emergency UI):** `teamSize` (default `2`), `emergencySacLitersPerMinute` (default `30`)

## UI fields (Emergency / Emergenza)

1. Team Size (stepper, 1–6)
2. Emergency SAC (L/min)
3. Extra Emergency Minutes (min, 0–30)
4. Automatic ascent (read-only)
5. Emergency time used (read-only)
6. Estimated Rock Bottom (L primary, bar secondary)
7. Reference-only footnote

## Rock Bottom formula

**Before:**

```
ascentMinutes = max(3, depth / 9)
emergencyMinutes = 1 + ascentMinutes + (depth > 10 ? 3 : 0)
Rock Bottom = emergencySAC × max(1, teamSize) × averageAscentATA × emergencyMinutes
```

**After:**

```
ascentMinutes = max(3, depth / 9)
extraEmergencyMinutes = clamp(input.emergencyExtraMinutes, 0…30)  // default 3
emergencyMinutes = ascentMinutes + extraEmergencyMinutes
Rock Bottom = emergencySAC × normalizedTeamSize × averageAscentATA × emergencyMinutes
```

## Confirmations

| Requirement | Status |
|-------------|--------|
| Automatic ascent remains depth-based | Yes |
| User edits only extra emergency minutes | Yes |
| Emergency SAC separate from normal SAC | Yes |
| Bühlmann unchanged | Yes |
| CCR unchanged | Yes |
| Ratio Deco unchanged | Yes |
| Schedule gas consumption unchanged | Yes |
| Available/remaining gas ledger unchanged | Yes |
| Reserve warnings follow new Rock Bottom threshold | Yes (expected) |
| Reference-only / non-certified wording preserved | Yes |
| Experimental Buddy/Watch files untouched | Yes |

## Tests added/updated

**New (`ScheduleGasConsumptionServiceTests`):**

- `testRockBottomUsesExtraEmergencyMinutesDefaultThree`
- `testRockBottomChangesWhenExtraEmergencyMinutesChanges`
- `testRockBottomUsesTeamSizeDefaultTwo`
- `testRockBottomChangesWhenTeamSizeChanges`
- `testAutomaticAscentTimeStillDepthBased`
- `testEmergencyExtraMinutesCannotBeNegative`
- `testEmergencyExtraMinutesDecodesDefaultWhenKeyMissing`

**Updated (`PlannerPresentationTests`):**

- `testEmergencyWindowLocalizationKeysExist`
- `testPlannerPresentationShowsEmergencySection`

**Regression (passed):**

- `BuhlmannReauditFixTests.testRockBottomUsesEnvironment`
- `ContingencyEngineTests.testLostGasContingencyUsesRockBottomLiters`

## Remaining limitations

- PDF/briefing export does not yet list Emergency section fields (optional per spec; unchanged this pass).
- Full Algorithm Tests suite has 11 unrelated failures in the current workspace (not introduced by this change).
- Numeric Rock Bottom values differ slightly from the old hidden `1 min + conditional +3 min` model; default extra **3** replaces the depth>10 margin explicitly.
