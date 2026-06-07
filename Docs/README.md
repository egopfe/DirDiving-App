# DIR DIVING - watchOS Dive App

Copyright Federico Lombardo di Monte Iato 2026

DIR DIVING is a SwiftUI **watchOS + iOS companion** project (XcodeGen) for Apple Watch Ultra-class devices and iPhone. The stable **`main`** branch delivers **Diving mode** on Watch (depth, ascent awareness, **BUSSOLA**, log, GPS surface entry/exit, Subsurface CSV) plus the iOS companion (logbook, planner, equipment, analysis, sync). Snorkeling, Apnea, and Buddy Assist live on **experimental** branches only.

**Documentazione italiana (panoramica):** [`Docs/PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md) · **Indice:** [`Docs/INDEX.md`](INDEX.md) · **Baseline:** `main` = `origin/main` @ **`a69bc4b`**. Run `xcodegen generate` before Xcode.

## Safety and limitations (MAIN)

Disclaimer completo: [`Docs/SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) · TestFlight: [`Docs/TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) · Roadmap: [`Docs/ROADMAP.md`](ROADMAP.md)

DIR DIVING is a **support and logging tool**: it records dives, surfaces ascent awareness, and syncs to the iPhone companion for review and **indicative** planning. It is **not** a certified dive computer unless a future release explicitly documents certification. It does **not** replace training, dive-center rules, certified equipment, or human judgment. Planner and Bühlmann-style presentations are **indicative** — verify with certified tools. GPS is meaningful **at the surface**; underwater or poor-sky conditions mean fixes can be missing — missing data must not be read as “dive success.”

## Build and generated project policy

- Run `xcodegen generate` before opening/building `DIRDiving.xcodeproj`.
- Do not manually edit generated `.xcodeproj` contents.
- Regenerate after every `project.yml` change.
- Run `./Scripts/validate_main_release_readiness.sh` before release.
- Full workflow: [`Docs/BUILD_AND_XCODEGEN_WORKFLOW.md`](BUILD_AND_XCODEGEN_WORKFLOW.md).

### Stato corrente (`main` = `origin/main`, 2026-06-07)

| Pass | Commit | Contenuto |
|------|--------|-----------|
| **Deep code audit remediation** | `a69bc4b` | MAIN-AUD-001…016 — signed sync ACK, HMAC photo management, cloud oversize guard, PDF protection, planner debounce, replay cache — [`Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md) |
| **Docs / branch alignment** | docs pass | INDEX, README, CSV, ROADMAP, branch policy @ `a69bc4b` — [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) |
| **Watch photo transfer + management** | `fc311be` → `90dc3f5` | Manual send (non auto on pick), iOS manage/delete sheet, Watch→iOS ACK, Watch staging fix before WCSession returns, EN/IT `watch_photo.*` — [`Docs/DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md), [`Docs/DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_IMAGE_FULL_MANAGEMENT_IMPLEMENTATION_REPORT_20260605.md) |
| **Docs / branch alignment (prior)** | 2026-06-06 | [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md) — **superseded for HEAD baseline** by 2026-06-07 report |
| **MAIN UI/UX readiness 100%** | `c8f91f6` | Audit W-UX/I-UX/X-UX P0–P3: Live scroll, legal i18n, Policy A edit, DEMO badge, iCloud conflicts, Crown hint — [`Docs/MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) |
| Watch MAIN algorithmic readiness 100% | `f654bec` | Audit WMATH-HIGH → INFO-014 — [`Docs/WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| iOS MAIN algorithmic readiness 100% | `dce89e7` | Audit B2–B5: pressure/MOD unificato, toggle max/avg depth, cloud merge per sessione, CSV metadata, demo Analysis isolation — [`Docs/IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| iOS comprehensive CNS/OTU + Bühlmann readiness | `dae29b8` | NOAA single/daily CNS, surface/air-break recovery, REPEX OTU, snapshot v2 oxygen carryover, P1–P4 readiness — [`Docs/DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) |
| iOS Bühlmann UX/UI readiness | `3237262` | Fix P1–P3 UX planner; verdict **Ready** — [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md) |
| iOS Bühlmann reaudit algorithm | `69e69b2` | Fix P1–P3 algoritmo — [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) |
| iOS Bühlmann ZHL-16C engine | corrente | Reference N2+He multigas — [`Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) |
| Audit/docs alignment | `ab398eb` | Report readiness aggiornato, riferimenti audit coerenti, documentazione MAIN/experimental riallineata |
| v10 | `2322145` | Watch: pulsante **Start Dive** in superficie senza disattivare l'avvio automatico; iOS: riferimento pianificazione max/media e refresh input planner/Bühlmann allineati |
| Mission Mode | `9d8baa1` | Profilo runtime/UI immersione attiva + indicatore minimale; nessuna regressione safety-critical |
| Algorithm hardening | `ddaf2d7` → `92e639a` | Pipeline depth validata, lifecycle automatico, TTV/time-weighted avg, haptic coordinator, XCTest `DIRDiving Watch Algorithm Tests`; vedi [`Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) |
| Watch algorithm final hardening | corrente | Cap logbook 40 sessioni su load/reload, temperature bounds, export vuoto bloccato, policy GPS fallback, conversioni centralizzate; vedi [`Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) |
| iOS algorithm hardening | corrente | Validatori iOS centralizzati, planner/gas/NDL safe states, import/export/sync/logbook hardening, test `DIRDiving iOS Algorithm Tests`; vedi [`Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) |
| iOS Buhlmann multigas assessment | `37e4464` | Assessment MAIN iOS pre-implementazione: identificava supporto Buhlmann multigas/helium incompleto e piano per motore ZHL-16C+GF+He; vedi [`Docs/DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) |
| iOS Buhlmann ZHL-16C multigas engine | corrente | Motore iOS-only ZHL-16C N2+He con Air/Nitrox/Trimix/Heliox, GF Low/High, NDL tissue-state, gas switch e stop da ceiling; reference-only/non certificato. Vedi [`Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md), [`Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md). |
| Docs alignment | pass 2026-05-19 | README, INDEX, matrice CSV, branch strategy, audit delta; vedi [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) |

**Pass documentale (2026-06-07):** Allineamento architettura MAIN + matrice CSV + branch strategy @ `a69bc4b` — [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md). **Pass precedente (2026-06-06):** @ `90dc3f5` — [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md) (superseded for HEAD). **Algorithmic + UI/UX readiness 100% (codice)** @ `c8f91f6`. **QA fisica** Ultra, coppia iPhone/Watch signed sync/photo auth, external Bühlmann validation, App Store assets ancora **PENDING** — [`Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md).

**Recent Watch algorithm pass (2026-05-31):** WMATH-HIGH-001 → INFO-014; Watch + iOS sync XCTest verde su simulatori; vedi [`Docs/WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md).

**Recent iOS algorithm pass (`dce89e7`):** risoluzione audit B2–B5; **154/154** algorithm tests (1 skipped) on iPhone 17 sim; vedi [`Docs/IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md).

**Prior pass (`dae29b8`):** comprehensive NOAA CNS/OTU; Bühlmann readiness P1–P4; 119 XCTest baseline before expanded suite.

**Recent MAIN UI/UX pass (`3237262`):** repetitive planning visibility, schedule gas ledger, environment copy, result headers, CNS/OTU disclaimers — presentation layer; algorithm expanded @ `dae29b8`.

**Watch UX baseline (2026-05-20):** ascent over-limit shows a **red inline banner** on the live dive screen (non-blocking); depth, gauge, TTV, and controls stay visible. Details: [`Docs/WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md).

> Status note: the app is prepared for Apple water submersion APIs, but the depth/submersion entitlement is still pending. Until the entitlement is granted and the app is signed with it, `CMWaterSubmersionManager` may report entitlement-related errors and will not deliver production depth data.

## Onboarding legale e accettazione disclaimer

Dal pass del **2026-05-22** DIR DIVING mostra un flusso obbligatorio al primo avvio, o quando cambia la major version/revisione legale dell'app:

1. **Welcome**: introduce il flusso safety/legal.
2. **Safety Warning**: mostra in modo esplicito `DIR Diving is NOT a dive computer.`
3. **Legal Disclaimer**: carica il disclaimer completo localizzato da `LegalDisclaimer.txt` in `en.lproj` o `it.lproj`, derivato dai DOCX legali approvati.
4. **Acceptance**: richiede tutte le conferme obbligatorie prima di entrare nell'app.

L'accettazione viene salvata in `UserDefaults` con timestamp, versione app accettata, major version, tipo dispositivo, lingua e revisione legale. La sezione **Settings -> Legal & Safety** / **Altro -> Legal & Safety** permette di rivedere disclaimer completo, versione accettata e timestamp. Questo gating non modifica telemetry, GPS, bussola, profondita, risalita, sync, export o modelli dati immersione.

## Pass production readiness (2026-05-23, `main`)

### Commit `5e595ee` — sync, i18n, build

Miglioramenti **senza** modificare algoritmi immersione, GPS, bussola, TTV, planner math o modello crittografico sync:

- Build: nomi prodotto interni `DIRDivingWatchApp` / `DIRDivingiOSApp` (nome utente **DIR DIVING** invariato in Info.plist).
- Sync: **invio sessioni iPhone → Watch**, coda outbound, tracciamento ID inviati; card **conflitti sync** in Altro (Usa Watch / Mantieni iPhone).
- UX Watch: salto automatico Mode Selection quando esiste solo Diving; tab **User Images** nascosta se bundle vuoto; badge aptica disattivata anche in pre-immersione.
- i18n: Settings Watch, pannello manuale live, More, Planner, errori import CSV; banner risalita EN **ASCENT TOO FAST** / **SLOW DOWN**.
- Sicurezza UX: toggle riconoscimento planner indicativo prima di **Calcola Piano**.

### Commit `6cda004` — limiti profondità operativi (Watch)

- Stati UI **35 / 38 / 40 m** con banner, haptic throttled e flag log `exceededSupportedDepthRange`.
- Onboarding: checkbox obbligatoria sui limiti operativi documentati Apple; revisione legale **`2026-05-23`**.
- Checklist QA: [`Docs/DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md).

### Pass MAIN readiness 100% (2026-05-23, UX — solo UI/i18n)

Senza modifiche a GPS, BUSSOLA, calcoli profondità/risalita, TTV, planner/Bühlmann/gas math:

- **Import CSV** sempre raggiungibile da Logbook e Altro (`CSVImportPanel`).
- **Planner**: tab risultato PIANO / BUHLMANN / GRAFICI mostrano sezioni distinte; solo modalità **Avanzato** attiva (altre disabilitate, pianificate).
- **Watch Settings**: riga Export solo informativa (export reale da Log immersioni).
- **iOS unità**: sezione metrico-only onesta in Altro.
- **Onboarding legale**: scroll obbligatorio sul disclaimer prima di Continue.
- **Log Watch**: elimina con icona cestino + conferma (no `contextMenu` deprecato).

Report: [`Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) · Audit UX: [`Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) · TestFlight esterno: [`Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md).

### Pass MAIN readiness ~94% (2026-05-24, build + i18n + copy)

Senza modifiche ad algoritmi, sync logic o UI graphics:

- **Build:** fix compile Watch (`AscentRateSettingsView`, `DiveLogListView`); simulator Watch + iOS green.
- **Copy/i18n:** planner metric notice; Equipment/Planner EN/IT; settings Watch sync scope; device QA checklists App Intents e sync.

Indice: [`Docs/INDEX.md`](INDEX.md) · Report: [`Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) · QA device: [`Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md), [`Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md).

### Pass note sviluppo branch MAIN (`f851b61`, 2026-05-24)

Implementazione di [`Docs/DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) — wiring UI e sync; **nessuna** modifica ad algoritmi GPS, **BUSSOLA**, profondità/risalita, decompressione o TTV business. Lo storage canonico resta metrico; le unità imperiali sono di **presentazione** e export CSV Subsurface resta in metri.

| Area | Contenuto |
|------|-----------|
| Unità | Picker metrico/imperiale Watch + iOS; sync bidirezionale `units` via `WatchConnectivity` `applicationContext` |
| Disclaimer | Overlay companion a **ogni** cold launch (IT/EN), oltre onboarding legale |
| Allarmi Watch | Default soglia tempo **30 min**; soglia profondità mostrata in m o ft |
| Brand | `altosinistra.png` in header (`DiveOctopusLogo` / `DIRBrandMark`) |
| iOS | Tab **Planner** prima; immersioni **manuali**; checklist attrezzatura editabile; **foto → Watch**; planner con consenso in cima e campi disabilitati se OFF |

Report implementazione: [`Docs/DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md).

### Pass audit UX e readiness (2026-05-24, `876bcd2` → `bd129ca`)

Serie di commit **solo UI/copy/sync surface/i18n** (nessuna modifica GPS, BUSSOLA, calcoli profondità/risalita/decompressione):

| Commit | Contenuto |
|--------|-----------|
| `876bcd2` | Audit UX: edit immersione manuale iOS, merge metadata sync, rimozione riga mock planner, disclaimer companion persistente, pressioni UI, conflitti sync, scroll legale, allarme 30 min, unità Live/Log Watch, CSV in Analisi |
| `db72dce` | Gauge risalita etichette imperiali (ft/min), catalogo **7 App Shortcuts**, help tasto laterale in Settings, refresh dettaglio dopo edit manuale |
| `62e25d5` | **R2** ack planner persistito (`PlannerSafetyAcknowledgment` + `@AppStorage`); **R3** errori decode iCloud visibili in Altro; **R4** localizzazione Logbook/Dettaglio/Analisi; audit complete readiness 20260520/20260524 |

Report: [`Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) · [`Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md).

**QA esterno ancora aperto (R1):** entitlement water submersion + profondità automatica su Apple Watch Ultra reale — [`Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md).

### Strategia controlli Apple Watch (2026-05-24, `72fa15b`)

DIR DIVING su Apple Watch usa una strategia controlli coerente e review-safe, senza pretendere controlli hardware non supportati:

| Controllo | Policy |
|-----------|--------|
| Digital Crown | Navigazione pagine, scroll e regolazione soglie allarmi/risalita dove presente |
| Touch | Conferma primaria tramite pulsanti a schermo; le azioni distruttive restano confermate |
| App Intents / Action Button | Solo tramite Comandi Rapidi / Action Button quando watchOS espone gli intent supportati |
| Tasto laterale | Controllato dal sistema; DIR DIVING non lo sovrascrive direttamente |
| Immersione attiva | Live resta primaria; BUSSOLA resta raggiungibile; Settings pensate per modifica in superficie |

Dettagli: [`Docs/WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) e convenzioni in [`Docs/WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md).

## Depth Entitlement And Signing Checklist

Local configuration is internally aligned for the Watch target: `project.yml` points `DIRDiving Watch App` at `Config/DIRDiving.entitlements`, `App/Info.plist` declares `WKBackgroundModes` with `underwater-depth`, and the Watch entitlements include `com.apple.developer.coremotion.water-submersion`.

External validation is still required before release:

- On macOS/Xcode, run `xcodegen generate` and build the `DIRDiving Watch App` scheme with the Apple SDK.
- In Apple Developer portal, confirm the App ID `com.egopfe.dirdiving.ios.watch` (Watch, embedded in iOS) has the approved water submersion/depth entitlement and iCloud container `iCloud.com.egopfe.dirdiving`.
- On a real Apple Watch Ultra-class device, confirm automatic depth launch and live `CMWaterSubmersionManager` depth samples; this cannot be validated from Windows or simulator alone.

## Features

- Current, average, and maximum depth
- Water temperature
- RunTime
- TTV-style live value
- Manual stopwatch with Start, Stop, and Reset controls
- Local log of the latest 40 dives
- Local persistence with iCloud Key-Value Store mirroring for dive logs and ascent-rate settings
- Dive profile chart
- CSV export compatible with Subsurface workflows
- Integrated compass screen
- Contextual `SET BEARING` / `CLEAR BEARING` compass action
- On-screen `Start Dive` on Watch surface/live home state, with manual start that coexists with automatic depth-based dive start
- Dynamic ascent-rate gauge with green, yellow, and red zones
- User-configurable ascent-rate limits by depth band
- Red blinking warning and haptic feedback when ascent rate exceeds the current depth-band limit
- GPS entry and exit points captured with a best-effort surface fix
- Automatic WatchConnectivity transfer of saved dive logs to the iOS companion
- Stable pre-water selector for Diving on `main`; Snorkeling, Apnea and Buddy Assist remain isolated to experimental branches
- Local persistence with iCloud Key-Value Store mirroring for dive logs, ascent-rate settings, Watch sync queues and supported iOS companion state
- Custom image screen for bundled reference images, checklists, or static procedures
- iPhone -> Watch image push with validation/resize on iOS and surface-side image viewing before entering an active dive
- First-launch legal onboarding with localized IT/EN full disclaimer and mandatory acceptance logging
- Settings / Legal & Safety screen with accepted version, timestamp, language and full disclaimer
- Mission Mode auto-enable option for active dives only; runtime/UI optimization profile that reduces non-essential visual activity without altering safety-critical monitoring, dive calculations, sensor accuracy, ascent-rate logic, or GPS entry/exit logging, with a minimal active-state icon near the Watch header logo during the dive

Experimental branch documentation is available in [`Docs/EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md).

## Supported Platforms

DIR DIVING e organizzato come progetto XcodeGen multi-target:

- Apple Watch Ultra / watchOS 10+: app principale per Diving mode, bussola, log, GPS entry/exit, export e funzioni sperimentali isolate sui rami dedicati.
- iPhone / iOS 17+: companion app per logbook, dettaglio immersione, planner, risultato piano, analisi, export e sync WatchConnectivity.

Le istruzioni di build sono in [`Docs/BUILD_VALIDATION.md`](BUILD_VALIDATION.md) e in [`Docs/iOS/BUILD_AND_RUN.md`](iOS/BUILD_AND_RUN.md).

## Strategia dei rami (Branch Strategy)

- **`main`**: codice orientato alla stabilità **Diving** su Apple Watch e al companion iOS incluso nello stesso workspace XcodeGen. Le funzioni Apnea, Snorkeling, Buddy Assist e le mappe sperimentali **non** fanno parte del target MAIN (`project.yml` esclude i file sperimentali dal build production). I merge verso `main` devono **preservare** il comportamento Diving, GPS surface-only, **BUSSOLA** (terminologia UI: non usare «COMPASSO»), export Subsurface, sync documentati e onboarding legale.
- **`main-iOS`**: worktree/ramo storico divergente per allineamenti iOS. Non e la fonte di verita per la release candidate MAIN unificata; usare solo per review manuali o port selettivi.
- **`codex/experimental-features`**: Watch sperimentale (Snorkeling Live, mappe waypoint/ritorno, Apnea workflow esteso, Buddy Assist, ecc.). Non importare questi file nel target MAIN senza revisione esplicita.
- **`codex/ios-experimental-features`**: iOS sperimentale (surface Snorkeling/Apnea/Buddy/exploration concepts). Isolato da App Store candidate su `main`.
- **Allineamenti UI-only** su `main`: possono toccare layout, copy, accessibilità e documentazione **senza** modificare algoritmi di decompressione, modello gas, calcoli TTV/TTR/SAC/CNS/OTU, sampling sensori o regole di sync — vedi [`Docs/MAIN_UX_COMPLETION_REPORT.md`](MAIN_UX_COMPLETION_REPORT.md).
- **HEAD `main` consigliato** per release candidate Watch+iOS unificato: **`a69bc4b`**. Baseline funzionale cumulativa: UI/UX code 100% (`8c7d6e6` / `c8f91f6`), deep-code remediation (`a69bc4b`), planner gas (`a36dc23`), sync/input refresh (`d962117`), control strategy (`72fa15b`), Watch photo ACK + management (`fc311be`), iOS photo labels (`90dc3f5`). `main-iOS` resta worktree storico divergente: non riallineare codice senza review dedicata.
- **UI-only / documentazione**: non alterare Diving mode, GPS surface-only, **BUSSOLA** (mai COMPASSO), export Subsurface, sync HMAC, onboarding legale.

### Matrice funzionalità (CSV)

La tabella aggiornata con colonne Area / Branch / App / Mode / Feature / Status / Reachable / UX Complete / Safety Complete / **Algorithm Complete** / **Documentation Complete** / Description / UI Reference / Localization / Notes:

[`Docs/DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv)

**Indice completo documentazione:** [`Docs/INDEX.md`](INDEX.md) — ingresso consigliato, con scheda dedicata a [`Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md) (sezioni A–O).

## Sicurezza e sync (security baseline 2026-05-19)

Audit statico in [`Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) (18 finding: 2 HIGH / 4 MEDIUM / 6 LOW / 6 INFO). Remediation F1–F12 applicate in commit `4136ec0`:

- **Auth pairing**: `WatchSyncAuth.resetPeerTrust()` ripristinato su iOS MAIN; UI di reset associazione Watch ora funzionante.
- **Sync key autoritativa**: algoritmo HMAC `v2 ordered-secrets` documentato con commento `MARK` su entrambi i `WatchSyncAuth.swift` (Watch + iOS). Cambi futuri richiedono bump di `WatchDiveSyncCodec.schemaVersion` + release coordinata.
- **Data Protection**: Watch CSV export ora `[.atomic, .completeFileProtection]` con UUID filename e cleanup 24 h. Pending queue Watch (`dirdiving_watch_pending_sync_sessions.json`) e conflicts iOS (`dirdiving_ios_watch_sync_conflicts.json`) migrati da `UserDefaults` a `Documents/` con `.completeFileProtection`; legacy keys ripulite dopo migrazione one-shot.
- **Replay window**: `WatchDiveSyncCodec.maxIssuedAtSkew` ridotto da **24 h → 1 h** (3 600 s).
- **CSV import**: cap di **10 MB** con nuovo errore `.fileTooLarge`. Bound `maxDiveDurationSeconds / maxDepthMeters / validTemperatureRange / isValidGPS` confermati su MAIN.
- **Naming canonical**: nuove costanti `dirdiving_*` (Keychain service iOS, `Notification.Name`, `AscentRateSettingsStore` key) con read-fallback dal legacy `dirmotion_*`. Nessuna chiave persistita rimossa direttamente.
- **No deterministic fallback**: se `SecRandomCopyBytes` fallisce, il secret locale non viene più derivato in modo deterministico; il flusso fallisce in modo esplicito loggando via `os.Logger` con `privacy:.private`.
- **Signed WatchConnectivity ack**: ack HMAC su `"ack|sessionID|issuedAt"`; iOS calcola e firma il reply, Watch verifica in tempo costante. Mantenuto fallback `status == acknowledged` per build iOS legacy (TODO follow-up: rimuovere quando il floor build sale).
- **Logging**: `print` rimossi da `Services/DiveLogStore.swift` → `os.Logger` con `privacy:.private`. Nessun GPS/session content esposto in console.

**Vincoli mantenuti**: nessuna modifica a GPS, BUSSOLA, calcoli profondità/risalita, decompressione, sampling sensori, formato CSV business (header/ordine colonne) e UI/UX.

> Su `origin/main-iOS` (PR #9 / branch `codex/ios-experimental-features`) restano due regressioni note rispetto a `main`: rimozione di `.completeFileProtection`/cleanup nell'export iOS e rimozione dei bound di import CSV. Vedi sezione *Appendix A* dell'audit. Da bloccare in eventuali merge verso MAIN.

## Pre-release backlog (2026-05-19, UX-H/M/L + SAF-3..SAF-10)

Pass UX/Interaction/Feature Accessibility seguito dall'esecuzione MAIN PRE-RELEASE BACKLOG (vedi audit del 2026-05-19). Vincoli rispettati: nessuna modifica a business logic, decompressione, TTV/TTR, modello gas, regole sync; nessun ridisegno UI/UX; nessun file experimental toccato; terminologia UI invariata (`BUSSOLA`, mai `COMPASSO`).

Nuovi documenti pubblicati su `main` e `main-iOS`:

- [`Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md) — backlog rimanente / item rinviati con motivazione (imperial Watch, GPX/UDDF exporter, per-field cloud merge, side-button capture watchOS, convergenza branch).
- [`Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) — checklist QA eseguibile su Watch Ultra, Watch piccolo, iPhone SE, iPhone Pro Max (HEAD presence, ascent gauge co-visible, GPS banner compatto, alarm acknowledge cooldown, SAF-3/SAF-4, App Intents, haptics matrix, a11y, Dynamic Type).

Backlog Watch (`cbcabf7`, `c685155`, `efa53e4`) **reintegrato su `main`** in commit **`a75a6c3`** (2026-05-20) tramite port manuale — non cherry-pick letterale — preservando security F1–F12 in `WatchSyncService` / `WatchDiveSyncCodec`. Il branch di riferimento **`backup/main-watch-backlog-20260519`** resta per audit storico.

Report implementazione: [`Docs/MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md). Checklist issue: [`Docs/MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md).

Lato `main-iOS`, le due rimanenze (SAF-3 visual + SAF-4 bound CSV più aggressivi) sono già sul ramo come commit `bf4718d`:

- **SAF-3 (iOS)**: `iOSApp/Views/DiveDetailView.swift` aggiunge label + hint accessibilità sul tile *TTV info* e una nota muted *"TTV informativo: derivato da profondità media + runtime; non è un valore decompressivo o time-to-surface."*. Allineato visivamente al Watch (`TTV INFO` in `DiveUI.secondaryText`).
- **SAF-4 (iOS)**: `iOSApp/Services/DiveImportService.swift` restringe i bound CSV ai valori del backlog 2026-05-19: `maxDepthMeters = 200`, `maxDurationSeconds = 28 800` (480 min), `temperatureRange = -2…40 °C`. Le righe fuori range vengono saltate e contate (`ImportSummary.skippedMalformedCount`), il formato CSV business non cambia.

Acceptance state per area:

| Area | Item | Stato su `origin/main` (Watch) | Stato su `origin/main-iOS` (iOS) |
|---|---|---|---|
| UX-H1 / SAF-6 | Tombstone unified key `dirdiving_shared_deleted_session_ids` | **Implemented** (`a75a6c3`) | Implemented |
| UX-H2 | iOS → Watch verified push + Watch consumer | **Implemented** (`a75a6c3`) | Implemented |
| UX-H3 / SAF-1 | Ascent warning + gauge co-visible | **Implemented** (banner inline 2026-05-20) | n/a (Watch-only) |
| UX-H4 / SAF-2 | GPS confirmation compact banner | **Implemented** (`a75a6c3`) | n/a (Watch-only) |
| UX-H5 | Canonical iOS branch (`main-iOS`) documented | Documented | Implemented |
| UX-M1..M13 | UX cluster (ModeSelection, hidden nav, retry, toast, info-rows, units, activation labels, notif perm, planner modes, etc.) | Partial (UserImages hide TODO); Implemented (iOS) | Implemented |
| UX-L1..L9 | LOW cluster (icon copy, units pill, dead code, CLEAR disabled, a11y, Dynamic Type, alarm step, dedupe delete) | Partial + i18n 2026-05-20; Implemented (iOS) | Implemented |
| SAF-3 | TTV semantics clarification | Partial (a11y hint localized) | Implemented (`bf4718d`) |
| SAF-4 | CSV bound tightening | n/a | Implemented (`bf4718d`) |
| SAF-7 | Haptics-off badge pre-dive | **Implemented** (`a75a6c3`) | n/a |
| SAF-8 | Alarm acknowledge with cooldown | **Implemented** (`a75a6c3`) | n/a |
| SAF-9 | Planner safety acknowledgement | n/a | Implemented (`62e25d5`: ack persistito revisione `2026-05-24`; campi disabilitati se OFF) |
| SAF-10 | Per-session sync delivery status | TODO surfaced honestly in Settings/MoreView | TODO surfaced honestly |

Build verification: `xcodegen generate` riesce su entrambi i worktree; `swiftc -parse/-typecheck` di tutti i file toccati passa su iOS 26.5 e watchOS 26.5 SDK. Full `xcodebuild` richiede l'installazione dei platform runtime (Xcode → Settings → Components, oppure `xcodebuild -downloadPlatform iOS` / `xcodebuild -downloadPlatform watchOS`); comandi completi in `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` §0.

## Lingue e internazionalizzazione (i18n)

Da `fadd8a6` + `4cca72e` su `main`:

- **Selettore lingua per app**: `DIRAppLanguage` (Watch) e `DIRIOSAppLanguage` (iOS) in `App/DIRAppLanguage.swift` e `iOSApp/App/DIRIOSAppLanguage.swift`. Tre casi: **`system`**, **`it`** (Italiano), **`en`** (English).
- **Persistenza**: `@AppStorage("dirdiving_app_language")` indipendente su Watch e iPhone (sandbox separati; non sincronizzato cross-device).
- **Locale runtime**: `.environment(\.locale, …)` impostato sulla root `WindowGroup` di entrambe le app.
- **Tabelle stringhe**: `Resources/{en,it}.lproj/Localizable.strings` (Watch) e `iOSApp/Resources/{en,it}.lproj/Localizable.strings` (iOS). Aggiunta più recente: chiavi stabili `tab.*` (Logbook/Analisi/Planner/Attrezzatura/Altro), `logbook.delete.a11y`, `accessibility.command_button.hint`.
- **UI**: picker in Watch `SettingsView` (sezione *Lingua*) e in iOS `MoreView` con disclaimer *"Changing language does not change units, calculations or saved data."*
- **Logbook iOS**: i mesi/intestazioni rispettano `@Environment(\.locale)` invece di forzare `it_IT`.
- **Legal onboarding**: disclaimer completo localizzato in `Resources/{en,it}.lproj/LegalDisclaimer.txt` e `iOSApp/Resources/{en,it}.lproj/LegalDisclaimer.txt`; la lingua segue il selettore app o la lingua di sistema supportata.
- **Estensibilità**: per aggiungere una lingua bastano (a) un nuovo case negli enum `DIRAppLanguage`/`DIRIOSAppLanguage`, (b) una nuova cartella `xx.lproj/Localizable.strings`, (c) eventualmente estendere la fallback `supportedSystemLocale` (oggi `en`/`it`; altri sistemi cadono in italiano).
- **Vincoli**: la modifica della lingua **non** cambia unità di misura, calcoli, persistenza o dati salvati.
- **Pass secondario 2026-05-20**: ~130+ chiavi Watch e ~90+ iOS in `Localizable.strings`; servizi sync/bussola/allarmi localizzati con `String(localized:)`; schermate Settings, log, export, planner header, Analysis empty state coperte. Stato messaggi sync: si aggiorna al prossimo evento dopo cambio lingua.
- **Debito residuo**: alcune righe planner risultato, dettaglio GPS (`Start:`/`Accuratezza:`), warning dinamici del planner store, import CSV runtime (`DiveImportService` ancora IT hardcoded). Migrazione progressiva verso String Catalog `.xcstrings` opzionale.
- **TestFlight / sicurezza**: [`Docs/TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md), [`Docs/SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md), [`Docs/ROADMAP.md`](ROADMAP.md).

## Visual Design Standard

DIR DIVING uses the supplied Apple Watch Ultra dive-computer screenshot as its product visual baseline.

Future screens and feature work should preserve this look and feel:

- Apple Watch Ultra titanium case framing with a dark underwater bubbles background in presentation material
- Full black watch-first screen canvas for maximum underwater contrast
- Oversized white current-depth value, with the blue `m` unit aligned on the baseline
- Blue labels for water, temperature, depth, and technical measurement context
- Green immersion state, TTV panel, and safe action styling
- Yellow stopwatch panel, orange/yellow ascent caution zones, and red stop/danger states
- Thin rounded borders around operational panels and action controls
- Compact vertical spacing matching the supplied reference screenshot
- SwiftUI-drawn octopus logo at the top left of the live screen, matching the supplied reference instead of relying on emoji rendering
- Dedicated depth and ascent-gauge columns on the live screen so values, labels, and the colored ascent bar never overlap
- No generic dashboard cards, decorative gradients, or marketing-style layouts inside the watch UI

This premium visual system is now applied across the watch UI, not only the live dive screen:

- `DiveLiveView`: primary dive computer screen with octopus logo, depth, TTV, RunTime, separated ascent gauge, stopwatch, and controls
- `CompassView`: black full-screen compass surface with large heading, bearing panel, and bordered controls
- `AscentRateSettingsView`: custom ascent-limit controls with color-coded depth bands
- `ModeSelectionView`: stable Diving selector using the same black technical panels; experimental modes are excluded from MAIN target membership
- `DiveLogListView` and `DiveDetailView`: log, detail, chart, GPS, and CSV export screens using the same metric panels and command buttons
- `UserImagesView`: bundled image selector with the same black canvas and bordered action controls

### iOS Companion Visual Alignment

Il companion iOS stabile segue `iOS_look_feel.png` come riferimento master. Le schermate principali usano sfondo nero, pannelli charcoal, accento ciano, tabbar scura e numeri tecnici leggibili:

- `LogbookView`: titolo Logbook, ricerca scura, lista immersioni a card, thumbnail e tabbar con attivo ciano.
- `DiveDetailView`: tab riepilogo/grafici/dettagli, immagine sito, griglia metriche, grafico profondita ciano, gas card ed export.
- `PlannerView`: titolo Planner, controllo segmentato modalita, input profilo, gas card con bordo neon e pulsante `Calcola Piano`.
- `PlanResultView`: tab piano/curva/grafici, griglia riepilogo, tabella piano risalita e curva Bühlmann in pannello scuro.
- `AnalysisView`: metriche logbook reali, SAC medio, distribuzione gas, **riepilogo route GPS** da entry/exit dei log (nessun motore mappe esterno).
- `EquipmentView`: profilo attrezzatura persistente, checklist e SAC pianificazione.
- `MoreView` / `Settings`: onboarding operativo, preferenze locali unita/export, stato Watch sync, cloud backup, retry sync, conflitti Watch, tombstone iCloud KVS e note Subsurface.

Questi allineamenti sono UI-only: non cambiano calcoli planner, sync, persistenza, data flow, navigazione o modelli.

### Stable UX / Accessibility Corrections

Gli ultimi fix sulla superficie stable separano chiaramente `main` dalle funzioni sperimentali:

- Apple Watch `main` espone solo il flusso stabile Diving, bussola, settings, immagini e log.
- Apnea, Snorkeling e Buddy Assist restano documentati e isolati nei rami experimental.
- La schermata `Settings` Watch e raggiungibile dalla navigazione principale e collega limiti risalita, allarmi persistenti, info device/batteria, stato GPS, stato sensore profondita, stato sync e preferenza haptic.
- La bussola Watch usa azioni esplicite `SET BEARING` e `CLEAR`, senza promettere un callback del tasto laterale non controllato dall'app.
- Le conferme GPS entry/exit sono mostrate dal lifecycle immersione e non usano coordinate finte quando il fix non e disponibile.
- L'export Watch dalla lista esporta l'ultima immersione e mostra share/error feedback.
- Il companion iOS stabile espone **cinque tab** (ordine da sinistra): **`Planner`**, `Logbook`, `Analisi`, `Attrezzatura`, `Altro`; dati reali o etichettati come informativi/locali.
- Il planner iOS mostra disclaimer in-app e separa i tab risultato `PIANO`, `CURVA BÜHLMANN` e `GRAFICI`.
- Il progetto MAIN esclude Apnea, Snorkeling, Buddy Assist e concept experimental dal target membership generato da XcodeGen.
- L'onboarding legale usa lo stesso linguaggio visivo premium: Watch con pannelli neri, testo grande e controlli glove-friendly; iOS con card scure, accenti ciano/giallo/rosso e dark mode forzato.

Implementation helpers live in:

```text
Views/DiveUIComponents.swift
```

The visual reference image is stored at:

```text
Docs/ReferenceLookAndFeel.jpg
```

The current code preview is stored at:

```text
Docs/LiveDiveImmersionPremiumPreview.png
```

## Project Structure

```text
App/        watchOS app entry point and Info.plist
Config/     entitlements file
iOSApp/     iOS companion app, services, views, assets and entitlements
Models/     dive sessions, samples, GPS points, ascent status
Services/   dive, GPS, compass, haptics, export, image loading, App Intents
Utils/      formatting helpers
Views/      SwiftUI screens and components
Resources/  asset catalogs and bundled user resources
```

The project is configured with XcodeGen through `project.yml`.

## iCloud Persistence

The watchOS app persists user data locally and mirrors supported data to iCloud Key-Value Store when the app is signed with the iCloud capability.

Persisted data:

- Latest dive log sessions.
- User-configurable ascent-rate limits.
- Pending WatchConnectivity session queue for unsent Watch logs.
- iOS companion profile/planner/equipment data where available.
- Deleted iOS log tombstones, so KVS reloads do not silently restore removed sessions.

Implementation:

- `Services/CloudSyncStore.swift`
- `Services/DiveLogStore.swift`
- `Services/AscentRateSettingsStore.swift`
- `Config/DIRDiving.entitlements`

Runtime note: iCloud sync requires the Apple Developer iCloud capability and the configured iCloud container to be enabled for the app identifier. Without the entitlement/capability at signing time, data is still saved locally.

On the experimental branches, Snorkeling/Apnea exploration state and lightweight sync queue status are also mirrored where implemented. Secure Buddy authentication keys remain in Keychain and are intentionally not mirrored through iCloud Key-Value Store.

## Main Navigation

DIR DIVING uses a vertical page-based `TabView`, designed for Apple Watch navigation with the Digital Crown.

Main screens on `main`:

1. Mode selector screen
2. Live dive screen
3. Compass screen
4. Settings screen
5. User images screen (sempre in navigazione **fuori** immersione attiva; v9)
6. Dive log screen

The compass is implemented as a full screen, not as a modal feature that must be launched. Bearing actions are contextual to the compass screen.

Terminologia UI: nelle schermate italiane nuove usare `BUSSOLA`; non introdurre `COMPASSO`.

Experimental Apnea, Snorkeling and Buddy Assist screens are intentionally not part of `main` navigation or MAIN target membership. They remain in `codex/experimental-features` until hardware, UX, safety and build validation are complete.

## Live Dive Screen

The live screen shows:

- Current depth
- Maximum depth
- Average depth
- Water temperature, when available
- RunTime
- TTV value
- Manual stopwatch value
- Ascent-rate gauge
- Warning state when ascent rate is over limit

RunTime is controlled automatically by the dive session. The manual stopwatch is independent and can be started, stopped, or reset by the user.

## Ascent-Rate Limits

The ascent-rate limit changes according to current depth. The default profile is:

| Depth band | Limit |
| --- | ---: |
| 40-30 m | 10 m/min |
| 30-20 m | 5 m/min |
| 20-6 m | 3 m/min |
| 6-0 m | 1 m/min |
| Outside configured bands | 10 m/min |

The fallback limit of `10 m/min` outside the configured bands is intentional.

The `ASC SET` screen lets the diver customize each limit directly on Apple Watch:

- `40-30 m`
- `30-20 m`
- `20-6 m`
- `6-0 m`
- `Other`

Values are stored locally with `UserDefaults`, persist across app launches, and can be restored with `RESET STD`.

The app computes ascent rate by comparing consecutive depth samples. When depth decreases, DIR DIVING converts the difference into meters per minute.

## Warning and Haptics

When ascent rate exceeds the active limit:

- The ascent gauge enters the red zone
- The live depth warning state blinks in red
- Apple Watch plays `.failure` haptic feedback
- Haptic feedback is throttled to at most one warning every 2 seconds

The warning is intentionally kept inside the main live UI instead of using a separate fixed bottom banner.

## Compass

The compass screen uses `CoreLocation` and `CLHeading` to show:

- Current heading in degrees
- Cardinal direction
- Saved bearing
- Bearing clear action

Actions:

- `SET BEARING` stores the current heading as the active bearing
- `CLEAR` removes the active bearing

Required permission in `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>DIR DIVING uses location to save GPS entry and exit points.</string>
```

## Manual Stopwatch and App Intents

The on-screen stopwatch controls are:

- `START`: starts the manual stopwatch
- `STOP`: pauses the manual stopwatch
- `RESET`: returns the stopwatch to `00:00`

The project also includes two App Intents:

- `ToggleStopwatchIntent`: starts or stops the manual stopwatch
- `ResetStopwatchIntent`: resets the manual stopwatch

These intents are intended for Action Button or shortcut-style workflows where watchOS exposes them. Apple does not provide a public API for arbitrary long-press handling of the physical side button or Action Button inside a watchOS app, so the reset action remains available through the UI and through the dedicated intent.

## Automatic GPS Entry and Exit Points

DIR DIVING records surface GPS metadata for the beginning and end of a dive.

### Entry Point

When the watch enters submersion mode:

1. The app immediately stores the latest available GPS point.
2. It starts a best-effort GPS capture window.
3. If a better fix arrives within the capture window, the entry point is updated.
4. If no better fix arrives, the app keeps the latest available point.

This design reflects the fact that GPS is not reliable underwater. Entry position should be captured at the surface or immediately before descent.

### Exit Point

When the watch leaves submersion mode:

1. The app immediately stores the latest available GPS point.
2. It starts a best-effort surface GPS capture window.
3. If a better fix arrives, the exit point is saved with the dive log.
4. If no better fix arrives, the app keeps the latest available point.

The dive log is finalized after the exit best-effort capture completes, so the exported session contains the best available exit point.

### Display and Use

- Entry and exit coordinates are shown in the dive detail screen when available.
- GPS data represents surface entry/exit metadata, not underwater tracking.
- The app keeps location updates active while needed so a recent point is available.

## Dive Log

Dive sessions are stored locally in the app documents directory as JSON. The log keeps the latest 40 sessions and sorts them by start date.

Each saved session includes:

- Start and end date
- Duration
- Maximum depth
- Average depth
- Average, minimum, and maximum water temperature when available
- TTV value
- Entry and exit GPS points when available
- Full depth/temperature sample list

## Buddy Assist

Buddy Assist is experimental-only and is excluded from the current MAIN Watch target. The experimental `BUDDY` screen is designed for quick preset messages between divers:

- `OK`
- `RISALI`
- `HO UN PROBLEMA`
- `DOVE SEI?`
- `TORNA INDIETRO`
- `LOW GAS`

The intended concept is:

```text
Apple Watch <-> BLE <-> Apple Watch
```

Current implementation status:

- Adds the watchOS UI for secure pre-dive pairing, buddy identification, and sending preset messages.
- Stores the paired buddy identity locally after a successful trusted pairing.
- Stores Buddy Assist authentication material in Keychain through `SecureBuddyStore`.
- Requires manual confirmation of a shared pairing code before messages are enabled.
- Sends Buddy Assist messages as authenticated JSON envelopes with HMAC-SHA256, session, timestamp, and sequence checks.
- Rejects unauthenticated, stale, repeated, or non-secure Buddy Assist messages.
- Blocks pairing while `DiveManager.isDiveActive` is true.
- Cancels an active pairing scan if a dive starts before pairing completes.
- Adds an `OpenBuddyAssistIntent` so the Buddy Assist page can be opened from an Action Button or shortcut-style workflow when watchOS exposes it.
- Shows the mandatory safety warning: `Indicazione di prossimità sperimentale non affidabile per sicurezza immersione.`
- Shows the mandatory pairing warning: `Pairing solo prima dell'immersione. Non effettuare pairing in immersione.`
- Shows an experimental proximity dot:
  - green when RSSI suggests the buddy is near;
  - yellow when RSSI suggests the buddy is around the distant / mid-range zone;
  - red when no buddy link is available.
- Adds Buddy Link status with `ONLINE` / `LOST`.
- Adds haptic patterns for proximity changes:
  - slow pulse when the buddy is distant;
  - rapid double pulse when the buddy is near.
- Adds a compass block with last known direction, shared bearing, current heading, and an estimated `Direzione plausibile`.
- Reads buddy RSSI every 15 seconds while connected.
- Adds a `BuddyAssistService` with CoreBluetooth central-side scaffolding.
- Defines a custom BLE service UUID and message characteristic UUID.
- Adds the required Bluetooth privacy usage string only on branches where the experimental Buddy/BLE surface is target-included.
- Adds `Security.framework` for Keychain-backed trusted buddy keys.
- Uses the shared premium visual system from `DiveUIComponents.swift`, with black canvas, thin status borders, large readable values, and blue/green/yellow/red functional colors.

Operational rule: Buddy pairing must be completed before entering the water. DIR DIVING intentionally disables pairing while a dive is active and cancels any in-progress pairing scan when a dive starts, because pairing underwater is not a safe or reliable setup workflow.

Important limitation: Apple documents that watchOS apps cannot advertise BLE peripheral services with `CBPeripheralManager`. A true direct Watch-to-Watch BLE pairing architecture is therefore not currently reliable as a production-only Apple Watch implementation. A production path may require a companion device, an external BLE relay, or a revised architecture validated on Apple hardware.

## Subsurface CSV Export

The dive detail screen can generate and share a CSV file for Subsurface-style import workflows.

Workflow:

1. Open the dive log.
2. Select a dive.
3. Tap `ESPORTA (SUBSURFACE)` on Watch detail or `Genera CSV Subsurface` on iOS detail.
4. Tap the share button / `Condividi CSV` and send the CSV to iPhone, Mac, Files, AirDrop, or email.
5. In Subsurface, open `File > Import > Import log files > CSV`.
6. Map the columns:
   - `time_seconds` = elapsed time in seconds
   - `depth_m` = depth in meters
   - `temperature_c` = water temperature in degrees Celsius

The CSV also includes entry and exit latitude/longitude columns when available.

The Watch log list also exposes `ESPORTA ULTIMA (SUBSURFACE)` for the latest saved dive and shows error feedback when no dive can be exported.

## User Images

Su **`main` @ `d962117`**, la tab **Immagini** è sempre presente quando non si è in immersione attiva (stato vuoto con istruzioni sync da iPhone). Durante l'immersione restano disponibili solo Live e BUSSOLA. Le foto inviate da iOS passano validazione/resize (`WatchPhotoPreprocessor`) con avviso IT/EN se la conversione riduce la leggibilità.

DIR DIVING includes a `Screens` view for bundled static images and companion-synced photos. This is useful for:

- Dive checklists
- Personal procedures
- Reference tables
- Static reminders
- High-contrast underwater-readable notes

### Adding Images

watchOS standalone apps cannot directly read arbitrary files from a PC or Mac filesystem. DIR DIVING therefore loads images that are bundled with the app.

To add images:

1. Prepare `PNG`, `JPG`, `JPEG`, or `HEIC` images.
2. Use dimensions matching, or proportional to, the target Apple Watch screen.
3. Copy the images into:

```text
Resources/UserImages/
```

4. Regenerate the Xcode project if using XcodeGen:

```bash
xcodegen generate
```

5. Build and install the app on Apple Watch.
6. Open DIR DIVING and navigate to the `Screens` view.

### Recommended Image Style

- Portrait orientation
- Dark background
- Large text
- High contrast
- Minimal fine detail

Saved dives are also transferred to the iOS companion through `WatchConnectivity` when the paired iPhone app is installed and reachable. The watch uses direct messages when possible and queued `transferUserInfo` delivery as a fallback.

## Apple Water Submersion API Compatibility

The dive engine uses:

- `CMWaterSubmersionManager.waterSubmersionAvailable`
- `CMWaterSubmersionManagerDelegate`
- `CMWaterSubmersionEvent`
- `CMWaterSubmersionMeasurement`
- `CMWaterTemperature`
- `manager(_:errorOccurred:)`

Delegate methods are marked `nonisolated` and bridge back to the main actor for Swift concurrency compatibility.

## Build Notes

This repository is intended to be generated and built on macOS with Xcode and XcodeGen.

```bash
xcodegen generate
open DIRDiving.xcodeproj
```

### Un solo progetto Xcode (importante)

- **Apri solo** `DIRDiving.xcodeproj` nella **root** del repository (`DirDiving-App/`), dopo `xcodegen generate`.
- Il file **non è versionato su Git** (si rigenera da `project.yml`). Eventuali copie in `.worktrees/` o cartelle vecchie vanno **eliminate** — non usarle in Xcode.
- **Non** esistono più progetti separati Watch/iOS nel repo: uno workspace XcodeGen con due scheme (`DIRDiving Watch App`, `DIRDiving iOS`).
- Dopo ogni `git pull` che modifica `project.yml`, riesegui `xcodegen generate` prima di aprire Xcode.

Then open the generated Xcode project and build the watchOS target.

Schemes principali generati da `project.yml`:

- `DIRDiving Watch App`
- `DIRDiving iOS`

This environment cannot run a full watchOS `xcodebuild` validation because Xcode and the Apple watchOS SDK are not available here. Final validation should be performed on macOS with the target Apple Watch hardware or simulator configuration.

## MAIN Readiness Notes

Gli ultimi aggiornamenti MAIN readiness aggiungono:

- app icon asset reference validation per Watch e iOS;
- esclusione XcodeGen delle sorgenti experimental dai target MAIN;
- rimozione della privacy string Bluetooth dal Watch MAIN, perche Buddy Assist non e una funzione production visibile;
- allarmi Watch con soglie profondita, tempo e batteria editabili/persistite/applicate;
- haptic feedback per START/STOP/RESET cronometro, rispettando il toggle haptics;
- iOS Watch sync con conflitti visibili e risoluzione manuale;
- tombstone iOS per evitare che log cancellati riappaiano da KVS;
- import CSV iOS, profilo attrezzatura persistente, tab **Analisi** con riepilogo route GPS e metriche logbook basate su dati reali;
- planner iOS con warning dinamici e copy non certificato;
- pulsante Watch **Start Dive** in superficie con coesistenza tra avvio manuale e avvio automatico da profondita;
- Mission Mode Watch con toggle persistente, ottimizzazione runtime/UI solo durante immersione attiva e indicatore minimale vicino al logo header.

Build finale, `xcodegen generate` e `xcodebuild` devono essere eseguiti su macOS.

## Latest MAIN UX Audit Implementation

Dopo il report `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx`, i rami MAIN hanno ricevuto un pass UX mirato e separato dai rami sperimentali:

- Watch MAIN: `Settings`, `AlarmSettings`, `DiveLive` e `DiveLogList` chiariscono metriche/local-only, shortcut/App Intents, avvio manuale, stato log vuoto, export non disponibile senza log e conferma delete.
- Watch MAIN: le soglie allarme restano locali sul Watch, non sincronizzate con iPhone; i controlli +/- sono piu grandi e scrollabili per ridurre clipping e migliorare uso con guanti.
- iOS MAIN: `Settings` marca unita/export come preferenze non editabili o local-only quando non esiste ancora un contratto sync production.
- iOS MAIN: `Logbook`, `Analisi` (route GPS + import/sync), `Planner`, `Attrezzatura` e `Altro` aggiungono empty state o conferme distruttive per import/sync assenti, nessuna rotta, nessuna statistica, delete immersione e reset profilo.
- Non sono stati modificati algoritmi GPS, bussola, profondita, risalita, decompressione, persistenza dati o modelli business; il pass e UI/UX e copy-only salvo conferme SwiftUI.

## Latest MAIN UX Audit And Documentation TODO

Il report pre-modifica MAIN piu recente e:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx
```

Stato documentato dopo l'audit:

- Le superfici principali MAIN sono raggiungibili: Apple Watch `Diving`, `BUSSOLA`, settings, immagini, log/export; iOS `Logbook`, `Analisi`, `Planner`, `Attrezzatura`, `Altro` (cinque tab; route GPS in **Analisi**).
- Risolti nel pass MAIN UX: empty state iOS principali, conferme delete/reset, spiegazione Action Button/App Intents, copy di avvio manuale, settings iOS marcati read-only/local-only dove appropriato e controlli allarme Watch piu grandi.
- Restano TODO di allineamento sync: settings Watch/iOS sono dichiarati local-only e la policy cloud conflict oltre KVS resta roadmap.
- Restano TODO build/config da verificare su macOS: l'asset catalog iOS MAIN deve contenere i PNG citati da `AppIcon.appiconset/Contents.json`; `xcodegen generate` e le build Watch/iOS devono confermare i fix runtime piu recenti.
- L'audit resta snapshot pre-modifica; i fix MAIN UX successivi sono committati separatamente dalla documentazione.

## Entitlement Status

The entitlements file currently exists at:

```text
Config/DIRDiving.entitlements
```

Il file entitlements Watch include la chiave `com.apple.developer.coremotion.water-submersion`, coerente con `WKBackgroundModes` / `underwater-depth` in `App/Info.plist` e con `CODE_SIGN_ENTITLEMENTS: Config/DIRDiving.entitlements` in `project.yml`.

Questa configurazione non equivale a validazione release: prima di TestFlight/App Store serve confermare in Apple Developer portal che l'App ID **`com.egopfe.dirdiving.ios.watch`** (Watch embedded in **`com.egopfe.dirdiving.ios`**) abbia l'entitlement water submersion approvato, poi generare/buildare con Xcode su macOS e validare su Apple Watch Ultra reale. L'ID legacy `com.egopfe.dirdiving` non va usato per install embedded.

## Branch Strategy

Panoramica italiana estesa: [`Docs/PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md).

La strategia branch corrente e:

- `main`: codice stabile @ **`a69bc4b`**, orientato alla produzione Apple Watch + companion iOS nello stesso workspace, con Diving mode preservato come funzione primaria.
- `main-iOS`: ramo/worktree storico divergente, utile per review manuali ma non canonico per la candidata release MAIN.
- `codex/experimental-features`: ramo Apple Watch per UI e funzioni sperimentali Snorkeling, Apnea, Buddy Assist e schermate future.
- `codex/ios-experimental-features`: ramo iOS per companion UI, pianificazione, mappe, enrichment POI e superfici sperimentali.

Regole operative:

- Il lavoro di allineamento UI-only non deve modificare business logic, calcoli immersione, GPS, algoritmi bussola, persistenza o state machine.
- Ogni merge verso `main` deve preservare Diving mode, schermata live, warning risalita, haptic behavior, GPS entry/exit e log immersioni.
- `main` non deve esporre Apnea, Snorkeling, Buddy Assist o placeholder sperimentali come flussi production. `main-iOS` non va trattato come baseline runtime implicita.
- Le funzioni sperimentali restano isolate finche non sono validate su hardware, build XcodeGen e test manuali.
- In caso di conflitto, preservare prima codice buildabile e comportamento Diving stabile, poi la UI master reference piu recente, poi gli aggiornamenti documentali.

## Platform And Build Matrix

| Branch | App | Stato | Note |
| --- | --- | --- | --- |
| `main` | Apple Watch | Stable | Diving mode, log, export, BUSSOLA, immagini, settings raggiungibili, allarmi/haptic persistenti, GPS entry/exit confirmation, sync queue, helper shortcut/App Intents, empty state log e target membership senza experimental. |
| `codex/experimental-features` | Apple Watch | Experimental | Snorkeling Live, Mappa Waypoint, Mappa Ritorno, Direzione Waypoint, POI con log/dettaglio/conferma, allarmi Snorkeling persistenti locali, Apnea, haptics sperimentali, settings sperimentali raggiungibili e Buddy Assist marcato lab-only. |
| `main` | iOS Companion | Stable | Planner, Logbook, Analisi, Attrezzatura, Altro; legal onboarding, planner safety acknowledgment, import/export CSV, sync Watch, iCloud KVS, manual dive add/edit, photo push to Watch e superfici legali dedicate. |
| `main-iOS` | iOS Companion | Historical / divergent | Worktree storico con documentazione e runtime da confrontare manualmente prima di qualsiasi port verso `main`. Non considerarlo la baseline release corrente. |
| `codex/ios-experimental-features` | iOS Companion | Experimental | Explore Lab, route planning, waypoint management, POI enrichment mock/TODO, Apnea Review interattiva, queue/status sync sperimentale, impostazioni locali editabili e note map/offline. |

## Mode Selection

La selezione modalita su Apple Watch separa:

- `Diving` su `main`: dive computer principale con profondita, TTV, RunTime, cronometro, gauge risalita, warning, bussola, settings, immagini e log.
- `Snorkeling` su experimental: navigazione superficie con waypoint, ritorno al punto di partenza, marker/POI e mappe leggere.
- `Apnea` su experimental: timer apnea, recovery assistant, counter e warning sperimentali.

Le modalita condividono il design system nero/neon, ma non devono condividere logiche safety in modo implicito.

## UI Master References

Le UI Apple Watch devono seguire `Docs/ReferenceUI/Watch_LIVE_reference.png` come riferimento canonico per densita, gerarchia, colore e bordo. Le UI iOS devono seguire `Docs/ReferenceUI/iOS_Companion_reference.png`.

Riferimenti recenti per iOS main:

- `ios_logbook_reference.png`
- `ios_dive_detail_reference.png`
- `ios_planner_reference.png`
- `ios_plan_result_reference.png`

Riferimenti recenti per Snorkeling sperimentale:

- `01_snorkeling_live_final.png`
- `02_Mappa_Waypoint_reference.png`
- `03_Mappa_Ritorno_reference.png`
- `04_Direzione_Waypoint_reference.png`
- `05_Log_Marcatori_POI_AppleWatch_reference.png`
- `06_Dettaglio_Marcatore_POI_AppleWatch_reference.png`
- `08_Allarmi_Snorkeling_reference.png`

## Feature Matrix

La matrice feature aggiornata e in:

```text
Docs/DIR_DIVING_Feature_Comparison.csv
```

La specifica Snorkeling sperimentale e in:

```text
Docs/SNORKELING_EXPERIMENTAL_SPEC.md
```

La specifica Apnea sperimentale e in:

```text
Docs/APNEA_EXPERIMENTAL_SPEC.md
```

## Snorkeling Experimental Notes

Snorkeling su Apple Watch experimental include:

- Live screen con runtime, distanza, velocita media, profondita attuale e GPS status.
- Mappa Waypoint separata dalla Mappa Ritorno.
- Direzione Waypoint come funzione compass-style verso il waypoint, non bussola generica.
- `BUSSOLA` come terminologia obbligatoria; non usare `COMPASSO`.
- `MARCATORE` come quick-capture POI leggero con conferma, haptic, payload timestamp/GPS/profondita/temperatura/bearing/waypoint/sessione quando disponibili e stato `Da arricchire su iPhone`.
- Log Marcatori e Dettaglio POI raggiungibili da Watch, con metadata, stato enrichment e chiara boundary di sync verso iPhone.
- Allarmi snorkeling specifici, separati dai settings globali, persistiti localmente con `AppStorage` in attesa di uno store dedicato.
- Schermate raggiungibili per Calibrazione Bussola e Legenda Icone Mappe senza modificare algoritmi bussola o motore mappe.

Il Watch non modifica foto/commenti POI. Il companion iOS espone una superficie di enrichment per foto, video, commenti, categorie, tag e note osservazione, ma media upload/save e sync reale restano marcati come TODO sperimentali.

## Apnea Experimental Notes

Apnea su Apple Watch experimental include:

- Home Apnea dal selettore modalita.
- Menu con `Sessione`, `Tabelle`, `Statistiche` e `Logbook`.
- Sessione `Acque Libere`, configurazione locale persistente per intervallo superficie e profondita massima allarme, countdown `03`, `02`, `01 / VAI` con haptic tick e surface waiting.
- Avvio automatico immersione da profondita e chiusura automatica al ritorno in superficie usando `ExplorationStore`.
- Stati visuali per discesa, fondo, risalita, allarme risalita, superficie, recovery, riepilogo, grafico, dettagli e salvataggio.
- Logbook e statistiche Apnea con dati reali dove esposti e placeholder TODO dove mancano campioni, HR, temperatura o aggregati.
- Pannelli espliciti per `Watch -> iPhone Apnea` e settings sync, senza introdurre una nuova architettura WatchConnectivity.

Il companion iOS experimental aggiunge `Apnea Review` in `ExplorationCenterView` con tab interattivi `Riepilogo`, `Grafico` e `Dettagli`, profilo mock e metriche placeholder finche non esiste sincronizzazione record Apnea dedicata.

## Latest Experimental UX Audit Fixes

Il documento Word dell'audit e conservato in `Docs/EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx`. Gli ultimi fix implementati sui rami sperimentali aggiungono:

- Watch Snorkeling: conferma `MARCATORE SALVATO`, haptic, log marcatori, dettaglio marcatore, GPS unavailable state, settings Snorkeling, allarmi persistenti locali, calibrazione Bussola e legenda mappe.
- Watch Apnea: configurazione locale persistente, allarmi raggiungibili, haptic countdown/start/save/recovery, azioni esplicite su riepilogo/grafico/dettagli/salvataggio e boundary sync dichiarate.
- iOS Experimental Explore Lab: sezioni Snorkeling Review, POI/Osservazioni, Waypoint Planning, Apnea Review e Experimental Settings; POI enrichment mock, manifest route/settings per Watch e note MBTiles/MapLibre/OpenSeaMap.
- Tutte le funzioni non production-ready sono etichettate come `Mock`, `TODO`, `Non ancora sincronizzato` o `Sync sperimentale` per evitare false promesse UX.

### Latest Experimental Blocker Resolution

Dopo il report `Docs/EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx`, i rami sperimentali hanno ricevuto un pass di contenimento UX senza modificare algoritmi GPS, bussola, profondita, risalita o decompressione:

- Watch experimental: `SettingsView`, `AlarmSettingsView`, `AscentRateSettingsView` e `InfoView` sono raggiungibili dalla navigazione sperimentale; le preferenze locali espongono unita metriche, haptics, Always-On safe, soglie generali e limiti risalita.
- Watch Snorkeling: la sessione si avvia visibilmente, le soglie profondita/tempo/distanza sono enforce locali con haptic warning, la batteria resta indicata come non cablata, e i pannelli POI mostrano stato queue/delivery experimental.
- Watch Apnea: profondita non disponibile mostra `--`; HR, batteria e temperatura non usano piu valori finti ma `HR OFF`, `BAT --`, `TEMP --`; profilo/statistiche restano chiaramente schematiche o TODO.
- Watch Buddy Assist: il flusso e marcato `LAB-ONLY` e disabilitato finche l'architettura BLE/relay Watch non e validata.
- iOS Experimental: Planner result e export sono marcati `PIANO LAB` / `EXPORT LAB`; Logbook e Dive Detail non mostrano piu affordance statiche come azioni reali; More espone impostazioni locali per unita, CSV export, diagnostica sync e gate safety mock.
- iOS Explore Lab: route/settings manifest usano una coda locale sperimentale visibile con conteggio, stato e revisione manuale; il receiver iOS mostra il numero di payload experimental ricevuti e lo stato import, senza promettere merge production.

## Known Limitations

- GPS e affidabile solo in superficie; sott'acqua usare ultimo fix valido e contesto bussola/waypoint come supporto informativo.
- Le mappe Watch sono leggere e SwiftUI-only; non scaricano tile online.
- OpenStreetMap public tile server non devono essere usati hard-coded per traffico production pesante.
- OpenSeaMap, GEBCO, EMODnet e MBTiles restano roadmap/future layer; il companion iOS mostra solo stato/TODO e non include ancora un motore MapLibre reale.
- Apnea e Snorkeling experimental non sono dispositivi certificati di sicurezza.
- Buddy Assist resta sperimentale, lab-only e limitato dalle policy watchOS BLE.
- Watch -> iPhone POI, Watch -> iPhone Apnea, iPhone -> Watch route/waypoint/settings, duplicate prevention e offline queue hanno stato/queue UX sperimentale; non sono ancora una pipeline production completa.

## Roadmap

- Validare build XcodeGen su macOS per ogni ramo.
- Evolvere POI Watch e Apnea sync da queue/status sperimentale a pipeline persistente con ACK, retry, duplicate prevention e merge iOS.
- Migrare gli allarmi Snorkeling da `AppStorage` locale a store dedicato quando il contratto dati sara stabile.
- Collegare record Apnea Watch a review iOS senza simulare campioni profilo non ancora disponibili.
- Introdurre workflow MapLibre/OpenSeaMap/MBTiles sul companion iOS dopo valutazione licenze e prestazioni.
- Aggiungere report test hardware Apple Watch Ultra per Diving, Snorkeling e Apnea.
- Preparare export e documentazione Subsurface piu completa per import CSV.
- **i18n**: completare migrazione stringhe alle tabelle `Localizable.strings` (o `.xcstrings`); valutare unificazione `DIRAppLanguage` / `DIRIOSAppLanguage` in un modulo condiviso; eventuale sync preferenza lingua via WatchConnectivity.

## Aggiornamento pre-release 2026-05-18

Il pass piu recente mantiene MAIN e sperimentale separati e documenta i blocker corretti senza promuovere Apnea, Snorkeling o Buddy Assist in produzione:

- Watch MAIN: `WatchSyncAuth` non dipende piu da `SecureBuddyStore`, che resta escluso dal target MAIN per evitare leakage Buddy/BLE.
- Watch MAIN: le conferme GPS distinguono successo, ultimo punto noto e nessun fix; il GPS resta surface-only e non viene documentato come tracking subacqueo.
- Watch MAIN: l'avviso risalita conserva profondita corrente e RunTime durante l'allarme; la logica di calcolo risalita non e stata modificata.
- Watch MAIN: quando l'aptica e disattivata, la live UI mostra `APTICA DISATTIVATA` e `AVVISI SOLO VISIVI`.
- iOS MAIN: sync Watch senza peer secret resta `Associazione Watch non verificata`; nessuna fallback key deterministica viene trattata come fidata.
- iOS MAIN: import CSV preserva la data sorgente quando presente, usa ID deterministico da hash per evitare duplicati e mostra risultato import/duplicati/errori.
- iOS MAIN: la tab **Analisi** include riepilogo route GPS, import CSV, sync Watch e empty state con azioni reali; le cinque tab companion sono Logbook / Analisi / Planner / Attrezzatura / Altro.
- iOS MAIN: Planner usa solo modalita semplice come comportamento attivo, marca modalita avanzate/tecniche come planned, valida input e richiede acknowledgement safety.
- iOS MAIN: conversioni unita restano display-only; dati salvati, planner, import/export CSV e sync Watch restano metrici.

Restano obbligatori: build `xcodegen generate` / Xcode su macOS, test Apple Watch Ultra reale, validazione entitlement depth nel Developer portal e QA su import/export, sync, cloud KVS e schermate piccole.

## Aggiornamento documentazione 2026-05-19

- Aggiunti: [`Docs/BUILD_VALIDATION.md`](BUILD_VALIDATION.md), [`Docs/GLOSSARY.md`](GLOSSARY.md), [`Docs/RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md), [`Docs/UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md), [`CHANGELOG.md`](CHANGELOG.md), [`CONTRIBUTING.md`](CONTRIBUTING.md), report di sync [`Docs/DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md), allineamento [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md).
- Riferimenti visivi consolidati in `Docs/ReferenceUI/` (Watch live + iOS companion).
- Matrice CSV aggiornata in coda (righe additive) per tab iOS a cinque voci e documentazione build.
- PR **#8** e **#9**: al fetch risultano ancora **`mergeable: CONFLICTING`** — **non** mergeate automaticamente; vedi [`Docs/PR_STATUS_20260524.md`](PR_STATUS_20260524.md) e [`Docs/DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md).

## Aggiornamento documentazione 2026-05-24 (post-readiness `bd129ca`)

- Baseline `main` @ **`bd129ca`**: merge documentale + commit `62e25d5` (R2–R4), `db72dce`, `876bcd2`.
- README, [`CHANGELOG.md`](CHANGELOG.md), [`Docs/ROADMAP.md`](ROADMAP.md), matrice [`Docs/DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv), [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md).
- **Onboarding:** flusso legale + disclaimer companion revisionato (`CompanionDisclaimerAcceptance` `2026-05-24`) + checkbox limiti profondità `2026-05-23`.
- **Modalità:** Diving su `main`; Snorkeling (Live, Mappa Waypoint, Mappa Ritorno, ritorno ingresso, POI) e Apnea su `codex/experimental-features` — vedi [`Docs/SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md), [`Docs/APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md).
- **i18n:** pass R4 su Logbook/Dettaglio/Analisi; debito Planner/Equipment/alcuni messaggi runtime — vedi sezione Lingue sopra.
- **Nota Watch post-`3b7358b`:** lista log mostra profondità max in `m` fisso (regressione display unità rispetto a `db72dce`); storage e export restano metrici — TODO QA se ripristinare `WatchDepthFormatting` in lista.

## Aggiornamento documentazione 2026-05-25 (`ab398eb`)

- `main` confermato come baseline stabile Watch+iOS; `main-iOS` documentato come worktree storico divergente e non come branch release canonico.
- Documenti correnti allineati: README, INDEX, ROADMAP, safety/release/TestFlight notes, UX conventions, audit correnti e matrice feature CSV.
- Audit/readiness correnti aggiornati per riflettere i fix repo-side gia chiusi: legal links dedicati, wording entitlement onesto, localizzazione BUSSOLA/planner, recent sync activity, safeguard reset cronometro.
- Nuovi report di processo: [`Docs/DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md), [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md), [`Docs/PR_STATUS_20260525.md`](PR_STATUS_20260525.md).

## Aggiornamento documentazione 2026-05-26

- Baseline commit corrente verificata: `main` @ `2322145`; working tree locale con ulteriori aggiornamenti documentali e Mission Mode Watch.
- README, indice documentazione, roadmap, note safety/release/TestFlight e audit correnti riallineati al MAIN attuale: `Start Dive` visibile in superficie, immagini visibili fuori immersione attiva, Mission Mode e relativo indicatore minimale.
- Nuovi report di processo: [`Docs/DOCUMENTATION_UPDATE_REPORT_20260526.md`](DOCUMENTATION_UPDATE_REPORT_20260526.md), [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md), [`Docs/PR_STATUS_20260526.md`](PR_STATUS_20260526.md).

## Aggiornamento documentazione 2026-05-27

- Baseline verificata prima del pass: `main` @ `37e4464`; branch locali tracciati allineati ai rispettivi remoti (`main`, `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`).
- Documentazione MAIN riallineata a legal onboarding, warning profondita 35/38/40 m, banner risalita inline, overlay GPS compatti, App Intents/Action Button via Shortcuts, Side Button system-controlled, sync Watch <-> iPhone, push iPhone -> Watch, tombstone, edit manuale, planner safety acknowledgement, User Images conditional visibility e mode auto-skip.
- Stato algoritmico documentato al 2026-05-27: Watch MAIN release-hard/final hardening, iOS MAIN algorithm hardening, e assessment iOS Buhlmann multigas/helium pre-implementazione.
- Nuovi report di processo: [`Docs/DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md), [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md), [`Docs/PR_STATUS_20260527.md`](PR_STATUS_20260527.md).
- PR #8 e #9 controllate con `gh`: entrambe aperte, experimental e non safe-to-merge automaticamente; #8 alterna `UNKNOWN` / `CONFLICTING`, #9 risulta `CONFLICTING`.

## Aggiornamento documentazione 2026-05-29 (`69e69b2`)

- Baseline: `main` @ `69e69b2`, allineato a `origin/main` — fix reaudit Bühlmann P1–P3; XCTest iOS verde su macOS.
- **Audit UX/UI planner iOS:** [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) — verdict *Partially ready*; gap UI (repetitive planning, ledger per cilindro, copy ambiente) indicizzato in [`Docs/INDEX.md`](INDEX.md) §1, §4, §6, §13.
- Re-audit math risolto: [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) + [`Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md).

## Aggiornamento documentazione 2026-05-29 (`570964e`)

- Baseline: `main` @ `570964e`, allineato a `origin/main` dopo sync remoto (hardening Watch/iOS, motore Buhlmann, golden fixtures, reaudit).
- Indicizzati audit in root: [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md).
- Indicizzati in `Docs/`: [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md); aggiornato [`Docs/INDEX.md`](INDEX.md).

## Aggiornamento iOS Buhlmann 2026-05-28

- Implementato motore iOS-only Buhlmann ZHL-16C N2+He sotto `iOSApp/Algorithms/Buhlmann/`, integrato nel planner companion senza modificare Watch, watchOS, UI premium o branch sperimentali.
- Supporto reference-only per Air, Nitrox, Trimix, Heliox, travel/bottom/deco gas, GF Low/High, NDL tissue-state, gas switch e stop generati da ceiling.
- Aggiunta verifica matematica dedicata: [`Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md).
- Hardening successivo: validazione gas sull'intero segmento respirato, separazione TTS/runtime, gas-switch dwell modellato nei tessuti, seed di stato tessutale per profili ripetitivi/reference e cross-check esterno a tolleranza larga in [`Docs/DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md).
- Re-audit statico post-implementazione: [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) — motore non più placeholder-only; P1/P2 residui prima di claim release-hard.
- Validazione locale eseguita in modalita Windows static analysis; build `xcodegen`/`xcodebuild` e XCTest completi restano da eseguire su macOS.

## Aggiornamento documentazione 2026-05-20 (post v9 `d962117`)

- Baseline codice: v8 planner gas (`a36dc23`), v9 Watch surface images + planner sync (`d962117`).
- Aggiunti/aggiornati: [`Docs/PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md), [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md), [`Docs/PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md), matrice CSV (righe v8/v9), README, INDEX, CHANGELOG, ROADMAP.
- PR #8/#9: non merge automatico; vedi report PR post-v9.

## Aggiornamento documentazione 2026-05-24 (control strategy `72fa15b`)

- Aggiunta documentazione strategia controlli Watch: Crown, touch, App Intents / Action Button, tasto laterale system-controlled, haptics e navigazione sott'acqua.
- Aggiornati README, CHANGELOG, ROADMAP, matrice feature CSV/XLSX e report [`Docs/DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md).
- PR #8 e #9 restano non safe-to-merge senza review manuale, build macOS e QA Diving/BUSSOLA/GPS surface-only.

## Aggiornamento documentazione e audit post-fix 2026-05-18

Il report post-fix pre-modifica corrente e stato aggiunto in:

```text
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md
Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx
```

Stato documentale corrente:

- Apple Watch MAIN include ora delete visibile da `DiveDetailView`, diagnostica depth entitlement/sensore/callback in `Info`, coda sync con retry/clear, metadata GPS fix/fallback/no-fix, stato UserImages vuoto e note export/units local-only.
- iOS MAIN include Logbook con mesi dinamici; **Analisi** con route GPS, import CSV, sync Watch e azioni empty state; reset/re-pair trust Watch; stato autorizzazione notifiche; policy cloud visibile; CSV parser con campi quotati e feedback `importate/duplicati/righe saltate`; feedback `Salvato` su Attrezzatura.
- La matrice `Docs/DIR_DIVING_Feature_Comparison.csv` separa Apple Watch Main, Apple Watch Experimental, iOS Main e iOS Experimental.
- Le PR sperimentali aperte (#8 e #9) risultano conflittuali e con build check falliti; non sono considerate safe-to-merge finche non passano build macOS, review target membership e QA safety.

Aggiornamento runtime MAIN 2026-05-18 20:22:

- Watch MAIN: il blocker `AscentWarningView` -> `Formatters.zero` e stato corretto aggiungendo il formatter zero-decimal Watch senza modificare `time` o `one`.
- Watch MAIN: la coda WatchConnectivity ora distingue `pending`, `sent`, `delivered/acknowledged`, `failed` e last retry; i pending non vengono rimossi prima dell'ack diretto iPhone.
- Watch MAIN: il label `TTV` resta visibile, ma la documentazione/UI lo descrive come metrica informativa derivata da profondita media e runtime, non come NDL/TTS/decompressione.
- Watch MAIN: l'opzione imperiale e non selezionabile finche la conversione Watch non e implementata; export resta metrico/Subsurface.
- iOS MAIN: il blocker `PlannerView.swift` / `ResultPanelStyle` / `PlanTab` e stato corretto mantenendo `PlanTab` a file scope.
- iOS MAIN: CSV import valida durata, profondita, temperatura e range GPS, continua a gestire campi quotati e riporta importati, duplicati e righe malformate/scartate.
- iOS MAIN: detail/analysis non mostrano piu SAC, temperatura o accuratezza GPS mancanti come zero misurati; usano `—` o `Non disponibile`.
- iOS MAIN: export CSV include il GPS fix source entry/exit; Settings mostra una preview merge cloud locale/cloud/risultato senza promettere conflict resolver per-campo.
- `Views/AscentGaugeView.swift` su Watch MAIN puo apparire modificato senza diff contenutistico per line endings; non va incluso in commit funzionali se resta stat-only.
