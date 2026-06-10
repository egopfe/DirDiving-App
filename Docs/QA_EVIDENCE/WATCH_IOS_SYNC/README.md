# Watch ↔ iOS Sync — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/WATCH_IOS_SYNC_QA_MATRIX.md`](../../WATCH_IOS_SYNC_QA_MATRIX.md)  
**Device checklist:** [`Docs/WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md`](../../WATCH_IOS_SYNC_DEVICE_QA_CHECKLIST.md)

---

## Scope

Paired physical iPhone + Apple Watch sync validation: signed ACK dequeue policy, offline queue flush, tombstone/idempotency, trust reset, manual no-depth session policy, and CCR reference-data boundaries (Watch has no CCR live loop). Automated tests (`WatchSyncPendingQueueTests`, `WatchSyncServiceIntegrationTests`) cover logic only.

---

## Required device / simulator matrix

| Component | Requirement |
|-----------|-------------|
| iPhone | Physical device, iOS release target |
| Apple Watch | Physical device, watchOS release target |
| Network | Offline → online recovery scenarios |
| Builds | Matching commit on both targets |

Minimum external gate: WS-01…WS-05 per [`Docs/RELEASE_CHECKLIST.md`](../../RELEASE_CHECKLIST.md).

---

## Required evidence files

- [ ] Watch → iOS immediate sync with signed ACK (logbook entry on iPhone)
- [ ] iOS → Watch sync (if in release scope)
- [ ] Offline queue → online flush with signed ACK
- [ ] Pending queue retained when ACK missing/invalid
- [ ] Tombstone / idempotency — no duplicate logbook after redelivery
- [ ] Trust reset / peer secret mismatch handling (if tested)
- [ ] Manual no-depth session sync policy verification
- [ ] Console or export logs (redact account identifiers if sharing externally)

---

## Sign-off

| Field | Value |
|-------|-------|
| iPhone model | |
| iOS version | |
| Watch model | |
| watchOS version | |
| Build number (both targets) | |
| Commit SHA | |
| Tester | |
| Date | |
| Pass/Fail | **PENDING** |

Synced CCR metadata on iPhone must not appear as live PPO₂ on Watch.

**Session notes:**

```
(paste pass/fail notes per scenario)
```
