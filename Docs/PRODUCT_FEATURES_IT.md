# DIR DIVING — Panoramica funzionalità (italiano)

**Aggiornato:** 2026-05-31  
**Branch di riferimento:** `main` @ `1d69d88` (`origin/main`; algorithm @ `dce89e7`)  
**Spec prodotto corrente:** [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md)

Documento additivo: integra README e matrice CSV senza sostituire audit o note legali dettagliate.

---

## Piattaforme

| App | Target | Branch stabile | Branch sperimentale |
|-----|--------|----------------|---------------------|
| Apple Watch Ultra / watchOS 10+ | `DIRDiving Watch App` | `main` | `codex/experimental-features` |
| iPhone companion iOS 17+ | `DIRDiving iOS` | `main` (workspace unificato) | `codex/ios-experimental-features` |
| Worktree storico solo iOS | — | `main-iOS` (divergente; non baseline release) | — |

Generazione progetto: `xcodegen generate` → `DIRDiving.xcodeproj` (non versionato).

---

## Onboarding e disclaimer

- Flusso obbligatorio al primo avvio o cambio revisione legale: Welcome → Safety Warning → Disclaimer completo → Acceptance.
- Testi IT/EN in `LegalDisclaimer.txt` per Watch e iOS.
- Persistenza accettazione: versione app, major, device, lingua, timestamp.
- **Settings → Legal & Safety** per rilettura.
- Overlay companion a **ogni cold launch** (oltre onboarding) — `CompanionDisclaimerAcceptance`.
- Checkbox limiti operativi profondità Apple (35/38/40 m); revisione legale `2026-05-23`.

Vedi [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md).

---

## Modalità operative

### Diving (MAIN — `main`)

- Schermata live: profondità, TTV informativo, RunTime, gauge risalita, cronometro manuale, warning risalita inline (non full-screen).
- **Start Dive** visibile in superficie sulla schermata iniziale/live del Watch: avvio manuale disponibile senza disattivare l'avvio automatico da profondità.
- **BUSSOLA** dedicata: heading, SET BEARING, CLEAR (terminologia UI: **BUSSOLA**, mai «COMPASSO»).
- GPS ingresso/uscita **solo in superficie** (best-effort); nessun tracking subacqueo certificato.
- Log ultime 40 immersioni, dettaglio, export CSV Subsurface, sync WatchConnectivity + iCloud KVS.
- Settings: limiti risalita, allarmi (profondità default configurabile 30/40 m, tempo default 30 min), haptic, unità metrico/imperiale (display), info device/batteria, sync.
- **Mission Mode**: opzione locale Watch con toggle *Auto-enable on dive start*; si attiva solo dopo l'ingresso in stato immersione attiva, si disattiva a fine immersione, riduce solo animazioni/effetti non essenziali e mostra un indicatore icona minimale vicino al polpo solo durante l'immersione attiva.
- Immagini utente: tab sempre disponibile **fuori** immersione attiva; durante immersione solo Live + BUSSOLA.
- App Intents / Action Button: cronometro, bearing, allarmi (quando watchOS espone gli intent).
- **Algorithm hardening MAIN (`92e639a`):** pipeline depth validata, lifecycle automatico >1 m con debounce, TTV/time-weighted average depth, haptic coordinator fuori da SwiftUI view; resta **non certificato** — vedi [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md).

### Snorkeling (MAIN — Watch + iOS companion)

- **Snorkeling Live (Watch):** runtime, distanza, velocità, profondità, GPS, waypoint, ritorno.
- **iOS companion:** dashboard, sessioni, statistiche, route planner, profili, logbook isolato.
- Architettura: [`SNORKELING_ARCHITECTURE.md`](SNORKELING_ARCHITECTURE.md). QA fisica paired-device: **PENDING**.

### Apnea (MAIN — Watch + iOS companion)

- Menu Sessione / Tabelle / Statistiche / Logbook; acque libere con countdown e recovery.
- **iOS companion:** planner, logbook, statistiche, export isolato da Diving/Snorkeling.
- Architettura: [`APNEA_ARCHITECTURE.md`](APNEA_ARCHITECTURE.md). Non certificato; QA fisica: **PENDING**.

