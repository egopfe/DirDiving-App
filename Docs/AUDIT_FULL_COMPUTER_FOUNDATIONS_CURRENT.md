# AUDIT 01 — Full Computer Foundations (read-only)

**Date:** 2026-06-17  
**Auditor:** Independent automated + manual code review (no code changes)  
**Command:** `01_AUDIT_FULL_COMPUTER_FOUNDATIONS.md`

---

## Executive summary

| Baseline | SHA | Verdict |
|----------|-----|---------|
| `main` | `5e38e05` | **FAIL** — Commands 01–03 are **not merged** |
| `integration/full-computer` | `a3eb574` | **CONDITIONAL PASS** — foundations implemented; fix test guard + enum semantics before merge / Command 04 promotion |

Commands **01–03** (modes/startup, Gauge optional TTV, shared Bühlmann core) exist only on `integration/full-computer` (+282 files vs `main`). Auditing the **implementation** below references that branch; auditing **`main` alone** cannot pass.

---

## Readiness by area (`integration/full-computer`)

| Area | Readiness | Notes |
|------|-----------|-------|
| Activity selection at startup | **95%** | `DIRStartupSelectionPolicy`, `StartupFlowView`, cold-launch `fullScreenCover` |
| Gauge / Full Computer selection | **95%** | `DivingModeSelectionView`, `DIRDivingMode` |
| Startup preferences & defaults | **95%** | UserDefaults keys + legacy migration from `WatchModeSelectionPreferences` |
| Mandatory FC confirmation | **100%** | Gate in `completeStartup` + predive configuration store |
| Block mode change during dive | **100%** | `canChangeModes` + Settings `.disabled(dive.isDiveActive)` |
| Gauge TTV optional, default OFF | **100%** | Policy + tests; UI hidden when off |
| Shared Bühlmann core | **95%** | `Shared/BuhlmannCore/` — Foundation-only imports |
| No iOS/Watch math duplication | **90%** | Single `BuhlmannEngine`; iOS `GasMix` bridge only |
| `project.yml` membership | **90%** | Explicit FC files + `path: Shared`; Apnea UI excluded |
| iOS / Watch build | **100%** | Verified 2026-06-17 |
| Gauge / existing regression | **95%** | TTV tests + golden planner pass; stale audit test **fails** |
| Apnea / Snorkeling isolation | **85%** | Watch UI excluded; routing → `comingSoon`; shared Apnea models compile on branch |

**Overall (integration branch): ~93%** internal readiness for Command 04 **on the integration branch**.  
**Overall (`main`): 0%** for FC foundations until merge.

---

## 1. File map (new / moved / modified vs `main`)

### Command 01 — Modes & startup (added on integration)

| File | Status | Role |
|------|--------|------|
| `Models/DIRModesAndStartup.swift` | **A** | `DIRActivityMode`, `DIRDivingMode`, `DIRStartupLaunchStep` |
| `Utils/DIRStartupSelectionPolicy.swift` | **A** | Persisted prefs, cold-launch routing, legacy migration |
| `Services/DIRActivitySelectionStore.swift` | **A** | Startup orchestration, dive-active lock |
| `Views/StartupFlowView.swift` | **A** | Full-screen startup container |
| `Views/ActivitySelectionView.swift` | **A** | Activity picker |
| `Views/DivingModeSelectionView.swift` | **A** | Gauge vs Full Computer |
| `Views/FullComputerPrediveConfirmationView.swift` | **A** | Mandatory FC confirmation |
| `Views/ActivityComingSoonView.swift` | **A** | Apnea/Snorkeling placeholder |
| `Docs/DIR_DIVING_MODES_AND_STARTUP_FLOW_IMPLEMENTATION_REPORT.md` | **A** | Command 01 report |

**Modified:** `Views/ContentView.swift`, `Views/ModeSelectionView.swift`, `Services/DiveManager.swift`, `Utils/WatchModeSelectionPreferences.swift`, `project.yml`.

### Command 02 — Gauge optional TTV (added)

| File | Status | Role |
|------|--------|------|
| `Utils/GaugeLivePresentationPolicy.swift` | **A** | Presentation-only top panel (hidden / TTV+runtime / runtime+temp) |
| `Docs/DIR_DIVING_GAUGE_OPTIONAL_TTV_IMPLEMENTATION_REPORT.md` | **A** | Command 02 report |

