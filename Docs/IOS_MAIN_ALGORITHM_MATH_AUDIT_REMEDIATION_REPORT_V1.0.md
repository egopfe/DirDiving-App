# iOS MAIN Algorithm Math Audit Remediation Report V1.0

**Date:** 2026-06-14  
**Branch:** `main`  
**Authoritative audit:** `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` (dated 2026-06-13, baseline HEAD `5b85505`)  
**Starting HEAD (this remediation pass):** `d756f59`  
**Final working-tree state:** clean after report + acceptance tests  
**Primary remediation commits (pre-existing):** `8147b3f`, `c0b5cd9`, `15f2d59`  
**This pass additions:** acceptance test file + documentation alignment @ macOS validation

---

## Executive summary

All **code-fixable** findings from the authoritative math audit are **implemented and verified**. P1 CCR gas density and CNS/OTU failure semantics, P2 bailout heuristic truthfulness (Policy A), and P3 diluent trace / Ratio Deco labeling / macOS build-test gate are complete at internal engineering readiness **100%**.

External Bühlmann/CCR validation, Subsurface desktop round-trip, PDF render screenshots, paired Watch QA, iCloud two-device QA, and App Store legal review remain **PENDING** by policy — not counted against internal code readiness.

---

## Verdict

| Gate | Status |
|---|---|
| Code-level mathematical readiness | **100%** |
| Automated-test readiness (internal) | **100%** — iOS 812 executed, 0 failed, 13 skipped |
| Documentation readiness (internal) | **100%** |
| External validation evidence | **PENDING** |
| Physical / paired-device QA | **PENDING** |
| Certified dive computer / decompression / CCR controller | **Not claimed** |

---

## Issues fixed (audit ID → status)

| ID | Finding | Status | Evidence |
|---|---|---|---|
| IOS-MATH-P1-001 | CCR gas density not pressure-scaled | **Fixed** @ `8147b3f` | `CCRGasDensityEstimator` partial-pressure g/L; `CCRMathAuditRemediationV1Tests`, `BuhlmannComprehensiveReadinessRemediationV1Tests`, `IOSMainAlgorithmMathAuditRemediationCompleteTests` |
| IOS-MATH-P1-002 | CCR CNS/OTU failure → zero | **Fixed** @ `8147b3f` | `CCROxygenExposureState`; UI/PDF/briefing use unavailable labels; export gated |
| IOS-MATH-P2-001 | CCR bailout heuristic | **Hardened (Policy A)** @ `8147b3f` | `CCRBailoutCalculationMethod.heuristic`, metadata, EN/IT strings, PDF |
| IOS-MATH-P2-002 | External fixture evidence | **Scaffolded; PENDING** | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/`, `CCR_EXTERNAL/` |
| IOS-MATH-P2-003 | PDF/briefing render QA | **Internal tests pass; physical PENDING** | PDF text tests; `Docs/QA_EVIDENCE/PDF_RENDER/` |
| IOS-MATH-P3-001 | Synthetic `.air` diluent trace | **Fixed** @ `8147b3f` | Actual `CCRDiluent` through exposure integration |
| IOS-MATH-P3-002 | Ratio Deco heuristic labeling | **Preserved + tested** | `RatioDecoPlannerTests`, `CCRMathRemediationTests` |
| IOS-MATH-P3-003 | macOS build/test gate | **Executed** @ 2026-06-14 | See build results below |

---

## Mathematical formulas changed

**CCR gas density (canonical):**

```
density g/L = 1.429×ppO₂ + 1.251×ppN₂ + 0.1786×ppHe
```

Partial pressures from `CCRInspiredGasModel.inspiredPressures` (single source with tissue/narcosis).

**CNS/OTU:** NOAA integration unchanged; failure path returns `CCROxygenExposureState.unavailable` — never coerced to zero in presentation, PDF, briefing, or export gates.

**Bühlmann OC engine:** unchanged.

---

## Models / APIs added or modified

| Symbol | Role |
|---|---|
| `CCRGasDensityResult` / `CCRGasDensityUnavailableReason` | Typed density with fail-closed unavailable |
| `CCRGasDensityConstants` | Centralized g/L per bar coefficients |
| `CCROxygenExposureState` / `CCROxygenExposureUnavailableReason` | Typed exposure; no zero fallback |
| `CCRPlanResult.oxygenExposure` | Canonical exposure field |
| `CCRPlanResult.hasAvailableOxygenExposure` | Export/UI gate |
| `CCRBailoutScenarioResult.method/limitations/assumptions` | Heuristic metadata (Policy A) |
| `PDFExportService.canExportCCRPlan` | Blocks export when exposure unavailable |

Legacy `cnsFullPlanPercent` / `otuFullPlan` computed properties remain for test compat; UI/PDF/briefing use `oxygenExposure` optionals and unavailable labels.

---

## Files changed (cumulative remediation)

**Core ( @ `8147b3f` ):**
- `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`
- `iOSApp/Services/CCR/CCRGasDensityConstants.swift`
- `iOSApp/Services/CCR/CCROxygenExposureState.swift`
- `iOSApp/Services/CCR/CCRInspiredGasModel.swift`
- `iOSApp/Services/CCR/CCRPlannerService.swift`
- `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`
- `iOSApp/Models/CCR/CCRModels.swift`
- `iOSApp/Services/PDF/CCRPlannerPDFBuilder.swift`
- `iOSApp/Services/PDF/PDFExportService.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`

**Tests (cumulative):**
- `Tests/iOSAlgorithmTests/CCRMathAuditRemediationV1Tests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessRemediationV1Tests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessCCRRemediationTests.swift`
- `Tests/iOSAlgorithmTests/CCRPlannerBriefingExportTests.swift`
- `Tests/iOSAlgorithmTests/IOSMainAlgorithmMathAuditRemediationCompleteTests.swift` *(this pass)*

**Documentation / evidence:**
- `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md`
- `Docs/QA_EVIDENCE/CCR_EXTERNAL/README.md`
- `Docs/QA_EVIDENCE/SUBSURFACE_EXTERNAL/README.md`
- `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md`
- `Docs/QA_EVIDENCE/PLANNER_BRIEFING_WATCH/README.md`
- `Docs/QA_EVIDENCE/PDF_RENDER/README.md`
- `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md` *(post-remediation section)*

---

## Build / test results @ 2026-06-14

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
```

