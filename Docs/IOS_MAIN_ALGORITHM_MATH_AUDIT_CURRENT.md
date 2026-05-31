# iOS Companion MAIN — Algorithm & Mathematical Functions Audit (Current)

**Audit date:** 2026-05-31  
**Repository:** `egopfe/DirDiving-App`  
**Branch audited:** `main` @ `4d5aabc`  
**Target:** `DIRDiving iOS` (iOS Companion MAIN only)  
**Mode:** Read-only audit — no application code changes

> **Update 2026-05-31:** Readiness remediation complete on `main` @ `dce89e7`. See [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md). **Post-remediation estimate: 100%** (code criteria; external QA still required per report § K). Scores below reflect **pre-remediation** audit @ `4d5aabc`.

---

## A. Executive Summary

### Readiness scores (iOS Companion MAIN @ `4d5aabc`)

| Dimension | Score | Notes |
|-----------|------:|-------|
| **Overall algorithmic readiness** | **76%** | Strong core; known cross-layer inconsistencies |
| **Mathematical robustness** | **78%** | Typed validation, Schreiner loading, bounded integration |
| **Planner confidence** | **72%** | Real ZHL-16C reference engine; non-certified by design |
| **Sync / data integrity confidence** | **75%** | HMAC + normalization; blob LWW cloud merge |
| **Unit / display consistency** | **74%** | Dual pressure models (environment vs legacy 10 m/bar) |
| **Automated test coverage (algorithms)** | **82%** | 119 iOS algorithm XCTest cases; gaps in CSV/cloud/UI |

### Critical blockers

| ID | Blocker | Type |
|----|---------|------|
| B1 | GitHub Actions billing prevents CI verification on remote | Process / infra |
| B2 | MOD/PPO₂ validation uses legacy 1.0 bar + 10 m/bar while Bühlmann uses `AmbientPressureModel` — diverges at altitude | Mathematical consistency |
| B3 | Average-depth planning mode changes NDL preview but full deco still uses max depth | Semantic inconsistency |
| B4 | Cloud sync is whole-logbook last-write-wins; per-session `DiveSessionMerge` rarely runs | Data integrity |
| B5 | CSV export omits start date and `# session_meta`; re-import loses timeline and manual fields | Data round-trip |

### TestFlight blockers

- Resolve B2–B5 or document accepted limitations in internal test playbook.
- Confirm planner safety acknowledgement flow on device (session-scoped).
- Paired Watch ↔ iPhone round-trip QA for manual pressure fields and tombstones.
- Demo logbook must be OFF during external-facing tests (Analysis aggregates include demo when ON).

### App Store blockers

- All TestFlight blockers, plus:
- External QA sign-off on reference-only planner copy vs displayed deco schedules.
- Verified Subsurface CSV regression suite (export → re-import on supported fields).
- iCloud conflict scenario tested (edit same dive on two devices).

### What blocks 100% algorithmic readiness

**Status @ `dce89e7`:** Items 1–6 below **implemented** on `main`. Remaining gaps are **external QA** — see [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) § J–K.

1. ~~Environment-unified pressure/MOD path across validator, display, and engine.~~ ✅  
2. ~~Planning-depth reference semantics aligned end-to-end (average vs max).~~ ✅  
3. ~~Field-level cloud merge or documented single-writer policy with user-visible conflict UI.~~ ✅  
4. ~~CSV round-trip preserving start date and manual metadata.~~ ✅  
5. ~~Analysis dashboard excluding demo sessions when demo toggle is ON.~~ ✅  
6. ~~Contingency / mock GF helper code removed or wired to engine recomputation.~~ ✅  

**Still open (process / infra):**

---

## Phase 0 — Preflight

### 0.1 Branch & git status

```
Branch: main @ 4d5aabc
Remote: origin/main (aligned)
Working tree: clean
```

### 0.2 Experimental exclusion (`project.yml`)

`DIRDiving iOS` sources `iOSApp` with these **excludes** (not in MAIN build):

