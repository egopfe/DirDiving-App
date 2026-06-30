# DIR DIVING — APNEA iOS + APPLE WATCH IMPLEMENTATION COMMAND
## P1 + P2 + P3: Profiles, Recovery, Session Check, Data Quality, Training Analytics

Repository: `egopfe/DirDiving-App`

---

## 0. Obiettivo generale

Implementare una roadmap completa per la modalità **Apnea** su:

- **app iOS companion**: configurazione, profili, session check, checklist, statistiche, logbook, export e analisi;
- **Apple Watch**: runtime apnea, timer, recovery timer, alert aptici, sensor/data quality, session summary e log finale.

Separazione architetturale obbligatoria:

```text
iOS = configurazione, profili, checklist, analisi, logbook, statistiche, export
Apple Watch = runtime, timer, recovery, alert, sensori, log finale
```

La modalità Apnea non deve copiare la logica Snorkeling route-based. Snorkeling lavora su rotta, mappa e orientamento. Apnea deve lavorare su sessione, recupero, ripetizioni, profondità, qualità sensori e trend.

Implementare in sequenza:

```text
P1 — ESSENZIALE
P2 — MOLTO UTILE
P3 — AVANZATO
```

---

# 1. Policy di sviluppo

Rispetta rigorosamente le policy già adottate nel progetto DIR Diving.

## 1.1 Scope ammesso

Questa implementazione riguarda solo:

```text
Apnea iOS companion
Apnea Apple Watch
Apnea shared models / sync
Apnea logbook
Apnea runtime session
Apnea recovery tracking
Apnea sensor/data quality
Apnea training profiles
```

Non modificare:

```text
Diving
Gauge
Full Computer
Snorkeling
Bühlmann
Gradient Factors
Decompression planner
Gas planner
CNS/OTU
Dive logbook ownership
Snorkeling route planner
Snorkeling GPS route runtime
Apple underwater entitlement logic
Watch auto-open logic
```

## 1.2 Safety / medical policy

- Non presentare la funzione come dispositivo medico.
- Non presentare la funzione come safety-critical.
- Non promettere prevenzione blackout, samba, sincope o incidenti.
- Non sostituire buddy, istruttore, addestramento o procedure di sicurezza.
- Non usare wording tipo `safe to dive`, `safe to hold`, `blackout prevention`.
- Usare wording prudente: `training aid`, `session reminder`, `recovery reminder`, `data quality`, `logging support`.
- Ogni alert recovery è un reminder, non autorizza automaticamente una nuova apnea.
- Inserire disclaimer ove necessario: `Do not freedive alone. Use this as a training/logging aid only.`

## 1.3 GPS / location policy

Per Apnea il GPS è solo opzionale per logbook/location metadata, non per navigazione runtime.

- Usare solo `When In Use`.
- Non introdurre `Always Location`.
- Non introdurre background location generico.
- Non creare coordinate fake.
- Non usare GPS come safety runtime principale.
- Non portare mappe, waypoint, route progress o off-route warning in Apnea.

## 1.4 Watch runtime policy

- Il Watch deve avere schermate semplici, leggibili e con pochi dati.
- Il Watch deve gestire timer apnea, timer recovery, ripetizioni, profondità se disponibile, HR/SpO2 solo se già supportati, alert aptici, data/sensor quality e log finale.
- Il Watch non deve introdurre flussi complessi durante l’attività.
- Il Watch non deve cambiare automaticamente profilo in runtime senza azione utente.

## 1.5 QA / compliance policy

- Non dichiarare QA fisica PASS senza evidenza reale.
- Tutti i QA template devono partire da `PENDING`.
- I risultati simulatore non sostituiscono test reale in acqua.
- Ogni nuova funzione deve avere test unitari dove possibile e QA manuale documentato.
- Nessuna funzione deve essere descritta come certificata, medicale o salvavita.

---

