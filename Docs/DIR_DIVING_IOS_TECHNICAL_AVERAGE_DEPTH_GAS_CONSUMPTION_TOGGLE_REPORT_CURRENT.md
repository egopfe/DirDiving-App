# DIR Diving iOS — Technical Average Depth Gas Consumption Toggle

**Date:** 2026-06-10  
**Branch:** MAIN  
**Status:** Implemented (automated validation complete; manual QA pending)

---

## 1. Executive summary

Technical planner now exposes a dedicated **Use average depth for gas consumption** toggle (default **OFF**). When OFF, gas consumption is estimated conservatively at **maximum planned depth**. When ON, gas consumption may use **average depth**; decompression remains unchanged and never reads average depth.

No Bühlmann, decompression, tissue, GF, MOD, CNS/OTU, SAC/RMV, or gas consumption formulas were modified. Changes are limited to input state, presentation policy, UI, gas-consumption depth projection, PDF/briefing copy, validation, and tests.

---

## 2. Product decision

| Rule | Implementation |
|------|----------------|
| Technical-only advanced gas refinement | Toggle visible only in Technical via `showsAverageDepthGasConsumptionToggle` |
| Default conservative | `usesAverageDepthForGasConsumption` defaults to `false` (nil decodes as false) |
| OFF → max depth for consumption | `gasConsumptionReferenceDepthMeters(for: .technical)` → `plannedDepthMeters` |
| ON → average depth for consumption | Same helper → `min(plannedAverageDepthMeters, plannedDepthMeters)` |
| Never for decompression | `buhlmannPlanningDepthMeters` always returns `plannedDepthMeters`; Bühlmann sources have no average-depth references |
| No “use average depth for deco” | No such toggle or copy; UI tests assert absence |
| Base / Deco / CCR unchanged | Presentation policy and projection preserve existing behavior |

---

## 3. Audit result — Average Depth usage

| Classification | Files / behavior | Uses avg depth? |
|----------------|------------------|-----------------|
| **1. UI input/display** | `PlannerView.swift` (Technical toggle + conditional field), `PlannerResultPresentation`, PDF/briefing result summaries | Yes (Technical only, toggle-gated) |
| **2. Gas consumption / RMV-SAC estimation** | `GasPlanningService.swift` via `gasConsumptionReferenceDepthMeters(for:)`; `GasPlanInput.effectivePlanningDepthMeters` on projected active input | Yes (Technical when toggle ON) |
| **3. PDF/export/briefing** | `PlannerPDFBuilder.swift`, `BriefingPDFBuilder.swift` | Yes (Technical toggle ON only; reference label ON/OFF) |
| **4. Decompression/Bühlmann/tissue/NDL/TTS/ceiling** | `BuhlmannPlanner.swift`, `PlannerService.swift`, `RepetitiveDivePlannerService.swift`, `PlannerAscentTableBuilder.swift`, `OxygenExposureModels.swift`, `CCRPlannerEngine.swift` | **No** — confirmed by static guard tests |
| **5. MOD/gas switch validation** | `GasPlanInput.normalizeSwitchDepthsToMOD`, `PlannerInputValidator` depth checks use max depth / `gasConsumptionReferenceDepthMeters` | **No** avg depth for MOD/switch |
| **6. Persistence** | `GasPlanInput.usesAverageDepthForGasConsumption: Bool?`; `plannedAverageDepthMeters` retained when toggle OFF | Toggle optional; avg depth value preserved |

**Safety-critical confirmation:** Average depth does **not** enter decompression, Bühlmann, tissue loading, NDL, TTS, ceiling, or stop schedule generation. Deco mode projection continues to force max depth for consumption (`projectDecoInput`).

**Unrelated avg depth (out of scope, unchanged):** LogBook/dive sessions (`avgDepthMeters`), CCR planner field, Watch sync, TTV index — not connected to Technical planner toggle.

---

## 4. UI changes

**Technical planner (`PlannerView.swift`):**

- Toggle: `planner.technical.average_depth.gas_toggle`
- Toggle **ON**: editable Average Depth field + `planner.technical.average_depth.gas_enabled_note`
- Toggle **OFF**: field hidden + `planner.technical.average_depth.gas_disabled_note`
- Removed always-visible planning depth reference picker from Technical profile card
- Result summary shows gas-consumption reference (max vs average) for Technical only

**Deco:** conservative max-depth note unchanged; no toggle; avg depth input hidden.

**Localization:** EN/IT keys added under `planner.technical.average_depth.*` and `planner.technical.gas_consumption.reference.*`.

---

## 5. Active input / gas-consumption reference

