# DIR DIVING - watchOS Dive App

Copyright Federico Lombardo di Monte Iato 2026

DIR DIVING is a SwiftUI watchOS application for Apple Watch Ultra-class devices. It focuses on essential in-water dive information, ascent-rate awareness, compass navigation, local dive logging, GPS entry/exit metadata, and CSV export for Subsurface.

## Safety and limitations (MAIN)

DIR DIVING is a **support and logging tool**: it records dives, surfaces ascent awareness, and syncs to the iPhone companion for review and **indicative** planning. It is **not** a certified dive computer unless a future release explicitly documents certification. It does **not** replace training, dive-center rules, certified equipment, or human judgment. Planner and Bühlmann-style presentations are **indicative** — verify with certified tools. GPS is meaningful **at the surface**; underwater or poor-sky conditions mean fixes can be missing — missing data must not be read as “dive success.”

**Recent MAIN UI/UX pass:** layout, typography, contrast, tab labels, accessibility text, empty states, disclaimers, and documentation only — **no** changes to decompression math, gas models, TTV/TTR calculations, SAC/CNS/OTU math, sensor sampling, or sync transport rules.

> Status note: the app is prepared for Apple water submersion APIs, but the depth/submersion entitlement is still pending. Until the entitlement is granted and the app is signed with it, `CMWaterSubmersionManager` may report entitlement-related errors and will not deliver production depth data.

## Depth Entitlement And Signing Checklist

Local configuration is internally aligned for the Watch target: `project.yml` points `DIRDiving Watch App` at `Config/DIRDiving.entitlements`, `App/Info.plist` declares `WKBackgroundModes` with `underwater-depth`, and the Watch entitlements include `com.apple.developer.coremotion.water-submersion`.

External validation is still required before release:

- On macOS/Xcode, run `xcodegen generate` and build the `DIRDiving Watch App` scheme with the Apple SDK.
- In Apple Developer portal, confirm the App ID `com.egopfe.dirdiving` has the approved water submersion/depth entitlement and iCloud container `iCloud.com.egopfe.dirdiving`.
- On a real Apple Watch Ultra-class device, confirm automatic depth launch and live `CMWaterSubmersionManager` depth samples; this cannot be validated from Windows or simulator alone.

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
- Stable pre-water selector for Diving on `main`; Snorkeling, Apnea and Buddy Assist remain isolated to experimental branches
- Local persistence with iCloud Key-Value Store mirroring for dive logs, ascent-rate settings, Watch sync queues and supported iOS companion state
- Custom image screen for bundled reference images, checklists, or static procedures

Experimental branch documentation is available in [`Docs/EXPERIMENTAL_FEATURES.md`](Docs/EXPERIMENTAL_FEATURES.md).

## Supported Platforms

DIR DIVING e organizzato come progetto XcodeGen multi-target:

- Apple Watch Ultra / watchOS 10+: app principale per Diving mode, bussola, log, GPS entry/exit, export e funzioni sperimentali isolate sui rami dedicati.
- iPhone / iOS 17+: companion app per logbook, dettaglio immersione, planner, risultato piano, analisi, export e sync WatchConnectivity.

Le istruzioni di build sono in [`Docs/BUILD_VALIDATION.md`](Docs/BUILD_VALIDATION.md) e in [`Docs/iOS/BUILD_AND_RUN.md`](Docs/iOS/BUILD_AND_RUN.md).

## Strategia dei rami (Branch Strategy)

- **`main`**: codice orientato alla stabilità **Diving** su Apple Watch e al companion iOS incluso nello stesso workspace XcodeGen. Le funzioni Apnea, Snorkeling, Buddy Assist e le mappe sperimentali **non** fanno parte del target MAIN (`project.yml` esclude i file sperimentali dal build production). I merge verso `main` devono **preservare** il comportamento Diving, GPS surface-only, **BUSSOLA** (terminologia UI: non usare «COMPASSO»), export Subsurface e sync documentati.
- **`main-iOS`**: ramo di lavoro storico/parallelo per allineamenti UI iOS; può divergere da `main`. Allineare la documentazione quando le feature companion sono equivalenti.
- **`codex/experimental-features`**: Watch sperimentale (Snorkeling Live, mappe waypoint/ritorno, Apnea workflow esteso, Buddy Assist, ecc.). Non importare questi file nel target MAIN senza revisione esplicita.
- **`codex/ios-experimental-features`**: iOS sperimentale (Explore Lab, Buddy Lab, concept mappe). Isolato da App Store candidate su `main`.
- **Allineamenti UI-only** su `main`: possono toccare layout, copy, accessibilità e documentazione **senza** modificare algoritmi di decompressione, modello gas, calcoli TTV/TTR/SAC/CNS/OTU, sampling sensori o regole di sync — vedi [`Docs/MAIN_UX_COMPLETION_REPORT.md`](Docs/MAIN_UX_COMPLETION_REPORT.md).

