# DIR DIVING — Documentation update report (pre-release backlog pass)

**Date:** 2026-05-19
**Branch in focus:** `main` (Apple Watch MAIN + iOS unified workspace), with companion update on `main-iOS`.
**Predecessor docs:** `DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY.md`, `DOCUMENTATION_UPDATE_REPORT_20260519_SECURITY_PT2.md`, `DOCUMENTATION_UPDATE_REPORT_20260519_I18N.md`, `DOCUMENTATION_UPDATE_REPORT_20260519.md`.

This report covers the documentation-only pass that follows the 2026-05-19 MAIN pre-release backlog execution (UX-H1..H5, UX-M1..M13, UX-L1..L9, SAF-3..SAF-10, Phase-5 haptics + App Intents).

> Scope rules honored: no business logic change, no decompression / TTV / TTR / gas-model / sync-rule edits, no UI redesign, no experimental file touched, terminology preserved (`BUSSOLA`, never `COMPASSO`).

---

## A. Files updated

### On `main` (this pass, all documentation-only)

1. `README.md` — new section **“Pre-release backlog (2026-05-19, UX-H/M/L + SAF-3..SAF-10)”** inserted between the security PT2 note and the i18n section. Adds the acceptance matrix per area and the documented procedure to reintegrate the 3 Watch backlog commits from `backup/main-watch-backlog-20260519` with the F1–F12 cluster.
2. `CHANGELOG.md` — new **Added / Changed / Nota** entries under `[Unreleased]` documenting the new docs, the backup branches, and the iOS SAF-3/SAF-4 commit on `main-iOS`.
3. `Docs/DIR_DIVING_Feature_Comparison.csv` — 16 additive rows: 2 documents, per-area status rows for UX-H1..H5, UX-M*/L* clusters, SAF-3/7/8/10, Phase-5 App Intents, plus this report row. Existing rows untouched.
4. `Docs/DOCUMENTATION_UPDATE_REPORT_20260519_PRE_RELEASE_BACKLOG.md` — this report.
5. `Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md` (already committed in `baa1681`).
6. `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` (already committed in `baa1681`).

### On `main-iOS` (already committed in `bf4718d`)

1. `iOSApp/Services/DiveImportService.swift` — SAF-4 bound tightening (200 m / 480 min / -2..40 °C).
2. `iOSApp/Views/DiveDetailView.swift` — SAF-3 accessibility hint + muted footnote on the `TTV info` tile.
3. `Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`.
4. `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`.

> All other doc files (`Docs/EXPERIMENTAL_FEATURES.md`, `Docs/APNEA_EXPERIMENTAL_SPEC.md`, `Docs/SNORKELING_EXPERIMENTAL_SPEC.md`, `Docs/UI_UX_VISUAL_GUIDELINES.md`, `Docs/GLOSSARY.md`, `Docs/BUILD_VALIDATION.md`, `Docs/RELEASE_CHECKLIST.md`, `CONTRIBUTING.md`) were inspected and found already accurate vs the current state of the code on the respective branches. No additive edits were necessary in this pass.

## B. Branches inspected

| Branch | Local state | Remote state | Notes |
|---|---|---|---|
| `main` | up-to-date with `origin/main` after pre-pass cherry-pick of `baa1681` | `baa1681` HEAD | Watch UI sources (e.g. `Views/ContentView.swift`) still contain `ModeSelectionView` in tab order on `origin/main`; UX-M1 removal lives on backup branch only. |
| `main-iOS` (worktree at `.worktrees/main-iOS`) | up-to-date with `origin/main-iOS` | `bf4718d` HEAD | SAF-3 + SAF-4 + pre-release docs already pushed in `bf4718d`. |
| `codex/experimental-features` | not checked out | tip `6d12e6a` | 26 commits ahead of `main`, 9 behind. Touches experimental files (ApneaView, BuddyAssistView, ExperimentalConceptsView, ExplorationStore, ExperimentalSyncContracts) plus security-overlapping `Services/WatchSyncService.swift` and `Services/WatchDiveSyncCodec.swift`. Already includes the new pre-release docs from `main`. |
| `codex/ios-experimental-features` | not checked out | tip `88d3472` | 116 commits ahead of `main-iOS`, 6 behind. Touches experimental iOS features (Buddy Lab, Technical Planner extensions, alternate AppIcon assets). Already includes the new pre-release docs from `main-iOS`. |
| `backup/main-watch-backlog-20260519` | local only | not pushed | Preserves the 3 Watch UX backlog commits (`cbcabf7`, `c685155`, `efa53e4`). |
| `backup/before-docs-pre-release-pass-20260519` | local only | not pushed | Snapshot of `main` HEAD immediately before this documentation pass. |

## C. Branches updated

