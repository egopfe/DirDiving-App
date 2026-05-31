# DIR Diving iOS Bühlmann Comprehensive Readiness Audit

**Date:** 2026-05-30  
**Implementation follow-up:** P1–P4 + comprehensive CNS/OTU implemented @ `dae29b8` (2026-05-31) — see [`DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md`](DIR_DIVING_IOS_BUHLMANN_IMPLEMENTATION_COMPLETION_REPORT.md). **119/119** XCTest pass. Verdict below reflects **pre-implementation** audit state.
**Auditor scope:** Read-only static inspection + macOS build/test execution  
**Repository:** `main` @ `af39283` (= `origin/main`, synced)  
**Platform:** macOS (Darwin), Xcode iOS Simulator `iPhone 17`, iOS SDK 26.5  

---

## Executive Verdict

### **Almost Ready**

The iOS Companion MAIN Bühlmann planner is **mathematically coherent**, **algorithmically fail-closed on invalid input**, **well test-covered (88/88 XCTest pass)**, and **UX/UI-ready for structured internal QA** following the 2026-05-29 UX fix pass. It remains a **non-certified planning reference** and must not be presented as decompression authority.

**Blockers before TestFlight / release candidate:** Apple Watch Ultra entitlement field validation (Watch scope, not planner), external Bühlmann validation campaign, physical-device accessibility QA, and resolution of minor environment/preview consistency gaps documented below.

---

## Scope Confirmation

| Constraint | Status |
|---|---|
| iOS Companion MAIN only | ✅ Confirmed — audit limited to `iOSApp/*` planner/Bühlmann paths |
| MAIN branch only | ✅ `main` @ `af39283`, clean working tree, synced with `origin/main` |
| No Watch code modified | ✅ Audit-only; no file changes |
| No experimental scope | ✅ No `ExplorationCenterView`, Buddy, Apnea, Snorkeling files used |
| No code/UI/business-logic changes | ✅ Report + plan only |
| Safety positioning preserved | ✅ All findings assume reference-only, non-certified posture |

---

## Repository State

```
Branch:     main @ af39283
Upstream:   origin/main (0 ahead / 0 behind)
Remote:     https://github.com/egopfe/DirDiving-App
Working tree: clean
OS:         macOS (Darwin)
```

### Build / test execution (macOS)

| Step | Result |
|---|---|
| `xcodegen generate` | ✅ PASS |
| `xcodebuild` scheme **DIRDiving iOS** → iPhone 17 sim | ✅ BUILD SUCCEEDED |
| `xcodebuild test` scheme **DIRDiving iOS Algorithm Tests** → iPhone 17 sim | ✅ **88 tests, 0 failures** |

Note: User spec referenced iPhone 15; this machine exposes iPhone 17 simulators. Tests ran on `iPhone 17`.

### iOS targets (from `project.yml`)

- **DIRDiving iOS** — companion app (`iOSApp/`, bundle `com.egopfe.dirdiving.ios`)
- **DIRDiving iOS Algorithm Tests** — algorithm/planner XCTest target (`Tests/iOSAlgorithmTests/`)

Watch targets exist in the repo but were **not inspected for modification** per scope.

---

## Files Inspected

### Algorithms
- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`

### Services
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/PlannerStore.swift`

### Models / utils
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift` (referenced via UI)

### UI
- `iOSApp/Views/PlannerView.swift` (includes `PlanResultView`)
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Views/ContentView.swift` (tab routing spot-check)
- `iOSApp/Views/MoreView.swift` (legal/safety spot-check)

### Tests (38 files under `Tests/iOSAlgorithmTests/`, including 17 JSON fixtures)
- All `Buhlmann*.swift`, `PlannerRegressionFixtureTests.swift`, `IOSAlgorithmTests.swift`, `Fixtures/*`

