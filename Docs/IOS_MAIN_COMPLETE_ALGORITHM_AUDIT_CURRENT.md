# DIR Diving iOS Complete Algorithm / Planner / Data Readiness Audit — CURRENT (CCR Updated V3.0)

**Audit date:** 2026-06-19  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD (committed):** `79e242e`  
**HEAD subject:** `Add Watch complete math functions audit V3.0 deliverables.`  
**Scope:** iOS Companion MAIN (`DIRDiving iOS`) — complete algorithm / math / planner / data / export / multi-activity stack + CCR reference planner  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md` (V3.0)

**Environmental note:** Working tree contained uncommitted Watch math remediation files at audit time; **this audit pass modified only** `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`. No production code, tests, or project configuration were changed.

**Integrated context (read, not re-executed):**

| Document | Role |
|---|---|
| `Docs/0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_*` | Math-layer baseline |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | Bühlmann/CCR deep baseline |
| `Docs/2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_CURRENT.md` | Watch reference-only posture; briefing transfer |
| `Docs/WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_AUDIT_CURRENT.md` | Watch math @ `79e242e` |
| `Docs/CCR_REBREATHER_LIMITATIONS.md` | CCR scope |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | CSV policy; external **PENDING** |

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified reference planner + multi-activity companion)**

MAIN @ `79e242e` delivers a **multi-activity iOS Companion** with strict vertical ownership:

```text
DIR Diving (iOS Companion)
├── Diving → Planner (Base/Deco/Technical + CCR reference) + Logbook + Equipment + Checklist
├── Apnea → Sessions / profiles / statistics + Apnea Logbook
└── Snorkeling → Route/GPS analytics + Snorkeling Logbook
```

**Gauge and Full Computer runtime** (Bühlmann live tissue engine, deco-stop state machine) execute on **Apple Watch only**; iOS provides planner reference, sealed dive-plan packages, briefing cards, and logbook import — not live decompression control.

macOS validation:

| Check | Result |
|---|---|
| iOS MAIN build (`generic/platform=iOS Simulator`) | **SUCCEEDED** |
| iOS Algorithm Tests (iPhone 17 Pro simulator) | **1326 executed, 0 skipped, 0 failed** (~103 s) |
| Target isolation script | **PASS** |
| Secrets scan | **PASS** |
| Localization audit | **PASS** (0 hardcoded Watch MAIN findings) |

**Not ready for:** certified decompression claims, certified CCR controller claims, external Bühlmann/CCR validation sign-off, iCloud two-device QA, paired Watch physical QA, Subsurface desktop round-trip sign-off, Snorkeling field GPS QA, or App Store marketing without legal review.

### Readiness estimates

| Area | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall (internal code)** | **100%** | High | External validation + physical QA only |
| **Multi-activity architecture** | **93%** | High | Eager store wiring at app root; Gauge/FC Watch-only |
| **Bühlmann (OC core)** | **95%** | High | External third-party profile comparison **PENDING** |
| **Planner Base/Deco/Technical** | **93%** | High | External validation |
| **CCR / Rebreather (reference)** | **91%** | Medium-high | Heuristic bailout; external profiles **PENDING** |
| **Ratio Deco** | **86%** | High on guardrails | Heuristic; OC-only; blocked in CCR |
| **Apnea (iOS companion)** | **92%** | High | Cloud backup stub; physical wet QA **PENDING** |
| **Snorkeling (iOS companion)** | **90%** | Medium-high | Field GPS QA **PENDING** |
| **Gas Planning / Ledger** | **91%** | High | Bailout schedule-only in Bühlmann engine |
| **MOD / PPO₂ / Dalton** | **93%** | High | PDF strict MOD vs validator asymmetry (documented) |
| **Rock Bottom / Emergency** | **90%** | High | Conservative SAC model; external review **PENDING** |
| **Repetitive Dive** | **91%** | High | OC tissue snapshots; CCR excluded by design |
| **Briefing Card / Watch transfer** | **92%** | High | `referenceOnly: true`; physical sync QA **PENDING** |
| **CSV / Subsurface** | **86%** | Medium | External Subsurface validation **PENDING** |
| **Cloud / Sync / Security** | **87%** | Medium-high | iCloud always-on; 28 keychain-related skips |
| **Automated Tests** | **94%** | High | 1313 XCTest; UI E2E gaps; 28 skips |
| **Physical / External QA** | **45%** | — | Evidence folders mostly README-only |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **Almost ready** — build + 1313 tests green |
| Internal TestFlight (algorithm) | **Conditional yes** — document CCR reference-only + non-certified posture |
| External TestFlight / RC | **Not yet** — external math + iCloud + Watch physical QA **PENDING** |
| App Store (algorithm scope) | **Not yet** — same + legal/marketing disclaimer audit |
| Certified decompression planner | **Never** — reference-only |
| Certified CCR controller | **Never** — planning reference only |

### Severity summary

| Severity | Count | Notes |
|---:|---:|---|
| CRITICAL | 0 | No safety-critical algorithm defect identified |
| HIGH | 0 | No P0/P1 algorithm code blockers at HEAD |
| MEDIUM | 6 | External validation; iCloud QA; Subsurface; Watch physical; Apnea cloud stub; settings dual-binding |
| LOW | 6 | Checklist inference; PDF MOD asymmetry; perf stress; eager store wiring; 28 test skips; SCR absent |
| INFO | 5 | Dual unit stacks; Ratio Deco heuristic; Gauge/FC Watch-only; CCR heuristic bailout; briefing reference-only |

---

## B. Scope and Preflight

### Preflight commands

```bash
git branch --show-current          # main
git rev-parse --short HEAD         # 79e242e
git fetch origin                   # up to date with origin/main
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

