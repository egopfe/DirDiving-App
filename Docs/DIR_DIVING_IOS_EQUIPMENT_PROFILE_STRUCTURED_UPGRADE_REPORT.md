# DIR Diving iOS Equipment Profile Structured Upgrade — Report

## Git context

| Item | Value |
|------|-------|
| Branch | `main` |
| Starting commit | `330aaa0` |
| Build | **SUCCEEDED** (`DIRDiving iOS`, generic iOS Simulator) |

## Files modified

- `iOSApp/Models/EquipmentProfile.swift`
- `iOSApp/Services/EquipmentStore.swift`
- `iOSApp/Views/EquipmentView.swift`
- `iOSApp/Services/PDF/PDFExportService.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `project.yml`

## New files

- `iOSApp/Models/EquipmentStructuredModels.swift`
- `iOSApp/Utils/EquipmentStructuredSupport.swift`
- `iOSApp/Utils/EquipmentPlannerMapper.swift`
- `iOSApp/Utils/EquipmentChecklistGenerator.swift`
- `iOSApp/Services/PDF/EquipmentSetupPDFBuilder.swift`
- `Tests/iOSAlgorithmTests/EquipmentProfileStructuredModelTests.swift`
- `Tests/iOSAlgorithmTests/EquipmentStoreStructuredSetupTests.swift`
- `Tests/iOSAlgorithmTests/EquipmentPlannerMapperTests.swift`
- `Tests/iOSAlgorithmTests/EquipmentChecklistGeneratorTests.swift`
- `Tests/iOSAlgorithmTests/EquipmentMaintenanceTests.swift`
- `Tests/iOSAlgorithmTests/PDFExportServiceEquipmentTests.swift`
- `Docs/DIR_DIVING_IOS_EQUIPMENT_PROFILE_STRUCTURED_UPGRADE.md`

## Models added

- `EquipmentSetupMode`, `EquipmentGasCylinder`, `EquipmentMaintenanceItem`, `EquipmentMaintenanceKind`, `EquipmentMaintenanceStatus`
- `ChecklistMergeStrategy`, `EquipmentPlannerApplyResult`
- `EquipmentProfile` fields: `activeSetupName`, `setupMode`, `structuredCylinders`, `maintenanceItems`

## Legacy compatibility

- Custom `EquipmentProfile` decoder/encoder with `decodeIfPresent` defaults
- Legacy string fields preserved and still editable
- `effectiveCylinders` falls back to legacy gas strings when structured list is empty
- `syncLegacySummary` updates legacy gas/cylinder summary when structured cylinders are saved

## UI

Equipment tab reorganized into cards: Setup, Cylinders, Gases, Consumption, Saved setups, Checklist link, Planner link, Watch assets, Maintenance, Reset. Toolbar PDF export added.

## Integrations

| Feature | Behavior |
|---------|----------|
| Planner prefill | Maps cylinders/gases/SAC to `GasPlanInput`, navigates to Planner |
| Checklist generation | Appends gas/equipment/safety tasks; dedupes on append |
| Maintenance | CRUD + overdue/due-soon status + optional checklist add |
| PDF | `exportEquipmentSetup` — reference equipment sheet |

## Tests added

- `EquipmentProfileStructuredModelTests` (6)
- `EquipmentStoreStructuredSetupTests` (4)
- `EquipmentPlannerMapperTests` (4)
- `EquipmentChecklistGeneratorTests` (3)
- `EquipmentMaintenanceTests` (4)
- `PDFExportServiceEquipmentTests` (3)

## Tests run (passed)

Targeted + regression batch (**60 tests, 0 failures**):

- All new Equipment/* tests
- `ChecklistPlannerSyncMapperTests`
- `DIRChecklistConfigurationEvaluatorTests`
- `GasPlanningServiceTests`
- `ScheduleGasConsumptionServiceTests`
- `RatioDecoPlannerTests`

Full iOS Algorithm Tests suite: **4 pre-existing failures** unrelated to this change (`CCRMathRemediationTests`, `CloudSessionMergeTests`, `IOSI18nRemediationTests`, `MainDeepCodeRemediationDCATests`).

## Algorithm safety confirmation

- Bühlmann unchanged
- DecoStop generation unchanged
- `PlannerService` math unchanged
- `GasPlanningService` math unchanged
- `ScheduleGasConsumptionService` math unchanged
- Rock Bottom unchanged
- CCR engine unchanged
- Ratio Deco unchanged
- MOD/PPO2/CNS/OTU calculations unchanged (equipment UI uses existing `GasMix.modMeters` for display only)
- Watch live dive unchanged
- No experimental target files touched
- No certified-planner/safety claims introduced

## Remaining limitations / next steps

- Save current structured setup as named template (beyond checklist templates) — not implemented; saved setups sheet remains checklist-template focused
- Full test suite has unrelated failing tests; consider triaging separately
- CCR equipment → CCR planner prefill works only when planner mode is `.ccr`