### Documentation
- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md`
- `Docs/DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_REAUDIT_2026-05-28.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`
- `DIR_DIVING_IOS_BUHLMANN_UX_UI_READINESS_AUDIT.md` (superseded)
- `DIR_DIVING_IOS_BUHLMANN_UX_UI_FIX_VERIFICATION.md`
- `README.md`, `project.yml` (target/bundle verification)

---

## Bühlmann Mathematical Model Assessment

| Area | Verdict | Notes |
|---|---|---|
| **Constants** | ✅ Correct | 16 N2 + 16 He half-times; a/b tables complete; ordering fast→slow; `BuhlmannConstantsTests` validates boundaries |
| **Gas model** | ✅ Correct | O2/N2/He fractions; O2+He≤1; hypoxic/MOD/PPO2 validation; stable `gasMixId`/`cylinderId` identity |
| **Pressure model** | ⚠️ Partial | Validated paths use `PlannerEnvironment` + `AmbientPressureModel` (altitude barometric formula, salinity density). Legacy `IOSUnitConversions.ambientPressureBar` (1.0 bar + 10 m/bar) still exists for nil-environment fallbacks |
| **Tissue loading** | ✅ Correct | Independent N2/He; constant-depth exponential; Schreiner linear segments; gas-switch dwell 0.5 min |
| **Ceiling / deco** | ✅ Correct | Mixed a/b weighting; GF-interpolated tolerated ambient; environment-aware depth conversion; iterative 3 m stops; not a static template |
| **Gradient factors** | ✅ Correct | GF Low/High validated (Low < High); interpolation between first stop and surface; GF 30/70 more conservative than 50/80 (fixture-tested) |
| **NDL** | ✅ Correct | Binary search on tissue state; environment-aware; returns `maxBottomTimeMinutes` cap (600), not fake 999; monotonic with depth in tests |
| **Multigas** | ✅ Correct | Bottom/travel/deco roles; switch ordering; `bestAscentGas` prefers higher O2 when valid; segment operational validation |
| **Repetitive planning** | ⚠️ Partial | Snapshot + surface-interval off-gassing on air at surface; environment match enforced; **semantic limitation**: snapshot sourced from prior *plan output*, not dive log |
| **Oxygen exposure** | ✅ Implemented @ `dae29b8` | Comprehensive NOAA model: single + daily CNS, 90 min recovery, REPEX OTU, air-break, snapshot v2 carryover — see limitations doc |
| **Gas consumption** | ✅ Correct | Schedule ledger from engine segments × SAC × ambient ATA; per-cylinder UUID keys; reserve/rock-bottom/lost-gas heuristics |
| **Numerical robustness** | ✅ Correct | Fail-closed on NaN/invalid GF/depth; coefficient epsilon guard; finite outputs asserted in tests |

### Notable mathematical detail — dual surface pressure baseline

- `PlannerEnvironment.seaLevelSaltWater.surfacePressureBar` = **1.01325 bar**
- `IOSAlgorithmConfiguration.surfacePressureBar` = **1.0 bar**
- `BuhlmannTissueState.airSaturated()` (no args) uses **1.0 bar**

Validated planner requests use `airSaturated(surfacePressureBar: environment.surfacePressureBar)` via `BuhlmannPlanner.makeRequest(input:environment:)`, so **production planning paths are consistent**. Default engine struct defaults and legacy nil-environment fallbacks retain the 1.0 bar simplification (~1.3% N2 saturation delta at sea level).

---

## Algorithmic Consistency Assessment

### Canonical path — ✅ **Mostly consistent**

`PlannerService.makePlan` executes **one** `BuhlmannEngine.plan(request)` per successful validation. From that `BuhlmannEngineResult`:

| Output | Source |
|---|---|
| NDL, TTS, stops, segments | `enginePlan` directly |
| Deco stop UI rows | `BuhlmannPlanner.decoStops(from: enginePlan)` |
| Runtime segment UI | `BuhlmannPlanner.runtimeSegments(from: enginePlan)` |
| Gas ledger | `ScheduleGasConsumptionService.analyze(..., enginePlan:, environment:)` |
| CNS/OTU (full profile) | `OxygenExposureModel.from(segments: enginePlan.segments, ...)` |
| GF comparison table | **Separate** `BuhlmannEngine.plan` runs per preset (intentional sensitivity table) |
| Repetitive seed | `initialTissueState` set before canonical run via `RepetitiveDivePlannerService.seedRequest` |

Repetitive planning does **not** recompute deco from a clean-dive assumption when snapshot seeding succeeds (verified by `BuhlmannReauditFixTests`).

### Inconsistencies — ⚠️

| Issue | Classification |
|---|---|
| **Bühlmann NDL curve preview** (`PlannerStore` → `BuhlmannPlanner.plan` without `PlannerEnvironment` from input) | **Inconsistent** — CURVA BUHLMANN tab / live NDL preview uses sea-level defaults while plan result respects altitude/salinity |
| **GF comparison presets** | **Partial** — auxiliary engine runs; not shown as primary plan NDL/TTS |
| **Bailout cylinders** | **Missing in engine** — role exists in UI/MOD/schedule copy but not in `BuhlmannPlanRequest` travel/deco lists |
| **`surfaceIntervalRejected` state** | **Missing wiring** — enum + copy exist; never emitted by services |
| **`unavailablePlan` header environment** | **Partial** — uses `.seaLevelSaltWater` when input invalid (presentation-only) |

---

## Numerical Robustness Assessment

| Risk | Mitigation observed |
|---|---|
| Divide-by-zero in mixed coefficients | `max(pn2 + phe, 1e-6)` guard |
| NaN / infinity propagation | Validation rejects non-finite inputs; tests assert finite stop/segment outputs |
| Negative tissue pressure | Schreiner/loading guards; ceiling skips non-positive totals |
| Fake-valid NDL (999 min) | Capped at `maxBottomTimeMinutes` (600); tests assert `< 999` |
| Silent sea-level fallback on validated plans | `PlannerService` fail-closed on invalid environment before engine |
| Legacy 10 m/bar pressure | Only when `environment` parameter omitted in `BuhlmannGas.inspiredPressure` |
| Schedule non-convergence | `calculationLimitReached` → `.noValidDecompressionSolution` / `.modelIncomplete` |
| Duplicate gas labels | UUID `allocationKey` prevents ledger collapse (tested) |

---

## UX/UI Readiness Assessment

Prior UX re-audit (`Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md`) verdict: **READY**. This comprehensive audit **confirms** that assessment with additional notes:

### Planner input UX — ✅
Depth, time, GF, gas cylinders/roles, SAC, altitude, salinity, repetitive toggle/SI, safety acknowledgement, environment status row, MOD/PPO2 on gas cards.

### Result UX — ✅
No-deco / deco-required headers, reference-only hints, stops/TTS/NDL, CNS/OTU with disclaimer, gas ledger card, typed warnings, repetitive badge, environment summary.

### Warning UX — ✅
All major `PlannerResultState` values have localized user-facing copy + corrective hints (`BuhlmannUxReadinessTests`).

### Accessibility — ⚠️ Partial
VoiceOver labels on result cards, warnings, environment, repetitive status. **Not** exhaustively validated on physical hardware or extreme Dynamic Type (documented limitation).

### Safety / legal UX — ✅
Safety acknowledgement gate, informative disclaimers, non-certified headers, no certified-deco implication in primary headers.

### UX gap carried into this audit
**Bühlmann curve tab** may show NDL inconsistent with environment-adjusted plan until preview path passes `PlannerEnvironment` (P2).

---

## Test Coverage Assessment

### Existing coverage — ✅ Strong

**88 tests passing**, including:

| Suite | Focus |
|---|---|
| `BuhlmannConstantsTests` | ZHL-16C table integrity |
| `BuhlmannPressureModelTests` | Altitude/salinity ambient pressure |
| `BuhlmannTissueLoadingTests`, `BuhlmannSchreinerEquationTests` | Loading math |
| `BuhlmannCeilingTests`, `BuhlmannGradientFactorTests`, `BuhlmannNDLTests` | Ceiling, GF, NDL |
| `BuhlmannTrimixHeliumTests`, `BuhlmannMultigasPlannerTests` | He / multigas |
| `BuhlmannGasValidationTests`, `BuhlmannNumericalRobustnessTests` | Fail-closed / finite outputs |
| `BuhlmannGoldenFixtureTests`, `BuhlmannReferenceFixtureTests`, `PlannerRegressionFixtureTests` | JSON fixtures w/ tolerance ranges |
| `BuhlmannReauditFixTests` | Environment NDL, ledger UUIDs, repetitive canonical result, rock-bottom env |
| `BuhlmannUxReadinessTests` | Presentation model copy, headers, ledger, environment |
| `IOSAlgorithmTests` | Broader iOS algorithm hardening |

Fixtures encode depth, GF, gases, environment (where applicable), and expected TTS/stop ranges.

### Missing / weak coverage

| Gap | Priority |
|---|---|
| Bühlmann preview curve uses same `PlannerEnvironment` as plan | P2 |
| `airSaturated()` 1.0 vs 1.01325 baseline alignment test | P2 |
| `surfaceIntervalRejected` emission path (or remove dead state) | P2 |
| Bailout role excluded from engine schedule (explicit regression) | P3 |
| Physical VoiceOver / Dynamic Type UI tests | P2 (manual QA) |
| End-to-end external reference fixture campaign beyond envelope tests | P1 (process, not unit test) |

---

## Documentation Assessment

| Document | Status |
|---|---|
| `DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md` | ✅ Accurate post-reaudit; documents canonical `PlannerService` path |
| `DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` | ✅ Formulas match code; cites external references |
| `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | ✅ Honest about reference-only posture; UX section current |
| `DIR_DIVING_IOS_BUHLMANN_VALIDATION_FIXTURES.md` | ✅ Aligned with fixture directory |
| `DIR_DIVING_IOS_ALGORITHM_RELEASE_HARDENING.md` | ✅ P1–P3 fix history documented |
| UX re-audit / fix verification | ✅ Consistent with code inspection |
| `README.md` | ✅ References `origin/main`; safety positioning intact |