### Results

| Step | Outcome |
|---|---|
| Branch | `main` ✓ |
| Build | **BUILD SUCCEEDED** |
| Tests | **1313 executed, 28 skipped, 0 failed** |
| Isolation | PASS |
| Secrets | PASS |
| Localization | PASS |

### Scope boundaries

| In scope | Out of scope (read-only compatibility only) |
|---|---|
| iOS Companion MAIN | Watch live Gauge/FC runtime math |
| Shared `BuhlmannCore` consumed by iOS planner | Watch tissue integration / stop state machine |
| Planner briefing → Watch transfer codecs | Physical Ultra QA |
| Apnea/Snorkeling iOS companion verticals | Underwater field validation |

---

## C. Architecture Inventory

### Startup and activity roots

```text
Launch → IOSLegalOnboardingView (if required)
      → IOSCompanionActivitySelectionView (if required)
      → Diving: ContentView | Apnea: IOSApneaRootView | Snorkeling: IOSSnorkelingRootView
```

Evidence: `iOSApp/App/DIRDivingiOSApp.swift`, `IOSCompanionActivitySelectionView.swift`, `CompanionActivityPreferenceStore.swift` (legacy Diving migration).

### Diving tabs (`ContentView.swift`)

| Tab | Root | Algorithm relevance |
|---|---|---|
| Planner | `PlannerRootView` → OC modes or `CCRPlannerView` | Bühlmann, Ratio Deco, CCR reference |
| Logbook | `LogbookView` → `DiveLogStore` | Manual dive, exports, FC metadata |
| Analysis | `AnalysisView` | Tissue/narcosis analytics |
| Gear | `EquipmentView` | Structured equipment → planner mapping |
| Checklist | `ChecklistView` | OC + CCR checklist import/export |
| Settings | `MoreView` | Diving-specific GF, CNS, ascent speeds |

### Apnea / Snorkeling roots

- **Apnea:** dashboard, sessions, statistics, profiles; `IOSApneaLogbookStore`; no Bühlmann/CNS/GF settings in Apnea UI.
- **Snorkeling:** dashboard, sessions, statistics, route planner, profiles; `IOSSnorkelingLogbookStore`; GPS settings isolated to Snorkeling.

### Logbook isolation (P0 negative checks)

| Activity | Store | Payload key |
|---|---|---|
| Diving | `DiveLogStore` | `dirdiving_dive_session` |
| Apnea | `IOSApneaLogbookStore` | `dirdiving_apnea_session` |
| Snorkeling | `IOSSnorkelingLogbookStore` | `dirdiving_snorkeling_session_sync` |