| Branch | Action | Commit |
|---|---|---|
| `main` | documentation-only commit added on top of `baa1681` | to be created as `docs: update DIR DIVING feature documentation and branch matrix (pre-release backlog)` |
| `main-iOS` | already current (`bf4718d`) | nothing further this pass |
| `codex/experimental-features` | not modified (by policy) | none |
| `codex/ios-experimental-features` | not modified (by policy) | none |
| Backup branches | created/preserved only, never pushed | none |

## D. Conflicts found

1. **`main` ↔ `backup/main-watch-backlog-20260519`** — the Watch backlog cluster (`cbcabf7`, `c685155`, `efa53e4`) and the F1–F12 security cluster (`4136ec0`) both edit `Services/WatchSyncService.swift` and `Services/WatchDiveSyncCodec.swift`. The two clusters live on parallel histories rooted on the common ancestor `e8b70a2`.
2. **`main` ↔ `codex/experimental-features`** — overlap on `Services/WatchSyncService.swift`, `Services/WatchSyncAuth.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/AscentRateSettingsStore.swift`, `Utils/WatchSyncNotifications.swift`, plus experimental-only files. PR #8 status remains `CONFLICTING` on GitHub per earlier security pass notes.
3. **`main-iOS` ↔ `codex/ios-experimental-features`** — overlap on `Services/AscentRateSettingsStore.swift`, `Services/ActionButtonIntents.swift`, `Services/AppNavigationStore.swift`, plus alternate AppIcon set and additional iOS-only experimental views. PR #9 status remains `CONFLICTING`.

## E. Conflicts resolved

- **None resolved in this pass** (documentation-only pass by design).
- The Watch backlog ↔ security overlap (item D.1) has a documented procedure in `README.md` §“Pre-release backlog (2026-05-19, UX-H/M/L + SAF-3..SAF-10)” — `git cherry-pick cbcabf7 c685155 efa53e4` then resolve `Services/WatchSyncService.swift` / `Services/WatchDiveSyncCodec.swift` preferring security F1–F12 on crypto / data-protection edits and the backlog commit on UX-only edits.
- Items D.2 and D.3 are left to the maintainer per the standing constraint that experimental ↔ MAIN merges require explicit review and macOS build validation.

## F. PRs inspected

> Note: the GitHub CLI (`gh`) is not installed in this environment and the GitHub REST API endpoint for the private repository returns `404` without an auth token. PR inspection in this pass is therefore done **via branch comparison**, not via the GitHub API. The PR numbers and titles below come from the prior security audit pass that did have `gh` access; they are reproduced here for continuity.

### PR #8 — `codex/experimental-features` → `main` (Watch experimental)

- **Head:** `6d12e6a Add language selector localization support`
- **Affected file areas:** `Views/ApneaView.swift`, `Views/BuddyAssistView.swift`, `Views/ExperimentalConceptsView.swift`, `Views/SnorkelingView.swift`, `Services/ExplorationStore.swift`, `Models/ExperimentalSyncContracts.swift`, `Models/ExplorationModels.swift`, `Utils/ExperimentalFeatures.swift`, plus overlap on `Services/WatchSyncService.swift`, `Services/WatchSyncAuth.swift`, `Services/WatchDiveSyncCodec.swift`, `Services/AscentRateSettingsStore.swift`, `Utils/WatchSyncNotifications.swift`, `Resources/{en,it}.lproj/Localizable.strings`, `Views/AlarmSettingsView.swift`, `Views/DiveLiveView.swift`, `Views/DiveUIComponents.swift`, `Views/ContentView.swift`, `Models/AppPage.swift`, `Services/HapticService.swift`, `Services/DiveLogStore.swift`, `Services/SubsurfaceExportService.swift`.
- **Conflict status:** CONFLICTING (carried over from prior pass).
- **Merge recommendation:** **NOT safe to merge automatically.** Requires:
  1. macOS build with simulator runtime installed.
  2. Conservative resolution of overlapping security files preserving F1–F12 protections.
  3. Watch UX backlog reintegration must happen **before** experimental merge so the conflict matrix is two-way, not three-way.
  4. Snorkeling/Apnea acceptance against the master references in `Docs/FeatureScreenshots/`.
- **Risks:** regressing Data Protection on `Services/SubsurfaceExportService.swift`, replay window widening on `Services/WatchDiveSyncCodec.swift`, breaking BUSSOLA terminology in localized strings.
- **Required manual checks:** §3 of `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` plus §3.3 SAF security checks from `Docs/RELEASE_CHECKLIST.md`.

### PR #9 — `codex/ios-experimental-features` → `main-iOS` (iOS experimental)

