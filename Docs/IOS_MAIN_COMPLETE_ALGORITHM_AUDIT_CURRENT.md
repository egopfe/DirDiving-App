# DIR Diving iOS Complete Algorithm / Planner Readiness Audit — Current (CCR Updated V2.0)

**Audit date:** 2026-06-14  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `15f2d59` (`15f2d596f6e06a368dd625140d840704fd91481e`)  
**HEAD subject:** `fix(watch): remediate Watch briefing audit P2 items to internal readiness.`  
**Scope:** iOS Companion MAIN (`DIRDiving iOS`) only — complete algorithm / math / planner / data / export stack + CCR reference planner  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V2.0.md`

**Integrated context (read, not re-executed):**

| Document | HEAD / status | Role in this audit |
|---|---|---|
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | Updated @ `fedf4eb`; remediation @ `8147b3f`/`c0b5cd9` | Bühlmann/CCR deep baseline; P1 math items closed in code |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_REMEDIATION_REPORT_V1.0.md` | @ `c0b5cd9` | Comprehensive readiness remediation (cache, tests, evidence folders) |
| `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_CURRENT.md` | @ `f12265a` | Watch reference-only posture; iOS briefing transfer compatibility |
| `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_REMEDIATION_REPORT_V1.0.md` | @ `15f2d59` | CCR Watch briefing export from iOS; session ID; incomplete package UX |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Present | Math-layer baseline |
| `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md` (prior) | @ `984a69b` | Superseded by this report |
| `Docs/CCR_REBREATHER_LIMITATIONS.md` | Present | CCR scope / limitations |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Present | CSV policy; external steps **PENDING** |

**Actions in this audit pass:**

- Created/updated this report only (read-only audit).
- No Swift, UI, localization, algorithm, sync, security, or test production code modified.
- No commit or push performed.

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified reference planner)**

MAIN @ `15f2d59` delivers a coherent **dual-planner architecture**: open-circuit **Bühlmann ZH-L16C + GF** (Base / Deco / Technical), an isolated **CCR / Rebreather reference planner** (setpoint-inspired gas, dedicated engine/validator, heuristic bailout scenarios with explicit metadata), **Ratio Deco as comparative heuristic only** (OC deco/technical; blocked in CCR mode), tissue/narcosis analytics with source footnotes, structured Equipment setup with operational checklist generation, OC and **CCR checklist import/export UI**, manual dive entry with CCR logbook metadata, schedule-aware gas consumption with liters + bar-equivalent ledger, repetitive-dive tissue snapshots (OC), global ascent-speed settings, Rock Bottom / emergency parameters, PDF/CSV export, **Planner briefing PNG cards with Watch transfer** (OC + CCR summary), and centralized pressure-unit preference. macOS build and **800/800** executed iOS algorithm tests (13 skipped) pass on iPhone 17 Pro simulator.

**Not ready for:** certified decompression claims, certified CCR controller claims, external Bühlmann/CCR validation sign-off, iCloud two-device QA, paired Watch physical QA, Subsurface desktop round-trip sign-off, or App Store marketing without legal review.

### Readiness estimates

| Area | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall (internal code)** | **94%** | High on OC + automated tests; medium on CCR external parity | External validation + physical QA + cloud opt-in |
| **Bühlmann (OC core)** | **95%** | High | External third-party profile comparison **PENDING** |
| **Ratio Deco** | **86%** | High on guardrails | Heuristic by design; OC-only; no CCR |
| **Gas Planning (OC)** | **91%** | High | Bailout schedule-only in Bühlmann engine |
| **Gas Roles** | **89%** | Medium-high | Checklist title inference edge cases |
| **MOD / PPO₂ / Dalton** | **93%** | High | PDF strict MOD vs validator asymmetry (documented) |
| **Tissue Loading** | **91%** | High | Logbook simulated segments footnoted |
| **Narcosis / END** | **90%** | Medium-high | CCR density uses partial-pressure model; unavailable when invalid |
| **Planner Modes** | **93%** | High | CCR isolated in `.ccr` mode |
| **Checklist Sync** | **90%** | High | CCR export/import UI wired; UI E2E tests partial |
| **Manual Dive** | **89%** | Medium-high | Physical UX QA **PENDING** |
| **PDF / Share** | **91%** | High | CCR Dive Pack / Briefing OC-only by design |
| **Planner Briefing / Watch** | **92%** | High | CCR summary export + transfer; physical sync QA **PENDING** |
| **CSV / Subsurface** | **86%** | Medium | External Subsurface validation **PENDING** |
| **Unit Conversion** | **93%** | High | Global pressure preference + dual IOS/DIR stacks intentional |
| **CCR Overall** | **91%** | Medium-high | Heuristic bailout; P1 math fixed; external profiles **PENDING** |
| **Performance / Numerical** | **90%** | Medium | Long-profile stress partial |
| **Security / Privacy** | **87%** | Medium-high | iCloud always-on (SEC-P1-003); opt-in visual QA **PENDING** |
| **Automated Tests** | **93%** | High | 800 XCTest; UI E2E gaps |
| **Physical / External QA** | **45%** | — | Evidence folders mostly README-only |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **Almost ready** — build + 800 tests green @ `15f2d59` |
| Internal TestFlight (algorithm) | **Conditional yes** — document CCR reference-only + bailout heuristic + non-certified posture |
| External TestFlight / RC | **Not yet** — external math + iCloud + Watch physical QA **PENDING** |
| App Store (algorithm scope) | **Not yet** — same + legal/marketing disclaimer audit |
| Certified decompression planner | **Never** — remain non-certified reference-only |
| Certified CCR controller / life-support | **Never** — planning reference only |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No safety-critical algorithm defect identified |
| HIGH | 0 | No P0/P1 algorithm code blockers at HEAD |
| MEDIUM | 5 | External validation; iCloud QA; Subsurface external; cloud opt-in; CCR UI E2E gaps |
| LOW | 5 | `runtimeSegments` reserved; loop volume unused; checklist inference; PDF MOD asymmetry; perf stress |
| INFO | 5 | Dual unit stacks; Ratio Deco heuristic; Watch CSV divergence; SCR absent; bailout by design |

