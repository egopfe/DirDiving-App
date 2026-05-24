# DIR Diving — Development Notes UPDATED v8 — Implementation Report

**Date:** 2026-05-20  
**Branch:** `main` (local, uncommitted at report time)  
**Spec:** `Docs/DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`

## Constraints confirmed

- No app UI redesign, color/typography/layout changes, or unrelated refactors.
- No Bühlmann / decompression algorithm changes (`BuhlmannPlanner.swift` untouched).
- Planner/MOD/gas input flow and UI behavior updated only where required by v8.

## Files changed (this pass)

| File | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | `GasMixKind`, mix normalization, PPO₂ 0.1 steps, legacy sync, validation helpers |
| `iOSApp/Models/EquipmentProfile.swift` | `gasMixKind`, `pressureUnit` on checklist items |
| `iOSApp/Services/PlannerStore.swift` | `refreshDerivedPlanningPreview()`, normalize on load/calculate |
| `iOSApp/Views/PlannerGasMixCard.swift` | **New** — Air/EAN/Trimix segmented control, locked fields, MOD, PPO₂ 0.1 |
| `iOSApp/Views/EquipmentChecklistGasSection.swift` | **New** — GAS-on-only gas type, BAR/PSI, tank, pressure |
| `iOSApp/Views/PlannerView.swift` | Planning-reference info alert; removed emergency rule banner; new gas card wiring |
| `iOSApp/Views/EquipmentView.swift` | GAS OFF hides all gas fields (fix inverted logic) |
| `iOSApp/Views/EquipmentTemplateEditorView.swift` | Same checklist GAS behavior |
| `iOSApp/Resources/en.lproj/Localizable.strings` | v8 strings (mix kinds, roles, planner info, validation) |
| `iOSApp/Resources/it.lproj/Localizable.strings` | IT equivalents |

## Features implemented / verified

### 1. App icons (iOS + Watch)
**Verified (no code change this pass).** Asset catalogs build; `Scripts/update_app_icons.sh` remains the regen path. If icons do not appear in Simulator, clear Derived Data / reinstall.

### 2. Watch image upload validation (iOS)
**Already on `main`** — `WatchPhotoPreprocessor.swift`, `WatchPhotoTransferPanel.swift`, IT/EN conversion warning.

### 3. Checklist & My equipment (iOS)
- **My equipment** templates: already present; editor unchanged structurally.
- **GAS switch:** OFF → no gas type, BAR/PSI, tank, or pressure UI. ON → gas type (Air/EAN/Trimix), BAR/PSI unit, tank size, pressure.
- Default REC/TEC templates unchanged.

### 4–6. Planner gas (iOS)
- Cylinders with roles (Back Gas, Travel, Decompression, Bailout), tank sizes, MOD per cylinder — existing + role label **Back Gas**.
- **Air / EAN / Trimix** segmented selector with field locks and O₂+He+N₂ = 100% validation.
- **PPO₂ max** step **0.1**; stored values normalized to 0.1 increments.
- **MOD** via Dalton in `PlannerMODValidator`; live MOD on gas card; switch-depth warnings unchanged.
- Invalid mix blocks **Calcola Piano** with localized alert.

### 7. Planner depth reference (iOS)
- Average depth + max/avg planning reference — already present.
- Removed visible emergency-gas rule `DIRWarningBox`.
- Added **info (i)** alert with IT/EN text from v8.

### 8. Bühlmann integration (iOS)
- `PlannerStore.refreshDerivedPlanningPreview()` syncs cylinders → legacy gases and refreshes Bühlmann NDL preview on gas/role/switch changes.
- `calculate()` normalizes mixes before `PlannerService.makePlan` / `BuhlmannPlanner.plan`.
- **No changes** inside `BuhlmannPlanner` algorithm.

### 9. Apple Watch
**Verified existing:** max depth alarm (default 40 m, 30 m allowed), runtime threshold default 30 min, back navigation helpers — no changes this pass.

## Build / test results

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| iOS Simulator (`DIRDiving iOS`, iPhone 17) | **BUILD SUCCEEDED** |
| watchOS Simulator (`DIRDiving Watch App`) | **BUILD SUCCEEDED** |
| Unit tests | No test target in project |

## TODOs / follow-ups

- **Travel gas sequencing** in deco profile: roles and MOD are validated; automatic travel-gas schedule in `PlannerService` stops is not expanded (would be new planning logic beyond input sync).
- **iPad icon slots** in `AppIcon.appiconset` — actool warnings for 76×76@2x and 83.5×83.5@2x (iPhone-only target; optional if iPad support is added).
- **Commit & push** when ready (not done automatically).

## Localization added (EN / IT)

`gas.mix.*`, `gas.role.bottom` → Back Gas, `planner.reference.info.*`, `planner.gas.mix_invalid`, `planner.gas.oxygen/helium/nitrogen/ppo2_max`, `planner.calculate.error.title`, `equipment.checklist.gas_type/pressure_unit/bar/psi`.
