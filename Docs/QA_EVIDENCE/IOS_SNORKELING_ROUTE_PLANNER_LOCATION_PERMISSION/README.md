# Physical QA — IOS_SNORKELING_ROUTE_PLANNER_LOCATION_PERMISSION

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-LOC-002 |
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
| **Previous permission state** | notDetermined |
| **Rollback required** | NO |

## Preconditions

- Snorkeling mode selected on iOS companion.
- Location permission **notDetermined** (reset in Settings or fresh install, skip first-launch allow if testing in-planner CTA).

## Steps

1. Open Snorkeling → Route Planner.
2. Confirm map placeholder and **Abilita posizione GPS** banner.
3. Tap **Abilita posizione GPS**.
4. Confirm native iOS dialog; grant permission.
5. Confirm interactive map appears (entry / waypoint / exit).

## Expected result

Route Planner triggers system permission request and shows map after grant.

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