### Matrice funzionalità (CSV)

La tabella aggiornata con colonne Area / Branch / App / Mode / Feature / Status / Description / UI Reference / Notes:

[`Docs/DIR_DIVING_Feature_Comparison.csv`](Docs/DIR_DIVING_Feature_Comparison.csv)

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
- `ModeSelectionView`: stable Diving selector using the same black technical panels; experimental modes are excluded from MAIN target membership
- `DiveLogListView` and `DiveDetailView`: log, detail, chart, GPS, and CSV export screens using the same metric panels and command buttons
- `UserImagesView`: bundled image selector with the same black canvas and bordered action controls

### iOS Companion Visual Alignment

Il companion iOS stabile segue `iOS_look_feel.png` come riferimento master. Le schermate principali usano sfondo nero, pannelli charcoal, accento ciano, tabbar scura e numeri tecnici leggibili:

- `LogbookView`: titolo Logbook, ricerca scura, lista immersioni a card, thumbnail e tabbar con attivo ciano.
- `DiveDetailView`: tab riepilogo/grafici/dettagli, immagine sito, griglia metriche, grafico profondita ciano, gas card ed export.
- `PlannerView`: titolo Planner, controllo segmentato modalita, input profilo, gas card con bordo neon e pulsante `Calcola Piano`.
- `PlanResultView`: tab piano/curva/grafici, griglia riepilogo, tabella piano risalita e curva Bühlmann in pannello scuro.
- `AnalysisView`: metriche logbook reali, SAC medio, distribuzione gas, **riepilogo route GPS** da entry/exit dei log (nessun motore mappe esterno).
- `EquipmentView`: profilo attrezzatura persistente, checklist e SAC pianificazione.
- `MoreView` / `Settings`: onboarding operativo, preferenze locali unita/export, stato Watch sync, cloud backup, retry sync, conflitti Watch, tombstone iCloud KVS e note Subsurface.

Questi allineamenti sono UI-only: non cambiano calcoli planner, sync, persistenza, data flow, navigazione o modelli.

### Stable UX / Accessibility Corrections

Gli ultimi fix sulla superficie stable separano chiaramente `main` dalle funzioni sperimentali:

- Apple Watch `main` espone solo il flusso stabile Diving, bussola, settings, immagini e log.
- Apnea, Snorkeling e Buddy Assist restano documentati e isolati nei rami experimental.
- La schermata `Settings` Watch e raggiungibile dalla navigazione principale e collega limiti risalita, allarmi persistenti, info device/batteria, stato GPS, stato sensore profondita, stato sync e preferenza haptic.
- La bussola Watch usa azioni esplicite `SET BEARING` e `CLEAR`, senza promettere un callback del tasto laterale non controllato dall'app.
- Le conferme GPS entry/exit sono mostrate dal lifecycle immersione e non usano coordinate finte quando il fix non e disponibile.
- L'export Watch dalla lista esporta l'ultima immersione e mostra share/error feedback.
- Il companion iOS stabile espone **cinque tab**: `Logbook`, `Analisi`, `Planner`, `Attrezzatura`, `Altro`; dati reali o etichettati come informativi/locali.
- Il planner iOS mostra disclaimer in-app e separa i tab risultato `PIANO`, `CURVA BÜHLMANN` e `GRAFICI`.
- Il progetto MAIN esclude Apnea, Snorkeling, Buddy Assist e concept experimental dal target membership generato da XcodeGen.

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
- Pending WatchConnectivity session queue for unsent Watch logs.
- iOS companion profile/planner/equipment data where available.
- Deleted iOS log tombstones, so KVS reloads do not silently restore removed sessions.

Implementation:

- `Services/CloudSyncStore.swift`
- `Services/DiveLogStore.swift`
- `Services/AscentRateSettingsStore.swift`
- `Config/DIRDiving.entitlements`

