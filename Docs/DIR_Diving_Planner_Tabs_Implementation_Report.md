# DIR DIVING — Planner Three-Tab Implementation Report

**Date:** 2026-06-06  
**Branch:** `main`  
**Scope:** iOS Companion MAIN (`DIRDiving iOS`) only  
**Plan:** [`DIR_Diving_Planner_Tabs_Implementation_Plan.md`](DIR_Diving_Planner_Tabs_Implementation_Plan.md)

---

## Summary

Implemented functional **Base / Deco / Technical** planner modes on iOS. Tabs now control visible inputs, active gas projection, validation, calculation input, and result presentation. One shared `BuhlmannEngine` + `PlannerService`; modes differ by **exposure policy**, not separate algorithms.

**Reference-only / non-certified** wording preserved and reinforced (`planner.reference_only.warning`).

---

## Modes implemented

| Mode | IT tab | Active gases | GF UI | Result tabs |
|------|--------|--------------|-------|-------------|
| **Base** | Base | Bottom only (Air/EAN) | Hidden (standard preset applied internally) | Plan only |
| **Deco** | Deco | Bottom + max 1 deco | GF presets (Conservative / Standard / Aggressive) | Plan + simplified Bühlmann |
| **Technical** | Tecnico | Full multigas (travel, deco×n, bailout) | Manual GF Low/High | Plan + Bühlmann curve + Charts |

Legacy persisted modes decode as: `Ricreativa`→Base, `Avanzata`→Deco, `Tecnica`/`Cave/Wreck`→Technical.

---

## Input matrix

| Field | Base | Deco | Technical |
|-------|------|------|-----------|
| Max depth | ✅ | ✅ | ✅ |
| Avg depth / planning reference | ❌ | ❌ | ✅ |
| Bottom time | ✅ | ✅ | ✅ |
| Temperature | ✅ | ✅ | ✅ |
| Altitude / salinity / environment | ❌ | ❌ | ✅ |
| Single bottom gas (Air/EAN) | ✅ | ✅ | ✅ |
| Trimix bottom | ❌ | ❌ | ✅ |
| Deco gas | ❌ | max 1 | multiple |
| Travel / bailout | ❌ | ❌ | ✅ |
| SAC / emergency SAC | ❌ | ✅ | ✅ |
| Repetitive planning | ❌ | ❌ | ✅ |
| Team preview | ❌ | ❌ | ✅ |

---

## Output matrix

| Section | Base | Deco | Technical |
|---------|------|------|-----------|
| Summary metrics (TTR, OTU, CNS, …) | Simplified + base compatibility card | Full summary grid | Full summary grid |
| Ascent / deco table | Hidden (guidance if deco required) | Simplified table | Full table + surface row |
| Gas ledger | ❌ | ✅ | ✅ |
| Contingencies / team match | ❌ | ❌ | ✅ |
| Bühlmann NDL curve chart | ❌ | ❌ (summary tab) | ✅ |
| Segment timeline / GF compare | ❌ | Timeline only | ✅ |

---

## Validation matrix

| Rule | Base | Deco | Technical |
|------|------|------|-----------|
| Trimix blocked | ✅ | ✅ | ❌ |
| Multiple deco in draft | Ignored (projection uses first) | Ignored | Allowed |
| Hidden technical gases in draft | Allowed (not deleted) | Allowed | N/A |
| Profile exceeds Base (deco required) | Warning guidance | N/A | N/A |
| Full MOD/PPO2 / environment | On active input | On active input | Full |

---

## Mode switching data policy

- Full `GasPlanInput` draft **preserved** in `PlannerStore` / iCloud state.
- `PlannerModePolicy.activePlanInput(from:mode:)` projects active cylinders per mode.
- Switching Technical → Base → Technical **does not delete** travel/deco/bailout cards.
- Calculate uses **projected** input only.

---

## Bühlmann display rules

| Mode | Presentation |
|------|----------------|
| Base | Hidden; message if profile needs deco → switch to Deco/Technical |
| Deco | Simplified summary (TTS, stop count, NDL) — not full compartment curve |
| Technical | Full NDL reference chart (existing Swift Charts) + disclaimers |

**Note:** True ZHL-16C tissue loading % vs time curve still requires algorithm output extension (see [`DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md`](DIR_DIVING_IOS_PLANNER_DECO_TABLE_BUHLMANN_CURVE_AUDIT_CURRENT.md)).

---

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | `PlannerMode` → base/deco/technical + legacy decode |
| `iOSApp/Utils/PlannerModePolicy.swift` | **New** — projection, validation, presentation policy |
| `iOSApp/Utils/PlannerInputValidator.swift` | Mode-aware field validation |
| `iOSApp/Services/PlannerService.swift` | Mode parameter, active input, mode guidance |
| `iOSApp/Services/PlannerStore.swift` | Default Base, pass mode to calculate |
| `iOSApp/Models/DivePlan.swift` | `plannerMode`, `modeGuidanceMessage` |
| `iOSApp/Views/PlannerView.swift` | Mode picker, conditional UI, mode-aware results |
| `iOSApp/Views/PlannerGasMixCard.swift` | `allowedMixKinds` |
| `iOSApp/Resources/en.lproj/Localizable.strings` | Mode + warning keys |
| `iOSApp/Resources/it.lproj/Localizable.strings` | Mode + warning keys |
| `Tests/iOSAlgorithmTests/PlannerModePolicyTests.swift` | **New** — 10 tests |
| `project.yml` | Test target includes `PlannerModePolicy.swift` |

**Not touched:** Watch runtime, experimental iOS views, Bühlmann engine math.

---

## Tests added

`PlannerModePolicyTests` — projection, mode switch preservation, trimix rejection (Base), presentation flags, localization keys.

---

## Build / test results

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
# BUILD SUCCEEDED

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
# TEST SUCCEEDED

xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
# BUILD SUCCEEDED
```

---

## Remaining limitations

1. Default `GasPlanInput` bottom gas is still Trimix — **Base mode** requires user to select Air/EAN (validation blocks calculate until then).
2. Deco mode **GRAFICI** tab hidden; segment timeline shown under Bühlmann tab context only via Plan tab sections where applicable.
3. Tissue loading compartment curve (reference screenshot) **not implemented** — requires engine time-series export, not UI-only work.
4. Export share text does not yet prefix mode name (future polish).

---

## Safety confirmation

- No certified dive-computer claims added.
- Reference-only disclaimers retained and visible on planner input screen.
- Bühlmann chart remains labeled reference NDL curve (Technical), not certified decompression authority.
