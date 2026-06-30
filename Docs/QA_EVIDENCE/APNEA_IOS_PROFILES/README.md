# Physical QA — APNEA_IOS_PROFILES

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-001 |
| **Priority** | P1 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify structured Apnea profiles on iOS (`ApneaSessionProfile`, `ApneaProfileKind`) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Apple Watch model** | (optional — profile sync spot-check) |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |

## Preconditions

- Apnea mode accessible from iOS companion
- Default profile: Free Training

## Test steps

1. Install build at recorded commit.
2. Open Apnea → Profiles.
3. Confirm all six kinds: Static, Dynamic, Depth/Constant Weight, Training Intervals, Recovery Session, Free Training.
4. Select Static Apnea; verify recovery policy and Watch layout hint present.
5. Create/edit custom display name; relaunch app; confirm persistence.
6. Confirm profiles are labeled as training aid (no safety-critical claims).
7. Capture screenshots.

## Expected results

All profile kinds configurable. Default Free Training. Settings persist. No medical/safety-critical wording.

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
