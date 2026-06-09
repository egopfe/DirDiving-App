# iOS Complete Algorithm Audit — Remediation Report

**Date:** 2026-06-09  
**Starting HEAD:** `9301fb334ce0911d7aa0aef6f5e17b7e377ed6d1`  
**Authoritative audit:** [`IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`](IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md) (preserved)  
**Scope:** iOS Companion MAIN only — Watch runtime not modified

---

## Summary

Remediation implements all fixable non-physical items from the iOS complete algorithm audit @ `9301fb3`. iOS remains a **non-certified reference planner**; CCR remains **reference-only** with **heuristic bailout**; Ratio Deco remains **heuristic comparator** blocked in CCR mode.

**No external validation or physical QA was fabricated or marked passed.**

---

## Issues addressed

| ID | Action |
|---|---|
| **IOS-CHK-CCR-001** | Wired CCR checklist export in `CCRPlannerView` + `CCRPlanResultView` via `CCRChecklistExportCoordinator`; confirmation dialog + `CCRChecklistExportSheet`; mapper `ccrExportCandidates` / `hasCCRChecklistItemsMissing` |
| **IOS-EXT-BM-001** | Expanded [`QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md`](QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md) — **PENDING** |
| **IOS-EXT-CCR-001** | Expanded [`QA_EVIDENCE/CCR_EXTERNAL/README.md`](QA_EVIDENCE/CCR_EXTERNAL/README.md) — **PENDING** |
| **IOS-ICLOUD-001** | Expanded [`QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md`](QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md) — **PENDING** |
| **IOS-SUB-001** | Expanded [`QA_EVIDENCE/SUBSURFACE_CSV/README.md`](QA_EVIDENCE/SUBSURFACE_CSV/README.md); `SubsurfaceExportServiceRemediationTests` |
| **IOS-BAILOUT-DOC-001** | Preserved `CCRBailoutScenarioResult.isHeuristic`; existing PDF/disclaimer tests retained |
| **IOS-CCR-PDF-001** | Documented OC-only Dive Pack/Briefing in [`CCR_REBREATHER_EXPORT_POLICY.md`](CCR_REBREATHER_EXPORT_POLICY.md); CCR result view offers CCR plan PDF only |
| **IOS-CCR-RUNTIME-001** | `runtimeSegments` documented as reserved; existing `testRuntimeSegmentsDoNotAlterCCRPlan` retained |
| **IOS-CCR-LOOP-001** | `loopVolumeLiters` documented as metadata-only; `testLoopVolumeLitersDoesNotAlterCCRPlanMath` added |
| **IOS-PERF-001** | Long OC/CCR profile finite-output tests added |
| **IOS-LEGAL-001** | [`IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md`](IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md) |
| **IOS-VISUAL-001** | [`IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md`](IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md) + [`QA_EVIDENCE/IOS_ACCESSIBILITY/`](QA_EVIDENCE/IOS_ACCESSIBILITY/README.md) |

---

## Issues intentionally left manual / external / physical

| ID | Reason |
|---|---|
| IOS-EXT-BM-001 | External Bühlmann third-party comparison |
| IOS-EXT-CCR-001 | CCR-01…07 external profiles |
| IOS-ICLOUD-001 | Two-device iCloud QA |
| IOS-SUB-001 | Subsurface desktop round-trip |
| IOS-VISUAL-001 | Dynamic Type / VoiceOver device QA |
| Watch physical / paired sync | Out of scope — separate matrices |

---

## Files changed

### Code

- `iOSApp/Utils/ChecklistPlannerSyncMapper.swift`
- `iOSApp/Utils/CCRChecklistExportCoordinator.swift` (new)
- `iOSApp/Views/CCR/CCRChecklistExportSheet.swift` (new)
- `iOSApp/Views/CCR/CCRPlannerView.swift`
- `iOSApp/Views/CCR/CCRPlanResultView.swift`
- `iOSApp/Models/CCR/CCRModels.swift`
- `project.yml`

### Tests

- `Tests/iOSAlgorithmTests/IOSCompleteAlgorithmAuditRemediationTests.swift` (new)
- `Tests/iOSAlgorithmTests/ChecklistPlannerSyncMapperTests.swift`

### Documentation

- `Docs/QA_EVIDENCE/BUHLMANN_EXTERNAL/README.md`
- `Docs/QA_EVIDENCE/CCR_EXTERNAL/README.md`
- `Docs/QA_EVIDENCE/ICLOUD_TWO_DEVICE/README.md`
- `Docs/QA_EVIDENCE/SUBSURFACE_CSV/README.md`
- `Docs/QA_EVIDENCE/IOS_ACCESSIBILITY/README.md` (new)
- `Docs/IOS_DYNAMIC_TYPE_VOICEOVER_QA_MATRIX.md` (new)
- `Docs/IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` (new)
- `Docs/CCR_REBREATHER_EXPORT_POLICY.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_REMEDIATION_REPORT.md` (this file)

---

## Tests run

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

**Simulator:** iPhone 17 Pro (exact name; no substitution)

### Results

| Command | Result |
|---|---|
| iOS build | **PASS** |
| iOS Algorithm Tests | **PASS** — 554 executed, 13 skipped, **0 failures** (+14 new tests) |

---

## Safety posture preserved

- Non-certified reference planner
- CCR reference-only — not life-support controller
- Ratio Deco heuristic only — unavailable in CCR mode
- Heuristic bailout explicit (`isHeuristic`)
- `runtimeSegments` / `loopVolumeLiters` inactive in engine math
- Watch runtime unchanged

---

## Final readiness

| Gate | Status |
|---|---|
| Internal TestFlight | **Conditional yes** — tests pass; limitations disclosed |
| External TestFlight | **No** — external Bühlmann, CCR, iCloud, Subsurface, Watch physical QA **PENDING** |
| App Store | **No** — same evidence gates + legal/marketing review **PENDING** |
| Certified decompression planner | **Never** under current scope |
| Certified CCR controller / life-support | **Never** under current scope |

---

*End of remediation report. Working tree uncommitted unless user requests commit.*
