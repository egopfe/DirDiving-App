# DIR Diving iOS Bühlmann UX/UI Readiness Audit

Date: 2026-05-28
**Superseded by:** [`Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`](DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md) (2026-05-30, verdict **READY** after fix @ `3237262`)
Branch audited: `main` (iOS Companion only) @ `570964e` (pre-algorithm fix); algorithm P1–P3 resolved @ `69e69b2` — see [`Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`](DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md)
Indexed in: [`Docs/INDEX.md`](INDEX.md) §1, §4, §6, §13
Audit type: read-only UX/UI readiness audit after latest Bühlmann multigas planner work

## Executive Verdict

**Partially ready**

The iOS planner flow is discoverable, premium-style coherent, and safety-gated before calculation. Core reference warnings and MOD/PPO2 visibility exist.
However, there are blocking UX gaps for safe interpretation of the latest hardening features (especially repetitive planning, schedule gas allocation visibility, and environment messaging consistency).

## Scope Confirmed

- Audited **iOS Companion MAIN only**
- No Apple Watch files inspected for changes
- No watchOS targets touched
- No experimental-only files used for findings
- No code/UI changes made as part of this audit

## Screens And Flows Inspected

### iOS Views
- `iOSApp/Views/ContentView.swift`
- `iOSApp/Views/PlannerView.swift` (includes `PlanResultView`)
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/DiveDetailView.swift` (consistency spot check)

### iOS Models / Utils
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`

### iOS Services / Algorithms
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`

### Tests/Docs for UX claim consistency
- `Tests/iOSAlgorithmTests/BuhlmannGoldenFixtureTests.swift`
- `Tests/iOSAlgorithmTests/PlannerRegressionFixtureTests.swift`
- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_FIXTURE_SOURCES.md`
- `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`

## UX/UI Findings

### Planner input / entry
- Planner is highly discoverable (first tab in `ContentView`) and gated by explicit safety acknowledgment in `PlannerView`.
- Reference-only language is present before/around planning (`planner.disclaimer.informative`, trimix disclaimer, safety toggle).
- Input coverage is broad (depth, avg depth, GF, gases, roles, switch depth, SAC/emergency SAC, temperature, altitude, salinity).
- **Gap:** repetitive planning controls (snapshot source, SI, enabled/disabled state) are not exposed in planner UI although logic exists in store/service.

### Gas configuration
- Roles and gas editing are visible; MOD is shown per gas and blocking MOD states are surfaced in input/result cards.
- Gas mix invalid state is visible in gas card.
- **Gap:** schedule-based per-cylinder allocation results are not shown in result UI (only aggregate reserve card).
- **Gap:** missing-cylinder/allocation errors become generic planner warnings, but no targeted “which cylinder is missing” UX.

### Bühlmann results
- Result tabs (plan/curve/charts) expose stops, stop depth/time/gas, TTR, CNS/OTU, GF comparisons, segment timeline.
- Share/export text includes indicative footer and decompression lines.
- **Gap:** explicit “decompression-required vs no-deco” state is implicit (stops list) rather than strongly labeled.
- **Gap:** controlling-compartment / ceiling-specific warning visibility is limited in UI language.

### Warnings and error handling
- MOD and validation errors block calculate and show alerts/cards.
- Planner states include many typed states (`invalidEnvironment`, `gasAllocationIncomplete`, `oxygenExposureElevated`, etc.).
- **Gap:** several typed failure states are not distinctly surfaced in UX copy (snapshot stale/corrupt/schema mismatch, fixture mismatch, no-solution).
- **Gap:** some messages remain technical but not corrective (user action unclear).

### Repetitive planning
- Service layer supports snapshots and surface interval modeling.
- Store persists snapshot and repetitive toggles.
- **Major UX gap:** no user-facing controls/status for:
  - snapshot source/timestamp
  - SI input and unit context
  - “repetitive plan active” indicator
  - rejection reasons (stale/corrupt/missing snapshot)

### Altitude/salinity
- Altitude and salinity are present in input UI.
- Pressure model services exist.
- **Critical consistency issue:** validator message still says altitude/salinity are stored but not applied; this conflicts with current implementation intent and creates user trust risk.

### CNS/OTU
- Displayed in analysis/result grid and accumulated from schedule path.
- **Gap:** thresholds/assumptions are not always explained where values are shown (user may read as authoritative unless disclaimer section is noticed).

### Accessibility/interactions
- Many controls include labels/hints; segmentation and warning boxes are readable on standard sizes.
- **Likely issues (static audit):**
  - Dense cards with many steppers can become crowded in large Dynamic Type.
  - Warning-heavy sections may push critical actions below fold with no sticky summary.
  - Decimal separator and keyboard entry behavior cannot be fully validated from static inspection.

## Safety-Critical UX Issues

### P0
- **None confirmed** from static inspection.

### P1
- **P1-1: Repetitive planning not user-visible while logic exists**
  Users cannot verify whether residual tissue state is applied, or why it failed, yet output may differ.
