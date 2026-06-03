# Release checklist — DIR DIVING MAIN

Compilare su **macOS** dopo `xcodegen generate`. Non spuntare voci non verificate.

## Metadati release

| Campo | Valore |
|-------|--------|
| Data | __________ |
| Commit `HEAD` | __________ |
| Esecutore | __________ |

## Audit remediation (2026-06-03)

- [ ] Review [`DIR_DIVING_FULL_CODE_AUDIT_2026-06-03_REMEDIATION_REPORT.md`](DIR_DIVING_FULL_CODE_AUDIT_2026-06-03_REMEDIATION_REPORT.md)
- [ ] Optional CSV import without `temperature_c` verified on device (see [`CSV_IMPORT_EXPORT_POLICY.md`](CSV_IMPORT_EXPORT_POLICY.md))
- [ ] Watch GPS lifecycle policy reviewed ([`WATCH_GPS_LIFECYCLE_POLICY.md`](WATCH_GPS_LIFECYCLE_POLICY.md))

## Build

- [ ] `xcodegen generate` senza errori  
- [ ] `git diff --exit-code -- DIRDiving.xcodeproj` (nessun drift post-generate)
- [ ] `xcodebuild` **DIRDiving Watch App** — `generic/platform=watchOS` — **PASS**  
- [ ] `xcodebuild` **DIRDiving iOS** — `generic/platform=iOS` — **PASS**  
- [ ] `xcodebuild test` **DIRDiving Watch Algorithm Tests** — **PASS**
- [ ] `xcodebuild test` **DIRDiving iOS Algorithm Tests** — **PASS**
- [ ] `./Scripts/check_main_target_isolation.sh` — **PASS**
- [ ] `./Scripts/check_secrets.sh` — **PASS**
- [ ] `./Scripts/validate_main_release_readiness.sh` — **PASS**

## Depth entitlement (Apple Watch Ultra — field validation)

**Not complete until executed on real hardware.** Entitlement is configured in `Config/DIRDiving.entitlements`; simulator does not certify submersion.

- [ ] Apple Developer portal: Watch App ID `com.egopfe.dirdiving.ios.watch` includes **water submersion** entitlement approved
- [ ] Apple Developer portal: embedded pair remains linked to iOS App ID `com.egopfe.dirdiving.ios`
- [ ] Provisioning profile used for Archive includes `com.apple.developer.coremotion.water-submersion`  
- [ ] Real **Apple Watch Ultra**: automatic dive launch when submerged (if product expects it)  
- [ ] Live depth samples from `CMWaterSubmersionManager` during test dive  
- [ ] Manual dive fallback panel still works when sensor unavailable  
- [ ] Info screen diagnostics match field result (not only “Configurato”)  

## Device matrix (manuale)

- [ ] Apple Watch **Ultra** — live screen, gauge, START/STOP/RESET, testi non tagliati  
- [ ] Apple Watch **Ultra** — pulsante **Start Dive** visibile in superficie; avvia sessione manuale senza impedire il successivo lifecycle automatico da profondita
- [ ] Apple Watch **41/45 mm** — stesse schermate  
- [ ] iPhone **piccolo** (es. SE class) — tab bar + Logbook  
- [ ] iPhone **Pro Max** — card e grafici  
- [ ] GPS **negato** — copy coerente, nessun “successo” verde fuorviante  
- [ ] Nessun iPhone / WatchConnectivity disattivato — messaggio sync chiaro  
- [ ] iCloud **non disponibile** — stato backup chiaro  
- [ ] Logbook **vuoto** — empty state + passi successivi  
- [ ] Export **fallito** — messaggio esplicito  
- [ ] Aptica Watch **off** — badge “avvisi solo visivi” visibile  
- [ ] Immagini sync iPhone -> Watch leggibili e raggiungibili fuori immersione attiva
- [ ] Mission Mode: auto-enable in Settings, stato/manuale superficie, fulmine in Live durante immersione, disclaimer ≠ Apple Basso Consumo, draft restore con auto-enable ON

## Sicurezza / copy

- [ ] Disclaimer MAIN visibile (iOS `MoreView` / README)  
- [ ] Link **Terms** / **Privacy** puntano ai documenti dedicati `Docs/TERMS_OF_USE.md` e `Docs/PRIVACY_AND_DATA_USE.md`
- [ ] Nessun claim di certificazione non supportato  
- [ ] Side Button descritto onestamente come system-controlled
- [ ] Action Button descritto come disponibile solo tramite Shortcuts / App Intents quando watchOS lo espone
- [ ] Planner iOS descritto come riferimento non certificato; il motore Buhlmann ZHL-16C N2+He multigas e presente ma richiede validazione esterna prima di claim piu forti.
- [ ] TTV Watch descritto come indice informativo (non NDL/TTS/deco)
- [ ] Mission Mode descritto come profilo runtime/UI interno (non Apple Basso Consumo)

## QA algoritmico MAIN