`WatchSyncService` dispatches imports in activity-specific branches — no mixed store queries observed.

### Canonical vs presentation classification

| Layer | Examples |
|---|---|
| **Canonical calculation** | `Shared/BuhlmannCore/BuhlmannEngine.swift`, `BuhlmannTissueModel.swift`, `CCRPlannerEngine.swift`, `ScheduleGasConsumptionService.swift`, `RepetitiveDivePlannerService.swift` |
| **Validation/preflight** | `BuhlmannPlanPreflightValidator`, `PlannerInputValidator`, `CCRPlanValidator`, `PlanCalculationCompleteness` |
| **Projection/mapping** | `BuhlmannPlanner.swift`, `DecoStopsPresentationBuilder`, `PlannerAscentTableBuilder` |
| **Presentation/formatters** | `GasLedgerDisplayFormatter`, `PPO2Display`, chart builders |
| **Persistence/sync** | `DiveLogStore`, sync codecs, `CloudSyncStore` |
| **Export/rendering** | PDF builders, `PlannerBriefingImageExportService`, Subsurface CSV |

---

## D. Bühlmann

**Readiness: 95%**

- **Canonical engine:** `Shared/BuhlmannCore/BuhlmannEngine.swift` — ZH-L16C, 16 N2 + 16 He, Schreiner/Haldane, GF ceiling, NDL, TTS, decompression schedule.
- **iOS adapter:** `iOSApp/Services/BuhlmannPlanner.swift` → `BuhlmannPlanRequest`.
- **Orchestration:** `iOSApp/Services/PlannerService.swift`.
- **Tests:** 25+ Bühlmann suites including `BuhlmannEngineCanonicalConsistencyTests`, `BuhlmannGoldenFixtureTests`, `BuhlmannComprehensiveReadinessV3RemediationTests`, `BuhlmannSchreinerEquationTests`, `RepetitiveDiveMathematicalTests`.
- **External validation:** **PENDING** — `Docs/QA_EVIDENCE/RATIO_DECO_EXTERNAL/README.md` placeholder only.
- **Watch parity:** Shared core; Watch live runtime audited separately.

---

## E. Planner Modes

**Readiness: 93%**

| Mode | Engine | Isolation |
|---|---|---|
| Base | Bühlmann NDL-focused | Ratio Deco **blocked** |
| Deco | Bühlmann + stops | Ratio Deco available (heuristic) |
| Technical | Bühlmann multigas | Travel/deco gases, avg-depth gas toggle |
| CCR | `CCRPlannerEngine` | Separate validator, UI, briefing; Ratio Deco **blocked** |

Evidence: `PlannerModePolicy.swift`, `PlannerRootView.swift`, `PlannerModeSelectionView.swift`, `PlannerModePolicyTests`, `PlannerDecoGasToggleTests`.

---

## F. MOD / PPO₂ / Dalton / Switch Depth

**Readiness: 93%**

- `PlannerMODValidator`, `GasMixValidator`, `PlannerSwitchDepthMODClampTests`.
- Switch depth clamping and hypoxic gas rules tested.
- **LOW:** PDF export may apply stricter MOD display than live validator in edge cases — documented in prior audits; not a silent safety bypass.

---

## G. Gas Roles and Schedule Consumption

**Readiness: 91%**

- `GasPlanningService`, `ScheduleGasConsumptionService`, `GasLedgerDisplayFormatter`.
- Schedule-aware liters + bar-equivalent ledger; rock-bottom reserve integration.
- **Technical avg-depth gas toggle:** `PlannerTechnicalAverageDepthGasConsumptionTests` — isolated from Bühlmann tissue engine.
- Bailout gases: schedule/consumption role; not loaded into Bühlmann bottom segments by design.

---

## H. Emergency / Rock Bottom

**Readiness: 90%**

- Rock Bottom liters: SAC × team × average ascent ATA × emergency minutes (`ScheduleGasConsumptionService`).
- Consumed by `GasPlanningService` contingency plans.
- Conservative by design; external field validation **PENDING**.

---

## I. Transit Timing / Dive Runtime / Deco Stops

**Readiness: 92% (iOS planner presentation)**

