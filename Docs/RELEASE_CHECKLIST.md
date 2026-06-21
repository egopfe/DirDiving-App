# Release checklist — DIR DIVING MAIN

Compilare su **macOS** dopo `xcodegen generate`. Non spuntare voci non verificate.

## Metadati release

| Campo | Valore |
|-------|--------|
| Data | __________ |
| Commit `HEAD` | __________ |
| Esecutore | __________ |

## Audit remediation (2026-06-20 — Command 13 release/legal/claims @ `RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`)

- [ ] Review [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md)
- [ ] Claims matrix: [`CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](CLAIMS_EVIDENCE_MATRIX_CURRENT.csv) — no unsupported certification claims in MAIN software audit
- [ ] Release gate matrix: [`RELEASE_GATE_MATRIX_CURRENT.csv`](RELEASE_GATE_MATRIX_CURRENT.csv)
- [ ] App Store / TestFlight blockers: [`APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md)
- [ ] External legal counsel sign-off **PENDING** — [`IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md`](IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md)
- [ ] Run `./Scripts/validate_release_legal_claims_readiness.sh` — expect `RELEASE_CLAIMS_SOFTWARE_READINESS_100`
- [ ] Claims registry: [`CLAIMS_POLICY_REGISTRY_CURRENT.csv`](CLAIMS_POLICY_REGISTRY_CURRENT.csv) + [`PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv`](PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv)
- [ ] Remediation report: [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_REMEDIATION_REPORT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_REMEDIATION_REPORT_CURRENT.md)
- [ ] **Code-level claims compliance:** **100%** software/documentation gates — truthful non-certified posture; **not legal approval**
- [ ] **External TestFlight / App Store:** **BLOCKED** until P1/P2 external gates close

## Audit remediation (2026-06-20 — Command 12 test/QA evidence @ `TEST_QA_EVIDENCE_REMEDIATION_REPORT_CURRENT.md`)

- [ ] Review [`TEST_QA_EVIDENCE_REMEDIATION_REPORT_CURRENT.md`](TEST_QA_EVIDENCE_REMEDIATION_REPORT_CURRENT.md)
- [ ] Run `./Scripts/validate_test_qa_evidence_readiness.sh` — expect `TEST_QA_SOFTWARE_READINESS_100`
- [ ] Traceability matrix: [`REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv`](REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv) — 55/55 `Software_Status: PASS`
- [ ] Finding traceability: [`TEST_QA_FINDING_TRACEABILITY_CURRENT.csv`](TEST_QA_FINDING_TRACEABILITY_CURRENT.csv) — `SOFTWARE_VERIFIABLE_FINDINGS_OPEN_0`
- [ ] Evidence folders **PENDING**: see [`TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md`](TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md)
- [ ] **Code-level test/QA readiness:** **100%** software gates (Commands 7–12)
- [ ] **External TestFlight / App Store:** **BLOCKED** until physical QA + external validation + marketing evidence

## Audit remediation (2026-06-14 — deep code V1.0 @ `MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md`)