### Stale / incomplete items

| Item | Priority |
|---|---|
| Repetitive snapshot semantics (“prior plan output”, not logged dive) could be more prominent in UI copy | P2 |
| Bühlmann preview environment mismatch not documented | P2 |
| `surfaceIntervalRejected` documented in enum but unused | P3 |

---

## Risk Matrix

### P0 — Safety-critical / misleading / crash

*None identified in iOS MAIN planner at `af39283` for validated inputs.* Engine and `PlannerService` fail closed; no certified-deco UI headers found.

---

### P1 — Mathematical correctness / release-hard

| ID | Title | File(s) | Evidence | Impact | Recommended fix | Acceptance criteria |
|---|---|---|---|---|---|---|
| P1-1 | External validation campaign incomplete | Docs + fixtures | Cross-check doc exists; no broad independent fixture sign-off | Cannot claim parity with certified planners | Run expanded external fixture campaign on macOS; document tolerances | Signed validation report; no P1 math regressions in CI |
| P1-2 | Dual surface-pressure baseline (1.0 vs 1.01325) | `IOSAlgorithmConfiguration.swift`, `BuhlmannTissueModel.swift`, `PlannerEnvironment.swift` | `airSaturated()` default uses 1.0; environment sea level uses 1.01325 | Small N2 saturation bias on legacy/default paths | Unify on `PlannerEnvironment` surface pressure or document explicit 1.0 simplification everywhere | Unit test: sea-level saturated tissue matches environment within ε |