- [ ] Watch MAIN: verificare `Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md` e test su cap log 40, temperatura plausibile, export vuoto, GPS fallback e conversioni.
- [ ] iOS MAIN: verificare `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` e test su planner/gas validation, import/export/sync, logbook time-weighted math, route math e safe states.
- [ ] iOS planner: verificare che trimix/helium usino il motore N2+He e restino reference-only; riferirsi a `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` e `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`.
- [ ] iOS planner UX (@ `3237262` + `dae29b8`): repetitive planning toggle + status; environment altitude/salinity messaging; schedule gas ledger card; result header badges (no-deco/deco-required); typed warnings; CNS/OTU reference disclaimers with **daily CNS / OTU 24h summary** and air-break note; VoiceOver labels su card risultato — vedi [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md).
- [ ] iOS planner CNS/OTU algorithm (@ `dae29b8`): deco profile with O₂ then air shows lower CNS than O₂ alone; repetitive second dive carries prior CNS/OTU after short SI; 24 h SI resets daily OTU — vedi [`OxygenExposureDeepModelTests.swift`](../Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift).

## QA Security (audit F1–F12, baseline 2026-05-19)

Rif. `Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md` (Appendix A) e commit `4136ec0`.

### Auth / pairing

- [ ] **F1** — Reset associazione Watch dalla UI iOS (`MoreView` / debug) → console mostra che il peer secret viene eliminato e ripubblicato dopo la nuova handshake; `userVisibleState` torna a "Associazione Watch non verificata" finché non arriva il secret.
- [ ] **F2** — `WatchSyncAuth.syncKey` su entrambe le piattaforme legge il commento MARK *"v2 ordered-secrets"*; nessun drift introdotto in PR aperte (PR #8 / #9).
- [ ] **F7** — Simulare `SecRandomCopyBytes` failure su simulator (es. swizzle in test) → app non genera secret deterministico, log strutturato via `os.Logger` con `privacy:.private`.

### Persistenza / Data Protection

- [ ] **F3** — Watch CSV export → file in `tmp/` con attributo `NSURLFileProtectionComplete`, filename `DIRDiving_Export_<UUID>.csv`, file > 24 h vengono ripuliti al successivo export.
- [ ] **F4** — iOS CSV export → `[.atomic, .completeFileProtection]`, cleanup attivo. **Vietato merge** da `main-iOS` se rimuove queste protezioni.
- [ ] **F9** — Verifica file `Documents/dirdiving_watch_pending_sync_sessions.json` (Watch) e `Documents/dirdiving_ios_watch_sync_conflicts.json` (iOS) creati con Data Protection complete; chiavi `UserDefaults` legacy `dirdiving_watch_pending_sync_sessions` e `dirdiving_ios_watch_sync_conflicts` non presenti dopo il primo launch post-migrazione.

### Sync protocol

- [ ] **F6** — Tampering del campo `issuedAt` > 1 h fuori dal `Date()` corrente → import iOS rigetta con `WatchDiveSyncError.stalePayload`.
- [ ] **F11** — iPhone con build aggiornata: il reply include `ackSignature` HMAC; Watch logga "ack firmato dal companion".
- [ ] **Signed ACK enforcement** — iPhone con build precedente o reply senza `ackSignature`: Watch mostra errore e conserva la pending queue.
- [ ] Tampering del campo `body` con MAC valido per body originale → `WatchDiveSyncError.invalidSignature`.

### Input validation

- [ ] **F5** — Import CSV con valori fuori bound (`depth_m = 99999`, `entry_lat = 5000`, `time_seconds = -42`) → riga conteggiata come malformata, non importata; risultato UI: "Import: 0 importate, 0 duplicati, N righe malformate".
- [ ] **F10** — Import CSV > 10 MB → errore `.fileTooLarge` con messaggio "CSV troppo grande: limite 10 MB."; nessun crash, nessun caricamento parziale.

### Logging / naming

- [ ] **F8 migration** — Utente con `dirmotion_ascent_rate_limits` esistente (sandbox precedente): valori letti correttamente, nuove modifiche scritte sotto `dirdiving_ascent_rate_limits`; lo stesso per Keychain iOS `com.egopfe.dirdiving.watch-sync` (legacy `com.egopfe.dirmotion.watch-sync` letto una volta).
- [ ] **F12** — Console (Mac → device): nessun `print()` Swift visibile; `Logger` per subsystem `com.egopfe.dirdiving*` mostra `<private>` sui dettagli errore.

### Privacy / leakage

- [ ] Sysdiagnose non contiene coordinate GPS, profondità o durata immersione nei log di `DiveLogStore`, `WatchSyncService`.
- [ ] CSV export non scritto su `Caches/` ma solo su `tmp/` con Data Protection.

> Se anche un solo check fallisce in modo non documentato, **bloccare la release** e aprire un follow-up con riferimento al finding (es. "F6 regression on watchOS 11.x").

## Firma

Approvazione release: __________________ Data: ________

---

*Checklist documentale; non modifica il codice.*

## Gate esterni obbligatori (non chiudibili solo da codice)

- [ ] `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`
- [ ] `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`
- [ ] `Docs/WATCH_IOS_SYNC_QA_MATRIX.md`
- [ ] `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md`
- [ ] `Docs/CSV_SUBSURFACE_QA_MATRIX.md`
- [ ] `Docs/PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md`
- [ ] `Docs/TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`
- [ ] `Docs/APP_STORE_RELEASE_GATE_CHECKLIST.md`
