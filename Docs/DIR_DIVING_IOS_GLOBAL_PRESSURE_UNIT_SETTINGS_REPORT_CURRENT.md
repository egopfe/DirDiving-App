# DIR Diving iOS — Global Pressure Unit Settings Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Move BAR/PSI selection from planner screens to global Settings (More tab)

---

## 1. Executive summary

Pressure unit is now a global iOS preference (`dirdiving_ios_pressure_unit`), configured under **More → Units** alongside depth units. Planner gas editors no longer show a local BAR/PSI segmented toggle; they display and edit working pressure using the global setting while internal bar-based calculations remain unchanged.

---

## 2. Product decision

| Before | After |
|--------|-------|
| Each planner cylinder had a local BAR/PSI toggle | Pressure unit chosen once in Settings |
| Display tied to per-cylinder `pressureUnit` | Display/input uses global preference |
| Internal values stored per entry unit | Internal storage unchanged; display converts from bar canonical via `startPressureBar` |

---

## 3. Previous behavior

- `PlannerCylinderGasEditorView` showed a segmented BAR/PSI picker above working pressure.
- Each `PlannerCylinderEntry` stored `startPressure` in its own `pressureUnit`.
- PDF export used `entry.pressureUnit.rawValue`.
- Result metrics hardcoded `"bar"` labels.

Depth units were already global via `IOSUnitPreference` in MoreView. Manual dive logbook used `PressureDisplayMath.pressureUnit(for:)` coupling imperial depth → PSI (unchanged in this task).

---

## 4. New Settings behavior

**More → Preferences → Units:**

- **Depth:** existing metric/imperial segmented control (unchanged)
- **Pressure:** new bar/PSI segmented control

Storage key: `IOSPressureUnitPreference.storageKey` (`dirdiving_ios_pressure_unit`).  
Default when missing: `.bar`.

---

## 5. Planner UI changes

- Removed BAR/PSI segmented picker from `PlannerCylinderGasEditorView`.
- Working pressure row label shows global unit (`bar` / `PSI`).
- Wheel picker values follow global unit.
- Base, Deco, Technical planners all use the shared editor (CCR has no separate pressure toggle in UI today).

---

## 6. Formatting / input conversion

- Display: `PlannerGasEditingSupport.displayWorkingPressure(_:unit:)` converts from `entry.cylinder.startPressureBar`.
- Edit: `PlannerGasEditingSupport.applyWorkingPressure(_:unit:to:)` stores in selected unit without double conversion.
- Results/PDF: `Formatters.pressure(fromBar:unit:)` for metric tiles and planner PDF.

Example: 200 bar → ~2901 PSI display; 3000 PSI input → ~206.8 bar internal.

---

## 7. Persistence / backward compatibility

- Per-cylinder `pressureUnit` on `PlannerCylinderEntry` remains in Codable model (deprecated for UI, not deleted).
- Existing saved values keep their stored numeric meaning.
- Global preference defaults to bar for legacy installs.

---

## 8. Export / PDF behavior

`PDFExportPlannerContext` now includes `pressureUnitPreference`.  
`PlannerPDFBuilder` formats working pressure via `Formatters.pressure(fromBar:unit:)`.

---

## 9. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/Formatters.swift` | `IOSPressureUnitPreference`, `Formatters.pressure` |
| `iOSApp/Utils/PlannerGasEditingSupport.swift` | Display/apply working pressure helpers |
| `iOSApp/Views/PlannerCylinderGasEditorView.swift` | Remove toggle; use global unit |
| `iOSApp/Views/PlannerView.swift` | AppStorage + result pressure labels |
| `iOSApp/Views/MoreView.swift` | Pressure unit picker in Units section |
| `iOSApp/Services/PDF/PDFExportService.swift` | Context field |
| `iOSApp/Services/PDF/PlannerPDFBuilder.swift` | Global pressure formatting |
| `iOSApp/Views/ShareSheetView.swift` | Pass pressure preference to PDF context |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Settings + notice keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Settings + notice keys |
| `Tests/iOSAlgorithmTests/PlannerPressureUnitPreferenceTests.swift` | **New** |
| Test files using `PDFExportPlannerContext` | Added `pressureUnitPreference: .bar` |

---

## 10. Tests

**`PlannerPressureUnitPreferenceTests`** (9 tests): default, persistence, display/input conversion, static UI guards.

---

## 11. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerPressureUnitPreferenceTests" test
# ** TEST SUCCEEDED ** (9/9)
```

**Simulator:** `Iphone 15 Pro` (substituted for `iPhone 15 Pro`).

Note: Some pre-existing PDF checklist tests in `PDFExportServiceTests` fail unrelated to this change (localization/PDF text matching).

---

## 12. Manual QA checklist

### Settings
- [ ] Depth selector unchanged
- [ ] Pressure bar/PSI selector persists

### Planners (Base/Deco/Technical)
- [ ] No local BAR/PSI toggle
- [ ] Pressure fields follow global unit
- [ ] Calculate still works

### Regression
- [ ] Algorithms unchanged
- [ ] Watch unchanged

---

## 13. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| Gas/deco/Bühlmann/MOD/CNS/OTU/SAC unchanged | ✓ |
| Base/Deco/Technical/CCR business logic unchanged | ✓ |
| Watch / sync unchanged | ✓ |
| BAR and PSI both supported | ✓ |
| No planner-local BAR/PSI toggle | ✓ |

---

## Remaining blockers

Manual QA not executed. Pre-existing PDF checklist test failures remain outside this scope.
