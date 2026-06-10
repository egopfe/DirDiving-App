# DIR Diving iOS — Deco GF Preset Transparency Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Deco planner GF preset UI labels and explanatory copy only

---

## 1. Executive summary

Deco planner GF preset segments now show each preset name together with its GF pair (e.g. **Cons. GF 20/70**), and a dynamic note below the picker explains conservatism vs aggressiveness and the current preset values. Numeric preset values and all planner algorithms are unchanged.

---

## 2. Product issue

In Deco mode, the segmented GF preset control showed only **Conservative**, **Standard**, and **Aggressive** without visible GF values, so users could not immediately see which GF pair each preset applies.

---

## 3. Product decision

- Show **preset label + GF pair** in the Deco segmented picker (compact labels for layout).
- Add a **short explanatory note** below the picker that updates with the selected preset.
- Leave **Base**, **Technical**, and **CCR** GF behavior unchanged.

---

## 4. Existing GF values confirmed (unchanged)

| Preset | GF Low | GF High | Display pair |
|--------|--------|---------|--------------|
| Conservative | 20 | 70 | 20/70 |
| Standard | 30 | 80 | 30/80 |
| Aggressive | 40 | 85 | 40/85 |

`applyGFPreset`, `matchingGFPreset`, and Bühlmann/decompression engine paths are unchanged.

---

## 5. Previous implementation

- `PlannerGFPreset` defined numeric `gfLow` / `gfHigh` and `localizedTitle` only.
- `PlannerView.gfPresetRow` used `Text(preset.localizedTitle).tag(preset)` in a segmented picker.
- Shown only when `modePresentation.showsGFPresets` (Deco mode).
- Technical and CCR use `showsManualGFControls`; Base hides both presets and manual GF.

---

## 6. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | Display-only helpers on `PlannerGFPreset` |
| `iOSApp/Views/PlannerView.swift` | Compact value labels + explanation note in `gfPresetRow` |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Compact format + explanation keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Compact format + explanation keys |
| `Tests/iOSAlgorithmTests/PlannerGFPresetDisplayTests.swift` | **New** regression tests |

**Not modified:** Bühlmann engine, decompression, gas planning, CNS/OTU, MOD, Watch, sync, persistence.

---

## 7. UI changes

**Segmented picker labels** (compact for three-segment layout):

- Cons. GF 20/70 / Std. GF 30/80 / Aggr. GF 40/85

**Explanatory note** (updates on selection):

- EN: *Lower GF values are more conservative; higher GF values are more aggressive. Current preset: GF 30/80.*
- IT: *GF più bassi sono più conservativi; GF più alti sono più aggressivi. Preset attuale: GF 30/80.*

Optional info tooltip was **not** added to avoid clutter; the note is sufficient.

---

## 8. Localization changes

| Key | Purpose |
|-----|---------|
| `planner.gf.preset.conservative.compact_format` | Segmented label |
| `planner.gf.preset.standard.compact_format` | Segmented label |
| `planner.gf.preset.aggressive.compact_format` | Segmented label |
| `planner.gf.preset.explanation_format` | Dynamic note below picker |

EN/IT parity maintained; `%@` receives `displayPair` (e.g. `30/80`).

---

## 9. Tests added

**`PlannerGFPresetDisplayTests`** (9 tests):

1. Conservative / Standard / Aggressive numeric values unchanged
2. `displayPair` correct for each preset
3. `localizedTitleWithValues` and `localizedCompactTitleWithValues` include pair
4. Static guard: `PlannerView` uses value labels + explanation key
5. Localization keys exist in EN/IT
6. Deco `showsGFPresets`; Base/Technical/CCR presentation unchanged
7. `applyGFPreset` / `matchingGFPreset` semantics unchanged

---

## 10. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerGFPresetDisplayTests" test
# ** TEST SUCCEEDED ** (9 tests, 0 failures)
```

**Simulators:** `Iphone 15 Pro` (substituted for requested `iPhone 15 Pro`).  
**iPhone 14 Pro:** not available in local `simctl` list; layout clipping not machine-verified on smaller device.

---

## 11. Manual QA checklist

### Deco
- [ ] Segmented labels show GF values (Cons./Std./Aggr. GF XX/YY)
- [ ] Explanation note updates when preset changes
- [ ] Plan calculation unchanged
- [ ] EN/IT copy correct if language switched

### Base / Technical / CCR
- [ ] Base: no GF preset selector
- [ ] Technical: manual GF controls unchanged
- [ ] CCR: manual GF controls unchanged

### Regression
- [ ] Six tabs, Settings, Watch unchanged

---

## 12. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| GF preset numeric values unchanged | ✓ |
| Bühlmann / decompression / tissue math unchanged | ✓ |
| Gas planning / CNS / OTU / MOD unchanged | ✓ |
| Base / Technical / CCR behavior unchanged | ✓ |
| Watch / sync / persistence unchanged | ✓ |
| No features removed; readiness preserved | ✓ |

---

## Remaining blockers

Manual QA (§11) not executed in this session. iPhone 14 Pro layout check skipped (simulator unavailable).
