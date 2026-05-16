# DIR DIVING - iOS Companion App

Copyright Federico Lombardo di Monte Iato 2026

This branch contains the iPhone companion interface for DIR DIVING. It is intentionally focused on the iOS app and does not include the Apple Watch dive-computer target or experimental Buddy Assist BLE features.

## Branch Scope

`main-iOS` contains:

- iPhone logbook.
- Dive detail screen with summary metrics and depth profile.
- Dive analysis screen.
- Dive planner with Buhlmann ZH-L16C planning logic.
- Gas, MOD, decompression, and plan result screens.
- Equipment screen.
- Apple Watch log import through WatchConnectivity using direct messages and queued user-info delivery.
- Local persistence with iCloud Key-Value Store mirroring for logbook sessions and planner inputs.
- Subsurface CSV export support, including entry and exit GPS columns when available.
- iOS companion visual system aligned to the supplied dark cyan mockup.

Buddy Assist, Buddy Link, BLE pairing, and secure Buddy message authentication live only on the `codex/experimental-features` branch.

## Visual Design Standard

The iOS companion uses the supplied iPhone companion mockup as its product baseline:

- Black technical canvas.
- Cyan action color and chart accents.
- Compact operational cards.
- Dense logbook rows for fast scanning.
- Tab-based iPhone navigation.
- Technical planner surfaces instead of marketing-style pages.
- No Buddy/BLE screens in this branch.

## Project Structure

```text
iOSApp/App/          iOS app entry point and Info.plist
iOSApp/DesignSystem/ shared iOS colors, backgrounds, and card styling
iOSApp/Models/       iOS dive, gas, and planner models
iOSApp/Services/     log store, planner, WatchConnectivity, CSV export
iOSApp/Config/       iCloud entitlement configuration
iOSApp/Utils/        formatting helpers
iOSApp/Views/        SwiftUI iPhone screens and components
iOSApp/Resources/    asset catalogs and app icon
Docs/iOS/            iOS build, validation, and feature notes
```

The project is configured with XcodeGen through `project.yml`.

## XcodeGen Target

```text
DIRDiving iOS
```

Target configuration:

- Platform: iOS
- Deployment target: iOS 17.0
- Bundle identifier: `com.egopfe.dirdiving.ios`
- Info.plist: `iOSApp/App/Info.plist`
- Sources: `iOSApp`

Frameworks:

- `Charts.framework`
- `WatchConnectivity.framework`
- `CoreLocation.framework`

## iCloud Persistence

The iOS companion persists user data locally and mirrors supported data to iCloud Key-Value Store when the app is signed with the iCloud capability.

Persisted data:

- iOS logbook sessions.
- Planner mode and gas-planning input.

Implementation:

- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Config/DIRDivingiOS.entitlements`

Runtime note: iCloud sync requires the Apple Developer iCloud capability and the configured iCloud container to be enabled for the app identifier. Without the entitlement/capability at signing time, data is still saved locally and the UI reports iCloud as unavailable.

## Watch Log Sync

The companion imports saved dives sent by the watchOS app through `WatchConnectivity`.

Supported delivery paths:

- immediate `sendMessage` when the iPhone app is reachable;
- queued `transferUserInfo` fallback for delivery when the iPhone app becomes available.

Imported dives are de-duplicated by session identifier before being saved in the iOS logbook and mirrored to iCloud when available.

## Build Notes

Generate the project on macOS:

```bash
xcodegen generate
```

Then open the generated Xcode project and build the `DIRDiving iOS` target.

This Windows environment cannot run a real `xcodebuild` validation because Xcode and the Apple SDKs are not available here. Final validation should be performed on macOS with Xcode.

## Documentation

iOS-specific notes live in:

```text
Docs/iOS/
```

The watchOS production app is maintained on `main`. Experimental Buddy/BLE work is maintained on `codex/experimental-features`.

## Branch Strategy

La strategia branch corrente e:

- `main`: codice stabile, orientato alla produzione Apple Watch, con Diving mode preservato come funzione primaria.
- `main-iOS`: codice stabile per iOS Companion.
- `codex/experimental-features`: ramo Apple Watch per UI e funzioni sperimentali Snorkeling, Apnea, Buddy Assist e schermate future.
- `codex/ios-experimental-features`: ramo iOS per companion UI, pianificazione, mappe, enrichment POI e superfici sperimentali.

Regole operative:

- Il lavoro di allineamento UI-only non deve modificare business logic, calcoli immersione, GPS, algoritmi bussola, persistenza o state machine.
- Ogni merge verso `main` deve preservare Diving mode, schermata live, warning risalita, haptic behavior, GPS entry/exit e log immersioni.
- Le funzioni sperimentali restano isolate finche non sono validate su hardware, build XcodeGen e test manuali.
- In caso di conflitto, preservare prima codice buildabile e comportamento Diving stabile, poi la UI master reference piu recente, poi gli aggiornamenti documentali.

## Platform And Build Matrix

| Branch | App | Stato | Note |
| --- | --- | --- | --- |
| `main` | Apple Watch | Stable | Diving mode, log, export, bussola, immagini, settings visuali. |
| `codex/experimental-features` | Apple Watch | Experimental | Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, POI, Apnea, Buddy Assist. |
| `main-iOS` | iOS Companion | Stable | Logbook, detail, planner/analysis surfaces, WatchConnectivity. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore, route planning, waypoint management, future POI enrichment and map/offline workflows. |

## UI Master References

Le UI Apple Watch devono seguire `MASTER_REFERENCE_DIVING_LIVE.png` come riferimento canonico per densita, gerarchia, colore e bordo. Le UI iOS devono seguire `iOS_look_feel.png`.

## Feature Matrix

La matrice feature aggiornata e in:

```text
Docs/DIR_DIVING_Feature_Comparison.csv
```

La specifica Snorkeling sperimentale e in:

```text
Docs/SNORKELING_EXPERIMENTAL_SPEC.md
```

## iOS Companion Roadmap

- Collegare POI Watch a payload sync leggero e enrichment iOS.
- Introdurre workflow MapLibre/OpenSeaMap/MBTiles sul companion iOS dopo valutazione licenze e prestazioni.
- Mantenere logbook, planner, export e sync WatchConnectivity separati dai runtime sperimentali Watch.
- Validare build XcodeGen su macOS per ogni ramo prima dei merge.
