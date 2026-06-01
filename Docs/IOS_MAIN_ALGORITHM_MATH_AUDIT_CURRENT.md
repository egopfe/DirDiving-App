# iOS Companion MAIN — Algorithm & Mathematical Functions Audit (Current)

**Audit date:** 2026-06-01  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main` @ `5c2a27a`  
**Target:** `DIRDiving iOS` (iOS Companion MAIN only)  
**Mode:** Read-only static audit — **no application code changes**  
**Related:** [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) (remediation @ `dce89e7`), [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) (Watch MAIN parallel), [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT.md), [`DIR_DIVING_IOS_PLANNER_LIMITATIONS.md`](DIR_DIVING_IOS_PLANNER_LIMITATIONS.md)

---

## A. Executive Summary

### Readiness scores (iOS Companion MAIN @ `5c2a27a`)

| Dimension | Score | Notes |
|-----------|------:|-------|
| **Overall algorithmic readiness** | **~89%** | Real ZHL-16C reference planner, strong XCTest suite; residual UX/display and cross-layer depth-cap inconsistencies |
| **Mathematical robustness** | **~91%** | Schreiner loading, GF deco, bounded integration, validators, finite guards |
| **Planner confidence** | **~86%** | Engine is substantive and labeled non-certified; NDL curve chart axis is **not** physiological |
| **Sync / data integrity confidence** | **~88%** | HMAC watch codec, per-session merge + conflict UI, CSV metadata round-trip; empty-profile merge edge case |
| **Unit / display consistency** | **~87%** | Metric storage; `Formatters` + `IOSUnitConversions`; documented split between Bühlmann max depth vs gas “effective” depth |
| **Automated test coverage (algorithms)** | **~90%** | **173** `func test*` in `Tests/iOSAlgorithmTests/`; gaps in view-level stats, manual editor, route distance |

### Critical blockers (algorithm)

**None at CRITICAL severity** for a **non-certified informational** companion with existing disclaimers and reference-only planner copy.

### TestFlight blockers (algorithm / data)

| ID | Severity | Topic |
|----|----------|--------|
| IOSMATH-HIGH-001 | HIGH | Bühlmann NDL chart Y-axis is decorative (`100 − depth×1.5`), not model output — misread risk |
| IOSMATH-HIGH-002 | HIGH | Depth cap **300 m** (CSV import/export) vs **350 m** (watch sync / logbook normalize) — cross-layer inconsistency |
| — | Process | Paired Watch ↔ iPhone round-trip in water / field GPS not replaceable by simulator |
| — | Process | External planner reference validation campaign (documented in Bühlmann readiness docs) |

### App Store blockers (algorithm / data)

- All TestFlight process items above  
- Verified Subsurface CSV regression on supported fields (automated tests exist; field sign-off recommended)  
- iCloud conflict + tombstone scenarios on two devices  
- Marketing must not claim certified decompression / NDL authority  

### Prior audit remediation status (@ `dce89e7`, verified still present in code)

| Legacy ID | Topic | Status @ `5c2a27a` |
|-----------|--------|---------------------|
| B2 | Unified `PlannerEnvironment` / `AmbientPressureModel` for MOD/PPO₂ | **Resolved** — `GasMixValidator.modMeters(environment:)` |
| B3 | Planning depth: Bühlmann uses max; gas uses `effectivePlanningDepthMeters` | **Resolved by design** — documented in `GasPlan` comments + `PlanningDepthReferenceTests` |
| B4 | Cloud merge | **Improved** — per-session `DiveSessionMerge.preferred` + `DiveSessionMergeConflictDetector` |
| B5 | CSV start date / `# session_meta` | **Resolved** — `SubsurfaceExportService` / `DiveImportService` |
| — | Analysis demo exclusion default | **Resolved** — `includeDemoInAnalysis` default `false` |

### What blocks 100% algorithmic readiness

1. **Hardware / paired-device QA** (Watch sync, GPS, real profiles)  
2. **IOSMATH-HIGH-001** — chart labeling or axis tied to real NDL/compartment data  
3. **IOSMATH-HIGH-002** — align or document depth ceilings across import/export vs sync  
4. **View-layer test gaps** — Analysis aggregates, manual editor imperial defaults, route math  
5. **Process** — CI billing / external golden validation sign-off (if required by release policy)  

---

## Phase 0 — Preflight

### 0.1 Branch & git status

```
Branch: main @ 5c2a27a
Working tree: dirty (Watch MAIN algorithm remediation in progress; iOS sources unchanged in dirty set)
```

### 0.2 Experimental exclusion (`project.yml` → `DIRDiving iOS`)

| Excluded path | Reason |
|---------------|--------|
| `iOSApp/Models/ExplorationModels.swift` | Exploration Lab |
| `iOSApp/Models/BuddyExperimentalModels.swift` | Buddy experimental |
| `iOSApp/Services/ExplorationPlanningStore.swift` | Exploration |
| `iOSApp/Services/BuddyExperimentalStore.swift` | Buddy |
| `iOSApp/Views/ExplorationCenterView.swift` | Exploration UI |
| `iOSApp/Views/ExperimentalFutureConceptsView.swift` | Experimental concepts |
| `iOSApp/Views/BuddyExperimentalView.swift` | Buddy UI |

### 0.3 iOS MAIN build surface

- **Target:** `DIRDiving iOS` — sources `iOSApp/**` minus excludes above  
- **Embedded:** `DIRDiving Watch App` (companion only; Watch runtime code not audited here except shared codecs/models consumed by iOS)  
- **Tests:** `DIRDiving iOS Algorithm Tests` — `Tests/iOSAlgorithmTests/**` + listed algorithm sources  

### 0.4 Files inspected (core)

| Layer | Paths |
|-------|--------|
| Planner | `PlannerService.swift`, `BuhlmannPlanner.swift`, `PlannerGasSchedule.swift`, `PlannerMODValidator.swift`, `PlannerEnvironment.swift`, `RepetitiveDivePlannerService.swift`, `PlannerStore.swift` |
| Bühlmann | `iOSApp/Algorithms/Buhlmann/*.swift` |
| Gas / exposure | `GasPlanningService.swift`, `ScheduleGasConsumptionService.swift`, `OxygenExposureModels.swift` |
| Logbook / profile | `DiveLogStore.swift`, `DiveProfileMath.swift`, `DiveSessionMerge.swift`, `DiveSessionAlgorithmValidator.swift` |
| Import/export | `DiveImportService.swift`, `SubsurfaceExportService.swift` |
| Sync | `WatchDiveSyncCodec.swift`, `WatchSyncService.swift`, `CloudSyncStore.swift`, `WatchSyncSessionDiff.swift` |
| Models | `DiveSession.swift`, `DiveSample.swift`, `GasPlan.swift`, `DivePlan.swift`, `TankSize.swift`, `DemoDiveCatalog.swift` |
| Utils | `IOSAlgorithmConfiguration.swift`, `IOSUnitConversions.swift`, `Formatters.swift`, `GasMixValidator.swift`, `PlannerInputValidator.swift`, `PlanCalculationCompleteness.swift`, `PlannerResultState.swift`, `IOSDiveLogbookPolicy.swift` |
| UI (math display) | `PlannerView.swift`, `DiveDetailView.swift`, `LogbookView.swift`, `AnalysisView.swift`, `ManualDiveEditorView.swift`, `CSVImportPanel.swift` |
| Equipment | `EquipmentStore.swift` (persistence only) |
| Tests | `Tests/iOSAlgorithmTests/*.swift` (34 files, 173 test methods) |

---

## B. Algorithm Inventory

### 1. Planner / dive planning

| Symbol | File | Inputs | Outputs | Units | Safety |
|--------|------|--------|---------|-------|--------|
| `PlannerService.makePlan` | `PlannerService.swift` | `GasPlanInput`, env, optional tissue snapshot | `DivePlanResult` | m, min, bar, % | Orchestrates reference plan |
| `PlannerInputValidator.validate` | `PlannerInputValidator.swift` | Depth 0.1–120 m, bottom 0–600 min, GF, gases, temp | Errors / warnings | — | Blocks invalid input |
| `PlannerSafetyAcknowledgment` | `PlannerSafetyAcknowledgment.swift` | UserDefaults revision | Bool gate | — | Procedural only |
| `PlanCalculationCompletenessResolver` | `PlanCalculationCompleteness.swift` | Engine result + stops | complete / incomplete / no solution | — | Hides partial stops on limit |

