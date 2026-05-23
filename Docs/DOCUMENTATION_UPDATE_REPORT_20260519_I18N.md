# Report aggiornamento documentazione DIR DIVING — 2026-05-19 (pass i18n)

Pass **solo documentazione** dopo i commit di internazionalizzazione su `main`:

- `fadd8a6` — *Add language selector localization support*
- `4cca72e` — *fix(i18n): tab keys, logbook locale, localized Watch command hint*

Nessuna logica runtime modificata in questo pass: si aggiornano README, matrice CSV, CHANGELOG, e si chiude il giro con report A–K + commento sulle PR aperte.

---

## A. File aggiornati

| File | Tipo modifica |
|------|----------------|
| `README.md` | Nuova sezione **Lingue e internazionalizzazione (i18n)**; voce dedicata in roadmap. |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Aggiunta colonna **Internationalization** in header (append-only sulle nuove righe); righe additive **Localization** per Watch/iOS + voce Documentation. |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md` | Questo file (report A–K). |

> File runtime già committati su `main` in passi precedenti: `App/DIRAppLanguage.swift`, `iOSApp/App/DIRIOSAppLanguage.swift`, `Resources/{en,it}.lproj/Localizable.strings`, `iOSApp/Resources/{en,it}.lproj/Localizable.strings`, picker `SettingsView`/`MoreView`, `Views/DiveUIComponents.swift`, `iOSApp/Views/ContentView.swift`, `iOSApp/Views/LogbookView.swift`. Vedi `git log -p fadd8a6 4cca72e`.

---

## B. Branch ispezionati

- **Locali:** `main` (corrente), `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`, molti `backup/*` (incluso il nuovo **`backup/before-docs-merge-20260519-i18n`** creato prima di questo pass).
- **Remote (post-`git fetch`):** `origin/main`, `origin/main-iOS`, `origin/codex/experimental-features`, `origin/codex/ios-experimental-features`.

Divergenze sintetiche dai log:

- `origin/main` allineato a `4cca72e` (i18n).
- `codex/experimental-features` ha già ricevuto un commit `Add language selector localization support` (`6d12e6a`) **dopo** il merge `692ffcc` di `origin/main`.
- `codex/ios-experimental-features` ha ricevuto `Add iOS language selector localization support` (`88d3472`) e `Update localization language settings plan` (`fdc7eb1`) sopra il merge con `origin/main-iOS`.

---

## C. Branch aggiornati (commit)

- **`main`:** commit **solo documentazione** (`docs: …`) sui file della sezione A.
- **Altri branch:** non modificati (nessun cherry-pick cross-branch in questo pass).

Backup creato: **`backup/before-docs-merge-20260519-i18n`** (locale, da `HEAD` prima del commit).

---

## D. Conflitti trovati

- **PR #8** (`codex/experimental-features` → `main`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): `mergeable: CONFLICTING`, `mergeStateStatus: DIRTY`.

Stato attuale: GitHub segnala di nuovo conflitto rispetto agli ultimi avanzamenti i18n di `main` (probabili sovrapposizioni su `Localizable.strings`, `SettingsView.swift`, picker More).

---

## E. Conflitti risolti

- **Nessuno** in questo pass (scope: documentazione).

---

## F. PR ispezionate

| PR | Titolo | Base | URL |
|----|--------|------|-----|
| **#8** | Update experimental Apnea workflow | `main` | <https://github.com/egopfe/DirDiving-App/pull/8> |
| **#9** | Add experimental Apnea companion review | `main-iOS` | <https://github.com/egopfe/DirDiving-App/pull/9> |

Entrambe contengono ora **anche** modifiche di i18n proprie del ramo experimental (file `Localizable.strings`, picker lingua, modello `DIRAppLanguage`).

---

## G. PR considerate *safe to merge* (automatico)

- **Nessuna** nello stato attuale (`CONFLICTING`/`DIRTY` su entrambe).

---

## H. PR che richiedono revisione manuale

- **#8 e #9:** risolvere conflitti i18n su macOS (`Localizable.strings` + picker), `xcodegen generate`, build Watch/iOS, verificare che la modifica della lingua continui a **non** alterare unità/calcoli/persistenza, e che la **terminologia BUSSOLA** resti tale anche con `locale = en` se il prodotto la richiede in italiano (rivedere mapping `"BUSSOLA" = "COMPASS"` se necessario).
- Commento di stato i18n aggiunto alle PR via `gh pr comment`.

---

## I. Lacune documentali ancora aperte

- Coverage stringhe: molte viste usano ancora `Text("...")` letterali → con lingua `en` resta testo italiano misto fino a migrazione progressiva.
- Decidere se la **terminologia di prodotto** (es. *BUSSOLA*) deve restare invariata anche in inglese o tradotta (`COMPASS`).
- Sincronizzazione **cross-device** della preferenza lingua (Watch ↔ iPhone) non implementata; al momento ogni device ha la propria.
- Documentare in `Docs/RELEASE_CHECKLIST.md` step di QA i18n (switch dinamico, layout EN più largo, VoiceOver hint).

---

## J. Commit suggeriti (prossimi)

1. **`docs: update DIR DIVING feature documentation and branch matrix`** — questo pass.
2. **`docs: add i18n QA checklist to release checklist`** — nuovo passaggio in `Docs/RELEASE_CHECKLIST.md`.
3. **`chore(i18n): migrate residual hard-coded strings`** — quando si decide di chiavare i `Text("…")` rimanenti.
4. **`merge: …`** — solo dopo risoluzione conflitti PR #8/#9 da maintainer.

---

## K. Rischi / assunzioni

- Nessun `xcodebuild` eseguito (ambiente Windows): la validazione build i18n resta da fare su macOS.
- I metadati PR sono letti via `gh pr view`; lo stato Actions può differire — controllare su GitHub.
- **Assunzione:** la fallback `supportedSystemLocale` (forza italiano se sistema non è `en`/`it`) è il comportamento desiderato come baseline; va riconsiderata quando verranno aggiunte altre lingue.
