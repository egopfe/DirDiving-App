# Master Docs Index Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.1**  
**Target:** `Docs/INDEX.md` (primary index; `Docs/README.md` secondary)  
**Baseline:** `main` @ `7dfefe2`  
**Date:** 2026-06-28

Do **not** edit INDEX in this audit pass. Below are exact planned additions and fixes.

---

## 1. New top section (insert after file header)

```markdown
## Aggiornamento indice 2026-06-28 — Master audit V1.2 + Watch development wave

**Baseline:** `main` @ `7dfefe2`  
**Launch sequence:** [`commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md`](../commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md)  
**Orchestrator:** `00-MASTER_SUPER_ORCHESTRATOR...V1.2.md`

> **P0 BLOCKER:** `commands_for_cursor/01`–`04` bodies are **permuted** (01=file04 Main Code, 02=file03 UI/UX, 03=file01 Watch FC, 04=file02 iOS). Repair before executing audits by filename alone.

| # | Command (expected) | Main report @ 7dfefe2 |
|---|-------------------|------------------------|
| 01 | `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.1.md` | [`MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md`](MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md) |
| 02 | `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md` | [`MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) |
| 03 | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.2.md` | [`MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) |
| 04 | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.1.md` | [`MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`](MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md) |
| 05 | `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md` | [`MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md`](MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md) |
| 06 | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |

**2026-06-28 Watch wave matrices:**  
[`MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md`](MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md) · [`MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv`](MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv) · [`MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv`](MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv) · [`MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv`](MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv) · [`WATCH_WATER_AUTO_OPEN_POLICY.md`](WATCH_WATER_AUTO_OPEN_POLICY.md) · [`WATCH_UNDERWATER_FAST_CONTROLS.md`](WATCH_UNDERWATER_FAST_CONTROLS.md)

| Campo | Valore |
|-------|--------|
| **Verdict (aggregate)** | **PARTIAL** — safety posture strong; **command permutation P0**; physical/external **PENDING** |
| **Superseded for execution** | V3.0 commands 0–18 · Orchestrator V1.1 · `00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE.md` (OOLD) |
```

---

## 2. Missing links checklist

| Topic | Expected path | Currently in INDEX? | Action |
|-------|---------------|---------------------|--------|
| Project overview | `Docs/README.md` | Partial | Add under "Panoramica" |
| Safety philosophy | `SAFETY_DISCLAIMER.md` | Yes (scattered) | Consolidate Safety block |
| Watch MAIN | `WATCH_MAIN_UX_CONVENTIONS.md`, FC architecture | Partial | Link under Diving Watch |
| iOS Companion | `IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md` | Yes (2026-06-22) | Cross-link master 02/03 |
| Diving / Gauge / Full Computer | `FULL_COMPUTER_ARCHITECTURE.md` | Partial | Master 01 subsection |
| Apnea | `APNEA_ARCHITECTURE.md` | Weak | Dedicated Apnea block |
| Snorkeling | `SNORKELING_ARCHITECTURE.md` | Weak | Dedicated Snorkeling block |
| Planner | Bühlmann engine docs | Yes | Master 02 link |
| Bühlmann | `DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` | Yes | — |
| CCR reference-only | `CCR_REBREATHER_PLANNER.md` | Yes | Add reference-only tag |
| Ratio Deco | `RATIO_DECO_COMPARATIVE_HEURISTIC.md` | **Missing** | Planner subsection |
| Equipment/checklist | Equipment docs | Partial | Master 02 |
| Rock Bottom | Planner emergency docs | Partial | Planner subsection |
| Gas ledger | Planner gas schedule | Partial | — |
| Repetitive dive | Planner repetitive docs | Partial | — |
| Briefing cards | `PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | **Missing** | Planner + master 02 |
| Sync/security | `MASTER_SYNC_*`, `MASTER_SECURITY_*` | **Missing** as master block | Master 04 links |
| Privacy | `MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv` | **Missing** | Master 04 |
| Performance | `MASTER_PERFORMANCE_*` | Partial | Unify under master 04 |
| Localization/accessibility | `DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md` | Yes | Master 03 cross-link |
| UI/UX | `MASTER_UI_UX_*` | Partial (2026-06-22) | Expand to V2.2 |
| Mockups | `MASTER_MOCKUP_*` | Partial | Master 03 |
| Release/TestFlight/App Store | `TESTFLIGHT_REVIEW_NOTES`, `RELEASE_CHECKLIST` | Yes | Refresh baseline |
| QA evidence | `QA_EVIDENCE/README.md` | Partial | Central pending register |
| Audit master commands | `00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md` | **Missing** | New top section |
| Superseded commands | `commands_for_cursor/OLD`, `OOLD` | **Missing** | ARCHIVE_README link |
| Water auto-open | `WATCH_WATER_AUTO_OPEN_POLICY.md` | **Missing** | 2026-06-28 block |
| Shallow depth / entitlements | `APPLE_SHALLOW_DEPTH_ENTITLEMENT_SUPPORT.md` | Partial | Entitlement block |
| GF presets | `MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv` | **Missing** | FC subsection |
| Command permutation | `MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv` | **Missing** | P0 blocker note |

---

## 3. Superseded INDEX sections to annotate

| INDEX section | Current reference | Planned banner |
|---------------|-------------------|----------------|
| Command 6 V3.0 git alignment | `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT...` | **SUPERSEDED** → Command 06 V1.1 |
| Orchestrator V1.1 only | Partial | **SUPERSEDED for execution** → V1.2 + note 01–04 permutation |
| 2026-06-22 master table | Commands V1.0/V2.0 | Update versions; retain as historical after 2026-06-28 block |
| Command 18 CMAltimeter | Standalone | **SUPERSEDED** → merged into Command 01 |

---

## 4. Exact link snippets to add (Planner subsection)

```markdown
- Briefing cards (reference-only): [`PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv`](PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv)
- Ratio Deco (comparative heuristic): [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md)
- iOS GF preset cards: [`DIR_DIVING_IOS_DECO_GF_PRESET_CARD_SELECTOR_REPORT_CURRENT.md`](DIR_DIVING_IOS_DECO_GF_PRESET_CARD_SELECTOR_REPORT_CURRENT.md)
```

---

## 5. Verdict

**DOCS_INDEX_CURRENT: FAIL** — master V1.2 launch sequence not indexed; 2026-06-28 wave matrices missing; command versions stale; P0 permutation not documented in INDEX.

**Planned repair files after edit:** 1 (`Docs/INDEX.md`) + optional `Docs/README.md` baseline line.
