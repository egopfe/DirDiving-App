# Release checklist — DIR DIVING MAIN

Compilare su **macOS** dopo `xcodegen generate`. Non spuntare voci non verificate.

## Metadati release

| Campo | Valore |
|-------|--------|
| Data | __________ |
| Commit `HEAD` | __________ |
| Esecutore | __________ |

## Build

- [ ] `xcodegen generate` senza errori  
- [ ] `xcodebuild` **DIRDiving Watch App** — `generic/platform=watchOS` — **PASS**  
- [ ] `xcodebuild` **DIRDiving iOS** — `generic/platform=iOS` — **PASS**  

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
- [ ] Apple Watch **41/45 mm** — stesse schermate  
- [ ] iPhone **piccolo** (es. SE class) — tab bar + Logbook  
- [ ] iPhone **Pro Max** — card e grafici  
- [ ] GPS **negato** — copy coerente, nessun “successo” verde fuorviante  
- [ ] Nessun iPhone / WatchConnectivity disattivato — messaggio sync chiaro  
- [ ] iCloud **non disponibile** — stato backup chiaro  
- [ ] Logbook **vuoto** — empty state + passi successivi  
- [ ] Export **fallito** — messaggio esplicito  
- [ ] Aptica Watch **off** — badge “avvisi solo visivi” visibile  

## Sicurezza / copy

- [ ] Disclaimer MAIN visibile (iOS `MoreView` / README)  
- [ ] Link **Terms** / **Privacy** puntano ai documenti dedicati `Docs/TERMS_OF_USE.md` e `Docs/PRIVACY_AND_DATA_USE.md`
- [ ] Nessun claim di certificazione non supportato  
- [ ] Side Button descritto onestamente come system-controlled
- [ ] Action Button descritto come disponibile solo tramite Shortcuts / App Intents quando watchOS lo espone

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
- [ ] **F11 legacy fallback** — iPhone con build precedente (no `ackSignature`): Watch logga "ack legacy" e la pending queue si svuota comunque.
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
