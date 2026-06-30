# Physical QA — APNEA_IOS_CHECKLIST

| Field | Value |
|-------|-------|
| **QA ID** | APN-QA-007 |
| **Priority** | P2 |
| **Command category** | APNEA_IOS_WATCH_P1_P2_P3 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify pre-apnea checklist (`ApneaChecklistCatalog`, `IOSApneaChecklistView`) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **Apple Watch model** | (optional — compact reminder) |
| **watchOS version** | |
| **App build** | |
| **Test environment** | |

## Preconditions

- Apnea checklist accessible from iOS Apnea flow

## Test steps

1. Open pre-apnea checklist; confirm all items default unchecked.
2. Verify EN/IT strings: buddy, recovery, safe area, no hyperventilation, stop signal, watch charged, do not freedive alone.
3. Check items; relaunch app; confirm persistence.
4. Leave buddy unchecked; run Session Check; confirm warning (not block).
5. On Watch (if implemented), confirm compact reminder only (Buddy? Recovery? Ready?).
6. Confirm checklist not saved as safety certification.
7. Capture screenshots.

## Expected results

Non-blocking checklist. Influences session check warnings. Training aid disclaimer present.

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
