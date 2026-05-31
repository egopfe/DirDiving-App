# DIR DIVING iOS Companion MAIN Algorithm And Mathematical Logic Audit

Date: 2026-05-27

Branch audited: `main-iOS`

Scope: iOS Companion MAIN branch only. This audit did not inspect or modify Apple Watch implementation logic beyond repository/project context, did not inspect experimental branches, and did not change UI, UX, business logic, algorithms, or source code.

## Executive Summary

The iOS Companion MAIN branch contains real numerical logic in four main areas:

- Gas planning input model and gas consumption estimates.
- A simplified Buhlmann/NDL reference model.
- Planner output generation for TTR, indicative stops, CNS and OTU.
- Logbook import/export, Watch sync session validation, route distance/bearing and unit display conversion.

The implementation is useful as a demonstrator and informational companion, but it is not mathematically release-hard for dive planning. The main concern is not ordinary arithmetic failure; it is that simplified or heuristic planner outputs are displayed with terms such as Buhlmann, NDL, deco stops, CNS, OTU and TTR. The UI does include safety disclaimers and an acknowledgement gate, which reduces risk, but the underlying calculations are not complete enough to be treated as decompression, gas-management, or technical-diving planning.

Overall assessment:

- Gas planning implementation status: partial, metric-only core, simple single-cylinder estimate, no rock-bottom, no turn pressure, no validated multi-cylinder gas strategy.
- Buhlmann/no-deco implementation status: simplified N2-only reference calculation, not a full Buhlmann ZH-L16C planner.
- PPO2/MOD status: basic formulas present; bottom gas MOD validation exists; deco gas PPO2 is displayed but clipped in planner output.
- Logbook math status: Watch values are mostly preserved, but iOS import and merge can produce derived-value inconsistencies.
- Export status: works for nonempty samples, but does not sort/sanitize sample order and can export negative elapsed seconds for out-of-order data.
- Test coverage status: no XCTest target or automated iOS algorithm tests were found.

Verdict: not ready to call iOS Companion MAIN algorithmically release-hard. It is acceptable as an internal informational planner/logbook only if the simplified nature remains explicit and tester-facing. P0/P1 items below should be resolved before presenting planner outputs as production-quality planning.

## Files Inspected

Primary iOS algorithm/model files:

- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Utils/DiveSessionMerge.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Utils/Formatters.swift`
- `iOSApp/Services/RouteSummaryService.swift`
- `iOSApp/Models/DiveSession.swift`
- `iOSApp/Models/DiveSample.swift`
- `iOSApp/Models/GPSPoint.swift`
- `iOSApp/Models/EquipmentProfile.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/EquipmentStore.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/DiveDetailView.swift`
- `iOSApp/Views/AnalysisView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/EquipmentView.swift`

Project and safety context:

- `project.yml`
- `iOSApp/Resources/en.lproj/LegalDisclaimer.txt`
- `iOSApp/Resources/it.lproj/LegalDisclaimer.txt`
- `README.md`
- `Docs/DIR_DIVING_Feature_Comparison.csv`
- `Docs/GLOSSARY.md`

## Algorithms Found

### Gas Planning

Source: `iOSApp/Models/GasPlan.swift`

Found formulas:

- Nitrogen fraction: `max(0, 1.0 - oxygen - helium)` at line 22.
- MOD: `((maxPPO2 / max(oxygen, 0.01)) - 1.0) * 10.0` clamped to zero at line 23.
- PSI to bar: `psi / 14.5038` at lines 43-44.
- Available gas: `cylinderVolumeLiters * (startPressureBar - reservePressureBar)` at line 45.
- Ambient pressure: `plannedDepthMeters / 10.0 + 1.0` at line 46.
- Gas consumption: `SAC * ambientPressureBar * plannedBottomMinutes` at line 47.
- Remaining gas liters: available minus estimated consumption at line 48.
- Remaining bar: remaining liters divided by cylinder volume with `max(cylinderVolumeLiters, 0.1)` at line 49.
- Remaining PSI: remaining bar times `14.5038` at line 50.

Correctness assessment:

- The simple SAC/RMV gas consumption estimate is dimensionally coherent for metric single-cylinder planning.
- Reserve gas is handled as pressure reserve and subtracted from usable pressure.
- PSI conversion is present, but the planner UI appears metric-centric and there is no complete imperial planner input workflow.
- No finite-value guards exist in the model itself. UI validation catches ordinary negative/zero values before calculate, but persisted or programmatic invalid values can still reach `PlannerService`.
- No rock-bottom/minimum gas formula, turn pressure, buddy reserve, cylinder working-pressure validation, multi-cylinder allocation, deco gas consumption, or gas switch accounting was found.

### Buhlmann / No-Decompression

Source: `iOSApp/Services/BuhlmannPlanner.swift`

Found constants and formulas:

- N2 half-times: 16 compartment values at line 4.
- N2 `a` and `b` coefficients at lines 5-6.
- Nitrogen fraction in `plan`: `max(0, min(0.79, 1.0 - o2Fraction))` at line 8.
- Inspired PN2: `(ambient - waterVaporPressure) * nitrogenFraction` at lines 24-25.
- Compartment rate: `log(2.0) / halfTimesN2[i]` at line 28.
- Surface M-value approximation: `(surfacePressure / bN2[i]) + aN2[i]` at line 29.
- NDL control time: `-log(ratio) / k` at line 32.
- Infinite NDL fallback: `999` minutes at line 34.

Implementation status:

- This is not a full Buhlmann ZH-L16C decompression planner.
- It models N2 only.
- It ignores helium tissue loading despite the default bottom gas being trimix.
- It has no gradient factors.
- It has no ascent/descent model.
- It has no repetitive/multi-level tissue state.
- It has no decompression ceiling propagation.
- It has no gas switch tissue model.
- It has no validated CNS/OTU table model.
- The chart displayed as a Buhlmann curve uses generated reference points and a presentation transform, not compartment load values.

Correctness assessment:

- The calculation is internally deterministic for finite inputs.
- It is best classified as a simplified static NDL reference.
- The function name, tab label, chart title and warning text mention Buhlmann ZH-L16C. Although the UI says "semplificato", the output still uses decompression-planning vocabulary that can be over-trusted.
- For impossible or extreme gas inputs called directly, `fn2` can be forced to zero and return 999 minutes, which is unsafe if UI validation is bypassed.

### Planner Output

Source: `iOSApp/Services/PlannerService.swift`

Found formulas:

- `needsDeco = plannedBottomMinutes > ndl || plannedDepthMeters >= 35` at line 7.
- Ceiling heuristic: `min(21, max(3, floor(depth / 3) * 3 - 3))` at line 19.
- Stop depths every 3 m to 3 m at line 20.
- Deco gas selection: `decoGas1` at 12 m or deeper, else `decoGas2` at line 23.
- Stop pressure: `1.0 + depth / 10.0` at line 24.
- Base stop minutes: 2, 3 or 5 minutes depending on depth at line 25.
- Extra stop minutes: `ceil(overrun / 10.0)` at line 26.
- Stop PPO2 displayed as `min(gas.maxPPO2, gas.oxygen * pressure)` at line 27.
- Safety stop for no-deco path: fixed 5 m / 3 minutes at line 30.
- TTR: bottom time + stop minutes + `Int(depth / 10.0)` at line 32.
- CNS estimate: `minutes * max(0, O2 * ambientPressure - 0.5) * 2.2`, capped at 100 at line 33.
- OTU estimate: `minutes * pow(max(0.5, O2 * ambientPressure) - 0.5, 0.83) * 5` at line 34.

Implementation status:

- The planner output is heuristic.
- Deco stop placement and stop duration are not generated by a validated decompression algorithm.
- TTR is not ascent-rate based and does not account for gas switches, stop-to-stop travel time, or final ascent in a validated way.
- CNS/OTU formulas are simplified and not table-based.

Correctness assessment:

- Calculations are deterministic for ordinary UI-validated inputs.
- The formulas are not suitable for actual decompression planning.
- `min(gas.maxPPO2, gas.oxygen * pressure)` can understate displayed PPO2 if the actual computed value exceeds maxPPO2. For safety, output should show actual PPO2 plus a warning, not clip it down.
- `plannedDepthMeters >= 35` forces deco-like stops even if NDL says otherwise. This is conservative as a visual warning but not mathematically derived.

Example outputs reproduced from current formulas:

- Air 21% at 30 m for 20 min: NDL about 16.3 min, needs deco true, stops 21/18/15/12/9/6/3 m, TTR 52 min.
- Nitrox 32 at 30 m for 20 min: NDL about 28.0 min, no deco path, 5 m / 3 min stop, TTR 26 min.
- Default trimix 18/45 at 40 m for 20 min: helium ignored by NDL, NDL about 8.8 min, TTR 60 min.

### Partial Pressure / MOD / Gas Fractions

Sources: `iOSApp/Models/GasPlan.swift`, `iOSApp/Views/PlannerView.swift`, `iOSApp/Services/PlannerService.swift`

Found formulas:

- PPO2 at depth: `oxygen * (1 + depth / 10)` in planner output.
- MOD: `((maxPPO2 / oxygen) - 1) * 10`.
- Nitrogen fraction: `max(0, 1 - O2 - He)`.
- UI validation: O2 0.10...1.0, He >= 0, O2 + He <= 1.0, maxPPO2 1.0...1.6.

Correctness assessment:

- Basic PPO2 and MOD equations are standard for metric seawater approximation.
- O2 and He validation is present in `PlannerView`.
- Nitrogen fraction uses clamping and can mask invalid mixes in model-level or decoded persisted input.
- PPN2, END and EAD are not implemented.
- Saltwater/freshwater assumptions are not configurable; all pressure math uses 10 m/bar.

### Gas Density / Respirability

No gas density formula was found.

Status:

- No gas density calculation from mix, depth and pressure.
- No density warning threshold.
- No END/EAD proxy warning.

Risk:

- For trimix/technical-looking inputs, absence of density/respirability warnings is a planning completeness gap.

### Dive Planner Inputs

Source: `iOSApp/Views/PlannerView.swift`

UI validation found:

- Depth: 1...100 m at lines 235-236.
- Bottom time: 1...240 minutes at lines 238-239.
- Cylinder volume > 0, startPressureBar > reservePressureBar, reserve >= 0 at lines 241-242.
- SAC > 0 at lines 244-245.
- Gas mix O2/He/PPO2 bounds at lines 247-260.
- Bottom gas MOD must be >= planned depth at lines 250-251.
- Safety acknowledgement is required before navigation to plan output.

Correctness assessment:

- UI-level validation is a strong guard for normal user flows.
- Validation is not centralized in the model/service layer.
- `PlannerStore.calculate()` can still generate output for invalid persisted/programmatic values.
- Temperature has a planner input but is not used in the calculations.
- Pressure unit exists in the model but is not exposed as a full unit workflow in the planner UI.

### Planner Output Consistency

Sources: `PlannerService`, `PlannerStore`, `PlannerView`

Assessment:

- `PlannerStore.calculate()` computes both `plan` and `buhlmann` from the same `GasPlanInput`.
- `PlanResultView` displays values from `store.plan` and `store.buhlmann`.
- Output warnings are shown.
- There is no saved plan export.
- There is no immutable plan snapshot when opening the result; subsequent store changes can alter outputs.

### Logbook Calculations

Sources: `DiveImportService`, `DiveLogStore`, `DiveSessionMerge`, `DiveDetailView`, `AnalysisView`

Found formulas:

- Imported average depth: arithmetic mean of sample depths at `DiveImportService.swift:115`.
- Imported TTV: average depth + duration minutes at `DiveImportService.swift:124`.
- Demo average depth: arithmetic mean in `DiveLogStore`.
- Analysis averages: arithmetic mean of session avg temperatures and SAC values.
- Detail graph uses session sample values directly.

Correctness assessment:

- Imported average depth is not time-weighted.
- Import does not require monotonic timestamps.
- Import end time is the timestamp of the last row, not the maximum sample timestamp.
- Out-of-order rows can create mathematically inconsistent duration/profile/export.
- iOS merge can combine duration/max/TTV/sample arrays from different versions without recomputing derived values.
- Watch synced values are not recomputed, which is good for preserving Watch authority, but weak validation means corrupted payloads can still enter.

### Subsurface Export

Source: `iOSApp/Services/SubsurfaceExportService.swift`

Found behavior:

- Header: `time_seconds,depth_m,temperature_c,entry_lat,entry_lon,exit_lat,exit_lon`.
- Elapsed seconds are based on first sample timestamp.
- Samples are exported in stored order.
- Empty sample write returns failure.
- `makeCSV` can still produce header-only CSV if called directly.

Correctness assessment:

- Export unit is metric, consistent with Subsurface-style CSV.
- Sample order is not sorted.
- Negative elapsed seconds can be exported if samples are out of order.
- Non-finite depth/temperature/GPS values are not filtered.
- Gas mix is not exported.
- Exported derived data may not match logbook fields if session data was merged inconsistently.

### Unit Conversion System

Source: `iOSApp/Utils/Formatters.swift`

Found constants:

- meters to feet: `3.280839895`.
- meters to kilometers: `0.001`.
- meters to miles: `0.000621371`.
- liters to cubic feet: `0.0353147`.
- Celsius to Fahrenheit: `C * 9 / 5 + 32`.

Correctness assessment:

- Display conversion formulas are standard.
- Conversion is presentation-only; stored values are metric.
- There is no round-trip conversion API.
- No centralized pressure conversion exists outside `GasPlan`.
- Temperature unit labels are plain `C` / `F` rather than degree symbols.
- No finite-value guard in formatters; NaN/infinity can render into UI strings.

### Route Distance / Bearing

Source: `iOSApp/Services/RouteSummaryService.swift`

Found formulas:

- Haversine distance with earth radius 6,371,000 m.
- Initial bearing normalized to 0..<360.

Correctness assessment:

- Formula is standard for GPS surface entry/exit estimates.
- No coordinate finite/range validation is performed here.
- Invalid GPS from sync/import can produce NaN outputs.

## Constants And Thresholds Found

- Planner depth validation: 1...100 m.
- Planner bottom time validation: 1...240 min.
- Gas O2 validation: 0.10...1.0.
- Gas PPO2 validation: 1.0...1.6.
- Default cylinder: 12 L.
- Default pressure: 200 bar start, 50 bar reserve.
- Default SAC/RMV: 18 L/min.
- Pressure conversion: 14.5038 psi/bar.
- Depth pressure approximation: 10 m/bar.
- Import max rows: 20,000.
- Import max depth: 200 m.
- Import max duration: 28,800 s / 480 min.
- Import temperature range: -2...40 C.
- Watch sync max payload: 512,000 bytes.
- Watch sync max samples: 20,000.
- Watch sync max depth: 350 m.
- Watch sync max duration: 86,400 s.
- Watch sync issued-at skew: 3,600 s.
- Local log documentation mentions latest 40 dives, but the iOS store does not enforce a 40-session cap in `DiveLogStore`.

## Correctness Assessment By Audit Area

### 1. Gas Planning Algorithms

Status: partial.

The simple gas estimate is coherent for a single metric cylinder:

`usable liters = cylinder liters * (start pressure bar - reserve pressure bar)`

`consumption liters = SAC l/min * ambient pressure bar * bottom minutes`

Missing or weak:

- No rock-bottom/minimum gas.
- No turn pressure.
- No buddy gas requirement.
- No deco gas consumption.
- No gas switch accounting.
- No multi-cylinder pressure/volume model.
- No service-level finite validation.
- Negative remaining gas is allowed numerically and only warned.

### 2. Buhlmann / No-Decompression / Dive Table Logic

Status: simplified reference, not full Buhlmann.

The code uses N2 half-times and coefficients, but does not implement a complete Buhlmann decompression model. It should not be presented as a validated ZH-L16C plan. Current warnings help, but the planner still displays "CURVA BUHLMANN ZH-L16C", "Deco Stops", "TTR", "CNS%" and "OTU".

### 3. PPO2 / PPN2 / Partial Pressure

Status: basic PPO2/MOD only.

PPO2 and MOD are present. PPN2, END and EAD are absent. Invalid gas mixes are handled in the UI, but not in service/model entry points.

### 4. Gas Density / Respirability

Status: not implemented.

No density or respirability calculation was found.

### 5. Dive Planner Inputs

Status: UI-validated, not service-validated.

The visible "Calcola Piano" flow blocks common invalid inputs, but persisted or programmatic invalid input can still be calculated by `PlannerStore.calculate()` and `PlannerService.makePlan()`.

### 6. Planner Output Consistency

Status: internally consistent within one calculation, not validated as decompression output.

`PlannerStore` computes both planner and Buhlmann outputs from current input. The issue is algorithmic authority, not synchronization between screens.

### 7. Logbook Calculations

Status: partial.

Imported CSV sessions recalculate average depth arithmetically, not time-weighted. Sync validation is too weak to guarantee finite samples and ordered timestamps. Merge can preserve inconsistent derived fields.

### 8. Subsurface Export

Status: functional but not robust.

Export refuses empty sample arrays, but does not sort, sanitize or validate samples. Out-of-order timestamps can generate negative elapsed seconds.

### 9. Unit Conversion

Status: display-only and mostly correct.

Core storage remains metric. Display conversion constants are reasonable. There is duplication and missing pressure/round-trip coverage.

### 10. Mathematical Robustness

Status: insufficient for release-hard status.

Primary risks:

- NaN/infinity can enter through decoded persisted/synced `DiveSession`.
- Planner services do not enforce finite input validation.
- Buhlmann and planner methods can return plausible-looking output for invalid inputs if UI validation is bypassed.
- Merge/import/export can produce inconsistent sessions.

### 11. Certification / Safety Positioning

Status: safety copy is present, algorithm labels still need tightening.

Positive:

- Legal onboarding says DIR Diving is not a dive computer.
- Planner requires safety acknowledgement.
- Planner warnings say simplified/non-certified.

Remaining risk:

- Labels like Buhlmann ZH-L16C, Deco Stops, TTR, CNS%, OTU can imply more authority than the current math supports.

### 12. Test Coverage

Status: missing.

No iOS XCTest target was found in `project.yml`, and no iOS algorithm tests were found.

## Safety-Critical Issues

### P0-01: Planner shows decompression-like outputs from heuristic logic

Files:

- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Views/PlannerView.swift`