### 2. Bühlmann / decompression display

| Symbol | File | Inputs | Outputs | Notes |
|--------|------|--------|---------|-------|
| `BuhlmannEngine.plan` | `BuhlmannEngine.swift` | `BuhlmannPlanRequest` | NDL, TTS, stops, segments, tissue | ZHL-16C N₂+He, GF deco |
| `noDecompressionLimit` | `BuhlmannEngine.swift` | Depth, gases, GF high | minutes | Binary search 0–600; ascent **9 m/min** fixed |
| `decompressionSchedule` | `BuhlmannEngine.swift` | Bottom time, rates, switches | `[DecoStop]` | 3 m ladder; 180 min/stop; 720 min total caps |
| `BuhlmannPlanner.ndlCurve` | `BuhlmannPlanner.swift` | Depth 6…60 step 3 | `[NDLPoint]` | Compartment **labels** only |
| Chart series | `PlannerView.swift` | `ndlCurve` | Swift Charts | Y = `max(0, 100 − depth×1.5)` — **illustrative** |

**Implementation class:** Real reference engine, **not** certified deco computer. Copy: `BuhlmannPlanner.warning`, `PlannerResultState.nonCertifiedReference`.

### 3. Gas planning

| Symbol | File | Formula / behavior |
|--------|------|-------------------|
| `GasPlanningService.analyze` | `GasPlanningService.swift` | PPO₂, density, END, SAC×ATA×minutes, turn pressure, CNS/OTU when segments available |
| `ScheduleGasConsumptionService` | `ScheduleGasConsumptionService.swift` | Per-segment `SAC × ATA(depth) × min`; rock bottom with emergency SAC × team × ATA(depth/2) × emergency minutes |
| `GasPlan.estimatedConsumptionLiters` | `GasPlan.swift` | `SAC × ambientPressureBar(effective depth) × bottomMinutes` |

### 4. PPO₂ / MOD / gas safety

| Symbol | File | Rule |
|--------|------|------|
| `GasMixValidator` | `GasMixValidator.swift` | O₂ ∈ (0,1], He ≥ 0, O₂+He ≤ 1; maxPPO₂ 1.0–1.6 bar; `modMeters` via environment |
| `PlannerMODValidator` | `PlannerMODValidator.swift` | Switch depth > MOD + 0.05 m → issue |
| `BuhlmannGas.isOperational` | `BuhlmannGas.swift` | PPO₂ 0.16…max along depth path |

### 5. SAC / gas consumption

- Default SAC **18 L/min**, emergency **30 L/min** (`GasPlanInput`, `TankSize` presets).  
- **No SAC estimation from logged profile** in audited files — stored `sacLitersMinute` is user/import metadata.  
- Turn pressure: half of usable gas above rock bottom (rule-of-thumb).

### 6. CNS / OTU / oxygen exposure

| Model | File | Method |
|-------|------|--------|
| CNS | `OxygenExposureModels.swift` | NOAA 1991 piecewise; recovery half-time 90 min @ PPO₂ ≤ 0.5 |
| OTU | `OxygenExposureModels.swift` | Lambertsen/Baker; ramp integral step 0.05 min |
| Limits | `OxygenExposureModels.swift` | CNS single/daily warn 80%; OTU dive 300 / daily 850 / weekly 1800 |
| Planner rule | `CNSDescentBottomPlannerRule` | Warn if descent+bottom CNS > **15%** |
| Display cap | `GasPlanningService` | CNS capped at **300%** for display |

### 7. Dive log statistics

| Symbol | File | Behavior |
|--------|------|----------|
| `DiveProfileMath.summary` | `DiveProfileMath.swift` | Time-weighted avg depth, max, TTV, temps, exceeded ≥40 m |
| `DiveProfileMath.ttvIndex` | `DiveProfileMath.swift` | `avgDepth + durationSeconds/60` |
| `AnalysisView` aggregates | `AnalysisView.swift` | Count, max depth, sum duration, mean SAC/temp, route count |
| `LogbookView` grouping | `LogbookView.swift` | Calendar month buckets, text search |

### 8. Depth profile / charts