---

### P2 — UX / validation / data integrity / tests

| ID | Title | File(s) | Evidence | Impact | Recommended fix | Acceptance criteria |
|---|---|---|---|---|---|---|
| P2-1 | Bühlmann NDL preview ignores planner environment | `PlannerStore.swift`, `BuhlmannPlanner.swift` | `BuhlmannPlanner.plan(...)` called without environment from `input.altitudeMeters`/`salinity` | CURVA BUHLMANN tab diverges from plan NDL at altitude/freshwater | Pass `PlannerEnvironment` into preview `BuhlmannPlanner.plan` | Test: preview NDL changes when altitude/salinity changes |
| P2-2 | Repetitive snapshot semantics | `PlannerStore.swift`, `RepetitiveDivePlannerService.swift` | Snapshot updated from current `enginePlan` after each recalc | Users may think snapshot = prior **logged** dive tissue | Clarify UI copy + docs; optional future: seed from dive log export | UI strings state “prior reference plan”; doc updated |
| P2-3 | `surfaceIntervalRejected` never emitted | `PlannerResultState.swift`, `PlannerService.swift` | Grep shows enum only | Dead warning state; maintenance noise | Emit when SI invalid, or remove state + copy | Test covers emission or state removed |
| P2-4 | Physical accessibility QA gap | `PlannerView.swift` | Docs note VoiceOver/Dynamic Type not hardware-validated | Release UX risk | Manual QA matrix on device | Signed QA checklist |
| P2-5 | CNS/OTU model simplicity | `OxygenExposureModels.swift` | ~~Stepwise CNS clock~~ → **Implemented:** NOAA single/daily, recovery, REPEX, carryover @ `dae29b8` | Reference estimates with documented model | Keep disclaimers; avoid stronger claims in marketing | ✅ UI disclaimer + daily summary visible |