Impact:

The app presents stops, TTR, CNS, OTU and Buhlmann-labelled curves, but the underlying logic is simplified and not a validated decompression model.

Recommended fix:

Either demote this to a clearly labelled "study/reference only" output with non-actionable terminology, or replace it with a tested decompression-planning engine with explicit scope, validation, references and test vectors.

### P0-02: Buhlmann implementation ignores helium while default gas is trimix

Files:

- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`

Impact:

Default bottom gas is `TX 18/45`, but `BuhlmannPlanner` only uses O2 to infer N2 and ignores helium compartments. A technical-looking trimix plan can produce NDL/deco outputs that are not physically complete.

Recommended fix:

For MAIN, either disable trimix-driven Buhlmann outputs or implement full N2/He tissue loading with validated coefficients and tests.

### P0-03: Service-level planner validation missing

Files:

- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Models/GasPlan.swift`

Impact:

UI validation is bypassable through persisted state, cloud KVS, future code paths or tests. Invalid values can produce plausible-looking outputs such as 999 min NDL.

Recommended fix:

Centralize validation in a `PlannerInputValidator` used by the UI and service before any calculation.

## Priority Ranking

### P0 Safety-Critical

1. Heuristic decompression-like planner output is too authoritative for the current math.
2. Trimix input is accepted while Buhlmann model ignores helium.
3. Planner service lacks canonical validation, allowing invalid persisted/programmatic inputs to calculate.