- **P1-2: Environment messaging contradiction**
  UI/validation text indicates altitude/salinity are non-operative while implementation now tries to apply environment models.
- **P1-3: Schedule gas allocation not transparently shown per cylinder**
  New schedule-based gas hardening can be mistaken for legacy bottom-only aggregate values.

## UI Consistency Issues

- Result emphasizes TTR/OTU/CNS, but schedule gas ledger details are absent from result cards.
- Repetitive capabilities exist in service/store but no visual parity in planner input/results.
- Warning taxonomy is richer in code than in UI messaging (state-to-message mismatch).
- Environment model docs and in-app validation strings are currently inconsistent.

## Missing User Feedback States

- Missing explicit state for:
  - repetitive snapshot loaded/not loaded
  - snapshot stale/corrupt/schema mismatch
  - surface interval accepted/rejected
  - per-cylinder allocation success/failure
  - no valid decompression solution message distinct from generic invalid input
  - environment invalidity with corrective hint
- Missing clear no-deco/deco-required badge-state in result header.
- No dedicated loading/progress state (calculation appears immediate only).

## Readiness Matrix

| Area | Rating | Priority |
|---|---|---|
| 1. Planner entry points | READY | P3 |
| 2. Planner input UX | MINOR ISSUES | P2 |
| 3. Gas configuration UX | MAJOR ISSUES | P1 |
| 4. Bühlmann result UX | MINOR ISSUES | P2 |
| 5. Schedule gas consumption UX | MAJOR ISSUES | P1 |
| 6. Altitude/salinity UX | MAJOR ISSUES | P1 |
| 7. Repetitive dive UX | NOT READY | P1 |
| 8. CNS/OTU UX | MINOR ISSUES | P2 |
| 9. Error/warning UX | MAJOR ISSUES | P1 |
| 10. Cross-screen consistency | MAJOR ISSUES | P1 |
| 11. Accessibility/readability readiness | MINOR ISSUES | P2 |
| 12. Safety/legal positioning | READY | P3 |
| 13. UI regression vs premium style | MINOR ISSUES | P3 |
| 14. Overall readiness | PARTIALLY READY | P1 |

## Recommended Fix Plan

Implementation plan only (no changes applied in this audit):

1. **Expose repetitive planning controls and state (P1)**
   - Add existing-style section in planner profile/result:
     - toggle repetitive mode
     - SI minutes input
     - snapshot timestamp/source badge
     - explicit fail-closed rejection reasons

2. **Add schedule gas ledger result card (P1)**
   - Per gas/cylinder rows:
     - consumed liters
     - remaining liters
     - remaining bar/psi
     - reserve/min-gas/lost-gas flags
   - Keep current visual language (`DIRCard` + `DIRMetricTile` style)

3. **Fix environment UX consistency (P1)**
   - Align planner warnings/text with real behavior:
     - if active, say active with assumptions
     - if blocked, show typed reason and corrective hint

4. **Strengthen result-state clarity (P2)**
   - Add explicit header state:
     - No-deco reference / Deco required reference
   - Surface key blocking states with action-oriented copy.

5. **Map all typed planner states to user-facing copy (P1/P2)**
   - Ensure each state has:
     - visible message
     - non-misleading severity
     - user correction guidance

6. **Accessibility hardening pass (P2/P3)**
   - Dynamic Type stress test on dense planner cards
   - VoiceOver focus order for warning and calculate action
   - Ensure warning cards remain visible and not buried below fold

## Files To Protect

Do not touch during UX fixes:

- **Watch/runtime root files:** `App/*`, `Models/*` (root), `Services/*` (root), `Views/*` (root), `Utils/*` (root), `Resources/*` (root)
- **watchOS config/tests:** `Config/DIRDiving.entitlements`, watch targets in `project.yml` (except read-only validation), Watch algorithm tests
- **Experimental iOS files:**
  - `iOSApp/Models/ExplorationModels.swift`
  - `iOSApp/Models/BuddyExperimentalModels.swift`
  - `iOSApp/Services/ExplorationPlanningStore.swift`
  - `iOSApp/Services/BuddyExperimentalStore.swift`
  - `iOSApp/Views/ExplorationCenterView.swift`
  - `iOSApp/Views/ExperimentalFutureConceptsView.swift`
  - `iOSApp/Views/BuddyExperimentalView.swift`

## Acceptance Criteria For UX/UI Readiness

Before declaring planner UX/UI ready:

1. Repetitive planning is fully user-visible, explicit, and fail-closed with clear reasons.
2. Schedule gas consumption is shown per gas/cylinder (not aggregate-only).
3. Altitude/salinity messaging is consistent with actual calculation behavior.
4. All critical typed states map to clear user-facing messages and corrective actions.
5. Result header clearly distinguishes no-deco vs deco-required reference state.
6. CNS/OTU assumptions and reference-only positioning are visible where values appear.
7. Dynamic Type/VoiceOver checks pass on planner input and result flows.
8. No screen implies certified decompression authority or real-time dive-computer behavior.