### Delta vs prior complete audit (`984a69b`)

| Change | Impact |
|---|---|
| CCR math P1 fixes @ `8147b3f` | Gas density partial-pressure scaling; CNS/OTU unavailable semantics |
| Comprehensive readiness @ `c0b5cd9` | `AnalysisCacheKey` completeness; 14+ new readiness tests |
| CCR checklist export UI wired | Closes IOS-CHK-CCR-001 from prior audit |
| CCR Watch briefing export @ `15f2d59` | `CCRPlannerBriefingExportSupport` + send from `CCRPlanResultView` |
| Test count 540 → 800 | Broader regression coverage |
| Structured Equipment + checklist tabs | Equipment ↔ planner ↔ checklist mappings hardened |

---

## B. Scope and Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `15f2d59` |
| Working tree at audit start | Clean |
| Remote | `origin/main` aligned after `git fetch` |
| iOS target | `DIRDiving iOS` (`project.yml`) |
| iOS test target | `DIRDiving iOS Algorithm Tests` |
| Watch runtime | **Out of scope** — read-only compatibility for briefing/sync codecs |

### Experimental exclusions (`project.yml`)

Confirmed excluded from `DIRDiving iOS`:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

### Build / test commands (exact)

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

### Build / test results @ `15f2d59`

| Command | Result |
|---|---|
| `xcodegen generate` | **OK** |
| `DIRDiving iOS` build (generic iOS Simulator) | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` (iPhone 17 Pro) | **TEST SUCCEEDED** — 800 executed, 13 skipped, 0 failures (~79 s) |

Skipped tests are environment-gated (keychain peer secret, simulator-only guards) — not failures.

---

## C. Architecture Inventory

Presentation-only code is not credited as a separate mathematical engine.

| Family | Canonical source | Validation | Persistence | Presentation | Export | Tests | Reachable | Readiness |
|---|---|---|---|---|---|---|---|---:|
| Bühlmann OC | `BuhlmannEngine.swift`, `BuhlmannPlanner.swift` | `BuhlmannPlanPreflightValidator.swift` | `PlannerStore` | `PlannerView`, `DecoStopsPresentationBuilder` | PDF builders | 40+ files | Yes | 95% |
| Planner modes | `PlannerModePolicy.swift`, `PlannerService.swift` | `PlannerInputValidator.swift` | `PlannerStore` | Mode pickers | PDF | `PlannerModePolicyTests` | Yes | 93% |
| Gas schedule / MOD | `GasPlanningService`, `PlannerMODValidator` | `GasMixValidator` | — | Gas cards | PDF | `ScheduleGasConsumptionServiceTests` | Yes | 91% |
| Gas ledger | `ScheduleGasConsumptionService.swift` | Plan completeness | — | `GasLedgerDisplayFormatter` | PDF | `GasLedgerDisplayFormatterTests` | Yes | 91% |
| Ascent / runtime | `PlannerAscentTableBuilder`, `RouteSummaryService` | Ascent speed settings | — | Runtime section | PDF/briefing | `PlannerAscentTableTests` | Yes | 92% |
| Rock Bottom | `ScheduleGasConsumptionService` (rock bottom liters) | Emergency params | — | Emergency section | PDF | `ScheduleGasConsumptionServiceTests` | Yes | 90% |
| Repetitive dive | `RepetitiveDivePlannerService.swift` | Snapshot guards | `PlannerStore.lastTissueSnapshot` | Repetitive toggle | — | `BuhlmannReleaseHardeningTests` | OC only | 89% |
| Ratio Deco | Heuristic comparator | Blocked in CCR | — | Compare section | PDF section | `RatioDecoPlannerTests` | OC deco/tech | 86% |
| CCR planner | `CCRPlannerEngine.swift`, `CCRPlannerService.swift` | `CCRPlanValidator.swift` | CCR settings in store | `CCRPlannerView` | CCR PDF | `CCRPlannerTests`, `CCRMathAuditRemediationV1Tests` | `.ccr` mode | 91% |
| CCR bailout | `CCRBailoutScenarioCalculator.swift` | Validator | — | Result cards | PDF metadata | `CCRMathRemediationTests` | CCR | 88% |
| CCR density | `CCRGasDensityEstimator.swift` | Inspired gas model | — | Narcosis footnotes | Briefing rows | `CCRMathAuditRemediationV1Tests` | CCR | 92% |
| CCR CNS/OTU | `CCROxygenExposureState.swift` | Exposure model | — | Unavailable labels | Briefing/PDF gate | `BuhlmannComprehensiveReadinessRemediationV1Tests` | CCR | 93% |
| Equipment structured | `EquipmentProfile.swift`, `EquipmentStructuredSupport.swift` | Schema | `EquipmentStore` + cloud | Equipment tab | Equipment PDF | `EquipmentProfileStructuredModelTests` | Yes | 90% |
| Checklist sync OC | `ChecklistPlannerSyncMapper.swift` | Gas role match | Equipment checklist | `PlannerView` prompts | — | `ChecklistPlannerSyncMapperTests` | Yes | 91% |
| Checklist sync CCR | `ChecklistPlannerSyncMapper` CCR paths | `CCRChecklist*Coordinator` | Equipment checklist | `CCRPlannerView`, `CCRPlanResultView` | — | `IOSCompleteAlgorithmAuditRemediationTests` | Yes | 90% |
| Manual dive | `ManualDiveEditorValidation`, `DiveProfileMath` | Editor guards | `DiveLogStore` | Manual editor | CSV | `ManualDiveEditorLogicTests` | Yes | 89% |
| Subsurface CSV | `SubsurfaceExportService`, `DiveImportService` | Size/row caps | Dive log | Import UI | CSV | `CSVMetadataRoundTripTests` | Yes | 86% |
| Briefing card | `PlannerBriefingImageExportService` | Reference-only gate | Staging TTL | Result views | PNG | `PlannerBriefingImageExportServiceTests` | Yes | 92% |
| Watch briefing | `PlannerBriefingWatchTransferService` | HMAC/signed ACK | Watch-side store (read-only ref) | Send buttons | File transfer | `PlannerWatchBriefingTransferTests`, `CCRPlannerBriefingExportTests` | Paired Watch | 90% |
| Cloud sync | `CloudSyncStore.swift` | Payload cap, LWW | iCloud KVS + local | Error surfacing | — | `CloudSyncStoreLoadTests` | Always on | 85% |
| Units | `Formatters.swift`, `IOSPressureUnitPreference` | — | UserDefaults | Settings + planner | PDF | `PlannerPressureUnitPreferenceTests` | Yes | 93% |

---

## D. Bühlmann Core Audit

### Verified (evidence)

| Requirement | Status | Evidence |
|---|---|---|
| ZHL-16C constants, 16 N2/He compartments | **PASS** | `BuhlmannConstants.swift`, `BuhlmannConstantsTests` |
| Half-times, a/b coefficients | **PASS** | `BuhlmannTissueModel.swift`, reference fixtures |
| Tissue initialization / Schreiner integration | **PASS** | `BuhlmannSchreinerEquationTests`, `BuhlmannTissueLoadingTests` |
| GF low/high interpolation, ceiling, controlling compartment | **PASS** | `BuhlmannGradientFactorTests`, `BuhlmannCeilingTests` |
| Stop rounding, deco convergence | **PASS** | `BuhlmannEngineCanonicalConsistencyTests` |
| NDL, multigas switches, trimix/helium | **PASS** | `BuhlmannNDLTests`, `BuhlmannMultigasPlannerTests`, `BuhlmannTrimixHeliumTests` |
| Altitude / freshwater / salinity via `PlannerEnvironment` | **PASS** | `BuhlmannPressureModelTests`, `PlanningDepthReferenceTests` |
| Invalid-input guards, deterministic output | **PASS** | `BuhlmannNumericalRobustnessTests`, `BuhlmannReleaseHardeningTests` |
| No fake/static results | **PASS** | Golden fixtures, regression fixtures |

### External gap

Third-party Bühlmann profile comparison **PENDING** — `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md` (no PASS files).

---

## E. Planner Modes (Base / Deco / Technical / CCR)

| Mode | Engine | Ratio Deco | Repetitive tissue | Evidence |
|---|---|---|---|---|
| Base | Bühlmann simplified | Blocked | Optional | `PlannerModePolicyTests` |
| Deco | Bühlmann + deco gases | Allowed (compare) | Optional | `PlannerDecoGasToggleTests` |
| Technical | Bühlmann + team gas + avg-depth toggle | Allowed | Optional | `PlannerTechnicalAverageDepthGasConsumptionTests` |
| CCR | `CCRPlannerEngine` | **Blocked** | **Not seeded** | `CCRPlannerTests`, `PlannerModePolicyTests` |

Mode projection is centralized in `PlannerModePolicy.swift`; CCR never calls open-circuit Bühlmann for loop gas.

---

## F. MOD / PPO₂ / Dalton / Switch Depth

| Rule | OC | CCR | Tests |
|---|---|---|---|
| MOD from max PPO₂ | `PlannerMODValidator` | Setpoint + diluent paths | `PlannerSwitchDepthMODClampTests` |
| Switch depth clamp above MOD | Bühlmann preflight | CCR validator | `BottomGasSwitchDepthTests` |
| Dalton / density warnings | Gas mix validator | CCR inspired model | `BuhlmannGasValidationTests` |

**Known asymmetry (LOW):** PDF export may apply stricter MOD display than inline validator in edge cases — documented in prior audits; not a calculation divergence.

---

## G. Gas Roles and Schedule Consumption

- **Roles:** bottom, deco, travel, bailout (OC); `ccrDiluent`, `ccrBailout` (CCR) — `ChecklistPlannerSyncMapper.swift`.
- **Schedule consumption:** `ScheduleGasConsumptionService.analyze` produces segment-aware liters with rock-bottom and emergency minutes — `ScheduleGasConsumptionServiceTests`.
- **Ledger display:** liters primary, bar equivalent secondary — `GasLedgerDisplayFormatter.swift`.
- **Technical average-depth toggle:** `GasPlan.averageDepthGasConsumptionEnabled` projected by `PlannerModePolicy`; cache key includes toggle — `PlannerStore.AnalysisCacheKey`, `MainDeepCodeRemediationDCATests`.

---

## H. Emergency / Rock Bottom

- Emergency section exposes Rock Bottom parameters in planner settings (`PlannerStore` / UI).
- `ScheduleGasConsumptionService` computes `rockBottomLiters` using ascent-speed-aware automatic ascent minutes.
- Conservative assumptions documented in UI copy; not a certified minimum-gas standard.

---

## I. Transit Timing / Dive Runtime / Deco Stops

| Component | Role | Coherence check |
|---|---|---|
| `PlannerAscentSpeedSettings` | Global ascent rate for transit estimates | Matches ascent table builder inputs |
| `PlannerAscentTableBuilder` | Canonical stop schedule from engine output | `PlannerAscentTableTests` (25 tests) |
| `DecoStopsPresentationBuilder` | Presentation mapping only | `PlannerPresentationTests` |
| `RouteSummaryService` | Aggregates runtime totals | `RouteSummary` in plan result tests |

Deco-stop presentation is derived from engine output, not a parallel math engine.

---

## J. Technical Average-Depth Gas Toggle

- Toggle affects gas consumption depth reference in Technical mode only.
- `AnalysisCacheKey.averageDepthGasConsumptionEnabled` prevents stale analysis after toggle — fixed @ `c0b5cd9`.
- **Gap (LOW):** no dedicated XCTest that toggles only this field and asserts cache miss; indirect coverage via `PlannerTechnicalAverageDepthGasConsumptionTests`.

---

## K. Repetitive Dive / Residual Tissue

- `RepetitiveDivePlannerService.makeSnapshot` / `validateSnapshot` with fail-closed errors (missing, stale, corrupt, schema, environment mismatch).
- OC-only; CCR mode does not seed from prior tissue snapshot.
- Oxygen carryover via `OxygenExposureModel.applySurfaceInterval` — `OxygenExposureDeepModelTests`.
- External multi-dive envelope validation **PENDING**.

---

## L. Ratio Deco

- Heuristic comparator for OC deco/technical plans only.
- Explicitly blocked when `plannerMode == .ccr` — `RatioDecoPlannerTests`.
- Not a certified decompression algorithm; PDF sections labeled accordingly.

---

## M. Tissue / Narcosis / CNS / OTU

| Metric | OC | CCR | Truthfulness |
|---|---|---|---|
| Tissue loading | Bühlmann compartments | Planned segments footnoted | `.ccrPlanned` source tags |
| END / PPN2 | Standard models | Inspired gas from setpoint | Narcosis services |
| Gas density | N/A | Partial-pressure g/L | Unavailable when invalid — never zero |
| CNS / OTU | Full exposure model | `CCROxygenExposureState` | Unavailable on failure — never zero |

P1 fixes @ `8147b3f` verified in `CCRMathAuditRemediationV1Tests` and `BuhlmannComprehensiveReadinessRemediationV1Tests`.

---

## N. CCR / Rebreather

### Architecture

Isolated reference planner: setpoint-inspired gas, dedicated tissue sampler, heuristic bailout scenarios with explicit `method` / `limitations` / `assumptions` metadata.

### Closed since prior audits

| ID | Finding | Resolution @ HEAD |
|---|---|---|
| IOS-MATH-P1-001 | Gas density not pressure-scaled | `CCRGasDensityEstimator` partial-pressure formula |
| IOS-MATH-P1-002 | CNS/OTU failure → zero | `CCROxygenExposureState.unavailable` |
| IOS-MATH-P2-001 | Bailout heuristic undocumented | `CCRBailoutScenarioResult` metadata |
| IOS-MATH-P3-001 | Synthetic `.air` diluent trace | Actual `CCRDiluent` through exposure |
| IOS-CHK-CCR-001 | CCR checklist export UI missing | Wired in `CCRPlanResultView` / `CCRPlannerView` |

### Remaining CCR gaps

| ID | Sev | Finding |
|---|---|---|
| IOS-EXT-CCR-001 | MED | External CCR validation slots empty — `Docs/QA_EVIDENCE/CCR_EXTERNAL/` |
| IOS-BAILOUT-DOC-001 | LOW | Heuristic bailout must stay disclosed in TestFlight notes |
| IOS-CCR-RUNTIME-001 | INFO | `runtimeSegments` reserved unused |
| IOS-CCR-LOOP-001 | INFO | `loopVolumeLiters` unused in calculations |

---

## O. Structured Equipment / Checklist

- Structured cylinders + maintenance in `EquipmentProfile` with legacy bridge — `EquipmentStructuredSupport.swift`.
- `EquipmentPlannerMapper.apply` copies cylinders/SAC without altering math.
- `EquipmentChecklistGenerator` produces operational pre-dive tasks from structured setup.
- OC checklist import/export mirrors CCR pattern in `PlannerView`.
- CCR import from diluent card; export after valid calculate — `CCRChecklistImportSheet`, `CCRChecklistExportSheet`.

**Gap (LOW):** No UI integration test for full CCR calculate → export → persist → cloud round-trip.

---

## P. Manual Dive / Logbook

- Manual entry validation via `ManualDiveEditorValidation`; CCR metadata fields supported.
- `DiveProfileMath` for analytics; no-depth truthfulness preserved.
- Physical editor UX QA **PENDING** — `Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/`.

---

## Q. PDF / Share / CSV / Briefing Card

| Export | Status | Notes |
|---|---|---|
| OC plan PDF | **Ready** | `PDFExportServiceTests` |
| CCR plan PDF | **Ready** | Blocks when exposure unavailable |
| Equipment setup PDF | **Ready** | Structured fields |
| Briefing PNG (OC) | **Ready** | Reference-only watermark |
| Briefing PNG (CCR) | **Ready** | `CCRPlannerBriefingExportSupport` @ `15f2d59` |
| Watch transfer | **Ready (code)** | `PlannerBriefingWatchTransferService`; physical QA **PENDING** |
| Subsurface CSV | **Ready (in-repo)** | External desktop validation **PENDING** |

---

## R. Cloud / Sync / Persistence / Security

- `CloudSyncStore`: iCloud KVS + local fallback, LWW via `__modifiedAt`, payload size cap (`IOSAlgorithmConfiguration.maxSyncPayloadBytes`).
- Dive session merge uses field-level merge — `CloudSessionMergeTests`.
- Watch sync: HMAC / peer-secret / signed-ACK model — `WatchSyncPeerSecretPinningIOSTests` (skipped without keychain fixture).
- **SEC-P1-003 (MED):** iCloud sync constructed at app launch without user opt-in — privacy review recommended before App Store.

---

## S. Units / Localization / Accessibility

- Internal storage remains metric; display via `Formatters` + global `IOSPressureUnitPreference` in Settings — `PlannerPressureUnitPreferenceTests`.
- EN/IT localization for planner gas, runtime, CCR briefing, checklist flows — `IOSI18nRemediationTests`, `UIUXLocalizationRemediationTests`.
- Dynamic Type / VoiceOver matrices **PENDING** — `Docs/QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/`.

---

## T. Performance / Numerical Robustness

- `BuhlmannNumericalRobustnessTests` covers extreme GF, depth, and gas edge inputs.
- Long multigas profile stress partially covered; dedicated perf harness **P4**.
- CCR timeline sampling via `CCRTissueHistorySampler` — deterministic in unit tests.

---

## U. Test Coverage

| Metric | Value |
|---|---|
| Test files | 108 under `Tests/iOSAlgorithmTests/` |
| Executed @ audit | 800 |
| Skipped | 13 (environment gates) |
| Failures | 0 |

### Coverage matrix (selected)

| Area | Primary test files | Gap |
|---|---|---|
| Bühlmann core | `Buhlmann*Tests` (20+ files) | External fixtures only |
| CCR math | `CCRMathAuditRemediationV1Tests`, `CCRMathRemediationTests` | External CCR profiles |
| CCR checklist | `ChecklistPlannerSyncMapperTests`, `IOSCompleteAlgorithmAuditRemediationTests` | SwiftUI E2E |
| CCR briefing | `CCRPlannerBriefingExportTests` | WCSession transfer E2E |
| Gas ledger | `ScheduleGasConsumptionServiceTests` | Physical a11y |
| Cloud | `CloudSyncStoreLoadTests`, `CloudSessionMergeTests` | Two-device manual matrix |
| CSV | `CSVMetadataRoundTripTests` | Subsurface desktop |
| Repetitive | `BuhlmannReleaseHardeningTests`, golden fixtures | External multi-dive |

---

## V. Detailed Issue Matrix

| ID | Sev | Pri | Area | Finding | Status @ `15f2d59` | Evidence |
|---|---|---|---|---|---|---|
| IOS-EXT-BM-001 | MED | P1 | Bühlmann | External profile comparison not executed | **OPEN** | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` |
| IOS-EXT-CCR-001 | MED | P1 | CCR | CCR validation slots empty | **OPEN** | `QA_EVIDENCE/CCR_EXTERNAL/` |
| IOS-ICLOUD-001 | MED | P1 | Cloud | Two-device QA not recorded | **OPEN** | `ICLOUD_TWO_DEVICE_QA_MATRIX.md` |
| SEC-P1-003 | MED | P1 | Security | iCloud always-on without opt-in | **OPEN** | `CloudSyncStore` + `DIRDivingiOSApp` |
| IOS-SUB-001 | MED | P2 | CSV | Subsurface desktop round-trip **PENDING** | **OPEN** | `QA_EVIDENCE/SUBSURFACE_CSV/` |
| IOS-WATCH-SYNC-001 | MED | P2 | Sync | Paired Watch physical QA **PENDING** | **OPEN** | `WATCH_IOS_SYNC_QA_MATRIX.md` |
| IOS-CHK-CCR-E2E | LOW | P2 | Checklist | CCR export UI lacks SwiftUI E2E test | **OPEN** | Mapper tests only |
| IOS-BRIEF-CCR-E2E | LOW | P2 | Briefing | CCR Watch transfer lacks E2E test | **OPEN** | ACK unit tests only |
| IOS-MATH-P1-001 | HIGH | — | CCR density | Pressure scaling | **CLOSED** @ `8147b3f` | `CCRMathAuditRemediationV1Tests` |
| IOS-MATH-P1-002 | HIGH | — | CCR CNS/OTU | Zero fallback | **CLOSED** @ `8147b3f` | `CCROxygenExposureState` |
| IOS-CHK-CCR-001 | MED | — | Checklist UI | Export not wired | **CLOSED** @ `0e98f24`/CCR views | `CCRPlanResultView` |
| IOS-BAILOUT-DOC-001 | LOW | P1 | CCR | Heuristic bailout disclosure | **OPEN (process)** | TestFlight notes |
| IOS-LEGAL-001 | MED | P3 | Marketing | App Store copy vs posture | **OPEN** | Legal review |
| IOS-VISUAL-001 | LOW | P3 | UX | Dynamic Type / VoiceOver | **OPEN** | QA matrix |
| IOS-CCR-RUNTIME-001 | INFO | P4 | CCR | `runtimeSegments` unused | **OPEN** | Model reservation |
| IOS-PERF-001 | INFO | P4 | Perf | Long-profile benchmarks | **OPEN** | — |

