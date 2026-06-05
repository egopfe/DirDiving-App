# DIR DIVING — Indice documentazione (`Docs/`)

**Aggiornato:** 2026-06-05
**Branch consigliato:** `main` = `origin/main`
**Uso:** punto di ingresso per ripartire a lavorare sul progetto.
**Panoramica funzioni (IT):** [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md)

---

## Aggiornamento indice 2026-06-05 — Watch photo transfer audit (iOS → Watch)

Audit statico sul percorso **invio foto iPhone → Apple Watch** (`PhotosPicker` → `WatchPhotoPreprocessor` → `WCSession.transferFile` → `UserImageStore` → `UserImagesView`). Nessuna modifica codice nel report; QA runtime richiede macOS + coppia iPhone/Watch o simulatori.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) |
| **Percorso** | `Docs/DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md` |
| **Data audit** | 2026-06-05 |
| **Branch / commit auditato** | `main` @ `ca76a19` |
| **Modalità** | Static audit, report-only |
| **Verdetto** | Architettura core **corretta**; gap UX su conferma ricezione/import su Watch |
| **File chiave** | `WatchPhotoTransferPanel.swift`, `WatchPhotoPreprocessor.swift`, `WatchSyncService.swift` (iOS), `UserImageStore.swift`, `UserImagesView.swift`, `WatchCompanionPhotoValidator.swift` |

### Issues (Executive Summary)

| ID | Sev | Titolo |
|----|-----|--------|
| 1 | Medium | iOS segnala successo prima della prova di ricezione Watch |
| 2 | Medium | Nessun acknowledgement Watch → iOS post-import foto |
| 3 | Medium | `WCSessionFileTransfer` completion non tracciata su iOS |
| 4 | Low | Possibile collisione filename `companion_<timestamp>.jpg` |
| 5 | Low | Layout galleria Watch da verificare su 41 / 45 / 49 mm |

### Piano remediation (fasi report)

| Fase | Obiettivo |
|------|-----------|
| 1 | Acknowledgement import foto Watch → iOS |
| 2 | Stati transfer file su iOS (queued / delivered / failed) |
| 3 | Filename UUID al posto del timestamp |
| 4 | Messaggi iOS distinti (queued vs received) |
| 5 | Polish UX galleria Watch (`UserImagesView`, page dots, highlight nuova foto) |
| 6 | Test mirati preprocessor / validator / import |
| 7 | QA macOS/device (JPEG, PNG, HEIC, panorama, connettività) |

**Release recommendation:** feature **directionally correct**; non dichiarare fully verified senza QA device/simulator.

### Implementazione remediation (2026-06-05)

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) |
| **Percorso** | `Docs/DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md` |
| **Stato** | Implementato su `main` — ACK Watch→iOS, lifecycle transfer iOS, UUID filename, status localizzati, dedup import, page dots, tap-to-fullscreen in `UserImagesView`, test |
| **Build/test** | iOS + Watch build ✅; `CompanionPhotoTransferPipelineTests` 7/7; `CompanionPhotoImportSupportTests` 7/7 |
| **QA residua** | Coppia fisica iPhone/Watch; connettività disabilitata/ripristinata; 41 / 45 / 49 mm |

### Piano opzioni cancellazione immagini Watch (2026-06-05)

Piano **plan-only** per eliminare le immagini caricate su Apple Watch (nessuna modifica codice nel documento). Baseline: `main` @ `aa5a5c3` (fullscreen `UserImagesView`).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) |
| **Percorso** | `Docs/DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt` |
| **Data** | 2026-06-05 |
| **Modalità** | Plan-only (Opzione 1 consigliata prima; Opzione 2 iOS companion dopo) |
| **Gap attuale** | Nessuna delete singola / clear-all; bundle `UserImages` non cancellabile |
| **File chiave** | `UserImageStore.swift`, `UserImagesView.swift`, `WatchSyncService.swift` (se Opzione 2), `WatchSyncKeys.swift` |

| Opzione | Obiettivo | Priorità |
|---------|-----------|----------|
| **1** | Delete su Watch (trash + conferma in detail; solo `Documents/UserImages`) | **Implementare per prima** |
| **2** | Delete richiesta da iOS Companion con ACK Watch (`companionPhotoDeleteRequest` / `companionPhotoDeleteAck`) | Dopo Opzione 1, se serve gestione bulk da iPhone |

**Acceptance (Opzione 1):** immagine upload sparisce subito dalla lista; empty state se ultima; asset bundle intatti; send foto + ACK + fullscreen invariati.

---

## Aggiornamento indice 2026-06-04 - consolidamento `.md` in `Docs/`

Tutti i file Markdown che erano nella root del repository sono stati spostati in `Docs/` per avere un unico punto documentale. Nessun file codice, asset, modello, servizio o configurazione Xcode e stato modificato in questo pass.

| Documento | Nuova posizione | Nota |
|-----------|-----------------|------|
| [`README.md`](README.md) | `Docs/` | Ingresso documentale del progetto |
| [`CHANGELOG.md`](CHANGELOG.md) | `Docs/` | Cronologia modifiche |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | `Docs/` | Regole contribuzione |
| [`DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`](DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md) | `Docs/` | Audit Watch UI/UX/testo 2026-06-04 |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico Watch post-hardening |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico iOS Companion |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit UX/UI planner Buhlmann |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md) | `Docs/` | Verifica fix UX/UI Buhlmann |
| [`DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md`](DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md) | `Docs/` | Report readiness finale |
| [`DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md`](DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md) | `Docs/` | Audit grafica/testo |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md) | `Docs/` | Audit security current |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md) | `Docs/` | Report remediation security |
| [`DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md`](DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md) | `Docs/` | Audit security/exploit 2026-06-04 — piano remediation P1–P3 (vedi sezione dedicata sotto) |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) | `Docs/` | Audit transfer foto iOS → Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) | `Docs/` | Implementazione remediation transfer foto iOS → Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |
| [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) | `Docs/` | Piano opzioni delete immagini Watch 2026-06-05 — vedi sezione indice 2026-06-05 sopra |

---

## Aggiornamento indice 2026-06-04 — Security exploit audit & remediation plan

Audit statico **security / exploitability** su branch `main` @ `d2ad45b`. Report + piano remediation only (build/test non eseguiti sull’host audit Windows; comandi macOS in § finale del report).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md`](DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md) |
| **Percorso** | `Docs/DIR_DIVING_SECURITY_EXPLOIT_AUDIT_AND_REMEDIATION_PLAN_20260604.md` |
| **Data** | 2026-06-04 |
| **Commit audit** | `d2ad45b` |
| **Modalità** | Static audit, report-only |
| **P0** | Nessuno |
| **Verdetto** | Parziale — fix **P1** prima di TestFlight/App Store esterno |

### Controlli positivi (Executive Summary)

- HMAC-SHA256 su payload Watch↔iPhone; sync bounded (size, schema, bundle ID, skew).
- Keychain `AfterFirstUnlockThisDeviceOnly`; CSV import bounded; export `.completeFileProtection`.
- Nessun client rete arbitrario evidente nei path MAIN auditati; secret scan regex senza secret in sorgente.

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| — | Executive Summary | Controlli forti; rischi trust-boundary / privacy / safety-integrity / repo hygiene |
| — | Scope | Watch + iOS MAIN, WCSession, Keychain, iCloud KVS, CSV, foto, legal gate, App Intents, CI |
| — | Severity Model | P0–P3 + INFO |
| — | Findings | `SEC-P1-001` … `SEC-P3-002` (dettaglio sotto) |
| — | Remediation Roadmap | Phase 1–4 (P1 release-blocking → docs/privacy) |
| — | Suggested Implementation Order | Ordine 1–8 per ID finding |
| — | Proposed Tests | Watch / iOS / repo-CI |
| — | macOS Validation Commands | `xcodegen`, build Watch/iOS, algorithm tests |
| — | Physical QA Requirements | Ultra, Action Button, WCSession, iCloud, foto, legal revision |
| — | Final Verdict | No P0; P1 blocca release “security-hard” |

### Indice findings (priorità)

| ID | Sev | Area | File / evidenza principale |
|----|-----|------|----------------------------|
| **SEC-P1-001** | P1 | App Intents bypass legal onboarding | `ActionButtonIntents.swift`, `DIRDivingApp.swift`, `DiveManager.swift` → gate `LegalAcceptanceGate` |
| **SEC-P1-002** | P1 | Simulation sensor in release | `SensorSourceMode.swift`, `SensorProviderFactory.swift`, `DeveloperVersionUnlock.swift`, `InfoView` / `MoreView` |
| **SEC-P1-003** | P1 | iCloud KVS backup automatico log sensibili | `CloudSyncStore`, `DiveLogStore` (iOS), opt-in default off |
| **SEC-P2-001** | P2 | Peer secret overwrite da application context | `WatchSyncAuth.swift` (Watch + iOS), TOFU pinning |
| **SEC-P2-002** | P2 | Foto Watch senza decode/validazione contenuto | `UserImageStore.swift`, `WatchPhotoPreprocessor`, `WatchSyncService` |
| **SEC-P2-003** | P2 | ZIP tracciato bypass secret scan | `DirDiving-All-Branches-*.zip`, `Scripts/check_secrets.sh` |
| **SEC-P3-001** | P3 | Watch ACK verifier parità iOS | `WatchDiveSyncCodec` / ACK legacy `"acknowledged"` |
| **SEC-P3-002** | P3 | GitHub Actions least-privilege | `.github/workflows/build.yml` → `permissions: contents: read` |

### Roadmap remediation (Phase 1–4)

| Phase | Priorità | Task principali |
|-------|----------|-----------------|
| **1** | P1 | Legal gate App Intents; sensor `.automatic` in release; cloud backup opt-in |
| **2** | P2 | Peer-secret TOFU; ACK guard Watch; test sync |
| **3** | P2–P3 | Validazione immagine Watch; rimozione ZIP da repo; CI permissions |
| **4** | P2 | Privacy docs, TestFlight notes, security checklist, QA App Intents |

### Ordine implementazione suggerito (report § Suggested Implementation Order)

1. `SEC-P1-001` → 2. `SEC-P1-002` → 3. `SEC-P1-003` → 4. `SEC-P2-001` → 5. `SEC-P2-002` → 6. `SEC-P2-003` → 7. `SEC-P3-001` → 8. `SEC-P3-002`

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_AUDIT_CURRENT.md) | Audit security precedente (baseline storica) |
| [`MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md`](MAIN_BRANCH_FULL_CODE_SECURITY_REMEDIATION_REPORT.md) | Report remediation security storico |
| [`SECURITY_STATIC_CHECKLIST.md`](SECURITY_STATIC_CHECKLIST.md) | Checklist statica release |
| [`SECURITY_PRIVACY_RELEASE_EVIDENCE.md`](SECURITY_PRIVACY_RELEASE_EVIDENCE.md) | Evidenze privacy/release |
| [`Scripts/check_secrets.sh`](../Scripts/check_secrets.sh) | Secret scan (ZIP esclusi — vedi SEC-P2-003) |
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Note reviewer (simulation/cloud policy) |

**Commit doc su `main`:** `40bf110` (`docs: add security exploit remediation plan`).  
**Remediation implementata:** [`DIR_DIVING_SECURITY_REMEDIATION_REPORT_20260604.md`](DIR_DIVING_SECURITY_REMEDIATION_REPORT_20260604.md) — SEC-P1–P3 chiusi in codice/repo.

---

## Aggiornamento indice 2026-06-04 — iOS Bühlmann comprehensive readiness audit (updated)

Audit statico read-only su **iOS Companion MAIN — Planner only** (`DIRDiving iOS`). Nessuna modifica codice; report-only (host audit Windows: `xcodegen`/`xcodebuild` non eseguiti).

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) |
| **Percorso** | `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md` |
| **Data** | 2026-06-04 |
| **Commit doc** | `63ee0b4` (`docs: add updated iOS Buhlmann readiness audit`) |
| **Baseline audit** | `40bf110` (pre-report; post-security plan doc) |
| **Scope** | Motore ZHL-16C N2+He, planner services, CNS/OTU, UX/UI planner, test/docs |
| **Modalità** | Static audit only |
| **Verdetto** | **Partially ready** — core Bühlmann + CNS 15% rule forti; **OTU constant-depth formula** bloccante |

### Relazione con audit precedenti

| Documento | Relazione |
|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive @ `e1370f7` (2026-05-30) — verdict *Almost Ready*; **baseline storica** |
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | Implementazione P1–P4 + CNS/OTU @ `dae29b8` — da ri-validare dopo fix OTU |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | §11 oxygen exposure — allineare formula OTU dopo fix |
| [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) | Campagna validazione esterna (P1 pending) |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti reference-only planner |

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| — | Executive Verdict | *Partially ready*; blocker OTU inverted constant-depth |
| — | Scope Confirmation | iOS MAIN planner only; Watch/experimental esclusi |
| — | Repository State | `main`, `40bf110`, Windows static |
| — | Files Inspected | Engine, planner services, views, tests, l10n |
| — | Buhlmann Mathematical Model Assessment | ZHL-16C, GF, NDL, multigas, trimix |
| — | CNS / OTU / 15% Rule Assessment | CNS full plan + descent+bottom 15% warning; **OTU correctness** |
| — | Algorithmic Consistency Assessment | Validation, gas planning, result states |
| — | Numerical Robustness Assessment | Edge cases, OTU formula |
| — | UX/UI Readiness Assessment | Planner discoverability, safety copy |
| — | CNS UI/UX Visibility Matrix | Tabella visibilità CNS/OTU in UI |
| — | Test Coverage Assessment | Gap test OTU vs riferimento indipendente |
| — | Documentation Assessment | Docs OTU da correggere con codice |
| — | Risk Matrix | P0–P4 findings |
| — | Release Readiness Verdict | OTU not ready; Bühlmann core largely coherent |
| — | Implementation Plan | Phase 1–5 (OTU fix → macOS validation) |
| — | Protected Files / Areas | Watch + experimental iOS esclusi |
| — | Recommended Next Cursor / Codex Command | Prompt fix OTU + test (non eseguire automaticamente) |
| — | Final Recommendations | Fix OTU prima di release-hard |
| — | Audit Certification | Report-only, no commit dal audit |

### Indice findings (priorità)

| ID | Sev | Area | Sintesi |
|----|-----|------|---------|
| **OTU inverted** | P0/P1 | Oxygen exposure | `OxygenExposureModels.swift` — formula costante-depth apparentemente invertita; sottostima OTU a PPO2 elevato |
| **External validation** | P1 | Decompression reference | Campagna esterna ancora pending |
| **OTU tests self-referential** | P1 | Tests | Test validano implementazione, non riferimento canonico |
| **Travel gas switch** | P2 | Multigas | Switch depth travel→bottom semplificato |
| **macOS build/test stale** | P2 | Release process | Validazione macOS su HEAD corrente richiesta |
| **Build validation docs stale** | P2 | Documentation | Conteggi test/docs da aggiornare |
| **Hardcoded IT validation** | P3 | Localization | Messaggi validator planner |
| **Persistence key `experimental`** | P3 | Maintainability | Naming chiave planner |
| **Share/export CNS label** | P3 | UX copy | Etichette export generiche |
| **Bailout schedule-only** | P3 | Planning model | Documentato come limite |
| **Physical a11y QA** | P4 | UX validation | Dynamic Type / VoiceOver su device |
| **No exact equivalence claim** | P4 | Legal/docs | Reference-only — OK se esplicito |

### Piano implementazione (Phase 1–5)

| Phase | Focus |
|-------|--------|
| **1** | Correggere formula OTU + test monotonicità / fixture PPO2 0.6–1.6 |
| **2** | Campagna validazione esterna Bühlmann (NDL, stop, TTS, gas switch) |
| **3** | Modello travel gas switch depth |
| **4** | Localization + copy share/export CNS/OTU |
| **5** | `xcodegen`, build iOS, iOS Algorithm Tests su macOS |

**Esclusi da scope:** Apple Watch MAIN, file experimental iOS in `project.yml`, branch experimental.

**Remediation implementata:** [`DIR_DIVING_IOS_BUHLMANN_READINESS_REMEDIATION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_READINESS_REMEDIATION_REPORT.md) — OTU fix, test canonici, switch depth fondo, export CNS, l10n validator.

