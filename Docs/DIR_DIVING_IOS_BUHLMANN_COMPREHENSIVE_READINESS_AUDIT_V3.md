# DIR Diving iOS Bühlmann Comprehensive Readiness Audit — V3

Date: 2026-06-07  
Repository: `https://github.com/egopfe/DirDiving-App.git`  
Audited branch: `main`  
Audited HEAD: `a4b99e6` (`a4b99e6c…`)  
HEAD subject: `Complete iOS MAIN post-audit non-physical readiness fixes.`  
Scope: iOS Companion MAIN — Bühlmann planner + extension areas (Ratio Deco, gas roles, MOD, tissue/narcosis analytics, checklist sync, manual dive, PDF, units)  
Execution mode: macOS static analysis + `xcodegen` / `xcodebuild` validation on this host  

**Source command:** Google Drive `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md` (extends base Bühlmann completeness audit with Phases 2B–9B).

---

## Executive Verdict

Status: **Almost ready (non-certified reference)**

MAIN @ `a4b99e6` delivers a coherent Bühlmann ZH-L16C reference planner with multigas tissue loading, Ratio Deco as a **comparative heuristic only**, tissue/narcosis analytics on planned profiles, checklist↔planner gas sync, manual dive entry, PDF export, and centralized unit conversion. macOS build and **469/469** iOS algorithm tests (13 skipped) pass on iPhone 17 Pro simulator.

**Not ready for:** App Store certification claims, external Bühlmann validation sign-off, or physical/device QA without recorded evidence.

**Recommended posture:**

| Gate | Verdict |
| --- | --- |
| Internal algorithm / code review | **Almost ready** — build + tests green @ `a4b99e6` |
| Internal TestFlight planning | **Conditional** — fix or document remaining P2/P3 gaps below |
| External TestFlight / RC | **Not yet** — physical QA + external math comparison pending |
| Certified decompression claim | **Never** — remain non-certified reference-only |

Actions taken in this audit pass:

- Created this report only (read-only audit).
- No Swift, UI, localization, or test code modified.
- No commit or push performed.

---

## Repository State (Pre-flight)

| Check | Result |
| --- | --- |
| Branch | `main` |
| Upstream | `origin/main` (0 ahead / 0 behind) |
| HEAD | `a4b99e6` |
| Working tree | Clean |
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build (iPhone 17 Pro sim) | **PASS** |
| `DIRDiving iOS Algorithm Tests` | **PASS** — 469 executed, 13 skipped, 0 failures |

---

## Phase 2B — Ratio Deco Readiness Audit

### Verified

| Item | Evidence | Status |
| --- | --- | --- |
| `RatioDecoPlanner` | `iOSApp/Services/RatioDecoPlanner.swift` — presets, stop distribution, gas assignment, depth profile | OK |
| `RatioDecoValidator` | `iOSApp/Services/RatioDecoValidator.swift` — ceiling replay vs Bühlmann tissue after bottom | OK |
| Comparison mode | `PlannerDecompressionMethod.comparison`; UI in `RatioDecoPlannerViews.swift` | OK |
| Overlay chart | `RatioDecoPlannerViews` overlay card (`planner.ratio_deco.overlay.title`) | OK |
| Presets 1:1 / 2:1 / Custom | `RatioDecoModels.swift`; save/delete custom presets in UI | OK |
| Bühlmann validation layer | Validator marks incompatible schedules; does not alter Bühlmann engine | OK |
| Export PDF | `BriefingPDFBuilder`, `PlannerPDFBuilder`, `DivePackPDFBuilder` Ratio Deco sections | OK |
| Localization | EN/IT keys under `planner.ratio_deco.*`, `planner.deco_method.*` | OK |
| Bailout excluded from Ratio schedule | `RatioDecoPlannerTests.testBailoutIsNotUsedInPlannedSchedule` | OK |
| MOD violation surfaced | `IOSMainAlgorithmPostAuditTests.testRatioDecoMODViolationMarksIncompatibleAndDoesNotAlterBuhlmann` | OK |

### Gaps

- Ratio Deco remains **heuristic / comparative only** — not a decompression algorithm; must stay labeled in UI/PDF (currently OK).
- No independent external Ratio Deco reference comparison.
- Simulator visual QA for overlay chart and comparison tables not executed in this pass.