### P1 Mathematical Correctness

1. iOS import average depth is arithmetic, not time-weighted.
2. Import does not enforce monotonic sample timestamps.
3. Export does not sort or sanitize samples and may emit negative elapsed seconds.
4. Sync validation does not check finite values, sample timestamps, GPS validity or derived consistency.
5. Merge combines derived values and sample arrays without recomputation.
6. PPO2 display for stops clips actual PPO2 to `maxPPO2`, hiding over-limit values.
7. `GasMix.nitrogen` clamps invalid mixes to zero instead of preserving invalidity.
8. `BuhlmannPlanner` returns `999` for infinite control time without distinguishing "not computable" from "effectively no limit".

### P2 Data Integrity

1. iOS `DiveLogStore` does not enforce a documented 40-session cap.
2. GPS route calculations do not validate finite/ranged coordinates.
3. CSV export omits gas mix fields.
4. Import uses `horizontalAccuracy = -1` for imported GPS, which is semantically invalid for accuracy.
5. Demo dives contain one hardcoded TTV value inconsistent with the generic formula.

### P3 Maintainability

1. Unit conversion constants are split between `Formatters` and `GasPlan`.
2. Planner validation lives in `PlannerView`, not shared with services.
3. Safety-critical constants and formulas lack test-vector references.
4. There are no automated iOS algorithm tests.
5. Several strings show source-encoding artifacts in terminal display, which is not mathematical but can affect user trust.

