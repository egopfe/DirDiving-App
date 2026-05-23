# Report di sincronizzazione documentazione — 2026-05-19

## A. File aggiornati o creati

| File |
|------|
| `README.md` |
| `CHANGELOG.md` |
| `CONTRIBUTING.md` |
| `Docs/DIR_DIVING_Feature_Comparison.csv` |
| `Docs/BUILD_VALIDATION.md` |
| `Docs/GLOSSARY.md` |
| `Docs/RELEASE_CHECKLIST.md` |
| `Docs/UI_UX_VISUAL_GUIDELINES.md` |
| `Docs/PHASE0_MAIN_UX_PREFLIGHT_PLAN.md` |
| `Docs/MAIN_UX_COMPLETION_REPORT.md` |
| `Docs/IOS_TAB_TARGET_MISMATCH_REPORT.md` |
| `Docs/generate_main_branch_readiness_audit_full_docx.py` |
| `Docs/generate_main_readiness_audit_docx.py` |
| `Docs/generate_ux_roadmap_100_docx.py` |
| `Docs/ReferenceUI/Watch_LIVE_reference.png` |
| `Docs/ReferenceUI/iOS_Companion_reference.png` |
| `Docs/DOCUMENTATION_SYNC_REPORT_20260519.md` (questo file) |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md` |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md` |
| `Docs/IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md` |

*File `.docx` di audit/roadmap possono restare non versionati se si preferisce limitare la dimensione del repository.*

*Secondo pass 2026-05-19:* creato branch di sicurezza `backup/before-docs-merge-20260519` (puntatore a `HEAD` prima del commit documentazione). Verifica PR con `gh pr view`: #8 e #9 ancora `CONFLICTING` / `DIRTY`.

## B. Branch ispezionati

- Locale: `main`, `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`, rami `backup/*`.
- Remote: `origin/main`, `origin/main-iOS`, `origin/codex/experimental-features`, `origin/codex/ios-experimental-features` (dopo `git fetch`).

## C. Branch aggiornati (commit)

- **`main` (locale):** eseguito commit **solo documentazione** (`docs: update DIR DIVING feature documentation and branch matrix`). **Nessun** push forzato; altri branch non riscritti.

## D. Conflitti trovati

- **PR #8** (`codex/experimental-features` → `main`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.

## E. Conflitti risolti

- **Nessuno** — non è stato eseguito merge delle PR (rischio runtime e scope oltre documentazione).

## F. PR ispezionate

| PR | Titolo | Base |
|----|--------|------|
| 8 | Update experimental Apnea workflow | `main` |
| 9 | Add experimental Apnea companion review | `main-iOS` |

## G. PR considerate *safe to merge*

- **Nessuna** in questo stato (conflitti + scope ampio su file runtime).

## H. PR che richiedono revisione manuale

- **#8** e **#9**: risoluzione conflitti su macOS, `xcodegen generate`, build Watch/iOS, QA Snorkeling Live / mappe / Apnea, verifica terminologia **BUSSOLA** e GPS surface-only.

## I. Lacune documentali aperte

- Validazione build reale su **macOS** da registrare in `Docs/RELEASE_CHECKLIST.md`.
- Excel `Branch_Functionality_Matrix.xlsx` citato in alcuni branch PR **non** presente su `main` locale — la fonte di verità resta `Docs/DIR_DIVING_Feature_Comparison.csv` finché l'Excel non viene aggiunto senza duplicare informazioni in conflitto.
- Allineamento paragrafo-per-paragrafo tra `main` e `main-iOS` per README duplicati va fatto manualmente se i branch divergono.

## J. Commit suggeriti (prossimi)

1. `docs: update DIR DIVING feature documentation and branch matrix` — solo file elencati in sezione A (nessun `.swift` runtime).
2. Dopo QA macOS: `docs: record Xcode build results in RELEASE_CHECKLIST`.
3. Eventuale `merge:` solo dopo risoluzione PR #8/#9 da maintainer.

## K. Rischi / assunzioni

- L'agente non ha eseguito `xcodebuild` su Windows.
- Non è stato verificato lo stato delle PR su GitHub Actions oltre ai metadati `gh pr view`.
- **Assunzione:** le modifiche Swift locali non committate restano responsabilità del team per commit separati.
