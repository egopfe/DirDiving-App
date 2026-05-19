# Report: blocco critico iOS — mismatch tab ↔ target (`project.yml`)

**Repository:** DIR DIVING  
**Ambito:** target `DIRDiving iOS` su branch `main`  
**Tipo:** analisi causa radice + piano d’azione (nessuna modifica applicata in questo file)

---

## 1. Sintesi esecutiva

Il target iOS generato da **XcodeGen** include solo i file sotto `iOSApp/` **eccetto** quelli elencati in `project.yml` → `targets.DIRDiving iOS.sources[0].excludes`.

Sul **commit `HEAD` di `main`** (stato versionato su git), `iOSApp/Views/ContentView.swift` referenzia tipi definiti in file **esclusi** dal target:

| Tab su `HEAD` | Tipo Swift | File sorgente | In `project.yml` excludes? |
|---------------|------------|----------------|----------------------------|
| Explore Lab | `ExplorationCenterView` | `iOSApp/Views/ExplorationCenterView.swift` | **Sì** |
| Buddy Lab | `BuddyExperimentalView` | `iOSApp/Views/BuddyExperimentalView.swift` | **Sì** |

**Effetto:** il compilatore Swift non trova i simboli (`Cannot find type 'ExplorationCenterView' in scope`, ecc.) → **build iOS fallita**.

**Nota sul working tree locale (non committato):** esiste già un tentativo di correzione (`ContentView` che usa `ExploreView` + file `ExploreView.swift` e servizi correlati), ma **`ExploreView.swift` risulta ancora non tracciato da git** (`git status` → `??`). Finché non è committato insieme alle dipendenze, clone puliti / CI / altri sviluppatori restano sullo scenario rotto di `HEAD`.

---

## 2. Causa radice (tecnica)

1. **XcodeGen** costruisce la lista di compilazione = file nella cartella `iOSApp` **meno** `excludes`.
2. Le view “Lab” / experimental sono state **escluse** dal target MAIN per policy (codice sperimentale fuori dalla build di release).
3. **`ContentView` non è stato aggiornato** per allinearsi a quella decisione: continua a dichiarare tab che puntano a tipi non compilati nel modulo iOS.

Non è un bug di SwiftUI o di Xcode in sé: è **incoerenza tra navigazione di ingresso dell’app e definizione del target**.

---

## 3. Evidenza (riferimenti)

### 3.1 Esclusioni target (estratto logico)

In `project.yml`, per `DIRDiving iOS`, tra gli esclusi compaiono ad esempio:

- `Views/ExplorationCenterView.swift`
- `Views/BuddyExperimentalView.swift`
- (e modelli/store collegati: `ExplorationPlanningStore`, `BuddyExperimentalStore`, …)

### 3.2 `ContentView` su `HEAD` (versionato)

Su `git show HEAD:iOSApp/Views/ContentView.swift` le tab includono ancora:

- `ExplorationCenterView()` — file escluso  
- `BuddyExperimentalView()` — file escluso  

Quindi **HEAD non è coerente** con `project.yml`.

### 3.3 Direzione di fix già iniziata (working tree)

Il file locale `iOSApp/Views/ContentView.swift` (modificato, non committato) usa ad esempio `ExploreView()` al posto di “Explore Lab”, in linea con una **UI MAIN stabile**.

`ExploreView` dipende da servizi tipicamente in:

- `RouteSummaryService.swift`
- `DiveImportService.swift`

Questi file devono essere **nel target** (non in `excludes`) e **versionati** affinché la soluzione sia riproducibile.

---

## 4. Obiettivo di chiusura issue

**Definizione di “risolto”:**

1. `xcodegen generate` + build `DIRDiving iOS` **senza errori** su macOS.  
2. Ogni `struct`/`class` referenziata da `ContentView` (e da `DIRDivingiOSApp` / `@StateObject` / `.environmentObject`) ha il relativo `.swift` **incluso** nel target.  
3. Nessun tab MAIN punta a file in `excludes` (salvo decisione documentata di rimuovere l’exclude — sconsigliato per policy experimental).  
4. CI / clone pulito: **stesso risultato** dopo `git checkout` senza file solo locali.

---

## 5. Opzioni di soluzione (con pro/contro)

### Opzione A — **Allineare la UI al target (consigliata per `main`)**

**Cosa fare:** `ContentView` (e eventuali deep link) usano **solo** tipi i cui `.swift` sono compilati nel target MAIN.

**Esempi concreti:**

- Rimuovere le tab “Explore Lab” e “Buddy Lab” da `ContentView` su `main`, **oppure**
- Sostituirle con viste MAIN già nel target (`ExploreView` stabile, `AnalysisView`, ecc.) **senza** importare tipi esclusi.

