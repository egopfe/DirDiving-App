# iOS Companion MAIN Algorithm and Mathematical Functions Audit - Current

**Audit date:** 2026-06-03
**Repository:** DIR DIVING (`DirDiving-App`)
**Branch audited:** `main`
**Code baseline inspected after remote update:** `6a5054f`
**Target audited:** `DIRDiving iOS` only
**Mode:** Read-only static audit on Windows. No code, UI, UX, graphics, navigation, Watch, or experimental files were modified.

## Scope Confirmation

This audit is limited to the iOS Companion MAIN branch code included by `project.yml` in the `DIRDiving iOS` target. The project file excludes the experimental iOS files listed below from the MAIN iOS target:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

Apple Watch code was not audited except where needed to understand iOS-consumed sync models and payload validation. No Watch source file was modified.

## 1. Executive Summary

### Overall Verdict

The iOS Companion MAIN branch contains a substantive algorithmic layer: centralized unit conversions, planner input validation, gas mix validation, a ZHL-16C N2/He Buhlmann reference engine, time-weighted dive profile math, sync payload validation, CSV import/export guards, route math validation, and a broad iOS algorithm XCTest suite.

During publication, `origin/main` advanced to `6a5054f` with remediation changes that addressed the highest-priority audit findings around environment-aware MOD display, duplicate session collection integrity, and CSV temperature-column compatibility. This report therefore reflects the post-pull code baseline and separates remediated items from remaining P2/P3 hardening work.

The implementation is close to release-hard for internal validation. No P0/P1 algorithm blocker remains by static inspection, but several P2/P3 consistency, physical QA, and macOS build/test validation items should still be completed before calling the iOS Companion planner fully release-hard.

### Readiness Estimate

| Area | Static readiness | Notes |
|---|---:|---|
| Buhlmann ZHL-16C engine | 90% | Real N2/He tissue loading and GF-driven schedules are present; preview NDL environment seeding still needs correction. |
| Gas planning | 90% | Central validation is strong and MOD display/helper paths were made environment-aware in the remote remediation commit. |
| Logbook derived math | 92% | Time-weighted profile math is centralized and reused; manual/metadata edge cases are handled conservatively. |
| CSV import/export | 89% | Empty exports and invalid samples are rejected; optional temperature column support is now present; external compatibility still needs regression. |
| Watch sync validation on iOS | 91% | HMAC and mathematical validation are present; duplicate session collection integrity was hardened in the remote remediation commit. |
| Route/GPS math | 93% | Coordinates are validated, route distance uses Haversine, and bearing is normalized. |
| Unit conversion consistency | 89% | Central conversion helpers exist; pressure text fields still have unit-semantics ambiguity. |
| Automated algorithm tests | 90% | Large iOS algorithm suite exists; targeted gaps remain for the findings below. |

### Severity Summary

| Severity | Count | Summary |
|---|---:|---|
| CRITICAL | 0 | No immediate non-certified informational-app critical math blocker found by static inspection. |
| HIGH | 0 | Prior high-severity findings were remediated by `6a5054f`. |
| MEDIUM | 4 | Buhlmann preview NDL environment seeding, ascent/deco gas preflight coverage, END/EAD depth conversion, pressure entry unit semantics. |
| LOW | 3 | Localized service strings, Subsurface regression, bailout ledger clarity. |
| INFO | 2 | Oxygen exposure extrapolation positioning; arithmetic summary choices should remain documented. |

### Build/Test Status

This audit ran on Windows. Per project constraints, `xcodegen`, `xcodebuild`, and XCTest were not executed. The report is based on static source inspection, project file inspection, and test inventory.

## 2. Algorithm Inventory

### 2.1 Buhlmann Planning Engine

