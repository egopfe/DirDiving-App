# DIR DIVING — Branch alignment (2026-05-30)

**Baseline:** `main` = `origin/main` (Phase 15 complete; UX fix @ `3237262`)  
**Remote:** `origin` → `https://github.com/egopfe/DirDiving-App`

## Branch strategy (authoritative)

| Branch / pattern | Role | Merge to `main` |
|---|---|---|
| `main` | Stable Watch Diving + iOS companion (single repo) | — |
| `origin/main` | Remote tracking branch | Sync target |
| `main-iOS` | Historical worktree; divergent from unified `main` | Manual review only |
| `codex/experimental-features` | Watch Snorkeling/Apnea/Buddy experimental | Explicit review; PR #8 CONFLICTING |
| `codex/ios-experimental-features` | iOS Explore/Buddy experimental | Explicit review; PR #9 CONFLICTING |
| `backup/*` | Dated snapshot branches | Never auto-merge |
| `feature/*` | Feature development naming | PR + review |
| `release/*` | Release candidate naming | PR + review |
| `watch-main` | Documented alias for Watch-stable lineage on `main` | N/A |
| `watch-experimental` | Documented alias for `codex/experimental-features` | N/A |
| `ios-experimental` | Documented alias for `codex/ios-experimental-features` | N/A |

## Current MAIN capabilities (iOS planner)

After `3237262`:

- Bühlmann ZHL-16C N2+He multigas reference engine (algorithm @ `69e69b2`)
- Multigas / trimix / helium / GF / NDL / deco stops
- Environment-aware pressure model (altitude + salinity)
- Repetitive planning UX (toggle, SI, snapshot status, fail-closed)
- Schedule gas ledger per cylinder in results
- Typed warning taxonomy + result headers
- CNS/OTU reference-only disclaimers
- **UX/UI readiness verdict: READY** — [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md)

## Experimental isolation

- MAIN `project.yml` excludes Apnea, Snorkeling, Buddy, iOS experimental views
- UX fix commit `3237262` touched zero Watch and zero experimental files
- PR #8 / #9: do not auto-merge; preserve F1–F12 security and project exclusions

## Documentation chain

1. Algorithm reaudit: [`DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md) → fix @ `69e69b2`
2. UX readiness audit: [`../DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md`](../DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md) → gaps identified
3. UX fix: `3237262` → [`../DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`](../DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md)
4. UX re-audit: [`DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md) → **READY**
5. Repository consistency: [`DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md`](DIR_DIVING_REPOSITORY_CONSISTENCY_REPORT.md)

## Policy

- Never force-push `main`
- Never auto-merge experimental runtime into `main`
- Separate docs commits from runtime commits when possible
- macOS required for `xcodegen` / `xcodebuild` validation