**Ratio Deco readiness: 88%**

**Ratio Deco verdict:** **Almost ready** for internal reference comparison; not suitable as primary decompression authority.

---

## Phase 3B — Gas Role Audit

### Verified

| Role | Expected behavior | Evidence | Status |
| --- | --- | --- | --- |
| Back gas | Surface → first switch / bottom phase | `BuhlmannPlanner.makeRequest` bottom gas; `PlannerGasSchedule.bottomCylinder` | OK |
| Travel | Configured depth ranges on descent/ascent | `BuhlmannEngine` travel switch points; `PlannerGasSchedule.travelCylinders` | OK |
| Decompression | Ascent / deco stops only | `decoGases` in engine; deco cylinders filtered in schedule | OK |
| Bailout | Emergency only; excluded from Bühlmann schedule | `BuhlmannPlanner.swift:257-287`; UI hints; `BailoutGasTests` | OK |

| Integration | Status |
| --- | --- |
| Planner UI (`PlannerCylinderGasEditorView`, role picker) | OK |
| Bühlmann engine (`travelGases`, `decoGases`; no bailout slot) | OK |
| Gas ledger (`ScheduleGasConsumptionService`, standby/bailout flags) | OK |
| PDF (`PlannerPDFBuilder`, bailout hint in `DivePackPDFBuilder`) | OK |
| Checklist (`ChecklistPlannerSyncMapper`, role inference from titles) | OK |

### Gaps

- Travel cylinders may appear as standby in consumption ledger messaging — documented, acceptable.
- Checklist role inference from free-text titles can mis-classify edge cases; user can override in sync sheet.

**Gas Role readiness: 90%**

**Gas Role verdict:** **Almost ready** — roles are enforced in engine and UI with explicit bailout exclusion.

---

## Phase 3C — MOD / Dalton Audit

### Verified

| Item | Evidence | Status |
| --- | --- | --- |
| MOD auto update on O₂ / PPO₂ change | `PlannerCylinderGasEditorView` + `updateSwitchDepthAfterGasOrPPO2Change` | OK |
| PPO₂ step 0.1 | `PlannerGasEditingSupport.ppo2Step = 0.1`; picker stride | OK |
| No hidden 0.05 PPO₂ increments | `PlannerGasEditingSupportTests.testPPO2IncrementsByTenthOnly` | OK |
| Air lock (21/0) | `PlannerGasEditingSupportTests.testAirLocksComposition` | OK |
| EAN O₂-only edit | `GasMix.canEditOxygen`; EAN tests | OK |
| Trimix O₂+He edit | `GasMix.canEditHelium`; trimix tests | OK |
| O₂ 100% | `testPureOxygenLocksComposition` | OK |
| Displayed MOD == used MOD | Shared `PlannerMODValidator.modMeters` / `GasMixValidator` | OK |
| Planner uses same MOD | `PlannerMODValidator.validatePlannerCylinders` | OK |
| Ratio Deco uses same MOD | `RatioDecoValidator` + planner gas assignment | OK |
| Bühlmann uses same MOD | `BuhlmannPlanPreflightValidator`, engine gas-switch validation | OK |

Note: **0.05 m** tolerances appear for **depth/switch** comparisons only (not PPO₂ stepping).

### Gaps

- Dalton's law display is implicit via PPN₂/PPO₂/END — no separate Dalton UI panel (not required by command).
- Imperial MOD display relies on `Formatters.depth` — covered by unit tests but not full simulator matrix.

**MOD readiness: 94%**

**MOD verdict:** **Ready** for internal reference MOD/PPO₂ consistency across planner, Bühlmann, and Ratio Deco layers.

---

## Phase 4B — Tissue Loading Analytics Audit

### Verified

