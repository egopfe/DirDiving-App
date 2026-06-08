# DIR Diving iOS Bühlmann Comprehensive Readiness Audit — CCR Updated (Current)

**Audit date:** 2026-06-08  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Audited branch:** `main`  
**Audited HEAD:** `cc4d783` (`cc4d783dae48ce9950e09f9f3c815e14b1500568`)  
**HEAD subject:** `fix(ios): remediate CCR math audit findings on main.`  
**Scope:** iOS Companion MAIN (`DIRDiving iOS`) — Bühlmann planner, CCR / Rebreather reference planner, Ratio Deco, gas roles, MOD/PPO₂, tissue/narcosis analytics, checklist sync, manual dive, PDF/CSV export, units, cloud/sync  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Source command:** `commands_for_cursor/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`

**Integrated context (read, not re-executed):**

| Document | Status | Role in this audit |
|---|---|---|
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md` | Present @ `a4b99e6` | Prior OC-focused comprehensive baseline |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Present @ `b9f54a3` | Pre-remediation math baseline (87%) |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Present @ `cc4d783` | Post-remediation math deltas |
| `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` | Present | External CCR validation slots (pending) |
| `Docs/DIR_Diving_Planner_Tabs_Implementation_Report.md` | Present | Planner tab implementation evidence |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Present | CSV policy / round-trip notes |
| `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` | Present | Internal Bühlmann verification notes |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md` | **Missing** (prior snapshot) | Command references optional prior report — not found; this file supersedes |

**Actions in this audit pass:**

- Created this report only (read-only audit).
- No Swift, UI, localization, algorithm, sync, or test production code modified.
- No commit or push performed.

---

## A. Executive Summary

### Overall verdict

Status: **Almost ready (non-certified reference)**

MAIN @ `cc4d783` delivers a coherent **Bühlmann ZH-L16C + GF** open-circuit planner (Base / Deco / Technical), an **isolated CCR / Rebreather reference planner** (setpoint-inspired gas, dedicated engine/validator, heuristic bailout scenarios), **Ratio Deco as comparative heuristic only**, tissue/narcosis analytics with explicit source footnotes (including `.ccrPlanned`), checklist↔planner gas sync with CCR roles, manual dive entry, PDF/CSV export, and centralized unit conversion. macOS build and **526/526** iOS algorithm tests (13 skipped) pass on iPhone 17 simulator.

Recent CCR math remediation (`cc4d783`) closed all code-fixable P1/P2 items from the math audit (`b9f54a3`): tissue trace alignment, water vapor in inspired gas, imperial CCR switch depth, Ratio Deco `.ccr` guard, export gates, checklist CCR roles, PDF localization, and persistence round-trip tests.

**Not ready for:** certified decompression claims, external Bühlmann/CCR validation sign-off, iCloud two-device QA, paired Watch physical QA, or App Store marketing without legal review.

### Readiness estimates

| Area | Readiness | Confidence | Primary blockers |
|---:|---:|---|---|
| **Overall** | **91%** | High on OC + automated tests; medium on CCR external parity | External validation + physical QA |
| **Bühlmann (OC core)** | **94%** | High | External third-party profile comparison pending |
| **Planner (Base/Deco/Technical)** | **92%** | High | Visual QA on mode projection edge cases |
| **CCR / Rebreather** | **88%** | Medium-high post-remediation | Bailout heuristic not engine-simulated; external CCR profiles |
| **Ratio Deco** | **86%** | High on guardrails | Heuristic by design; no external reference |
| **MOD / PPO₂ / Dalton** | **93%** | High | CCR setpoint vs tank-pressure display discipline |
| **Tissue loading** | **90%** | High post `CCRTissueHistorySampler` | Logbook simulated segments still footnoted |
| **Narcosis / END / PPN₂** | **88%** | Medium-high | CCR density estimator simplified |
| **Checklist sync** | **84%** | Medium | Free-text role inference edge cases |
| **Manual dive / logbook** | **88%** | Medium-high | CCR manual fields validated; no physical dive QA |
| **PDF / share export** | **90%** | High | CCR Dive Pack PDF less exercised than OC |
| **Unit conversion** | **92%** | High | Imperial CCR switch depth fixed in remediation |
| **Cloud / sync integrity** | **86%** | Medium | iCloud two-device QA not executed |
| **Automated test coverage** | **89%** | High count; gaps in E2E/visual | 526 XCTest; no Subsurface external round-trip |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **Almost ready** — build + 526 tests green @ `cc4d783` |
| Internal TestFlight (algorithm) | **Conditional pass** — document CCR reference-only + bailout heuristic |
| External TestFlight / RC | **Not yet** — external math + iCloud + Watch physical QA pending |
| App Store (algorithm scope) | **Not yet** — same + legal/marketing disclaimer audit |
| Certified decompression claim | **Never** — remain non-certified reference-only |