---

## W. Edge-Case Matrix

| Edge case | Expected behavior | Observed | Tests |
|---|---|---|---|
| CCR setpoint above dry ambient | Density unavailable | `.setpointAboveDryAmbient` | `CCRMathAuditRemediationV1Tests` |
| CCR exposure computation failure | CNS/OTU unavailable, not zero | UI + PDF gate | `CCRPlannerBriefingExportTests` |
| Invalid CCR plan (no bailout) | No briefing export input | Watch button hidden | `CCRPlannerBriefingExportTests` |
| Stale tissue snapshot | Repetitive planning blocked | Error surfaced | `BuhlmannComprehensiveReadinessFixTests` |
| Oversize CSV import | Rejected at cap | Error returned | `MainDeepCodeAuditRemediationTests` |
| Oversize cloud payload | Save rejected | Error surfaced | `CloudSyncStoreLoadTests` |
| Switch depth above MOD | Clamped / validation error | Preflight fails | `PlannerSwitchDepthMODClampTests` |
| Ratio Deco in CCR mode | Blocked | No compare section | `RatioDecoPlannerTests` |
| Average-depth toggle change | Analysis cache invalidated | Recompute | `MainDeepCodeRemediationDCATests` |
| Subsurface CSV quoted commas | Simple parser limits | Documented policy | `CSVMetadataRoundTripTests` |
| Peer secret mismatch (Watch) | Sync rejected | Skip in CI keychain | `WatchSyncPeerSecretPinningIOSTests` |
| Incomplete briefing package (Watch) | Warning on Watch | iOS sends reference-only | Watch remediation @ `15f2d59` |

