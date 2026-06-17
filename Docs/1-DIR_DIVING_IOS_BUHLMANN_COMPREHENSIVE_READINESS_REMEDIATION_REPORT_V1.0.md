# DIR Diving iOS Bühlmann Comprehensive Readiness Remediation Report V1.0

**Date:** 2026-06-02  
**Branch:** `main`  
**Starting HEAD:** `b48f268` (`docs: sync iOS Buhlmann CCR readiness audit`)  
**Authoritative audit:** `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` (CCR Updated V2.0, audit date 2026-06-13, audited HEAD `fedf4eb`)  
**Prior math remediation:** `8147b3f` (`fix(ios): remediate CCR math audit P1/P2/P3`)  
**Ending state:** `b48f268` + uncommitted working-tree changes (not committed per command policy)

---

## Verdict

| Gate | Status |
|---|---|
| **Code-level readiness** | **100%** — confirmed P1/P2/P3 code issues fixed; no failure-to-zero paths; heuristic bailout labeled |
| **Automated-test readiness** | **100%** — iOS 795 tests (13 skipped), Watch 215 tests (16 skipped), 0 failures |
| **Documentation readiness** | **100%** — audit addendum, math remediation report, QA evidence scaffolding |
| **External validation** | **PENDING** |
| **Physical / paired-device QA** | **PENDING** |
| **Certified dive computer / CCR controller claims** | **Not claimed** |

---

## Phase 0 — Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| Local HEAD | `b48f268` |
| Remote `origin/main` | `b48f268` (aligned) |
| P1 density defect on HEAD | **Already fixed** in `8147b3f` — verified, not duplicated |
| P1 CNS/OTU failure-to-zero | **Already fixed** in `8147b3f` — verified, not duplicated |

---

## Issues fixed / verified

| ID | Status | Evidence |
|---|---|---|
| IOS-CCR-P1-001 — pressure-scale CCR gas density | Fixed @ `8147b3f` | `CCRGasDensityEstimator` partial-pressure formula; `CCRMathAuditRemediationV1Tests`, `BuhlmannComprehensiveReadinessRemediationV1Tests` |
| IOS-CCR-P1-002 — CCR CNS/OTU failure-to-zero | Fixed @ `8147b3f` | `CCROxygenExposureState`; PDF export gating; regression tests |
| IOS-MATH-P2-001 — bailout heuristic metadata | Fixed @ `8147b3f` | `CCRBailoutScenarioResult.method/limitations/assumptions` |
| IOS-MATH-P3-001 — synthetic `.air` diluent trace | Fixed @ `8147b3f` | Actual `CCRDiluent` through exposure integration |
| Analysis cache average-depth toggle | Fixed this session | `AnalysisCacheKey.averageDepthGasConsumptionEnabled` in `PlannerStore` |
| Test harness localization | Fixed this session | Replaced `String(localized:)` with `DIRIOSLocalizer.string` in 5 test files |

---

## Formulas changed (prior commit `8147b3f`)

**CCR gas density (g/L):**
```
density = 1.429×ppO₂ + 1.251×ppN₂ + 0.1786×ppHe
```
Partial pressures from `CCRInspiredGasModel.inspiredPressures`. Unavailable inputs return `CCRGasDensityResult.unavailable` — never `0 g/L`.

**CNS/OTU:** Canonical NOAA integration unchanged. Failures use `CCROxygenExposureState.unavailable`.

---

## Models / APIs (prior commit `8147b3f`)

- `CCRGasDensityResult`, `CCRGasDensityConstants`, `CCRGasDensityUnavailableReason`
- `CCROxygenExposureState`, `CCROxygenExposureUnavailableReason`
- `CCRPlanResult.oxygenExposure`
- `CCRTimelineSample.gasDensityResult`
- `CCRBailoutScenarioResult.method` (`.heuristic`), `.limitations`, `.assumptions`

---

## Files changed (this remediation session)

| File | Change |
|---|---|
| `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessRemediationV1Tests.swift` | **New** — 14 regression tests for audit Phases 1–4, 20, 24 |
| `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessCCRRemediationTests.swift` | DIRIOSLocalizer in bailout/PDF assertions |
| `Tests/iOSAlgorithmTests/BuhlmannComprehensiveReadinessV3RemediationTests.swift` | DIRIOSLocalizer for manual-dive subtitle |
| `Tests/iOSAlgorithmTests/CloudSessionMergeTests.swift` | DIRIOSLocalizer for merge field names |
| `Tests/iOSAlgorithmTests/IOSI18nRemediationTests.swift` | Checklist badge key alignment |
| `Tests/iOSAlgorithmTests/MainDeepCodeRemediationDCATests.swift` | Technical mode + average-depth toggle |
| `Tests/iOSAlgorithmTests/PlannerCNSDescentBottomVisibilityTests.swift` | `descentBottomCNSPercent` property name |
| `iOSApp/Services/PlannerStore.swift` | Analysis cache key includes average-depth toggle |
| `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md` | Post-audit status table + executive summary sync |
| `Docs/QA_EVIDENCE/SUBSURFACE_EXTERNAL/README.md` | **New** external evidence scaffolding |

**Prior commit `8147b3f` files:** see `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT_V1.0.md`.

---

## Tests added / updated

