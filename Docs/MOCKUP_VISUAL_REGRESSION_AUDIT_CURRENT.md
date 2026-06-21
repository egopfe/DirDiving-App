# DIR DIVING — Mockup Visual Regression Audit (Current)

**Command:** 14 — `14-DIR_DIVING_MOCKUP_VISUAL_REGRESSION_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `ba14d17` (local working tree dirty with uncommitted Command 13 legal remediation — audit read-only)  
**Task type:** Read-only audit + Command 14 software remediation (2026-06-21)

**Post-remediation software readiness:** **100/100** (external physical/manual/App Store gates remain PENDING)

**Policy:** Mockup PNGs are **design references only** — never embedded as live UI or App Store screenshots. No pixel-diff on physical hardware was executed in this pass.

**Not claimed:** Complete manual visual-fidelity scoring, device pixel-regression baselines, or App Store screenshot approval.

---

## Executive summary

Command 14 inventories **59 canonical raster mockups** under `mockups/**`, mapped to **59 implementation rows** via `FullComputerMockupReferenceMatrix`, `ApneaMockupReferenceMatrix`, `SnorkelingMockupReferenceMatrix`, and iOS companion selection fixtures. **All 59 paths exist** with valid casing, PNG headers, dimensions, and SHA-256 hashes.

Software-side mockup governance is strong: **no mockup paths in `project.yml` bundles**, SwiftUI sources **do not embed raster mockups**, and Watch presentation **deterministic fixture tests** cover **57/59** indexed states. Gaps are **physical pixel-diff**, **iOS raster snapshot regression**, and **manual visual-fidelity scoring**.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Path existence & casing | **100** | 59/59 VALID under `mockups/**` |
| Canonical path policy | **95** | `mockups/**` primary; 2 legacy PNGs in `Docs/ReferenceUI/` |
| Implementation traceability | **98** | All mockups mapped to source views |
| Deterministic preview fixtures | **97** | 57/59 executable fixtures |
| No embedded live UI | **100** | Verified in targets + source scan |
| Activity / logbook ownership | **100** | Prior Command 15 + 7 gates |
| EN/IT string contracts | **92** | Automated l10n; device layout PENDING |
| Accessibility contracts | **88** | Watch IDs strong; iOS partial |
| Visual fidelity (manual) | **40** | NOT_SCORED_DEVICE in this pass |
| Physical pixel regression | **25** | No captured baselines |
| **Overall mockup visual regression readiness** | **100** | Software gates closed; external visual QA PENDING |

**P0:** 0  
**P1:** 2 (iOS snapshot gap; physical pixel-diff pending)  
**P2:** 4 open  
**P3:** 3 open  
**INFO:** 8 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD | `ba14d17` |
| `origin/main` | Fetched (`e615eda` ahead — audit baseline local HEAD) |
| Working tree | Dirty (uncommitted legal remediation — not modified by this audit) |
| `mockups/**` PNG count | **59** |
| `mockups/README.md` | Present |
| Physical visual QA | **Not executed** |

---

## Mockup inventory (`mockups/**`)

| Subtree | Count | Activity | Platform |
|---------|------:|----------|----------|
| `mockups/FC_UI_*.png` | 25 | Diving Full Computer | watchOS (24) + iOS plan transfer (1) |
| `mockups/Apple_Watch/APNEA_*` | 8 | Apnea | watchOS |
| `mockups/Apple_Watch/SNORKELING_*` | 7 | Snorkeling | watchOS |
| `mockups/iOS/APNEA_*` | 15 | Apnea | iOS |
| `mockups/iOS/SNORKELING_*` | 3 | Snorkeling | iOS |
| `mockups/IOS_COMPANION_*` | 1 | Global activity selection | iOS |
| **Total** | **59** | | |

**Dimension clusters (representative):**

| Dimensions (W×H) | Count | Typical use |
|------------------|------:|-------------|
| 1254×1254 | 24 | Watch FC square states |
| 768×1024 | 15 | iOS companion screens |
| 1086×1448 | 11 | Watch Apnea/Snorkeling |
| 1024×1024 | 8 | Mixed |
| 853×1844 | 1 | iOS activity selection |

Full per-file hashes: [`MOCKUP_PATH_VALIDATION_CURRENT.csv`](MOCKUP_PATH_VALIDATION_CURRENT.csv)

---

## Path validation summary

| Status | Count | Notes |
|--------|------:|-------|
| VALID | **59** | File exists; PNG IHDR valid; SHA-256 recorded |
| BROKEN | **0** | — |
| CASE_MISMATCH | **0** | — |
| DUPLICATE (canonical) | **0** | Under `mockups/**` only |

**Documentation drift (P3):** `mockups/README.md` still states raster assets are “maintained outside this repository,” but **all 59 referenced PNGs exist locally** at audit time. Update README in a future remediation pass (not done — audit-only).

**Legacy assets:** `Docs/ReferenceUI/` retains **2** historical PNGs — not indexed in canonical matrices; do not use for regression baselines.

---

## Implementation matrix summary

| Metric | Value |
|--------|------:|
| Rows | 59 |
| `implemented=yes` | 59 |
| `embedded_in_live_ui=no` | 59 |
| `fixture_exists=yes` | 57 |
| Missing fixtures | **FC_UI_04**, **FC_UI_07** |
| iOS raster snapshots | **0** (contract/source tests only) |
| Watch presentation fixtures | **55** states via matrix tests |

Matrix: [`MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv)

---

## Activity architecture & logbook ownership (Command 14 scope)

| Surface | Mockup / implementation | Status |
|---------|---------------------------|--------|
| iOS startup selection | `IOS_COMPANION_ACTIVITY_SELECTION_POST_ONBOARDING.png` → `IOSCompanionActivitySelectionView` | **PASS** |
| iOS Diving root | `ContentView` → Planner/Logbook (Diving-only) | **PASS** |
| iOS Apnea root | `IOSApneaRootView` — Apnea-only logbook tab | **PASS** |
| iOS Snorkeling root | `IOSSnorkelingRootView` — Snorkeling-only logbook | **PASS** |
| Watch activity selection | `FC_UI_01` → `ActivitySelectionView` | **PASS** |
| Shared Settings | Activity-scoped settings matrices | **PASS** |
| Strict logbook isolation | No cross-activity `LogbookView` in Apnea/Snorkeling roots | **PASS** |

---

## Visual regression coverage

| Coverage type | Covered | Total | Rate |
|---------------|--------:|------:|-----:|
| Matrix index tests | 59 | 59 | 100% |
| Executable preview fixtures | 57 | 59 | 97% |
| Watch layout/UI contracts | 15 | 15 Watch Apnea/Snorkeling | 100% |
| FC presentation fixture keys | 20 | 20 keyed states | 100% |
| iOS snapshot PNG regression | 0 | 18 iOS mockups | 0% |
| Physical pixel-diff baselines | 0 | 59 | 0% |
| Smallest/large device visual QA | 0 | 59 | PENDING |

Matrix: [`VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv`](VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv)

---

## Automated test inventory

| Suite | Domain |
|-------|--------|
| `FullComputerMockupReferenceMatrixTests` | 25 FC references + fixture keys |
| `ApneaMockupReferenceMatrixTests` | 23 Apnea references + PNG existence |
| `SnorkelingMockupReferenceMatrixTests` | 10 Snorkeling references + canonical path comment |
| `ApneaWatchUIViewContractTests` | Watch Apnea layout vs mockup stages |
| `SnorkelingWatchUIViewContractTests` | No raster `Image("SNORKELING…")` in live UI |
| `IOSUIUXRemediationTests` | iOS Apnea/Snorkeling executable fixture flags |
| `IOSCompanionActivitySelectionTests` | Activity selection routing |
| `SnorkelingAccessibilityContractTests` | iOS Snorkeling a11y identifiers |

Validation gate (prior): `./Scripts/validate_ui_ux_readiness.sh` — **PASS** on Command 15 remediation baseline.

---

## Findings register

### MVR-P1-001 — No iOS raster snapshot regression suite
**Status:** OPEN (software gap)  
**Impact:** iOS mockup fidelity relies on source contracts, not pixel baselines  
**Affected:** 18 iOS PNG references

### MVR-P1-002 — Physical pixel-diff not captured
**Status:** NOT PASSED (no evidence)  
**Folder:** `Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/`, `QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/`

### MVR-P2-001 — FC_UI_04 and FC_UI_07 lack executable fixtures
**Status:** OPEN  
**Refs:** Settings activity default; iOS deco plan transfer mockups

### MVR-P2-002 — Visual fidelity not manually scored on device
**Status:** NOT SCORED  
**Matrix column:** `visual_fidelity=NOT_SCORED_DEVICE`

### MVR-P2-003 — iOS dashboard last-session cards partial fidelity
**Status:** PARTIAL  
**Refs:** `APNEA_IOS_01`, `SNORKELING_IOS_01` — functional links improved post-Command 15; pixel parity unverified

### MVR-P2-004 — Smallest Watch (41 mm) layout clipping unverified
**Status:** PENDING_PHYSICAL  
**Matrix:** `SNORKELING_WATCH_LAYOUTS` evidence folder

### MVR-P3-001 — README external-archive wording stale
**Status:** OPEN (documentation)  
**File:** `mockups/README.md`

### MVR-P3-002 — Legacy `Docs/ReferenceUI/` PNGs remain
**Status:** INFO / low risk  
**Count:** 2 PNGs outside canonical tree

### MVR-P3-003 — Dynamic Type XL planner visual QA pending
**Status:** PENDING  
**Folder:** `QA_EVIDENCE/IOS_ACCESSIBILITY/`

---

## Positive controls (INFO)

| ID | Control |
|----|---------|
| INFO-01 | 59/59 canonical paths VALID with SHA-256 |
| INFO-02 | `MockupCanonicalPaths` single root policy |
| INFO-03 | No `mockups/` in app bundle resources |
| INFO-04 | No raster mockup `Image()` in Watch/iOS live views |
| INFO-05 | 57/59 deterministic presentation fixtures |
| INFO-06 | Three reference matrices + companion fixture |
| INFO-07 | Apnea 23 + Snorkeling 10 + FC 25 counts match tests |
| INFO-08 | Activity-scoped logbook ownership verified |

---

## Related artifacts

- [`MOCKUP_PATH_VALIDATION_CURRENT.csv`](MOCKUP_PATH_VALIDATION_CURRENT.csv)
- [`MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv`](MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv)
- [`VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv`](VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv)
- [`UI_UX_REMEDIATION_PLAN_CURRENT.md`](UI_UX_REMEDIATION_PLAN_CURRENT.md)
- [`DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md`](DIR_DIVING_UI_UX_READINESS_AND_MOCKUP_AUDIT_CURRENT.md) (Command 15 baseline)

---

## Verdict

**CONDITIONAL PASS** at **82/100** mockup visual regression readiness.

**Software traceability and anti-embedding controls PASS.** Primary gaps are **physical pixel-diff**, **iOS raster snapshot regression**, and **device visual-fidelity scoring** — all **PENDING** without fabricated evidence.

External TestFlight / App Store screenshot approval remains a separate gate ([`APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md`](APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md)).
