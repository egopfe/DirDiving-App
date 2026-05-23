# DIR DIVING - Specifica Apnea Experimental

Questo documento descrive lo stato UI/UX e il comportamento sperimentale Apnea su Apple Watch, con il relativo punto di review sul companion iOS. Le funzioni sono isolate sui rami `codex/experimental-features` e `codex/ios-experimental-features`.

## Principi UI

- Sfondo nero pieno, pannelli minimi e numeri grandi ad alta leggibilita.
- Accento blu `#0084FF` per navigazione e stato tecnico.
- Ciano `#00D6EB` per superfici companion e profili.
- Verde `#28E64B` per conferme e recupero completato.
- Giallo `#FFD220` per attenzione, countdown, recovery e stato intermedio.
- Rosso `#FF362D` solo per warning o risalita troppo veloce.
- Nessuna card generica chiara o layout marketing nel Watch runtime.

## Workflow Apple Watch

Il flusso sperimentale Apnea e composto da:

1. Home mode selection con `Apnea` evidenziabile dal selettore modalita.
2. Menu Apnea con `Sessione`, `Tabelle`, `Statistiche` e `Logbook`.
3. Selezione tipo sessione con `Acque Libere` attiva e `Dinamica`, `Statica`, `Personalizzata` come placeholder disabilitati.
4. Configurazione `Acque Libere` con allarmi raggiungibili, intervallo superficie e profondita massima modificabili.
5. Countdown `03`, `02`, `01 / VAI` con avanzamento automatico, tap manuale e haptic tick/start.
6. Surface waiting: sessione attiva in superficie, timer immersione fermo, profondita a zero.
7. Discesa: avvio automatico del timer Apnea quando la profondita supera la soglia UI di immersione.
8. Fondo/profondita: visualizzazione grande della profondita e runtime.
9. Risalita: stato visuale derivato da profondita e tempo quando non esiste ancora uno stato motore dedicato.
10. Allarme risalita: usa `DiveManager.ascentStatus.isOverLimit` senza cambiare soglie o algoritmi.
11. Surface end: chiusura immersione tramite `ExplorationStore.surfaceFromApnea(...)`.
12. Recovery: timer superficie con logica esistente `max(durata * 2, 30)`.
13. Riepilogo: durata e profondita massima dalla sessione salvata.
14. Grafico profondita: profilo SwiftUI placeholder finche il record non espone campioni.
15. Dettagli: metriche placeholder per velocita discesa, velocita risalita e frequenza cardiaca.
16. Conferma salvataggio: UI di successo; la persistenza avviene gia nella chiusura sessione.
17. Logbook: mostra il record Apnea piu recente e righe placeholder.
18. Statistiche: usa record esistenti per profondita massima e conteggio; totale e media restano TODO.

## Stato e persistenza

La UI Apnea usa `ExplorationStore` e non introduce nuovi modelli persistenti in questo pass.

Persistito oggi:

- modalita selezionata;
- stato Apnea condiviso;
- record Apnea con durata, profondita massima e recovery richiesta;
- timer Apnea e recovery;
- contatore immersioni;
- warning Apnea.
- configurazione locale sperimentale `Intervallo superficie` e `Profondita max allarme` tramite `AppStorage`.

Non ancora persistito in un modello dedicato perche manca il contratto dati definitivo:

- campioni profondita per grafico reale;
- profondita media;
- temperatura acqua Apnea;
- frequenza cardiaca media/massima;
- velocita discesa/risalita calcolate;
- tipi sessione diversi da `Acque Libere`.

Il pass corrente aggiunge boundary UI esplicite per `Watch -> iPhone Apnea`: durata, profondita massima e recovery sono disponibili come record locale, mentre profilo campioni reale, duplicate prevention production e merge iOS restano roadmap. Il Watch mostra stato payload, delivery e coda sperimentale per evitare sync silenziosi.

## Sensori e limiti

- La profondita viene letta dal flusso esistente `DiveManager`.
- Il warning risalita riusa lo stato esistente `ascentStatus`; non modifica i calcoli di risalita.
- Frequenza cardiaca, batteria e temperatura non usano valori finti: la UI mostra `HR OFF`, `BAT --` e `TEMP --` finche non esiste una sorgente dati Apnea dedicata.
- Se il sensore profondita non e disponibile, la UI mostra `--` invece di una profondita zero apparentemente valida.
- Il GPS non viene usato per tracking subacqueo Apnea; eventuali dati GPS restano surface-only come nel resto del progetto.

## Companion iOS

Il ramo `codex/ios-experimental-features` include una card `Apnea Review` in `ExplorationCenterView`.

La card mostra:

- header `Apnea • MOCK`;
- tab interattivi `Riepilogo`, `Grafico`, `Dettagli`;
- profilo/percorso mock in stile dark-cyan;
- metriche placeholder per profondita massima, tempo e temperatura acqua.

La sincronizzazione dei record Apnea Watch verso iOS usa un contratto lightweight e stato import sperimentale; non e ancora una pipeline production con profilo campioni, retry persistente, merge e duplicate prevention. Il companion non cambia runtime Watch, BLE, GPS o persistenza Watch.

Il companion iOS experimental mostra sempre etichette `Mock`, `TODO`, `Non sincronizzato` o equivalenti per evitare di presentare dati locali come sync production.

## Sicurezza

Apnea experimental e un training aid UI. Non sostituisce procedure buddy, addestramento, strumenti certificati, supervisione in acqua o valutazione conservativa del rischio.
