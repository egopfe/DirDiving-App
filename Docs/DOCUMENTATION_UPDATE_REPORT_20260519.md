# Report aggiornamento documentazione DIR DIVING — 2026-05-19 (pass completo)

Documento di chiusura per allineamento **solo documentazione** dopo `git fetch origin`, ispezione branch locali/remoti e PR GitHub. Nessuna modifica a logica runtime richiesta da questa attività.

---

## A. File aggiornati

| File | Tipo modifica |
|------|----------------|
| `README.md` | Allineamento testuale MAIN iOS (tab **Analisi**, niente «Route Review» come tab separata su `main` unificato); matrice piattaforme `main-iOS`; sezioni readiness/audit. |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Righe additive (Return-to-entry snorkeling, waypoint/bearing); correzione riga Explore → Analisi; nota su Route Review vs Analisi; righe doc per nuovi report. |
| `CHANGELOG.md` | Voce `[Unreleased]` aggiornata per questo pass. |
| `CONTRIBUTING.md` | Nota operativa su PR conflittuali e commenti `gh pr`. |
| `Docs/DOCUMENTATION_SYNC_REPORT_20260519.md` | Riferimento backup branch e timestamp verifica PR. |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md` | Append operazioni 2026-05-19 (backup, commit docs-only). |
| `Docs/IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md` | Versionato (stato HEAD vs working tree). |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md` | Questo file (report A–K). |

Non sono stati eliminati file `.md` o `.docx` esistenti. File `.docx` non tracciati restano fuori dal commit (dimensione / policy repo).

---

## B. Branch ispezionati

- **Locali:** `main` (corrente), `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`, molti `backup/*`.
- **Remote (post-`git fetch origin`):** `origin/main`, `origin/main-iOS`, `origin/codex/experimental-features`, `origin/codex/ios-experimental-features`.

---

## C. Branch aggiornati (commit)

- **`main` (locale):** un commit **solo documentazione** (`docs: …`). Nessun merge da rami experimental verso `main` in questo pass.
- **Altri branch:** non modificati (nessun cherry-pick cross-branch automatico).

È stato creato il branch di sicurezza **`backup/before-docs-merge-20260519`** puntato a `HEAD` **prima** del commit documentazione.

---

## D. Conflitti trovati

- **PR #8** (`codex/experimental-features` → `main`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.

---

## E. Conflitti risolti

- **Nessuno** nel repository locale: non è stato eseguito merge delle PR (scope runtime + conflitti; rischio oltre documentazione).

---

## F. PR ispezionate

| PR | Titolo | Base | URL |
|----|--------|------|-----|
| **#8** | Update experimental Apnea workflow | `main` | `https://github.com/egopfe/DirDiving-App/pull/8` |
| **#9** | Add experimental Apnea companion review | `main-iOS` | `https://github.com/egopfe/DirDiving-App/pull/9` |

Entrambe includono molti file `.swift` e `project.yml`; #9 aggiunge anche asset e workflow CI.

---

## G. PR considerate *safe to merge* (automatico)

- **Nessuna** nello stato attuale (conflitti GitHub + modifiche runtime estese).

---

## H. PR che richiedono revisione manuale

- **#8:** risoluzione conflitti su macOS, `xcodegen generate`, build `DIRDiving Watch App`, QA Snorkeling Live / mappe / Apnea, verifica **BUSSOLA** e GPS surface-only, nessuna regressione Diving MAIN.
- **#9:** stesso tipo di verifica per iOS + base **`main-iOS`** (non `main`); allineare strategia se il prodotto vuole unificare verso `main` unificato.

È stato lasciato un **commento** sulle PR (via `gh pr comment`) con riepilogo stato e raccomandazione *non merge* finché i conflitti non sono risolti dal maintainer.

---

## I. Lacune documentali ancora aperte

- Esecuzione e annotazione build **macOS** (`xcodegen` + `xcodebuild`) in `Docs/RELEASE_CHECKLIST.md` o report dedicato.
- Eventuale file Excel `Branch_Functionality_Matrix.xlsx` presente solo in alcuni branch PR: su `main` la fonte resta **`Docs/DIR_DIVING_Feature_Comparison.csv`** finché l’Excel non viene aggiunto in modo non ridondante.
- Allineamento paragrafo-per-paragrafo `README` tra `main` e `main-iOS` se i branch divergono ancora sul companion.
- Chiusura **Definition of Done** iOS tab/target: commit runtime iOS ancora separato (vedi `Docs/IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`).

---

## J. Commit suggeriti (prossimi)

1. **`docs: update DIR DIVING feature documentation and branch matrix`** — questo pass (solo file in sezione A).
2. **`fix(ios): align ContentView and app entry with MAIN target`** — quando il team committa le modifiche Swift iOS non ancora su `HEAD`.
3. **`merge: …`** — solo dopo risoluzione manuale conflitti PR #8 / #9 e CI verde.

---

## K. Rischi / assunzioni

- L’agente non ha eseguito `xcodebuild` (ambiente Windows).
- I metadati PR sono stati letti con `gh pr view`; lo stato Actions potrebbe differire — da verificare su GitHub.
- **Assunzione:** le modifiche Swift/iOS nel working tree non committate restano responsabilità del team per commit dedicato; la documentazione le menziona dove pertinente (mismatch tab).
