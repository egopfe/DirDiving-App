# DIR DIVING — Report aggiornamento documentazione (2026-05-23)

**Tipo:** Solo documentazione + push Git (nessun merge PR automatico, nessuna modifica algoritmi).

---

## A. File aggiornati

| File | Azione |
|------|--------|
| `README.md` | Sezione pass production readiness `5e595ee`; nota HEAD `main` vs `main-iOS` |
| `CHANGELOG.md` | Voce 2026-05-23 |
| `Docs/ROADMAP.md` | Stato feature completate nel pass 2026-05-23 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Righe additive (sync iOS→Watch, conflitti UI, i18n, build, report) |
| `Docs/PR_STATUS_20260523.md` | Nuovo |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md` | Nuovo |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260523.md` | Questo file |
| `Docs/MAIN_BRANCH_ISSUES_AND_PRIORITIES_20260520.md` | Nota stato risoluzione (additiva in cima) |

**Già presenti (non riscritti):** `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`, `Docs/UI_UX_VISUAL_GUIDELINES.md`, `Docs/SNORKELING_EXPERIMENTAL_SPEC.md`, `Docs/APNEA_EXPERIMENTAL_SPEC.md`, `Docs/EXPERIMENTAL_FEATURES.md`, `Docs/GLOSSARY.md`.

**XLSX:** `Docs/Branch_Functionality_Matrix.xlsx` — non modificato in questo pass (CSV è fonte tabellare aggiornata; rigenerare XLSX manualmente da CSV se necessario).

---

## B. Branch ispezionati

| Branch | HEAD remoto (fetch 2026-05-23) | Note |
|--------|-------------------------------|------|
| `main` | `9b61e55` remote; locale `5e595ee` (+1 commit production readiness) | Workspace unificato Watch+iOS |
| `main-iOS` | `1cc6203` | Dietro `main` per codice unificato; allineamento docs pianificato |
| `codex/experimental-features` | `6649335` | Watch experimental |
| `codex/ios-experimental-features` | `9e5baca` | iOS experimental |
| `backup/before-docs-merge-20260523` | creato da `main` | Backup pre-push docs |

---

## C. Branch aggiornati (documentazione)

| Branch | Azione |
|--------|--------|
| `main` | Commit docs + push `origin/main` (include `5e595ee` code + docs) |
| `main-iOS` | Checkout file `Docs/*`, `CHANGELOG.md`, `README.md` da `main` (solo docs) + push se diverso |

**Nessun merge** di `codex/*` in `main`.

---

## D. Conflitti trovati

| Contesto | Stato |
|----------|--------|
| PR #8 → `main` | **CONFLICTING** (documentato 202605-22/23) |
| PR #9 → `main-iOS` | **CONFLICTING** |
| `main-iOS` merge preview vs `main` | Conflitti attesi in runtime iOS + docs — **non risolti** in questo pass |

---

## E. Conflitti risolti

| Contesto | Risoluzione |
|----------|-------------|
| Documentazione `main` | Nessun conflitto attivo nel worktree |
| Merge PR experimental | **Nessuno** (per policy) |

---

## F. PR ispezionate

| PR | Branch → base | Raccomandazione |
|----|---------------|-----------------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` → `main` | **Manual review — non mergeare automaticamente** |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` → `main-iOS` | **Manual review — non mergeare automaticamente** |

Dettaglio: [`Docs/PR_STATUS_20260523.md`](PR_STATUS_20260523.md).

---

## G. PR safe to merge

**Nessuna** senza review macOS, build Watch+iOS, verifica `project.yml` excludes e regressioni security F4/F5 (iOS).

---

## H. PR requiring manual review

- **#8** — rischio import view experimental nel target MAIN; overlap `WatchSyncService`.
- **#9** — rischio regressioni export protection e CSV bounds vs `main`.

---

## I. Documentation gaps still open

- `main-iOS` non contiene commit `5e595ee` (codice production readiness solo su `main` unificato).
- XLSX matrix non rigenerato da CSV in questo pass.
- Terminologia snorkeling/apnea: coperta in `Docs/SNORKELING_EXPERIMENTAL_SPEC.md` / `EXPERIMENTAL_FEATURES.md` — non duplicata integralmente in README (link alla matrice CSV).
- Validazione build su macOS: confermata localmente per `5e595ee`; non ripetuta in questo pass doc-only.

---

## J. Suggested next commits

1. `docs: update DIR DIVING feature documentation and branch matrix` — **questo pass**
2. Dopo merge manuale `main` → `main-iOS`: `docs: sync main-iOS documentation from unified main`
3. Non eseguire `merge PR #8/#9` finché CONFLICTING

---

## K. Rischi e assunzioni

- **Assunzione:** repository GitHub `egopfe/DirDiving-App` — API PR non disponibile senza token (`gh` assente); stato PR da documentazione 202605-22.
- **Assunzione:** italiano primario per nuovi paragrafi README/ROADMAP salvo file già in inglese.
- **Rischio:** utenti che buildano solo da `main-iOS` worktree non ricevono fix sync `5e595ee` finché non allineano al workspace `main`.

---

*Generato: 2026-05-23 · DIR DIVING documentation pass*
