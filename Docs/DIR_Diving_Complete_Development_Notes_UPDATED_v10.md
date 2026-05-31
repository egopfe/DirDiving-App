# DIR Diving — Complete Development Notes

_Last updated: 2026-05-25_

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


### Correzione impaginazione etichetta “Miscela Trimix”

La scritta:
- “Miscela Trimix”
oppure equivalenti collegati alla selezione TX/Trimix

non deve essere impaginata verticalmente o spezzata male nella UI.

### Requisiti UI/UX
- La label deve essere sempre visualizzata orizzontalmente.
- La label deve essere centrata correttamente.
- Evitare wrapping verticale o caratteri uno sotto l’altro.
- Garantire leggibilità sia su iPhone piccoli sia su schermi grandi.
- Mantenere coerenza con il design attuale dell’app.
- Nessun redesign grafico.
- Se necessario, usare:
  - font scaling controllato,
  - adaptive spacing,
  - multiline limit appropriato,
  - layout priority corretta,
  - segmented control sizing coerente.

### Requisiti tecnici
- Correggere solo il layout/UI della label.
- Non modificare la business logic gas/planner.
- Verificare comportamento in:
  - portrait,
  - landscape se supportato,
  - Dynamic Type,
  - localizzazione ITA/ENG.

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
### Informazione gas di emergenza tramite pulsante info

La regola secondo cui il gas di emergenza viene sempre calcolato sulla profondità massima non deve essere mostrata apertamente nella UI principale del Planner.

### Comportamento UI/UX
- Accanto alla voce “Riferimento pianificazione” deve essere presente una piccola icona informativa “i”.
- Premendo la “i”, deve apparire un popup/modal informativo.
- Il popup deve spiegare che:
  - il riferimento pianificazione può usare profondità media o massima;
  - il gas di emergenza viene comunque sempre calcolato utilizzando la profondità massima.
- La UI deve restare coerente con il design attuale dell’app.
- Nessun redesign grafico.

### Localizzazione italiano / inglese

#### Italiano
“Il riferimento di pianificazione può utilizzare profondità media o massima. Per motivi di sicurezza, il gas di emergenza viene sempre calcolato utilizzando la profondità massima.”

#### Inglese
“The planning reference can use average or maximum depth. For safety reasons, emergency gas is always calculated using maximum depth.”


---

## Planner iOS — gestione bombole e ruolo del gas

Nel tab Pianificazione dell’app iOS deve essere possibile aggiungere e rimuovere bombole utilizzate nella pianificazione.

### Ruolo del gas

Per ogni bombola aggiunta, deve essere possibile scegliere una delle seguenti categorie:

#### Italiano
- Trasporto
- Back Gas
- Decompressione

#### Inglese
- Travel
- Back Gas
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

## Planner iOS — selezione tipologia miscela gas: Aria, EAN, Trimix

Nel Planner iOS, per ogni gas deve essere mostrata una tipologia di miscela chiara, usando tre pulsanti/selettori:

- Aria
- EAN
- Trimix / TX

Questa selezione deve controllare quali campi gas sono modificabili dall’utente e come vengono aggiornate automaticamente le percentuali della miscela.

### Comportamento per tipologia gas

#### Aria / Air
Se l’utente seleziona “Aria”:
- Ossigeno bloccato a 21%
- Elio bloccato a 0%
- Azoto calcolato automaticamente a 79%
- L’utente non può modificare manualmente ossigeno, elio o azoto
- La miscela deve essere trattata come aria in pianificazione e nei profili decompressivi

#### EAN / Nitrox
Se l’utente seleziona “EAN”:
- L’utente può modificare solo la percentuale di ossigeno
- Elio bloccato a 0%
- Azoto aggiornato automaticamente come 100% - O₂
- L’utente non può modificare manualmente l’elio
- L’utente non può modificare manualmente l’azoto
- La miscela deve essere trattata come Nitrox/EAN in pianificazione e nei profili decompressivi

#### Trimix / TX
Se l’utente seleziona “Trimix” o “TX”:
- L’utente può modificare ossigeno
- L’utente può modificare elio
- Azoto deve essere calcolato automaticamente come 100% - O₂ - He oppure gestito come già previsto dalla logica attuale, purché coerente
- Deve restare possibile configurare la miscela completa come avviene attualmente
- La miscela deve essere trattata come Trimix in pianificazione e nei profili decompressivi

### Impatto obbligatorio su pianificazione e Bühlmann

