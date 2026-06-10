# DIR Diving iOS — Base EAN22 False Gas/Depth Fix Report

**Date:** 2026-06-10  
**Branch:** `main`  
**Scope:** iOS Companion Planner — Base mode only

---

## 1. Executive summary

Base mode falsely blocked EAN22 at 18 m with *“Impossibile calcolare il piano”* / *“Risolvi l'incompatibilità gas/profondità…”* even though PPO₂ ≈ 0.62 and derived MOD (PPO₂ 1.4) ≈ 53.6 m.

**Root cause:** The calculate button validated **raw** `store.input` (including stale deco/travel/bailout cylinders from prior Deco/Technical sessions) via `PlannerGasSchedule.hasMODBlockingIssues(input: store.input)`, while live UI warnings and `canCalculatePlan` correctly used **mode-projected** active Base input with a single bottom cylinder.

**Fix:** Hardened `projectBaseInput(_:)` to sanitize exactly one bottom/back-gas cylinder; aligned the calculate error path with `liveMODIssues` (active projected input); scoped `hasMODBlockingIssues` Base-only projection so Deco/Technical behavior is unchanged.

---

## 2. Exact bug

| Field | Value |
|-------|-------|
| Mode | `.base` |
| Planned depth | 18 m |
| Bottom gas | EAN22 |
| Expected | No gas/depth compatibility issue; plan may calculate |
| Actual | Gas/depth incompatibility warning and/or calculate blocked |

---

## 3. Mathematical sanity check

At 18 m (sea-level salt water):

- **PPO₂** ≈ 0.22 × (1 + 18/10) ≈ **0.62 bar** — well below 1.4 bar
- **MOD at PPO₂ 1.4** ≈ ((1.4 / 0.22) − 1) × 10 ≈ **53.6 m**
- **MOD at PPO₂ 1.0** ≈ **35.4 m**

18 m ≪ 53.6 m → gas/depth block is mathematically false for EAN22 bottom gas.

---

## 4. Root cause (code inspection)

### Diagnosis for failing scenario

When a user switches from Deco/Technical to Base, `store.input.plannerCylinders` often retains **stale extra cylinders** (deco O₂/EAN50, travel, bailout) with switch depths that fail MOD validation.

| Check | Raw `store.input` | Active Base projected input |
|-------|-------------------|----------------------------|
| Cylinder count | Often 3+ (bottom + stale deco/travel/bailout) | **1** (bottom only) |
| MOD validation scope | All cylinders + legacy deco gases | Bottom gas at `plannedDepthMeters` only |
| PPO₂ max used for EAN22 | May be stale (e.g. 1.0 on hidden deco) | Normalized to **1.4** |

### Where the false positive originated

1. **`PlannerView.calculateButton`** (primary bug path)  
   Called `PlannerGasSchedule.hasMODBlockingIssues(input: store.input)` on **raw** input.

2. **`PlannerGasSchedule.hasMODBlockingIssues`**  
   - Ran `PlannerInputValidator.validate(input)` defaulting to `.technical` mode on raw input.  
   - Validated **all** `plannerCylinders`, including stale deco at switch depths (e.g. O₂ at 6 m, EAN50 at 21 m).  
   - Ran `BuhlmannPlanner.enginePlan` on raw multi-cylinder input.

3. **`PlannerView.liveMODIssues` / `canCalculatePlan`** (already correct)  
   Used `PlannerModePolicy.activePlanInput(from: store.input, mode: store.mode)` → single bottom cylinder → **no issue for EAN22 @ 18 m**.

This mismatch allowed:
- UI to show no warning (`liveMODIssues` empty) but calculate to fail on press, **or**
- In edge cases, stale cylinders to surface in validation depending on sync state.

Typical stale issue example: **deco O₂** or **EAN50** at switch depth 21 m (MOD ~18 m at PPO₂ 1.6) reported in `MODValidationIssue.gasLabel` while UI showed EAN22 bottom gas.

---

## 5. Files modified

| File | Change |
|------|--------|
| `iOSApp/Utils/PlannerModePolicy.swift` | Hardened `projectBaseInput(_:)` — single bottom cylinder, explicit `bottomGas`, helium = 0, `maxPPO2 = 1.4`, trimix/oxygen → air |
| `iOSApp/Services/PlannerGasSchedule.swift` | `hasMODBlockingIssues` uses active Base projection; Deco/Technical path unchanged |
| `iOSApp/Views/PlannerView.swift` | Calculate button uses `liveMODIssues` (active projected input) instead of raw `hasMODBlockingIssues` |
| `Tests/iOSAlgorithmTests/PlannerBaseGasDepthCompatibilityTests.swift` | EAN22 @ 18 m, stale cylinders, calculate-gate, projection guards |
| `Tests/iOSAlgorithmTests/PlannerBaseMODUXTests.swift` | Static guards for active input usage and Base PPO₂ policy |

