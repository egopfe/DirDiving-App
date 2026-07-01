# iOS Unified Activity Logbook View

## Objective

Per-activity iOS setting **Show all activities in logbook** (default **OFF**). When ON, the current activity’s logbook shows a **read-only aggregated** timeline of Diving, Snorkeling, and Apnea sessions sorted by date descending.

## Architecture

- **Presentation only** — no merged storage, no cross-activity persistence, no Watch/sync changes.
- Three independent stores remain: `DiveLogStore`, `IOSSnorkelingLogbookStore`, `IOSApneaLogbookStore`.
- Mapping via `IOSUnifiedLogbookPresentationBuilder` → `[IOSUnifiedLogbookEntry]`.
- UI: `IOSUnifiedLogbookListView`, `IOSUnifiedLogbookEntryRow`, `IOSUnifiedLogbookDetailHost`.

## Settings

| Activity | UserDefaults key | Default |
|----------|------------------|---------|
| Diving | `dirdiving.ios.diving.logbook.showAllActivities` | `false` |
| Snorkeling | `dirdiving.ios.snorkeling.logbook.showAllActivities` | `false` |
| Apnea | `dirdiving.ios.apnea.logbook.showAllActivities` | `false` |

Stored in `IOSActivityLogbookVisibilitySettingsStore` on `IOSCompanionStoreCoordinator`.

## P1 scope

Included: aggregated timeline, entry count, activity badges, date sort, navigation to activity-specific detail.

Excluded: cross-activity statistics, mixed depth/time averages, unified export, personal bests across activities.

## Fake/demo policy

Real unified view excludes demo/fake entries (`includeDemo: false`). Activity-specific demo logbook toggles unchanged when unified toggle is OFF.

## QA

Manual UI QA templates under `Docs/QA_EVIDENCE/IOS_LOGBOOK_*`. Status: **PENDING**.
