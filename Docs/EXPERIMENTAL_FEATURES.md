# DIR DIVING Experimental Features

This document describes the work currently living on the `codex/experimental-features` branch. These features are intentionally isolated from `main` because they are exploratory, may require hardware validation, and should not be treated as production-ready dive safety systems.

## Branch Scope

The experimental branch currently contains:

- User-configurable ascent-rate limits.
- Buddy Assist preset messaging UI.
- Buddy Link proximity indication.
- Pre-dive Buddy pairing and local buddy identification.
- Experimental BLE/CoreBluetooth scaffolding.
- Buddy direction UI based on heading, shared bearing, and last known direction.
- Premium Apple Watch Ultra-style UI alignment for shared and experimental screens.

## Premium UI Alignment

The experimental branch uses the same premium visual language as the supplied Apple Watch Ultra dive-computer reference:

- Black full-screen watch canvas.
- Thin rounded technical panels instead of standard list rows.
- Large readable numeric values with monospaced digits.
- Blue labels for technical context.
- Green, yellow, orange, and red used as functional state colors.
- Custom bordered command controls instead of generic watchOS bordered buttons.
- A drawn octopus mark at the live screen top left, matching the supplied reference without depending on emoji glyphs.
- Explicit live-screen layout regions for the large depth value and the right-side ascent gauge, preventing text and gauge overlap.

The live dive screen reference preview generated from the current code is:

```text
Docs/LiveDiveImmersionPremiumPreview.png
```

The shared styling helpers live in:

```text
Views/DiveUIComponents.swift
```

Screens using this system include:

- `DiveLiveView`
- `CompassView`
- `AscentRateSettingsView`
- `BuddyAssistView`
- `DiveLogListView`
- `DiveDetailView`
- `UserImagesView`

## User-Configurable Ascent-Rate Limits

The `ASC SET` screen lets the diver adjust ascent-rate thresholds directly on Apple Watch.

Configurable bands:

| Depth band | Default |
| --- | ---: |
| 40-30 m | 10 m/min |
| 30-20 m | 5 m/min |
| 20-6 m | 3 m/min |
| 6-0 m | 1 m/min |
| Other | 10 m/min |

Settings are persisted locally with `UserDefaults` through `AscentRateSettingsStore`.

The live dive engine uses the configured values through `AscentRateLimits` when calculating `AscentStatus`.

## Buddy Assist

Buddy Assist is an experimental communication-oriented screen for pre-dive buddy identification and predefined diver-to-diver messages.

Preset messages:

- `OK`
- `RISALI`
- `HO UN PROBLEMA`
- `DOVE SEI?`
- `TORNA INDIETRO`
- `LOW GAS`

Intended concept:

```text
Apple Watch <-> BLE <-> Apple Watch
```

Current implementation:

- `BuddyAssistView`: watchOS UI for the feature.
- `BuddyAssistService`: CoreBluetooth central-side scaffold.
- `BuddyAssistMessage`: preset message model.
- `OpenBuddyAssistIntent`: App Intent intended for Action Button / shortcut-style access when watchOS exposes it.
- Received-message banner with direct `ANSWER` flow.
- Pre-dive pairing status with `PAIRED` / `NOT PAIRED`.
- Locally persisted paired buddy identity from the connected peripheral.
- Pairing lockout while `DiveManager.isDiveActive` is true.
- Automatic cancellation of an in-progress pairing scan if a dive starts before pairing completes.
- Premium Buddy UI panels for pairing, Buddy Link, proximity, compass, received messages, answer flow, and command buttons.

### Pre-Dive Pairing Rule

Buddy pairing must be completed before entering the water.

DIR DIVING intentionally blocks pairing during an active dive and cancels any in-progress pairing scan if a dive starts before pairing completes. Pairing is a setup workflow, not an underwater operational workflow, because BLE discovery, authorization prompts, RSSI, and connection establishment are not reliable safety actions during immersion.

Mandatory UI disclaimer:

```text
Pairing solo prima dell'immersione. Non effettuare pairing in immersione.
```

## Buddy Link UI

The Buddy Assist screen now includes a dedicated Buddy Link section.

Displayed state:

- `ONLINE`: a buddy peripheral is connected.
- `LOST`: no buddy link is available.

Signal indication:

