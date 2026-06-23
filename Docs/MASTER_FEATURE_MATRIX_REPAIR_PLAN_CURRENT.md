# Master Feature Matrix Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment  
**Target matrix:** `Docs/DIR_DIVING_Feature_Comparison.csv` (437 data rows)  
**Reference matrices:** `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`, `MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv`, `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv`  
**Baseline:** `main` @ `1f62235`  
**Date:** 2026-06-22

Do **not** edit the CSV in this audit pass.

---

## 1. Current assessment

| Criterion | Status | Notes |
|-----------|--------|-------|
| Diving Gauge | **PASS** | Core navigation row; Watch algorithm rows |
| Diving Full Computer | **PASS** | Row 429; not certified noted |
| Apnea MAIN | **PARTIAL** | Rows 430–432 accurate; **conflicts** with experimental rows 20–26 |
| Snorkeling MAIN | **PARTIAL** | Row 431 accurate; **conflicts** with experimental rows 12–19 |
| iOS Settings mode switcher | **MISSING** | Implemented; documented in INDEX not CSV |
| Activity Settings (Watch/iOS) | **MISSING** | `ACTIVITY_SETTINGS_OWNERSHIP_MATRIX` not reflected |
| Activity Logbooks | **PARTIAL** | Implied in navigation row; no per-activity logbook rows |
| Watch Full Computer | **PASS** | Row 429 + briefing utility rows |
| iOS Planner | **PASS** | Extensive planner rows; CCR docs rows 403–406 |
| CCR reference-only | **PASS** | Documentation + algorithm rows; not controller |
| Ratio Deco | **MISSING** | No feature row; only planner disclaimer strings in l10n inventory |
| Equipment | **PASS** | Equipment template rows present |
| Checklist | **PARTIAL** | CCR checklist sync doc row; generic checklist weak |
| Briefing cards | **PARTIAL** | Utility rows 416–417 only; no user-facing reference-only row |
| Sync/security | **PASS** | Sync rows; security doc rows |
| Privacy | **PARTIAL** | Privacy matrices exist as separate MASTER files not in CSV |
| Physical QA | **PARTIAL** | PENDING noted on some rows; inconsistent on experimental rows |
| External validation | **PARTIAL** | Not on CSV; in separate audit outputs |
| TestFlight/App Store readiness | **OUTDATED** | Some doc rows claim readiness without PENDING gates |

**Verdict:** `FEATURE_MATRIX_CURRENT: PARTIAL`

---

## 2. Conflicting rows to reconcile

| CSV rows | Issue | Planned fix |
|----------|-------|-------------|
| 12–26 (`Experimental,codex/experimental-features`, Apnea/Snorkeling) | Implies features not on MAIN | Change `Branch` column to `codex/experimental-features (legacy)`; add `Notes`: "Superseded for MAIN by rows 430–433; retained for branch diff" |
| 10 vs 53 | Row 10 says Apnea/Snorkeling in MAIN; row 53 correctly excludes Buddy only | No change to 53; add cross-reference note on row 10 |
| 340, 383 | "UI/UX readiness 100%" doc rows | Append "software only; physical QA PENDING" in Notes column |

---

## 3. Planned new rows (exact CSV fields)

Use existing column schema: `Category,Branch,Platform,Activity,Feature,Status,Watch,iOS,Sync,Description,Mockup,Localization,Notes`

### Row A — iOS Settings mode switcher

```csv
UX,main,iOS Companion,All,iOS Settings activity mode switcher,Implemented,Yes,Yes,Yes,"UI-only mode switcher routes Diving/Apnea/Snorkeling settings without cross-activity leakage; IOSApneaSettingsContent/IOSSnorkelingSettingsContent.",IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md,"it, en",@ 2f1d702; IOSActivitySettingsContentVisibilityTests; MASTER_UI_UX settings PASS.
```

### Row B — Watch activity settings access

```csv
UX,main,Apple Watch,All,Watch activity-scoped settings access,Implemented,Yes,N/A,N/A,"Diving/Apnea/Snorkeling settings reachable from activity context; gear routing documented.",WATCH_ACTIVITY_SETTINGS_ACCESS_CURRENT.md,"it, en",validate_activity_settings_navigation_readiness.sh PASS.
```

