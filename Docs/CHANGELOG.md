# Changelog

Tutte le date in formato ISO. Le voci documentano soprattutto **documentazione**, **allineamento UI/copy** e **processi di release**, salvo diversa indicazione.

## [Unreleased]

### Added (2026-06-20, documentation alignment V3.0 — docs-only)

- **Documentazione:** [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) (updated), [`Docs/PR_STATUS_20260620.md`](PR_STATUS_20260620.md).
- **Allineamento V3.0:** multi-activity scope (Diving + Apnea + Snorkeling on `main`); `Docs/README.md`, `Docs/INDEX.md`, root `README.md`, `DIR_DIVING_Feature_Comparison.csv` (additive rows + corrected navigation/exclusion notes).
- **Baseline:** `main` @ `f4f0a68` + MAIN deep-code readiness; **1362** iOS + **890** Watch algorithm tests, **0** skipped; external QA **PENDING**.

### Added (2026-06-20, MAIN deep code readiness — runtime + docs)

- **Cloud:** `CloudSyncLegacyMigrationPolicy`, `CloudSyncMigrationTelemetry` — legacy oversized KVS safe ignore + partial migration telemetry (MAIN-DCA-003).
- **Security:** `WatchSyncTrustStatePolicy` — TOFU fingerprint/epoch metadata (MAIN-DCA-013 accepted residual).
- **Validation:** `./Scripts/validate_main_deep_code_readiness.sh`; matrices under `Docs/MAIN_*_CURRENT.*`.
- **Test:** `MainDeepCodeReadinessCurrentTests`, `MainDeepCodeReadinessCurrentWatchTests`.
- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md), audit @ 100% software readiness.

### Added (2026-06-20, deep code audit V3.0 + remediation bundle — `f4f0a68`)

- iOS algorithm, UI/UX, Watch math software gates @ 100%; deep code audit V3.0 multi-activity report.

### Added (2026-06-14, documentation alignment — docs-only @ `99ea74a`)

- **Documentazione:** [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) (updated in place), [`Docs/PR_STATUS_20260614.md`](PR_STATUS_20260614.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260614.md`](DOCUMENTATION_UPDATE_REPORT_20260614.md).
- **Allineamento:** `Docs/INDEX.md`, `Docs/README.md`, root `README.md`, `ROADMAP.md`, `BRANCH_AND_TARGET_ISOLATION_POLICY.md`, `RELEASE_CHECKLIST.md`, `DIR_DIVING_Feature_Comparison.csv` (additive rows for V1.0 remediation, UI/UX V1.0, build/test evidence).
- **Baseline:** `main` @ `99ea74a`; deep-code remediation V1.0 MAIN-DCA-011…031 documented; physical QA still **PENDING**; experimental isolation reaffirmed; BUSSOLA terminology preserved.
- **Superseded (narrative baseline only):** prior alignment report narrative @ `0569903` for HEAD — file updated in place; `PR_STATUS_20260609` / `DOCUMENTATION_UPDATE_REPORT_20260609` superseded for HEAD baseline.

### Added (2026-06-14, deep code analysis remediation V1.0 — `99ea74a`, runtime)

- **Sync/cloud:** iOS Watch import metadata merge (`DiveSessionMerge.preferred`), aggregate + per-key KVS budget, iOS cloud success timestamp after completion window, gas label merge, pending flush policy + in-flight session IDs (MAIN-DCA-011/025/026/028/029).
- **Watch:** Durable photo delete ACK/inventory queue flushed on activation; alarm blink via `alarmBlinkActive` + `TimelineView` (no 1 Hz `@Published` toggle); reminder overlay suppression policy; briefing filename sanitize + atomic package swap; tissue chart axis l10n; Watch `.strings` alias cleanup (MAIN-DCA-012/019/020/021/022/030/031).
- **Policy:** `WatchSyncSchemaV1Policy`, `CCRMODTolerancePolicy` documented; threat model cross-links preserved.
- **Test:** `MainDeepCodeAnalysisRemediationV1Tests`, `MainDeepCodeAnalysisRemediationV1WatchTests`; Watch **239** + iOS **832** algorithm tests PASS (sim).
- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_V1.0.md).

### Added (2026-06-14, deep code analysis audit — `009855e`, docs-only)

- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) — MAIN-DCA-001…031 @ baseline `7c79105`.

### Added (2026-06-14, UI/UX audit remediation V1.0 — `7c79105`, runtime)

- **Documentazione:** [`Docs/UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT_V1.0.md); prior pass [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md) @ `dba1a22`.

### Added (2026-06-09, documentation alignment — docs-only @ `0569903`)

- **Documentazione:** [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md), [`Docs/PR_STATUS_20260609.md`](PR_STATUS_20260609.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md`](DOCUMENTATION_UPDATE_REPORT_20260609.md).
- **CCR reference docs:** [`CCR_REBREATHER_PLANNER.md`](CCR_REBREATHER_PLANNER.md), [`CCR_REBREATHER_SAFETY_DISCLAIMER.md`](CCR_REBREATHER_SAFETY_DISCLAIMER.md), [`CCR_REBREATHER_CHECKLIST_SYNC.md`](CCR_REBREATHER_CHECKLIST_SYNC.md).
- **Allineamento:** `Docs/INDEX.md`, `Docs/README.md`, root `README.md`, `ROADMAP.md`, `BRANCH_AND_TARGET_ISOLATION_POLICY.md`, `DIR_DIVING_Feature_Comparison.csv` (additive rows for MAIN-DCA, UI/UX remediation, CCR).
- **Baseline:** `main` @ `0569903`; deep-code remediation MAIN-DCA documented; physical QA still **PENDING**; experimental isolation reaffirmed; BUSSOLA terminology preserved.
- **Superseded (narrative baseline only):** prior `DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` @ `a69bc4b` for HEAD — file updated in place; `DOCUMENTATION_BRANCH_ALIGNMENT_20260607` narrative superseded.

### Added (2026-06-09, deep code analysis remediation — `0569903`, runtime)

- **Planner:** mode-projected MOD gating, analysis cache key, MOD/END label fix, reclamp on mode change (MAIN-DCA-004/005/010/011).
- **Watch sync:** userInfo import ACK dequeue, replay cache persistence, peer-secret publish gating (MAIN-DCA-001/013/014).
- **DiveManager:** end manual after handoff, throttled draft persistence, mission pending in draft v2 (MAIN-DCA-007/008/009).
- **Cloud/merge:** KVS 512KB cap, union merge policy (MAIN-DCA-002/003/006).
- **Misc:** blink timer 1.0s, CCR bailout switch-depth reconcile, photo `.completeFileProtection` (MAIN-DCA-012/015/016).
- **Test:** `MainDeepCodeRemediationDCATests`; Watch **192** + iOS **561** algorithm tests PASS (sim).
- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT.md), [`Docs/WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md).