Primary files:

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/PlannerService.swift`

Algorithms found:

- ZHL-16C N2 and He half-times.
- ZHL-16C N2 and He a/b coefficients.
- Independent N2 and He tissue loading.
- Constant-depth exponential loading.
- Schreiner-style linear depth segment loading.
- Inspired inert gas pressure with water vapour subtraction.
- Environment-aware ambient pressure model.
- Mixed N2/He weighted a/b coefficients.
- Ceiling calculation with gradient factor.
- GF Low / GF High interpolation by stop depth.
- Tissue-state-based NDL search.
- Multigas ascent/decompression schedule generation.
- Gas switch selection with operating-depth validation.

Assessment:

- The engine is not a placeholder. It is a real Buhlmann reference engine.
- The app continues to position the output as non-certified reference planning, which is appropriate.
- Remaining risk is mostly around integration consistency, environment propagation, and preflight validation coverage.

### 2.2 Gas Planning and Gas Validation

Primary files:

- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`

Algorithms found:

- O2/He/N2 fraction validation.
- PPO2 calculation.
- MOD calculation.
- Minimum operating depth for hypoxic mixes.
- PPN2, EAD, END estimates.
- Gas density estimate from mix and ambient pressure.
- SAC/RMV gas use estimation.
- Engine schedule gas ledger.
- Rock-bottom style emergency reserve estimate.
- CNS and OTU estimates through oxygen exposure models.

Assessment:

- Validation is generally centralized and conservative.
- Current planner display paths now use environment-aware MOD helpers; legacy sea-level helpers remain documented for older callers.
- Gas planning output should continue to be described as a reference calculation, not certified decompression or gas-management advice.

### 2.3 Planner Inputs and Result States

Primary files:

- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Views/PlannerView.swift`

Algorithms and validation found:

- Depth/time range validation.
- Cylinder volume, SAC/RMV, start/reserve pressure validation.
- O2/He/GF validation.
- Typed planner result states including invalid input, unsupported gas/depth, PPO2 exceeded, MOD exceeded, gas density warning/danger, model incomplete, simplified reference, and unavailable states.

Assessment:

- Planner validation is strong and mostly no longer view-only.
- Additional boundary tests should verify that persisted/programmatic invalid input paths cannot bypass validator logic.

### 2.4 Logbook and Dive Profile Math

Primary files:

- `iOSApp/Utils/DiveProfileMath.swift`
- `iOSApp/Utils/DiveSessionAlgorithmValidator.swift`
- `iOSApp/Utils/DiveSessionMerge.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Utils/IOSDiveLogbookPolicy.swift`

Algorithms found:

- Sample sanitization.
- Timestamp sorting and same-timestamp deduplication.
- Time-weighted average depth.
- Max depth recomputation.
- Duration recomputation.
- Canonical DIR Diving TTV/index: average depth plus duration minutes.
- Temperature average/min/max over valid samples.
- GPS validation.
- 40-session cap policy.
- Merge recomputation from canonical sample sets.

Assessment:

- The derived math layer is one of the strongest parts of the iOS codebase.
- Duplicate session collection integrity has been hardened; continue paired-device/iCloud regression testing.

### 2.5 CSV Import and Export

Primary files:

- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Views/CSVImportPanel.swift`

Algorithms found:

- CSV parser with quote handling.
- File size and row length guardrails.
- Required time/depth headers.
- Invalid row rejection.
- Timestamp normalization.
- Depth and temperature sanitization.
- GPS validation.
- Empty-profile export rejection.
- Monotonic elapsed-seconds export.

Assessment:

- Empty export and malformed depth values are guarded.
- Compatibility should be tested against real external CSV/Subsurface-style inputs.
- `temperature_c` is currently mandatory even though temperature values themselves can be optional.

### 2.6 Sync, Cloud Merge, and Data Integrity

Primary files:

- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Utils/WatchSyncSessionDiff.swift`
- `iOSApp/Utils/DiveSessionMergeConflict.swift`
- `iOSApp/Services/DiveLogStore.swift`

Algorithms found:

- HMAC-protected Watch payloads.
- Payload-size limit.
- Issued-at skew guard.
- Peer-secret checks.
- Session normalization before storage.
- Conflict detection.
- Tombstone-aware session merging.
- Offline outbound queue.

Assessment:

- Watch sync math/data validation is broadly robust.
- Duplicate IDs inside cloud/conflict arrays can still trigger `Dictionary(uniqueKeysWithValues:)` traps.

### 2.7 Route and GPS Math

Primary files:

- `iOSApp/Services/RouteSummaryService.swift`
- `iOSApp/Utils/RouteSummaryAggregation.swift`
- `iOSApp/Models/GPSPoint.swift`

Algorithms found:

- Coordinate finite/range validation.
- Haversine distance.
- Bearing normalization to `0..<360`.
- Identical-point handling.
- Aggregated route summary.

Assessment:

- Route math is conservative and finite-safe.

### 2.8 Unit Conversion and Display Formatting

Primary files:

- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/Formatters.swift`
- `iOSApp/Utils/PressureDisplayMath.swift`

Algorithms found:

- Meters/feet.
- Bar/psi.
- Liters/cubic feet.
- Celsius/Fahrenheit.
- M/min and ft/min.
- Ambient pressure approximation.

Assessment:

- Core conversion constants are centralized.
- Manual pressure-entry text does not retain its original unit, so display semantics can become ambiguous after unit preference changes.

## 3. Findings by Family

### IOS-AUDIT-001 - Environment-aware MOD mismatch in helper/display paths

**Severity:** Remediated P1
**Family:** Planner, gas planning, UI-adjacent math display
**Files/screens:** `iOSApp/Models/GasPlan.swift`, `iOSApp/Views/PlannerGasMixCard.swift`, `iOSApp/Views/PlannerView.swift`, `iOSApp/Services/GasPlanningService.swift`, `iOSApp/Services/PlannerGasSchedule.swift`

Status after pulling `origin/main` at `6a5054f`: remediated. `GasMix` and `PlannerCylinderEntry` now expose environment-aware MOD helpers, planner cards receive `plannerEnvironment`, cylinder rows use `entry.modMeters(environment:)`, and `GasPlanningService` uses environment-aware MOD state checks.

Legacy sea-level helpers remain for older callers, but they are documented as sea-level convenience paths and should not be used for current planner warnings.

Impact:

- The prior environment-display mismatch is closed by static inspection.
- Keep regression tests for altitude/freshwater MOD consistency so future UI or helper changes do not regress to sea-level defaults.

Recommended fix:

- Add/keep tests for freshwater/altitude MOD display consistency and switch-depth warnings.

### IOS-AUDIT-002 - Duplicate cloud/session ID crash risk remediated

**Severity:** Remediated P1
**Family:** Cloud merge, sync conflict detection, data integrity
**Files:** `iOSApp/Utils/DiveSessionMergeConflict.swift`, `iOSApp/Services/DiveLogStore.swift`, `iOSApp/Utils/DiveSessionCollectionIntegrity.swift`

Status after pulling `origin/main` at `6a5054f`: remediated. Duplicate session IDs are collapsed through `DiveSessionCollectionIntegrity.deduplicated(_:)`, duplicate IDs are surfaced as conflict metadata, and `DiveLogStore` now uses a safe dictionary builder for conflict snapshots.

Impact:

- The prior crash risk is closed by static inspection.
- Device/iCloud regression tests are still recommended.

Recommended fix:

- Keep tests for duplicate cloud IDs, duplicate local IDs, and mixed tombstone/live duplicates.

### IOS-AUDIT-003 - Buhlmann preview NDL/curve can use sea-level tissue saturation at non-sea-level environments

**Severity:** MEDIUM
**Family:** Buhlmann planner integration
**File:** `iOSApp/Services/BuhlmannPlanner.swift`

`BuhlmannPlanner.enginePlan(input:)` seeds initial tissue state with `PlannerEnvironment.surfacePressureBar`. However, `BuhlmannPlanner.plan(depthMeters:bottomGas:environment:gfHigh:)` and `ndlCurve` call `BuhlmannEngine.noDecompressionLimit(... plannerEnvironment: environment)` without explicitly passing an environment-saturated initial tissue state.

Impact:

- At altitude or freshwater/salinity variants, preview NDL/curve values can diverge from the plan engine path.
- Sea-level use is likely unaffected.

Recommended fix:

- Pass `initialTissueState: .airSaturated(surfacePressureBar: environment.surfacePressureBar)` in preview NDL and curve calls.
- Add tests comparing preview NDL with engine plan NDL at altitude and sea level.

### IOS-AUDIT-004 - Full ascent/deco gas envelope is not completely preflighted

**Severity:** MEDIUM
**Family:** Buhlmann multigas validation
**File:** `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`

`BuhlmannEngine.validateGasUseRanges` preflights descent and bottom segment operational ranges. Runtime ascent/decompression gas use is still protected by `ascendSegment`, which can fail with `.gasNotOperationalInSegment`, but not all possible deco/ascent gas-envelope conflicts are surfaced before schedule propagation starts.

Impact:

- Invalid or borderline multigas schedules should fail closed, but the error can occur late in propagation.
- Better preflight would improve planner predictability and error messaging.

Recommended fix:

- Add a preflight pass that checks every configured switch gas and expected usable depth band against MOD and minimum operating depth.
- Add tests for gas switch too deep, hypoxic gas too shallow, and oxygen/EAN50 switch depth boundaries.

### IOS-AUDIT-005 - END/EAD depth conversion uses fixed 10 m/bar after environment-aware pressure

**Severity:** MEDIUM
**Family:** Gas planning, environment consistency
**File:** `iOSApp/Services/GasPlanningService.swift`

`equivalentNarcoticDepth` and `equivalentAirDepth` use environment-aware ambient pressure, but convert equivalent pressure back to depth using a fixed `* 10.0` approximation rather than `AmbientPressureModel.depthMeters(...)`.

Impact:

- Sea-level saltwater values are plausible.
- Altitude/freshwater/salinity-adjusted outputs can diverge from the rest of the planner environment model.

Recommended fix:

- Convert equivalent ambient pressure back to depth through the active `AmbientPressureModel`.
- Add tests for END/EAD in sea-level saltwater and an altitude/freshwater environment.

### IOS-AUDIT-006 - Manual pressure text fields do not retain source unit

**Severity:** MEDIUM
**Family:** Manual dive metadata, unit semantics
**Files:** `iOSApp/Views/ManualDiveEditorView.swift`, `iOSApp/Utils/PressureDisplayMath.swift`, `iOSApp/Models/DiveSession.swift`

Manual pressure values are stored as text fields. `PressureDisplayMath` computes consumed pressure from those strings and labels the result with the current unit preference. If a user entered bar values and later switches to imperial, the displayed consumed pressure can be relabeled as psi.

Impact:

- The stored values are not converted incorrectly, but the unit label can become misleading.
- This is not a core planner math bug, but it affects logbook correctness perception.

Recommended fix:

- Store the unit used when pressure values are entered, or normalize manual pressure to a canonical numeric unit.
- Add regression tests for manual pressure display after unit preference changes.

### IOS-AUDIT-007 - Optional CSV `temperature_c` support remediated

**Severity:** Remediated P3
**Family:** CSV import compatibility
**File:** `iOSApp/Services/DiveImportService.swift`

Status after pulling `origin/main` at `6a5054f`: remediated. Import now requires `time_seconds` and `depth_m`, while `temperature_c` is optional.

Impact:

- Broader CSV compatibility is now supported by static inspection.

Recommended fix:

- Add tests for CSV without temperature column and CSV with invalid temperature data.

### IOS-AUDIT-008 - Hardcoded service/status strings remain

**Severity:** LOW
**Family:** Localization and status output
**Files:** `iOSApp/Services/BuhlmannPlanner.swift`, `iOSApp/Services/DiveImportService.swift`, `iOSApp/Services/SubsurfaceExportService.swift`, `iOSApp/Services/WatchDiveSyncCodec.swift`, `iOSApp/Services/WatchSyncService.swift`

Several algorithm/service outputs still contain hardcoded Italian or English strings. Many are not mathematical bugs, but they affect localized error interpretation.