---

## Aggiornamento indice 2026-06-04 — Watch UI text visibility audit (current)

Audit read-only su **Apple Watch MAIN** (`DIRDiving Watch App` only). Nessuna modifica codice; solo report statico SwiftUI.

| Campo | Valore |
|-------|--------|
| **Documento** | [`DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md`](DIR_DIVING_WATCH_UI_TEXT_VISIBILITY_AUDIT_CURRENT.md) |
| **Data audit** | 2026-06-04 |
| **Branch** | `main` |
| **Target** | `DIRDiving Watch App` |
| **Modalità** | Report-only (build/test non eseguiti) |
| **Readiness testo/UI** | **78%** |
| **Verdetto Settings** | Issue piccolo testo **confermata** (P1); Live Dive **forte** |
| **Benchmark** | Oceanic+, Garmin Descent, watchOS native density |

### Mappa sezioni report

| § | Titolo | Contenuto chiave |
|---|--------|------------------|
| 1 | Executive Summary | 78% readiness; P1 Settings + warning text; P2 secondarie |
| 2 | Scope Confirmed | View incluse/escluse da `project.yml` |
| 3 | Screen-by-Screen Audit | Home, Live Dive, Settings, Alarm/Ascent settings, Compass, Images, Logs, Info, Legal, Banners |
| 4 | Settings Deep Dive | 8 pt badge, 11/10 pt rows, `minimumScaleFactor(0.68)`, target 13/14 pt |
| 5 | Typography Inventory | `DiveUI.Typography.*`, 7–72 pt, `.caption2`, scale factors |
| 6 | Color and Contrast | Palette `DiveUI`, muted/disabled, warning colors |
| 7 | UX Fluidity | TabView, scroll, tap targets 31–44 pt |
| 8 | Benchmark Comparison | Oceanic+ / Garmin / watchOS |
| 9 | Prioritized Remediation Plan | P0 none; P1 Settings + warnings; P2 polish; P3 optional |
| 10 | Acceptance Criteria | Criteri fix futuro (44 pt rows, no micro-text, ecc.) |
| 11 | No-Code-Change Confirmation | Solo questo file creato/aggiornato |
| 12 | Final Verdict | Prossimo pass: UI-only typography/spacing |

### Indice per schermata (severità)

| Schermata | Severità | File principali |
|-----------|----------|-----------------|
| Settings | **P1** | `SettingsView.swift`, `DiveUIComponents.swift` |
| Warning banners / safety | **P1** (testo) / P2 (layout) | `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `DiveLiveView.swift` |
| Live Dive | P2 | `DiveLiveView.swift`, `AscentGaugeView.swift`, … |
| Compass | P2 | `CompassView.swift` |
| User Images | P2 | `UserImagesView.swift`, `UserImageStore.swift` — tap immagine → fullscreen; delete pianificata in [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt); vedi anche photo transfer audit/implementation 2026-06-05 |
| Logs / Dive Detail / Export | P2 | `DiveLogListView.swift`, `DiveDetailView.swift`, `ExportView.swift` |
| Info / diagnostics | P2 | `InfoView.swift` |
| Legal onboarding | P2 | `WatchLegalOnboardingView.swift` |
| Alarm settings | P2 | `AlarmSettingsView.swift` |
| Ascent rate settings | P3 | `AscentRateSettingsView.swift` |
| Mode selection | P3 | `ModeSelectionView.swift` (di solito nascosta in MAIN) |

### Indice remediation P1–P3 (§9)

| ID | Priorità | Azione | File |
|----|----------|--------|------|
| 1 | P1 | Restyle Settings typography/density | `SettingsView.swift`, `DiveUIComponents.swift` |
| 2 | P1 | Warning title/body più grandi | `AscentWarningBannerView.swift`, `DepthSafetyLiveViews.swift`, `DiveLiveView.swift` |
| 3 | P1 | Ridurre copy Settings; dettaglio in Info/Legal | `SettingsView.swift`, `InfoView.swift`, `WatchLegalOnboardingView.swift` |
| 4 | P2 | Eliminare label 7–8 pt secondarie | `DiveDetailView.swift`, `DiveLogListView.swift`, `CompassView.swift`, `UserImagesView.swift`, `InfoView.swift` |
| 5 | P2 | Tap target 40–44 pt | `DiveUIComponents.swift`, `CompassView.swift`, `SettingsView.swift`, `AlarmSettingsView.swift` |
| 6 | P2 | Coordinate/status-first su Watch | `DiveDetailView.swift`, `DiveLogListView.swift` |
| 7–10 | P3 | Header uniformi, stroke, l10n IT, QA Dynamic Type | Vari |

### Documenti correlati

| Documento | Relazione |
|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit **algoritmi** Watch (separato da questo audit **UI/testo**) |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) | Remediation algoritmi @ `39b3d4e` / `ba21813` |
| [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) | Audit UX cross-app (baseline storico) |
| [`DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md`](DIR_DIVING_GRAPHICS_UI_TEXT_AUDIT_CURRENT.md) | Audit grafica/testo (ambito diverso) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Convenzioni UX Watch MAIN |

**Esclusi da scope** (non in target audit): `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, iOS Companion.

---

