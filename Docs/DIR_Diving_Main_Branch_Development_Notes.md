# DIR Diving — Main Branch Development Notes

_Last updated: 2026-05-24_

---

# Modifiche iOS ed Watch

## Supporto unità di misura imperiali

Implementare in entrambe le app (Apple Watch + iOS Companion) la possibilità di selezionare il sistema di misura:

### Profondità
- Metri (m)
- Piedi (ft)

### Pressione
- BAR
- PSI

### Temperatura
- Celsius (°C)
- Fahrenheit (°F)

### Velocità di risalita
- m/min
- ft/min

### Persistenza impostazioni
- La preferenza deve essere sincronizzata tra Watch e iPhone
- Salvare tramite AppStorage/UserDefaults condivisi
- Cambio immediato live di tutta la UI
- Conversioni coerenti anche nei log immersione e grafici esportati

### UI/UX
- Inserire toggle o selettore chiaro nelle Settings
- Tutte le schermate devono rispettare automaticamente l’unità selezionata
- Nessun mix di unità metriche/imperiali nella stessa schermata

---

## Disclaimer obbligatorio ad ogni avvio

Indipendentemente dall’accettazione iniziale dell’onboarding/disclaimer, ad ogni apertura dell’app deve apparire un messaggio informativo.

### Comportamento
- Visualizzazione automatica ad ogni avvio app
- Deve comparire sia su Apple Watch sia su iOS
- Chiusura manuale tramite pulsante “OK” / “Continue”
- Non bloccare permanentemente l’utilizzo ma richiedere conferma visiva
- UI coerente con il design premium Apple dell’app

### Localizzazione automatica

#### Italiano
"DIR Diving non è da considerarsi un computer subacqueo o uno strumento di pianificazione. È soltanto un Diving Companion per aiutarti a tenere a mente le informazioni relative alle tue immersioni."

#### Inglese
"DIR Diving must not be considered a dive computer or a dive planning instrument. It is only a Diving Companion intended to help you keep track of information related to your dives."

### Requisiti aggiuntivi
- Supportare dark mode
- Supportare Dynamic Type
- Nessun linguaggio ambiguo o promozionale
- Nessuna schermata “achievement” o “gamification” associata alla sicurezza immersione

---

# Modifiche solo per Apple Watch

## Allarme profondità massima configurabile

Aggiungere nei Settings dell’Apple Watch la possibilità di modificare il valore dell’allarme di profondità massima.

### Comportamento
- Valore di default: 40 metri
- Possibilità di ridurre o aumentare il limite
- Esempio tipico: impostazione a 30 metri
- Il valore selezionato deve essere persistente
- Feedback aptico al raggiungimento della profondità impostata
- Evidenziazione grafica/arancione/rossa quando si supera il limite impostato

### UI/UX
- Slider o Digital Crown selector coerente con watchOS
- Valore mostrato chiaramente nelle unità selezionate (m/ft)
- Aggiornamento immediato della logica allarme
- UI semplice e leggibile sott’acqua

---

## Navigazione coerente tra schermate

Aggiungere in ogni finestra/schermata dell’app Apple Watch la freccia di ritorno in alto a sinistra per permettere il ritorno immediato alla schermata precedente.

### Requisiti UI/UX
- Comportamento coerente in tutta l’app
- Iconografia standard Apple/watchOS
- Hit area sufficientemente grande per utilizzo subacqueo
- Posizionamento sempre coerente
- Nessuna schermata orfana senza possibilità di ritorno
- Compatibilità con navigazione tramite Digital Crown e gesture native watchOS

### Requisiti tecnici
- Utilizzare pattern di navigazione nativi SwiftUI/watchOS
- Evitare custom navigation non standard
- Animazioni coerenti con watchOS
- Gestione corretta dello stack di navigazione

---

## Soglia tempo immersione di default

Impostare la soglia temporale di immersione con valore di default pari a 30 minuti.

### Comportamento
- Valore iniziale automatico: 30 minuti
- Possibilità futura di modifica tramite Settings
- Utilizzata come riferimento per alert e monitoraggio runtime immersione
- Persistenza del valore selezionato

### UI/UX
- Visualizzazione chiara del tempo impostato
- Coerenza grafica con le altre impostazioni di sicurezza
- Feedback aptico o visivo al raggiungimento della soglia tempo

---

## Asset grafici ufficiali applicazione

### altosinistra.png
Nuova icona persistente da visualizzare in entrambe le applicazioni.

