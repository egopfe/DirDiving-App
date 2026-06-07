# Watch-iOS Sync QA Matrix

Owner: ________  Date: ________  Build: ________  Commit: ________

**Automated coverage (2026-06-07):** `WatchSyncPendingQueueTests`, `WatchSyncServiceIntegrationTests` (keychain-dependent cases skip in CI).  
**Policy:** Pending queue dequeues **only** on verified signed ACK; `transferUserInfo` delivery alone does not dequeue.

| Scenario | Pass/Fail | Evidence | Notes |
|---|---|---|---|
| Watch -> iOS immediate sync (`sendMessage` + signed ACK) |  |  | ACK dequeues pending entry |
| iOS -> Watch sync |  |  |  |
| Queued sync retry on companion reachable |  |  | Flush re-attempts pending transfers |
| Manual/no-depth session handling |  |  | See [`WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`](WATCH_MANUAL_NODEPTH_SYNC_POLICY.md) |
| Tombstones — session not re-sent |  |  |  |
| Conflict resolution UI |  |  |  |
| Depth profile merge conflict (local vs iCloud samples) |  |  |  |
| Watch outbound queue — signed ACK received |  |  | `confirmSignedAck` removes session |
| Watch outbound queue — missing/invalid ACK (session stays queued) |  |  | Automated |
| Watch outbound queue — delayed ACK after unreachable |  |  | Physical: iPhone offline then online |
| Watch outbound queue — transferUserInfo fallback (no signed ACK) |  |  | Delivery marked; queue retained until ACK |
| Duplicate userInfo delivery — no duplicate logbook on companion |  |  | Session ID idempotency |
| Peer secret mismatch — no dequeue |  |  |  |
| Pending retention / attempt budget warning |  |  | 7-day / 64-attempt policy |
| Trust reset flow |  |  |  |
| Offline -> online recovery |  |  |  |
| importedFromCompanionIDs deterministic trim |  |  | Lexicographic UUID order |
