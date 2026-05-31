# Allineamento branch documentazione (2026-05-24)

**Baseline `main`:** `bd129ca` — merge post `62e25d5` (readiness R2–R4), `db72dce`, `876bcd2`.  
**Fetch:** `origin` aggiornato in questo pass. **Nessun force-push.** **Nessun merge PR automatico.**

---

## A. Branch ispezionati

| Branch | HEAD | Divergenza vs `main` (rev-list) | Azione documentazione |
|--------|------|----------------------------------|------------------------|
| `main` | `bd129ca` | — | Sorgente canonica Watch+iOS unificato |
| `main-iOS` | `3994b33` | ~172 behind / ~44 ahead | Sync **solo** file docs da `main` (commit dedicato) |
| `origin/codex/experimental-features` | `6649335` | ~36 behind / ~28 ahead | Mantenere doc experimental; non merge in `main` |
| `origin/codex/ios-experimental-features` | `9e5baca` | vs `main-iOS` | Mantenere Explore Lab isolato |
| `backup/before-docs-merge-20260524-docs` | `f851b61` | snapshot | Backup pre-pass documentazione |

---

## B. Regole merge (invariate)

1. Codice buildabile e Diving stabile su `main`.
2. UI master reference e Snorkeling Live / Waypoint / Return Map **solo** su rami experimental.
3. Terminologia **BUSSOLA** (mai COMPASSO).
4. GPS surface-only; Return-to-entry snorkeling solo experimental.
5. Allineamenti UI-only **non** alterano GPS, bussola, calcoli immersione, persistenza modelli.

---

## C. `main-iOS` — runtime vs documentazione

| Aspetto | Stato |
|---------|--------|
| Documentazione README/CSV/Docs | Allineabile da `main` senza toccare codice |
| Codice runtime iOS/Watch | **Divergente** — merge runtime non eseguito (~27 file in conflitto su dry-run storico) |
| Raccomandazione | Copiare docs; merge codice solo con review esplicita e QA F1–F12 |

---

## D. PR aperte

| PR | Base | Head | Merge | Note |
|----|------|------|-------|------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `main` | `codex/experimental-features` | **No** | CONFLICTING — Snorkeling/Apnea/Buddy fuori target MAIN |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `main-iOS` | `codex/ios-experimental-features` | **No** | CONFLICTING — regressioni security note su export/import |

Dettaglio: [`PR_STATUS_20260524.md`](PR_STATUS_20260524.md).

---

## E. Commit suggeriti (questo pass)

1. `main`: `docs: update feature matrix and branch alignment post bd129ca`
2. `main-iOS`: `docs: sync documentation from main @ bd129ca`

## F. Chiusura readiness audit (R2–R4)

| ID | Stato su `main` @ `62e25d5`+ |
|----|------------------------------|
| R2 Planner ack persistito | ✅ `PlannerSafetyAcknowledgment` |
| R3 iCloud decode UI | ✅ `CloudSyncStore.lastDecodeError` |
| R4 i18n Logbook/Detail/Analysis | 🟡 Parziale; Planner/Equipment aperti |
| R1 Ultra depth QA | ⏳ Hardware / entitlement — vedi TESTFLIGHT_ENTITLEMENT doc |

---

_Vedi anche [`DOCUMENTATION_UPDATE_REPORT_20260524.md`](DOCUMENTATION_UPDATE_REPORT_20260524.md)._
