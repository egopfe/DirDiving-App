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
4. Configurazione `Acque Libere` con righe UI per allarmi, intervallo superficie e profondita massima.
5. Countdown `03`, `02`, `01 / VAI` con avanzamento automatico e tap manuale.
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

Non ancora persistito perche manca un modello dedicato:

- configurazione dettagliata sessione Apnea;
- campioni profondita per grafico reale;
- profondita media;
- temperatura acqua Apnea;
- frequenza cardiaca media/massima;
- velocita discesa/risalita calcolate;
- tipi sessione diversi da `Acque Libere`.

## Sensori e limiti

- La profondita viene letta dal flusso esistente `DiveManager`.
- Il warning risalita riusa lo stato esistente `ascentStatus`; non modifica i calcoli di risalita.
- Frequenza cardiaca, batteria e temperatura sono visualizzati come placeholder dove non esiste una sorgente dati Apnea dedicata.
- Il GPS non viene usato per tracking subacqueo Apnea; eventuali dati GPS restano surface-only come nel resto del progetto.

## Companion iOS

Il ramo `codex/ios-experimental-features` include una card `Apnea Review` in `ExplorationCenterView`.

La card mostra:

- header `Apnea`;
- tab visuali `Riepilogo`, `Grafico`, `Dettagli`;
- profilo/percorso mock in stile dark-cyan;
- metriche placeholder per profondita massima, tempo e temperatura acqua.

La sincronizzazione reale dei record Apnea Watch verso iOS resta TODO. Il companion non cambia runtime Watch, BLE, GPS o persistenza Watch.

## Sicurezza

Apnea experimental e un training aid UI. Non sostituisce procedure buddy, addestramento, strumenti certificati, supervisione in acqua o valutazione conservativa del rischio.
