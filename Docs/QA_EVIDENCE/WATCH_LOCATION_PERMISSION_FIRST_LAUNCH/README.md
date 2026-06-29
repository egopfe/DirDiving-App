# Physical QA — WATCH_LOCATION_PERMISSION_FIRST_LAUNCH

| Field | Value |
|-------|-------|
| **QA ID** | WATCH-QA-LOC-001 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Tester** | |
| **Reviewer** | |
| **Date/time** | |
| **Apple Watch model** | |
| **watchOS version** | |
| **Paired iPhone model** | |
| **iOS version** | |
| **App build** | |
| **Install type** | fresh install / upgrade |
| **Previous permission state** | notDetermined |
| **Rollback required** | NO |

## Preconditions

- Delete Watch app (fresh install) or reset location for DIR DIVING.
- Complete Watch legal onboarding.

## Steps

1. Install build at recorded commit on paired Watch + iPhone.
2. Complete legal/safety acceptance.
3. Dismiss companion disclaimer if shown.
4. Confirm first-run GPS sheet appears before activity use.
5. Tap **Enable GPS** / **Abilita GPS**.
6. Confirm native watchOS When In Use dialog.
7. Grant permission; confirm sheet does not reappear on next launch.

## Expected result

Native When In Use prompt after user action; non-blocking flow.

## Observed result

**PENDING**

## Verdict

**PENDING**

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |
