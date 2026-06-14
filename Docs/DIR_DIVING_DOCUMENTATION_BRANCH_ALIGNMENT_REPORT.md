# DIR DIVING — Documentation Branch Alignment Report (2026-06-14)

## A. Scope and commit

**Scope:** Documentation-only alignment (Phases 0–12). No runtime, algorithm, sync architecture, persistence, or experimental target changes.

**Baseline audited:** `main` @ **`99ea74a`** (`Complete MAIN deep code audit remediation to internal 100% readiness`)

**Backup branch:** `backup/docs-alignment-20260614` (created before this pass)

**Git status before:** clean working tree on `main`, synced with `origin/main` @ `99ea74a`

**Cumulative baseline chain:** UI/UX V1.0 (`7c79105`) → deep-code audit @ `7c79105` (`009855e`) → deep-code remediation V1.0 (`99ea74a`); prior MAIN-DCA-001…018 @ `0569903` retained in INDEX/history.

---

## B. Files updated

| File | Change |
|------|--------|
| `README.md` (repo root) | Baseline → `99ea74a`; V1.0 audit/remediation sequence |
| `Docs/README.md` | Stato corrente table, branch strategy HEAD @ `99ea74a` |
| `Docs/INDEX.md` | Top sections: UI/UX V1.0, deep-code audit/remediation V1.0, docs alignment @ `99ea74a` |
| `Docs/CHANGELOG.md` | Unreleased: V1.0 remediation + docs alignment 2026-06-14 |
| `Docs/ROADMAP.md` | HEAD `99ea74a`; V1.0 rows + XCTest evidence |
| `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` | Branch inventory date + `main` HEAD |
| `Docs/RELEASE_CHECKLIST.md` | Deep-code V1.0 section; test counts 832/239 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Additive rows (V1.0 remediation, UI/UX V1.0, docs pass) |
| `Docs/CCR_REBREATHER_PLANNER.md` | Last updated header @ `99ea74a` |
| `Docs/CCR_REBREATHER_CHECKLIST_SYNC.md` | Last updated header @ `99ea74a` |
| `Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` | This report (updated in place) |

## C. Docs created

