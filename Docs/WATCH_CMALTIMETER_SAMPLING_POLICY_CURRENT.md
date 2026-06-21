# Watch CMAltimeter Sampling Policy (Current)

**Updated:** 2026-06-17  
**Applies to:** `FullComputerEnvironmentSensorService` / `FullComputerAltitudeSamplingPolicy`  
**Physical validation:** PENDING_PHYSICAL

## Purpose

Apple Watch absolute altitude (`CMAltimeter`) is sampled only as a **non-authoritative proposal** immediately before Full Computer predive confirmation. The diver must explicitly accept the proposal before it becomes the draft environment, and must commit the profile before dive start.

## Thresholds (software-enforced)

| Parameter | Value | Unit | Rejection behavior |
|-----------|------:|------|-------------------|
| Required usable samples | 5 | count | Continue sampling until timeout |
| Maximum accuracy | 30 | m | Sample discarded |
| Maximum stable spread (last 5) | 12 | m | Continue sampling |
| Sampling timeout | 8 | s | State → `timedOut`, no proposal |
| Sensor record max age | 120 | s | `validateForLiveStart` → stale |
| Altitude range | −500 … 4500 | m | Record creation fails |
| Max consecutive nil-data callbacks | 3 | count | State → `failed` |
| Future timestamp skew tolerance | 5 | s | Sample discarded |

## Freshness

- **Canonical time:** `CMAbsoluteAltitudeData.timestamp` → `FullComputerEnvironmentRecord.capturedAt`
- **Diagnostic receipt time:** callback delivery → `sensorReceivedAt`
- Stale/future sensor timestamps are rejected before proposal creation.

## Pending proposal relaunch policy (WCMA-006)

**Option A — intentionally ephemeral.** `pendingSensorProposal` is **not persisted**. After app relaunch the diver must request sampling again. Manual/imported `draftEnvironment` remains in UserDefaults.

## Safety rationale (software)

- **5 samples / 12 m spread:** reduces single-spike acceptance; conservative for predive proposal (pending physical tuning).
- **30 m accuracy gate:** aligns with `FullComputerEnvironmentRecord.maximumSensorAccuracyMeters`.
- **120 s max age:** prevents stale predive proposals at commit/start boundaries.
- **Explicit acceptance:** no automatic promotion to live authority.

## Physical QA still required

Threshold appropriateness, permission denial, hardware availability, and reference elevation comparison remain **PENDING_PHYSICAL**.
