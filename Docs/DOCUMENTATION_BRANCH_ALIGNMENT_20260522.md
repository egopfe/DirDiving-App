# Allineamento documentazione e branch - 2026-05-22

## A. Scope

Pass di allineamento dopo `git fetch --all --prune` del 2026-05-22. Obiettivo: preservare la documentazione piu recente, aggiornare lo stato branch/PR e non modificare logica runtime salvo merge gia presente su `origin/main`.

## B. Repository ispezionato

- Checkout principale: `C:\Users\egopf\Documents\GitHub\DirDiving-App`.
- Branch corrente: `main`.
- Worktree branch: `codex/experimental-features`, `codex/ios-experimental-features`, `main-iOS`.

## C. Branch ispezionati

| Branch | Stato dopo fetch | Azione |
|--------|------------------|--------|
| `main` | local ahead dopo merge `origin/main` | Merge completato; conflitti solo docs |
| `main-iOS` | local ahead 2 / behind 10 | Non mergeato: conflitti runtime e docs da review manuale |
| `codex/experimental-features` | behind 1 | Fast-forward a `origin/codex/experimental-features` |
| `codex/ios-experimental-features` | behind 2 | Fast-forward a `origin/codex/ios-experimental-features` |

## D. Conflitti trovati

Merge `origin/main` -> `main`:

- `Docs/SAFETY_DISCLAIMER.md`: add/add.
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`: add/add.

Preview `main-iOS` -> `origin/main-iOS`:

- Conflitti documentali: `README.md`, `Docs/DIR_DIVING_Feature_Comparison.csv`.
- Conflitti runtime: `iOSApp/Services/DiveImportService.swift`, `iOSApp/Services/WatchSyncService.swift`, `iOSApp/Views/AnalysisView.swift`, `iOSApp/Views/DiveDetailView.swift`, `iOSApp/Views/MoreView.swift`, `iOSApp/Views/PlannerView.swift` e componenti UI.

## E. Conflitti risolti

- `Docs/SAFETY_DISCLAIMER.md`: mantenuta versione IT completa da `origin/main`, integrata con nota local-only che DIR DIVING e companion/logging tool e non life-support.
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`: mantenuta versione IT completa da `origin/main`, integrata con riepilogo feature local-only da commit locale.

## F. PR ispezionate

| PR | Branch | Stato GitHub | Raccomandazione |
|----|--------|--------------|-----------------|
| #8 - Update experimental Apnea workflow | `codex/experimental-features` -> `main` | `CONFLICTING`, `DIRTY` | Non safe-to-merge automatico |
| #9 - Add experimental Apnea companion review | `codex/ios-experimental-features` -> `main-iOS` | `CONFLICTING`, `DIRTY` | Non safe-to-merge automatico |

## G. PR safe to merge

Nessuna PR aperta e risultata safe-to-merge automaticamente.

## H. PR da review manuale

- PR #8: verificare target membership `project.yml`, esclusione Apnea/Snorkeling/Buddy dal MAIN, preservazione banner risalita inline, GPS surface-only, BUSSOLA e sync security F1-F12.
- PR #9: risolvere regressioni note F4/F5 su export/import iOS e conflitti `main-iOS` prima di merge.

## I. Gap documentali aperti

- Allineare `main-iOS` con `origin/main-iOS` in un pass dedicato, con revisione runtime iOS.
- Completare i18n residua planner/GPS detail/import CSV.
- Eseguire validazione XcodeGen/Xcode su macOS e test Apple Watch Ultra reale per entitlement depth.
- Tenere PR #8/#9 isolate finche non hanno rebase/merge conflict resolution documentata.

## J. Commit suggeriti

- `docs: update DIR DIVING feature documentation and branch matrix`
- `merge: resolve documentation conflicts across branches`
- `docs: record 20260522 branch alignment and PR status`

## K. Rischi e assunzioni

- Nessuna modifica deliberata a GPS, algoritmi BUSSOLA, calcoli profondita/risalita, planner/decompressione o modelli di persistenza.
- `origin/main` contiene gia modifiche runtime precedenti; questo pass le ha solo integrate tramite merge conservativo.
- `main-iOS` non e stato mergeato perche la preview mostra conflitti runtime dove la scelta corretta richiede QA dedicata.

## Aggiornamento successivo - onboarding legale 2026-05-22

Dopo il commit `Add legal onboarding disclaimer flow`, i quattro branch principali risultano allineati ai rispettivi remoti e includono:

- flusso first-launch Welcome / Safety Warning / Legal Disclaimer / Acceptance;
- disclaimer completo IT/EN nel bundle Watch e iOS;
- storage locale accettazione con timestamp, versione, major version, device type, lingua e legal revision;
- sezione `Legal & Safety` in Settings/More.

Il pass documentale successivo e registrato in [`Docs/DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md`](DOCUMENTATION_UPDATE_REPORT_20260522_LEGAL_ONBOARDING.md). Le PR #8 e #9 restano aperte, `CONFLICTING` e non safe-to-merge automaticamente.