# 2. Ispezione preliminare obbligatoria

Prima di modificare, cerca dinamicamente i file perché i path possono essere cambiati.

Cercare nel progetto:

```text
Apnea
ApneaRuntime
ApneaWatchRuntimeStore
ApneaLogbookStore
ApneaSession
ApneaProfile
ApneaSettings
Recovery
Hold
BreathHold
Static
Dynamic
Depth
ConstantWeight
SpO2
HeartRate
HR
SensorQuality
DataQuality
FakeApnea
DemoApnea
WatchActivitySettingsSections
```

Ispezionare almeno:

```text
iOSApp/Views/Apnea
iOSApp/Views
iOSApp/Services
iOSApp/Models
Services/ApneaWatchRuntimeStore.swift
Services/ApneaLogbookStore.swift
Services
Shared/Models
Shared/Utils
Views/WatchActivitySettingsSections.swift
Views
Resources/it.lproj/Localizable.strings
Resources/en.lproj/Localizable.strings
iOSApp/Resources/it.lproj/Localizable.strings
iOSApp/Resources/en.lproj/Localizable.strings
Tests/iOSAlgorithmTests
Tests/WatchAlgorithmTests
Docs
project.yml
```

Non assumere path fissi. Se i file sono stati rinominati, usare i file equivalenti.

---

# 3. Architettura target

## 3.1 Flusso funzionale

```text
iOS configura profilo apnea
↓
iOS esegue Apnea Session Check + checklist opzionale
↓
iOS invia configurazione/profilo al Watch, se già previsto dal flusso
↓
Watch esegue sessione apnea
↓
Watch traccia hold, recovery, ripetizioni e sensori disponibili
↓
Watch produce log finale
↓
iOS mostra logbook, data quality, statistiche e trend
```

## 3.2 Modelli shared consigliati

Creare o estendere modelli shared:

```text
Shared/Models/ApneaSessionProfile.swift
Shared/Models/ApneaSessionConfiguration.swift
Shared/Models/ApneaRecoveryPolicy.swift
Shared/Models/ApneaSessionCheckResult.swift
Shared/Models/ApneaChecklistItem.swift
Shared/Models/ApneaDataQuality.swift
Shared/Models/ApneaSensorQuality.swift
Shared/Models/ApneaSessionSummary.swift
Shared/Models/ApneaTrainingTable.swift
```

Se modelli equivalenti esistono già, estenderli senza duplicare.


---

# 4. P1 — iOS: Profili Apnea strutturati

Implementare profili Apnea configurabili su iOS companion.

Profili minimi:

```swift
enum ApneaProfileKind: String, Codable, CaseIterable, Sendable {
    case staticApnea
    case dynamicApnea
    case depthConstantWeight
    case trainingIntervals
    case recoverySession
    case freeTraining
}
```

Ogni profilo deve avere:

```text
id
kind
displayName
description
targetHoldSeconds opzionale
targetDepthMeters opzionale
maxRepetitions opzionale
minimumRecoveryPolicy
watchRuntimeLayout
enabledAlerts
```

Descrizioni utente:

```text
Static Apnea = timer hold + recovery
Dynamic Apnea = hold + repetitions + optional distance/manual notes
Depth / Constant Weight = depth, max depth, hold time, recovery
Training Intervals = repeated holds + structured recovery
Recovery Session = conservative short holds + longer recovery
Free Training = minimal constraints
```

Default consigliato:

```text
Free Training
```

Non rendere i profili safety-critical.

---

# 5. P1 — iOS: Apnea Session Check

Creare `ApneaSessionCheckResult`.

Stati:

```swift
enum ApneaSessionCheckStatus: String, Codable, Sendable {
    case ready
    case warning
    case incomplete
    case blocked
}
```

Check minimi:

```text
profilo selezionato
recovery policy valida
alert recovery configurato
buddy reminder mostrato
Watch battery reminder mostrato, se disponibile
sensor availability known, se disponibile
```