- [ ] Review [`MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md)
- [ ] MAIN-DCA-011 metadata merge, MAIN-DCA-019 photo ACK queue, MAIN-DCA-025 aggregate KVS budget verified in code review
- [ ] MAIN-DCA-012 alarm blink, MAIN-DCA-020/021 briefing sanitize/swap, MAIN-DCA-022 reminder suppression overlay-only
- [ ] Evidence folders **PENDING**: [`QA_EVIDENCE/WATCH_IOS_SYNC/`](QA_EVIDENCE/WATCH_IOS_SYNC/README.md), [`QA_EVIDENCE/ICLOUD_TWO_DEVICE/`](QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md)
- [ ] **Code-level readiness:** green builds + 832 iOS / 239 Watch tests (sim)
- [ ] **External TestFlight / App Store:** **BLOCKED** until physical QA + signed evidence packs

## Audit remediation (2026-06-09 — UI/UX @ `UI_UX_MAIN_AUDIT_CURRENT.md`)

- [ ] Review [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md)
- [ ] P1 localization/a11y fixes (ascent settings, sync keys, CCR GF/gas, watch photo panel, CCR chart summaries)
- [ ] P2 UX (CCR checklist import, reminder dismiss, live depth-first layout, More tab sync badge)
- [ ] P3 polish (image swipe, locale logbook dates, reference UI scaffolding)
- [ ] Evidence folders **PENDING**: [`QA_EVIDENCE/REFERENCE_UI/`](QA_EVIDENCE/REFERENCE_UI/README.md), [`DYNAMIC_TYPE_VOICEOVER/`](QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/README.md), [`APP_STORE_MARKETING/`](QA_EVIDENCE/APP_STORE_MARKETING/README.md)
- [ ] **Code-level UI/UX readiness:** green builds + 832 iOS / 239 Watch tests @ `99ea74a`
- [ ] **External TestFlight / App Store:** **BLOCKED** until physical QA + screenshots + marketing evidence

## Audit remediation (2026-06-09 — iOS complete algorithm @ `IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`)

- [ ] Review [`IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md)
- [ ] CCR checklist export wired in `CCRPlanResultView` (IOS-CHK-CCR-001)
- [ ] Evidence folders **PENDING**: [`QA_EVIDENCE/BUHLMANN_EXTERNAL/`](QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md), [`CCR_EXTERNAL/`](QA_EVIDENCE/CCR_EXTERNAL/README.md), [`ICLOUD_TWO_DEVICE/`](QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md), [`SUBSURFACE_CSV/`](QA_EVIDENCE/SUBSURFACE_CSV/README.md), [`IOS_ACCESSIBILITY/`](QA_EVIDENCE/IOS_ACCESSIBILITY/README.md)
- [ ] App Store marketing checklist: [`IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md`](IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md)
- [ ] iOS remains non-certified reference planner; CCR reference-only; external TestFlight blocked until evidence gates

## Audit remediation (2026-06-08 — Bühlmann comprehensive readiness @ `cc4d783` / remediation pass)

- [ ] Review [`1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`](1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md)
- [ ] Review [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_REMEDIATION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_REMEDIATION_REPORT.md)
- [ ] External Bühlmann validation **PENDING** — [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_EVIDENCE.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_EVIDENCE.md)
- [ ] External CCR validation **PENDING** — [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md)
- [ ] iCloud two-device QA **PENDING** — [`ICLOUD_TWO_DEVICE_QA_MATRIX.md`](ICLOUD_TWO_DEVICE_QA_MATRIX.md)
- [ ] Watch/iPhone physical sync **PENDING** — [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md)
- [ ] Subsurface external CSV **PENDING** — [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md)
- [ ] Visual QA matrices **PENDING** — [`IOS_PLANNER_VISUAL_QA_MATRIX.md`](IOS_PLANNER_VISUAL_QA_MATRIX.md), [`IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md`](IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md), [`IOS_RATIO_DECO_VISUAL_QA.md`](IOS_RATIO_DECO_VISUAL_QA.md)
- [ ] CCR bailout heuristic disclosed — [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md)
- [ ] **Internal TestFlight:** conditional yes (526+ iOS tests green)
- [ ] **External TestFlight / App Store:** **BLOCKED** until external validation + physical QA
- [ ] **No certified decompression / CCR controller claims**

## Audit remediation (2026-06-07 — iOS MAIN post-audit non-physical @ `af31937`)

- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md)
- [ ] Confirm builds/tests green after post-audit pass
- [ ] Physical QA still **PENDING** — [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md)
- [ ] External Bühlmann validation still **PENDING** — [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md)
- [ ] **No App Store readiness claim**

## Non-physical readiness (conditional on green builds/tests)

- [ ] Documentation baseline aligned (`af31937` audit re-run; current HEAD in post-audit report)
- [ ] Briefing PDF, manual dive, Ratio Deco MOD, Watch alarm/reminder/photo tests added
- [ ] Watch localization static sweep tests pass
- [ ] Logbook tissue simulation labeling verified

## Still pending before External TestFlight / App Store

- [ ] Physical Watch Ultra QA — [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md)
- [ ] Paired iPhone + Watch QA
- [ ] iCloud two-device QA — [`ICLOUD_TWO_DEVICE_QA_MATRIX.md`](ICLOUD_TWO_DEVICE_QA_MATRIX.md)
- [ ] External Bühlmann validation — [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md)
- [ ] Subsurface external validation
- [ ] Accessibility Dynamic Type / VoiceOver matrix — [`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`](IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md)
- [ ] Legal review

## Audit remediation (2026-06-07 — iOS MAIN algorithm math @ `32f8d3e`)

- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md) — P1–P4 non-physical fixes
- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — source audit
- [ ] Review [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md) — Ratio Deco is **heuristic/comparative only**; Bühlmann remains primary
- [ ] Confirm **no App Store / certification overclaims** in release notes
- [ ] Physical QA still **PENDING** — [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md)
- [ ] External Bühlmann validation still **PENDING** — [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md)

## Audit remediation (2026-06-06 — iOS MAIN algorithm @ ecad0d9)

- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) — HIGH-001/002, MED-001…006, cloud profile conflicts, NDL projection, KVS 512 KB cap
- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — audit baseline
- [ ] External Subsurface CSV regression (manual — see [`SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md))

## Audit remediation (2026-06-14 — Watch complete algorithm @ `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_CURRENT.md`)

- [ ] Review [`WATCH_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md`](WATCH_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md) — CSV divergence, GPS battery policy, draft hardening, timestamp docs, evidence scaffolding
- [ ] Watch code readiness: **high / internal-reference ready** (non-certified companion logger; no CCR/Bühlmann/Ratio Deco runtime)
- [ ] **External TestFlight blocked** until: Ultra physical QA evidence ([`QA_EVIDENCE/WATCH_ULTRA/`](QA_EVIDENCE/WATCH_ULTRA/README.md)), paired sync evidence ([`QA_EVIDENCE/WATCH_IOS_SYNC/`](QA_EVIDENCE/WATCH_IOS_SYNC/README.md)), mock fallback banner screenshot attached
- [ ] Review [`WATCH_CSV_EXPORT_POLICY.md`](WATCH_CSV_EXPORT_POLICY.md) — intentional Watch/iOS metadata divergence (no CCR on Watch)
- [ ] Review [`WATCH_DEPTH_SAMPLE_TIMESTAMP_POLICY.md`](WATCH_DEPTH_SAMPLE_TIMESTAMP_POLICY.md)
- [ ] Review [`WATCH_GPS_LIFECYCLE_POLICY.md`](WATCH_GPS_LIFECYCLE_POLICY.md) — no continuous GPS outside active dive

## Audit remediation (2026-06-06 — Watch MAIN)

- [ ] Review [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md) — integration test isolation, mock fallback UX, draft schema, GPS auth guard, CSV alignment
- [ ] Review [`WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md`](WATCH_MAIN_HARDWARE_ALGORITHM_QA_CHECKLIST.md) — physical QA not complete until executed

## Audit remediation (2026-06-03)

- [ ] Review [`DIR_DIVING_FULL_CODE_AUDIT_2026-06-03_REMEDIATION_REPORT.md`](DIR_DIVING_FULL_CODE_AUDIT_2026-06-03_REMEDIATION_REPORT.md)
- [ ] Review [`IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md)
- [ ] Review [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md)
- [ ] Optional CSV import without `temperature_c` verified on device (see [`CSV_IMPORT_EXPORT_POLICY.md`](CSV_IMPORT_EXPORT_POLICY.md))
- [ ] Manual pressure bar storage verified when switching metric/imperial (see remediation report IOS-AUDIT-006)
- [ ] Subsurface external import QA (see [`SUBSURFACE_EXPORT_COMPATIBILITY_QA.md`](SUBSURFACE_EXPORT_COMPATIBILITY_QA.md))
- [ ] Watch GPS lifecycle policy reviewed ([`WATCH_GPS_LIFECYCLE_POLICY.md`](WATCH_GPS_LIFECYCLE_POLICY.md))

## Build

- [ ] `xcodegen generate` senza errori  
- [ ] `git diff --exit-code -- DIRDiving.xcodeproj` (nessun drift post-generate)
- [ ] `xcodebuild` **DIRDiving Watch App** — `generic/platform=watchOS` — **PASS**  
- [ ] `xcodebuild` **DIRDiving iOS** — `generic/platform=iOS` — **PASS**  
- [ ] `xcodebuild test` **DIRDiving Watch Algorithm Tests** — **PASS**
- [ ] `xcodebuild test` **DIRDiving iOS Algorithm Tests** — **PASS**
- [ ] `./Scripts/check_main_target_isolation.sh` — **PASS**
- [ ] `./Scripts/check_secrets.sh` — **PASS**
- [ ] `./Scripts/validate_main_release_readiness.sh` — **PASS**

## Depth entitlement (Apple Watch Ultra — field validation)

**Not complete until executed on real hardware.** Entitlement is configured in `Config/DIRDiving.entitlements`; simulator does not certify submersion.

- [ ] Apple Developer portal: Watch App ID `com.egopfe.dirdiving.ios.watch` includes **water submersion** entitlement approved
- [ ] Apple Developer portal: embedded pair remains linked to iOS App ID `com.egopfe.dirdiving.ios`
- [ ] Provisioning profile used for Archive includes `com.apple.developer.coremotion.water-submersion`  
- [ ] Real **Apple Watch Ultra**: automatic dive launch when submerged (if product expects it)  
- [ ] Live depth samples from `CMWaterSubmersionManager` during test dive  
- [ ] Manual dive fallback panel still works when sensor unavailable  
- [ ] Info screen diagnostics match field result (not only “Configurato”)  

## Device matrix (manuale)

- [ ] Apple Watch **Ultra** — live screen, gauge, START/STOP/RESET, testi non tagliati  
- [ ] Apple Watch **Ultra** — pulsante **Start Dive** visibile in superficie; avvia sessione manuale senza impedire il successivo lifecycle automatico da profondita
- [ ] Apple Watch **41/45 mm** — stesse schermate  
- [ ] iPhone **piccolo** (es. SE class) — tab bar + Logbook  
- [ ] iPhone **Pro Max** — card e grafici  
- [ ] GPS **negato** — copy coerente, nessun “successo” verde fuorviante  
- [ ] Nessun iPhone / WatchConnectivity disattivato — messaggio sync chiaro  
- [ ] iCloud **non disponibile** — stato backup chiaro  
- [ ] Logbook **vuoto** — empty state + passi successivi  
- [ ] Export **fallito** — messaggio esplicito  
- [ ] Aptica Watch **off** — badge “avvisi solo visivi” visibile  
- [ ] Immagini sync iPhone -> Watch leggibili e raggiungibili fuori immersione attiva
- [ ] Mission Mode: auto-enable in Settings, stato/manuale superficie, fulmine in Live durante immersione, disclaimer ≠ Apple Basso Consumo, draft restore con auto-enable ON

## Sicurezza / copy

- [ ] Disclaimer MAIN visibile (iOS `MoreView` / README)  
- [ ] Link **Terms** / **Privacy** puntano ai documenti dedicati `Docs/TERMS_OF_USE.md` e `Docs/PRIVACY_AND_DATA_USE.md`
- [ ] Nessun claim di certificazione non supportato  
- [ ] Side Button descritto onestamente come system-controlled
- [ ] Action Button descritto come disponibile solo tramite Shortcuts / App Intents quando watchOS lo espone
- [ ] Planner iOS descritto come riferimento non certificato; il motore Buhlmann ZHL-16C N2+He multigas e presente ma richiede validazione esterna prima di claim piu forti.
- [ ] TTV Watch descritto come indice informativo (non NDL/TTS/deco)
- [ ] Mission Mode descritto come profilo runtime/UI interno (non Apple Basso Consumo)

## QA algoritmico MAIN

- [ ] Watch MAIN: verificare `Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING_FINAL.md` e test su cap log 40, temperatura plausibile, export vuoto, GPS fallback e conversioni.
- [ ] iOS MAIN: verificare `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` e test su planner/gas validation, import/export/sync, logbook time-weighted math, route math e safe states.
- [ ] iOS planner: verificare che trimix/helium usino il motore N2+He e restino reference-only; riferirsi a `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` e `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`.
- [ ] iOS planner UX (@ `3237262` + `dae29b8`): repetitive planning toggle + status; environment altitude/salinity messaging; schedule gas ledger card; result header badges (no-deco/deco-required); typed warnings; CNS/OTU reference disclaimers with **daily CNS / OTU 24h summary** and air-break note; VoiceOver labels su card risultato — vedi [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md).
- [ ] iOS planner CNS/OTU algorithm (@ `dae29b8`): deco profile with O₂ then air shows lower CNS than O₂ alone; repetitive second dive carries prior CNS/OTU after short SI; 24 h SI resets daily OTU — vedi [`OxygenExposureDeepModelTests.swift`](../Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift).

## QA Security (audit F1–F12, baseline 2026-05-19)

Rif. `Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md` (Appendix A) e commit `4136ec0`.

### Auth / pairing

- [ ] **F1** — Reset associazione Watch dalla UI iOS (`MoreView` / debug) → console mostra che il peer secret viene eliminato e ripubblicato dopo la nuova handshake; `userVisibleState` torna a "Associazione Watch non verificata" finché non arriva il secret.
- [ ] **F2** — `WatchSyncAuth.syncKey` su entrambe le piattaforme legge il commento MARK *"v2 ordered-secrets"*; nessun drift introdotto in PR aperte (PR #8 / #9).
- [ ] **F7** — Simulare `SecRandomCopyBytes` failure su simulator (es. swizzle in test) → app non genera secret deterministico, log strutturato via `os.Logger` con `privacy:.private`.

### Persistenza / Data Protection

- [ ] **F3** — Watch CSV export → file in `tmp/` con attributo `NSURLFileProtectionComplete`, filename `DIRDiving_Export_<UUID>.csv`, file > 24 h vengono ripuliti al successivo export.
- [ ] **F4** — iOS CSV export → `[.atomic, .completeFileProtection]`, cleanup attivo. **Vietato merge** da `main-iOS` se rimuove queste protezioni.
- [ ] **F9** — Verifica file `Documents/dirdiving_watch_pending_sync_sessions.json` (Watch) e `Documents/dirdiving_ios_watch_sync_conflicts.json` (iOS) creati con Data Protection complete; chiavi `UserDefaults` legacy `dirdiving_watch_pending_sync_sessions` e `dirdiving_ios_watch_sync_conflicts` non presenti dopo il primo launch post-migrazione.

### Sync protocol

- [ ] **F6** — Tampering del campo `issuedAt` > 1 h fuori dal `Date()` corrente → import iOS rigetta con `WatchDiveSyncError.stalePayload`.
- [ ] **F11** — iPhone con build aggiornata: il reply include `ackSignature` HMAC; Watch logga "ack firmato dal companion".
- [ ] **Signed ACK enforcement** — iPhone con build precedente o reply senza `ackSignature`: Watch mostra errore e conserva la pending queue.
- [ ] Tampering del campo `body` con MAC valido per body originale → `WatchDiveSyncError.invalidSignature`.

### Input validation

- [ ] **F5** — Import CSV con valori fuori bound (`depth_m = 99999`, `entry_lat = 5000`, `time_seconds = -42`) → riga conteggiata come malformata, non importata; risultato UI: "Import: 0 importate, 0 duplicati, N righe malformate".
- [ ] **F10** — Import CSV > 10 MB → errore `.fileTooLarge` con messaggio "CSV troppo grande: limite 10 MB."; nessun crash, nessun caricamento parziale.

### Logging / naming

- [ ] **F8 migration** — Utente con `dirmotion_ascent_rate_limits` esistente (sandbox precedente): valori letti correttamente, nuove modifiche scritte sotto `dirdiving_ascent_rate_limits`; lo stesso per Keychain iOS `com.egopfe.dirdiving.watch-sync` (legacy `com.egopfe.dirmotion.watch-sync` letto una volta).
- [ ] **F12** — Console (Mac → device): nessun `print()` Swift visibile; `Logger` per subsystem `com.egopfe.dirdiving*` mostra `<private>` sui dettagli errore.

### Privacy / leakage

- [ ] Sysdiagnose non contiene coordinate GPS, profondità o durata immersione nei log di `DiveLogStore`, `WatchSyncService`.
- [ ] CSV export non scritto su `Caches/` ma solo su `tmp/` con Data Protection.

> Se anche un solo check fallisce in modo non documentato, **bloccare la release** e aprire un follow-up con riferimento al finding (es. "F6 regression on watchOS 11.x").

## Firma

Approvazione release: __________________ Data: ________

---

*Checklist documentale; non modifica il codice.*

## Gate esterni obbligatori (non chiudibili solo da codice)

- [ ] `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`
- [ ] `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`
- [ ] `Docs/WATCH_IOS_SYNC_QA_MATRIX.md`
- [ ] `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md`
- [ ] `Docs/CSV_SUBSURFACE_QA_MATRIX.md`
- [ ] `Docs/PLANNER_GOLDEN_VALIDATION_QA_MATRIX.md`
- [ ] `Docs/TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`
- [ ] `Docs/APP_STORE_RELEASE_GATE_CHECKLIST.md`
