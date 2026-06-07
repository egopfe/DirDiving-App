# iOS Companion MAIN Branch — Full Algorithm, Feature & Release Readiness Audit

**Audit date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main` only  
**Code baseline:** `e88c499` — `feat(ios): add Ratio Deco as comparative heuristic planner method`  
**Primary target:** `DIRDiving iOS`  
**Secondary target:** Apple Watch companion/runtime (scoped features only)  
**Mode:** Read-only audit. No application code modified. No commit. No push.  
**Supersedes:** prior revision @ `81f2d7f` (2026-06-07, pre–Ratio Deco)

---

## Scope Confirmation (Phase 0)

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `e88c499` |
| Working tree | Clean at audit start and end |
| Remote | `origin/main` @ `e88c499` |
| Experimental branches | Not modified |
| macOS build/test | Executed |

### Targets in `project.yml`

**DIRDiving iOS** — excludes experimental-only sources:
- `ExplorationModels.swift`, `BuddyExperimentalModels.swift`
- `ExplorationPlanningStore.swift`, `BuddyExperimentalStore.swift`
- `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`

**DIRDiving Watch App** — excludes buddy/apnea/snorkeling experimental surfaces.

**Test targets:** `DIRDiving iOS Algorithm Tests` (67 Swift test files + fixtures), `DIRDiving Watch Algorithm Tests` (171 tests).

### Build / test execution (Phase 17)

| Command | Destination | Result |
|---|---|---|
| `xcodegen generate` | — | OK |
| `DIRDiving iOS` build | iPhone 17 simulator | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | iPhone 17 simulator | **435 passed**, 13 skipped, 0 failures |
| `DIRDiving Watch App` build | Apple Watch Ultra 3 (49mm) | **BUILD SUCCEEDED** |
| `DIRDiving Watch Algorithm Tests` | Apple Watch Ultra 3 (49mm) | **171 passed**, 13 skipped, 0 failures |

Note: Requested `Apple Watch Ultra 2 (49mm)` simulator unavailable; **Apple Watch Ultra 3 (49mm)** used (OS 26.5).

---

## A. Executive Summary

### Overall verdict

At `e88c499`, DIR DIVING `main` is a **coherent, non-certified reference diving companion** with:

- Real Bühlmann ZHL-16C + GF decompression engine (iOS Planner)
- Three enforced planner modes (Base / Deco / Technical)
- **Ratio Deco** as an explicitly labeled heuristic comparator with Bühlmann cross-validation
- Gas/MOD/PPO₂ validation, CNS/OTU exposure models, tissue/narcotic analytics
- Equipment checklist with DIR/READY badges, PDF export/share, logbook CSV, Watch sync

**No P0 safety-critical algorithm defect** was found in static review or automated tests. **Internal algorithm validation is strong** (435 iOS + 171 Watch XCTest). **External decompression validation, paired-device QA, and documentation refresh** remain before App Store claims.

### Readiness estimates

| Area | Readiness | Confidence |
|---:|---:|---|
| **Overall MAIN readiness** | **88%** | High on code; medium on external QA |
| **Mathematical robustness** | **91%** | Bühlmann + exposure real; Ratio Deco heuristic; logbook tissue simulated |
| **Planner confidence** | **92%** | Mode policy + engine integration solid |
| **Bühlmann readiness** | **93%** | Real Schreiner/GF schedule; external fixtures pending |
| **Ratio Deco readiness** | **82%** | Correctly comparative; validator gaps; distribution modes duplicate |
| **Tissue / narcosis analytics** | **86%** | Planner path real; session path simulated |
| **CNS / OTU readiness** | **90%** | NOAA/Lambertsen integrated; UI clarity good |
| **Checklist / equipment** | **89%** | DIR badge real; gasText UI gap |
| **PDF / share readiness** | **87%** | Core flows work; Dive Pack omits Ratio Deco |
| **Watch companion readiness** | **85%** | Core dive lifecycle ready; EN localization gaps |
| **Sync / data confidence** | **88%** | CloudSync + merge tested; physical iCloud QA pending |
| **Documentation accuracy** | **72%** | README/INDEX baseline stale (`a69bc4b` vs `e88c499`) |
| **Automated tests** | **94%** | 606 total XCTest pass; some Ratio Deco / alarm gaps |

### Release gates

| Gate | Verdict |
|---|---|
| **Compile / unit-test (macOS)** | **Ready** |
| **Internal TestFlight (engineering)** | **Almost ready** — P1 doc + EN Watch strings |
| **External TestFlight** | **Not yet** — physical QA matrices pending |
| **App Store** | **Not yet** — external Bühlmann validation + paired sync QA |

### TestFlight / App Store blockers (summary)

1. External Bühlmann reference comparison campaign not complete (`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`)
2. Physical QA matrices largely **PENDING** (`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`, `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`)
3. Documentation baseline 4 commits behind HEAD
4. Watch EN localization holes for depth validation and photo sync status (P1)
5. Ratio Deco ceiling-violation path untested (P2)

---

## B. Algorithm Inventory (Phase 1–2)

### iOS Planner — implemented features

| Feature | Status | Primary evidence |
|---|---|---|
| Base / Deco / Technical modes | ✅ | `PlannerModePolicy`, `PlannerModeLimits`, `PlannerStore` |
| Bühlmann ZHL-16C + GF | ✅ Real | `BuhlmannEngine`, `BuhlmannTissueModel`, `BuhlmannConstants` |
| Ratio Deco heuristic | ✅ | `RatioDecoPlanner`, `RatioDecoModels` |
| Bühlmann vs Ratio comparison | ✅ | `RatioDecoComparisonSection`, `PlannerDecompressionMethod.comparison` |
| Ratio Deco presets 1:1 / 2:1 / custom | ✅ | `RatioDecoPreset`, `RatioDecoPresetCard` |
| Custom preset persistence | ✅ | `PlannerState.savedRatioDecoPresets` |
| Ratio Deco PDF | ✅ Plan + Briefing | `PlannerPDFBuilder.appendRatioDecoSection` |
| Air / EAN / Trimix / O2 selector | ✅ | `PlannerGasMixCard`, `PlannerGasEditingSupport` |
| PPO₂ step 0.1 | ✅ | `PlannerGasEditingSupport.ppo2Step = 0.1` |
| MOD auto-update | ✅ | `GasPlanInput.normalizeSwitchDepthsToMOD` |
| Dalton MOD validation | ✅ | `GasMixValidator.modMeters`, `PlannerMODValidator` |
| Gas switch validation | ✅ | `BuhlmannPlanPreflightValidator`, `PlannerMODValidator` |
| Back / Travel / Deco / Bailout roles | ✅ | `GasRole`, `PlannerGasSchedule` |
| Max vs average depth reference | ✅ | `GasPlanInput.planningDepthReference` |
| Emergency gas on max depth rule | ✅ | `PlannerGasEditingSupport` + UI info |
| Wheel pickers O₂/He/PPO₂/pressure | ✅ | `PlannerCylinderGasEditorView` |
| Base no-deco via Bühlmann NDL | ✅ | `PlannerModeLimits.requiresMandatoryDecompression` |
| Deco ≤ 40 m max/avg | ✅ | `PlannerModeLimits.validateDecoDepthLimits` |
| Technical unrestricted depth | ✅ | No artificial caps in `PlannerModePolicy.validate` |
| Repetitive planning (Technical) | ✅ | `RepetitiveDivePlannerService` |
| CNS descent+bottom threshold (5–50%, default 15%) | ✅ | `PlannerCNSDescentBottomCheckSettings` |
| Tissue analytics (planner) | ✅ Real replay | `BuhlmannTissueHistory` → `TissueAnalyticsService.buildFromPlanner` |
| Narcotic loading / END | ✅ | `GasPlanningService.equivalentNarcoticDepth` |

### Bühlmann — math assessment

**Verdict: Real reference implementation, not certified.**

- 16 N₂ + 16 He compartments (`BuhlmannConstants`)
- Schreiner loading (`BuhlmannTissueModel.loadedLinearDepth`)
- GF-interpolated ceiling (`BuhlmannTissueModel.ceiling`)
- Iterative stop schedule (`BuhlmannEngine.decompressionSchedule`)
- NDL via binary search (`BuhlmannEngine.noDecompressionLimit`)
- Preflight gas envelope validation before schedule

**Non-fake elements with caveats:**
- NDL curve `compartmentGroup` labels are **static depth bands** for chart UX, not controlling compartment (`BuhlmannPlanner.ndlCurve`)
- Bailout cylinders **excluded** from engine (`BuhlmannPlanner.makeRequest` comment)

### Ratio Deco — assessment (Phase 5)

**Verdict: Correctly implemented as comparative heuristic.**

| Requirement | Status |
|---|---|
| Disclaimer visible | ✅ `RatioDecoDisclaimerBanner` + localized strings |
| Bühlmann remains primary (default method) | ✅ `PlannerDecompressionMethod.buhlmann` default |
| Does not bypass MOD/PPO₂ | ✅ Uses `PlannerMODValidator`; warnings on violation |
| Presets 1:1 / 2:1 / custom | ✅ `RatioDecoPreset` |
| Custom persistence | ✅ `PlannerStore.saveRatioDecoPreset` |
| Schedule generation | ✅ Stop ladder + ratio time distribution |
| Bailout excluded | ✅ `gasAssignment` filters `.bailout` |
| Bühlmann validation | ✅ `RatioDecoValidator` replays tissue, checks GF-low ceiling |
| Comparison tables + overlay chart | ✅ `RatioDecoComparisonSection` |
| PDF integration | ✅ Plan + Briefing (not Dive Pack) |
| Localization IT/EN | ✅ Keys in `Localizable.strings` |

**Heuristic formula (documented in code):**
- 1:1 → total deco ≈ bottom time
- 2:1 → total deco ≈ bottom time / 2
- Custom → bottom / denominator
- Stops from deepest deco switch (or preset first stop) to 3 m in steps
- **Balanced and Linear distribution modes are currently identical** (`RatioDecoPlanner.distributeStopMinutes`)

**Safety note:** Validator confirms ceiling at stop depths with GF-low; it does **not** prove overall schedule adequacy vs full Bühlmann TTS. Aggressive ratio presets may show warnings but remain selectable.

---

## C. Planner Mode Audit (Phase 3)

### Base

| Check | Result |
|---|---|
| No-deco only enforced | ✅ `basicNoDecoLimitExceeded` + `canCalculatePlan` |
| Bühlmann detects mandatory deco | ✅ Engine NDL + `requiresMandatoryDecompression` |
| Invalid depth/time blocked | ✅ Input clamp + validation |
| Hidden technical gases in projection | ✅ `projectBaseInput` strips to bottom only |
| Ratio Deco unavailable | ✅ Picker disabled + validator warning |
| Warnings IT/EN | ✅ `planner.mode.basic.*` keys |

### Deco

| Check | Result |
|---|---|
| Max depth ≤ 40 m | ✅ `validateDecoDepthLimits` |
| Average depth ≤ 40 m | ✅ Same validator |
| Decompression allowed | ✅ Full ascent table (simplified presentation) |
| Over-40 m rejected | ✅ Validation + Ratio Deco empty schedule |
| Warnings IT/EN | ✅ `planner.mode.deco.depth_limit.*` |

### Technical

| Check | Result |
|---|---|
| Full multigas (travel, deco, bailout) | ✅ `projectTechnical` preserves draft |
| No artificial depth/time caps | ✅ Confirmed |
| MOD/PPO₂/gas validation active | ✅ Preflight + live MOD gate |
| GF manual + comparison + charts | ✅ `PlannerResultPresentation` |

---

## D. Gas / MOD / PPO₂ / SAC Assessment (Phase 4)

| Check | Result | Evidence |
|---|---|---|
| Back Gas surface → first switch | ✅ | `PlannerGasSchedule`, engine bottom gas |
| Travel in defined range | ✅ | Role-filtered in engine travel gases |
| Deco ascent only | ✅ | Deco role in schedule |
| Bailout emergency only | ✅ | Schedule lines + warnings; **not in Bühlmann engine** |
| Air locks 21/0/79 | ✅ | `GasMixValidator`, mix kind handlers |
| EAN edits O₂ only | ✅ | `PlannerGasEditingSupport` |
| Trimix O₂ + He | ✅ | Technical mode |
| O₂ locks 100/0/0 | ✅ | Mix kind `.oxygen` |
| N₂ = 100 − O₂ − He | ✅ | Computed property |
| MOD auto-updates | ✅ | `normalizeSwitchDepthsToMOD` |
| Switch depth ≤ MOD | ✅ | Clamp + validation |
| PPO₂ step exactly 0.1 | ✅ | `ppo2Step = 0.1`; tests in `PlannerGasEditingSupportTests`, `PPO2DisplayTests` |
| 0.05 values | Used only as **comparison tolerances** (MOD margin, ceiling epsilon), not PPO₂ steps | `PlannerMODValidator`, `BuhlmannEngine` |
| Bühlmann receives UI gas values | ✅ | `PlannerService` → `BuhlmannPlanner.makeRequest` from active input |

---

## E. Tissue & Narcosis Assessment (Phase 6)

| Component | Planner path | Logbook path |
|---|---|---|
| `TissueAnalyticsTrace` | ✅ From `BuhlmannTissueHistory` | ✅ Simulated |
| 16 compartments C1–C16 | ✅ | ✅ |
| Controlling compartment | ✅ | ✅ |
| Loading % / trend | ✅ GF-relative | ✅ Fixed GF 0.85 |
| Bühlmann source | ✅ Real | ⚠️ Assumed gas + 1-min steps |
| PPN2 / END narcotic chart | ✅ From segments | ✅ From profile samples |
| Source labels recorded/planned/simulated | ✅ | ✅ |
| Empty state | ✅ | ✅ Insufficient data |
| Informational only | ✅ Disclaimers in UI/docs | ✅ |

**Finding:** Logbook tissue analytics is explicitly **simulated** (`TissueAnalyticsService.buildFromSession`, `source: .simulated`). Not fake UI numbers, but **not equivalent to Bühlmann replay of recorded profile**.

---

## F. CNS / OTU Assessment (Phase 7)

| Check | Result |
|---|---|
| CNS full plan | ✅ `GasPlanningService` → `OxygenExposureModel` |
| Descent + bottom CNS | ✅ Separate metric + optional threshold warning |
| Ascent/deco CNS in full plan | ✅ Integrated in full-plan CNS |
| 15% descent+bottom rule (configurable 5–50%) | ✅ `PlannerCNSDescentBottomCheckSettings` |
| Deco gas CNS contribution | ✅ Per-segment integration (0.05 min steps) |
| O₂ 100% handling | ✅ High PPO₂ segments |
| Labels IT/EN | ✅ |
| Warning visibility | ✅ Banners in `PlanResultView` |
| Misleading bottom-only after full calc | ✅ Mitigated — separate tiles + footnotes |

Tests: `CNSDescentBottomTests`, `OxygenExposureDeepModelTests`, `OTUCanonicalFixtureTests`, `PlannerCNSCopyTests`.

---

## G. Charts / Tables Assessment (Phase 8)

| Chart / table | Data source | Static/fake? |
|---|---|---|
| PIANO / ascent plan | `PlannerAscentTableBuilder` from engine | Real engine output |
| Depth/time profile | `PlannerDepthProfileBuilder` from segments | Real |
| Bühlmann NDL curve | `BuhlmannPlanner.ndlCurve` | Real NDL; static group labels |
| Tissue chart | `BuhlmannTissueHistory` | Real (planner) |
| Narcotic chart | PPN2/END from analytics | Real (planner) |
| Ratio Deco overlay | Both depth profiles | Real generated points |
| Gas bars / ledger | `ScheduleGasConsumptionService` | Real |
| Runtime/TTS consistency | Engine segments | Real; Ratio comparison uses simplified Bühlmann runtime in table |

Accessibility: chart a11y labels present (`planner.charts.*.a11y`). Dynamic Type partially covered (`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` — manual QA pending).

---

## H. Checklist / Equipment Assessment (Phase 9)

| Feature | Status |
|---|---|
| REC / TEC / custom templates | ✅ `EquipmentStore.defaultTemplates` |
| Equipment / Task / GAS item types | ✅ |
| GAS switch conditional fields | ✅ Hide when switch OFF |
| Air/EAN/Trimix/O₂ in checklist | ✅ |
| Cylinder roles (Back, Deco Stage, Travel, Bailout) | ✅ |
| Planner ↔ Checklist guided sync | ✅ `ChecklistPlannerSyncMapper` |
| Duplicate prevention | ✅ Fingerprint matching |
| PDF YES/NO boxes | ✅ `PDFPageContext.drawChecklistRow` |
| DIR badge red/green | ✅ `DIRChecklistConfigurationEvaluator` (7 rules) |
| READY badge | ✅ Item count |
| FIELD badge | ✅ **Removed** @ `1e75a20` (dead i18n keys remain) |

**DIR required items verified in code:** bibo/twinset config, backup mask, SMB, spool, ready gas, wet notes, signaling buoy + spool.

**Gap:** Checklist has no `gasText` composition field or switch depth; sync falls back to mix-kind defaults when empty.

---

## I. PDF / Share Assessment (Phase 10)

| Export | Status | Notes |
|---|---|---|
| Plan PDF | ✅ | Full profile, gases, Bühlmann schedule, warnings |
| Briefing PDF | ✅ | Briefing lines + ascent |
| Checklist PDF | ✅ | YES/NO printable fields |
| Dive Pack PDF | ✅ | Combined; **no Ratio Deco section** |
| Ratio Deco disclaimer in PDF | ✅ Plan + Briefing |
| Share sheet | ✅ `ShareSheetView` |
| Invalid/empty gating | ✅ `PDFExportService.canExportPlan` |
| File protection | ✅ `.completeFileProtection` on export dir |
| Localization | ✅ PDF string keys |

Toolbar share icons: Planner (`PlannerView`), Equipment checklist (`EquipmentView`).

---

## J. Logbook / Manual Dive / Import Export (Phase 11)

| Feature | Status |
|---|---|
| Manual dive add/edit/delete | ✅ `ManualDiveEditorView`, `DiveLogStore` |
| Max/avg depth, GPS, profile, equipment | ✅ |
| Bar in/out, textual deco | ✅ |
| CSV export (Subsurface-compatible) | ✅ `SubsurfaceExportService` (iOS) |
| CSV import with guards | ✅ `DiveImportService` — size/row/column caps |
| Duplicate/malformed handling | ✅ Tests in `CSVMetadataRoundTripTests`, `MainDeepCodeAuditRemediationTests` |
| Metric/imperial consistency | ✅ `IOSUnitPreference` |
| Tissue/narcosis on recorded profiles | ✅ Simulated analytics |

---

## K. Apple Watch Companion Assessment (Phase 12)

| Feature | Status | Evidence |
|---|---|---|
| Manual start button | ✅ | `DiveLiveView` → `startManualDive()` |
| Auto-start > 1 m (2 samples) | ✅ | `DiveLifecycleAlgorithm`, `DiveAlgorithmConfiguration` |
| No duplicate sessions | ✅ | `DiveManager.beginDiveIfNeeded` |
| Images before dive | ✅ | `UserImagesView`; tabs restricted during dive |
| iOS image transfer | ✅ | `WatchSyncService` + iOS panel |
| Max depth alarm configurable | ✅ | `AlarmSettingsView`; default 40 m; stepper 10–100 m (30 m reachable) |
| Apple depth safety haptics 35/38/40 | ✅ | `DepthSafetyConfiguration`, `DepthLimitHapticCoordinator` |
| Back arrow navigation | ✅ | `WatchSubscreenBackToolbar`, `WatchDetailBackButton` |
| Multiple dive reminders (≤10) | ✅ | `DiveReminder`, `DiveReminderEngine` |
| Single/recurring, haptic, 3s overlay | ✅ | `DiveManager` reminder pipeline |
| Simultaneous aggregation (2 visible) | ✅ | `DiveReminderEngine` |
| Units IT/EN | ⚠️ Partial | Main UI localized; depth validation errors IT-only keys |
| Watch build + tests | ✅ | Build OK; 171 tests pass |

**Note:** User max-depth alarm is **off by default** (`depthAlarmEnabled = false`).

---

## L. Sync / Persistence Assessment (Phase 13)

| Store | Key / mechanism | Backward compat |
|---|---|---|
| `PlannerStore` | `dirdiving_ios_experimental_planner_state` | ✅ Custom decode for Ratio Deco fields |
| `EquipmentStore` | equipment profile + templates | ✅ |
| `DiveLogStore` (iOS) | Protected file + iCloud merge + tombstones | ✅ |
| `CloudSyncStore` | KVS with size guard | ✅ |
| Watch sync | Signed ACK, nonce replay cache | ✅ Tests |
| Unit settings | iOS ↔ Watch via application context | ✅ |

Conflict handling: LWW merge with generation tokens; merge conflict UI documented in `CloudSessionMergeTests`.

---

## M. Localization / Accessibility Assessment (Phase 14)

**Coverage:** Extensive IT/EN keys for planner modes, Ratio Deco, gases, checklist, PDF, tissue analytics, Watch reminders.

**Gaps (P1–P2):**
- Watch depth validation strings use Italian keys without EN entries (`DiveManager.swift`)
- Watch photo sync status strings untranslated (`WatchSyncService.swift`)
- Dead `equipment.badge.field` keys after FIELD removal
- Hardcoded `"Unità"` in Watch settings picker

**Accessibility:** VoiceOver labels on key planner/Watch controls; full Dynamic Type matrix QA **pending manual pass** (`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`).

---

## N. Test Coverage Audit (Phase 15)

### iOS — 435 tests, 13 skipped, 0 failures

**Strong coverage:** Bühlmann (20+ test classes), planner modes, MOD/PPO₂, CNS/OTU, checklist sync, PDF export, cloud merge, Ratio Deco (10 tests), tissue analytics.

**Missing / weak:**
- Ratio Deco ceiling violation scenario (validator)
- Ratio Deco MOD violation scenario
- `BriefingPDFBuilder` dedicated tests
- Dive Pack + Ratio Deco section
- `EquipmentStore` persistence round-trip
- `ManualDiveEditorView` UI/logic tests

### Watch — 171 tests, 13 skipped, 0 failures

**Strong coverage:** Dive lifecycle, reminders, depth safety haptics, photo store, sync codec, localization guard.

**Missing / weak:**
- User max-depth alarm firing integration test
- 3+ simultaneous reminder `hiddenCount` aggregation
- WCSession photo file E2E on Watch target

---

## O. Documentation Audit (Phase 16)

| Document | Status |
|---|---|
| `SAFETY_DISCLAIMER.md` | ✅ Non-certified positioning |
| `DIR_DIVING_IOS_PLANNER_LIMITATIONS.md` | ✅ Mode limits |
| `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | ✅ External validation pending |
| `RELEASE_CHECKLIST.md` | ✅ Exists; needs Ratio Deco line item |
| `README.md` / `INDEX.md` | ⚠️ Baseline cites `a69bc4b`, not `e88c499` |
| Ratio Deco in docs | ⚠️ **Missing** dedicated doc (code comments + audit only) |
| `MAIN_BRANCH_FINAL_READINESS_REPORT.md` | ⚠️ Still mentions FIELD badge |

