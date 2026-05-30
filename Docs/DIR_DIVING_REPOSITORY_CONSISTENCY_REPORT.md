# DIR Diving Repository Consistency Report

Date: 2026-05-30  
Branch inspected: `main` @ `3237262`  
Remote: `origin` → `https://github.com/egopfe/DirDiving-App`

## Summary

| Check | Status |
|---|---|
| Working tree clean (pre Phase 15 docs) | PASS @ `3237262` |
| Local `main` == `origin/main` | PASS @ `f7ce3e8` |
| Conflict markers in repo | PASS (none found) |
| Watch files in UX fix commit | PASS (none modified) |
| Experimental files in UX fix commit | PASS (none modified) |
| Bundle IDs consistent (`project.yml`) | PASS |
| README ↔ project.yml scheme names | PASS |
| Documentation ↔ implementation (post Phase 15) | PASS (this pass) |

## Git Inspection

```
Branch: main @ 3237262
Remote: origin/main @ 3237262 (synced before Phase 15 doc commits)
Remote URL: https://github.com/egopfe/DirDiving-App
```

### Branches observed

| Pattern | Examples | Role |
|---|---|---|
| `main` | `main` | Stable Watch + iOS companion (authoritative) |
| `main-iOS` | worktree + `origin/main-iOS` | Historical divergent iOS worktree |
| `codex/*` | `codex/experimental-features`, `codex/ios-experimental-features` | Experimental only |
| `backup/*` | multiple dated backups | Snapshot branches |
| `feature/*` | (none active locally) | Reserved naming |
| `release/*` | (none active locally) | Reserved naming |

No unintended merge artifacts or conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) found in workspace.

## UX Fix Commit Scope (`3237262`)

Files changed (14) — all within allowed iOS UX scope:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Services/PlannerService.swift`, `PlannerStore.swift`
- `iOSApp/Utils/PlannerResultState.swift`, `PlannerInputValidator.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`, `it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/BuhlmannUxReadinessTests.swift`, `BuhlmannReauditFixTests.swift`
- Docs (3) + `DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`

**Not modified:** `App/*`, Watch targets, experimental iOS files, Bühlmann algorithm core, `project.yml` entitlements.

## Bundle ID Consistency

From `project.yml`:

| Target | Bundle ID |
|---|---|
| Watch App | `com.egopfe.dirdiving.ios.watch` |
| iOS App | `com.egopfe.dirdiving.ios` |
| Watch Algorithm Tests | `com.egopfe.dirdiving.watch.algorithmtests` |
| iOS Algorithm Tests | `com.egopfe.dirdiving.ios.algorithmtests` |

`WKCompanionAppBundleIdentifier` = `com.egopfe.dirdiving.ios` — consistent with embedded Watch pairing model.

## Documentation Consistency

Post Phase 15 alignment:

- README, CHANGELOG, ROADMAP reflect `3237262` UX fix and READY verdict
- Feature matrix includes planner UX readiness rows
- Re-audit doc supersedes *Partially ready* UX audit verdict
- Release/TestFlight notes reference Bühlmann UX readiness completion
- INDEX.md links all new audit/report documents

## Experimental Isolation

- `project.yml` excludes experimental sources from MAIN targets (unchanged)
- PR #8 / #9 remain experimental and not auto-merged (documented in branch alignment)
- No experimental runtime code merged in UX fix commit

## Stale References Corrected

- ROADMAP: iOS Bühlmann UX/UI audit status updated from 🟡 Partially ready → ✅ Ready
- README baseline commit updated from older hashes to current `3237262` planner UX state
- CONTRIBUTING: links to UX re-audit and verification reports

## Recommendations Before App Store

1. Physical Apple Watch Ultra entitlement + depth QA (unchanged P0)
2. Physical VoiceOver walkthrough on planner input/result flows
3. Large Dynamic Type stress test on planner cards
4. External Bühlmann validation campaign before stronger release claims

## Verdict

**Repository consistency: PASS** for MAIN @ `f7ce3e8` (Phase 15 complete; `origin/main` synced).
