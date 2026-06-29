# Master Docs Index Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.1** (post-remediation rerun)  
**Target:** `Docs/INDEX.md` (primary index; `Docs/README.md` secondary)  
**Baseline:** `main` @ `5d757cc`  
**Date:** 2026-06-28

Do **not** edit INDEX in this audit pass except the Command 06 post-remediation block added by this rerun. Below are exact planned additions and fixes.

---

## 1. Status of prior repair plan items

| Prior item | Status @ 5d757cc |
|------------|------------------|
| 2026-06-28 consolidated remediation section (Command 10) | **DONE** — lines 8–21 |
| Command permutation P0 blocker note | **OBSOLETE** — CONS-001 FIXED; replace with integrity PASS note |
| Command 06 documentation alignment block | **ADDED** by this audit rerun |
| Watch wave matrix links in top block | **PARTIAL** — policy docs linked; GF/shallow matrices pending |

---

## 2. Command 06 post-remediation INDEX block (added by this rerun)

```markdown
## Aggiornamento indice 2026-06-28 — Documentation / Repository Alignment Audit V1.1 (Command 06 post-remediation)

Post-remediation read-only rerun @ `5d757cc`: CONS-001 command integrity **PASS**; CONS-034 INDEX wave **PARTIAL**.

| Campo | Valore |
|-------|--------|
| **Command** | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.1.md` |
| **Report** | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |
| **Truthfulness matrix** | [`MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv`](MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv) |
| **Outdated inventory** | [`MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv`](MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv) |
| **Command alignment** | [`MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv`](MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv) · [`MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv`](MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv) |
| **Remediation plan** | [`MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md`](MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md) |
| **Index repair plan** | [`MASTER_DOCS_INDEX_REPAIR_PLAN_CURRENT.md`](MASTER_DOCS_INDEX_REPAIR_PLAN_CURRENT.md) |
| **Feature matrix repair** | [`MASTER_FEATURE_MATRIX_REPAIR_PLAN_CURRENT.md`](MASTER_FEATURE_MATRIX_REPAIR_PLAN_CURRENT.md) |
| **Watch wave alignment** | [`MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv`](MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv) |
| **Entitlement alignment** | [`MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Validate** | `./Scripts/validate_commands_for_cursor_integrity.sh` **PASS** |
| **Verdict** | **PARTIAL** — command integrity PASS; README baseline FAIL; feature matrix PARTIAL; 2× P0 claim docs remain |
| **Audit baseline** | `5d757cc` |
```

---

## 3. Remaining missing links checklist

| Topic | Expected path | Currently in INDEX? | Action |
|-------|---------------|---------------------|--------|
| GF preset matrix | `MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv` | **Missing** top block | Add to Command 10 or Watch FC subsection |
| Shallow depth matrix | `MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv` | **Missing** top block | Add to entitlement subsection |
| Water auto-open audit | `MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.csv` | Partial | Expand 2026-06-28 block |
| Ratio Deco | `RATIO_DECO_COMPARATIVE_HEURISTIC.md` | **Missing** | Planner subsection |
| Briefing cards | `PLANNER_BRIEFING_CARD_KIND_MATRIX_CURRENT.csv` | **Missing** | Planner subsection |
| Master 04 sync/security | `MASTER_SYNC_*`, `MASTER_SECURITY_*` | **Missing** block | Master 04 links |
| Launch sequence doc | `00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-28.md` | **Missing** | Link from Command 06 block |
| Superseded commands | `commands_for_cursor/OLD`, `OOLD` | **Missing** | ARCHIVE_README link |

---

## 4. Superseded INDEX sections to annotate

| INDEX section | Current reference | Planned banner |
|---------------|-------------------|----------------|
| Command 6 V3.0 git alignment | `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT...` | **SUPERSEDED** → Command 06 V1.1 |
| 2026-06-22 master table | Commands V1.0/V2.0 | Update versions; retain as historical |
| Command permutation blocker | N/A (was planned) | **REMOVE** — replaced by integrity PASS note |

---

## 5. Verdict

**DOCS_INDEX_CURRENT: PARTIAL** (improved from FAIL @ 7dfefe2)

- **PASS:** 2026-06-28 consolidated remediation section; header date; policy doc links  
- **PARTIAL:** Watch wave matrices under-indexed; README not refreshed  
- **FIXED:** Command permutation blocker no longer applicable  

**Planned repair files after edit:** `Docs/INDEX.md` + `README.md` + `Docs/README.md` baseline lines.
