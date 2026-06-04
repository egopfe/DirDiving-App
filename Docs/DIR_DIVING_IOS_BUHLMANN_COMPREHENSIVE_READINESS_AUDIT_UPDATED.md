# DIR Diving iOS Buhlmann Comprehensive Readiness Audit - Updated

Date: 2026-06-04  
Repository: `https://github.com/egopfe/DirDiving-App.git`  
Branch audited: `main`  
Latest local/remote HEAD before report creation: `40bf110` - `docs: add security exploit remediation plan`  
Scope: iOS Companion MAIN branch, Planner only  
Execution mode: Windows static analysis only

## Executive Verdict

Status: **Partially ready**

The iOS Companion Planner now contains a substantial iOS-only Buhlmann ZHL-16C multigas reference engine with nitrogen, helium, trimix, gradient factors, decompression stops, gas switching, validation layers, schedule gas consumption, CNS reporting, and localized planner copy.

The Buhlmann decompression core appears broadly coherent from static inspection and is much stronger than the earlier simplified/reference-only planner. However, the planner should **not** yet be treated as fully release-hard for internal validation because one oxygen-exposure issue remains safety-significant:

- **P0/P1: OTU constant-depth calculation appears inverted** in `OxygenExposureModels.swift`, and current tests/documentation encode the same formula. This can materially understate OTU exposure at elevated PPO2.

The CNS model and the specific **CNS Descent + Bottom 15% warning** are implemented, localized, visible, and test-covered. The remaining blockers are primarily oxygen toxicity correctness, external validation, macOS build/test execution on current HEAD, and a few planner realism/documentation refinements.

## Scope Confirmation

This audit inspected only the iOS Companion MAIN planner-related code and documentation.

Confirmed constraints:

- No Apple Watch code was modified.
- No watchOS targets were modified.
- No experimental branch/files were modified.
- No UI, graphics, colors, navigation, layout, icons, animations, or business logic were changed.
- No fixes were implemented.
- No commit or push was performed.
- On Windows, `xcodegen` and `xcodebuild` were not run.

The audit used static inspection of Swift, localization files, tests, `project.yml`, and documentation.

## Repository State

Preflight findings:

- Current branch: `main`
- Upstream: `origin/main`
- Divergence before report creation: `0 ahead / 0 behind`
- Remote: `https://github.com/egopfe/DirDiving-App.git`
- Latest commit before report creation: `40bf11025f0254166435e7ac0e7e3622e8e0f20b`
- Operating system: Windows 10
- `xcodegen`: unavailable on this host
- `xcodebuild`: unavailable on this host

`project.yml` confirms:

- iOS target: `DIRDiving iOS`
- iOS bundle ID: `com.egopfe.dirdiving.ios`
- iOS sources: `iOSApp`
- iOS algorithm test target: `DIRDiving iOS Algorithm Tests`
- Experimental iOS files are explicitly excluded from the main iOS target.
- Watch targets exist, but were outside this audit scope.

## Files Inspected

Core Buhlmann engine:

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTypes.swift`

Planner services and models:

- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/OxygenExposureModels.swift`
- `iOSApp/Models/PlannerEnvironment.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/PlanCalculationCompleteness.swift`

Planner UI and localization:

- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

Tests:

- `Tests/iOSAlgorithmTests/*`
- `Tests/iOSAlgorithmTests/Fixtures/*`

Documentation:

- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`
- `Docs/BUILD_VALIDATION.md`
- `Docs/IOS_PLANNER_CNS_UI_UX_FIX_VERIFICATION.md`

## Buhlmann Mathematical Model Assessment

### ZHL-16C Constants

Assessment: **Mostly ready**

Evidence:

- 16 nitrogen half-times are present.
- 16 helium half-times are present.
- 16 nitrogen `a/b` coefficients are present.
- 16 helium `a/b` coefficients are present.
- `BuhlmannConstants.compartmentCount` is set to 16.
- Water vapor pressure is centralized as `0.0627 bar`.
- Surface pressure is centralized as `1.01325 bar`.
- Saltwater/freshwater density is centralized through planner environment handling.

The constants are isolated in `BuhlmannConstants.swift`, which is the correct architecture for release-hard validation.

Remaining requirement:

- Keep an external reference table in documentation and test fixtures to prove exact constant provenance and tolerance.

### Ambient Pressure / Inspired Gas Pressure

Assessment: **Ready for internal validation**

Evidence:

- `PlannerEnvironment` models salinity and altitude.
- `AmbientPressureModel` converts depth to ambient pressure using environment.
- Inspired inert gas pressure subtracts water vapor pressure.
- Oxygen is not loaded as inert gas.
- N2 and He inspired pressures are independent.

The previous mismatch between air saturation at `1.0 bar` and sea-level `1.01325 bar` appears fixed: `BuhlmannTissueModel.airSaturated()` now uses `BuhlmannConstants.seaLevelSurfacePressureBar`.

### Tissue Loading

Assessment: **Ready for internal validation**

Evidence:

- Independent nitrogen and helium compartment pressures exist.
- Constant-depth exponential loading is implemented.
- Linear ascent/descent loading uses Schreiner-style segment loading.
- Gas switches preserve tissue state and change inspired gas pressure for subsequent segments.
- Zero/negative durations are guarded by planner/engine validation paths.

Static inspection did not find obvious NaN/infinity propagation in the core tissue update paths for valid input.

### Mixed N2 / He Coefficients

Assessment: **Ready for internal validation**

Evidence:

- Mixed coefficients are weighted by N2 and He tissue pressure contribution.
- Near-zero inert pressure is protected by epsilon logic.
- Ceiling calculation uses mixed coefficients rather than nitrogen-only coefficients.

Remaining requirement:

- Continue validating mixed N2/He ceilings against external fixtures, especially low-inert-pressure edge cases.

### Ceiling / Gradient Factors / Decompression Stops

Assessment: **Ready for internal validation, not yet externally validated**

Evidence:

- Ceiling calculation is compartment-based.
- GF Low and GF High are validated.
- Decompression schedule is generated from tissue ceilings, not static stop templates.
- GF affects ceilings and stop generation rather than only labels.
- `GF 30/70` vs `GF 50/80` comparisons are tested.
- `PlanCalculationCompleteness` prevents partial schedules from being shown as complete when calculation limits are reached.

Remaining requirement:

- External reference validation is still pending before public release claims.

### NDL Calculation

Assessment: **Ready for internal validation**

Evidence:

- NDL is tissue-state based.
- No fake `999 min` NDL fallback was found in the current engine path.
- NDL search is bounded by a maximum bottom time.
- Invalid or incomplete states use typed result states rather than authoritative-looking outputs.

Remaining requirement:

- Compare NDL values against known reference planners across air, nitrox, and trimix profiles.

### Multigas / Trimix / Helium

Assessment: **Substantially implemented**

Evidence:

- Air, nitrox, trimix, oxygen-rich deco gas, and helium-bearing gases are represented.
- Helium tissue loading is supported.
- Trimix no longer has to fall back to `unsupportedTrimix` when mathematically valid.
- Multiple cylinders and gases are modeled.
- Deco gas switch validation exists.
- Gas switch depth, MOD, hypoxic minimum operating depth, and duplicate gas composition checks exist.

Remaining limitation:

- Travel gas to bottom gas switch modeling appears simplified. The schedule can model travel gases on descent until the maximum depth before switching to bottom gas. There is no explicit bottom-gas switch depth separate from maximum depth. This can distort tissue loading and gas consumption for some hypoxic trimix/travel-gas protocols.

## CNS / OTU / 15% Rule Assessment

### Is Total CNS Calculated?

Assessment: **Yes**

Evidence:

- `OxygenExposureModel.from(segments:carryover:)` integrates oxygen exposure over the planner schedule.
- `GasPlanningService.analyze(input:enginePlan:)` computes oxygen exposure from `enginePlan.segments`.
- `TechnicalGasAnalysis.cnsPercent` stores the full schedule CNS estimate.

### Does Total CNS Include Decompression?

Assessment: **Yes**

Evidence:

- The full oxygen exposure model receives `enginePlan.segments`, which include descent, bottom, ascent, gas switch, and stop phases.
- Deco stop and ascent exposure therefore contribute to `cnsPercent`.
- Planner UI labels this value as `planner.metric.cns_full_plan`.

### Is CNS Descent + Bottom Calculated Separately?

Assessment: **Yes**

Evidence:

- `OxygenExposureModel.cnsPercentDescentAndBottom(segments:)` filters only `.descent` and `.bottom` segments.
- `GasPlanningService.resolvedCNSDescentBottomPercent(...)` exposes this value.
- `TechnicalGasAnalysis.cnsDescentBottomPercent` stores it.

### Is Decompression Excluded From CNS Descent + Bottom?

Assessment: **Yes**

Evidence:

- The filter includes only `.descent` and `.bottom`.
- Test coverage explicitly checks that ascent/deco/gas switch segments do not increase descent+bottom CNS.

### Does the 15% Rule Exist?

Assessment: **Yes**

Evidence:

- `CNSDescentBottomPlannerRule.warningThresholdPercent = 15.0`
- `exceedsPlannerThreshold` returns true only when the value is greater than 15%.
- Tests verify that exactly 15% is acceptable and 15.01% exceeds the threshold.

### Is the Warning Red / Visible?

Assessment: **Yes, from static UI inspection**

Evidence:

- `PlannerView` renders a red warning tile/banner when `cnsDescentBottomWarningActive` is true.
- The warning includes localized title, hint, red styling, and accessibility label/hint.

### Is the CNS / OTU UI Clear?

Assessment: **Mostly yes**

The UI distinguishes:

- CNS Preview
- CNS Full Plan
- CNS Descent + Bottom
- CNS Ascent / Deco estimate
- OTU
- Daily CNS / OTU context
- Air-break note
- Reference-only oxygen exposure disclaimer

This is a strong UX improvement. The main copy gap is that exported/share text still uses a generic `CNS` label and should mirror the UI by saying `CNS full plan` or equivalent.

### OTU Correctness

Assessment: **Not ready**

Finding:

`OTUModel.otuIncrementConstant(ppO2:minutes:)` appears to implement:

```swift
minutes * pow((0.5 / (ppO2 - 0.5)), 5.0 / 6.0)
```

For PPO2 greater than 1.0, this decreases exposure as PPO2 rises, which is opposite to the common Lambertsen UPTD/OTU relationship. The expected constant-depth form is generally:

```swift
minutes * pow(((ppO2 - 0.5) / 0.5), 5.0 / 6.0)
```

Impact:

- OTU can be materially understated for high PPO2.
- Daily/weekly OTU warnings may be delayed.
- Documentation currently repeats the same inverted formula.
- Existing tests compare against the implemented formula, so they do not catch the issue.

Priority: **P0/P1**

## Algorithmic Consistency Assessment

### Planner Input Validation

Assessment: **Strong**

Evidence:

- `PlannerInputValidator` validates depth, average depth, bottom time, SAC/RMV, emergency SAC, team size, temperature, gradient factors, environment, gas density, cylinders, team member SAC/cylinders, and gas mixes.
- `GasMixValidator` validates O2, He, O2+He, max PPO2, MOD, density, and hypoxic minimum operating depth.
- `PlannerService` fails closed when validation fails.

Remaining issue:

- Some validator messages remain hardcoded in Italian and may surface in user-facing states or generated briefings.

### Gas Planning

Assessment: **Strong, with known modeling limitations**

Evidence:

- Gas consumption is schedule-aware through `ScheduleGasConsumptionService`.
- Per-cylinder ledgers are stable and role-aware.
- Negative or insufficient gas states are represented as warnings/result states.
- PPO2 is exposed as actual PPO2, not clipped.
- END, EAD, PPN2, gas density, CNS, OTU, and reserve logic exist.

Remaining limitations:

- Bailout cylinders are schedule-only and not part of decompression tissue optimization.
- Travel-to-bottom switch depth modeling is simplified.

### Planner Result States

Assessment: **Strong**

Evidence:

- Typed states such as invalid input, simplified reference, unavailable, PPO2 exceeded, MOD exceeded, insufficient gas, below reserve, gas density warnings, and calculation limits are present.
- The planner avoids presenting invalid states as authoritative decompression plans.

### Logbook / Import / Export / Sync

Assessment: **Previously hardened, not the main focus of this planner audit**

The current iOS algorithm hardening appears to include central validation and time-weighted math. No obvious planner regression was found from static inspection, but this audit focused on planner/Buhlmann readiness rather than full import/export revalidation.

## Numerical Robustness Assessment

Strong points:

- Buhlmann constants and pressure conversion are centralized.
- Gas fractions are validated before use.
- Invalid gas compositions fail closed.
- PPO2, MOD, hypoxic minimum depth, gas density, and GF values are validated.
- No fake 999-minute NDL was found.
- Schedule completion flags prevent partial results from looking complete.

Remaining risks:

- OTU constant-depth formula appears inverted.
- External fixture validation is still pending.
- Travel gas scheduling may be too simplified for some trimix descent protocols.
- Current Windows environment could not run XCTest or Swift compiler checks.

## UX/UI Readiness Assessment

Assessment: **Mostly ready**

The Planner UI remains aligned with the premium dark marine DIR Diving design language. The audit did not identify visual redesign regressions from static inspection.

Positive findings:

- Full CNS and CNS Descent + Bottom labels are distinct.
- CNS warning is red, visible, and localized.
- Technical metrics are grouped coherently.
- The planner uses reference-only disclaimer language.
- The More/settings section contains a CNS Descent + Bottom check toggle.
- Accessibility labels and hints exist for the CNS warning.

UX gaps:

- Share/export text should distinguish full-plan CNS from preview or descent+bottom CNS.
- Validation strings should be localized consistently.
- Physical-device QA is still required for Dynamic Type, VoiceOver, and visual clipping.

## CNS UI/UX Visibility Matrix

| Requirement | Status | Evidence | Priority |
|---|---:|---|---:|
| Total CNS calculated | Implemented | `OxygenExposureModel.from`, `GasPlanningService.analyze(input:enginePlan:)` | OK |
| Total CNS includes deco | Implemented | Full engine segments include stops/ascent/deco gases | OK |
| CNS Descent + Bottom calculated | Implemented | `cnsPercentDescentAndBottom` | OK |
| Deco excluded from Descent + Bottom | Implemented | Segment filter and tests | OK |
| 15% threshold | Implemented | `CNSDescentBottomPlannerRule` | OK |
| 15 exactly accepted | Implemented | Existing tests | OK |
| Warning visible/red | Implemented | `PlannerView` red banner/tile | OK |
| EN/IT localization | Implemented | EN/IT string keys and tests | OK |
| Accessibility copy | Implemented | A11y keys and hints | OK |
| Share/export wording clarity | Partial | Generic CNS label remains | P3 |
| OTU correctness | Blocking | Formula appears inverted | P0/P1 |

## Test Coverage Assessment

Assessment: **Broad but not complete**

Static source count found approximately 229 iOS algorithm test functions.

Strong coverage areas:

- Buhlmann constants
- Gas validation
- Pressure model
- Tissue loading
- Schreiner equation
- Ceiling calculation
- Gradient factors
- NDL
- Multigas planner
- Trimix/helium
- Reference/golden fixtures
- CNS Descent + Bottom rule
- Localization copy for CNS labels
- Schedule gas consumption
- Planner regression fixtures

Critical test gap:

- OTU constant-depth tests currently validate the implemented formula instead of validating against an external/canonical OTU reference.

Validation gap:

- `Docs/BUILD_VALIDATION.md` and other historical docs mention older test counts. Current source has more tests than the latest documented macOS validation runs. A fresh macOS run is required.

Required macOS commands:

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 15' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 15' test
```

