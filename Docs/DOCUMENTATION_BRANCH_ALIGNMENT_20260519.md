# DIR DIVING — Allineamento documentazione 2026-05-19

## Scopo

Aggiornamento **additivo** dopo `git fetch origin` e ispezione PR aperte. Nessuna modifica a logica GPS, bussola, calcoli immersione, modelli di persistenza o architettura.

## Stato remote

- `origin/codex/ios-experimental-features` avanzato (commit recenti rispetto al fetch precedente).

## README e CSV

- `README.md`: strategia branch, matrice CSV, sezione 19 maggio.
- `Docs/DIR_DIVING_Feature_Comparison.csv`: nuove righe documentazione; nota PR #8/#9 aggiornata; riga «Stable tab set» chiarita per tab a cinque voci su `main`.

## PR

- #8 e #9 restano **CONFLICTING** — nessun merge da questo pass.

## Prossimi passi (manuali)

1. macOS: build + checklist.  
2. Maintainer: risolvere conflitti PR con priorità documentata nel README (Diving stabile, UI master, snorkeling maps, documentazione).

---

## Aggiornamento 2026-05-19 (secondo pass)

- Creato branch di sicurezza **`backup/before-docs-merge-20260519`** da `HEAD` immediatamente prima del commit solo-documentazione.
- Report aggiuntivo strutturato: [`DOCUMENTATION_UPDATE_REPORT_20260519.md`](DOCUMENTATION_UPDATE_REPORT_20260519.md).
- Versionato [`IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md`](IOS_TAB_TARGET_MISMATCH_STATUS_20260519.md) (stato mismatch tab iOS vs `project.yml`).
- Commit **`docs: update DIR DIVING feature documentation and branch matrix`**: solo `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `Docs/DIR_DIVING_Feature_Comparison.csv`, file di report in `Docs/` elencati nel report di cui sopra — **nessun** file `.swift` o `project.yml` in questo commit.
- PR **#8** e **#9**: commento GitHub aggiunto con riepilogo *non safe-to-merge* automatico; merge lasciato al maintainer dopo risoluzione conflitti su macOS.