| Path | Reason |
|------|--------|
| `iOSApp/Models/ExplorationModels.swift` | Experimental |
| `iOSApp/Models/BuddyExperimentalModels.swift` | Experimental |
| `iOSApp/Services/ExplorationPlanningStore.swift` | Experimental |
| `iOSApp/Services/BuddyExperimentalStore.swift` | Experimental |
| `iOSApp/Views/ExplorationCenterView.swift` | Experimental |
| `iOSApp/Views/ExperimentalFutureConceptsView.swift` | Experimental |
| `iOSApp/Views/BuddyExperimentalView.swift` | Experimental |

Watch experimental surfaces (Apnea, Snorkeling, Buddy) are excluded from Watch MAIN target separately; iOS audit does not inspect them.

### 0.3 iOS MAIN target file inventory (build membership)

**Algorithms**

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`

**Models**

- `iOSApp/Models/DemoDiveCatalog.swift`
- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/DiveSample.swift`
- `iOSApp/Models/DiveSession.swift`
- `iOSApp/Models/EquipmentProfile.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Models/GPSPoint.swift`
- `iOSApp/Models/TankSize.swift`

**Services**

- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/EquipmentStore.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/RouteSummaryService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchPhotoPreprocessor.swift`
- `iOSApp/Services/WatchSyncAuth.swift`
- `iOSApp/Services/WatchSyncService.swift`

**Utils**

- `iOSApp/Utils/CloudSyncNotifications.swift`
- `iOSApp/Utils/CompanionDisclaimerAcceptance.swift`
- `iOSApp/Utils/DiveProfileMath.swift`
- `iOSApp/Utils/DiveSessionAlgorithmValidator.swift`
- `iOSApp/Utils/DiveSessionMerge.swift`
- `iOSApp/Utils/Formatters.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/IOSAlgorithmConfiguration.swift`
- `iOSApp/Utils/IOSDiveLogbookPolicy.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/LegalDisclaimerScrollGate.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/PlannerSafetyAcknowledgment.swift`
- `iOSApp/Utils/WatchSyncKeys.swift`
- `iOSApp/Utils/WatchSyncNotifications.swift`

**Views (algorithm-relevant)**

- `iOSApp/Views/AnalysisView.swift`
- `iOSApp/Views/CSVImportPanel.swift`
- `iOSApp/Views/DiveDetailView.swift`
- `iOSApp/Views/EquipmentChecklistGasSection.swift`
- `iOSApp/Views/EquipmentTemplateEditorView.swift`
- `iOSApp/Views/EquipmentTemplatesSheet.swift`
- `iOSApp/Views/EquipmentView.swift`
- `iOSApp/Views/LogbookView.swift`
- `iOSApp/Views/ManualDiveEditorView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Views/PlannerView.swift` (includes `PlanResultView`)
- `iOSApp/Views/WatchPhotoTransferPanel.swift`

**Shared Watch models consumed by iOS** (via test target / sync codec patterns): root `Models/DiveSample.swift`, `Models/DiveSession.swift`, `Models/GPSPoint.swift` — iOS uses `iOSApp/Models/*` copies with same semantics.

**Test target:** `DIRDiving iOS Algorithm Tests` — **119** test methods across 20 files + JSON fixtures.

---

## B. Algorithm Inventory (by family)

### 1. Planner / dive planning

| Symbol | File | Inputs → Outputs | Units | Thresholds | Safety |
|--------|------|------------------|-------|------------|--------|
| `PlannerService.makePlan` | `PlannerService.swift` | `GasPlanInput` → `DivePlanResult` | m, min, bar, L | via validator | Orchestrates full plan |
| `PlannerInputValidator.validate` | `PlannerInputValidator.swift` | input → `Result` | m, min, GF%, SAC | depth 0.1–120; bottom 0–600 | Blocks invalid plans |
| `BuhlmannPlanner.makeRequest` | `BuhlmannPlanner.swift` | input + env → `BuhlmannPlanRequest` | m, min, bar | GF, gases, cylinders | Travel/deco gas lists |
| `BuhlmannEngine.plan` | `BuhlmannEngine.swift` | request → stops, segments, TTR | m, min | 180 min/stop; 720 min total | Full deco schedule |
| `BuhlmannEngine.noDecompressionLimit` | same | depth, gas, tissue → NDL | min | 32-iter binary search | Reference NDL |
| `PlannerStore` / `PlannerView` | `PlannerStore.swift`, `PlannerView.swift` | UI state → recalc | display units | safety ack session | Acknowledgement gate |

### 2. Bühlmann / decompression display

| Symbol | File | Nature |
|--------|------|--------|
| `BuhlmannConstants` | `BuhlmannConstants.swift` | ZHL-16C 16-compartment N₂+He a/b, half-times |
| `BuhlmannTissueState` | `BuhlmannTissueModel.swift` | Schreiner + constant-depth loading |
| `BuhlmannEngine.decompressionSchedule` | `BuhlmannEngine.swift` | GF-low/high interpolation, 3 m stops |
| `BuhlmannPlanner.ndlCurve` | `BuhlmannPlanner.swift` | NDL preview points for chart |
| `PlannerView.buhlmannChart` | `PlannerView.swift` | **Cosmetic Y-axis** `100 - depth×1.5` |

**Verdict:** Real reference ZHL-16C multigas engine; UI chart axis is illustrative, not tissue load.

### 3. Gas planning

| Symbol | File | Formula |
|--------|------|---------|
| `GasPlanningService.analyze` | `GasPlanningService.swift` | SAC × ambient(bar) × minutes; CNS/OTU integration |
| `ScheduleGasConsumptionService.analyze` | `ScheduleGasConsumptionService.swift` | Per-segment cylinder ledger |
| `ScheduleGasConsumptionService.rockBottomLiters` | same | emergencySAC × team × avgAscentATA × minutes |
| `GasPlanningService.equivalentNarcoticDepth` | `GasPlanningService.swift` | END |
| `GasPlanningService.equivalentAirDepth` | same | EAD (He=0 only) |

### 4. PPO₂ / MOD / gas safety

| Symbol | File | Model |
|--------|------|-------|
| `GasMixValidator.validate` | `GasMixValidator.swift` | O₂/He fractions, maxPPO₂ 1.0–1.6 bar |
| `GasMixValidator.modMeters` | same | **Legacy:** 1.0 bar surface, 10 m/bar |
| `BuhlmannGas.ppO2` | `BuhlmannGas.swift` | **Environment:** `AmbientPressureModel` |
| `PlannerMODValidator.validate` | `PlannerMODValidator.swift` | MOD + 0.05 m tolerance at switches |
| `GasPlanningService.boundedPPO2` | `GasPlanningService.swift` | Caps display PPO₂ at gas max |

### 5. SAC / gas consumption

- RMV semantics: liters = SAC(L/min) × ambient pressure(bar) × time(min).
- Rock bottom: team size, emergency SAC, average ascent depth ≈ maxDepth/2, ascent rate 9 m/min (+3 min if depth>10 m).
- Reserve / below-reserve warnings via cylinder start, reserve, consumed ledger.

### 6. CNS / OTU / oxygen exposure

| Model | File | Details |
|-------|------|---------|
| `NOAACNSLimitTable` | `OxygenExposureModels.swift` | Piecewise single-exposure limits |
| `NOAACNSDailyLimitTable` | same | Daily knots 1.0–1.6 bar |
| `CNSRecoveryModel` | same | PPO₂ ≤ 0.5 → 90 min half-time decay |
| `OTUModel` | same | Lambertsen REPEX: `(0.5/(PPO2-0.5))^(5/6)` |
| `OxygenExposureCarryover` | same | Snapshot v2 repetitive carryover |
| Integration step | same | 0.05 min; cap CNS 300%; OTU daily 850 / weekly 1800 |

### 7. Dive log statistics

| Location | Metrics |
|----------|---------|
| `DiveProfileMath.summary` | duration, max/avg depth (time-weighted), TTV, temp mean |
| `AnalysisView` | count, max depth, total runtime, avg temp, avg SAC, routes, gas counts |
| `IOSDiveLogbookPolicy` | sort, cap 40 sessions |

### 8. Depth profile / charts

| Location | Behavior |
|----------|----------|
| `DiveDetailView.depthChart` | Catmull-Rom; Y inverted `[max+8, 0]` in display units |
| `AnalysisView` bar chart | Per-session max depth vs date |
| `ManualDiveSampleBuilder` | 4-point synthetic profile |

### 9. Analysis dashboard

Aggregates over **all** `logStore.sessions` (includes demo when present). Route bearing shows **first** route only.

### 10. Manual dive add/edit

- Validation: 5–300 min UI; start/end ordering; depth bounds via normalizer.
- Synthetic samples → `DiveProfileMath.summary` → `normalizedForStorage`.
- Silent failure if `logStore.add` rejects validation (**HIGH** finding).

### 11–13. CSV import / export / Subsurface

| Pipeline | Bounds |
|----------|--------|
| Import | 10 MB; 300 m depth; 24 h; 20k samples; -2…40 °C |
| Export | `normalizedForStorage`; 2-decimal depth; monotonic integer seconds |
| Session ID | SHA-256 first 16 bytes of file |

### 14. Watch sync

- HMAC-SHA256 signed envelope (`WatchDiveSyncCodec`).
- Sync depth limit **350 m** (vs CSV 300 m).
- Recomputes derived fields; rejects if stored scalars drift > tolerances.
- Demo dives not pushed to Watch.

### 15. Cloud merge / iCloud KVS

- `CloudSyncStore`: blob-level LWW on `.__modifiedAt`.
- Entire `[DiveSession]` array replaced — no per-field numeric merge in production path.
- `DiveSessionMerge.preferred` implemented but both load paths often read same merged blob.

### 16. Unit conversion / formatters

- `IOSUnitConversions`: m↔ft, °C↔°F, bar↔psi, L↔cu ft, ambient pressure helpers.
- `Formatters`: display precision, nil → `"--"`, planner metric-core policy.
- **Dual model:** `AmbientPressureModel` (Bühlmann) vs `IOSUnitConversions.ambientPressureBar` (1.0 + depth/10).

### 17. Equipment / checklist

- `EquipmentStore`: persistence only; checklist completion = boolean flags; no dive math.
- Templates copy checklist items; gas/tank size labels for UI only.

### 18. Demo logbook isolation

- Toggle `dirdiving_ios_include_demo_logbook`; stable UUID catalog; blocked from Watch sync and manual edit.
- **Not** excluded from `AnalysisView` aggregates.

### 19. Edge / empty paths

- `PlannerService.unavailablePlan`: zeros + `invalidInput` state.
- Empty logbook: Analysis empty states; charts hidden.
- Empty samples: export fails; detail chart empty.

---

## C. Findings by Family

### C.1 Planner / Bühlmann

| ID | Sev | Title | File / function | Impact | Fix class |
|----|-----|-------|-----------------|--------|-----------|
| P-01 | **HIGH** | MOD validator ignores altitude/salinity | `GasMixValidator.modMeters`, `PlannerMODValidator` | False MOD pass/fail vs engine at altitude | Small functional |
| P-02 | **HIGH** | Average-depth mode skews NDL preview vs engine max depth | `PlannerStore`, `BuhlmannPlanner.makeRequest` | Misleading NDL/TTR relationship | Small functional |
| P-03 | **HIGH** | Partial deco when calculation limit hit | `BuhlmannEngine.decompressionSchedule` | Incomplete schedule still displayed | Copy + UI guard |
| P-04 | **MEDIUM** | Contingency plans use hardcoded TTS offsets | `GasPlanningService.contingencyPlans` | Non-engine-derived contingencies | Small functional |
| P-05 | **MEDIUM** | Mock `gfComparisons` duplicate exists | `GasPlanningService.gfComparisons(input:baseTTS:)` | Dead code confusion | Cleanup |
| P-06 | **MEDIUM** | Bailout cylinders excluded from engine gas lists | `BuhlmannPlanner.makeRequest` | Bailout not in deco math | Architectural note |
| P-07 | **LOW** | NDL chart Y-axis cosmetic | `PlannerView.buhlmannChart` | Could misread as tissue load | Copy-only |
| P-08 | **LOW** | Water temperature validated but unused | `PlannerInputValidator` | No thermal model | INFO |
| P-09 | **INFO** | Reference-only disclaimers present | `PlannerResultState`, `PlannerView` | Mitigates certified-deco risk | — |

### C.2 Gas / PPO₂ / MOD

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| G-01 | **HIGH** | Dual pressure models (1.0 bar vs 1.01325; 10 m/bar vs ρgh) | `IOSAlgorithmConfiguration`, `AmbientPressureModel` | Cross-feature inconsistency | Medium refactor |
| G-02 | **MEDIUM** | `boundedPPO2` may hide over-limit actual PPO₂ in display | `GasPlanningService` | Under-warning in UI | UI-only |
| G-03 | **LOW** | END > 30 m triggers `.simplifiedReferenceOnly` heuristic | `GasPlanningService.makeStates` | Conservative state flag | INFO |

### C.3 CNS / OTU

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| O-01 | **MEDIUM** | OTU linear-ramp helper unused; midpoint integration only | `OxygenExposureModels.swift` | Small integration error on ramps | Small functional |
| O-02 | **MEDIUM** | Weekly/daily OTU reset is binary at SI thresholds | `OxygenExposureCarryover` | No partial decay | Document / small functional |
| O-03 | **INFO** | Comprehensive NOAA tables implemented | `OxygenExposureModels.swift` | Real model, not placeholder | — |

### C.4 Logbook / statistics / demo

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| L-01 | **MEDIUM** | Demo dives included in Analysis aggregates | `AnalysisView` | Inflated stats in demo mode | UI-only |
| L-02 | **MEDIUM** | Avg temperature is sample mean, not time-weighted | `DiveProfileMath.summary` | Slight stat bias | Small functional |
| L-03 | **LOW** | `exceededSupportedDepthRange` threshold duplicated (40 m) | `DiveSession`, `IOSAlgorithmConfiguration` | Maintenance drift risk | Cleanup |

### C.5 CSV / export / import

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| C-01 | **HIGH** | CSV re-import loses start date | `SubsurfaceExportService`, `DiveImportService` | Wrong dive timeline | Small functional |
| C-02 | **HIGH** | `# session_meta` exported but not imported | same | Manual fields lost on round-trip | Small functional |
| C-03 | **MEDIUM** | Depth limit 300 m export vs 350 m sync | `IOSAlgorithmConfiguration` | Divergent acceptance | Small functional |
| C-04 | **MEDIUM** | Export monotonic integer seconds | `SubsurfaceExportService` | Sub-second profile loss | Document |

### C.6 Watch sync / cloud

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| S-01 | **HIGH** | Cloud merge is blob LWW only | `CloudSyncStore`, `DiveLogStore` | Whole-logbook overwrite | Architectural |
| S-02 | **MEDIUM** | Sync ID list truncation (128/256) | `WatchDiveSyncCodec`, `WatchSyncService` | Duplicate re-sync edge case | Small functional |
| S-03 | **MEDIUM** | Conflict = full struct inequality | `WatchSyncService` | Metadata-only diffs block import | Small functional |
| S-04 | **INFO** | HMAC + recompute validation on receive | `WatchDiveSyncCodec` | Strong integrity | — |

### C.7 Manual dive / UI

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| M-01 | **HIGH** | Manual save fails silently on validation error | `ManualDiveEditorView`, `DiveLogStore.add` | User data loss perception | UI-only |
| M-02 | **LOW** | Pressure consumed is display parse only | `DiveDetailView` | No unit validation on free text | Copy-only |

### C.8 Units / formatters

| ID | Sev | Title | File | Impact | Fix class |
|----|-----|-------|------|--------|-----------|
| U-01 | **MEDIUM** | Planner core metric; imperial display only | `Formatters`, `PlannerView` | Documented but easy to miss | Copy-only |
| U-02 | **LOW** | Duration display rounds to whole minutes | `Formatters` | ±30 s display | INFO |

---

## D. Edge Case Matrix

| Case | Expected | Observed (code) | Tested |
|------|----------|-----------------|--------|
| Depth = 0 | Reject (< 0.1 m) | `PlannerInputValidator` rejects | Unit |
| Depth 120 m | Accept if gases valid | Accepted; engine validates | Unit |
| Depth > 120 m | Unavailable plan | Rejected | Unit |
| Bottom time = 0 | Reject | Rejected | Unit |
| Trimix bottom gas | Full He compartments | Engine supports; disclaimer shown | Unit |
| Altitude 3000 m | Environment-aware Bühlmann | Engine yes; MOD validator no | **Gap** |
| Average depth planning | Consistent NDL/deco reference | NDL preview ≠ engine depth | **Gap** |
| Imperial units | Display conversion only | Correct in Formatters | Manual |
| Empty logbook | Zero aggregates | Analysis empty state | Manual |
| Demo ON | Isolated from sync | Analysis still includes demo | **Gap** |
| CSV duplicate file | Same UUID, skip duplicate | SHA-256 ID | Partial |
| Watch dive → iOS | Recompute + validate | `validateForSync` | Unit partial |
| iCloud stale blob | LWW picks newer | Whole array replace | **Gap** |
| Manual end < start | Reject | Editor validation | Manual |
| Single sample chart | Renders one point | Catmull-Rom degenerates gracefully | Manual |
| PPO₂ > 1.6 | Warning / state | `.PPO2Exceeded` | Unit |
| CNS > 80% | Elevated warning | `.oxygenExposureElevated` | Unit |
| Repetitive stale snapshot | Fresh tissue fallback | `RepetitiveDivePlannerService` | Unit |

---

## E. Unit / Integration Test Plan

**Existing:** 119 tests in `DIRDiving iOS Algorithm Tests` covering Bühlmann engine, GF, trimix, NDL, fixtures, CNS/OTU deep model, UX readiness, comprehensive readiness.

**Recommended additions:**

| Priority | Feature | Input | Expected | Pass criteria |
|----------|---------|-------|----------|---------------|
| P0 | MOD at altitude | 32% @ 3000 m | MOD < sea-level MOD | Validator matches `AmbientPressureModel` |
| P0 | Average vs max planning depth | avg mode, 30 m avg / 40 m max | NDL consistent with documented reference | Single depth source documented |
| P0 | CSV round-trip | export → import | start date + manual meta preserved | Fields equal |
| P1 | Cloud LWW | two device edits | user-visible conflict or merge | No silent loss |
| P1 | Analysis demo isolation | demo ON | stats exclude demo IDs | Counts match non-demo |
| P1 | Manual save rejection | invalid depth | UI error shown | Non-silent |
| P2 | Sync 320 m dive | Watch payload | accepted sync, CSV export policy | Document limit |
| P2 | Contingency plans | engine TTS | contingencies recomputed | Within ±1 min of engine |

---

## F. Paired Watch / iPhone Test Plan

1. Record Watch dive → verify iOS import: depth, duration, TTV, samples within tolerances.  
2. Manual iOS dive with entry/exit pressure → push to Watch → edit on Watch → conflict UI.  
3. Delete dive on iOS → tombstone → Watch does not resurrect.  
4. Units: iOS imperial, Watch metric → display consistency on detail view.  
5. Demo dive ON → confirm not in Watch queue.  
6. Offline queue → reconnect → ack signature verified.

---

## G. CSV Import/Export Regression Plan

1. Golden Subsurface file: import → export → compare depth/time columns (±0.01 m, ±1 s).  
2. Missing headers → structured error, no crash.  
3. 10 MB + 1 byte → reject.  
4. 20,001 rows → reject.  
5. Export with notes containing commas/quotes → valid CSV.  
6. Re-import exported file → document known loss (start date, meta) until C-01/C-02 fixed.

---

## H. Cloud Merge Validation Plan

1. Device A edits dive max depth; Device B edits notes; sync both → observe LWW behavior.  
2. Malformed JSON in KVS → decode error surfaced in `CloudSyncStore` if implemented.  
3. Tombstone union across devices → deleted dive stays deleted.  
4. Equipment profile + templates merge via same LWW blob keys.

---

## I. Planner Boundary Validation Plan

1. GF 30/70 @ 40 m trimix 20 min → stops generated, `nonCertifiedReference` state.  
2. GF low ≥ high → unavailable plan, no stops.  
3. Hypoxic gas shallow → `.unsupportedGas` / blocking issue.  
4. Calculation limit → verify UI marks incomplete schedule.  
5. Safety acknowledgement reset per session → plan gated until ack.  
6. Repetitive dive with valid snapshot v2 → tissue seed differs from fresh.

---

## J. Prioritized Roadmap

### 1. Must fix before compile/use
- None (build passes locally on `main`).

### 2. Must fix before internal TestFlight
- P-01 MOD/environment alignment  
- M-01 Manual save error surfacing  
- L-01 Demo exclusion from Analysis (or force demo OFF in test builds)  
- Document planner reference-only scope in test playbook  

### 3. Must fix before external TestFlight
- P-02 Average/max depth consistency  
- C-01/C-02 CSV round-trip critical fields  
- S-01 Cloud conflict policy documented or field merge implemented  
- Paired sync QA checklist executed  

### 4. Must fix before App Store
- External QA on planner + CNS/OTU copy vs math  
- Subsurface regression green  
- iCloud multi-device scenario  
- Resolve GitHub Actions billing for CI gate  

### 5. Post-release improvements
- P-04/P-05 contingency and dead mock helpers  
- O-01/O-02 OTU integration refinements  
- P-06 bailout cylinder engine participation  
- P-07 chart axis relabeling  

---

## K. Final Verdict

| Question | Answer |
|----------|--------|
| **Mathematically ready?** | **Mostly** — core Bühlmann, gas ledger, and CNS/OTU models are implemented with strong unit tests; remaining gaps are cross-layer consistency (pressure/MOD, planning depth reference, CSV/cloud), not missing formulas. |
| **Planner safe enough for internal test?** | **Yes, with constraints** — reference-only copy and acknowledgement gate are appropriate; internal testers must treat deco schedules as non-certified study output. |
| **Sync/data ready?** | **Partially** — Watch sync integrity is strong; cloud blob LWW and CSV round-trip are the weak links. |
| **Ready for TestFlight?** | **Internal: yes** (after B2–B5 documented or fixed); **external: not until HIGH findings addressed or explicitly waived in QA sign-off.** |
| **Ready for App Store?** | **No** — requires external QA, CI restoration, and resolution/documentation of HIGH data-integrity findings. |
| **Blocks 100% readiness?** | Unified ambient pressure/MOD path; planning-depth semantics; cloud/CSV field preservation; demo/analysis isolation; engine-backed contingencies; CI billing restored. |

---

## Appendix — Phase audit notes (condensed)

### Phase 2 — Planner
Inputs validated before engine. Safety acknowledgement session-scoped via `PlannerSafetyAcknowledgment`. No mock rows in main `PlannerService` path; contingency rows are labeled scenarios. Metric calculation core; imperial display via `Formatters`.

### Phase 3 — Bühlmann
Real ZHL-16C N₂+He with Schreiner loading and GF stops. UI chart axis is **not** compartment loading. Copy states non-certified reference.

### Phase 4 — Gas planning
Cylinder ledger tracks consumption per segment; reserve warnings; rock bottom formula documented in `ScheduleGasConsumptionService`.

### Phase 5 — PPO₂/MOD
Validated fractions; MOD blocking issues surfaced; environment split is primary risk (P-01, G-01).

### Phase 6 — SAC
RMV at ambient pressure; nil SAC excluded from Analysis average.

### Phase 7 — CNS/OTU
Fully implemented NOAA + REPEX; not placeholder. UI shows computed values with elevated thresholds.

### Phase 8–10 — Logbook / charts / analysis
Derived fields recomputed on ingest; Analysis uses stored session scalars; demo leakage noted (L-01).

### Phase 11 — Manual dive
Synthetic profile builder; update-in-place via `DiveLogStore`; silent failure risk (M-01).

### Phase 12–13 — CSV
Robust row validation; export omits critical re-import fields (C-01, C-02).

### Phase 14–15 — Sync / cloud
HMAC Watch path strong; cloud LWW whole-blob (S-01).

### Phase 16 — Units
Centralized `Formatters` + `IOSUnitConversions`; planner stays metric internally.

### Phase 17 — Equipment
No algorithmic risk; checklist booleans only.

---

*Audit performed read-only on `main` @ `4d5aabc`. Prior report `DIR_DIVING_IOS_ALGORITHM_MATH_AUDIT.md` (2026-05-27) is superseded for readiness claims — codebase now includes full Bühlmann engine, environment model, repetitive snapshot v2, and 119 iOS algorithm tests.*
