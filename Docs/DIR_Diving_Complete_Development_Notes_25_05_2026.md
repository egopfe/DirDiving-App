# DIR Diving — Complete Development Notes

_Last updated: 2026-05-24_

---

# 1) Comuni per App iOS ed Apple Watch

## Verifica aggiornamento icone app

Su entrambe le app bisogna ricontrollare l’integrazione delle nuove icone, perché al momento le icone non risultano cambiate.

### Ambito
- App iOS
- App Apple Watch

### Comportamento atteso
- L’icona iOS deve essere aggiornata con il nuovo asset ufficiale previsto.
- L’icona Apple Watch deve essere aggiornata con il nuovo asset ufficiale previsto.
- L’icona deve risultare corretta:
  - nella Home Screen iOS
  - nella lista app Apple Watch
  - nel simulatore
  - sul dispositivo reale
  - in Xcode/AppIcon asset catalog
  - in App Store Connect, se applicabile

### Requisiti tecnici
- Verificare che gli asset siano stati inseriti nell’Asset Catalog corretto.
- Verificare che tutte le dimensioni richieste da iOS siano presenti.
- Verificare che tutte le dimensioni richieste da watchOS siano presenti.
- Verificare che il target iOS punti all’AppIcon corretto.
- Verificare che il target watchOS punti all’AppIcon corretto.
- Verificare che non ci siano asset duplicati o vecchie icone ancora collegate.
- Pulire Derived Data / cache simulatore se necessario per validare correttamente il cambio icona.
- Non modificare la grafica interna dell’app.
- Non cambiare il branding già definito: bisogna solo assicurarsi che le nuove icone vengano effettivamente usate.

---

# 2) Solo iOS

## Validazione e conversione immagini per Apple Watch

Quando dall’app iOS si carica una immagine da inviare all’Apple Watch, l’app deve verificare che il file sia nel formato corretto in termini di risoluzione e compatibilità con la visualizzazione su watchOS.

### Comportamento
- Controllare automaticamente risoluzione, proporzioni e formato dell’immagine.
- Se l’immagine non è adatta alla visualizzazione su Apple Watch, convertirla automaticamente.
- Ridimensionare/comprimere l’immagine mantenendo la migliore leggibilità possibile.
- Prima o durante la conversione, avvisare l’utente che la conversione potrebbe ridurre la leggibilità sull’Apple Watch.
- Il messaggio deve essere localizzato in italiano e inglese.

### Messaggio italiano
“L’immagine non è nel formato ottimale per Apple Watch. Verrà convertita automaticamente, ma la conversione potrebbe renderla meno leggibile sullo schermo dell’orologio.”

### Messaggio inglese
“The image is not in the optimal format for Apple Watch. It will be automatically converted, but the conversion may make it less readable on the watch screen.”

### Requisiti tecnici
- Validazione lato iOS prima dell’invio.
- Conversione automatica solo se necessaria.
- Nessuna modifica manuale richiesta all’utente.
- Gestione errori se la conversione non riesce.
- UI coerente con il design attuale dell’app.

---

## Checklist — “La mia attrezzatura” e modelli salvabili

Nella sezione checklist dell’app iOS deve essere aggiunto un tasto chiamato:

- Italiano: “La mia attrezzatura”
- Inglese: “My equipment”

Questa funzione deve permettere all’utente di creare, salvare e richiamare modelli di attrezzatura preconfigurati.

### Esempi di modelli
- Italiano: “Attrezzatura REC”
- Inglese: “REC Equipment”

- Italiano: “Attrezzatura TEC”
- Inglese: “TEC Equipment”

### Comportamento
- L’utente può creare un modello di attrezzatura.
- L’utente può salvare il modello.
- L’utente può modificare un modello esistente.
- L’utente può eliminare un modello.
- L’utente può richiamare un modello salvato e applicarlo alla checklist corrente.
- I modelli devono essere persistenti.
- La UI deve restare coerente con il design attuale dell’app iOS.

### Item checklist con flag GAS

Ogni item della checklist deve avere un flag dedicato:
- GAS

Se il flag GAS è attivo, l’app deve richiedere informazioni aggiuntive:
- BAR / PSI
- Dimensione bombola / Tank size

### Dimensione bombola / Tank size

La dimensione della bombola deve essere selezionabile da un menu preconfigurato.

Opzioni iniziali:
1. S80
2. S40
3. Bibo 12+12
4. 12L
5. 15L
6. 18L

### Requisiti tecnici
- Implementazione solo lato iOS.
- Persistenza locale dei modelli di attrezzatura.
- Nessuna modifica alla business logic subacquea.
- Nessun calcolo automatico dei consumi gas.
- Compatibilità con unità metriche/imperiali già previste.
- Non alterare la grafica esistente.

