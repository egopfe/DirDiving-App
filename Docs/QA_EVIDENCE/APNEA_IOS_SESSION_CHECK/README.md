# Physical QA — APNEA_IOS_SESSION_CHECK

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-002 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Apnea Session Check UI and `ApneaSessionCheckEvaluator` outcomes |
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

- Valid Apnea profile selected
- Session Check screen reachable before Watch start

## Test steps

1. Open Apnea Session Check with valid profile and recovery alerts ON.
2. Confirm status **Ready** when checklist confirmed and policy valid.
3. Leave buddy checklist unchecked; confirm **Warning** (not blocked).
4. Select Depth profile without depth sensor (simulator OK); confirm depth warning.
5. Verify issue list shows localized messages.
6. Confirm user can proceed despite warnings (non safety-critical).
7. Capture screenshots.

## Expected results

Ready/warning/incomplete states match evaluator. Warnings do not block except incomplete config. No "safe to dive" wording.

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