### Critical blockers (P0)

**None identified** in static review or automated tests at `cc4d783`.

### TestFlight blockers

- External Bühlmann profile comparison not signed off (`Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` — pending)
- External CCR profile comparison not executed (`Docs/CCR_REBREATHER_VALIDATION_PLAN.md` — all slots empty)
- iCloud two-device merge QA not recorded (`Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md` — manual)
- Paired Watch/iPhone physical sync QA not recorded
- CCR bailout remains **heuristic SAC estimate**, not Bühlmann OC switch simulation (labeled, but not externally validated)

### App Store blockers

- All TestFlight blockers above
- App Store legal / marketing language review for non-certified + CCR reference-only posture
- Screenshot and review-notes alignment with `Docs/SAFETY_DISCLAIMER.md` and `Docs/TESTFLIGHT_REVIEW_NOTES.md`

---

## B. Scope Confirmation

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `cc4d783` |
| Working tree at audit start | Clean |
| iOS target | `DIRDiving iOS` only (Watch build referenced, not re-audited in depth) |
| Experimental exclusions | `project.yml` excludes Exploration, Buddy experimental, apnea/snorkeling experimental surfaces |
| `xcodegen generate` | **PASS** |
| `DIRDiving iOS` build | **PASS** — iPhone 17 simulator (OS 26.5) |
| `DIRDiving iOS Algorithm Tests` | **PASS** — **526 executed**, 13 skipped, **0 failures** |

### Build / test commands (exact)

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

### Docs found / missing

| Document | Status |
|---|---|
| `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md` | Found |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` | Found |
| `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md` | Found |
| `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` | Found |
| `Docs/DIR_Diving_Planner_Tabs_Implementation_Report.md` | Found |
| `Docs/SUBSURFACE_CSV_ROUNDTRIP.md` | Found |
| `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` | Found |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md` | **Missing** — noted only |

---

## C. Architecture Inventory

### iOS algorithm stack (implemented)

| Layer | Primary files | Status |
|---|---|---|
| Planner modes | `PlannerModePolicy.swift`, `PlannerModeLimits.swift`, `PlannerService.swift` | Implemented |
| Bühlmann engine | `BuhlmannEngine.swift`, `BuhlmannPlanner.swift`, `BuhlmannModels.swift` | Implemented — OC only |
| GF / M-values | `GradientFactorInterpolator.swift`, compartment constants in engine | Implemented |
| Environment | `PlannerEnvironment.swift` (altitude, water type, salinity) | Implemented |
| Gas / MOD | `PlannerMODValidator.swift`, `PlannerGasEditingSupport.swift`, `GasPlan.swift` | Implemented |
| Ratio Deco | `RatioDecoPlanner.swift`, `RatioDecoValidator.swift`, `RatioDecoModels.swift` | Implemented — heuristic |
| CCR module | `iOSApp/Services/CCR/*.swift` (7 files) | Implemented — isolated path |
| Tissue analytics | `TissueAnalyticsService.swift`, `CCRTissueHistorySampler.swift` | Implemented |
| Narcosis | `NarcoticLoadingService.swift`, `CCRGasDensityEstimator.swift` | Implemented |
| CNS / OTU | `OxygenExposureService.swift`, exposure models | Implemented |
| Checklist sync | `ChecklistPlannerSyncMapper.swift` | Implemented — CCR export path |
| Manual dive | `ManualDiveEditorView.swift`, `DiveImportService.swift` | Implemented |
| PDF export | `PlannerPDFBuilder.swift`, `BriefingPDFBuilder.swift`, `DivePackPDFBuilder.swift` | Implemented |
| CSV | Subsurface export paths in import/export services | Implemented |
| Units | `UnitConversionService.swift`, display formatters | Implemented |
| Cloud | `CloudSyncService.swift`, KVS payload caps | Implemented — E2E QA pending |

