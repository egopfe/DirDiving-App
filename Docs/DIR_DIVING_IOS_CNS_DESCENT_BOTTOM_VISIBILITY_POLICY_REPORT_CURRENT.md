# DIR Diving iOS — CNS Descent+Bottom Settings Card Visibility Policy

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** iOS Companion Planner UI visibility only

---

## 1. Executive summary

The configurable **CNS descent + bottom** settings card (toggle + threshold) is now hidden from the main planner input form in **Base** and **Deco** modes, while remaining visible in **Technical** and **CCR** modes. CNS/OTU calculations, result tiles, and oxygen exposure warnings are unchanged.

---

## 2. Product decision

| Planner mode | CNS descent+bottom settings card |
|--------------|----------------------------------|
| Base | Hidden |
| Deco | Hidden |
| Technical | Visible |
| CCR | Visible |

---

## 3. Rationale

- **Base** is simplified recreational/no-deco planning (Air/EAN, fixed internal PPO₂ 1.4, automatic gas/depth compatibility).
- **Deco** is guided/limited with bounded depth; the configurable CNS threshold card is advanced input noise in the main form.
- **Technical** and **CCR** are advanced planners where users expect configurable CNS descent+bottom threshold controls.
- **CNS/OTU math** and **result-level warnings** (tiles, banners, PDF metrics) remain fully active in all modes.

---

## 4. Previous behavior

`PlannerView` mounted `cnsDescentBottomWarningCard` unconditionally for all open-circuit modes (Base, Deco, Technical). CCR used a separate `CCRPlannerView` without the card. The card included:

- Toggle: enable CNS descent+bottom check
- Threshold stepper (when enabled)
- Reference-only disclaimer text

Scroll-to-card was driven by `store.scrollToCNSThresholdSettings` from plan result “edit threshold” links.

---

## 5. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | Added `showsCNSDescentBottomSettings` to `PlannerResultPresentation` |
| `iOSApp/Views/Components/PlannerCNSDescentBottomSettingsCard.swift` | **New** shared settings card component |
| `iOSApp/Views/PlannerView.swift` | Conditional card mount; scroll guard for hidden modes |
| `iOSApp/Views/CCR/CCRPlannerView.swift` | Added card + scroll-to-CNS support per CCR policy |
| `Tests/iOSAlgorithmTests/PlannerCNSDescentBottomVisibilityTests.swift` | **New** policy and static UI guards |
| `Tests/iOSAlgorithmTests/PlannerModePolicyTests.swift` | Extended Base/Deco presentation assertions |

**Not modified:** CNS/OTU algorithms, `GasPlanningService`, `OxygenExposureModels`, Bühlmann engine, MOD/gas-depth logic, Watch files, sync/persistence, Settings summary row in `MoreView`.

---

## 6. Presentation policy change

```swift
struct PlannerResultPresentation {
    let showsCNSDescentBottomSettings: Bool
    // ...
}

// .base, .deco  → false
// .technical, .ccr → true
```

This property controls **only** the configurable input card in the planner form. It does not gate calculations or result warnings.

---

## 7. PlannerView rendering guard

```swift
if modePresentation.showsCNSDescentBottomSettings {
    PlannerCNSDescentBottomSettingsCard()
        .id(PlannerCNSDescentBottomCheckSettings.scrollTargetID)
}
```

---

## 8. Scroll guard

```swift
private func scrollToCNSThresholdSettings(using scrollProxy: ScrollViewProxy) {
    guard modePresentation.showsCNSDescentBottomSettings else {
        store.acknowledgeCNSThresholdSettingsFocus()
        return
    }
    // scroll + acknowledge
}
```

Base/Deco no longer attempt to scroll to a missing card; the focus flag is cleared safely.

`CCRPlannerView` includes matching scroll handlers now that the card is present in the CCR form.

---

## 9. Result-level CNS/OTU preserved

Unchanged in `PlannerView` plan results:

- `cnsDescentBottomWarningActive`
- `cnsDescentBottomWarningBanner`
- `planner.metric.cns_descent_bottom` tile
- `fullPlanCNSWarningActive` / weekly OTU warnings
- `cnsThresholdEditLink` (Technical only reaches visible card; Base/Deco dismiss without scroll)

`CCRPlanResultView` still shows `cnsDescentBottomPercent` metric.

Settings (`MoreView.cnsDescentBottomSettingsSummary`) unchanged.

---

## 10. Tests added/updated

**`PlannerCNSDescentBottomVisibilityTests`**

1. Policy: Base/Deco false; Technical/CCR true
2. Static: `PlannerView` uses `showsCNSDescentBottomSettings` guard
3. Static: scroll guard present
4. Static: CCR planner mounts card
5. Static: result-level CNS warnings preserved (open circuit + CCR)

**`PlannerModePolicyTests`**

- Base and Deco presentation assert `showsCNSDescentBottomSettings == false`

---

## 11. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerCNSDescentBottomVisibilityTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerModePolicyTests" test
# ** TEST SUCCEEDED ** (24 tests, 0 failures)
```

**Simulator:** `Iphone 15 Pro` (substituted for requested `iPhone 15 Pro`).

---

## 12. Manual QA checklist

### Base
- [ ] CNS descent+bottom settings card not visible
- [ ] Plan calculates; gas/depth and no-deco limits unchanged
- [ ] Result CNS/OTU tiles/warnings still appear when applicable

### Deco
- [ ] Settings card not visible
- [ ] Deco fields, calculation, validation unchanged
- [ ] Result oxygen exposure display unchanged

### Technical
- [ ] Settings card visible
- [ ] Toggle/threshold unchanged
- [ ] Scroll-to-CNS from result link works

### CCR
- [ ] Settings card visible in CCR planner form
- [ ] CCR calculation unchanged
- [ ] Result CNS descent+bottom metric unchanged

### Regression
- [ ] Six tabs, Settings, language, LogBook, Checklist, Attrezzatura unchanged
- [ ] Watch unchanged

---

## 13. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| Bühlmann / decompression / tissue math unchanged | ✓ |
| MOD / gas-depth compatibility unchanged | ✓ |
| Gas planning math unchanged | ✓ |
| CNS/OTU calculations unchanged | ✓ |
| Result-level oxygen exposure warnings not removed | ✓ |
| Deco / Technical / CCR calculation behavior unchanged | ✓ |
| Watch / sync / persistence unchanged | ✓ |
| No features removed from Technical/CCR | ✓ |
| UI/UX readiness preserved | ✓ |

---

## Remaining blockers

Manual QA (§12) not executed in this session.
