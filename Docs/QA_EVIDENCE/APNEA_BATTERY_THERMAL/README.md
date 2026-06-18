# APNEA_BATTERY_THERMAL — Physical QA evidence

**Status:** `PENDING`  
**Scope:** Watch Ultra battery and thermal baseline during a representative Apnea session (Mission Mode compatible).

## Prerequisites

- Apple Watch Ultra (49 mm) on watchOS matching release candidate
- Paired iPhone on matching iOS build
- App SHA recorded from `git rev-parse HEAD`
- Starting battery ≥ 80% recommended for comparable runs

## Device matrix

| Field | Value |
|-------|-------|
| Watch model | _e.g. Apple Watch Ultra 3 (49 mm)_ |
| watchOS version | _record exact build_ |
| iPhone model | _if sync exercised_ |
| iOS version | _if sync exercised_ |
| App SHA | _commit hash_ |
| Tester | _name_ |
| Date | _YYYY-MM-DD_ |

## Procedure

1. Note starting battery % and wrist temperature observation (if visible in Settings).
2. Start Apnea from Watch MAIN; arm session with depth sensor available.
3. Complete at least two dives with recovery intervals (pool or open water).
4. Suspend/resume once via OS lifecycle (raise wrist, background app, return).
5. End session; note ending battery % and any thermal warning.
6. Optional: repeat with airplane mode (offline autonomy) and sync after reconnect.

## Expected limits (internal code review — not guarantees)

- No unbounded checkpoint write loop during session
- Haptic rate limiting active (`AscentSafetyHapticCoordinator` / operational event engine)
- Sync retry backoff when online
- No canonical `Timer.scheduledTimer` for Apnea elapsed time

## Observed result

| Metric | Observed |
|--------|----------|
| Starting battery % | |
| Ending battery % | |
| Session duration | |
| Number of dives | |
| Mission Mode | |
| Sensor state | |
| Temperature observation | |
| Evidence files | _screenshots, sysdiagnose refs_ |

## PASS / FAIL

| Result | Requirement |
|--------|-------------|
| **PASS** | Evidence attached; no unexpected thermal shutdown; battery drain within team-agreed baseline |
| **FAIL** | Document failure mode and attach logs |

**Rule:** Do not mark PASS without attached evidence files in this folder.
