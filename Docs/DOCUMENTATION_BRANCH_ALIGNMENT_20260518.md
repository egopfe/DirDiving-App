# DIR DIVING - Allineamento documentazione e branch 2026-05-18

## Scopo

Questo aggiornamento documenta lo stato dopo i fix pre-release MAIN e dopo il controllo PR/branch. Non modifica business logic, GPS, algoritmi bussola, calcoli profondita/risalita/decompressione o modelli di persistenza.

## Branch ispezionati

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- remote `origin/main`
- remote `origin/main-iOS`
- remote `origin/codex/experimental-features`
- remote `origin/codex/ios-experimental-features`

Backup refs creati:

```text
backup/before-docs-merge-20260518-1337-main
backup/before-docs-merge-20260518-1337-main-iOS
backup/before-docs-merge-20260518-1337-watch-experimental
backup/before-docs-merge-20260518-1337-ios-experimental
backup/before-docs-merge-20260518-1903-main
backup/before-docs-merge-20260518-1903-main-iOS
backup/before-docs-merge-20260518-1903-watch-experimental
backup/before-docs-merge-20260518-1903-ios-experimental
```

## Stato MAIN Apple Watch

- `Diving` resta il flusso stabile production-oriented.
- `WatchSyncAuth` MAIN e documentato come isolato da `SecureBuddyStore`; Buddy/BLE resta experimental.
- Depth entitlement e configurato nel file Watch, ma richiede Apple Developer portal, Xcode/macOS e Apple Watch Ultra reale per validazione.
- GPS entry/exit resta surface-only: successo, ultimo punto noto e no-fix devono essere distinguibili.
- Avviso risalita mantiene contesto live senza modificare algoritmi.
- Haptics off e visibile come stato operativo; warning visuali restano obbligatori.

## Stato iOS MAIN

- `main-iOS` resta companion stabile per Logbook, Dive Detail, Route Review, Analysis, Planner, Gear e Settings.
- Sync Watch non deve concedere trust senza peer secret verificata.
- Local/cloud load e documentato come separato prima del merge; tombstone delete restano espliciti.
- CSV import preserva data sorgente quando disponibile, usa ID deterministico anti-duplicato e mostra feedback import.
- Planner MAIN mantiene solo `Semplice` come comportamento attivo; `Avanzato` e `Tecnico` sono planned finche non cambiano davvero comportamento.
- Conversione unita iOS e display-only; planner, dati salvati, import/export CSV e sync restano metrici.

## Stato Experimental Apple Watch

- Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, GPS marker, Log/Dettaglio POI, allarmi Snorkeling e settings restano in `codex/experimental-features`.
- Terminologia obbligatoria: `BUSSOLA`, mai `COMPASSO`.
- Return-to-entry e waypoint sono situational awareness, non navigazione certificata.
- Apnea resta training aid UI sperimentale.
- Buddy Assist resta lab-only finche BLE/relay e safety review non sono validati.

## Stato Experimental iOS

- Explore Lab, route/waypoint manifest, POI enrichment e Apnea Review restano in `codex/ios-experimental-features`.
- Mock/TODO/Non sincronizzato devono restare visibili finche i dati production non esistono.
- Non importare superfici Watch experimental nel branch iOS MAIN come feature production.

## Aggiornamento post-fix 2026-05-18 19:03

- `main` e `main-iOS` sono allineati con `origin` prima di questo pass documentale; i rami experimental sono avanti ai rispettivi branch base ma indietro di 3 commit MAIN.
- Il nuovo audit post-fix e in `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md` e `.docx`.
- Watch MAIN documenta delete visibile, depth diagnostics, coda sync retry/clear, metadata GPS fix/fallback/no-fix, UserImages empty state e limiti unit/export.
- iOS MAIN documenta Logbook con mesi dinamici, Explore sync Watch/iCloud separati, Analysis actions, reset/re-pair trust Watch, stato notifiche, cloud merge-policy UI, CSV parser quotato e Gear save feedback.
- Blocker runtime da correggere separatamente: Watch `AscentWarningView` usa `Formatters.zero` mancante; iOS `PlannerView.swift` ha struttura brace/scope non valida vicino a `ResultPanelStyle` / `PlanTab`.
- `Views/AscentGaugeView.swift` su Watch MAIN puo risultare dirty senza diff contenutistico per line endings; non includerlo in commit funzionali se resta stat-only.

## PR aperte

### PR #8 - Update experimental Apnea workflow

- Branch: `codex/experimental-features` -> `main`
- GitHub: `mergeable=CONFLICTING`, `mergeStateStatus=DIRTY`, build checks failing.
- Rischio: ampia modifica runtime Watch experimental, inclusi Snorkeling/Apnea/Buddy e project membership.
- Raccomandazione: non merge automatico; richiede build macOS, Apple Watch QA e review safety.

### PR #9 - Add experimental Apnea companion review

- Branch: `codex/ios-experimental-features` -> `main-iOS`
- GitHub: `mergeable=CONFLICTING`, `mergeStateStatus=DIRTY`, build checks failing.
- Rischio: modifica ampia con molti file Watch/root e companion experimental.
- Raccomandazione: non merge automatico; richiede review target membership, build macOS e verifica che mock/lab non entrino in MAIN.

## Validazioni obbligatorie

- `xcodegen generate` su macOS.
- Build `DIRDiving Watch App` e `DIRDiving iOS` con Xcode.
- Apple Developer portal: entitlement depth/submersion su `com.egopfe.dirdiving`.
- Apple Watch Ultra reale: depth entitlement, GPS no-fix/fallback, haptics on/off, ascent warning.
- iPhone reale: pairing Watch, cloud KVS/delete, CSV import/re-import, planner invalid-input, UI small/large screen.

## Regole future di merge

1. Preservare codice buildabile.
2. Preservare Diving stabile.
3. Preservare UI master reference piu recente.
4. Preservare Snorkeling Live, Mappa Waypoint, Mappa Ritorno, GPS marker e return-to-entry su experimental.
5. Preservare documentazione aggiornata.
6. Mantenere feature sperimentali isolate finche non sono validate e promosse esplicitamente.
