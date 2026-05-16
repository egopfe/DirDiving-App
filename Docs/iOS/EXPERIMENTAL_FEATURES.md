# DIR DIVING iOS Experimental Features

This document tracks experimental iPhone companion work on the `codex/ios-experimental-features` branch.

The branch starts from `main-iOS` and is intended to stay aligned with the Apple Watch experimental branch:

```text
Apple Watch experimental branch: codex/experimental-features
iOS experimental branch:         codex/ios-experimental-features
Stable iOS branch:               main-iOS
```

## Branch Rules

- Keep stable iOS companion work on `main-iOS`.
- Keep exploratory iOS companion work on `codex/ios-experimental-features`.
- Do not add Apple Watch targets back into this iOS branch.
- Do not add Buddy/BLE watchOS runtime code directly to the iOS target.
- Mirror experimental Watch concepts only as iPhone companion UI, planning, status, configuration, documentation, or sync-support scaffolding.

## Implemented Companion Scope

The branch now mirrors the Apple Watch experimental Buddy Assist concepts as iPhone companion surfaces:

- `Buddy Lab` tab in the iOS tab bar.
- Secure pre-dive pairing review card with `VERIFY`, `TRUSTED`, confirmation code, and key fingerprint.
- Buddy Link status card with `ONLINE` / `LOST`, signal color, RSSI, and 15-second ping context.
- Compass card for heading, shared bearing, and "ultima direzione plausibile".
- Preset message preparation UI for:
  - `OK`
  - `RISALI`
  - `HO UN PROBLEMA`
  - `DOVE SEI?`
  - `TORNA INDIETRO`
  - `LOW GAS`
- Watch experimental sync card explaining that BLE pairing and actual message sending remain Watch-side runtime responsibilities.

## Snorkeling, Route Planning, And Apnea Analytics

The branch now implements the companion-side scope from `DIR_DIVING_Integrated_Development_Specs_FINAL.docx` as premium iOS UI.

Implemented surfaces:

- `Explore` tab in the main iOS tab bar.
- Premium dark-cyan snorkeling map mock surface with OSM/OpenSeaMap/offline-cache status, route line, waypoint pins, heatmap indicator, and route distance.
- Waypoint planner with tap-style waypoint creation, category icons, coordinate display, route ordering controls, and Watch sync action.
- Route planning card for waypoint count, distance, offline cache, and iPhone -> WatchConnectivity -> Watch cache workflow.
- Apnea analytics card with max depth, recovery trend, readiness score, fatigue trend, and apnea-duration chart.
- Sync/settings card for apnea duration warning, recovery ratio, drift threshold, and waypoint auto-switch.
- GPX/CSV export actions for route, marker, and analytics data.

Implementation files:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`

Map note: the current branch provides a premium MapLibre/OpenSeaMap-ready UI surface and route model. A production map engine should be selected and validated on-device before replacing the coded map preview with live tiles/offline MBTiles.

## iCloud Persistence

The branch now includes local persistence plus iCloud Key-Value Store mirroring for iOS companion data.

Persisted data:

- Logbook sessions.
- Technical planner state and gas inputs.
- Buddy Lab companion state.
- Explore route, waypoint, warning settings, and export/sync status.

The implementation uses `CloudSyncStore` as a small persistence adapter around `UserDefaults` and `NSUbiquitousKeyValueStore`. iCloud sync becomes active only when the app is signed with the iCloud capability and the configured container is available for the Apple ID.

The branch also implements the first technical-planner requirements from `DIR_DIVING_Requisiti_Sviluppo_Planner_Tecnico_iOS.docx`:

- Planner modes: recreational, advanced, technical, and cave/wreck future-ready.
- Profile inputs for depth, bottom time, temperature, salinity, and altitude.
- GF Low / GF High inputs for future decompression model refinement.
- Cylinder inputs for volume, start pressure, reserve pressure, SAC/RMV, and emergency SAC.
- Gas mix model with O2, He, calculated N2, role, MOD, max PPO2, and surface density.
- Available gas, segment consumption, remaining gas, rock bottom/minimum gas, and turn pressure.
- PPO2 at planned depth.
- Gas density at planned depth with green/warning/danger rating using 5.2 g/L and 6.2 g/L defaults.
- END and EAD calculations.
- CNS% and OTU indicative calculations.
- Planner warnings for MOD/PPO2, density, END, and gas reserve issues.
- Premium iOS cards for gas planning, density/END, reserve, warnings, and plan output.
- V1 multi-segment timeline for descent, bottom, ascent, stops, and gas switches.
- V1 gas matching for team members with SAC, available gas, reserve, and status.
- V2 contingency plans for lost gas, delayed ascent, and extended bottom time.
- V2 gradient-factor comparison table across 20/80, 30/70, 40/85, and custom values.
- V2 briefing card with PDF-ready summary lines for future share/export flow.

## Files

Experimental iOS files:

- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`
- `iOSApp/Views/PlannerView.swift`

## Implemented V1/V2 Notes

The V1/V2 implementation is intentionally informational and follows the product safety position:

- Multi-segment and contingency outputs are planning aids, not certified decompression instructions.
- GF comparison currently adjusts the existing simplified planner output and is ready for a stronger Buhlmann engine.
- Briefing export is represented as a PDF-ready/share-ready content card; actual PDF rendering can be wired to the iOS share pipeline in a later pass.
- Team gas matching uses the current local team profile data model and can be expanded to imported/team-synced divers.

Shared iOS files touched:

- `iOSApp/App/DIRDivingiOSApp.swift`
- `iOSApp/Views/ContentView.swift`
- `iOSApp/Views/MoreView.swift`

## Runtime Boundary

The iOS experimental branch does not add:

- Apple Watch target.
- CoreBluetooth runtime.
- Keychain Buddy authentication runtime.
- Direct underwater message sending.

Those capabilities remain in the Apple Watch experimental branch. iOS displays, prepares, reviews, and documents companion data only.

## Safety Position

Any Buddy Assist, Buddy Link, BLE proximity, secure pairing, or underwater communication feature remains experimental. The iPhone companion must not describe these features as certified dive safety, rescue, or underwater navigation systems.