### Added (2026-06-09, UI/UX audit remediation — `dba1a22`, runtime)

- **Localization/a11y:** ascent settings, sync status semantics, CCR GF steppers, Watch shortcut help, checklist/tissue/haptics/legal/toast VoiceOver.
- **UX:** CCR checklist import flow, sync status badge, locale-aware date formatting.
- **Test:** `UIUXRemediationV3AccessibilityTests`, `UIUXLocalizationRemediationTests`.
- **Documentazione:** [`Docs/UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md); audit baseline [`UI_UX_MAIN_AUDIT_CURRENT.md`](UI_UX_MAIN_AUDIT_CURRENT.md) @ `b7b6e93`.

### Added (2026-06-09, deep code analysis audit — `a2733d2`, docs-only)

- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md) — MAIN-DCA-001…018 @ baseline `dba1a22`.

### Added (2026-06-07, documentation alignment — docs-only @ `a69bc4b`)

- **Documentazione:** [`Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md), [`Docs/PR_STATUS_20260607.md`](PR_STATUS_20260607.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260607.md`](DOCUMENTATION_UPDATE_REPORT_20260607.md).
- **Allineamento:** `Docs/INDEX.md`, `Docs/README.md`, root `README.md`, `ROADMAP.md`, `BRANCH_AND_TARGET_ISOLATION_POLICY.md`, `DIR_DIVING_Feature_Comparison.csv` (header + rows for deep-code remediation, safety, release gates).
- **Baseline:** `main` @ `a69bc4b`; deep-code remediation documented; physical QA still **PENDING**; experimental isolation reaffirmed; BUSSOLA terminology preserved.
- **Superseded (narrative baseline only):** [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md) for HEAD — file retained as historical record.

### Added (2026-06-06, deep code remediation — `a69bc4b`, runtime)

- **Sync/security:** iOS outbound pending until signed Watch import ACK (`MAIN-AUD-001`); HMAC-signed photo inventory/delete (`MAIN-AUD-002`); sync nonce replay cache v2 (`MAIN-AUD-012`).
- **iOS:** Cloud oversize guard before local write; PDF to protected Application Support; photo preflight; planner debounce/cache; DiveLogStore delete guard; safe planner table a11y; cloud sync generation token; CSV quote hardening.
- **Test:** `MainDeepCodeAuditRemediationTests`; Watch **171** + iOS **415** algorithm tests PASS (sim).
- **Documentazione:** [`Docs/MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md`](MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md), [`Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md).

### Added (2026-06-05, experimental branch sync docs-only)

- **Documentazione:** aggiunto [`Docs/EXPERIMENTAL_BRANCH_SYNC_REPORT_20260605.md`](EXPERIMENTAL_BRANCH_SYNC_REPORT_20260605.md) per registrare i latest remote refs verificati prima delle modifiche docs.
- **Branch experimental:** confermati `codex/experimental-features` @ `227bcaa` e `codex/ios-experimental-features` @ `441fb77`, entrambi fast-forwardati dai rispettivi upstream.
- **Scope:** Apnea e Snorkeling restano feature experimental; Buddy Assist / BLE messaging rimangono lab-only e fuori da MAIN.

### Added (2026-06-06, documentation alignment — docs-only)

- **Documentazione:** README root stub, [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260606.md`](DOCUMENTATION_UPDATE_REPORT_20260606.md), [`Docs/PR_STATUS_20260606.md`](PR_STATUS_20260606.md).
- **Allineamento:** `Docs/README.md`, `INDEX.md`, `ROADMAP.md`, `BRANCH_AND_TARGET_ISOLATION_POLICY.md`, `ReferenceUI/README.md`, append `DIR_DIVING_Feature_Comparison.csv`.
- **Baseline:** `main` @ `90dc3f5`; experimental isolation reaffirmed; BUSSOLA terminology preserved.

### Added (2026-06-05 → 2026-06-06, Watch photo transfer + management — `fc311be`, `90dc3f5`)

- **iOS:** Manual **Send to Apple Watch** (no auto-transfer on pick); **Manage Apple Watch Images** sheet with refresh/delete; localized `watch_photo.send_to_watch`, `watch_photo.manage.open`.
- **Watch:** Synchronous staging of incoming companion photos before WCSession delegate returns (fixes deleted transfer file); ACK to iOS post-import.
- **Sync:** Transfer lifecycle tracking, inventory poll, distinct queued vs delivered status.
- **Documentazione:** Implementation reports 2026-06-05; INDEX remediation status updated; device QA still required on physical pair.

### Added (2026-05-31, MAIN UI/UX readiness 100% — `c8f91f6`)

- **Watch MAIN UI/UX:** Live Dive scroll + compact banner stacking; legal onboarding IT/EN; Crown first-run hint; underwater navigation toast; reset stopwatch intent guard; export ShareLink; compass/images a11y; tiered battery bar; alarm/ascent i18n + imperial bands; mode selection documented.
- **iOS MAIN UI/UX:** Policy A no-depth metadata-only edit; DEMO badge + mixed-logbook banner; iCloud merge conflict UI; planner team preview-only; sync status clarity; tab/picker a11y; synthetic manual profile disclosure; logbook expanded search; swipe-to-delete + confirmation; Analysis CSV via shared `CSVImportPanel`.
- **Documentazione:** [`Docs/MAIN_UI_UX_READINESS_AUDIT_CURRENT.md`](MAIN_UI_UX_READINESS_AUDIT_CURRENT.md), [`Docs/MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md), [`Docs/MAIN_UI_UX_READINESS_QA_ANALYSIS.md`](MAIN_UI_UX_READINESS_QA_ANALYSIS.md), INDEX/CSV/README/ROADMAP alignment @ `c8f91f6`.
- **Verdict (codice):** Watch/iOS/cross-app UI/UX **100%**; Internal TestFlight UI/UX **YES**; external TestFlight/App Store dopo QA fisica.

