# Physical QA — APNEA_IOS_STATISTICS

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-008 |
| **Priority** | P2 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Apnea statistics and trends (`ApneaStatisticsCalculator`) |
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

- At least 2 real synced Apnea sessions in logbook
- Fake logbook toggle available (default OFF)

## Test steps

1. With fake logbook OFF, open Apnea statistics/dashboard.
2. Verify metrics: session count, hold count, best hold, avg hold/recovery, by profile.
3. Enable fake logbook; confirm DEMO sessions show DEMO badge.
4. Confirm DEMO sessions excluded from real statistics / personal bests.
5. Mark incomplete session if available; confirm labeled in stats.
6. Capture screenshots.

## Expected results

Real stats exclude DEMO. Incomplete data labeled. No medical ranking claims.

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