### CCR module files inspected

| File | Role |
|---|---|
| `CCRPlannerEngine.swift` | Setpoint-segmented deco simulation |
| `CCRInspiredGasModel.swift` | Inspired gas from setpoint + diluent (water vapor corrected post-remediation) |
| `CCRTissueHistorySampler.swift` | Engine-aligned tissue trace for charts |
| `CCRBailoutScenarioCalculator.swift` | Heuristic SAC bailout estimates |
| `CCRPlanValidator.swift` | Setpoint / diluent / MOD preflight |
| `CCRPlannerService.swift` | Planner façade; mode isolation |
| `CCRGasDensityEstimator.swift` | Loop density for narcosis display |

### Unreachable / quarantined

| Item | Status |
|---|---|
| `runtimeSegments` on CCR plans | **Quarantined** — documented not for production replay; test asserts guard |
| Watch CCR runtime | **Absent by design** — Watch has no CCR loop controller |
| Experimental planner branches | Excluded from `DIRDiving iOS` target |

### Test coverage snapshot

| Metric | Value |
|---|---|
| iOS algorithm test Swift files | **75** |
| Files touching Bühlmann/Planner/MOD/etc. | **59** (approx., by keyword) |
| CCR-focused test files | **2** — `CCRPlannerTests.swift`, `CCRMathRemediationTests.swift` |
| CCR test methods | **27** (11 + 16) |
| Executed @ audit | **526 passed**, 13 skipped |

---

## D. Bühlmann Core Audit

### Verified

| Item | Evidence | Status |
|---|---|---|
| ZHL-16C, 16 compartments | `BuhlmannEngine` compartment tables; tests | OK |
| N₂ and He | Dual inert gas loading; trimix tests | OK |
| GF low/high interpolation | `GradientFactorInterpolator`; GF 30/70 vs 50/80 tests | OK |
| Surface / altitude / water type | `PlannerEnvironment`; altitude profile tests | OK |
| Ascent/descent segments | Schreiner integration in engine | OK |
| Stop rounding / first stop | Engine stop builder; golden-style tests | OK |
| Ceiling / controlling compartment | Engine outputs; tissue analytics reads schedule | OK |
| NDL preview | Base/Deco projections; NDL tests | OK |
| Invalid gas preflight | Hypoxic / MOD violations rejected | OK |
| Bailout excluded from schedule | `BuhlmannPlanner` bailout filter; `BailoutGasTests` | OK |
| OC core unchanged by CCR | CCR uses separate `CCRPlannerEngine` | OK |

### Gaps

- External Bühlmann third-party comparison **not executed** — internal tests strong, external sign-off pending
- Some golden fixtures documented in `DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md` — not all re-run in this pass

**Bühlmann readiness: 94%**  
**Mathematical robustness: 92%** (internal) / **60%** (external validation status — pending)  
**Blocking issues:** None code-level P0; external validation is process blocker only.

---

## E. Planner Base / Deco / Technical Audit

### Base

| Check | Status | Evidence |
|---|---|---|
| One active gas | OK | `PlannerModePolicy.base` limits |
| Hidden technical gases ignored | OK | Mode-projected `GasPlan` |
| NDL preview uses Base projection | OK | Planner NDL path |
| Full technical schedule hidden | OK | UI gating |
| Deco obligation guidance | OK | Mode upgrade hints |

### Deco