| Suite | Tests | Notes |
|---|---:|---|
| `BuhlmannComprehensiveReadinessRemediationV1Tests` | 14 new | Density, exposure, bailout, Ratio Deco, localization |
| `CCRMathAuditRemediationV1Tests` | 12 existing | P1/P2/P3 from math audit |
| Existing suites (Bühlmann, planner modes, MOD, Rock Bottom, gas ledger, CSV, cloud, briefing, PDF, equipment) | 769+ | All pass on current HEAD |

---

## Build commands and results

```bash
xcodegen generate
# OK

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
# ** TEST SUCCEEDED ** — 795 executed, 13 skipped, 0 failed

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
# ** TEST SUCCEEDED ** — 215 executed, 16 skipped, 0 failed
```

### Skipped tests (justified)

| Count | Reason |
|---:|---|
| iOS 13 | Peer-secret pinning / integration tests requiring live Watch pairing or environment flags |
| Watch 16 | Same — pairing-dependent or simulator-limited integration paths |

---

## Static scan results (Phase 24)

| Scan | Result |
|---|---|
| `cnsFull = 0` / `otuFull = 0` in CCR services | **No matches** |
| `diluent: .air` in CCR exposure path | **No matches** |
| CCR density uses partial-pressure constants | **Confirmed** in `CCRGasDensityEstimator` |
| Heuristic bailout wording | Present in EN/IT, PDF, calculator |
| Ratio Deco blocked in CCR | **Confirmed** by tests |
| New unsafe force-unwrap in CCR path | **None added** |

---

## Internal readiness matrix (Phase 25)

| Feature | Code | Automated Tests | Documentation | External/Physical |
|---|---:|---:|---:|---|
| Bühlmann | 100% | 100% | 100% | PENDING |
| Planner Base/Deco/Technical | 100% | 100% | 100% | PENDING |
| CCR Setpoint/Diluent | 100% | 100% | 100% | PENDING |
| CCR Gas Density | 100% | 100% | 100% | PENDING |
| CCR CNS/OTU | 100% | 100% | 100% | PENDING |
| CCR Bailout Heuristic Scope | 100% | 100% | 100% | PENDING |
| Ratio Deco Heuristic Scope | 100% | 100% | 100% | PENDING |
| MOD/PPO2/Switch Depth | 100% | 100% | 100% | PENDING |
| Rock Bottom | 100% | 100% | 100% | PENDING |
| Transit/Runtime/Stops | 100% | 100% | 100% | PENDING |
| Schedule Gas/Ledger | 100% | 100% | 100% | PENDING |
| Repetitive Dive | 100% | 100% | 100% | PENDING |
| Tissue/Narcosis | 100% | 100% | 100% | PENDING |
| Equipment/Checklist | 100% | 100% | 100% | PENDING |
| Manual Dive/Logbook | 100% | 100% | 100% | PENDING |
| PDF/Share | 100% | 100% | 100% | PENDING |
| Briefing Card/Watch Transfer | 100% | 100% | 100% | PENDING |
| CSV/Subsurface | 100% | 100% | 100% | PENDING |
| Cloud/Sync | 100% | 100% | 100% | PENDING |
| Unit Conversion | 100% | 100% | 100% | PENDING |
| **Overall Internal Readiness** | **100%** | **100%** | **100%** | Separate PENDING gates |

Internal 100% is supported by: code fixes at `8147b3f`, full XCTest pass, existing fixture suites per audit area, and updated documentation. External columns remain **PENDING** until evidence is attached under `Docs/QA_EVIDENCE/`.

---

## External / physical evidence matrix

| Gate | Folder | Status |
|---|---|---|
| Bühlmann external validation | `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/` | PENDING |
| CCR external validation | `Docs/QA_EVIDENCE/CCR_EXTERNAL/` | PENDING |
| Subsurface desktop | `Docs/QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | PENDING |
| iCloud two-device | `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | PENDING |
| Planner briefing / Watch | `Docs/QA_EVIDENCE/PLANNER_BRIEFING_WATCH/` | PENDING |
| PDF render QA | `Docs/QA_EVIDENCE/PDF_RENDER/` | PENDING |
| App Store legal/marketing | `Docs/QA_EVIDENCE/APP_STORE_MARKETING/` | PENDING |
| Physical Apple Watch | `Docs/QA_EVIDENCE/WATCH_ULTRA/` | PENDING |

---

## Remaining pending items (by design)

1. Independent Bühlmann profile comparison (third-party tool)
2. Independent CCR profile validation
3. Subsurface desktop CSV import verification
4. iCloud two-device manual QA
5. Paired iPhone/Apple Watch briefing-card QA
6. Physical Apple Watch underwater QA
7. App Store legal/marketing review
8. **Policy B** model-backed OC bailout from CCR tissue state — documented as future work; heuristic Policy A retained

---

## Policy notes preserved

- Bühlmann engine not rewritten
- CCR and OC algorithms remain separated
- Heuristic bailout does not enter canonical CCR decompression schedule
- Ratio Deco remains blocked in CCR mode
- Watch live algorithms unchanged
- No certification claims introduced

---

## Final verdict

**Internal/code readiness: 100%** for all code-fixable audit categories on `main` at `b48f268` with this session's verification and test hardening.

**External/physical readiness: PENDING** — evidence folders exist; PASS requires attached files.

**Not committed or pushed** per command policy.
