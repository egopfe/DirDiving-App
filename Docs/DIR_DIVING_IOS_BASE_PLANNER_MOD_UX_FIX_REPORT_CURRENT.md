# DIR DIVING iOS — Base Planner MOD UX Fix Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Base-mode UI/UX and validation-message remediation only.

---

## 1. Executive summary

BASE planner no longer presents MOD/PPO₂ as user-configurable parameters or asks the user to “modify MOD”. Gas/depth safety validation is unchanged and still blocks unsafe combinations with recreational-friendly copy.

---

## 2. Bug description

In BASE mode, users saw MOD validation titles, PPO₂ max rows, MOD rows, and “fix MOD” messaging — appropriate for Deco/Technical but confusing for simplified recreational planning.

---

## 3. Root cause

- `liveMODIssues` ran for all open-circuit modes including `.base`.
- `plannerMODInputWarnings` used generic MOD copy for every mode.
- `PlannerCylinderGasEditorView` always showed PPO₂ max, MOD row, and MOD status card.
- Safety check was correct; presentation treated Base like technical MOD planning.

---

## 4. Files modified

| File | Change |
|------|--------|
| `iOSApp/Views/PlannerView.swift` | Mode-branched warnings; Base gas/depth copy; block-calculate message |
| `iOSApp/Views/PlannerCylinderGasEditorView.swift` | Hide PPO₂/MOD UI in Base |
| `iOSApp/Services/PDF/PlannerPDFBuilder.swift` | Base PDF detail format |
| `iOSApp/Resources/en.lproj/Localizable.strings` | `planner.base.gas_depth.*` |
| `iOSApp/Resources/it.lproj/Localizable.strings` | `planner.base.gas_depth.*` |
| `Tests/iOSAlgorithmTests/PlannerBaseMODUXTests.swift` | Regression guardrails |

---

## 5. PlannerView changes

- `.base` → `baseGasDepthCompatibilityWarning` (no MOD wording).
- `.deco`/`.technical` → `genericMODInputWarnings` (unchanged semantics).
- `.ccr` → no open-circuit MOD card.
- `modBlockCalculateMessage` uses Base-specific blocking copy.
- `PlanResultView.modValidationSection` branches like input warnings.

---

## 6. PlannerCylinderGasEditorView changes

- `showsAdvancedMODControls = plannerMode != .base`
- PPO₂ max row, MOD row, `modStatusCard` hidden in Base.
- Deco/Technical/CCR unchanged.

---

## 7. Localization

| Key | EN | IT |
|-----|----|----|
| `planner.base.gas_depth.title` | Gas not compatible with planned depth | Gas non compatibile con la profondità |
| `planner.base.gas_depth.message` | Oxygen limit before max depth | Limite ossigeno prima della profondità |
| `planner.base.gas_depth.hint` | Reduce depth / O₂ / choose Air | Riduci profondità / O₂ / Aria |
| `planner.base.gas_depth.detail_format` | %@ at %@ exceeds derived limit %@ | %@ a %@ supera limite derivato %@ |
| `planner.base.gas_depth.block_calculate` | Resolve gas/depth compatibility… | Risolvi incompatibilità gas/profondità… |

Existing `planner.mod.*` keys retained for Deco/Technical.

---

## 8. Tests

`PlannerBaseMODUXTests` (6 tests): static UI branching, localization, Base unsafe gas still blocked, Air/EAN only, Deco MOD copy preserved.

---

## 9. Build / test

See delivery output.

---

## 10. Manual QA checklist

- [ ] Base: no PPO₂/MOD rows in gas editor
- [ ] Base: no “modify MOD” language
- [ ] Base EAN50 @ 40 m: gas/depth warning, calculate blocked
- [ ] Base Air @ 30 m: no warning
- [ ] Deco/Technical: MOD UI unchanged

---

## 11. Confirmations

- Bühlmann / decompression / gas planning math: **not changed**
- MOD formula / `GasMixValidator`: **not changed**
- Safety validation blocking: **preserved**
- Watch files: **not changed**
- UI/UX readiness: **preserved**
