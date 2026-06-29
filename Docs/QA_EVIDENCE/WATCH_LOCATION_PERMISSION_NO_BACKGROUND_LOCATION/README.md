# Physical QA — WATCH_LOCATION_PERMISSION_NO_BACKGROUND_LOCATION

| Field | Value |
|-------|-------|
| **QA ID** | WATCH-QA-LOC-005 |
| **Status** | **PENDING** |

## Steps

1. Fresh install; complete first-run GPS flow with **Enable GPS** then deny or allow.
2. Inspect Watch app Info.plist / capabilities: no background location mode added.
3. After onboarding **Enable GPS** tap (before granting), verify continuous GPS does not start (no dive/snorkeling session active).
4. Confirm `WKBackgroundModes` unchanged except existing `underwater-depth`.

## Expected result

When In Use only; onboarding does not start tracking; no new background location.

## Observed result

**PENDING**

## Verdict

**PENDING**
