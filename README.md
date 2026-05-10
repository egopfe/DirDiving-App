# DIR DIVING - watchOS Dive App

Copyright Federico Lombardo di Monte Iato 2026

DIR DIVING is a SwiftUI watchOS application for Apple Watch Ultra-class devices. It focuses on essential in-water dive information, ascent-rate awareness, compass navigation, local dive logging, GPS entry/exit metadata, and CSV export for Subsurface.

> Status note: the app is prepared for Apple water submersion APIs, but the depth/submersion entitlement is still pending. Until the entitlement is granted and the app is signed with it, `CMWaterSubmersionManager` may report entitlement-related errors and will not deliver production depth data.

## Features

- Current, average, and maximum depth
- Water temperature
- RunTime
- TTV-style live value
- Manual stopwatch with Start, Stop, and Reset controls
- Local log of the latest 40 dives
- Dive profile chart
- CSV export compatible with Subsurface workflows
- Integrated compass screen
- Contextual `SET BEARING` / `CLEAR BEARING` compass action
- Dynamic ascent-rate gauge with green, yellow, and red zones
- User-configurable ascent-rate limits by depth band
- Red blinking warning and haptic feedback when ascent rate exceeds the current depth-band limit
- GPS entry and exit points captured with a best-effort surface fix
- Experimental Buddy Assist screen for preset buddy messages over a future BLE pairing path
- Custom image screen for bundled reference images, checklists, or static procedures

Experimental branch documentation is available in [`Docs/EXPERIMENTAL_FEATURES.md`](Docs/EXPERIMENTAL_FEATURES.md).

## Visual Design Standard

DIR DIVING uses an Apple Watch Ultra-style dive computer interface as its product visual baseline.

Future screens and feature work should preserve this look and feel:

- Full black watch-first canvas for maximum underwater contrast
- Large white depth and time values with monospaced-style numeric readability
- Blue labels for water, depth, and technical measurement context
- Green, yellow, orange, and red used only as functional state colors
- Thin rounded borders around operational panels and action controls
- Compact vertical spacing suited to Apple Watch Ultra displays
- No generic dashboard cards, decorative gradients, or marketing-style layouts inside the watch UI

The current live UI preview is stored at:

```text
Docs/CurrentCodeLiveViewPreview.png
```

## Project Structure

```text
App/        watchOS app entry point and Info.plist
Config/     entitlements file
Models/     dive sessions, samples, GPS points, ascent status
Services/   dive, GPS, compass, haptics, export, image loading, App Intents
Utils/      formatting helpers
Views/      SwiftUI screens and components
Resources/  asset catalogs and bundled user resources
```

The project is configured with XcodeGen through `project.yml`.

## Main Navigation

DIR DIVING uses a vertical page-based `TabView`, designed for Apple Watch navigation with the Digital Crown.

Main screens:

1. Live dive screen
2. Compass screen
3. Ascent-rate settings screen
4. Buddy Assist screen
5. User images screen
6. Dive log screen

The compass is implemented as a full screen, not as a modal feature that must be launched. Bearing actions are contextual to the compass screen.

## Live Dive Screen

The live screen shows:

- Current depth
- Maximum depth
- Average depth
- Water temperature, when available
- RunTime
- TTV value
- Manual stopwatch value
- Ascent-rate gauge
- Warning state when ascent rate is over limit

RunTime is controlled automatically by the dive session. The manual stopwatch is independent and can be started, stopped, or reset by the user.

## Ascent-Rate Limits

The ascent-rate limit changes according to current depth. The default profile is:

| Depth band | Limit |
| --- | ---: |
| 40-30 m | 10 m/min |
| 30-20 m | 5 m/min |
| 20-6 m | 3 m/min |
| 6-0 m | 1 m/min |
| Outside configured bands | 10 m/min |

The fallback limit of `10 m/min` outside the configured bands is intentional.

The `ASC SET` screen lets the diver customize each limit directly on Apple Watch:

- `40-30 m`
- `30-20 m`
- `20-6 m`
- `6-0 m`
- `Other`

Values are stored locally with `UserDefaults`, persist across app launches, and can be restored with `RESET STD`.

The app computes ascent rate by comparing consecutive depth samples. When depth decreases, DIR DIVING converts the difference into meters per minute.

## Warning and Haptics

When ascent rate exceeds the active limit:

- The ascent gauge enters the red zone
- The live depth warning state blinks in red
- Apple Watch plays `.failure` haptic feedback
- Haptic feedback is throttled to at most one warning every 2 seconds

The warning is intentionally kept inside the main live UI instead of using a separate fixed bottom banner.

## Compass

The compass screen uses `CoreLocation` and `CLHeading` to show:

- Current heading in degrees
- Cardinal direction
- Saved bearing
- Bearing clear action

Actions:

- `SET BEARING` stores the current heading as the active bearing
- `CLEAR` removes the active bearing

