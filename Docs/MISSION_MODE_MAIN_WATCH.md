# Mission Mode — Watch MAIN

**Aggiornato:** 2026-05-29
**Ambito:** solo Apple Watch `main` (nessun file experimental, nessun cambiamento companion iOS richiesto)

---

## Scopo

Mission Mode e un **profilo interno DIR DIVING** di ottimizzazione runtime/UI per immersioni attive su Apple Watch MAIN. Riduce animazioni ed effetti decorativi non essenziali durante la sessione.

**Non** attiva la modalita Basso Consumo di sistema di Apple Watch. DIR DIVING non puo abilitarla tramite API pubblica.

Mission Mode **non** cambia logica immersione, warning safety, campionamento profondita, logging, GPS, allarmi, aptica (salvo il toggle aptico globale), WatchConnectivity o calcoli.

---

## Persistenza

| Elemento | Persistito? | Chiave / nota |
|----------|-------------|---------------|
| Auto-enable on dive start | Si (`@AppStorage`) | `dirdiving.missionMode.autoEnableOnDiveStart` — default **OFF** |
| Stato runtime attivo | No | Solo sessione corrente |
| Override manuale pre-immersione | No | `missionModeManualPendingForSession` — azzerato a fine immersione |
| Draft immersione attiva | Si (senza flag Mission) | Ripristino riesegue `applyMissionModeIfNeededOnDiveStart(restored:)` |

---

## Attivazione

Mission Mode runtime si attiva quando:

1. **Auto-enable** e ON e l'app entra in immersione attiva (`beginDiveIfNeeded`), oppure
2. L'utente sceglie **Attiva ora** in Settings (superficie) — pending per la prossima immersione, oppure
3. L'utente tocca il **fulmine** in Live durante immersione attiva (controllo manuale compatto), oppure
4. Un **draft immersione attiva** valido viene ripristinato e auto-enable e ON (`restored`).

Path avvio immersione coperti: automatico da sensore e manuale da Live.

---

## Disattivazione

- Fine immersione: runtime disattivato; preferenza auto-enable invariata; pending manuale azzerato.
- **Disattiva ora** in Settings (superficie) o fulmine in Live: disattiva runtime e pending manuale; non modifica auto-enable.

---

## Settings (Watch)

Sezione **Modalità Missione** / **Mission Mode**:

- Toggle auto-enable (disabilitato durante immersione attiva)
- Riga stato (attiva / non attiva / si attivera alla prossima immersione)
- Attiva ora / Disattiva ora (superficie)
- Durante immersione: hint per usare il fulmine in Live
- Testo effetti, esclusioni safety, disclaimer Apple Basso Consumo

---

## Effetti runtime (codice)

Quando Mission Mode e attivo:

- `MissionModeRuntimeProfile.mission`: `animationsEnabled = false`, `decorativeEffectsEnabled = false`
- Applicato a **Live** e **Bussola** (animazioni SwiftUI e shadow decorativi)

Non sono presenti campi morti (`uiRefreshInterval` rimosso). Nessun throttling di campionamento profondita, GPS, allarmi, logging o aptica.

---

## Indicatore Live

- Controllo compatto sul logo (fulmine): pieno = attivo, contorno = non attivo
- Accessibilita EN/IT con hint sul profilo interno
- Non copre profondita, runtime, TTV o gauge risalita

---

## Info — Basso Consumo Apple (solo lettura)

`InfoView` mostra se `ProcessInfo.processInfo.isLowPowerModeEnabled` e attivo sul sistema, con nota che DIR DIVING non puo attivarlo.

---

## Esclusioni di sicurezza

Invariato rispetto alla policy prodotto: nessuna modifica a profondita, runtime, warning risalita, limiti profondita, aptica safety, campionamento, logging, GPS, calcoli.

---

## Test e QA hardware

- Test unitari: `Tests/WatchAlgorithmTests/MissionModeTests.swift`
- Impatto batteria reale: validare su hardware prima di claim marketing