## Documentation Assessment

Assessment: **Good, but one mathematical correction required**

Strong documentation:

- Buhlmann engine design exists.
- Math verification exists.
- Planner limitations exist.
- Oxygen exposure model documentation exists.
- External validation plan exists.

Documentation issue:

- OTU formula documentation appears to repeat the same inverted formula found in code. This should be corrected alongside code/tests.

Documentation/process gap:

- Build validation docs should be refreshed after the next macOS build/test pass.

## Risk Matrix

### P0 - Blocking / Safety-Critical

1. **OTU constant-depth formula appears inverted**
   - Area: oxygen exposure
   - Impact: can understate pulmonary oxygen exposure at elevated PPO2.
   - Files: `iOSApp/Models/OxygenExposureModels.swift`, oxygen exposure docs, OTU tests.
   - Fix: correct formula, update ramp consistency if needed, add external reference tests, update docs.

### P1 - Critical

1. **External Buhlmann validation campaign still pending**
   - Area: decompression planning reference
   - Impact: internal validation can proceed, but public release claims should not exceed reference-only status.
   - Fix: execute documented validation campaign against trusted external reference planners.

2. **OTU tests validate implementation instead of independent reference**
   - Area: tests
   - Impact: regression suite cannot catch the current OTU issue.
   - Fix: add canonical OTU fixtures at PPO2 0.6, 1.0, 1.3, 1.4, 1.6 and multi-segment schedules.