---

## P. Findings by Priority (Phase 18)

### P0 — Safety-critical
**None identified** in static audit + 606 passing unit tests.

---

### P1 — Release-hard / misleading risk

| ID | Title | Family | Location | Target | Impact | Proposed fix |
|---|---|---|---|---|---|---|
| **P1-001** | Documentation baseline stale | Docs | `Docs/README.md:7`, `Docs/INDEX.md` | iOS | Release notes mislead reviewers | Update baseline to `e88c499`; add Ratio Deco to feature matrix |
| **P1-002** | External Bühlmann validation incomplete | QA/Process | `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | iOS | Cannot claim reference accuracy vs published tools | Execute fixture campaign + sign-off |
| **P1-003** | Physical QA matrices pending | QA/Process | `MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md` | iOS+Watch | TestFlight risk | Complete device QA evidence packs |
| **P1-004** | Watch EN localization gaps (depth errors, photo sync) | Localization | `Services/DiveManager.swift`, `WatchSyncService.swift` | Watch | EN users see Italian/system keys | Add EN strings; localize status messages |
| **P1-005** | Ratio Deco selectable despite Bühlmann incompatibility | Planner UX | `RatioDecoComparisonSection` | iOS | User may treat heuristic as plan | Strengthen warning UX; optional export gate when incompatible |

---

### P2 — Correctness / validation / data integrity

| ID | Title | Family | Location | Mode | Proposed fix |
|---|---|---|---|---|---|
| **P2-001** | Ratio Deco Balanced = Linear | Ratio Deco | `RatioDecoPlanner.distributeStopMinutes` | Ratio | Implement distinct linear weights or remove duplicate mode |
| **P2-002** | No test for Ratio Deco ceiling violation | Tests | `RatioDecoValidator` | Ratio | Add fixture expecting `ceilingViolation` |
| **P2-003** | Dive Pack PDF omits Ratio Deco | PDF | `DivePackPDFBuilder.swift` | Ratio | Append same section as Plan PDF when selected |
| **P2-004** | Checklist missing gasText / switch depth | Checklist | `EquipmentChecklistGasSection` | Shared | Add fields + sync mapping |
| **P2-005** | Checklist PDF uses raw items not migrated | PDF | `PDFExportService.hasExportableChecklist` | iOS | Use `migratedChecklistItems` |
| **P2-006** | Logbook tissue analytics simulated | Analytics | `TissueAnalyticsService.buildFromSession` | iOS | Document clearly in UI; future: profile replay |
| **P2-007** | Bailout not in Bühlmann engine | Gas | `BuhlmannPlanner.makeRequest` | Technical | By design — ensure UI always shows schedule-only disclaimer |
| **P2-008** | NDL curve compartmentGroup static | Charts | `BuhlmannPlanner.ndlCurve` | Shared | Relabel chart legend as “depth band” not compartment |
| **P2-009** | Watch depth alarm off by default | Watch | `AlarmSettingsView` | Watch | Consider onboarding hint or safer default messaging |
| **P2-010** | Duplicate SubsurfaceExportService iOS/Watch | Maintainability | Two source files | Shared | Consolidate or document divergence |

---

### P3 — Documentation / polish

| ID | Title | Location |
|---|---|---|
| **P3-001** | Dead `equipment.badge.field` i18n keys | `Localizable.strings` |
| **P3-002** | No dedicated Ratio Deco user doc | `Docs/` |
| **P3-003** | Sync export/import default asymmetry (.skip vs .replace) | `ChecklistPlannerSyncMapper` |
| **P3-004** | Planning card in Equipment is informational only | `EquipmentView` |
| **P3-005** | Hardcoded `"Unità"` Watch settings | `SettingsView.swift:299` |
| **P3-006** | `RatioDecoWarning.noDecoGases` unused | `RatioDecoModels.swift` |

---

### P4 — Nice-to-have

| ID | Title |
|---|---|
| **P4-001** | Discrete 30 m preset for Watch depth alarm (currently stepper only) |
| **P4-002** | Bühlmann comparison table runtime from full segments (not cumulative deco only) |
| **P4-003** | Weekly OTU tile visibility in planner results |
| **P4-004** | EquipmentStore cloud round-trip unit test |

---

## Q. Edge Case Matrix (selected)

| Scenario | Base | Deco | Technical | Expected | Verified |
|---|---|---|---|---|---|
| Trimix bottom gas | Block | Block | Allow | Validation error / allow | ✅ Tests |
| Depth 41 m, deco mode | — | Block | — | `decoDepthLimitExceeded` | ✅ |
| Bottom time > NDL | Block | Allow | Allow | Base blocked | ✅ |
| MOD switch too deep | Block calc | Block calc | Block calc | MOD issues | ✅ |
| Ratio Deco in Base | N/A | — | — | Unavailable warning | ✅ |
| Ratio Deco depth 45 m Deco mode | — | Empty/warn | — | Depth limit | ✅ |
| O₂ 100% deco at 6 m | — | Allow | Allow | PPO₂ check | ✅ |
| CSV > size cap | — | — | — | Reject import | ✅ |
| Cloud oversize payload | — | — | — | Skip write | ✅ Test |
| Watch auto-start 0.9 m | — | — | — | No start | ✅ Test |
| Watch auto-start 1.1 m × 2 | — | — | — | Start | ✅ Test |

---

## R. Test Plan (Phase 19 — priority excerpts)

### Unit — P0/P1

| Feature | Input | Expected | Priority |
|---|---|---|---|
| Base NDL block | 30 m / 50 min air | `basicNoDecoLimitExceeded`, calc disabled | P0 |
| Deco 40 m cap | 41 m max | Validation fail | P0 |
| Ratio Deco ceiling fail | Aggressive 2:1 trimix dive | `isBuhlmannCompatible == false` | P1 |
| Bühlmann GF schedule | Fixture `gf-30-70.json` | Stops match golden | P1 |
| MOD switch 30 m on EAN50 | Switch at 30 m | MOD issue | P1 |

### Simulator — P1

| Feature | Steps | Pass criteria |
|---|---|---|
| Ratio Deco comparison | Technical dive → Comparison tab | Overlay chart + TTS delta + disclaimer |
| PDF Ratio Deco | Export plan with Ratio Deco selected | PDF generates; disclaimer section |
| Checklist sync | Export planner gas → checklist | No duplicates; roles preserved |
| Watch manual start | Tap MANUAL START on surface | Dive active; reminders fire from start |

### Physical — P1/P2

| Feature | Devices | Pass criteria |
|---|---|---|
| Watch ↔ iOS sync | Paired iPhone + Watch | Dive transfers; units sync |
| iCloud planner state | Two iOS devices | Ratio Deco preset survives |
| Subsurface CSV round-trip | Real file | Import → export → re-import |
| Watch photo transfer | iPhone sends photo | Visible on Watch pre-dive |
| Depth alarm @ 30 m | Watch enabled alarm | Haptic/message at threshold |

### Localization — P2

| Check | Pass criteria |
|---|---|
| EN Watch depth error | English UI, trigger validation error → English text |
| IT Ratio Deco disclaimer | Italian UI → Italian disclaimer in results + PDF |

---

## S. Prioritized Roadmap

### 1. Must fix before compile/use
**None** — builds and tests pass @ `e88c499`.

### 2. Must fix before internal TestFlight
- P1-001 Documentation baseline refresh
- P1-004 Watch EN localization (depth errors, photo sync)
- P2-002 Ratio Deco validator negative test + manual ceiling scenario QA

### 3. Must fix before external TestFlight
- P1-002 External Bühlmann validation campaign (partial sign-off minimum)
- P1-003 Physical QA matrices (iOS + paired Watch)
- P2-003 Dive Pack Ratio Deco section
- P2-005 Checklist PDF migrated items

### 4. Must fix before App Store
- Full external validation sign-off
- Complete accessibility QA matrix
- P1-005 Ratio Deco incompatible-profile UX hardening
- Legal/disclaimer review with Ratio Deco PDF text

### 5. Post-release improvements
- P2-006 Logbook tissue replay from recorded samples
- P2-001 Ratio Deco distribution mode differentiation
- P4-* polish items

---

## T. Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Mostly yes** for Bühlmann reference path (91%). Ratio Deco is intentionally **not** a decompression model. |
| **Are Base/Deco/Technical modes real?** | **Yes** — distinct projection, validation, and presentation; engine-backed NDL/40 m gates. |
| **Is Ratio Deco safely comparative?** | **Yes**, with disclaimer, Bühlmann validation, and comparison UI — but **not** a substitute for Bühlmann (82% readiness). |
| **Is Bühlmann truthful?** | **Yes** as non-certified ZHL-16C reference; external campaign still pending for published cross-check. |
| **Are tissue/narcosis charts truthful?** | **Planner: yes.** **Logbook: simulated approximation** — must be labeled informational. |
| **Are CNS/OTU correct?** | **Yes** per NOAA/Lambertsen reference models integrated in planner (90%). |
| **Is checklist operationally ready?** | **Yes** for DIR workflow (89%); gasText/switch depth gaps remain. |
| **Are PDFs/share ready?** | **Yes** for core flows (87%); Dive Pack Ratio Deco gap. |
| **Are Watch reminders/start dive ready?** | **Yes** for core functionality (85%); EN strings and alarm defaults need polish. |
| **Is sync/data ready?** | **Yes** at code level (88%); physical iCloud/paired QA pending. |
| **Ready for internal TestFlight?** | **Yes**, with P1 doc/localization fixes recommended first. |
| **Ready for external TestFlight?** | **Not yet** — external validation + device QA blockers. |
| **Ready for App Store?** | **Not yet**. |
| **What blocks 100% readiness?** | External Bühlmann validation, physical QA evidence, documentation refresh, Ratio Deco test/UX hardening, Watch EN gaps, logbook tissue simulation gap. |

---

## Audit metadata

| Item | Value |
|---|---|
| Auditor mode | Static code review + automated build/test |
| Files modified during audit | **This report only** (`Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`) |
| Application code modified | **None** |
| Commits / pushes | **None** |
| iOS tests | 435 passed, 13 skipped |
| Watch tests | 171 passed, 13 skipped |
| Experimental branches touched | **None** |

---

*End of audit report @ `e88c499`.*
