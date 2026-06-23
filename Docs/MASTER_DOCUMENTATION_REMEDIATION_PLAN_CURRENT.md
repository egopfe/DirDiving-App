# Master Documentation Remediation Plan — Current

**Audit:** Command 06 — Master Documentation / Repository Alignment Audit V1.0  
**Date:** 2026-06-22  
**Branch:** `main`  
**Commit:** `1f62235` (`1f62235996c5a00418db36519479df289c212744`)  
**Type:** Remediation plan only — no documentation edits in this pass

---

## P0 — Unsafe / unsupported claims / wrong architecture causing unsafe use

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P0-001 | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | § Rami non inclusi | Replace "Apnea, Snorkeling … solo su branch codex/*" with "Apnea and Snorkeling ship on MAIN @ current baseline; Buddy Assist and exploration remain experimental-only; physical QA PENDING." | TestFlight reviewers may believe MAIN build lacks Apnea/Snorkeling | P0 | 05 Release QA; 06 Documentation |
| DOC-P0-002 | `Docs/WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md` | App Store ready row | Change "App Store ready (UX/safety/copy)? **Yes**" to "**No** for external App Store — internal UX copy acceptable; physical QA, entitlement, and legal review **PENDING**." | Unsupported App Store readiness claim | P0 | 05 Release QA |
| DOC-P0-003 | `Docs/PRODUCT_FEATURES_IT.md` | § Snorkeling / § Apnea | Rewrite both sections as MAIN production (Watch + iOS), link `APNEA_ARCHITECTURE.md` / `SNORKELING_ARCHITECTURE.md`, mark `codex/*` as legacy exploration only | Contradicts V3.0 MAIN architecture; Italian overview misleads | P0 | 06 Documentation |
| DOC-P0-004 | `Docs/EXPERIMENTAL_FEATURES.md` | Opening + Apnea integration | State Buddy Assist / exploration / legacy branch surfaces only; remove "Apnea excluded from MAIN Watch target until promotion" | Implies Apnea not in production MAIN | P0 | 06 Documentation |

---

## P1 — README / matrix / command sequence / release wording / ownership

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P1-001 | `README.md` | Release baseline | Update `origin/main` @ **`1f62235`**; add link to `commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE.md` | Stale SHA bf03fb0 | P1 | 06 Documentation |
| DOC-P1-002 | `Docs/README.md` | Baseline + stato corrente | Refresh baseline to `1f62235`; add row for master audits 01–05 outputs | Primary project doc stale | P1 | 06 Documentation |
| DOC-P1-003 | `Docs/INDEX.md` | New top section | Insert "Aggiornamento indice 2026-06-22 — Master audit Launch Order 01–06" with links to all `MASTER_*_CURRENT` reports/matrices | Master audit outputs invisible | P1 | 06 Documentation |
| DOC-P1-004 | `Docs/INDEX.md` | Command 6 V3.0 section | Add superseded banner → `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.0.md` | Wrong active command | P1 | 06 Documentation |
| DOC-P1-005 | `Docs/ROADMAP.md` | Header + experimental table | Update date/SHA; add MAIN Snorkeling/Apnea shipped rows; relabel codex table "legacy branch exploration" | ROADMAP contradicts MAIN | P1 | 06 Documentation |
| DOC-P1-006 | `Docs/DIR_DIVING_Feature_Comparison.csv` | Rows 12–26 vs 430–433 | Prefix experimental rows with `branch=codex/* (legacy)` or move to appendix; ensure no conflict with MAIN rows | Feature matrix drift | P1 | 06 Documentation |
| DOC-P1-007 | `Docs/WATCH_LOW_POWER_MISSION_MODE_IMPLEMENTATION_REPORT.md` | App Store rows | Demote "App Store ready" to conditional internal; cite PENDING physical QA | Overstates release readiness | P1 | 05 Release QA |
| DOC-P1-008 | `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | project.yml claim | Add superseded banner @ top; note Apnea/Snorkeling now in MAIN | Pre-V3.0 false exclusion | P1 | 06 Documentation |
| DOC-P1-009 | `commands_for_cursor/` archive | Missing V3.0 files | Restore or document absence of Commands 4–17 V3.0 in `INDEX` superseded table | INDEX references missing files | P1 | 06 Documentation |
| DOC-P1-010 | `Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md` | Scope | Append § post-master-audit delta @ `1f62235` | Last alignment @ bf03fb0 | P1 | 06 Documentation |
| DOC-P1-011 | `Docs/CHANGELOG.md` | Unreleased | Add master audit 01–06 execution summary (audit-only outputs) | Release notes gap | P1 | 06 Documentation |
| DOC-P1-012 | `Docs/ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md` | ORCH-001 | Footnote: altitude environment P0 remediated @ 1f62235 per MASTER_WATCH audit | Stale NO-GO root cause | P1 | 01 Watch FC |

---

## P2 — Missing links / incomplete index / stale readiness / screenshots

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P2-001 | `Docs/INDEX.md` | Settings / Logbook | Consolidated link block: `IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md`, `WATCH_ACTIVITY_SETTINGS_ACCESS_CURRENT.md`, `MASTER_UI_UX_*_OWNERSHIP` | Ownership docs scattered | P2 | 03 UI/UX |
| DOC-P2-002 | `Docs/DIR_DIVING_Feature_Comparison.csv` | New rows | Add iOS Settings mode switcher, Activity Settings, Briefing cards (reference-only), Ratio Deco heuristic | Matrix gaps | P2 | 06 Documentation |
| DOC-P2-003 | `Docs/INDEX.md` | Physical/external QA | Link `MASTER_*_EXTERNAL_*` and `MASTER_*_PHYSICAL_*` pending docs from audits 01–05 | QA pending not centralized | P2 | 05 Release QA |
| DOC-P2-004 | `Docs/APNEA_EXPERIMENTAL_SPEC.md` | Title/header | Rename or mark "legacy branch spec — see APNEA_ARCHITECTURE.md for MAIN" | Misleading filename | P2 | 06 Documentation |
| DOC-P2-005 | `Docs/SNORKELING_EXPERIMENTAL_SPEC.md` | Title/header | Same as DOC-P2-004 for Snorkeling | Misleading filename | P2 | 06 Documentation |
| DOC-P2-006 | `Docs/IOS_PERFORMANCE_OPTIMIZATION_AUDIT_CURRENT.md` | INDEX baseline | Normalize referenced SHA to current or mark audit baseline explicitly | SHA drift in INDEX | P2 | 04 Main code |
| DOC-P2-007 | `README.md` | Quick links | Add master audit launch sequence + `MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md` after remediation | Discoverability | P2 | 06 Documentation |
| DOC-P2-008 | `Docs/TERMINOLOGY_GLOSSARY_IT_EN_CURRENT.md` | Settings | Add "mode switcher", "activity-scoped settings", "logbook ownership" | New UI vocabulary | P2 | 03 UI/UX |
| DOC-P2-009 | `Docs/RELEASE_CHECKLIST.md` | Master audits | Checkbox: master audits 01–06 outputs indexed and claims reviewed | Release gate alignment | P2 | 05 Release QA |
| DOC-P2-010 | `Docs/PR_STATUS_*.md` | INDEX preference | Ensure INDEX primary link is latest PR_STATUS (20260620+) | Stale PR narrative | P2 | 06 Documentation |
| DOC-P2-011 | `Docs/WATCH_MAIN_ALGORITHM_READINESS_100_REPORT.md` | Title | Append "(software readiness)" | Ambiguous 100% | P2 | 01 Watch FC |
| DOC-P2-012 | `Docs/MAIN_UI_UX_READINESS_QA_ANALYSIS.md` | Headline | Clarify software-only vs overall UI/UX % | Ambiguous readiness | P2 | 03 UI/UX |
| DOC-P2-013 | `Docs/INDEX.md` | Command 18 | Mark superseded by 01-MASTER_WATCH; retain report link | Duplicate audit track | P2 | 01 Watch FC |
| DOC-P2-014 | `Docs/INDEX.md` | Orchestrator | Mark `00-MASTER_SUPER_ORCHESTRATOR` superseded for execution; keep roadmap link | Two command systems | P2 | 06 Documentation |
| DOC-P2-015 | `Docs/PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | INDEX | Add to Planner/Briefing index subsection | Orphan matrix | P2 | 02 iOS |
| DOC-P2-016 | `Docs/RATIO_DECO_COMPARATIVE_HEURISTIC.md` | Feature matrix + INDEX | Cross-link from planner section | Heuristic under-documented in index | P2 | 02 iOS |
| DOC-P2-017 | `Docs/MASTER_*_CURRENT.*` | Git | Commit audit outputs from Commands 01–05 when approved (separate from this plan) | Untracked evidence | P2 | 06 Documentation |
| DOC-P2-018 | `Docs/BRANCH_AND_TARGET_ISOLATION_POLICY.md` | HEAD | Refresh commit reference to `1f62235` | Minor staleness | P2 | 06 Documentation |

