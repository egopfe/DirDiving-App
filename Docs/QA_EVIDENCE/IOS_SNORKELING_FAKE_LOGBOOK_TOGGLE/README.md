# Physical QA — IOS_SNORKELING_FAKE_LOGBOOK_TOGGLE

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-SFL-001 |
| **Command category** | IOS_SNORKELING_FAKE_LOGBOOK_TOGGLE |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Snorkeling fake logbook toggle (default OFF, independent from Apnea) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **App build** | |

## Preconditions

- Cleared `dirdiving.ios.snorkeling.fakeLogbook.enabled` key.
- Settings → Snorkeling accessible.

## Test steps

1. Confirm Snorkeling demo logbook toggle OFF by default.
2. Enable toggle; relaunch app; confirm ON.
3. With Apnea toggle OFF, confirm Snorkeling toggle independent.
4. Disable and verify persistence OFF.
5. Capture screenshots.

## Expected results

Default OFF. Independent from Apnea toggle.

## Observed results

**PENDING**

## Evidence artifacts

- (none)

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |

## Verdict

**PENDING**
