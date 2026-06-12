# DIR Diving iOS — Structured Equipment Profile Upgrade

## Overview

The iOS **Attrezzatura / Equipment** tab is now a structured operational equipment profile. It organizes setup data into cards, supports structured cylinders and maintenance tracking, and integrates safely with the Checklist and Planner tabs without changing decompression or gas-planning algorithms.

## Architecture

### Legacy compatibility

`EquipmentProfile` keeps all legacy string fields:

- `cylinders`, `configuration`, `bottomGas`, `decoGas1`, `decoGas2`
- `sacLitersMinute`, readiness flags, `checklistItems`

New fields decode with defaults when absent from saved JSON:

- `activeSetupName`, `setupMode`
- `structuredCylinders`, `maintenanceItems`

`EquipmentProfile.init(from:)` uses `decodeIfPresent` so existing iCloud/local profiles continue to load.

### Structured models

| Type | Purpose |
|------|---------|
| `EquipmentSetupMode` | Rec OC, DIR twinset, technical OC, CCR, sidemount, custom |
| `EquipmentGasCylinder` | Name, `GasRole`, `TankSize`, `GasMix`, pressures, switch depth |
| `EquipmentMaintenanceItem` | Service/expiry tracking with optional due date |
| `ChecklistMergeStrategy` | `appendMissing` (default) or `replace` for checklist generation |

### Helpers

- `effectiveCylinders` — structured list when present, otherwise best-effort legacy derivation
- `enabledCylinders`, `activeGasSummary`, `hasStructuredSetup`
- `EquipmentStructuredSupport.syncLegacySummary` — copies structured gases into legacy strings on save (non-destructive for user text configuration)

## UI cards (Equipment tab)

1. Header + setup completeness badge (informational)
2. **Setup** — name, mode, configuration; legacy import when unstructured
3. **Cylinders** — add/edit/delete structured cylinders
4. **Gases** — per-cylinder gas labels, switch depth, MOD reference display (existing `GasMix.modMeters`)
5. **Consumption** — SAC/RMV from `sacLitersMinute`
6. **Saved setups** — existing `EquipmentTemplatesSheet`
7. **Checklist integration** — generate tasks, open Checklist tab
8. **Planner integration** — copy inputs to Planner, navigate to Planner tab
9. **Watch images & briefing** — existing `WatchPhotoTransferPanel`
10. **Maintenance** — CRUD, due/overdue badges, optional add-to-checklist
11. Reset + export toolbar action

## Checklist generation

`EquipmentChecklistGenerator` creates workflow items only:

- Equipment checks per cylinder
- Gas analyze / MOD verify / pressure verify tasks
- Safety tasks (Rock Bottom, team plan, bubble check, valve drill, CCR pre-breathe, etc.)
- Optional maintenance tasks when overdue/due soon

Duplicates are avoided via normalized title + `ChecklistItemKind` when using `appendMissing`.

## Planner prefill

`EquipmentPlannerMapper.apply(profile:to:plannerMode:)`:

- Copies SAC and `PlannerCylinderEntry` rows from enabled structured cylinders
- Calls `syncLegacyGasesFromPlannerCylinders()` on `GasPlanInput`
- Ignores CCR roles when planner mode is open-circuit
- Does **not** change GF, depth, bottom time, or run `PlannerService`

## Maintenance

Statuses: OK, due soon (30 days), overdue. User can mark complete, edit, delete. Optional button adds due items to checklist.

## PDF export

`PDFExportService.exportEquipmentSetup(profile:)` via `EquipmentSetupPDFBuilder`:

- Setup name/mode, cylinders, gases, SAC, maintenance summary, checklist count
- Reference disclaimer (not a certified service record)
- Existing checklist/plan PDF exports unchanged

## What is NOT changed

- Bühlmann engine and planner math
- Deco stop generation
- `GasPlanningService`, `ScheduleGasConsumptionService`
- Rock Bottom formulas
- CCR planner engine and setpoint math
- Ratio Deco
- MOD/PPO2/CNS/OTU calculation paths (display-only MOD reference uses existing helpers)
- Watch live dive runtime
- Experimental Buddy/Apnea/Snorkeling/Exploration targets

## Known limitations

- Planner prefill copies inputs only; user must still acknowledge safety and run planner as before
- Checklist tasks are operational workflow records, not certified verification
- Maintenance tracking does not replace manufacturer/service-center records
- Legacy-derived cylinders are display/import helpers until user saves structured data
