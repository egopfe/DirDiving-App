# DIR DIVING — Documentation Branch Alignment Report (2026-06-07)

**Scope:** Documentation-only alignment (Phases 0–12). No runtime, algorithm, sync architecture, persistence, or experimental target changes.

**Baseline audited:** `main` @ **`a69bc4b`** (`Fix MAIN deep-code audit sync, security, planner, and crash issues`)

**Backup branch:** `backup/docs-alignment-20260607` (created before this pass)

**Git status before:** clean working tree on `main`, synced with `origin/main` @ `a69bc4b`

---

## A. Files updated

| File | Change |
|------|--------|
| `README.md` (repo root) | Baseline → `a69bc4b`; link to alignment report |
| `Docs/README.md` | Stato corrente table, branch strategy HEAD, docs pass 2026-06-07, CSV column list |
| `Docs/INDEX.md` | Top sections: docs alignment + deep-code remediation @ `a69bc4b`; audit blocker narrative updated |
| `Docs/CHANGELOG.md` | Unreleased: deep-code remediation + docs alignment 2026-06-07 |
| `Docs/ROADMAP.md` | HEAD `a69bc4b`; released rows; P0 physical QA checklist |
| `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` | Branch inventory date + `main` HEAD |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Header extended; ~30 additive rows (no deletions) |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md` | Marked superseded for HEAD (file retained) |

## B. Docs created

| File | Purpose |
|------|---------|
| `Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` | This report (Phase 11, sections A–Z) |
| `Docs/PR_STATUS_20260607.md` | Open PR inspection snapshot |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260607.md` | Short changelog of doc edits |

## C. Docs marked superseded