## Edge Cases

### Required Scenarios

- Air dive 21% O2 at 30 m:
  - Current formula yields NDL about 16.3 min for a 20 min plan, so the heuristic deco branch is triggered.
  - This may be conservative, but the stop schedule is not Buhlmann-derived.

- Nitrox 32 at 30 m:
  - Current formula yields NDL about 28.0 min for a 20 min plan, so a 5 m / 3 min safety stop is shown.
  - MOD at PPO2 1.4 is about 33.8 m, so validation passes for 30 m.

- Invalid gas mix above 100%:
  - UI blocks O2 + He > 1.0.
  - Model/service can still be called directly with invalid values.

- Zero cylinder size:
  - UI blocks it.
  - Model `estimatedRemainingBar` uses `max(cylinderVolumeLiters, 0.1)`, which can hide invalidity if called directly.

- Zero SAC/RMV:
  - UI blocks it.
  - Service does not.

- Negative depth:
  - UI blocks depth below 1 m.
  - Service/model can calculate ambient pressure below 1 bar for direct calls.

- Very deep unsupported depth:
  - UI allows up to 100 m.
  - Import allows 200 m.
  - Watch sync validation allows 350 m.
  - These ranges are inconsistent and should be centralized.

- Metric to imperial round trip:
  - Display-only conversion exists; no round-trip API or tests.

