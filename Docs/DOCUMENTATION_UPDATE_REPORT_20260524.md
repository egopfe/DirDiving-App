# DIR DIVING — Report aggiornamento documentazione (2026-05-24, post `f851b61`)

**Tipo:** Solo documentazione e allineamento Git. Nessun merge PR automatico. Nessuna modifica a GPS, BUSSOLA, calcoli immersione o persistenza modelli.

**HEAD `main`:** `f851b61` — development notes (unità sync, disclaimer launch, manual dives, foto Watch, checklist, Planner first tab, ecc.).

---

## A. File aggiornati

| File | Azione |
|------|--------|
| `README.md` | Sezione pass `f851b61`; tab iOS Planner prima; HEAD branch strategy |
| `CHANGELOG.md` | Voce Unreleased `f851b61` |
| `Docs/ROADMAP.md` | Feature rilasciate + backlog aggiornato |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Riga unità aggiornata + ~14 righe additive |
| `Docs/DIR_DIVING_MAIN_BRANCH_DEVELOPMENT_IMPLEMENTATION_REPORT.md` | Stato commit/push |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md` | **Nuovo** |
| `Docs/PR_STATUS_20260524.md` | **Nuovo** |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260524.md` | Questo file (aggiornato) |

**Non modificati in questo pass (già validi):** `project.yml`, `Docs/BUILD_VALIDATION.md`, `CONTRIBUTING.md`, spec Snorkeling/Apnea experimental.

---

## B. Branch ispezionati

| Branch | HEAD | Note |
|--------|------|------|
| `main` | `f851b61` | Allineato `origin/main` |
| `main-iOS` | `3994b33` | ~172 behind `main` — sync docs pianificato |
| `codex/experimental-features` | `6649335` | Watch experimental |
| `codex/ios-experimental-features` | `9e5baca` | iOS experimental |
| `backup/before-docs-merge-20260524-docs` | `f851b61` | Backup locale |

---

## C. Branch aggiornati (questo pass)

| Branch | Azione |
|--------|--------|
| `main` | Commit documentazione + push |
| `main-iOS` | Checkout file docs da `main` + commit + push |

---

## D. Conflitti trovati

| Contesto | Stato |
|----------|--------|
| PR #8 → `main` | CONFLICTING (documentale) |
| PR #9 → `main-iOS` | CONFLICTING (documentale) |
| `main` ↔ `main-iOS` runtime | Non tentato |

---

## E. Conflitti risolti

Nessuno in questo pass (solo documentazione lineare su `main`).

---

## F. PR ispezionate

| PR | Branch | Base |
|----|--------|------|
| #8 | `codex/experimental-features` | `main` |
| #9 | `codex/ios-experimental-features` | `main-iOS` |

---

## G. PR safe to merge

**Nessuna** senza review manuale, build macOS e verifica `project.yml` excludes.

---

## H. PR requiring manual review

- **#8** — rischio inclusione Snorkeling/Apnea/Buddy in MAIN; verificare conflitti con `f851b61` units sync e Diving UI.
- **#9** — rischio regressioni security export/import CSV; allineare a `main` F4/F5 prima del merge.

---

## I. Gap documentazione aperti

- `Docs/Branch_Functionality_Matrix.xlsx` — rigenerare manualmente da CSV se usato esternamente.
- AppIcon App Store da `Docs/ReferenceIcon/apple watch icon.png` / `ios icon.png`.
- Watch back navigation audit su tutte le sub-screen.
- Convergenza **runtime** `main-iOS` ↔ `main` (processo separato dalla docs).
- Alcune righe Settings/InfoView Watch ancora IT letterali (LOW i18n).

---

## J. Commit eseguiti / suggeriti

1. `docs: update feature documentation and branch matrix post f851b61` — `main`
2. `docs: sync documentation from main @ f851b61` — `main-iOS`

---

## K. Rischi e assunzioni

- Stato PR **CONFLICTING** basato su report precedenti + divergenza branch; **non** verificato con `gh` (CLI assente).
- Documentazione descrive unità imperiali come **display**; export Subsurface e storage restano metrici.
- Snorkeling Live / Waypoint Map / Return Map restano **solo** su rami experimental — non documentati come MAIN production.

---

_Report generato in pass documentazione post-push codice `f851b61`._