| Document | Superseded by | Notes |
|----------|---------------|-------|
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260606.md` | This report @ `a69bc4b` | Retained; historical baseline was `90dc3f5` |
| `Docs/INDEX.md` pre-fix audit verdict (MAIN-AUD-001 blocker) | `MAIN_DEEP_CODE_ANALYSIS_REMEDIATION_REPORT_CURRENT.md` | Audit source doc @ `4a80c54` kept as historical |

## D. README changes

- Root `README.md`: explicit baseline `a69bc4b`, alignment report link.
- `Docs/README.md`: Branch Strategy HEAD, stato corrente table (deep-code + docs pass), physical QA pointer, CSV columns include Algorithm/Documentation Complete.

## E. Feature matrix changes

- **Header:** added `Algorithm Complete`, `Documentation Complete` columns.
- **Rows:** additive only (~30 new rows): deep-code fixes MAIN-AUD-001…016, safety semantics (TTV, Bühlmann reference-only, CNS 15%, depth discouragement, inline ascent), experimental isolation, release gates, docs passes.
- **Legacy rows:** pre-2026-06-07 rows may omit last two columns; parsers should treat as optional trailing fields.

## F. Branches inspected

| Branch | vs `origin/main` | Role |
|--------|------------------|------|
| `main` | 0 \| 0 | Canonical release candidate @ `a69bc4b` |
| `main-iOS` | 3 \| 119 | Historical divergent worktree — not release source |
| `codex/experimental-features` | 3 \| 92 | Watch Snorkeling / Apnea / Buddy — isolated |
| `codex/ios-experimental-features` | 3 \| 144 | iOS experimental surfaces — isolated |
| `codex/watch-main-algorithm-audit-current` | 3 \| 65 | Docs-only audit; PR #10 |
| `codex/main-full-code-security-audit-current` | 0 \| 0 | Synced to `main` @ `a69bc4b` |
| `backup/*` | local | Safety snapshots; not auto-merged |

**Worktrees:** `.worktrees/main-iOS`, `codex-ios-experimental`, `codex-experimental`, `watch-audit`, `security-audit`

## G. Branches updated

This pass modifies **`main` only** (documentation commits). No experimental runtime merged into MAIN.

## H. Conflicts found

None during this documentation-only pass on `main`.

## I. Conflicts resolved

N/A (no merge performed).

## J. PRs inspected

See [`Docs/PR_STATUS_20260607.md`](PR_STATUS_20260607.md).

| PR | Branch | Summary |
|----|--------|---------|
| #10 | `codex/watch-main-algorithm-audit-current` | Watch MAIN algorithm audit docs |
| #9 | `codex/ios-experimental-features` | Experimental Apnea companion review |
| #8 | `codex/experimental-features` | Experimental Apnea workflow |

## K. PRs safe to merge

| PR | Recommendation |
|----|----------------|
| #10 | **Docs-only review OK** — merge after human review; no runtime on MAIN from this PR alone |

## L. PRs requiring manual review

| PR | Recommendation |
|----|----------------|
| #8 | **Do not auto-merge** — experimental Watch runtime (Apnea) |
| #9 | **Do not auto-merge** — experimental iOS runtime (Apnea) |

## M. Remaining documentation gaps

- `Docs/ReferenceUI/*.png` files referenced in `ReferenceUI/README.md` may not all be committed to the repo — verify assets before App Store submission.
- Legacy CSV rows lack `Algorithm Complete` / `Documentation Complete` values — backfill optional in future pass.
- Worktree branches (`main-iOS`, `codex/*`) carry stale docs relative to `main` @ `a69bc4b`; update only via targeted doc ports after review.
- Integration tests for `WatchSyncService` signed ACK hooks noted as incomplete in remediation report.

## N. Remaining release blockers

- All items in [`Docs/MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — **PENDING**
- External Bühlmann ZHL-16C validation ([`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md))
- Apple Developer portal confirmation: water submersion entitlement on `com.egopfe.dirdiving.ios.watch`
- Paired iPhone + Watch physical sync QA (signed ACK, photo HMAC, tombstones)

## O. Remaining TestFlight blockers

- Physical device QA matrices not executed with evidence pack
- Ultra depth entitlement provisioning not confirmed on real hardware
- Cannot claim external TestFlight readiness until [`TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`](TESTFLIGHT_RELEASE_GATE_CHECKLIST.md) items have signed evidence

## P. Remaining App Store blockers

- Same as TestFlight blockers plus legal/copy final review
- App Store assets (icons, screenshots) from `Docs/ReferenceUI/` not fully verified in repo
- Reference-only planner/Bühlmann/CNS disclaimers must remain in review notes ([`APP_STORE_REVIEW_NOTES.md`](APP_STORE_REVIEW_NOTES.md))

## Q. Suggested next commits

1. `docs: align DIR DIVING architecture and release documentation @ a69bc4b`
2. (Optional separate) `docs: update feature comparison matrix columns and deep-code rows`

## R. Risks / assumptions

- Documentation reflects code @ `a69bc4b` from static inspection and prior build/test evidence; no new `xcodebuild` run in this pass.
- Authenticated sync (HMAC, signed ACK, photo auth) documented as implemented @ `a69bc4b`; physical pairing behavior unverified in this pass.
- User Images inventory/delete sync documented @ `fc311be`/`a69bc4b`; device QA still open.
- Tissue-history Bühlmann curve, NDL reference curve, depth profile chart: documented as implemented in planner readiness docs; chart truthfulness requires external validation.

## S. Experimental isolation confirmation

- `project.yml` MAIN targets exclude experimental Snorkeling, Apnea, Buddy Assist, exploration surfaces.
- Feature matrix rows mark experimental branches separately with `Experimental` status.
- PRs #8/#9 explicitly flagged — no auto-merge to `main`.

## T. MAIN stability confirmation

- Diving mode, GPS surface-only, BUSSOLA terminology, inline ascent warnings, depth discouragement philosophy preserved in all updated docs.
- No runtime files modified in this pass.
- Prior sim evidence: Watch **171** + iOS **415** algorithm tests PASS @ `a69bc4b`.

## U. Watch documentation alignment confirmation

Aligned in INDEX, README, CSV, safety docs cross-links:

- TTV informational index (not NDL/TTS/deco)
- Inline ascent warnings; no full-screen underwater warnings
- GPS compact overlays; entry/exit finalization; draft/pending restore
- Depth safety 35/38/40 m discouragement
- Mission Mode semantics; App Intents; Action Button via Shortcuts; Side Button system-controlled
- BUSSOLA (never COMPASSO)
- Authenticated sync / signed ACK / photo HMAC @ `a69bc4b`
- Apple Watch Ultra entitlement notes

## V. iOS Bühlmann planner documentation alignment confirmation

- Three-mode planner: Base / Deco / Technical
- Bühlmann ZHL-16C multigas reference-only; N2+He; GF; trimix/nitrox/air
- Gas ledger; repetitive planning reference; environment-aware pressure
- PIANO / CURVA BÜHLMANN / GRAFICI tabs
- Reference-only / non-certified positioning preserved
- External validation still required

## W. CNS/OTU documentation alignment confirmation

- CNS/OTU as reference estimates only
- CNS full plan; descent+bottom; 15% warning rule documented in CSV and planner docs
- Not medical or decompression authority

## X. Chart truthfulness documentation confirmation

- Planner charts labeled reference-only in safety and Bühlmann audit docs
- External validation plan remains open
- NDL reference curve / tissue-history curve: see iOS algorithm readiness reports — truthfulness not certified

## Y. Git status before/after

| When | Branch | HEAD | Working tree |
|------|--------|------|--------------|
| Before | `main` | `a69bc4b` | clean vs `origin/main` |
| After (pending commit) | `main` | `a69bc4b` | documentation edits only |

## Z. Push status if performed

- **Not pushed** in this pass unless explicitly requested after commit.
- Recommended: single docs commit on `main`, then `git push origin main`.

---

**Mandatory UI references preserved** (see [`Docs/ReferenceUI/README.md`](ReferenceUI/README.md)):

- `Watch_LIVE_reference.png`
- `iOS_Companion_reference.png`
- Ascent warning inline mockup references
- Snorkeling / Apnea experimental screenshot paths (when present)
- Bühlmann planner / CNS/OTU UI references (when present)

**Terminology:** BUSSOLA only — COMPASSO must not appear as UI term.
