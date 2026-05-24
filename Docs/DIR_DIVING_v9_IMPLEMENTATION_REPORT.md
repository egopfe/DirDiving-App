# DIR Diving — Development Notes UPDATED v9 — Implementation Report

**Date:** 2026-05-20  
**Branch:** `main`  
**Spec:** `Docs/DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`

## Constraints confirmed

- No app UI redesign, premium Apple styling, navigation structure, or unrelated refactors.
- No Bühlmann / decompression algorithm rewrite (`BuhlmannPlanner.swift` compartment math unchanged).
- Planner/Bühlmann **input propagation** and Watch surface navigation only where v9 required gaps existed.
- Existing v8 planner gas, equipment GAS, MOD, photo validation, and Watch alarms remain in place (verified, not reimplemented).

---

## Files changed (v9 pass)

| File | Change |
|------|--------|
| `Views/ContentView.swift` | User Images tab always in `TabView`; surface vs active-dive navigation clarified |
| `Services/AppNavigationStore.swift` | Removed clamp that hid User Images when the store was empty |
| `Views/UserImagesView.swift` | Localized list/detail labels; larger detail image (`scaledToFit`, 168pt max height) |
| `Resources/en.lproj/Localizable.strings` | `user_images.list.title`, `user_images.item.label`, iPhone-sync empty body |
| `Resources/it.lproj/Localizable.strings` | IT equivalents |
| `iOSApp/Services/PlannerStore.swift` | Full plan + Bühlmann refresh on input changes; guarded side-effect flag |
| `iOSApp/Views/PlannerView.swift` | `plannerCylinders` changes trigger `refreshDerivedPlanningPreview()` |

**No changes this pass (already on `main` from v8 / prior work):**  
`WatchPhotoPreprocessor.swift`, `EquipmentTemplatesSheet`, `PlannerGasMixCard.swift`, `GasPlan.swift`, `PlannerGasSchedule.swift`, `PlannerMODValidator.swift`, `AlarmSettingsView.swift`, `WatchSubscreenBackToolbar.swift`, app icon catalogs / `Scripts/update_app_icons.sh`.

---

## Features implemented / verified by section

### 1. App icons (iOS + Watch)
- **Verified:** `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset`, `Resources/Assets.xcassets/AppIcon.appiconset`, target assignments via XcodeGen.
- **Regenerated:** `Scripts/update_app_icons.sh` (OK).
- **Note:** If Simulator still shows old icons: Product → Clean Build Folder, delete app, reinstall. Derived Data can cache icon assets.

### 2. iOS → Watch image validation
- **Verified:** `WatchPhotoPreprocessor` + `WatchPhotoTransferPanel` with IT/EN conversion warning and error handling; WatchConnectivity flow unchanged.

### 3. Checklist & My equipment (iOS)
- **Verified:** “My equipment” / templates (create, save, edit, delete, apply); REC/TEC defaults; local persistence (`EquipmentStore`).
- **GAS switch:** OFF hides all gas UI with no empty spacing; ON shows gas type, BAR/PSI, tank size, pressure (`EquipmentChecklistGasSection`).

### 4. Planner cylinder management (iOS)
- **Verified:** Add/remove cylinders; gas role, tank size (S80, S40, Bibo 12+12, 12L, 15L, 18L), mix per cylinder.
- **Roles:** Back Gas, Travel, Decompression, Bailout — affect schedule, MOD validation, Bühlmann bottom gas, bailout handling (`PlannerGasSchedule`, `GasPlanningService`).

### 5. Gas mix types (iOS)
- **Verified:** Air / EAN / Trimix segmented selector; field locks; O₂+He+N₂ = 100%; legacy mapping; Trimix label horizontal/centered in `PlannerGasMixCard`.

### 6. PPO₂/FPO₂ & MOD (iOS)
- **Verified:** PPO₂ steps 0.1 only; Dalton MOD; auto-update on mix/PPO₂/role changes; switch depth vs MOD highlighting; Calculate blocked on MOD issues.

### 7. Planning reference (iOS)
- **Verified:** Average depth field; max vs average planning reference; emergency gas rule via info (i) alert only (not permanent banner).

### 8. Bühlmann integration (iOS)
- **Enhanced this pass:** `PlannerStore.applyInputToPlanningOutputs()` updates **both** `plan` and `buhlmann` when input changes (after init) and when `refreshDerivedPlanningPreview()` / `calculate()` run.
- **Enhanced:** Cylinder array edits refresh plan preview from `PlannerView`.
- **Unchanged:** `BuhlmannPlanner` ZHL-16C implementation.

### 9. Apple Watch only
- **Max depth alarm:** Verified — configurable, default 40 m, 30 m option, persisted, units from preferences.
- **Back navigation:** Verified — `WatchDetailBackButton` / `WatchSubscreenBackToolbar` on pushed screens.
- **Dive time threshold:** Verified — default 30 min, persisted where configurable.
- **Images outside dive (v9 gap fixed):**
  - User Images tab **always** available when not in an active dive (empty state explains iPhone sync).
  - During active dive, navigation still limited to Live + Compass.
  - Photos persist under Documents/`UserImages`; `companionPhotoDidArrive` reloads store.

### 10. Localization
- Watch user-images strings updated EN/IT.
- Planner/equipment/watch-photo strings from v8 remain in `iOSApp/Resources` and root `Resources`.

### 11. Validation (build/test)

| Step | Result |
|------|--------|
| `xcodegen generate` | OK |
| iOS Simulator (`DIRDiving iOS`, iPhone 17) | **BUILD SUCCEEDED** |
| watchOS Simulator (`DIRDiving Watch App`, Apple Watch Ultra 3 49mm) | **BUILD SUCCEEDED** |
| Unit tests | No automated test target in project |

---

## TODOs / follow-ups

- **Travel gas automatic schedule expansion** in deco profile remains partial (roles/MOD validated; full travel sequencing in stops is incremental planning logic, not input sync).
- **iPad icon slots** — actool may warn on missing iPad sizes if target family expands.
- **Simulator icon cache** — manual clean if icons appear stale after `update_app_icons.sh`.
---

## Summary

v9 requirements were largely satisfied on `main` from prior v8 implementation (`a36dc23`). This pass closed the remaining **Watch User Images** accessibility gap (tab always visible on surface, localized empty/sync copy, improved detail readability) and strengthened **Planner → Bühlmann/plan synchronization** on every gas-related input change without touching decompression math.

**Confirmation:** No unrelated UI redesign, no unrelated business-logic rewrite, no Bühlmann algorithm rewrite.