Remediation completa da audit [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) (83% Watch / 86% iOS / 81% cross-app → **100%** criteri codice; QA fisica ancora richiesta):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md) | `Docs/` | Audit read-only pre-fix (baseline storico @ `02eb9d8`) |
| [`MAIN_UI_UX_READINESS_AUDIT_LONG_PRE_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_LONG_PRE_FIX.md) | `Docs/` | Conferma issue pre-implementazione |
| [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) | `Docs/` | **Report post-fix** — P0–P3 chiusi; Internal TestFlight UI/UX YES |
| [`MAIN_UI_UX_READINESS_QA_ANALYSIS.md`](MAIN_UI_UX_READINESS_QA_ANALYSIS.md) | `Docs/` | QA sintetica build/test + file modificati |

Implementazione: Live Dive scroll/compact banners, legal onboarding i18n, Crown hint, underwater lock toast, Policy A no-depth edit, DEMO badge, iCloud conflict UI, planner team preview, logbook search/swipe-delete, CSV import unificato via `CSVImportPanel`.

---

## Aggiornamento indice 2026-05-31 — Watch MAIN algorithmic readiness 100%

Remediation completa da audit [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) (82% pre-remediation → **100%** criteri codice; QA fisica § L ancora richiesta):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | **Report finale** — WMATH-HIGH/MED/LOW/INFO risolti, XCTest Watch + iOS sync |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | `Docs/` | Policy A: sessioni manuali senza profilo — sync iOS, export disabilitato |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | Audit read-only originale + link al report 100% |

Implementazione runtime Watch: depth silence watchdog, GPS fix/fallback/no-fix, `MonotonicElapsedClock`, blink/haptic indipendenti, gauge/zone alignment, CSV time origin, persistence class, iOS logbook manual no-depth UI.

---

## Aggiornamento indice 2026-05-31 — iOS MAIN algorithmic readiness 100% @ `dce89e7`

Remediation completa da audit [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) (76% @ `4d5aabc` → **100%** criteri codice @ `dce89e7`):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | **Report finale** — B2–B5 risolti, 154/154 XCTest, build locale OK |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | Audit read-only originale + link al report 100% |
| [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md) | `Docs/` | CSV `# session_meta` export/import round-trip |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260531.md) | `Docs/` | Branch strategy + PR #8/#9/#10 @ `1d69d88` |
| [`PR_STATUS_20260531.md`](PR_STATUS_20260531.md) | `Docs/` | Stato PR aperti, CI, raccomandazioni merge |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | `Docs/` | Pressure unificato, planning depth toggle, cloud merge, incomplete calc |
| [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) | `Docs/` | Pass documentale CNS/OTU + readiness 100% |

Implementazione runtime (non Watch experimental): pressure `AmbientPressureModel`, toggle max/avg depth, merge cloud per sessione, CSV metadata, demo isolation Analysis, engine contingencies, **154 XCTest** (1 skipped) iPhone 17 sim.

---

## Aggiornamento indice 2026-05-31 — Watch MAIN algorithm audit (current)

Audit read-only su **Apple Watch MAIN** (`DIRDiving Watch App` only), parallelo a [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | `Docs/` | **Audit corrente Watch MAIN** — pre-remediation ~82%; remediation **100%** codice → [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | `Docs/` | Report finale readiness 100% (codice) + QA fisica § L |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | `Docs/` | Policy sync sessioni manuali senza profilo |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit pre-hardening @ `ddaf2d7` (storico) |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit post-hardening 2026-05-27 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | `Docs/` | Implementazione hardening @ `92e639a` |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | `Docs/` | Final hardening cap log / export / GPS |

Origine: branch [`codex/watch-main-algorithm-audit-current`](https://github.com/egopfe/DirDiving-App/pull/10); file indicizzato su `main` per navigazione. **Non** include Snorkeling, Apnea, Buddy, Exploration Lab (esclusi in `project.yml`).

---

## Aggiornamento indice 2026-05-31 — comprehensive NOAA CNS/OTU + readiness @ `dae29b8`

Implementazione runtime + documentazione allineata (**119/119 XCTest pass**, iPhone 17 sim):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | `Docs/` | P1–P4 + **comprehensive CNS/OTU** — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | `Docs/` | Daily CNS, surface/air-break recovery, REPEX OTU, snapshot v2 carryover |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | `Docs/` | §11 oxygen exposure — NOAA single/daily, recovery, REPEX |
| [`OxygenExposureDeepModelTests.swift`](../Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift) | `Tests/` | 14 test CNS/OTU (decay, daily limits, air-break, carryover) |
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | `Docs/` | Righe algorithm/UX CNS/OTU comprehensive @ `dae29b8` |
| [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) | `Docs/` | Report A–K allineamento documentazione post CNS/OTU |

Relazione: comprehensive readiness @ `f7de936` → implementazione P1–P4 + NOAA CNS/OTU @ `dae29b8`.

---

## Aggiornamento indice 2026-05-29 — comprehensive readiness implementation

Implementazione P1–P4 da [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) (**119/119 XCTest pass** @ `dae29b8`, iPhone 17 sim):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md) | `Docs/` | **Completion report** — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) | `Docs/` | External validation campaign checklist |
| [`DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md`](DIR_DIVING_IOS_PHYSICAL_ACCESSIBILITY_QA.md) | `Docs/` | Physical a11y QA matrix |

---

## Aggiornamento indice 2026-05-30 — comprehensive Bühlmann readiness audit

Pass read-only su `main` @ `e1370f7` (math, consistency, UX/UI, tests, docs; **88/88 XCTest pass**):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | `Docs/` | **Comprehensive readiness audit** @ `e1370f7` — verdict **Almost Ready**; baseline storica |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | `Docs/` | **Audit aggiornato 2026-06-04** @ `63ee0b4` — verdict **Partially ready**; blocker OTU; CNS 15% OK — vedi sezione indice 2026-06-04 sopra |

---

## Aggiornamento indice 2026-05-30 — Phase 15 UX fix + re-audit READY

Pass UX/UI su `main` @ `3237262` (fix P1–P3 presentation; algoritmo invariato @ `69e69b2`; XCTest `BuhlmannUxReadinessTests` verde):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md) | `Docs/` | **Post-fix re-audit** — verdict **READY**; matrice issue originale → SOLVED |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md) | `Docs/` | Verifica implementazione fix UX @ `3237262` |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit originale (2026-05-28) *Partially ready* — **superseded** da re-audit |
| [`DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md`](DIR_DIVING_FINAL_IMPLEMENTATION_AND_READINESS_REPORT.md) | `Docs/` | Report Phase 15 — verdict **READY FOR INTERNAL VALIDATION** |
| [`DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md`](DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md) | `Docs/` | Consistency audit pre-commit Phase 15 |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260530.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260530.md) | `Docs/` | Branch strategy + MAIN capabilities @ `3237262` |

Relazione: reaudit math → fix @ `69e69b2` → UX audit gaps → fix @ `3237262` → re-audit **READY**.

---

## Aggiornamento indice 2026-05-29 — reaudit P1–P3 fix + UX readiness audit

Pass algoritmico su `main` @ `69e69b2` (fix reaudit [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) P1–P3; XCTest verde su macOS):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | `Docs/` | Tabella fix P1–P3 @ `69e69b2`; build/test macOS |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | `Docs/` | Environment-aware ceiling/NDL, canonical engine result, stable gas IDs |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | **Audit UX/UI readiness** planner Bühlmann iOS (2026-05-28): verdict *Partially ready*; gap UI su repetitive planning, ledger per cilindro, messaging ambiente — da affrontare **dopo** fix algoritmico @ `69e69b2` |

Relazione: reaudit math [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) → fix @ `69e69b2` → UX gaps residui in audit root UX/UI.

---

## Aggiornamento indice 2026-05-29 — audit algoritmi root + Buhlmann reaudit/UX

Pass documentale additivo su `main` @ `570964e`–`69e69b2` (post-sync remoto: hardening Watch/iOS, motore Buhlmann, golden fixtures, reaudit fix):

| Documento | Posizione | Contenuto |
|-----------|-----------|-----------|
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico Watch MAIN post-hardening (2026-05-27): lifecycle, TTV, risalita, GPS, bussola, logbook, export; P0–P3 |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | `Docs/` | Audit matematico iOS Companion MAIN (2026-05-27): planner, gas, sync, export, limiti reference-only |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | `Docs/` | Re-audit Buhlmann/gas planner iOS dopo fixture golden e hardening @ `76fce90`–`570964e` |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | `Docs/` | Audit UX/UI readiness planner Bühlmann iOS (2026-05-28): discoverability, safety copy, gap interpretazione UI (repetitive, ledger, ambiente) — complementa reaudit math |

Relazione audit Watch: [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) = pre-hardening @ `ddaf2d7`; audit root = post-hardening 2026-05-27; [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) = audit corrente read-only @ `main` (2026-05-31, PR #10). Implementazione: [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md), [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md).

---

## Aggiornamento indice 2026-05-19 — baseline `92e639a` + algorithm hardening

Pass documentale additivo su `main` @ `92e639a`:

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Release-hard pass Watch MAIN @ `92e639a`: depth validator, lifecycle, TTV, haptic coordinator, XCTest |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit matematico/algoritmico Watch MAIN @ `ddaf2d7` |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) | Allineamento branch strategy, MAIN vs experimental, conflict policy |
| [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md) | Report A–O del pass documentale corrente |
| [`PR_STATUS_20260519.md`](PR_STATUS_20260519.md) | Stato PR #8 / #9 e raccomandazioni merge |

Riferimenti UI obbligatori: [`ReferenceUI/Watch_LIVE_reference.png`](ReferenceUI/Watch_LIVE_reference.png), [`ReferenceUI/iOS_Companion_reference.png`](ReferenceUI/iOS_Companion_reference.png), [`FeatureScreenshots/02-ascent-warning.png`](FeatureScreenshots/02-ascent-warning.png).

---

## Aggiornamento indice 2026-05-28 - iOS gas+Buhlmann plan e refresh algoritmico

Pass documentale additivo su `main` tra `d1d48d5` -> `2edc46e` -> `9ee1912` -> `bc08707`:

| Documento | Stato | Contenuto |
|-----------|-------|-----------|
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | **Nuovo** | Piano operativo miglioramenti planner gas+Buhlmann iOS: obiettivi, criteri qualità, piano test e readiness |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Nuovo (pass 2026-05-28) | Cross-check esterno su envelope di riferimento Air/Nitrox/Trimix |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Aggiornato | Hardening iOS planner/Buhlmann e policy safety/reference |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Aggiornato | Design engine Buhlmann multigas e note implementative correnti |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Aggiornato | Verifica matematica estesa + copertura casi edge |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Aggiornato | Fixture/test aggiornati per regressioni numeriche |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Aggiornato | Limiti planner/reference esplicitati post hardening |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | **Nuovo** | Re-audit statico planner Buhlmann/gas iOS @ `76fce90`–`a7d2961`: motore ZHL-16C N2+He, golden fixtures, finding P1/P2 |
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | Aggiornato | Matrice feature aggiornata con stato iOS planner/Buhlmann |
| [`INDEX.md`](INDEX.md) | Aggiornato | Indicizzazione completa file nuovi/aggiornati 2026-05-28 |