Messaggi warning:

```text
Buddy reminder not confirmed
Recovery policy very short
Sensor data may be incomplete
Depth data unavailable
```

UI iOS:

```text
Apnea Session Check
Profile: Static Apnea
Recovery alerts: ON
Buddy reminder: shown
Status: Ready / Warning / Incomplete
```

Non bloccare l’utente salvo configurazioni tecnicamente impossibili.

---

# 6. P1 — Apple Watch: Recovery timer automatico

Implementare o estendere runtime Watch per gestire ciclo:

```text
Hold started
↓
Hold ended
↓
Recovery timer starts automatically
↓
Recovery target calculated
↓
Haptic when recovery target is reached
```

Regole:

- Il recovery timer parte alla fine dell’hold.
- Il target recovery deriva dalla policy del profilo.
- Haptic una volta sola per ogni recovery completata.
- Non mostrare `safe` o `ready to dive` come autorizzazione.
- Usare wording EN: `Recovery target reached`.
- Usare wording IT: `Recupero target raggiunto`.

## 6.1 Recovery policy P1

Implementare almeno:

```swift
enum ApneaRecoveryPolicy: Codable, Equatable, Sendable {
    case fixed(seconds: Int)
    case ratio(multiplier: Double)
}
```

Default consigliato:

```text
ratio 2.0x last hold
```

Esempio:

```text
Last hold: 1:45
Recovery target: 3:30
Recovery left: 1:20
```

Gestire:

```text
last hold zero
recovery interrotta
nuova apnea iniziata prima del target
session stop
```

---

# 7. P1 — Apple Watch: Runtime layout per profilo

Il Watch deve adattare il layout al profilo scelto.

## Static Apnea

```text
HOLD
02:14

RECOVERY
01:20 / 04:28

REP
3/6
```

## Dynamic Apnea

```text
HOLD
01:12

REP
4

RECOVERY
02:10
```

## Depth / Constant Weight

```text
DEPTH
12.4 m

MAX
18.2 m

TIME
01:05

RECOVERY
02:30
```

## Free Training

```text
HOLD
01:40

RECOVERY
03:20

SENSORS
OK
```

Non inserire troppi dati in una schermata. Usare più pagine se necessario.

---

# 8. P1 — Apple Watch: Haptic recovery alert

Quando recovery target è raggiunto:

```swift
WKInterfaceDevice.current().play(.notification)
```

Regole:

```text
una volta per recovery
non ripetere continuamente
latch per ogni ciclo
reset latch al nuovo hold
```

Stato UI:

```text
Recovery target reached
```

Non usare:

```text
Safe to dive
```

---

# 9. P1 — iOS + Watch: Data quality base

Creare `ApneaDataQuality`.

Valori:

```swift
enum ApneaDataQualityLevel: String, Codable, Sendable {
    case good
    case medium
    case poor
    case unavailable
}
```

Valutare almeno:

```text
session completeness
valid hold count
recovery tracking completeness
depth availability
heart rate availability, se già presente
sensor gaps
```

Nel Watch mostrare compatto:

```text
Sensors OK
Depth weak
HR unavailable
```

Nel logbook iOS:

```text
Data quality: Good
Depth signal: Good
Recovery tracking: Complete
```

---

# 10. P1 — iOS: Fake logbook Apnea separato

Se non già implementato, implementare fake logbook Apnea iOS-only, separato dallo storage reale.

Regole:

```text
default OFF
abilitabile nei settings Apnea
provider separato
badge DEMO obbligatorio
non salvare fake logs nello storage reale
non sincronizzare fake logs al Watch
non includere fake logs nelle statistiche reali
```

Provider:

```text
FakeApneaLogbookProvider
```

Sessioni demo:

```text
Static apnea
Dynamic apnea
Depth apnea
Training intervals
Recovery-focused session
```

