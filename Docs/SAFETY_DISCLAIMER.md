# Disclaimer di sicurezza - DIR DIVING

**Versione documento:** 2026-05-19 — baseline `main` @ `92e639a` + pass documentale corrente

DIR DIVING (Apple Watch MAIN + iOS Companion) e uno strumento companion per log immersioni e supporto operativo. **Non** e un computer subacqueo certificato, **non** e un planner decompressivo certificato, **non** e un dispositivo life-support e **non** e un sistema di soccorso o navigazione sostitutivo.

## Cosa l'app non sostituisce

L'app **non** deve essere usata come:

- computer subacqueo primario;
- planner decompressivo certificato;
- sostituto di tabelle o procedure di agenzia;
- sostituto di formazione tecnica o di team;
- unica fonte per decisioni di sicurezza in immersione.

Gli utenti devono sempre affidarsi a strumentazione certificata, formazione adeguata, procedure di centro immersioni/team e giudizio umano. I calcoli del planner iOS, i valori **TTV** live (indice informativo, non NDL/TTS/deco), le presentazioni stile Buhlmann e le curve sono **indicativi ed educativi**.

La filosofia UX MAIN privilegia warning **non bloccanti** sott'acqua: i banner di risalita e profondita scoraggiano comportamenti a rischio senza nascondere profondita, runtime, gauge o controlli critici.

## Onboarding e accettazione obbligatoria

Dal 2026-05-22 l'app mostra un onboarding legale al primo avvio su Apple Watch e iOS Companion. Il flusso include:

- schermata di benvenuto;
- avviso esplicito **DIR Diving is NOT a dive computer.**;
- disclaimer completo scrollabile in italiano o inglese;
- accettazione con conferme obbligatorie su certificazione subacquea, non uso come computer subacqueo, non uso come supporto vitale primario e accettazione termini/disclaimer.

L'accettazione viene registrata localmente con timestamp, versione app accettata, major version, tipo dispositivo, lingua e revisione legale. Un cambio major version o revisione legale richiede nuova accettazione. La sezione **Legal & Safety** nei settings permette di rileggere il disclaimer completo e vedere i metadati di accettazione.

## Profondita e sensore (Apple Watch Ultra)

- L'entitlement **water submersion** va approvato in Apple Developer e validato su **hardware reale** (non simulatore).
- Fino a validazione completa, la profondita automatica puo non essere disponibile: usare **avvio manuale** dove documentato.
- Il pulsante Watch **Start Dive** e un percorso manuale di superficie; non disattiva l'avvio automatico da profondita quando il sensore e disponibile.
- Il simulatore e macOS **non** certificano profondita o pressione.
- Le soglie 35 / 38 / 40 m sono una politica di discouragement e logging, non una certificazione di sicurezza.

## Mission Mode

- Mission Mode e un profilo **interno DIR DIVING** di ottimizzazione runtime/UI del Watch MAIN, non una modalita immersione separata e **non** la modalita Basso Consumo di sistema di Apple Watch.
- DIR DIVING **non** puo attivare il Basso Consumo di sistema tramite API pubblica.
- Auto-enable all'inizio immersione, controllo manuale da Settings (superficie) o fulmine in Live (immersione attiva); disattivazione automatica a fine immersione.
- **Non** riduce monitoraggio safety-critical, **non** cambia warning, **non** modifica campionamento profondita, logging, GPS entry/exit, calcoli, soglie allarme o algoritmi immersione.
- Riduce solo animazioni/effetti visivi non essenziali su Live e Bussola.
- L'indicatore/controllo fulmine nel live header non sostituisce warning o metriche di sicurezza.

## GPS (solo superficie)

- GPS e metadata di **superficie** per ingresso/uscita e revisione percorso.
- **Non** e tracking subacqueo affidabile; sott'acqua o con cielo coperto il fix puo mancare.
- Coordinate mancanti o *ultimo punto noto* devono essere lette come etichettate, non come successo dell'immersione.

## Bussola e snorkeling sperimentale

- Terminologia UI: **BUSSOLA** (mai "COMPASSO").
- **Return-to-entry** e mappe snorkeling su rami experimental sono ausili di consapevolezza situazionale, non navigazione certificata.
- Il tasto laterale Apple Watch resta **system-controlled**; eventuali azioni aggiuntive passano da **Shortcuts / App Intents / Action Button** solo quando watchOS le espone.

## Sync e dati

- Sync Watch <-> iPhone richiede pairing verificato; i dati possono essere in coda o in conflitto: controllare stato in Impostazioni / Altro.
- Export **Subsurface CSV** e per flusso log; il formato business delle colonne non implica validazione decompressiva.
- La visibilita sync in MAIN mostra stato e attivita recenti, ma non sostituisce ancora una prova hardware end-to-end di ogni trasferimento.

## Planner iOS

Il planner e la schermata risultato devono mantenere avvisi in-app visibili. Il planner iOS e **reference-only** (non pianificazione decompressiva certificata). Il riferimento di pianificazione puo usare profondita media o massima, ma il gas di emergenza resta sempre legato alla profondita massima. Non rimuovere il disclaimer dal flusso utente salvo sostituzione con workflow certificato.

## Rami sperimentali

Snorkeling (Live, Mappa Waypoint, Mappa Ritorno, POI), Buddy Assist e concept iOS **non** fanno parte del target MAIN (`project.yml` esclude i file). Non promuovere in release production senza review esplicita.

### Apnea (`main` — Watch MAIN promotion)

- Training/logbook companion per apnea — **non** computer subacqueo certificato e **non** sistema di soccorso.
- **Nessun** rilevamento blackout, ipossia o assenza di movimento: non promettere queste funzioni in marketing o UI.
- Il promemoria buddy sul Watch e la checklist iOS **non** sostituiscono un buddy fisico in acqua; l'app **non** fornisce monitoraggio remoto di soccorso (`apnea.ios.buddy.disclaimer`).
- Con sensore profondità degradato o non disponibile, l'avvio sessione Apnea sul Watch è **bloccato** (stato `sensorDegraded`).
- Sessioni con qualità dati degradata sono escluse dai record personali per default.
- Runtime isolato: `ApneaWatchRuntimeStore` + `ApneaSessionEngine` — **nessuna** dipendenza da `DiveManager`.
- Vedi [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md) e [`DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md`](DIR_DIVING_APNEA_RELEASE_HARD_VALIDATION_REPORT.md).

---

Vedi anche: [`Docs/iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) (inglese, focus companion).
