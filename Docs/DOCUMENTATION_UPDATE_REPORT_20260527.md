# DIR DIVING - Documentation Update Report 2026-05-27

**Date:** 2026-05-27  
**Working branch:** `main` @ `37e4464` before this documentation pass  
**Scope:** documentation / repository consistency / branch narrative alignment  
**Runtime rule respected:** no edits to Swift code, UI, UX, dive logic, planner algorithms, sync architecture, GPS behavior, BUSSOLA algorithms, persistence models or target membership

---

## A. Files updated

- `README.md`
- `CHANGELOG.md`
- `Docs/INDEX.md`
- `Docs/ROADMAP.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`

---

## B. Docs created

- `Docs/DOCUMENTATION_UPDATE_REPORT_20260527.md`
- `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260527.md`
- `Docs/PR_STATUS_20260527.md`

---

## C. Branches inspected

- `main`
- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- local `backup/*` branches
- corresponding `origin/*` refs

---

## D. Branches updated

Updated branch:

- `main` only

Branches intentionally not modified:

- `main-iOS`
- `codex/experimental-features`
- `codex/ios-experimental-features`
- `backup/*`

---

## E. Conflicts found

No local file conflicts were found during the documentation pass.

Open GitHub PR status:

- PR #8: `codex/experimental-features` -> `main`, `UNKNOWN` / `CONFLICTING` observed; treat as unsafe
- PR #9: `codex/ios-experimental-features` -> `main-iOS`, `CONFLICTING`

---

## F. Conflicts resolved

None. No PR merge or runtime conflict resolution was attempted because both open PRs are experimental and unsafe for automatic merge.

---

## G. PRs inspected

Inspected with `gh pr list`:

- #8 `Update experimental Apnea workflow`
- #9 `Add experimental Apnea companion review`

---

## H. PRs safe to merge

None.

---

## I. PRs requiring manual review

- #8: requires explicit experimental merge approval, conflict resolution, macOS build and Diving regression QA.
- #9: requires explicit iOS experimental review; base branch `main-iOS` is historical/divergent and not the current production source of truth.

---

## J. Remaining documentation gaps

- Older historical reports still preserve previous baselines for traceability and may mention stale commit hashes. Current entry points now point to 2026-05-27.
- Superseded 2026-05-28: the iOS Buhlmann ZHL-16C + GF + Helium multigas reference engine is now implemented in iOS MAIN; external validation remains required.
- Any future experimental promotion needs a dedicated branch-by-branch docs refresh after runtime merge decisions.

---

## K. Remaining release blockers

- Apple water-submersion entitlement approval/provisioning for `com.egopfe.dirdiving.ios.watch`.
- Real Apple Watch Ultra QA for automatic depth data, lifecycle, 35/38/40 m warnings, GPS entry/exit, haptics and App Intents/Action Button.
- macOS/Xcode validation: `xcodegen generate`, Watch/iOS builds, Watch/iOS algorithm tests.
- App Store legal review of non-certified planner wording.

---

## L. Suggested next commits

This pass should be committed as:

```text
docs: align current DIR DIVING branch and release docs
```

The Buhlmann runtime work was subsequently implemented as iOS-only code and tests; preserve the docs/code separation in future changes.
- `docs: update planner certification and helium limitations`

---

## M. Risks / assumptions

- Assumption: `main` remains the production-oriented source for both Apple Watch and iOS companion in the unified XcodeGen project.
- Assumption: `main-iOS` remains historical/divergent unless the user requests a dedicated reconciliation.
- Risk: merging PR #8/#9 without manual review could reintroduce experimental runtime files or stale docs into stable MAIN.
- Risk: claiming certified decompression authority remains legally and technically misleading even with the reference engine implemented.

---

## N. Experimental isolation confirmation

Confirmed in documentation and `project.yml`:

- Watch experimental models/services/views are excluded from `DIRDiving Watch App`.
- iOS experimental models/services/views are excluded from `DIRDiving iOS`.
- Snorkeling, Apnea, Buddy Assist and iOS Explore Lab remain experimental.

---

## O. MAIN stability confirmation

This pass changed documentation only. It did not modify:

- business logic
- dive/depth/ascent calculations
- planner algorithms
- GPS behavior
- BUSSOLA algorithms
- sync architecture
- persistence models
- UI layout or visual design
- target membership

Stable MAIN behavior is preserved.