### P2 - Important

1. **Travel gas to bottom gas switch depth is simplified**
   - Area: multigas planning
   - Impact: may distort tissue and gas consumption for some hypoxic trimix protocols.
   - Fix: add explicit bottom gas switch depth / travel gas switch schedule model.

2. **Fresh macOS build/test validation missing for current HEAD**
   - Area: release process
   - Impact: Windows static audit cannot prove compile/test pass.
   - Fix: run `xcodegen`, iOS build, iOS algorithm tests on macOS.

3. **Build validation documentation is stale**
   - Area: documentation
   - Impact: docs show older test counts and may not represent current code.
   - Fix: refresh after current macOS validation.

### P3 - Maintainability / UX Copy

1. **Planner validation messages include hardcoded Italian**
   - Area: localization
   - Impact: possible mixed-language states if those messages surface.
   - Fix: route user-facing validation through localization keys.

2. **Planner persistence key still includes `experimental`**
   - Area: maintainability
   - Impact: confusing naming in MAIN branch.
   - Fix: migrate or alias persistence key carefully without losing stored planner settings.

3. **Share/export planner text uses generic CNS label**
   - Area: UX copy
   - Impact: less clear than on-screen labels.
   - Fix: label exported value as CNS full plan and optionally include descent+bottom separately.

