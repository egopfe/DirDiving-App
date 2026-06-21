# DIR DIVING — Mockup Visual Regression Remediation Report (Current)

**Command:** 14 remediation  
**Branch:** `main`  
**Source audit HEAD:** `ba14d17` (82/100)  
**Remediation HEAD:** see final git status  

---

## A. Executive Summary

Command 14 software-verifiable gaps are closed: **59/59** canonical mockups validate, **59/59** executable fixtures (including **FC_UI_04** and **FC_UI_07**), iOS raster snapshot regression suite passes, anti-embedding controls strengthened, dashboard last-session fidelity improved for **APNEA_IOS_01**, documentation and QA scaffolding aligned. Physical/manual/App Store gates remain **PENDING**.

## B. Source Audit Baseline

- 59 canonical PNGs under `mockups/**`
- 57/59 fixtures; 0/18 iOS raster snapshots
- Overall readiness **82/100**

## C. Initial Working Tree

Dirty tree preserved: Command 13 legal remediation + Command 14 audit CSVs (uncommitted).

## D. Current Baseline

- `MockupVisualRegressionRegistry`: 59 entries, 19 iOS raster contracts
- Software readiness **100%** (external QA separate)

## E. Findings Inventory

| ID | Result |
|----|--------|
| MVR-P1-001 | FIXED — iOS raster snapshot suite |
| MVR-P1-002 | PENDING_PHYSICAL_QA — scaffolding only |
| MVR-P2-001 | FIXED — FC_UI_04/07 fixtures |
| MVR-P2-002 | PENDING_MANUAL_VISUAL_QA |
| MVR-P2-003 | FIXED — Apnea dashboard inline metrics |
| MVR-P2-004 | PENDING_PHYSICAL_QA — simulator contracts added |
| MVR-P3-001 | FIXED — mockups/README.md |
| MVR-P3-002 | FIXED — legacy register |
| MVR-P3-003 | FIXED software — Dynamic Type XL planner contracts + template |

## F–Q. Remediation details

See finding traceability CSV and changed files below.

## R. Mockup Traceability Matrix

`Docs/UI_UX_MOCKUP_INVENTORY_CURRENT.csv` (59 rows, all `Fixture_Exists=yes`, `Runtime_Bundled=no`).

## S. Full Build/Test Results

Executed via `./Scripts/validate_mockup_visual_regression_readiness.sh` (see final summary).

## T. Audit 15 Impact

**NOT_TOUCHED** — Full Computer math/runtime unchanged.

## U. Audit 16 Result

**NOT_TOUCHED** — UI changes limited to Apnea dashboard last-session card layout (activity-scoped, no navigation ownership change). Re-run audit 16 if required before release.

## V. Readiness Recalculation

| Dimension | Before | After |
|-----------|--------|-------|
| Path existence | 100% | 100% |
| Fixture coverage | 97% | **100%** |
| iOS raster snapshot | 0% | **100%** (software) |
| Documentation | partial | **100%** |
| **Software mockup VR** | **82%** | **100%** |

## W. Physical/App Store QA Pending

All external gates documented in `Docs/MOCKUP_VISUAL_REGRESSION_EXTERNAL_QA_PENDING_CURRENT.md`.

## X. Changed Files

Production: `IOSApneaDashboardView.swift`, `IOSApneaDashboardPresentation.swift`, `FullComputerMockupReferenceMatrix.swift`, localization EN/IT.

New: fixtures, registry, policy, tests, scripts, QA scaffolding, CSV matrices.

## Y. Residual Accepted Risks

Physical pixel-diff and manual fidelity unverified on device; simulator ≠ physical evidence.

## Z. Final Git Status

Uncommitted remediation + prior legal work (not auto-committed).

## AA. Final Verdict

**MOCKUP_VISUAL_REGRESSION_REMEDIATION: PASS** (software); external visual gates **PENDING**.
