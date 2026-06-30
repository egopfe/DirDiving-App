# Physical QA — APNEA_DATA_QUALITY_LOGBOOK

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-006 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify data quality on Watch runtime and iOS logbook (`ApneaDataQualityEvaluator`) |
| **Required device** | Paired iPhone + Apple Watch |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Apple Watch model** | |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |
| **Sensor availability** | Record depth/HR availability |

## Preconditions

- Complete at least one real Apnea session synced to iOS logbook

## Test steps

1. During Watch session, note compact sensor labels (SENSORS OK / DEPTH WEAK / HR unavailable).
2. Complete session; sync to iOS.
3. Open session detail on iOS; verify Data quality, depth signal, recovery tracking fields.
4. Compare with session that has sparse/missing depth (if reproducible).
5. Confirm unavailable HR not shown as critical error.
6. Capture screenshots.

## Expected results

Quality levels good/medium/poor/unavailable reflected honestly. No invented sensor data. Logbook matches Watch session.

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
