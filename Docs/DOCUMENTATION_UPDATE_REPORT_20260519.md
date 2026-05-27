# DIR DIVING — Documentation Update Report 2026-05-19

**Date:** 2026-05-19  
**Baseline:** `main` @ `92e639a`  
**Pass type:** documentation / repository consistency only

---

## A. Files updated

| File | Change |
|------|--------|
| `README.md` | Baseline commit `92e639a`; algorithm hardening pass; branch strategy HEAD |
| `CHANGELOG.md` | Docs pass + algorithm hardening entries |
| `CONTRIBUTING.md` | v10 notes + algorithm audit references |
| `Docs/INDEX.md` | 2026-05-19 index section; baseline update |
| `Docs/PRODUCT_FEATURES_IT.md` | Baseline + algorithm hardening summary |
| `Docs/ROADMAP.md` | Algorithm hardening shipped; docs pass; P1 XCTest QA |
| `Docs/BUILD_VALIDATION.md` | Baseline + `DIRDiving Watch Algorithm Tests` target |
| `Docs/SAFETY_DISCLAIMER.md` | Baseline version line |
| `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_2026-05-25.md` | Audit delta for `92e639a` |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Stale Planned→Implemented; algorithm rows; docs rows |

---

## B. Docs created

| File | Purpose |
|------|---------|
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260519.md` | Branch alignment strategy |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260519.md` | This report |
| `Docs/PR_STATUS_20260519.md` | Live PR inspection |

---

## C. Branches inspected

`main`, `main-iOS`, `codex/experimental-features`, `codex/ios-experimental-features`, all `backup/*` refs, all `origin/*` refs.

---

## D. Branches updated

- **`main`:** documentation pass (this commit)
- **Other branches:** not modified in this pass (runtime isolation preserved)

---

## E. Conflicts found

None during this docs-only pass on `main`.

Prior note: `main-iOS` had merge conflicts when syncing earlier; resolved by reset to `origin/main-iOS` @ `5023d71`.

---

## F. Conflicts resolved

None in this pass.

---

## G. PRs inspected

| PR | Title | Base | Head | State |
|----|-------|------|------|-------|
| #8 | Update experimental Apnea workflow | `main` | `codex/experimental-features` | OPEN |
| #9 | Add experimental Apnea companion review | `main-iOS` | `codex/ios-experimental-features` | OPEN |

Details: [`PR_STATUS_20260519.md`](PR_STATUS_20260519.md)

---

## H. PRs safe to merge

**None automatically.** Both PRs touch experimental runtime surfaces and large doc matrices; require manual macOS build + target isolation review.

---

## I. PRs requiring manual review

- **PR #8:** Watch experimental Apnea/Snorkeling/Buddy — high runtime risk if merged to `main`
- **PR #9:** iOS experimental Apnea review — high runtime risk; base branch `main-iOS` is divergent historical worktree

---

## J. Remaining documentation gaps

- `Branch_Functionality_Matrix.xlsx` not regenerated in this pass (binary; preserve existing)
- Some historical audit `.docx` files retain older branch assumptions (preserved intentionally)
- `main-iOS`-specific README sections on experimental branches may lag unified `main` narrative
- Import CSV runtime strings still partially hardcoded IT (`DiveImportService`) — documented as Planned in CSV

---

## K. Remaining release blockers

| Blocker | Type |
|---------|------|
| Water submersion entitlement approval + Ultra hardware QA | Apple / P0 |
| XCTest `DIRDiving Watch Algorithm Tests` execution on macOS | QA / P1 |
| Signed generic device builds Watch + iOS | Release / P0 |
| App Intents / Action Button physical Watch QA | Hardware / P1 |
| Terms/Privacy final legal review for App Store | Legal / P2 |

---

## L. Suggested next commits

1. `docs: align DIR DIVING architecture and release documentation` (this pass on `main`)
2. `docs: propagate baseline alignment to codex/* branches` (optional follow-up, docs-only cherry-pick)
3. Runtime follow-ups only after explicit issue: log list imperial depth display, import.csv localization

---

## M. Risks / assumptions

- Assumed `92e639a` is the correct stable HEAD (verified against `origin/main`)
- Algorithm hardening docs describe code changes already merged; this pass does not re-validate XCTest execution
- Experimental PR bodies claim no algorithm changes; merge still risks `project.yml` target pollution
- Windows environment cannot run `xcodegen` / `xcodebuild` locally

---

## N. Experimental isolation confirmation

`project.yml` on `main` excludes from MAIN targets:

- Watch: `ApneaView`, `SnorkelingView`, `BuddyAssistView`, `ExperimentalConceptsView`, exploration/buddy services
- iOS: exploration/buddy experimental views and stores

Documentation consistently marks Snorkeling, Apnea, Buddy Assist as **experimental only**.

---

## O. MAIN stability confirmation

- No runtime files modified in this pass
- Diving mode, GPS surface-only, BUSSOLA, inline warnings, sync, planner (iOS), legal onboarding documented as stable on `main`
- Watch algorithm hardening (`92e639a`) documented as release-hard for internal validation pending device QA