4. **Bailout cylinders remain schedule-only**
   - Area: technical planning model
   - Impact: acceptable if clearly documented, but not full bailout planning.
   - Fix: keep documented or add explicit bailout scenario planner later.

### P4 - Process / QA

1. **Physical-device UI/accessibility QA pending**
   - Area: UX validation
   - Impact: static inspection cannot prove no clipping under all Dynamic Type or VoiceOver cases.
   - Fix: run physical-device QA.

2. **Reference planner exact equivalence not claimed**
   - Area: documentation/legal
   - Impact: acceptable due reference-only positioning.
   - Fix: keep limitations explicit.

## Release Readiness Verdict

| Category | Verdict | Notes |
|---|---:|---|
| iOS Planner compile readiness | Unknown on this host | Requires macOS build |
| Buhlmann core readiness | Almost ready | Static inspection strong, external validation pending |
| Helium / trimix readiness | Almost ready | Implemented; travel gas switch modeling needs refinement |
| CNS readiness | Ready for internal validation | Full plan and descent+bottom are implemented and localized |
| OTU readiness | Not ready | Formula appears inverted |
| UX/UI readiness | Mostly ready | No visual blockers found statically |
| Localization readiness | Mostly ready | Planner CNS copy localized; some validator strings remain |
| Documentation readiness | Partial | OTU docs need correction; build validation stale |
| TestFlight planning readiness | Not yet | OTU fix and macOS validation required |
| App Store readiness | Not yet | External validation/legal review/physical QA required |

Final readiness statement:

The iOS Companion Planner is **not yet fully ready** for release-hard internal validation because OTU exposure math must be corrected and re-tested. The Buhlmann decompression core, CNS full-plan model, CNS descent+bottom 15% warning, localization, and UI copy are substantially implemented and appear coherent from static inspection.

## Implementation Plan

### Phase 1 - Fix OTU Formula

Files likely affected:

- `iOSApp/Models/OxygenExposureModels.swift`
- `Tests/iOSAlgorithmTests/OxygenExposureDeepModelTests.swift`
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`

Actions:

1. Replace the constant-depth OTU formula with canonical Lambertsen/UPTD direction:
   `minutes * pow(((ppO2 - 0.5) / 0.5), 5.0 / 6.0)`.
2. Verify ramp integration and constant-depth integration are directionally consistent.
3. Add independent test vectors for PPO2 0.6, 1.0, 1.3, 1.4, 1.6.
4. Verify OTU increases monotonically with PPO2.
5. Update docs and warnings.

### Phase 2 - External Validation Campaign

Actions:

1. Select reference engines/tools.
2. Freeze fixture profiles:
   - Air 21% at 30 m
   - Nitrox 32 at 30 m
   - Trimix bottom gas
   - Trimix + EAN50 deco gas
   - Trimix + oxygen deco gas
   - GF 30/70 vs GF 50/80
3. Compare NDL, first stop, total stop time, TTS, controlling compartments, and gas switch behavior.
4. Document tolerances and results.

### Phase 3 - Travel Gas Switch Model

Actions:

1. Add explicit travel-to-bottom gas switch depth model.
2. Validate hypoxic bottom gas switch depth.
3. Ensure Buhlmann loading and gas ledger use the same switch schedule.
4. Add tests for hypoxic trimix with travel gas.

### Phase 4 - Localization / Copy Cleanup

Actions:

1. Move user-facing planner validator strings to localization.
2. Update share/export text:
   - CNS full plan
   - CNS descent+bottom
   - CNS ascent/deco estimate
   - OTU
3. Keep reference-only wording.

### Phase 5 - macOS Build and Test Validation

Actions:

1. Run `xcodegen generate`.
2. Build iOS target.
3. Run iOS Algorithm Tests.
4. Update build validation docs with actual test count and results.

## Protected Files / Areas

These areas must remain untouched for this iOS-only planner work:

- `DIRDiving Watch App/*`
- Watch views, managers, models, services, tests, entitlements
- Root-level Watch-specific `App/*`, `Models/*`, `Services/*`, `Views/*`, `Utils/*`, `Resources/*` if they are watch runtime paths
- `Config/DIRDiving.entitlements`
- Experimental iOS files:
  - `iOSApp/Models/ExplorationModels.swift`
  - `iOSApp/Models/BuddyExperimentalModels.swift`
  - `iOSApp/Services/ExplorationPlanningStore.swift`
  - `iOSApp/Services/BuddyExperimentalStore.swift`
  - `iOSApp/Views/ExplorationCenterView.swift`
  - `iOSApp/Views/ExperimentalFutureConceptsView.swift`
  - `iOSApp/Views/BuddyExperimentalView.swift`
- Experimental branches

## Recommended Next Cursor / Codex Command

Do not run this automatically during this audit. Use it only after accepting the report findings.

```text
Fix the iOS Companion MAIN planner oxygen exposure and validation issues identified in Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md.

Scope:
- iOS Companion MAIN only.
- Do not modify Apple Watch code.
- Do not modify experimental files or branches.
- Do not redesign UI.
- Preserve legal/reference-only positioning.

Mandatory fixes:
1. Correct OTU constant-depth formula and align ramp/constant behavior.
2. Add independent OTU fixtures and monotonicity tests.
3. Update oxygen exposure documentation.
4. Add explicit travel-to-bottom gas switch depth plan or document as a limitation.
5. Localize remaining planner validation messages.
6. Clarify share/export CNS labels.
7. Run macOS xcodegen/build/tests if available; otherwise perform Windows static validation.

Acceptance:
- No P0/P1 oxygen exposure issues remain.
- iOS Algorithm Tests pass on macOS.
- No Watch or experimental files modified.
```

## Final Recommendations

1. Fix OTU formula before calling the planner release-hard.
2. Run the full iOS algorithm test suite on macOS after the OTU fix.
3. Refresh build validation documentation with current test counts.
4. Execute the external Buhlmann validation plan before TestFlight claims beyond internal reference validation.
5. Keep the product wording as non-certified and reference-only.

## Audit Certification

This report was produced by static inspection only.

No code fix was implemented.  
No UI was changed.  
No Apple Watch file was modified.  
No experimental file was modified.  
No commit or push was performed.  
macOS build/test validation remains required.
