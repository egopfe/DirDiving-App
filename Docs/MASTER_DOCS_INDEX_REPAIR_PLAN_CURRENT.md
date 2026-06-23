# Master Docs Index Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment  
**Target:** `Docs/INDEX.md` (primary index; `Docs/README.md` secondary)  
**Baseline:** `main` @ `1f62235`  
**Date:** 2026-06-22

Do **not** edit INDEX in this audit pass. Below are exact planned additions and fixes.

---

## 1. New top section (insert after file header, before 2026-06-22 iOS Performance)

```markdown
## Aggiornamento indice 2026-06-22 — Master audit Launch Order 01–06

Audit read-only consolidato; output `Docs/MASTER_*_CURRENT.*`. Sequenza canonica: [`commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE.md`](../commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE.md).

| # | Command | Main report | Key matrices / plans |
|---|---------|-------------|----------------------|
| 01 | `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.0.md` | [`MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md`](MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md) | Schreiner, altitude, physical QA, external validation |
| 02 | `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.0.md` | [`MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) | Feature inventory, settings/logbook ownership, release hard matrix |
| 03 | `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.0.md` | [`MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md`](MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md) | Navigation, settings, logbook, mockup, gap remediation |
| 04 | `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.0.md` | [`MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md`](MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md) | Sync, security, performance, concurrency |
| 05 | `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.0.md` | *(pending `MASTER_RELEASE_*_CURRENT`)* · interim [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md) | QA evidence, legal claims |
| 06 | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.0.md` | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) | Truthfulness, outdated inventory, remediation plans |

| Campo | Valore |
|-------|--------|
| **Baseline** | `main` @ `1f62235` |
| **Verdict (aggregate)** | **PARTIAL** — software/documented posture strong; INDEX/command drift; physical/external **PENDING** |
| **Superseded for execution** | V3.0 numbered commands 0–18 · Orchestrator V1.1 · `IOS_PERFORMANCE_OPTIMIZATION_AUDIT_COMMAND` (partial → 04) |
```

---

## 2. Missing links checklist

| Topic | Expected path | Currently in INDEX? | Action |
|-------|---------------|---------------------|--------|
| Project overview | `Docs/README.md` | Partial (implicit) | Add under "Panoramica" |
| Safety philosophy | `SAFETY_DISCLAIMER.md` | Yes (scattered) | Consolidate single Safety block |
| Watch MAIN | `WATCH_MAIN_UX_CONVENTIONS.md`, FC architecture | Partial | Link under Diving Watch |
| iOS Companion | `IOS_COMPANION_SETTINGS_MODE_SWITCH_CURRENT.md` | Yes (2026-06-22 section) | Keep; cross-link from master 02/03 |
| Diving / Gauge / Full Computer | `FULL_COMPUTER_ARCHITECTURE.md` | Partial | Add to master 01 subsection |
| Apnea | `APNEA_ARCHITECTURE.md` | Weak | Dedicated Apnea block in master 02 |
| Snorkeling | `SNORKELING_ARCHITECTURE.md` | Weak | Dedicated Snorkeling block |
| Planner | Bühlmann engine docs | Yes | Link from master 02 |
| Bühlmann | `DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` | Yes | — |
| CCR reference-only | `CCR_REBREATHER_PLANNER.md`, safety disclaimer | Yes | Add "reference-only" tag in master table |
| Ratio Deco | `RATIO_DECO_COMPARATIVE_HEURISTIC.md` | Missing | Add under Planner |
| Equipment/checklist | Equipment docs | Partial | Link from master 02 |
| Rock Bottom | Planner emergency docs | Partial | Link from planner subsection |
| Gas ledger | Planner gas schedule docs | Partial | — |
| Repetitive dive | Planner repetitive docs | Partial | — |
| Briefing cards | `PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | **Missing** | Add under Planner + master 02 |
| Sync/security | `MASTER_SYNC_*`, `MASTER_SECURITY_*` | **Missing** (non-MASTER names indexed) | Add master 04 matrix links |
| Privacy | `MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv` | **Missing** | Add master 04 link |
| Performance | `MASTER_PERFORMANCE_*`, IOS performance docs | Partial | Unify under master 04 |
| Localization/accessibility | `DIR_DIVING_LOCALIZATION_AUDIT_CURRENT.md` | Yes | Cross-link master 03 |
| UI/UX | `MASTER_UI_UX_*` | **Missing** | master 03 block |
| Mockups | `MASTER_MOCKUP_*` | **Missing** | master 03 block |
| Release/TestFlight/App Store | `RELEASE_CHECKLIST.md`, `TESTFLIGHT_REVIEW_NOTES.md` | Yes | Flag P0 stale TestFlight section |
| QA evidence | `Docs/QA_EVIDENCE/` | Partial | Link master pending docs |
| Audit master commands | `commands_for_cursor/01-06` | **Missing** | New top section §1 |
| Superseded commands | `commands_for_cursor/OLD`, `OOLD` | **Missing** | New subsection below |

---

## 3. Superseded commands subsection (planned)

```markdown
### Comandi audit superseded (archivio)

| Comando | Stato | Archivio / sostituto |
|---------|-------|----------------------|
| `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED_V3.0.md` | Superseded | → `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.0.md` |
| `0`–`3` V3.0 math/algorithm | Superseded | → `01` / `02` MASTER |
| `4`–`16` V3.0 (file assenti in repo) | Superseded | → `01`–`05` MASTER; report legacy in `Docs/*_CURRENT.md` |
| `18` CMAltimeter | Superseded | → `01-MASTER_WATCH` |
| `00-MASTER_SUPER_ORCHESTRATOR` V1.1 | Superseded (execution) | → Launch Order `01`–`06`; retain remediation roadmap |
| `commands_for_cursor/OLD/*` V2.0 | Archivio | Non eseguire |
| `commands_for_cursor/OOLD/*` V3.0 parziale | Archivio | Non eseguire |
```

---

## 4. Sections requiring superseded banners (no deletion)

| INDEX section | Banner text |
|---------------|-------------|
| Command 6 git/documentation V3.0 | Superseded by Command 06 MASTER @ 2026-06-22 |
| Orchestrated audit V1.1 | Execution superseded by Launch Order 01–06; ORCH-001 verify @ 1f62235 |
| Command 18 CMAltimeter | Superseded by 01-MASTER_WATCH FC forensic |

---

## 5. `Docs/README.md` secondary index gaps

| Missing link | Planned location |
|--------------|------------------|
| Master audit launch sequence | After "Indice: INDEX.md" |
| `MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md` | After alignment report link |
| Apnea/Snorkeling architecture (already in opening) | Ensure `PRODUCT_FEATURES_IT` defers to same |

---

## 6. Acceptance criteria (post-remediation)

- [ ] New user finds Launch Order 01–06 within first 30 lines of INDEX or README quick links
- [ ] Every `MASTER_*_CURRENT` file from audits 01–06 linked once in INDEX
- [ ] No INDEX section presents V3.0 Command 6 as active without superseded banner
- [ ] Superseded command archive paths documented
- [ ] Briefing cards, Ratio Deco, Settings mode switch reachable from INDEX without grep

---

*End of index repair plan — audit-only*