---

### P3 — Documentation / maintainability / polish

| ID | Title | File(s) | Evidence | Impact | Recommended fix | Acceptance criteria |
|---|---|---|---|---|---|---|
| P3-1 | Bailout role not in Bühlmann engine | `GasPlan.swift`, `BuhlmannEngine.swift` | Bailout in schedule copy/contingency only | Users may expect bailout in deco schedule | Document explicitly; optional future engine integration | LIMITATIONS.md + UI hint |
| P3-2 | Legacy 10 m/bar pressure helper | `IOSUnitConversions.swift` | Still used when environment nil | Confusion for maintainers | Deprecate or route all Bühlmann paths through `AmbientPressureModel` | No Bülmann call sites use legacy helper |
| P3-3 | GF comparison runs 4 full plans | `BuhlmannPlanner.gfComparisons` | Performance on complex profiles | UI jank on slow devices | Cache or throttle; optional progress | No main-thread stall on 60 m trimix profile |
| P3-4 | Sync calculation UX | `PlannerView.swift` | No progress indicator | Large profiles may appear frozen | Optional async wrapper + spinner | UX test on heavy profile |

---

### P4 — Nice-to-have

| ID | Title | Notes |
|---|---|---|
| P4-1 | Persist repetitive snapshot from dive log | Future enhancement linking logbook → tissue seed |
| P4-2 | Team gas matching polish | Already present; expand tests |

---

## Release Readiness Verdict

| Gate | Verdict | Rationale |
|---|---|---|
| **Internal validation** | **Almost Ready → Ready*** | *Ready* after P2-1 preview fix OR documented acceptance of preview mismatch; run physical VoiceOver QA |
| **TestFlight** | **Not Ready** | Watch entitlement QA, external Bühlmann validation campaign, physical device matrix |
| **Release candidate** | **Not Ready** | Same as TestFlight + App Store review readiness |
| **Overall product** | **Not Ready** (App Store) | Planner reference acceptable; whole product blocked by hardware entitlement / broader release gates |

\*If internal QA accepts P2-1 as known limitation with UI note, **Ready for internal validation** stands without code change.

---

## Implementation Plan

> **Reminder:** This plan is for a **future implementation pass**. Do not execute as part of this audit.

### Phase A — Environment consistency (P1-2, P2-1, P3-2)

**Objective:** Single pressure/tissue baseline across preview, plan, and engine defaults.

**Files likely to modify:**
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift` (or stop using 1.0 for tissue)
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`

**Tests to add/update:**
- `BuhlmannPressureModelTests` — saturated tissue @ sea level matches `PlannerEnvironment.seaLevelSaltWater`
- New test — preview NDL changes with altitude/salinity via `PlannerStore` or direct `BuhlmannPlanner.plan(..., environment:)`

**Docs:** `DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`, `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`

**Acceptance:** Preview curve NDL = plan NDL for same input/environment; no legacy 10 m/bar in Bühlmann paths.

---

### Phase B — Repetitive semantics & dead states (P2-2, P2-3)

**Objective:** Honest repetitive planning UX and clean state machine.

