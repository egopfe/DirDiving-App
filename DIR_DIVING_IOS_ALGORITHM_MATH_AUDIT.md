# DIR DIVING iOS Companion MAIN Algorithm and Mathematical Logic Audit

Audit date: 2026-05-27  
Repository: `egopfe/DirDiving-App`  
Branch audited: `main`  
Scope: iOS Companion MAIN app only  
Mode: audit/report only; no application code changes

## Executive Summary

The iOS Companion MAIN branch includes a premium dark UI and a substantial set of planning/logbook/sync/export features, but the algorithmic layer is not yet release-hard for technical dive planning.

The strongest parts are:

- basic gas consumption formulas exist and are readable
- MOD and PPO2 calculations exist
- gas density, END, EAD, CNS, and OTU reference calculations exist
- Subsurface-style CSV import/export exists
- WatchConnectivity payloads are HMAC signed
- planner UI includes safety acknowledgement and non-certified wording
- experimental iOS files are excluded from the main iOS target by `project.yml`

The main algorithmic risks are:

- the planner generates actionable-looking technical outputs from simplified/reference math
- Buhlmann is N2-only and does not model helium compartments, even though trimix is a first-class gas in the MAIN planner
- generated decompression stops are static schedule logic, not propagated Buhlmann ceilings
- invalid programmatic planner inputs can still calculate because validation is UI-oriented and normalization silently clamps values
- stop PPO2 can be hidden by `boundedPPO2`, which reports a capped value rather than actual PPO2
- iOS imported/logged average depth is arithmetic, not time-weighted
- manual dive TTV uses multiplication instead of the Watch MAIN formula
- sync/import/merge/export validation is much weaker on iOS than on the Watch MAIN hardening path
- route math does not validate GPS coordinates before Haversine/bearing calculations
- there is no iOS XCTest target in `project.yml`

Overall readiness:

- Gas planning formulas: **partial**
- Buhlmann/no-decompression logic: **simplified reference only; not full ZHL-16C**
- Trimix planning: **not mathematically validated**
- Import/export integrity: **partial**
- Sync payload validation: **partial**
- Unit conversion system: **duplicated and not centralized**
- iOS algorithm test coverage: **missing**

The app's legal/safety copy correctly states that DIR DIVING is not a certified dive computer. However, the mathematical output is technical enough that the planner should either be hardened with typed validation/unavailable states or explicitly blocked from producing actionable-looking plans for unsupported modes such as trimix/decompression.

## Branch and Target Confirmation

Current branch during audit:

- `main`
- local and `origin/main` were aligned before this report

Relevant `project.yml` state:

- iOS target: `DIRDiving iOS`
- iOS bundle ID: `com.egopfe.dirdiving.ios`
- excluded from iOS MAIN target:
  - `iOSApp/Models/ExplorationModels.swift`
  - `iOSApp/Models/BuddyExperimentalModels.swift`
  - `iOSApp/Services/ExplorationPlanningStore.swift`
  - `iOSApp/Services/BuddyExperimentalStore.swift`
  - `iOSApp/Views/ExplorationCenterView.swift`
  - `iOSApp/Views/ExperimentalFutureConceptsView.swift`
  - `iOSApp/Views/BuddyExperimentalView.swift`
- only test target currently present: `DIRDiving Watch Algorithm Tests`
- no iOS algorithm test target found

## Files Inspected

Primary iOS algorithm/model/service files:

- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/DiveSample.swift`
- `iOSApp/Models/DiveSession.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/GPSPoint.swift`
- `iOSApp/Models/TankSize.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/RouteSummaryService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Services/WatchSyncAuth.swift`
- `iOSApp/Utils/DiveSessionMerge.swift`
- `iOSApp/Utils/Formatters.swift`
- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift`