ID prefisso:

```text
demo-apnea-
```


---

# 11. P2 — iOS: Checklist pre-apnea

Aggiungere checklist leggera su iOS.

Elementi minimi IT:

```text
Buddy presente
Recupero sufficiente
Zona sicura
Nessuna iperventilazione
Segnale di stop concordato
Watch carico
Sessione non in solitaria
```

Elementi minimi EN:

```text
Buddy present
Recovery sufficient
Safe area checked
No hyperventilation
Stop signal agreed
Watch charged
Do not freedive alone
```

Regole:

- default unchecked;
- non bloccare l’uso;
- non salvare come certificazione safety;
- può influenzare Session Check come warning.

Su Watch mostrare solo reminder sintetico:

```text
Buddy?
Recovery?
Ready?
```

---

# 12. P2 — iOS: Statistiche sessione e trend

Aggiungere statistiche iOS Apnea:

```text
best static hold
best depth
number of sessions
number of holds
average hold duration
average recovery duration
recovery consistency
weekly apnea volume
sessions by profile
trend average hold
trend max depth
```

Regole:

```text
fake logbook escluso dalle statistiche reali
dati incompleti etichettati
personal best esclusi da sessioni DEMO
```

---

# 13. P2 — iOS + Watch: Recovery ratio configurabile

Estendere recovery policy:

```text
fixed seconds
ratio 1.5x
ratio 2.0x
ratio 3.0x
custom ratio, solo se già coerente con UI
```

Default:

```text
2.0x last hold
```

UI iOS:

```text
Recovery rule
- Fixed
- 2x last hold
- 3x last hold
```

Watch deve ricevere la policy configurata.

---

# 14. P2 — Watch: Session summary avanzato

A fine sessione Watch mostrare riepilogo:

```text
Best hold
Max depth
Reps
Average recovery
Data quality
```

Esempio:

```text
BEST
02:14

MAX DEPTH
18.2 m

REPS
6

QUALITY
Good
```

Non mostrare metriche non disponibili.

---

# 15. P2 — Watch: Sensor quality indicator

Mostrare indicatore compatto in runtime:

```text
SENSORS OK
DEPTH WEAK
HR —
SPO2 —
```

Regole:

```text
se HR/SpO2 non sono disponibili, non presentarli come errore grave
usare unavailable
non inventare dati
non introdurre API non supportate
```

---

# 16. P2 — Watch: Repetition tracking

Tracciare ripetizioni:

```text
rep count
hold duration per rep
recovery per rep
best hold
last hold
average recovery
```

Il runtime deve poter salvare summary nel logbook.


---

# 17. P3 — iOS: Export sessione Apnea

Implementare export/condivisione sessione Apnea.

Prima release consigliata:

```text
Share sheet testuale
```

Contenuti:

```text
profile
date
number of holds
best hold
average hold
max depth
average recovery
data quality
notes
```

Non esportare dati DEMO come reali. Se esporti DEMO, aggiungi badge `DEMO`.

---

# 18. P3 — iOS: Training tables CO2/O2

Implementare training tables come configurazioni iOS.

## CO2 table

```text
hold duration fixed or progressive
recovery decreasing
repetitions
```

## O2 table

```text
hold duration increasing
recovery fixed
repetitions
```

Regole:

```text
non presentare come programma medico
aggiungere disclaimer training
utente deve confermare profilo
Watch riceve solo step essenziali
haptic per inizio/fine hold/recovery
```

Modelli:

```text
ApneaTrainingTable
ApneaTrainingStep
ApneaTrainingTableKind
```

---

# 19. P3 — iOS: Analisi recupero

Aggiungere analisi recupero post-sessione:

```text
recovery ratio actual vs target
recovery consistency
short recovery events
trend recovery
```

Warning non medicali:

```text
Recovery shorter than configured target
```

Non usare:

```text
Unsafe
Blackout risk
Medical risk
```