---

## X. Release-Hard Matrix

| Feature | Readiness | Blockers | Priority |
|---|---|---:|---|
| Bühlmann | 95% | External validation **PENDING** | P1 |
| Planner Base/Deco/Technical | 93% | External validation | P1 |
| CCR / Rebreather | 91% | External + bailout disclosure | P1 |
| Ratio Deco | 86% | Heuristic by design | — |
| Gas Planning | 91% | Bailout schedule-only in engine | P4 |
| Gas Roles | 89% | Checklist inference edges | P3 |
| MOD/PPO2/Dalton | 93% | PDF display asymmetry | P3 |
| Switch Depth Clamp | 93% | — | — |
| Emergency / Rock Bottom | 90% | Non-certified minimum gas | — |
| Ascent / Descent Timing | 92% | — | — |
| Dive Runtime / Deco Stops | 92% | — | — |
| Schedule-Aware Gas Consumption | 91% | — | — |
| Gas Ledger / Reserve | 91% | — | — |
| Technical Average-Depth Gas Toggle | 90% | Dedicated cache test gap | P3 |
| Repetitive Dive / Residual Tissues | 89% | External multi-dive **PENDING** | P2 |
| Tissue Loading | 91% | — | — |
| Narcosis / END / PPN2 | 90% | — | — |
| CNS / OTU | 93% | — | — |
| Structured Equipment | 90% | — | — |
| Checklist Sync | 90% | CCR E2E test gap | P2 |
| CCR Checklist Import / Export | 90% | E2E + cloud round-trip | P2 |
| CCR Bailout Scenario | 88% | Heuristic by design | P1 doc |
| CCR Gas Density | 92% | — | — |
| Manual Dive | 89% | Physical QA **PENDING** | P2 |
| PDF / Share | 91% | — | — |
| Planner Briefing Card / Watch Transfer | 92% | Physical sync QA **PENDING** | P2 |
| CSV / Subsurface | 86% | Desktop validation **PENDING** | P2 |
| Unit Conversion | 93% | — | — |
| Cloud / Sync / Persistence | 85% | Opt-in (SEC-P1-003); two-device QA | P1 |
| Security / Privacy | 87% | Opt-in; marketing review | P1 |
| Performance / Numerical Robustness | 90% | Long-profile bench | P4 |
| Test Coverage | 93% | UI E2E gaps | P2 |
| Internal TestFlight | 92% | Disclaimers required | — |
| External TestFlight | 55% | External + physical QA | P1 |
| App Store | 50% | Same + legal | P1 |
| **Overall (internal code)** | **94%** | External + physical + cloud opt-in | P1 |

