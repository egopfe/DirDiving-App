# Watch Underwater Fast Controls — Implementation Report (Current)

**Branch:** `feature/watch-underwater-fast-controls`  
**Baseline:** uncommitted stack on `feature/watch-water-auto-open`  

## Verdict

| Gate | Status |
|------|--------|
| Internal | **INTERNAL_READY** |
| Physical Water Lock QA | **PHYSICAL_WATER_LOCK_QA_PENDING** |
| Side button / Crown press | **NO_CLAIM_ON_SIDE_BUTTON_OR_CROWN_PRESS** |
| Action Button shortcut | **ACTION_BUTTON_SHORTCUT_CONFIGURATION_REQUIRED** |

## Files

- `Utils/WatchUnderwaterPagePolicy.swift`
- `Services/WatchUnderwaterActionRouter.swift`
- `Views/WatchUnderwaterPrimaryActionHintView.swift`
- `ExecuteUnderwaterPrimaryActionIntent` in `ActionButtonIntents.swift`
- Updated: `ContentView`, `AppNavigationStore`, `UserImageStore`, `DIRDivingApp`, `UserImagesView`
- Tests: `WatchUnderwaterPagePolicyTests`, `WatchUnderwaterActionRouterTests`
- QA: 7 `WATCH_UNDERWATER_FAST_CONTROLS_*` templates (PENDING)

## Pages allowed underwater (Phase 1)

| Activity | Pages |
|----------|-------|
| Diving | live, compass, userImages (if images) |
| Apnea | live only |
| Snorkeling | live only |

Settings intentionally excluded (safety-first).

## Rollback

Revert branch; remove Action Button shortcut assignment on device.