---

# 20. P3 — iOS: Confronto sessioni e personal best

Aggiungere confronto sessioni:

```text
best hold by profile
best depth by profile
best session volume
average recovery trend
personal best history
```

Regole:

```text
personal best separati per profilo
fake logbook escluso
dati incomplete marcati
nessun ranking medico
```

---

# 21. P3 — Watch: Coaching mode leggero

Implementare solo se P1/P2 sono solidi.

Runtime Watch per training tables:

```text
Next: Hold
Hold: 01:30
Recovery: 02:00
Rep: 3/8
```

Haptic:

```text
start hold
end hold
recovery target reached
table completed
```

Non usare voce o interazioni complesse.

---

# 22. Cosa NON portare da Snorkeling ad Apnea

Non implementare in Apnea:

```text
waypoint
ritorno al punto di ingresso come funzione runtime
off-route warning
route progress %
mappa avanzata
tipo mappa Satellite / Explore
reset mappa
distanza da ingresso
freccia/bearing runtime
snorkeling route planner
```

Unico uso GPS ammesso per Apnea:

```text
location metadata nel logbook, opzionale e non safety-critical
```

---

# 23. Modelli e helper testabili

Creare helper puri dove possibile:

```text
ApneaRecoveryTargetCalculator
ApneaSessionCheckEvaluator
ApneaDataQualityEvaluator
ApneaSensorQualityEvaluator
ApneaStatisticsCalculator
ApneaTrainingTableBuilder
ApneaTrainingStepRuntimeEvaluator
ApneaPersonalBestCalculator
ApneaExportPayloadBuilder
```

Evitare logica complessa direttamente in SwiftUI View.


---

# 24. Localizzazione

Aggiornare localizzazioni IT/EN iOS e Watch.

Chiavi minime EN:

```properties
apnea.profile.static = "Static Apnea";
apnea.profile.dynamic = "Dynamic Apnea";
apnea.profile.depth_constant_weight = "Depth / Constant Weight";
apnea.profile.training_intervals = "Training Intervals";
apnea.profile.recovery_session = "Recovery Session";
apnea.profile.free_training = "Free Training";
apnea.session_check.title = "Apnea Session Check";
apnea.session_check.ready = "Session ready";
apnea.session_check.warning = "Session warning";
apnea.session_check.incomplete = "Session incomplete";
apnea.recovery.title = "Recovery";
apnea.recovery.target_reached = "Recovery target reached";
apnea.recovery.rule = "Recovery rule";
apnea.recovery.fixed = "Fixed recovery";
apnea.recovery.ratio_2x = "2x last hold";
apnea.recovery.ratio_3x = "3x last hold";
apnea.checklist.title = "Pre-apnea checklist";
apnea.checklist.buddy = "Buddy present";
apnea.checklist.recovery = "Recovery sufficient";
apnea.checklist.safe_area = "Safe area checked";
apnea.checklist.no_hyperventilation = "No hyperventilation";
apnea.checklist.stop_signal = "Stop signal agreed";
apnea.checklist.watch_charged = "Watch charged";
apnea.checklist.not_alone = "Do not freedive alone";
apnea.data_quality.title = "Data quality";
apnea.sensor_quality.title = "Sensor quality";
apnea.watch.sensors_ok = "Sensors OK";
apnea.watch.depth_weak = "Depth weak";
apnea.watch.hr_unavailable = "HR unavailable";
apnea.watch.recovery_target_reached = "Recovery target reached";
apnea.summary.best_hold = "Best hold";
apnea.summary.max_depth = "Max depth";
apnea.summary.reps = "Reps";
apnea.summary.average_recovery = "Average recovery";
apnea.export.share_session = "Share apnea session";
apnea.training.co2_table = "CO2 table";
apnea.training.o2_table = "O2 table";
apnea.disclaimer.training_aid = "Training and logging aid only. Do not freedive alone.";
```