**Files likely to modify:**
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/PlannerService.swift` or `RepetitiveDivePlannerService.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Resources/*/Localizable.strings`

**Tests:** Extend `BuhlmannUxReadinessTests` + `BuhlmannReauditFixTests` for SI rejection or state removal.

**Docs:** `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`, UX re-audit addendum.

**Acceptance:** No dead `PlannerResultState` cases; UI copy distinguishes reference snapshot vs logged dive.

---

### Phase C — External validation & release hardening (P1-1, P2-4)

**Objective:** Evidence pack for stakeholders / TestFlight.

**Activities (non-code):**
- macOS fixture campaign vs published references
- Physical iPhone VoiceOver + Dynamic Type walkthrough
- Update `Docs/RELEASE_CHECKLIST.md`, `Docs/TESTFLIGHT_REVIEW_NOTES.md`

**Acceptance:** Signed checklist; no open P1 items.

---

### Phase D — Documentation & polish (P3-1, P3-3, P3-4)

**Objective:** Maintainability and UX polish.

**Files:** LIMITATIONS, engine design, optional async plan wrapper in `PlannerStore`.

**Acceptance:** Docs match code; optional performance UX if profiling shows need.

---

## Protected Files / Areas

**Do not modify in a planner fix pass:**

| Area | Reason |
|---|---|
| `App/*`, Watch targets, `WatchApp/*` | Out of scope — Watch MAIN |
| Experimental iOS/Watch views (`Exploration*`, `Buddy*`, Apnea, Snorkeling) | Experimental isolation |
| `project.yml` Watch target exclusions | Branch safety policy |
| Legal onboarding / disclaimer core logic | Approved legal flow |
| Watch sync / logbook merge / GPS / BUSSOLA runtime | Unrelated to planner reference |
| Certified-sounding marketing copy outside planner | Safety positioning |

**Safe to modify (planner pass):**
- `iOSApp/Algorithms/Buhlmann/*`
- `iOSApp/Services/Planner*.swift`, `BuhlmannPlanner.swift`, `GasPlanning*.swift`, `ScheduleGas*.swift`, `Repetitive*.swift`, `OxygenExposure*.swift`
- `iOSApp/Utils/Planner*.swift`
- `iOSApp/Views/Planner*.swift`
- `Tests/iOSAlgorithmTests/*`
- Bühlmann/planner docs under `Docs/`

---

## Final Recommendations

### Next Cursor / Codex command strategy

1. **Fix Phase A (P2-1)** — smallest high-value diff: pass `PlannerEnvironment` into `PlannerStore` Bühlmann preview.
2. **Fix Phase A (P1-2)** — align `airSaturated()` with environment surface pressure.
3. **Run** `xcodegen generate && xcodebuild test -scheme "DIRDiving iOS Algorithm Tests"` on macOS after each phase.
4. **Re-run** this audit checklist or update this document with “resolved” markers.
5. **Do not** merge experimental branches or touch Watch code.

### macOS validation requirement

All release claims require macOS `xcodebuild` test pass (88+ tests) on a current iOS simulator. Windows/static-only review is insufficient for release sign-off.

### Documentation update requirement

After implementation, update:
- `Docs/DIR_DIVING_IOS_BUHLMANN_ENGINE_DESIGN.md`
- `Docs/DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_UX_UI_REAUDIT.md` (or new addendum)
- `Docs/DIR_DIVING_Feature_Comparison.csv` if UX rows change

### Git commit strategy (future work)

Separate commits per phase:
1. `fix(ios): align Bühlmann preview with planner environment`
2. `fix(ios): unify tissue saturation surface pressure baseline`
3. `fix(ios): repetitive snapshot UX and surface interval states`
4. `docs: update Bühlmann comprehensive audit follow-up`

Never force-push `main`. No experimental merges.

---

## Audit Certification

| Check | Result |
|---|---|
| Code modified | **No** |
| Commits created | **No** |
| Push performed | **No** |
| Watch files touched | **No** |
| Experimental files touched | **No** |
| Tests executed | **Yes** — 88/88 pass @ macOS |
| Build executed | **Yes** — DIRDiving iOS BUILD SUCCEEDED |

**Safety reminder:** DIR DIVING is **not** a certified dive computer. The Bühlmann planner is a **Bühlmann-based planning reference** for informational use only. Users must rely on training, team procedures, and certified instruments for decompression control.