- Green dot: buddy appears near.
- Yellow dot: buddy appears distant / weaker signal but still linked.
- Red dot: no active buddy link.

The proximity indicator is based on RSSI readings. The app reads RSSI every 15 seconds while connected.

Safety warning shown in the UI:

```text
Indicazione di prossimità sperimentale non affidabile per sicurezza immersione.
```

This warning must remain visible because RSSI proximity is not a reliable underwater safety signal.

## Buddy Haptics

The experimental haptic behavior is:

- Buddy near: rapid double pulse.
- Buddy distant: slow pulse.
- Buddy message received: notification haptic for normal messages.
- Critical buddy message received: failure haptic for `HO UN PROBLEMA` and `LOW GAS`.

Implementation lives in `HapticService`:

- `buddyNearPulseIfNeeded()`
- `buddyDistantPulseIfNeeded()`

These haptics are throttled to avoid continuous vibration.

## Received Messages and Answer Flow

When a buddy message is received, the UI promotes it into a large visible banner:

- Header: `MESSAGGIO BUDDY`
- Main text: received preset message
- Critical styling for:
  - `HO UN PROBLEMA`
  - `LOW GAS`

The banner includes:

- `ANSWER`: switches the message grid into reply mode.
- `OK`: dismisses the active received message.

The reply mode uses the same preset message set:

- `OK`
- `RISALI`
- `HO UN PROBLEMA`
- `DOVE SEI?`
- `TORNA INDIETRO`
- `LOW GAS`

After sending an answer, the active received-message banner is cleared.

## Buddy Compass Block

The Buddy Assist UI includes a compass block intended to provide an "ultima direzione plausibile" view.

Displayed values:

- Last known direction.
- Shared bearing.
- Current heading.
- Plausible direction.

Current logic:

- `CompassManager` provides current heading and local bearing.
- `BuddyAssistService.updateCompassContext(...)` stores the latest compass context.
- Plausible direction currently prefers the shared bearing when available, otherwise it falls back to the last known heading.

This is a UI and state model for future validation. It is not a guaranteed buddy locator.

## BLE and watchOS Limitation

Apple documents that watchOS apps cannot advertise BLE peripheral services using `CBPeripheralManager`. This limits a pure Watch-to-Watch BLE architecture because one watch cannot reliably advertise itself as a custom BLE peripheral service for the other watch to discover.

Implication:

- The current implementation should be treated as central-side scaffolding and UI.
- A production version may require an external BLE relay, companion device, or a revised architecture tested on Apple Watch hardware.

Reference:

- Apple `CBPeripheralManager` documentation: https://developer.apple.com/documentation/corebluetooth/cbperipheralmanager

## Files Added or Modified

Main experimental files:

- `Models/AscentRateLimits.swift`
- `Services/AscentRateSettingsStore.swift`
- `Views/AscentRateSettingsView.swift`
- `Models/BuddyAssistMessage.swift`
- `Services/BuddyAssistService.swift`
- `Views/BuddyAssistView.swift`
- `Models/AppPage.swift`
- `Services/AppNavigationStore.swift`
- `Services/ActionButtonIntents.swift`
- `Services/HapticService.swift`
- `Docs/BuddyAssistPreview.png`

Project configuration:

- `project.yml` includes `CoreBluetooth.framework`.
- `App/Info.plist` includes `NSBluetoothAlwaysUsageDescription`.

## Preview

Current static Buddy Assist preview:

![Buddy Assist Preview](BuddyAssistPreview.png)

## Validation Checklist

Before promoting any part of this branch to `main`:

- Generate the Xcode project with XcodeGen on macOS.
- Build the watchOS target with Xcode.
- Validate that `TabView(selection:)` works correctly with vertical page navigation on watchOS.
- Confirm App Intent availability and Action Button assignment behavior on target Apple Watch hardware.
- Test CoreBluetooth authorization and scanning behavior on watchOS.
- Validate whether any external BLE relay or companion device is required.
- Test RSSI behavior in air and controlled water conditions.
- Confirm haptic patterns are noticeable but not excessive.
- Confirm the UI remains readable on the target Apple Watch screen size.

## Safety Position

Buddy Assist and Buddy Link must not be marketed or treated as a certified dive safety communication or rescue system. The feature is experimental and should only be considered an assistive interface for future validation.
