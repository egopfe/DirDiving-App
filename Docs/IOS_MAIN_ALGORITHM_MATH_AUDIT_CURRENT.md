# iOS Companion MAIN Branch — Full Algorithm, Feature & Release Readiness Audit

**Audit date:** 2026-06-07 (re-run post-remediation)  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main` only  
**Code baseline:** `32f8d3e` — `Implement iOS MAIN algorithm math audit remediation (P1–P4).`  
**Prior audit baseline:** `e88c499` (superseded) · **Remediation report:** [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md)  
**Primary target:** `DIRDiving iOS`  
**Secondary target:** Apple Watch companion/runtime (scoped features only)  
**Mode:** Read-only audit. No application code modified. No commit. No push.  
**Scope:** Original Check_Math_iOS unified audit + phases 2B–15B (Ratio Deco, tissue/narcosis, MOD/Dalton, gas roles, checklist/planner, PDF/share, manual dive, units, release matrix)

---

## Scope Confirmation (Phase 0)

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `32f8d3e` |
| Working tree | Clean at audit start and end |
| Remote | `origin/main` @ `32f8d3e` |
| Experimental branches | Not modified |
| macOS build/test | Executed |

### Targets in `project.yml`

**DIRDiving iOS** — excludes experimental-only sources:
- `ExplorationModels.swift`, `BuddyExperimentalModels.swift`
- `ExplorationPlanningStore.swift`, `BuddyExperimentalStore.swift`
- `ExplorationCenterView.swift`, `ExperimentalFutureConceptsView.swift`, `BuddyExperimentalView.swift`

**DIRDiving Watch App** — excludes buddy/apnea/snorkeling experimental surfaces.

**Test targets:** `DIRDiving iOS Algorithm Tests` (68 Swift test files + fixtures), `DIRDiving Watch Algorithm Tests`.

### Build / test execution (Phase 17)

| Command | Destination | Result |
|---|---|---|
| `xcodegen generate` | — | OK |
| `DIRDiving iOS` build | iPhone 17 Pro simulator | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | iPhone 17 Pro simulator | **443 passed**, 13 skipped, 0 failures |
| `DIRDiving Watch App` build | Apple Watch Ultra 3 (49mm) | **BUILD SUCCEEDED** |
| `DIRDiving Watch Algorithm Tests` | Apple Watch Ultra 3 (49mm) | **161 passed**, 13 skipped, 0 failures |

Note: Requested `Apple Watch Ultra 2 (49mm)` simulator unavailable; **Apple Watch Ultra 3 (49mm)** used (OS 26.5).

---

## A. Executive Summary

### Overall verdict

At `32f8d3e`, DIR DIVING `main` is a **coherent, non-certified reference diving companion** with:

- Real Bühlmann ZHL-16C + GF decompression engine (iOS Planner)
- Three enforced planner modes (Base / Deco / Technical)
- **Ratio Deco** as an explicitly labeled heuristic comparator with Bühlmann cross-validation, distinct distribution modes, and PDF/UX hardening
- Gas/MOD/PPO₂ validation, CNS/OTU exposure models, tissue/narcotic analytics with source footnotes
- Equipment checklist with DIR/READY badges, gasText/switch-depth fields, PDF export/share, logbook CSV, Watch sync

**No P0 safety-critical algorithm defect** was found in static review or automated tests. **Internal algorithm validation is strong** (443 iOS + 161 Watch XCTest). **External decompression validation, paired-device QA, and minor documentation baseline drift** remain before App Store claims.

### Post-remediation delta (vs prior audit @ `e88c499`)

All **non-physical** P1–P4 items from the prior audit were addressed in commit `32f8d3e`. See [Section P — Remediation status](#p-remediation-status--prior-findings) and the remediation report.

### Readiness estimates

| Area | Readiness | Confidence | Δ vs `e88c499` |
|---:|---:|---:|---:|
| **Overall MAIN readiness** | **94%** | High on code; medium on external QA | +6 |
| **Mathematical robustness** | **94%** | Bühlmann + exposure real; Ratio Deco heuristic; logbook tissue simulated | +3 |
| **Planner confidence** | **95%** | Mode policy + engine integration solid | +3 |
| **Bühlmann readiness** | **93%** | Real Schreiner/GF schedule; external fixtures pending | — |
| **Ratio Deco readiness** | **92%** | Distinct modes; ceiling test; Dive Pack PDF; incompatibility UX | +10 |
| **Tissue / narcosis analytics** | **90%** | Planner path real; session path simulated + UI footnotes | +4 |
| **CNS / OTU readiness** | **90%** | NOAA/Lambertsen integrated; UI clarity good | — |
| **Checklist / equipment** | **95%** | gasText/switch depth UI/sync/PDF; migration fixed | +6 |
| **PDF / share readiness** | **94%** | Dive Pack includes Ratio Deco; checklist migration | +7 |
| **Watch companion readiness** | **90%** | Core dive lifecycle ready; audit-target EN strings fixed | +5 |
| **Sync / data confidence** | **88%** | CloudSync + merge tested; physical iCloud QA pending | — |
| **Documentation accuracy** | **88%** | Ratio Deco doc added; README/INDEX still cite `a6ccd8d` not `32f8d3e` | +16 |
| **Automated tests** | **96%** | 604 total XCTest pass; 20 new remediation tests | +2 |

### Release gates

| Gate | Verdict |
|---|---|
| **Compile / unit-test (macOS)** | **Ready** |
| **Internal TestFlight (engineering)** | **Ready** — minor doc baseline commit ref |
| **External TestFlight** | **Not yet** — physical QA matrices pending |
| **App Store** | **Not yet** — external Bühlmann validation + paired sync QA + legal |

### TestFlight / App Store blockers (summary)

1. External Bühlmann reference comparison campaign not complete (`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`)
2. Physical QA matrices largely **PENDING** (`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`, `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`)
3. Documentation baseline commit refs in README/INDEX cite `a6ccd8d` instead of current `32f8d3e` (cosmetic)
4. Logbook tissue analytics remains **simulated** (documented; not equivalent to Bühlmann replay)
5. Accessibility Dynamic Type / VoiceOver matrix QA **pending manual pass**

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
| Ratio Deco PDF | ✅ Plan + Briefing + **Dive Pack** | `PlannerPDFBuilder`, `DivePackPDFBuilder.appendRatioDecoSection` |
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
- NDL curve `depthBand` labels are **static depth bands** for chart UX, not controlling compartment (`BuhlmannPlanner.ndlCurve`) — relabeled @ `32f8d3e`
- Bailout cylinders **excluded** from engine (`BuhlmannPlanner.makeRequest` comment) — schedule-only; UI footnotes retained

### Ratio Deco — assessment (Phase 5 / 2B)

**Verdict: Correctly implemented as comparative heuristic; remediation hardened UX and tests.**

| Requirement | Status |
|---|---|
| Disclaimer visible | ✅ `RatioDecoDisclaimerBanner` + localized strings |
| Bühlmann remains primary (default method) | ✅ `PlannerDecompressionMethod.buhlmann` default |
| Does not bypass MOD/PPO₂ | ✅ Uses `PlannerMODValidator`; warnings on violation |
| Presets 1:1 / 2:1 / custom | ✅ `RatioDecoPreset` |
| Custom persistence | ✅ `PlannerStore.saveRatioDecoPreset` |
| Schedule generation | ✅ Stop ladder + ratio time distribution |
| **Balanced vs Linear distinct** | ✅ **Fixed** — even vs shallow-weighted ramp (`RatioDecoPlanner.distributeStopMinutes`) |
| Bailout excluded | ✅ `gasAssignment` filters `.bailout` |
| Bühlmann validation | ✅ `RatioDecoValidator` replays tissue, checks GF-low ceiling |
| **Incompatible → NOT validated plan** | ✅ **Fixed** — UI status + PDF warnings |
| Comparison tables + overlay chart | ✅ `RatioDecoComparisonSection`; runtime from full `ascentTableRows` |
| PDF integration | ✅ Plan + Briefing + **Dive Pack** |
| `noDecoGases` warning wired | ✅ **Fixed** when no deco cylinder |
| Localization IT/EN | ✅ Keys in `Localizable.strings` |
| Dedicated user doc | ✅ [`RATIO_DECO_COMPARATIVE_HEURISTIC.md`](RATIO_DECO_COMPARATIVE_HEURISTIC.md) |

**Heuristic formula (documented in code):**
- 1:1 → total deco ≈ bottom time
- 2:1 → total deco ≈ bottom time / 2
- Custom → bottom / denominator
- Stops from deepest deco switch (or preset first stop) to 3 m in steps
- **Balanced:** equal weights; **Linear:** shallow ramp; **Shallow-weighted:** deepest stops weighted

**Safety note:** Validator confirms ceiling at stop depths with GF-low; it does **not** prove overall schedule adequacy vs full Bühlmann TTS. Aggressive ratio presets show warnings and **NOT validated plan** status when incompatible.

**Tests:** `RatioDecoPlannerTests`, `IOSMainAlgorithmMathRemediationTests` (balanced/linear, ceiling violation, PDF, comparison runtime).

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

## E. Tissue & Narcosis Assessment (Phase 6 / 6B)

| Component | Planner path | Logbook path |
|---|---|---|
| `TissueAnalyticsTrace` | ✅ From `BuhlmannTissueHistory` | ✅ Simulated |
| 16 compartments C1–C16 | ✅ | ✅ |
| Controlling compartment | ✅ | ✅ |
| Loading % / trend | ✅ GF-relative | ✅ Fixed GF 0.85 |
| Bühlmann source | ✅ Real | ⚠️ Assumed gas + 1-min steps |
| PPN2 / END narcotic chart | ✅ From segments | ✅ From profile samples |
| Source labels recorded/planned/simulated | ✅ | ✅ |
| **UI footnotes (simulated vs planned)** | ✅ **Fixed** | ✅ `TissueNarcosisAnalyticsView` |
| Empty state | ✅ | ✅ Insufficient data |
| Informational only | ✅ Disclaimers in UI/docs | ✅ |

**Finding:** Logbook tissue analytics is explicitly **simulated** (`TissueAnalyticsService.buildFromSession`, `source: .simulated`). UI footnote added @ `32f8d3e`. Not fake UI numbers, but **not equivalent to Bühlmann replay of recorded profile** — acceptable for reference-only positioning.

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
| Weekly OTU tile in planner | ✅ Existing tile; no fake data added (P4-003) |
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
| Bühlmann NDL curve | `BuhlmannPlanner.ndlCurve` | Real NDL; **`depthBand`** labels (not compartment) |
| Tissue chart | `BuhlmannTissueHistory` | Real (planner) |
| Narcotic chart | PPN2/END from analytics | Real (planner) |
| Ratio Deco overlay | Both depth profiles | Real generated points |
| Gas bars / ledger | `ScheduleGasConsumptionService` | Real |
| Runtime/TTS consistency | Engine segments | Real; **comparison table uses full `ascentTableRows` runtime** @ `32f8d3e` |

Accessibility: chart a11y labels present (`planner.charts.*.a11y`). Dynamic Type partially covered (`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` — manual QA pending).

---

## H. Checklist / Equipment Assessment (Phase 9 / 9B)

| Feature | Status |
|---|---|
| REC / TEC / custom templates | ✅ `EquipmentStore.defaultTemplates` |
| Equipment / Task / GAS item types | ✅ |
| GAS switch conditional fields | ✅ Hide when switch OFF |
| Air/EAN/Trimix/O₂ in checklist | ✅ |
| Cylinder roles (Back, Deco Stage, Travel, Bailout) | ✅ |
| **`gasText` + `switchDepthMeters`** | ✅ **Fixed** — UI, sync, PDF @ `32f8d3e` |
| Planner ↔ Checklist guided sync | ✅ `ChecklistPlannerSyncMapper` |
| Duplicate prevention | ✅ Fingerprint matching; export default `.replace` aligned |
| PDF YES/NO boxes | ✅ `PDFPageContext.drawChecklistRow` |
| PDF uses **migrated** items | ✅ **Fixed** — `migratedChecklistItems` in export/PDF |
| DIR badge red/green | ✅ `DIRChecklistConfigurationEvaluator` (7 rules) |
| READY badge | ✅ Item count |
| FIELD badge | ✅ Removed; dead i18n keys **removed** @ `32f8d3e` |
| Planning card informational label | ✅ **Fixed** — `EquipmentView` |

**DIR required items verified in code:** bibo/twinset config, backup mask, SMB, spool, ready gas, wet notes, signaling buoy + spool.

---

## I. PDF / Share Assessment (Phase 10 / 10B)

| Export | Status | Notes |
|---|---|---|
| Plan PDF | ✅ | Full profile, gases, Bühlmann schedule, warnings |
| Briefing PDF | ✅ | Briefing lines + ascent |
| Checklist PDF | ✅ | YES/NO printable fields; gasText/switch depth |
| Dive Pack PDF | ✅ | Combined; **Ratio Deco section + incompatibility warning** @ `32f8d3e` |
| Ratio Deco disclaimer in PDF | ✅ Plan + Briefing + Dive Pack |
| Share sheet | ✅ `ShareSheetView` |
| Invalid/empty gating | ✅ `PDFExportService.canExportPlan` |
| File protection | ✅ `.completeFileProtection` on export dir |
| Localization | ✅ PDF string keys |

Toolbar share icons: Planner (`PlannerView`), Equipment checklist (`EquipmentView`).

---

## J. Logbook / Manual Dive / Import Export (Phase 11 / 11B)

| Feature | Status |
|---|---|
| Manual dive add/edit/delete | ✅ `ManualDiveEditorView`, `DiveLogStore` |
| Max/avg depth, GPS, profile, equipment | ✅ |
| Bar in/out, textual deco | ✅ |
| CSV export (Subsurface-compatible) | ✅ `SubsurfaceExportService` (iOS + Watch) |
| CSV import with guards | ✅ `DiveImportService` — size/row/column caps |
| Duplicate/malformed handling | ✅ Tests in `CSVMetadataRoundTripTests`, `MainDeepCodeAuditRemediationTests` |
| Metric/imperial consistency | ✅ `IOSUnitPreference` |
| Tissue/narcosis on recorded profiles | ✅ Simulated analytics + footnote |
| Subsurface iOS/Watch divergence | ✅ **Documented** in file headers (not consolidated) |

---

## K. Apple Watch Companion Assessment (Phase 12)

| Feature | Status | Evidence |
|---|---|---|
| Manual start button | ✅ | `DiveLiveView` → `startManualDive()` |
| Auto-start > 1 m (2 samples) | ✅ | `DiveLifecycleAlgorithm`, `DiveAlgorithmConfiguration` |
| No duplicate sessions | ✅ | `DiveManager.beginDiveIfNeeded` |
| Images before dive | ✅ | `UserImagesView`; tabs restricted during dive |
| iOS image transfer | ✅ | `WatchSyncService` + iOS panel |
| Max depth alarm configurable | ✅ | `AlarmSettingsView`; default 40 m; **30 m preset** @ `32f8d3e` |
| **Depth alarm default-off hint** | ✅ **Fixed** — onboarding hint in `AlarmSettingsView` |
| Apple depth safety haptics 35/38/40 | ✅ | `DepthSafetyConfiguration`, `DepthLimitHapticCoordinator` |
| Back arrow navigation | ✅ | `WatchSubscreenBackToolbar`, `WatchDetailBackButton` |
| Multiple dive reminders (≤10) | ✅ | `DiveReminder`, `DiveReminderEngine` |
| Single/recurring, haptic, 3s overlay | ✅ | `DiveManager` reminder pipeline |
| Simultaneous aggregation (2 visible) | ✅ | `DiveReminderEngine` |
| Units IT/EN | ✅ **Improved** | Depth validation + photo sync + units picker localized @ `32f8d3e` |
| Watch build + tests | ✅ | Build OK; 161 tests pass |

**Note:** User max-depth alarm remains **off by default** (`depthAlarmEnabled = false`); hint added rather than changing default.

**Residual:** Some Watch sync/status strings outside the audit remediation scope may still use legacy Italian-as-key patterns — not re-audited exhaustively in this pass.

---

## L. Sync / Persistence Assessment (Phase 13)

| Store | Key / mechanism | Backward compat |
|---|---|---|
| `PlannerStore` | `dirdiving_ios_experimental_planner_state` | ✅ Custom decode for Ratio Deco fields |
| `EquipmentStore` | equipment profile + templates | ✅ `switchDepthMeters` backward-compatible decode |
| `DiveLogStore` (iOS) | Protected file + iCloud merge + tombstones | ✅ |
| `CloudSyncStore` | KVS with size guard | ✅ Round-trip test @ `32f8d3e` |
| Watch sync | Signed ACK, nonce replay cache | ✅ Tests |
| Unit settings | iOS ↔ Watch via application context | ✅ |

Conflict handling: LWW merge with generation tokens; merge conflict UI documented in `CloudSessionMergeTests`.

---

## M. Localization / Accessibility Assessment (Phase 14)

**Coverage:** Extensive IT/EN keys for planner modes, Ratio Deco, gases, checklist, PDF, tissue analytics, Watch reminders.

**Fixed @ `32f8d3e`:**
- Watch depth validation strings (`DiveManager.swift`)
- Watch photo sync status strings (`WatchSyncService.swift`)
- Dead `equipment.badge.field` keys removed
- Hardcoded `"Unità"` in Watch settings picker → localized

**Remaining gaps:**
- Full Dynamic Type / VoiceOver matrix QA **pending manual pass** (`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`)
- Exhaustive Watch string audit for legacy key patterns (low priority)

---

## N. Test Coverage Audit (Phase 15 / 15B)

### iOS — 443 tests, 13 skipped, 0 failures

**Strong coverage:** Bühlmann (20+ test classes), planner modes, MOD/PPO₂, CNS/OTU, checklist sync, PDF export, cloud merge, Ratio Deco (10+ tests), tissue analytics, **20 remediation tests** in `IOSMainAlgorithmMathRemediationTests`.

**Still missing / weak (non-blocking for internal TestFlight):**
- `BriefingPDFBuilder` dedicated tests (covered indirectly via export tests)
- `ManualDiveEditorView` UI/logic tests
- Ratio Deco MOD violation dedicated scenario (ceiling violation now tested)

### Watch — 161 tests, 13 skipped, 0 failures

**Strong coverage:** Dive lifecycle, reminders, depth safety haptics, photo store, sync codec, localization guard (`WatchMainUILocalizationTests` updated).

**Still missing / weak:**
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
| `RELEASE_CHECKLIST.md` | ✅ Updated for remediation pass |
| `RATIO_DECO_COMPARATIVE_HEURISTIC.md` | ✅ **Added** @ remediation |
| `IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md` | ✅ Remediation traceability |
| `README.md` / `INDEX.md` | ⚠️ Baseline cites `a6ccd8d`, not `32f8d3e` |
| `MAIN_BRANCH_FINAL_READINESS_REPORT.md` | ✅ Points to remediation report |

---

## P. Remediation status — prior findings

All items below were **open** at `e88c499` / `a6ccd8d` audit. Status after `32f8d3e`:

### P0 — Safety-critical
**None identified** — unchanged.

### P1 — Release-hard / misleading risk

| ID | Title | Status @ `32f8d3e` |
|---|---|---|
| **P1-001** | Documentation baseline stale | **Mostly fixed** — Ratio Deco in matrix; README/INDEX still cite `a6ccd8d` |
| **P1-002** | External Bühlmann validation incomplete | **OPEN** — process/QA |
| **P1-003** | Physical QA matrices pending | **OPEN** — process/QA |
| **P1-004** | Watch EN localization gaps | **FIXED** |
| **P1-005** | Ratio Deco incompatible-profile UX | **FIXED** — NOT validated plan + PDF warnings |

### P2 — Correctness / validation / data integrity

| ID | Title | Status @ `32f8d3e` |
|---|---|---|
| **P2-001** | Ratio Deco Balanced = Linear | **FIXED** |
| **P2-002** | No test for Ratio Deco ceiling violation | **FIXED** |
| **P2-003** | Dive Pack PDF omits Ratio Deco | **FIXED** |
| **P2-004** | Checklist missing gasText / switch depth | **FIXED** |
| **P2-005** | Checklist PDF uses raw items not migrated | **FIXED** |
| **P2-006** | Logbook tissue analytics simulated | **Documented** — UI footnote; future replay optional |
| **P2-007** | Bailout not in Bühlmann engine | **By design** — disclaimer retained |
| **P2-008** | NDL curve compartmentGroup static | **FIXED** — `depthBand` + chart note |
| **P2-009** | Watch depth alarm off by default | **Mitigated** — hint + 30 m preset |
| **P2-010** | Duplicate SubsurfaceExportService | **Documented** — divergence in headers |

### P3 — Documentation / polish

| ID | Title | Status @ `32f8d3e` |
|---|---|---|
| **P3-001** | Dead `equipment.badge.field` i18n keys | **FIXED** |
| **P3-002** | No dedicated Ratio Deco user doc | **FIXED** |
| **P3-003** | Sync export/import default asymmetry | **FIXED** — `.replace` default aligned |
| **P3-004** | Planning card informational only | **FIXED** |
| **P3-005** | Hardcoded `"Unità"` Watch settings | **FIXED** |
| **P3-006** | `RatioDecoWarning.noDecoGases` unused | **FIXED** |

### P4 — Nice-to-have

| ID | Title | Status @ `32f8d3e` |
|---|---|---|
| **P4-001** | 30 m preset for Watch depth alarm | **FIXED** |
| **P4-002** | Bühlmann comparison table full runtime | **FIXED** |
| **P4-003** | Weekly OTU tile visibility | **Already present** — no change needed |
| **P4-004** | EquipmentStore cloud round-trip test | **FIXED** |

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
| Ratio Deco ceiling violation | — | — | Warn | `isBuhlmannCompatible == false` | ✅ **New test** |
| O₂ 100% deco at 6 m | — | Allow | Allow | PPO₂ check | ✅ |
| CSV > size cap | — | — | — | Reject import | ✅ |
| Cloud oversize payload | — | — | — | Skip write | ✅ Test |
| Legacy checklist export | — | — | — | Migrated profile exportable | ✅ **New test** |
| Watch auto-start 0.9 m | — | — | — | No start | ✅ Test |
| Watch auto-start 1.1 m × 2 | — | — | — | Start | ✅ Test |

---

## R. Test Plan (Phase 19 — priority excerpts)

### Unit — P0/P1

| Feature | Input | Expected | Priority | Status |
|---|---|---|---|---|
| Base NDL block | 30 m / 50 min air | `basicNoDecoLimitExceeded`, calc disabled | P0 | ✅ |
| Deco 40 m cap | 41 m max | Validation fail | P0 | ✅ |
| Ratio Deco ceiling fail | Aggressive 2:1 trimix dive | `isBuhlmannCompatible == false` | P1 | ✅ **Fixed** |
| Bühlmann GF schedule | Fixture `gf-30-70.json` | Stops match golden | P1 | ✅ |
| MOD switch 30 m on EAN50 | Switch at 30 m | MOD issue | P1 | ✅ |
| Balanced ≠ Linear stops | Same dive, both modes | Different minute vectors | P2 | ✅ **Fixed** |

### Simulator — P1

| Feature | Steps | Pass criteria | Status |
|---|---|---|---|
| Ratio Deco comparison | Technical dive → Comparison tab | Overlay chart + TTS delta + disclaimer | Manual pending |
| PDF Ratio Deco | Export plan with Ratio Deco selected | PDF generates; disclaimer section | ✅ Automated |
| Dive Pack Ratio Deco | Export dive pack with Ratio Deco | Ratio section present | ✅ Automated |
| Checklist sync | Export planner gas → checklist | No duplicates; roles preserved | ✅ Automated |
| Watch manual start | Tap MANUAL START on surface | Dive active; reminders fire from start | Manual pending |

### Physical — P1/P2 (all PENDING)

| Feature | Devices | Pass criteria |
|---|---|---|
| Watch ↔ iOS sync | Paired iPhone + Watch | Dive transfers; units sync |
| iCloud planner state | Two iOS devices | Ratio Deco preset survives |
| Subsurface CSV round-trip | Real file | Import → export → re-import |
| Watch photo transfer | iPhone sends photo | Visible on Watch pre-dive |
| Depth alarm @ 30 m | Watch enabled alarm | Haptic/message at threshold |
| External Bühlmann cross-check | Reference tools | Fixture campaign sign-off |

### Localization — P2

| Check | Pass criteria | Status |
|---|---|---|
| EN Watch depth error | English UI, trigger validation error → English text | ✅ Fixed; manual spot-check pending |
| IT Ratio Deco disclaimer | Italian UI → Italian disclaimer in results + PDF | Manual pending |

---

## S. Prioritized Roadmap

### 1. Must fix before compile/use
**None** — builds and tests pass @ `32f8d3e`.

### 2. Must fix before internal TestFlight
- **Optional:** Update README/INDEX baseline to `32f8d3e` (cosmetic)
- **Done:** Watch EN localization, Ratio Deco tests/UX, checklist/PDF fixes

### 3. Must fix before external TestFlight
- P1-002 External Bühlmann validation campaign (partial sign-off minimum)
- P1-003 Physical QA matrices (iOS + paired Watch)
- Manual simulator spot-checks for Ratio Deco comparison UI

### 4. Must fix before App Store
- Full external validation sign-off
- Complete accessibility QA matrix
- Legal/disclaimer review with Ratio Deco PDF text
- Physical evidence packs per `MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`

### 5. Post-release improvements
- P2-006 Logbook tissue replay from recorded samples
- P2-010 Subsurface export consolidation (optional)
- Watch alarm E2E integration tests
- `ManualDiveEditorView` automated tests

---

## T. Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Yes** for Bühlmann reference path (94%). Ratio Deco is intentionally **not** a decompression model. |
| **Are Base/Deco/Technical modes real?** | **Yes** — distinct projection, validation, and presentation; engine-backed NDL/40 m gates. |
| **Is Ratio Deco safely comparative?** | **Yes** — disclaimer, validator, NOT validated plan UX, comparison UI, PDF coverage (92%). |
| **Is Bühlmann truthful?** | **Yes** as non-certified ZHL-16C reference; external campaign still pending for published cross-check. |
| **Are tissue/narcosis charts truthful?** | **Planner: yes.** **Logbook: simulated approximation** — labeled in UI. |
| **Are CNS/OTU correct?** | **Yes** per NOAA/Lambertsen reference models integrated in planner (90%). |
| **Is checklist operationally ready?** | **Yes** for DIR workflow (95%); gasText/switch depth complete. |
| **Are PDFs/share ready?** | **Yes** for core flows including Dive Pack Ratio Deco (94%). |
| **Are Watch reminders/start dive ready?** | **Yes** for core functionality (90%); EN audit strings fixed. |
| **Is sync/data ready?** | **Yes** at code level (88%); physical iCloud/paired QA pending. |
| **Ready for internal TestFlight?** | **Yes** — non-physical remediation complete. |
| **Ready for external TestFlight?** | **Not yet** — external validation + device QA blockers. |
| **Ready for App Store?** | **Not yet**. |
| **What blocks 100% readiness?** | External Bühlmann validation, physical QA evidence, accessibility manual matrix, logbook tissue simulation (by design), minor doc baseline commit refs. |

---

## Audit metadata

| Item | Value |
|---|---|
| Auditor mode | Static code review + automated build/test |
| Files modified during audit | **This report only** (`Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`) |
| Application code modified | **None** |
| Commits / pushes | **None** |
| iOS tests | 443 passed, 13 skipped |
| Watch tests | 161 passed, 13 skipped |
| Total automated tests | **604** passed, 26 skipped |
| Experimental branches touched | **None** |
| Remediation reference | `32f8d3e` — [`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md) |

---

*End of audit report @ `32f8d3e` (post-remediation re-run).*
