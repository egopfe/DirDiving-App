# Changelog

Tutte le date in formato ISO. Le voci documentano soprattutto **documentazione**, **allineamento UI/copy** e **processi di release**, salvo diversa indicazione.

## [Unreleased]

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