| Check | Status | Evidence |
|---|---|---|
| Bottom + max one deco gas | OK | `PlannerModeLimits` |
| No bailout in active projection | OK | Engine input filter |
| One gas switch max | OK | Deco mode policy + tests |
| Deco projection in export | OK | PDF/CSV use projected plan |

### Technical

| Check | Status | Evidence |
|---|---|---|
| Travel + multiple deco + bailout | OK | Full `BuhlmannPlanner.makeRequest` |
| Manual GF low/high | OK | Planner GF controls |
| Full schedule + tissue charts | OK | Technical UI surfaces |
| Bailout separation in ledger | OK | Standby flags |

### CCR mode isolation

| Check | Status |
|---|---|
| `PlannerMode.ccr` separate from OC modes | OK |
| OC Bühlmann not fed CCR setpoint directly | OK |
| Ratio Deco rejects `.ccr` | OK — post-remediation API guard |

**Planner mode readiness: 92%**  
**Mode projection correctness: 93%**  
**Mode-specific export readiness: 90%** (CCR Dive Pack PDF less covered than OC)

---

## F. CCR / Rebreather Audit

### Implementation status: **Implemented (reference planner, not loop controller)**

| Concept | Status | Notes |
|---|---|---|
| Setpoint low/high | Implemented | PPO₂ bar, not tank pressure |
| Diluent gas | Implemented | `GasRole.ccrDiluent` |
| Bailout OC gas | Implemented | `GasRole.ccrBailout`; heuristic calculator |
| Inspired gas model | Implemented | Water vapor correction @ remediation |
| Deco schedule | Implemented | `CCRPlannerEngine` |
| Tissue trace for charts | Implemented | `CCRTissueHistorySampler` aligned with engine |
| Bailout scenarios | **Heuristic** | SAC-based; UI/PDF labeled honestly |
| Live loop PPO₂ monitoring | **Not implemented** | Correct — out of scope |
| Watch CCR runtime | **Absent** | Safe |

### Verified post-remediation

| ID | Fix | Status |
|---|---|---|
| P1-001 | Tissue trace vs engine | Closed |
| P1-004 | Water vapor in inspired gas | Closed |
| P1-005 | Imperial CCR switch depth | Closed |
| P1-003 | Bailout labeling | Closed — heuristic disclosed |
| P2-* | Export, PDF, checklist, persistence | Closed per remediation report |

### Remaining gaps

| Gap | Severity | Notes |
|---|---|---|
| Bailout not Bühlmann OC switch simulation | MEDIUM | By design heuristic; not falsely labeled |
| `runtimeSegments` quarantined, not implemented | LOW | Documented |
| External CCR profile validation | HIGH (process) | All `CCR_REBREATHER_VALIDATION_PLAN` slots empty |
| CCR Dive Pack PDF depth | LOW | Less test coverage than OC briefing |
| No manufacturer procedure review | HIGH (process) | Companion app scope |

**CCR readiness: 88%**  
**CCR setpoint: 92%** | **Diluent: 90%** | **Bailout: 72%** (heuristic) | **Tissue: 90%**

**Is CCR safe to expose?** **Yes, as reference-only planner** with current disclaimers — **not** as certified CCR controller or live monitoring tool.

---

## G. Ratio Deco Audit

### Verified

| Item | Status |
|---|---|
| `RatioDecoPlanner` / `RatioDecoValidator` | OK |
| Comparison mode vs Bühlmann | OK |
| Presets 1:1, 2:1, custom | OK |
| Overlay chart in UI | OK — not statically faked |
| MOD violation marks incompatible | OK |
| Bailout excluded from Ratio schedule | OK |
| PDF sections | OK |
| **`.ccr` mode rejected at API** | OK — post-remediation |

### Gaps

- Heuristic only — must stay labeled (currently OK in EN/IT)
- No external Ratio Deco reference comparison
- Simulator visual QA for overlay not executed in this pass

**Ratio Deco readiness: 86%**  
**Comparison readiness: 88%** | **Export readiness: 87%**

---

## H. Gas Role Audit

### Open circuit

