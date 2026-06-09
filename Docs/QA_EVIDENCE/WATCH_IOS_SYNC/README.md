# Watch ↔ iOS Sync — Evidence Folder

**Status: PENDING** — Do not mark PASS without attached files.

**Matrix:** [`Docs/WATCH_IOS_SYNC_QA_MATRIX.md`](../../WATCH_IOS_SYNC_QA_MATRIX.md)

Place paired-device screenshots, screen recordings, and sync logs here after executing the Watch-iOS sync matrix on physical iPhone + Apple Watch hardware.

---

## Evidence checklist (copy per test session)

| Field | Value |
|---|---|
| iPhone model | |
| iOS version | |
| Watch model | |
| watchOS version | |
| Build number (both targets) | |
| Commit SHA | |
| Tester | |
| Date | |
| Pass/Fail | **leave blank until evidence attached** |

### Required attachments

- [ ] Watch → iOS immediate sync with signed ACK (screenshot of logbook entry on iPhone)
- [ ] iOS → Watch sync (if applicable to release scope)
- [ ] Offline queue → online flush with signed ACK
- [ ] Pending queue retained when ACK missing/invalid
- [ ] Tombstone / idempotency — no duplicate logbook after redelivery
- [ ] Trust reset / peer secret mismatch handling (if tested)
- [ ] Manual no-depth session sync policy verification
- [ ] Console or export logs (redact account identifiers if sharing externally)

### Notes

- Unit tests (`WatchSyncPendingQueueTests`, `WatchSyncServiceIntegrationTests`) cover logic; **this folder is for paired hardware evidence only**.
- Watch has **no** CCR live loop — synced CCR metadata on iPhone must not appear as live PPO₂ on Watch.

**Session notes:**

```
(paste pass/fail notes per scenario)
```
