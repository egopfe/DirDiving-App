# iOS Planner MOD + switch-depth auto-clamp — remediation report

## A. Branch confirmed

`main` @ `4e44ac1` (implementation commit pending on top of freeze fix)

## B. Commit confirmed

Baseline: `4e44ac1` — `freeze bug solution`  
Implementation: uncommitted at report generation time (MOD/switch-depth auto-clamp pass)

## C. Target confirmed

- **Branch:** `main` only  
- **Target:** `DIRDiving iOS` (iOS Companion MAIN)  
- **Area:** Planner tab only  

## D. Experimental exclusions confirmed

Not modified; remain excluded from `DIRDiving iOS` in `project.yml`:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

## E. Files modified

| File | Change |
|------|--------|
| `iOSApp/Models/GasPlan.swift` | `PlannerSwitchDepthRoundingPolicy`, `usableSwitchDepthMeters`, clamp/update helpers, `GasPlanInput.normalizeSwitchDepthsToMOD` |
| `iOSApp/Views/PlannerView.swift` | Clamped switch-depth binding, gas-card `onMixChanged`, env/role hooks, stepper max at MOD |
| `iOSApp/Views/PlannerGasMixCard.swift` | Unchanged (already environment-aware MOD display + `onMixChanged`) |
| `iOSApp/Services/PlannerMODValidator.swift` | Unchanged (canonical MOD path retained) |
| `iOSApp/Utils/PlannerInputValidator.swift` | MOD backstop via `PlannerMODValidator.validatePlannerCylinders` |
| `iOSApp/Services/PlannerEnvironment.swift` | Unchanged |
| `iOSApp/Utils/PlannerModePolicy.swift` | Unchanged |
| `iOSApp/Services/PlannerStore.swift` | Store helpers for gas/PPO2/env normalization (no recursive `.onChange` on cylinders array) |
| `iOSApp/Services/PlannerService.swift` | Normalize draft before validation/plan generation |
| `Tests/iOSAlgorithmTests/PlannerSwitchDepthMODClampTests.swift` | **New** — 12 cases |

## F. Canonical MOD helper used

**`PlannerMODValidator.modMeters(oxygenFraction:maxPPO2:environment:)`** → **`GasMixValidator.modMeters(...)`** → **`IOSUnitConversions.depthMeters(forPressureBar:environment:)`**

Used consistently for:

- MOD display (`GasMixCard`, cylinder MOD line)
- `PlannerCylinderEntry.usableSwitchDepthMeters`
- `PlannerMODValidator.validatePlannerCylinders` / live warnings
- `PlannerInputValidator` backstop

No new hardcoded MOD formula introduced. Sea-level-only `GasMix.modMeters` property remains legacy; Planner safety paths use environment-aware APIs.

## G. Environment-aware behavior

- Switch-depth clamp uses `GasPlanInput.plannerEnvironment` (altitude + salinity via `PlannerEnvironment.make`).
- Altitude/salinity edits in Technical mode call `PlannerStore.clampAllSwitchDepthsToMOD()`.
- Fresh vs salt and altitude MOD differences covered by tests.

## H. Switch-depth normalization strategy

1. **`PlannerCylinderEntry.usableSwitchDepthMeters`** — `floor(MOD)` whole meters (default policy).
2. **`clampSwitchDepthToMOD`** — only lowers switch depth when above usable MOD (+0.05 m tolerance); bottom gas unchanged.
3. **`updateSwitchDepthAfterGasOrPPO2Change`** — sets non-bottom switch to usable MOD after gas/PPO2 edit.
4. **`GasPlanInput.normalizeSwitchDepthsToMOD`** — bulk or single-cylinder normalization.
5. **`PlannerService.makePlan`** — normalizes draft before validation and planning (safety net for persisted bad data).

## I. UI edit strategy and loop-prevention

- **No** `.onChange(of: plannerCylinders)` recursive rewrite.
- **Gas mix edits:** `GasMixCard.onMixChanged` → `PlannerStore.normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID:)` with `isApplyingInputSideEffects` guard.
- **Manual switch depth:** custom binding → `clampSwitchDepth(forCylinderAt:proposedMeters:)`; `+` stepper capped at usable MOD display value.
- **Environment:** `.onChange` on altitude/salinity only → `clampAllSwitchDepthsToMOD()`.
- **New cylinders:** normalized once after append.

## J. Mode-specific behavior

| Mode | Behavior |
|------|----------|
| **Base** | Only bottom gas active in projection; hidden non-bottom cylinders still clamped when edited/stored |
| **Deco** | Single active deco gas; switch auto-updates to MOD on O2/PPO2 change; hidden technical gases preserved in draft |
| **Technical** | Travel/deco/bailout all clamp; bottom unchanged; hypoxic/MOD validation independent |

## K. Tests added

`Tests/iOSAlgorithmTests/PlannerSwitchDepthMODClampTests.swift` (12 cases):

1. O2 100% / PPO2 1.6 → floored MOD switch depth  
2. Shallower switch (5 m) preserved  
3. Deeper switch clamped  
4. PPO2 change updates switch  
5. O2 fraction change (EAN50 → O2) clamps  
6. Environment-aware altitude MOD  
7. Deco mode projection  
8. Technical all non-bottom roles  
9. Repeated normalization stability  
10. Validation backstop before/after normalize  
11. Plan generation clamps unsafe persisted depth  
12. Single-cylinder bulk normalize isolation  

## L. Tests run

```text
xcodegen generate                                    PASS
xcodebuild DIRDiving iOS (simulator, unsigned)       BUILD SUCCEEDED
xcodebuild DIRDiving iOS Algorithm Tests             311 executed, 4 skipped, 0 failures
PlannerSwitchDepthMODClampTests                      12/12 PASS
```

## M. Build results

All commands above passed on macOS simulator (iPhone 17 Pro).

## N. Remaining limitations

- Usable switch depth uses **floor(MOD)** to whole meters; raw MOD for O2/PPO2 1.6 @ sea-level salt is ~5.9 m → stored switch **5 m** (not 6 m). This matches the specified rounding policy and keeps PPO2 ≤ limit at switch.
- UI normalization runs on iOS Planner only; Watch runtime untouched.
- External golden validation against third-party planners not in scope.

## O. Confirmation checklist

- [x] iOS MAIN only  
- [x] Watch runtime untouched  
- [x] Experimental branches/features untouched  
- [x] No UI redesign  
- [x] No duplicated MOD formula  
- [x] `PlannerEnvironment` respected  
- [x] User may choose shallower switch depth  
- [x] User cannot persist deeper-than-MOD switch depth  
- [x] No certified decompression planner claim introduced  
- [x] Base / Deco / Technical architecture preserved  
- [x] No recursive SwiftUI cylinder-array `.onChange` loop  

---

*Reference-only planner positioning unchanged. See `Docs/SAFETY_DISCLAIMER.md`.*