| Symbol | File | Behavior |
|--------|------|----------|
| `DiveDetailView` chart | `DiveDetailView.swift` | Catmull-Rom; Y domain `[depthValue(max+8), 0]` (surface at top) |
| Sample storage | `DiveSample.swift` | `depthMeters`, `temperatureCelsius?`, `timestamp` (metric) |

### 9. Analysis dashboard

- Tiles from `analysisSessions` (demo excluded by default).  
- Bar chart: max depth per dive day — auto Y scale.  
- Route card: sum distance; bearing from **first** route only.

### 10. Manual dive add/edit

| Symbol | File | Behavior |
|--------|------|----------|
| `ManualDiveSampleBuilder` | `ManualDiveEditorView.swift` | 4-point synthetic profile → `DiveProfileMath.summary` |
| Metadata-only path | `ManualDiveEditorView.swift` | Preserves depths when `!hasDepthProfile` |
| GPS | `ManualDiveEditorView.swift` | `horizontalAccuracy: 10` if coords valid |

### 11–13. CSV import / export / Subsurface

| Path | Cap | Key rules |
|------|-----|-----------|
| Import | 10 MB, ≤20k samples | Requires `time_seconds`, `depth_m`, `temperature_c` columns; depth ≤ **300 m** |
| Export | Same 300 m normalize | `# session_meta`, `# dirdiving_start_date`, monotonic `time_seconds` from `startDate` |
| Validator | Storage | Stored max/avg/ttv must match recomputed within 0.25/0.25/0.5 |

### 14. Watch sync numerical consistency

- Payload: JSON `DiveSession` + HMAC; skew ≤ 3600 s; depth ≤ **350 m** in `WatchDiveSyncCodec.validateForSync`.  
- Manual no-depth: empty samples allowed when `isManual && !hasDepthProfile`.  
- iOS `WatchSyncService`: passes session through codec; display strings only.

### 15. Cloud merge / KVS

- `CloudSyncStore`: newer `modifiedAt` wins for **blob** keys.  
- `DiveLogStore`: union by session ID; `DiveSessionMerge.preferred` unless field-level conflict flagged.  
- `DiveSessionMergeConflictDetector`: user resolves keep-local vs use-cloud.

### 16. Unit conversion / formatting

- `IOSUnitConversions`: m↔ft, bar↔psi, L↔cu ft, °C↔°F, m/min↔ft/min.  
- Fallback ATA: `1 + depth/10` when environment build fails.  
- `Formatters`: display precision; export depths remain metric in CSV.

### 17. GPS / route

- `RouteSummaryService`: haversine, earth radius 6_371_000 m; bearing 0…360.

### 18. Equipment / checklist

- `EquipmentStore`: checklist/templates JSON — **no dive math**.

### 19. Demo isolation

- `DemoDiveCatalog` fixed UUIDs; `isDemo` flag; Analysis toggle; demo non-deletable in logbook.  
- `insertDemoDives`: synthetic profiles; **idx 0 TTV hardcoded 24** (inconsistent with formula).

### 20. Edge / empty paths

- Empty logbook → empty analysis with import CTAs.  
- No profile → detail chart placeholder; export blocked.  
- Engine `calculationLimitReached` → completeness incomplete, **presentation stops cleared**.

---

## C. Findings by Family

### Planner / Bühlmann

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-HIGH-001 | HIGH | NDL chart Y-axis is non-physiological | `PlannerView.swift` ~1383 | Users may treat chart as tissue loading | Misread as certified science | P2 TestFlight | UI-only / copy |
| IOSMATH-MED-001 | MED | NDL search uses fixed 9 m/min ascent | `BuhlmannEngine.noDecompressionLimit` | NDL differs from user ascent rate setting | Conservative/aggressive vs user expectation | P3 | Small functional |
| IOSMATH-MED-002 | MED | `calculationLimitReached` clears all stops in UI | `PlanCalculationCompletenessResolver` | Partial deco hidden | May underestimate required stops | P2 | Small functional |
| IOSMATH-MED-003 | MED | `BuhlmannPlanner.plan` preview validates GF 85 while NDL uses param | `BuhlmannPlanner.swift` | Preview edge inconsistency | Low direct risk | P4 | Small functional |
| IOSMATH-LOW-001 | LOW | NDL curve compartment groups are display labels only | `BuhlmannPlanner.ndlCurve` | Cosmetic | Low | P5 | Copy-only |
| IOSMATH-INFO-001 | INFO | Bailout cylinders excluded from engine | `PlannerGasSchedule` / `makeRequest` | Schedule-only bailout | Documented | — | — |
| IOSMATH-INFO-002 | INFO | Repetitive surface interval loads on air @ maxPPO2 1.4 | `RepetitiveDivePlannerService` | SI model simplification | Informational | — | — |

### Gas / SAC / CNS / OTU

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-MED-004 | MED | Simple `analyze(input:)` ignores ascent/deco SAC | `GasPlanningService` | Underestimates gas without full engine | Planning optimism | P3 | Document / wire engine |
| IOSMATH-MED-005 | MED | Lost-gas warning uses 30% consumed heuristic | `ScheduleGasConsumptionService` | False +/- vs real rules | Informational contingency | P4 | Small functional |
| IOSMATH-LOW-002 | LOW | CNS display cap 300% | `GasPlanningService` / exposure | Masks extreme integration | Display only | P5 | UI-only |
| IOSMATH-LOW-003 | LOW | Turn pressure = half usable above rock bottom | `GasPlanningService` | Non-standard rule | Informational | P5 | Copy |
| IOSMATH-INFO-003 | INFO | END > 30 m → `simplifiedReferenceOnly` | `GasPlanningService` | Policy flag | Informational | — | — |

### Logbook / profile / merge

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-HIGH-002 | HIGH | Import/export 300 m vs sync 350 m | `IOSAlgorithmConfiguration` | Watch dive fails CSV re-export | Data friction | P2 TestFlight | Small functional / doc |
| IOSMATH-MED-006 | MED | Empty-profile merge uses `min(avg)` not summary | `DiveSessionMerge.preferred` L32 | Under-reported avg after merge | Stats wrong | P3 | Small functional |
| IOSMATH-MED-007 | MED | Imperial manual defaults 30/18 not converted on new dive | `ManualDiveEditorView` | Wrong depths in ft mode | Incorrect log | P2 | Small functional |
| IOSMATH-LOW-004 | LOW | Demo dive idx 0 TTV = 24 fixed | `DiveLogStore.insertDemoDives` | Demo analysis skew | Demo only | P5 | Small functional |
| IOSMATH-INFO-004 | INFO | `exceededSupportedDepthRange` forced if max ≥ 40 m | `DiveSession` init/decode | Aligns with Watch policy | Informational | — | — |

### Analysis / UI display

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-MED-008 | MED | Route bearing uses first route only | `AnalysisView` | Misleading multi-dive routes | Navigation info wrong | P4 | UI-only |
| IOSMATH-LOW-005 | LOW | Salinity always “not recorded” | `DiveDetailView` | Static placeholder | No false numeric | P5 | Copy |
| IOSMATH-LOW-006 | LOW | Pressure footnote: raw `entry-exit` without unit conversion | `DiveDetailView` | Wrong if mixed units typed | Low | P5 | UI-only |
| IOSMATH-INFO-005 | INFO | Analysis excludes demo by default | `AnalysisView` | Correct isolation | — | — | — |

### Sync / cloud / import-export

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-MED-009 | MED | Cloud blob LWW; per-session merge on conflict only | `CloudSyncStore` + `DiveLogStore` | Rare whole-logbook overwrite | Data loss risk | P3 | Process + UI |
| IOSMATH-LOW-007 | LOW | Deco stop MOD validation indexes gases by stop order | `PlannerMODValidator.validateDecoStops` | Wrong gas if order mismatched | MOD display | P4 | Small functional |
| IOSMATH-INFO-006 | INFO | CSV export repeats GPS/meta on every sample row | `SubsurfaceExportService` | Large files | No math error | — | — |

### Units / environment

| ID | Sev | Title | Location | User impact | Safety | Fix priority | Impact |
|----|-----|-------|----------|-------------|--------|--------------|--------|
| IOSMATH-MED-010 | MED | Fallback `1 + depth/10` when env build fails | `IOSUnitConversions` | Diverges from altitude/salinity model | MOD/PPO₂ error | P3 | Small functional |
| IOSMATH-INFO-007 | INFO | Bühlmann depth always max; gas uses effective depth | `GasPlan` | Documented split | Intentional | — | — |

---

## D. Edge Case Matrix (selected)

