# Documentation branch alignment — 2026-05-31 (readiness 100%)

**Baseline:** `main` = `origin/main` @ `e952b55` (Watch MAIN readiness 100% pass, 2026-05-31)  
**Algorithm commits:** Watch WMATH remediation @ `f654bec` + iOS `dce89e7`  
**CI:** `macos-latest` runner (may fail if Actions minutes exhausted)

## Branch roles

| Branch | Role | Docs state | Sync @ |
|--------|------|------------|--------|
| `main` | Stable Watch Diving + iOS Companion MAIN | Authoritative; Watch + iOS readiness 100% reports | `e952b55` |
| `main-iOS` | Historical / divergent iOS worktree | Merged `main`; not separate release baseline | `0a3073e` |
| `codex/experimental-features` | Watch experimental (Apnea, Snorkeling, Buddy) | Merged readiness docs from `main`; experimental runtime unchanged in scope | `0e08748` |
| `codex/ios-experimental-features` | iOS experimental companion | Merged readiness implementation + docs | `62c1dec` |
| `codex/watch-main-algorithm-audit-current` | Watch MAIN audit (PR #10) | Superseded by `main` remediation; close PR #10 recommended | `70511d1` |

## Open pull requests (2026-05-31)

| PR | Head → base | Merge conflicts | Notes |
|----|-------------|-----------------|-------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` → `main` | None | Experimental — do not merge without explicit release decision |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` → `main` | None | Experimental iOS |
| [#10](https://github.com/egopfe/DirDiving-App/pull/10) | `codex/watch-main-algorithm-audit-current` → `main` | None | Superseded — full remediation on `main`; close PR recommended |

All branches merged/pushed through `e952b55`:

| Branch | Commit | Notes |
|--------|--------|-------|
| `main` | `e952b55` | Watch readiness 100% + INDEX baseline |
| `main-iOS` | `0a3073e` | LogbookView conflict resolved (unitPreference + maxDepthLine) |
| `codex/experimental-features` | `0e08748` | Docs/runtime from main; experimental scope unchanged |
| `codex/ios-experimental-features` | `62c1dec` | `project.yml` Watch Algorithm Tests target from main |
| `codex/watch-main-algorithm-audit-current` | `70511d1` | Superseded; audit doc from main |

## Conflict policy

- **`main` wins** for iOS MAIN algorithm paths when merging feature branches.
- **Experimental-only files** stay on experimental branches; excluded from `main` `project.yml`.
- **Documentation-only sync** may merge `main` into experimental branches without promoting experimental runtime to `main`.

## Key documents (2026-05-31)

- [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) — Watch MAIN 100% (codice)
- [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) — Policy A sync
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — iOS MAIN 100%
- [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — audit snapshot (76% @ `4d5aabc`)
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — remediation report (100% code criteria)
- [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) — full doc pass log