**Model (`GasPlanInput`):**

```swift
var usesAverageDepthForGasConsumption: Bool? = nil  // default false via averageDepthGasConsumptionEnabled
func gasConsumptionReferenceDepthMeters(for mode: PlannerMode) -> Double
var buhlmannPlanningDepthMeters: Double  // always plannedDepthMeters
```

**Projection (`PlannerModePolicy.projectTechnicalInput`):**

- Toggle ON → `planningDepthReference = .averageDepth` on active projected input
- Toggle OFF → `planningDepthReference = .maximumDepth`
- Deco continues `projectDecoInput` (max depth only)

**Gas planning (`GasPlanningService.analyze`):** uses `input.gasConsumptionReferenceDepthMeters(for: mode)` instead of raw average depth.

---

## 6. Persistence / backward compatibility

- New field `usesAverageDepthForGasConsumption: Bool?` — missing key decodes as `nil` → treated as **false**
- Existing `plannedAverageDepthMeters` values are **not** wiped when toggle is OFF
- Re-enabling toggle restores previously stored average depth
- No migration of saved plans required

---

## 7. Tests added / updated

**New:** `Tests/iOSAlgorithmTests/PlannerTechnicalAverageDepthGasConsumptionTests.swift`

| Test | Purpose |
|------|---------|
| `testDefaultIsConservativeOff` | Default toggle false |
| `testTechnicalOffUsesMaxDepthForGasConsumption` | OFF → reference 60 m |
| `testTechnicalOnUsesAverageDepthForGasConsumption` | ON → reference 30 m |
| `testDecompressionUnaffectedByAverageDepthGasToggle` | Identical deco/TTS; consumption differs |
| `testTechnicalUIHasGasConsumptionToggleWithoutDecoToggle` | UI strings / no deco toggle copy |
| `testBaseAndDecoDoNotExposeTechnicalGasToggle` | Mode isolation |
| `testDecompressionSourcesDoNotReferenceGasConsumptionToggle` | Static safety guard |
| `testPersistenceDecodesMissingToggleAsFalse` | Backward-compatible decode |

**Updated:**

- `PlannerAverageDepthPolicyTests.swift` — presentation + Technical projection
- `PlanningDepthReferenceTests.swift` — consumption via toggle

---

## 8. Build / test results

| Command | Result |
|---------|--------|
| `xcodegen generate` | OK |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=Iphone 15 Pro' build` | **BUILD SUCCEEDED** |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 14 Pro' build` | **Skipped** — no matching simulator on this machine |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" … PlannerTechnicalAverageDepthGasConsumptionTests` | **8/8 passed** |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" … PlannerAverageDepthPolicyTests + PlanningDepthReferenceTests` | **14/14 passed** |

**Simulator used:** `Iphone 15 Pro` (note: destination name matches local simulator spelling with lowercase “phone”).

---

## 9. Manual QA checklist

| Area | Status |
|------|--------|
| Technical toggle visible, default OFF | **Not run** (simulator manual QA pending) |
| OFF: hidden avg depth, max-depth note, deco unchanged | **Not run** |
| ON: avg depth field, gas-only note, consumption changes, deco unchanged | **Not run** |
| No “use average depth for deco” option | **Automated** (UI source test) |
| Deco: no toggle, no avg depth input, max-depth consumption | **Automated** (policy tests) |
| Base / CCR unchanged | **Not run** (manual) |
| Regression (tabs, GF, CNS, BAR/PSI, Watch) | **Not run** |

---

## 10. Confirmations

- Bühlmann math was **not** changed
- Decompression algorithms were **not** changed
- Tissue loading logic was **not** changed
- GF behavior was **not** changed
- MOD formula was **not** changed
- Gas/depth compatibility was **not** changed
- CNS/OTU logic was **not** changed
- SAC/RMV formula was **not** changed
- Gas consumption **formula** was **not** changed (depth reference only)
- Average depth affects **only** gas consumption when toggle enabled
- Average depth **never** affects deco
- No average-depth-for-deco toggle was introduced
- Base behavior was **not** changed
- Deco behavior was **not** changed
- Technical deco output is **unchanged** by toggling average-depth gas consumption (tested)
- CCR behavior was **preserved**
- Watch app files were **not** changed
- WatchConnectivity/sync logic was **not** changed
- Persistence semantics are **backward-compatible**
- UI/UX readiness was **not** reduced

---

## Remaining blockers

1. **Manual QA** on device/simulator not yet executed (Part 10).
2. **iPhone 14 Pro** build not validated — simulator unavailable locally; iPhone 15 Pro used instead.
