# DIR DIVING iOS — Base Auto MOD Policy Fix Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** Base planner UI/UX and validation-policy only.

---

## 1. Executive summary

Base mode now uses a fixed internal PPO₂ max of **1.4** for gas/depth compatibility, derives maximum depth automatically, hides Helium/Role/MOD/PPO₂ controls, and blocks incompatible plans (e.g. EAN50 @ 40 m) with recreational-friendly copy.

---

## 2. Bug / product rule

```
PPO₂ max = 1.4 (fixed internally in Base)
MOD = derived from selected gas + environment
plannedDepthMeters <= derived MOD
Role = always Bottom Gas internally
Gas = Air or EAN only; Helium hidden
```

---

## 3. Root cause

- `projectBaseInput` kept stale `gas.maxPPO2` (e.g. 1.0), causing false positives for EAN32 @ 30 m.
- Base gas editor still showed Role and Helium rows.
- Warnings did not reference PPO₂ 1.4 automatic maximum depth.

---

## 4. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | `baseBottomGasMaxPPO2`, `baseDerivedMODMeters`, `projectBaseInput` |
| `iOSApp/Views/PlannerCylinderGasEditorView.swift` | Hide Role/Helium in Base |
| `iOSApp/Resources/en.lproj/Localizable.strings` | PPO₂ 1.4 copy |
| `iOSApp/Resources/it.lproj/Localizable.strings` | PPO₂ 1.4 copy |
| `Tests/iOSAlgorithmTests/PlannerBaseGasDepthCompatibilityTests.swift` | **New** |
| `Tests/iOSAlgorithmTests/PlannerBaseMODUXTests.swift` | Updated static assertions |

---

## 5–9. Implementation details

- **Projection:** Base bottom gas forced to `.bottom` role, Air/EAN only, `maxPPO2 = 1.4`, helium = 0.
- **Validation:** `PlannerMODValidator` unchanged; uses projected gas.
- **UI:** `showsRoleRow`, `showsHeliumRow`, `showsAdvancedMODControls` gate Base fields.
- **Copy:** automatic maximum depth wording with PPO₂ 1.4.

---

## 10. Tests

`PlannerBaseGasDepthCompatibilityTests` (9 tests) + updated `PlannerBaseMODUXTests`.

---

## 11. Confirmations

- MOD formula / Bühlmann / gas planning math: **not changed**
- Deco / Technical / CCR: **not changed**
- Safety blocking: **preserved**
- Watch files: **not changed**
