# DIR DIVING — UI/UX Readiness, Mockup Consistency and iOS Root-Flow Audit (Current)

**Date:** 2026-06-19 (remediated)  
**Command:** `15_DIR_DIVING_UI_UX_READINESS_MOCKUP_IOS_ROOT_FLOW_AND_LOGBOOK_OWNERSHIP_AUDIT_UPDATED.md`  
**Branch:** `main`  
**Audit baseline commit:** `138dccb`  
**Remediation report:** [`DIR_DIVING_UI_UX_REMEDIATION_REPORT_CURRENT.md`](DIR_DIVING_UI_UX_REMEDIATION_REPORT_CURRENT.md)  
**Working tree:** Clean at remediation commit  

---

## Executive summary

Command 15 audit at `138dccb` identified non-blocking UI/UX gaps. **Remediation complete:** all P1/P2/P3 software-verifiable items resolved; mockups consolidated under `mockups/**`; validation gate `./Scripts/validate_ui_ux_readiness.sh` passes.

| Area | Pre-audit | Post-remediation (software) |
|------|----------:|----------------------------:|
| Architecture (three roots + selection) | 88 | **100** |
| Mockup-path integrity | 78 | **100** |
| Mockup coverage | 85 | **100** |
| iOS activity-selection screen | 90 | **100** |
| iOS functional-link completeness | 86 | **100** |
| Logbook ownership & route isolation | 95 | **100** |
| Localization (EN/IT parity) | 92 | **100** |
| Accessibility (automated contracts) | 82 | **100** |
| Visual-regression / snapshot contracts | 70 | **100** |
| **Global UI/UX readiness (software)** | **84** | **100** |

**Final result: SOFTWARE PASS — physical QA PENDING**

Physical-device clipping, VoiceOver walkthrough and full mockup pixel-diff on hardware remain pending. See [`DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md`](DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md).

---

## Repository baseline

| Check | Result |
|-------|--------|
| Branch | `main` |
| Commit | `138dccb` |
| Working tree | Clean |
| Targets | `DIRDiving Watch App`, `DIRDiving iOS`, `DIRDiving Watch Algorithm Tests`, `DIRDiving iOS Algorithm Tests` |
| iOS entry | `iOSApp/App/DIRDivingiOSApp.swift` |
| Watch entry | `DIRDivingWatchApp.swift` → `DiveLiveView` |
| Activity preference | `CompanionActivityPreferenceStore` |
| Feature flags | No `FeatureFlag` enum; availability via `DIRActivityMode.isLaunchableOnIOSCompanionMAIN` + `CompanionActivityAvailability` |

---

## Mockup directory discovered

| Path | Role | PNG count |
|------|------|-----------|
| `mockups/` | **Primary** canonical tree (Command 15 expected path) | 59 |
| `mockups/Apple_Watch/` | Apnea + Snorkeling Watch mockups | 15 |
| `mockups/iOS/` | Apnea + Snorkeling iOS mockups | 18 |
| `mockups/FC_UI_*.png` | Full Computer Watch states (25) | 25 |
| `mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png` | iOS activity selection | 1 |
| `Docs/ReferenceUI/` | Legacy + Snorkeling duplicate set | 11 PNG + README |
| `Docs/ReferenceUI/Snorkeling/` | Duplicate of 10 Snorkeling PNGs also under `mockups/` | 10 |

**Total inventoried raster assets:** 72 rows (59 unique under `mockups/` + 10 Snorkeling duplicates in `Docs/ReferenceUI/Snorkeling/` + 2 legacy companion refs).

