# iOS Activity Logbook Visibility Settings

## Store

`IOSActivityLogbookVisibilitySettingsStore` — iOS-only, coordinator-scoped, injected via `applyGlobalEnvironment`.

## Properties

- `showAllActivitiesInDivingLogbook`
- `showAllActivitiesInSnorkelingLogbook`
- `showAllActivitiesInApneaLogbook`

## Persistence

Independent `UserDefaults` boolean keys per activity (see `IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW.md`).

## UI

`IOSActivityLogbookVisibilitySettingsSection` embedded in:

- `IOSDivingSettingsEmbeddedContent`
- `IOSSnorkelingSettingsContent`
- `IOSApneaSettingsContent`

Each section includes toggle + activity-specific description footnote.

## Defaults

All toggles default **OFF** on fresh install.
