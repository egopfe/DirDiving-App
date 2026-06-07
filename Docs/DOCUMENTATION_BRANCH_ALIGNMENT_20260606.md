# DIR DIVING — Documentation / Branch Alignment Report (2026-06-06)

> **Superseded for HEAD baseline:** use [`DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md`](DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md) @ `a69bc4b` (2026-06-07). This file is retained as historical record.

**Scope:** Documentation-only alignment pass. No runtime, algorithm, sync architecture, or persistence changes.

**Baseline audited:** `main` @ `90dc3f5` (`fix(ios): localize Watch photo send and manage button labels`)

**Backup branch:** `backup/docs-alignment-20260606` (created before this pass)

---

## A. Files updated

| File | Change |
|------|--------|
| `README.md` (repo root) | **Created** — pointer to `Docs/README.md`, quick links, baseline commit |
| `Docs/README.md` | Baseline → `90dc3f5`; photo transfer/management pass; Branch Strategy HEAD |
| `Docs/INDEX.md` | Section 2026-06-06 documentation alignment + photo remediation status |
| `Docs/CHANGELOG.md` | Unreleased entries: photo UX, Watch staging fix, docs alignment |
| `Docs/ROADMAP.md` | Released rows: photo ACK, manual send, iOS manage sheet, docs pass |
| `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` | Branch inventory, bundle IDs, worktrees, experimental isolation |
| `Docs/ReferenceUI/README.md` | Mandatory UI references (Watch, iOS, ascent, Snorkeling, Apnea) |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | New rows (photo management, docs pass) — no rows deleted |

## B. Docs created

| File | Purpose |
|------|---------|
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md` | This report (Phase 10) |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260606.md` | Short changelog of doc edits |
| `Docs/PR_STATUS_20260606.md` | Open PR inspection snapshot |

## C. Branches inspected

| Branch | Remote | Notes |
|--------|--------|-------|
| `main` | ✅ `origin/main` @ `90dc3f5` | Canonical release candidate |
| `main-iOS` | ✅ divergent worktree | Historical iOS-only alignment; not release source |
| `codex/experimental-features` | ✅ | Watch Snorkeling / Apnea / Buddy — isolated |
| `codex/ios-experimental-features` | ✅ | iOS experimental surfaces — isolated |
| `codex/watch-main-algorithm-audit-current` | ✅ | Docs-only audit branch; PR #10 |
| `codex/main-full-code-security-audit-current` | ✅ | Security audit docs |
| `backup/*` | local only | Safety snapshots; not pushed by this pass |

**Worktrees (known):** `.worktrees/main-iOS`, `codex-ios-experimental`, `codex-experimental`, `watch-audit`

## D. Branches updated

This pass modifies **`main` only** (documentation commits). Experimental branches are **not** merged into `main`. Worktree branches may receive doc-only cherry-picks manually if needed.

## E. Conflicts found

None during this documentation-only pass on `main`.

## F. Conflicts resolved

N/A (no merge performed).

## G. PRs inspected

| PR | Branch | Summary | Runtime risk | Doc risk | Recommendation |
|----|--------|---------|--------------|----------|----------------|
| [#8](https://github.com/egopfe/DirDiving-App/pull/8) | `codex/experimental-features` | Experimental Apnea workflow | **High** if merged to MAIN | Low | **Do not auto-merge** — experimental only |
| [#9](https://github.com/egopfe/DirDiving-App/pull/9) | `codex/ios-experimental-features` | Apnea companion review | **High** if merged to MAIN | Low | **Do not auto-merge** — experimental only |
| [#10](https://github.com/egopfe/DirDiving-App/pull/10) | `codex/watch-main-algorithm-audit-current` | Watch MAIN algorithm audit docs | **Low** (docs) | Low | **Safe for doc review** — verify no accidental runtime diff before merge |

## H. PRs safe to merge (with review)

- **#10** — if diff is documentation-only and does not alter Diving runtime on `main`.

## I. PRs requiring manual review

- **#8**, **#9** — experimental runtime; require hardware QA and explicit isolation review before any MAIN merge.
- **#10** — confirm audit doc claims match `90dc3f5` codebase.

## J. Remaining documentation gaps

| Gap | Priority |
|-----|----------|
| PNG reference assets not in repo (`Watch_LIVE_reference.png`, `iOS_Companion_reference.png`) | P1 before App Store visual gate |
| Snorkeling / Apnea / ascent-warning mockup PNGs in `Docs/ReferenceUI/` | P2 — capture from experimental branches |
| Physical-device QA evidence packs (Ultra depth, photo sync pair, App Intents) | P0 release |
| `main-iOS` worktree doc divergence vs unified `main` | P2 process |
| Entitlement approval status (water submersion) | P0 Apple |

## K. Remaining release blockers

1. Apple **water submersion / depth** entitlement approval and signed Ultra builds.
2. Physical QA: depth lifecycle, 35/38/40 m discouragement, ascent inline banners, sync tombstones, photo transfer on real pair.
3. App Store assets (icons, screenshots) from `Docs/ReferenceUI/` checklist.
4. External Bühlmann validation (reference-only engine — not certification).

## L. Suggested next commits

1. `docs: align DIR DIVING architecture and release documentation` (this pass)
2. `docs: update feature comparison matrix and branch strategy` (if split)
3. Future: `docs: add ReferenceUI PNG captures` after simulator/device screenshots

## M. Risks / assumptions

- Assumes `90dc3f5` is the authoritative MAIN runtime; older doc commit hashes preserved as historical context.
- Photo transfer remediation (`fc311be`, `90dc3f5`) marked **implemented** based on code + build/test reports; **device QA still open**.
- Root `README.md` added for GitHub discoverability; canonical doc remains `Docs/README.md`.
- User requested remote sync — push after doc commit on `main` only unless user expands scope.

## N. Experimental isolation confirmation

- `project.yml` MAIN targets: `DIRDiving Watch App`, `DIRDiving iOS`, algorithm test bundles only.
- Bundle IDs: `com.egopfe.dirdiving.ios.watch`, `com.egopfe.dirdiving.ios`, test suffixes `.watch.algorithmtests` / `.ios.algorithmtests`.
- Snorkeling, Apnea, Buddy Assist documented under `codex/experimental-features` and `codex/ios-experimental-features` — **not** in MAIN `project.yml` production targets.
- `./Scripts/check_main_target_isolation.sh` remains required before merge/release.

## O. MAIN stability confirmation

- No business logic, dive/planner/sync algorithms, or persistence models changed in this pass.
- Diving mode, **BUSSOLA** terminology (never COMPASSO), inline ascent warnings, GPS surface-only, legal onboarding, depth-limit discouragement (35/38/40 m), and underwater non-blocking warning philosophy preserved in all updated docs.
- Last verified build @ `90dc3f5`: `xcodegen generate` → Watch + iOS **BUILD SUCCEEDED**; iOS Algorithm Tests **TEST SUCCEEDED** (prior session).

---

**Related:** [`DOCUMENTATION_UPDATE_REPORT_20260606.md`](DOCUMENTATION_UPDATE_REPORT_20260606.md) · [`PR_STATUS_20260606.md`](PR_STATUS_20260606.md) · [`INDEX.md`](INDEX.md)
