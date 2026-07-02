# DIRDiving iOS Equipment Gas UI/UX Remediation

**Date:** 2026-07-02  
**Branch:** `main`

---

## Problem summary

In the Diving Equipment / Pre-Dive Checklist area, every checklist row exposed a generic **“GAS”** toggle (`equipment.checklist.gas_flag`). Users could toggle gas linkage on unrelated items (mask, fins, wetsuit, computer, torch, reel, accessories), which is semantically confusing. Gas mixes and cylinders should be managed separately from generic equipment.

---

## Root cause

- `ChecklistView` and `EquipmentTemplateEditorView` rendered `Toggle("GAS", isOn: binding.usesGas)` on **every** checklist item row.
- `EquipmentChecklistGasSection` was always present in the row hierarchy (hidden when `usesGas == false`, but the toggle allowed accidental conversion).
- UI grouping used `item.kind` only, so cylinder-linked equipment (`kind: .equipment`, `usesGas: true`) appeared under **Equipment** instead of **Gas & Cylinders**.

---

## UX decision

1. **Remove** the generic GAS toggle from all item editors.
2. **Choose type at creation time:**
   - “Add equipment item” → `usesGas: false`, user-selected `kind`
   - “Add gas / cylinder item” → `usesGas: true`, `kind: .equipment`
3. **Show gas-specific fields** only when `usesGas == true`, labeled “Gas / cylinder item”.
4. **Group display** by `EquipmentItemPresentationPolicy.sectionKind`: equipment rows with `usesGas == true` appear under **Gas & Cylinders**.
5. **Keep `usesGas` in the model** for backward-compatible persistence and planner sync — no schema migration.

---

## Files changed

- `iOSApp/Utils/EquipmentItemPresentationPolicy.swift` (new)
- `iOSApp/Utils/ChecklistItemSupport.swift`
- `iOSApp/Views/ChecklistView.swift`
- `iOSApp/Views/EquipmentTemplateEditorView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/EquipmentItemPresentationPolicyTests.swift` (new)
- `project.yml`
- `Docs/INDEX.md`

---

## Data compatibility

- `usesGas` property retained on `EquipmentChecklistItem`; decoding unchanged.
- Existing `usesGas == true` items → Gas & Cylinders section + gas editor.
- Existing `usesGas == false` items → Equipment (or task/safety/etc. by `kind`) section, no gas editor.
- No destructive migration; no name-based heuristics.

---

## Confirmations

| Item | Status |
|------|--------|
| Generic equipment no longer shows GAS toggle | **YES** |
| Gas/cylinder items managed separately | **YES** |
| No planner / decompression / CCR algorithm changes | **YES** |
| No Bühlmann / GF / CNS / MOD / OTU changes | **YES** |
| No gas consumption / tissue model changes | **YES** |
| No Watch runtime changes | **YES** |
| Planner numerical outputs unchanged | **YES** |

---

## Tests executed

| Suite | Result |
|-------|--------|
| `EquipmentItemPresentationPolicyTests` | **9/9 PASS** |
| `ChecklistItemKindTests` | **10/10 PASS** |
| iOS app build (`DIRDiving iOS`) | **PASS** |

---

## Tests not executed

- Full iOS suite (1655 tests) — run if CI/local time permits; not required for this UI-only scope.
- SwiftUI snapshot / UI automation — not available in unit test target.

---

## Manual UI QA checklist (PENDING)

- [ ] Open Pre-Dive Checklist; expand Mask / Fins / Computer rows — **no GAS toggle**
- [ ] Back gas / Deco stage / CCR cylinders appear under **Gas & Cylinders**
- [ ] Gas cylinder rows show mix/pressure/role fields; generic equipment rows do not
- [ ] “Add equipment item” creates item without gas fields
- [ ] “Add gas / cylinder item” creates item with gas editor visible
- [ ] Template editor: same behavior; sections grouped correctly
- [ ] IT/EN localization for new strings
- [ ] Existing saved profiles/templates load without data loss

---

## Software readiness preservation

Presentation / localization / checklist UX remediation only. Equipment persistence and planner sync mappers unchanged. No regression to decompression, CCR, or Watch algorithms.
