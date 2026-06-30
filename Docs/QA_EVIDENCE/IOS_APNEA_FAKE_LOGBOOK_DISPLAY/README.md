# Physical QA — IOS_APNEA_FAKE_LOGBOOK_DISPLAY

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-AFL-002 |
| **Command category** | IOS_APNEA_FAKE_LOGBOOK_DISPLAY |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify demo apnea sessions display with DEMO badge and do not mix with real logs ambiguously |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **App build** | |

## Preconditions

- Apnea fake logbook toggle ON.
- Optional: one real apnea session for mixed display test.

## Test steps

1. Enable Settings → Apnea → Demo logbook.
2. Open Apnea logbook / sessions list.
3. Confirm demo sessions visible with DEMO badge.
4. If real sessions exist, confirm Real logs vs Demo logs sections.
5. Open demo session detail; confirm DEMO badge and no export as real.
6. Capture screenshots/video.

## Expected results

Demo sessions clearly marked DEMO. Export disabled for demo entries.

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