Impact:

- EN/IT mode can show mixed-language service errors.
- Safety and planner warning clarity can vary by locale.

Recommended fix:

- Move service-facing status copy to localization keys while keeping algorithmic states typed and language-neutral.

### IOS-AUDIT-009 - Subsurface export compatibility needs external regression

**Severity:** LOW
**Family:** Export interoperability
**File:** `iOSApp/Services/SubsurfaceExportService.swift`

The export path is finite-safe and rejects empty profiles, but the produced CSV should be verified against current Subsurface import behavior and expected metadata handling.

Impact:

- The export is internally consistent, but external import fidelity is not proven by static inspection.

Recommended fix:

- Add external-tool regression fixtures or documented manual Subsurface import validation.

### IOS-AUDIT-010 - Analysis session averages are arithmetic over sessions

**Severity:** INFO
**Family:** Analytics semantics
**File:** `iOSApp/Utils/AnalysisDashboardMath.swift`

Dashboard SAC and temperature summaries are arithmetic across sessions rather than duration-weighted. This can be an intentional product choice, but should remain documented.

Impact:

- No finite-safety issue.
- Users may interpret averages differently.

Recommended fix:

- Document the aggregation semantics, or add separate weighted metrics if desired.

### IOS-AUDIT-011 - Oxygen exposure extrapolates over high PPO2 while relying on separate warnings

**Severity:** INFO
**Family:** Oxygen exposure estimates
**File:** `iOSApp/Services/OxygenExposureModels.swift`

PPO2 values above NOAA table limits are extrapolated/clamped for exposure accumulation. Planner state warnings should already flag PPO2 over-limit situations.

Impact:

- Exposure estimates remain finite, but high-PPO2 schedules must never appear normal.

Recommended fix:

- Keep PPO2Exceeded state dominant in warning ordering.
- Add tests that high PPO2 generates both finite exposure values and a clear over-limit state.

### IOS-AUDIT-012 - Unused/bailout cylinders are not part of the main consumption ledger

**Severity:** LOW
**Family:** Gas planning ledger semantics
**File:** `iOSApp/Services/ScheduleGasConsumptionService.swift`

The engine ledger accounts for gases used in the generated schedule. Bailout cylinders are intentionally separate and not included as consumed schedule gases.

Impact:

- This is acceptable if the UI and docs make bailout availability distinct from planned gas consumption.

Recommended fix:

- Keep bailout separate, but add tests/documentation confirming planned-gas ledger vs bailout reserve semantics.

## 4. Edge Case Matrix

| Edge case | Current behavior | Risk | Recommended test/fix |
|---|---|---|---|
| Negative depth planner input | Rejected by shared validation | Low | Keep boundary tests. |
| Depth above planner max | Rejected/unavailable | Low | Keep unsupported-depth tests. |
| Depth above import/export max | Sanitizer rejects profiles beyond cap | Low | Verify 350 m cap consistency across iOS paths. |
| O2 <= 0 or O2 > 1 | Rejected | Low | Existing gas validator tests should remain. |
| O2 + He > 1 | Rejected | Low | Existing trimix invalid tests should remain. |
| Hypoxic gas at surface | Engine validates minimum operating depth | Medium | Add more switch-depth boundary tests. |
| Deco gas switch too deep | Runtime and validator checks exist | Medium | Add preflight tests across all switch gases. |
| Altitude/freshwater planner | Environment model exists | Medium | Fix NDL preview and MOD helper environment propagation. |
| Zero/negative segment duration | Engine returns/fails safely | Low | Keep numerical robustness tests. |
| Duplicate cloud session IDs | Deduplicated before conflict dictionaries | Low | Keep duplicate-ID regression tests. |
| Empty export profile | Rejected | Low | Keep export tests. |
| CSV without temperature column | Accepted if required time/depth columns are present | Low | Keep optional-temperature regression tests. |
| Invalid GPS | Sanitized/rejected | Low | Keep route/import/sync tests. |
| Identical route points | Distance zero, bearing unavailable | Low | Keep route tests. |
| Manual pressure after unit switch | Unit label can be misleading | Medium | Store pressure unit or canonicalize numeric pressure. |

