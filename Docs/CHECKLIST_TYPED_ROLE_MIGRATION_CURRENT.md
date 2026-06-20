# Checklist Typed Role Migration — CURRENT

## Policy

Gas roles on checklist items are **typed metadata** (`EquipmentChecklistItem.gasRole`). Title inference is **migration-only** via `ChecklistRoleMigration.legacyInferRole(from:)`.

## Runtime resolution

```text
ChecklistPlannerSyncMapper.resolvedRole(for:)
  └── ChecklistRoleMigration.resolvedRole → item.gasRole only
```

## Migration

On `EquipmentStore` load:

- `ChecklistRoleMigration.migrateLegacyRoles(in:)` persists inferred roles once for legacy rows.

## Templates

Default equipment templates now set `gasRole` for OC back gas, deco stage, regulator, and CCR diluent/bailout rows.

## Tests

- `ChecklistTypedRoleMigrationTests`
- `ChecklistPlannerSyncMapperTests` (legacy infer vs typed resolve)
- `BuhlmannComprehensiveReadinessCCRRemediationTests`