### Row C — Activity logbook ownership

```csv
Core,main,All,All,Strict activity logbook ownership,Implemented,Yes,Yes,Yes,"Separate logbook stores/routes per Diving Apnea Snorkeling; no cross-activity write.",MASTER_UI_UX_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv,"it, en",7/7 PASS @ 1f62235.
```

### Row D — Planner briefing cards (reference-only)

```csv
UX,main,iOS Companion,Diving,Planner briefing cards reference-only,Implemented,N/A,Yes,Yes,"Briefing card export/import for Watch transfer; indicative only not live decompression authority.",PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv,"it, en",PlannerBriefingCardStore; MASTER_MAIN_CODE briefing PASS.
```

### Row E — Ratio Deco comparative heuristic

```csv
Algorithm,main,iOS Companion,Diving,Ratio Deco comparative heuristic,Implemented,N/A,Yes,N/A,"Side-by-side heuristic vs Bühlmann; not primary decompression engine.",RATIO_DECO_COMPARATIVE_HEURISTIC.md,"it, en",RatioDecoPlannerViews; planner.ratio_deco.disclaimer.
```

### Row F — Physical QA gate (global)

```csv
Release,main,All,All,Physical QA evidence gate,PENDING,No,No,N/A,"All MAIN activities: QA_EVIDENCE folders template-only; execution PENDING.",Docs/QA_EVIDENCE/,"it, en",MASTER_*_PHYSICAL_* matrices; do not claim complete.
```

### Row G — External validation gate (global)

```csv
Release,main,All,All,External Bühlmann/CCR validation gate,PENDING,No,No,N/A,"Oracle/simulator evidence only; third-party/chamber validation PENDING.",MASTER_WATCH_FULL_COMPUTER_EXTERNAL_VALIDATION_PLAN_CURRENT.md,"it, en",15% external readiness @ FC audit.
```

### Row H — Master audit documentation alignment

```csv
Documentation,main,All,All,Master audit Launch Order 01-06 indexed,Partial,Yes,N/A,N/A,"Audit outputs produced; INDEX/feature matrix drift remediation pending Command 06.",MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md,"it, en",@ 1f62235 audit-only.
```

---

## 4. Rows to update (not add)

| Row feature | Column | New value |
|-------------|--------|-----------|
| Documentation branch alignment 20260609+ | Notes | Add "Superseded for command sequence by MASTER Launch Order 01-06" |
| Experimental source exclusion (row 53) | Description | Clarify "excludes BuddyAssist ExperimentalConcepts only" |
| Full Computer Bühlmann runtime (429) | Notes | Add link `MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md` |

---

## 5. Cross-matrix alignment tasks

| Source matrix | Target CSV action |
|---------------|-------------------|
| `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv` (45 rows) | For each MAIN Implemented row missing in CSV, add or mark N/A with doc link |
| `MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv` | Verify Apnea/Snorkeling iOS roots match CSV 432–433 |
| `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv` | Ensure FC-016 CCR reference-only reflected in CSV CCR rows |
| `ACTIVITY_FEATURE_OWNERSHIP_MATRIX_CURRENT.csv` | Merge ownership summary into Row C |

---

## 6. Validation after edit

1. Run `./Scripts/validate_main_release_readiness.sh` (if CSV validated by script).
2. Grep CSV for `Experimental,codex` + `Apnea` — ensure no row without legacy qualifier conflicts with `Core,main`.
3. Rerun Command 06 documentation alignment audit.

---

## 7. Priority

| Priority | Items |
|----------|-------|
| P1 | Reconcile experimental vs MAIN Apnea/Snorkeling rows |
| P1 | Add rows A–C (Settings + logbook ownership) |
| P2 | Add rows D–G (briefing, Ratio Deco, QA gates) |
| P2 | Update readiness doc rows 340/383 |
| P3 | Row H documentation alignment |

---

*End of feature matrix repair plan — audit-only*
