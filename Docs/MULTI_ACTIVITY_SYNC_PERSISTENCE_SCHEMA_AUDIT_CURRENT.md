# Multi-Activity Sync, Persistence & Schema Audit (Current)

**Command:** 8 — `8-DIR_DIVING_SYNC_PERSISTENCE_SCHEMA_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main` @ `2aee901`  
**Working tree at audit start:** Dirty (Command 7 remediation uncommitted)  
**Task type:** Read-only audit (reports only)

Environmental limitations: Two-device paired sync, tombstone propagation under field conditions, and iCloud KVS restore on physical hardware not executed in this pass.

---

## Executive summary

Watch ↔ iOS sync for Diving, Apnea, and Snorkeling uses **separate payload keys, codecs, pending queues, and logbook stores**, unified by **WatchSyncAuth HMAC v2** and **WatchSyncService** key-based routing. Mandatory route checks (**Diving→Diving, Apnea→Apnea, Snorkeling→Snorkeling**) are satisfied in production import paths.

Primary gaps: **WC tombstone broadcast is Diving-only**; **iOS cloud backup toggle is shared-scoped but upload is Diving-only**; **no payload chunking** for oversized sessions; **no end-to-end cross-decode rejection test** through `WatchSyncService`.

| Dimension | Score (0–100) |
|-----------|---------------|
| Diving sync | **87** |
| Apnea sync | **86** |
| Snorkeling sync | **85** |
| Cross-activity isolation | **88** |
| Backup/restore | **62** |
| **Overall** | **82** |

**P0 findings:** 0  
**P1 findings:** 2  
**P2 findings:** 3  
**P3 findings:** 3

---

## Architecture overview

Activity routing is **key-based** (no shared envelope `activityType` field):

```text
dirdiving_dive_session              → DiveLogStore / IOS DiveLogStore
dirdiving_apnea_session             → ApneaLogbookStore / IOSApneaLogbookStore
dirdiving_snorkeling_session_sync   → SnorkelingLogbookStore / IOSSnorkelingLogbookStore
```

Plan, briefing, and photo routes use separate `transferType` strings (see `SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv`).

Transport: HMAC-SHA256 v2 signed envelope (`schemaVersion = 2`), bundle ID binding, nonce replay cache, signed import ACKs.

---

## Audit checklist

| Area | Status | Evidence |
|------|--------|----------|
| Shared transport envelope (HMAC v2) | **PASS** | `WatchDiveSyncCodec`, `ApneaSessionSyncCodec`, `SnorkelingSessionSyncCodec` |
| Activity discriminator | **PARTIAL** | Distinct payload keys; no single envelope enum |
| Separate codecs | **PASS** | Three codec enums per platform |
| Separate stores | **PASS** | Distinct logbook stores and filenames |
| Revision / checksum | **PASS** | Dive plan SHA-256; FC checkpoint checksum; briefing content hash |
| HMAC / peer trust | **PASS** | `WatchSyncAuth`, TOFU pinning, `WatchSyncPeerSecretPinningIOSTests` |
| ACK / retry / idempotency | **PARTIAL** | Signed ACK all three activities; iOS outbound dequeue waits signed ACK for diving |
| Payload chunking | **FAIL** | `maxPayloadBytes` ~512 KB; no reassembly |
| Large profile transfer | **PARTIAL** | Dive samples capped; file transfer for photos/briefing only |
| Out-of-order delivery | **PARTIAL** | Per-session merge + nonce replay; no sequence field |
| Tombstones | **PARTIAL** | Diving WC + KVS; Apnea Watch KVS only; Snorkeling none |
| Conflict resolution (Diving) | **PASS** | `WatchSyncSessionDiff`, conflict file, `WatchSyncConflictTests` |
| Corrupt / future schema | **PASS** | `unsupportedVersion`; `ApneaSchemaMigration`, `SnorkelingSchemaMigration`; `CloudSyncLegacyMigrationPolicy` |
| Legacy Diving KVS migration | **PASS** | `CloudSyncLegacyMigrationPolicy`, `MainDeepCodeReadinessCurrentTests` |
| FC tissue checkpoints | **PASS** | `FullComputerRuntimeCheckpointCodec`, `FullComputerRecoveryCheckpointTests` |
| Apnea multi-dive sessions | **PASS** | `ApneaSessionMergeIntegrityTests` |
| Snorkeling track + dips | **PARTIAL** | Dips tested in sync codec; trackPoints not explicitly in sync tests |
| Settings payload namespaces | **PASS** | `ActivitySettingsVisibility`, WC applicationContext keys |
| Plan/card/photo separation | **PASS** | `FullComputerNamespaceIsolationTests`, `SnorkelingCrossDomainIsolationTests` |
| Backup/restore isolation | **PARTIAL** | Diving iOS opt-in; Apnea/Snorkeling iOS local-only |
| Cross-decoding rejection | **PARTIAL** | Key guards; no E2E wrong-codec-through-service test |
| Mandatory routes | **PASS** | Import paths bind to owning store only |

---

## Findings register

| ID | Sev | Summary | Location |
|----|-----|---------|----------|
| SYNC-P1-001 | P1 | WC tombstone broadcast (`dirdiving_deleted_session_ids`) is **Diving-only**; Apnea has Watch KVS tombstones but no WC broadcast; Snorkeling has neither | `WatchSyncService.publishDeletedSessionIDs` |
| SYNC-P1-002 | P1 | `dirdiving_ios_cloud_backup_enabled` is shared-scoped but iOS upload path is **Diving-only** (`DiveLogStore.syncCloudSessionsBackup`) | `CloudBackupSettings`, `ApneaCloudCapability` |
| SYNC-P2-001 | P2 | No integration test feeding dive transport into Apnea/Snorkeling import paths | Test gap |
| SYNC-P2-002 | P2 | No payload chunking; oversized sessions fail closed at ~512 KB | Session codecs `maxPayloadBytes` |
| SYNC-P2-003 | P2 | Snorkeling Watch logbook has no iCloud/tombstone path (local file only) | `SnorkelingLogbookStore` |
| SYNC-P3-001 | P3 | No symmetric `DiveSessionSyncTransportNegativeTests` mirroring Apnea/Snorkeling | Test inventory |
| SYNC-P3-002 | P3 | External docs may reference FC checkpoint schema v5; code uses `currentSchemaVersion = 1` | `FullComputerRuntimeCheckpointPayload` |
| SYNC-P3-003 | P3 | No explicit `activityType` in transport envelope (key-based design) | By design |

---

## Key test evidence

- `ApneaSessionSyncTransportNegativeTests` — future version, replay, wrong bundle, invalid signature
- `SnorkelingSessionSyncTransportNegativeTests` — stale timestamp, ACK round-trip
- `WatchSyncConflictTests` — signed ACK verification
- `FullComputerNamespaceIsolationTests` — FC vs Apnea plan ACK isolation
- `IntegratedModesSequentialFlowTests.testSequentialGaugeFullComputerApneaSnorkelingWithoutCrossDomainBleed`
- `IOSActivityLogbookDataIsolationTests` — separate storage files

---

## Related deliverables

- `Docs/SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv`
- `Docs/SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv`
- `Docs/BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv`
- `Docs/MAIN_SYNC_DATA_INTEGRITY_MATRIX_CURRENT.csv` (prior deep-code audit)

---

**Audit completed:** 2026-06-20 on `main` @ `2aee901`.
