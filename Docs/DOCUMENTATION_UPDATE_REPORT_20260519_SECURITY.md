# Report aggiornamento documentazione DIR DIVING — 2026-05-19 (pass security)

Pass **solo documentazione** dopo i commit di security audit + remediation su `main`:

- `c9b9802` — *docs: add information security audit for main and main-iOS*
- `4136ec0` — *fix(security): apply audit findings F1-F12 on MAIN*

Nessuna logica runtime modificata in questo pass: si aggiornano README, matrice CSV, CHANGELOG e si chiude il giro con report A–K + commento di stato sulle PR aperte.

---

## A. File aggiornati

| File | Tipo modifica |
|------|----------------|
| `README.md` | Nuova sezione **Sicurezza e sync (security baseline 2026-05-19)** con sintesi finding e remediation F1–F12. |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | 13 righe additive (categoria **Security**) per audit + ciascuna remediation F1–F12 + follow-up F11 + regressioni note su `main-iOS` (F4/F5). |
| `CHANGELOG.md` | Voce *2026-05-19, pass documentazione security* nel blocco Unreleased. |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md` | Questo file. |

> File runtime già committati nel commit `4136ec0` non sono stati toccati in questo pass: `Services/WatchSyncAuth.swift`, `iOSApp/Services/WatchSyncAuth.swift`, `Services/WatchDiveSyncCodec.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift`, `Services/WatchSyncService.swift`, `iOSApp/Services/WatchSyncService.swift`, `Services/SubsurfaceExportService.swift`, `iOSApp/Services/DiveImportService.swift`, `Services/DiveLogStore.swift`, `Services/AscentRateSettingsStore.swift`, `Utils/WatchSyncNotifications.swift`, `iOSApp/Utils/WatchSyncNotifications.swift`.

---

## B. Branch ispezionati

- **Locali:** `main` (corrente, HEAD `4136ec0`), `main-iOS`, vari `backup/*` (incluso il nuovo **`backup/before-docs-merge-20260519-security`** creato prima di questo pass).
- **Remoti (post-`git fetch`):** `origin/main` allineato a `4136ec0`. `origin/main-iOS` ha 5 commit avanti rispetto a `origin/main` (HEAD `06057d7` — *Add iOS language selector localization support*, poi `899f6ce`, `168a27e`, `e8d4bbe`, `442defa`).
- **PR remote ancora aperte:** `codex/experimental-features` (PR #8), `codex/ios-experimental-features` (PR #9).

---

## C. Branch aggiornati (commit)

- **`main`:** commit di documentazione (`docs: …`) sui file della sezione A.
- **Altri branch:** non modificati. La security baseline non è stata propagata sui rami sperimentali in questo pass (scope esplicito MAIN). I rami `codex/*` resteranno indietro fino a un eventuale merge `main → codex/*` manuale.

Backup creato: **`backup/before-docs-merge-20260519-security`** (locale, da `HEAD` prima del commit).

---

## D. Conflitti trovati

- **PR #8** (`codex/experimental-features` → `main`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY` — invariato.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY` — invariato.

Stato attuale: i conflitti pre-esistenti su `Localizable.strings`, `SettingsView/MoreView` e `project.yml` non sono affrontati in questo pass. Con i nuovi cambi di security su `main` aumenta la superficie di conflitto su `WatchSyncAuth.swift`, `WatchSyncService.swift`, `WatchDiveSyncCodec.swift`, `SubsurfaceExportService.swift`, `DiveImportService.swift`, `DiveLogStore.swift`.

---

## E. Conflitti risolti

- **Nessuno** in questo pass (scope: documentazione).

---

## F. PR ispezionate

| PR | Titolo | Base | URL |
|----|--------|------|-----|
| **#8** | Update experimental Apnea workflow | `main` | <https://github.com/egopfe/DirDiving-App/pull/8> |
| **#9** | Add experimental Apnea companion review | `main-iOS` | <https://github.com/egopfe/DirDiving-App/pull/9> |

Aggiunto commento di stato security sulle PR: invita a rebase su `4136ec0` e segnala vincoli (Data Protection / bound CSV / signed ack).

---

## G. PR considerate *safe to merge* (automatico)

- **Nessuna** nello stato attuale (`CONFLICTING`/`DIRTY` su entrambe).

---

## H. PR che richiedono revisione manuale

- **#8 e #9:** oltre ai conflitti pre-esistenti i18n, ora aggiungere checklist QA security:
  - Mantenere algoritmo `v2 ordered-secrets` lato `WatchSyncAuth.syncKey`.
  - Mantenere `[.atomic, .completeFileProtection]` su export Watch (`Services/SubsurfaceExportService.swift`).
  - Mantenere bound CSV iOS e cap 10 MB (no regressioni vs `main`).
  - Mantenere `maxIssuedAtSkew = 3_600`.
  - Persistenza pending/conflicts su file con Data Protection (no UserDefaults).
  - Logger con `privacy:.private` (no `print`).
  - Verificare ack firmato HMAC (`ackSignature`) in `parsePayload(from:)`.

---

## I. Lacune documentali ancora aperte

- Aggiornare `Docs/RELEASE_CHECKLIST.md` con sezione *QA Security* (pairing reset, payload tampering, replay 1h boundary, CSV oversize, ack legacy vs signed).
- Documentare migrazione one-shot e tempi di rimozione delle costanti `legacy*` (F8/F9 cleanup).
- Aggiungere chiave EN per il messaggio *"CSV troppo grande: limite 10 MB."* (oggi solo IT).
- Allineare i rami `codex/*` alla security baseline prima di qualsiasi merge.
- Migrazione progressiva dei `Text("…")` letterali residui in chiavi `.strings` (i18n).

---

## J. Commit suggeriti (prossimi)

1. **`docs: update DIR DIVING feature documentation and branch matrix`** — questo pass.
2. **`docs: add security QA checklist to release checklist`** — sezione dedicata in `Docs/RELEASE_CHECKLIST.md`.
3. **`chore(i18n): add EN key for CSV size-cap error`** — quando si tocca `iOSApp/Resources/en.lproj/Localizable.strings`.
4. **`merge: …`** — solo dopo risoluzione conflitti PR #8/#9 da maintainer su macOS.

---

## K. Rischi / assunzioni

- Nessun `xcodebuild` eseguito (ambiente Windows): le remediation security restano da validare runtime su macOS / Apple Watch Ultra reale.
- I metadati PR sono letti via `gh pr view`; lo stato Actions può differire.
- **Assunzione:** la rimozione del fallback deterministico (F7) non rompe nessun flusso esistente perché `SecRandomCopyBytes` non è mai fallito in produzione. Da confermare con sysdiagnose post-rilascio.
- **Assunzione:** la migrazione UserDefaults → `Documents/*.json` per pending/conflicts è idempotente; se il file esiste e UserDefaults ha residui, il file vince.
