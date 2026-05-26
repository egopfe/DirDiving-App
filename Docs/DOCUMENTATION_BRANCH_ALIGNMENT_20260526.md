# DIR DIVING — Documentation Branch Alignment 2026-05-26

**Date:** 2026-05-26  
**Working branch:** `main` @ `2322145`  
**Scope:** documentation / repository consistency only  
**Runtime policy:** no dive, planner, sync, GPS, BUSSOLA, or persistence logic changed in this pass

---

## A. Branches inspected

Inspected from the local repository and fetched `origin/*` refs:

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- local `backup/*` branches

---

## B. Working tree / remotes

- `git fetch origin --prune` completed successfully
- `git status --short --branch` showed `main...origin/main` plus local uncommitted work
- `git remote -v` confirms `origin = https://github.com/egopfe/DirDiving-App`

Working tree note:

- this pass was executed on top of an already dirty local tree that contained the in-progress Watch MAIN Mission Mode implementation and related docs
- the documentation updates in this pass were layered conservatively on top of that local state without touching unrelated runtime files

---

## C. Divergence snapshot vs `origin/main`

Measured from locally available refs with:

```text
git rev-list --left-right --count origin/main...<branch>
```

| Branch ref | `origin/main` ahead | Branch ahead | Interpretation |
|-----------|----------------------|--------------|----------------|
| `origin/main` | 0 | 0 | Aligned |
| `origin/main-iOS` | 212 | 47 | Historical divergent worktree; not a stable MAIN source of truth |
| `origin/codex/experimental-features` | 76 | 29 | Expected experimental divergence |
| `origin/codex/ios-experimental-features` | 123 | 60 | Expected experimental divergence |

These counts are documentation aids only, not merge instructions.

---

## D. Alignment decision

This pass keeps **`main`** as the authoritative documentation baseline for:

- stable Diving mode on Apple Watch
- stable iOS companion in the unified XcodeGen workspace
- legal onboarding and disclaimer revision flow
- inline ascent warning UX
- compact GPS overlays
- visible Watch `Start Dive`
- surface image viewing outside active dives
- Mission Mode + minimal active-state indicator
- BUSSOLA terminology
- App Intents / Action Button policy
- truthful Side Button limitations
- release/TestFlight/App Store blocker documentation

`main-iOS` remains documented as a **historical divergent worktree**, not as a stable release branch.

Experimental branches remain explicitly isolated and must not be described as MAIN-ready runtime targets.

---

## E. Docs updated as part of this alignment

- `README.md`
- `CHANGELOG.md`
- `Docs/INDEX.md`
- `Docs/PRODUCT_FEATURES_IT.md`
- `Docs/ROADMAP.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`
- `Docs/SAFETY_DISCLAIMER.md`
- `Docs/WATCH_MAIN_UX_CONVENTIONS.md`
- `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`
- `Docs/MAIN_BRANCH_UX_INTERACTION_ACCESSIBILITY_AUDIT_CURRENT.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260526.md`
- `Docs/PR_STATUS_20260526.md`

---

## F. Branches intentionally not modified

To avoid unsafe drift:

- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- historical `backup/*` branches

No runtime merge, force-push, squash, or cross-branch cherry-pick was performed in this pass.

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
- manual `Start Dive` visibility on stable MAIN
- Mission Mode safety exclusions
- legal disclaimer / Terms / Privacy destinations
- Action Button / Side Button truthfulness

---

## H. Remaining branch-level risks

- `main-iOS` is materially divergent; runtime reconciliation still requires a dedicated review pass
- experimental branches may contain newer exploratory screenshots/docs, but they must not be promoted into MAIN runtime descriptions
- live PR metadata could not be refreshed from GitHub because `gh` is not installed in this environment
- several historical audit documents still mention older `main-iOS` assumptions for traceability; the current baseline is clarified in README, INDEX, roadmap, and current audit docs

---

## I. Conclusion

Repository documentation is now aligned around a single stable branch narrative:

- **`main` = production-oriented stable branch**
- **`main-iOS` = historical/divergent worktree**
- **`codex/*` = experimental only**

No runtime merge was performed as part of this alignment.