---

## Y. Prioritized Action Plan

### P0 — none

No safety-critical algorithm defect requires immediate code change.

### P1 — internal TestFlight / release-hard

| ID | Action | Owner |
|---|---|---|
| IOS-EXT-BM-001 | Execute `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`; attach evidence | Manual QA |
| IOS-EXT-CCR-001 | Execute `CCR_REBREATHER_VALIDATION_PLAN.md` | Manual QA |
| IOS-ICLOUD-001 | Execute `ICLOUD_TWO_DEVICE_QA_MATRIX.md` | Manual QA |
| SEC-P1-003 | Product decision: iCloud opt-in vs disclosure-only | Product + legal |
| IOS-BAILOUT-DOC-001 | Keep heuristic bailout in TestFlight / App Store review notes | Docs |

### P2 — external TestFlight

| ID | Action |
|---|---|
| IOS-SUB-001 | Subsurface desktop round-trip per `SUBSURFACE_CSV_ROUNDTRIP.md` |
| IOS-WATCH-SYNC-001 | Paired Watch sync matrix + briefing card physical QA |
| IOS-CHK-CCR-E2E | Add SwiftUI/integration test for CCR checklist export flow |
| IOS-BRIEF-CCR-E2E | Add CCR → Watch briefing transfer integration test (simulator WCSession mock) |

