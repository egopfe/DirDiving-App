# DIR DIVING - Documentation Branch Alignment 2026-05-17

## Scopo

Questo aggiornamento documentale allinea README, documenti iOS e matrice feature dopo gli ultimi sviluppi MAIN readiness e dopo i fix sperimentali Apnea/Snorkeling.

Non modifica business logic, GPS, bussola, calcoli immersione/profondita/risalita, modelli di persistenza o architettura runtime.

## Branch ispezionati

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- backup branches locali esistenti
- PR aperte `#8` e `#9`

Backup creato:

```text
backup/before-docs-merge-20260517-2127
```

## Aggiornamenti documentati

### MAIN Apple Watch

- Diving mode resta il flusso stabile production-oriented.
- La UI Watch MAIN segue `MASTER_REFERENCE_DIVING_LIVE.png`.
- Apnea, Snorkeling, Buddy Assist e concept future sono esclusi da navigazione e target membership MAIN.
- Gli allarmi Watch hanno soglie profondita/tempo/batteria editabili, persistite e applicate.
- START/STOP/RESET cronometro hanno haptic feedback rispettando il toggle haptics.
- I toni audio sono documentati come non usati sott'acqua; feedback operativo via vibrazione.
- Privacy Bluetooth rimossa da MAIN se Buddy Assist non e visibile/production.

### iOS Companion MAIN

- UI principale allineata a `iOS_look_feel.png`.
- Tabbar stabile documentata come `Logbook`, `Route Review`, `Analysis`, `Planner`, `Gear`, `Settings`.
- `Route Review` usa GPS entry/exit surface-only dai log, non tracking subacqueo.
- `Analysis` usa metriche reali logbook.
- `Gear` usa profilo attrezzatura persistente.
- CSV import/export documentati.
- Watch sync conflict review e tombstone KVS documentati.
- Planner resta non certificato e mostra warning dinamici.

### Experimental Apple Watch

- Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, Marcatori POI, allarmi Snorkeling e settings sperimentali restano nel ramo `codex/experimental-features`.
- Terminologia obbligatoria: `BUSSOLA`, mai `COMPASSO`.
- GPS resta surface-only; return-to-entry e waypoint sono situational awareness.
- Apnea experimental resta training aid, con HR/batteria/temperatura non disponibili mostrati come `HR OFF`, `BAT --`, `TEMP --`.
- Buddy Assist resta lab-only.

### Experimental iOS

- Explore Lab, POI enrichment, Apnea Review, route/settings manifest e import/queue diagnostics restano su `codex/ios-experimental-features`.
- Mock/TODO/Non sincronizzato devono rimanere visibili finche i dati production non esistono.

## PR aperte

### PR #8 - Update experimental Apnea workflow

- Branch: `codex/experimental-features` -> `main`
- Stato GitHub aggiornato: `CLEAN`, checks visibili passati.
- Rischio: contiene molte modifiche runtime sperimentali Watch; non va mergiata automaticamente in `main`.
- Raccomandazione: manual review e build macOS; preservare isolamento Apnea/Snorkeling/Buddy anche se la PR non e piu in conflitto.

### PR #9 - Add experimental Apnea companion review

- Branch: `codex/ios-experimental-features` -> `main-iOS`
- Stato GitHub aggiornato: `CLEAN`, checks visibili passati.
- Rischio: include molti file Watch/root aggiunti oltre al companion sperimentale; richiede review manuale target membership e scope.
- Raccomandazione: non merge automatico finche MAIN iOS non ha build pulita e confronto file-by-file.

## Aggiornamento audit MAIN 2026-05-17 sera

