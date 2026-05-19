# Report aggiornamento documentazione DIR DIVING — 2026-05-19 (pass security PT2)

Pass **solo documentazione** che chiude le lacune residue identificate nel report precedente (`Docs/DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`):

- QA checklist security in `RELEASE_CHECKLIST.md`.
- Chiavi i18n per il messaggio CSV size-cap (`F10`) e altri errori `DiveImportService`.
- Commenti di stato security su PR #8 e #9.

Nessuna logica runtime modificata.

---

## A. File aggiornati

| File | Tipo modifica |
|------|----------------|
| `Docs/RELEASE_CHECKLIST.md` | Nuova sezione **QA Security (audit F1–F12, baseline 2026-05-19)** con sotto-sezioni Auth/pairing, Persistenza/Data Protection, Sync protocol, Input validation, Logging/naming, Privacy/leakage. |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Aggiunte chiavi additive `import.csv.too_large`, `import.csv.too_large.10mb`, `import.csv.unreadable`, `import.csv.missing_columns`, `import.csv.empty_profile` con commento NOTE che documenta il follow-up runtime. |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Stesso set di chiavi in italiano, additive. |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | 3 nuove righe additive: *RELEASE_CHECKLIST.md QA Security* (Documentation), *Chiavi import.csv.\** (Localization, status `Planned` per la parte runtime), *DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md* (Documentation). |
| `CHANGELOG.md` | Voce *2026-05-19, pass documentazione security PT2*. |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md` | Questo file. |

> **Nessun file `Services/*.swift` o `iOSApp/Services/*.swift` modificato.** Le chiavi `.strings` sono asset di localizzazione: aggiungerle non altera il runtime finché `DiveImportService.ImportError.errorDescription` continua a restituire stringhe hardcoded.

---

## B. Branch ispezionati

- **Locali:** `main` (HEAD `14e39d5` prima di questo pass), `main-iOS`, backup vari.
- **Remoti (post-`git fetch`):** `origin/main` allineato a `14e39d5`. `origin/main-iOS`, `origin/codex/experimental-features`, `origin/codex/ios-experimental-features` invariati dal pass precedente.

---

## C. Branch aggiornati (commit)

- **`main`:** commit di documentazione (`docs: …`) sui file della sezione A.
- Backup creato: **`backup/before-docs-merge-20260519-security`** (creato nel pass precedente, ancora valido come marker di stato pre-security-PT2).
- Altri branch non modificati.

---

## D. Conflitti trovati

- **PR #8** (`codex/experimental-features` → `main`): `CONFLICTING`/`DIRTY`.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): `CONFLICTING`/`DIRTY`.

---

## E. Conflitti risolti

- Nessuno (scope: documentazione).

---

## F. PR ispezionate

| PR | Titolo | Base | Stato |
|----|--------|------|-------|
| **#8** | Update experimental Apnea workflow | `main` | CONFLICTING/DIRTY |
| **#9** | Add experimental Apnea companion review | `main-iOS` | CONFLICTING/DIRTY |

Commenti security postati con `gh pr comment` (issuecomment `4488127946` su #8, `4488128195` su #9). Il body è in `Docs/_pr_security_comment.md` (file temporaneo rimosso dopo l'invio).

---

## G. PR considerate *safe to merge* (automatico)

- Nessuna.

---

## H. PR che richiedono revisione manuale

- **#8** e **#9**: lista di vincoli security già nel commento PR. Riassunto:
  - Mantenere `v2 ordered-secrets` su `syncKey`.
  - Mantenere `[.atomic, .completeFileProtection]` su export Watch.
  - Mantenere bound `DiveImportService` + cap 10 MB.
  - Mantenere `maxIssuedAtSkew = 3_600`.
  - Mantenere file in `Documents/` con Data Protection per pending/conflicts.
  - Mantenere ack firmato HMAC.
  - Mantenere `os.Logger` con `privacy:.private`.

---

## I. Lacune documentali ancora aperte

Tutte le lacune del report PT1 sono chiuse, ad eccezione di:

- **Wiring runtime delle chiavi `import.csv.*`** (`DiveImportService.ImportError.errorDescription`): le chiavi sono pubblicate ma il runtime restituisce ancora IT hardcoded. È un follow-up tecnico, **non documentazione**, e va trattato in un PR separato per non mescolare doc-only con runtime change.
- **Allineamento dei rami `codex/*`** alla security baseline (resta in carico ai maintainer della PR su macOS).
- **F11 follow-up** — rimozione fallback legacy `status == acknowledged` quando il floor build iOS sale.
- **F8 cleanup** — rimozione costanti `legacyKey` / `legacyKeychainService` dopo periodo di rilascio (≥ 2 release).
- **F9 cleanup** — rimozione codice di migrazione UserDefaults → file dopo periodo di rilascio.
- **Test E2E `WatchDiveSyncCodec`** per bloccare drift di protocollo (suggerito in audit F2).

---

## J. Commit suggeriti (prossimi)

1. **`docs: update DIR DIVING feature documentation and branch matrix`** — questo pass.
2. **`chore(i18n): wire DiveImportService errors to localized strings`** — converte `ImportError.errorDescription` a `NSLocalizedString`. Modifica runtime ma minima, già preparata via chiavi `.strings`.
3. **`test: add Watch->iOS WatchDiveSyncCodec round-trip test`** — bloccare regressioni F2.
4. **`merge: …`** — solo dopo risoluzione conflitti PR #8/#9 su macOS.

---

## K. Rischi / assunzioni

- Nessun `xcodebuild` eseguito in questo pass; le chiavi `.strings` sono compilate da Xcode al prossimo build ma essendo additive non rompono nessuna esistente.
- **Assunzione:** il commento NOTE nelle `.strings` rende esplicito al prossimo manutentore che le chiavi `import.csv.*` esistono per un follow-up runtime, non per un wiring già attivo.
- I commenti su GitHub PR #8/#9 sono visibili a chiunque legga la PR; non contengono informazioni sensibili (sono già pubbliche tramite l'audit `Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`).
