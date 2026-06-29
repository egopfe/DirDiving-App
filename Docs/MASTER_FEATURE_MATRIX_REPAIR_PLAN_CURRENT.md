# Master Feature Matrix Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.1** (post-remediation rerun)  
**Target matrix:** `Docs/DIR_DIVING_Feature_Comparison.csv`  
**Reference matrices:** `MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv`, `MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv`, `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv`  
**Baseline:** `main` @ `5d757cc`  
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
| **Water auto-open routing** | **MISSING** | FC-020 feature inventory |
| **GF preset selection (Watch FC)** | **MISSING** | FC-019 feature inventory |
| **Shallow depth entitlement / dev toggles** | **MISSING** | FC-017–018; DEPTH_CAPABILITY matrix |
| **Digital Crown / Action Button underwater** | **MISSING** | MASTER_WATCH_UNDERWATER_HARDWARE matrix |

**Verdict:** `FEATURE_MATRIX_CURRENT: PARTIAL` (unchanged — CSV not edited in remediation pass)

---

## 2. Conflicting rows to reconcile

| CSV rows | Issue | Planned fix |
|----------|-------|-------------|
| 12–26 (`Experimental,codex/experimental-features`) | Implies Apnea/Snorkeling not on MAIN | Change `Branch` to `codex/experimental-features (legacy)`; Notes: superseded by 430–433 |
| 340, 383 | "UI/UX readiness 100%" doc rows | Append Notes: "software only; physical QA PENDING" |

---

## 3. Planned new rows (2026-06-28 wave)

Unchanged from prior plan — see rows WAO, GF, SH, DEV, A, B, C in prior audit. Source: `MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY FC-017`–`FC-020`.

---

## 4. Execution order

1. Fix conflicting experimental rows (12–26) — **P1**
2. Add 2026-06-28 wave rows (WAO, GF, SH, DEV) — **P1**
3. Add mode switcher, briefing, Ratio Deco — **P2**
4. Append PENDING notes to readiness doc rows — **P2**
5. Re-run `./Scripts/validate_main_release_readiness.sh` after CSV edit — **P2**

**Planned repair file count:** 1 primary (`DIR_DIVING_Feature_Comparison.csv`) + INDEX cross-links.