## 5. Unit and Integration Test Plan

### Buhlmann Engine Tests

- Verify NDL preview equals `enginePlan` NDL at sea level and altitude.
- Verify GF 30/70 remains more conservative than GF 50/80 for representative profiles.
- Verify switch gases are preflighted before schedule propagation.
- Verify oxygen and EAN50 switch-depth boundaries.
- Verify hypoxic trimix minimum operating depth boundaries.
- Verify no compartment pressure becomes NaN, infinite, or negative from valid inputs.

### Gas Planning Tests

- Verify all MOD displays and helper warnings use the same `PlannerEnvironment`.
- Verify actual PPO2 and MODExceeded state align for freshwater/altitude cases.
- Verify END/EAD convert equivalent pressure back through `AmbientPressureModel`.
- Verify gas density warning/danger boundaries.
- Verify bailout cylinders remain separate from scheduled gas consumption.

### Logbook and Manual Entry Tests

- Verify manual pressure values retain correct unit semantics after user preference changes.
- Verify metadata-only manual dives keep canonical TTV/index.
- Verify 41st session pruning remains newest-40 deterministic.
- Verify time-weighted average remains stable with irregular sample spacing.

### Import/Export Tests

- CSV without `temperature_c` imports if time/depth are valid.
- CSV with invalid finite temperature rejects or skips rows according to documented policy.
- Export never succeeds with header-only data.
- Export elapsed seconds remain monotonic and nonnegative.
- External Subsurface import fixture round-trip preserves depth/time profile.

### Sync and Cloud Tests

- Duplicate cloud session IDs do not crash.
- Duplicate local session IDs are merged or rejected deterministically.
- Tombstones beat live duplicates according to policy.
- Corrupted sample arrays are rejected before logbook insertion.
- Valid signature with invalid math payload still fails validation.

## 6. Paired Watch/iPhone Test Plan

These checks require physical devices or macOS/iOS simulator infrastructure and were not executed during this Windows static audit.

| Scenario | Expected result |
---|---|
| Watch records valid dive and syncs to iPhone | iOS log shows recomputed finite duration, max depth, average depth, TTV, GPS, and profile samples. |
| Watch sends corrupted sample payload | iOS rejects before storage and reports sync failure. |
| Watch sends duplicate session update | iOS merges deterministically and recomputes derived fields. |
| iPhone pushes log/session update to Watch | Watch receives only validated sessions. |
| Paired devices offline then reconnect | Retry queue drains without duplicate logs. |
| Tombstone/delete sync | Deleted sessions stay deleted across both devices. |
| Unit preference mismatch | iOS display converts values without altering canonical stored metric values. |
| No peer secret / reset trust | Sync fails closed and can be repaired through documented trust reset flow. |

## 7. CSV Import/Export Regression Plan

1. Import a minimal valid CSV with `time_seconds` and `depth_m` only.
2. Import a full CSV with temperature, GPS, notes, and metadata.
3. Import CSV with out-of-order rows and verify deterministic sorting or rejection.
4. Import CSV with NaN/infinity tokens and verify rejection.
5. Import CSV with row count above `maxProfileSampleCount` and verify rejection.
6. Export a valid synced Watch session and verify:
   - nonempty sample profile
   - monotonic elapsed seconds
   - finite depth and temperature fields
   - stable metadata headers
7. Attempt export for empty sample profile and verify failure.
8. Import exported CSV into Subsurface or a documented compatibility harness.

## 8. Cloud Merge Validation Plan

1. Cloud payload with duplicate live sessions sharing the same ID.
2. Cloud payload with duplicate tombstones sharing the same ID.
3. Local live session versus cloud tombstone.
4. Local tombstone versus cloud live session.
5. Same session with complementary samples.
6. Same session with conflicting samples and metadata.
7. Corrupted cloud payload containing invalid GPS or invalid depth.
8. Decode failure of cloud payload.
9. iCloud unavailable state.
10. Two-device concurrent edit followed by conflict resolution.