- BAR to PSI round trip:
  - `GasPlan` uses 14.5038; no central pressure conversion or tests.

- Profile with missing samples:
  - Export write fails when sample array is empty.
  - Charts may show empty chart if a stored session has no samples.

- Profile with out-of-order timestamps:
  - Import accepts it.
  - Export can produce negative elapsed seconds.

- Buhlmann disabled / placeholder / unavailable:
  - No unavailable state exists; planner always calculates.

- Planner output with incomplete inputs:
  - UI validation blocks common incomplete inputs.
  - Service-level validation missing.

- Export with missing gas data:
  - Export ignores gas data entirely and still succeeds.

## Missing Tests

No existing automated tests were found for:

- Gas planning.
- SAC/RMV.
- Pressure conversion.
- PPO2/PPN2.
- MOD.
- Buhlmann/no-deco logic.
- NDL lookup.
- Logbook profile calculation.
- Subsurface export.
- Invalid inputs.

Recommended XCTest scenarios:

1. Air 21% at 30 m / 20 min returns expected NDL branch and warnings.
2. Nitrox 32 at 30 m validates MOD and no-deco branch behavior.
3. O2 + He > 100% rejected by shared validator.
4. O2 > 100% rejected by shared validator.
5. O2 <= 0 rejected by shared validator.
6. Zero cylinder size rejected.
7. Zero SAC/RMV rejected.
8. Negative depth rejected.
9. Depth above supported planner range rejected or marked unavailable.
10. Metric to imperial depth round trip within tolerance.
11. Bar to PSI round trip within tolerance.
12. Liters to cubic feet display conversion within tolerance.
13. Time-weighted average depth with irregular samples.
14. Imported CSV with missing samples returns empty-profile error.
15. Imported CSV with out-of-order timestamps is sorted or rejected.
16. Imported CSV with NaN/Infinity depth rejected.
17. Sync payload with NaN/Infinity derived values rejected.
18. Sync payload with sample timestamp outside session rejected.
19. Merge recomputes duration, max depth, average depth and TTV.
20. Empty export rejected.
21. Export with unsorted samples sorts or rejects.
22. Export with missing gas data either documents omission or emits explicit empty gas fields.
23. Buhlmann unavailable/placeholder mode returns a non-actionable state.
24. Planner with incomplete inputs never yields valid-looking plan output.
25. Deco stop PPO2 shows actual PPO2 and warning when over limit.

## Recommended Fixes

### Release-Hard Algorithm Path

1. Add a central iOS algorithm module:
   - `IOSAlgorithmConfiguration`
   - `IOSUnitConversions`
   - `PlannerInputValidator`
   - `GasMixValidator`
   - `DiveSessionAlgorithmValidator`
   - `DiveProfileMath`

2. Move all planner validation out of `PlannerView` and into shared services.

3. Decide product strategy for planner:
   - Option A: keep current simple planner but remove decompression-authoritative labels.
   - Option B: implement a validated planner with full N2/He Buhlmann, GF, tissue state, ascent/descent, gas switches and test vectors.

4. Make all planning functions return typed result states:
   - valid
   - invalid input
   - unsupported depth
   - insufficient model
   - warning/unsafe

5. Recompute imported/merged derived values from sorted, validated samples:
   - duration
   - max depth
   - time-weighted average depth
   - TTV/index
   - temperature average/min/max if supported

6. Harden sync/import/export:
   - finite checks
   - monotonic timestamps
   - range checks
   - sorted samples
   - no negative elapsed seconds
   - no header-only success path

7. Add an XCTest target for iOS algorithms.

## Final Audit Conclusion

The iOS Companion MAIN branch is not currently algorithmically release-hard. It is a strong UI/logbook companion with explicit safety copy, but the planner and decompression-adjacent outputs need either stronger mathematical implementation or stronger demotion to non-actionable reference material.

No code was modified during this audit. Only this report file was created.
