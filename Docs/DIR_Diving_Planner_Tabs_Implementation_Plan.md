# DIR DIVING — Piano di Implementazione Planner a Tre Livelli

**Oggetto:** implementazione dei tre TAB del Planner iOS Companion: **Base / Deco / Tecnico**  
**Target:** DIR DIVING iOS Companion — branch `main`  
**Scope:** UI/UX del Planner, modello dati, validazioni, output, curva Bühlmann, gas planning, safety copy  
**Vincoli:** nessun claim di planner certificato, nessuna modifica alla logica Apple Watch, nessuna modifica ai branch experimental

---

## 1. Obiettivo del piano

L’obiettivo è trasformare i tre TAB del Planner da semplice selettore grafico a tre modalità funzionali realmente diverse:

1. **Base**  
   Planner rapido, ricreativo, monogas, senza complessità decompressiva visibile.

2. **Deco**  
   Planner intermedio, con gas di fondo + massimo un gas decompressivo, validazioni MOD/PPO₂, CNS/OTU e output Bühlmann semplificato.

3. **Tecnico**  
   Planner completo multigas: gas di fondo, travel gas, deco gas multipli, bailout, GF manuali, Bühlmann completo, curva compartimenti, gas planning e validazioni avanzate.

Il Planner attuale, per come è stato immaginato nel mockup e per come hai descritto il codice, corrisponde soprattutto al livello **Tecnico**. I tab **Base** e **Deco** devono quindi essere implementati come viste/funzionalità filtrate e semplificate dello stesso motore, non come tre algoritmi separati.

---

## 2. Principio architetturale

### 2.1 Un solo motore, tre livelli di esposizione

Il Planner deve usare un unico backend di calcolo e validazione, ma con tre preset di complessità:

```swift
enum PlannerMode {
    case base
    case deco
    case technical
}
```

Ogni modalità deve controllare:

- campi visibili;
- gas configurabili;
- validazioni attive;
- tipo di output;
- livello di dettaglio dei grafici;
- copy safety;
- export disponibile o meno;
- quantità di warning mostrati all’utente.

### 2.2 Non duplicare algoritmi

Non devono esistere tre planner matematici diversi. Deve esistere:

- un modello input comune;
- un normalizzatore per modalità;
- un motore di validazione comune;
- un motore Bühlmann comune;
- tre presentazioni UI/UX diverse.

Schema consigliato:

```swift
PlannerView
 ├── PlannerModeSelector
 ├── PlannerInputReducer(mode:)
 ├── PlannerValidationPipeline(mode:)
 ├── PlannerService.calculate(input: mode:)
 └── PlanResultView(mode: result:)
```

---

## 3. Nomenclatura consigliata

Nel mockup i tab erano:

- Semplice
- Avanzato
- Tecnico

Per coerenza funzionale, consiglio di rinominarli in:

- **Base**
- **Deco**
- **Tecnico**

Motivazione:

- “Semplice” è generico;
- “Avanzato” è ambiguo;
- “Deco” spiega chiaramente che la modalità intermedia aggiunge una decompressione base;
- “Tecnico” spiega chiaramente multigas, trimix, bailout, Bühlmann avanzato.

Se vuoi mantenere le label originali per marketing, allora la mappatura deve essere:

| Label UI attuale | Significato funzionale consigliato |
|---|---|
| Semplice | Base |
| Avanzato | Deco |
| Tecnico | Tecnico |

---

## 4. Planner Base

## 4.1 Scopo

Planner rapido per immersioni ricreative o per pre-check di compatibilità gas/profondità.

Non deve far percepire all’utente di avere un piano decompressivo tecnico.

## 4.2 Input visibili

Campi consigliati:

- profondità massima;
- tempo di fondo;
- temperatura opzionale;
- gas singolo;
- PPO₂ massima;
- unità di misura;
- SAC/RMV opzionale, solo se già presente nel modello.

## 4.3 Gas ammessi

Solo un gas:

- Air;
- Nitrox/EAN.

Da escludere in Base:

- Trimix;
- travel gas;
- deco gas;
- bailout;
- gas multipli;
- switch gas.

## 4.4 Validazioni

Validazioni minime ma obbligatorie:

- profondità > 0;
- tempo > 0;
- PPO₂ entro range ammesso;
- MOD compatibile con profondità;
- warning se il gas scelto supera PPO₂ max alla profondità impostata;
- warning se la profondità supera il range operativo raccomandato dell’app.

