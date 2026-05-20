# Disclaimer di sicurezza — DIR DIVING

**Versione documento:** 2026-05-20 · rami `main` / `main-iOS`

DIR DIVING (Apple Watch MAIN + iOS Companion) **non** è un computer subacqueo certificato, **non** è un planner decompressivo certificato e **non** è un sistema di soccorso o navigazione sostitutivo.

## Cosa l'app non sostituisce

L'app **non** deve essere usata come:

- computer subacqueo primario;
- planner decompressivo certificato;
- sostituto di tabelle o procedure di agenzia;
- sostituto di formazione tecnica o di team;
- unica fonte per decisioni di sicurezza in immersione.

I calcoli del planner iOS, i valori **TTV** live, le presentazioni stile Bühlmann e le curve sono **indicativi ed educativi**. Verificare sempre con strumenti certificati, formazione, gas reale e giudizio umano.

## Profondità e sensore (Apple Watch Ultra)

- L'entitlement **water submersion** va approvato in Apple Developer e validato su **hardware reale** (non simulatore).
- Fino a validazione completa, la profondità automatica può non essere disponibile: usare **avvio manuale** dove documentato.
- Il simulatore e macOS **non** certificano profondità o pressione.

## GPS (solo superficie)

- GPS è metadata di **superficie** per ingresso/uscita e revisione percorso.
- **Non** è tracking subacqueo affidabile; sott'acqua o con cielo coperto il fix può mancare.
- Coordinate mancanti o *ultimo punto noto* devono essere lette come etichettate, non come successo dell'immersione.

## Bussola e snorkeling sperimentale

- Terminologia UI: **BUSSOLA** (mai «COMPASSO»).
- **Return-to-entry** e mappe snorkeling su rami experimental sono ausili di consapevolezza situazionale, non navigazione certificata.

## Sync e dati

- Sync Watch ↔ iPhone richiede pairing verificato; i dati possono essere in coda o in conflitto — controllare stato in Impostazioni / Altro.
- Export **Subsurface CSV** è per flusso log; il formato business delle colonne non implica validazione decompressiva.

## Planner iOS

Il planner e la schermata risultato devono mantenere avvisi in-app visibili. Non rimuovere il disclaimer dal flusso utente salvo sostituzione con workflow certificato.

## Rami sperimentali

Apnea, Snorkeling (Live, Mappa Waypoint, Mappa Ritorno, POI), Buddy Assist e concept iOS **non** fanno parte del target MAIN (`project.yml` esclude i file). Non promuovere in release production senza review esplicita.

---

Vedi anche: [`Docs/iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) (inglese, focus companion).