| Item | Evidence | Status |
| --- | --- | --- |
| 16 compartments | `BuhlmannTissueHistorySampler`; `BuhlmannTissueHistoryTests` | OK |
| Groups 1–4, 5–8, 9–12, 13–16 | `BuhlmannTissueHistory.swift:247-254`; chart grouping | OK |
| Timeline: runtime, depth, gas, PPO₂, ceiling | `TissueAnalyticsService.buildSamples`; `TissueAnalyticsTrace` | OK |
| No fake data (planner) | Replay from `DivePlanResult.tissueHistory` / engine segments | OK |
| No static chart (planner) | Primary CURVA BÜHLMANN from tissue history; NDL secondary only | OK |
| Planner integration | `TissueNarcosisAnalyticsView`; planner tab | OK |
| Logbook integration | `TissueAnalyticsService.buildFromSession` | **Partial** |

### Gaps

- **Logbook tissue is simulated**, not full Bühlmann replay — documented in [`LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md`](LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md); UI footnote + subtitle distinguish estimate vs planner replay.
- Logbook path uses assumed gas from label, not logged switch history.

**Tissue readiness: 82%**

**Tissue verdict:** **Almost ready** for planner; **partial** for logbook until replay future work lands.

---

## Phase 4C — Narcotic Loading Audit

### Verified

| Item | Evidence | Status |
| --- | --- | --- |
| PPN₂ | `TissueAnalyticsService` samples; chart in `TissueAnalyticsCharts.swift` | OK |
| END | `NarcosisAnalyticsSupport.endMeters(fromPPN2Bar:)` | OK |
| Active gas integration | Segment gas from planner replay / session assumed gas | OK |
| Runtime integration | Timeline samples tied to profile elapsed time | OK |
| Planner simulated profile | `source: .planned` trace from Bühlmann plan | OK |
| Logbook recorded profile | `buildFromSession` with depth samples | **Partial** (simulated tissue, not Bühlmann replay) |

Tests: `TissueAnalyticsServiceTests.testPPN2MatchesActiveGasAndDepth`, `testENDDerivedFromPPN2`; `IOSMainAlgorithmAuditRemediationTests` END/EAD environment cases.

### Gaps

- Logbook narcosis inherits simulated tissue limitations.
- Oxygen narcotic toggle (`isOxygenNarcotic`) affects END in analysis but logbook assumes label-only gas.

**Narcosis readiness: 80%**

**Narcosis verdict:** **Almost ready** for planner reference; logbook remains informational estimate only.

---

## Phase 5B — Planner ↔ Checklist Audit

### Verified

| Direction | Mapping | Status |
| --- | --- | --- |
| Checklist → Planner | Back, travel, deco, bailout via `ChecklistPlannerSyncMapper.applyImport` | OK |
| Planner → Checklist | Export candidates + `applyExport` | OK |
| Duplicate prevention | Fingerprint matching; skip/replace actions | OK |
| Stable IDs | Checklist item UUID; planner cylinder UUID preserved on replace | OK |
| Persistence | Equipment profile / planner store persistence | OK |

Tests: `ChecklistPlannerSyncMapperTests` (8 cases) — tank pressure, mix, role inference, duplicate skip/replace, export line switch depth.

UI: `ChecklistPlannerSyncSheet.swift`, `EquipmentChecklistGasSection.swift`.

### Gaps

- Manual UI walkthrough on device not recorded in this pass.
- Checklist PDF switch depth format hardcodes `%d m` in one code path — imperial checklist PDF edge case.

**Planner Checklist readiness: 88%**

**Checklist Sync verdict:** **Almost ready** — mapper logic and tests are solid; device QA pending.

---

## Phase 6B — Manual Dive Audit

### Verified

| Field | Evidence | Status |
| --- | --- | --- |
| Max / avg depth | `ManualDiveEditorView` + validation | OK |
| GPS start / end | Entry/exit coordinate fields → `GPSPoint` | OK |
| Dive profile | `ManualDiveSampleBuilder` synthetic samples | OK |
| Equipment | `equipmentUsed` on session | OK |
| Bar in / out | `entryPressureText` / `exitPressureText` + bar fields | OK |
| Deco notes | `decompressionNotes` | OK |
| CSV export | `DiveDetailView` ShareLink CSV | OK |
| Logbook integration | Manual sessions in logbook list/detail | OK |
| Tissue integration | Simulated via `TissueAnalyticsService.buildFromSession` | **Partial** |
| Narcosis integration | Same simulated path | **Partial** |

