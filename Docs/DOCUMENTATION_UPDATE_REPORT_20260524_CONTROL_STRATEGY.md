# DIR DIVING — Report aggiornamento documentazione (2026-05-24, Watch control strategy)

**Tipo:** documentazione + commit precedente Watch control strategy. Nessun merge PR automatico. Nessuna modifica a GPS, algoritmi BUSSOLA, calcoli immersione, TTV, planner o persistenza modelli durante il pass documentale.

**Baseline locale `main`:** `72fa15b` — `origin/main` `86ef349` + `feat(watch): implement control strategy`.

---

## A. Files updated

| File | Azione |
|------|--------|
| `README.md` | Sezione strategia controlli Apple Watch; HEAD consigliato aggiornato a `72fa15b`; nota documentazione post-control-strategy |
| `CHANGELOG.md` | Voce Unreleased per Watch control strategy |
| `Docs/ROADMAP.md` | HEAD `72fa15b`; righe Crown/touch/App Intents/bearing; follow-up long-press |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Righe additive per navigazione underwater, Crown tuning, bearing toast, side-button copy, App Intents, haptics, report |
| `Docs/Branch_Functionality_Matrix.xlsx` | Sync da CSV se runtime spreadsheet disponibile |
| `Docs/PR_STATUS_20260524.md` | Stato `gh` PR #8/#9 = `mergeable: UNKNOWN`; non safe-to-merge |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md` | Baseline `72fa15b`, divergenza branch aggiornata |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260524_CONTROL_STRATEGY.md` | Questo report |

---

## B. Branches inspected

| Branch | Stato |
|--------|-------|
| `main` | Locale ahead 1 dopo commit control strategy; rebase completato su `origin/main` |
| `origin/main` | `86ef349` dopo fetch |
| `origin/main-iOS` | `e3b733a`; divergente da `main` |
| `origin/codex/experimental-features` | `6649335`; ~28 ahead / ~47 behind vs `origin/main` |
| `origin/codex/ios-experimental-features` | `9e5baca`; ~59 ahead / ~94 behind vs `origin/main` |
| backup locali | `backup/before-docs-merge-20260524-1520` creato prima del rebase/commit |

---

## C. Branches updated

| Branch | Azione |
|--------|--------|
| `main` | Commit `feat(watch): implement control strategy`; commit documentale separato previsto |
| `main-iOS` | Non aggiornato in questo pass per evitare checkout con branch divergente/worktree collegato; sync docs consigliato dopo push main |
| experimental | Non aggiornati; isolamento preservato |

---

## D. Conflicts found

Nessun conflitto locale durante `git pull --rebase origin main`.

PR #8/#9 restano non safe-to-merge: post-push #8 risulta `mergeable: UNKNOWN`, #9 `mergeable: CONFLICTING`, ed entrambe hanno check GitHub Actions `build` fallito.

---

## E. Conflicts resolved

Nessuno.

---

## F. PRs inspected

| PR | Branch | Base | Stato | Raccomandazione |
|----|--------|------|-------|-----------------|
| #8 Update experimental Apnea workflow | `codex/experimental-features` | `main` | `mergeable: UNKNOWN`, build failed | Review manuale; non auto-merge |
| #9 Add experimental Apnea companion review | `codex/ios-experimental-features` | `main-iOS` | `mergeable: CONFLICTING`, build failed | Review manuale; non auto-merge |

---

## G. PRs safe to merge

Nessuna PR considerata safe-to-merge automaticamente.

---

## H. PRs requiring manual review

- **#8:** rischio inclusione sperimentale Snorkeling/Apnea/Buddy in `main`; verificare `project.yml` excludes, Diving Live, BUSSOLA, GPS surface-only, haptics e control strategy.
- **#9:** rischio regressioni iOS security/import/export già documentate; verificare F4/F5, build iOS, Explore Lab non production.

---

## I. Documentation gaps still open

| Gap | Priorità |
|-----|----------|
| Build XcodeGen + Watch/iOS su macOS | P0 |
| QA Apple Watch Ultra reale / entitlement water submersion | P0 |
| Sync documentazione `main-iOS` dopo push main | P2 |
| i18n residuo Planner/Equipment/runtime | P2 |
| XLSX feature matrix da verificare visivamente in Excel | P3 |

---

## J. Suggested next commits

1. `docs: update DIR DIVING documentation after Watch control strategy`
2. `docs: sync main-iOS documentation from main @ 72fa15b`

---

## K. Risks / assumptions

- **Assunzione:** `main` resta branch production-oriented; experimental resta isolato.
- **Rischio:** merge PR #8/#9 senza review può sovrascrivere UI MAIN o promuovere funzioni lab.
- **Rischio:** build Apple non verificabile da Windows; serve macOS con XcodeGen/Xcode.
- **Vincolo rispettato:** nessun cambiamento business logic nel pass documentale.
