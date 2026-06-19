# DIR DIVING — UI/UX Readiness, Mockup Consistency and iOS Root-Flow Audit (Current)

**Date:** 2026-06-17  
**Command:** `15_DIR_DIVING_UI_UX_READINESS_MOCKUP_IOS_ROOT_FLOW_AND_LOGBOOK_OWNERSHIP_AUDIT_UPDATED.md`  
**Branch:** `main`  
**Commit:** `138dccb` (`138dccbf74fd71b63c527868a046adcfaf25bd3f`)  
**Working tree:** Clean  
**Audit type:** Read-only — no production code modified  

---

## Executive summary

Independent UI/UX audit of the three-mode iOS Companion + Watch MAIN surfaces at `138dccb`. The repository has a **mature activity-specific root architecture**, **canonical activity-selection screen**, and **strict logbook route isolation**. Mockup assets are present under `mockups/` (59 PNG) with code-indexed reference matrices for FC, Apnea and Snorkeling Watch states. Gaps are **non-blocking for internal software QA** but prevent a full external UI sign-off: duplicate Snorkeling PNG trees, documentation path drift, partial dashboard deep-links, and limited iOS raster snapshot coverage.

| Area | Score | Label |
|------|-------|-------|
| Architecture (three roots + selection) | 88 | PASS |
| Mockup-path integrity | 78 | CONDITIONAL PASS |
| Mockup coverage | 85 | CONDITIONAL PASS |
| iOS activity-selection screen | 90 | PASS |
| iOS functional-link completeness | 86 | CONDITIONAL PASS |
| Logbook ownership & route isolation | 95 | PASS |
| Localization (EN/IT parity) | 92 | PASS |
| Accessibility (automated contracts) | 82 | CONDITIONAL PASS |
| Adaptive layout (simulator evidence) | 75 | NOT TESTABLE (physical) |
| Visual-regression / snapshot coverage | 70 | CONDITIONAL PASS |
| **Global UI/UX readiness** | **84** | **CONDITIONAL PASS** |

**Final result: CONDITIONAL PASS**

No P0 findings. P1 items documented below; physical-device clipping, VoiceOver walkthrough and full mockup pixel-diff remain pending.

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

| ID | Finding | Evidence |
|----|---------|----------|
| AUDIT15-UX-001 | Dual Snorkeling mockup canonical paths | `mockups/` vs `Docs/ReferenceUI/Snorkeling/` |
| AUDIT15-UX-002 | Apnea/Snorkeling post-selection landing flags never consumed in UI | `CompanionActivityPreferenceStore` marks pending; only Diving consumes planner landing in `ContentView` |
| AUDIT15-UX-003 | Dashboard “last session” cards non-interactive (Apnea + Snorkeling) | `IOSApneaDashboardView`, `IOSSnorkelingDashboardView` |
| AUDIT15-UX-004 | Watch `SettingsView` remains diving-centric (Command 14 deferred) | Cross-activity settings leakage on Watch |
| AUDIT15-UX-005 | 12 broken mockup/doc path references | Path validation CSV |

### P2 — Moderate

| ID | Finding |
|----|---------|
| AUDIT15-UX-006 | Snorkeling route planner dual entry (tab + sheet) |
| AUDIT15-UX-007 | iOS mockups lack executable fixtures / snapshots |
| AUDIT15-UX-008 | Hardcoded brand string on selection screen |
| AUDIT15-UX-009 | Diving iOS has Planner-as-home vs mockup “Dashboard” naming |

### P3 — Minor

| ID | Finding |
|----|---------|
| AUDIT15-UX-010 | One-off RGB on safety card |
| AUDIT15-UX-011 | Unreferenced mockup PNGs in inventory |
| AUDIT15-UX-012 | Legacy `Docs/ReferenceUI/iOS_Companion_reference.png` predates three-mode selection |

---

## Readiness scores (0–100)

| Metric | Score |
|--------|-------|
| Architecture | 88 |
| Mockup-path integrity | 78 |
| Mockup coverage | 85 |
| Visual fidelity | 80 |
| Functional-state coverage | 86 |
| iOS activity-selection screen | 90 |
| iOS functional-link completeness | 86 |
| Root navigation | 88 |
| Design-system consistency | 85 |
| Localization | 92 |
| Accessibility | 82 |
| Adaptive layout | 75 |
| Error/degraded states | 84 |
| Test coverage | 83 |
| Regression risk | 78 |
| iOS root-flow readiness | 89 |
| iOS Diving-link readiness | 88 |
| iOS Apnea-link readiness | 85 |
| iOS Snorkeling-link readiness | 87 |
| Watch Gauge readiness | 86 |
| Watch Full Computer readiness | 88 |
| Watch Apnea readiness | 87 |
| Watch Snorkeling readiness | 86 |
| iOS Diving readiness | 86 |
| iOS Apnea readiness | 85 |
| iOS Snorkeling readiness | 87 |
| Separate Logbook readiness | 95 |
| Logbook ownership readiness | 95 |
| **Global UI/UX readiness** | **84** |

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

**CONDITIONAL PASS**

Safe to proceed to the next development phase for **internal** three-mode Companion work. External TestFlight / App Store UI sign-off requires P1 remediation, physical layout QA, and consolidated mockup path policy.
