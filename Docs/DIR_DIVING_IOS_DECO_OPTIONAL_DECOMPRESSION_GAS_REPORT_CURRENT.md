# DIR Diving iOS — Deco Optional Decompression Gas Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Deco planner gas UI and active input projection only

---

## 1. Executive summary

Deco planner now labels the first cylinder **Back Gas**, offers an optional **Decompression Gas** toggle, and projects active planning input so disabled decompression gas is excluded from validation, calculation, and export while remaining stored in draft state.

---

## 2. Product decision

| Element | Behavior |
|---------|----------|
| Former “Bombola 1” / “Cylinder 1” | **Back Gas** (always visible in Deco) |
| Former “Bombola 2” / “Cylinder 2” | **Gas Decompressivo** / **Decompression Gas** (optional) |
| Toggle OFF | Active plan uses Back Gas only |
| Toggle ON | Back Gas + one Decompression Gas in active input |

---

## 3. Previous behavior

- Deco showed generic numbered cylinder headers (`BOMBOLA 1`, `CYLINDER 1`, etc.).
- `projectDecoInput` always included bottom + first deco cylinder.
- Stale deco gas in `plannerCylinders` was always validated and calculated.
- “Add deco gas” button appended a deco cylinder manually.

---

## 4. Persistence / state

- Added `GasPlanInput.isDecoGasEnabled: Bool?` (nil/false = off).
- Computed `decoGasPlanningEnabled` returns `isDecoGasEnabled ?? false`.
- **Default:** off for new and legacy saved inputs (missing key decodes as nil).
- Draft deco gas/cylinders are **not deleted** when toggled off; they are excluded from active projection only.
- `ensureDefaultDecoGasIfNeeded()` restores deco cylinder from existing `decoGas1` default when toggle is turned on.

---

## 5. Active input projection

`PlannerModePolicy.projectDecoInput(_:)`:

- Always includes exactly one `.bottom` cylinder.
- Includes one `.deco` cylinder only when `decoGasPlanningEnabled == true`.
- `validateDecoDraft` now validates active projected gases (not stale draft deco).

Calculation, MOD validation, PDF export (`PlannerPDFBuilder` already uses `activePlanInput`), and `PlannerStore` planning outputs use projected input.

---

## 6. UI changes

**Deco cylinders card:**

1. Back Gas editor (custom section title).
2. Toggle: *Usa gas decompressivo / Use decompression gas*.
3. When ON: description + Decompression Gas editor.
4. When OFF: note *La pianificazione userà solo il Back Gas.*

**Technical / Base / CCR:** unchanged numbered cylinder labels and behavior.

`PlannerCylinderGasEditorView` accepts optional `sectionTitle` for Deco role-based labels.

---

## 7. Localization (EN/IT)

- `planner.deco.back_gas.title`
- `planner.deco.decompression_gas.title`
- `planner.deco.decompression_gas.toggle`
- `planner.deco.decompression_gas.description`
- `planner.deco.decompression_gas.off_note`

---

## 8. Files modified

| File | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | `isDecoGasEnabled`, `decoGasPlanningEnabled`, `ensureDefaultDecoGasIfNeeded()` |
| `iOSApp/Utils/PlannerModePolicy.swift` | `projectDecoInput`, `validateDecoDraft` |
| `iOSApp/Views/PlannerView.swift` | Deco toggle, labels, visibility |
| `iOSApp/Views/PlannerCylinderGasEditorView.swift` | Optional `sectionTitle` |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Deco gas keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Deco gas keys |
| `Tests/iOSAlgorithmTests/PlannerDecoGasToggleTests.swift` | **New** |
| `Tests/iOSAlgorithmTests/PlannerSwitchDepthMODClampTests.swift` | Enable deco gas in projection clamp test |

---

## 9. Tests

**`PlannerDecoGasToggleTests`** (8 tests): projection OFF/ON, MOD validation OFF/ON, UI static guards, mode isolation, persistence decode, default deco gas helper.

---

## 10. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerDecoGasToggleTests" test
# ** TEST SUCCEEDED ** (8 tests, 0 failures)
```

**Simulator:** `Iphone 15 Pro` (substituted for `iPhone 15 Pro`).

---

## 11. Manual QA checklist

### Deco OFF
- [ ] Back Gas visible; toggle OFF
- [ ] Decompression Gas section hidden
- [ ] Plan uses Back Gas only; no stale deco in results/PDF

### Deco ON
- [ ] Decompression Gas section visible
- [ ] Invalid deco MOD still warns/blocks
- [ ] Valid two-gas plan works

### Regression
- [ ] Base / Technical / CCR unchanged

---

## 12. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| Bühlmann / decompression / GF / MOD / CNS / OTU unchanged | ✓ |
| Base / Technical / CCR unchanged | ✓ |
| Watch / sync unchanged | ✓ |
| No features removed | ✓ |

---

## Remaining blockers

Manual QA not executed in this session.
