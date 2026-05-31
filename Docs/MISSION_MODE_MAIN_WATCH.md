# Mission Mode — Watch MAIN

**Aggiornato:** 2026-05-26
**Ambito:** solo Apple Watch `main` (nessun file experimental, nessun cambiamento companion iOS richiesto)

---

## Scopo

Mission Mode e un profilo di ottimizzazione runtime/UI per immersioni attive su Apple Watch MAIN. Riduce attivita visive non essenziali durante la sessione senza cambiare logica immersione, warning safety, campionamento profondita, logging o GPS di superficie.

---

## Persistenza impostazione

- Setting Watch: **Mission Mode**
- Toggle: **Auto-enable on dive start**
- Persistenza locale: `@AppStorage`
- Chiave: `dirdiving.missionMode.autoEnableOnDiveStart`
- Default: **OFF**

La preferenza resta salvata dopo riavvio app/dispositivo. Lo stato runtime attivo **non** viene persistito.

---

## Condizioni di attivazione

Mission Mode si attiva **solo** dopo che l'app entra in stato immersione attiva (`isDiveActive == true`) e **solo** se la preferenza auto-enable e attiva.

Path coperti:

- avvio automatico da sensore / `CMWaterSubmersionManager`
- avvio manuale dalla schermata live / ready

Mission Mode **non** avvia un'immersione da solo e non modifica la logica che decide quando l'immersione inizia.

---

## Condizioni di disattivazione

Mission Mode viene disattivato automaticamente quando la sessione immersione termina.

- Lo stato runtime torna a `false`
- La preferenza utente resta invariata

---

## Ambito ottimizzazione runtime

Quando Mission Mode e attivo durante una dive session:

- vengono ridotte/disattivate animazioni non essenziali nelle view Watch MAIN gia esistenti;
- vengono ridotti glow/shadow decorativi non critici;
- le transizioni non essenziali possono diventare immediate per ridurre overhead di rendering.

L'ottimizzazione si applica solo a superfici UI gia presenti, in particolare Live e BUSSOLA, senza cambiare layout core o flusso navigazione.

---

## Indicatore visivo

Quando Mission Mode e attivo durante una sessione immersione attiva, il Watch MAIN mostra un indicatore icona minimale vicino all'icona polpo nell'area superiore sinistra del live display.

- visibile solo se `isDiveActive == true` e `isMissionModeActive == true`;
- nascosto fuori immersione e nelle altre schermate;
- solo icona, nessun testo;
- nessun banner, pannello o overlay aggiuntivo;
- nessuna animazione continua o timer dedicato.

Scopo: indicare lo stato di ottimizzazione runtime in modo professionale e non invasivo, senza cambiare la gerarchia visiva del live screen.

---

## Esclusioni di sicurezza

Mission Mode **non** modifica:

- profondita attuale / media / massima;
- runtime immersione;
- logica warning risalita;
- warning limiti profondita supportata;
- alert aptici gia implementati;
- accuratezza campionamento profondita;
- accuratezza logging immersione;
- GPS entry/exit logging behavior;
- calcoli dive / deco / planner;
- business logic di start/end dive.

Mission Mode e quindi **solo** un profilo di ottimizzazione runtime/UI, non una modalita safety ridotta e non una modalita di risparmio che degrada monitoraggio critico.