Nuovo artifact documentale generato su `main`:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx
```

Sintesi documentale:

- Apple Watch MAIN resta production-oriented su Diving, `BUSSOLA`, settings, immagini, log, export e GPS entry/exit surface-only.
- iOS MAIN resta production-oriented su Logbook, Route Review, Analysis, Planner, Gear, Settings, WatchConnectivity, KVS, import/export CSV.
- Apnea, Snorkeling, Buddy Assist, Explore Lab, POI enrichment e Apnea Review restano experimental.
- Non sono state applicate modifiche runtime durante l'audit; eventuali fix devono rimanere separati dai commit docs.

Nuovi TODO non risolti in questo pass:

- Verificare su macOS che `WatchSyncAuth` MAIN non dipenda da helper Buddy esclusi dal target MAIN.
- Verificare che i PNG referenziati da `AppIcon.appiconset/Contents.json` siano presenti nel ramo iOS MAIN.
- Completare o marcare read-only le preferenze iOS local-only.
- Aggiungere empty state, conferme delete/reset e accessibility labels dove mancanti.
- Eseguire `xcodegen generate` e build Watch/iOS su macOS prima di promozioni o merge production.

## Issue / bug report con dipendenze e priorita

| Priorita | Area | Issue / bug | Dipendenze | Azione consigliata |
| --- | --- | --- | --- | --- |
| CRITICAL | Build | Build macOS non verificato per MAIN dopo source exclusion XcodeGen | macOS, Xcode, XcodeGen | Eseguire `xcodegen generate` e build dei target `DIRDiving Watch App` / `DIRDiving iOS`. |
| HIGH | Build | Possibile dipendenza MAIN Watch da helper Buddy escluso | macOS, XcodeGen, target membership | Verificare `WatchSyncAuth` e correggere in commit runtime separato se la build lo conferma. |
| HIGH | Assets | AppIcon iOS referenzia PNG da validare nel worktree iOS MAIN | asset catalog, Xcode | Aggiungere asset mancanti o correggere Contents.json in pass asset/config separato. |
| HIGH | PR #8 | PR Watch experimental e `CLEAN` ma ampia | CI/build macOS, review safety | Non mergiare automaticamente; preservare MAIN Diving e isolamento experimental. |
| HIGH | PR #9 | PR iOS experimental e `CLEAN` ma molto ampio | review target membership | Review manuale prima del merge; evitare import di Watch experimental in iOS main. |
| HIGH | Sync | Settings sync Watch/iOS documentato local-only | product decision | Decidere se local-only e accettabile per v1 o pianificare contratto sync. |
| MEDIUM | Cloud | Tombstone KVS semplice, non conflict engine completo | device/iCloud test | Test multi-device e documentare policy ultimo salvataggio. |
| MEDIUM | Export/import | CSV import/export non validati su device esterno | iPhone, Files, Subsurface | Test file validi/malformed/empty e import Subsurface. |
| MEDIUM | UI | Six-tab iOS stable puo essere denso su iPhone piccolo | device QA | Verificare su device; eventualmente raggruppare in More. |
| LOW | Docs | Alcuni documenti storici Word/docx restano audit snapshots | nessuna | Mantenerli come storico; non cancellare. |

## Commit consigliati

```text
docs: update DIR DIVING feature documentation and branch matrix
docs: update snorkeling and apnea specifications
docs: document main readiness and release blockers
merge: resolve documentation conflicts across branches
```

## Regole future

- Non introdurre `COMPASSO`; usare `BUSSOLA`.
- Non documentare GPS come tracking subacqueo.
- Non promuovere Apnea/Snorkeling/Buddy a MAIN senza build, device QA e safety review.
- Non modificare algoritmi GPS, bussola, profondita, risalita o planner durante lavori UI-only/docs.

## Aggiornamento audit MAIN 2026-05-17 sera

Nuovo artifact documentale generato su `main`:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx
```

Sintesi documentale:

- PR `#8` e `#9` risultano `CLEAN` con checks visibili passati, ma non devono essere mergiate automaticamente perche includono superfici experimental ampie.
- Apple Watch MAIN resta production-oriented su Diving, `BUSSOLA`, settings, immagini, log, export e GPS entry/exit surface-only.
- iOS MAIN resta production-oriented su Logbook, Route Review, Analysis, Planner, Gear, Settings, WatchConnectivity, KVS, import/export CSV.
- Apnea, Snorkeling, Buddy Assist, Explore Lab, POI enrichment e Apnea Review restano experimental.
- Non sono state applicate modifiche runtime durante l'audit; eventuali fix devono rimanere separati dai commit docs.

Nuovi TODO non risolti in questo pass:

- Verificare su macOS che `WatchSyncAuth` MAIN non dipenda da helper Buddy esclusi dal target MAIN.
- Verificare che i PNG referenziati da `AppIcon.appiconset/Contents.json` siano presenti nel ramo iOS MAIN.
- Completare o marcare read-only le preferenze iOS local-only.
- Aggiungere empty state, conferme delete/reset e accessibility labels dove mancanti.
- Eseguire `xcodegen generate` e build Watch/iOS su macOS prima di promozioni o merge production.
