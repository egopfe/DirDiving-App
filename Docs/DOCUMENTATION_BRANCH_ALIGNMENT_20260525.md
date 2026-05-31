# DIR DIVING — Documentation Branch Alignment 2026-05-25

**Date:** 2026-05-25  
**Working branch:** `main` @ `ab398eb`  
**Scope:** documentation/repository consistency only  
**Runtime policy:** no dive, planner, sync, GPS, BUSSOLA, or persistence logic changed in this pass

---

## A. Branches inspected

Inspected from the local repository and locally available `origin/*` refs:

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- local `backup/*` branches

Current local branch inventory also includes historical safety backups created during earlier documentation passes.

---

## B. Working tree / remotes

- `git status --short --branch` -> clean `main...origin/main`
- `git remote -v` -> `origin` = `https://github.com/egopfe/DirDiving-App`
- `git branch -a` confirms the unified stable branch (`main`), the historical divergent iOS worktree (`main-iOS`), and the two experimental codex branches

---

## C. Divergence snapshot vs `origin/main`

Measured from locally available remote refs with:

```text
git rev-list --left-right --count origin/main...<branch>
```

| Branch ref | `origin/main` ahead | Branch ahead | Interpretation |
|-----------|----------------------|--------------|----------------|
| `origin/main` | 0 | 0 | Aligned |
| `origin/main-iOS` | 209 | 47 | Historical divergent worktree; do not treat as MAIN source of truth |
| `origin/codex/experimental-features` | 73 | 29 | Expected experimental divergence |
| `origin/codex/ios-experimental-features` | 120 | 60 | Expected experimental divergence |

These numbers are alignment aids, not merge instructions.

---

## D. Alignment decision

This pass keeps **`main`** as the authoritative documentation baseline for:

- stable Diving mode
- stable iOS companion surfaces
- legal onboarding revision flow
- inline ascent warning UX
- compact GPS overlays
- BUSSOLA terminology
- App Intents / Action Button policy
- Side Button truthfulness
- sync, push-to-Watch, and recent sync activity visibility
- release/TestFlight/App Store blocker documentation

`main-iOS` remains documented as a **historical divergent worktree**, not a stable release branch.

Experimental branches remain explicitly isolated in docs and are not promoted into MAIN runtime targets.

---

## E. Docs updated as part of this alignment

- `README.md`
- `CHANGELOG.md`
- `Docs/PRODUCT_FEATURES_IT.md`
- `Docs/ROADMAP.md`
- `Docs/INDEX.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/SAFETY_DISCLAIMER.md`
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`
- `Docs/WATCH_MAIN_UX_CONVENTIONS.md`
- `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`
- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`
- `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md`
- `Docs/iOS/EXPERIMENTAL_FEATURES.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`

---

## F. Branches intentionally not modified

To avoid unsafe runtime drift:

- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- historical `backup/*` branches

The branch strategy is documented, but no cross-branch code merge or doc cherry-pick was forced from this pass.

---

## G. Conflict policy confirmed

If a future merge is required, preserve in this order:

1. buildable code
2. stable Diving functionality on `main`
3. latest stable UI references
4. latest inline underwater warning UX
5. latest release and legal docs
6. experimental isolation

Never overwrite:

- `BUSSOLA` terminology
- inline ascent warning policy
- compact GPS overlay policy
- legal disclaimer / Terms / Privacy destinations
- Action Button / Side Button truthfulness

---

## H. Remaining branch-level risks

- `main-iOS` is materially divergent; runtime reconciliation requires a dedicated review pass.
- Experimental branches may contain newer exploratory docs/screens, but those must not be described as MAIN-ready.
- Live PR state could not be refreshed with `gh` from this environment; see `PR_STATUS_20260525.md`.

---

## I. Conclusion

Repository documentation is now aligned around a single stable branch narrative:

- **`main` = production-oriented stable branch**
- **`main-iOS` = historical/divergent worktree**
- **`codex/*` = experimental only**

No runtime merge was performed as part of this alignment.