**Modified:** `Views/DiveLiveView.swift`, `Views/SettingsView.swift`, `Services/WatchSyncService.swift`, localization.

### Command 03 — Shared Bühlmann core (added / moved)

| File | Status | Role |
|------|--------|------|
| `Shared/BuhlmannCore/BuhlmannEngine.swift` | **A** | Canonical planner + `runtimeProjection` |
| `Shared/BuhlmannCore/BuhlmannTissueModel.swift` | **A** | Tissue compartments |
| `Shared/BuhlmannCore/BuhlmannGas.swift` | **A** | Gas model |
| `Shared/BuhlmannCore/BuhlmannRuntimeProjection.swift` | **A** | Runtime NDL/TTS/ceiling |
| `Shared/BuhlmannCore/PlannerEnvironment.swift` | **A** | Ambient pressure |
| `Shared/BuhlmannCore/BuhlmannConstants.swift` | **A** | Shared constants |
| `Shared/BuhlmannCore/BuhlmannCoreConfiguration.swift` | **A** | Planner bounds |
| `Shared/BuhlmannCore/BuhlmannPlanPreflightValidator.swift` | **A** | Preflight validation |
| `Shared/BuhlmannCore/BuhlmannTissueHistory.swift` | **A** | Tissue history types |
| `iOSApp/Algorithms/Buhlmann/BuhlmannGas+GasMix.swift` | **M** (bridge) | iOS `GasMix` → `BuhlmannGas` adapter only |
| `Tests/WatchAlgorithmTests/BuhlmannCoreCrossTargetEquivalenceTests.swift` | **A** | Cross-target determinism |
| `Docs/DIR_DIVING_SHARED_BUHLMANN_CORE_EXTRACTION_REPORT.md` | **A** | Command 03 report |

**Removed from iOS-only tree:** duplicate `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift` and siblings (replaced by `Shared/BuhlmannCore/`).

---

## 2. Bühlmann core independence (SwiftUI / WatchKit / WCSession / UserDefaults)

**PASS** — all nine files under `Shared/BuhlmannCore/` import **only** `Foundation`.

Evidence: `Shared/BuhlmannCore/BuhlmannEngine.swift:1`, `BuhlmannTissueModel.swift:1`, etc.

Persistence and sync remain outside the core (`DIRStartupSelectionPolicy` uses UserDefaults; `WatchSyncService` syncs TTV preference). FC runtime (`FullComputerDecoSolver.swift`) **calls** `BuhlmannEngine.runtimeProjection` rather than reimplementing GF/tissue math.

---

## 3. Planner golden tests (before/after refactor)

**PASS** on `integration/full-computer`.

| Suite | Result | Evidence |
|-------|--------|----------|
| `BuhlmannGoldenFixtureTests` | **14 tests, 0 failures** | iOS simulator, 2026-06-17 |
| `BuhlmannCoreCrossTargetEquivalenceTests` | **Included in 24-test run, 0 failures** | watchOS simulator |

Golden fixtures exercise shared `BuhlmannEngine` — no separate iOS engine copy remains (`grep` finds single `BuhlmannEngine` definition in `Shared/BuhlmannCore/BuhlmannEngine.swift`).

---

## 4. Watch compiles against shared core

**PASS** — Watch target includes `path: Shared` in `project.yml` (Watch App + Algorithm Tests).  
`FullComputerDecoSolver.swift` and `FullComputerRuntimeEngine.swift` reference `BuhlmannEngine` / `BuhlmannTissueState` from shared core.

Build: `DIRDiving Watch App` — **BUILD SUCCEEDED** (generic watchOS, 2026-06-17).

---

## 5. TTV policy (Gauge)

| Check | Result | Evidence |
|-------|--------|----------|
| Default OFF | **PASS** | `DIRStartupSelectionPolicy.gaugeShowsTTV` returns `false` when key unset (`Utils/DIRStartupSelectionPolicy.swift:48-55`) |
| Hidden when OFF | **PASS** | `GaugeLivePresentationPolicy.evaluate` → `.runtimeAndTemperature` or FC → `.hidden` (`Utils/GaugeLivePresentationPolicy.swift:13-21`); `DiveLiveView` uses `EmptyView()` for `.hidden` (`Views/DiveLiveView.swift:788-790`) |
| Never labeled TTS in Gauge UI | **PASS** | `GaugeOptionalTTVTests.testRepositoryStringsUseTTVLabelAndCommandFooter` — `live.metric.ttv` = `"TTV"`, not TTS |
| FC mode hides Gauge top metrics | **PASS** | `isGaugeMode: false` → `topPanel: .hidden` (`GaugeLivePresentationPolicy.swift:14-16`) |

