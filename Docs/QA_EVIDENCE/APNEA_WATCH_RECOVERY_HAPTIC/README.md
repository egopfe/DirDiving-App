# Physical QA — APNEA_WATCH_RECOVERY_HAPTIC

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-004 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify one-shot recovery haptic and latch reset per cycle |
| **Required device** | Apple Watch (physical — haptic) |
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

- Recovery alerts enabled on profile
- Short hold for quick recovery target (e.g. 15 s hold, 30 s recovery)

## Test steps

1. Complete hold; wait for recovery target.
2. Confirm single notification haptic at target (not repeating).
3. Confirm UI shows "Recovery target reached" / localized equivalent.
4. Remain on recovery screen 30 s; confirm no additional haptics.
5. Start next hold; complete; confirm haptic fires again once for new cycle.
6. Note observed haptic behavior in log.

## Expected results

One haptic per recovery completion. Latch resets on new hold. Reminder wording only — not authorization.

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

**PENDING** — PASS requires physical Watch haptic evidence and signatures.