## 4.5 Output

Il risultato Base deve mostrare:

- riepilogo profilo;
- gas usato;
- MOD;
- PPO₂ alla profondità impostata;
- CNS stimato;
- consumo gas stimato se SAC/RMV disponibile;
- warning di sicurezza;
- eventuale indicazione “profilo fuori ambito” se necessario.

## 4.6 Bühlmann in modalità Base

In modalità Base, Bühlmann deve essere **nascosto o ridotto**.

Opzioni possibili:

### Opzione A — No Bühlmann visibile

Mostrare solo un risultato sintetico:

- “Profilo compatibile / non compatibile”;
- “Verifica gas superata / fallita”;
- “Planner indicativo”.

### Opzione B — Bühlmann semplificato

Mostrare solo:

- stato no-deco / deco richiesta;
- nessuna curva compartimenti;
- nessuna tabella dettagliata;
- nessun GF manuale.

Copy consigliata:

> “Verifica indicativa. Non rappresenta un piano decompressivo certificato.”

## 4.7 Grafici in modalità Base

Da mostrare:

- nessun grafico, oppure;
- mini indicatore compatibilità gas/profondità.

Da non mostrare:

- curva Bühlmann completa;
- compartimenti;
- grafico CNS/OTU avanzato;
- piano deco tabellare.

---

## 5. Planner Deco

## 5.1 Scopo

Planner intermedio per immersioni con un gas di fondo e un gas decompressivo singolo.

Questa modalità è utile per:

- Nitrox avanzato;
- immersioni con EAN50;
- deco base;
- extended range leggero;
- utenti che non vogliono gestire travel gas, bailout e multigas complesso.

## 5.2 Input visibili

Campi consigliati:

- profondità massima;
- tempo di fondo;
- temperatura;
- gas di fondo;
- gas decompressivo singolo;
- profondità cambio gas;
- PPO₂ max fondo;
- PPO₂ max deco;
- GF preset;
- SAC/RMV;
- volume bombola fondo;
- volume bombola deco opzionale.

## 5.3 Gas ammessi

Gas di fondo:

- Air;
- Nitrox;
- eventualmente Trimix solo se si decide che il Deco sia “extended”.

Gas deco:

- massimo un gas;
- EAN50;
- EAN80;
- O₂ solo se validato correttamente a 6 m;
- cambio gas vincolato a MOD/PPO₂.

Da escludere in Deco:

- travel gas multipli;
- più deco gas;
- bailout multipli;
- gestione avanzata delle bombole;
- switch depth multipli.

## 5.4 GF in modalità Deco

Consiglio: usare preset e non slider manuali liberi.

Esempio:

```swift
enum GradientFactorPreset {
    case conservative   // 20/70
    case standard       // 30/70
    case progressive    // 40/80
}
```

La UI può mostrare:

- Conservativo;
- Standard;
- Spinto.

In piccolo può indicare il valore GF corrispondente.

## 5.5 Validazioni

Validazioni obbligatorie:

- MOD gas fondo;
- MOD gas deco alla profondità di cambio;
- PPO₂ max fondo;
- PPO₂ max deco;
- gas operativo alla profondità in cui viene usato;
- gas deco non usato troppo profondo;
- CNS/OTU;
- piano incompleto;
- warning se calcolo non converge;
- warning se si seleziona O₂ puro sopra 6 m circa;
- warning se EAN50 è impostato sopra 21 m.

## 5.6 Output

Il risultato Deco deve mostrare:

- riepilogo profilo;
- TTS/TTR indicativo;
- numero soste;
- tabella deco semplificata;
- gas per ogni stop;
- PPO₂ per gas;
- MOD;
- CNS/OTU;
- warning safety;
- consumo gas fondo/deco.

## 5.7 Bühlmann in modalità Deco

La modalità Deco deve usare Bühlmann, ma con presentazione semplificata.

Da mostrare:

- piano risalita;
- soste;
- curva semplificata;
- eventuale stato dei compartimenti raggruppato.

Da nascondere:

- dettaglio completo per tutti i 16 compartimenti;
- GF manuali avanzati;
- debug numerico;
- grafici troppo tecnici.

## 5.8 Curva Bühlmann in modalità Deco

