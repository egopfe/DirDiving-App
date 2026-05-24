# Report aggiornamento documentazione (post v9)

**Data:** 2026-05-20  
**Baseline `main`:** `d962117`  
**Tipo pass:** solo documentazione (nessuna modifica runtime)

---

## A. File aggiornati

| File | Azione |
|------|--------|
| `README.md` | Panoramica bilingue, stato `d962117`, Branch Strategy, User Images v9, link PRODUCT_FEATURES_IT |
| `Docs/INDEX.md` | HEAD `d962117`, link report post-v9 e PRODUCT_FEATURES_IT |
| `Docs/PRODUCT_FEATURES_IT.md` | **Nuovo** — panoramica funzioni IT |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Righe additive v8/v9 + docs post-v9 |
| `CHANGELOG.md` | Sezioni v8, v9, docs post-v9 |
| `Docs/ROADMAP.md` | HEAD `d962117`, voci v8/v9 rilasciate |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260520_POST_V9.md` | **Nuovo** |
| `Docs/PR_STATUS_20260520_POST_V9.md` | **Nuovo** |
| `CONTRIBUTING.md` | Invariato (già allineato) |

---

## B. Contenuto documentato

- Onboarding legale + disclaimer companion + limiti profondità
- Diving MAIN (Watch): live, BUSSOLA, GPS surface-only, log, export, allarmi, control strategy
- Snorkeling / Apnea / Buddy: solo branch experimental
- iOS companion: 5 tab, planner gas v8, equipment template GAS, foto→Watch, sync
- v9: User Images sempre in superficie; sync Planner/Bühlmann su input
- Design system, i18n IT/EN, Subsurface export, limitazioni, roadmap

---

## C. Branch ispezionati

| Branch | HEAD | vs `main` |
|--------|------|-----------|
| `main` | `d962117` | — |
| `main-iOS` | `e3b733a` | 46 ahead / 202 behind |
| `origin/codex/experimental-features` | `6649335` | 28 ahead / 66 behind |
| `origin/codex/ios-experimental-features` | `9e5baca` | 59 ahead / 113 behind |

---

## D. Branch aggiornati (documentazione)

- `main`: commit docs (questo pass)
- `main-iOS`, experimental: sync file documentali da `main` (commit separato `docs: sync documentation from main @ d962117`)

---

## E–F. Conflitti

- **Nessun conflitto** risolto su codice runtime in questo pass.
- Merge runtime `main` → `main-iOS` **non** eseguito (divergenza ampia).

---

## G–H. PR

| PR | Merge safe? | Nota |
|----|-------------|------|
| #8 Watch experimental → `main` | **No** | CONFLICTING; fuori target MAIN |
| #9 iOS experimental → `main-iOS` | **No** | CONFLICTING; rischi security F4/F5 |

Dettaglio: [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md).

---

## I. Gap documentali aperti

- i18n residuo Planner/Equipment/messaggi runtime import
- Lista log Watch profondità in `m` fisso (regressione display unità)
- Validazione entitlement Ultra reale (R1)
- Convergenza **codice** `main-iOS` ↔ `main` (solo docs sincronizzati)

---

## J. Commit suggeriti

1. `main`: `docs: update DIR DIVING feature documentation and branch matrix post v9`
2. `main-iOS` / experimental: `docs: sync documentation from main @ d962117`

---

## K. Rischi e assunzioni

- `gh` CLI non disponibile in ambiente agente; stato PR da documentazione storica + policy invariata.
- Nessuna modifica a GPS, bussola, calcoli immersione, persistenza, algoritmo Bühlmann.
- `project.yml` e bundle ID non modificati.