| Role | Planner | Bühlmann | Ledger | PDF | Checklist |
|---|---|---|---|---|---|
| Back gas | OK | OK | OK | OK | OK |
| Travel | OK | OK | OK | OK | OK |
| Decompression | OK | OK | OK | OK | OK |
| Bailout (standby) | OK | Excluded | Standby flag | OK | OK |

### CCR-specific (post-remediation)

| Role | Status |
|---|---|
| `ccrDiluent` | OK — checklist sync via `applyCCRExport` |
| `ccrBailout` | OK |
| Setpoint (not a tank role) | OK — separate UI fields |
| Separation from OC back/deco | OK |

### Gaps

- Checklist role inference from free-text titles can mis-classify edge cases
- Travel as standby in consumption messaging — documented acceptable

**Gas Role readiness: 88%**  
**CCR Gas Role readiness: 86%**

---

## I. MOD / PPO₂ / Dalton / Switch Depth Audit

### Verified

| Item | Status |
|---|---|
| MOD auto-update on O₂ / PPO₂ change | OK |
| PPO₂ step 0.1 | OK |
| Switch depth clamp to MOD | OK — `PlannerMODValidator` |
| Hypoxic preflight | OK |
| CCR setpoint PPO₂ in bar (not psi tank units) | OK |
| Ratio Deco reuses MOD rules | OK |
| Imperial feet display for switch depth (CCR manual dive) | OK — fixed @ remediation |

### Gaps

- Dalton display optional — not blocking
- Visual QA on autoclamp edge cases (exactly-at-MOD switches) — manual matrix pending

**MOD/PPO₂ readiness: 93%**  
**Switch depth clamp: 91%**  
**CCR unit discipline: 92%**

---

## J. Tissue Loading Audit

### Verified

| Source | Model-backed | Evidence |
|---|---|---|
| Planned OC profile | Yes | Bühlmann engine replay |
| Planned CCR profile | Yes | `CCRTissueHistorySampler` + `.ccrPlanned` footnote |
| Logbook imported profile | Simulated segments | Footnoted in UI |
| Charts | Real trace data | Not static placeholders |
| Export | Tissue summary in PDF where claimed | OK |

### Gaps

- Logbook non-planner segments remain simulated (disclosed)
- Performance boundary tests for very long profiles — limited

**Tissue loading readiness: 90%**

---

## K. Narcotic Loading Audit

### Verified

| Item | Status |
|---|---|
| END / PPN₂ from planned gas | OK |
| CCR loop density estimator | OK — simplified model |
| Chart + export integration | OK |
| Source footnotes | OK |

### Gaps

- CCR narcosis uses estimator, not full loop physics
- No external END reference comparison

**Narcosis readiness: 88%**

---

## L. CNS / OTU Audit

### Verified

| Item | Status |
|---|---|
| NOAA CNS integration | OK |
| OTU (Lambertsen) | OK |
| CCR setpoint exposure path | OK |
| PDF labels unambiguous | OK post-remediation |
| Not presented as medical advice | Disclaimer present |

**CNS / OTU readiness: 91%**

---

## M. Planner ↔ Checklist Audit

### Verified

| Item | Status |
|---|---|
| OC gas sync | OK |
| CCR export (`applyCCRExport`) | OK post-remediation |
| Equipment template includes CCR items | OK |
| PDF checklist YES/NO boxes | OK |
| Stable gas IDs | OK |

### Gaps

- Free-text title role inference
- Full two-device checklist merge not QA'd

**Checklist sync readiness: 84%**

---

## N. Manual Dive / Logbook Audit

### Verified

| Item | Status |
|---|---|
| Manual entry fields | OK |
| CCR mode validation | OK post-remediation |
| Imperial depth/unit conversion | OK |
| Import service (CSV) | OK |
| Duplicate session prevention | Tested |
| Planner vs logbook math consistency | Footnotes where simulated |

### Gaps

- Physical logbook UX QA not in this pass
- Subsurface external round-trip not signed off

**Manual dive readiness: 88%**

---

## O. PDF / Share / CSV / Subsurface Audit