Nota: aggiornamenti 2026-05-28 sono documentali/di validazione; non promuovono feature experimental nel runtime MAIN.

---

## Aggiornamento indice 2026-05-27 - current architecture, algorithm docs, branch safety

Pass documentale additivo su `main` dopo `37e4464`:

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Hardening iOS MAIN: validator, planner/gas safe states, import/export/sync/logbook math e test iOS |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Design motore iOS MAIN: Buhlmann ZHL-16C N2+He multigas reference engine |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Verifica matematica Buhlmann: costanti, formule, GF, NDL, multigas, robustezza numerica |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Cross-check esterno a tolleranza larga con fixture decotengu ZHL-16C |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Fixture/test iOS Algorithm per air, nitrox, trimix, deco gases, GF e helium loading |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | Piano migliorativo iOS per planner gas + Buhlmann: scope, hardening, QA e criteri release-ready |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti planner iOS: reference-only, assunzioni pressione, QA esterna richiesta |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | Assessment pre-implementazione con nota 2026-05-28 che rimanda al motore implementato |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Final hardening Watch MAIN: cap 40 log, temperatura plausibile, export vuoto, GPS fallback, conversioni |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) | Stato branch, divergenze, policy merge e isolamento experimental |
| [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) | Report A-O del pass documentale corrente |
| [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | PR #8/#9 live via `gh`, experimental e non safe-to-merge automaticamente |

Nota corrente: Snorkeling, Apnea, Buddy Assist e concept iOS experimental restano esclusi dai target MAIN in `project.yml`; le schermate e gli screenshot experimental sono documentati ma non promossi in runtime stabile.

---

## Aggiornamento indice 2026-05-26 - documenti e asset indicizzati

Questa sezione indicizza in modo additivo i file documentali e gli asset tracciati che non erano citati esplicitamente nell'indice precedente. Non cambia il contenuto dei documenti indicizzati.

| Documento / asset | Tipo | Nota |
|-------------------|------|------|
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit algoritmico Watch MAIN | Audit 2026-05-26 su algoritmi, formule, costanti, edge case e test mancanti del target Apple Watch MAIN. |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Hardening algoritmico Watch MAIN | P0/P1 fix, assunzioni finali, limiti residui e copertura test del pass release-hard. |
| [`Audits/DIR_DIVING_MAIN_BRANCH_READINESS_AUDIT_20260523.docx`](Audits/DIR_DIVING_MAIN_BRANCH_READINESS_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`DIR_DIVING_Piano_100_UX_UI_Watch_iOS_Sicurezza.docx`](DIR_DIVING_Piano_100_UX_UI_Watch_iOS_Sicurezza.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_POST_FIX.docx`](EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_POST_FIX.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx`](EXPERIMENTAL_FUNCTIONS_UX_AUDIT_20260517_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx`](EXPERIMENTAL_UX_INTERACTION_AUDIT_20260517.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/01-live-dive.png`](FeatureScreenshots/01-live-dive.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/02-ascent-warning.png`](FeatureScreenshots/02-ascent-warning.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/03-ascent-settings.png`](FeatureScreenshots/03-ascent-settings.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/04-compass-bearing.png`](FeatureScreenshots/04-compass-bearing.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/05-stopwatch-action.png`](FeatureScreenshots/05-stopwatch-action.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/06-dive-log.png`](FeatureScreenshots/06-dive-log.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/07-dive-detail-export.png`](FeatureScreenshots/07-dive-detail-export.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/08-gps-entry-exit.png`](FeatureScreenshots/08-gps-entry-exit.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/09-user-images.png`](FeatureScreenshots/09-user-images.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/10-buddy-send.png`](FeatureScreenshots/10-buddy-send.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/11-buddy-answer.png`](FeatureScreenshots/11-buddy-answer.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`FeatureScreenshots/12-buddy-link-compass.png`](FeatureScreenshots/12-buddy-link-compass.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/01-buddy-lab.png`](iOS/FeatureScreenshots/01-buddy-lab.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/02-technical-planner.png`](iOS/FeatureScreenshots/02-technical-planner.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/03-plan-result-v1-v2.png`](iOS/FeatureScreenshots/03-plan-result-v1-v2.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`iOS/FeatureScreenshots/04-contingencies-briefing.png`](iOS/FeatureScreenshots/04-contingencies-briefing.png) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260517.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260517.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260519.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260519.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_READINESS_AUDIT_FULL_20260519.docx`](MAIN_BRANCH_READINESS_AUDIT_FULL_20260519.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md) | Documento Markdown | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260517_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.docx`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.docx) | Documento Word / audit storico | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`ReferenceIcon/apple watch icon.png`](<ReferenceIcon/apple watch icon.png>) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |
| [`ReferenceIcon/ios icon.png`](<ReferenceIcon/ios icon.png>) | Asset / screenshot documentale | Indicizzato nel pass 2026-05-26; contenuto preservato senza modifiche. |

---

## 0. Note di sviluppo prodotto (MAIN) — leggere per backlog

| Documento | Contenuto | Stato |
|-----------|-----------|--------|
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | **Note sviluppo complete aggiornate (v10)** — backlog/spec iOS + Apple Watch aggiornato al 2026-05-25 | **Corrente (spec)** — file locale indicizzato |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | **Note sviluppo complete aggiornate (v9)** — iOS + Watch: icone, equipment, planner gas/Bühlmann, MOD, Watch allarmi/nav, checklist GAS | Spec precedente |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | Note sviluppo v8 (stesso ambito di v9; in caso di differenze preferire **v9**) | Spec precedente |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | Report implementazione v8 in codice: gas mix Air/EAN/Trimix, MOD, schedule travel/bailout, disclaimer trimix Bühlmann | **Completato** @ `a36dc23` |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | Report implementazione v9: immagini Watch in superficie, sync Planner/Bühlmann su input | **Completato** @ `d962117` |
| [`PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md) | Panoramica funzionalità MAIN/experimental, modalità, i18n, branch strategy | Corrente @ `2322145` + pass docs 2026-05-26 |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | Prima versione note 25/05/2026 (stesso ambito; usare v9/v8 se in conflitto) | Archivio / baseline |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | Implementazione codice note 25/05 (`c23d4d4`) | Completato |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Rigenerazione icone (`Scripts/update_app_icons.sh`) + cache Simulator | Operativo |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | Audit UX post-implementazione @ `c23d4d4` · [`.docx`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx) | Pre-fix B1/B2/B4/B6 |
| — | Fix UX B1/B2/B4/B6 (`9600015`): auto-dive copy, log bloccato in immersione, planner unità display, editor manuale | In `main` |
| — | Planner v8 codice (`a36dc23`): `PlannerGasSchedule`, `PlannerGasMixCard`, MOD block Calcola, N₂ Bühlmann trimix | In `main` |

---

## 1. Documento principale (leggere per primo)

### [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md)

Audit completo **MAIN** (Watch + iOS companion), struttura A–O. Versione Word: [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx). Audit pre-modifica redatto su `main` @ `21a7f41`, poi riallineato documentalmene sulla baseline corrente `main` e aggiornato nei delta documentali fino al pass 2026-05-26.

