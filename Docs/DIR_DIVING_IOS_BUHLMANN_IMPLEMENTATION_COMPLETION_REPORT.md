# DIR DIVING iOS Bühlmann Implementation Completion Report

**Date:** 2026-06-07  
**Branch:** `main`  
**Scope:** iOS Companion MAIN — Bühlmann planner only (no Watch / experimental)

## Summary

P2 and P3 items from [`DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md`](DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_UPDATED.md) were implemented. Bühlmann decompression math, CNS/OTU integration, and legal disclaimers were not changed.

## P2 fixes completed

| ID | Fix |
|---|---|
| IOS-BUH-P2-001 | `PlannerAscentTableBuilder` now orders PIANO DI RISALITA as bottom → post-bottom ascent/gas-switch travel rows (elapsed order) → deco stops → surface. Descent segments are excluded from the ascent briefing table. |
| IOS-BUH-P2-002 | Full-plan CNS dashboard tile uses warning color/icon when `oxygenExposureElevated` is present on plan or gas analysis state. |

## P3 fixes completed

| ID | Fix |
|---|---|
| IOS-BUH-P3-001 | GF policy documented in validation copy: GF Low must be strictly lower than GF High; equality rejected (Technical mode). Test added. |
| IOS-BUH-P3-002 | Briefing copy uses TTS-only wording (`planner.briefing.gf_tts`) in EN/IT; export already used TTS-only. |
| IOS-BUH-P3-003 | Tissue chart display path no longer silently falls back to sea-level ambient pressure; invalid conversion skips chart samples / returns nil metrics. |

## Files modified

- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Services/TissueAnalyticsService.swift`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`
- `Tests/iOSAlgorithmTests/PlannerAscentTableTests.swift`
- `Tests/iOSAlgorithmTests/PlannerCNSCopyTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannGradientFactorTests.swift`
- `Tests/iOSAlgorithmTests/BuhlmannTissueHistoryTests.swift`

## macOS validation

Commands (iPhone 17 simulator):

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test
```

Result: **BUILD SUCCEEDED**, **TEST SUCCEEDED** (363 tests, 5 skipped).

## Confirmations

- No Apple Watch files modified.
- No experimental files modified.
- Bühlmann constants and tissue equations unchanged.
- CNS/OTU math unchanged.
- Reference-only / non-certified disclaimers intact.

## P4 deferred

- External Bühlmann reference comparison campaign.
- Physical-device Dynamic Type / VoiceOver QA.
- Inline constant source citations in `BuhlmannConstants.swift`.
- Heliox named UI mix kind.

## Final readiness verdict

**READY FOR INTERNAL VALIDATION**

Remaining before release candidate: external decompression comparison, simulator/device QA, stale README baseline strings (`90dc3f5` in some docs), and optional `Docs/DIR_DIVING_IOS_CNS_PLANNER_IMPLEMENTATION_AUDIT.md`.
