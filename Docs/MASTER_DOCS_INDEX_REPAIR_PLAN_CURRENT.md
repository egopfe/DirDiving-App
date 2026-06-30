# Master Docs Index Repair Plan — Current

**Audit:** Command 06 — Documentation / Repository Alignment **V1.2**  
**Target:** `Docs/INDEX.md` (primary index; `Docs/README.md` secondary)  
**Baseline:** `main` @ `451f8fb`  
**Date:** 2026-06-30

Do **not** edit INDEX in this audit pass. Below are exact planned additions and fixes.

---

## 1. Header refresh (P1)

Replace top header:

```markdown
**Aggiornato:** 2026-06-30  
**Branch consigliato:** `main` = `origin/main` @ `451f8fb`
```

---

## 2. Command 06 V1.2 INDEX block (P1 — add after orchestrator block)

```markdown
## Aggiornamento indice 2026-06-30 — Documentation / Repository Alignment Audit V1.2 (Command 06)

Post-remediation read-only rerun @ `451f8fb`: command bodies 01–07 **ALIGNED**; integrity script **FAIL** (CONS-046); README baseline **FAIL**; feature matrix **PARTIAL**.

| Campo | Valore |
|-------|--------|
| **Command** | `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.2.md` |
| **Report** | [`MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md`](MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md) |
| **Truthfulness matrix** | [`MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv`](MASTER_DOCUMENTATION_TRUTHFULNESS_MATRIX_CURRENT.csv) |
| **Outdated inventory** | [`MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv`](MASTER_OUTDATED_DOCUMENT_INVENTORY_CURRENT.csv) |
| **Command alignment** | [`MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv`](MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv) · [`MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv`](MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv) |
| **Remediation plan** | [`MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md`](MASTER_DOCUMENTATION_REMEDIATION_PLAN_CURRENT.md) |
| **Post-remediation alignment** | [`MASTER_POST_REMEDIATION_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_POST_REMEDIATION_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Remediation command alignment** | [`MASTER_REMEDIATION_COMMAND_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_REMEDIATION_COMMAND_DOCUMENTATION_ALIGNMENT_CURRENT.csv) |
| **Audit 07 alignment** | [`MASTER_07_AUDIT_COMMAND_ALIGNMENT_CURRENT.csv`](MASTER_07_AUDIT_COMMAND_ALIGNMENT_CURRENT.csv) |
| **Verdict** | **PARTIAL** · README/INDEX baseline drift · P0 claim docs remain |
```

---

## 3. Master command table version fixes (P1)

| Row | Current INDEX | Planned |
|-----|---------------|---------|
| Command 01 | V2.1 | **V2.2** |
| Command 02 | V1.1 | **V1.2** |
| Command 03 | V2.2 | **V2.3** |
| Command 04 | V1.1 | **V1.2** |
| Command 05 | V1.1 | **V1.2** |
| Command 06 | V1.1 | **V1.2** |
| Command 07 | (partial) | **V1.0** — audit-only verification |
| Command 10 | referenced | Restore file or **archive banner** |

---

## 4. Orchestrator V1.3 block additions (P1)

Add to existing orchestrator block:

- [`MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv`](MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv)
- [`MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv`](MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv)
- [`MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md`](MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md)
- [`MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv`](MASTER_LATEST_WATCH_DEVELOPMENT_DOC_ALIGNMENT_CURRENT.csv)
- [`MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv`](MASTER_ENTITLEMENT_DOCUMENTATION_ALIGNMENT_CURRENT.csv)
- [`commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-30.md`](../commands_for_cursor/00-DIR_DIVING_MASTER_AUDIT_LAUNCH_SEQUENCE_UPDATED_2026-06-30.md)

---

## 5. Snorkeling consolidated block (P2)

Add subsection linking:

- [`SNORKELING_ARCHITECTURE.md`](SNORKELING_ARCHITECTURE.md)
- [`SNORKELING_IOS_WATCH_ARCHITECTURE.md`](SNORKELING_IOS_WATCH_ARCHITECTURE.md)
- [`SNORKELING_IOS_WATCH_ROADMAP_P1_P2_P3.md`](SNORKELING_IOS_WATCH_ROADMAP_P1_P2_P3.md)
- [`SNORKELING_RELEASE_CHECKLIST.md`](SNORKELING_RELEASE_CHECKLIST.md)
- [`AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md`](AUDIT_SNORKELING_IOS_MAPS_SYNC_EXPORT_CURRENT.md)
- Verdict: **INTERNAL_READY** · **PHYSICAL_QA_PENDING**

---

## 6. Missing links checklist

| Topic | Planned INDEX location | Status |
|-------|------------------------|--------|
| Project overview | Docs/README.md | **PASS** |
| Safety philosophy | SAFETY_DISCLAIMER | **PASS** |
| Settings mode switch | IOS_COMPANION_SETTINGS_MODE_SWITCH | **MISSING** |
| Activity settings ownership | ACTIVITY_SETTINGS_OWNERSHIP_MATRIX | **PARTIAL** |
| Logbook ownership | DIR_DIVING_LOGBOOK_OWNERSHIP matrix | **PARTIAL** |
| Briefing cards | PLANNER_BRIEFING_CARD_KIND_MATRIX | **MISSING** |
| Ratio Deco | RATIO_DECO_COMPARATIVE_HEURISTIC | **MISSING** |
| Physical QA pending hub | MASTER_UI_UX_EXTERNAL_PHYSICAL_QA_PENDING | **PARTIAL** |
| Superseded V3.0 commands | Archive banner under audit commands | **MISSING** |
| Launch sequence 2026-06-30 | commands_for_cursor helper | **MISSING** |

---

## 7. Superseded index entries (P1)

Add banner on any remaining `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED_V3.0.md` references:

> **Superseded by** `06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.2.md`