| Sezione | Contenuto |
|---------|-----------|
| **A** | Branch, target, `project.yml`, build e separazione target MAIN / experimental |
| **B** | Executive summary (repo-side 100%, overall 84% nel report 2026-05-25) |
| **C** | Feature inventory (Watch + iOS: impl / reach / usable / complete) |
| **D** | Navigation map (flussi Watch e iOS, dead end) |
| **E** | UI consistency vs reference (`Docs/ReferenceUI/`) |
| **F** | Settings (unità, allarmi, haptic, cloud, export) |
| **G** | Haptics / tones |
| **H** | Hardware (Crown, Action Button, App Intents) |
| **I** | Sync Watch ↔ iPhone, iCloud KVS |
| **J** | Export Subsurface CSV |
| **K** | Safety / disclaimer / non dive computer |
| **L** | Empty / error states |
| **M** | **Bugs to fix** (tabella con file e severità) |
| **N** | Priority roadmap (compile → TestFlight → App Store → post-release) |
| **O** | Final verdict (compile / utente medio / TestFlight / App Store) |
| **Validation log** | `xcodegen` + simulator build pass; generic device build bloccato da entitlement/provisioning |

**Bug critici elencati in §M (versione audit 2026-05-25; distinguere fra fix repo-side chiusi e blocchi esterni ancora aperti):**

| Bug | File indicato |
|-----|----------------|
| Entitlement `water-submersion` non approvato nel provisioning attivo | Apple Developer / profili / build generici |
| Build generico iOS bloccato dal target Watch embedded | Coppia iOS + Watch release |
| Automatic dive lifecycle non validato su hardware Ultra reale | Device QA |
| Repo-side issues del dated audit | **Risolti** su `main` (baseline commit `2322145`, con delta documentali 2026-05-26) — legal links dedicati, wording entitlement, BUSSOLA/planner i18n, recent sync activity, safeguard reset cronometro, docs branch alignment corrente |

> **Nota:** `e1cc982`–`fc08466`: build simulator Watch/iOS verde; i18n Equipment/Planner; checklist device QA in §6.

**Audit readiness precedenti (storico):**

| File | Uso |
|------|-----|
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.md) | Pass precedente, baseline immediata prima del dated audit 2026-05-25 |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md) | Pass R2–R4, baseline `db72dce` / WIP |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260523.md) | Pass readiness 100% UX |
| [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260522.md) | Onboarding legale |

**Audit planner / Bühlmann iOS MAIN (read-only):**

| File | Uso |
|------|-----|
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | **Audit comprehensive corrente** (2026-06-04 @ `63ee0b4`): Bühlmann + CNS/OTU + UX planner; verdict *Partially ready*; **P0/P1 OTU formula** |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive @ `e1370f7` (2026-05-30) — superseded per snapshot OTU/post-`40bf110` dall’audit **UPDATED** |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit post motore ZHL-16C N2+He, golden fixtures e hardening gas: scope iOS-only, verdict, file ispezionati, finding P1–P3 (**risolti** @ `69e69b2`); complementa [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) e [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | Audit UX/UI readiness planner Bühlmann iOS (Docs): verdict *Partially ready*; gap UI su repetitive planning, ledger per cilindro, copy ambiente — **non** coperti dal fix algoritmico @ `69e69b2` |

---

## 2. Stato repo, branch e PR

| Documento | Contenuto |
|-----------|-----------|
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md) | Allineamento corrente 2026-05-26: `main` baseline stabile, `main-iOS` worktree storico divergente, `codex/*` experimental-only |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) | Allineamento corrente 2026-05-27: `main` stabile, branch tracciati allineati ai remoti, PR #8/#9 experimental e non auto-merge |
| [`DOCUMENTATION_UPDATE_REPORT_20260526.md`](DOCUMENTATION_UPDATE_REPORT_20260526.md) | Report aggiornamento documentazione/repository consistency corrente |
| [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) | Report aggiornamento documentazione/repository consistency corrente post iOS algorithm/Buhlmann assessment |
| [`PR_STATUS_20260526.md`](PR_STATUS_20260526.md) | Stato PR/merge safety 2026-05-26 con divergenza branch aggiornata e limiti ambiente correnti |
| [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | Stato PR/merge safety 2026-05-27 da `gh pr list` |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) | Allineamento corrente: `main` canonico, `main-iOS` worktree storico divergente, experimental isolato |
| [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) | Report aggiornamento documentazione corrente |
| [`PR_STATUS_20260525.md`](PR_STATUS_20260525.md) | Stato PR/merge safety 2026-05-25 con limiti ambiente correnti |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md) | Allineamento branch post v9 @ `d962117` |
| [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md) | Report A–K pass documentazione post v9 |
| [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md) | Stato PR #8/#9 post v9 |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) | Branch `main` / `main-iOS` / experimental; regole merge; R2–R4 (storico) |
| [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md) | Report A–K pass docs post `bd129ca` / `86ef349` |
| [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) | Docs post Watch control strategy (`72fa15b`) |
| [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md) | PR #8 / #9 — non auto-merge |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md) | Allineamento precedente |
| [`PR_STATUS_20260523.md`](PR_STATUS_20260523.md) | Stato PR storico |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) | Stato PR storico (20260520) |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | Sync documentazione multi-branch |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260518.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md) | Allineamento branch (archivio) |
| [`DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md) | Allineamento branch (archivio) |

---

## 3. Watch MAIN — UX, controlli, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_AUDIT_REPORT_20260605.md) | **Audit** transfer foto iOS → Watch @ `ca76a19` (2026-06-05) — gap ack delivery, UX galleria |
| [`DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md`](DIRDIVING_WATCH_PHOTO_TRANSFER_IMPLEMENTATION_REPORT_20260605.md) | **Implementazione** remediation transfer foto iOS → Watch (2026-06-05) — lifecycle, ACK, UUID, test |
| [`DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt`](DIRDIVING_WATCH_IMAGE_DELETE_OPTIONS_PLAN_20260605.txt) | **Piano** delete immagini Watch (2026-06-05) — Opzione 1 Watch-first; Opzione 2 iOS+ACK |
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | Crown, Settings, App Intents, haptics (`72fa15b`) |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | Banner risalita inline, layout Live, BUSSOLA |
| [`MISSION_MODE_MAIN_WATCH.md`](MISSION_MODE_MAIN_WATCH.md) | Mission Mode MAIN: persistenza, attivazione/disattivazione, scope runtime e safety exclusions |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **Audit corrente** Watch MAIN @ `main`: pre-audit ~82%; post-remediation **100%** codice — [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report readiness 100% Watch MAIN (codice + test) |
| [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) | Policy sync manual/no-depth Watch → iOS |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit Watch pre-hardening @ `ddaf2d7` |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | Release-hard pass @ `92e639a` + XCTest |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Final hardening: cap log 40, temperature, export vuoto, GPS fallback |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | **Audit Docs** Watch MAIN post-hardening (2026-05-27) |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | Implementazione allarme risalita |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | QA 35 / 38 / 40 m |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) | **R1** entitlement + Ultra |
| [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | Note revisore App Store |

---

## 4. iOS MAIN — UX, audit, implementazione

| Documento | Contenuto |
|-----------|-----------|
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | **Audit corrente** iOS Companion MAIN — 76% @ audit → 100% @ `dce89e7` |
| [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report remediation iOS MAIN @ `dce89e7` |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente Watch MAIN — remediation **100%** codice |
| [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) | Report finale Watch MAIN readiness |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | **Audit UX/interaction/accessibilità PRE-MOD** @ `8a4d10e` (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | Audit UX/a11y precedente (`.docx` omonimo) |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | Audit precedente |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | **Report finale** pass readiness ~94% (build, i18n, copy, QA docs; device-only residui) |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | QA hardware: 7 App Intents + Action Button |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | QA hardware: sync, conflitti, tombstone, unità |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | Fix `db72dce` (gauge, intents, detail) |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | Implementazione issue backlog |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | Priorità issue |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | Note prodotto storiche (unità, disclaimer, manual dive) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | → vedi **§0** (spec prodotto **corrente**) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | → vedi **§0** (spec prodotto precedente) |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | → vedi **§0** |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v8 in codice) |
| [`DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md) | → vedi **§0** (implementazione v9 in codice) |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | → vedi **§0** |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | → vedi **§0** |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | → vedi **§0** |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | → vedi **§0** |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | Report implementazione storico `f851b61` |
| [`iOS/BUILD_AND_RUN.md`](iOS/BUILD_AND_RUN.md) | Build companion iOS |
| [`iOS/SUBSURFACE_EXPORT.md`](iOS/SUBSURFACE_EXPORT.md) | Export CSV |
| [`iOS/SAFETY_DISCLAIMER.md`](iOS/SAFETY_DISCLAIMER.md) | Disclaimer iOS |
| [`iOS/VALIDATION_REPORT.md`](iOS/VALIDATION_REPORT.md) | Validazione iOS |
| [`iOS/MOCKUP_COHERENCE.md`](iOS/MOCKUP_COHERENCE.md) | Coerenza mockup |
| [`iOS/GITHUB_SETUP.md`](iOS/GITHUB_SETUP.md) | Setup GitHub |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | Tab vs target |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | Stato mismatch |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit Buhlmann/gas planner iOS MAIN |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | **Audit Docs** algoritmi/math iOS Companion MAIN |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | **Audit Docs** UX/UI readiness planner Bühlmann iOS — gap UI post-fix algoritmico |

