# MASTER iOS V1.7 Demo Logbook Fix Audit (CURRENT)

**Reference implementation doc:** `Docs/DIRDIVING_IOS_DIVING_DEMO_LOGBOOK_REGRESSION_FIX_CURRENT.md`  
**Baseline:** `main` @ `7ae527b`

## Audit outcomes

- Demo dives are no longer silently dropped when real sessions exist.
- Demo insertion/removal behavior is idempotent and scoped.
- Unified logbook builder supports activity-specific demo inclusion flags.
- No canonical diving/apnea/snorkeling store merge introduced.
- No watch sync mutation path introduced by demo toggle behavior.

## Evidence

- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Utils/IOSUnifiedLogbookPresentationBuilder.swift`
- `iOSApp/Views/Shared/IOSUnifiedLogbookListView.swift`
- `Tests/iOSAlgorithmTests/IOSDiveLogStoreDemoLogbookTests.swift`
- `Tests/iOSAlgorithmTests/IOSUnifiedLogbookPresentationBuilderTests.swift`
- `Tests/iOSAlgorithmTests/IOSUnifiedLogbookNoContaminationTests.swift`

## Pending gates

- Manual UI walkthrough with mixed real/demo datasets remains pending.

## Verdict

`PASS_SOFTWARE_PARTIAL_RELEASE` (software contamination fix present; manual QA still pending).
