# Changelog

Tutte le date in formato ISO. Le voci documentano soprattutto **documentazione**, **allineamento UI/copy** e **processi di release**, salvo diversa indicazione.

## [Unreleased]

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