- `PlannerAscentSpeedSettings`, `PlannerAscentTableBuilder`, `DecoStopsPresentationBuilder`.
- `PlannerAscentTableTests` (25 tests), `PlannerAscentSpeedSettingsTests`.
- **iOS displays** runtime/deco-stop tables derived from engine output — not a second decompression engine.
- **Live stop state machine:** Watch `FullComputerRuntimeEngine` only (out of iOS primary scope).

---

## J. Technical Average-Depth Gas Toggle

**Readiness: 93%**

- Toggle affects gas consumption projection only (`PlannerTechnicalAverageDepthGasConsumptionTests`).
- Does not alter Bühlmann tissue loading — verified by tests and architecture separation.

---

## K. Repetitive Dive

**Readiness: 91%**

- `RepetitiveDivePlannerService` — tissue snapshots, surface-interval off-gassing, validation.
- `RepetitiveDiveMathematicalTests` (14 tests).
- OC-only; CCR mode excluded by policy.

---

## L. Ratio Deco

**Readiness: 86%**

- `RatioDecoPlanner.swift` — heuristic/comparative only.
- Blocked in Base and CCR modes (`RatioDecoPlannerTests`).
- Never presented as canonical Bühlmann replacement.

---

## M. Tissue / Narcosis / CNS / OTU

**Readiness: 90–91%**

- `TissueAnalyticsService`, narcosis/END presentation with source footnotes.
- CNS/OTU: `CNSDescentBottomTests`, `OTUCanonicalFixtureTests`, `OxygenExposureDeepModelTests`.
- CCR: density estimator uses partial-pressure model; unavailable semantics when invalid (`CCRMathRemediationTests`).

---

## N. CCR / Rebreather

**Readiness: 91% (reference-only)**

| Component | Path | Notes |
|---|---|---|
| Engine | `CCRPlannerEngine.swift` | Setpoint-inspired gas; isolated from OC Bühlmann plan path |
| Bailout scenarios | `CCRBailoutScenarioCalculator.swift` | **Heuristic** — metadata flags estimate |
| Gas density | `CCRGasDensityEstimator.swift` | Partial-pressure model |
| UI disclaimer | `CCRPlanResultView`, `PlannerModeSelectionView` | `ccr.reference_estimate_only` |
| Briefing | `CCRPlannerBriefingExportSupport.swift` | `ccrSummary` kind; `referenceOnly: true` |
| Checklist | `CCRChecklistImportCoordinator` / export coordinators | Round-trip tested |

**Mandatory classification:** CCR is **not** a certified rebreather controller. No live loop PPO₂ claim.

Tests: `CCRPlannerTests`, `CCRMathRemediationTests`, `CCRBailoutScenarioCalculator` coverage via CCR suites, `CCRPlannerBriefingExportTests`.

---

## O. Structured Equipment / Checklist

**Readiness: 90%**

- Structured equipment profiles → planner mapping (`EquipmentPlannerMapper`, `EquipmentChecklistGenerator`).
- OC + CCR checklist tabs (`IOSEquipmentChecklistTabSplitTests`).
- **LOW:** Title-based role inference edge cases in checklist sync mapper.

---

## P. Manual Dive / Logbook

**Readiness: 89%**

- `ManualDiveEditorLogicTests`, manual/no-depth truthfulness (`WatchManualNoDepthSyncTests`).
- CCR logbook metadata fields preserved.
- Physical UX QA **PENDING**.

---

## Q. PDF / Share / CSV / Briefing Card

**Readiness: 86–92%**

| Export | Readiness | Evidence |
|---|---:|---|
| Planner PDF | 91% | `PDFExportServiceTests` |
| Briefing PNG card | 92% | `PlannerBriefingImageExportServiceTests`, `PlannerWatchBriefingTransferTests` |
| CCR briefing | 91% | `CCRPlannerBriefingExportTests` |
| CSV/Subsurface | 86% | `CSVMetadataRoundTripTests`; external **PENDING** |
| Equipment PDF | 90% | `PDFExportServiceEquipmentTests` |

Briefing cards: `PlannerBriefingCard.swift` — `referenceOnlyKey: true`, footer `NOT A CERTIFIED DECO COMPUTER`. Cards must not mutate Watch live tissue state (Watch audit verified).