### PDF / share

| Export | OC | CCR | Notes |
|---|---|---|---|
| Planner briefing PDF | OK | OK | CCR bailout text localized |
| Dive Pack PDF | OK | Partial | CCR less tested |
| Checklist PDF | OK | OK | CCR equipment |
| Share targets (Mail, AirDrop, etc.) | OK | OK | System share sheet |
| Reference-only disclaimer | OK | OK | No certified wording |

### CSV / Subsurface

| Item | Status |
|---|---|
| Metric export policy | OK |
| Time base / columns | OK per `CSV_IMPORT_EXPORT_POLICY.md` |
| CCR fields in CSV | Partial — policy documented |
| External Subsurface validation | **Not executed** |
| Import round-trip | Internal tests; external pending |

**PDF / share readiness: 90%**  
**CSV readiness: 85%** | **Subsurface external: 50%** (not run)  
**CCR export readiness: 88%**

---

## P. Unit Conversion Audit

### Verified

| Conversion | Planner | Charts | Logbook | PDF | CSV | CCR |
|---|---|---|---|---|---|---|
| m ↔ ft | OK | OK | OK | OK | Metric policy | OK |
| bar ↔ psi | OK | OK | OK | OK | OK | Setpoint stays bar |
| °C ↔ °F | OK | OK | OK | OK | OK | OK |
| Switch depth display | OK | OK | OK | OK | — | Fixed imperial bug |

**Unit conversion readiness: 92%**  
**CCR unit readiness: 92%**

---

## Q. Cloud / Sync / Persistence Audit

### Verified

| Item | Status |
|---|---|
| Conflict detection | Implemented |
| Tombstone policy | Documented |
| KVS payload size cap | Implemented |
| CCR JSON persistence round-trip | Test added @ remediation |
| Gas role preservation | Tests |
| Watch payload isolation | Watch does not corrupt iOS algorithm state |

### Gaps

- iCloud two-device QA matrix **not executed**
- Opt-in backup visual QA pending

**Cloud readiness: 86%**  
**Sync data integrity: 86%** | **CCR persistence: 88%**

---

## R. Test Coverage Audit

### Strong coverage

- Bühlmann core, GF, trimix, altitude, bailout exclusion
- Planner mode limits and projections
- MOD/PPO₂/switch depth autoclamp
- Ratio Deco validator + MOD incompatibility
- CCR planner, validator, inspired gas, tissue sampler, remediation suite
- Checklist sync, manual dive validation, PDF builders (unit-level)
- Unit conversion, cloud conflict fixtures

### Missing or weak

| Area | Gap |
|---|---|
| External Bühlmann fixtures | Process, not XCTest |
| CCR bailout engine simulation | Intentionally absent — document only |
| Subsurface external round-trip | Manual / external |
| iCloud two-device merge | Manual QA matrix |
| Visual overlay chart QA | Manual |
| CCR Dive Pack PDF snapshot tests | Limited |
| Performance / long-profile stress | Partial |

**Automated test readiness: 89%**  
**Manual QA readiness: 55%** (matrices exist, evidence slots mostly empty)  
**External validation readiness: 45%**

---

## S. Release Hard Matrix

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | **94%** | External third-party profile sign-off | P1 process |
| Planner Base/Deco/Technical | **92%** | Visual QA edge cases | P3 |
| CCR / Rebreather | **88%** | Bailout heuristic; external CCR profiles | P1 |
| Ratio Deco | **86%** | Heuristic by design; no external ref | P3 |
| Gas Roles | **88%** | Checklist title inference | P3 |
| MOD/PPO2/Dalton | **93%** | Manual autoclamp visual QA | P3 |
| Switch Depth Clamp | **91%** | Same | P3 |
| Tissue Loading | **90%** | Logbook simulated segments | P3 |
| Narcosis | **88%** | CCR estimator simplification | P3 |
| CNS/OTU | **91%** | None code-level | P4 |
| Checklist Sync | **84%** | Two-device QA | P2 |
| Manual Dive | **88%** | Physical UX QA | P2 |
| PDF Export | **90%** | CCR Dive Pack depth | P2 |
| CSV/Subsurface | **85%** | External Subsurface validation | P2 |
| Unit Conversion | **92%** | None significant | P4 |
| Cloud/Sync | **86%** | iCloud two-device QA | P1 process |
| Test Coverage | **89%** | E2E/visual gaps | P2 |
| **Overall** | **91%** | External validation + physical QA | P1 |

