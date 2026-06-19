# DIR Diving — Snorkeling iOS/Watch Sync Protocol (Command 11)

**Date:** 2026-06-18  
**Command:** `11_SNORKELING_IOS_WATCH_SYNC_PROTOCOL.md`  
**Gate:** `READY_FOR_SNORKELING_COMMAND_12`

## Summary

Command 11 adds a dedicated WatchConnectivity namespace for snorkeling session sync (Watch → iOS), extending the existing iOS → Watch route package sync from Command 08. Transfers use signed v2 transport envelopes with HMAC, nonce replay protection, signed ACK, persistent pending queues, and idempotent logbook import.

## Delivered

### Shared

- `SnorkelingSessionMerge` — completeness-based merge for track, dips, markers, events, route plans, profile, equipment, buddy, warnings
- `SnorkelingSessionSyncImportPolicy` + `SnorkelingSessionSyncImportResult` (iOS codec)

### Watch → iOS session transport

- `SnorkelingSessionSyncCodec` (Watch sender + iOS receiver) — payload key `dirdiving_snorkeling_session_sync` (isolated from checkpoint `dirdiving_snorkeling_session`)
- `SnorkelingSyncPendingTransfer` — durable outbound queue
- `WatchSyncService.transferSnorkelingSession` — sendMessage with signed ACK fallback to `transferUserInfo`, flush on reconnect
- `SnorkelingLogbookStore.add` triggers transfer for `.completed` / `.aborted` sessions

### iOS import

- `IOSSnorkelingLogbookStore.mergeImportedSession` — atomic import with duplicate/replay/merge outcomes
- `WatchSyncService.importSnorkelingSessionPayload` — routes to logbook, activity log, signed reply ACK
- `IOSSnorkelingSessionSyncService` — dashboard session sync presentation state

### iOS → Watch (existing, unchanged namespace)

- Route/profile package via `SnorkelingRouteSyncTransferSupport` (Command 08) — profile, route, waypoints, markers, alarms, mission mode, revision

### UI

- Dashboard sync card shows **Route** and **Sessions** lines (local-only, pending, up-to-date, imported/merged, failed)

### Cross-domain isolation

- `SnorkelingReleaseSelfCheck.sessionSyncPayloadKey`
- `SnorkelingCrossDomainIsolationTests` extended for sync key collision checks

### Localization

- EN/IT: `snorkeling.sync.*`, `snorkeling.ios.sync.session.*`, `snorkeling.ios.sync.route_label`, Watch queue strings

### Tests (Command 11 focused)

| Suite | Count | Result |
|-------|------:|--------|
| `SnorkelingSessionSyncCodecTests` | 2 | PASS |
| `SnorkelingSessionSyncTransportNegativeTests` | 5 | XCTSkip (peer keychain) |
| `SnorkelingSessionSyncTransportNegativeWatchTests` | 2 | PASS |
| `SnorkelingCrossDomainIsolationTests` | 6 | PASS |
| **Total focused** | **10** | **PASS** (+ 5 skipped crypto transport) |

Build: **DIRDiving iOS** — BUILD SUCCEEDED.

## Rules preserved

- No fake sync success — ACK-gated Watch outbound queue removal
- Snorkeling WC keys do not collide with dive, apnea, briefing, photo, or settings sync
- No underwater GPS treated as live position in sync payloads

## Gate

`READY_FOR_SNORKELING_COMMAND_12`