Required permission in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DIR DIVING uses location to save GPS entry and exit points.</string>
```

## Manual Stopwatch and App Intents

The on-screen stopwatch controls are:

- `START`: starts the manual stopwatch
- `STOP`: pauses the manual stopwatch
- `RESET`: returns the stopwatch to `00:00`

The project also includes two App Intents:

- `ToggleStopwatchIntent`: starts or stops the manual stopwatch
- `ResetStopwatchIntent`: resets the manual stopwatch

These intents are intended for Action Button or shortcut-style workflows where watchOS exposes them. Apple does not provide a public API for arbitrary long-press handling of the physical side button or Action Button inside a watchOS app, so the reset action remains available through the UI and through the dedicated intent.

## Automatic GPS Entry and Exit Points

DIR DIVING records surface GPS metadata for the beginning and end of a dive.

### Entry Point

When the watch enters submersion mode:

1. The app immediately stores the latest available GPS point.
2. It starts a best-effort GPS capture window.
3. If a better fix arrives within the capture window, the entry point is updated.
4. If no better fix arrives, the app keeps the latest available point.

This design reflects the fact that GPS is not reliable underwater. Entry position should be captured at the surface or immediately before descent.

### Exit Point

When the watch leaves submersion mode:

1. The app immediately stores the latest available GPS point.
2. It starts a best-effort surface GPS capture window.
3. If a better fix arrives, the exit point is saved with the dive log.
4. If no better fix arrives, the app keeps the latest available point.

The dive log is finalized after the exit best-effort capture completes, so the exported session contains the best available exit point.

### Display and Use

- Entry and exit coordinates are shown in the dive detail screen when available.
- GPS data represents surface entry/exit metadata, not underwater tracking.
- The app keeps location updates active while needed so a recent point is available.

## Dive Log

Dive sessions are stored locally in the app documents directory as JSON. The log keeps the latest 40 sessions and sorts them by start date.

Each saved session includes:

- Start and end date
- Duration
- Maximum depth
- Average depth
- Average, minimum, and maximum water temperature when available
- TTV value
- Entry and exit GPS points when available
- Full depth/temperature sample list

## Buddy Assist

The experimental `BUDDY` screen is designed for quick preset messages between divers:

- `OK`
- `RISALI`
- `HO UN PROBLEMA`
- `DOVE SEI?`
- `TORNA INDIETRO`
- `LOW GAS`

The intended concept is:

```text
Apple Watch <-> BLE <-> Apple Watch
```

Current implementation status:

- Adds the watchOS UI for pairing and sending preset messages.
- Adds an `OpenBuddyAssistIntent` so the Buddy Assist page can be opened from an Action Button or shortcut-style workflow when watchOS exposes it.
- Shows the mandatory safety warning: `Indicazione di prossimità sperimentale non affidabile per sicurezza immersione.`
- Shows an experimental proximity dot:
  - green when RSSI suggests the buddy is near;
  - yellow when RSSI suggests the buddy is around the distant / mid-range zone;
  - red when no buddy link is available.
- Adds Buddy Link status with `ONLINE` / `LOST`.
- Adds haptic patterns for proximity changes:
  - slow pulse when the buddy is distant;
  - rapid double pulse when the buddy is near.
- Adds a compass block with last known direction, shared bearing, current heading, and an estimated `Direzione plausibile`.
- Reads buddy RSSI every 15 seconds while connected.
- Adds a `BuddyAssistService` with CoreBluetooth central-side scaffolding.
- Defines a custom BLE service UUID and message characteristic UUID.
- Adds the required Bluetooth privacy usage string to `Info.plist`.

Important limitation: Apple documents that watchOS apps cannot advertise BLE peripheral services with `CBPeripheralManager`. A true direct Watch-to-Watch BLE pairing architecture is therefore not currently reliable as a production-only Apple Watch implementation. A production path may require a companion device, an external BLE relay, or a revised architecture validated on Apple hardware.

## Subsurface CSV Export

The dive detail screen can generate and share a CSV file for Subsurface-style import workflows.

Workflow:

1. Open the dive log.
2. Select a dive.
3. Tap `Generate Subsurface CSV`.
4. Tap the share button and send the CSV to iPhone, Mac, Files, AirDrop, or email.
5. In Subsurface, open `File > Import > Import log files > CSV`.
6. Map the columns:
   - `time_seconds` = elapsed time in seconds
   - `depth_m` = depth in meters
   - `temperature_c` = water temperature in degrees Celsius

The CSV also includes entry and exit latitude/longitude columns when available.

## User Images

DIR DIVING includes a `Screens` view for bundled static images. This is useful for:

- Dive checklists
- Personal procedures
- Reference tables
- Static reminders
- High-contrast underwater-readable notes

### Adding Images

watchOS standalone apps cannot directly read arbitrary files from a PC or Mac filesystem. DIR DIVING therefore loads images that are bundled with the app.

To add images:

1. Prepare `PNG`, `JPG`, `JPEG`, or `HEIC` images.
2. Use dimensions matching, or proportional to, the target Apple Watch screen.
3. Copy the images into:

```text
Resources/UserImages/
```

4. Regenerate the Xcode project if using XcodeGen:

```bash
xcodegen generate
```

5. Build and install the app on Apple Watch.
6. Open DIR DIVING and navigate to the `Screens` view.

### Recommended Image Style

- Portrait orientation
- Dark background
- Large text
- High contrast
- Minimal fine detail

For future file transfer without recompiling the app, the project could be extended with an iPhone companion app and `WatchConnectivity`.

## Apple Water Submersion API Compatibility

The dive engine uses:

- `CMWaterSubmersionManager.waterSubmersionAvailable`
- `CMWaterSubmersionManagerDelegate`
- `CMWaterSubmersionEvent`
- `CMWaterSubmersionMeasurement`
- `CMWaterTemperature`
- `manager(_:errorOccurred:)`

Delegate methods are marked `nonisolated` and bridge back to the main actor for Swift concurrency compatibility.

## Build Notes

This repository is intended to be generated and built on macOS with Xcode and XcodeGen.

```bash
xcodegen generate
```

Then open the generated Xcode project and build the watchOS target.

This environment cannot run a full watchOS `xcodebuild` validation because Xcode and the Apple watchOS SDK are not available here. Final validation should be performed on macOS with the target Apple Watch hardware or simulator configuration.

## Entitlement Status

The entitlements file currently exists at:

```text
Config/DIRDiving.entitlements
```

The Apple water depth/submersion entitlement is intentionally not filled in yet because approval is pending. After Apple grants the entitlement, update this file and rebuild with the correct signing profile.