Tests: `GaugeOptionalTTVTests` — **8/8 PASS**.

Note: **TTS** terminology remains correct on **iOS planner / Full Computer deco** (decompression runtime), distinct from Gauge **TTV** (time-weighted profile index). This matches product semantics.

---

## 6. Apnea / Snorkeling accidental activation

| Surface | Watch MAIN | Evidence |
|---------|------------|----------|
| UI entry | **Blocked** | `project.yml:27-29` excludes `ApneaView.swift`, `SnorkelingView.swift` |
| Startup routing | **Blocked** | `nextStepAfterActivitySelection(.apnea)` → `.comingSoon` (`DIRStartupSelectionPolicy.swift:93-100`); test `DIRModesAndStartupFlowTests.testApneaRoutesToComingSoon` |
| Snorkeling enum | **Blocked** | `isLaunchableInMAIN == false` for `.snorkeling` (`DIRModesAndStartup.swift:14`) |
| iOS companion | **Apnea selectable** | By design on integration (`IOSCompanionActivitySelectionTests`) — separate from Watch MAIN |

**CONDITIONAL** — Apnea **shared models/services** compile on Watch via `path: Shared` (integration branch scope beyond FC 01–03). No Watch runtime UI launch path found.

---

## 7. Preference migration & backward compatibility

**PASS**

- Legacy `WatchModeSelectionPreferences.skipWhenSingleMode` inverted into `showActivitySelectionAtLaunch` (`DIRStartupSelectionPolicy.swift:117-125`).
- One-shot migration flag `dirdiving_watch_startup_preferences_migrated_v1`.
- Test: `DIRModesAndStartupFlowTests.testLegacySkipMigrationInvertsShowActivitySelection`.

---

## 8. Duplicate scan

| Domain | Duplication | Assessment |
|--------|-------------|------------|
| `BuhlmannEngine` | Single in `Shared/BuhlmannCore/` | **OK** |
| Gas models | `BuhlmannGas` (shared) + `GasMix` (iOS) + bridge | **Intentional** |
| Tissue models | `BuhlmannTissueState` in shared core only | **OK** |
| GF logic | Inside `BuhlmannEngine` only | **OK** |
| Mode enums | `DIRActivityMode` / `DIRDivingMode` (Watch) vs `CompanionActivityPreference` (iOS) | **Intentional dual stores** — documented, not synced |
| Navigation | `DIRStartupLaunchStep` vs `AppPage` | **OK** — startup vs tabs |

---

## Test execution (minimal matrix)

| Test | Result |
|------|--------|
| Build Watch | **PASS** |
| Build iOS | **PASS** |
| iOS planner golden (`BuhlmannGoldenFixtureTests`) | **PASS** (14) |
| Watch algorithms — startup routing (`DIRModesAndStartupFlowTests`) | **PASS** (11) |
| Watch — TTV (`GaugeOptionalTTVTests`) | **PASS** (8) |
| Watch — shared core (`BuhlmannCoreCrossTargetEquivalenceTests`) | **PASS** |
| iOS companion routing (`IOSCompanionActivitySelectionTests`) | **PASS** (12) |
| Legacy MAIN guard (`WatchCompleteAlgorithmAuditRemediationTests.testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords`) | **FAIL** |

---

## Findings (P0–P3)

### P0 — None (functional blockers for Command 04 on integration branch)

No missing gates for FC startup, confirmation, or shared core consumption.

### P1 — Stale Watch audit guard conflicts with FC / shared Bühlmann on Watch

`testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords` forbids token `buhlmann` in `App/Models/Services/Views/Utils` but **does not scan `Shared/`**. FC files now legitimately reference Bühlmann:

