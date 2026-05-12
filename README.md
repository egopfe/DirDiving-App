# DIR DIVING - iOS Companion App

Copyright Federico Lombardo di Monte Iato 2026

This branch contains the iPhone companion interface for DIR DIVING. It is intentionally focused on the iOS app and does not include the Apple Watch dive-computer target.

## Branch Scope

`main-iOS` contains the stable iOS companion app. The experimental iOS companion branch is `codex/ios-experimental-features`.

The stable iOS app contains:

- iPhone logbook.
- Dive detail screen with summary metrics and depth profile.
- Dive analysis screen.
- Dive planner with Buhlmann ZH-L16C planning logic.
- Gas, MOD, decompression, and plan result screens.
- Equipment screen.
- Apple Watch sync status scaffold through WatchConnectivity.
- Subsurface CSV export support.
- iOS companion visual system aligned to the supplied dark cyan mockup.

Buddy Assist, Buddy Link, BLE pairing, and secure Buddy message authentication runtime code live only on the Apple Watch `codex/experimental-features` branch. iOS companion experiments that mirror or support those concepts live on `codex/ios-experimental-features`.

On `codex/ios-experimental-features`, the iOS app adds a `Buddy Lab` tab that mirrors the Watch experimental feature set as companion UI:

- secure pre-dive pairing review;
- confirmation code and key fingerprint display;
- Buddy Link `ONLINE` / `LOST` state;
- signal color, RSSI, and 15-second ping context;
- plausible direction card based on heading and shared bearing;
- preset message preparation using the same Watch message set.

The iOS branch still does not perform BLE pairing or underwater messaging directly.

The branch also adds an experimental `Explore` tab for the integrated snorkeling/apnea specification:

- premium dark-cyan snorkeling map surface with OSM/OpenSeaMap/offline-cache status;
- waypoint planning from tap-style actions, manual coordinate display, categories, colors, and route ordering;
- route planning workflow for iPhone -> WatchConnectivity -> local Watch cache -> offline underwater availability;
- apnea analytics dashboard with readiness, fatigue, recovery, depth, and duration chart;
- configurable warning settings for apnea duration, recovery ratio, drift threshold, and waypoint auto-switch;
- GPX/CSV export actions for route, marker, and analytics data.

## iCloud Persistence

The iOS experimental companion persists user data locally and mirrors supported data to iCloud Key-Value Store when the signed app has the iCloud capability enabled.

Persisted data:

- iOS logbook sessions.
- Technical planner mode and gas-planning input.
- Buddy Lab companion state.
- Explore route, waypoint, warning settings, and export/sync status.

Implementation:

- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Config/DIRDivingiOS.entitlements`

Runtime note: iCloud sync requires the Apple Developer iCloud capability and the configured iCloud container to be enabled for the app identifier. Without the entitlement/capability at signing time, data is still saved locally and the UI reports iCloud as unavailable.

The experimental iOS branch also extends the planner toward the technical-planner requirements document:

- cylinder pressure, reserve, SAC/RMV, and emergency SAC inputs;
- available gas, consumption, rock bottom, minimum gas, and turn pressure;
- MOD/PPO2, gas density, END/EAD, CNS, and OTU indicative outputs;
- warning cards for gas density, MOD/PPO2, END, and gas reserve risks;
- multi-segment timeline, team gas matching, contingency scenarios, GF comparison, and PDF-ready briefing card;
- premium dark technical cards consistent with the existing iOS companion mockup.

## Visual Design Standard

The iOS companion uses the supplied iPhone companion mockup as its product baseline:

- Black technical canvas.
- Cyan action color and chart accents.
- Compact operational cards.
- Dense logbook rows for fast scanning.
- Tab-based iPhone navigation.
- Technical planner surfaces instead of marketing-style pages.
- No Apple Watch runtime target in this branch.
- Experimental Buddy Lab surfaces must keep the same dark cyan premium iOS styling.

## Project Structure

```text
iOSApp/App/          iOS app entry point and Info.plist
iOSApp/DesignSystem/ shared iOS colors, backgrounds, and card styling
iOSApp/Models/       iOS dive, gas, and planner models
iOSApp/Services/     log store, planner, WatchConnectivity, CSV export
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

Experimental iOS companion notes live in:

```text
Docs/iOS/EXPERIMENTAL_FEATURES.md
```

The watchOS production app is maintained on `main`. Experimental Apple Watch Buddy/BLE work is maintained on `codex/experimental-features`. Experimental iOS companion work is maintained on `codex/ios-experimental-features`.