La curva può essere mostrata in modo aggregato:

- linea “loading medio”;
- linea “ceiling / limite” se disponibile;
- colori verde/giallo/rosso;
- niente singolo compartimento.

Copy consigliata:

> “Curva Bühlmann semplificata — riferimento indicativo, non certificato.”

---

## 6. Planner Tecnico

## 6.1 Scopo

Planner completo per immersioni tecniche, decompressive, trimix, multigas e bailout.

Questa è la modalità che più corrisponde al Planner già immaginato nel mockup.

## 6.2 Input visibili

Campi consigliati:

- profondità massima;
- profondità media opzionale;
- switch “calcola deco su profondità massima / media” se richiesto;
- tempo di fondo;
- temperatura;
- gas di fondo;
- travel gas;
- deco gas 1;
- deco gas 2;
- ulteriori deco gas se supportati;
- bailout;
- PPO₂ max fondo;
- PPO₂ max deco;
- GF Low;
- GF High;
- SAC/RMV;
- bombole;
- pressione iniziale/finale;
- riserva;
- END/EAD;
- gas density;
- CNS/OTU;
- opzioni ambiente: acqua dolce/salata, quota se supportata.

## 6.3 Gas ammessi

Tutti i gas previsti dal modello:

- fondo;
- trasporto;
- decompressione;
- bailout;
- eventuali standby gas.

Ogni gas deve avere:

- O₂;
- He;
- N₂ calcolato;
- MOD;
- PPO₂ max;
- profondità di switch;
- ruolo gas;
- volume bombola;
- pressione;
- eventuale priorità/uso.

## 6.4 Validazioni

Validazioni complete:

- gas di fondo respirabile alla profondità massima;
- travel gas operativo nel segmento assegnato;
- deco gas operativo alla profondità di switch;
- bailout non confuso con gas consumato dal piano;
- MOD per ogni gas;
- PPO₂ per ogni segmento;
- ipossia a bassa profondità;
- END/EAD;
- gas density;
- CNS/OTU;
- gas consumption;
- calcolo incompleto;
- gradient factor fuori range;
- switch gas non ordinati;
- profondità cambio gas incompatibile;
- profondità media usata per deco se switch attivo.

## 6.5 Output

Il risultato Tecnico deve mostrare:

- piano completo;
- runtime;
- TTS/TTR;
- tabella risalita;
- soste;
- gas per segmento;
- PPO₂ per segmento;
- MOD;
- CNS;
- OTU;
- gas consumption;
- warning avanzati;
- curva Bühlmann completa;
- compartimenti;
- eventuale compartimento controllante;
- export piano;
- report testuale.

## 6.6 Bühlmann in modalità Tecnico

In Tecnico si deve mostrare il massimo dettaglio disponibile:

- curva Bühlmann ZH-L16C;
- gruppi compartimenti;
- ceiling;
- saturazione/desaturazione;
- GF low/high;
- piano stop-by-stop;
- controllo dei gas;
- warning su piano incompleto.

## 6.7 Curva Bühlmann in modalità Tecnico

La schermata “Curva Bühlmann” dovrebbe includere:

- asse X: tempo;
- asse Y: percentuale relativa o pressione tissutale normalizzata;
- linee per gruppi di compartimenti, per esempio:
  - 1–4;
  - 5–8;
  - 9–12;
  - 13–16;
- legenda;
- ceiling o limite se disponibile;
- evidenza del compartimento controllante;
- warning se la curva è semplificata o aggregata.

Importante: se il grafico non è realmente basato sui tessuti calcolati, deve essere etichettato come illustrativo. Se è basato sul motore Bühlmann, deve usare i dati reali del motore.

---

## 7. Conseguenze sul modello dati

## 7.1 PlannerInput

Il modello input deve supportare tre livelli:

```swift
struct PlannerInput {
    var mode: PlannerMode
    var maxDepthMeters: Double
    var averageDepthMeters: Double?
    var useAverageDepthForDeco: Bool
    var bottomTimeMinutes: Double
    var temperatureCelsius: Double?
    var bottomGas: PlannerGas
    var travelGases: [PlannerGas]
    var decoGases: [PlannerGas]
    var bailoutGases: [PlannerGas]
    var gfLow: Int
    var gfHigh: Int
    var gfPreset: GradientFactorPreset?
    var sacRate: Double?
    var environment: PlannerEnvironment
}
```

