# Watch Water Auto-Open — Implementation Report (Current)

**Date:** 2026-06-17  
**Branch:** `feature/watch-water-auto-open`  
**Baseline commit:** `6197673` (parent: Apple Shallow Depth entitlement feature)  

## Verdict

| Gate | Status |
|------|--------|
| Internal implementation | **INTERNAL_READY** |
| Physical water auto-open QA | **PHYSICAL_WATER_AUTO_OPEN_QA_PENDING** |
| System Auto-Launch listing | **SYSTEM_AUTO_LAUNCH_LISTING_NOT_CLAIMED** |

## Files changed

### New
- `Utils/WatchWaterAutoOpenPolicy.swift`
- `Views/WatchWaterAutoOpenSettingsView.swift`
- `Tests/WatchAlgorithmTests/WatchWaterAutoOpenPolicyTests.swift`
- `Docs/WATCH_WATER_AUTO_OPEN_POLICY.md`
- `Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*` (5 templates, PENDING)

### Modified
- `Utils/DIRStartupSelectionPolicy.swift` — `resolveWaterAutoLaunchStep()`
- `Services/DIRActivitySelectionStore.swift` — `beginWaterAutoLaunch()`, record last selected
- `Services/ActionButtonIntents.swift` — `OpenWaterAutoLaunchModeIntent`
- `Views/SettingsView.swift` — startup section row
- `App/DIRDivingApp.swift` — migration on launch
- `Resources/en.lproj/Localizable.strings`, `Resources/it.lproj/Localizable.strings`
- `Tests/WatchAlgorithmTests/WatchCompleteAlgorithmAuditRemediationTests.swift`
- `project.yml`

## Known limitations

- System submerged Auto-Launch list depends on Apple entitlement/provisioning and watchOS behavior
- Water submersion context detection for cold launch is not fully hookable without OS callbacks; App Intent + policy prepare routing when invoked

## Rollback

Revert branch or set `WatchWaterAutoOpenPolicy.mode = .disabled`.