### Added (2026-05-31, Watch MAIN algorithmic readiness 100%)

- **Algoritmo Watch:** remediation WMATH-HIGH-001 → INFO-014 — depth callback silence watchdog, GPS fix/fallback/no-fix banners, manual/no-depth sync (Policy A), auto-start sample retention, persistence class, CSV time origin, `MonotonicElapsedClock`, independent blink/haptic sources, gauge/zone alignment, imperial ascent banner, temperature freshness.
- **iOS companion:** `hasDepthProfile`, sync validation manual no-depth, logbook/detail UI `RUNTIME/GPS`.
- **Test:** `WatchReadinessAlgorithmTests` + `WatchManualNoDepthSyncTests`; Watch + iOS algorithm suites **PASS** (Ultra 3 / iPhone 17 sim).
- **Documentazione:** [`Docs/WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md), [`Docs/WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md).

### Added (2026-05-31, iOS MAIN algorithmic readiness 100% — `dce89e7`)

- **Algoritmo iOS:** audit remediation B2–B5 — `AmbientPressureModel` unificato MOD/PPO₂; toggle profondità max/media end-to-end; merge iCloud per sessione; CSV `# session_meta` round-trip; incomplete calc guard; contingencies engine-driven; demo isolation in Analysis; time-weighted temperature.
- **Test:** 11 nuove suite + **154/154** `DIRDiving iOS Algorithm Tests` (1 skipped) su iPhone 17 sim.
- **Documentazione:** [`Docs/IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md), [`Docs/SUBSURFACE_CSV_ROUNDTRIP.md`](SUBSURFACE_CSV_ROUNDTRIP.md), branch alignment + PR status 2026-05-31.

### Added (2026-05-31, CI runner — `1d69d88`)

- **CI:** Build workflow `runs-on: macos-latest` (fix runner non assegnato su `macos-15`).

### Added (2026-05-31, comprehensive NOAA CNS/OTU + docs alignment — `dae29b8`)

- **Algoritmo iOS:** modello CNS/OTU comprehensive — limiti NOAA singolo e giornaliero, recupero superficie/pausa aria 90 min, soglie REPEX OTU (300 / 850 / 1800), carryover ossigeno su snapshot v2, integrazione su profilo completo.
- **Test:** `OxygenExposureDeepModelTests` (14 test); suite **119/119** `DIRDiving iOS Algorithm Tests` su iPhone 17 sim.
- **Documentazione:** README, INDEX, ROADMAP, CSV, PRODUCT_FEATURES_IT, GLOSSARY, completion report, engine design, hardening, improvement plan, changelog allineati @ `dae29b8`.
- **Report:** [`Docs/DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md).

### Added (2026-05-30, Phase 15 documentation alignment)

- Phase 15 docs: README, INDEX, ROADMAP, CSV, release/TestFlight, re-audit, consistency report, final readiness report @ `3237262`.

### Fixed (2026-05-30, iOS Bühlmann UX/UI — `3237262`)

- UX P1–P3 planner presentation fix; verification [`DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md); re-audit **Ready** [`Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md).

### Fixed (2026-05-29, iOS Buhlmann reaudit — `69e69b2`)

- **Algoritmo iOS:** fix P1–P3 da [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) — environment-aware ceiling/NDL, canonical engine result, stable cylinder IDs, fixture/tests; `DIRDiving iOS Algorithm Tests` verde su macOS.

### Added (2026-05-29, documentation indexing — `69e69b2`)

- **Indice:** [`Docs/INDEX.md`](INDEX.md) aggiornato @ `69e69b2`; sezione dedicata reaudit fix + **UX readiness audit**.
- **Audit root UX/UI:** [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) indicizzato in §1, §4, §6, §13, §14; relazione reaudit math → fix algoritmico → gap UI residui.
- **Docs:** aggiornati README, ROADMAP, CONTRIBUTING e hardening docs post-fix.

### Added (2026-05-29, documentation indexing — `570964e`)

