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
- Local persistence with iCloud Key-Value Store mirroring for dive logs and ascent-rate settings
- Dive profile chart
- CSV export compatible with Subsurface workflows
- Integrated compass screen
- Contextual `SET BEARING` / `CLEAR BEARING` compass action
- Dynamic ascent-rate gauge with green, yellow, and red zones
- User-configurable ascent-rate limits by depth band
- Red blinking warning and haptic feedback when ascent rate exceeds the current depth-band limit
- GPS entry and exit points captured with a best-effort surface fix
- Automatic WatchConnectivity transfer of saved dive logs to the iOS companion
- Experimental pre-water selector for Diving, Apnea, and Snorkeling
- Experimental Snorkeling mode with waypoint navigation, return-to-entry, GPS markers, and compass bearing delta
- Experimental Apnea mode with apnea timer, recovery assistant, dive counter, depth warning surface, and compass block
- Local persistence with iCloud Key-Value Store mirroring for dive logs, ascent-rate settings, and experimental exploration state
- Experimental Buddy Assist screen for secure pre-dive buddy identification and preset messages over a future BLE pairing path
- Custom image screen for bundled reference images, checklists, or static procedures

Experimental branch documentation is available in [`Docs/EXPERIMENTAL_FEATURES.md`](Docs/EXPERIMENTAL_FEATURES.md).

## Supported Platforms

DIR DIVING e organizzato come progetto XcodeGen multi-target:

- Apple Watch Ultra / watchOS 10+: app principale per Diving mode, bussola, log, GPS entry/exit, export e funzioni sperimentali isolate sui rami dedicati.
- iPhone / iOS 17+: companion app per logbook, dettaglio immersione, planner, risultato piano, analisi, export e sync WatchConnectivity.

Le istruzioni di build iOS companion sono anche in [`Docs/iOS/BUILD_AND_RUN.md`](Docs/iOS/BUILD_AND_RUN.md).

## Visual Design Standard

DIR DIVING uses the supplied Apple Watch Ultra dive-computer screenshot as its product visual baseline.

Future screens and feature work should preserve this look and feel:

- Apple Watch Ultra titanium case framing with a dark underwater bubbles background in presentation material
- Full black watch-first screen canvas for maximum underwater contrast
- Oversized white current-depth value, with the blue `m` unit aligned on the baseline
- Blue labels for water, temperature, depth, and technical measurement context
- Green immersion state, TTV panel, and safe action styling
- Yellow stopwatch panel, orange/yellow ascent caution zones, and red stop/danger states
- Thin rounded borders around operational panels and action controls
- Compact vertical spacing matching the supplied reference screenshot
- SwiftUI-drawn octopus logo at the top left of the live screen, matching the supplied reference instead of relying on emoji rendering
- Dedicated depth and ascent-gauge columns on the live screen so values, labels, and the colored ascent bar never overlap
- No generic dashboard cards, decorative gradients, or marketing-style layouts inside the watch UI

This premium visual system is now applied across the watch UI, not only the live dive screen:

- `DiveLiveView`: primary dive computer screen with octopus logo, depth, TTV, RunTime, separated ascent gauge, stopwatch, and controls
- `CompassView`: black full-screen compass surface with large heading, bearing panel, and bordered controls
- `AscentRateSettingsView`: custom ascent-limit controls with color-coded depth bands
- `ModeSelectionView`: pre-water activity selector using the same black technical panels
- `SnorkelingView`: GPS route, waypoint, marker, and return-to-entry surface
- `ApneaView`: apnea timer, recovery assistant, warning, and compass surface
- `BuddyAssistView`: pre-dive pairing, Buddy Link, proximity, message, and compass panels using the same black technical visual language
- `DiveLogListView` and `DiveDetailView`: log, detail, chart, GPS, and CSV export screens using the same metric panels and command buttons
- `UserImagesView`: bundled image selector with the same black canvas and bordered action controls

### iOS Companion Visual Alignment

Il companion iOS stabile segue `iOS_look_feel.png` come riferimento master. Le schermate principali usano sfondo nero, pannelli charcoal, accento ciano, tabbar scura e numeri tecnici leggibili:

- `LogbookView`: titolo Logbook, ricerca scura, lista immersioni a card, thumbnail e tabbar con attivo ciano.
- `DiveDetailView`: tab riepilogo/grafici/dettagli, immagine sito, griglia metriche, grafico profondita ciano, gas card ed export.
- `PlannerView`: titolo Planner, controllo segmentato modalita, input profilo, gas card con bordo neon e pulsante `Calcola Piano`.
- `PlanResultView`: tab piano/curva/grafici, griglia riepilogo, tabella piano risalita e curva Bühlmann in pannello scuro.

