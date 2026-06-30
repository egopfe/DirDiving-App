# iOS Apnea & Snorkeling Fake Logbook — Implementation Report

**Date:** 2026-06-17  
**Branch:** `main` (uncommitted at report time)  
**Verdict:** INTERNAL_READY · PHYSICAL_QA_PENDING

## Summary

Implemented iOS-only fake logbook toggles for Apnea and Snorkeling with separate in-memory providers, presentation-layer composition, DEMO badges, and no real-storage contamination.

## Files added

| File | Role |
|------|------|
| `iOSApp/Services/IOSActivityDemoLogbookSettingsStore.swift` | Toggle store (UserDefaults) |
| `iOSApp/Services/FakeApneaLogbookProvider.swift` | 7 demo apnea sessions |
| `iOSApp/Services/FakeSnorkelingLogbookProvider.swift` | 7 demo snorkeling sessions with routes |
| `iOSApp/Models/IOSLogbookDisplayModels.swift` | Display entries + composer |
| `iOSApp/Views/Common/DemoLogbookBadge.swift` | Reusable DEMO badge |
| `Tests/iOSAlgorithmTests/IOSActivityDemoLogbookSettingsStoreTests.swift` | Settings tests |
| `Tests/iOSAlgorithmTests/FakeApneaLogbookProviderTests.swift` | Apnea provider tests |
| `Tests/iOSAlgorithmTests/FakeSnorkelingLogbookProviderTests.swift` | Snorkeling provider tests |
| `Tests/iOSAlgorithmTests/ApneaDemoLogbookPresentationTests.swift` | Presentation tests |
| `Tests/iOSAlgorithmTests/SnorkelingDemoLogbookPresentationTests.swift` | Presentation tests |
| `Docs/IOS_APNEA_SNORKELING_FAKE_LOGBOOK.md` | Feature spec |
| `Docs/QA_EVIDENCE/IOS_*` | QA templates (6) |

## Files modified

| File | Change |
|------|--------|
| `iOSApp/Services/IOSCompanionStoreCoordinator.swift` | Inject `demoLogbookSettings` |
| `iOSApp/Views/Apnea/IOSApneaSettingsContent.swift` | Apnea demo toggle section |
| `iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift` | Snorkeling demo toggle section |
| `iOSApp/Views/Apnea/IOSApneaSessionsListView.swift` | Real/demo sections, stats filter |
| `iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift` | Same |
| `iOSApp/Views/Apnea/IOSApneaSessionDetailView.swift` | Demo badge, export guard |
| `iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift` | Demo badge, map overlay, export guard |
| `iOSApp/Resources/*/Localizable.strings` | EN/IT keys |
| `project.yml` | Test target sources |

## Contamination prevention

- Providers return `[ApneaSession]` / `[SnorkelingSession]` in memory only
- Real stores never receive `append` from fake providers
- Stats use `Demo*SessionCatalog.isDemoSession` filter
- Detail export UI hidden for `isDemoSession`

## Sync / export prevention

- Demo sessions exist only in presentation layer on iOS
- No Watch transfer path for demo catalog IDs
- Export buttons disabled on demo detail views

## Known limitations

- iOS-only; Watch has no demo logbook toggle
- Physical QA not executed (all QA templates PENDING)
- Diving demo logbook pattern (insert into real store) intentionally not replicated

## Regression scope verified (software)

- Diving fake logbook unchanged
- Apnea/Snorkeling runtime unchanged
- Watch build not required (no Shared runtime changes)