- **Indice:** [`Docs/INDEX.md`](INDEX.md) aggiornato con audit root Watch/iOS, reaudit Buhlmann e UX readiness planner iOS.
- **Audit root:** [`DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md`](DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md), [`DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md).
- **Docs:** [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) indicizzato in §1, §4, §6, §12, §13, §14 e pass 2026-05-28; aggiornati README e ROADMAP.

### Added (2026-05-27, documentation / branch alignment refresh)

- **Documentazione corrente:** riallineati `README.md`, `Docs/INDEX.md`, `Docs/ROADMAP.md`, `Docs/RELEASE_CHECKLIST.md`, `Docs/TESTFLIGHT_REVIEW_NOTES.md` e `Docs/DIR_DIVING_Feature_Comparison.csv` alla baseline `main` @ `37e4464` e agli ultimi documenti algorithm/Buhlmann.
- **Nuovi report:** `Docs/DOCUMENTATION_UPDATE_REPORT_20260527.md`, `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`, `Docs/PR_STATUS_20260527.md`.
- **Algorithm docs:** indicizzati Watch final hardening, iOS algorithm hardening e assessment iOS Buhlmann multigas/helium.
- **Branch/PR policy:** `main` confermato stabile; `main-iOS` storico/divergente; `codex/*` experimental-only. PR #8/#9 ispezionate via `gh`, entrambe experimental e non safe-to-merge automaticamente.
- **Vincoli:** solo documentazione/repository consistency; nessuna modifica runtime, UI, UX, planner, sync, GPS, BUSSOLA o persistence.

### Added (2026-05-19, documentation / branch alignment — baseline `92e639a`)

- **Baseline commit:** README, INDEX, ROADMAP, PRODUCT_FEATURES_IT, SAFETY_DISCLAIMER, BUILD_VALIDATION e matrice CSV riallineati a `main` @ `92e639a`.
- **Algorithm hardening documentato:** pass `ddaf2d7` → `92e639a` indicizzato con [`Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md) e audit [`Docs/CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md).
- **Nuovi report:** [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md), [`Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md), [`Docs/PR_STATUS_20260519.md`](PR_STATUS_20260519.md).
- **Feature matrix:** righe additivi per algorithm validation pipeline, XCTest target, stale backlog rows riallineate a Implemented dove già presenti su `main`.
- **Branch strategy:** `main` = baseline stabile; `main-iOS` = worktree storico divergente; `codex/*` = experimental-only.
- **Vincoli:** solo documentazione/repository consistency; nessuna modifica runtime in questo pass.

### Added (2026-05-26, Watch algorithm release-hard — `92e639a`)

- **Watch MAIN:** depth sample validation pipeline, automatic dive lifecycle algorithm, time-weighted average depth, centralized ascent/T compass math, `AscentSafetyHapticCoordinator`, timestamp-derived runtime/stopwatch.
- **Tests:** target `DIRDiving Watch Algorithm Tests` + `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift`.
- **Report:** [`Docs/DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`](DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md).

### Added (2026-05-26, Watch algorithm audit — `ddaf2d7`)

- **Watch MAIN:** audit matematico/algoritmico completo; hardening iniziale su DiveManager, merge, sync codec, export.
- **Report:** [`Docs/CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md`](CODEX_DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md).

### Added (2026-05-26, documentation / branch alignment refresh)

- **Documentazione corrente:** riallineati `README.md`, `Docs/INDEX.md`, `Docs/PRODUCT_FEATURES_IT.md`, `Docs/ROADMAP.md`, `Docs/BUILD_VALIDATION.md`, `Docs/RELEASE_CHECKLIST.md`, `Docs/TESTFLIGHT_REVIEW_NOTES.md`, `Docs/SAFETY_DISCLAIMER.md`, `Docs/WATCH_MAIN_UX_CONVENTIONS.md`.
- **Audit correnti:** aggiornati `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md` e `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md` per riflettere il Watch `Start Dive`, Mission Mode e la narrativa branch corrente.
- **Nuovi report:** `Docs/DOCUMENTATION_UPDATE_REPORT_20260526.md`, `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`, `Docs/PR_STATUS_20260526.md`.
- **Branch strategy:** `main` confermato come baseline stabile; `main-iOS` confermato come worktree storico divergente; `codex/*` mantenuti experimental-only.

### Added (2026-05-26, Mission Mode — Watch MAIN)

- **Watch MAIN:** nuova impostazione `Mission Mode` con toggle persistente **Auto-enable on dive start** (`dirdiving.missionMode.autoEnableOnDiveStart`), default OFF.
- **Lifecycle:** Mission Mode si attiva solo dopo il passaggio a immersione attiva e si disattiva automaticamente a fine immersione; coperti sia avvio automatico da sensore sia avvio manuale.
- **Runtime/UI only:** ridotte animazioni, transizioni e shadow decorative non essenziali su Live e BUSSOLA; warning safety, profondita, runtime, logica risalita, logging e GPS entry/exit restano invariati.
- **Indicatore UI:** piccola icona statica vicino al polpo nell'header live, visibile solo quando Mission Mode e attivo durante una immersione attiva.
- **Documentazione:** aggiornati `README.md`, `Docs/PRODUCT_FEATURES_IT.md`, `Docs/WATCH_MAIN_UX_CONVENTIONS.md`, `Docs/SAFETY_DISCLAIMER.md`, `Docs/INDEX.md`; nuovo documento `Docs/MISSION_MODE_MAIN_WATCH.md`; matrice CSV aggiornata.

### Added (2026-05-25, documentation / branch alignment — `ab398eb`)

- **Documentazione:** riallineati `README.md`, `Docs/INDEX.md`, `Docs/PRODUCT_FEATURES_IT.md`, `Docs/ROADMAP.md`, `Docs/BUILD_VALIDATION.md`, `Docs/RELEASE_CHECKLIST.md`, `Docs/SAFETY_DISCLAIMER.md`, `Docs/TESTFLIGHT_REVIEW_NOTES.md`, `Docs/WATCH_MAIN_UX_CONVENTIONS.md`.
- **Audit/report:** aggiornati `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`, `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`; `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` marcato come report storico superseded.
- **Nuovi report:** `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`, `Docs/DOCUMENTATION_UPDATE_REPORT_20260525.md`, `Docs/PR_STATUS_20260525.md`.
- **Branch strategy:** `main` confermato come baseline stabile Watch+iOS; `main-iOS` documentato come worktree storico divergente; `codex/*` mantenuti experimental-only.
- **Vincoli:** solo documentazione/repository consistency; nessuna modifica runtime, business logic, planner math o sync architecture.

### Added (2026-05-20, documentation post v9 — `d962117`)

- **Documentazione:** [`Docs/PRODUCT_FEATURES_IT.md`](PRODUCT_FEATURES_IT.md) panoramica funzioni IT; README, INDEX, ROADMAP, matrice CSV (righe v8/v9); report [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md), [`DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md), [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md).
- **Baseline codice documentata:** v9 Watch surface User Images + Planner/Bühlmann input sync; v8 planner gas/equipment/MOD.
- **Vincoli:** solo documentazione; nessuna modifica runtime in questo pass.

### Added (2026-05-20, v9 — `d962117`)

- **Watch:** tab User Images sempre disponibile fuori immersione attiva; empty state localizzato; dettaglio immagine `scaledToFit`.
- **iOS:** `PlannerStore.applyInputToPlanningOutputs()` aggiorna plan + Bühlmann su cambio input gas; refresh su `plannerCylinders`.
- **Report:** [`Docs/DIR_DIVING_v9_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v9_IMPLEMENTATION_REPORT.md).

### Added (2026-05-20, v8 planner gas — `a36dc23`)

- **iOS:** cilindri multipli, ruoli gas, Air/EAN/Trimix, PPO₂ 0.1, MOD Dalton, equipment template GAS, foto→Watch con preprocess.
- **Report:** [`Docs/DIR_DIVING_v8_IMPLEMENTATION_REPORT.md`](DIR_DIVING_v8_IMPLEMENTATION_REPORT.md).

### Added (2026-05-24, MAIN readiness pass — build, i18n, copy, QA docs)

- **Build (Watch):** `return` mancanti in `AscentRateSettingsView.limitControl` e `DiveLogListView.logRow`; `xcodegen` + build simulator Watch/iOS **SUCCEEDED**.
- **i18n (solo copy):** Equipment e Planner iOS localizzati EN/IT; disclaimer lingua in More; settings Watch sync/underwater/shortcuts; empty state User Images.
- **Planner:** avviso metrico onesto (`planner.units.metric_notice`); nessuna modifica calcoli/algoritmi gas/deco.
- **Watch copy:** unità sync vs locale; toni audio non implementati (haptics); RESET cronometro immediato; impostazioni disabilitate in immersione (sicurezza).
- **Documentazione:** [`Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`](MAIN_BRANCH_FINAL_READINESS_REPORT.md), [`Docs/APP_INTENTS_DEVICE_QA_CHECKLIST.md`](APP_INTENTS_DEVICE_QA_CHECKLIST.md), [`Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md); aggiornati playbook TestFlight e `Docs/INDEX.md`.
- **Vincoli:** nessuna modifica experimental, algoritmi immersione, TTV, planner math, sync logic, UI graphics.

### Added (2026-05-24, Watch control strategy — `72fa15b`)

- **Watch controls:** strategia esplicita per Digital Crown, touch, App Intents / Action Button e tasto laterale system-controlled.
- **Underwater UX:** Live resta pagina primaria durante immersione attiva; BUSSOLA resta raggiungibile; Settings e preferenze sono scoraggiate/bloccate durante immersione.
- **Threshold tuning:** soglie allarmi e limiti risalita regolabili anche con Digital Crown, mantenendo i controlli touch.
- **Bussola:** feedback inline localizzato per `SET BEARING` / `CLEAR`.
- **Haptics:** conferme coerenti per start/end dive, stopwatch e bearing; warning safety esistenti invariati.
- **Documentazione:** `WATCH_CONTROL_STRATEGY_IMPLEMENTATION_REPORT.md`, convenzioni Watch, README, ROADMAP e feature matrix aggiornati.
- **Vincoli:** nessuna modifica a GPS, BUSSOLA algoritmica, calcoli profondita/risalita, decompressione, TTV, planner o modelli persistence.

### Added (2026-05-24, readiness R2–R4 + UX audits — `62e25d5`, `db72dce`, `876bcd2`)

- **iOS (`62e25d5`):** persistenza ack sicurezza planner (`PlannerSafetyAcknowledgment`); surfacing errori decode iCloud in Altro; localizzazione Logbook / Dettaglio / Analisi (chiavi `detail.*`, `logbook.*`, `analysis.*`, `cloud.*`).
- **Watch + iOS (`db72dce`):** etichette gauge risalita imperiali; catalogo 7 App Shortcuts; help tasto laterale; refresh dettaglio dopo edit immersione manuale.
- **Watch + iOS (`876bcd2`):** fix audit UX (edit manuale, merge metadata, disclaimer companion, conflitti sync, scroll legale, allarme 30 min, unità Live/Log, CSV in Analisi, ecc.).
- **Documentazione:** audit complete readiness 20260520/20260524; aggiornamento matrice CSV e README post `bd129ca`.

### Added (2026-05-24, development notes — `f851b61`)

- **Codice (UI/sync only):** unità metriche/imperiali con sync Watch↔iOS; disclaimer companion ogni avvio; allarmi Watch (default 30 min, profondità in unità selezionate); marchio `altosinistra`; iOS Planner prima tab; immersioni manuali; checklist attrezzatura editabile; invio foto al Watch; planner safety ack in cima con campi disabilitati se OFF.
- **Documentazione:** README, CSV feature matrix, `DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md`, allineamento branch/PR 2026-05-24.
- **Vincoli:** nessuna modifica GPS, BUSSOLA, calcoli profondità/risalita/decompressione; storage metrico canonico invariato.

### Added (2026-05-24, documentation alignment + MAIN readiness 100% UX)

- Documentazione: README (pass `6cda004` depth limits + readiness 100% UX), CSV feature matrix, `DOCUMENTATION_UPDATE_REPORT_20260524.md`, aggiornamento branch alignment e PR status.
- Codice UX (solo UI/i18n, nessun algoritmo): import CSV Logbook/More, tab planner funzionali, modalità planner onesta, export Watch informational, unità iOS metric-only, scroll legale obbligatorio, delete log senza contextMenu.
- Audit e checklist: `MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523`, `TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523`.

### Added (2026-05-23, depth limit safety — Watch)

- Commit `6cda004`: UI/haptic/log per limiti operativi 35/38/40 m; onboarding depth-limits ack; revisione legale 2026-05-23.

### Added (2026-05-23, production readiness MAIN — code + docs)

- Pass production readiness su `main` (`5e595ee`): product name build interni, iOS→Watch session push, UI conflitti sync in More, i18n Settings/live/Planner/import, planner safety ack, auto-skip Mode Selection, tab User Images condizionale, righe Settings informative.
- `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` — report finale A–K (~92% readiness post-pass).
- Allineamento documentale: CSV feature matrix, README, ROADMAP, PR status, branch alignment 2026-05-23.
- Vincoli: nessuna modifica a GPS, BUSSOLA, calcoli profondità/risalita, decompressione, planner math, crypto sync.

### Added (2026-05-22, legal onboarding + docs alignment)

- Flusso onboarding legale first-launch su Watch e iOS: Welcome, Safety Warning, Legal Disclaimer, Acceptance.
- Disclaimer completo IT/EN incluso come `LegalDisclaimer.txt` nei bundle `Resources/{en,it}.lproj` e `iOSApp/Resources/{en,it}.lproj`.
- Persistenza accettazione: timestamp, versione app, major version, device type, lingua e legal revision.
- Sezione **Legal & Safety** nei settings Watch/iOS con disclaimer completo, versione accettata e timestamp.
- Aggiornamento documentale additivo: README, safety disclaimer, roadmap, build/iOS notes, UI guidelines, branch alignment e matrice feature CSV/XLSX.
- Vincoli rispettati: nessuna modifica a GPS, BUSSOLA, calcoli profondita/risalita, decompressione, sync, export o modelli dati.

### Added (2026-05-22, branch/docs alignment)

- `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260522.md` - report A-K su fetch, branch, PR #8/#9 e conflitti.
- Merge `origin/main` in `main` con risoluzione conservativa dei soli conflitti documentali in `Docs/SAFETY_DISCLAIMER.md` e `Docs/TESTFLIGHT_REVIEW_NOTES.md`.
- Fast-forward dei worktree `codex/experimental-features` e `codex/ios-experimental-features` ai rispettivi remote.
- Righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` per report 2026-05-22 e stato PR aperte.

### Nota (2026-05-22)

- `main-iOS` resta divergente (local ahead 2 / behind 10) e richiede merge manuale: la preview mostra conflitti in documentazione e file runtime iOS. Nessuna risoluzione automatica e stata applicata per evitare cambi involontari a import CSV, sync o planner.

### Added (2026-05-20, secondary i18n + documentation alignment)

- Pass i18n secondario: espansione `Resources/{en,it}.lproj` e `iOSApp/Resources/{en,it}.lproj`; localizzazione messaggi sync, bussola, allarmi, Settings, log, export, Analysis/Planner header.
- `Docs/SAFETY_DISCLAIMER.md`, `Docs/TESTFLIGHT_REVIEW_NOTES.md`, `Docs/ROADMAP.md`.
- Aggiornamento `Docs/DIR_DIVING_Feature_Comparison.csv` (stati UX backlog → Implemented su `main` dove in `a75a6c3`).
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260520_POST_RELEASE.md` — report A–K allineamento documentazione.

### Added (2026-05-20, MAIN issues implementation — code on main)

- Commit `a75a6c3`: P0 inbound Watch sync, P1 tombstone unificata, GPS banner compatto, alarm OK, sync strip, App Intents; port manuale backlog preservando F1–F12.
- `Docs/MAIN_ISSUES_IMPLEMENTATION_REPORT_20260520.md`, `Docs/MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md`.

### Added (2026-05-20, ascent alarm inline banner + documentation pass)

- `Views/AscentWarningBannerView.swift` — banner rosso non bloccante tra TTV/RunTime e profondita (mockup `ascent_alarm.png`).
- Chiavi i18n `ascent_alarm_*` in `Resources/{en,it}.lproj/Localizable.strings`.
- `Docs/WATCH_MAIN_UX_CONVENTIONS.md` — baseline UX Watch MAIN (banner inline, no full-screen takeover).
- `Docs/ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md` — report implementazione A–J + QA checklist.
- `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md` (+ `.docx`) — audit UX/interaction MAIN.
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260520.md` e `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md` — report allineamento documentazione A–K.
- Righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` per banner risalita, convenzioni UX, report audit/implementazione.

### Changed (2026-05-20)

- `Views/DiveLiveView.swift` — rimosso takeover full-screen 1 s; haptic risalita da live view; gauge sempre visibile.
- `Views/AscentWarningView.swift` — wrapper sottile su `AscentWarningBannerView`.
- `Services/HapticService.swift` — `ascentAlarmTriggered` / `ascentAlarmRepeatIfNeeded` / `ascentAlarmCleared`.
- `Services/DiveManager.swift` — haptic risalita non invocati dal path di calcolo (solo UI).
- `README.md` — baseline Watch UX 2026-05-20; tabella pre-release UX-H3 aggiornata a *Implemented* su main.
- `Docs/DIR_DIVING_Feature_Comparison.csv` — voce «Avviso risalita» e UX-H3/SAF-1 allineate al banner inline.

### Nota (2026-05-20)

- L'audit `MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519` descriveva policy **1 s full-screen** (revisione stakeholder 2026-05-20): il codice su `main` implementa ora il **banner inline** documentato in `WATCH_MAIN_UX_CONVENTIONS.md`. Nessuna modifica a soglie o algoritmi di risalita.
- PR **#8** (`codex/experimental-features` → `main`) e **#9** (`codex/ios-experimental-features` → `main-iOS`): restano **non safe-to-merge** automaticamente (conflitti + regressioni security note su iOS experimental).

### Added (2026-05-19, pass pre-release backlog — UX-H/M/L + SAF + simulator QA)

- `Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md` — backlog rimanente / item rinviati post pre-release pass, con motivazione per Watch imperial conversion, GPX/UDDF exporter, per-field cloud merge per Equipment/Planner, side-button capture watchOS, convergenza branch `main` ↔ `main-iOS`.
- `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` — checklist QA eseguibile su Watch Ultra, Watch piccolo, iPhone SE e iPhone Pro Max: build smoke test, UX-H1..H4 acceptance, SAF-3..SAF-10, App Intents, haptics matrix, a11y, Dynamic Type.
- Sezione **Pre-release backlog (2026-05-19, UX-H/M/L + SAF-3..SAF-10)** in `README.md` con tabella di acceptance per area e procedura di reintegro dei 3 commit Watch backlog.
- Branch di sicurezza locale `backup/before-docs-pre-release-pass-20260519` creato prima del commit documentazione di questo pass.
- Branch di sicurezza locale `backup/main-watch-backlog-20260519` (creato in pass precedente) conserva i 3 commit Watch UX-H/M/L (`cbcabf7`, `c685155`, `efa53e4`) in attesa di riconciliazione con il cluster security F1–F12 sui file `Services/WatchSyncService.swift` e `Services/WatchDiveSyncCodec.swift`.
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md` — report strutturato A–K post-pass pre-release backlog.

### Changed (2026-05-19, pass pre-release backlog)

- Aggiunte righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` per i nuovi documenti, lo stato per-area UX-H/M/L + SAF-3..SAF-10, e l'evidenza del backup branch Watch backlog (status `Pending merge`).

### Nota

- Lato `origin/main-iOS` (commit `bf4718d`) sono già live SAF-3 (TTV info accessibility hint + nota muted in `iOSApp/Views/DiveDetailView.swift`) e SAF-4 (bound CSV `maxDepthMeters = 200`, `maxDurationSeconds = 28 800`, `temperatureRange = -2…40 °C` in `iOSApp/Services/DiveImportService.swift`).
- Nessuna modifica a business logic, decompressione, TTV/TTR algoritmi, modello gas o regole sync in questo pass. Nessun file experimental toccato. Terminologia UI: `BUSSOLA`, mai `COMPASSO`.

### Added (2026-05-19, pass documentazione security PT2)

- Sezione **QA Security (audit F1–F12, baseline 2026-05-19)** in `Docs/RELEASE_CHECKLIST.md` con sotto-sezioni Auth/pairing, Persistenza/Data Protection, Sync protocol, Input validation, Logging/naming, Privacy/leakage.
- Chiavi i18n `import.csv.too_large`, `import.csv.too_large.10mb`, `import.csv.unreadable`, `import.csv.missing_columns`, `import.csv.empty_profile` in `iOSApp/Resources/{en,it}.lproj/Localizable.strings` (additive; runtime in `DiveImportService.ImportError.errorDescription` restituisce ancora stringhe IT hardcoded — follow-up tecnico tracciato).
- 3 righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` (Documentation × 2 + Localization Planned).
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md` — report A–K.
- Commenti di stato security su PR #8 (issuecomment `4488127946`) e PR #9 (issuecomment `4488128195`) tramite `gh pr comment --body-file`.

### Added (2026-05-19, pass documentazione security)

- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md` — report strutturato A–K post-pass remediation security.
- Sezione **Sicurezza e sync (security baseline 2026-05-19)** in `README.md` con sintesi audit, finding HIGH/MEDIUM/LOW e remediation F1–F12.
- 13 righe additive categoria **Security** in `Docs/DIR_DIVING_Feature_Comparison.csv`: una per l'audit complessivo, una per ciascuna remediation F1, F2, F3, F6, F7, F8, F9, F10, F11, F12, una TODO per F11-follow-up (signed ack mandatory) e una TODO per le regressioni note su `main-iOS` (F4/F5), più la voce documento.
- Backup branch locale `backup/before-docs-merge-20260519-security` prima del commit.

### Fixed (2026-05-19, security audit F1–F12)

- **F1 (HIGH, build break)** ripristinato `WatchSyncAuth.resetPeerTrust()` su iOS MAIN con helper `deleteKeychain(account:service:)` (`iOSApp/Services/WatchSyncAuth.swift`).
- **F2 (HIGH, protocol drift)** documentata l'algoritmo autoritativo `v2 ordered-secrets` con commento MARK; Watch e iOS MAIN già allineati.
- **F3 (MEDIUM)** Watch `SubsurfaceExportService` ora scrive il CSV con `[.atomic, .completeFileProtection]`, filename UUID e cleanup 24 h.
- **F4 (MEDIUM)** iOS `SubsurfaceExportService` su MAIN mantiene `.completeFileProtection` + cleanup (nessuna regressione introdotta).
- **F5 (MEDIUM)** iOS `DiveImportService` su MAIN mantiene i bound `maxDiveDurationSeconds`, `maxDepthMeters`, `validTemperatureRange`, `isValidGPS`.
- **F6 (MEDIUM)** `WatchDiveSyncCodec.maxIssuedAtSkew` ridotto da 86 400 s a **3 600 s** (1 h) per restringere la finestra di replay.
- **F7 (LOW)** rimosso fallback deterministico SHA256 quando `SecRandomCopyBytes` fallisce; `loadOrCreateLocalSecret` ora ritorna `Data?` e i chiamanti loggano via `os.Logger` con `privacy:.private`.
- **F8 (LOW)** naming canonico `dirdiving_*`: nuova `Notification.Name("dirdiving.watchSyncPeerSecretDidUpdate")` (Watch + iOS), `AscentRateSettingsStore.key = "dirdiving_ascent_rate_limits"` con read-fallback dal legacy `dirmotion_ascent_rate_limits`, e Keychain service iOS `com.egopfe.dirdiving.watch-sync` con migrazione one-shot dalla legacy `com.egopfe.dirmotion.watch-sync`. Nessuna chiave persistita rimossa direttamente.
- **F9 (LOW)** pending sessions Watch (`dirdiving_watch_pending_sync_sessions.json`) e conflicts iOS (`dirdiving_ios_watch_sync_conflicts.json`) ora in `Documents/` con `[.atomic, .completeFileProtection]`; migrazione one-shot da UserDefaults con clear della chiave legacy.
- **F10 (LOW)** import CSV iOS limitato a **10 MB** con nuovo errore `.fileTooLarge`; pre-check su `URLResourceValues.fileSize` e post-check sui byte UTF-8.
- **F11 (LOW)** ack WatchConnectivity firmato HMAC su `"ack|sessionID|issuedAt"` lato iOS reply + verify lato Watch in tempo costante. Mantenuto fallback `status == acknowledged` per compatibilità con vecchie iOS builds; TODO esplicito per rendere il firmato obbligatorio. Introdotta `WatchDiveSyncCodec.PayloadEnvelope` e `parsePayload(from:)` per esporre `issuedAt` ai chiamanti.
- **F12 (LOW)** rimosso `print` in `Services/DiveLogStore.swift`; ora `Logger(subsystem: "com.egopfe.dirdiving", category: "DiveLogStore")` con `privacy:.private` sui dettagli errore.

### Added (2026-05-19, security audit)

- `Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md` — audit di sicurezza statico su `main` (HEAD `e8b70a2`) e `origin/main-iOS` (HEAD `06057d7`): 18 finding (2 HIGH, 4 MEDIUM, 6 LOW, 6 INFO). Highlights: build break su `main` per `WatchSyncAuth.resetPeerTrust` mancante; drift algoritmo HMAC `syncKey` tra Watch (`main`) e iOS (`main-iOS`); regressioni di Data Protection e input validation su `main-iOS`. Nessuna modifica runtime in questo commit.

### Added (2026-05-19, pass i18n)

- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md` — report strutturato A–K post-pass internazionalizzazione.
- Sezione **Lingue e internazionalizzazione (i18n)** in `README.md` con descrizione enum, persistenza, locale runtime, picker e vincoli.
- Voce roadmap i18n in `README.md`.
- Colonna **Internationalization** nell'header di `Docs/DIR_DIVING_Feature_Comparison.csv` e righe additive *Localization* per Watch/iOS (selettore lingua, tabelle stringhe, logbook locale-aware, hint VoiceOver, gap residui, sync cross-device pianificato).
- Backup branch locale `backup/before-docs-merge-20260519-i18n` prima del commit.

### Added (2026-05-19, secondo pass)

- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md` — report strutturato A–K (file aggiornati, branch, PR, rischi).
- `Docs/IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md` — versionato nel repo (stato mismatch tab iOS vs target).
- Branch di sicurezza `backup/before-docs-merge-20260519` creato prima del commit documentazione.
- Righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` (Return-to-entry snorkeling, waypoint/bearing, report documentali).

### Changed (2026-05-19, secondo pass)

- i18n: tab bar iOS con chiavi `tab.*`; logbook con `@Environment(\.locale)` per sezioni mese e abbreviazioni card; hint accessibilità comandi Watch da `Localizable.strings`.
- `README.md` — allineamento testi MAIN iOS: tab **Analisi** al posto di «Route Review» come superficie separata; matrice piattaforme `main-iOS` chiarita.
- `Docs/DIR_DIVING_Feature_Comparison.csv` — riga «Explore» sostituita da voce **Analisi** per sync/empty state; nota su Route Review vs Analisi.
- `CONTRIBUTING.md` — nota su PR conflittuali e uso `gh pr comment`.
- `Docs/DOCUMENTATION_SYNC_REPORT_20260519.md` e `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md` — riferimento backup e verifica PR (mergeable CONFLICTING).

### Added (2026-05-19)

- `Docs/BUILD_VALIDATION.md` — comandi `xcodegen` / `xcodebuild` per Watch e iOS.
- `Docs/GLOSSARY.md` — glossario utente e mapping terminologico.
- `Docs/RELEASE_CHECKLIST.md` — checklist manuale pre-release.
- `Docs/UI_UX_VISUAL_GUIDELINES.md` — riferimenti visivi (`Docs/ReferenceUI/`).
- `Docs/MAIN_UX_COMPLETION_REPORT.md`, `Docs/PHASE0_MAIN_UX_PREFLIGHT_PLAN.md`, `Docs/IOS_TAB_TARGET_MISMATCH_REPORT.md`.
- `Docs/DOCUMENTATION_SYNC_REPORT_20260519.md`, `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md`.
- `CONTRIBUTING.md` — linee guida per contributi senza toccare la business logic.
- Righe additive in `Docs/DIR_DIVING_Feature_Comparison.csv` (documentazione e tab iOS a cinque voci).

### Changed (2026-05-19)

- `README.md` — sezione **Strategia dei rami (Branch Strategy)**, link matrice CSV, aggiornamento documentazione 19 maggio, correzioni testuali iOS MAIN (Analisi / Attrezzatura).

### Nota

- Modifiche runtime SwiftUI su Watch/iOS possono essere presenti nel working tree ma **non** sono parte di questa voce se consegnate in commit separati.
