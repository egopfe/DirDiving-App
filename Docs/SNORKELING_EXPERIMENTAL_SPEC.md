# DIR DIVING - Specifica Snorkeling Experimental

Questo documento descrive lo stato UI/UX sperimentale Snorkeling su Apple Watch e il ruolo del companion iOS. Le funzioni sono isolate sul ramo `codex/experimental-features` salvo dove indicato nella matrice branch.

## Principi UI

- Sfondo nero pieno e pannelli tecnici scuri.
- Accento ciano per navigazione e mappe.
- Verde per stato attivo, GPS OK e marker salvati.
- Giallo per waypoint, direzione, attenzione e valori target.
- Rosso solo per eliminazione o pericolo.
- Nessuna card SwiftUI generica o sfondo chiaro.
- Terminologia obbligatoria: `BUSSOLA`, mai `COMPASSO`.

## Schermata Live Snorkeling

La schermata live sperimentale mostra:

- `SNORKELING` in ciano.
- Stato `IN ATTIVITA`.
- Runtime, distanza e velocita media.
- Profondita attuale, profondita massima e tempo totale.
- Stato GPS senza conteggio satelliti o `FIX 3D`.
- Pannello `VERSO WAYPOINT` con nome waypoint, distanza e direzione.
- Azioni `MARCATORE`, `RITORNO`, `BUSSOLA`.

I valori vengono riusati da `ExplorationStore`, `GPSManager`, `CompassManager` e `DiveManager` quando presenti. Se una sorgente dati manca, la UI deve usare placeholder con `TODO` esplicito.

## Mappa Waypoint

`Mappa Waypoint` mostra la posizione utente rispetto al prossimo waypoint selezionato.

- Titolo centrale: `MAPPA WAYPOINT`.
- Card superiore: `PROSSIMO WAYPOINT`, nome, distanza e direzione.
- Mappa SwiftUI leggera con sfondo marino scuro, marker corrente, target giallo, rotta tratteggiata gialla, controlli zoom e scala `100 m`.
- Pulsante `INDIETRO`.

Non deve essere confusa con `Mappa Ritorno`.

## Mappa Ritorno

`Mappa Ritorno` mostra come tornare al punto di partenza/sessione.

- Titolo centrale: `MAPPA RITORNO`.
- Card superiore: `RITORNO AL PUNTO DI PARTENZA`, distanza e direzione.
- Mappa SwiftUI leggera con home/entry marker, marker corrente, rotta tratteggiata ciano, controlli zoom e scala `100 m`.
- Pulsante `INDIETRO`.

L'azione `RITORNO` dalla schermata live apre questa schermata.

## Direzione Waypoint

`Direzione Waypoint` e una funzione di navigazione verso waypoint, non la bussola generica.

- Titolo: `DIREZIONE WAYPOINT`.
- Dial circolare con tick, cardinali, anello giallo interno e freccia direzionale.
- Valore bearing in giallo e direzione cardinale.
- Card inferiore: `VERSO WAYPOINT`, nome e distanza.
- Pulsante `INDIETRO`.

Non modifica gli algoritmi bussola; usa heading e bearing gia disponibili.

## Marcatori / POI

`MARCATORE` su Watch e una quick-capture di Point Of Interest.

Payload leggero previsto:

- timestamp;
- ultima coordinata GPS valida;
- profondita superficiale/shallow se disponibile;
- temperatura se disponibile;
- heading/bearing se disponibile;
- waypoint attivo se disponibile;
- session id quando esposto;
- `isEnriched = false` quando il modello dedicato verra introdotto.

Il Watch non modifica foto, commenti o categorie avanzate. Il companion iOS arricchira i POI dopo sync con foto, video, commenti, categoria, tag e note di osservazione/specie. La UI Watch deve indicare `Da arricchire su iPhone` o `Companion iOS` dove pertinente.

## Allarmi Snorkeling

Gli allarmi Snorkeling sono specifici della modalita e non includono settings globali:

- Profondita massima.
- Tempo massimo.
- Distanza massima.
- Batteria bassa.

Finche non esiste uno store dedicato, le soglie sono placeholder UI con `TODO`.

## Limite GPS

DIR DIVING tratta il GPS come informazione di superficie. In acqua o sott'acqua il fix puo non essere affidabile; le mappe Watch usano visualizzazioni leggere basate su ultimo punto valido, bearing e contesto waypoint/entry.

## Mappe libere e roadmap tecnica

Per il companion iOS, l'architettura preferita e:

- MapLibre Native o wrapper SwiftUI compatibile se validato nel progetto.
- Base tile OpenStreetMap-compatible.
- OpenSeaMap come overlay marino opzionale.
- MBTiles come formato cache/offline futuro.
- GEBCO/EMODnet come overlay batimetrici futuri.

Per Apple Watch, in questo pass non si scaricano tile online. La UI resta una mappa SwiftUI leggera. I server pubblici OpenStreetMap hanno policy d'uso: in produzione preferire server self-hosted, provider approvato o MBTiles pacchettizzati/offline.

## Sicurezza

Snorkeling, waypoint, ritorno al punto iniziale, POI e mappe sono funzioni sperimentali di situational awareness. Non sostituiscono addestramento, procedure buddy, strumenti certificati, pianificazione conservativa o valutazione reale dell'ambiente.
