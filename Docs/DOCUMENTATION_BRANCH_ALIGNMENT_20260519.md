# DIR DIVING — Documentation Branch Alignment 2026-05-19

**Date:** 2026-05-19  
**Working branch:** `main` @ `92e639a`  
**Scope:** documentation / repository consistency only  
**Runtime policy:** no dive, planner, sync, GPS, BUSSOLA, or persistence logic changed in this pass

---

## A. Branches inspected

Inspected from the local repository and fetched `origin/*` refs:

- `main` (authoritative stable baseline)
- `main-iOS` (historical divergent worktree)
- `codex/experimental-features` (Watch experimental)
- `codex/ios-experimental-features` (iOS experimental)
- local `backup/*` branches (historical snapshots only)

---

## B. Working tree / remotes

- `git fetch --all --prune` completed successfully
- `main` clean and aligned with `origin/main` @ `92e639a`
- `origin = https://github.com/egopfe/DirDiving-App`

Worktrees synced before this pass:

| Worktree | Branch | Commit | Remote |
|----------|--------|--------|--------|
| `DirDiving-App` | `main` | `92e639a` | up to date |
| `DirDiving-App-exp-watch-fix` | `codex/experimental-features` | `dfb9659` | up to date |
| `DirDiving-App-ios-exp-apnea` | `codex/ios-experimental-features` | `22f89a4` | up to date |
| `DirDiving-App-main-iOS-ui` | `main-iOS` | `5023d71` | up to date |

Backup branch created: `backup/docs-alignment-20260519`.

---

## C. Divergence snapshot vs `origin/main`

Measured with `git rev-list --left-right --count origin/main...<branch>`:

| Branch ref | `origin/main` ahead | Branch ahead | Interpretation |
|-----------|----------------------|--------------|----------------|
| `origin/main` | 0 | 0 | Aligned |
| `origin/main-iOS` | 216 | 48 | Historical divergent worktree; not stable MAIN source of truth |
| `origin/codex/experimental-features` | 80 | 29 | Expected experimental divergence |
| `origin/codex/ios-experimental-features` | 127 | 60 | Expected experimental divergence |

These counts are documentation aids only, not merge instructions.

---

## D. Alignment decision

This pass keeps **`main` @ `92e639a`** as the authoritative documentation baseline for:

- stable Diving mode on Apple Watch
- stable iOS companion in the unified XcodeGen workspace
- legal onboarding and disclaimer revision flow
- depth safety discouragement at 35 / 38 / 40 m
- inline ascent warning UX (non-blocking banners)
- compact GPS overlays
- visible Watch `Start Dive`
- User Images conditional visibility and mode auto-skip
- Mission Mode + minimal active-state indicator
- Watch algorithm release-hard pass (`ddaf2d7` → `92e639a`)
- BUSSOLA terminology (never COMPASSO)
- App Intents / Action Button policy
- truthful Side Button limitations
- release/TestFlight/App Store blocker documentation

`main-iOS` remains documented as a **historical divergent worktree**, not as a stable release branch.

Experimental branches remain explicitly isolated and must not be described as MAIN-ready runtime targets.

---

## E. Docs updated as part of this alignment

- `README.md`
- `CHANGELOG.md`
- `CONTRIBUTING.md`
- `Docs/INDEX.md`
- `Docs/PRODUCT_FEATURES_IT.md`
- `Docs/ROADMAP.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/SAFETY_DISCLAIMER.md`
- `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md` (audit delta only)
- `Docs/DIR_DIVING_Feature_Comparison.csv`
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md`
- `Docs/PR_STATUS_20260519.md`

Prior reports (`DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`, etc.) are preserved as historical context.

---

## F. Branches intentionally not modified (runtime)

To avoid unsafe drift:

- `codex/experimental-features` (runtime)
- `codex/ios-experimental-features` (runtime)
- historical `backup/*` branches

No runtime merge, force-push, squash, or cross-branch cherry-pick was performed in this pass.

Documentation-only propagation to experimental branches may follow as a separate docs commit if needed.

---

## G. Conflict policy confirmed

If a future merge is required, preserve in this order:

1. buildable code
2. stable Diving functionality on `main`
3. latest stable UI references (`Docs/ReferenceUI/`)
4. latest inline underwater warning UX
5. latest release and legal docs
6. experimental isolation in `project.yml`

Never overwrite:

- `BUSSOLA` terminology
- inline ascent warning policy
- compact GPS overlay policy
- manual `Start Dive` visibility on stable MAIN
- Mission Mode safety exclusions
- legal disclaimer / Terms / Privacy destinations
- Action Button / Side Button truthfulness
- algorithm hardening assumptions documented in `DIR_DIVING_WATCH_ALGORITHM_RELEASE_HARDENING.md`

---

## H. Remaining branch-level risks

- `main-iOS` is materially divergent; runtime reconciliation still requires a dedicated review pass
- experimental branches contain Snorkeling/Apnea/Buddy runtime not present in MAIN targets
- PR #8 and #9 remain open and unsafe for automatic merge (see `PR_STATUS_20260519.md`)
- XCTest execution for `DIRDiving Watch Algorithm Tests` requires macOS/Xcode validation

---

## I. Conclusion

Repository documentation is aligned around a single stable branch narrative:

- **`main` @ `92e639a` = production-oriented stable branch**
- **`main-iOS` = historical/divergent worktree**
- **`codex/*` = experimental only**

No runtime merge was performed as part of this alignment.