#### Comportamento
- Deve essere sempre visibile in alto a sinistra durante la navigazione
- Deve essere visibile anche durante l’utilizzo sott’acqua
- Nel mockup attuale è già presente come riferimento grafico

#### Requisiti UI/UX
- Posizionamento coerente in tutte le schermate
- Dimensione compatibile con leggibilità watchOS/iOS
- Non invasiva rispetto ai dati immersione
- Compatibile con dark mode
- Rendering nitido su Apple Watch Ultra

---

### apple watch icon.png
Nuova icona ufficiale dell’app Apple Watch.

#### Requisiti
- Utilizzare come app icon primaria watchOS
- Compatibilità completa con App Store Connect
- Ottimizzazione per Apple Watch Ultra
- Mantenere resa leggibile anche in dimensioni molto ridotte

---

### ios icon.png
Nuova icona ufficiale dell’app iOS Companion.

#### Requisiti
- Utilizzare come app icon primaria iOS
- Compatibilità completa con App Store Connect
- Rendering coerente con branding DIR Diving
- Compatibilità dark/light mode di iOS

---

# Modifiche solo per iOS

## Menu principale

Il menu dell’app iOS deve partire da sinistra con la sezione Planner come prima voce/schermata.

### Requisiti UI/UX
- Planner posizionato come prima sezione da sinistra
- Navigazione coerente con il design premium Apple
- Ordine del menu chiaro e stabile
- Nessuna modifica grafica incoerente con il reference design

---

## Invio foto da iOS ad Apple Watch

Implementare una funzione che permetta di caricare foto dall’app iOS e inviarle all’Apple Watch per la visualizzazione.

### Comportamento
- Selezione/caricamento foto da iPhone
- Invio delle immagini all’Apple Watch
- Visualizzazione delle foto sull’app Apple Watch
- Gestione corretta di immagini multiple
- Persistenza locale dove necessario
- Ottimizzazione dimensioni immagini per watchOS

### Requisiti tecnici
- Utilizzare WatchConnectivity
- Gestire stato connessione iPhone ↔ Apple Watch
- Gestire errori di trasferimento
- Compressione/ridimensionamento automatico immagini
- UI di conferma invio completato

---

## Checklist attrezzatura modificabile

Implementare la possibilità di aggiungere e rimuovere attrezzatura dalla checklist personale.

### Comportamento
- Aggiunta manuale di nuovi elementi
- Rimozione elementi esistenti
- Persistenza della checklist
- Stato completato/non completato per ogni elemento

### Bombole

Per ogni bombola inserita nella checklist, prevedere campi testo dedicati per:
- Gas
- BAR / PSI

Per ora entrambi possono essere semplici campi testo, senza calcoli automatici.

---

## Gestione manuale immersioni

Implementare la possibilità di aggiungere e rimuovere immersioni manualmente dal log iOS.

### Caso d’uso

L’utente deve poter caricare manualmente immersioni non sincronizzate con Apple Watch, ad esempio perché effettuate con un altro computer subacqueo.

### Dati inseribili manualmente

Le informazioni devono essere le stesse normalmente ricevute dall’Apple Watch e devono comparire sia nel log sia nell’export CSV:

1. Profondità massima
2. Profondità media
3. Punto GPS di inizio immersione
4. Punto GPS di fine immersione
5. Profilo dell’immersione
6. Attrezzatura utilizzata
7. BAR/PSI ingresso
8. BAR/PSI uscita
9. Eventuale descrizione testuale della decompressione

### Requisiti UI/UX
- Pulsante “Aggiungi immersione manuale”
- Possibilità di modificare o cancellare immersioni inserite manualmente
- Evidenza chiara tra immersioni sincronizzate da Apple Watch e immersioni inserite manualmente
- Coerenza con unità metriche/imperiali selezionate

---

## Planner — consenso obbligatorio iniziale

Nel Planner iOS, lo switch:

“Comprendo che il planner è solo indicativo”

deve essere posizionato all’inizio della schermata.

### Comportamento
- Se lo switch è OFF:
  - Non deve essere possibile inserire dati
  - Tutti i campi del planner devono risultare disabilitati
  - Nessun calcolo o pianificazione deve essere disponibile

- Se lo switch è ON:
  - I campi diventano utilizzabili
  - Il planner viene sbloccato normalmente

### Requisiti UI/UX
- Messaggio molto visibile
- Coerenza grafica con il disclaimer generale dell’app
- Stato disabilitato chiaramente percepibile
- Compatibilità dark mode
- Persistenza opzionale dello stato solo per la sessione corrente

---