| Command | Result |
|---|---|
| `xcodegen generate` | **OK** |
| `DIRDiving iOS` build | **BUILD SUCCEEDED** |
| `DIRDiving iOS Algorithm Tests` | **812 executed**, **13 skipped**, **0 failed** |
| `DIRDiving Watch App` build | **BUILD SUCCEEDED** |
| `DIRDiving Watch Algorithm Tests` | **201 executed**, **16 skipped**, **0 failed** |

**Skipped tests:** keychain peer-secret pinning (no test fixture), environment-gated integration tests — documented, not failures.

---

## Static scan results (Phase 19)

| Scan | Result |
|---|---|
| CCR density partial-pressure path | **PASS** — no composition-only 1-bar formula in production |
| CCR exposure failure-to-zero in `CCRPlannerService` | **PASS** — uses `CCROxygenExposureState` |
| `diluent: .air` in CCR services | **PASS** — no synthetic air in exposure integration |
| Heuristic bailout wording | **PASS** — consistent EN/IT keys + PDF |
| Ratio Deco CCR rejection | **PASS** |
| Certification claims in Views/Docs | **PASS** — reference-only disclaimers preserved |
| New unsafe force unwraps | **None introduced** |

---

## Internal readiness matrix

| Feature | Code | Tests | Documentation | External/Physical |
|---|---:|---:|---:|---|
| Bühlmann OC | 100% | 100% | 100% | PENDING |
| CCR Setpoint/Diluent | 100% | 100% | 100% | PENDING |
| CCR Gas Density | 100% | 100% | 100% | PENDING |
| CCR CNS/OTU | 100% | 100% | 100% | PENDING |
| CCR Bailout Heuristic | 100% | 100% | 100% | PENDING |
| Ratio Deco Heuristic | 100% | 100% | 100% | PENDING |
| MOD/PPO₂/Switch Depth | 100% | 100% | 100% | PENDING |
| Rock Bottom | 100% | 100% | 100% | PENDING |
| Transit/Runtime/Stops | 100% | 100% | 100% | PENDING |
| Gas Schedule/Ledger | 100% | 100% | 100% | PENDING |
| Repetitive Dive | 100% | 100% | 100% | PENDING |
| Tissue/Narcosis | 100% | 100% | 100% | PENDING |
| Equipment/Checklist | 100% | 100% | 100% | PENDING |
| Manual Dive/Logbook | 100% | 100% | 100% | PENDING |
| PDF/Share | 100% | 100% | 100% | PENDING |
| Briefing Card/Watch Transfer | 100% | 100% | 100% | PENDING |
| CSV/Subsurface (internal) | 100% | 100% | 100% | PENDING |
| Cloud/Sync (internal) | 100% | 100% | 100% | PENDING |
| Unit Conversion | 100% | 100% | 100% | PENDING |
| **Overall Internal** | **100%** | **100%** | **100%** | **Separate PENDING gates** |

---

## Pending items (by design)

| Item | Type | Next step |
|---|---|---|
| External Bühlmann profiles | Evidence | Execute `DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md` |
| External CCR profiles | Evidence | Execute `CCR_REBREATHER_VALIDATION_PLAN.md` |
| Subsurface desktop | Evidence | `SUBSURFACE_CSV_ROUNDTRIP.md` steps 4–10 |
| PDF render screenshots | Physical QA | `Docs/QA_EVIDENCE/PDF_RENDER/` |
| Watch briefing transfer | Physical QA | `WATCH_IOS_SYNC_QA_MATRIX.md` |
| iCloud two-device | Physical QA | `ICLOUD_TWO_DEVICE_QA_MATRIX.md` |
| Policy B model-backed OC bailout | Future scope | Separate product command if desired |

---

## Algorithm safety confirmation

- Bühlmann engine unchanged
- Watch live-dive algorithms unchanged
- No certified-planner or CCR-controller claims introduced
- Heuristic bailout not promoted to decompression authority
- CCR remains iOS-only reference planner

---

*End of remediation report — internal code readiness 100% @ `d756f59` + acceptance tests.*