---

## 5. Matrice feature e roadmap

| Documento | Contenuto |
|-----------|-----------|
| [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) | **Matrice master** — Watch Main / Experimental / iOS / status / i18n |
| [`Branch_Functionality_Matrix.xlsx`](Branch_Functionality_Matrix.xlsx) | Export Excel (derivato da CSV) |
| [`ROADMAP.md`](ROADMAP.md) | Fatto / prossimi passi |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md) | Backlog pre-release |
| [`GLOSSARY.md`](GLOSSARY.md) | Glossario termini |

---

## 6. Build, release, sicurezza

| Documento | Contenuto |
|-----------|-----------|
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | `xcodegen`, scheme, build; troubleshooting GPS views / `xcodegen generate` |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | Icone app: `../Scripts/update_app_icons.sh`, Derived Data |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | Checklist release |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | Hardening algoritmico finale Watch MAIN |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | Hardening algoritmico iOS MAIN |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | **Audit comprehensive planner** 2026-06-04 — OTU blocker, risk matrix P0–P4 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | Audit comprehensive 2026-05-30 (baseline) |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | Motore Buhlmann ZHL-16C N2+He multigas iOS |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | Verifica matematica e statica del motore Buhlmann iOS |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | Fixture e test iOS Buhlmann |
| [`DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`](DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md) | Origine fixture golden/regression e tolleranze dichiarate |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | Envelope di riferimento esterno per Air, Nitrox e Trimix multigas |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | Limiti planner reference-only |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | Piano migliorativo planner gas+Buhlmann iOS (scope, roadmap, QA) |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | Assessment pre-implementazione ora superseded da design/fixture |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | Re-audit Buhlmann post golden fixtures e hardening (P1–P3 fix @ `69e69b2`) |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | Audit iOS algorithm/math |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | **Audit Docs** UX/UI readiness Bühlmann — repetitive UI, per-cylinder ledger, environment copy |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | Disclaimer (root Docs) |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | Destinazione dedicata per Termini d'uso da Watch/iOS |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | Destinazione dedicata per privacy / data use da Watch/iOS |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | Audit security F1–F12 |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | QA interno giornaliero; link checklist device |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | App Intents su Watch fisico |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | Sync Watch↔iPhone su hardware |
| [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | QA simulatore |

---

## 7. Experimental (non in target MAIN)

| Documento | Contenuto |
|-----------|-----------|
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | Panoramica Watch experimental |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | Snorkeling Live, Mappa Waypoint/Ritorno, POI, ritorno ingresso |
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | Apnea workflow |
| [`iOS/EXPERIMENTAL_FEATURES.md`](iOS/EXPERIMENTAL_FEATURES.md) | iOS Explore Lab / Buddy |

---

## 8. Audit UX storici e pass implementativi

| Documento | Contenuto |
|-----------|-----------|
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md) | Audit pre-modifica 20260519 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_CURRENT_PRE_MODIFICATION.md) | Audit 20260518 |
| [`MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md`](MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md) | Post-fix 20260518 |
| [`MAIN_UX_COMPLETION_REPORT.md`](MAIN_UX_COMPLETION_REPORT.md) | Completamento UX MAIN |
| [`MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md`](MAIN_UX_GAP_FIX_IMPLEMENTATION_20260518.md) | Gap fix 20260518 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | Readiness 100% 20260517 |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | Preflight UX |

---

## 9. Report aggiornamento documentazione (cronologia)

| Data | File |
|------|------|
| 20260527 | [`DOCUMENTATION_UPDATE_REPORT_20260527.md`](DOCUMENTATION_UPDATE_REPORT_20260527.md) |
| 20260526 | [`DOCUMENTATION_UPDATE_REPORT_20260526.md`](DOCUMENTATION_UPDATE_REPORT_20260526.md) |
| 20260525 | [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) |
| 20260524 | [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md), [`DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md`](DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md) |
| 20260523 | [`DOCUMENTATION_UPDATE_REPORT_20260523.md`](DOCUMENTATION_UPDATE_REPORT_20260523.md) |
| 20260522 | [`DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`](DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md) |
| 20260520 | [`DOCUMENTATION_UPDATE_REPORT_20260520.md`](DOCUMENTATION_UPDATE_REPORT_20260520.md), [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md) |
| 20260519 | [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md`](DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md`](DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md), [`DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md`](DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md) |

| Data | Branch alignment |
|------|------------------|
| 20260527 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md) |
| 20260526 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md) |
| 20260525 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) |
| 20260517–24 | [`DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md) … [`DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md) |

---

## 10. Riferimenti visivi e asset

| Percorso | Contenuto |
|----------|-----------|
| [`ReferenceUI/Watch_LIVE_reference.png`](ReferenceUI/Watch_LIVE_reference.png) | UI Watch Diving (benchmark audit §E) |
| [`ReferenceUI/iOS_Companion_reference.png`](ReferenceUI/iOS_Companion_reference.png) | UI iOS companion |
| [`ReferenceIcon/`](ReferenceIcon/) | Icone app, `altosinistra.png` |
| [`ReferenceLookAndFeel.jpg`](ReferenceLookAndFeel.jpg) | Look & feel (se presente) |
| [`LiveDiveImmersionPremiumPreview.png`](LiveDiveImmersionPremiumPreview.png) | Preview Live Dive |
| [`CurrentCodeLiveViewPreview.png`](CurrentCodeLiveViewPreview.png) | Preview codice Live |
| [`SecureBuddyPairingMockup.svg`](SecureBuddyPairingMockup.svg) | Mockup Buddy (experimental) |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | Linee guida visive |

---

## 11. Script generatori `.docx`

| Script | Output |
|--------|--------|
| [`generate_main_branch_complete_readiness_audit_20260524_docx.py`](generate_main_branch_complete_readiness_audit_20260524_docx.py) | `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260524.docx` |
| [`generate_main_branch_complete_readiness_audit_current_docx.py`](generate_main_branch_complete_readiness_audit_current_docx.py) | Generatore legacy del pass pre-modifica poi archiviato come `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.docx` |
| [`generate_main_branch_complete_readiness_audit_20260520_docx.py`](generate_main_branch_complete_readiness_audit_20260520_docx.py) | Audit 20260520 docx |
| [`generate_main_branch_complete_readiness_audit_20260522_docx.py`](generate_main_branch_complete_readiness_audit_20260522_docx.py) | Audit 20260522 docx |
| [`generate_main_branch_complete_readiness_audit_20260523_docx.py`](generate_main_branch_complete_readiness_audit_20260523_docx.py) | Audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260523_docx.py) | UX audit 20260523 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_docx.py) | UX audit 20260524 docx |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_post_dev_notes_docx.py) | `MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.docx` |
| [`generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py`](generate_main_branch_ux_interaction_accessibility_audit_20260524_pre_mod_docx.py) | UX audit PRE-MOD docx |
| [`generate_main_branch_readiness_audit_full_docx.py`](generate_main_branch_readiness_audit_full_docx.py) | Audit full |
| [`generate_main_readiness_audit_docx.py`](generate_main_readiness_audit_docx.py) | Readiness docx |
| [`generate_main_ux_audit_20260519_docx.py`](generate_main_ux_audit_20260519_docx.py) | UX 20260519 |
| [`generate_ux_roadmap_100_docx.py`](generate_ux_roadmap_100_docx.py) | Roadmap 100 docx |