## 7.2 Mode reducer

Serve un normalizzatore che impedisca a Base/Deco di passare campi non ammessi al motore.

```swift
struct PlannerModeReducer {
    func normalizedInput(_ input: PlannerInput, for mode: PlannerMode) -> PlannerInput
}
```

Regole:

### Base

- travelGases = [];
- decoGases = [];
- bailoutGases = [];
- GF preset standard interno;
- solo Air/EAN;
- trimix disabilitato;
- output semplificato.

### Deco

- travelGases = [] oppure massimo 1 se esplicitamente supportato;
- decoGases = max 1;
- bailoutGases = [];
- GF da preset;
- output semplificato.

### Tecnico

- tutti i campi ammessi;
- GF manuali;
- multigas;
- bailout;
- output completo.

---

## 8. Conseguenze sulla UI

## 8.1 PlannerView

`PlannerView` deve diventare mode-aware.

Struttura consigliata:

```swift
PlannerView
 ├── PlannerModePicker
 ├── BasePlannerForm
 ├── DecoPlannerForm
 └── TechnicalPlannerForm
```

Oppure:

```swift
PlannerForm(mode: selectedMode)
```

ma con sezioni condizionali pulite.

## 8.2 Cosa mostrare nei tre tab

| Sezione UI | Base | Deco | Tecnico |
|---|---:|---:|---:|
| Profilo immersione | sì | sì | sì |
| Temperatura | opzionale | sì | sì |
| Gas singolo | sì | no | no |
| Gas fondo | no/semplificato | sì | sì |
| Gas trasporto | no | no | sì |
| Gas deco 1 | no | sì | sì |
| Gas deco multipli | no | no | sì |
| Bailout | no | no | sì |
| GF preset | nascosto | sì | no |
| GF manuale | no | no | sì |
| SAC/RMV | opzionale | sì | sì |
| Bombole/pressioni | opzionale | base | completo |
| Calcola piano | sì | sì | sì |

---

## 9. Conseguenze su PlanResultView

Il risultato deve essere diverso per modalità.

## 9.1 Base Result

Tab consigliati:

- Riepilogo;
- Sicurezza;
- Gas.

Non mostrare:

- Curva Bühlmann completa;
- tabella deco complessa;
- compartimenti.

## 9.2 Deco Result

Tab consigliati:

- Piano;
- Sicurezza;
- Grafico.

Mostrare:

- piano risalita semplificato;
- singolo gas deco;
- CNS/OTU;
- curva semplificata.

## 9.3 Tecnico Result

Tab consigliati:

- Piano;
- Curva Bühlmann;
- Gas;
- Warning;
- Grafici.

Mostrare:

- tabella deco completa;
- tutti i gas;
- curva Bühlmann completa;
- compartimenti;
- gas ledger;
- warning avanzati.

---

## 10. Conseguenze sulla curva Bühlmann

## 10.1 Base

La curva Bühlmann dovrebbe essere nascosta.

Se si decide di mostrarla:

- deve essere semplificata;
- deve avere copy chiaro;
- non deve sembrare una certificazione.

## 10.2 Deco

Curva semplificata:

- aggregata;
- senza compartimenti singoli;
- no debug;
- no GF manuali;
- warning reference-only.

## 10.3 Tecnico

Curva completa:

- compartimenti raggruppati o singoli;
- ceiling;
- GF;
- compartimento controllante;
- stop schedule;
- timeline completa.

## 10.4 Requisito critico

Non usare mai una curva decorativa se il titolo dice “Bühlmann”.

Se il grafico è reale:

> usare dati reali dal motore Bühlmann.

Se il grafico è illustrativo:

> scrivere chiaramente “grafico illustrativo”.

---

## 11. Conseguenze sulla sicurezza e sul copy

Ogni modalità deve avere un messaggio safety adeguato.

### Base

> “Verifica indicativa del profilo e del gas. Non sostituisce addestramento, tabelle, computer subacqueo certificato o pianificazione professionale.”

### Deco

> “Piano decompressivo indicativo basato su modello Bühlmann. Non certificato e non utilizzabile come unico piano immersione.”

### Tecnico

> “Planner tecnico reference-only. Verificare sempre con strumenti certificati, formazione, procedure di team e bailout planning indipendente.”

