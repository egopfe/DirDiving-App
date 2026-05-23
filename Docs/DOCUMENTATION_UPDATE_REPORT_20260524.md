# DIR DIVING — Report aggiornamento documentazione (2026-05-24)

**Tipo:** Allineamento documentazione + commit readiness UX + push `main`. Nessun merge PR automatico. Nessuna modifica GPS/BUSSOLA/calcoli.

---

## A. File aggiornati

| File | Azione |
|------|--------|
| `README.md` | Pass `6cda004`, readiness 100% UX, bundle `.ios.watch`, branch strategy |
| `CHANGELOG.md` | Voci 2026-05-24 e depth safety |
| `Docs/ROADMAP.md` | Feature completate readiness pass |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | ~15 righe additive |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260523.md` | HEAD `6cda004` |
| `Docs/PR_STATUS_20260523.md` | Baseline PR invariata |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260524.md` | Questo file |
| `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | Già aggiornato nel pass UX |
| `Docs/TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA_20260523.md` | Già presente |
| `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_20260523.md` | Già presente |

**Codice (commit separato):** `CSVImportPanel.swift`, Logbook, More, Planner, Settings Watch, DiveLogListView, legal onboarding, Localizable.strings.

---

## B. Branch ispezionati

| Branch | HEAD (fetch 2026-05-24) | Note |
|--------|-------------------------|------|
| `main` | `6cda004` | Allineato con `origin/main` |
| `main-iOS` | diverge ~168 behind / 43 ahead vs `main` | Solo sync docs consigliato |
| `codex/experimental-features` | `6649335` | Snorkeling/Apnea/Buddy isolati |
| `codex/ios-experimental-features` | `9e5baca` | Explore Lab iOS |
| `backup/before-docs-merge-20260524-readiness` | snapshot pre-commit | Backup locale |

---

## C. Branch aggiornati

| Branch | Azione |
|--------|--------|
| `main` | Commit UX + docs + `git push origin main` |
| `main-iOS` | **Non merge automatico** — copiare manualmente `Docs/*`, `README.md`, `CHANGELOG.md` da `main` se desiderato |

---

## D–E. Conflitti

| Contesto | Stato |
|----------|--------|
| PR #8 | CONFLICTING — non merge |
| PR #9 | CONFLICTING — non merge |
| `main-iOS` runtime merge | Non tentato |

Nessun conflitto risolto in questo pass (solo `main` lineare).

---

## F–H. PR

| PR | Safe auto-merge | Motivo |
|----|-----------------|--------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | **No** | Experimental Watch in MAIN target |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | **No** | Regressioni security note iOS experimental |

**Manual checks:** `project.yml` excludes, build Watch+iOS, BUSSOLA, GPS surface-only, F1–F12.

---

## I. Gap documentazione aperti

- `Docs/Branch_Functionality_Matrix.xlsx` — rigenerare da CSV manualmente.
- Shortcut help Watch / alcune righe InfoView ancora IT letterali (LOW).
- Validazione entitlement Ultra su device reale (checklist esterna).
- Convergenza runtime `main-iOS` ↔ `main` (processo, non docs).

---

## J. Commit suggeriti (eseguiti su `main`)

1. `feat(main): readiness 100% UX — import, planner UI, legal scroll, i18n`
2. `docs: update feature matrix and branch alignment post readiness pass`

---

## K. Rischi / assunzioni

- `gh` CLI non disponibile in ambiente agent: stato PR da file `PR_STATUS_20260523.md` e fetch Git.
- Build iOS/Watch verificate su macOS named simulators nel pass UX precedente.
- Nessuna validazione entitlement Apple Developer portal in questo pass.

---

*Report A–K — 2026-05-24*