**Not modified:** MOD formula, `GasMixValidator.modMeters`, Bühlmann/deco/tissue/CNS/OTU/SAC math, Deco/Technical/CCR planner logic, Watch files, persistence semantics.

---

## 6. Base projection fix

`projectBaseInput(_:)` now:

1. Ensures legacy cylinders exist, then selects the bottom cylinder (or creates from `bottomGas`).
2. Normalizes role to `.bottom`, mix to Air/EAN only (trimix/oxygen → air).
3. Sets `helium = 0`, `maxPPO2 = baseBottomGasMaxPPO2` (1.4), normalizes mix.
4. Sets `projected.plannerCylinders = [bottomEntry]` and `projected.bottomGas = bottomEntry.gas`.
5. Does **not** call `syncLegacyGasesFromPlannerCylinders()` internally (final sync remains in `activePlanInput`).

**Acceptance:** `activePlanInput(from: input, mode: .base)` → `plannerCylinders.count == 1`, role `.bottom`, Air/EAN only, no stale deco/travel/bailout in active validation path.

---

## 7. Base validation path fix

| Path | Before | After |
|------|--------|-------|
| `liveMODIssues` | Active projected input ✓ | Unchanged ✓ |
| `canCalculatePlan` | `liveMODIssues.isEmpty` ✓ | Unchanged ✓ |
| Calculate button MOD gate | Raw `store.input` ✗ | `liveMODIssues` (active) ✓ |
| `hasMODBlockingIssues` (Base callers) | Raw input ✗ | Active Base projection ✓ |
| `hasMODBlockingIssues` (Deco/Technical) | Raw input | Unchanged (raw input) ✓ |

---

## 8. Tests added

`PlannerBaseGasDepthCompatibilityTests`:

1. `testBaseEAN22At18MetersDoesNotRaiseGasDepthIssue`
2. `testBaseStaleExtraCylindersDoNotAffectValidation` — bottom EAN22 + stale deco/travel/bailout
3. `testBaseEAN50At40MUsesPPO2OnePointFourDerivedMOD` — still fails, MOD ≈ 18 m
4. `testBaseEAN22At18MetersDoesNotBlockMODGate` — `hasMODBlockingIssues(mode: .base)` passes
5. `testBaseProjectionSetsSingleBottomCylinderWithNormalizedPPO2`
6. Existing Deco/Technical preservation tests retained

`PlannerBaseMODUXTests`:

- `testPlannerViewLiveMODIssuesUsesActiveProjectedInput`
- `testPlannerModePolicyDefinesBaseBottomGasMaxPPO2`

---

## 9. Build / test results

```bash
xcodebuild -list
# Schemes: DIRDiving iOS, DIRDiving iOS Algorithm Tests, …

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' test
# ** TEST SUCCEEDED ** (23 targeted tests including Base gas/depth + Buhlmann MOD regression)

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build
# ** BUILD SUCCEEDED **
```

**Simulator note:** Requested `iPhone 15 Pro` → used available device **`Iphone 15 Pro`** (same hardware class).

---

## 10. Manual QA checklist

### Base — positive (EAN22 @ 18 m)

- [ ] Planner → Base
- [ ] Select EAN22, depth 18 m
- [ ] No gas/depth compatibility warning
- [ ] Calculate enabled (with safety ack)
- [ ] No *“Impossibile calcolare il piano / risolvi incompatibilità gas/profondità”*
- [ ] Gas editor: no Helium, Role, PPO₂ max, MOD rows

### Base — negative (EAN50 @ 40 m)

- [ ] Gas/depth warning appears
- [ ] Calculate blocked
- [ ] Copy references automatic derived maximum depth (not “modify MOD”)

### Regression

- [ ] Deco MOD behavior unchanged
- [ ] Technical MOD/Helium/Role unchanged
- [ ] CCR unchanged
- [ ] Six tabs, Settings, Watch unchanged

---

## 11. Safety / scope confirmations

| Constraint | Status |
|------------|--------|
| MOD formula unchanged | ✓ |
| `GasMixValidator.modMeters` unchanged | ✓ |
| Bühlmann / decompression / tissue / gas consumption / CNS / OTU / SAC math unchanged | ✓ |
| Deco / Technical / CCR planner behavior unchanged | ✓ |
| Safety validation not weakened | ✓ |
| EAN50 @ 40 m remains blocked in Base | ✓ |
| EAN22 @ 18 m no longer falsely fails | ✓ |
| Watch app files not changed | ✓ |
| Sync / persistence semantics unchanged | ✓ |
| No features removed; UI/UX readiness preserved | ✓ |

---

## Remaining blockers

None for this fix. Manual QA items in §10 should be executed on simulator/device before release gate sign-off.