- **Head:** `88d3472 Add iOS language selector localization support`
- **Affected file areas:** experimental iOS views (Buddy Lab, technical planner extensions, contingencies briefing), alternate AppIcon asset catalog (full reset of `Resources/Assets.xcassets/AppIcon.appiconset/`), `App/DIRDivingApp.swift`, `App/Info.plist`, `Config/DIRDiving.entitlements`, `.github/workflows/build.yml`, plus overlap on `Services/ActionButtonIntents.swift`, `Services/AppNavigationStore.swift`, `Services/AscentRateSettingsStore.swift`, several `Models/*.swift`.
- **Conflict status:** CONFLICTING (carried over from prior pass).
- **Merge recommendation:** **NOT safe to merge automatically.** Requires:
  1. Decision on the AppIcon set (experimental introduces a wholesale replacement — confirm intent before merge).
  2. Reconciliation against the SAF-4 bound tightening landed in `bf4718d` on `main-iOS`: the experimental branch had previously regressed those bounds (audit Appendix A).
  3. Confirmation that the experimental Buddy Lab and technical planner additions are gated behind `Utils/ExperimentalFeatures.swift` and not pulled into the MAIN target via `project.yml`.
- **Risks:** Data Protection regression on iOS export (F4), CSV bound regression (F5/SAF-4), accidental MAIN inclusion of experimental flows, AppIcon overwrite.
- **Required manual checks:** §6 of `Docs/RELEASE_CHECKLIST.md` (Security QA), `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md` §5/§6/§7 (Logbook/Planner/More).

## G. PRs safe to merge

- **None in this pass.** Both PR #8 and PR #9 require manual conflict resolution on macOS with Xcode platform runtimes installed (see Open Items §2.1).

## H. PRs requiring manual review

- PR #8 — see §F.
- PR #9 — see §F.

## I. Documentation gaps still open

1. **`main` Watch UI README description** vs current state — README §“Main Navigation” still lists `1. Mode selector screen` as the first tab. This is accurate for `origin/main` today but will become stale the moment the Watch backlog commits (UX-M1) are merged. Action: refresh the README after the cherry-pick reintegration; do **not** change it now to avoid drift from current code.
2. **`main-iOS` CSV schema** — `Docs/DIR_DIVING_Feature_Comparison.csv` on `main-iOS` is on the older 9-column schema (no `Internationalization` column). Aligning it requires updating all ~100 existing rows; deferred as a structural change. Action: TODO row already present in this CSV; convergence rides with §1.5 of `Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`.
3. **Per-session sync delivery UI** — Both Watch Settings and iOS More currently surface a `TODO` row for SAF-10. Real per-record delivery status (mapping `WCSession` ack callbacks to a `DiveSession.id`) is planned but not in this pass.
4. **Imperial unit conversion on Watch (UX-M7 / UX-L2 follow-up)** — UI is honest today; conversion engine is out of scope.
5. **Localized error strings in `DiveImportService` (i18n F10 follow-up)** — keys pre-published in EN/IT; runtime strings still IT-hardcoded.

## J. Suggested next commits

1. `docs: update DIR DIVING feature documentation and branch matrix (pre-release backlog)` — this commit (this pass on `main`).
2. `git cherry-pick cbcabf7 c685155 efa53e4 # on main, resolve sync conflicts vs F1–F12` — Watch backlog reintegration (separate commit, after macOS build verification).
3. `docs(main-iOS): refresh README iOS Stable Alignment with SAF-3/SAF-4` — optional refresh on `main-iOS` README to mention the inline TTV info footnote and the tighter CSV bounds, if the maintainer chooses to surface those at top-of-README level.
4. PR comment to #8 and #9: paste the §F summary as a status comment via `gh pr comment` once `gh` is available; do **not** merge from automation.

## K. Risks and assumptions

- **Risk:** if the Watch backlog cherry-pick is performed without considering F1–F12, signed-ack and Data Protection wins may regress. Mitigation: the README procedure explicitly states the conflict-resolution policy (prefer security on crypto/Data Protection, prefer backlog on UX-only).
- **Risk:** running `swiftc -parse / -typecheck` is not a substitute for a real `xcodebuild`. The platform runtimes for iOS 26.5 and watchOS 26.5 are not installed in this environment; a full build pass is still owed. Mitigation: §0 of `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`.
- **Assumption:** `bf4718d` on `origin/main-iOS` correctly carries SAF-3 + SAF-4; verified by `git log -1` and by reading the post-edit content of the touched files.
- **Assumption:** the GitHub PR numbers #8 and #9 referenced here match the still-open PRs from the prior security pass. They are reproduced from the prior `gh pr view` output rather than fetched live this pass.
- **Assumption:** terminology rules continue to apply across all branches: `BUSSOLA`, never `COMPASSO`. No file edited this pass introduces `COMPASSO`.

---

*Generated as part of the MAIN pre-release backlog documentation pass, 2026-05-19. Companion docs: `Docs/MAIN_PRE_RELEASE_OPEN_ITEMS_20260519.md`, `Docs/MAIN_PRE_RELEASE_SIMULATOR_QA_20260519.md`, `Docs/SECURITY_AUDIT_MAIN_AND_MAIN_IOS_20260519.md`.*
