# Documentation branch alignment — 2026-05-31 (readiness 100%)

**Baseline:** `main` = `origin/main` @ `1d69d88`  
**Algorithm commit:** `dce89e7` (iOS MAIN readiness 100%)  
**CI commit:** `1d69d88` (`macos-latest` runner)

## Branch roles

| Branch | Role | Docs state |
|--------|------|------------|
| `main` | Stable Watch Diving + iOS Companion MAIN | Authoritative; includes readiness report + audit |
| `main-iOS` | Historical / divergent iOS worktree | Merged `main` @ `dce89e7`; not separate release baseline |
| `codex/experimental-features` | Watch experimental (Apnea, Snorkeling, Buddy) | Merged readiness docs from `main`; experimental runtime unchanged in scope |
| `codex/ios-experimental-features` | iOS experimental companion | Merged readiness implementation + docs |
| `codex/watch-main-algorithm-audit-current` | Watch MAIN audit (PR #10) | Includes iOS readiness docs via merge; Watch audit doc on branch only |

## Open pull requests (2026-05-31)

| PR | Head → base | Merge conflicts | Notes |
|----|-------------|-----------------|-------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` → `main` | None | Experimental — do not merge without explicit release decision |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` → `main` | None | Experimental iOS |
| [#10](https://github.com/egopfe/DirDiving-App/pull/10) | `codex/watch-main-algorithm-audit-current` → `main` | None | Watch MAIN audit docs |

All three PRs synced with `main` through `1d69d88`. CI Build workflow may fail if GitHub Actions macOS minutes are exhausted (runner not assigned).

## Conflict policy

- **`main` wins** for iOS MAIN algorithm paths when merging feature branches.
- **Experimental-only files** stay on experimental branches; excluded from `main` `project.yml`.
- **Documentation-only sync** may merge `main` into experimental branches without promoting experimental runtime to `main`.

## Key documents @ `dce89e7`

- [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — audit snapshot (76% @ `4d5aabc`)
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — remediation report (100% code criteria)
- [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) — full doc pass log