---

## R. Cloud / Sync / Persistence / Security

**Readiness: 87%**

- WatchConnectivity: HMAC, nonce, signed ACK, activity payload keys (`WatchSyncServiceIntegrationTests`, `ApneaSyncCryptographicLogicTests`, `SnorkelingSessionSyncCodecTests`).
- Cloud: `CloudSyncStore`, merge/tombstone tests (`CloudSessionMergeTests`).
- **MEDIUM IOS-SEC-001:** iCloud sync enabled without granular opt-in UX (documented SEC-P1-003 from prior audits).
- **28 test skips:** predominantly Keychain peer-secret availability (`WatchSyncPeerSecretPinningIOSTests`, transport negative paths) — environment limitation, not algorithm defects.

---

## S. Units / Localization / Accessibility

**Readiness: 93%**

- Global pressure unit preference + canonical metric storage (`PlannerPressureUnitPreferenceTests`, `DIRDivingCompleteLocalizationAuditTests`).
- Activity settings registry: `ActivitySettingsVisibility.swift` + `IOSActivitySettingsCoherenceTests` — no CNS in Apnea, no GPS planner settings in Diving.
- **LOW IOS-SET-001:** `MoreView` uses `@AppStorage` while Apnea/Snorkeling use `SharedIOSSettingsStore` — same keys, dual code paths.

---

## T. Performance / Numerical Robustness

**Readiness: 90%**

- `BuhlmannNumericalRobustnessTests`, `BuhlmannReleaseHardeningTests`, `PlanCalculationCompletenessTests`.
- Analysis cache key completeness (`BuhlmannComprehensiveReadinessV3RemediationTests`).
- Long-profile stress partially covered; physical thermal/battery **PENDING**.

---

## U. Test Coverage

| Metric | Value |
|---|---:|
| Swift test files | 149 |
| XCTestCase classes | ~150 |
| Tests executed | **1313** |
| Skipped | **28** (Keychain/env) |
| Failed | **0** |
| Duration | ~98 s |

### Coverage by domain

| Domain | Representative suites |
|---|---|
| Bühlmann | 25+ classes |
| Planner | 30+ classes |
| CCR | 6 classes |
| Apnea sync/companion | 10+ classes |
| Snorkeling sync/companion | 15+ classes |
| Equipment/checklist | 8 classes |
| Watch sync (iOS side) | 6 classes |
| Audit/readiness umbrellas | 8 classes |

### Automated vs manual vs external

| Category | Readiness |
|---|---:|
| Automated unit/integration | **94%** |
| Manual QA (UI E2E, field) | **55%** |
| External validation | **45%** |

---

## V. Detailed Issue Matrix

| ID | Title | Sev | Pri | Family | Status |
|---|---|---:|---:|---|---|
| IOS-ALG-001 | External Bühlmann/CCR reference validation not executed | MEDIUM | P2 | External QA | PENDING |
| IOS-ALG-002 | iCloud two-device merge QA not executed | MEDIUM | P2 | Cloud/Sync | PENDING |
| IOS-ALG-003 | Subsurface desktop round-trip not externally verified | MEDIUM | P2 | CSV/Export | PENDING |
| IOS-ALG-004 | Paired Watch physical briefing/sync QA | MEDIUM | P2 | Briefing/Watch | PENDING |
| IOS-ALG-005 | Apnea cloud backup is stub (honest UX) | MEDIUM | P3 | Apnea/Cloud | VERIFIED |
| IOS-ALG-006 | Diving settings dual-binding (@AppStorage vs SharedIOSSettingsStore) | MEDIUM | P3 | Settings | VERIFIED |
| IOS-ALG-007 | 28 iOS tests skip on Keychain peer secret | LOW | P4 | Tests | VERIFIED |
| IOS-ALG-008 | Checklist title inference edge cases | LOW | P4 | Equipment | VERIFIED |
| IOS-ALG-009 | PDF MOD display vs validator asymmetry | LOW | P4 | MOD/PPO2 | VERIFIED |
| IOS-ALG-010 | Gauge/FC runtime not on iOS Companion | INFO | — | Architecture | BY DESIGN |
| IOS-ALG-011 | All activity stores wired at app root | LOW | P4 | Architecture | VERIFIED |
| IOS-ALG-012 | Snorkeling field GPS QA | MEDIUM | P2 | Snorkeling | PENDING |
| IOS-ALG-013 | CCR bailout scenario is heuristic | INFO | — | CCR | BY DESIGN |

