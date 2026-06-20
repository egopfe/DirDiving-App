# DIR DIVING — Documentation Branch Alignment Report (2026-06-20, V3.0)

## A. Scope and commit

**Scope:** Documentation alignment Command 6 V3.0 (Phases 0–12) plus committed MAIN deep-code readiness remediation on `main`.

**Baseline audited:** `main` @ **`bf03fb0`** (MAIN deep-code readiness 100%)

**Backup branch:** `backup/docs-alignment-20260620` (recommended before push)

**Git status before alignment pass:** dirty — MAIN deep-code readiness (production + tests + docs) uncommitted @ `f4f0a68`

**V3.0 product scope:** Diving (Gauge + Full Computer), Apnea, Snorkeling on Watch and iOS Companion; Buddy/exploration experimental-only.

---

## B. Files updated

| File | Change |
|------|--------|
| `README.md` (root) | Baseline `f4f0a68`; Full Computer on `main`; alignment report link |
| `Docs/README.md` | Multi-activity opening; stato corrente table 2026-06-20 |
| `Docs/INDEX.md` | Command 5 + Command 6 sections; test counts; gate strings |
| `Docs/CHANGELOG.md` | Unreleased 2026-06-20 entries |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | V3.0 navigation/exclusion corrections; additive rows |
| `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md` | 100% software readiness scores |
| `Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` | This report |

## C. Docs created (remediation pass, referenced here)

| File | Purpose |
|------|---------|
| `Docs/MAIN_DEEP_CODE_FINDING_TRACEABILITY_CURRENT.csv` | Finding verification matrix |
| `Docs/MAIN_DEEP_CODE_REQUIREMENT_TEST_MATRIX_CURRENT.csv` | Requirement → test mapping |
| `Docs/MAIN_SECURITY_NEGATIVE_TEST_MATRIX_CURRENT.csv` | Adversarial test matrix |
| `Docs/MAIN_PERFORMANCE_BUDGET_CURRENT.csv` | Software performance budgets |
| `Docs/MAIN_PRIVACY_FILE_PROTECTION_MATRIX_CURRENT.csv` | File protection matrix |
| `Docs/MAIN_SYNC_DATA_INTEGRITY_MATRIX_CURRENT.csv` | Sync/merge integrity matrix |
| `Docs/MAIN_EXTERNAL_QA_PENDING_CURRENT.md` | External gates PENDING |
| `Docs/MAIN_RELEASE_GATE_MATRIX_CURRENT.csv` | Software vs external release gates |
| `Docs/PR_STATUS_20260620.md` | PR inspection snapshot |
| `Scripts/validate_main_deep_code_readiness.sh` | Consolidated software gate |

## D. Docs marked superseded

| Document | Superseded by | Notes |
|----------|---------------|-------|
| Prior narrative @ `99ea74a` in this report | This report @ HEAD | File updated in place |
| `Docs/PR_STATUS_20260614.md` | `Docs/PR_STATUS_20260620.md` | Prior snapshot retained |
| Stale “Apnea/Snorkeling experimental-only on main” in README opening | V3.0 multi-activity text | Historical experimental branch docs unchanged |

## E. README changes

- Root: baseline chain through `f4f0a68`; Full Computer documented on `main`.
- `Docs/README.md`: multi-activity production scope; Apnea/Snorkeling architecture links; validation scripts.

## F. Feature matrix changes

- **Corrected:** navigation gating row; experimental exclusion row (Apnea/Snorkeling/FC now in MAIN).
- **Added:** Full Computer, Apnea Watch, Snorkeling Watch, Apnea iOS, Snorkeling iOS, audit V3.0, deep-code readiness, docs alignment 2026-06-20, XCTest @ 1362/890.

## G. Branches inspected

| Branch | Role | Merge recommendation |
|--------|------|------------------------|
| `main` | Canonical @ `f4f0a68` | Release source |
| `main-iOS` | Divergent worktree | Do not auto-merge (PR #13) |
| `codex/experimental-features` | Legacy Watch experimental | Isolated |
| `codex/ios-experimental-features` | Legacy iOS experimental | Isolated |
| `codex/watch-main-algorithm-audit-current` | Docs PR #10 | Review-only merge |
| `fix/snorkeling-release-gate-remediation` | Feature branch | Review before merge |

## H. Conflicts found / resolved

None during documentation pass. Production remediation had no merge conflicts.

## I. PRs inspected

See [`Docs/PR_STATUS_20260620.md`](PR_STATUS_20260620.md).

## J. Remaining documentation gaps

- Physical QA evidence folders empty (by policy).
- Some legacy `Docs/README.md` sections still describe experimental Apnea/Snorkeling paths — marked historically; V3.0 opening supersedes for HEAD scope.
- External Bühlmann/CCR validation reports pending third-party evidence.

## K. Release / TestFlight / App Store blockers

- All external QA matrices **PENDING** — see `Docs/MAIN_EXTERNAL_QA_PENDING_CURRENT.md`.
- App Store marketing assets **PENDING**.
- Legal/privacy final review **PENDING**.
- **Software internal readiness: 100%** — does not imply external TestFlight GO.

## L. Experimental isolation confirmation

`project.yml` excludes `BuddyAssistView`, `ExperimentalConceptsView`, exploration stores from MAIN. Apnea/Snorkeling production views **included** in MAIN per V3.0.

## M–V. Domain alignment summaries

| Domain | Status |
|--------|--------|
| Watch MAIN | Documented; multi-activity; FC/Audit-15 validated in software |
| iOS Planner | Reference-only; three-mode + CCR docs current |
| Bühlmann/Ratio Deco | Primary vs heuristic documented |
| CCR | Reference-only disclaimers current |
| Equipment/checklist | Sync docs @ `99ea74a`+ retained |
| Runtime/deco/Emergency/Rock Bottom | Presentation docs current |
| Gas ledger / schedule gas | Documented |
| Repetitive dive | Documented; limitations stated |
| Briefing cards | Reference-only; Watch transfer documented |
| Accessibility/l10n | `audit_localization.sh` PASS |
| QA evidence | Templates only — **PENDING** |

## W–X. QA / ReferenceUI

`Docs/QA_EVIDENCE/*/README.md` — no fabricated PASS. Mockup inventory @ `Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv`.

## Y. Git status before/after

- **Before:** dirty @ `f4f0a68` (24 files — deep-code readiness).
- **After commits:** clean on `main`, pushed to `origin/main`.

## Z. Commits created

1. MAIN deep-code readiness remediation (production + tests + docs).
2. `docs: align DIR DIVING documentation to V3.0 multi-activity MAIN`.

## AA. Push status

Pushed to `origin/main` per user request; worktrees synced with `origin/main`.

## AB. Risks / assumptions

- TOFU peer secret accepted residual documented (MAIN-DCA-013).
- CCR MOD 0.5 m slack intentional (MAIN-DCA-024).
- Deferred reminder visibility indicator deferred by product (MAIN-DCA-032).
- Simulator test PASS ≠ physical device QA.

---

*End of report — Command 6 V3.0 — 2026-06-20*