Tests: `ManualDiveEditorLogicTests` (8) — depth order, duration clamp, synthetic session, GPS, pressures.

### Gaps

- Synthetic profile is trapezoidal estimate, not user-drawn profile editor.
- No full Bühlmann replay from manual dive (same logbook limitation).

**Manual Dive readiness: 78%**

**Manual Dive verdict:** **Almost ready** for logbook entry and export; analytics remain simulated estimates.

---

## Phase 6C — PDF / Share Audit

### Verified

| Export | Content | Status |
| --- | --- | --- |
| Planner PDF | Gas plan, deco plan, MOD issues, environment | OK |
| Briefing PDF | Profile, ascent, disclaimer, Ratio Deco when selected | OK |
| Checklist PDF | YES/NO boxes, equipment lines, gas rows | OK |
| Dive pack | Combined planner + checklist + Ratio Deco | OK |
| Comparison / Ratio Deco | Sections in briefing/planner/dive pack builders | OK |

Share surfaces: `ShareSheetView` (`UIActivityViewController`) from `PlannerView`, `EquipmentView` — supports system share targets (Mail, AirDrop, Files, WhatsApp when installed). `ShareLink` on dive detail CSV.

Tests: `PDFExportServiceTests` (7), `BriefingPDFBuilderTests` (3).

### Gaps

- No automated test per share destination (WhatsApp/Mail/AirDrop) — relies on iOS share sheet.
- Physical share QA not executed.
- Briefing PDF pagination for long Ratio Deco blocks improved (`ensureSpace(160)`) — not visually verified on device.

**PDF readiness: 90%**

**PDF verdict:** **Almost ready** — generation and content coverage strong; share-channel QA manual.

---

## Phase 7B — Unit Conversion Audit

### Verified

| Conversion | Central helper | Surfaces |
| --- | --- | --- |
| m ↔ ft | `IOSUnitConversions`, `Formatters.depth` | Planner, charts, tissue/narcosis views, manual dive, PDF |
| bar ↔ psi | `IOSUnitConversions`, `PlannerGasEditingSupport.convertPressure` | Planner cylinders, manual dive pressures |

Tests: `BuhlmannPressureModelTests`, `PlannerGasEditingSupportTests`, `ManualDiveEditorLogicTests`, `IOSMainAlgorithmAuditRemediationTests` (pressure display).

### Gaps

- Checklist PDF switch-depth string uses metric `%d m` in one formatter path regardless of user units.
- CSV export depth columns — verify imperial preference on device (code paths exist via formatters; not re-tested in this pass).

**Unit Conversion readiness: 92%**

**Unit Conversion verdict:** **Almost ready** — core conversions centralized; minor PDF/checklist imperial polish remains.

---

## Phase 9B — Release Hard Matrix

Percentages reflect **internal reference readiness** (code + automated tests + docs). They do **not** include physical QA, external validation, or App Store gates.

| Feature | Readiness | Blockers / notes |
| --- | ---: | --- |
| Bühlmann | **92%** | External validation campaign pending; GF equality policy documented conservative |
| Ratio Deco | **88%** | Heuristic only; no external reference |
| Gas Roles | **90%** | Bailout exclusion documented |
| MOD/PPO2 | **94%** | Strong cross-layer consistency |
| Tissue Loading | **82%** | Logbook simulated replay |
| Narcosis | **80%** | Logbook simulated replay |
| Checklist Sync | **88%** | Device UI QA pending |
| Manual Dive | **78%** | Synthetic profile; simulated analytics |
| PDF Export | **90%** | Share destinations not device-tested |
| Unit Conversion | **92%** | Minor checklist PDF imperial gap |

**Overall (mean of matrix): 88%**

---

## Final Verdict Extensions (Mandatory)

| Area | Verdict |
| --- | --- |
| Ratio Deco | **Almost ready** — comparative heuristic with Bühlmann validation layer; not primary deco authority |
| Tissue | **Almost ready** (planner) / **Partial** (logbook simulated) |
| Narcosis | **Almost ready** (planner) / **Partial** (logbook simulated) |
| Gas Role | **Almost ready** — engine + UI + sync aligned; bailout explicitly excluded |
| Checklist Sync | **Almost ready** — mapper tested; manual QA pending |
| Manual Dive | **Almost ready** for entry/export; analytics estimate only |
| PDF | **Almost ready** — builders tested; share sheet QA manual |
| Unit Conversion | **Almost ready** — centralized; small PDF imperial polish |

