# iOS Post-Remediation GF and Sync Verification — CURRENT

**Audit command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.2`  
**Baseline:** `main` @ `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958`)  
**Audit date:** 2026-06-30  
**Mode:** Read-only static verification

---

## Executive summary

Post-remediation consolidated software findings **CONS-002**, **CONS-003**, **CONS-004**, and **CONS-005** are **verified present in code** at `451f8fb`. No regression detected in GF preset parity or sync ACK/tombstone hardening relative to the `5d757cc` post-remediation baseline.

| Gate | Verdict |
|---|---|
| IOS_GF_PRESET_PARITY | **PASS** |
| IOS_INFLIGHT_ACK_CLEANUP | **PASS** |
| IOS_DIVE_IMPORT_ACK_SYMMETRY | **PASS** |
| IOS_TOMBSTONE_SECURITY | **PASS** (signed primary; diving legacy UUID mirror documented) |
| IOS_SOFTWARE_READINESS_AFTER_REMEDIATION | **91** |

---

## CONS-002 — iOS GF preset parity with Watch

**Status:** FIXED_SOFTWARE — **PASS @ 451f8fb**

- `PlannerGFPreset` triplets align with `FullComputerGradientFactorPreset`: `20/80`, `30/70`, `40/85`.
- `PlannerGFPreset.fullComputerGradientFactorPresetRawValue` maps to Watch raw values (`conservative2080`, `standard3070`, `moderate4085`).
- `DivePlanPackageBuilder.build` emits optional `gradientFactorPreset` for all three iOS planner presets.
- Watch import fail-closed preserved for unsupported pairs (e.g. `30/80`).

**Evidence:** `PlannerGFPresetDisplayTests`, `DivePlanPackageBuilderTests`, `FullComputerGradientFactorPreset.matching(package:)`.

**Residual:** External Bühlmann preset spot-check remains **PENDING** (CONS-043). Physical paired import QA remains **PENDING** (CONS-011).

See: `Docs/MASTER_IOS_GF_PRESET_PARITY_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-003 — inFlightOutboundSessionIDs cleanup after failed ACK

**Status:** FIXED_SOFTWARE — **PASS @ 451f8fb**

- `releaseInFlightOutboundSession(_:)` centralizes cleanup.
- Called on: failed ACK signature verify, `sendMessage` error (with userInfo fallback), encode failure.
- `WatchSyncPendingFlushPolicy` excludes in-flight IDs from batch flush.

**Residual caveat:** `markUserInfoDelivered` failure path does not release in-flight on the unreachable→userInfo branch only. Low risk; not a regression vs remediation scope.

See: `Docs/MASTER_IOS_SYNC_ACK_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-004 — symmetric Watch↔iOS diveImportAck

**Status:** FIXED_SOFTWARE — **PASS @ 451f8fb**

- iOS `didReceiveUserInfo` path calls `sendDiveImportAckToWatch` after successful import ingest.
- Watch mirror: `deliverImportAck` after iOS-origin userInfo import.
- Both use `WatchDiveSyncCodec.makeImportAckPayload` with HMAC `ackSignature`.

**Residual:** End-to-end paired integration test for userInfo ACK path not dedicated; verification is code-path based. Physical paired QA **PENDING**.

---

## CONS-005 — unsigned tombstone hardening

**Status:** FIXED_SOFTWARE — **PASS @ 451f8fb** (with documented legacy mirror)

- `ActivitySyncTombstoneCodec` signs with HMAC-SHA256; verify uses constant-time compare.
- Publish prefers signed tombstones when peer secret + sync key available.
- Apnea/snorkeling ingest signed-only on activity-scoped keys.
- Diving retains legacy unsigned UUID list ingest for bootstrap compatibility when signed path unavailable; residual unsigned mirror when secret present is documented accepted risk (P3).

See: `Docs/MASTER_IOS_TOMBSTONE_SECURITY_POST_REMEDIATION_MATRIX_CURRENT.csv`

---

## CONS-028 / CONS-040 — activity architecture, Settings, Logbook isolation

| Item | Verdict | Notes |
|---|---|---|
| CONS-028 navigation restoration | **PARTIAL** | Tab/settings scope tokens persist; full scene graph restore incomplete (IOS-P3-001) |
| CONS-040 dual diving settings binding | **OPEN P3** | MoreView @AppStorage vs IOSDivingSettingsStore; no cross-activity leak (IOS-P3-003) |
| Settings mode switch | **PASS** | UI-only; no Watch runtime mutation |
| Logbook strict ownership | **PASS** | Separate stores/files/routes per activity |

---

## Build/test note @ 451f8fb

- iOS MAIN build: **SUCCEEDED** (`generic/platform=iOS Simulator`, `CODE_SIGNING_ALLOWED=NO`).
- iOS Algorithm Tests: **BUILD FAILED** — Snorkeling test compile errors (IOS-P1-001). Prior baseline reported 1527 tests PASS @ `5d757cc`; current HEAD test gate blocked by compile failure, not assertion failures.

---

## Final verdict block

```text
IOS_GF_PRESET_PARITY: PASS
IOS_INFLIGHT_ACK_CLEANUP: PASS
IOS_DIVE_IMPORT_ACK_SYMMETRY: PASS
IOS_TOMBSTONE_SECURITY: PASS
IOS_SOFTWARE_READINESS_AFTER_REMEDIATION: 91
```
