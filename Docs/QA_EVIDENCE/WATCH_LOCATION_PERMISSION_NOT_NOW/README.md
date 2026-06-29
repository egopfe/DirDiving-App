# Physical QA — WATCH_LOCATION_PERMISSION_NOT_NOW

| Field | Value |
|-------|-------|
| **QA ID** | WATCH-QA-LOC-002 |
| **Status** | **PENDING** |
| **Install type** | fresh install |
| **Previous permission state** | notDetermined |

## Steps

1. Fresh install; complete legal onboarding.
2. On first-run GPS sheet tap **Not now** / **Non ora**.
3. Confirm app continues to Diving Gauge / mode selection without blocking.
4. Cold restart app; confirm first-run sheet does **not** reappear.
5. Open Snorkeling with imported route; confirm GPS notice still offers **Enable GPS** if status remains notDetermined.

## Expected result

Non-blocking dismiss; no infinite first-run loop; feature-level CTA remains.

## Observed result

**PENDING**

## Verdict

**PENDING**
