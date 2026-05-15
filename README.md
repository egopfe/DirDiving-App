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