Questo cambiamento deve impattare correttamente:
- pianificazione immersione
- calcoli gas del Planner
- validazione MOD
- profili decompressivi Bühlmann
- cambi gas
- gas di trasporto / Travel
- Back Gas
- gas decompressivi / Decompression

È fondamentale che i profili decompressivi Bühlmann usino la miscela effettivamente selezionata e non valori gas obsoleti o non sincronizzati con la UI.

### Regole di coerenza miscela
- La somma O₂ + He + N₂ deve sempre essere pari a 100%.
- Se la combinazione inserita non è valida, la UI deve impedire il calcolo o mostrare errore chiaro.
- Le percentuali devono essere salvate coerentemente nel modello dati del Planner.
- Le modifiche della tipologia gas devono aggiornare subito i campi collegati.
- I calcoli esistenti non devono ricevere valori incoerenti o parziali.

### UI/UX
- Usare tre pulsanti o segmented control coerente con lo stile attuale dell’app:
  - Aria / Air
  - EAN
  - Trimix / TX
- I campi bloccati devono essere visivamente disabilitati.
- Nessun redesign grafico.
- Integrare la modifica nella UI attuale del Planner.

### Localizzazione italiano / inglese

#### Italiano
- “Aria”
- “EAN”
- “Trimix”
- “TX”
- “Ossigeno”
- “Elio”
- “Azoto”
- “Miscela gas”
- “La miscela gas non è valida”
- “La somma di ossigeno, elio e azoto deve essere pari al 100%”

#### Inglese
- “Air”
- “EAN”
- “Trimix”
- “TX”
- “Oxygen”
- “Helium”
- “Nitrogen”
- “Gas mix”
- “The gas mix is not valid”
- “Oxygen, helium and nitrogen must add up to 100%”

### Requisiti tecnici
- Implementazione solo lato iOS.
- Intervenire nel Planner e nei modelli gas usati dal Planner.
- Aggiornare il collegamento verso i calcoli Bühlmann affinché usino la miscela corretta.
- Non introdurre nuovi algoritmi decompressivi.
- Non modificare il modello Bühlmann, ma assicurare che riceva gas corretti.
- Non modificare business logic non correlata.
- Mantenere compatibilità con i dati già salvati.
- Se esistono gas precedenti senza tipologia, mappare:
  - O₂ 21%, He 0% → Aria
  - He 0% e O₂ diverso da 21% → EAN
  - He maggiore di 0% → Trimix


## Planner iOS — step FPO₂ e aggiornamento automatico MOD

In generale su iOS, per tutte le miscele gas, la regolazione della FPO₂ / PPO₂ massima non deve procedere con incrementi da 0,05, ma con incrementi da 0,1.

### Comportamento richiesto
- La regolazione deve avanzare a step di 0,1.
- Esempio corretto:
  - 1,4
  - 1,5
  - 1,6
- Non devono essere usati valori intermedi come:
  - 1,45
  - 1,55
- Anche se la UI non mostra gli intermedi, bisogna verificare che internamente il valore non venga comunque gestito con step da 0,05.

### Aggiornamento automatico MOD
La MOD deve essere aggiornata automaticamente ogni volta che cambia uno dei parametri rilevanti:

- percentuale di ossigeno
- percentuale di elio, se presente
- tipologia miscela: Aria / EAN / Trimix
- PPO₂ / FPO₂ massima selezionata
- gas associato alla bombola
- unità di misura selezionata, metri o piedi

### Requisiti UI/UX
- La MOD visualizzata deve aggiornarsi immediatamente senza richiedere ulteriori azioni manuali.
- Il valore mostrato deve essere coerente con la miscela e la PPO₂/FPO₂ selezionata.
- Nessun redesign grafico.
- Mantenere la UI attuale.

### Requisiti tecnici
- Implementazione solo lato iOS.
- Applicare la regola a tutte le miscele gas del Planner.
- Normalizzare eventuali valori esistenti allo step più vicino da 0,1.
- Verificare che il valore salvato e quello mostrato siano coerenti.
- Verificare che la validazione MOD usi sempre il valore aggiornato.
- Non modificare algoritmi decompressivi non correlati.
- Non modificare business logic non richiesta.


### Impatto obbligatorio su pianificazione e calcolo decompressivo Bühlmann

