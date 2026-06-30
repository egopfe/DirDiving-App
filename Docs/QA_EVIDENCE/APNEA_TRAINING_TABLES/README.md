# Physical QA — APNEA_TRAINING_TABLES

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-010 |
| **Priority** | P3 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify CO₂/O₂ training tables (`ApneaTrainingTable`, `IOSApneaTrainingTablesView`) |
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

- Training tables UI accessible on iOS
- Disclaimer acknowledgment required before use

## Test steps

1. Create CO₂ table: verify recovery decreases across steps.
2. Create O₂ table: verify hold increases, recovery fixed.
3. Confirm disclaimer must be acknowledged (`apnea.disclaimer.training_aid`).
4. Start Watch session from table profile; verify coaching layout (Next/Hold/Recovery/Rep).
5. Verify haptics: hold start/end, recovery target, table complete (dry run OK).
6. Confirm not presented as medical program.
7. Capture screenshots/video.

## Expected results

Table builder semantics correct. Watch receives steps. Training aid disclaimer shown.

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
