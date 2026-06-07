# Watch GPS lifecycle policy

## Ownership model

- **`DiveManager`** owns continuous GPS updates during an active dive session (`GPSManager.start()` at session start; `stop()` on session end).
- **`GPSManager.captureBestEffortPoint(for:stopUpdatesWhenComplete:completion:)`** performs a timed best-effort fix. It always completes any in-flight capture before starting a new one.
- **Default `stopUpdatesWhenComplete = false`** preserves existing dive entry/exit capture used by `DiveManager` (6 s capture while broader session GPS remains active).
- **One-shot callers** may pass `stopUpdatesWhenComplete: true` to stop updates after the capture completes and avoid unintended battery drain.

## Dive entry / exit

`DiveManager` calls `captureBestEffortPoint(for: 6)` without stopping updates afterward, because session-level GPS remains owned by the dive lifecycle.

## Tests

See `Tests/WatchAlgorithmTests/GPSLifecycleTests.swift` (2026-06-07 audit remediation — placeholder removed).

| Case | Coverage |
|---|---|
| One-shot capture start | Unit test |
| Valid fix completion | Unit test |
| No-fix path — no false success | Unit test |
| Timeout graceful completion | Unit test |
| Denied permission safe path | Unit test |
| Finalization resumes after pending draft | Integration via DiveManager tests |
| Invalid coordinate rejected | Unit test |

Physical GPS accuracy and underwater antenna behavior require Ultra field QA.
