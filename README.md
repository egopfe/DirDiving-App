# DIR DIVING — watchOS Dive App
# Copyright Federico Lombardo di Monte Iato 2026
## Contenuto
Questo pacchetto contiene il codice SwiftUI/watchOS di DIR DIVING con:
- profondità attuale, media e massima
- temperatura acqua
- TTV
- RunTime
- cronometro manuale Start / Stop / Reset
- log locale ultime 40 immersioni
- profilo grafico immersione
- export CSV per Subsurface
- schermata bussola integrata
- set bearing contestuale nella schermata bussola
- scala dinamica velocità di risalita verde/giallo/rosso
- vibrazione e warning lampeggiante rosso quando la velocità di risalita supera il limite

## Navigazione e comandi
Lo standard implementato è:
- **Bussola = schermata**, non funzione da avviare.
- **Digital Crown = navigazione** tra le schermate dell'app.
- **Tasto/azione contestuale nella schermata bussola = SET BEARING / CLEAR BEARING**.
- Nessuna shortcut complessa dedicata alla bussola.

Le schermate principali sono:
1. Live immersione
2. Bussola
3. Log immersioni

## Bussola
La schermata bussola usa `CoreLocation` e `CLHeading` per mostrare:
- heading corrente in gradi
- punto cardinale
- accuratezza heading, quando disponibile
- bearing bloccato
- deviazione dal bearing impostato

Il pulsante contestuale funziona così:
- `SET BEARING`: salva la direzione corrente come bearing
- `CLEAR BEARING`: cancella il bearing salvato

Per usare la bussola è presente in `Info.plist` la chiave:
- `NSLocationWhenInUseUsageDescription`

## Velocità massima di risalita
La scala cambia automaticamente in base alla profondità corrente:
- 40–30 m: limite 10 m/min
- 30–20 m: limite 5 m/min
- 20–6 m: limite 3 m/min
- 6–0 m: limite 1 m/min

La velocità reale viene calcolata confrontando i campioni di profondità successivi. Se la profondità diminuisce, DIR DIVING calcola la risalita in m/min.

## Warning e vibrazione
Quando la velocità attuale supera il limite della fascia corrente:
- la scala lampeggia in rosso
- il bordo del pannello lampeggia
- Apple Watch vibra con feedback `.failure`
- la vibrazione viene limitata a un massimo di una ogni 2 secondi per evitare feedback continuo

Nel mockup non compare un banner inferiore fisso: il warning resta nella UI della scala e nel feedback aptico.

## Pulsanti cronometro
I pulsanti sul display comandano solo il cronometro manuale:
- START avvia il cronometro
- STOP mette in pausa
- RESET riporta a 00:00

Il RunTime di immersione resta automatico e viene gestito dalla sessione immersione.

## Tasto laterale / Action Button
Apple non espone API pubbliche per intercettare liberamente il long-press fisico del tasto laterale o dell'Action Button dentro una app watchOS. Per questo nel progetto restano inclusi due App Intent semplici:
- `ToggleStopwatchIntent`: avvia/ferma il cronometro, assegnabile all'Action Button
- `ResetStopwatchIntent`: reset del cronometro, richiamabile come intent dedicato

Quindi la pressione singola dell'Action Button può essere usata per Start/Stop cronometro. Il reset con pressione di 2 secondi non è implementabile in modo affidabile con API pubbliche Apple; il reset resta disponibile dal tasto display e dall'intent dedicato.

Per la bussola non sono stati aggiunti shortcut complessi: il bearing si imposta dalla schermata bussola con il tasto contestuale.

## Export Subsurface
Sì: la documentazione e il codice includono l'export per Subsurface.

Procedura:
1. Apri il log immersioni su DIR DIVING.
2. Seleziona una immersione.
3. Premi `Genera CSV Subsurface`.
4. Premi `Condividi CSV` e invia il file a iPhone, Mac, Files, AirDrop o email.
5. In Subsurface apri: `File > Import > Import log files > CSV`.
6. Mappa le colonne:
   - `time_sec` = tempo in secondi
   - `depth_m` = profondità in metri
   - `temperature_c` = temperatura acqua in °C
7. Subsurface ricostruirà il profilo grafico dell'immersione.


## GPS automatico inizio/fine immersione

DIR DIVING registra automaticamente il punto GPS di inizio e fine immersione, anche se l'utente non preme nessun comando manuale.

### Punto GPS di inizio immersione
Quando Apple Watch entra in modalità immersione / submersione:

1. DIR DIVING salva subito l'ultimo punto GPS valido già disponibile.
2. Avvia una richiesta `best effort` di posizione aggiornata.
3. Se entro pochi secondi arriva un fix migliore, aggiorna il punto di inizio.
4. Se il fix non arriva, resta salvato l'ultimo punto registrabile disponibile prima dell'immersione.

Questo comportamento è pensato perché il GPS sott'acqua non è affidabile: il punto di inizio deve essere preso in superficie o immediatamente prima della discesa.

### Punto GPS di fine immersione
Quando Apple Watch esce dalla modalità immersione perché torna fuori dall'acqua:

1. DIR DIVING salva subito l'ultimo punto GPS disponibile.
2. Prova per alcuni secondi ad acquisire un nuovo fix di superficie.
3. Se arriva un fix migliore, lo usa come punto fine.
4. Se non arriva, mantiene l'ultimo punto valido già registrato.

### Visualizzazione e uso
- Nel dettaglio immersione vengono mostrate coordinate e accuratezza stimata.
- Il dato GPS va considerato come posizione di superficie/entry-exit, non come tracking subacqueo continuo.
- L'app mantiene il GPS aggiornato mentre è attiva per avere sempre un ultimo punto registrabile pronto da salvare.

Permesso richiesto in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DIR DIVING usa la posizione per la bussola e per registrare il punto GPS di inizio e fine immersione quando disponibile in superficie.</string>
```

### Subsurface e coordinate GPS

L'export CSV Subsurface resta disponibile dal dettaglio immersione. Il file contiene:

- campioni `time_sec`, `depth_m`, `temperature_c`
- righe commentate con `start_lat`, `start_lon`, `end_lat`, `end_lon` quando disponibili

In Subsurface importa il CSV da **File > Import > Import log files > CSV** e mappa le colonne tempo/profondità/temperatura. Le coordinate sono incluse come metadati DIR DIVING nel CSV; se la procedura CSV di Subsurface non le usa automaticamente, restano comunque disponibili nel file esportato e nel dettaglio immersione dell'app.

## Revisione compatibilità API — 27/04/2026

Ho riallineato il codice alle firme pubbliche Apple più recenti per la parte submersione:

- disponibilità verificata con `CMWaterSubmersionManager.waterSubmersionAvailable`;
- delegate aggiornato con metodi `manager(_:didUpdate:)` per `CMWaterSubmersionEvent`, `CMWaterSubmersionMeasurement` e `CMWaterTemperature`;
- gestione errori con `manager(_:errorOccurred:)`;
- metodi delegate marcati `nonisolated` per evitare errori di actor isolation con Swift moderno;
- app icon set espanso con le dimensioni watchOS principali oltre alla marketing icon da 1024 px.

### Apple Watch Ultra 5
Al momento della revisione non risulta un modello Apple Watch Ultra 5 ufficialmente documentato da Apple. La compatibilità dichiarabile è quindi: **Apple Watch Ultra e modelli successivi che espongono `CMWaterSubmersionManager` e il sensore di profondità/temperatura acqua**. Se un futuro Apple Watch Ultra 5 manterrà le stesse API pubbliche, il progetto è strutturalmente compatibile; andrà comunque ricompilato e validato con l'SDK Apple disponibile al momento.

### Nota compilazione
Non posso eseguire `xcodebuild` watchOS in questo ambiente perché non è disponibile Xcode/macOS. Il progetto è stato ricontrollato staticamente e preparato per generazione tramite XcodeGen su Mac.

## Immagini caricate da PC/Mac e visualizzazione sull'orologio

È stata aggiunta una schermata **Schermi** dentro DIR DIVING, navigabile con la Digital Crown insieme a Live, Bussola e Log.

### Cosa fa
La schermata permette di visualizzare immagini personalizzate già preparate nelle dimensioni dello schermo dell'Apple Watch. È utile per:
- checklist grafiche;
- promemoria di immersione;
- tabelle personali;
- schermate statiche o procedure da consultare sott'acqua/in superficie.

### Come caricare le immagini dal PC/Mac
watchOS non consente a una app standalone di leggere direttamente file dal filesystem di un PC. Per questo la soluzione implementata è tramite risorse incluse nel progetto:

1. Prepara le immagini sul PC/Mac in formato `PNG`, `JPG`, `JPEG` o `HEIC`.
2. Usa dimensioni pari o proporzionate allo schermo del tuo Apple Watch.
3. Copia i file dentro:

```text
DIRDiving/Resources/UserImages/
```

4. Se usi XcodeGen, rigenera il progetto:

```bash
xcodegen generate
```

5. Apri Xcode, compila e installa l'app sull'Apple Watch.
6. Apri DIR DIVING e vai alla schermata **Schermi**.
7. Seleziona l'immagine e visualizzala a pieno schermo.

### Dimensioni consigliate
Per immagini pensate per lo schermo completo, prepara file già ottimizzati per il modello di Apple Watch target. In generale:
- formato verticale;
- sfondo scuro;
- testi grandi;
- alto contrasto;
- evitare dettagli piccoli, perché in immersione sono poco leggibili.

### Aggiornamento immagini
Per aggiungere o sostituire immagini:
1. aggiungi/rimuovi i file nella cartella `Resources/UserImages`;
2. ricompila l'app;
3. reinstalla/sincronizza su Apple Watch.

### Estensione futura
Se in futuro vuoi caricare immagini senza ricompilare l'app, serve una companion app iPhone o una funzione di sincronizzazione via `WatchConnectivity`. La struttura `UserImageStore` è già predisposta per leggere anche immagini presenti nella cartella Documents dell'app, quindi può essere estesa in seguito per ricevere file trasferiti da iPhone.
