# Physical QA — APNEA_WATCH_PROFILE_RUNTIME_LAYOUT

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-005 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Watch layout adapts to profile (`ApneaWatchProfileLayoutPresentation`) |
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

## Preconditions

- Profiles configured on iOS for Static, Dynamic, Depth, Free Training

## Test steps

1. **Static Apnea:** confirm HOLD, RECOVERY (elapsed/target), REP n/m visible.
2. **Dynamic Apnea:** confirm HOLD, REP count, RECOVERY (no overcrowded screen).
3. **Depth / Constant Weight:** confirm DEPTH, MAX, TIME, RECOVERY when depth available.
4. **Free Training:** confirm HOLD, RECOVERY, compact SENSORS strip.
5. Verify layout changes only when profile changed on iOS (not auto mid-session).
6. Capture screenshots per profile.

## Expected results

Layout matches profile kind. Readable on smallest supported Watch. Multi-page OK if used.

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