Questi allineamenti sono UI-only: non cambiano calcoli planner, sync, persistenza, data flow, navigazione o modelli.

Implementation helpers live in:

```text
Views/DiveUIComponents.swift
```

The visual reference image is stored at:

```text
Docs/ReferenceLookAndFeel.jpg
```

The current code preview is stored at:

```text
Docs/LiveDiveImmersionPremiumPreview.png
```

## Project Structure

```text
App/        watchOS app entry point and Info.plist
Config/     entitlements file
iOSApp/     iOS companion app, services, views, assets and entitlements
Models/     dive sessions, samples, GPS points, ascent status
Services/   dive, GPS, compass, haptics, export, image loading, App Intents
Utils/      formatting helpers
Views/      SwiftUI screens and components
Resources/  asset catalogs and bundled user resources
```

The project is configured with XcodeGen through `project.yml`.

## iCloud Persistence

The watchOS app persists user data locally and mirrors supported data to iCloud Key-Value Store when the app is signed with the iCloud capability.

Persisted data:

- Latest dive log sessions.
- User-configurable ascent-rate limits.

Implementation:

- `Services/CloudSyncStore.swift`
- `Services/DiveLogStore.swift`
- `Services/AscentRateSettingsStore.swift`
- `Config/DIRDiving.entitlements`

Runtime note: iCloud sync requires the Apple Developer iCloud capability and the configured iCloud container to be enabled for the app identifier. Without the entitlement/capability at signing time, data is still saved locally.

On the experimental branch, Snorkeling/Apnea exploration state is also mirrored to iCloud. Secure Buddy authentication keys remain in Keychain and are intentionally not mirrored through iCloud Key-Value Store.

## Main Navigation

DIR DIVING uses a vertical page-based `TabView`, designed for Apple Watch navigation with the Digital Crown.

Main screens:

1. Mode selector screen
2. Live dive screen
3. Snorkeling exploration screen
4. Apnea assistant screen
5. Compass screen
6. Ascent-rate settings screen
7. Buddy Assist screen
8. User images screen
9. Dive log screen

The compass is implemented as a full screen, not as a modal feature that must be launched. Bearing actions are contextual to the compass screen.

Terminologia UI: nelle schermate italiane nuove usare `BUSSOLA`; non introdurre `COMPASSO`.

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

- Adds the watchOS UI for secure pre-dive pairing, buddy identification, and sending preset messages.
- Stores the paired buddy identity locally after a successful trusted pairing.
- Stores Buddy Assist authentication material in Keychain through `SecureBuddyStore`.
- Requires manual confirmation of a shared pairing code before messages are enabled.
- Sends Buddy Assist messages as authenticated JSON envelopes with HMAC-SHA256, session, timestamp, and sequence checks.
- Rejects unauthenticated, stale, repeated, or non-secure Buddy Assist messages.
- Blocks pairing while `DiveManager.isDiveActive` is true.
- Cancels an active pairing scan if a dive starts before pairing completes.
- Adds an `OpenBuddyAssistIntent` so the Buddy Assist page can be opened from an Action Button or shortcut-style workflow when watchOS exposes it.
- Shows the mandatory safety warning: `Indicazione di prossimità sperimentale non affidabile per sicurezza immersione.`
- Shows the mandatory pairing warning: `Pairing solo prima dell'immersione. Non effettuare pairing in immersione.`
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
- Adds `Security.framework` for Keychain-backed trusted buddy keys.
- Uses the shared premium visual system from `DiveUIComponents.swift`, with black canvas, thin status borders, large readable values, and blue/green/yellow/red functional colors.

Operational rule: Buddy pairing must be completed before entering the water. DIR DIVING intentionally disables pairing while a dive is active and cancels any in-progress pairing scan when a dive starts, because pairing underwater is not a safe or reliable setup workflow.

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

Saved dives are also transferred to the iOS companion through `WatchConnectivity` when the paired iPhone app is installed and reachable. The watch uses direct messages when possible and queued `transferUserInfo` delivery as a fallback.

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

Schemes principali generati da `project.yml`:

- `DIRDiving Watch App`
- `DIRDiving iOS`

This environment cannot run a full watchOS `xcodebuild` validation because Xcode and the Apple watchOS SDK are not available here. Final validation should be performed on macOS with the target Apple Watch hardware or simulator configuration.

## Entitlement Status

The entitlements file currently exists at:

```text
Config/DIRDiving.entitlements
```

The Apple water depth/submersion entitlement is intentionally not filled in yet because approval is pending. After Apple grants the entitlement, update this file and rebuild with the correct signing profile.

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
| `main-iOS` | iOS Companion | Stable | Logbook, Dive Detail, Planner e Plan Result allineati alla reference iOS, WatchConnectivity, export e analisi. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore, route planning, waypoint management, future POI enrichment and map/offline workflows. |