Relevant iOS views inspected for algorithm entry points and safety framing:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/ManualDiveEditorView.swift`
- `iOSApp/Views/DiveDetailView.swift`
- `iOSApp/Views/AnalysisView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/IOSLegalOnboardingView.swift`

Project/test files:

- `project.yml`
- `Tests/WatchAlgorithmTests/DiveAlgorithmTests.swift` as evidence that only Watch algorithm tests exist

Documents checked for safety positioning:

- `Docs/iOS/SAFETY_DISCLAIMER.md`
- `Docs/SAFETY_DISCLAIMER.md`
- `Docs/GLOSSARY.md`
- `Docs/iOS/MOCKUP_COHERENCE.md`

## Algorithms Found

### Planner Orchestration

Found in:

- `PlannerStore`
- `PlannerService`
- `PlannerView`

Flow:

1. `PlannerStore.input` stores `GasPlanInput`.
2. `PlannerStore.applyInputToPlanningOutputs()` normalizes planner gases.
3. `BuhlmannPlanner.plan()` computes a simplified NDL preview.
4. `PlannerService.makePlan()` computes:
   - NDL
   - `needsDeco`
   - gas analysis
   - static/role-aware deco stops
   - MOD validation issues
   - TTR
   - segments
   - GF comparisons
   - contingency plans
   - team gas matching
   - briefing text

Assessment: coherent as a UI reference workflow, but not a mathematically validated technical planner.

### Gas Planning

Found in:

- `GasPlanningService.analyze(input:)`
- `GasPlanInput`
- `Cylinder`
- `TeamMember`

Main calculations:

- ambient pressure approximation
- PPO2 at planning depth
- gas density at planning depth
- END
- EAD for nitrox
- gas consumption
- remaining gas
- rock-bottom/minimum gas
- turn pressure
- CNS
- OTU
- team gas matching

Assessment: formulas are understandable but not centrally validated. Programmatic invalid inputs can produce apparently valid output.

### MOD / PPO2

Found in:

- `PlannerMODValidator`
- `GasPlanningService.ppO2`
- `GasPlanningService.boundedPPO2`
- `PlannerGasSchedule.makeDecoStop`

Assessment: actual PPO2 is calculated for bottom analysis, but deco-stop PPO2 is bounded/clipped, which can hide actual PPO2 over-limit in plan output.

### Buhlmann / NDL

Found in:

- `BuhlmannPlanner`

Implementation:

- 16 N2 half-times
- 16 N2 `a` coefficients
- 16 N2 `b` coefficients
- simplified inspired nitrogen pressure calculation
- no helium compartments
- no tissue history across profile
- no gas switching model
- no gradient-factor ceiling propagation
- no decompression stop calculation from tissue ceilings
- returns `999` when the controlling compartment remains infinity

Assessment: simplified N2-only no-decompression reference. It must not be treated as full Buhlmann ZHL-16C.

### Decompression Stops / TTR

Found in:

- `PlannerGasSchedule.buildDecoStops`
- `PlannerService.makePlan`

Implementation:

- `needsDeco` if planned bottom time > simplified NDL or planning depth >= 35 m
- if no deco is needed, a 5 m / 3 min stop is still returned
- if deco is needed, static stops are generated:
  - deep switch stop
  - 15 m
  - shallow switch stop
  - 6 m
  - 3 m
- stop depths are clamped to MOD via `min(requestedDepth, mod)`
- TTR is bottom minutes + stop minutes + `plannedDepth / 10`

Assessment: this is not a decompression algorithm. It is a static schedule/reference output.

### Logbook / Profile Math

Found in:

- `DiveImportService`
- `DiveLogStore`
- `DiveSessionMerge`
- `ManualDiveEditorView`
- `AnalysisView`

Implementation:

- imported CSV average depth uses arithmetic mean
- imported CSV TTV = arithmetic average depth + duration minutes
- manual dive TTV = average depth * duration minutes
- demo logbook average depth uses arithmetic mean
- merge may preserve existing derived values rather than recomputing from selected samples

Assessment: inconsistent with Watch MAIN hardened time-weighted average depth and TTV formula.

### CSV Import / Export

Found in:

- `DiveImportService`
- `SubsurfaceExportService`

Implementation:

- CSV import supports `time_seconds`, `depth_m`, `temperature_c`
- optional GPS columns are read
- invalid rows are skipped
- export writes a CSV-like profile with additional manual metadata
- export rejects empty samples at `writeCSV`, but `makeCSV` can still return header/meta-only output for empty sessions

Assessment: useful but not robust enough for corrupted or unsorted profile data.

### Watch Sync

Found in:

- `WatchDiveSyncCodec`
- `WatchSyncService`
- `WatchSyncAuth`

Implementation:

- HMAC-signed transport envelope
- peer secret via WatchConnectivity/keychain
- max payload size
- max issued-at skew
- basic session-level validation

Assessment: transport security is stronger than mathematical validation. Payload validation does not validate per-sample math deeply enough.

### Route Math

Found in:

- `RouteSummaryService`

Implementation:

- Haversine distance
- initial bearing normalized to 0..<360

Assessment: formula is standard, but coordinate validation is missing before computation.

## Mathematical Formulas Found

### Ambient Pressure

```text
ambient_pressure_bar = depth_m / 10 + 1
```

Used in gas consumption, PPO2, density, END, EAD, and Buhlmann inspired gas approximation.

Limitation: salinity and altitude fields exist but do not appear to change pressure math.

### PPO2

```text
PPO2 = FO2 * ambient_pressure_bar
```

Used in bottom gas analysis.

Issue: stop PPO2 uses:

```text
bounded_PPO2 = min(gas.maxPPO2, actual_PPO2)
```

This hides over-limit actual PPO2 values in stop output.

### MOD

```text
MOD_m = ((max_PPO2 / FO2) - 1) * 10
```

Implementation clamps FO2 to at least 0.01, which avoids divide-by-zero but can hide invalid gas.

### Nitrogen Fraction

```text
FN2 = max(0.01, min(0.79, 1 - FO2 - FHe))
```

Issue: invalid/unsupported gas states are converted into a bounded number, not rejected.

### Gas Density

```text
surface_density_g_L = FO2 * 1.429 + FN2 * 1.251 + FHe * 0.1786
density_at_depth_g_L = surface_density_g_L * ATA
```

Assessment: reasonable approximation if inputs are validated.

### END

```text
narcotic_fraction = FN2 + (FO2 if oxygen is treated narcotic)
air_narcotic_fraction = 0.79 + (0.21 if oxygen is treated narcotic)
narcotic_pressure = ATA * narcotic_fraction
END_m = max(0, ((narcotic_pressure / air_narcotic_fraction) - 1) * 10)
```

Assessment: standard simplified approach; depends on policy choice for oxygen narcotic behavior.

### EAD

```text
PN2 = ATA * FN2
EAD_m = max(0, ((PN2 / 0.79) - 1) * 10)
```

Only returned for helium == 0 and oxygen > 0.21.

### Gas Consumption

```text
consumption_L = SAC_L_min * ATA * bottom_minutes
remaining_L = available_L - consumption_L
remaining_bar = remaining_L / cylinder_volume_L
```

Issue: volume denominator uses `max(volume, 0.1)`, masking zero or invalid cylinder size.

### Cylinder Available Gas

```text
available_L = max(0, volume_L * (start_pressure_bar - reserve_pressure_bar))
```

Issue: start pressure <= reserve pressure is converted to 0 available gas rather than invalid input state.

### Rock Bottom / Minimum Gas

```text
average_ascent_ATA = ((planned_depth / 2) / 10) + 1
ascent_minutes = max(3, planned_depth / 9)
emergency_minutes = 1 + ascent_minutes + safety_stop_minutes
rock_bottom_L = emergency_SAC * team_size * average_ascent_ATA * emergency_minutes
minimum_gas_bar = rock_bottom_L / cylinder_volume_L
```

Assessment: simplified heuristic. It is not documented as a formal minimum-gas method with stop/gas-switch propagation.

### Turn Pressure

```text
usable_before_minimum = max(0, available_L - rock_bottom_L)
turn_pressure_bar = min(start_bar, max(reserve_bar, start_bar - usable_before_minimum / 2 / cylinder_volume_L))
```

Assessment: simple half-usable-gas turn pressure. Invalid cylinder inputs can be masked.

### CNS

Piecewise exposure limits based on PPO2:

- PPO2 < 1.0: 720 min
- PPO2 < 1.2: 210 min
- PPO2 < 1.4: 150 min
- PPO2 < 1.6: 45 min
- PPO2 >= 1.6: 10 min

```text
CNS_percent = min(300, minutes / limit_minutes * 100)
```

Assessment: simplified reference.

### OTU

```text
OTU = minutes * pow(0.5 / (PPO2 - 0.5), -0.833)
```

Assessment: common-style approximation above PPO2 0.5; no validation around extreme invalid PPO2 inputs.

### Buhlmann NDL

For each N2 compartment:

```text
k = ln(2) / half_time
m0 = surface_pressure / b + a
ratio = (m0 - inspired_PN2) / (surface_PN2 - inspired_PN2)
NDL = -ln(ratio) / k
```

Assessment: simplified no-decompression estimate only. It is not full profile-based Buhlmann ZHL-16C.

### Import Average Depth

```text
avg_depth = sum(depth_samples) / sample_count
```

Issue: arithmetic average, not time-weighted.

### Manual Dive TTV

```text
ttv = avg_depth_m * duration_minutes
```

Issue: inconsistent with Watch MAIN hardened formula, where TTV/index is average depth + runtime minutes.

### Route Distance

Haversine formula:

```text
a = sin(dLat/2)^2 + cos(lat1) * cos(lat2) * sin(dLon/2)^2
distance = earth_radius * 2 * atan2(sqrt(a), sqrt(1 - a))
```

Issue: no input validation/clamping of `a` before sqrt.

### Route Bearing

```text
degrees = atan2(y, x) * 180 / pi
bearing = (degrees + 360) % 360
```

Issue: no input validation for coordinates.

## Buhlmann / No-Decompression Implementation Status

Status: **simplified N2-only reference, not full Buhlmann ZHL-16C**.

Implemented:

- N2 half-time table
- N2 `a` and `b` coefficient arrays
- simple NDL-style calculation
- curve data for charting

Not implemented:

- helium compartments
- combined N2/He tissue loading
- descent/ascent tissue history
- multi-segment exposure propagation
- gas-switch tissue updates
- gradient-factor ceiling calculation
- decompression stop propagation
- validated test vectors
- altitude/salinity pressure adjustment
- CNS/OTU across multi-segment profile

Critical observation:

The default planner bottom gas is trimix (`O2 18%, He 45%`). The Buhlmann planner subtracts helium from nitrogen fraction but does not model helium tissue loading. That can make NDL/reference outputs look more favorable without accounting for helium decompression obligations.

## Gas Planning Implementation Status

Status: **partial reference implementation**.

Implemented:

- ambient pressure approximation
- PPO2 at depth
- MOD
- gas density estimate
- END
- EAD for nitrox
- consumption in liters
- remaining gas in liters/bar
- rock-bottom heuristic
- turn pressure heuristic
- CNS/OTU approximations
- team gas match heuristic
- MOD issue list

Not fully implemented or weak:

- no central validator for `GasPlanInput`
- no typed result state such as invalid input, unsupported gas, model incomplete, insufficient gas, or unavailable
- invalid cylinder volume can be hidden by denominator clamping
- start pressure <= reserve pressure becomes 0 available gas
- invalid gas fractions are normalized/clamped in the model instead of always rejected
- no true PPN2 output
- no full trimix decompression model
- no multi-gas gas consumption by segment
- no validated salt/freshwater/altitude pressure model despite fields existing
- no single central unit conversion helper

## Constants and Thresholds Found

### Planner Defaults

- default planned max depth: 40 m
- default planned average depth: 20 m
- default bottom time: 20 min
- default SAC/RMV: 18 L/min
- default emergency SAC: 30 L/min
- default team size: 2
- default water temperature: 24 C
- default GF low/high: 30/70
- default density warning/danger: 5.2 / 6.2 g/L
- default bottom gas: TX 18/45
- default deco gases: EAN50 and EAN80
- default cylinder: 12 L, 200 bar, 50 bar reserve

### Gas Constants

- O2 surface density: 1.429 g/L
- N2 surface density: 1.251 g/L
- He surface density: 0.1786 g/L
- pressure conversion: 14.5038 psi/bar in `GasPlan`, 14.5038-like constants elsewhere
- meters-to-feet: 3.280839895 in `Formatters` and direct usage in `ManualDiveEditorView`/`PlannerView`
- liters-to-cubic-feet: 0.0353147

### Import / Sync / Export

- import max file size: 10 MB
- import max dive duration: 24 h
- import max depth: 300 m
- import valid temperature: -5...40 C
- sync max payload: 512,000 bytes
- sync max samples: 20,000
- sync max depth: 350 m
- sync max issued-at skew: 1 h
- temporary export cleanup: 24 h

### Safety

- `DiveSession` flags exceeded supported depth at 40 m
- planner MOD uses +0.05 m tolerance for switch-depth checks
- CNS capped at 300%

## Correctness Assessment By Audit Area

### 1. Gas Planning Algorithms

Status: partial.

Correct:

- SAC/RMV consumption formula is standard: SAC * ATA * minutes.
- Available gas in liters from cylinder volume and pressure delta is conceptually correct.
- Remaining gas and turn pressure are understandable.
- Rock-bottom heuristic is conservative in spirit.

Issues:

- no central validator blocks zero/negative/non-finite cylinder volume, SAC/RMV, depth, time, pressure, or gas fractions before calculation
- `max(volume, 0.1)` masks invalid cylinder volume
- `availableGasLiters` hides start pressure <= reserve pressure by returning 0
- no typed warning/result state; warnings are strings
- gas consumption is bottom-phase only and does not consume different gases by segment
- pressure conversion constants are duplicated and slightly inconsistent
- imperial pressure/display logic is partial; planner results still show bar in several places

### 2. Buhlmann / No-Decompression / Dive Table Logic

Status: simplified reference only.

Correct:

- coefficient arrays are present for N2.
- inspired PN2 and compartment equation are recognizable.

Issues:

- no helium compartments
- no gas switches
- no tissue loading over a profile
- no gradient factor ceiling/stop algorithm
- no validated decompression stop propagation
- trimix input can produce NDL based only on reduced nitrogen fraction
- `999` NDL fallback can look like a real number instead of unavailable
- deco stops are static schedule, not generated from Buhlmann ceilings
- GF comparisons are heuristic multipliers, not real GF decompression plans

### 3. PPO2 / PPN2 / Partial Pressure

Status: partial.

Correct:

- PPO2 = FO2 * ATA is implemented.
- MOD formula is implemented.
- EAD and END are implemented as simplified formulas.

Issues:

- stop PPO2 is clipped through `boundedPPO2`, hiding actual over-limit PPO2
- PPN2 is not exposed as its own validated output
- invalid gas fractions can be clamped or normalized instead of rejected
- salinity/water type does not alter pressure conversion
- altitude does not alter ambient pressure

### 4. Gas Density / Respirability

Status: partial.

Correct:

- gas density approximation is implemented as surface density * ATA.
- warning/danger thresholds exist.

Issues:

- no validation for non-finite gas fractions/depth before density calculation
- trimix respirability output can look validated while decompression model is not
- no typed "gas density unavailable" state

### 5. Dive Planner Inputs

Status: weak.

Issues:

- validation is spread across UI controls, model normalization, and MOD checks
- `PlannerService.makePlan` can be called directly with invalid data
- no central `PlannerInputValidator`
- no central `GasMixValidator`
- no hard upper depth/time bounds in service layer
- GF values are not service-validated for order/range
- zero SAC/RMV, zero cylinder, negative pressures, and unsupported depths are not rejected centrally
- planner state persists via cloud without a validation gate

### 6. Planner Output Consistency

Status: partial.

Issues:

- `store.plan` and `store.analysis` are computed separately; both use current `input`, but `analysis` is a computed property and can diverge conceptually from a previously calculated plan
- NDL, TTR, deco stops, GF comparison, and segments are not generated by one validated decompression model
- plan share/export can distribute indicative outputs
- MOD validation reports issues, but applied stops also clamp depths to MOD, which may hide the requested unsafe stop depth in the primary table

### 7. Logbook Calculations

Status: inconsistent.

Issues:

- imported CSV average depth is arithmetic rather than time-weighted
- demo sessions use arithmetic average
- manual dive TTV formula is inconsistent with Watch MAIN formula
- manual sample builder uses only three synthetic samples and does not make the stored average depth mathematically match time-weighted profile
- merge does not recompute derived values from selected samples
- iOS may preserve Watch-derived values, but import/manual paths can create divergent values

### 8. Subsurface Export

Status: partial.

Correct:

- `writeCSV` rejects empty sample arrays.
- output includes profile samples and manual metadata.
- temporary files are written atomically with complete file protection.

Issues:

- `makeCSV` still returns header/meta-only CSV for empty profiles
- samples are not sorted before export
- negative elapsed seconds can be produced for unsorted samples
- invalid sample depths/temperatures are not filtered
- GPS values are exported without revalidation
- gas fields are not exported as structured gas mix fields
- output does not guarantee consistency with recomputed logbook values

### 9. Unit Conversion System

Status: partial.

Issues:

- conversion constants are duplicated:
  - meters-to-feet in `Formatters`, `ManualDiveEditorView`, `PlannerView`
  - psi/bar in `GasPlan`
  - liters-to-cubic-feet only in `Formatters`
- no central iOS unit conversion helper
- no round-trip tests
- planner output often remains metric/bar even when UI preference is imperial

### 10. Mathematical Robustness

Status: not release-hard.

Risks:

- NaN/infinity values can reach planner calculations via programmatic or corrupted persisted input
- `max(..., 0.1)` hides invalid cylinder volumes
- `max(oxygen, 0.01)` hides invalid FO2 in MOD
- `999` hides Buhlmann "no controlling compartment" as a real NDL
- route formulas can produce NaN from invalid GPS
- sync validation does not validate samples, GPS, average depth, TTV, or profile order
- merge can create mathematically inconsistent sessions

### 11. Certification / Safety Positioning

Status: mostly safe in copy, weaker in output semantics.

Good:

- legal onboarding includes "DIR Diving is NOT a dive computer."
- More/Legal copy states non-certified positioning.
- planner safety acknowledgement exists.
- planner disclaimer/informative copy exists.
- docs clearly state iOS planner is not certified.

Risk:

- result screen presents `Piano Immersione`, deco stops, Buhlmann curve, CNS, OTU, GF comparisons, turn pressure, and briefing lines. Those outputs can look operationally authoritative even if copy says indicative.
- default trimix/technical planner makes unsupported math especially risky.

### 12. Test Coverage

Status: missing for iOS algorithms.

Project status:

- no iOS XCTest target found in `project.yml`
- only `DIRDiving Watch Algorithm Tests` exists

No automated iOS tests found for:

- gas planning
- SAC/RMV
- cylinder pressure conversions
- PPO2 / PPN2
- MOD
- EAD / END
- gas density
- CNS / OTU
- Buhlmann / NDL
- planner invalid inputs
- logbook import average depth
- manual dive TTV
- Subsurface export sorting/validation
- Watch sync payload validation
- route distance/bearing validation

## Safety-Critical Issues

### P0 - Safety-Critical

1. **Actionable-looking technical planner output is generated from simplified/reference math**
   - Files: `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/PlannerService.swift`, `iOSApp/Services/PlannerGasSchedule.swift`, `iOSApp/Views/PlannerView.swift`
   - Impact: user can receive deco stops, GF comparisons, TTR, CNS/OTU, END, gas turn pressure, and shareable briefing from a model that is not full Buhlmann ZHL-16C and not validated for decompression use.
   - Mitigation already present: non-certified disclaimers and safety acknowledgement.
   - Recommended fix: return typed states such as `simplifiedReferenceOnly`, `modelIncomplete`, `unsupportedTrimix`, `unavailable`, and avoid presenting unsupported outputs as a plan.

2. **Trimix planner uses N2-only Buhlmann preview**
   - Files: `iOSApp/Models/GasPlan.swift`, `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/PlannerService.swift`
   - Impact: helium reduces nitrogen fraction in the simplified NDL estimate, but helium tissue loading is not modeled. This can make trimix output mathematically misleading.
   - Recommended fix: for trimix, return `modelIncomplete` unless a full N2+He Buhlmann engine is implemented and tested.

### P1 - Mathematical Correctness

1. **Manual dive TTV formula is inconsistent**
   - File: `iOSApp/Views/ManualDiveEditorView.swift`
   - Current: `ttv = avgDepth * durationMinutes`
   - Watch MAIN formula: `ttv = avgDepth + durationMinutes`
   - Impact: manual iOS dives can store huge/inconsistent TTV values.

2. **Stop PPO2 is clipped**
   - Files: `iOSApp/Services/GasPlanningService.swift`, `iOSApp/Services/PlannerGasSchedule.swift`
   - Current: `min(gas.maxPPO2, actualPPO2)`
   - Impact: actual PPO2 over limit is hidden in stop output.

3. **Buhlmann returns `999` as valid NDL**
   - File: `iOSApp/Services/BuhlmannPlanner.swift`
   - Impact: "unbounded/no controlling compartment" is displayed as a numeric NDL, not an unavailable/simplified state.

4. **Planner service accepts invalid programmatic input**
   - Files: `iOSApp/Services/PlannerService.swift`, `iOSApp/Services/GasPlanningService.swift`, `iOSApp/Models/GasPlan.swift`
   - Impact: invalid depth, time, pressure, cylinder volume, SAC/RMV, gas fractions, and GF values can produce outputs.

5. **Imported average depth is arithmetic, not time-weighted**
   - File: `iOSApp/Services/DiveImportService.swift`
   - Impact: imported logbook values can diverge from Watch MAIN math and actual time-at-depth profile.

### P2 - Data Integrity

1. **Watch sync validation is shallow**
   - File: `iOSApp/Services/WatchDiveSyncCodec.swift`
   - Missing validation: per-sample finite depth, temperature, timestamp order, GPS range, duration consistency, max/average/TTV consistency.

2. **DiveSessionMerge mixes derived fields**
   - File: `iOSApp/Utils/DiveSessionMerge.swift`
   - Impact: max depth, average depth, TTV, duration, and sample arrays can be taken from different versions without recomputation.

3. **CSV export does not sort or validate samples**
   - File: `iOSApp/Services/SubsurfaceExportService.swift`
   - Impact: unsorted samples can create negative elapsed seconds; invalid samples can be exported.

4. **CSV import uses `horizontalAccuracy = -1`**
   - File: `iOSApp/Services/DiveImportService.swift`
   - Impact: imported GPS points violate the nonnegative accuracy convention used elsewhere.

5. **Route summary does not validate GPS**
   - File: `iOSApp/Services/RouteSummaryService.swift`
   - Impact: invalid GPS can generate NaN distance/bearing.

6. **iOS logbook does not enforce a 40-session cap**
   - File: `iOSApp/Services/DiveLogStore.swift`
   - Impact: if product/docs expect latest 40 sessions across platforms, iOS can grow unbounded except storage constraints.

### P3 - Maintainability

1. **Unit conversions are duplicated**
   - Files: `Formatters.swift`, `GasPlan.swift`, `ManualDiveEditorView.swift`, `PlannerView.swift`

2. **Magic numbers are spread across planner/import/sync/export**
   - Examples: 10 m/bar, 14.5038 psi/bar, 3.280839895 ft/m, max depths 300/350/40, temperature -5...40, density 5.2/6.2.

3. **Warnings are strings rather than typed states**
   - Files: `GasPlanningService.swift`, planner views.

4. **No iOS algorithm tests**
   - File: `project.yml`

5. **Planner fields exist but are unused in pressure math**
   - `salinity` and `altitudeMeters` are persisted but not used in ambient pressure calculation.

## Required Test Scenarios To Add

### Gas / Planner

- Air 21% O2 at 30 m / 20 min
- Nitrox 32 at 30 m / 20 min
- Trimix returns unsupported/modelIncomplete unless full N2+He model exists
- O2 + He > 100% rejected
- O2 > 100% rejected
- O2 <= 0 rejected
- He < 0 rejected
- zero cylinder size rejected
- zero SAC/RMV rejected
- start pressure <= reserve pressure rejected
- negative depth rejected
- unsupported deep depth rejected/unavailable
- MOD exceeded generates typed warning/error
- actual stop PPO2 over max is exposed and warned, not clipped
- gas density finite for valid inputs
- gas density unavailable for invalid inputs

### Buhlmann / NDL

- Buhlmann disabled/unavailable state does not produce actionable stops
- invalid gas does not return 999 min NDL
- simplified model returns `simplifiedReferenceOnly`
- helium > 0 returns `modelIncomplete` unless full He model exists
- GF comparison does not pretend to be a real decompression plan
- NDL outputs are finite or explicitly unavailable

### Unit Conversions

- meters/feet round trip
- bar/psi round trip
- liters/cubic feet conversion
- Celsius/Fahrenheit conversion
- m/min/ft/min if displayed

### Logbook / Import / Export

- time-weighted average depth with irregular samples
- empty profile rejected
- out-of-order timestamps sorted or rejected
- negative elapsed export impossible
- NaN depth rejected
- infinity depth rejected
- invalid temperature rejected
- invalid GPS rejected
- imported GPS uses valid accuracy semantics
- manual dive TTV matches canonical formula
- merge recomputes derived fields
- CSV export with missing gas data is documented or includes gas fields

### Sync

- corrupted sample rejected
- sample outside session range rejected
- invalid GPS rejected
- inconsistent max/average/TTV rejected or recomputed
- payload with valid signature but invalid math rejected

### Route

- invalid latitude rejected
- invalid longitude rejected
- NaN route output impossible
- identical entry/exit returns zero distance and defined/empty bearing behavior

## Recommended Fixes

### Immediate Release-Hardening

1. Add a central iOS algorithm module:
   - `IOSAlgorithmConfiguration`
   - `IOSUnitConversions`
   - `PlannerInputValidator`
   - `GasMixValidator`
   - `DiveProfileMath`
   - `DiveSessionAlgorithmValidator`
   - `PlannerResultState`
   - `BuhlmannModelState`

2. Make `PlannerService.makePlan` refuse invalid inputs and return typed states.

3. For trimix, either:
   - implement full Buhlmann ZHL-16C N2+He with validated test vectors, or
   - return `modelIncomplete/unsupportedTrimix` and suppress actionable deco outputs.

4. Replace `boundedPPO2` output with:
   - actual PPO2
   - max allowed PPO2
   - over-limit warning state

5. Replace arithmetic import/logbook average depth with time-weighted average.

6. Fix manual dive TTV to the canonical informational formula.

7. Harden sync/import/export validation to reject or repair corrupted data deterministically.

8. Add an iOS XCTest target and algorithm test suite.

### Before TestFlight

1. Keep planner safety acknowledgement mandatory.
2. Keep non-certified wording visible in planner and export/share output.
3. Add explicit "simplified reference only" labels where technical outputs remain.
4. Run all iOS algorithm tests on macOS/Xcode.
5. Validate iOS/Watch sync with corrupted payload tests.

### Before App Store

1. Legal review of technical planner wording.
2. App Review notes clarifying non-certified planner.
3. Physical device sync/export/import QA.
4. Decide whether MAIN iOS should expose technical planner by default or gate it behind a stronger warning/unavailable state.

## Final Verdict

### Ready To Compile?

This audit did not run Xcode because the current environment is Windows and has no `xcodebuild`/XcodeGen runtime available. Static inspection found no immediate syntax edits because no code was changed.

### Algorithmically Release-Hard?

No. The iOS Companion MAIN branch is not yet algorithmically release-hard for technical planning.

### Ready For Internal QA?

Yes, as an informational planner/logbook candidate, if testers understand that planner outputs are simplified and non-certified.

### Ready For TestFlight?

Not from an algorithmic standpoint unless the planner is clearly treated as simplified reference and unsupported trimix/deco states are blocked or labeled more strongly.

### Ready For Average User?

Not for technical dive planning. Logbook and sync workflows are closer, but import/export/merge/sync math still needs hardening.

### Ready For App Store?

Not until planner mathematical limitations, test coverage, legal copy, and unsupported trimix/deco behavior are resolved.

## Priority Roadmap

### Must Fix Before Calling iOS MAIN Algorithmically Release-Hard

- add central validators
- block invalid planner input
- remove actionable trimix output from N2-only Buhlmann path
- expose actual PPO2, not clipped PPO2
- replace 999 NDL fallback with unavailable/simplified state
- fix manual TTV formula
- time-weight imported/logbook averages
- validate sync samples and derived fields
- add iOS algorithm tests

### Must Fix Before TestFlight

- export/import sorting and invalid sample handling
- route GPS validation
- merge derived-value recomputation
- unit conversion centralization
- planner share text safety review

### Can Fix Post-Release If Planner Is Gated/Reference-Only

- full N2+He Buhlmann model
- multi-segment gas consumption
- altitude/salinity pressure model
- complete Subsurface gas export fields
- formal rock-bottom/team gas configuration model

