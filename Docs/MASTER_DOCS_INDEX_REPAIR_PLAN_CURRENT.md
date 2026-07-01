# Master Docs Index Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.5**  
**Target:** `Docs/INDEX.md` (primary index; `Docs/README.md` secondary)  
**Baseline:** `main` @ `2c30412`  
**Date:** 2026-07-01

Do **not** edit INDEX in this audit pass. Below are exact planned additions and fixes.

---

## 1. Header refresh (P1)

Replace top header:

```markdown
**Aggiornato:** 2026-07-01  
**Branch consigliato:** `main` = `origin/main` @ `2c30412`
```

---

## 2. Command 06 V1.5 INDEX block (P1 — add after orchestrator block)

```markdown
## Aggiornamento indice 2026-07-01 — Documentation / Repository Alignment Audit V1.5 (Command 06)

Read-only rerun @ `2c30412` after audits 01–05 V1.5: command bodies 01–07 **ALIGNED @ V1.5**; integrity script **PASS** (CONS-046 CLOSED); README baseline **FAIL**; INDEX **PARTIAL**; feature matrix **PARTIAL**; 2× P0 legacy claim docs remain.

| Campo | Valore |
|-------|--------|
| **Command** | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.5.md` |
| **Report** | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |
| **Truthfulness matrix** | [`MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv`](MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv) |
| **Outdated inventory** | [`MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv`](MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv) |
| **Command alignment** | [`MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv`](MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv) · [`MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv`](MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv) |
| **Remediation plan** | [`MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md`](MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md) |
| **Apnea alignment** | [`MASTER_APNEA_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_APNEA_DOCUMENTATION_ALIGNMENT_CURRENT.csv) · [`MASTER_APNEA_DOCS_INDEX_REPAIR_PLAN_CURRENT.md`](MASTER_APNEA_DOCS_INDEX_REPAIR_PLAN_CURRENT.md) |
| **Algorithmic gate** | [`MASTER_ALGORITHMIC_DOCUMENTATION_TRUTHFULNESS_GATE_CURRENT.md`](MASTER_ALGORITHMIC_DOCUMENTATION_TRUTHFULNESS_GATE_CURRENT.md) |
| **Post-remediation alignment** | [`MASTER_POST_REMEDIATION_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_POST_REMEDIATION_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Remediation command alignment** | [`MASTER_REMEDIATION_COMMAND_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_REMEDIATION_COMMAND_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Audit 07 alignment** | [`MASTER_07_AUDIT_COMMAND_ALIGNMENT_CURRENT.csv`](MASTER_07_AUDIT_COMMAND_ALIGNMENT_CURRENT.csv) |
| **Launch sequence** | [`commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_V1.5.md`](../commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_V1.5.md) |
| **Validate** | `./Scripts/validate_commands_for_cursor_integrity.sh` **PASS** |
| **Verdict** | **PARTIAL** · README/INDEX baseline drift · P0 claim docs · Apnea audit outputs under-indexed |
```

---

## 3. Master command table version fixes (P1)

| Row | Current INDEX | Planned |
|-----|---------------|---------|
| Orchestrator | V1.3 | **V1.5** |
| Command 01 | V2.1/V2.2 | **V1.5** |
| Command 02 | V1.1/V1.2 | **V1.5** |
| Command 03 | V2.2/V2.3 | **V1.5** |
| Command 04 | V1.1/V1.2 | **V1.5** |
| Command 05 | V1.1/V1.2 | **V1.5** |
| Command 06 | V1.1/V1.2 | **V1.5** |
| Command 07 | V1.0 | **V1.5** — audit-only verification |
| Command 10/11 | Command 10 filename | **Command 11** `11-MASTER_2026_06_30...` |

---

## 4. Orchestrator V1.5 block additions (P1)

Add to orchestrator block:

- [`MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv`](MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv)
- [`MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv`](MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv)
- [`MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md`](MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md)
- [`MASTER_ALGORITHMIC_DOCUMENTATION_TRUTHFULNESS_GATE_CURRENT.md`](MASTER_ALGORITHMIC_DOCUMENTATION_TRUTHFULNESS_GATE_CURRENT.md)
- [`MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv`](MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv)
- [`MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv)
- Apnea audit outputs (see `MASTER_APNEA_DOCS_INDEX_REPAIR_PLAN_CURRENT.md`)

---

## 5. Missing INDEX links (P2)

| Topic | Planned link |
|-------|--------------|
| Project overview | `Docs/README.md` ✓ (exists) |
| Safety philosophy | `SAFETY_DISCLAIMER.md` ✓ |
| Apnea first-class audits | **MISSING** — add block |
| Superseded commands | **PARTIAL** — link `commands_for_cursor/OOLD/` |
| Physical QA pending | **PARTIAL** — centralize `MASTER_*_PHYSICAL_*` matrices |
| Command 06 V1.5 outputs | **MISSING** — add block §2 |

See also `MASTER_APNEA_DOCS_INDEX_REPAIR_PLAN_CURRENT.md` for Apnea-specific INDEX repairs.
