# Physical QA — APNEA_IOS_EXPORT

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-009 |
| **Priority** | P3 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Apnea session share/export (`ApneaExportPayloadBuilder`, `IOSApneaSessionExportView`) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Apple Watch model** | |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |

## Preconditions

- Real Apnea session in logbook
- Optional: DEMO session with fake logbook ON

## Test steps

1. Open real session → Share / Export.
2. Confirm text payload includes: profile, date, holds, best/avg hold, max depth, avg recovery, data quality, notes.
3. Share via share sheet; verify content in Notes/Messages.
4. Export DEMO session; confirm **DEMO** badge in payload.
5. Confirm no export presents data as medical certification.
6. Capture screenshot of shared text.

## Expected results

Text share sheet works. DEMO clearly marked. Real and demo not conflated.

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

**PENDING** — PASS requires device evidence and signatures.