```47:79:Tests/WatchAlgorithmTests/WatchCompleteAlgorithmAuditRemediationTests.swift
    func testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords() throws {
        ...
        for token in Self.forbiddenRuntimeTokens {
            XCTAssertFalse(
                codeWithoutLineComments.contains(token),
                "\(file.lastPathComponent) must not reference decompression/CCR runtime token in code: \(token)"
            )
        }
```

**Failing files (2026-06-17):** `FullComputerDecoSolver.swift`, `FullComputerRuntimeEngine.swift`, `FullComputerRuntimeModels.swift`, `FullComputerGasSwitchPolicy.swift`, `FullComputerRuntimeCheckpoint.swift`, `FullComputerRuntimePlan.swift`.

**Fix before merge / Command 04 CI:** Update guard to allow `Shared/BuhlmannCore` + explicit FC runtime allowlist, or retire test in favour of `BuhlmannCoreCrossTargetEquivalenceTests`.

### P2 — `isLaunchableInMAIN` contradicts Watch routing for Apnea

```11:15:Models/DIRModesAndStartup.swift
    var isLaunchableInMAIN: Bool {
        switch self {
        case .diving, .apnea: return true
        case .snorkeling: return false
```

Watch routing sends `.apnea` to `.comingSoon` regardless (`DIRStartupSelectionPolicy.swift:84-86`, `97-100`). Property name/comment misleading; iOS companion treats apnea as launchable. **Fix:** rename or split Watch vs iOS launchability before Command 04 docs/API freeze.

### P2 — Dual mode-selection UX on Watch

`WatchModeSelectionPreferences.hasMultipleStableModes = true` (`Utils/WatchModeSelectionPreferences.swift:18`) exposes permanent Mode tab **in addition to** cold-launch `fullScreenCover`. On `main` this was `false`. Redundant but not a safety regression.

### P3 — Documentation drift

- Command 02 report cites 9 TTV tests; suite has **8** methods.
- Command 01 report wording (“apnea not launchable”) vs `isLaunchableInMAIN == true` for apnea.

---

## Regressions observed

| Regression | Severity | Branch |
|------------|----------|--------|
| FC foundations absent on `main` | **Blocker for MAIN release** | `main` |
| `testWatchCompileRootsExcludeDecompressionAndCCRRuntimeKeywords` fails | **CI / merge blocker** | `integration/full-computer` |
| `hasMultipleStableModes` true changes pre-FC UX | **Low** | vs `main` cold-launch-only |

**No Gauge TTV regression** detected: default OFF, panel removed when disabled, formula tests unchanged.

---

## Decision

| Scope | Decision |
|-------|----------|
| **`main` @ `5e38e05`** | **FAIL** — Commands 01–03 not present; iOS-local Bühlmann, no startup flow, no optional TTV policy |
| **`integration/full-computer` @ `a3eb574`** | **CONDITIONAL PASS** — foundations meet spec; resolve P1 test guard + P2 enum semantics before promoting to `main` or treating as “done on main” |

---

## Required fixes before Command 04

1. **P1** — Update `WatchCompleteAlgorithmAuditRemediationTests` forbidden-token policy for post–Command 03 layout (allow shared core + FC runtime paths).
2. **P2** — Align `DIRActivityMode.isLaunchableInMAIN` with Watch `comingSoon` routing (or document split Watch/iOS APIs).
3. **P2 (optional)** — Decide whether `hasMultipleStableModes` should remain `true` alongside cold-launch cover; document UX intent.
4. **Process** — Merge `integration/full-computer` → `main` (or re-audit after merge) so “audit on main” matches code reality.
5. **P3** — Sync Command 01/02 implementation report test counts and apnea launchability wording.

---

## Evidence index

| Topic | File:line |
|-------|-----------|
| FC confirmation gate | `Services/DIRActivitySelectionStore.swift:121-127` |
| Dive-active mode lock | `Services/DIRActivitySelectionStore.swift:96-99` |
| TTV default OFF | `Utils/DIRStartupSelectionPolicy.swift:48-55` |
| TTV UI hidden | `Views/DiveLiveView.swift:788-790` |
| Shared engine import purity | `Shared/BuhlmannCore/BuhlmannEngine.swift:1` |
| Apnea UI exclusion | `project.yml:27-29` |
| Session mode recording | `Services/DiveManager.swift:272-274` |
| Legacy preference migration | `Utils/DIRStartupSelectionPolicy.swift:117-125` |

---

*Read-only audit — no repository code was modified.*
