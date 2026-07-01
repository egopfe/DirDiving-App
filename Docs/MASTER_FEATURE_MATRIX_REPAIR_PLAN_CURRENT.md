# Master Feature Matrix Repair Plan — Current

**Audit:** Command 06 V1.5  
**Target:** `Docs/DIR_DIVING_Feature_Comparison.csv`  
**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01

Do **not** edit the CSV in this audit pass.

---

## 1. Duplicate / conflicting rows (P1)

| Rows | Issue | Planned fix |
|------|-------|-------------|
| 12–26 (codex experimental Apnea/Snorkeling) vs 430–433 (MAIN) | Conflicting **Experimental** vs **Implemented** | Add column note **SUPERSEDED_BY_ROW_430** on legacy codex rows; keep for history |
| Row 430 Apnea | Accurate MAIN status | Retain as canonical Apnea row |
| Row 431+ Snorkeling | Accurate MAIN status | Retain as canonical Snorkeling row |

---

## 2. Missing rows — add from feature inventories (P1)

| Feature | Source inventory | Planned CSV row fields |
|---------|------------------|------------------------|
| iOS Settings mode switcher | `MASTER_UI_UX_SETTINGS_OWNERSHIP_MATRIX` | Core, main, iOS, All, mode switcher, Implemented, PHYSICAL_QA n/a |
| Watch water auto-open routing | `MASTER_WATCH_WATER_AUTO_OPEN_AUDIT` FC-016 | Core, main, Apple Watch, Diving, WAO policy, Implemented, PENDING physical |
| Full Computer GF preset selection | `MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX` | Core, main, Apple Watch, Diving, GF presets predive, Implemented |
| GF predive snapshot persistence | FC-019 feature inventory | Algorithm, main, Apple Watch, Diving, GF snapshot, Implemented |
| Shallow-depth developer Gauge toggle | `MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX` | Core, main, Apple Watch, Diving, dev shallow Gauge, Implemented, Internal TF only |
| Shallow-depth developer FC toggle | Same matrix | Core, main, Apple Watch, Diving, dev shallow FC, Implemented, Internal TF only |
| Apnea WAO boundary | `MASTER_WATCH_APNEA_WATER_AUTO_OPEN_BOUNDARY_MATRIX` | Core, main, Apple Watch, Apnea, WAO no auto-start, Implemented, PENDING |
| Legacy App Intent routing | `MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION` | Safety, main, Apple Watch, All, Legacy intent block, Implemented |

---

## 3. Activity coverage verification (P2)

| Area | Matrix status | Action |
|------|---------------|--------|
| Diving Gauge | Present | None |
| Diving Full Computer | Present row 429 | Cross-link GF/WAO rows |
| Apnea | Row 430 accurate | Reconcile experimental duplicates |
| Snorkeling | Rows 431+ | Reconcile experimental duplicates |
| iOS Planner | Present | None |
| CCR reference-only | Documented rows | None |
| Briefing cards | Present | Confirm reference-only note |
| Sync/security | Partial | Add CONS-003/004/005 remediation note row |
| Physical QA | Missing aggregate row | Add **Documentation** row: all physical QA PENDING |

---

## 4. Truthfulness constraints for new rows

All new rows must include:

- **Not certified** where decompression-adjacent
- **PENDING_PHYSICAL** for water auto-open, shallow wet, Crown, Action Button
- **Internal/TestFlight only** for developer shallow toggles
- **Does not start dive/session** for WAO rows

---

## 5. Priority summary

| Priority | Items |
|----------|------:|
| P1 | Dedupe Apnea/Snorkeling experimental rows; add 8 missing 2026-wave rows |
| P2 | Physical QA aggregate row; sync remediation note |
| P3 | Column formatting cleanup |

**Estimated new rows:** 8–10  
**Estimated row annotations:** 14 legacy codex rows
