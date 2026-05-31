# DIR DIVING — Documentation Update Report 2026-05-26

**Date:** 2026-05-26  
**Working branch:** `main` @ `2322145`  
**Scope:** documentation / repository consistency / branch narrative alignment  
**Runtime rule respected:** no deliberate edits to dive logic, planner math, sync architecture, GPS behavior, compass algorithms, or persistence models in this pass

---

## A. Goal

Align the current MAIN documentation set with the latest stable architecture and repository state:

- unified stable `main` branch
- Apple Watch Diving MAIN + iOS companion MAIN
- legal onboarding and disclaimer revision flow
- inline ascent warning policy
- compact GPS overlays
- visible Watch `Start Dive`
- surface image viewing
- Mission Mode on Watch with minimal indicator
- explicit separation from Snorkeling / Apnea / Buddy experimental branches

---

## B. Files updated

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

---

## C. Docs created

- `Docs/DOCUMENTATION_UPDATE_REPORT_20260526.md`
- `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260526.md`
- `Docs/PR_STATUS_20260526.md`

---

## D. Main documentation corrections applied

- Updated top-level docs to treat **`main`** as the stable production-oriented branch and **`main-iOS`** as a historical divergent worktree
- Brought README / product overview / roadmap in line with the current stable Watch MAIN story:
  - surface `Start Dive`
  - automatic start still preserved
  - image viewing outside active dives
  - Mission Mode scope and indicator
- Updated release/TestFlight/safety docs so they describe:
  - no full-screen underwater warning takeover
  - truthful Side Button limitations
  - Action Button via Shortcuts / App Intents only
  - water-submersion entitlement as an external blocker
- Updated current readiness and UX audit docs to remove stale wording around manual dive availability and to reflect Mission Mode on current MAIN

---

## E. Feature matrix status

`Docs/DIR_DIVING_Feature_Comparison.csv` was extended to better reflect the stable MAIN narrative without deleting historical rows:

- preserved existing historical and branch-specific rows
- kept Watch MAIN / Watch experimental / iOS experimental separation
- added current MAIN Watch rows for manual `Start Dive` and Mission Mode-related behavior where missing
- retained older `main-iOS` rows as historical evidence rather than rewriting history

---

## F. Branch / PR documentation status

- fetched remote refs and refreshed divergence counts
- created a new dated branch-alignment report for 2026-05-26
- created a new dated PR risk summary for 2026-05-26
- no branch was force-pushed, deleted, merged, or rebased in this pass

---

## G. Validation

Repository-side validation performed in this pass:

- `git fetch origin --prune`
- `git branch -a`
- `git branch -vv`
- `git remote -v`
- divergence counts vs `origin/main`
- document cross-check against `project.yml`

Build validation is recorded separately in `Docs/BUILD_VALIDATION.md` and should be rerun on macOS after the current working tree is finalized.

---

## H. Known limitations

- `gh` is not installed here, so PR metadata could not be refreshed live from GitHub
- several older historical reports still mention legacy `main-iOS` assumptions for traceability
- the working tree was already dirty at the start of this pass because it contained an in-progress Watch MAIN Mission Mode implementation and related docs

---

## I. Remaining release blockers

- Apple approval/provisioning for `com.apple.developer.coremotion.water-submersion`
- generic signed device builds that depend on that entitlement
- real Apple Watch Ultra field/device QA for automatic dive lifecycle and underwater evidence

---

## J. Outcome

The repository documentation now consistently describes:

- **`main`** as the authoritative stable branch
- experimental branches as isolated/non-production
- the current Watch MAIN interaction model, including `Start Dive`, compact overlays, and Mission Mode
- the current external blockers as signing/device-evidence issues rather than missing repo-side documentation
