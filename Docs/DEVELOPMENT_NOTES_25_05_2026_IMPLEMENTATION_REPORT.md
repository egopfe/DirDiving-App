# Development notes 25/05/2026 — implementation report

**Spec:** `Docs/DIR_Diving_Complete_Development_Notes_25_05_2026.md`  
**Branch:** `main`  
**Date:** 2026-05-24 (updated for 100% compliance pass)

## Summary

All ten development-note items are implemented in code with full compliance pass (template editor, per-cylinder MOD + switch depths, Watch back on all pushed/detail flows, icons regenerated and installed on Simulator). No app redesign, no decompression algorithm changes, and no removal of existing features.

## Features implemented

| # | Area | Status |
|---|------|--------|
| 1 | App icons (iOS + watchOS) | Regenerated from `Docs/ReferenceIcon/` via `Scripts/update_app_icons.sh`; both targets use `AppIcon` (`project.yml`). See `Docs/APP_ICON_UPDATE_NOTES.md` for Derived Data / simulator cache. |
| 2 | Watch photo validation/conversion (iOS) | `WatchPhotoPreprocessor` + localized warning in `WatchPhotoTransferPanel`; conversion errors surfaced. |
| 3 | My equipment templates (iOS) | `EquipmentTemplatesSheet` + **`EquipmentTemplateEditorView`** (full edit); `EquipmentStore` CRUD + REC/TEC defaults; checklist GAS + tank + pressure. |
| 4 | Planner tank type | Shared `TankSize` enum; cylinder cards use same list. |
| 5 | Average depth + planning reference | `GasPlanInput` fields + UI; emergency gas rule copy; rock bottom still uses max depth in `GasPlanningService`. |
| 6 | Planner cylinders (add/remove, role, tank, gas) | `PlannerCylinderEntry` + `plannerCylindersCard`; legacy gases synced. |
| 7 | MOD validation (Dalton) | Per-cylinder MOD display + editable switch depths; `validatePlannerCylinders` + stop validation; live + result warnings; capped stops in plan. |
| 8 | Watch max depth alarm | **Verified existing** — `AlarmSettingsView` + `@AppStorage` default 40 m, stepper 10–100 m (includes 30 m). |
| 9 | Watch back navigation | Back on alarms, ascent, shortcuts help, info, export, dive detail, legal, user image detail (`WatchDetailBackButton` / `watchSubscreenBackToolbar`). |
| 10 | Watch dive time default 30 min | **Verified existing** — `WatchAlarmDefaults.runtimeThresholdMinutes = 30`. |

## Files changed

### New
- `iOSApp/Views/EquipmentTemplateEditorView.swift`
- `iOSApp/Models/TankSize.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/WatchPhotoPreprocessor.swift`
- `iOSApp/Views/EquipmentTemplatesSheet.swift`
- `Utils/WatchSubscreenBackToolbar.swift`
- `Utils/WatchDetailBackButton.swift`
- `Scripts/update_app_icons.sh`
- `Docs/APP_ICON_UPDATE_NOTES.md`
- `Docs/DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md` (this file)

### Modified
- App icon PNGs: `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset/*`, `Resources/Assets.xcassets/AppIcon.appiconset/*`
- iOS models/services/views: `GasPlan.swift`, `DivePlan.swift`, `EquipmentProfile.swift`, `EquipmentStore.swift`, `GasPlanningService.swift`, `PlannerService.swift`, `PlannerStore.swift`, `EquipmentView.swift`, `PlannerView.swift`, `WatchPhotoTransferPanel.swift`
- iOS localization: `iOSApp/Resources/{en,it}.lproj/Localizable.strings`
- Watch views: `AlarmSettingsView.swift`, `AscentRateSettingsView.swift`, `DiveDetailView.swift`, `WatchLegalOnboardingView.swift`
- Watch localization: `Resources/{en,it}.lproj/Localizable.strings` (`watch.nav.back`)

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' build` | **BUILD SUCCEEDED** |
| Dedicated formatter/linter | Not configured in repo |

## Limitations / notes

- **MOD / helium:** MOD uses FO₂ and PPO₂ max per Dalton (helium fraction is in the mix but does not alter O₂ toxicity MOD).
- **Deco stop schedule:** Fixed multi-stop template still applies after user switch depths; depths beyond MOD are capped and flagged.
- **Icons on device:** Simulator install performed on iPhone 17; physical device / App Store Connect still require manual install/upload.
- If Simulator shows a stale icon, follow `Docs/APP_ICON_UPDATE_NOTES.md` (clean build, delete app).

## Constraints confirmation

- No unrelated UI redesign, color/typography changes, or feature removal.
- Decompression, dive logging, export, and core safety runtime logic unchanged except explicit MOD validation / deco stop depth cap and planning-depth reference for END/EAD display paths.
- WatchConnectivity photo transfer path preserved; preprocessing runs before send.