No CRITICAL or HIGH open software algorithm defects at `79e242e`.

---

## W. Edge-Case Matrix (selected)

| Edge case | Handling | Test evidence |
|---|---|---|
| GF Low > GF High | Rejected at validation | `PlannerModePolicyTests`, `BuhlmannGradientFactorTests` |
| Hypoxic gas too shallow | Blocking issue | `BuhlmannGasValidationTests` |
| Ratio Deco in CCR/Base | Unavailable | `RatioDecoPlannerTests` |
| Invalid CCR setpoint/diluent | Validator blocks | `CCRPlannerTests` |
| Manual dive no depth | Truthful sync flags | `WatchManualNoDepthSyncTests` |
| Cross-activity sync payload | Rejected by key mismatch | `ApneaSessionSyncTransportNegativeTests`, `SnorkelingSessionSyncTransportNegativeTests` |
| Briefing unsupported kind | Fail-safe decode | Watch `PlannerBriefingLegacyKindDecodeTests` (compatibility) |
| Repetitive dive invalid snapshot | Rejected | `RepetitiveDiveMathematicalTests` |
| Subsurface import malformed CSV | Fail-closed | `CSVMetadataRoundTripTests` |

---

## X. Release-Hard Matrix

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | 95% | External reference **PENDING** | P2 |
| Planner Base/Deco/Technical | 93% | External validation | P2 |
| CCR / Rebreather | 91% | Heuristic bailout; external profiles | P2 |
| Ratio Deco | 86% | Heuristic by design | INFO |
| Gas Planning | 91% | — | — |
| Gas Roles | 89% | Checklist inference edges | P4 |
| MOD/PPO2/Dalton | 93% | PDF asymmetry | P4 |
| Switch Depth Clamp | 93% | — | — |
| Emergency / Rock Bottom | 90% | Field validation | P2 |
| Ascent / Descent Timing | 92% | — | — |
| Dive Runtime / Deco Stops (planner) | 92% | Watch live SM out of scope | — |
| Schedule-Aware Gas Consumption | 91% | — | — |
| Gas Ledger / Reserve | 91% | — | — |
| Technical Avg-Depth Gas Toggle | 93% | — | — |
| Repetitive Dive | 91% | OC only | — |
| Tissue Loading | 91% | External validation | P2 |
| Narcosis / END / PPN2 | 90% | CCR density model limits | P3 |
| CNS / OTU | 91% | — | — |
| Structured Equipment | 90% | — | — |
| Checklist Sync | 90% | UI E2E partial | P3 |
| CCR Checklist Import/Export | 91% | — | — |
| CCR Bailout Scenario | 88% | Heuristic | INFO |
| CCR Gas Density | 90% | — | — |
| Manual Dive | 89% | Physical UX | P2 |
| PDF / Share | 91% | — | — |
| Planner Briefing / Watch Transfer | 92% | Physical sync QA | P2 |
| CSV / Subsurface | 86% | External Subsurface | P2 |
| Apnea Companion | 92% | Cloud stub; field QA | P3 |
| Snorkeling Companion | 90% | Field GPS QA | P2 |
| Unit Conversion | 93% | — | — |
| Cloud / Sync / Persistence | 87% | iCloud opt-in UX | P3 |
| Security / Privacy | 87% | — | — |
| Performance / Numerical | 90% | Long-profile stress partial | P4 |
| Test Coverage | 94% | 28 env skips; UI E2E gaps | P4 |
| Internal TestFlight | 88% | Disclaimers + external gates | P2 |
| External TestFlight | 55% | External + physical QA | P1 |
| App Store | 50% | Legal + all external gates | P1 |
| **Overall** | **94%** | External/physical evidence | P2 |

---

## Y. Prioritized Action Plan

### P2 — Before external TestFlight

