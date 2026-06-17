# DIR DIVING — Modes & Startup Flow Implementation Report (Command 01)

**Branch:** `integration/full-computer` @ `f2663c6`  
**Date:** 2026-06-16  
**Remote:** pushed to `origin/integration/full-computer`  
**Build:** `xcodegen generate` + iOS + Watch **BUILD SUCCEEDED**; `DIRModesAndStartupFlowTests` **11/11 PASS**
**Scope:** Watch MAIN — global activity modes, Diving sub-modes (Gauge / Full Computer), startup flow, Settings, pre-dive FC confirmation shell. **No Bühlmann runtime.**

## Summary

Implemented the stable mode-selection and cold-launch routing described in Command 01 and the attached mockups (FC_UI_01 … FC_UI_05). Existing Gauge algorithms, TTV math, lifecycle, alarms, Mission Mode, and logbook behavior are unchanged.

## Files added

| File | Purpose |
|------|---------|
| `Models/DIRModesAndStartup.swift` | `DIRActivityMode`, `DIRDivingMode`, `DIRStartupLaunchStep`, `DIRActivitySelectionState` |
| `Utils/DIRStartupSelectionPolicy.swift` | Persisted preferences, cold-launch routing, legacy migration |
| `Services/DIRActivitySelectionStore.swift` | Session selection state, startup flow, mode-change guard |
| `Views/StartupFlowView.swift` | Startup flow container |
| `Views/ActivitySelectionView.swift` | SCEGLI ATTIVITÀ screen |
| `Views/DivingModeSelectionView.swift` | MODALITÀ DIVING screen |
| `Views/FullComputerPrediveConfirmationView.swift` | FC pre-dive confirmation (no auto-start) |
| `Views/ActivityComingSoonView.swift` | Apnea / Snorkeling not release-ready |
| `Views/WatchStartupSettingsPickers.swift` | Default activity / diving mode pickers |
| `Tests/WatchAlgorithmTests/DIRModesAndStartupFlowTests.swift` | Policy, routing, FC confirm, block-under-dive tests |

## Files modified

| File | Change |
|------|--------|
| `Views/ContentView.swift` | Startup fullScreenCover, mode-change toast |
| `Views/ModeSelectionView.swift` | Delegates to `ActivitySelectionView` |
| `Views/SettingsView.swift` | AVVIO + DIVING sections, TTV toggle |
| `Views/DiveLiveView.swift` | Gauge TTV optional (default hidden); runtime-only panel |
| `App/DIRDivingApp.swift` | `DIRActivitySelectionStore` injection |
| `Services/AppNavigationStore.swift` | Removed legacy auto-skip to Live |
| `Services/DiveManager.swift` | Session mode recording + log metadata |
| `Models/DiveSession.swift` | Optional `watchActivityMode` / `watchDivingMode` |
| `Utils/WatchModeSelectionPreferences.swift` | `hasMultipleStableModes = true` |
| `Resources/en.lproj/Localizable.strings` | IT/EN startup keys |
| `Resources/it.lproj/Localizable.strings` | IT/EN startup keys |
| `project.yml` | Watch test target sources |

## Behavior

1. **Cold launch:** activity selection when `showActivitySelectionAtLaunch` (default **true**).
2. **Diving →** Gauge or Full Computer selection.
3. **Full Computer →** always requires explicit pre-dive confirmation (`AVVIA`); never auto-starts.
4. **Automatic startup** (selection OFF): uses default activity/mode; FC still requires confirmation.
5. **Apnea / Snorkeling:** routed to coming-soon screen (not launchable).
6. **Gauge TTV:** Settings toggle, default **OFF**; Live Dive hides TTV panel when off.
7. **Active dive:** mode changes blocked with localized toast; Settings startup rows disabled.
8. **Log:** `DiveSession` stores optional activity/diving mode strings at finalize.

## Not in scope (by design)

- Watch Bühlmann runtime, NDL, ceiling, deco stops, gas switch
- Full Computer live UI states (in-curve / deco layouts)
- Operational plan sync schema

## Tests

`DIRModesAndStartupFlowTests` — defaults, migration, routing matrix, FC confirm gate, dive-active block, Gauge vs FC completion paths.

## Next command

Command 02+ — shared Bühlmann core and Watch decompressive runtime.
