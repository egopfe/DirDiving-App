# Physical QA — IOS_LOCATION_PERMISSION_DENIED_SETTINGS

| Field | Value |
|-------|-------|
| **QA ID** | IOS-QA-LOC-003 |
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
| **Previous permission state** | denied |
| **Rollback required** | NO |

## Preconditions

- Location permission for DIR DIVING set to **Never** in iOS Settings.

## Steps

1. Open Snorkeling → Route Planner (or any map surface using location).
2. Confirm denied message and **Apri Impostazioni** / **Open Settings** button.
3. Tap button; confirm iOS Settings app opens to DIR DIVING.
4. Enable **While Using the App**; return to app.
5. Confirm map becomes available without repeated system deny loops.

## Expected result

No repeated system prompt when denied; Settings deep link works; map works after user enables in Settings.

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