Le modifiche relative a:
- tipologia miscela Aria / EAN / Trimix
- percentuali O₂ / He / N₂
- PPO₂ / FPO₂ massima con step da 0,1
- MOD aggiornata automaticamente
- ruolo del gas: Travel / Back Gas / Decompression
- dimensione bombola associata al gas

devono avere impatto reale e coerente sia sulla pianificazione sia sul calcolo decompressivo Bühlmann.

### Requisiti funzionali
- Il Planner deve usare sempre la miscela gas aggiornata.
- Il calcolo Bühlmann deve ricevere le percentuali gas effettive e aggiornate.
- I profili decompressivi devono riflettere i gas selezionati dall’utente.
- I cambi gas devono rispettare la MOD calcolata automaticamente.
- Se l’utente modifica miscela, PPO₂/FPO₂ o ruolo gas, il risultato della pianificazione deve aggiornarsi coerentemente.
- Non devono rimanere valori gas obsoleti nel calcolo.
- Non devono esserci differenze tra gas mostrato in UI e gas usato dal Bühlmann.

### Requisiti tecnici
- Verificare il data flow tra UI Planner, modello gas, validazione MOD e motore/calcolo Bühlmann.
- Assicurarsi che ogni modifica ai gas invalidi o aggiorni il risultato precedente della pianificazione.
- Non modificare l’algoritmo Bühlmann in sé.
- Modificare solo il passaggio dati/input affinché Bühlmann lavori con le miscele corrette.
- Non introdurre nuovi algoritmi decompressivi.
- Mantenere compatibilità con dati già salvati.


## Planner iOS — significato operativo dei ruoli gas

Nel Planner iOS, i ruoli assegnati ai gas devono avere un significato operativo chiaro e devono impattare coerentemente sulla pianificazione e sul calcolo decompressivo Bühlmann.

### Ruoli gas

#### Back Gas
Il gas marcato come “Back Gas” significa:
- sarà utilizzato dalla superficie fino al primo cambio gas;
- rappresenta il gas principale di fondo;
- deve essere trattato come gas primario nella pianificazione immersione e nel Bühlmann.

#### Decompressione / Decompression
Il gas marcato come “Decompressione” significa:
- sarà utilizzato esclusivamente durante la risalita;
- sarà utilizzato durante le tappe decompressive;
- non deve essere considerato come gas principale di fondo;
- deve essere trattato come gas decompressivo nel Planner e nel Bühlmann.

#### Trasporto / Travel
Il gas marcato come “Trasporto” significa:
- sarà utilizzato in discesa o risalita entro determinate quote;
- può essere utilizzato prima del Back Gas o tra cambi gas;
- deve essere considerato correttamente nei cambi gas e nel profilo Bühlmann.

#### Bailout
Il gas marcato come “Bailout” significa:
- sarà utilizzato solo in caso di necessità/emergenza;
- deve essere identificato chiaramente come gas di emergenza;
- non deve essere automaticamente trattato come gas pianificato principale salvo logica specifica già esistente;
- deve comunque essere validato rispetto a MOD e miscela.

### Impatto obbligatorio sul Planner e Bühlmann
Questi ruoli devono influenzare:
- sequenza dei cambi gas;
- logica di utilizzo gas;
- profilo decompressione;
- validazione MOD;
- consumo gas pianificato, se già previsto;
- ordine dei gas nella pianificazione;
- input utilizzati dal motore Bühlmann.

### Requisiti UI/UX
- I ruoli gas devono essere chiaramente identificabili nella UI.
- Nessun redesign grafico.
- Mantenere coerenza con il design attuale dell’app.
- I gas devono essere mostrati in modo comprensibile nella sequenza immersione.

### Localizzazione italiano / inglese

#### Italiano
- “Back Gas”
- “Decompressione”
- “Trasporto”
- “Bailout”
- “Gas principale”
- “Gas decompressivo”
- “Gas di trasporto”
- “Gas di emergenza”

#### Inglese
- “Back Gas”
- “Decompression”
- “Travel”
- “Bailout”
- “Primary gas”
- “Decompression gas”
- “Travel gas”
- “Emergency gas”

### Requisiti tecnici
- Implementazione solo lato iOS.
- Collegare i ruoli gas alla pianificazione esistente.
- Assicurarsi che il motore Bühlmann riceva il ruolo corretto per ogni gas.
- Non modificare l’algoritmo Bühlmann.
- Non introdurre nuovi algoritmi decompressivi.
- Non modificare business logic non correlata.


