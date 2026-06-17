# DIR DIVING - Specifica Apnea (integration `integration/full-computer`)

**Aggiornato:** 2026-06-17  
**Branch:** `integration/full-computer` (non `main`)  
**Architettura:** [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md)  
**Release-hard:** [`DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md)

## Stato attuale

Apnea su `integration/full-computer` usa modelli condivisi (`Shared/Models/Apnea*`), motore lifecycle (`ApneaSessionEngine`), companion iOS (`iOSApp/Views/Apnea/`) e sync WatchConnectivity dedicato (`apneaSyncPlanPackage`, `dirdiving_apnea_session`).

- **Watch UI** (`Views/ApneaView.swift`): implementata ma **esclusa** dal target MAIN Watch in `project.yml` fino a review di promozione.
- **Feature flag:** `ExperimentalFeatures.apneaIntegrationEnabled` (vedi `Utils/ExperimentalFeatures.swift`).
- **Mockup:** 23 PNG `APNEA_*` indicizzati in `Utils/ApneaMockupReferenceMatrix.swift` — **non** incorporati nel bundle.
- **Sicurezza:** nessun rilevamento blackout/movimento; buddy disclaimer su iOS; start bloccato con sensore degradato.

## Principi UI (mockup Commands 05–11)

- Watch: sfondo nero, numeri grandi, verde/giallo/rosso per stato semantico (ready, dive, ascent, recovery, summary, allarmi).
- iOS: companion chiaro con accenti teal/cyan, tab Dashboard / Sessioni / Statistiche / Profilo.
- Localizzazione **EN + IT** obbligatoria per tutte le stringhe Apnea.

## Workflow Apple Watch (target integrazione)

1. Ready — piano importato da iOS o sessione autonoma; allarmi profondità; gate sensore.
2. Dive / Ascent — profondità, velocità verticale, timer apnea, overlay marker/target.
3. Surface recovery — countdown recupero con policy 1:1 / 2:1 / fissa.
4. Session summary — statistiche sessione, salvataggio logbook, sync verso iOS.
5. Depth alarms screen — elenco soglie con stato semantico (mockup WATCH_06).

## Companion iOS

Schermate allineate ai mockup `APNEA_IOS_01` … `15`: dashboard, profili, pianificazione (invio al Watch), dettaglio immersione e grafici, statistiche, attrezzatura, buddy/sicurezza, mappa sessione, logbook, allarmi/marcatori, record personali, export, impostazioni apnea.

## Sync

- **iOS → Watch:** pacchetto piano firmato con `revision`, `packageID`, ACK firmato.
- **Watch → iOS:** sessione completata/abortita via `dirdiving_apnea_session` con merge idempotente nel logbook iOS.
- Namespace **isolato** da sync immersioni Gauge/Full Computer.

## Limitazioni note

- Frequenza cardiaca / batteria mostrati solo con sorgente reale (`--` altrimenti).
- GPS solo superficie per mappa sessione.
- QA fisica (Water Lock, guanti, profondità reale): **PENDING** — vedi matrici QA in `Docs/`.

---

## Appendice — storico branch `codex/experimental-features`

Il contenuto seguente descrive il prototipo precedente basato su `ExplorationStore` (branch experimental legacy). Non riflette il runtime su `integration/full-computer`.

### Workflow legacy (ExplorationStore)

Il flusso sperimentale Apnea legacy era composto da menu Apnea, countdown, `ExplorationStore.surfaceFromApnea(...)`, recovery `max(durata * 2, 30)`, grafici placeholder e card iOS `Apnea Review` con dati mock.

Persistenza legacy: record Apnea in `ExplorationStore`, senza modelli `ApneaSession` dedicati né sync production.

Per dettagli storici UI/UX del branch experimental, vedere commit su `codex/experimental-features` e [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md).