### Mandatory summary table

| Feature | Readiness |
| --- | ---: |
| Bühlmann | 92% |
| Ratio Deco | 88% |
| Gas Roles | 90% |
| MOD/PPO2 | 94% |
| Tissue Loading | 82% |
| Narcosis | 80% |
| Checklist Sync | 88% |
| Manual Dive | 78% |
| PDF Export | 90% |
| Unit Conversion | 92% |
| **Overall** | **88%** |

---

## Bühlmann Core (Base Audit Summary @ `a4b99e6`)

Inherited from comprehensive base audit; re-validated on current HEAD:

- ZH-L16C N₂+He engine, GF stops, tissue-state NDL, environment model, CNS/OTU reference estimates — **coherent**.
- PIANO DI RISALITA uses post-bottom ascent briefing rows in engine order (`PlannerAscentTableBuilder.ascentBriefingTravelRows`) — prior chronological-order P2 ** remediated**.
- Full-plan CNS dashboard tile reflects elevated exposure (`fullPlanCNSWarningActive`) — prior P2 **remediated**.
- macOS tests: **469 pass** (13 skipped) vs 355 static count in prior Windows-only audit.

Remaining Bühlmann P3 items (non-blocking):

| ID | Finding | Status |
| --- | --- | --- |
| IOS-BUH-P3-001 | GF Low == GF High rejected (conservative) | Open — document or adjust policy |
| IOS-BUH-P3-002 | Briefing `TTS/TTR` copy vs TTS-only value | Open — copy polish |
| IOS-BUH-P3-003 | Tissue chart sea-level display fallback | Low risk — prefer fail-empty |
| IOS-BUH-P3-004 | Doc baselines drift vs HEAD | Partially updated @ post-audit pass; this report sets `a4b99e6` |
| P1 external | External Bühlmann validation | **PENDING** — see external validation plan |

---

## Risk Matrix (V3 Extension)

### P0 — Safety-critical

None found in this pass (build + tests green; fail-closed validators intact).

### P1 — Major correctness

None found in automated suite @ `a4b99e6`.

### P2 — Before stronger TestFlight claims

| ID | Area | Finding | Recommendation |
| --- | --- | --- | --- |
| V3-P2-001 | Logbook tissue/narcosis | Simulated replay, not Bühlmann | Keep labeling; implement replay per future-work doc or defer explicitly |
| V3-P2-002 | Share/PDF | No device evidence for Mail/AirDrop/WhatsApp | Run manual matrix with saved PDFs |
| V3-P2-003 | External validation | No independent deco table comparison | Execute `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` |

### P3 — Polish

| ID | Area | Finding |
| --- | --- | --- |
| V3-P3-001 | Checklist PDF | Switch depth format may show meters when user prefers feet |
| V3-P3-002 | Manual dive | Trapezoidal synthetic profile only |
| V3-P3-003 | Ratio Deco | Overlay/comparison layout needs simulator screenshots |

---

## Related Documents

- [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) — prior comprehensive @ `93d6324`
- [`IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) — math audit baseline
- [`IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_POST_AUDIT_FIX_REPORT_CURRENT.md) — remediation @ `a4b99e6`
- [`LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md`](LOGBOOK_TISSUE_REPLAY_FUTURE_WORK.md) — logbook tissue gap
- [`DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`](DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md) — external campaign
- [`MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md`](MAIN_PHYSICAL_EXTERNAL_QA_CHECKLIST.md) — physical gates (**PENDING**)

---

## Final Readiness Statement

DIR DIVING iOS MAIN @ `a4b99e6` is a **strong non-certified Bühlmann reference implementation** with extension features at **~88% overall internal readiness**. It is **almost ready** for continued internal validation and conditional TestFlight planning after P2 share/external gaps are closed or explicitly deferred in release notes.

**Do not claim:** certified decompression, App Store readiness, or completion of physical/external QA without evidence from the checklists above.

*Report generated by V3 comprehensive readiness audit command — read-only, no code changes.*