---

## 12. Percorso rapido (30 minuti)

1. [`README.md`](README.md) — panoramica e branch strategy
2. [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) — **backlog prodotto corrente** (iOS + Watch)
3. [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) — cosa è già implementato in codice (v8) @ `a36dc23`
4. [`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`](MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md) — **§B, §M, §N, §O**
5. [`DOCUMENTATION_UPDATE_REPORT_20260525.md`](DOCUMENTATION_UPDATE_REPORT_20260525.md) + [`DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md) — allineamento documentazione/branch corrente
6. [`DIR_DIVING_Feature_Comparison.csv`](DIR_DIVING_Feature_Comparison.csv) — stato feature
7. [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) — `xcodegen generate` + build
8. [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) — se lavori su Watch
9. [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) + [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) — audit math Watch MAIN (corrente + post-hardening root)
10. [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) + [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) + [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) — se lavori su planner/iOS
11. [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md) — se lavori su TestFlight / R1

---

## 13. File principali collegati e repository root

| File | Ruolo |
|------|--------|
| [`README.md`](README.md) | Ingresso repository |
| [`CHANGELOG.md`](CHANGELOG.md) | Changelog |
| [`CONTRIBUTING.md`](CONTRIBUTING.md) | Regole contribuzione |
| [`../project.yml`](../project.yml) | XcodeGen / exclude experimental |
| [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente Watch MAIN (`Docs/`) |
| [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) | Audit corrente iOS Companion MAIN (`Docs/`) |
| [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | Audit algoritmi/math Watch MAIN (Docs) |
| [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md) | Audit algoritmi/math iOS Companion MAIN (Docs) |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | Audit UX/UI readiness planner Bühlmann iOS (Docs) |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | Audit comprehensive planner iOS @ `63ee0b4` (2026-06-04) |

---

---

## 14. Elenco alfabetico — `.md` in `Docs/` + audit root (riferimento rapido)

Audit storici ora consolidati in `Docs/`: vedi anche **§13** — [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md).

| File | Sezione indice |
|------|----------------|
| [`APNEA_EXPERIMENTAL_SPEC.md`](APNEA_EXPERIMENTAL_SPEC.md) | §7 |
| [`APP_ICON_UPDATE_NOTES.md`](APP_ICON_UPDATE_NOTES.md) | §0, §6 |
| [`APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md`](ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md) | §3 |
| [`BUILD_VALIDATION.md`](BUILD_VALIDATION.md) | §6, §12 |
| [`CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md) | §3 |
| [`DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md`](DEPTH_LIMIT_SAFETY_TEST_CHECKLIST.md) | §3 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md) | §6, agg. 2026-05-30 |
| [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) | §6, agg. 2026-06-04 |
| [`DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`](DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) | §1, §4, §6 |
| [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) | §1, §4, §6, §13 |
| [`DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md`](DIR_DIVING_IOS_BUHLMANN_MULTIGAS_ASSESSMENT.md) | §6 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) | §3, §6 |
| [`DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md) | §3, §6 |
| [`DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md`](DEVELOPMENT_NOTES_25_05_2026_IMPLEMENTATION_REPORT.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_25_05_2026.md`](DIR_Diving_Complete_Development_Notes_25_05_2026.md) | §0 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v10.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v10.md) | §0, §4, §12 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v8.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v8.md) | §0, §4 |
| [`DIR_Diving_Complete_Development_Notes_UPDATED_v9.md`](DIR_Diving_Complete_Development_Notes_UPDATED_v9.md) | §0, §12 |
| [`DIR_Diving_Main_Branch_Development_Notes.md`](DIR_Diving_Main_Branch_Development_Notes.md) | §4 |
| [`DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`](DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md) | §4 |
| [`DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md) | §0, §12 |
| [`DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md`](DIR_DIVING_IOS_GAS_BUHLMANN_PLANNER_IMPROVEMENT_PLAN.md) | §6 |
| [`DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`](DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md`](DIR_DIVING_IOS_BUHLMANN_REFERENCE_CROSSCHECK.md) | §6 |
| [`DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`](DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md) | §6 |
| [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md) | §6 |
| `DOCUMENTATION_BRANCH_ALIGNMENT_20260517.md` … `20260525.md` | §2, §9 |
| [`DOCUMENTATION_SYNC_REPORT_20260519.md`](DOCUMENTATION_SYNC_REPORT_20260519.md) | §2 |
| `DOCUMENTATION_UPDATE_REPORT_20260519.md` … `20260525.md` | §9 |
| [`EXPERIMENTAL_FEATURES.md`](EXPERIMENTAL_FEATURES.md) | §7 |
| [`GLOSSARY.md`](GLOSSARY.md) | §5 |
| [`INDEX.md`](INDEX.md) | questo file |
| [`INTERNAL_TESTING_PLAYBOOK_20260520.md`](INTERNAL_TESTING_PLAYBOOK_20260520.md) | §6 |
| [`IOS_TAB_TARGET_MISMATCH_REPORT.md`](IOS_TAB_TARGET_MISMATCH_REPORT.md) | §4 |
| [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) | §4 |
| `MAIN_BRANCH_COMPLETE_READINESS_AUDIT_20260520.md` … `2026-05-25.md` (+ `.docx`) | §1 |
| [`MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md) | §4 |
| [`MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`](MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md) | §4 |
| [`MAIN_BRANCH_TARGETED_FIX_REPORT.md`](MAIN_BRANCH_TARGETED_FIX_REPORT.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_CURRENT_PRE_MODIFICATION.md) | §4 |
| [`MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md`](MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260524_POST_DEV_NOTES.md) | §0, §4 |
| `MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518*.md`, `20260519*.md` | §8 |
| [`MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`](MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md) | §4 |
| [`MISSION_MODE_MAIN_WATCH.md`](MISSION_MODE_MAIN_WATCH.md) | §3 |
| [`MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`](MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md), [`MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`](MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md) | §5, §6 |
| [`MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md`](MAIN_READINESS_100_IMPLEMENTATION_REPORT_20260517.md) | §8 |
| [`MAIN_UX_*`](MAIN_UX_COMPLETION_REPORT.md) | §8 |
| [`PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`](PHASE0_MAIN_UX_PREFLIGHT_PLAN.md) | §8 |
| [`PRIVACY_AND_DATA_USE.md`](PRIVACY_AND_DATA_USE.md) | §6 |
| [`PR_STATUS_20260520.md`](PR_STATUS_20260520.md) … [`PR_STATUS_20260527.md`](PR_STATUS_20260527.md) | §2 |
| [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) | §6 |
| [`ROADMAP.md`](ROADMAP.md) | §5 |
| [`SAFETY_DISCLAIMER.md`](SAFETY_DISCLAIMER.md) | §6 |
| [`SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`](SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md) | §6 |
| [`SNORKELING_EXPERIMENTAL_SPEC.md`](SNORKELING_EXPERIMENTAL_SPEC.md) | §7 |
| [`TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md`](TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md), [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) | §3, §12 |
| [`TERMS_OF_USE.md`](TERMS_OF_USE.md) | §6 |
| [`UI_UX_VISUAL_GUIDELINES.md`](UI_UX_VISUAL_GUIDELINES.md) | §10 |
| [`WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`](WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md) | §3, §12 |
| [`WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md) | §4, §6 |
| [`WATCH_MAIN_UX_CONVENTIONS.md`](WATCH_MAIN_UX_CONVENTIONS.md) | §3 |
| [`iOS/*.md`](iOS/BUILD_AND_RUN.md) | §4 |

Altri asset in `Docs/`: `.docx`, `.csv`, `.xlsx`, `.py` (generatori §11), `ReferenceUI/`, `ReferenceIcon/`, immagini §10.

---

*Indice per ripresa lavoro su `main` @ `origin/main`. Baseline documentale: audit Watch/iOS consolidati in `Docs/`, photo transfer + image delete plan 2026-06-05, reaudit/UX Bühlmann 2026-05-28, hardening + motore Buhlmann in `Docs/` §6.*