---

## T. Detailed Action Plan

### P0 — Critical (immediate)

**None.** No safety-critical algorithm defect open at `cc4d783`.

### P1 — High (before external TestFlight)

| ID | Action | Files / area | Tests | Acceptance |
|---|---|---|---|---|
| P1-EXT-BM | Execute external Bühlmann profile comparison | `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` | Manual evidence pack | Signed comparison table |
| P1-EXT-CCR | Execute CCR external validation slots | `Docs/CCR_REBREATHER_VALIDATION_PLAN.md` | Manual | All CCR-01…04 filled or waived with rationale |
| P1-ICLOUD | Two-device iCloud merge QA | `Docs/ICLOUD_TWO_DEVICE_QA_MATRIX.md` | Manual | Recorded pass/fail |
| P1-BAILOUT-DOC | Keep bailout heuristic disclosure in review notes | `Docs/TESTFLIGHT_REVIEW_NOTES.md` | Review | No engine-simulated bailout claims |

### P2 — Medium (internal TestFlight hardening)

| ID | Action | Files | Tests |
|---|---|---|---|
| P2-CCR-PDF | Expand CCR Dive Pack PDF tests | `DivePackPDFBuilder.swift`, tests | PDF snapshot or field asserts |
| P2-SUBSURFACE | Subsurface CSV external round-trip | Export/import services | Manual per `SUBSURFACE_CSV_ROUNDTRIP.md` |
| P2-WATCH-QA | Paired Watch physical sync | `Docs/WATCH_IOS_SYNC_QA_MATRIX.md` | Manual |
| P2-RUNTIME | Decide fate of `runtimeSegments` | CCR models + docs | Implement or permanent quarantine test |

### P3 — Low (polish)

| ID | Action |
|---|---|
| P3-VISUAL | Run planner overlay / Dynamic Type / VoiceOver matrices |
| P3-CHECKLIST | Improve checklist role inference hints |
| P3-NARCOSIS | Document CCR density estimator limits in UI footnote |

### P4 — Future / optional

| ID | Action |
|---|---|
| P4-BAILOUT-ENGINE | Optional Bühlmann OC bailout switch simulation (major scope) |
| P4-GOLDEN | Expand golden Bühlmann fixture library |
| P4-PERF | Long-profile performance benchmarks |

---

## U. 7-Day / 14-Day Readiness Plan

### Days 1–7 (external gate prep)

1. **Day 1–2:** Run Bühlmann external validation plan — capture profiles, screenshots, delta table.
2. **Day 3–4:** Run CCR validation plan CCR-01…04 — document heuristic bailout separately.
3. **Day 5:** iCloud two-device QA on planner + manual dive + CCR persistence.
4. **Day 6:** Update TestFlight review notes + safety disclaimer cross-check.
5. **Day 7:** Re-run full iOS algorithm test suite + `validate_main_release_readiness.sh` if available.

### Days 8–14 (Release candidate)

1. **Day 8–9:** Subsurface CSV external round-trip + Watch physical sync matrix.
2. **Day 10:** Visual QA — Ratio Deco overlay, CCR planner screens, PDF exports.
3. **Day 11:** App Store legal/marketing language audit (non-certified, CCR reference-only).
4. **Day 12:** Internal TestFlight build with evidence pack (`Docs/QA_EVIDENCE_PACK_TEMPLATE.md`).
5. **Day 13–14:** Triage feedback; only P1 fixes; re-audit with this command.

---

## V. Recommended Cursor Remediation Commands (draft only — do not execute)