Acceptance requirement:

- No merge path may crash.
- All accepted sessions must pass `DiveSessionAlgorithmValidator`.
- All stored sessions must respect the newest-40 logbook cap.

## 9. Planner Boundary Validation Plan

| Boundary | Expected result |
|---|---|
| Depth 0 m | Invalid or unavailable for dive plan. |
| Depth 0.1 m | Valid only if project considers it meaningful minimum planner depth. |
| Depth 120 m | Upper supported planner boundary. |
| Depth 120.01 m | Unsupported depth. |
| Bottom time 0 | Invalid. |
| Bottom time 600 min | Upper supported boundary. |
| O2 0 | Invalid. |
| O2 1.0 | Valid only within PPO2/MOD constraints. |
| He < 0 | Invalid. |
| O2 + He = 1 | Valid if PPO2/MOD/min-depth constraints pass. |
| O2 + He > 1 | Invalid. |
| GF low = GF high | Invalid. |
| GF low > GF high | Invalid. |
| PPO2 exactly max | Allowed if policy says inclusive. |
| PPO2 above max | PPO2Exceeded / invalid operational state. |
| Hypoxic mix at surface | Gas not operational. |
| Deco gas switch above MOD | Invalid switch. |
| Freshwater/altitude environment | All MOD, pressure, NDL, END/EAD paths must use same environment. |

## 10. Prioritized Roadmap

### P0 - Must Fix Before External Safety Claims

No P0 issues were found in this static audit, assuming the app remains explicitly non-certified and reference-only.

### P1 - Must Fix Before Calling iOS MAIN Fully Algorithmically Release-Hard

No open P1 item remains by static inspection after pulling remediation commit `6a5054f`.

### P2 - Must Fix Before Broad TestFlight

1. Pass environment-saturated initial tissue to preview NDL/curve paths.
2. Add or verify full ascent/deco gas-envelope preflight coverage.
3. Convert END/EAD equivalent pressure back through `AmbientPressureModel`.
4. Preserve or canonicalize manual pressure-entry units.
5. Run macOS `xcodegen`, iOS build, and iOS algorithm XCTest suite.

### P3 - Must Fix Before App Store Submission

1. Add external Subsurface import/export regression sign-off.
2. Localize remaining service/status strings.
3. Document analysis average semantics.
4. Document planned-gas ledger versus bailout reserve semantics.

### P4 - Post-Release Hardening

1. Add additional external Buhlmann fixture comparisons from independent tools.
2. Add field tests for paired Watch/iPhone sync after real dives.
3. Add richer diagnostics for cloud conflict sources.

## 11. Final Verdict

### Ready to compile?

Not verified in this audit because the environment is Windows and Apple build tools were intentionally not run. Static inspection did not find obvious iOS compile blockers in the audited algorithm files, but macOS build validation is still required.

### Ready for internal algorithm QA?

Yes. The codebase has enough validators and tests to support meaningful internal QA. The remaining P2/P3 items should be part of the next QA/fix pass.

### Ready to call the iOS Companion MAIN planner algorithmically release-hard?

Close, but not fully signed off. The prior P1 environment-display and duplicate-ID risks are remediated by `6a5054f`; remaining P2 items should still be closed and macOS build/tests must be run before a 100% release-hard claim.

### Ready for TestFlight?

Not from this audit alone. Before TestFlight, run macOS build/tests and fix or explicitly sign off the remaining P2 roadmap items.

### Ready for App Store?

Not yet. App Store readiness still requires physical paired-device QA, external export/import validation, localization cleanup, and continued strict non-certified safety positioning.

### Bottom Line

The iOS MAIN branch is in a strong state and no placeholder-only planner was found. The Buhlmann and gas-planning system is real and mostly well isolated from UI. After pulling the remote remediation commit, the highest-priority issues are closed by static inspection. The remaining work is not a rewrite: it is targeted P2/P3 integration hardening, physical/macOS validation, and regression coverage.
