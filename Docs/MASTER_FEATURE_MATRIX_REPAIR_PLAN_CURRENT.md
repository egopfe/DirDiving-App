# Master Feature Matrix Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.1**  
**Target matrix:** `Docs/DIR_DIVING_Feature_Comparison.csv`  
**Reference matrices:** `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`, `MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv`, `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv`  
**Baseline:** `main` @ `7dfefe2`  
**Date:** 2026-06-28

Do **not** edit the CSV in this audit pass.

---

## 1. Current assessment

| Criterion | Status | Notes |
|-----------|--------|-------|
| Diving Gauge | **PASS** | Core navigation row; Watch algorithm rows |
| Diving Full Computer | **PASS** | Row 429; not certified noted |
| Apnea MAIN | **PARTIAL** | Rows 430–432 accurate; conflicts with experimental rows 20–26 |
| Snorkeling MAIN | **PARTIAL** | Row 431 accurate; conflicts with experimental rows 12–19 |
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
| **Water auto-open routing** | **MISSING** | FC-020 feature inventory @ 7dfefe2 |
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

---

## 3. Planned new rows (2026-06-28 wave)

Use existing column schema: `Category,Branch,Platform,Activity,Feature,Status,Watch,iOS,Sync,Description,Mockup,Localization,Notes`

### Row WAO — Water auto-open routing

```csv
System,main,watchOS,All,Water auto-open startup routing,Implemented,Yes,No,No,"Routes cold/wet launch to last/preferred activity destination; does NOT start dive; FC routes to predive only.",WATCH_WATER_AUTO_OPEN_POLICY.md,"it, en",@ 7dfefe2; WatchSubmersionLaunchProbeTests; PENDING_PHYSICAL QA.
```

### Row GF — Watch FC GF presets

```csv
Diving,main,watchOS,Full Computer,GF preset selection (predive),Implemented,Yes,No,Partial,"Three presets 20/80 30/70 40/85; locked during active runtime; snapshotted to logbook.",MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv,"it, en",FC-019; FullComputerGradientFactorSettingsStoreTests; not Gauge/Apnea/Snorkeling.
```

### Row SH — Shallow depth capability

```csv
System,main,watchOS,Diving,Shallow depth entitlement (default signing),Implemented,Yes,No,No,"Default WithShallowDepth; DIRDepthEntitlementTier=shallow; FC blocked without full entitlement or dev toggle.",BUILD_AND_XCODEGEN_WORKFLOW.md,"it, en",@ 7dfefe2; DepthCapabilityTests; not certified deco guidance.
```

### Row DEV — Developer shallow testing toggles

```csv
System,main,watchOS,Diving,Developer shallow Gauge/FC testing toggles,Implemented (internal),Yes,No,No,"TestFlight/internal only; explicit toggles; ~6m shallow testing scope.",MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv,"it, en",Not App Store production path; PENDING_PHYSICAL wet tests.
```

### Row A — iOS Settings mode switcher (retained from prior plan)

```csv
UX,main,iOS Companion,All,iOS Settings activity mode switcher,Implemented,Yes,Yes,Yes,"UI-only mode switcher routes Diving/Apnea/Snorkeling settings.",IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md,"it, en",IOSActivitySettingsContentVisibilityTests; MASTER_UI_UX settings PASS.
```

### Row B — Briefing cards reference-only

```csv
Planner,main,iOS Companion,Diving,Planner briefing cards (reference-only export),Implemented,Partial,Yes,Yes,"PNG/PDF briefing card export; NOT certified decompression authority.",PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv,"it, en",PlannerBriefingImageExportService; reference-only strings.
```

### Row C — Ratio Deco heuristic

```csv
Planner,main,iOS Companion,Diving,Ratio Deco comparative heuristic,Implemented,No,Yes,No,"Comparative heuristic only; does not replace Bühlmann or certified tools.",RATIO_DECO_COMPARATIVE_HEURISTIC.md,"it, en",RatioDecoPlannerViews; not primary engine.
```

---

## 4. Cross-matrix alignment tasks

| Source matrix | Target CSV action |
|---------------|-------------------|
| `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY FC-017`–`FC-020` | Add rows SH, DEV, GF, WAO |
| `MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX` | Add row: Crown/Action Button underwater clamp — PENDING_PHYSICAL |
| `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX` | Verify Apnea/Snorkeling settings rows match CSV after legacy row fix |
| `MASTER_IOS_FEATURE_INVENTORY` | Add iOS GF planner card row (planner-only not FC) |

---

## 5. Execution order

1. Fix conflicting experimental rows (12–26) — **P1**
2. Add 2026-06-28 wave rows (WAO, GF, SH, DEV) — **P1**
3. Add mode switcher, briefing, Ratio Deco — **P2**
4. Append PENDING notes to readiness doc rows — **P2**
5. Re-run `./Scripts/validate_main_release_readiness.sh` after CSV edit — **P2**

**Planned repair file count:** 1 primary (`DIR_DIVING_Feature_Comparison.csv`) + INDEX cross-links.