Chiavi minime IT:

```properties
apnea.profile.static = "Apnea statica";
apnea.profile.dynamic = "Apnea dinamica";
apnea.profile.depth_constant_weight = "Profondità / Peso costante";
apnea.profile.training_intervals = "Allenamento a intervalli";
apnea.profile.recovery_session = "Sessione recupero";
apnea.profile.free_training = "Allenamento libero";
apnea.session_check.title = "Controllo sessione apnea";
apnea.session_check.ready = "Sessione pronta";
apnea.session_check.warning = "Avviso sessione";
apnea.session_check.incomplete = "Sessione incompleta";
apnea.recovery.title = "Recupero";
apnea.recovery.target_reached = "Recupero target raggiunto";
apnea.recovery.rule = "Regola recupero";
apnea.recovery.fixed = "Recupero fisso";
apnea.recovery.ratio_2x = "2x ultima apnea";
apnea.recovery.ratio_3x = "3x ultima apnea";
apnea.checklist.title = "Checklist pre-apnea";
apnea.checklist.buddy = "Buddy presente";
apnea.checklist.recovery = "Recupero sufficiente";
apnea.checklist.safe_area = "Zona sicura controllata";
apnea.checklist.no_hyperventilation = "Nessuna iperventilazione";
apnea.checklist.stop_signal = "Segnale di stop concordato";
apnea.checklist.watch_charged = "Watch carico";
apnea.checklist.not_alone = "Non fare apnea da solo";
apnea.data_quality.title = "Qualità dati";
apnea.sensor_quality.title = "Qualità sensori";
apnea.watch.sensors_ok = "Sensori OK";
apnea.watch.depth_weak = "Profondità debole";
apnea.watch.hr_unavailable = "FC non disponibile";
apnea.watch.recovery_target_reached = "Recupero target raggiunto";
apnea.summary.best_hold = "Migliore apnea";
apnea.summary.max_depth = "Profondità max";
apnea.summary.reps = "Ripetizioni";
apnea.summary.average_recovery = "Recupero medio";
apnea.export.share_session = "Condividi sessione apnea";
apnea.training.co2_table = "Tabella CO2";
apnea.training.o2_table = "Tabella O2";
apnea.disclaimer.training_aid = "Solo supporto ad allenamento e logbook. Non fare apnea da solo.";
```

Evitare duplicati.


---

# 25. Test obbligatori

Creare/aggiornare test iOS:

```text
Tests/iOSAlgorithmTests/ApneaProfileTests.swift
Tests/iOSAlgorithmTests/ApneaRecoveryTargetCalculatorTests.swift
Tests/iOSAlgorithmTests/ApneaSessionCheckEvaluatorTests.swift
Tests/iOSAlgorithmTests/ApneaChecklistTests.swift
Tests/iOSAlgorithmTests/ApneaDataQualityEvaluatorTests.swift
Tests/iOSAlgorithmTests/ApneaStatisticsCalculatorTests.swift
Tests/iOSAlgorithmTests/ApneaExportPayloadBuilderTests.swift
Tests/iOSAlgorithmTests/ApneaTrainingTableBuilderTests.swift
```

Creare/aggiornare test Watch:

```text
Tests/WatchAlgorithmTests/ApneaWatchRecoveryRuntimeTests.swift
Tests/WatchAlgorithmTests/ApneaWatchHapticLatchTests.swift
Tests/WatchAlgorithmTests/ApneaWatchProfileRuntimeLayoutTests.swift
Tests/WatchAlgorithmTests/ApneaWatchSensorQualityTests.swift
Tests/WatchAlgorithmTests/ApneaWatchSessionSummaryTests.swift
Tests/WatchAlgorithmTests/ApneaTrainingStepRuntimeEvaluatorTests.swift
```

Test minimi:

