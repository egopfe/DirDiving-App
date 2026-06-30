# Physical QA — IOS_FAKE_LOGBOOK_NO_REAL_STORAGE_CONTAMINATION

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-FL-003 |
| **Command category** | IOS_FAKE_LOGBOOK_NO_REAL_STORAGE_CONTAMINATION |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify demo sessions are not persisted in real Apnea/Snorkeling logbook storage |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **App build** | |

## Preconditions

- Empty or known real logbook state before test.
- Both fake logbook toggles available.

## Test steps

1. Record real session count (or storage snapshot) for Apnea and Snorkeling.
2. Enable both fake logbook toggles; view demo sessions in UI.
3. Disable toggles; confirm demo sessions disappear from UI.
4. Inspect on-disk / UserDefaults / store files — real session count unchanged.
5. Relaunch with toggles OFF; confirm no demo IDs in persisted storage.

## Expected results

No demo catalog UUIDs written to real logbook persistence.

## Observed results

**PENDING**

## Storage inspection evidence

- (none)

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |

## Verdict

**PENDING**