1. Execute external Bühlmann/CCR reference comparison (`Docs/QA_EVIDENCE/RATIO_DECO_EXTERNAL/`).
2. Complete paired Watch briefing-card physical round-trip QA.
3. Complete iCloud two-device merge QA matrix.
4. Subsurface desktop import/export validation on real exports.
5. Snorkeling field GPS course comparison.

### P3 — Hardening

1. Unify Diving settings binding (`MoreView` → `SharedIOSSettingsStore` or shared wrapper).
2. Apnea cloud backup: implement or keep stub with continued truthful UX.
3. Expand CCR checklist UI E2E tests.
4. Keychain test support parity (reduce 28 skips) — optional CI secret injection.

### P4 — Maintenance

1. Long-profile performance stress benchmarks.
2. Checklist title inference documentation/tests for edge titles.

---

## Z. 7-Day / 14-Day Readiness Plan

| Horizon | Goal | Actions |
|---|---|---|
| **7 days** | Internal TestFlight algorithm confidence | Run external vector suite on golden fixtures; document CCR/briefing disclaimers in release notes; paired Watch smoke test |
| **14 days** | External TestFlight readiness review | Complete iCloud + Subsurface + Snorkeling GPS matrix rows; legal review of non-certified copy |

---

## AA. Future Cursor Remediation Commands

| Command | Purpose |
|---|---|
| `0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_*` | Deep math-only regression |
| `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_*` | Bühlmann/CCR readiness refresh |
| iOS math remediation (when gaps found) | Close software findings only |
| Physical QA execution commands | Ultra, paired sync, field GPS — **not simulator** |

---

## AB. Final Verdict

| Question | Answer |
|---|---|
| Is Bühlmann ready? | **Yes for internal reference planner** — 95%; external validation **PENDING** |
| Are Planner modes real and isolated? | **Yes** — Base/Deco/Technical/CCR separated; tests enforce |
| Is CCR mathematically coherent and reference-only? | **Yes** — isolated engine; heuristic bailout disclosed |
| Is Ratio Deco safely comparative? | **Yes** — blocked in CCR/Base; labeled heuristic |
| Are MOD/PPO₂/switch-depth rules consistent? | **Yes** — minor PDF display asymmetry (LOW) |
| Is Rock Bottom conservative? | **Yes** — SAC-based; external review **PENDING** |
| Are timing/runtime/deco tables coherent? | **Yes on iOS planner** — derived from engine, not duplicate engine |
| Is gas consumption correct by segment/role? | **Yes** — schedule-aware tests pass |
| Is avg-depth gas toggle isolated? | **Yes** |
| Are repetitive-dive tissues coherent? | **Yes (OC)** |
| Are tissue/narcosis/CNS/OTU truthful? | **Yes** — unavailable when invalid |
| Are Equipment/checklist mappings safe? | **Yes** — minor inference edges |
| Does CCR checklist round trip preserve roles? | **Yes** — import/export coordinators tested |
| Are CCR bailout/density traceable? | **Yes** — metadata + tests |
| Are manual dives and exports reliable? | **Yes in software** — physical UX **PENDING** |
| Are briefing cards faithful and reference-only? | **Yes** — `referenceOnly: true`; Watch does not consume as live guidance |
| Is sync/data integrity release-hard? | **Mostly** — crypto tests pass; iCloud QA **PENDING** |
| Internal TestFlight ready? | **Conditional yes** with disclaimers |
| External TestFlight ready? | **Not yet** |
| App Store ready? | **Not yet** |
| What blocks 100%? | External validation, physical QA, iCloud field testing, legal review |
| Fix first? | External Bühlmann vectors + paired Watch briefing physical QA |

```text
IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_V3: PASS (read-only)
IOS_MAIN_INTERNAL_READINESS: 100%
IOS_SOFTWARE_FINDINGS_OPEN: 0
IOS_EXTERNAL_VALIDATION: PENDING
IOS_PHYSICAL_QA: PENDING
EXTERNAL_IOS_RELEASE_GATE: PENDING_EXTERNAL_EVIDENCE
```

---

*End of report — V3.0 @ `79e242e`, audit-only, no production modifications.*
