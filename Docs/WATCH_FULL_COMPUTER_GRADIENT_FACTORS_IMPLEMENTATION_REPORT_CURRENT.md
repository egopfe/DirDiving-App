# Watch Full Computer Gradient Factors — Implementation Report

**Date:** 2026-06-17  
**Branch:** `main`  
**Baseline commit (pre-change):** `79a51e7`  
**Status:** INTERNAL_READY — PHYSICAL_WATCH_QA_PENDING

## Verdict

| Criterion | Status |
|-----------|--------|
| FULL_COMPUTER_GF_PRESET_SELECTION_READY | Yes |
| IOS_PLAN_OVERRIDE_SUPPORTED_OR_DOCUMENTED | Yes |
| NO_CUSTOM_GF_ON_WATCH | Yes |
| NO_ACTIVE_DIVE_GF_CHANGE | Yes |
| PHYSICAL_WATCH_QA_PENDING | Yes (templates created, default PENDING) |

## Models added/updated

| File | Change |
|------|--------|
| `Shared/Models/FullComputerGradientFactorPreset.swift` | **New** — preset enum, source, resolved snapshot, lock reason, lock context |
| `Shared/Models/DivePlanPackage.swift` | Optional `gradientFactorPreset` on body; import unchanged for low/high |
| `Shared/Models/FullComputerDiveLogbookMetadata.swift` | `gradientFactorPreset`, `gradientFactorSource`, logbook display helper |

## Stores added/updated

| File | Change |
|------|--------|
| `Services/FullComputerGradientFactorSettingsStore.swift` | **New** — Watch preset persistence (`dirdiving.fullComputer.gradientFactorPreset.watchDefault`) |
| `Services/FullComputerPrediveConfigurationStore.swift` | Confirmed GF snapshot, `resolvedGradientFactorsForRuntime()`, runtime plan uses snapshot |
| `Services/FullComputerImportedPlanStore.swift` | Preset validation on import; iOS plan activation stores `.iosPlan` snapshot |
| `Services/DIRActivitySelectionStore.swift` | Predive confirm freezes resolved GF |
| `Services/DiveManager.swift` | `hasActiveFullComputerEngine`; logbook exports preset/source |

## Views added/updated

| File | Change |
|------|--------|
| `Views/FullComputerDivingSettingsView.swift` | **New** — Settings → Diving → Full Computer |
| `Views/FullComputerConservatismSettingsView.swift` | **New** |
| `Views/FullComputerGradientFactorsInfoView.swift` | **New** |
| `Views/FullComputerGradientFactorSelectionView.swift` | **New** — 3-preset menu with checkmarks |
| `Views/FullComputerGradientFactorCurrentValueView.swift` | **New** — Watch / iOS / active-dive states |
| `Views/SettingsView.swift` | Full Computer navigation link |
| `Views/FullComputerPrediveSettingsView.swift` | GF row with source + navigation |
| `Views/FullComputerPrediveConfirmationView.swift` | GF + source line |
| `Views/DiveDetailView.swift` | Logbook GF panel |

## iOS plan integration

- Watch rejects imported plans whose GF pair does not map to 20/80, 30/70, or 40/85 (`invalidGradientFactors`).
- Optional payload field `gradientFactorPreset` added (backward compatible decode).
- Active iOS plan locks Watch GF selection; source shown as **iOS Plan**.
- iOS Companion builder not yet emitting `gradientFactorPreset`; legacy low/high still work when they match a preset.

## Predive / runtime / logbook coherence

1. **Resolve** — iOS plan > Watch Settings (when unlocked).
2. **Confirm** — `commitConfirmedProfile(resolvedGradientFactors:)` freezes snapshot.
3. **Runtime** — `runtimePlan()` applies confirmed snapshot GF only.
4. **Logbook** — saves `gradientFactorPreset`, `gradientFactorSource`, low/high from snapshot.

## Tests

| Suite | Result |
|-------|--------|
| `FullComputerGradientFactorPresetTests` (6) | PASS |
| `FullComputerGradientFactorSettingsStoreTests` (7) | PASS |
| `FullComputerGradientFactorRuntimeResolutionTests` (4) | PASS |

**Total new tests:** 17 executed, 0 failures.

## Build & validation

| Check | Result |
|-------|--------|
| `xcodegen generate` | OK |
| `DIRDiving Watch App` build | **BUILD SUCCEEDED** |
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS (EN/IT 1427 keys) |

## Localization

Added EN/IT keys under `full_computer.*` (conservatism, settings, gradient factors, lock messages, predive/logbook formats).

## QA templates

Created under `Docs/QA_EVIDENCE/`:

- `WATCH_FULL_COMPUTER_GF_SETTINGS_SELECTION`
- `WATCH_FULL_COMPUTER_GF_IOS_PLAN_OVERRIDE`
- `WATCH_FULL_COMPUTER_GF_ACTIVE_DIVE_LOCK`
- `WATCH_FULL_COMPUTER_GF_PREDIVE_CONFIRMATION`
- `WATCH_FULL_COMPUTER_GF_LOGBOOK_PERSISTENCE`
- `WATCH_FULL_COMPUTER_GF_NO_CROSS_ACTIVITY_EXPOSURE`

All default **PENDING**.

## Documentation

- `Docs/WATCH_FULL_COMPUTER_GRADIENT_FACTORS_SETTINGS.md`
- This report

## Limitations

- Physical Apple Watch QA not executed in this session.
- iOS planner may still send GF 30/80 until Companion emits supported presets; such plans are rejected at Watch import until aligned.
- Logbook GF display appears only when `fullComputerLogbookMetadata` is present (Full Computer dives).

## Files changed (summary)

**New:** 9 Swift files, 1 settings doc, 1 report, 6 QA templates, localization keys  
**Updated:** 12 Swift files, `project.yml`, EN/IT `Localizable.strings`