## Mode Selection

La selezione modalita su Apple Watch separa:

- `Diving`: dive computer principale con profondita, TTV, RunTime, cronometro, gauge risalita e warning.
- `Snorkeling`: navigazione superficie con waypoint, ritorno al punto di partenza, marker/POI e mappe leggere.
- `Apnea`: timer apnea, recovery assistant, counter e warning sperimentali.

Le modalita condividono il design system nero/neon, ma non devono condividere logiche safety in modo implicito.

## UI Master References

Le UI Apple Watch devono seguire `MASTER_REFERENCE_DIVING_LIVE.png` come riferimento canonico per densita, gerarchia, colore e bordo. Le UI iOS devono seguire `iOS_look_feel.png`.

Riferimenti recenti per iOS main:

- `ios_logbook_reference.png`
- `ios_dive_detail_reference.png`
- `ios_planner_reference.png`
- `ios_plan_result_reference.png`

Riferimenti recenti per Snorkeling sperimentale:

- `01_snorkeling_live_final.png`
- `02_Mappa_Waypoint_reference.png`
- `03_Mappa_Ritorno_reference.png`
- `04_Direzione_Waypoint_reference.png`
- `05_Log_Marcatori_POI_AppleWatch_reference.png`
- `06_Dettaglio_Marcatore_POI_AppleWatch_reference.png`
- `08_Allarmi_Snorkeling_reference.png`

## Feature Matrix

La matrice feature aggiornata e in:

```text
Docs/DIR_DIVING_Feature_Comparison.csv
```

La specifica Snorkeling sperimentale e in:

```text
Docs/SNORKELING_EXPERIMENTAL_SPEC.md
```

La specifica Apnea sperimentale e in:

```text
Docs/APNEA_EXPERIMENTAL_SPEC.md
```

## Snorkeling Experimental Notes

Snorkeling su Apple Watch experimental include:

- Live screen con runtime, distanza, velocita media, profondita attuale e GPS status.
- Mappa Waypoint separata dalla Mappa Ritorno.
- Direzione Waypoint come funzione compass-style verso il waypoint, non bussola generica.
- `BUSSOLA` come terminologia obbligatoria; non usare `COMPASSO`.
- `MARCATORE` come quick-capture POI leggero.
- Dettaglio POI con metadata e nota `Da arricchire su iPhone`.
- Allarmi snorkeling specifici, separati dai settings globali.

Il Watch non modifica foto/commenti POI. Il companion iOS arricchira i POI dopo sync con foto, video, commenti, categorie, tag e note osservazione.

## Apnea Experimental Notes

Apnea su Apple Watch experimental include:

- Home Apnea dal selettore modalita.
- Menu con `Sessione`, `Tabelle`, `Statistiche` e `Logbook`.
- Sessione `Acque Libere`, countdown `03`, `02`, `01 / VAI` e surface waiting.
- Avvio automatico immersione da profondita e chiusura automatica al ritorno in superficie usando `ExplorationStore`.
- Stati visuali per discesa, fondo, risalita, allarme risalita, superficie, recovery, riepilogo, grafico, dettagli e salvataggio.
- Logbook e statistiche Apnea con dati reali dove esposti e placeholder TODO dove mancano campioni, HR, temperatura o aggregati.

Il companion iOS experimental aggiunge `Apnea Review` come card UI-only in `ExplorationCenterView`, con profilo mock e metriche placeholder finche non esiste sincronizzazione record Apnea dedicata.

## Known Limitations

- GPS e affidabile solo in superficie; sott'acqua usare ultimo fix valido e contesto bussola/waypoint come supporto informativo.
- Le mappe Watch sono leggere e SwiftUI-only; non scaricano tile online.
- OpenStreetMap public tile server non devono essere usati hard-coded per traffico production pesante.
- OpenSeaMap, GEBCO, EMODnet e MBTiles restano roadmap/future layer.
- Apnea e Snorkeling experimental non sono dispositivi certificati di sicurezza.
- Buddy Assist resta sperimentale e limitato dalle policy watchOS BLE.

## Roadmap

- Validare build XcodeGen su macOS per ogni ramo.
- Collegare POI Watch a payload sync leggero e enrichment iOS.
- Definire store persistente per soglie Snorkeling quando richiesto.
- Introdurre workflow MapLibre/OpenSeaMap/MBTiles sul companion iOS dopo valutazione licenze e prestazioni.
- Aggiungere report test hardware Apple Watch Ultra per Diving, Snorkeling e Apnea.
- Preparare export e documentazione Subsurface piu completa per import CSV.
