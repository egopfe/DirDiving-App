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

### Latest Stable iOS UI Alignment

Il companion iOS stabile segue `iOS_look_feel.png` e i riferimenti specifici piu recenti:

- `LogbookView`: titolo Logbook, ricerca scura, stacked dive cards, thumbnail e tabbar con attivo ciano.
- `DiveDetailView`: tab riepilogo/grafici/dettagli, immagine sito, griglia metriche, grafico profondita ciano, gas card ed export.
- `PlannerView`: titolo Planner, controllo segmentato modalita, input profilo, gas card con bordo neon e pulsante `Calcola Piano`.
- `PlanResultView`: tab piano/curva/grafici, griglia riepilogo, tabella piano risalita e curva Bühlmann in pannello scuro.
- `MoreView` / `Settings`: onboarding operativo, preferenze unita/export, stato Watch sync, cloud backup, retry sync e note Subsurface.

Questi allineamenti sono UI-only: non cambiano calcoli planner, sync, persistenza, data flow, navigazione o modelli.

### Stable UX / Accessibility Corrections

Gli ultimi fix sulla superficie stable separano chiaramente i flussi production dalle funzioni sperimentali:

- Apple Watch `main` espone solo il flusso stabile Diving, bussola, settings, immagini e log.
- Apnea, Snorkeling e Buddy Assist restano documentati e isolati nei rami experimental.
- La schermata `Settings` Watch e raggiungibile dalla navigazione principale e collega limiti risalita, allarmi persistenti, info device/batteria, stato GPS, stato sensore profondita, stato sync e preferenza haptic.
- La bussola Watch usa azioni esplicite `SET BEARING` e `CLEAR`, senza promettere un callback del tasto laterale non controllato dall'app.
- Le conferme GPS entry/exit sono mostrate dal lifecycle immersione e non usano coordinate finte quando il fix non e disponibile.
- L'export Watch dalla lista esporta l'ultima immersione e mostra share/error feedback.
- Il companion iOS stabile espone solo `Logbook`, `Planner` e `Settings`; le superfici placeholder `Explore`, `Analysis` e `Equipment` non sono nel tabbar stable.
- Il planner iOS mostra disclaimer in-app e separa i tab risultato `PIANO`, `CURVA BÜHLMANN` e `GRAFICI`.
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

Schemes principali generati da `project.yml`:

- `DIRDiving iOS`
- `DIRDiving Watch App`

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
- I rami `main` e `main-iOS` non devono esporre Apnea, Snorkeling, Buddy Assist o placeholder sperimentali come flussi production.
- Le funzioni sperimentali restano isolate finche non sono validate su hardware, build XcodeGen e test manuali.
- In caso di conflitto, preservare prima codice buildabile e comportamento Diving stabile, poi la UI master reference piu recente, poi gli aggiornamenti documentali.

## Platform And Build Matrix

| Branch | App | Stato | Note |
| --- | --- | --- | --- |
| `main` | Apple Watch | Stable | Diving mode, log, export, bussola, immagini, settings raggiungibili, allarmi/haptic persistenti, GPS entry/exit confirmation. |
| `codex/experimental-features` | Apple Watch | Experimental | Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, POI con log/dettaglio/conferma, allarmi Snorkeling persistenti locali, Apnea, haptics sperimentali e Buddy Assist. |
| `main-iOS` | iOS Companion | Stable | Logbook, Dive Detail, Planner/Plan Result, Settings, WatchConnectivity, iCloud, onboarding e export Subsurface. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore Lab, route planning, waypoint management, POI enrichment mock/TODO, Apnea Review interattiva, manifest sync sperimentale e note map/offline. |

## Mode Availability

La selezione modalita vive sull'app Apple Watch. Dal punto di vista iOS:

- `main-iOS` supporta revisione log, planner, settings, sync e export per Diving stabile.
- Snorkeling companion planning e Apnea Review restano in `codex/ios-experimental-features`.
- Le funzioni experimental non devono comparire nel tabbar stable senza validazione e merge esplicito.

Le modalita condividono il design system nero/neon, ma non devono condividere logiche safety in modo implicito.

## UI Master References

Le UI Apple Watch devono seguire `MASTER_REFERENCE_DIVING_LIVE.png` come riferimento canonico per densita, gerarchia, colore e bordo. Le UI iOS devono seguire `iOS_look_feel.png`.

Riferimenti recenti per iOS main:

- `ios_logbook_reference.png`
- `ios_dive_detail_reference.png`
- `ios_planner_reference.png`
- `ios_plan_result_reference.png`

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

## iOS Companion Roadmap

- Mantenere `Apnea Review` come card UI-only finche i record Apnea Watch non vengono sincronizzati con un modello dedicato.
- Collegare POI Watch a payload sync leggero e enrichment iOS, includendo queue offline e prevenzione duplicati.
- Mantenere `Apnea Review` con tab interattivi `Riepilogo`, `Grafico` e `Dettagli`, ma con etichette `Mock` / `TODO` finche non esistono record Apnea sincronizzati.
- Esporre POI / Osservazioni come superficie di enrichment per foto, video, commenti, categorie, tag e note specie, senza promettere media upload/save reale.
- Preparare manifest mock iPhone -> Watch per waypoint, route e settings, mantenendo WatchConnectivity production fuori da questo pass.
- Introdurre workflow MapLibre/OpenSeaMap/MBTiles sul companion iOS dopo valutazione licenze e prestazioni.
- Mantenere logbook, planner, export e sync WatchConnectivity separati dai runtime sperimentali Watch.
- Validare build XcodeGen su macOS per ogni ramo prima dei merge.

## Latest Experimental UX Audit Fixes

Il documento Word dell'audit e conservato in `Docs/EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx`. Gli ultimi fix sui rami sperimentali aggiungono:

- Watch Snorkeling: conferma `MARCATORE SALVATO`, haptic, log marcatori, dettaglio marcatore, GPS unavailable state, settings Snorkeling, allarmi persistenti locali, calibrazione Bussola e legenda mappe.
- Watch Apnea: configurazione locale persistente, allarmi raggiungibili, haptic countdown/start/save/recovery, azioni esplicite su riepilogo/grafico/dettagli/salvataggio e boundary sync dichiarate.
- iOS Experimental Explore Lab: sezioni Snorkeling Review, POI/Osservazioni, Waypoint Planning, Apnea Review e Experimental Settings; POI enrichment mock, manifest route/settings per Watch e note MBTiles/MapLibre/OpenSeaMap.
- Tutte le funzioni non production-ready sono etichettate come `Mock`, `TODO`, `Non ancora sincronizzato` o `Sync sperimentale`.

## Known Limitations

- GPS e affidabile solo in superficie; sott'acqua usare ultimo fix valido e contesto bussola/waypoint come supporto informativo.
- Le mappe Watch sono leggere e SwiftUI-only; non scaricano tile online.
- OpenStreetMap public tile server non devono essere usati hard-coded per traffico production pesante.
- OpenSeaMap, GEBCO, EMODnet e MBTiles restano roadmap/future layer; il companion iOS mostra solo stato/TODO e non include ancora un motore MapLibre reale.
- Apnea e Snorkeling experimental non sono dispositivi certificati di sicurezza.
- Watch -> iPhone POI, Watch -> iPhone Apnea, iPhone -> Watch route/waypoint/settings, duplicate prevention e offline queue sono documentati come sync boundary sperimentali; non sono ancora una pipeline completa.