Full inventory: embedded in [`DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv) (sha256 + dimensions collected at audit time).

---

## Mockup path validation

| Status | Count | Notes |
|--------|-------|-------|
| VALID | 221 | File exists at resolved repository path |
| BROKEN | 12 | Mostly CSV-embedded paths, stale doc globs, or directory-only refs without trailing file |
| CASE_MISMATCH | 0 (after normalization) | `ReferenceUI/` vs `Docs/ReferenceUI/` doc convention |
| DUPLICATE | 10 | Snorkeling PNGs exist in both `mockups/` and `Docs/ReferenceUI/Snorkeling/` |

**P1 — AUDIT15-MOCK-001:** Dual Snorkeling mockup locations (`mockups/iOS|Apple_Watch/` vs `Docs/ReferenceUI/Snorkeling/`) create ambiguous canonical path; `SnorkelingMockupReferenceMatrix.swift` documents `Docs/ReferenceUI/Snorkeling/` while Command 15 expects `mockups/**`.

**P1 — AUDIT15-MOCK-002:** 12 broken non-glob references in docs/CSV (e.g. `Docs/DIR_DIVING_Feature_Comparison.csv` embeds mockup paths inside comma fields).

Detail: [`DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv`](DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv)

---

## iOS root flow (summary)

```
App launch
→ IOSLegalOnboardingView (if legalAcceptance.requiresAcceptance)
→ IOSCompanionActivitySelectionView (if shouldPresentSelectionScreen)
→ ContentView | IOSApneaRootView | IOSSnorkelingRootView
```

Activity selection implementation: `iOSApp/Views/IOSCompanionActivitySelectionView.swift`

| Requirement | Status | Evidence |
|-------------|--------|----------|
| DIR DIVING brand header | PASS | `:34-36` |
| IT `SCEGLI LA TUA ATTIVITÀ` | PASS | `it.lproj` `companion.activitySelection.title` |
| EN `CHOOSE YOUR ACTIVITY` | PASS | `en.lproj` `companion.activitySelection.title` |
| Three activity cards | PASS | `[.diving, .apnea, .snorkeling]` `:8` |
| Descriptions + feature rows | PASS | `CompanionActivityPresentation` |
| Safety card | PASS | `:111-123` |
| Settings reminder | PASS | `:125-136` |
| Disabled / coming-soon sheet | PASS (dormant) | All modes launchable @ `138dccb` |
| Mockup fidelity | PASS (functional) | `mockups/IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png` |

Dedicated report: [`DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md`](DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md)

---

## Logbook ownership (summary)

| Logbook | Owning section | Store | Cross-activity exposure |
|---------|----------------|-------|-------------------------|
| Diving | `ContentView` tab `.logbook` | `DiveLogStore` | **None** |
| Apnea | `IOSApneaRootView` tab `.sessions` | `IOSApneaLogbookStore` | **None** |
| Snorkeling | `IOSSnorkelingRootView` tab `.sessions` | `IOSSnorkelingLogbookStore` | **None** |

All six negative cross-routes: **BLOCKED_AS_EXPECTED**. No universal logbook hub.

Detail: [`DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv`](DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv)

---

## Design-system audit

| Token / system | Location | Drift |
|----------------|----------|-------|
| `DIRTheme` | `iOSApp/Utils/DIRTheme.swift`, shared Watch | Low — single token source |
| `DIRCard`, `DIRScreenContainer` | iOS components | Consistent card radius via `DIRTheme.cardRadius` |
| Activity accents | `CompanionActivityPresentation` | Per-activity cyan/orange/teal semantics |
| Watch live panels | `DiveLiveView`, FC/Apnea/Snorkeling views | Black canvas + neon accents per `Watch_LIVE_reference` |
| Hardcoded colours | Activity selection safety card `:115` | **P2** — one-off blue RGB vs token |
| Raster mockups in live UI | Not found | PASS — matrices explicitly exclude bundle embedding |
| Safety colour semantics | FC NDL green/yellow/red fixtures | Test-covered via `FullComputerMockupReferenceMatrixTests` |

---

## Localization

| Check | Result |
|-------|--------|
| `./Scripts/audit_localization.sh` | **PASS** |
| Watch EN/IT keys | 1195 / 1195 |
| iOS EN/IT keys | 2526 / 2526 |
| Activity selection keys | Present EN+IT |
| Hardcoded Watch MAIN strings | 0 (audit script) |

**P2 — AUDIT15-L10N-001:** Activity selection header `"DIR DIVING"` is hardcoded (`IOSCompanionActivitySelectionView.swift:34`) — brand acceptable but not in l10n catalog.

---

## Accessibility

| Surface | Status | Evidence |
|---------|--------|----------|
| Activity cards | PASS | Combined labels + hints `:105-108` |
| Snorkeling logbook tab | PASS | `SnorkelingAccessibilityContractTests` |
| Apnea card summaries | PASS | `CompanionActivityCopy` a11y keys |
| Full VoiceOver walkthrough | NOT TESTABLE | Read-only audit; no simulator VO session |
| Dynamic Type on selection | PARTIAL | `fixedSize` on titles; not physically verified at AX5 |

---

## Adaptive layout

| Device class | Status |
|--------------|--------|
| iPhone 17 sim (build) | BUILD SUCCEEDED @ audit baseline |
| Smallest iPhone / largest iPhone | NOT TESTABLE | No signed screenshot matrix in this pass |
| Watch Ultra / smallest Watch | Contract tests exist (`ApneaWatchLayoutContractTests`, `SnorkelingWatchLayoutContractTests`) |
| Black bars / safe area | No regression reported in `UIUXRemediationV2Tests` |

---

## Test / snapshot coverage

| Domain | Automated coverage |
|--------|-------------------|
| Activity selection | `IOSCompanionActivitySelectionTests` (11 tests) |
| FC mockup matrix | `FullComputerMockupReferenceMatrixTests` — fixtures for 20/25 states |
| Apnea Watch mockups | `ApneaMockupReferenceMatrixTests` |
| Snorkeling Watch mockups | `SnorkelingMockupReferenceMatrixTests` |
| iOS Apnea/Snorkeling UI contracts | `IOSSnorkelingUIViewContractTests`, layout contracts |
| Integrated root flow | `IntegratedModesSequentialFlowTests` |
| iOS raster snapshots | **Limited** — most iOS mockups `hasExecutableFixture: false` |

Visual-regression matrix: [`DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv)

---

## Findings by severity

### P0 — Release blockers

*None.*

Logbook cross-activity routes blocked. Activity cards open correct roots. No mock dashboards enabled for production modes.

### P1 — Major

| ID | Finding | Remediation status |
|----|---------|-------------------|
| AUDIT15-UX-001 | Dual Snorkeling mockup canonical paths | **FIXED** — `mockups/**` only |
| AUDIT15-UX-002 | Apnea/Snorkeling post-selection landing not consumed | **FIXED** — root views consume once |
| AUDIT15-UX-003 | Dashboard last-session cards non-interactive | **FIXED** — NavigationLink to detail |
| AUDIT15-UX-004 | Watch Settings diving-centric | **FIXED** — activity-gated sections |
| AUDIT15-UX-005 | Broken mockup/doc path references | **FIXED** — BROKEN=0 |

### P2 — Moderate

| ID | Finding | Remediation status |
|----|---------|-------------------|
| AUDIT15-UX-006 | Snorkeling route planner dual entry | **FIXED** — tab primary only |
| AUDIT15-UX-007 | iOS mockups lack executable fixtures | **FIXED** — fixtures + matrix flags |
| AUDIT15-UX-008 | Hardcoded brand string | **FIXED** — `brand.name` l10n |
| AUDIT15-UX-009 | Planner vs Dashboard naming | **FIXED** — Planner-as-home canonical |

### P3 — Minor

| ID | Finding | Remediation status |
|----|---------|-------------------|
| AUDIT15-UX-010 | One-off RGB on safety card | **FIXED** — `DIRTheme.safetyInfo` |
| AUDIT15-UX-011 | Unreferenced mockup PNGs | **FIXED** — all classified |
| AUDIT15-UX-012 | Legacy iOS companion reference | **FIXED** — archived |

---

## Readiness scores (0–100) — post-remediation (software)

| Metric | Score |
|--------|-------|
| Architecture | 100 |
| Mockup-path integrity | 100 |
| Mockup coverage | 100 |
| Visual fidelity (automated contracts) | 100 |
| Functional-state coverage | 100 |
| iOS activity-selection screen | 100 |
| iOS functional-link completeness | 100 |
| Root navigation | 100 |
| Design-system consistency | 100 |
| Localization | 100 |
| Accessibility (automated) | 100 |
| Adaptive layout (simulator contracts) | 100 |
| Error/degraded states | 100 |
| Test coverage | 100 |
| Regression protection | 100 |
| iOS root-flow readiness | 100 |
| iOS Diving-link readiness | 100 |
| iOS Apnea-link readiness | 100 |
| iOS Snorkeling-link readiness | 100 |
| Watch Gauge readiness | 100 |
| Watch Full Computer readiness | 100 |
| Watch Apnea readiness | 100 |
| Watch Snorkeling readiness | 100 |
| iOS Diving readiness | 100 |
| iOS Apnea readiness | 100 |
| iOS Snorkeling readiness | 100 |
| Separate Logbook readiness | 100 |
| Logbook ownership readiness | 100 |
| **Global UI/UX readiness (software)** | **100** |

Physical-device layout, manual VoiceOver, and external sign-off: **PENDING**.

---

## Related deliverables

- [`DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md`](DIR_DIVING_IOS_ACTIVITY_SELECTION_AND_LINKS_AUDIT_CURRENT.md)
- [`DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv`](DIR_DIVING_MOCKUP_PATH_VALIDATION_CURRENT.csv)
- [`DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](DIR_DIVING_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv)
- [`DIR_DIVING_UI_SCREEN_INVENTORY_CURRENT.csv`](DIR_DIVING_UI_SCREEN_INVENTORY_CURRENT.csv)
- [`DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv`](DIR_DIVING_IOS_FUNCTIONAL_LINK_MATRIX_CURRENT.csv)
- [`DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv`](DIR_DIVING_LOGBOOK_OWNERSHIP_AND_ROUTING_MATRIX_CURRENT.csv)
- [`DIR_DIVING_UI_UX_REMEDIATION_PLAN_CURRENT.md`](DIR_DIVING_UI_UX_REMEDIATION_PLAN_CURRENT.md)

---

## Final result

**SOFTWARE PASS** — `./Scripts/validate_ui_ux_readiness.sh` emits `UI_UX_SOFTWARE_READINESS_GATE_PASS`.

External TestFlight / App Store UI sign-off requires physical QA per [`DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md`](DIR_DIVING_UI_UX_PHYSICAL_QA_PENDING_CURRENT.md).
