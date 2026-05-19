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
- Route Review from logged GPS entry/exit points.
- Persistent equipment profile and checklist.
- CSV import for compatible dive profiles.
- Apple Watch log import through WatchConnectivity using direct messages and queued user-info delivery.
- Local persistence with iCloud Key-Value Store mirroring for logbook sessions, planner inputs, equipment profile and deleted-session tombstones.
- Subsurface CSV export support, including entry and exit GPS columns when available.
- iOS companion visual system aligned to the supplied dark cyan mockup.

`main-iOS` is the canonical iOS companion source for pre-release work. Watch production changes stay on `main`; experimental Apnea, Snorkeling, Buddy/BLE and Explore Lab surfaces stay on their experimental branches.

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
- No release-visible mock UI in MAIN; route review, analysis and equipment surfaces must use real local/logbook data or clearly label limitations.

### Latest Stable iOS UI Alignment

Il companion iOS stabile segue `iOS_look_feel.png` e i riferimenti specifici piu recenti:

- `LogbookView`: titolo Logbook, ricerca scura, stacked dive cards, thumbnail e tabbar con attivo ciano.
- `DiveDetailView`: tab riepilogo/grafici/dettagli, immagine sito, griglia metriche, grafico profondita ciano, gas card ed export.
- `PlannerView`: titolo Planner, controllo segmentato modalita, input profilo, gas card con bordo neon e pulsante `Calcola Piano`.
- `PlanResultView`: tab piano/curva/grafici, griglia riepilogo, tabella piano risalita e curva Bühlmann in pannello scuro.
- `ExploreView` / `Route Review`: route calcolate da GPS entry/exit dei log importati o sincronizzati.
- `AnalysisView`: metriche reali da logbook, SAC medio, distribuzione gas e riepilogo route.
- `EquipmentView`: profilo attrezzatura persistente, checklist e SAC pianificazione.
- `MoreView` / `Settings`: onboarding operativo, preferenze locali unita/export, stato Watch sync, conflitti Watch, cloud backup KVS, retry sync e note Subsurface.

Questi allineamenti sono UI-only: non cambiano calcoli planner, sync, persistenza, data flow, navigazione o modelli.

### Stable UX / Accessibility Corrections

Gli ultimi fix sulla superficie stable separano chiaramente i flussi production dalle funzioni sperimentali:

- Apple Watch `main` espone solo il flusso stabile Diving, bussola, settings, immagini e log.
- Apnea, Snorkeling e Buddy Assist restano documentati e isolati nei rami experimental.
- La schermata `Settings` Watch e raggiungibile dalla navigazione principale e collega limiti risalita, allarmi persistenti, info device/batteria, stato GPS, stato sensore profondita, stato sync e preferenza haptic.
- La bussola Watch usa azioni esplicite `SET BEARING` e `CLEAR`, senza promettere un callback del tasto laterale non controllato dall'app.
- Le conferme GPS entry/exit sono mostrate dal lifecycle immersione e non usano coordinate finte quando il fix non e disponibile.
- L'export Watch dalla lista esporta l'ultima immersione e mostra share/error feedback.
- Il companion iOS stabile espone `Logbook`, `Route Review`, `Analysis`, `Planner`, `Gear` e `Settings`; queste superfici usano dati reali locali/logbook o copy esplicita sulle limitazioni.
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
- Equipment profile and checklist.
- Deleted-session tombstones used to avoid restoring removed logs from KVS reloads.
- Watch sync conflict records for user review.

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

If a Watch payload conflicts with an existing local session, the companion stores a visible conflict record so the user can keep the local version or accept the Watch version. Deleted local sessions are tracked with tombstones and filtered on KVS reload to reduce accidental reappearance.

## Latest MAIN UX Audit Implementation

Dopo il report `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx`, iOS MAIN ha ricevuto un pass UX mirato:

- `Settings` espone unita iOS editabili e persistite localmente; la conversione e presentation-only per profondita, temperatura, distanza e SAC.
- `Settings` mantiene export come preferenza non editabile perche oggi esiste solo Subsurface CSV.
- `Settings` chiarisce che gli allarmi immersione sono gestiti su Apple Watch e che i permessi notifiche iOS si recuperano dalle Impostazioni di sistema.
- `Logbook`, `Route Review` e `Analysis` mostrano empty state quando non ci sono immersioni, route GPS surface-only o statistiche reali.
- `Logbook` richiede conferma prima di eliminare una sessione e `Gear` richiede conferma prima del reset profilo.
- Non sono stati modificati algoritmi GPS, bussola, profondita, risalita, planner, persistenza o modello sync; le conversioni unita non cambiano dati salvati, import/export CSV o calcoli planner.

## Latest MAIN UX Audit And Documentation TODO