```text
default profile = Free Training
static profile has recovery policy
depth profile shows depth metrics if available
recovery fixed seconds works
recovery ratio 2x last hold works
zero hold does not crash
recovery alert fires once
recovery alert latch resets on next hold
session check ready with valid profile
session check warning if buddy checklist not confirmed
data quality good/medium/poor/unavailable
fake apnea logs excluded from real statistics
personal best excludes demo logs
training CO2 table recovery decreases
training O2 table hold increases
no Diving regression
no Snorkeling regression
no Full Computer regression
```

---

# 26. Documentazione

Creare:

```text
Docs/APNEA_IOS_WATCH_ROADMAP_P1_P2_P3.md
Docs/APNEA_IOS_WATCH_ARCHITECTURE.md
Docs/APNEA_RECOVERY_TIMER_POLICY.md
Docs/APNEA_SESSION_CHECK.md
Docs/APNEA_DATA_QUALITY_POLICY.md
Docs/APNEA_TRAINING_TABLES.md
Docs/APNEA_IOS_WATCH_P1_P2_P3_IMPLEMENTATION_REPORT_CURRENT.md
```

Documentare:

```text
separazione iOS/Watch
P1/P2/P3
profili Apnea
recovery policy
session check
checklist
Watch runtime
data quality
fake logbook
training tables
limitazioni
nessuna pretesa safety-critical
QA richiesta
```

---

# 27. QA evidence

Creare template QA:

```text
Docs/QA_EVIDENCE/APNEA_IOS_PROFILES/README.md
Docs/QA_EVIDENCE/APNEA_IOS_SESSION_CHECK/README.md
Docs/QA_EVIDENCE/APNEA_WATCH_RECOVERY_TIMER/README.md
Docs/QA_EVIDENCE/APNEA_WATCH_RECOVERY_HAPTIC/README.md
Docs/QA_EVIDENCE/APNEA_WATCH_PROFILE_RUNTIME_LAYOUT/README.md
Docs/QA_EVIDENCE/APNEA_DATA_QUALITY_LOGBOOK/README.md
Docs/QA_EVIDENCE/APNEA_IOS_CHECKLIST/README.md
Docs/QA_EVIDENCE/APNEA_IOS_STATISTICS/README.md
Docs/QA_EVIDENCE/APNEA_IOS_EXPORT/README.md
Docs/QA_EVIDENCE/APNEA_TRAINING_TABLES/README.md
Docs/QA_EVIDENCE/APNEA_NO_CROSS_ACTIVITY_REGRESSION/README.md
```

Ogni template deve contenere:

```text
QA ID
priority P1/P2/P3
branch
commit
tester
reviewer
date/time
iPhone model
iOS version
Apple Watch model
watchOS version
app build
preconditions
steps
expected result
observed result
screenshots/video/logs
sensor availability
PASS/FAIL/PENDING
tester signature
reviewer signature
```

Default:

```text
PENDING
```

---

# 28. Build e validazione

Eseguire:

```bash
xcodegen generate
```

Build iOS:

```bash
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Build Watch:

```bash
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Test iOS:

```bash
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 15' test
```

Test Watch:

```bash
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
```

Script se presenti:

```bash
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
./Scripts/check_main_target_isolation.sh
./Scripts/validate_snorkeling_release_readiness.sh
```

Se esistono script Apnea specifici, eseguirli.

---

# 29. Acceptance criteria P1

P1 è accettabile se:

```text
iOS ha profili Apnea strutturati
iOS ha Apnea Session Check
Watch ha recovery timer automatico
Watch ha recovery alert haptic
Watch layout cambia in base al profilo
iOS/Watch hanno data quality base
fake logbook Apnea è separato e non contamina dati reali
nessuna modifica a Diving/Snorkeling/Full Computer
test P1 aggiunti
documentazione P1 aggiunta
QA template P1 creati
```

Verdetto massimo P1 senza QA fisica:

