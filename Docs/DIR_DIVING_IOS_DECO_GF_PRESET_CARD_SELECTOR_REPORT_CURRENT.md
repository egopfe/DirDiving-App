# DIR Diving iOS — Deco GF Preset Card Selector Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Deco planner GF preset UI — two-line vertical cards only

---

## 1. Executive summary

Replaced the compact segmented GF preset control in Deco mode with three vertical selectable cards. Each card shows the preset name on the first line and **GF XX/YY** on the second line, derived from `PlannerGFPreset` at runtime. Numeric preset values and all planner algorithms are unchanged.

---

## 2. Product issue

Compact segmented labels (e.g. `Std. GF 30/80`) were hard to read and did not clearly separate preset name from GF values.

---

## 3. Product decision

- Show each Deco GF preset as a **two-line selectable card** (name + GF pair).
- Keep the dynamic explanatory note below the selector.
- Add accessibility labels with preset name and GF values.
- Leave Base, Technical, and CCR GF behavior unchanged.

---

## 4. Actual implemented GF values (confirmed, unchanged)

| Preset | GF Low | GF High | Display |
|--------|--------|---------|---------|
| Conservative | 20 | 70 | GF 20/70 |
| Standard | 30 | 80 | GF 30/80 |
| Aggressive | 40 | 85 | GF 40/85 |

UI labels are built from `displayPair` (`"\(Int(gfLow))/\(Int(gfHigh))"`), not hard-coded strings.

---

## 5. Previous implementation

- Segmented `Picker` with `localizedCompactTitleWithValues` (e.g. `Cons. GF 20/70`).
- Explanatory note below picker (retained).

---

## 6. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | `localizedGFValueLine`, `accessibilityLabel` on `PlannerGFPreset` |
| `iOSApp/Views/PlannerView.swift` | Vertical `gfPresetOptionCard` selector replaces segmented picker |
| `iOSApp/Resources/en.lproj/Localizable.strings` | `planner.gf.preset.accessibility_format` |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `planner.gf.preset.accessibility_format` |
| `Tests/iOSAlgorithmTests/PlannerGFPresetDisplayTests.swift` | Card UI guards, display derivation, a11y tests |

**Not modified:** GF numeric values, Bühlmann/decompression, gas planning, CNS/OTU, MOD, Watch, sync, persistence.

---

## 7. UI changes

**Card layout** (per preset):

```
Conservative          ✓
GF 20/70
```

- Selected: cyan border, subtle cyan fill, checkmark.
- Unselected: `DIRTheme.surface2` fill, hairline border.
- Same `gfPresetBinding` → `PlannerModePolicy.applyGFPreset` path.

**Explanatory note** (unchanged key, dynamic `displayPair`):

- EN: *Lower GF values are more conservative… Current preset: GF 30/80.*
- IT: *GF più bassi sono più conservativi… Preset attuale: GF 30/80.*

---

## 8. Localization changes

| Key | Purpose |
|-----|---------|
| `planner.gf.preset.accessibility_format` | VoiceOver: `%@, Gradient Factor %@` |

Existing `planner.gf.preset.explanation_format` retained. Compact format keys retained on enum (legacy helper, not used in Deco UI).

---

## 9. Accessibility changes

- Each card: `preset.accessibilityLabel` → e.g. *Conservative, Gradient Factor 20/70*.
- Selected card: `.accessibilityAddTraits(.isSelected)`.
- Card group: `.accessibilityElement(children: .contain)`.

---

## 10. Tests added/updated

**`PlannerGFPresetDisplayTests`** (11 tests):

1. GF values unchanged (20/70, 30/80, 40/85)
2. `displayPair` derives from `gfLow`/`gfHigh`
3. `localizedGFValueLine` uses `displayPair`
4. Accessibility label includes name + pair
5. Static: `gfPresetOptionCard`, two-line labels, no segmented picker in `gfPresetRow`
6. Localization keys (explanation + accessibility)
7. Deco/Technical/CCR presentation + `applyGFPreset` unchanged

---

## 11. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerGFPresetDisplayTests" test
# ** TEST SUCCEEDED ** (11 tests, 0 failures)
```

**Simulator:** `Iphone 15 Pro` (substituted for requested `iPhone 15 Pro`).  
**iPhone 14 Pro:** not available locally.

---

## 12. Manual QA checklist

### Deco
- [ ] Three vertical GF preset cards visible
- [ ] Each shows name + GF XX/YY (20/70, 30/80, 40/85)
- [ ] Selection checkmark and note update
- [ ] Plan calculation unchanged

### Base / Technical / CCR
- [ ] Base: no GF preset cards
- [ ] Technical/CCR: manual GF controls unchanged

### Regression
- [ ] Six tabs, Settings, Watch unchanged

---

## 13. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| GF preset numeric values unchanged | ✓ |
| Bühlmann / decompression / tissue math unchanged | ✓ |
| Gas planning / CNS / OTU / MOD unchanged | ✓ |
| Base / Technical / CCR unchanged | ✓ |
| Watch / sync / persistence unchanged | ✓ |
| No features removed; readiness preserved | ✓ |

---

## Remaining blockers

Manual QA (§12) not executed in this session.