---

## Planner iOS — selezione tipologia bombole

Nella sezione di pianificazione dell’app iOS deve essere possibile scegliere la tipologia di bombole utilizzabili durante la pianificazione.

### Lista tipologie bombole
1. S80
2. S40
3. Bibo 12+12
4. 12L
5. 15L
6. 18L

### Requisiti
- Riutilizzare la stessa lista della funzione “La mia attrezzatura”.
- Nessuna modifica alla business logic del Planner se non necessaria.
- Nessun redesign grafico.

---

## Planner iOS — profondità media e riferimento di pianificazione

Nel tab Pianificazione dell’app iOS deve essere possibile inserire anche la profondità media dell’immersione.

### Comportamento
- Aggiungere un campo per la profondità media.
- L’utente deve poter scegliere quale profondità usare come riferimento principale per la pianificazione:
  - Profondità massima
  - Profondità media

### Regola d’oro per gas di emergenza
Indipendentemente dalla scelta dell’utente per il riferimento di pianificazione, il gas di emergenza deve essere sempre calcolato utilizzando la profondità massima.

Questa regola non deve essere modificabile dall’utente.

---

## Planner iOS — gestione bombole e ruolo del gas

Nel tab Pianificazione dell’app iOS deve essere possibile aggiungere e rimuovere bombole utilizzate nella pianificazione.

### Ruolo del gas

Per ogni bombola aggiunta, deve essere possibile scegliere una delle seguenti categorie:

#### Italiano
- Trasporto
- Fondo
- Decompressione

#### Inglese
- Travel
- Bottom
- Decompression

### Dimensione bombola

Opzioni iniziali:
1. S80
2. S40
3. Bibo 12+12
4. 12L
5. 15L
6. 18L

### Requisiti
- Per ogni bombola l’utente deve poter scegliere:
  - ruolo del gas
  - dimensione della bombola
  - tipologia di gas
- Nessun redesign grafico.
- Nessuna modifica non richiesta alla logica di pianificazione.

---

## Planner iOS — verifica MOD con legge di Dalton

Nel tab Pianificazione dell’app iOS bisogna ricontrollare il risultato generato quando l’utente preme il tasto di calcolo/pianificazione, per assicurarsi che il cambio gas venga validato correttamente rispetto alla MOD del gas selezionato.

### Problema da correggere
Esempio attuale:
- Secondo gas decompressivo impostato come O₂ al 100%
- Il Planner indica cambio gas a 9 metri

### Requisito funzionale
Per ogni bombola/gas inserito nel Planner, l’app deve calcolare la MOD usando la legge di Dalton:
- Percentuale di ossigeno inserita dall’utente
- Pressione parziale massima di ossigeno scelta/impostata dall’utente
- Eventuale presenza di Elio nella miscela

### Formula di riferimento

MOD metri = ((PPO₂ max / FO₂) - 1) × 10

### Esempi attesi
- O₂ 100% con PPO₂ max 1.6 ATA → MOD circa 6 metri
- EAN50 con PPO₂ max 1.6 ATA → MOD circa 22 metri
- Aria 21% con PPO₂ max 1.4 ATA → MOD circa 56 metri

### Requisiti
- Controllare che il cambio gas non avvenga più profondo della MOD.
- Evidenziare eventuali incoerenze.
- Non introdurre nuove logiche decompressive.
- Non modificare business logic non correlate.

---

# 3) Solo Apple Watch

## Allarme profondità massima configurabile

Aggiungere nei Settings dell’Apple Watch la possibilità di modificare il valore dell’allarme di profondità massima.

### Comportamento
- Valore di default: 40 metri
- Possibilità di ridurre o aumentare il limite
- Esempio tipico: impostazione a 30 metri
- Il valore selezionato deve essere persistente
- Feedback aptico al raggiungimento della profondità impostata
- Evidenziazione grafica/arancione/rossa quando si supera il limite impostato

---

## Navigazione coerente tra schermate

Aggiungere in ogni finestra/schermata dell’app Apple Watch la freccia di ritorno in alto a sinistra per permettere il ritorno immediato alla schermata precedente.

### Requisiti
- Comportamento coerente in tutta l’app
- Iconografia standard Apple/watchOS
- Compatibilità con Digital Crown e gesture native watchOS
- Gestione corretta dello stack di navigazione

---

## Soglia tempo immersione di default

Impostare la soglia temporale di immersione con valore di default pari a 30 minuti.

### Comportamento
- Valore iniziale automatico: 30 minuti
- Possibilità futura di modifica tramite Settings
- Persistenza del valore selezionato
- Feedback aptico o visivo al raggiungimento della soglia tempo

---