## Checklist iOS — visibilità condizionale campi GAS

Nella checklist iOS, i campi relativi ai gas non devono essere sempre visibili.

### Comportamento richiesto
- I campi:
  - “GAS”
  - “BAR / PSI”
  - eventuale “Dimensione bombola”

  devono comparire solo se viene attivato lo switch “GAS”.

### Regole UI/UX
- Se lo switch GAS è OFF:
  - i campi gas devono essere completamente nascosti;
  - non devono occupare spazio nella UI;
  - l’item deve apparire come normale attrezzatura generica.

- Se lo switch GAS è ON:
  - devono apparire:
    - selezione/tipo GAS;
    - BAR / PSI;
    - dimensione bombola;
    - eventuali controlli collegati al gas.

### Esempio pratico
- Una maschera non deve mostrare:
  - GAS
  - BAR / PSI
  - dimensione bombola

- Una bombola invece deve poter mostrare:
  - tipo gas;
  - pressione;
  - dimensione bombola.

### Requisiti UI/UX
- La comparsa/scomparsa deve essere fluida e coerente con il design attuale.
- Nessun redesign grafico.
- Evitare clutter inutile nella checklist.
- La checklist deve restare leggibile e veloce da usare.

### Localizzazione italiano / inglese

#### Italiano
- “GAS”
- “BAR”
- “PSI”
- “Dimensione bombola”

#### Inglese
- “GAS”
- “BAR”
- “PSI”
- “Tank size”

### Requisiti tecnici
- Implementazione solo lato iOS.
- Usare rendering condizionale UI.
- Non modificare la business logic delle checklist.
- Persistenza coerente dei dati gas anche se i campi vengono temporaneamente nascosti.


---

# 3) Solo Apple Watch

## Apple Watch — tasto avvio immersione dalla schermata iniziale

Nella schermata iniziale dell’app Apple Watch deve essere inserito un tasto per permettere all’utente di avviare manualmente l’immersione.

### Comportamento
- Il tasto deve essere visibile nella schermata iniziale dell’app Apple Watch.
- Premendo il tasto, l’utente può avviare l’immersione manualmente.
- L’avvio manuale non deve sostituire l’avvio automatico già previsto.
- L’immersione deve comunque avviarsi automaticamente quando il sensore del profondimetro rileva una profondità superiore a 1 metro.

### Regola di avvio automatico
- Se la profondità rilevata è maggiore di 1 metro, l’app deve entrare automaticamente in modalità immersione.
- Questa regola deve restare sempre attiva anche se è stato aggiunto il tasto di avvio manuale.

### Requisiti UI/UX
- Il tasto deve essere coerente con il design attuale Apple Watch.
- Nessun redesign grafico.
- Il tasto deve essere facilmente accessibile ma non invasivo.
- Deve essere chiaro che l’immersione può partire manualmente o automaticamente.

### Requisiti tecnici
- Implementazione solo lato Apple Watch.
- Non modificare la business logic del sensore di profondità se non necessario.
- Non disabilitare l’avvio automatico basato sul profondimetro.
- Evitare duplicazione di sessioni se l’immersione è già attiva.
- Gestire correttamente lo stato: non iniziata, avviata manualmente, avviata automaticamente, in corso.

## Apple Watch — visualizzazione immagini anche fuori immersione

Le immagini sincronizzate dall’app iOS devono poter essere visualizzate anche quando non si è ancora entrati in immersione.

### Comportamento
- L’utente deve poter aprire e visualizzare le immagini direttamente dall’app Apple Watch anche in superficie.
- Le immagini devono restare disponibili:
  - prima dell’immersione;
  - durante la navigazione nei menu;
  - durante l’utilizzo operativo dell’app, se compatibile con la UI corrente.
- Le immagini sincronizzate devono essere persistenti localmente sull’Apple Watch, se già previsto dall’architettura corrente.

### Requisiti UI/UX
- Accesso semplice e veloce alle immagini.
- Nessun redesign grafico.
- Mantenere coerenza con il design attuale dell’app.
- Le immagini devono essere leggibili su Apple Watch Ultra.
- Gestire correttamente immagini ridimensionate/convertite provenienti da iOS.

### Requisiti tecnici
- Implementazione solo lato Apple Watch.
- Riutilizzare il sistema di sincronizzazione immagini già previsto tramite WatchConnectivity.
- Non interferire con le schermate immersione critiche.
- Non modificare business logic subacquea o decompressione.

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
