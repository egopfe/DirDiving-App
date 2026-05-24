# Pull request status (post v9)

**Baseline `main`:** `d962117` (2026-05-20)  
**Nessun merge automatico eseguito.**

> Nota: `gh` non disponibile in ambiente CI agente; stato basato su ispezione branch, documentazione precedente e policy merge invariata.

---

## PR #8 — Watch experimental → `main`

| Campo | Valore |
|-------|--------|
| URL | https://github.com/egopfe/DirDiving-App/pull/8 |
| Head | `codex/experimental-features` |
| Base | `main` |
| **Conflict status** | **CONFLICTING** (66 commit behind `main` @ `d962117`) |
| **Merge recommendation** | **Manual review — do not auto-merge** |

**Affected areas (typical):** `SnorkelingView`, `ApneaView`, `ExplorationStore`, `project.yml` target membership, experimental navigation.

**Risks:**

- Promozione accidentale Snorkeling/Apnea/Buddy nel target MAIN
- Regressione Diving live, banner risalita inline, security F1–F12, v8/v9 planner isolation on iOS in unified `main`

**Required manual checks:**

- `xcodegen generate` + build `DIRDiving Watch App`
- Verify `project.yml` excludes experimental sources on MAIN
- QA BUSSOLA, GPS surface-only, Diving live unchanged
- Preserve latest Snorkeling Live / Waypoint / Return Map UI **on experimental branch only**

---

## PR #9 — iOS experimental → `main-iOS`

| Campo | Valore |
|-------|--------|
| URL | https://github.com/egopfe/DirDiving-App/pull/9 |
| Head | `codex/ios-experimental-features` |
| Base | `main-iOS` |
| **Conflict status** | **CONFLICTING** |
| **Merge recommendation** | **Manual review — do not auto-merge** |

**Risks (documented in security audit):**

- Possible removal of `.completeFileProtection` on iOS CSV export
- Weaker CSV import bounds vs `main`

**Required manual checks:**

- Restore F4/F5 security behaviors from `main` before any merge
- Build `DIRDiving iOS` on macOS
- Do not promote Explore Lab to stable without product sign-off

---

## Safe to merge?

| PR | Safe auto-merge? |
|----|------------------|
| #8 | **No** |
| #9 | **No** |

---

## Git operations performed

- `git fetch --all --prune`
- Documentation commits on `main`; doc sync to other branches (no runtime merge)