Runtime note: iCloud sync requires the Apple Developer iCloud capability and the configured iCloud container to be enabled for the app identifier. Without the entitlement/capability at signing time, data is still saved locally.

On the experimental branches, Snorkeling/Apnea exploration state and lightweight sync queue status are also mirrored where implemented. Secure Buddy authentication keys remain in Keychain and are intentionally not mirrored through iCloud Key-Value Store.

## Main Navigation

DIR DIVING uses a vertical page-based `TabView`, designed for Apple Watch navigation with the Digital Crown.

Main screens on `main`:

1. Mode selector screen
2. Live dive screen
3. Compass screen
4. Settings screen
5. User images screen
6. Dive log screen

The compass is implemented as a full screen, not as a modal feature that must be launched. Bearing actions are contextual to the compass screen.

Terminologia UI: nelle schermate italiane nuove usare `BUSSOLA`; non introdurre `COMPASSO`.

Experimental Apnea, Snorkeling and Buddy Assist screens are intentionally not part of `main` navigation or MAIN target membership. They remain in `codex/experimental-features` until hardware, UX, safety and build validation are complete.

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

Buddy Assist is experimental-only and is excluded from the current MAIN Watch target. The experimental `BUDDY` screen is designed for quick preset messages between divers:

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
- Adds the required Bluetooth privacy usage string only on branches where the experimental Buddy/BLE surface is target-included.
- Adds `Security.framework` for Keychain-backed trusted buddy keys.
- Uses the shared premium visual system from `DiveUIComponents.swift`, with black canvas, thin status borders, large readable values, and blue/green/yellow/red functional colors.

Operational rule: Buddy pairing must be completed before entering the water. DIR DIVING intentionally disables pairing while a dive is active and cancels any in-progress pairing scan when a dive starts, because pairing underwater is not a safe or reliable setup workflow.

Important limitation: Apple documents that watchOS apps cannot advertise BLE peripheral services with `CBPeripheralManager`. A true direct Watch-to-Watch BLE pairing architecture is therefore not currently reliable as a production-only Apple Watch implementation. A production path may require a companion device, an external BLE relay, or a revised architecture validated on Apple hardware.

## Subsurface CSV Export

The dive detail screen can generate and share a CSV file for Subsurface-style import workflows.

Workflow:

1. Open the dive log.
2. Select a dive.
3. Tap `ESPORTA (SUBSURFACE)` on Watch detail or `Genera CSV Subsurface` on iOS detail.
4. Tap the share button / `Condividi CSV` and send the CSV to iPhone, Mac, Files, AirDrop, or email.
5. In Subsurface, open `File > Import > Import log files > CSV`.
6. Map the columns:
   - `time_seconds` = elapsed time in seconds
   - `depth_m` = depth in meters
   - `temperature_c` = water temperature in degrees Celsius

The CSV also includes entry and exit latitude/longitude columns when available.

The Watch log list also exposes `ESPORTA ULTIMA (SUBSURFACE)` for the latest saved dive and shows error feedback when no dive can be exported.

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

## MAIN Readiness Notes

Gli ultimi aggiornamenti MAIN readiness aggiungono:

- app icon asset reference validation per Watch e iOS;
- esclusione XcodeGen delle sorgenti experimental dai target MAIN;
- rimozione della privacy string Bluetooth dal Watch MAIN, perche Buddy Assist non e una funzione production visibile;
- allarmi Watch con soglie profondita, tempo e batteria editabili/persistite/applicate;
- haptic feedback per START/STOP/RESET cronometro, rispettando il toggle haptics;
- iOS Watch sync con conflitti visibili e risoluzione manuale;
- tombstone iOS per evitare che log cancellati riappaiano da KVS;
- import CSV iOS, profilo attrezzatura persistente, Route Review e Analysis basati su dati logbook;
- planner iOS con warning dinamici e copy non certificato.

Build finale, `xcodegen generate` e `xcodebuild` devono essere eseguiti su macOS.

## Latest MAIN UX Audit Implementation

Dopo il report `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx`, i rami MAIN hanno ricevuto un pass UX mirato e separato dai rami sperimentali:

- Watch MAIN: `Settings`, `AlarmSettings`, `DiveLive` e `DiveLogList` chiariscono metriche/local-only, shortcut/App Intents, avvio manuale, stato log vuoto, export non disponibile senza log e conferma delete.
- Watch MAIN: le soglie allarme restano locali sul Watch, non sincronizzate con iPhone; i controlli +/- sono piu grandi e scrollabili per ridurre clipping e migliorare uso con guanti.
- iOS MAIN: `Settings` marca unita/export come preferenze non editabili o local-only quando non esiste ancora un contratto sync production.
- iOS MAIN: `Logbook`, `Route Review`, `Analysis` e `Gear` aggiungono empty state o conferme distruttive per import/sync assenti, nessuna rotta, nessuna statistica, delete immersione e reset profilo.
- Non sono stati modificati algoritmi GPS, bussola, profondita, risalita, decompressione, persistenza dati o modelli business; il pass e UI/UX e copy-only salvo conferme SwiftUI.

## Latest MAIN UX Audit And Documentation TODO

Il report pre-modifica MAIN piu recente e:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx
```

Stato documentato dopo l'audit:

- Le superfici principali MAIN sono raggiungibili: Apple Watch `Diving`, `BUSSOLA`, settings, immagini, log/export; iOS `Logbook`, `Route Review`, `Analysis`, `Planner`, `Gear`, `Settings`.
- Risolti nel pass MAIN UX: empty state iOS principali, conferme delete/reset, spiegazione Action Button/App Intents, copy di avvio manuale, settings iOS marcati read-only/local-only dove appropriato e controlli allarme Watch piu grandi.
- Restano TODO di allineamento sync: settings Watch/iOS sono dichiarati local-only e la policy cloud conflict oltre KVS resta roadmap.
- Restano TODO build/config da verificare su macOS: l'asset catalog iOS MAIN deve contenere i PNG citati da `AppIcon.appiconset/Contents.json`; `xcodegen generate` e le build Watch/iOS devono confermare i fix runtime piu recenti.
- L'audit resta snapshot pre-modifica; i fix MAIN UX successivi sono committati separatamente dalla documentazione.

## Entitlement Status

The entitlements file currently exists at:

```text
Config/DIRDiving.entitlements
```

Il file entitlements Watch include la chiave `com.apple.developer.coremotion.water-submersion`, coerente con `WKBackgroundModes` / `underwater-depth` in `App/Info.plist` e con `CODE_SIGN_ENTITLEMENTS: Config/DIRDiving.entitlements` in `project.yml`.

Questa configurazione non equivale a validazione release: prima di TestFlight/App Store serve confermare in Apple Developer portal che l'App ID `com.egopfe.dirdiving` abbia l'entitlement depth/submersion approvato, poi generare/buildare con Xcode su macOS e validare su Apple Watch Ultra reale.

## Branch Strategy

La strategia branch corrente e:

- `main`: codice stabile, orientato alla produzione Apple Watch, con Diving mode preservato come funzione primaria.
- `main-iOS`: codice stabile per iOS Companion.
- `codex/experimental-features`: ramo Apple Watch per UI e funzioni sperimentali Snorkeling, Apnea, Buddy Assist e schermate future.
- `codex/ios-experimental-features`: ramo iOS per companion UI, pianificazione, mappe, enrichment POI e superfici sperimentali.

Regole operative:

- Il lavoro di allineamento UI-only non deve modificare business logic, calcoli immersione, GPS, algoritmi bussola, persistenza o state machine.
- Ogni merge verso `main` deve preservare Diving mode, schermata live, warning risalita, haptic behavior, GPS entry/exit e log immersioni.
- I rami `main` e `main-iOS` non devono esporre Apnea, Snorkeling, Buddy Assist o placeholder sperimentali come flussi production.
- Le funzioni sperimentali restano isolate finche non sono validate su hardware, build XcodeGen e test manuali.
- In caso di conflitto, preservare prima codice buildabile e comportamento Diving stabile, poi la UI master reference piu recente, poi gli aggiornamenti documentali.

## Platform And Build Matrix

| Branch | App | Stato | Note |
| --- | --- | --- | --- |
| `main` | Apple Watch | Stable | Diving mode, log, export, BUSSOLA, immagini, settings raggiungibili, allarmi/haptic persistenti, GPS entry/exit confirmation, sync queue, helper shortcut/App Intents, empty state log e target membership senza experimental. |
| `codex/experimental-features` | Apple Watch | Experimental | Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, POI con log/dettaglio/conferma, allarmi Snorkeling persistenti locali, Apnea, haptics sperimentali, settings sperimentali raggiungibili e Buddy Assist marcato lab-only. |
| `main-iOS` | iOS Companion | Stable | Logbook, Dive Detail, Route Review, Analysis, Planner/Plan Result, Gear, Settings, WatchConnectivity, iCloud KVS, CSV import/export, Subsurface, empty state e conferme distruttive. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore Lab, route planning, waypoint management, POI enrichment mock/TODO, Apnea Review interattiva, queue/status sync sperimentale, impostazioni locali editabili e note map/offline. |

## Mode Selection

La selezione modalita su Apple Watch separa:

- `Diving` su `main`: dive computer principale con profondita, TTV, RunTime, cronometro, gauge risalita, warning, bussola, settings, immagini e log.
- `Snorkeling` su experimental: navigazione superficie con waypoint, ritorno al punto di partenza, marker/POI e mappe leggere.
- `Apnea` su experimental: timer apnea, recovery assistant, counter e warning sperimentali.

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
- `MARCATORE` come quick-capture POI leggero con conferma, haptic, payload timestamp/GPS/profondita/temperatura/bearing/waypoint/sessione quando disponibili e stato `Da arricchire su iPhone`.
- Log Marcatori e Dettaglio POI raggiungibili da Watch, con metadata, stato enrichment e chiara boundary di sync verso iPhone.
- Allarmi snorkeling specifici, separati dai settings globali, persistiti localmente con `AppStorage` in attesa di uno store dedicato.
- Schermate raggiungibili per Calibrazione Bussola e Legenda Icone Mappe senza modificare algoritmi bussola o motore mappe.

Il Watch non modifica foto/commenti POI. Il companion iOS espone una superficie di enrichment per foto, video, commenti, categorie, tag e note osservazione, ma media upload/save e sync reale restano marcati come TODO sperimentali.

## Apnea Experimental Notes

Apnea su Apple Watch experimental include:

- Home Apnea dal selettore modalita.
- Menu con `Sessione`, `Tabelle`, `Statistiche` e `Logbook`.
- Sessione `Acque Libere`, configurazione locale persistente per intervallo superficie e profondita massima allarme, countdown `03`, `02`, `01 / VAI` con haptic tick e surface waiting.
- Avvio automatico immersione da profondita e chiusura automatica al ritorno in superficie usando `ExplorationStore`.
- Stati visuali per discesa, fondo, risalita, allarme risalita, superficie, recovery, riepilogo, grafico, dettagli e salvataggio.
- Logbook e statistiche Apnea con dati reali dove esposti e placeholder TODO dove mancano campioni, HR, temperatura o aggregati.
- Pannelli espliciti per `Watch -> iPhone Apnea` e settings sync, senza introdurre una nuova architettura WatchConnectivity.

Il companion iOS experimental aggiunge `Apnea Review` in `ExplorationCenterView` con tab interattivi `Riepilogo`, `Grafico` e `Dettagli`, profilo mock e metriche placeholder finche non esiste sincronizzazione record Apnea dedicata.

## Latest Experimental UX Audit Fixes

Il documento Word dell'audit e conservato in `Docs/EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx`. Gli ultimi fix implementati sui rami sperimentali aggiungono:

- Watch Snorkeling: conferma `MARCATORE SALVATO`, haptic, log marcatori, dettaglio marcatore, GPS unavailable state, settings Snorkeling, allarmi persistenti locali, calibrazione Bussola e legenda mappe.
- Watch Apnea: configurazione locale persistente, allarmi raggiungibili, haptic countdown/start/save/recovery, azioni esplicite su riepilogo/grafico/dettagli/salvataggio e boundary sync dichiarate.
- iOS Experimental Explore Lab: sezioni Snorkeling Review, POI/Osservazioni, Waypoint Planning, Apnea Review e Experimental Settings; POI enrichment mock, manifest route/settings per Watch e note MBTiles/MapLibre/OpenSeaMap.
- Tutte le funzioni non production-ready sono etichettate come `Mock`, `TODO`, `Non ancora sincronizzato` o `Sync sperimentale` per evitare false promesse UX.

### Latest Experimental Blocker Resolution

Dopo il report `Docs/EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx`, i rami sperimentali hanno ricevuto un pass di contenimento UX senza modificare algoritmi GPS, bussola, profondita, risalita o decompressione:

- Watch experimental: `SettingsView`, `AlarmSettingsView`, `AscentRateSettingsView` e `InfoView` sono raggiungibili dalla navigazione sperimentale; le preferenze locali espongono unita metriche, haptics, Always-On safe, soglie generali e limiti risalita.
- Watch Snorkeling: la sessione si avvia visibilmente, le soglie profondita/tempo/distanza sono enforce locali con haptic warning, la batteria resta indicata come non cablata, e i pannelli POI mostrano stato queue/delivery experimental.
- Watch Apnea: profondita non disponibile mostra `--`; HR, batteria e temperatura non usano piu valori finti ma `HR OFF`, `BAT --`, `TEMP --`; profilo/statistiche restano chiaramente schematiche o TODO.
- Watch Buddy Assist: il flusso e marcato `LAB-ONLY` e disabilitato finche l'architettura BLE/relay Watch non e validata.
- iOS Experimental: Planner result e export sono marcati `PIANO LAB` / `EXPORT LAB`; Logbook e Dive Detail non mostrano piu affordance statiche come azioni reali; More espone impostazioni locali per unita, CSV export, diagnostica sync e gate safety mock.
- iOS Explore Lab: route/settings manifest usano una coda locale sperimentale visibile con conteggio, stato e revisione manuale; il receiver iOS mostra il numero di payload experimental ricevuti e lo stato import, senza promettere merge production.

## Known Limitations

- GPS e affidabile solo in superficie; sott'acqua usare ultimo fix valido e contesto bussola/waypoint come supporto informativo.
- Le mappe Watch sono leggere e SwiftUI-only; non scaricano tile online.
- OpenStreetMap public tile server non devono essere usati hard-coded per traffico production pesante.
- OpenSeaMap, GEBCO, EMODnet e MBTiles restano roadmap/future layer; il companion iOS mostra solo stato/TODO e non include ancora un motore MapLibre reale.
- Apnea e Snorkeling experimental non sono dispositivi certificati di sicurezza.
- Buddy Assist resta sperimentale, lab-only e limitato dalle policy watchOS BLE.
- Watch -> iPhone POI, Watch -> iPhone Apnea, iPhone -> Watch route/waypoint/settings, duplicate prevention e offline queue hanno stato/queue UX sperimentale; non sono ancora una pipeline production completa.

## Roadmap

- Validare build XcodeGen su macOS per ogni ramo.
- Evolvere POI Watch e Apnea sync da queue/status sperimentale a pipeline persistente con ACK, retry, duplicate prevention e merge iOS.
- Migrare gli allarmi Snorkeling da `AppStorage` locale a store dedicato quando il contratto dati sara stabile.
- Collegare record Apnea Watch a review iOS senza simulare campioni profilo non ancora disponibili.
- Introdurre workflow MapLibre/OpenSeaMap/MBTiles sul companion iOS dopo valutazione licenze e prestazioni.
- Aggiungere report test hardware Apple Watch Ultra per Diving, Snorkeling e Apnea.
- Preparare export e documentazione Subsurface piu completa per import CSV.

## Aggiornamento pre-release 2026-05-18

Il pass piu recente mantiene MAIN e sperimentale separati e documenta i blocker corretti senza promuovere Apnea, Snorkeling o Buddy Assist in produzione:

- Watch MAIN: `WatchSyncAuth` non dipende piu da `SecureBuddyStore`, che resta escluso dal target MAIN per evitare leakage Buddy/BLE.
- Watch MAIN: le conferme GPS distinguono successo, ultimo punto noto e nessun fix; il GPS resta surface-only e non viene documentato come tracking subacqueo.
- Watch MAIN: l'avviso risalita conserva profondita corrente e RunTime durante l'allarme; la logica di calcolo risalita non e stata modificata.
- Watch MAIN: quando l'aptica e disattivata, la live UI mostra `APTICA DISATTIVATA` e `AVVISI SOLO VISIVI`.
- iOS MAIN: sync Watch senza peer secret resta `Associazione Watch non verificata`; nessuna fallback key deterministica viene trattata come fidata.
- iOS MAIN: import CSV preserva la data sorgente quando presente, usa ID deterministico da hash per evitare duplicati e mostra risultato import/duplicati/errori.
- iOS MAIN: la tab **Analisi** include riepilogo route GPS, import CSV, sync Watch e empty state con azioni reali; le cinque tab companion sono Logbook / Analisi / Planner / Attrezzatura / Altro.
- iOS MAIN: Planner usa solo modalita semplice come comportamento attivo, marca modalita avanzate/tecniche come planned, valida input e richiede acknowledgement safety.
- iOS MAIN: conversioni unita restano display-only; dati salvati, planner, import/export CSV e sync Watch restano metrici.

Restano obbligatori: build `xcodegen generate` / Xcode su macOS, test Apple Watch Ultra reale, validazione entitlement depth nel Developer portal e QA su import/export, sync, cloud KVS e schermate piccole.

## Aggiornamento documentazione 2026-05-19

- Aggiunti: [`Docs/BUILD_VALIDATION.md`](Docs/BUILD_VALIDATION.md), [`Docs/GLOSSARY.md`](Docs/GLOSSARY.md), [`Docs/RELEASE_CHECKLIST.md`](Docs/RELEASE_CHECKLIST.md), [`Docs/UI_UX_VISUAL_GUIDELINES.md`](Docs/UI_UX_VISUAL_GUIDELINES.md), [`CHANGELOG.md`](CHANGELOG.md), [`CONTRIBUTING.md`](CONTRIBUTING.md), report di sync [`Docs/DOCUMENTATION_SYNC_REPORT_20260519.md`](Docs/DOCUMENTATION_SYNC_REPORT_20260519.md), allineamento [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md).
- Riferimenti visivi consolidati in `Docs/ReferenceUI/` (Watch live + iOS companion).
- Matrice CSV aggiornata in coda (righe additive) per tab iOS a cinque voci e documentazione build.
- PR **#8** e **#9**: al fetch risultano ancora **`mergeable: CONFLICTING`** / stato GitHub **DIRTY** — **non** mergeate automaticamente; vedi report di sync.

## Aggiornamento documentazione e audit post-fix 2026-05-18

Il report post-fix pre-modifica corrente e stato aggiunto in:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx
```