**Pro:** rispetta la policy “experimental fuori da MAIN”; build verde; meno rischio App Store.  
**Contro:** richiede commit coordinato (tab + eventuali nuovi file + `DIRDivingiOSApp`).

---

### Opzione B — **Rimuovere gli `excludes` per i file Lab**

**Cosa fare:** togliere da `project.yml` le righe che escludono `ExplorationCenterView`, `BuddyExperimentalView`, store e modelli collegati.

**Pro:** `ContentView` su `HEAD` torna a compilare senza riscrittura tab.  
**Contro:** **contraddice** l’intento di tenere experimental fuori dal MAIN; contenuto “TODO / placeholder” può finire in build di produzione; rischio review App Store e confusione utente.

**Verdetto:** sconsigliata salvo cambio esplicito di policy prodotto.

---

### Opzione C — **Target iOS duplicato** (es. `DIRDiving iOS Experimental`)

**Cosa fare:** secondo target XcodeGen che include i Lab; il target MAIN resta pulito.

**Pro:** separazione netta.  
**Contro:** costo manutenzione doppio (scheme, icone, bundle id, provisioning); spesso overkill se il prodotto retail è uno solo.

---

## 6. Piano d’azione raccomandato (Opzione A, passi ordinati)

### Fase 0 — Decisione (5 min)

- Confermare: **`main` = solo funzionalità stabilie**, nessun Lab in tab bar.

### Fase 1 — Inventario dipendenze (30–60 min)

1. Aprire `ContentView.swift` **target finale** (post-fix).  
2. Per ogni tipo nella `TabView`, elencare: file `.swift`, `@EnvironmentObject` / `@StateObject` richiesti.  
3. Incrociare con `project.yml` → `excludes`: **nessun tipo tab deve risiedere in un file escluso**.

### Fase 2 — Implementazione minima (1–2 h)

1. **Sostituire** le tab Lab con viste MAIN già previste (es. `ExploreView` + copy “Explore” / “Route Review” coerente con prodotto).  
2. Assicurarsi che **tutti** i file usati da quelle view siano:
   - presenti sotto `iOSApp/`,
   - **non** in `excludes`,
   - **committati** (`git add` …).  
3. Allineare `DIRDivingiOSApp.swift`: `@StateObject` / `.environmentObject` solo per store **inclusi** nel target (niente `BuddyExperimentalStore` / `ExplorationPlanningStore` su MAIN se restano esclusi).

### Fase 3 — Verifica build (macOS)

```bash
cd /path/to/DirDiving-App
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' -configuration Debug build
```

*(Aggiungere `-sdk iphonesimulator` e una destination simulatore se preferite.)*

### Fase 4 — Regressioni UX (30 min)

- Avvio app → ogni tab si apre senza crash.  
- Nessun riferimento a stringhe “Lab” se non più in prodotto.  
- Sync Watch / Logbook / Planner smoke test.

### Fase 5 — Prevenzione futura

- **Checklist PR:** “Se modifichi `project.yml` excludes, aggiorna `ContentView` / entry point”.  
- Opzionale: script CI che greppa `ContentView` vs lista excludes (fragile ma utile) o build obbligatoria su ogni PR verso `main`.

---

## 7. Checklist di verifica (Definition of Done)

- [ ] `git show HEAD:iOSApp/Views/ContentView.swift` non contiene `ExplorationCenterView` né `BuddyExperimentalView` (se restano esclusi).  
- [ ] Nessun altro file iOS importa tipi da file esclusi (grep incrociato).  
- [ ] `project.yml` valido; `xcodegen generate` OK.  
- [ ] `xcodebuild` target `DIRDiving iOS` **OK**.  
- [ ] Clone pulito + build OK.  
- [ ] Documentazione README/Docs aggiornata se le tab utente cambiano nome.

---

## 8. Rischi residui

| Rischio | Mitigazione |
|--------|-------------|
| File nuovi dimenticati in git | `git status` pulito prima del merge |
| `ExploreView` dipende da codice non committato | Aggiungere tutti i `.swift` necessari nello stesso commit / PR |
| Divergenza `main` vs `main-iOS` | Dopo fix, confrontare tab e store con branch di riferimento e documentare |

---

## 9. Conclusione

Il blocco è **100% strutturale**: tab che importano tipi da unità di compilazione escluse. La soluzione corretta per `main` è **allineare la superficie utente (tab) al perimetro del target** (Opzione A), eventualmente usando la direzione già iniziata con `ExploreView` **a patto che tutto sia committato e buildato**.

L’Opzione B (re-includere i Lab) va scelta solo se il prodotto accetta esplicitamente experimental nella build MAIN.

---

*Documento generato per supporto decisionale; non modifica il codice applicativo.*
