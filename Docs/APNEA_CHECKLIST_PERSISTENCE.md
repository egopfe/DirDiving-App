# Apnea Checklist Persistence

## Model

`ApneaCompanionSettings` schema v2 adds:

```swift
var preApneaChecklist: [ApneaChecklistItem]
```

Default: `ApneaChecklistCatalog.defaultItems()` (7 items, all unchecked).

Backward-compatible `init(from:)` decodes legacy settings without checklist and migrates to defaults.

## Store

`IOSApneaSettingsStore`:

- `setChecklistItem(id:isChecked:)` — immediate persist
- `resetChecklist()` — restores catalog defaults (unchecked)
- `isChecklistComplete`, `buddyChecklistConfirmed`, checklist counts
- `resetToDefaults()` resets checklist with other settings

## UI

- **Settings:** `IOSApneaChecklistView` reads/writes store; operational reminder card; reset with confirmation
- **Planner:** compact checklist section with completion count
- **Dashboard:** readiness card shows `X/7` count

Checklist state is **not** written to logbook as safety certification.
