# DIR Diving Apnea iOS/Watch Sync and Offline Autonomy — Implementation Report (Current)

**Command:** 11 — APNEA IOS/WATCH SYNC AND OFFLINE AUTONOMY  
**Status:** Implemented  
**Branch baseline:** `integration/full-computer`

## Summary

Dedicated Apnea WatchConnectivity protocol (separate from Diving sync) delivers iOS→Watch plan/profile/settings packages with checksum, revision, signed ACK, snapshot context, and idempotent import. Watch→iOS signed session transport merges into the iOS Apnea logbook with replay protection. Watch Ready UI reads the locally imported plan for target, recovery, alarms, mission mode, and revision.

## iOS → Watch

| Component | Path |
|-----------|------|
| Package model | `Shared/Models/ApneaSyncPackage.swift` |
| Codec / seal / validate | `Shared/Utils/ApneaSyncCodec.swift` |
| WC envelope helpers | `Shared/Utils/ApneaSyncTransferSupport.swift` |
| Package builder | `Shared/Utils/ApneaSyncPackageBuilder.swift` |
| Transfer service | `iOSApp/Services/IOSApneaWatchTransferService.swift` |
| ACK signer (iOS) | `iOSApp/Services/ApneaSyncAckSigner.swift` |

Payload includes plan, profile, settings, `packageID`, `revision`, `schemaVersion`, checksum, capabilities.

## Watch → iOS

| Component | Path |
|-----------|------|
| Session sync codec (Watch) | `Services/ApneaSessionSyncCodec.swift` |
| Session sync codec (iOS) | `iOSApp/Services/ApneaSessionSyncCodec.swift` |
| Import merge policy | `ApneaSessionSyncImportPolicy` in iOS codec file |
| Logbook atomic import | `IOSApneaLogbookStore.mergeImportedSession` |
| Pending queue | `Services/ApneaSyncPendingTransfer.swift` |

Namespace key: `dirdiving_apnea_session` (not `dirdiving_dive_session`).

## Watch offline autonomy

| Component | Path |
|-----------|------|
| Imported plan store | `Services/ApneaImportedPlanStore.swift` |
| WC receiver + ACK | `Services/ApneaSyncWatchReceiver.swift` |
| Ready UI wiring | `Views/ApneaView.swift` |
| Recovery labels | `Shared/Utils/ApneaRecoveryPresentation.swift` |

During an active session, newer plans are stored as pending and activated when the session returns to idle. Stale revisions are rejected without replacing the active plan.

## Sync routing

- **Watch** `WatchSyncService`: Apnea plan `userInfo` + snapshot import; Apnea session outbound queue; dive/briefing/photo paths unchanged.
- **iOS** `WatchSyncService`: Apnea plan ACK → `IOSApneaWatchTransferService`; Apnea session import → `IOSApneaLogbookStore`; dive sync unchanged.

## UI

- **Planner** (`IOSApneaSessionPlannerView`): send only when valid; icon + text states for sending, queued, awaiting ACK (with revision), acknowledged, failed.
- **Watch Ready**: target/recovery/alarms from imported package; revision row; pending-plan notice when session is active.
- **Dashboard**: existing watch connectivity card reused.

## Tests

| Target | File | Coverage |
|--------|------|----------|
| iOS Algorithm Tests | `Tests/iOSAlgorithmTests/ApneaSyncCodecTests.swift` | seal/validate, checksum mismatch, ACK parse, merge policy, logbook import |
| Watch Algorithm Tests | `Tests/WatchAlgorithmTests/ApneaSyncWatchReceiverTests.swift` | import, stale revision, idempotent duplicate, pending while session active |

## Compatibility

- Diving sync (`dirdiving_dive_session`), briefing, photos, and settings use existing namespaces and handlers.
- Apnea uses `apneaSyncPlanPackage`, `apneaSyncPlanPackageAck`, `dirdiving_apnea_session`.

## Mockup alignment

- `APNEA_IOS_03_SESSION_PLANNER` — INVIA AL WATCH with transfer states
- `APNEA_WATCH_01_READY` — target, recovery, alarms, revision after import
- `APNEA_IOS_01_DASHBOARD` / `APNEA_IOS_15_SETTINGS` — planner/settings feed package builder inputs

## Follow-ups (out of scope)

- Command 12 release hardening / full simulator matrix
- Cloud backup for Apnea sessions (preference-only today)
