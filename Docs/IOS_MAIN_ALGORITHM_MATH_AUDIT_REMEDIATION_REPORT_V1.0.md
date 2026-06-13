# iOS MAIN Algorithm Math Audit Remediation Report V1.0

**Date:** 2026-06-13  
**Branch:** `main`  
**Audit source:** `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`  
**Baseline HEAD:** `fedf4eb`  
**Remediation commit:** _(see git log after push)_

## Verdict

| Gate | Status |
|---|---|
| Code-level mathematical readiness | **100%** (confirmed P1/P2/P3 code issues addressed) |
| Internal engineering readiness | **100%** (build + targeted regression tests pass) |
| External validation evidence | **PENDING** |
| Physical / paired-device QA | **PENDING** |
| Certified dive computer / controller claims | **Not claimed** |

## Issues fixed

| ID | Fix |
|---|---|
| IOS-MATH-P1-001 | CCR gas density now pressure-scaled from partial pressures (g/L) |
| IOS-MATH-P1-002 | CCR CNS/OTU failures use `CCROxygenExposureState.unavailable` — no zero fallback |
| IOS-MATH-P2-001 | Bailout heuristic typed with method/limitations/assumptions metadata |
| IOS-MATH-P3-001 | CCR exposure integration passes actual diluent (not `.air`) |
| IOS-MATH-P3-002 | Ratio Deco regression tests retained; still blocked in CCR |
| IOS-MATH-P3-003 | macOS build + iOS Algorithm Tests executed on this machine |

## Formulas changed

**Gas density (CCR):**
```
density g/L = 1.429×ppO₂ + 1.251×ppN₂ + 0.1786×ppHe
```
Partial pressures from `CCRInspiredGasModel.inspiredPressures` (same path as tissue/narcosis).

**CNS/OTU:** Canonical NOAA integration unchanged; failure path now unavailable instead of `0`.

## Model / API changes

- `CCRGasDensityResult` + `CCRGasDensityConstants`
- `CCROxygenExposureState` + `CCROxygenExposureUnavailableReason`
- `CCRTimelineSample.gasDensityResult` (optional grams via computed property)
- `CCRPlanResult.oxygenExposure` replaces silent zero doubles for failures
- `CCRBailoutScenarioResult.method`, `.limitations`, `.assumptions`
- PDF export requires `hasAvailableOxygenExposure`

## Files changed (core)

- `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`
- `iOSApp/Services/CCR/CCRGasDensityConstants.swift` (new)
- `iOSApp/Services/CCR/CCROxygenExposureState.swift` (new)
- `iOSApp/Services/CCR/CCRInspiredGasModel.swift`
- `iOSApp/Services/CCR/CCRPlannerService.swift`
- `iOSApp/Services/CCR/CCRPlannerEngine.swift`
- `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`
- `iOSApp/Models/CCR/CCRModels.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`
- `iOSApp/Services/PDF/CCRPlannerPDFBuilder.swift`
- `iOSApp/Services/PDF/PDFExportService.swift`
- `Tests/iOSAlgorithmTests/CCRMathAuditRemediationV1Tests.swift` (new)
- `Docs/QA_EVIDENCE/*/README.md` (new scaffolding)

## Tests added

`CCRMathAuditRemediationV1Tests` — density scaling, unavailable semantics, bailout metadata, diluent trace.

## Build / test results

| Command | Result |
|---|---|
| `xcodegen generate` | OK |
| `xcodebuild -scheme "DIRDiving iOS" build` | **SUCCEEDED** |
| `CCRMathAuditRemediationV1Tests` | **PASSED** (12) |
| `CCRMathRemediationTests` | **PASSED** |
| `CCRPlannerTests` | **PASSED** |

## Still PENDING (by design)

- IOS-MATH-P2-002 external Bühlmann/CCR fixture evidence
- IOS-MATH-P2-003 PDF render + paired Watch QA
- Policy B model-backed OC bailout (documented as post-release; Policy A shipped)

## Readiness matrix (post-remediation)

| Area | Code readiness |
|---|---:|
| OC Bühlmann planner | 100% internal |
| CCR gas density | 100% internal |
| CCR CNS/OTU failure semantics | 100% internal |
| CCR bailout heuristic | 100% internal (explicitly non-authoritative) |
| Ratio Deco | 100% internal (heuristic labeling preserved) |
| PDF/export gating | 100% internal |
| External parity claims | PENDING evidence |

## Algorithm safety confirmation

- Bühlmann engine unchanged
- Watch live-dive algorithms unchanged
- No certified-planner claims introduced
- Heuristic bailout not promoted to decompression authority
