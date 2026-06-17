# CCR / Equipment Checklist ↔ Planner Sync — DIR DIVING iOS MAIN

**Last updated:** 2026-06-14 (`main` @ `99ea74a`)  
**Code:** `iOSApp/Utils/ChecklistPlannerSyncMapper.swift`

## Purpose

Equipment checklist gas rows can be imported into OC Planner cylinders and CCR planner diluent/bailout slots (and exported back) without manual re-entry. This reduces transcription errors during dive planning.

## OC Planner sync

| Direction | Behavior |
|-----------|----------|
| Checklist → Planner | Gas items with `usesGas` mapped to `PlannerCylinderEntry`; duplicate detection by tank size, role, O₂/He, pressure unit |
| Planner → Checklist | Selected cylinders exported as checklist gas items |
| Duplicates | User chooses **replace** (default) or **skip** per candidate |

Roles are inferred from checklist metadata where possible; unassigned roles require user selection before import.

## CCR planner sync

| Direction | Behavior |
|-----------|----------|
| Checklist → CCR | `CCRChecklistImportCandidate` matches diluent and bailout cylinders; switch depths reconciled on import (MAIN-DCA-015) |
| CCR → Checklist | `CCRChecklistExportCandidate` exports selected diluent/bailout configuration |

**Switch-depth reconcile:** When importing bailout gas from checklist, switch depths are clamped/reconciled against active CCR setpoint profile so MOD and switch semantics stay consistent.

## Fingerprinting

`ChecklistPlannerGasFingerprint` deduplicates by:

- Tank size
- Gas role (when assigned)
- Oxygen and helium percentages
- Pressure unit

## Safety notes

- Sync copies **gas metadata** only — it does not validate manufacturer CCR procedures.
- Imported gases remain **reference planning inputs** — verify against your CCR handset and dive plan.
- See [`CCR_REBREATHER_SAFETY_DISCLAIMER.md`](CCR_REBREATHER_SAFETY_DISCLAIMER.md) and [`CCR_REBREATHER_LIMITATIONS.md`](CCR_REBREATHER_LIMITATIONS.md).

## Related UX remediation

CCR checklist import UI and localization were hardened in UI/UX remediation @ `dba1a22` — [`UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`](UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md).
