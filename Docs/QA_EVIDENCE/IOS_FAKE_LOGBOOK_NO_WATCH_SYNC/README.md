# Physical QA — IOS_FAKE_LOGBOOK_NO_WATCH_SYNC

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-FL-004 |
| **Command category** | IOS_FAKE_LOGBOOK_NO_WATCH_SYNC |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify demo Apnea/Snorkeling sessions are not synced to Watch as real logs |
| **Required device** | iPhone + paired Apple Watch |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Watch model** | |
| **watchOS version** | |
| **App build** | |

## Preconditions

- Paired Watch with DIR Diving installed.
- iOS fake logbook toggles ON for activity under test.

## Test steps

1. Enable iOS Apnea fake logbook; view demo sessions on iPhone.
2. On Watch, open Apnea logbook; confirm demo sessions **not** present.
3. Repeat for Snorkeling fake logbook.
4. Capture Watch screenshots and sync logs if available.

## Expected results

Demo sessions remain iOS presentation-only; Watch logbook unchanged.

## Observed results

**PENDING**

## Sync inspection evidence

- (none)

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |

## Verdict

**PENDING**