| File | Purpose |
|------|---------|
| `Docs/PR_STATUS_20260614.md` | Open PR inspection snapshot @ `99ea74a` |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260614.md` | Short changelog of doc edits |

## D. Docs marked superseded

| Document | Superseded by | Notes |
|----------|---------------|-------|
| Prior narrative in this report @ `0569903` | This report @ `99ea74a` | File updated in place; historical commits retained in INDEX |
| `Docs/PR_STATUS_20260609.md` | `Docs/PR_STATUS_20260614.md` | Prior snapshot retained |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | `Docs/DOCUMENTATION_UPDATE_REPORT_20260614.md` | Prior snapshot retained |

## E. README changes

- Root `README.md`: explicit baseline `99ea74a`, V1.0 audit/remediation chain, alignment report link.
- `Docs/README.md`: Branch Strategy HEAD, stato corrente table (V1.0 passes + docs alignment), physical QA pointer unchanged.

## F. Feature matrix changes

- **Rows:** additive only — UI/UX V1.0 @ `7c79105`, deep-code audit @ `009855e`, deep-code remediation V1.0 MAIN-DCA-011…031 @ `99ea74a`, individual fix rows, build/test evidence, documentation alignment 2026-06-14.
- **Legacy rows:** unchanged; no deletions.

## G. Branches inspected

| Branch | vs `origin/main` | Role |
|--------|------------------|------|
| `main` | 0 \| 0 | Canonical release candidate @ `99ea74a` |
| `main-iOS` | divergent | Historical worktree — not release source |
| `codex/experimental-features` | divergent | Watch Snorkeling / Apnea / Buddy — isolated |
| `codex/ios-experimental-features` | divergent | iOS experimental surfaces — isolated |
| `codex/watch-main-algorithm-audit-current` | divergent | Docs-only audit; PR #10 |
| `backup/docs-alignment-20260614` | local | Safety snapshot before this pass |
| `backup/docs-alignment-20260609` | local | Prior docs pass snapshot |

## H. Conflicts found / resolved

None during this documentation-only pass on `main`. N/A merge conflicts.

## I. PRs inspected

See [`Docs/PR_STATUS_20260614.md`](PR_STATUS_20260614.md).

| PR | Branch | Summary |
|----|--------|---------|
| #10 | `codex/watch-main-algorithm-audit-current` | Watch MAIN algorithm audit docs |
| #9 | `codex/ios-experimental-features` | Experimental Apnea companion review |
| #8 | `codex/experimental-features` | Experimental Apnea workflow |

## J. Remaining documentation gaps

- `Docs/ReferenceUI/*.png` assets may not all be committed — verify before App Store submission.
- CCR external validation evidence rows remain **PENDING** in [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md).
- Worktree branches may carry stale docs relative to `main` @ `99ea74a`.
- Physical QA matrices require executed evidence packs — [`QA_EVIDENCE_PACK_TEMPLATE.md`](QA_EVIDENCE_PACK_TEMPLATE.md).

## K. Release / TestFlight / App Store blockers

**Release:** All items in [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — **PENDING**; external Bühlmann validation; water submersion entitlement; paired sync QA.

**TestFlight:** Physical device QA not executed with evidence pack; cannot claim external readiness until [`TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`](TESTFLIGHT_RELEASE_GATE_CHECKLIST.md) has signed evidence.

**App Store:** Same as TestFlight plus legal/copy review; reference-only disclaimers must remain in [`APP_STORE_REVIEW_NOTES.md`](APP_STORE_REVIEW_NOTES.md).

## L. Experimental isolation confirmation

- `project.yml` MAIN targets exclude experimental surfaces.
- PRs #8/#9 flagged — no auto-merge to `main`.

## M. Watch documentation alignment

- TTV informational; inline ascent warnings; GPS overlays; BUSSOLA terminology
- Photo ACK queue; alarm blink via `TimelineView` (MAIN-DCA-012); reminder overlay suppression (MAIN-DCA-022)
- Briefing sanitize + atomic swap; reference-only cards

## N. iOS Planner documentation alignment

- Bühlmann ZHL-16C reference-only; CCR MOD tolerance policy documented
- Briefing cards to Watch — sanitize + atomic swap

## O. Bühlmann / Ratio Deco / Tissue documentation alignment

- External validation plans open; tissue chart axis l10n (MAIN-DCA-030)

## P. CCR documentation alignment

| Document | Status |
|----------|--------|
| [`CCR_REBREATHER_PLANNER.md`](CCR_REBREATHER_PLANNER.md) | Updated header @ `99ea74a` |
| [`CCR_REBREATHER_CHECKLIST_SYNC.md`](CCR_REBREATHER_CHECKLIST_SYNC.md) | Updated header @ `99ea74a` |
| Other CCR docs | Existing — evidence **PENDING** |

## Q. Structured Equipment / checklist documentation alignment

- Prior passes unchanged; CCR checklist cross-linked

## R. Ascent-speed / Dive Runtime / deco-stop alignment

- Prior passes unchanged; reference-only positioning preserved

## S. Emergency / Rock Bottom documentation alignment

- Rock Bottom remains an estimate; no certification claims

## T. Gas-ledger / schedule-consumption alignment

- Prior passes unchanged

## U. Repetitive-dive documentation alignment

- Limitations documented; no new certification claims

## V. Planner briefing-card / Watch-transfer alignment

- MAIN-DCA-020/021 sanitize + atomic swap documented

## W. Accessibility / localization documentation alignment

- UI/UX V1.0 @ `7c79105`; Watch `.strings` cleanup (MAIN-DCA-031)
- Dynamic Type / VoiceOver QA **PENDING**

## X. QA evidence / ReferenceUI status

Scaffolded under `Docs/QA_EVIDENCE/` — all **PENDING** execution. No fabricated PASS claims.

## Y. Git status before/after

| When | Branch | HEAD | Working tree |
|------|--------|------|--------------|
| Before | `main` | `99ea74a` | clean vs `origin/main` |
| After (commit) | `main` | `dd3ed91` | documentation edits only |
| After (push) | `main` | `dd3ed91` | clean; synced with `origin/main` |

## Z. Commits created

1. `dd3ed91` — `docs: align DIR DIVING architecture and release documentation @ 99ea74a`

## AA. Push status

**Pushed** to `origin/main` @ `dd3ed91` (2026-06-14).

## AB. Risks / assumptions

- Documentation reflects code @ `99ea74a` from remediation report and build/test evidence.
- Internal code readiness 100% does **not** imply TestFlight or App Store readiness.
- Physical QA remains **PENDING**.

---

**Terminology:** BUSSOLA only — COMPASSO must not appear as UI term.