```text
P1_INTERNAL_READY
P1_PHYSICAL_QA_PENDING
APNEA_PROFILES_READY
APNEA_RECOVERY_TIMER_READY
APNEA_SESSION_CHECK_READY
NO_CROSS_ACTIVITY_REGRESSION
```

---

# 30. Acceptance criteria P2

P2 è accettabile se:

```text
iOS ha checklist pre-apnea
iOS ha statistiche sessione e trend
iOS ha recovery ratio configurabile
Watch riceve recovery policy configurata
Watch ha session summary avanzato
Watch ha sensor quality indicator
Watch traccia ripetizioni
test P2 aggiunti
documentazione P2 aggiunta
QA template P2 creati
```

Verdetto massimo P2 senza QA fisica:

```text
P2_INTERNAL_READY
P2_PHYSICAL_QA_PENDING
APNEA_CHECKLIST_READY
APNEA_STATISTICS_READY
APNEA_SENSOR_QUALITY_READY
NO_SAFETY_CRITICAL_CLAIMS
```

---

# 31. Acceptance criteria P3

P3 è accettabile se:

```text
iOS può esportare/condividere sessione Apnea
iOS supporta training tables CO2/O2
iOS ha analisi recupero
iOS ha confronto sessioni e personal best per profilo
Watch supporta coaching mode leggero per training tables
test P3 aggiunti
documentazione P3 aggiunta
QA template P3 creati
```

Verdetto massimo P3 senza QA fisica:

```text
P3_INTERNAL_READY
P3_PHYSICAL_QA_PENDING
APNEA_EXPORT_READY
APNEA_TRAINING_TABLES_READY
APNEA_RECOVERY_ANALYSIS_READY
NO_MEDICAL_DEVICE_CLAIMS
```

---

# 32. Implementation strategy

Implementare in sequenza:

```text
Step 1: shared models + helpers pure
Step 2: iOS P1 profiles + session check
Step 3: Watch P1 recovery timer + haptic alert
Step 4: Watch P1 profile layouts + data quality base
Step 5: fake Apnea logbook integration check
Step 6: tests P1 + docs + QA templates
Step 7: iOS P2 checklist + statistics + recovery ratio
Step 8: Watch P2 sensor quality + summary + repetition tracking
Step 9: tests P2 + docs
Step 10: iOS P3 export + CO2/O2 tables + recovery analysis
Step 11: Watch P3 lightweight coaching mode
Step 12: tests P3 + final docs
```

Non implementare P3 prima di P1/P2.

Se una parte è troppo grande per un singolo commit, dividere in branch/commit logici:

```text
apnea-p1-profiles-session-check
apnea-p1-watch-recovery
apnea-p2-checklist-statistics
apnea-p2-watch-sensor-quality
apnea-p3-training-export
```

---

# 33. Report finale richiesto

Alla fine produci un report con:

```text
branch
baseline commit
implementation scope
P1 files changed
P2 files changed
P3 files changed
shared models added/updated
iOS Apnea profiles changes
iOS Apnea Session Check changes
iOS checklist/statistics/export changes
Watch Apnea runtime changes
Watch recovery timer changes
Watch haptic changes
Watch profile layout changes
Watch sensor/data quality changes
training tables changes
logbook changes
fake logbook separation evidence
tests added
tests executed
build result
localization result
docs created
QA templates created
known limitations
physical QA status
final verdict
```

Final verdict massimo senza test reale:

```text
INTERNAL_READY
PHYSICAL_QA_PENDING
APNEA_IOS_WATCH_P1_READY
APNEA_IOS_WATCH_P2_READY
APNEA_IOS_WATCH_P3_READY
NO_CROSS_ACTIVITY_REGRESSION
NO_LOCATION_POLICY_REGRESSION
NO_FAKE_DATA_CONTAMINATION
NO_SAFETY_CRITICAL_CLAIMS
NO_MEDICAL_DEVICE_CLAIMS
```
