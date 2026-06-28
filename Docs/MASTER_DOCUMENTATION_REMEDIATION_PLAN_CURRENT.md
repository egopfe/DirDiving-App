# Master Documentation Remediation Plan — Current

**Audit:** Command 06 — Master Documentation / Repository Alignment Audit **V1.1**  
**Date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `7dfefe2` (`7dfefe2cd7817780a903a64e51b890d901111ffd`)  
**Type:** Remediation plan only — no documentation edits in this pass

---

## P0 — Unsafe / unsupported claims / wrong architecture / command integrity

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P0-001 | `commands_for_cursor/01`–`04` | Entire body vs filename | **Permutation repair:** restore bodies so 01=Watch FC V2.1, 02=iOS V1.1, 03=UI/UX V2.2, 04=Main Code V1.1. Current state: **01=file04, 02=file03, 03=file01, 04=file02** (CONFLICTING). Use OOLD archives + V1.2 source as restore references. | Wrong audit would execute if launch sequence followed filenames | P0 | 00 Orchestrator; all 01–06 |
| DOC-P0-002 | `Docs/WATCH_LOW_POWER_MISSION_MODE_IMPLEMENTATION_REPORT.md` | Executive table App Store ready row | Change "**Conditional yes**" to "**No** for external App Store — internal TestFlight UX only; physical QA and copy review **PENDING**." | Unsupported App Store readiness | P0 | 05 Release QA |
| DOC-P0-003 | `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | § Not claimed | Remove bullet "**CCR external validation complete**" or rewrite as "**CCR external validation PENDING** (see CCR_REBREATHER_VALIDATION_EVIDENCE.md)." | Contradicts PENDING external validation posture | P0 | 05 Release QA; 06 Documentation |
| DOC-P0-004 | `commands_for_cursor/00-MASTER_SUPER_ORCHESTRATOR...V1.2.md` | Preflight / execution gate | Add explicit **STOP** if 01–04 body SHA/title mismatch detected (permutation guard). | Prevents silent wrong-audit execution until repair | P0 | 00 Orchestrator |

---

## P1 — README / matrix / command sequence / release wording / 2026-06-28 wave

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P1-001 | `README.md` | Release baseline | Update `origin/main` @ **`7dfefe2`**; link `commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md` | Stale SHA bf03fb0 | P1 | 06 Documentation |
| DOC-P1-002 | `Docs/README.md` | Baseline + stato corrente | Refresh baseline to `7dfefe2`; add master audits 01–06 @ 7dfefe2 row | Primary project doc stale | P1 | 06 Documentation |
| DOC-P1-003 | `Docs/INDEX.md` | New top section | Insert "**Aggiornamento indice 2026-06-28** — Master audit V1.2 + 2026-06-28 Watch wave" with links to water auto-open, shallow depth, GF preset matrices and `MASTER_*_CURRENT` @ 7dfefe2 | Master outputs and new wave invisible | P1 | 06 Documentation |
| DOC-P1-004 | `Docs/INDEX.md` | 2026-06-22 master table | Update command filenames to V2.1/V1.1/V2.2/V1.1/V1.1/V1.1; add **P0 permutation blocker** note until repaired | Wrong command versions indexed | P1 | 06 Documentation |
| DOC-P1-005 | `Docs/DIR_DIVING_Feature_Comparison.csv` | Rows 12–26 vs 430–433 | Prefix experimental rows `branch=codex/* (legacy)`; add GF preset, shallow testing, water auto-open rows from feature inventory | Matrix drift + 2026-06-28 gap | P1 | 06 Documentation |
| DOC-P1-006 | `Docs/ROADMAP.md` | Header | Update date/SHA to `7dfefe2` | Stale header | P1 | 06 Documentation |
| DOC-P1-007 | `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | Top | Add superseded banner — pre-V3.0; Apnea/Snorkeling now on MAIN | False exclusion claim | P1 | 06 Documentation |
| DOC-P1-008 | `Docs/INDEX.md` | Command 6 V3.0 | Superseded banner → `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` | Wrong active command | P1 | 06 Documentation |
| DOC-P1-009 | `Docs/MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv` | Git + INDEX | Commit when approved; link from INDEX Watch entitlement subsection | Untracked audit output | P1 | 01 Watch FC |
| DOC-P1-010 | `Docs/MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv` | Git + INDEX | Commit when approved; link from INDEX FC subsection | Untracked audit output | P1 | 01 Watch FC |
| DOC-P1-011 | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Header baseline | Update SHA from `7b620f3` to `7dfefe2`; add shallow-depth + water auto-open reviewer bullets | Reviewer context stale | P1 | 05 Release QA |
| DOC-P1-012 | `Docs/PRODUCT_FEATURES_IT.md` | Branch table intro | Add sentence: table compares MAIN vs legacy codex branches; Apnea/Snorkeling ship on MAIN | Ambiguous branch table | P1 | 06 Documentation |

---

## P2 — Missing links / incomplete index / stale readiness / baseline drift

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P2-001 | `Docs/INDEX.md` | Settings / Logbook | Consolidated block: settings mode switch, activity settings, logbook ownership matrices | Ownership docs scattered | P2 | 03 UI/UX |
| DOC-P2-002 | `Docs/INDEX.md` | Physical/external QA | Link all `MASTER_*_PHYSICAL_*`, `MASTER_*_EXTERNAL_*`, `QA_EVIDENCE/` | QA pending not centralized | P2 | 05 Release QA |
| DOC-P2-003 | `Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md` | Header baseline | Re-run @ `7dfefe2` or update baseline note | Output @ 1f62235 | P2 | 05 Release QA |
| DOC-P2-004 | `Docs/APNEA_EXPERIMENTAL_SPEC.md` | Header | Legacy branch spec banner → `APNEA_ARCHITECTURE.md` | Misleading filename | P2 | 06 Documentation |
| DOC-P2-005 | `Docs/SNORKELING_EXPERIMENTAL_SPEC.md` | Header | Same legacy banner | Misleading filename | P2 | 06 Documentation |
| DOC-P2-006 | `README.md` | Quick links | Add master audit launch sequence + documentation alignment audit | Discoverability | P2 | 06 Documentation |
| DOC-P2-007 | `Docs/PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | INDEX | Add under Planner + briefing subsection | Orphan matrix | P2 | 02 iOS |
| DOC-P2-008 | `Docs/RATIO_DECO_COMPARATIVE_HEURISTIC.md` | INDEX + CSV | Cross-link; add CSV row | Heuristic under-indexed | P2 | 02 iOS |
| DOC-P2-009 | `Docs/RELEASE_CHECKLIST.md` | Master audits | Checkbox: commands 01–06 aligned (post permutation fix) and outputs indexed | Release gate | P2 | 05 Release QA |
| DOC-P2-010 | `Docs/DIR_DIVING_IOS_DECO_GF_PRESET_CARD_SELECTOR_REPORT_CURRENT.md` | Cross-links | Link FC GF preset matrix | iOS/Watch GF separation | P2 | 01+02 |

---

## P3 — Copy cleanup / formatting / historical archive notes

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P3-001 | `commands_for_cursor/OLD/` + `OOLD/` | Archive | Add `commands_for_cursor/ARCHIVE_README.md` listing OLD vs OOLD vs active 00–06 | Archive discoverability | P3 | 06 Documentation |
| DOC-P3-002 | `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_202605*.md` | Header | Superseded banner → latest alignment report | Historical confusion | P3 | 06 Documentation |
| DOC-P3-003 | `Docs/1-DIR_DIVING_*` / `2-DIR_DIVING_*` / `IOS_MAIN_COMPLETE_*` | Header | Archive banners — superseded by MASTER audits | Legacy audit docs | P3 | 06 Documentation |
| DOC-P3-004 | `Docs/INDEX.md` | Length | Collapsible archive section for pre-2026-06 entries | INDEX >2300 lines | P3 | 06 Documentation |
| DOC-P3-005 | `Docs/PR_STATUS_20260607.md` | Header | Superseded by 20260620+ | Duplicate PR snapshots | P3 | 06 Documentation |
| DOC-P3-006 | `Docs/ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md` | Verdict | Superseded notice → MASTER consolidated plan | Two orchestration narratives | P3 | 00 Orchestrator |

---

## P4 — Verified fixed since prior audit (track only)

| ID | File | Status | Notes |
|----|------|--------|-------|
| DOC-P4-001 | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | FIXED | Apnea/Snorkeling on MAIN correctly stated |
| DOC-P4-002 | `Docs/EXPERIMENTAL_FEATURES.md` | FIXED | Buddy/exploration legacy scope only |
| DOC-P4-003 | `Docs/WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md` | FIXED | App Store ready = No external |
| DOC-P4-004 | `commands_for_cursor/05` + `06` | ALIGNED | Bodies match filenames @ 7dfefe2 |
| DOC-P4-005 | `commands_for_cursor/00` V1.2 | ALIGNED | Orchestrator filename/body match |

---

## Summary counts

| Priority | Count |
|----------|-------|
| P0 | 4 |
| P1 | 12 |
| P2 | 10 |
| P3 | 6 |
| P4 | 5 (track-only / verified fixed) |
| **Total remediation items** | **37** |

**Recommended execution order:** DOC-P0-001 (command permutation) → DOC-P0-004 → P0 claims → P1 INDEX/README → P1 feature matrix → P2 links → P3 archive.

**Audit to rerun after remediation:** Command 06 (this audit); Command 00 orchestrator validation; Commands 01–05 only after permutation repair.
