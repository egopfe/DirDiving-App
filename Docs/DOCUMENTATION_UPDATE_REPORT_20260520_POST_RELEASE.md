# Documentation update report — post-release alignment (2026-05-20)

Report strutturato A–K dopo implementazione MAIN (`a75a6c3`), pass i18n secondario e allineamento documentazione.

---

## A. Files updated

| File | Azione |
|------|--------|
| `README.md` | Backlog → Implemented; i18n; link TestFlight/safety/roadmap |
| `CHANGELOG.md` | Voci Unreleased 2026-05-20 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Stati UX backlog; righe i18n/P0/docs |
| `Docs/SAFETY_DISCLAIMER.md` | **Nuovo** (IT) |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | **Nuovo** |
| `Docs/ROADMAP.md` | **Nuovo** |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md` | Aggiornato (questo pass) |
| `Resources/*.lproj`, `iOSApp/Resources/*.lproj` | i18n (commit separato) |
| Servizi/views i18n | commit separato `fix(i18n)` |

## B. Branches inspected

| Branch | Remote | Note |
|--------|--------|------|
| `main` | `origin/main` | HEAD include `a75a6c3`+ docs; i18n locale uncommitted → committed |
| `main-iOS` | `origin/main-iOS` | `79bad65` tombstone iOS |
| `codex/experimental-features` | yes | +15 / -26 vs main (approx) |
| `codex/ios-experimental-features` | yes | +62 / -57 vs main-iOS |
| `backup/main-watch-backlog-20260519` | local | storico |
| `backup/before-docs-merge-20260520` | local | safety |

## C. Branches updated

- **`main`**: commit i18n + commit docs (questo pass).
- **`main-iOS`**: allineamento doc CSV/README/CHANGELOG consigliato (copy da `main` senza toccare codice iOS se già allineato).

## D. Conflicts found

- **PR #8** (`codex/experimental-features` → `main`): 40 file, 26 commit — overlap su `WatchSyncService`, views experimental vs MAIN exclusions.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): 95 file, 116 commit — regressioni security note (F4/F5 export/import).
- Nessun merge automatico eseguito.

## E. Conflicts resolved

- Nessun merge PR in questo pass (documentazione only).
- Backlog Watch già risolto su `main` via port manuale `a75a6c3` (non cherry-pick).

## F. PRs inspected

| PR | Branch | Base | File | Commit |
|----|--------|------|------|--------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` | `main` | ~40 | 26 |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` | `main-iOS` | ~95 | 116 |

## G. PRs safe to merge

**Nessuna** senza review manuale e risoluzione conflitti su macOS.

## H. PRs requiring manual review

- **#8**: isolare Snorkeling/Apnea/Buddy; non sovrascrivere F1–F12; non importare file esclusi da `project.yml` nel target MAIN.
- **#9**: ripristinare `.completeFileProtection` export iOS e bound CSV prima di merge verso MAIN.

## I. Documentation gaps still open

- Validazione entitlement profondità su Ultra reale (checklist `RELEASE_CHECKLIST.md`).
- `DiveImportService` error strings → `NSLocalizedString` follow-up.
- PlanResultView / planner warning strings EN parziali.
- Convergenza strutturale `main` vs `main-iOS` worktree.
- PR body/description update on GitHub (richiede `gh` CLI o UI).

## J. Suggested next commits

1. `fix(i18n): secondary EN/IT coverage for Watch and iOS MAIN` (già preparato)
2. `docs: update DIR DIVING feature documentation and branch matrix` (questo pass)
3. Opzionale: `docs(main-iOS): sync feature matrix from main`

## K. Risks and assumptions

- **Assunzione**: `a75a6c3` su `origin/main` è la baseline code post-backlog; documentazione allineata di conseguenza.
- **Rischio**: merge PR #8/#9 senza policy conservativa può reintrodurre file experimental nel target MAIN o regressioni security iOS.
- **gh CLI** non disponibile in ambiente agent; stato PR da API GitHub + git fetch.
- Nessuna modifica a GPS, bussola, calcoli immersione, planner math in questo pass.

---

*2026-05-20 · additive documentation only*
