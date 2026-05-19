# Report — iOS tab vs target (`project.yml`): stato al 2026-05-19

## 1. Domanda diretta

**Il mismatch tab ↔ target è ancora presente sul *commit* registrato in git (`HEAD`)?**  
**Sì.** Su `HEAD` di `main`, `ContentView` importa ancora `ExplorationCenterView` e `BuddyExperimentalView`, i cui file sono **esclusi** dal target `DIRDiving iOS` in `project.yml` → il modulo iOS **non** contiene quei tipi → **errore di compilazione atteso** (es. «Cannot find type … in scope»).

**È risolto nel *working tree* locale (file non ancora committati)?**  
**Sì, per la parte tab.** La copia locale di `iOSApp/Views/ContentView.swift` usa solo `LogbookView`, `AnalysisView`, `PlannerView`, `EquipmentView`, `MoreView`, tutte in file **non** esclusi dal target.

---

## 2. Meccanismo tecnico (perché succede)

1. XcodeGen costruisce il target iOS includendo `iOSApp/**/*.swift` **tranne** i path in `excludes`.
2. Se `ContentView.swift` (che **è** incluso) referenzia un tipo definito in un file **escluso**, il compilatore non vede quel file nel target → simbolo mancante.
3. Il problema **non** è SwiftUI in sé: è **incoerenza tra navigazione di ingresso e perimetro del target**.

---

## 3. Evidenza (file e righe)

### 3.1 Esclusioni iOS (`project.yml`)

Sotto `targets → DIRDiving iOS → sources → excludes` compaiono tra gli altri:

- `Views/ExplorationCenterView.swift`
- `Views/BuddyExperimentalView.swift`
- (e store/modelli collegati: `ExplorationPlanningStore`, `BuddyExperimentalStore`, …)

### 3.2 `ContentView` su `HEAD` (versione committata)

`git show HEAD:iOSApp/Views/ContentView.swift` contiene ancora:

```swift
ExplorationCenterView().tabItem { Label("Explore Lab", ...) }
BuddyExperimentalView().tabItem { Label("Buddy Lab", ...) }
```

→ **Mismatch confermato** rispetto agli `excludes`.

### 3.3 `ContentView` nel working tree (modificato, non in `HEAD`)

Versione attuale sul disco: cinque tab (`Logbook`, `Analisi`, `Planner`, `Attrezzatura`, `Altro`) senza riferimenti ai file esclusi.

### 3.4 `DIRDivingiOSApp.swift` (working tree)

Espone solo `DiveLogStore`, `WatchSyncService`, `PlannerStore`, `EquipmentStore`, `CloudSyncStore`, `IOSNavigationStore` — **nessun** `BuddyExperimentalStore` / `ExplorationPlanningStore` richiesto dalle tab escluse. Coerente con le tab corrette.

---

## 4. Stato «due mondi»: git vs disco

| Aspetto | `HEAD` (origin/main dopo push) | Working tree (locale) |
|--------|--------------------------------|------------------------|
| Tab Explore/Buddy Lab | Presenti | Assenti |
| Coerenza con `project.yml` | **No** | **Sì** (per ContentView) |
| Build iOS attesa | **Fallita** (simboli esclusi) | Dipende da altri file modificati / non tracciati |

`git status` tipico: `M iOSApp/Views/ContentView.swift` (e altri file iOS ancora non committati nel commit solo-docs).

---

## 5. Rischi secondari (post-fix tab)

Anche con `ContentView` corretto, la build può fallire se:

- `AnalysisView` (o altre viste) nel working tree chiama tipi in file **non tracciati** da git (es. servizi route/import) assenti su clone pulito.
- Sul **commit** `HEAD`, `AnalysisView` è ancora la versione più semplice (senza `RouteSummaryService`); il rischio principale resta **`ContentView` su `HEAD`**.

Verifica consigliata dopo commit delle fix iOS:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS' build
```

---

## 6. Conclusione operativa

| Voce | Esito |
|------|--------|
| Mismatch ancora presente su **git `HEAD`**? | **Sì** |
| Mismatch risolto nel **working tree** per `ContentView`? | **Sì** |
| Azione consigliata | **Commit + push** (o PR) che includa `ContentView.swift` (e coerenze collegate) su `main`, poi build su macOS |

---

## 7. Definition of Done (chiusura issue)

- [ ] `git show HEAD:iOSApp/Views/ContentView.swift` **non** contiene `ExplorationCenterView` né `BuddyExperimentalView`.
- [ ] Nessun altro sorgente nel target iOS importa tipi da file in `excludes` (grep / CI).
- [ ] `xcodebuild` **DIRDiving iOS** verde su macOS.

*Report additivo; non modifica il codice.*
