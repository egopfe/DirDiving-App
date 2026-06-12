# DIR DIVING iOS — Pre-Dive Checklist Operational Tasks

## Overview

The iOS Checklist tab is now titled **Pre-Dive Checklist** / **Checklist pre-immersione**. It supports structured preparation beyond equipment-only rows:

| Kind | Purpose |
|------|---------|
| `equipment` | Physical gear |
| `gas` | Gas analysis, pressure, MOD/PPO2 checks |
| `task` | Operational pre-dive activities |
| `safety` | Safety-critical procedures |
| `document` | Permits, insurance, paperwork |
| `custom` | User-defined items |

## Examples

- Analyze gas / Analizzare il gas
- Verify MOD / PPO2
- Check cylinder pressure
- Confirm Rock Bottom
- Confirm plan with team
- Send briefing to Watch
- Bubble check, valve drill, backup computer check

## Model changes

`EquipmentChecklistItem` adds:

- `kind: ChecklistItemKind` (default `.equipment` for legacy data)
- `isRequired: Bool` (default `true`)
- `completedAt: Date?`
- `note: String`

Legacy JSON without new fields decodes safely.

## UI

- Grouped sections by kind (Equipment, Gas, Tasks, Safety, Documents, Custom)
- Required / optional badges
- Completion timestamp when checked
- Optional note per item
- Manual add with kind + required toggle
- Quick-add menu for common operational tasks
- Hero badge prioritizes **Required X/Y**

## Templates

REC, TEC, and CCR default templates include operational gas, task, and safety items. Existing equipment entries are preserved.

## PDF export

Checklist PDF groups items by kind and includes required/optional status, completion state, timestamp, note, and gas details when linked.

## Out of scope

- No Bühlmann, CCR, Ratio Deco, gas planning, Rock Bottom, or planner math changes
- No Watch live dive changes
- Planner-linked auto-suggestions deferred (user adds tasks manually or via quick presets)

## Limitations

- Checklist completion is a user record, not proof of safety
- Task items without `usesGas` do not satisfy DIR gas-configuration evaluator requirements
