# Physical QA — IOS_APNEA_FAKE_LOGBOOK_TOGGLE

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-AFL-001 |
| **Command category** | IOS_APNEA_FAKE_LOGBOOK_TOGGLE |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Purpose** | Verify Apnea fake logbook toggle in iOS Settings (default OFF, persists ON/OFF) |
| **Required device** | iPhone |
| **Tester** | |
| **Reviewer** | |
| **Execution date** | |
| **iPhone model** | |
| **iOS version** | |
| **App build** | |
| **Test environment** | |

## Preconditions

- Fresh install or cleared `dirdiving.ios.apnea.fakeLogbook.enabled` UserDefaults key.
- Navigate to Settings → Apnea.

## Test steps

1. Install build at recorded commit.
2. Open Settings → Apnea → Demo logbook section.
3. Confirm toggle **Enable fake apnea logbook** is OFF by default.
4. Enable toggle; kill and relaunch app; confirm still ON.
5. Disable toggle; relaunch; confirm OFF.
6. Capture screenshots.

## Expected results

Toggle defaults OFF. Persists independently from Snorkeling toggle.

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
