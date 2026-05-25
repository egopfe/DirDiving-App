# Disclaimer di sicurezza - DIR DIVING

**Versione documento:** 2026-05-25 - baseline `main` @ `ab398eb`

DIR DIVING (Apple Watch MAIN + iOS Companion) e uno strumento companion per log immersioni e supporto operativo. **Non** e un computer subacqueo certificato, **non** e un planner decompressivo certificato, **non** e un dispositivo life-support e **non** e un sistema di soccorso o navigazione sostitutivo.

## Cosa l'app non sostituisce

L'app **non** deve essere usata come:

- computer subacqueo primario;
- planner decompressivo certificato;
- sostituto di tabelle o procedure di agenzia;
- sostituto di formazione tecnica o di team;
- unica fonte per decisioni di sicurezza in immersione.

Gli utenti devono sempre affidarsi a strumentazione certificata, formazione adeguata, procedure di centro immersioni/team e giudizio umano. I calcoli del planner iOS, i valori **TTV** live, le presentazioni stile Buhlmann e le curve sono **indicativi ed educativi**.

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
- Il simulatore e macOS **non** certificano profondita o pressione.
- Le soglie 35 / 38 / 40 m sono una politica di discouragement e logging, non una certificazione di sicurezza.

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

Il planner e la schermata risultato devono mantenere avvisi in-app visibili. Il riferimento di pianificazione puo usare profondita media o massima, ma il gas di emergenza resta sempre legato alla profondita massima. Non rimuovere il disclaimer dal flusso utente salvo sostituzione con workflow certificato.

## Rami sperimentali

Apnea, Snorkeling (Live, Mappa Waypoint, Mappa Ritorno, POI), Buddy Assist e concept iOS **non** fanno parte del target MAIN (`project.yml` esclude i file). Non promuovere in release production senza review esplicita.

---

Vedi anche: [`Docs/iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) (inglese, focus companion).
