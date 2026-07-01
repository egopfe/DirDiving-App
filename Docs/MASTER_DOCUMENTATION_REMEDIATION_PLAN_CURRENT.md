# Master Documentation Remediation Plan — Current

**Audit:** Command 06 V1.5 — Documentation / Repository Alignment  
**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01  
**Upstream inputs:** Audits 01–05 @ `2c30412` (all PARTIAL); CONS-046 **CLOSED** (integrity script V1.5 PASS)

Do **not** apply fixes in this audit pass — planned edits only.

---

## P0 — Unsafe / unsupported claims

| File | Section | Exact change required | Why | Audit rerun |
|------|---------|----------------------|-----|-------------|
| `Docs/WATCH_LOW_POWER_MISSION_MODE_IMPLEMENTATION_REPORT.md` | § App Store ready / summary tables | Replace **Conditional yes** / **Yes with copy review** with **NO for external App Store** · **Internal TestFlight conditional** · **PHYSICAL_QA_PENDING** | Claims App Store readiness without physical/legal evidence | 05, 06 |
| `Docs/DOCUMENTATION_UPDATE_REPORT_20260609.md` | Not claimed list | Remove bullet **CCR external validation complete** or move to **PENDING** with evidence link | Contradicts `CCR_REBREATHER_VALIDATION_EVIDENCE` PENDING status | 05, 06 |

---

## P1 — Architecture / command / index drift

| File | Section | Exact change required | Why | Audit rerun |
|------|---------|----------------------|-----|-------------|
| `README.md` | Release baseline | Update `bf03fb0` → `2c30412`; link V1.5 launch sequence | Stale SHA misleads contributors | 06 |
| `Docs/README.md` | Baseline table | Refresh to `2c30412`; orchestrator **V1.5**; audits 01–07 | Secondary index stale | 06 |
| `Docs/INDEX.md` | Header | `Aggiornato: 2026-07-01` · `main` @ `2c30412` | Header cites `ad1c836` | 06 |
| `Docs/INDEX.md` | Master command table | Update all commands to **V1.5** filenames | Still cites V1.1/V1.2/V2.x | 06 |
| `Docs/INDEX.md` | Command 10 block | Point to `11-MASTER_2026_06_30...` or restore Command 10 alias | Remediation body is Command 11 | 06 |
| `Docs/INDEX.md` | CONS-046 block | Reconcile **SOFTWARE_READY 100%** with audits 01–05 **PARTIAL** | Overstates release readiness | 06 |
| `Docs/INDEX.md` | Apnea audit block | Add links to `MASTER_IOS_APNEA_*`, `MASTER_UI_UX_APNEA_*`, `MASTER_APNEA_RELEASE_*` | V1.5 Apnea scope outputs not indexed | 06 |
| `Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md` | Header | Refresh to `2c30412`, orchestrator V1.5, CONS-046/049 closed | Plan header @ `451f8fb` stale | 00 |
| `Docs/DIR_DIVING_Feature_Comparison.csv` | Rows 12–26 vs 430–433 | Mark codex experimental Apnea/Snorkeling rows superseded; add GF/shallow/WAO/mode-switcher rows | Matrix drift | 06 |
| `Docs/MAIN_BRANCH_FINAL_READINESS_REPORT.md` | Top | Archive banner: superseded pre-V3.0; Apnea/Snorkeling on MAIN | Conflicts current architecture | 06 |

---

## P2 — Missing links / stale baselines

| File | Section | Exact change required | Why | Audit rerun |
|------|---------|----------------------|-----|-------------|
| `Docs/ROADMAP.md` | Header | Update SHA/date to `2c30412` | Stale | 06 |
| `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Header | Refresh baseline SHA; add shallow + WAO bullets | Release notes drift | 05 |
| `Docs/PRODUCT_FEATURES_IT.md` | Branch table | Clarify codex comparison ≠ MAIN exclusion | Ambiguous experimental wording | 06 |
| `APNEA_EXPERIMENTAL_SPEC.md` | Header | Legacy banner → `APNEA_ARCHITECTURE.md` | Misleading filename | 06 |
| `SNORKELING_EXPERIMENTAL_SPEC.md` | Header | Legacy banner → `SNORKELING_ARCHITECTURE.md` | Misleading filename | 06 |
| `Docs/INDEX.md` | Watch wave | Link `MASTER_ALGORITHMIC_*` gate docs from audit 05 | Under-indexed safety gates | 06 |

---

## P3 — Copy cleanup / archive notes

| File | Section | Exact change required | Why |
|------|---------|----------------------|-----|
| `commands_for_cursor/OOLD/` | README | List superseded V1.0–V2.x commands → active V1.5 | Discoverability |
| Historical CCR audit docs | Header | Archive banner → `MASTER_*_CURRENT` | Prevent mistaken authority |
| `Docs/PR_STATUS_20260607.md` | Header | Superseded notice | Duplicate narrative |

---

## Summary counts

| Priority | Count |
|----------|------:|
| P0 | 2 |
| P1 | 10 |
| P2 | 6 |
| P3 | 3+ |

**Total planned remediation items:** 21+ distinct edits across 15+ files.
