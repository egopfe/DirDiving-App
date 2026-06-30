# Master Feature Matrix Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.2**  
**Target matrix:** `Docs/DIR_DIVING_Feature_Comparison.csv`  
**Reference matrices:** `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`, `MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv`, `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv`  
**Baseline:** `main` @ `451f8fb`  
**Date:** 2026-06-30

Do **not** edit the CSV in this audit pass.

---

## 1. Current assessment

| Criterion | Status | Notes |
|-----------|--------|-------|
| Diving Gauge | **PASS** | Core navigation row; Watch algorithm rows |
| Diving Full Computer | **PASS** | Row 429; not certified noted |
| Apnea MAIN | **PARTIAL** | Rows 430 accurate; conflicts with experimental rows 20–26 |
| Snorkeling MAIN | **PARTIAL** | Row 431 accurate; conflicts with experimental rows 12–19; 18 SNORKELING_* docs not reflected |
| iOS Settings mode switcher | **MISSING** | Implemented; not in CSV |
| Activity Settings (Watch/iOS) | **MISSING** | Ownership matrices not reflected |
| Activity Logbooks | **PARTIAL** | Implied in navigation; no per-activity rows |
| Watch Full Computer | **PASS** | Row 429 + briefing utility rows |
| iOS Planner | **PASS** | Extensive planner rows |
| CCR reference-only | **PASS** | Docs rows 403–406 |
| Ratio Deco | **MISSING** | No feature row |
| Equipment | **PASS** | Template rows present |
| Checklist | **PARTIAL** | CCR checklist weak |
| Briefing cards | **PARTIAL** | Utility rows 416–417 only |
| Sync/security | **PASS** | Sync rows present |
| Privacy | **PARTIAL** | Separate MASTER files not in CSV |
| Physical QA | **PARTIAL** | PENDING inconsistent on experimental rows |
| External validation | **PARTIAL** | Not on CSV |
| TestFlight/App Store readiness | **OUTDATED** | Some doc rows lack PENDING gates |
| **Water auto-open routing** | **MISSING** | FC-020 feature inventory |
| **GF preset selection (Watch FC)** | **MISSING** | FC-019 feature inventory |
| **Shallow depth entitlement / dev toggles** | **MISSING** | FC-017–018; DEPTH_CAPABILITY matrix |
| **Digital Crown / Action Button underwater** | **MISSING** | MASTER_WATCH_UNDERWATER_HARDWARE matrix |

**Verdict:** `FEATURE_MATRIX_CURRENT: PARTIAL`

---

## 2. Conflicting rows to reconcile

| CSV rows | Issue | Planned fix |
|----------|-------|-------------|
| 12–26 (`Experimental,codex/experimental-features`) | Implies Apnea/Snorkeling not on MAIN | Change `Branch` to `codex/experimental-features (legacy)`; Notes: superseded by 430–433 |
| 340, 383 | "UI/UX readiness 100%" doc rows | Append Notes: "software only; physical QA PENDING" |
| 376–379 | Experimental architecture rows | Prefix `(legacy branch)`; link SNORKELING_ARCHITECTURE / APNEA_ARCHITECTURE |

---

## 3. Planned new rows (exact content)

### Row A — iOS Settings mode switcher

```csv
Core,main,iOS Companion,Settings,iOS activity mode switcher,Implemented,Yes,Yes,Yes,Segmented Diving/Apnea/Snorkeling scope routing in Settings; UI-only visibility gates.,iOS_look_feel.png,"it, en",IOSCompanionSettingsModeSwitch tests; not in CSV @ 451f8fb.
```

### Row B — Watch water auto-open routing

```csv
Core,main,Apple Watch,Navigation,Water auto-open routing,Implemented,Yes,Yes,Yes,Submersion launch routes to mode selection or FC predive; does NOT start dive.,settings_from_workflow.png,"it, en",WATCH_WATER_AUTO_OPEN_POLICY.md; physical QA PENDING.
```

### Row C — Full Computer GF preset selection

```csv
Core,main,Apple Watch,Diving,Full Computer GF preset selection,Implemented,Yes,Yes,Yes,Three presets at predive; locked during active FC runtime; snapshotted to logbook.,MASTER_REFERENCE_DIVING_LIVE.png,"it, en",MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX; not certified.
```

### Row D — Shallow depth developer testing toggles

```csv
Core,main,Apple Watch,Settings,Developer shallow Gauge/FC testing toggles,Implemented,Yes,Yes,Yes,Default OFF; TestFlight/internal only; not production decompression guidance.,settings_from_workflow.png,"it, en",MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX; wet QA PENDING.
```

### Row E — Snorkeling iOS companion (expand row 433)

Add Notes to row 433: `See SNORKELING_IOS_WATCH_ARCHITECTURE.md; map type settings; route planner; PHYSICAL_QA_PENDING.`

### Row F — Ratio Deco heuristic

```csv
Algorithm,main,iOS Companion,Planner,Ratio Deco comparative heuristic,Implemented,Yes,Yes,N/A,Comparative heuristic alongside Bühlmann; not a decompression algorithm.,ios_planner_reference.png,"it, en",RATIO_DECO_COMPARATIVE_HEURISTIC.md.
```

---

## 4. Snorkeling documentation cross-reference

Snorkeling is **documented** outside the CSV in 18 files. Matrix repair should add a Documentation row:

```csv
Documentation,main,All,Snorkeling,Snorkeling architecture and release docs,Implemented,Yes,N/A,N/A,18 SNORKELING_* docs; INTERNAL_READY · PHYSICAL_QA_PENDING.,SNORKELING_ARCHITECTURE.md,"it, en",validate_snorkeling_release_readiness.sh.
```

---

## 5. Repair sequence

1. Reconcile experimental legacy rows (12–26) — **P1**
2. Add 2026 wave rows A–D — **P1**
3. Add mode switcher + Ratio Deco — **P2**
4. Append PENDING gates to readiness doc rows — **P2**
5. Add Snorkeling documentation row — **P2**

**Estimated new rows:** 6  
**Estimated row edits:** 15
