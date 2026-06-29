# Physical QA — IOS_LOCATION_PERMISSION_FIRST_LAUNCH

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-LOC-001 |
| **Status** | **PENDING** |
| **Branch** | (record at execution) |
| **Commit** | (record at execution) |
| **Tester** | |
| **Reviewer** | |
| **Date/time** | |
| **iPhone model** | |
| **iOS version** | |
| **App build** | |
| **Install type** | fresh install / upgrade |
| **Previous permission state** | notDetermined / denied / authorizedWhenInUse |
| **Rollback required** | NO |

## Preconditions

- Delete app from device (fresh install) OR reset location permission for DIR DIVING in Settings.
- Legal onboarding completable.

## Steps

1. Install build at recorded commit.
2. Complete legal onboarding if shown.
3. Confirm first-launch location sheet appears before activity mode selection.
4. Tap **Consenti posizione** / **Allow location**.
5. Confirm native iOS location dialog appears.
6. Grant permission; confirm sheet dismisses and does not reappear on next cold start.

## Expected result

Native When In Use dialog after user taps allow; sheet not shown again after dismiss or grant.

## Observed result

**PENDING**

## Evidence

- (screenshots / video paths)

## Verdict

**PENDING**

## Signatures

| Role | Name | Date |
|------|------|------|
| Tester | | |
| Reviewer | | |