Stato documentale corrente:

- Apple Watch MAIN include ora delete visibile da `DiveDetailView`, diagnostica depth entitlement/sensore/callback in `Info`, coda sync con retry/clear, metadata GPS fix/fallback/no-fix, stato UserImages vuoto e note export/units local-only.
- iOS MAIN include Logbook con mesi dinamici; **Analisi** con route GPS, import CSV, sync Watch e azioni empty state; reset/re-pair trust Watch; stato autorizzazione notifiche; policy cloud visibile; CSV parser con campi quotati e feedback `importate/duplicati/righe saltate`; feedback `Salvato` su Attrezzatura.
- La matrice `Docs/DIR_DIVING_Feature_Comparison.csv` separa Apple Watch Main, Apple Watch Experimental, iOS Main e iOS Experimental.
- Le PR sperimentali aperte (#8 e #9) risultano conflittuali e con build check falliti; non sono considerate safe-to-merge finche non passano build macOS, review target membership e QA safety.

Aggiornamento runtime MAIN 2026-05-18 20:22:

- Watch MAIN: il blocker `AscentWarningView` -> `Formatters.zero` e stato corretto aggiungendo il formatter zero-decimal Watch senza modificare `time` o `one`.
- Watch MAIN: la coda WatchConnectivity ora distingue `pending`, `sent`, `delivered/acknowledged`, `failed` e last retry; i pending non vengono rimossi prima dell'ack diretto iPhone.
- Watch MAIN: il label `TTV` resta visibile, ma la documentazione/UI lo descrive come metrica informativa derivata da profondita media e runtime, non come NDL/TTS/decompressione.
- Watch MAIN: l'opzione imperiale e non selezionabile finche la conversione Watch non e implementata; export resta metrico/Subsurface.
- iOS MAIN: il blocker `PlannerView.swift` / `ResultPanelStyle` / `PlanTab` e stato corretto mantenendo `PlanTab` a file scope.
- iOS MAIN: CSV import valida durata, profondita, temperatura e range GPS, continua a gestire campi quotati e riporta importati, duplicati e righe malformate/scartate.
- iOS MAIN: detail/analysis non mostrano piu SAC, temperatura o accuratezza GPS mancanti come zero misurati; usano `—` o `Non disponibile`.
- iOS MAIN: export CSV include il GPS fix source entry/exit; Settings mostra una preview merge cloud locale/cloud/risultato senza promettere conflict resolver per-campo.
- `Views/AscentGaugeView.swift` su Watch MAIN puo apparire modificato senza diff contenutistico per line endings; non va incluso in commit funzionali se resta stat-only.
