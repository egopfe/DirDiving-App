# MAIN Physical & External QA Checklist

Baseline: `main` @ `a6ccd8d` + iOS MAIN algorithm math remediation ([`IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md`](IOS_MAIN_ALGORITHM_MATH_REMEDIATION_REPORT_CURRENT.md)). **Simulator/build/test gates for non-physical fixes are complete; this checklist is unchanged.** Every item below remains **PENDING** until executed on hardware with recorded evidence. **App Store readiness must not be claimed until this checklist and external Bühlmann validation are complete.**

## Watch Ultra underwater / sensor QA

| Item | Status | Evidence |
|---|---|---|
| Watch Ultra underwater depth sensor accuracy vs reference | PENDING | |
| Auto start/stop depth thresholds in water | PENDING | |
| 35 m caution warning underwater | PENDING | |
| 38 m strong warning underwater | PENDING | |
| 40 m critical warning underwater | PENDING | |
| Haptic behavior underwater (ascent + depth limits) | PENDING | |
| GPS entry/exit lifecycle on real dive | PENDING | |

## Paired Watch ↔ iPhone sync QA

| Item | Status | Evidence |
|---|---|---|
| Paired direct dive-session sync (reachable) | PENDING | |
| Paired queued/offline sync (`transferUserInfo`) | PENDING | |
| Signed import ACK required before iOS clears pending | PENDING | |
| Signed ACK rejection leaves pending retryable | PENDING | |
| Peer-secret mismatch / reset recovery | PENDING | |
| Signed photo inventory request/response | PENDING | |
| Signed photo delete request/ACK | PENDING | |
| Replay rejection for signed management messages | PENDING | |

## iCloud & privacy QA

| Item | Status | Evidence |
|---|---|---|
| iCloud two-device conflict merge | PENDING | |
| iCloud tombstone propagation | PENDING | |
| PDF export stored in protected app directory | PENDING | |
| CSV import/export privacy on device | PENDING | |

## External validation

| Item | Status | Evidence |
|---|---|---|
| Subsurface CSV import validation (real exports) | PENDING | |
| Subsurface-compatible export round-trip | PENDING | |

## Scope confirmation

- Experimental targets (Apnea, Snorkeling, Buddy Assist, Exploration) were **not** modified in this remediation pass.
- Legal/safety disclaimers and safety gates were **not** weakened.
- No TestFlight, External TestFlight, or App Store readiness is claimed by this checklist alone.
