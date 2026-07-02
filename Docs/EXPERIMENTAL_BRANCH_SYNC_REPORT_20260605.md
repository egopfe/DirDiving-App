# Experimental Branch Sync Report - 2026-06-05

**Scope:** Documentation-only status update for the experimental branches after verifying the latest remote refs. No runtime, algorithm, sync, persistence, UI, entitlement, or project membership code was changed by this pass.

## Latest Remote Baseline Verified

| Ref | Commit | Notes |
|-----|--------|-------|
| `origin/main` | `ecad0d9` | Latest MAIN at verification time; UI/UX readiness 100% pass for Watch and iOS MAIN |
| `origin/codex/experimental-features` | `227bcaa` | Watch/iOS combined experimental branch, fast-forwarded through `origin/main` |
| `origin/codex/ios-experimental-features` | `441fb77` | iOS-named experimental branch, fast-forwarded through `origin/main` |

Both local experimental worktrees were clean, fetched with `git fetch origin --prune`, and fast-forwarded before this documentation update.

## Branch Roles

| Branch | Current Role | Merge Guidance |
|--------|--------------|----------------|
| `codex/experimental-features` | Canonical combined experimental branch for Watch Apnea/Snorkeling plus matching iOS companion experimental surfaces | Do not merge to `main` without explicit hardware, safety, UI/UX, and target-isolation review |
| `codex/ios-experimental-features` | iOS-named experimental branch aligned for app/project code paths while preserving branch-specific iOS docs | Do not merge to `main` or `main-iOS` automatically |

## Function Scope Confirmed

- **Apnea:** remains experimental. Watch Apnea mode, recovery/session surfaces, and iOS companion review/exploration surfaces are isolated to the experimental branches.
- **Snorkeling:** remains experimental. Watch snorkeling runtime/navigation/POI surfaces and iOS companion exploration/route review surfaces are isolated to the experimental branches.
- **Buddy / BLE messaging:** remains experimental/lab-only. Buddy Assist, BLE relay, peer pairing, and messaging must not be copied to MAIN as part of an Apnea/Snorkeling-only promotion.

## Prior Fixes Reflected

The previous consistency pass fixed the experimental app wiring before this documentation update:

- Watch app creates and injects `ExplorationStore`.
- Watch app creates and injects `BuddyAssistService`.
- Watch mode selection exposes the experimental multi-mode entry points.
- iOS app creates and injects `ExplorationPlanningStore`.
- iOS app creates and injects `BuddyExperimentalStore`.
- iOS Explore and Buddy tabs are reachable.
- `ExploreView` is reachable from `ExplorationCenterView`.
- `project.yml` keeps a single `iOSApp/Services/WatchSyncAuth.swift` entry in the iOS algorithm test target.

## Verification Boundary

Static Git/source verification was performed on Windows. `xcodebuild` and `xcodegen` are not available in this environment, so final validation still requires macOS:

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" ...
xcodebuild -scheme "DIRDiving iOS" ...
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" test ...
```

Hardware QA remains required before any production promotion of Apnea or Snorkeling.
