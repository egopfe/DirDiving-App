# Aggiornamento documentazione - onboarding legale e matrice branch - 2026-05-22

## A. File aggiornati

- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `Docs/SAFETY_DISCLAIMER.md`
- `Docs/ROADMAP.md`
- `Docs/UI_UX_VISUAL_GUIDELINES.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/iOS/BUILD_AND_RUN.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`
- `Docs/Branch_Functionality_Matrix.xlsx`
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`

## B. Branch ispezionati

| Branch | Remoto | Stato prima del pass |
|---|---|---|
| `main` | `origin/main` | Allineato |
| `codex/experimental-features` | `origin/codex/experimental-features` | Allineato |
| `main-iOS` | `origin/main-iOS` | Allineato |
| `codex/ios-experimental-features` | `origin/codex/ios-experimental-features` | Allineato |

Backup locali creati prima del pass documentale:

- `backup/main-before-docs-merge-20260522`
- `backup/watch-experimental-before-docs-merge-20260522`
- `backup/main-ios-before-docs-merge-20260522`
- `backup/ios-experimental-before-docs-merge-20260522`

## C. Branch aggiornati

Il pass e documentale. Gli stessi aggiornamenti devono essere portati su:

- `main`
- `codex/experimental-features`
- `main-iOS`
- `codex/ios-experimental-features`

## D. Conflitti trovati

Nessun conflitto locale prima dell'aggiornamento documentale. Le PR GitHub aperte risultano invece ancora conflittuali.

## E. Conflitti risolti

Nessun conflitto runtime risolto in questo pass. Non sono stati modificati GPS, BUSSOLA, depth/ascent calculations, sync, export, modelli o manager.

## F. PR ispezionate

| PR | Branch | Base | Stato | Check |
|---|---|---|---|---|
| #8 - Update experimental Apnea workflow | `codex/experimental-features` | `main` | `CONFLICTING` | build failure |
| #9 - Add experimental Apnea companion review | `codex/ios-experimental-features` | `main-iOS` | `CONFLICTING` | build failure |

## G. PR safe to merge

Nessuna PR aperta e safe-to-merge automaticamente.

## H. PR da review manuale

- PR #8: contiene file experimental Watch, modifiche a `project.yml`, Apnea/Snorkeling/Buddy, onboarding legale gia presente e componenti UI. Richiede review target membership, build macOS e QA Diving live/BUSSOLA/GPS surface-only.
- PR #9: contiene superfici iOS experimental, asset/documenti, project/workflow, Buddy/Planner/Explore Lab e onboarding legale gia presente. Richiede review regressioni iOS, build macOS, controllo isolamento da `main-iOS` stable.

## I. Gap documentali aperti

- Terms & Privacy URL: prima di TestFlight/App Store sostituire i link repository con URL legali definitivi se richiesto.
- i18n residua: alcune stringhe runtime planner/GPS/import CSV restano da migrare a `Localizable.strings` o `.xcstrings`.
- Build reale: XcodeGen/Xcode build va eseguita su macOS; Windows non puo certificare build Apple.
- Entitlement depth: ancora da validare su Apple Developer portal e Apple Watch Ultra reale.

## J. Commit suggeriti

- `docs: update DIR DIVING feature documentation and branch matrix`
- `docs: record legal onboarding and disclaimer acceptance flow`

## K. Rischi e assunzioni

- Assunzione: l'onboarding legale implementato nel commit precedente e il riferimento corrente per `main`, `main-iOS` e branch sperimentali.
- Rischio: merge automatico PR #8/#9 potrebbe contaminare `main`/`main-iOS` con feature sperimentali o regressioni, quindi resta sconsigliato.
- Rischio: l'XLSX e una derivazione documentale; la fonte primaria resta `Docs/DIR_DIVING_Feature_Comparison.csv`.
- Vincolo preservato: nessuna modifica runtime in questo pass documentale.
