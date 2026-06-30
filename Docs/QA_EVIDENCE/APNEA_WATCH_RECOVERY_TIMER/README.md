# Physical QA — APNEA_WATCH_RECOVERY_TIMER

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-003 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify automatic recovery timer after hold end (`ApneaRecoveryTargetCalculator`) |
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
| **Sensor availability** | Depth / HR as available |

## Preconditions

- Apnea session active on Watch with 2× recovery policy
- Profile synced from iOS

## Test steps

1. Start Apnea session on Watch.
2. Complete a hold (~30–90 s dry run acceptable).
3. Confirm recovery timer starts automatically at hold end.
4. Verify target = 2× last hold (or configured policy).
5. Observe countdown: elapsed / target and remaining.
6. Start new hold before target; confirm new recovery cycle after next hold.
7. End session; confirm recovery state clears.
8. Capture video or screenshots.

## Expected results

Recovery auto-starts. Target matches policy. Zero hold does not crash. No "safe to dive" text.

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
