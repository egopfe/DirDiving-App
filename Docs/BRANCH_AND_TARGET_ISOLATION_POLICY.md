# Branch and Target Isolation Policy (MAIN)

## Canonical release branch

- Release candidate branch is **`main`** (`origin/main`).
- Experimental branches remain isolated and are **not** release sources.
- **`main-iOS`** is a historical divergent worktree — compare manually before any port; not canonical for unified release.

## Branch inventory (2026-06-14)

| Branch | Role | Merge to MAIN |
|--------|------|---------------|
| `main` | Stable Diving + iOS Companion @ `99ea74a` | N/A (canonical) |
| `main-iOS` | Historical iOS worktree | Manual review only |
| `codex/experimental-features` | Watch Snorkeling / Apnea / Buddy | ❌ Without explicit review |
| `codex/ios-experimental-features` | iOS experimental surfaces | ❌ Without explicit review |
| `codex/watch-main-algorithm-audit-current` | Algorithm audit docs (PR #10) | Docs-only review |
| `codex/main-full-code-security-audit-current` | Security audit docs | Docs-only review |
| `backup/*` | Local safety snapshots | Never merge automatically |

Experimental features **never** auto-merge into MAIN. UI alignment must not change Diving business logic.

## MAIN target set

- `DIRDiving Watch App`
- `DIRDiving iOS`
- `DIRDiving Watch Algorithm Tests`
- `DIRDiving iOS Algorithm Tests`

## Bundle identifiers (`project.yml`)

| Target | Bundle ID |
|--------|-----------|
| Watch App | `com.egopfe.dirdiving.ios.watch` |
| iOS Companion | `com.egopfe.dirdiving.ios` |
| Watch Algorithm Tests | `com.egopfe.dirdiving.watch.algorithmtests` |
| iOS Algorithm Tests | `com.egopfe.dirdiving.ios.algorithmtests` |

Prefix: `com.egopfe`. Regenerate with `xcodegen generate` after `project.yml` changes.

## Required compatibility checks before merge/release

- [ ] Watch build passes
- [ ] iOS build passes
- [ ] Watch algorithm tests pass
- [ ] iOS algorithm tests pass
- [ ] Watch/iOS sync codec compatibility tests pass
- [ ] Manual/no-depth session round-trip checks pass
- [ ] CSV round-trip checks pass
- [ ] EN/IT localization key parity passes for Watch and iOS
- [ ] `project.yml` experimental exclusions unchanged

## Automation

- Run `./Scripts/check_main_target_isolation.sh` locally and in CI.
- Run `./Scripts/validate_main_release_readiness.sh` before release tagging.

## Merge conflict priority (documentation + code)

1. Buildable code
2. Stable Diving functionality
3. Latest UI references
4. Latest underwater warning UX (inline, non-blocking)
5. Latest Snorkeling/Apnea **docs** (not runtime without review)
6. Latest release docs
7. Latest audits
8. Experimental isolation

Never overwrite: **BUSSOLA** terminology, inline warning strategy, depth-limit philosophy, sync documentation, legal disclaimers, release/TestFlight docs.

## Related

- [`Docs/README.md`](README.md) — Branch Strategy
- [`Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md`](DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md)