| Case | Expected (code intent) | Observed / risk | Tested |
|------|------------------------|-----------------|--------|
| Planner depth 0 | Rejected (< 0.1 m) | Validator error | Yes |
| Depth 120 m | Allowed | Engine runs | Yes |
| Depth > 120 m | Blocked | Validator | Yes |
| Bottom 0 min | Invalid / edge | Validator | Partial |
| Bottom > NDL | Deco or `noDecompressionSolution` | Completeness resolver | Yes |
| GF low ≥ high | Blocked | Validator | Yes |
| O₂ fraction 0 | Invalid mix | `GasMixValidator` | Yes |
| Imperial planner display | Metric internally | Formatters | Partial |
| Empty logbook | Zero aggregates | Analysis empty state | Partial |
| Demo only + analysis default off | Empty analysis | By design | Yes (`AnalysisDemoIsolationTests`) |
| Watch dive 320 m deep | Sync OK @ 350 | CSV export/import fails @ 300 | **Gap** |
| Manual no-depth | Sync allowed | `WatchManualNoDepthSyncTests` | Yes |
| Merge empty profiles | min(avg) | IOSMATH-MED-006 | **Gap** |
| Single sample profile | Avg = sample depth | `DiveProfileMath` | Yes |
| CSV duplicate import | Same session id hash | Import service | Partial |
| iCloud malformed JSON | `lastDecodeError` | `CloudSyncStore` | Partial |
| Engine 720 min cap | Incomplete, stops cleared | Completeness | Yes |

---

## E. Unit / Integration Test Plan

| Priority | Feature | Input | Expected | Criteria |
|----------|---------|-------|----------|----------|
| P1 | NDL chart labeling | Open Bühlmann tab | Disclaimer + non-physiological axis | No certified implication |
| P1 | Depth 300/350 policy | Session max 320 m | Sync OK; export documents limit | Document or align caps |
| P1 | `DiveSessionMerge` empty samples | Two manuals merged | avg = summary or documented min rule | Unit test |
| P2 | Manual editor imperial | New dive, imperial units | Defaults converted from 30/18 m | ft depths ≈ 98/59 |
| P2 | `RouteSummaryService` | Known lat/lon pair | Distance ±1%, bearing | Unit test |
| P2 | Analysis aggregates | 3 dives mixed nil SAC | Mean ignores nils | Unit test |
| P3 | NDL ascent rate | User ascent 6 m/min | Document NDL uses 9 | Spec test or fix |
| P3 | Gas simple vs engine | Same plan | Engine remaining ≤ simple | Integration |
| P4 | Demo TTV consistency | `insertDemoDives` | TTV = avg + duration/60 all indices | Unit test |

**Existing coverage:** Bühlmann golden fixtures, pressure unification, CSV metadata round-trip, cloud merge, CNS/OTU deep model, planning depth reference, watch sync conflicts — see `Tests/iOSAlgorithmTests/`.

---

## F. Paired Watch/iPhone Test Plan

| # | Scenario | Pass criteria |
|---|----------|---------------|
| 1 | Watch auto dive → iOS receive | max/avg/ttv/samples match within validator tolerances |
| 2 | iOS manual edit → push Watch | Pressures, notes, depths preserved |
| 3 | Delete tombstone both sides | Session absent after sync |
| 4 | Conflict same session edit | Conflict UI; resolution preserves chosen math fields |
| 5 | Manual no-depth Watch session | iOS logbook + no export profile |
| 6 | Deep dive > 300 m on Watch | iOS displays; CSV export behavior documented |
| 7 | Unit preference mismatch | Display converts; stored metric unchanged |

---

## G. CSV Import/Export Regression Plan

| Case | File | Expected |
|------|------|----------|
| G1 | Valid Subsurface + `# dirdiving_start_date` | Start preserved; samples ≤300 m |
| G2 | Re-export → re-import | Metadata + profile within tolerance |
| G3 | Missing temperature column | Import OK, nil temps |
| G4 | Row depth 301 m | Row rejected / import fail |
| G5 | 20,001 samples | Fail gracefully |
| G6 | Imperial UI session | Export depths still metric in CSV |
| G7 | Manual pressure metadata | Round-trip in comments |

Automated: `CSVMetadataRoundTripTests`, `IOSAlgorithmTests` import sections.

