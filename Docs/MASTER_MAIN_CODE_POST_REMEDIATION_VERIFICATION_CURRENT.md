# DIR DIVING — Main Code Post-Remediation Verification (Current)

**Audit command:** 04 — `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.2`  
**Date:** 2026-06-30  
**Branch:** `main`  
**Commit:** `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958`)  
**Baseline requested:** `451f8fb`

---

## Summary

Cross-cutting software remediations CONS-003 through CONS-007 and CONS-019/027 remain **verified in production code** at `451f8fb`. Post-remediation consolidated outputs under `Docs/MASTER_CONSOLIDATED_*` are **present** and were read for context.

| Gate | Verdict |
|------|---------|
| MAIN_SYNC_SECURITY_REMEDIATION | **PASS** (software) |
| MAIN_DEPTH_CAPABILITY_REMEDIATION | **PASS** (software) |
| MAIN_COMMAND_INTEGRITY | **FAIL** (script paths stale — MAIN-P1-001) |
| MAIN_SOFTWARE_READINESS_AFTER_REMEDIATION | **92** |

---

## CONS cross-check @ 451f8fb

| ID | Area | Code verification | Status |
|----|------|-------------------|--------|
| CONS-003 | iOS in-flight ACK cleanup | `releaseInFlightOutboundSession` on send/ACK/encode errors | PASS |
| CONS-004 | Symmetric diveImportAck | `sendDiveImportAckToWatch` after userInfo import | PASS |
| CONS-005 | Signed tombstones | `ActivitySyncTombstoneBroadcast.verifiedSessionIDs` primary | PASS |
| CONS-006 | Shallow dev toggles | Default OFF; dev section gated | PASS |
| CONS-007 | Depth compile authority | `runtimeAuthorityTier` over plist metadata | PASS |
| CONS-019 | WAO DepthCapabilityPolicy | `resolveAutomaticStep` gates FC before predive | PASS |
| CONS-027 | PlannerStore deinit | `planningUpdateTask?.cancel()` + `saveTask?.cancel()` | PASS |
| CONS-046 | Command integrity script | Script expects V2.1/V1.1 filenames | **FAIL** |

---

## Snorkeling P1/P2/P3 scope

- **SnorkelingRouteSyncCodec** (`Shared/Utils/SnorkelingRouteSyncCodec.swift`): schema v1, checksum, TTL, route validation — **PASS** (static).
- **Snorkeling session sync codec** v3 envelope with activity discriminator — **PASS** (static).
- **iOS test lane:** `SnorkelingRouteProfileTests` compile failure blocks automated regression (**MAIN-P2-001**).
- **Physical QA:** 12 `SNORKELING_*` templates **PENDING_PHYSICAL** (**MAIN-P2-002** / CONS-048).

---

## Build/test evidence (this pass)

| Command | Result |
|---------|--------|
| `check_main_target_isolation.sh` | PASS |
| `check_secrets.sh` | PASS |
| `audit_localization.sh` | PASS |
| iOS MAIN build (`DIRDiving iOS`) | BUILD SUCCEEDED |
| Watch MAIN build (`DIRDiving Watch App`) | BUILD SUCCEEDED |
| Watch remediation subset (8 tests) | TEST SUCCEEDED |
| iOS remediation test subset | **BLOCKED** — test target compile fail (MAIN-P2-001) |
| `validate_commands_for_cursor_integrity.sh` | **FAIL** exit 1 |

---

## Physical / external gates (not converted)

All physical Watch/iPhone, paired-device, Instruments, underwater, and external Bühlmann validation gates remain **PENDING** unless signed artifacts exist in `Docs/QA_EVIDENCE/`.
