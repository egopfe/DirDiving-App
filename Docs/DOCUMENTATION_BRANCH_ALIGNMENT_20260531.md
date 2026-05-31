# Documentation branch alignment — 2026-05-31 (readiness 100%)

**Baseline:** `main` = `origin/main` @ `21da64e` (Watch + iOS algorithmic + UI/UX readiness 100% codice, 2026-05-31)  
**Algorithm commits:** Watch WMATH remediation @ `f654bec` + iOS @ `dce89e7`  
**UI/UX commits:** P0–P2 @ `d796bfd` + P3 @ `c8f91f6`  
**CI:** `macos-latest` runner (may fail if Actions minutes exhausted)

## Branch roles

| Branch | Role | Docs state | Sync @ |
|--------|------|------------|--------|
| `main` | Stable Watch Diving + iOS Companion MAIN | Authoritative; algorithm + UI/UX readiness 100% (codice) | `21da64e` |
| `main-iOS` | Historical / divergent iOS worktree | Merged `main`; not separate release baseline | `6e7e30e` |
| `codex/experimental-features` | Watch experimental (Apnea, Snorkeling, Buddy) | Merged readiness + UI/UX docs from `main`; experimental runtime unchanged | `48b3f3a` |
| `codex/ios-experimental-features` | iOS experimental companion | Merged readiness + UI/UX implementation + docs | `78890c5` |
| `codex/watch-main-algorithm-audit-current` | Watch MAIN audit (PR #10) | Superseded by `main` remediation; close PR #10 recommended | `4425311` |

## Open pull requests (2026-05-31)

| PR | Head → base | Merge conflicts | Notes |
|----|-------------|-----------------|-------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` → `main` | None expected | Experimental — do not merge without explicit release decision |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` → `main` | None expected | Experimental iOS |
| [#10](https://github.com/egopfe/DirDiving-App/pull/10) | `codex/watch-main-algorithm-audit-current` → `main` | None | Superseded — full remediation on `main`; close PR recommended |

## Conflict policy

- **`main` wins** for iOS MAIN algorithm paths when merging feature branches.
- **Experimental-only files** stay on experimental branches; excluded from `main` `project.yml`.
- **Documentation-only sync** may merge `main` into experimental branches without promoting experimental runtime to `main`.

## Key documents (2026-05-31)

- [`MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md`](MAIN_UI_UX_READINESS_AUDIT_POST_FIX.md) — MAIN UI/UX 100% (codice) @ `c8f91f6`
- [`MAIN_UI_UX_READINESS_QA_ANALYSIS.md`](MAIN_UI_UX_READINESS_QA_ANALYSIS.md) — build/test QA for UI/UX pass
- [`WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md`](WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md) — Watch MAIN 100% (codice)
- [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) — Policy A sync
- [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) — iOS MAIN 100%
- [`DOCUMENTATION_UPDATE_REPORT_20260531.md`](DOCUMENTATION_UPDATE_REPORT_20260531.md) — full doc pass log (Parts 1–4)
