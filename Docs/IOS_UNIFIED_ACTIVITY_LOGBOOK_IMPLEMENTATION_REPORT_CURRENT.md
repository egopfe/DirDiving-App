# iOS Unified Activity Logbook — Implementation Report (Current)

**Branch:** `main` (local, uncommitted)  
**Baseline commit:** `efda217` — *Implement Watch GPS capture through activity-specific logbooks end-to-end.*  
**Date:** 2026-07-01  

## Final verdict

| Verdict | Status |
|---------|--------|
| `INTERNAL_READY` | ✅ |
| `IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW_READY` | ✅ |
| `PRESENTATION_ONLY_CONFIRMED` | ✅ |
| `NO_CROSS_ACTIVITY_CONTAMINATION` | ✅ |
| `NO_FAKE_DEMO_CONTAMINATION` | ✅ |
| `NO_WATCH_RUNTIME_REGRESSION` | ✅ |
| `NO_SYNC_REGRESSION` | ✅ |
| `NO_ALGORITHM_REGRESSION` | ✅ |
| `PHYSICAL_QA_NOT_REQUIRED_FOR_IOS_PRESENTATION_ONLY` | ✅ |
| `MANUAL_UI_QA_PENDING` | ✅ |

**Not declared:** production-ready without manual UI QA.

---

## Files inspected (audit)

- `IOSCompanionStoreCoordinator.swift`, settings content views (Diving/Snorkeling/Apnea)
- `LogbookView.swift`, `IOSSnorkelingSessionsListView.swift`, `IOSApneaSessionsListView.swift`
- `DiveLogStore`, `IOSSnorkelingLogbookStore`, `IOSApneaLogbookStore`
- `IOSActivityDemoLogbookSettingsStore`, fake logbook providers, demo catalogs
- Localization EN/IT (iOS + root Resources), `project.yml`

## Files changed / added

### New

- `iOSApp/Services/IOSActivityLogbookVisibilitySettingsStore.swift`
- `iOSApp/Models/IOSUnifiedLogbookEntry.swift`
- `iOSApp/Utils/IOSUnifiedLogbookPresentationBuilder.swift`
- `iOSApp/Views/Shared/IOSUnifiedLogbookEntryRow.swift`
- `iOSApp/Views/Shared/IOSUnifiedLogbookListView.swift`
- `iOSApp/Views/Shared/IOSUnifiedLogbookDetailHost.swift`
- `iOSApp/Views/Shared/IOSActivityLogbookVisibilitySettingsSection.swift`
- `Tests/iOSAlgorithmTests/IOSUnifiedLogbookPresentationBuilderTests.swift`
- `Tests/iOSAlgorithmTests/IOSActivityLogbookVisibilitySettingsTests.swift`
- `Tests/iOSAlgorithmTests/IOSUnifiedLogbookNoContaminationTests.swift`
- Docs: `IOS_UNIFIED_ACTIVITY_LOGBOOK_VIEW.md`, `IOS_ACTIVITY_LOGBOOK_VISIBILITY_SETTINGS.md`, `IOS_UNIFIED_LOGBOOK_NO_CONTAMINATION_POLICY.md`
- QA templates (8 folders under `Docs/QA_EVIDENCE/IOS_LOGBOOK_*` and `IOS_UNIFIED_LOGBOOK_*`)

### Modified

- `IOSCompanionStoreCoordinator.swift` — visibility store, `ensureStoresForUnifiedLogbook()`, presentation logbook accessors
- `LogbookView.swift`, `IOSSnorkelingSessionsListView.swift`, `IOSApneaSessionsListView.swift` — conditional unified view
- Settings: `IOSDivingSettingsEmbeddedContent.swift`, `IOSSnorkelingSettingsContent.swift`, `IOSApneaSettingsContent.swift`
- Localization EN/IT (iOS + Resources)
- `project.yml` — test target sources

---

## Settings implementation

`IOSActivityLogbookVisibilitySettingsStore` on coordinator with independent UserDefaults keys:

| Activity | Key | Default |
|----------|-----|---------|
| Diving | `dirdiving.ios.diving.logbook.showAllActivities` | `false` |
| Snorkeling | `dirdiving.ios.snorkeling.logbook.showAllActivities` | `false` |
| Apnea | `dirdiving.ios.apnea.logbook.showAllActivities` | `false` |

Injected globally via `applyGlobalEnvironment`.

## Per-activity toggle UI

Shared `IOSActivityLogbookVisibilitySettingsSection` in each activity Settings → **Logbook** card with toggle + description footnote.

## Presentation model

`IOSUnifiedLogbookEntry` + `IOSUnifiedLogbookActivityKind` + `IOSUnifiedLogbookSelection` — iOS-only, non-persistent. IDs: `{activity}-{uuid}`.

## Mapper

`IOSUnifiedLogbookPresentationBuilder.build(...)` — maps sessions, sorts date descending, excludes demo when `includeDemo == false`.

## Unified UI

- `IOSUnifiedLogbookListView` — aggregated header badge “All activities”, read-only footnote, entry count, list
- `IOSUnifiedLogbookEntryRow` — activity badge (DIVING/SNORKELING/APNEA), metrics, chevron
- `IOSUnifiedLogbookDetailHost` — routes to `DiveDetailView`, `IOSSnorkelingSessionDetailView`, `IOSApneaSessionDetailView` with required environment objects

## Logbook integration

- **Diving:** `LogbookView` shows unified list when diving toggle ON; OFF unchanged
- **Snorkeling:** `IOSSnorkelingSessionsListView` same pattern
- **Apnea:** `IOSApneaSessionsListView` same pattern

## Navigation

Tap entry → `IOSUnifiedLogbookSelection` → activity-specific detail via `navigationDestination`. Cross-activity details call `ensureSnorkelingStores()` / `ensureApneaStores()` only for navigation.

## Fake/demo exclusion

Unified real view uses `includeDemo: false`. Demo catalog IDs and `isDemoDive` filtered in builder.

## Tests added

- `IOSUnifiedLogbookPresentationBuilderTests` (9 tests)
- `IOSActivityLogbookVisibilitySettingsTests` (8 tests)
- `IOSUnifiedLogbookNoContaminationTests` (5 tests)

## Tests executed

```
xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:...IOSUnifiedLogbook* ...IOSActivityLogbookVisibility*
```

**Result:** 22 tests, 0 failures.

## Build results

| Target | Result |
|--------|--------|
| DIRDiving iOS | **BUILD SUCCEEDED** |
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS Algorithm Tests (unified subset) | **TEST SUCCEEDED** |

## Localization

Added `logbook.visibility.*`, `logbook.unified.*`, `logbook.activity.*` (EN/IT, iOS + Resources).  
`./Scripts/audit_localization.sh` — **PASS**

## Scripts

| Script | Result |
|--------|--------|
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS |
| `check_main_target_isolation.sh` | PASS |
| `validate_snorkeling_release_readiness.sh` | PASS (pre-existing catalog warnings for unrelated folders) |

## Known limitations (P1)

- No cross-activity statistics or unified export
- Unified view is read-only (no delete/edit from aggregated list)
- Manual UI QA not executed — all QA templates **PENDING**
- Full iOS algorithm test suite not re-run in this pass (new tests pass; recommend full CI)

## Docs / QA

- 3 policy/feature docs created
- 8 QA evidence templates created (PENDING)