### P3 — App Store

| ID | Action |
|---|---|
| IOS-LEGAL-001 | Legal/marketing review vs non-certified posture |
| IOS-VISUAL-001 | Dynamic Type / VoiceOver matrices |

### P4 — post-release

| ID | Action |
|---|---|
| IOS-CCR-RUNTIME-001 | Implement or permanently document `runtimeSegments` |
| IOS-PERF-001 | Long-profile profiling harness |

---

## Z. 7-Day / 14-Day Readiness Plan

### 7-day (internal TestFlight algorithm gate)

1. Attach at least one external Bühlmann profile comparison to `QA_EVIDENCE/BUHLMANN_EXTERNAL/`.
2. Record CCR bailout + reference-only disclaimers in `TESTFLIGHT_REVIEW_NOTES.md` review pass.
3. Run iCloud two-device smoke on planner + equipment (even partial evidence).
4. Execute Subsurface import of one exported CSV on desktop (step 4+ of round-trip doc).

### 14-day (external TestFlight gate)

1. Complete Bühlmann + CCR external validation slots with PASS/FAIL (never PASS without files).
2. Complete `WATCH_IOS_SYNC_QA_MATRIX.md` with paired hardware.
3. Complete `IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` on critical planner paths.
4. Resolve or document SEC-P1-003 (opt-in UI or privacy policy update).

