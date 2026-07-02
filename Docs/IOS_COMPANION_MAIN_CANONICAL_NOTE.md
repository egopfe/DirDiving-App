# iOS Companion MAIN — Canonical Source Note

Date: 2026-05-19
Branch: `main-iOS`
Audit reference: `Docs/MAIN_BRANCHES_UX_INTERACTION_AUDIT_20260518_POST_FIX_PRE_MODIFICATION.md`
Backlog reference: 2026-05-19 pre-release backlog (UX-H5)

## Summary

For the iOS companion app, **`main-iOS` is the canonical MAIN branch** going
forward. The Apple Watch app remains on the `main` branch with `project.yml`
limited to the Watch target.

## Why the divergence existed

Historically, the Apple Watch `main` branch carried a copy of `iOSApp/`
sources that diverged from the dedicated iOS branch. The pre-release audit
flagged this as UX-H5 (Tab divergence). Concretely, on the Watch `main`
branch the `iOSApp/` companion exposed a 5-tab layout, while on `main-iOS`
it exposes the canonical 6-tab layout including Explore.

## Resolution (this commit)

- The canonical iOS Companion product is whatever `main-iOS` builds via
  the iOS-only `project.yml` (single target, six tabs).
- The `iOSApp/` files inside the Apple Watch `main` branch are not used by
  the Watch build (`project.yml` Watch target excludes them) and remain
  for legacy compatibility only. They MUST NOT be edited to add or remove
  iOS tabs; iOS work happens exclusively on `main-iOS`.
- No experimental iOS files are pulled into `main-iOS`. Specifically the
  following experimental files remain excluded from this branch:
  - `ExplorationCenterView.swift`
  - `ExperimentalFutureConceptsView.swift`
  - `BuddyExperimentalView.swift`
  - `BuddyExperimentalStore.swift`
  - `BuddyExperimentalModels.swift`
  - `ExplorationModels.swift`
  - `ExplorationPlanningStore.swift`

## Build contract (recap)

```sh
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination "platform=iOS Simulator,name=iPhone 15 Pro" build
```

## Cross-branch coupling

The only cross-branch protocol is WatchConnectivity. Both branches share:

- `WatchSyncKeys.deletedSessionIDsKey` (unified tombstone key).
- `WatchSyncKeys.unitsPreferenceKey` (iOS -> Watch applicationContext, UX-M7).
- `WatchDiveSyncCodec` HMAC contract (peer secret managed by `WatchSyncAuth`,
  signed payloads verified bidirectionally — see UX-H1/UX-H2).

Any future schema change to those keys MUST land on both branches before
release.