1. **`2-DIR_DIVING_IOS_BUHLMANN_CORE_EXTERNAL_VALIDATION_EVIDENCE.md`** — collect and commit external Bühlmann comparison evidence.
2. **`3-DIR_DIVING_IOS_CCR_HARDENING_AND_BAILOUT_TRUTHFULNESS.md`** — optional bailout engine simulation vs enhanced heuristic docs.
3. **`4-DIR_DIVING_IOS_RATIO_DECO_VISUAL_AND_EXPORT_QA.md`** — overlay chart + PDF comparison QA automation.
4. **`5-DIR_DIVING_IOS_MOD_SWITCH_DEPTH_VISUAL_QA.md`** — autoclamp edge-case matrix execution.
5. **`6-DIR_DIVING_IOS_TISSUE_NARCOSIS_LOGbook_FOOTNOTES.md`** — logbook simulated segment UX polish.
6. **`7-DIR_DIVING_IOS_CHECKLIST_PDF_CCR_EXPORT.md`** — CCR Dive Pack PDF parity + checklist inference.
7. **`8-DIR_DIVING_IOS_UNIT_TEST_COVERAGE_AND_ICLOUD_E2E.md`** — two-device tests + Subsurface round-trip harness.

---

## W. Final Verdict

| Question | Answer |
|---|---|
| Is Bühlmann ready? | **Yes for internal reference validation** (94%); **not** for external certification sign-off until third-party comparison completes. |
| Is the Planner ready? | **Yes** for Base/Deco/Technical (92%); CCR mode isolated and functional (88%). |
| Is CCR implemented, partial, or absent? | **Implemented** as reference planner — not live loop controller. |
| Is CCR safe to expose? | **Yes with reference-only disclaimers** — bailout is heuristic; no monitoring claims. |
| Is Ratio Deco ready? | **Yes as labeled heuristic comparator** (86%) — not primary deco authority. |
| Is tissue loading real/model-backed? | **Yes** for planner and CCR planned profiles; logbook uses disclosed simulation. |
| Is narcotic loading real/model-backed? | **Yes** with simplified CCR density estimator — footnote-worthy. |
| Are MOD/PPO₂ and switch-depth rules consistent? | **Yes** across Planner, Ratio Deco, Bühlmann, CCR setpoint paths post-remediation. |
| Are manual dives integrated? | **Yes** (88%) — CCR validation and imperial fixes landed. |
| Are exports reliable? | **Mostly** (90% PDF, 85% CSV) — external Subsurface not validated. |
| Safe for internal TestFlight? | **Conditional yes** — document CCR + bailout + non-certified posture. |
| Safe for external TestFlight? | **Not yet** — external math + iCloud + Watch physical QA pending. |
| Ready for App Store? | **Not yet** — same gates + legal/marketing review. |
| What blocks 100% readiness? | External validation evidence, physical QA matrices, heuristic CCR bailout (by design), optional `runtimeSegments`, Subsurface external sign-off. |
| What must be fixed first? | **Process, not code:** external Bühlmann + CCR validation evidence and iCloud two-device QA. |

### Static tooling scan (Phase 10 — recorded, not fixed)

| Scan | Result |
|---|---|
| `try!` in iOSApp/Services/Views/Models | **0** |
| `as!` (same scope) | Not elevated — spot checks clean in algorithm paths |
| CCR-related Swift files in iOSApp | **7** module files + planner integration |
| TODO/FIXME in iOSApp | Present in places — none flagged as P0 in this pass |

---

## Phase 13 Validation Checklist

| Check | Result |
|---|---|
| Report file exists | **YES** — this file |
| Report not empty | **YES** |
| Issue matrix / action plan | **YES** — Sections T, S |
| Release Hard Matrix | **YES** — Section S |
| No source code modified | **YES** (audit pass) |
| Git status | New report file only expected |

---

*End of audit @ `cc4d783`. Prior comprehensive baseline: V3 @ `a4b99e6` (469 tests). Math baseline: `b9f54a3` (509 tests, 87%). Post-remediation math: `cc4d783` (526 tests, 93% math scope). This comprehensive audit overall: **91%**.*