---

## AA. Future Cursor Remediation Commands (draft — do not execute)

1. **`4-DIR_DIVING_IOS_COMPLETE_ALGORITHM_REMEDIATION_CCR_UPDATED_V2.0.md`** — CCR checklist E2E tests; Subsurface evidence harness; SEC-P1-003 opt-in decision implementation.
2. **`2-DIR_DIVING_IOS_BUHLMANN_CORE_EXTERNAL_VALIDATION_EVIDENCE.md`** — external Bühlmann comparison evidence pack automation.
3. **`3-DIR_DIVING_IOS_CCR_HARDENING_AND_BAILOUT_TRUTHFULNESS.md`** — bailout engine vs enhanced heuristic (product decision).
4. **`5-DIR_DIVING_IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md`** — autoclamp visual matrix execution.
5. **`8-DIR_DIVING_IOS_UNIT_TEST_COVERAGE_AND_ICLOUD_E2E.md`** — two-device tests + briefing transfer E2E.

---

## AB. Final Verdict

| Question | Answer |
|---|---|
| Is Bühlmann ready? | **Yes for internal reference** (95%); external certification sign-off **PENDING**. |
| Are Planner modes real and isolated? | **Yes** — Base/Deco/Technical/CCR with policy gates. |
| Is CCR mathematically coherent and reference-only? | **Yes** — P1 math fixed; bailout heuristic with metadata; not a controller. |
| Is Ratio Deco safely comparative? | **Yes** (86%) — OC only; blocked in CCR. |
| Are MOD/PPO₂/switch-depth rules consistent? | **Yes** across OC + CCR setpoint paths. |
| Is Rock Bottom conservative and correct? | **Yes for reference planning** — not certified minimum gas. |
| Are ascent/descent timing and runtime totals coherent? | **Yes** — ascent table derived from engine + speed settings. |
| Does the deco-stop table match the engine? | **Yes** — presentation builder maps engine output. |
| Is gas consumption correct by segment and role? | **Yes** — schedule-aware ledger with rock-bottom integration. |
| Is the average-depth gas toggle isolated? | **Yes** — Technical mode; cache key includes toggle. |
| Are repetitive-dive tissues coherent? | **Yes (OC)** — fail-closed snapshots; external validation **PENDING**. |
| Are tissue/narcosis/CNS/OTU truthful? | **Yes** — unavailable semantics; no silent zeros in CCR. |
| Are Equipment/checklist mappings safe? | **Yes** — structured setup + role-preserving mappers. |
| Does CCR checklist round trip preserve roles? | **Yes in mapper/coordinator** — E2E persistence test gap. |
| Are CCR bailout and gas density traceable? | **Yes** — metadata + partial-pressure density formula. |
| Are manual dives and exports reliable? | **Mostly** (89%) — in-repo CSV round-trip OK; external **PENDING**. |
| Are briefing cards numerically faithful and reference-only? | **Yes** — watermark + unavailable exposure labels. |
| Is sync/data integrity release-hard? | **Conditional** — caps and merge tested; iCloud opt-in gap. |
| Safe for internal TestFlight? | **Conditional yes** — disclose CCR + bailout + non-certified posture. |
| Safe for external TestFlight? | **No** — external math + iCloud + Watch physical QA **PENDING**. |
| Ready for App Store? | **No** — same gates + legal/marketing review. |
| What blocks 100% readiness? | External validation evidence, physical QA matrices, cloud privacy opt-in, UI E2E gaps, heuristic bailout (by design). |
| What must be fixed first? | **Process/evidence:** external Bühlmann + CCR validation files; iCloud two-device QA; SEC-P1-003 product decision. **Not algorithm P0 code.** |

### Static tooling scan

No production source files modified during this audit. Git status after report write should show only `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`.

---

*End of report — DIR Diving iOS Complete Algorithm Audit CCR Updated V2.0 @ `15f2d59`.*
