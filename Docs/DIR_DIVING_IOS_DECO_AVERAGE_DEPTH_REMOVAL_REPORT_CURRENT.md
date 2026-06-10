# DIR Diving iOS — Deco Average Depth Removal Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Deco planner UI and active input projection for average depth policy

---

## 1. Executive summary

Average Depth is removed from the Deco planner profile UI. Active Deco input now projects `plannedAverageDepthMeters = plannedDepthMeters` and `planningDepthReference = .maximumDepth`, so gas consumption uses maximum planned depth conservatively without changing decompression algorithms or gas consumption formulas.

---

## 2. Product decision

| Mode | Average Depth UI | Gas consumption depth reference |
|------|------------------|--------------------------------|
| Base | Hidden (unchanged) | Unchanged |
| Deco | **Removed** | Max planned depth (conservative) |
| Technical | Visible/editable (unchanged) | User average depth (unchanged) |
| CCR | Unchanged (`CCRPlannerView` retains its own avg depth field) | Unchanged |

---

## 3. Audit result — where Average Depth was used

| Category | Usage | Affected by Deco change? |
|----------|-------|--------------------------|
| **UI input** | `PlannerView` profile card for non-base modes | Yes — Deco hidden via `showsAverageDepthInput` |
| **Gas consumption** | `GasPlanInput.effectivePlanningDepthMeters` → `GasPlanningService` | Yes — Deco projection sets avg = max |
| **PDF/export/briefing** | `PlannerPDFBuilder`, `BriefingPDFBuilder` | Yes — hidden for Deco; active input in PDF context |
| **Decompression/Bühlmann** | `GasPlanInput.buhlmannPlanningDepthMeters` → always `plannedDepthMeters` | **No change needed** |
| **Validation** | `PlannerInputValidator` avg depth checks | Yes — gated by `showsAverageDepthInput` |
| **Persistence** | `plannedAverageDepthMeters` on draft input | Unchanged — stale draft preserved, ignored in active Deco projection |

### Safety-critical audit conclusion

**Average Depth does not enter decompression, Bühlmann, tissue loading, NDL, TTS, or ceiling math.**  
`BuhlmannPlanner` uses `buhlmannPlanningDepthMeters`, which is explicitly documented and implemented as `plannedDepthMeters` only. Static guard tests confirm decompression source files contain no `plannedAverageDepthMeters` / `averageDepthMeters` references.

Average Depth affects **gas consumption, END/density preview tiles, and planning reference display only**.

---

## 4. UI changes

- Added `PlannerResultPresentation.showsAverageDepthInput`.
- Deco profile card: max depth + conservative consumption note; no avg depth row; no planning reference picker.
- Technical: avg depth + planning reference unchanged.
- Base: unchanged (no avg depth).

---

## 5. Active input projection

In `PlannerModePolicy.projectDecoInput(_:)`:

```swift
projected.plannedAverageDepthMeters = projected.plannedDepthMeters
projected.planningDepthReference = .maximumDepth
```

Stale draft average depth values are not deleted; they are excluded from active Deco calculation, validation, PDF export, and result reference display.

---

## 6. Gas consumption behavior

- Formula unchanged: `SAC × ATA × bottom time`.
- Deco: ATA derived from max depth via projected `effectivePlanningDepthMeters`.
- Technical: user-provided average depth preserved.
- `GasPlanningService.analyze` already uses `activePlanInput` — projection applies automatically.

---

## 7. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | `showsAverageDepthInput`; Deco projection |
| `iOSApp/Utils/PlannerInputValidator.swift` | Avg depth validation gated by presentation |
| `iOSApp/Views/PlannerView.swift` | UI policy; Deco note; result reference uses active input |
| `iOSApp/Views/ShareSheetView.swift` | PDF context uses active input |
| `iOSApp/Services/PDF/PlannerPDFBuilder.swift` | Hide avg depth for Deco |
| `iOSApp/Services/PDF/BriefingPDFBuilder.swift` | Hide avg depth for Deco |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Conservative depth note |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Conservative depth note |
| `Tests/iOSAlgorithmTests/PlannerAverageDepthPolicyTests.swift` | **New** |

---

## 8. Tests

**`PlannerAverageDepthPolicyTests`** (8 tests): presentation policy, Deco/Technical projection, conservative consumption, decompression static guard, UI policy guard.

**`PlanningDepthReferenceTests`**: regression — all pass.

---

## 9. Build / test results

```bash
xcodegen generate                                    → OK
xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlannerAverageDepthPolicyTests" \
  -only-testing:"DIRDiving iOS Algorithm Tests/PlanningDepthReferenceTests" test
# ** TEST SUCCEEDED ** (13 tests, 0 failures)
```

**Simulator:** `Iphone 15 Pro` (substituted for `iPhone 15 Pro`).

---

## 10. Manual QA checklist

### Deco
- [ ] No Average Depth field
- [ ] Conservative depth note visible
- [ ] Gas consumption/ledger still works
- [ ] Decompression plan unchanged
- [ ] PDF shows no avg depth

### Technical
- [ ] Average Depth still editable
- [ ] Gas consumption responds to avg depth

### Regression
- [ ] Base unchanged; Deco gas toggle unchanged; Watch unchanged

---

## 11. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| Bühlmann / decompression / GF / MOD / CNS / OTU / SAC formula unchanged | ✓ |
| Gas consumption formula unchanged | ✓ |
| Technical avg depth preserved | ✓ |
| Base/Deco avg depth hidden | ✓ |
| Watch / sync unchanged | ✓ |

---

## Remaining blockers

Manual QA not executed in this session.
