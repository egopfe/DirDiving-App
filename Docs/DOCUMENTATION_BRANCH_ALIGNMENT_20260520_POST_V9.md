# Allineamento branch documentazione (post v9)

**Baseline `main`:** `d962117`  
**Fetch:** `git fetch --all --prune`  
**Nessun force-push.** **Nessun merge PR automatico.**

---

## Branch ispezionati

| Branch | HEAD | Divergenza vs `main` | Documentazione |
|--------|------|----------------------|----------------|
| `main` | `d962117` | canonico | Sorgente |
| `main-iOS` | `e3b733a` | 202 behind / 46 ahead | Sync docs da `main` |
| `origin/codex/experimental-features` | `6649335` | 66 behind / 28 ahead | Sync docs; codice experimental invariato |
| `origin/codex/ios-experimental-features` | `9e5baca` | 113 behind / 59 ahead | Sync docs |
| `backup/before-docs-merge-20260520-post-v9` | `d962117` | snapshot pre-pass | Backup |

---

## Branch Strategy (riepilogo)

| Branch | Ruolo |
|--------|--------|
| **`main`** | Stabile production-oriented: Diving + companion iOS; `project.yml` esclude Apnea/Snorkeling/Buddy |
| **`main-iOS`** | Storico parallelo iOS; allineare documentazione; merge codice solo con review esplicita |
| **`codex/experimental-features`** | Watch: Snorkeling Live, mappe waypoint/ritorno, Apnea, Buddy |
| **`codex/ios-experimental-features`** | iOS: Explore Lab, mappe, POI enrichment |

Regole:

1. UI-only non altera GPS, **BUSSOLA**, calcoli profondità/risalita, persistenza.
2. Ogni merge verso `main` preserva Diving mode e security F1–F12.
3. Terminologia **BUSSOLA** (mai COMPASSO).
4. GPS surface-only su MAIN; Return-to-entry snorkeling solo experimental.

---

## `main-iOS`

| Aspetto | Raccomandazione |
|---------|-----------------|
| Documentazione | `git checkout main -- README.md CHANGELOG.md CONTRIBUTING.md Docs/...` (file elencati nel commit sync) |
| Runtime | **Non** merge automatico — 202 commit behind; conflitti storici su import/sync/planner |

---

## PR

Vedi [`PR_STATUS_20260520_POST_V9.md`](PR_STATUS_20260520_POST_V9.md).

---

_Vedi [`DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md`](DOCUMENTATION_UPDATE_REPORT_20260520_POST_V9.md)._