Il report pre-modifica MAIN piu recente e generato sul ramo Watch `main`:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx
```

Stato documentato per il companion iOS MAIN:

- Le superfici principali sono raggiungibili: `Logbook`, `Route Review`, `Analysis`, `Planner`, `Gear`, `Settings`.
- Risolti nel pass MAIN UX: empty state principali, conferme delete/reset, unita iOS editabili con formatter di conversione, export ancora marcato read-only e copy coerente per settings local-only.
- Restano TODO sync: settings Watch/iOS non sono ancora una pipeline bidirezionale production; i conflitti Watch sono visibili ma richiedono test device e policy prodotto.
- Restano TODO build/config da verificare su macOS: l'asset catalog iOS MAIN deve contenere i PNG citati da `iOSApp/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json`.
- L'audit resta snapshot pre-modifica; i fix MAIN UX successivi sono committati separatamente dalla documentazione.

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
| `main` | Apple Watch | Stable | Diving mode, log, export, BUSSOLA, immagini, settings raggiungibili, allarmi/haptic persistenti, GPS entry/exit confirmation, helper shortcut/App Intents e empty state log. |
| `codex/experimental-features` | Apple Watch | Experimental | Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, POI con log/dettaglio/conferma, allarmi Snorkeling persistenti locali, Apnea, haptics sperimentali e Buddy Assist. |
| `main-iOS` | iOS Companion | Stable | Logbook, Dive Detail, Route Review, Analysis, Planner/Plan Result, Gear, Settings, WatchConnectivity, iCloud KVS, CSV import/export, Subsurface, empty state e conferme distruttive. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore Lab, route planning, waypoint management, POI enrichment mock/TODO, Apnea Review interattiva, manifest sync sperimentale e note map/offline. |

## Mode Availability

La selezione modalita vive sull'app Apple Watch. Dal punto di vista iOS:

- `main-iOS` supporta revisione log, Route Review da GPS entry/exit, Analysis, Gear, planner, settings, sync e export/import CSV per Diving stabile.
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

- Validare su device iOS file import, share sheet, KVS tombstone e conflitti Watch.
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

## Latest Experimental Blocker Resolution

Dopo il report `Docs/EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx`, i rami sperimentali hanno ricevuto un pass di contenimento UX senza modificare algoritmi GPS, bussola, profondita, risalita o decompressione:

- Watch experimental: settings, allarmi, limiti risalita e info sono raggiungibili dalla navigazione sperimentale.
- Watch Snorkeling: lifecycle sessione, allarmi enforce locali e stato sync POI queue/delivery sono visibili.
- Watch Apnea: sensori non disponibili sono mostrati come `--`, `HR OFF`, `BAT --`, `TEMP --` invece di valori finti.
- Watch Buddy Assist: flusso marcato `LAB-ONLY` e disabilitato finche il relay BLE Watch non e validato.
- iOS Experimental: Planner result/export sono `PIANO LAB` / `EXPORT LAB`, dead affordances sono rimosse o etichettate, More espone impostazioni locali e diagnostica sync.
- iOS Explore Lab: route/settings manifest usano queue locale con conteggio/stato e import experimental visibile, senza promettere merge production.

## Known Limitations

- GPS e affidabile solo in superficie; sott'acqua usare ultimo fix valido e contesto bussola/waypoint come supporto informativo.
- Le mappe Watch sono leggere e SwiftUI-only; non scaricano tile online.
- OpenStreetMap public tile server non devono essere usati hard-coded per traffico production pesante.
- OpenSeaMap, GEBCO, EMODnet e MBTiles restano roadmap/future layer; il companion iOS mostra solo stato/TODO e non include ancora un motore MapLibre reale.
- Apnea e Snorkeling experimental non sono dispositivi certificati di sicurezza.
- Watch -> iPhone POI, Watch -> iPhone Apnea, iPhone -> Watch route/waypoint/settings, duplicate prevention e offline queue hanno stato/queue UX sperimentale; non sono ancora una pipeline production completa.

## Aggiornamento pre-release 2026-05-18

Il pass piu recente mantiene `main-iOS` production-oriented e non promuove superfici Apnea/Snorkeling/Explore Lab dal ramo experimental:

- Sync Watch: una peer secret mancante produce `Associazione Watch non verificata`; i payload non vengono trattati come fidati tramite fallback deterministico.
- Cloud/logbook: i record locali e cloud vengono letti separatamente prima del merge per evitare conflazione silenziosa; tombstone delete restano espliciti ma richiedono test multi-device.
- CSV import: la data sorgente viene preservata se presente, il file produce un ID deterministico per evitare duplicati su re-import, e gli errori su righe malformed sono visibili.
- Route Review: gli empty state usano pulsanti reali per sincronizzare, importare CSV o aprire impostazioni; etichette non funzionali non devono sembrare azioni.
- Planner: `Semplice` e la sola modalita comportamentale attiva; `Avanzato` e `Tecnico` restano planned, con validazione input e acknowledgement safety prima del piano.
- Unita iOS: conversione coerente e display-only per profondita, temperatura, distanza e SAC; dati salvati, planner, import/export CSV e sync Watch restano metrici.

Validazione richiesta fuori da Windows: `xcodegen generate`, build Xcode, test iPhone small/large screen, pairing Watch, import/re-import CSV, cloud KVS/delete e App Icon asset catalog.

## Aggiornamento documentazione e audit post-fix 2026-05-18

Il report post-fix pre-modifica corrente e conservato sul ramo Watch `main`:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx
```

Stato documentale corrente per iOS MAIN:

- Logbook usa gruppi mese/anno dinamici con label italiane e continua a supportare import CSV e delete con conferma.
- Explore separa chiaramente `Sync Watch` da `Sync iCloud`, evitando copy ambiguo su route GPS surface-only.
- Analysis ha azioni reali per `Importa CSV`, `Sync Watch` e apertura Logbook.
- Settings mostra reset/re-pair trust Watch con conferma, stato peer verificato, stato autorizzazione notifiche, policy cloud/merge e roadmap export.
- CSV import gestisce campi quotati, righe malformed saltate, duplicate count e data sorgente preservata quando disponibile.
- Gear mostra feedback discreto `Salvato` dopo auto-save.

Blocker aperti da risolvere in commit runtime separati, non in documentazione:

- iOS MAIN: `PlannerView.swift` ha una struttura brace/scope non valida vicino a `ResultPanelStyle` / `PlanTab`.
- Watch MAIN: `AscentWarningView` usa `Formatters.zero`, ma il formatter Watch espone solo `time` e `one`.
- Le PR sperimentali #8 e #9 sono conflittuali e con build check falliti; non sono safe-to-merge finche non passano build macOS, review target membership e QA safety.