Spec legacy branch (solo esplorazione): [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md), [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md).

---

## Companion iOS (MAIN)

Cinque tab (ordine): **Planner**, Logbook, Analisi, Attrezzatura, Altro.

| Area | Contenuto |
|------|-----------|
| **Planner** | Cilindri multipli, ruoli gas (Back / Travel / Deco / Bailout), mix Air/EAN/Trimix, PPO₂ step 0.1, MOD Dalton, riferimento pianificazione max/media; motore **Bühlmann ZHL-16C N2+He** reference con GF, NDL, soste generate; risultati PIANO / BÜHLMANN / GRAFICI; pianificazione ripetitiva con snapshot tessuti v2 e carryover CNS/OTU; ledger gas per cilindro; ambiente altitudine/salinità; ack sicurezza persistito |
| **CNS / OTU (planner)** | Modello NOAA di riferimento: limiti singolo e giornaliero, recupero superficie/pausa aria (90 min), OTU Lambertsen con soglie REPEX giornaliere/settimanali; integrazione su profilo completo (discesa, fondo, deco); **solo pianificazione di riferimento — non guida certificata** |
| **Logbook** | Lista, dettaglio, immersioni manuali, import/export CSV |
| **Analisi** | Metriche logbook, SAC, gas, riepilogo route GPS (entry/exit surface-only) |
| **Attrezzatura** | Profilo, checklist editabile, **La mia attrezzatura** (template REC/TEC), switch GAS ON/OFF per voce |
| **Altro** | Settings, sync Watch, iCloud, lingua IT/EN, invio foto Watch con validazione/resize |

Export Subsurface: [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md).

Implementazione v8/v9: [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md), [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md).

---

## Design system UI/UX

- Watch: sfondo nero, profondità oversize, accenti blu/verde/giallo/rosso, pannelli bordati — riferimento `MASTER_REFERENCE_DIVING_LIVE.png`, [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md), [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md).
- iOS: dark mode, card charcoal, accenti ciano — `iOS_look_feel.png`, `Docs/ReferenceUI/`.
- Pass UI-only **non** alterano algoritmi immersione, GPS, bussola, decompressione.

---

## Internazionalizzazione

- Lingue: **Italiano** e **English** (`DIRAppLanguage` / `DIRIOSAppLanguage`: system / it / en).
- Bundle: `Resources/{en,it}.lproj` (Watch), `iOSApp/Resources/{en,it}.lproj` (iOS).
- Cambio lingua non modifica unità salvate, calcoli o persistenza.
- Debito: alcuni messaggi runtime planner/import ancora da migrare.

---

## Strategia branch

| Branch | Ruolo |
|--------|--------|
| `main` | Produzione Diving + Apnea + Snorkeling (Watch + iOS companion) nello stesso workspace |
| `main-iOS` | Worktree storico divergente; usare solo per review manuali o port selettivi verso `main` |
| `codex/experimental-features` | Esplorazione legacy Watch (Buddy Assist, mockups) — non baseline MAIN |
| `codex/ios-experimental-features` | Esplorazione legacy iOS — non baseline MAIN |

Regole merge: preservare Diving stabile, GPS surface-only, BUSSOLA, export Subsurface, security F1–F12. PR #8/#9: non auto-merge (vedi [`PR_STATUS_20260526.md`](PR_STATUS_20260526.md)).

---

## Limitazioni note

- Non computer subacqueo certificato; planner/Bühlmann **indicativi** (trimix: disclaimer He non in compartimenti Bühlmann).
- CNS/OTU: modello NOAA-style comprehensive ma **reference-only** — non sostituisce computer, tabelle produttore o guida medica.
- Entitlement water submersion: configurato, validazione Ultra reale aperta (R1).
- GPS solo superficie; mappe Watch senza tile online.
- Funzioni experimental non promosse in App Store candidate su `main`.

---

## Riferimenti rapidi

- Indice: [`INDEX.md`](INDEX.md)
- Matrice feature: [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv)
- Build: [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md)
- Roadmap: [`ROADMAP.md`](ROADMAP.md)
