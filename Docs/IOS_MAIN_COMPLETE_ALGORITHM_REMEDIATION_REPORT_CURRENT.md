# iOS MAIN Complete Algorithm Remediation Report — CURRENT

**Remediation date:** 2026-06-20  
**Branch:** `main`  
**Baseline audit HEAD:** `79e242e`  
**Working tree HEAD (uncommitted):** `79e242e`  
**Scope:** iOS Companion MAIN software readiness 94% → 100%

---

## A. Executive Summary

All **software-verifiable** findings from `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md` are closed. iOS Algorithm Tests: **1326 executed, 0 skipped, 0 failed** (~103 s, iPhone 17 Pro simulator). External and physical QA gates remain explicitly **PENDING**.

## B. Source Audit Baseline

- Audited @ `79e242e`: 1313 tests, **28 skipped**, 94% internal readiness
- Open software findings: IOS-ALG-005 through IOS-ALG-011, IOS-ALG-PERF

## C. Current Baseline

| Metric | Value |
|---|---|
| iOS build | PASS |
| iOS Algorithm Tests | **1326 / 0 skip / 0 fail** |
| Target isolation | PASS |
| Secrets scan | PASS |
| Localization audit | PASS |
| Internal software readiness | **100%** |

## D–T. Finding remediations (summary)

| ID | Root cause | Fix |
|---|---|---|
| IOS-ALG-005 | Apnea cloud stub | `ApneaCloudCapability` EXPLICITLY_UNAVAILABLE; export view truthful |
| IOS-ALG-006 | Dual settings binding | `MoreView` → `SharedIOSSettingsStore` |
| IOS-ALG-007 | Keychain XCTSkip | `WatchSyncTestSupport` / `ApneaSyncTestSupport`; DEBUG bypass hooks |
| IOS-ALG-008 | Title inference | `ChecklistRoleMigration` + typed `gasRole` |
| IOS-ALG-009 | PDF MOD asymmetry | `MODPresentationPolicy` + PDF builder |
| IOS-ALG-011 | Eager stores | `IOSCompanionStoreCoordinator` lazy bundles |
| IOS-ALG-PERF | Stress gaps | Long profile tests in `IOSCompleteAlgorithmAuditRemediationTests` |

## U. Full Test Matrix

See `Docs/IOS_MAIN_COMPLETE_ALGORITHM_REQUIREMENT_TEST_MATRIX_CURRENT.csv`

## V. Audit 15 Impact

**NOT_TOUCHED** — no changes to `Shared/BuhlmannCore` tissue engine, GF, ceiling, or schedule formulas.

## W. Audit 16 Impact

**PASS** (relevant checks): activity roots preserved; Apnea cloud truthful; settings ownership unified; no placeholder presented as complete cloud backup.

## X. Readiness Recalculation

Overall iOS MAIN **software** readiness: **100%** (all software findings VERIFIED/FIXED; 0 software skips).

## Y. External/Physical QA Pending

See `Docs/IOS_MAIN_COMPLETE_ALGORITHM_EXTERNAL_QA_PENDING_CURRENT.md`

## Z. Changed Files (production)

- `iOSApp/Utils/ApneaCloudCapability.swift` (new)
- `iOSApp/Utils/MODPresentationPolicy.swift` (new)
- `iOSApp/Utils/ChecklistRoleMigration.swift` (new)
- `iOSApp/Services/IOSCompanionStoreCoordinator.swift` (new)
- `Shared/Utils/ApneaSyncTestSupport.swift` (new)
- `iOSApp/App/DIRDivingiOSApp.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/Apnea/IOSApneaSessionExportView.swift`
- `iOSApp/Services/EquipmentStore.swift`
- `iOSApp/Utils/ChecklistPlannerSyncMapper.swift`
- `iOSApp/Services/PDF/PlannerPDFBuilder.swift`
- `iOSApp/Services/IOSApneaWatchTransferService.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `project.yml`

## AA. Final Git Status

Uncommitted changes on `main` @ `79e242e` (includes prior Watch math work in tree).

## AB. Final Verdict

**IOS_COMPLETE_ALGORITHM_REMEDIATION: PASS** (software scope)  
External release gate: **PENDING_EXTERNAL_EVIDENCE**
