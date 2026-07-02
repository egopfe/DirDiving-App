# iOS Diving Demo Logbook Regression Fix

**Date:** 2026-06-17  
**Status:** **FIXED_SOFTWARE** · **MANUAL_UI_QA_PENDING**

## Regression summary

Enabling the Diving demo logbook toggle in iOS Settings did not reliably show the five catalog demo dives in the Logbook tab when real/imported/synced dives were already present. Unified (all-activities) logbook mode also hid Diving demo dives because demo inclusion was hardcoded off.

## Root cause

1. **`DiveLogStore`** inserted demo dives only when no non-demo sessions existed (`guard sessions.filter({ !$0.isDemoDive }).isEmpty`), and `insertDemoDives()` replaced the entire `sessions` array with demo-only content.
2. **`IOSUnifiedLogbookListView`** called `IOSUnifiedLogbookPresentationBuilder.build(..., includeDemo: false)`, excluding all demo entries regardless of the Diving settings toggle.

## Files changed

| File | Change |
|------|--------|
| `iOSApp/Services/DiveLogStore.swift` | Idempotent `insertMissingDemoDives()` / `removeDemoDives()`; preserve real sessions; test hooks |
| `iOSApp/Utils/IOSUnifiedLogbookPresentationBuilder.swift` | Per-activity demo flags |
| `iOSApp/Views/Shared/IOSUnifiedLogbookListView.swift` | Pass Diving/Apnea/Snorkeling demo toggles separately |
| `Tests/iOSAlgorithmTests/IOSDiveLogStoreDemoLogbookTests.swift` | New store regression tests |
| `Tests/iOSAlgorithmTests/IOSUnifiedLogbookPresentationBuilderTests.swift` | Activity-specific demo inclusion tests |
| `Tests/iOSAlgorithmTests/IOSUnifiedLogbookNoContaminationTests.swift` | Updated default-flag call site |

## Final behavior

- Diving demo toggle ON → five `DemoDiveCatalog` dives appear in Diving Logbook even with existing real dives.
- Real/imported/synced dives remain visible and unchanged.
- Toggle OFF → only demo dives removed.
- Re-enabling toggle ON → no duplicate demo dives (idempotent by catalog IDs).
- Demo insertion mutates local store only; does not call `add(_:)` or Watch transfer.
- Unified logbook respects `includeDivingDemo`, `includeSnorkelingDemo`, and `includeApneaDemo` independently.

## Data compatibility

- Demo dives use stable `DemoDiveCatalog.sessionIDs`.
- Protected logbook file and cloud merge semantics unchanged for real sessions.
- Demo preference stored in existing `dirdiving_ios_include_demo_logbook` UserDefaults key.

## Non-algorithm confirmation

No changes to Bühlmann, CCR, planner, gas, tissue, Watch runtime algorithms, or dive numerical outputs.

## Tests executed

*(Recorded at validation run)*

| Suite | Result |
|-------|--------|
| `IOSDiveLogStoreDemoLogbookTests` (9 tests) | **PASS** |
| `IOSUnifiedLogbookPresentationBuilderTests` (14 tests) | **PASS** |
| `IOSUnifiedLogbookNoContaminationTests` (5 tests) | **PASS** |
| `DIRDiving iOS` build | **PASS** |

## Tests not executed

- Full iOS Algorithm Tests scheme (optional; run if CI time allows).
- Manual device UI walkthrough (required before App Store reviewer demo sign-off).

## Manual UI QA checklist

- [ ] Enable Diving demo logbook in Settings with an empty logbook → 5 demo dives visible.
- [ ] Import or sync at least one real dive → enable demo toggle → real + 5 demos visible.
- [ ] Disable demo toggle → only real dives remain.
- [ ] Re-enable demo toggle → 5 demos return, no duplicates.
- [ ] Enable unified/all-activities logbook → Diving demos visible when Diving demo toggle ON.
- [ ] With only Diving demo ON, Apnea/Snorkeling fake demos do not appear in unified list.
- [ ] Demo rows show demo badge; delete affordance remains hidden for demo dives.

## Software readiness

Fix is **software-complete** for the reported regression. Physical QA, TestFlight, and App Store gates remain unchanged and **PENDING**.
