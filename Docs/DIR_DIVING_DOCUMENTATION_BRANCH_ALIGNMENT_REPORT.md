# DIR DIVING — Documentation Branch Alignment Report (2026-06-09)

**Scope:** Documentation-only alignment (Phases 0–12). No runtime, algorithm, sync architecture, persistence, or experimental target changes.

**Baseline audited:** `main` @ **`0569903`** (`fix(main): complete deep code analysis remediation for MAIN-DCA-001–018`)

**Backup branch:** `backup/docs-alignment-20260609` (created before this pass)

**Git status before:** clean working tree on `main`, synced with `origin/main` @ `0569903`

---

## A. Files updated

| File | Change |
|------|--------|
| `README.md` (repo root) | Baseline → `0569903`; audit sequence links |
| `Docs/README.md` | Stato corrente table, branch strategy HEAD, docs pass 2026-06-09 |
| `Docs/INDEX.md` | Top sections: UI/UX audit/remediation, deep-code audit/remediation, docs alignment @ `0569903` |
| `Docs/CHANGELOG.md` | Unreleased: remediation passes + docs alignment 2026-06-09 |
| `Docs/ROADMAP.md` | HEAD `0569903` |
| `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` | Branch inventory date + `main` HEAD |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Additive rows (MAIN-DCA, UI/UX remediation, CCR docs) |
| `Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` | This report (updated in place) |

## B. Docs created

| File | Purpose |
|------|---------|
| `Docs/CCR_REBREATHER_PLANNER.md` | CCR planner scope, engine, UI surfaces |
| `Docs/CCR_REBREATHER_SAFETY_DISCLAIMER.md` | CCR-specific safety disclaimer |
| `Docs/CCR_REBREATHER_CHECKLIST_SYNC.md` | Checklist ↔ planner/CCR sync behavior |
| `Docs/PR_STATUS_20260609.md` | Open PR inspection snapshot |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | Short changelog of doc edits |

## C. Docs marked superseded

| Document | Superseded by | Notes |
|----------|---------------|-------|
| Prior narrative in this report @ `a69bc4b` | This report @ `0569903` | File updated in place; historical commits retained in INDEX |
| `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_20260607.md` narrative | This report | File retained; baseline was `a69bc4b` |

## D. README changes

- Root `README.md`: explicit baseline `0569903`, alignment report link.
- `Docs/README.md`: Branch Strategy HEAD, stato corrente table (UI/UX + deep-code + docs pass), physical QA pointer.

## E. Feature matrix changes

- **Rows:** additive only — MAIN-DCA-001…018 fixes, UI/UX remediation @ `dba1a22`, CCR reference docs, build/test evidence @ `0569903`, documentation alignment 2026-06-09.
- **Legacy rows:** unchanged; no deletions.

## F. Branches inspected

| Branch | vs `origin/main` | Role |
|--------|------------------|------|
| `main` | 0 \| 0 | Canonical release candidate @ `0569903` |
| `main-iOS` | divergent | Historical worktree — not release source |
| `codex/experimental-features` | divergent | Watch Snorkeling / Apnea / Buddy — isolated |
| `codex/ios-experimental-features` | divergent | iOS experimental surfaces — isolated |
| `codex/watch-main-algorithm-audit-current` | divergent | Docs-only audit; PR #10 |
| `codex/main-full-code-security-audit-current` | synced @ `0569903` | Security audit worktree aligned to `main` |
| `backup/*` | local | Safety snapshots; not auto-merged |

## G. Branches updated

This pass modifies **`main` only** (documentation commits). No experimental runtime merged into MAIN.

## H. Conflicts found

None during this documentation-only pass on `main`.

## I. Conflicts resolved

N/A (no merge performed).

## J. PRs inspected

See [`Docs/PR_STATUS_20260609.md`](PR_STATUS_20260609.md).

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

- `Docs/ReferenceUI/*.png` assets may not all be committed — verify before App Store submission.
- CCR external validation evidence rows remain **PENDING** in [`CCR_REBREATHER_VALIDATION_EVIDENCE.md`](CCR_REBREATHER_VALIDATION_EVIDENCE.md).
- Worktree branches may carry stale docs relative to `main` @ `0569903`.
- Physical QA matrices require executed evidence packs — [`QA_EVIDENCE_PACK_TEMPLATE.md`](QA_EVIDENCE_PACK_TEMPLATE.md).

## N. Remaining release blockers