---

## P3 — Copy cleanup / formatting / historical archive notes

| ID | File | Section | Exact change required | Why | Priority | Audit to rerun |
|----|------|---------|----------------------|-----|----------|----------------|
| DOC-P3-001 | `Docs/DOCUMENTATION_BRANCH_ALIGNMENT_202605*.md` | All | Ensure each has "superseded for HEAD" banner pointing to latest alignment report | Archive clarity | P3 | 06 Documentation |
| DOC-P3-002 | `Docs/MAIN_BRANCH_COMPLETE_READINESS_AUDIT_202605*.md` | Verdict | Add archive banner — pre-V3.0 | Historical confusion | P3 | 06 Documentation |
| DOC-P3-003 | `Docs/PR_STATUS_20260607.md` | Header | Superseded by 20260620 | Duplicate PR snapshots | P3 | 06 Documentation |
| DOC-P3-004 | `Docs/INDEX.md` | Length | Consider collapsible/archive section for pre-2026-06 entries | INDEX >2300 lines | P3 | 06 Documentation |
| DOC-P3-005 | `commands_for_cursor/OLD/` | README stub | Add `commands_for_cursor/ARCHIVE_README.md` listing OLD vs OOLD vs missing V3 | Archive discoverability | P3 | 06 Documentation |
| DOC-P3-006 | `Docs/ReferenceUI/README.md` | Legacy paths | Verify all mockup paths match MASTER_MOCKUP_PATH_VALIDATION | Broken reference risk | P3 | 03 UI/UX |
| DOC-P3-007 | `Docs/WATCH_MISSION_MODE_UX_SAFETY_VERIFICATION_REPORT.md` | Formatting | After P0 fix, align table with RELEASE_LEGAL claim registry | Consistency | P3 | 05 Release QA |
| DOC-P3-008 | `Scripts/validate_master_main_code_sync_security_performance_audit.sh` | INDEX | Optional script link under Command 04 | Minor discoverability | P3 | 04 Main code |

---

## Summary counts

| Priority | Open items |
|----------|------------|
| P0 | 4 |
| P1 | 12 |
| P2 | 18 |
| P3 | 8 |
| **Total** | **42** |

**Recommended execution order:** P0 → P1 (INDEX + README + TestFlight + PRODUCT_FEATURES_IT) → P2 feature matrix → P3 archive hygiene → rerun Command 06.

---

*End of plan — audit-only @ `1f62235`*
