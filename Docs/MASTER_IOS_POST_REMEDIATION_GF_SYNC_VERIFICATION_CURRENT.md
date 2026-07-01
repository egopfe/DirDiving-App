# iOS Post-Remediation GF and Sync Verification — CURRENT

**Audit command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5`  
**Baseline:** `main` @ `2c30412` (`2c30412e777e6ef40a688b9ac11215f32310764f`)  
**Audit date:** 2026-07-01  
**Mode:** Read-only static verification + iOS Algorithm Tests @ `2c30412`

---

## Executive summary

Post-remediation consolidated software findings **CONS-002**, **CONS-003**, **CONS-004**, and **CONS-005** remain **verified present in code and tests** at `2c30412`. **CONS-046 V1.5** command integrity script **PASS**. No regression detected relative to `7a429a7` remediation baseline.

| Gate | Verdict |
|---|---|
| IOS_GF_PRESET_PARITY | **PASS** |
| IOS_INFLIGHT_ACK_CLEANUP | **PASS** |
| IOS_DIVE_IMPORT_ACK_SYMMETRY | **PASS** |
| IOS_TOMBSTONE_SECURITY | **PASS** (signed primary; diving legacy UUID mirror documented) |
| CONS-046 V1.5 | **PASS** |
| IOS_SOFTWARE_READINESS_AFTER_REMEDIATION | **94** |

**Test evidence:** iOS Algorithm Tests **1655 executed, 0 failures** @ `2c30412`.

---

## CONS-002 — iOS GF preset parity with Watch

**Status:** FIXED_SOFTWARE — **PASS @ 2c30412**

- `PlannerGFPreset` triplets align with `FullComputerGradientFactorPreset`: `20/80`, `30/70`, `40/85`.
- `DivePlanPackageBuilder.build` emits optional `gradientFactorPreset` for all three iOS planner presets.
- Watch import fail-closed preserved for unsupported pairs.

**Evidence:** `PlannerGFPresetDisplayTests`, `DivePlanPackageBuilderTests` — PASS in 1655-test run.

See: `Docs/MASTER_IOS_GF_PRESET_PARITY_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-003 — inFlightOutboundSessionIDs cleanup after failed ACK

**Status:** FIXED_SOFTWARE — **PASS @ 2c30412**

- `releaseInFlightOutboundSession(_:)` centralizes cleanup on failed ACK, send error, encode failure.
- `WatchSyncPendingFlushPolicy` excludes in-flight IDs from batch flush.

**Evidence:** `MainDeepCodeAuditRemediationTests`, `WatchSyncConflictTests` — PASS.

See: `Docs/MASTER_IOS_SYNC_ACK_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-004 — symmetric Watch↔iOS diveImportAck

**Status:** FIXED_SOFTWARE — **PASS @ 2c30412**

- iOS `didReceiveUserInfo` path calls `sendDiveImportAckToWatch` after successful import ingest.
- HMAC `ackSignature` via `WatchDiveSyncCodec.makeImportAckPayload`.

**Evidence:** `ActivitySyncSignedAckSymmetryTests`, `WatchSyncConflictTests` — PASS.

---

## CONS-005 — unsigned tombstone hardening

**Status:** FIXED_SOFTWARE — **PASS @ 2c30412**

- `ActivitySyncTombstoneCodec` HMAC-SHA256; constant-time verify.
- Apnea/snorkeling ingest signed-only on activity-scoped keys.
- Diving legacy unsigned UUID mirror documented accepted risk when signed path unavailable.

**Evidence:** `ActivitySyncTombstoneTests` — PASS.

See: `Docs/MASTER_IOS_TOMBSTONE_SECURITY_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-046 — command integrity V1.5

**Status:** FIXED_SOFTWARE — **PASS @ 2c30412**

```bash
bash Scripts/validate_commands_for_cursor_integrity.sh
# PASS: commands_for_cursor integrity (00–07 launch order aligned @ V1.5)
```

---

## CONS-028 / CONS-040 — activity architecture

- Settings/Logbook isolation: **PASS** — routing tests in 1655 suite.
- Navigation restoration: **PARTIAL** — IOS-P3-001.

---

*End of post-remediation verification — V1.5 @ `2c30412`.*