- All items in [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — **PENDING**
- External Bühlmann ZHL-16C validation
- Apple Developer portal: water submersion entitlement on `com.egopfe.dirdiving.ios.watch`
- Paired iPhone + Watch physical sync QA (userInfo ACK, replay cache, photo protection)

## O. Remaining TestFlight blockers

- Physical device QA matrices not executed with evidence pack
- Ultra depth entitlement not confirmed on real hardware
- Cannot claim external TestFlight readiness until [`TESTFLIGHT_RELEASE_GATE_CHECKLIST.md`](TESTFLIGHT_RELEASE_GATE_CHECKLIST.md) has signed evidence

## P. Remaining App Store blockers

- Same as TestFlight blockers plus legal/copy final review
- App Store assets not fully verified in repo
- Reference-only planner/Bühlmann/CCR disclaimers must remain in [`APP_STORE_REVIEW_NOTES.md`](APP_STORE_REVIEW_NOTES.md)

## Q. Suggested next commits

1. `docs: align DIR DIVING architecture and release documentation @ 0569903`
2. (Optional) Execute physical QA matrices and attach evidence under `Docs/QA_EVIDENCE/`

## R. Risks / assumptions

- Documentation reflects code @ `0569903` from static inspection and build/test evidence in remediation reports.
- MAIN-DCA fixes documented as implemented; physical pairing behavior requires device QA.
- CCR planner documented as reference-only; external validation not complete.

## S. Experimental isolation confirmation

- `project.yml` MAIN targets exclude experimental Snorkeling, Apnea, Buddy Assist, exploration surfaces.
- Feature matrix rows mark experimental branches separately.
- PRs #8/#9 explicitly flagged — no auto-merge to `main`.

## T. MAIN stability confirmation

- Diving mode, GPS surface-only, BUSSOLA terminology, inline ascent warnings preserved in all updated docs.
- No runtime files modified in this pass.
- Sim evidence @ `0569903`: Watch **192** + iOS **561** algorithm tests PASS.

## U. Watch documentation alignment confirmation

- TTV informational index; inline ascent warnings; GPS overlays; depth discouragement 35/38/40 m
- Mission Mode; App Intents; BUSSOLA terminology
- Sync security: userInfo ACK, replay persistence, threat model @ [`WATCH_SYNC_SECURITY_THREAT_MODEL.md`](WATCH_SYNC_SECURITY_THREAT_MODEL.md)
- Blink timer 1.0s documented (MAIN-DCA-012)

## V. iOS Bühlmann planner documentation alignment confirmation

- Three-mode planner: Base / Deco / Technical; Bühlmann ZHL-16C reference-only
- Ratio Deco comparative heuristic only (not decompression algorithm)
- Mode-projected MOD gating and analysis cache documented (MAIN-DCA-004/005)

## W. CNS/OTU documentation alignment confirmation

- CNS/OTU reference estimates only; 15% descent+bottom warning documented
- Not medical or decompression authority

## X. Chart truthfulness documentation confirmation

- Planner and CCR charts labeled reference-only
- External validation plans remain open

## Y. CCR documentation alignment confirmation

| Document | Status |
|----------|--------|
| [`CCR_REBREATHER_PLANNER.md`](CCR_REBREATHER_PLANNER.md) | Created |
| [`CCR_REBREATHER_SAFETY_DISCLAIMER.md`](CCR_REBREATHER_SAFETY_DISCLAIMER.md) | Created |
| [`CCR_REBREATHER_CHECKLIST_SYNC.md`](CCR_REBREATHER_CHECKLIST_SYNC.md) | Created |
| [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md) | Existing — cross-linked |
| [`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md) | Existing — cross-linked |
| [`CCR_REBREATHER_VALIDATION_PLAN.md`](CCR_REBREATHER_VALIDATION_PLAN.md) | Existing — evidence **PENDING** |

## Z. Git status before/after

| When | Branch | HEAD | Working tree |
|------|--------|------|--------------|
| Before | `main` | `0569903` | clean vs `origin/main` |
| After (pending commit) | `main` | `0569903` | documentation edits only |

**Push status:** Not pushed unless explicitly requested after commit.

---

**Mandatory UI references preserved** (see [`Docs/ReferenceUI/README.md`](ReferenceUI/README.md)):

- `Watch_LIVE_reference.png`
- `iOS_Companion_reference.png`
- Ascent warning inline mockup references
- Experimental screenshot paths (when present)

**Terminology:** BUSSOLA only — COMPASSO must not appear as UI term.
