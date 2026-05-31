# DIR DIVING — Documentation update report (2026-05-20)

Report strutturato A–K post-pass documentazione, banner risalita inline Watch MAIN, e allineamento matrice feature.

---

## A. Files updated

| File | Tipo |
|------|------|
| `README.md` | Baseline UX Watch; tabella pre-release UX-H3 |
| `CHANGELOG.md` | Sezione Unreleased 2026-05-20 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Righe ascent banner, UX-H3, report docs |
| `Docs/WATCH_MAIN_UX_CONVENTIONS.md` | Nuovo (policy banner inline) |
| `Docs/ASCENT_ALARM_IMPLEMENTATION_REPORT_20260520.md` | Nuovo |
| `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260519_CURRENT_PRE_MODIFICATION.md` | Nota supersessione policy risalita |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260520.md` | Nuovo |
| `Views/AscentWarningBannerView.swift` | Nuovo (runtime) |
| `Views/DiveLiveView.swift`, `AscentWarningView.swift` | Runtime |
| `Services/HapticService.swift`, `DiveManager.swift` | Runtime |
| `Resources/{en,it}.lproj/Localizable.strings` | i18n ascent_alarm_* |

---

## B. Branches inspected

| Branch | Remote | Note |
|--------|--------|------|
| `main` | `origin/main` | Watch MAIN + iOSApp nel workspace unificato |
| `main-iOS` | `origin/main-iOS` | Worktree locale `.worktrees/main-iOS` |
| `codex/experimental-features` | sì | Watch Snorkeling/Apnea/Buddy |
| `codex/ios-experimental-features` | sì | iOS Explore/Apnea Lab |
| `backup/main-watch-backlog-20260519` | locale | UX backlog Watch in attesa cherry-pick |
| `backup/before-docs-pre-release-pass-20260519` | locale | Backup docs |

---

## C. Branches updated

- **`main`**: documentazione + implementazione banner risalita (commit in questa sessione).
- **`main-iOS`**: da allineare con cherry-pick **solo documentazione** (CSV, CHANGELOG, report) se diverge — non eseguito automaticamente in questo pass se worktree non aggiornato.

---

## D. Conflicts found

- Nessun conflitto git locale su `main` prima del commit.
- **PR #8** (`codex/experimental-features` → `main`): mergeable state unknown via API; storico documentato **CONFLICTING**.
- **PR #9** (`codex/ios-experimental-features` → `main-iOS`): idem; regressioni F4/F5 note su branch experimental iOS.

---

## E. Conflicts resolved

- Nessuna risoluzione merge runtime in questo pass (solo docs + ascent banner su `main`).

---

## F. PRs inspected

| PR | Titolo | Head → Base | Raccomandazione |
|----|--------|-------------|-----------------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | Update experimental Apnea workflow | `codex/experimental-features` → `main` | **Manual review** — non merge automatico |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | Add experimental Apnea companion review | `codex/ios-experimental-features` → `main-iOS` | **Manual review** — non merge automatico |

---

## G. PRs safe to merge

- **Nessuna** in automatico. Entrambe toccano superfici experimental con conflitti storici e build check falliti in pass precedenti.

---

## H. PRs requiring manual review

- **#8**: preservare Diving MAIN, BUSSOLA, GPS; isolare Apnea experimental; risolvere conflitti in `project.yml` / file sperimentali.
- **#9**: verificare che non reintroduca regressioni security (`.completeFileProtection`, bound CSV); QA macOS + iOS simulator.

**Checklist manuale:**

- [ ] `xcodegen generate` + build Watch scheme
- [ ] Build iOS companion su `main-iOS`
- [ ] Smoke Diving live + log sync
- [ ] Nessun file experimental nel target MAIN Watch

---

## I. Documentation gaps still open

- Audit `.docx` generato; corpo audit ancora cita full-screen 1 s in molte sezioni (nota supersessione in testa).
- Watch backlog (`backup/main-watch-backlog-20260519`): UX-H1/H2/H4/M/L/SAF ancora **pending cherry-pick** vs security cluster.
- `gh` CLI non disponibile in ambiente agent — commenti PR via API non autenticata limitati.
- Full `xcodebuild` non eseguito (runtime simulator opzionale).
- Migrazione stringhe `Text("…")` → `Localizable.strings` (debito i18n).
- Sync preferenza lingua Watch ↔ iPhone (Planned).

---

## J. Suggested next commits

1. `feat(watch): inline ascent speed alarm banner with localized haptics` — già preparato su `main`
2. `docs: update DIR DIVING feature documentation and branch matrix` — CSV, README, CHANGELOG, report 20260520
3. `docs: cherry-pick documentation to main-iOS` — solo file Docs/ + CHANGELOG se branch diverge
4. `merge: resolve documentation conflicts across branches` — solo se merge PR #8/#9 avviato manualmente

---

## K. Risks and assumptions

- **Assunto:** banner inline non modifica soglie risalita (verificato in code review statica).
- **Rischio:** cherry-pick backlog Watch può reintrodurre `compactAscentWarning` diverso dal banner attuale — risolvere preferendo implementazione 2026-05-20.
- **Rischio:** merge PR #9 senza riallineare F4/F5 degrada security iOS MAIN.
- **Non fatto:** force-push, delete branch, squash, modifica GPS/compass/decompression.

---

*Generato: 2026-05-20 · DIR DIVING documentation pass*