---

## H. Cloud Merge Validation Plan

| Case | Steps | Expected |
|------|-------|----------|
| H1 | Edit dive A on device 1, sync | Cloud updated |
| H2 | Edit same field on device 2 | Conflict surfaced |
| H3 | Resolve keep-local | Local math fields win |
| H4 | Resolve use-cloud | Cloud math fields win |
| H5 | Malformed cloud blob | `lastDecodeError` visible |
| H6 | Delete dive + sync | Tombstone / absent |

Automated: `CloudSessionMergeTests`, `DiveSessionMergeConflict` flows in store tests.

---

## I. Planner Boundary Validation Plan

| Depth (m) | Bottom (min) | Gas | Expected |
|-----------|--------------|-----|----------|
| 0.05 | 30 | Air | Invalid depth |
| 6 | 0 | Air | Edge NDL |
| 40 | 25 | EAN32 | MOD/PPO₂ warnings possible |
| 60 | 20 | Trimix | Deco schedule |
| 120 | 10 | Air | At ceiling |
| 121 | 10 | Air | Blocked |
| 30 | 601 | Air | Blocked |
| 30 | NDL+1 | Air | Deco or no solution state |

Automated: `BuhlmannNDLTests`, `BuhlmannGoldenFixtureTests`, `PlannerRegressionFixtureTests`, `PlanCalculationCompletenessTests`.

---

## J. Prioritized Roadmap

### 1. Must fix before compile/use
- None identified (project builds; algorithms guarded).

### 2. Must fix before internal TestFlight
- IOSMATH-HIGH-001 (chart axis disclaimer or fix)  
- IOSMATH-HIGH-002 (depth cap policy doc or alignment)  
- IOSMATH-MED-007 (imperial manual defaults)

### 3. Must fix before external TestFlight
- Paired device sync matrix (§ F)  
- IOSMATH-MED-002 (partial stops presentation policy)  
- CSV regression sign-off (§ G)

### 4. Must fix before App Store
- External QA per `IOS_MAIN_ALGORITHM_READINESS_100_REPORT` § K  
- iCloud conflict H1–H6  
- Planner safety acknowledgement on device  

### 5. Post-release improvements
- IOSMATH-MED-001 NDL ascent rate alignment  
- IOSMATH-MED-004 simple gas path  
- IOSMATH-MED-008 route bearing aggregate  
- Remove dead `AnalysisDepthTrendPreview` code  

---

## K. Final Verdict

| Question | Answer |
|----------|--------|
| **Mathematically ready (code)?** | **Yes, with caveats** — core engine, validators, and 173 tests provide strong coverage; known issues are mostly display, cross-layer caps, and merge edge cases. |
| **Planner safe enough for internal test?** | **Yes** — reference-only labeling, acknowledgement gate, blocking validators; **not** for treating output as authorized deco instructions. |
| **Sync/data ready?** | **Mostly** — HMAC watch codec, per-session merge conflicts, CSV metadata; complete field QA on devices still required. |
| **Ready for TestFlight?** | **Yes with documented caveats** (HIGH-001/002, paired QA, demo toggle off for external testers). |
| **Ready for App Store?** | **Conditional** — same as TestFlight plus marketing/legal alignment and two-device iCloud validation. |
| **What blocks 100%?** | (1) External/hardware QA, (2) misleading NDL chart axis, (3) 300 vs 350 m policy, (4) view-layer test gaps, (5) optional NDL/gas presentation refinements. |

---

## Product positioning (verified)

- iOS Companion is an **informational/educational** tool; Bühlmann output is **reference-only**, not a certified decompression plan.  
- TTV on logged dives: **`avgDepth + runtimeMinutes`** (informational index).  
- No claim that planner NDL/TTS replaces certified dive computers or tables.  
- Watch MAIN math is separate; iOS consumes `DiveSession` / sync codec with documented depth ceilings.

---

*Audit performed read-only on `main` @ `5c2a27a`. Supersedes readiness percentages in the 2026-05-31 audit body that referenced pre-remediation `4d5aabc` blockers B2–B5 (now resolved in code). Implementation history: [`IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md`](IOS_MAIN_ALGORITHM_READINESS_100_REPORT.md) @ `dce89e7`.*
