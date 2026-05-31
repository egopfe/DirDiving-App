# DIR DIVING — Report aggiornamento documentazione (2026-05-24, post `bd129ca`)

**Tipo:** Solo documentazione e allineamento Git. Nessun merge PR automatico. Nessuna modifica a GPS, BUSSOLA, calcoli immersione o persistenza modelli.

**HEAD `main`:** `bd129ca` — include `62e25d5` (R2–R4 + audit), `db72dce`, `876bcd2`, `f851b61`, readiness pass.

---

## A. File aggiornati

| File | Azione |
|------|--------|
| `README.md` | Pass audit `876bcd2`→`bd129ca`; HEAD branch strategy; onboarding/modalità/i18n; nota regressione log depth `3b7358b` |
| `CHANGELOG.md` | Voce Unreleased post-readiness |
| `Docs/ROADMAP.md` | HEAD `bd129ca`; R2–R4; P0 R1; P1 log unità |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | ~18 righe additive (876bcd2, db72dce, 62e25d5, PR status, log depth TODO) |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260524.md` | Baseline `bd129ca`; tabella R2–R4 |
| `Docs/PR_STATUS_20260524.md` | Baseline `bd129ca` |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260524.md` | Questo file |

**Non modificati:** `project.yml`, algoritmi runtime, spec experimental (salvo cross-ref).

---

## B. Branch ispezionati

| Branch | HEAD (fetch) | Note |
|--------|--------------|------|
| `main` | `bd129ca` | Canonico Watch+iOS unificato |
| `main-iOS` | divergente | Sync **solo** documentazione da `main` |
| `origin/codex/experimental-features` | ~46 behind / ~28 ahead vs `main` | Snorkeling/Apnea/Buddy |
| `origin/codex/ios-experimental-features` | vs `main-iOS` | Explore Lab |
| `backup/before-docs-merge-20260524-post-readiness` | snapshot pre-pass | Backup locale |

---

## C. Branch aggiornati (questo pass)

| Branch | Azione |
|--------|--------|
| `main` | Commit documentazione + push |
| `main-iOS` | `git checkout main --` docs paths + commit + push |

---

## D. Conflitti trovati

| Contesto | Stato |
|----------|--------|
| PR #8 → `main` | CONFLICTING — non mergeato |
| PR #9 → `main-iOS` | CONFLICTING — non mergeato |
| `main` ↔ `main-iOS` runtime | Non tentato |

---

## E. Conflitti risolti

Nessuno (pass solo documentazione).

---

## F. PR ispezionate

| PR | Head | Base | Raccomandazione |
|----|------|------|-----------------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` | `main` | **Review manuale** — non auto-merge |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` | `main-iOS` | **Review manuale** — ripristinare F4/F5 da `main` |

Dettaglio: [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md).

---

## G. PR safe to merge

**Nessuna** senza build macOS, verifica `project.yml` excludes e QA Diving/BUSSOLA/GPS.

---

## H. PR requiring manual review

- **#8** — rischio promozione Snorkeling/Apnea/Buddy in MAIN; conflitti con unità sync, banner risalita, security F1–F12.
- **#9** — regressioni export `.completeFileProtection` e bound CSV documentate in security audit.

---

## I. Documentation gaps still open

| Gap | Priorità |
|-----|----------|
| R1 validazione Ultra + entitlement Apple | P0 |
| i18n Planner / Equipment / messaggi runtime import | P2 |
| Ripristino unità lista log Watch (`3b7358b`) | P1 |
| Convergenza runtime `main-iOS` ↔ `main` | P2 (non solo docs) |
| GPX/KML/.ssrf export | P3 |
| AppIcon da `Docs/ReferenceIcon/` | P3 |

---

## J. Suggested next commits

1. `docs: sync main-iOS documentation from main @ bd129ca` (se non già pushato)
2. `fix(watch): restore imperial depth labels in dive log list` (opzionale — solo display)
3. QA sign-off `TESTFLIGHT_ENTITLEMENT_AND_DEVICE_QA` con data/device

---

## K. Risks / assumptions

- **Assunzione:** PR #8/#9 restano CONFLICTING fino a risoluzione manuale su macOS.
- **Assunzione:** `gh` CLI non disponibile in CI agent; URL PR verificati da documentazione storica.
- **Rischio:** merge PR #8 in `main` senza excludes → inclusione target Snorkeling in produzione.
- **Rischio:** `main-iOS` runtime divergente anche dopo sync docs — utenti non devono confondere branch per build release.

---

_Contenuti documentati: onboarding legale + disclaimer companion; Diving MAIN; Snorkeling/Apnea experimental; BUSSOLA; GPS surface-only; export Subsurface CSV; sync Watch↔iOS; iCloud KVS; i18n IT/EN; UI reference `Docs/ReferenceUI/`._
