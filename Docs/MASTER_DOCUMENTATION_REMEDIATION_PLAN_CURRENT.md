# Master Documentation Remediation Plan — Current

**Audit:** Command 06 — Master Documentation / Repository Alignment Audit **V1.2**  
**Date:** 2026-06-30  
**Branch:** `main`  
**Commit:** `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958`)  
**Type:** Remediation plan only — no documentation edits in this pass

---

## P0 — Unsafe / unsupported claims

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P0-001 | `Docs/WATCH_LOW_POWER_MISSION_MODE_IMPLEMENTATION_REPORT.md` | Executive table App Store ready row | Change "**Conditional yes**" to "**No** for external App Store — internal TestFlight UX only; physical QA and copy review **PENDING**." | Unsupported App Store readiness | P0 | 05 Release QA |
| DOC-P0-002 | `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | § Not claimed | Remove bullet "**CCR external validation complete**" or rewrite as "**CCR external validation PENDING** (see CCR_REBREATHER_VALIDATION_EVIDENCE.md)." | Contradicts PENDING external validation posture | P0 | 05 Release QA; 06 Documentation |

---

## P1 — README / matrix / index / release wording / command drift

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P1-001 | `README.md` | Release baseline | Update `origin/main` @ **`451f8fb`**; link `commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-30.md` | Stale SHA bf03fb0 | P1 | 06 Documentation |
| DOC-P1-002 | `Docs/README.md` | Baseline + stato corrente | Refresh baseline to `451f8fb`; add orchestrator V1.3 + audits 01–07 row | Primary project doc stale | P1 | 06 Documentation |
| DOC-P1-003 | `Docs/INDEX.md` | Header | Update **Aggiornato** date + `main` @ **`451f8fb`** | Header cites 8f224da | P1 | 06 Documentation |
| DOC-P1-004 | `Docs/INDEX.md` | Master command table | Update Command 03 → V2.3; Command 06 → V1.2; link this audit outputs | Version column stale | P1 | 06 Documentation |
| DOC-P1-005 | `Docs/INDEX.md` | Command 10 block | Restore `10-MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_CODE_READINESS_COMMAND_V1.0.md` to disk or add superseded/archive path | Broken command reference (CONS-047) | P1 | 00 Orchestrator |
| DOC-P1-006 | `Scripts/validate_commands_for_cursor_integrity.sh` | expect_launch_order paths | Update to V2.2 / V1.2 / V2.3 / V1.2 / V1.2 / V1.2 filenames | Script FAIL (CONS-046) | P1 | 06 Documentation |
| DOC-P1-007 | `Docs/DIR_DIVING_Feature_Comparison.csv` | Rows 12–26 vs 430–433 | Prefix experimental rows `branch=codex/* (legacy)`; add GF preset, shallow testing, water auto-open rows | Matrix drift + 2026 wave gap | P1 | 06 Documentation |
| DOC-P1-008 | `Docs/ROADMAP.md` | Header | Update date/SHA to `451f8fb` | Stale header | P1 | 06 Documentation |
| DOC-P1-009 | `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | Top | Add superseded banner — pre-V3.0; Apnea/Snorkeling now on MAIN | False exclusion claim | P1 | 06 Documentation |
| DOC-P1-010 | `Docs/INDEX.md` | Command 6 V3.0 | Superseded banner → `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.2.md` | Wrong active command | P1 | 06 Documentation |
| DOC-P1-011 | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Header baseline | Update SHA to `451f8fb`; add shallow-depth + water auto-open reviewer bullets | Reviewer context stale | P1 | 05 Release QA |
| DOC-P1-012 | `Docs/PRODUCT_FEATURES_IT.md` | Branch table intro | Add sentence: table compares MAIN vs legacy codex branches; Apnea/Snorkeling ship on MAIN | Ambiguous branch table | P1 | 06 Documentation |
| DOC-P1-013 | `Docs/INDEX.md` | 2026-06-28 Watch wave | Add GF preset + shallow depth + water auto-open matrix links to orchestrator block | Matrices under-indexed | P1 | 06 Documentation |
| DOC-P1-014 | `Docs/INDEX.md` | Command 06 V1.2 block | Insert post-remediation Command 06 @ `451f8fb` linking all audit outputs | Master doc alignment outputs indexed | P1 | 06 Documentation |

---

## P2 — Missing links / incomplete index / baseline drift

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P2-001 | `Docs/INDEX.md` | Settings / Logbook | Consolidated block: settings mode switch, activity settings, logbook ownership matrices | Ownership docs scattered | P2 | 03 UI/UX |
| DOC-P2-002 | `Docs/INDEX.md` | Physical/external QA | Link all `MASTER_*_PHYSICAL_*`, `MASTER_*_EXTERNAL_*`, `QA_EVIDENCE/` | QA pending not centralized | P2 | 05 Release QA |
| DOC-P2-003 | `Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md` | Header baseline | Re-run @ `451f8fb` or update baseline note | Output predates baseline | P2 | 05 Release QA |
| DOC-P2-004 | `Docs/APNEA_EXPERIMENTAL_SPEC.md` | Header | Legacy branch spec banner → `APNEA_ARCHITECTURE.md` | Misleading filename | P2 | 06 Documentation |
| DOC-P2-005 | `Docs/SNORKELING_EXPERIMENTAL_SPEC.md` | Header | Same legacy banner → `SNORKELING_ARCHITECTURE.md` | Misleading filename | P2 | 06 Documentation |
| DOC-P2-006 | `README.md` | Quick links | Add master audit launch sequence + documentation alignment audit | Discoverability | P2 | 06 Documentation |
| DOC-P2-007 | `Docs/PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | INDEX | Add under Planner + briefing subsection | Orphan matrix | P2 | 02 iOS |
| DOC-P2-008 | `Docs/RATIO_DECO_COMPARATIVE_HEURISTIC.md` | INDEX + CSV | Cross-link; add CSV row | Heuristic under-indexed | P2 | 02 iOS |
| DOC-P2-009 | `Docs/RELEASE_CHECKLIST.md` | Master audits | Checkbox: commands 01–07 aligned; integrity script PASS | Release gate | P2 | 05 Release QA |
| DOC-P2-010 | `Docs/DIR_DIVING_IOS_DECO_GF_PRESET_CARD_SELECTOR_REPORT_CURRENT.md` | Cross-links | Link FC GF preset matrix | iOS/Watch GF separation | P2 | 01+02 |
| DOC-P2-011 | `Docs/DIR_DIVING_Feature_Comparison.csv` | Mode switcher | Add iOS Settings mode switcher row | Implemented not in CSV | P2 | 03 UI/UX |
| DOC-P2-012 | `Docs/INDEX.md` | Snorkeling docs | Consolidated Snorkeling architecture/roadmap/QA link block | 18 SNORKELING_* docs under-linked | P2 | 06 Documentation |
| DOC-P2-013 | `Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md` | Upstream stale note | Refresh STALE_UPSTREAM_AUDIT_OUTPUT after reruns @ 451f8fb | CONS-047 | P2 | 00 Orchestrator |
| DOC-P2-014 | `Docs/INDEX.md` | Audit 07 outputs | Link `MASTER_POST_REMEDIATION_*` when audit 07 rerun completes | Verification outputs discoverability | P2 | 07 Verification |

---

## P3 — Copy cleanup / formatting / historical archive notes

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P3-001 | `commands_for_cursor/OLD/` + `OOLD/` | Archive | Add `commands_for_cursor/ARCHIVE_README.md` listing OLD vs OOLD vs active 00–07 | Archive discoverability | P3 | 06 Documentation |
| DOC-P3-002 | `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_202605*.md` | Header | Superseded banner → latest alignment report | Historical confusion | P3 | 06 Documentation |
| DOC-P3-003 | `Docs/1-DIR_DIVING_*` / `2-DIR_DIVING_*` / `IOS_MAIN_COMPLETE_*` | Header | Archive banners — superseded by MASTER audits | Legacy audit docs | P3 | 06 Documentation |
| DOC-P3-004 | `Docs/INDEX.md` | Length | Collapsible archive section for pre-2026-06 entries | INDEX >2300 lines | P3 | 06 Documentation |
| DOC-P3-005 | `Docs/PR_STATUS_20260607.md` | Header | Superseded by 20260620+ | Duplicate PR snapshots | P3 | 06 Documentation |
| DOC-P3-006 | `Docs/ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md` | Verdict | Superseded notice → MASTER consolidated plan | Two orchestration narratives | P3 | 00 Orchestrator |
| DOC-P3-007 | `commands_for_cursor/OOLD/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md` | Header | Superseded → 2026-06-30 launch doc | Duplicate launch sequences | P3 | 06 Documentation |
| DOC-P3-008 | `Docs/RELEASE_CHECKLIST.md` | Internal TestFlight row | Append "physical QA PENDING" to conditional yes wording | Release wording drift | P3 | 05 Release QA |

---

## P4 — Verified fixed since prior audit (track only)

| ID | File | Status | Notes |
|----|------|--------|-------|
| DOC-P4-001 | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | FIXED | Apnea/Snorkeling on MAIN correctly stated |
| DOC-P4-002 | `Docs/EXPERIMENTAL_FEATURES.md` | FIXED | Buddy/exploration legacy scope only |
| DOC-P4-003 | `Docs/WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md` | FIXED | App Store ready = No external |
| DOC-P4-004 | `commands_for_cursor/01`–`07` launch order + body versions | FIXED | V2.2/V2.3/V1.2/V1.0 parity @ 451f8fb |
| DOC-P4-005 | `commands_for_cursor/00` V1.3 | ALIGNED | Orchestrator filename/body match |
| DOC-P4-006 | Snorkeling documentation suite | ALIGNED | 18 docs; INTERNAL_READY · PHYSICAL_QA_PENDING posture |

---

## Summary

| Priority | Count |
|----------|-------|
| P0 | 2 |
| P1 | 14 |
| P2 | 14 |
| P3 | 8 |
| **Total actionable** | **38** |
