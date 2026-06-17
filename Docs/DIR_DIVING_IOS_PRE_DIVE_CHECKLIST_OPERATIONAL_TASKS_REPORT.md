# DIR DIVING iOS — Pre-Dive Checklist Operational Tasks — Report

## Branch / commit

| Item | Value |
|------|-------|
| Branch | `main` |
| Starting commit | `e72c142` |
| Report | uncommitted working tree |

## Files modified

- `iOSApp/Models/EquipmentProfile.swift`
- `iOSApp/Services/EquipmentStore.swift`
- `iOSApp/Views/ChecklistView.swift`
- `iOSApp/Services/PDF/ChecklistPDFBuilder.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/ChecklistItemKindTests.swift` (new)
- `Tests/iOSAlgorithmTests/IOSEquipmentChecklistTabSplitTests.swift`
- `Tests/iOSAlgorithmTests/PDFExportServiceTests.swift`
- `project.yml`

## Files added

- `iOSApp/Utils/ChecklistItemSupport.swift`
- `Docs/DIR_DIVING_IOS_PRE_DIVE_CHECKLIST_OPERATIONAL_TASKS.md`

## Model fields added

`EquipmentChecklistItem`:

| Field | Default (legacy) |
|-------|------------------|
| `kind: ChecklistItemKind` | `.equipment` |
| `isRequired: Bool` | `true` |
| `completedAt: Date?` | `nil` |
| `note: String` | `""` |

`EquipmentProfile` computed: `requiredChecklistItems`, `requiredReadyCount`, `optionalReadyCount`, `isRequiredChecklistComplete`.

## Backward compatibility

Custom `init(from:)` decodes missing fields with safe defaults. Existing `EquipmentChecklistItem(title:)` initializer unchanged for call sites.

## Templates updated

REC, TEC, CCR default templates retain equipment entries and add localized gas/task/safety operational items (analyze gas, pressures, MOD, Rock Bottom, team plan, Watch briefing, CCR pre-breathe, etc.).

## UI sections

Grouped `DIRCard` sections by kind: Equipment, Gas, Tasks, Safety, Documents, Custom.

Hero badge: **Required X/Y** (+ optional secondary badge).

## Quick actions

Menu with 9 localized presets (analyze gas, MOD, pressure, Rock Bottom, team plan, Watch briefing, bubble check, valve drill, backup computer).

## PDF changes

- Grouped by `ChecklistItemKind`
- Required/optional, completed state, timestamp, note, gas details

## Planner-linked suggestions

Not implemented (deferred — manual/quick-add only).

## Tests

| Suite | Result |
|-------|--------|
| `ChecklistItemKindTests` (10) | Passed |
| `IOSEquipmentChecklistTabSplitTests` | Passed |
| `DIRChecklistConfigurationEvaluatorTests` | Passed |
| `ChecklistPlannerSyncMapperTests` | Passed |
| `PDFExportServiceTests` | Passed |

## Build

`DIRDiving iOS` — **BUILD SUCCEEDED**

## Algorithm confirmation

- Bühlmann unchanged
- CCR unchanged
- Ratio Deco unchanged
- GasPlanningService unchanged
- ScheduleGasConsumptionService unchanged
- Rock Bottom unchanged
- PlannerModePolicy unchanged
- Runtime unchanged
- Tappe Decompressione unchanged
- Watch live dive unchanged
- No experimental files touched
- No certified-planner claims introduced

## Limitations / next steps

- Planner-linked task suggestions (future)
- Checklist completion is user-recorded only, not safety certification
- Saved user templates from before this change keep legacy items as `.equipment` until edited
