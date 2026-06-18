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
- `isEnriched = false`.

Stato implementato sul ramo experimental:

- tap su `MARCATORE` salva un `GPSInterestMarker` leggero in `ExplorationStore`;
- la UI mostra conferma `MARCATORE SALVATO`, check verde, haptic e link a `LOG` / `DETTAGLI`;
- se il GPS non e disponibile, la UI mostra `GPS NON DISPONIBILE` e non finge coordinate;
- `Log Marcatori` e `Dettaglio Marcatore` sono raggiungibili da `Impostazioni Snorkeling`;
- il dettaglio mostra ora, distanza, direzione, profondita, temperatura, waypoint attivo, session id e stato `Da arricchire su iPhone`;
- la UI mostra stato di sync sperimentale Watch -> iPhone con tipo payload, coda locale e stato delivery;
- queue persistente completa, duplicate prevention production e conferma ricezione iPhone restano roadmap.

Il Watch non modifica foto, commenti o categorie avanzate. Il companion iOS espone la superficie di enrichment dopo sync con foto, video, commenti, categoria, tag e note di osservazione/specie, ma media picker/storage reali restano TODO sperimentali.

## Allarmi Snorkeling

Gli allarmi Snorkeling sono specifici della modalita e non includono settings globali:

- Profondita massima.
- Tempo massimo.
- Distanza massima.
- Batteria bassa.

Stato attuale:

- le soglie sono modificabili da Apple Watch;
- la persistenza locale usa `AppStorage`;
- profondita, tempo e distanza sono enforce locali con warning/haptic;
- `Batteria bassa` resta configurata ma indicata come non cablata finche non esiste una sorgente batteria;
- non esiste ancora uno store Snorkeling dedicato;
- sync iPhone -> Watch settings, duplicate prevention e offline queue persistente sono LAB/roadmap espliciti.

## Lifecycle sessione e stati indisponibili

Il pass blocker-resolution ha reso visibile il lifecycle Snorkeling:

- l'apertura della schermata Snorkeling avvia la sessione se necessario;
- il punto entry viene acquisito dal miglior GPS disponibile, oppure la UI mostra `GPS NON DISPONIBILE - ENTRY PENDING`;
- `Mappa Ritorno` resta non disponibile finche non esiste un entry point;
- se il sensore profondita non e disponibile, i valori profondita devono mostrare `--` o warning dedicato, non `0.0` come dato reale.

Questa scelta mantiene la modifica incrementale e non introduce nuova architettura di persistenza.

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

## Schermate Snorkeling raggiungibili

La navigazione sperimentale Watch espone:

- `Snorkeling Live`;
- `Mappa Waypoint`;
- `Mappa Ritorno`;
- `Direzione Waypoint`;
- `Log Marcatori`;
- `Dettaglio Marcatore`;
- `Impostazioni Snorkeling`;
- `Allarmi Snorkeling`;
- `Calibrazione Bussola`;
- `Legenda Icone Mappe`.

`Calibrazione Bussola` e istruttiva e non modifica gli algoritmi `CompassManager`. `Legenda Icone Mappe` documenta posizione corrente, waypoint, punto di partenza, POI/marcatore, rotta waypoint e rotta ritorno.

## Sicurezza

Snorkeling, waypoint, ritorno al punto iniziale, POI e mappe sono funzioni sperimentali di situational awareness. Non sostituiscono addestramento, procedure buddy, strumenti certificati, pianificazione conservativa o valutazione reale dell'ambiente.

GPS puo essere assente o impreciso; la traccia misurata e superficiale; i segmenti subacquei possono essere stimati o non disponibili; la navigazione e solo di riferimento; l'utente resta responsabile di rotta e condizioni.

## Foundation boundary (Commands 01–03, 2026-06-18)

Il runtime condiviso `Shared/` (domain, feed, `SnorkelingSessionEngine`) e validato senza UI MAIN. `SnorkelingView` resta esclusa da Watch MAIN. Bearing, waypoint advisor e persistenza su disco appartengono a Command 04 e Command 07 — vedi contratti in `Docs/SNORKELING_NAVIGATION_RETURN_ENGINE_CONTRACT.md` e `Docs/SNORKELING_PERSISTENCE_RECOVERY_CONTRACT.md`.
