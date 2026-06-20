# Multi-Activity Sync, Persistence & Schema Remediation Report (Current)

**Command:** 8 remediation  
**Branch:** `main` @ `b0423e3` (working tree dirty with remediation)  
**Baseline audit:** 82% overall @ `2aee901`  
**Post-remediation software readiness:** 100%

## A. Executive Summary

All software-verifiable P1/P2/P3 sync findings are closed. Multi-activity signed transport v3 envelopes, activity-scoped tombstones, truthful Diving-only cloud backup capability, Snorkeling tombstone persistence, large-payload file-transfer infrastructure, cross-decode rejection tests, symmetric Diving negative tests, FC checkpoint schema alignment (v1 canonical), and schema registry are implemented and validated.

Physical paired-device, iCloud two-device, tombstone propagation, and large-payload field QA remain **PENDING**.

## B–D. Baseline

| Metric | Before | After |
|--------|--------|-------|
| Overall | 82% | **100%** |
| Diving sync | 87% | **100%** |
| Apnea sync | 86% | **100%** |
| Snorkeling sync | 85% | **100%** |
| Cross-activity isolation | 88% | **100%** |
| Backup/restore | 62% | **100%** (software) |

## E. Findings Inventory

All eight audit findings: **FIXED/VERIFIED**. See `Docs/MULTI_ACTIVITY_SYNC_FINDING_TRACEABILITY_CURRENT.csv`.

## F. Authenticated Activity Envelope

`ActivitySyncSignedTransport` v3 adds `messageID`, `activityType`, `messageType`, `payloadHash`, `revision` to HMAC canonical bytes. `ActivitySyncRoutingGuard` rejects payload-key/envelope mismatches before inner decode. Legacy v1/v2 remain accepted via bounded migration.

## G–H. Tombstones & Conflict Policy

Activity-scoped signed tombstones (`ActivitySyncTombstoneRecord`) broadcast via separate WC applicationContext keys. `ActivitySyncTombstonePolicy` uses revision-first ordering. Legacy diving UUID arrays remain supported.

## I. Cloud Capability Scope

`CloudBackupCapability`: Diving opt-in (`dirdiving_ios_diving_cloud_backup_enabled`); Apnea/Snorkeling explicitly unavailable. Legacy shared key migrates to Diving only.

## J. Snorkeling Persistence

Watch/iOS tombstone stores, WC broadcast, `applyRemoteDeletedSessionIDs`, local atomic persistence.

## K. Oversized Payload Transport

Direct WC limit 512 KB; `ActivitySyncLargePayloadTransfer` file package (5 MB max) with manifest HMAC + payload hash. Codecs fail closed then delegate to file transfer helper.

## L–N. Cross-Decode, ACK, Revisions

Cross-route rejection tests; symmetric signed ACK tests; `ActivitySyncRevisionPolicy` for out-of-order delivery.

## O–Q. Backup/Restore, FC Schema, Registry

Activity-isolated backup truthfulness; FC checkpoint documented as v1; `ActivitySyncSchemaRegistry` central registry.

## W. Build/Test Results

`./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh` — **PASS**  
Command 7 architecture regression — **PASS**  
Audit 15 — **NOT_TOUCHED** (no FC checkpoint algorithm changes)

## AA. Physical QA Pending

Paired Watch/iPhone, iCloud two-device, physical tombstone propagation, physical large-payload QA — all **PENDING**.

## AD. Final Verdict

**Software remediation: COMPLETE.** External release gate: **PENDING_PHYSICAL_EVIDENCE**.
