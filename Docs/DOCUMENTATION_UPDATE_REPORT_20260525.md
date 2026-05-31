# DIR DIVING — Documentation Update Report 2026-05-25

**Date:** 2026-05-25  
**Branch:** `main` @ `ab398eb`  
**Pass type:** documentation / repository consistency  
**Runtime changes:** none

---

## A. Goal

Align the current public/project documentation with the real MAIN architecture:

- stable Diving mode on Watch
- stable iOS companion inside the same `main` workspace
- legal onboarding revision system
- inline ascent warning philosophy
- compact GPS overlays
- BUSSOLA terminology
- sync / push-to-Watch / legal/release documentation
- experimental isolation for Snorkeling, Apnea, Buddy Assist, and exploration concepts

---

## B. Files updated

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

## C. Files created

- `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260525.md`
- `Docs/DOCUMENTATION_UPDATE_REPORT_20260525.md`
- `Docs/PR_STATUS_20260525.md`

---

## D. Main corrections applied

1. Repointed “current” branch references from older SHAs to `main` @ `ab398eb`.
2. Reframed `main-iOS` as a **historical divergent worktree**, not as the canonical stable iOS branch.
3. Aligned README / feature docs / safety docs with the current MAIN UX:
   - inline ascent warning
   - compact GPS banners
   - Action Button via Shortcuts/App Intents only
   - Side Button as system-controlled
4. Updated build and release docs to reflect:
   - current bundle IDs
   - current simulator naming guidance
   - known external entitlement blocker
5. Updated rolling audit docs so they no longer report already-fixed repo-side issues as open.
6. Normalized the feature matrix schema to the current requested columns while preserving historical rows.

---

## E. Documentation decisions

- Historical audit/readiness files were **preserved**.
- The current dated readiness audit (`MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md`) remains the authoritative readiness source.
- `MAIN_BRANCH_FINAL_READINESS_REPORT.md` is kept as a historical intermediate report and explicitly marked as superseded.
- No experimental runtime behavior was promoted into MAIN.

---

## F. Validation used for this pass

- `git status --short --branch`
- `git branch -a`
- `git branch -vv`
- `git remote -v`
- `git rev-list --left-right --count origin/main...<branch>`
- direct reads of `project.yml`, README, index, roadmap, safety/release docs, audits, and experimental docs

---

## G. Limitations

- `gh` is not installed in the current environment.
- Live GitHub PR metadata could not be refreshed directly from this environment.
- GitHub web fetch for private PR pages was not available here.
- Therefore PR status was documented conservatively from local refs and prior repo reports rather than claimed as a fresh live GitHub truth.

---

## H. Remaining gaps

- Physical Watch Ultra depth/submersion QA remains external.
- Generic signed device builds remain blocked by entitlement/provisioning.
- If the team wants audit-grade sync traceability, a persisted per-session ledger is still a future enhancement.
- Historical branch/worktree convergence (`main-iOS` in particular) remains a separate, runtime-sensitive task.

---

## I. Confirmation

This pass did **not**:

- redesign UI
- change dive/planner/sync algorithms
- alter persistence models
- merge experimental runtime code into MAIN
- force-push or rewrite branch history

The pass is documentation-first and repository-consistency-first.