---

## 12. Conseguenze su export/share

L’export deve includere la modalità usata.

Esempio:

```text
Planner Mode: Technical
Reference-only: yes
Certified dive plan: no
```

Campi export per modalità:

| Campo export | Base | Deco | Tecnico |
|---|---:|---:|---:|
| Riepilogo profilo | sì | sì | sì |
| Gas | sì | sì | sì |
| MOD/PPO₂ | sì | sì | sì |
| Tabella deco | no | sì | sì completa |
| Curva Bühlmann | no | semplificata | sì completa |
| CNS/OTU | base | sì | sì |
| Gas ledger | no/base | sì | sì completo |
| Bailout | no | no | sì |
| Warning avanzati | no | alcuni | sì |

---

## 13. Conseguenze sui test

Aggiungere test per:

## 13.1 Mode reducer

- Base rimuove deco/travel/bailout;
- Base rifiuta trimix se non supportato;
- Deco limita a un gas decompressivo;
- Deco usa GF preset;
- Tecnico preserva tutti i gas;
- Tecnico abilita GF manuali.

## 13.2 Planner validation

- Base EAN32 a profondità compatibile;
- Base EAN32 oltre MOD;
- Deco EAN50 usato troppo profondo;
- Deco O₂ usato troppo profondo;
- Tecnico travel gas ipossico troppo superficiale;
- Tecnico bailout non incluso nel gas consumato principale;
- Tecnico switch depth non ordinati.

## 13.3 Result rendering policy

- Base non mostra curva completa;
- Deco mostra curva semplificata;
- Tecnico mostra curva completa;
- Base non esporta piano deco;
- Deco esporta piano semplificato;
- Tecnico esporta piano completo.

## 13.4 Safety copy

- ogni modalità mostra disclaimer corretto;
- nessun output dice “certificato”;
- Watch non viene coinvolto;
- planner rimane iOS reference-only.

---

## 14. Priorità implementativa

## Fase 1 — Refactor leggero del modello modalità

- creare `PlannerMode`;
- creare `PlannerModeReducer`;
- collegare il tab selezionato al modello;
- evitare che il tab sia solo grafico.

## Fase 2 — Base

- UI ridotta;
- monogas;
- MOD/PPO₂;
- output semplificato;
- no curva Bühlmann completa.

## Fase 3 — Deco

- gas fondo + un deco;
- GF preset;
- output piano risalita semplificato;
- curva Bühlmann semplificata;
- CNS/OTU.

## Fase 4 — Tecnico

- rendere l’attuale planner il tab Tecnico;
- multigas;
- bailout;
- GF manuali;
- curva completa;
- compartimenti;
- warning avanzati.

## Fase 5 — PlanResultView mode-aware

- risultato diverso per modalità;
- export diverso per modalità;
- warning diversi per modalità.

## Fase 6 — Test e documentazione

- unit test;
- regression test;
- documentazione safety;
- aggiornamento release notes.

---

## 15. File probabilmente coinvolti

Da verificare nel repository:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/PlanResultView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/*`
- `Docs/IOS_PLANNER_MODE_STRATEGY.md`

---

## 16. Acceptance criteria

L’implementazione è corretta se:

1. i tre tab cambiano realmente funzioni e input visibili;
2. Base è monogas e non tecnico;
3. Deco è fondo + massimo un deco gas;
4. Tecnico è multigas completo;
5. il Planner attuale viene collocato nel tab Tecnico;
6. i risultati cambiano per modalità;
7. la curva Bühlmann è nascosta/semplificata/completa in base alla modalità;
8. nessun grafico Bühlmann è decorativo senza essere dichiarato;
9. export/share indicano la modalità;
10. safety copy è differenziato;
11. nessun claim certificato viene introdotto;
12. i test coprono reducer, validazioni, risultati, export e safety copy.

---

## 17. Raccomandazione finale

La scelta più pulita è questa:

- **Base**: planner monogas, controllo MOD/PPO₂, output semplice.
- **Deco**: gas fondo + un gas deco, Bühlmann semplificato, GF preset.
- **Tecnico**: planner attuale completo, multigas, bailout, curva Bühlmann completa.

In questo modo i tab non sono decorativi, ma diventano tre livelli reali di utilizzo, coerenti con il pubblico DIR DIVING e con la complessità crescente del planner.
