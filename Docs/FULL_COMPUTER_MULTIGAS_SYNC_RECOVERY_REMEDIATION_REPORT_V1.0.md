# Full Computer Multigas / Sync / Recovery — Remediation Report V1.0

**Date:** 2026-06-17  
**Authoritative audit:** `Docs/AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_CURRENT.md` (baseline `5b842e1`)  
**Starting branch:** `main` @ `a1a2462`  
**Task:** Close Audit 03 P2/P3 findings to 100% internal readiness (Commands 07–10)

---

## Executive summary

Remediation implements **Policy A** for travel and bailout gases (no schema change), hardens `FullComputerImportedPlanStore` and `confirmGasSwitch`, and adds **62+ automated tests** across Watch and iOS targets. All builds and full algorithm suites pass.

---

## Policy decisions

### Travel gas — Policy A (intentional limitation)

- `DivePlanPackage` schema **v1** transfers bottom gas, deco gases, and planned switches only.
- Travel gases are configured **locally on Watch** pre-dive.
- Plan activation imports bottom/deco but **preserves** existing Watch-native `travelGases`.
- Travel affects TTS only when enabled and **manually confirmed** at runtime.

### Bailout gas — Policy A (schedule/reference-only)

- Bailout is **not** in iOS plan packages.
- Watch predive may configure bailout locally.
- Bailout is **excluded** from `projectionGases` and normal TTS.
- Off-plan switch requires `confirmOffPlanGasSwitch`.

### Schema / migration

| Item | Value |
|------|-------|
| Schema change | **None** |
| `DivePlanPackageCodec.currentSchemaVersion` | **1** |
| `algorithmVersion` | `buhlmann-gf-shared-1` |
| Migration | N/A — backward compatible |

---

## Code changes

| File | Change |
|------|--------|
| `Services/FullComputerImportedPlanStore.swift` | Fail closed on equal revision + different checksum; preserve travel/bailout on activation |
| `Services/FullComputerRuntimeEngine.swift` | `confirmGasSwitch` rejects unavailable gas IDs |

### New test files (Watch)

- `Tests/WatchAlgorithmTests/FullComputerImportedPlanStoreTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerGasSwitchRecoveryIntegrationTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerTravelBailoutPolicyTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerFutureGasTTSPolicyTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerGasSwitchTimestampTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerNoAutomaticGasSwitchTests.swift`
- `Tests/WatchAlgorithmTests/FullComputerNamespaceIsolationTests.swift`

### Extended tests

- `Tests/WatchAlgorithmTests/DivePlanPackageCodecTests.swift` (+4)
- `Tests/iOSAlgorithmTests/DivePlanPackageBuilderTests.swift` (+1 Policy A builder check)

### Documentation

- Audit 03 addendum, Command 07/08/09/10 reports, this report, `Docs/INDEX.md`

---

## Validation results

### Builds

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** |
| DIRDiving iOS | **BUILD SUCCEEDED** |

### Focused Watch FC tests

| Suite | Result |
|-------|--------|
| `FullComputerGasProfileTests` | PASS |
| `FullComputerGasSwitchPolicyTests` | PASS |
| `FullComputerRecoveryCheckpointTests` | PASS |
| `FullComputerImportedPlanStoreTests` | PASS (21) |
| `FullComputerGasSwitchRecoveryIntegrationTests` | PASS (7) |
| `FullComputerTravelBailoutPolicyTests` | PASS (9) |
| `FullComputerFutureGasTTSPolicyTests` | PASS (8) |
| `FullComputerGasSwitchTimestampTests` | PASS (6) |
| `FullComputerNoAutomaticGasSwitchTests` | PASS (4) |
| `FullComputerNamespaceIsolationTests` | PASS (7) |
| `DivePlanPackageCodecTests` | PASS (9) |
| `FullComputerRuntimeEngineTests` | PASS |
| `FullComputerReleaseHardValidationTests` | PASS |

### Full suites

| Suite | Tests | Skipped | Failures |
|-------|-------|---------|----------|
| DIRDiving iOS Algorithm Tests | 933 | 14 | **0** |
| DIRDiving Watch Algorithm Tests | 508 | 16 | **0** |

**Simulators:** iPhone 17 Pro, Apple Watch Ultra 3 (49mm)

---

## Static scan summary

- No automatic `changeGas` / `confirmGasSwitch` paths outside explicit user confirmation APIs.
- FC namespace keys (`fullComputerPlanPackage*`, `dirdiving_fc_plan_*`) isolated from Apnea (`apneaSyncPlanPackage`, `dirdiving_apnea_session`).
- Bailout excluded from `projectionGases`; unconfirmed travel excluded until confirmed.
- Schema v1 unchanged; revision monotonicity and checksum validation preserved.

---

## Readiness matrix (internal)

| Domain | Code | Automated Tests | Documentation | External Evidence |
|---|---:|---:|---:|---|
| Multigas Models | 100% | 100% | 100% | PENDING |
| Predive Validation | 100% | 100% | 100% | PENDING |
| Travel Gas Policy | 100% | 100% | 100% | PENDING |
| Bailout Gas Policy | 100% | 100% | 100% | PENDING |
| Plan Package Codec | 100% | 100% | 100% | PENDING |
| iOS → Watch Transfer | 100% | 100% | 100% | PENDING |
| Revision / Idempotency | 100% | 100% | 100% | PENDING |
| Namespace Isolation | 100% | 100% | 100% | PENDING |
| Manual Gas Switching | 100% | 100% | 100% | PENDING |
| Exact Switch Timestamp | 100% | 100% | 100% | PENDING |
| Future Gas TTS Policy | 100% | 100% | 100% | PENDING |
| TTS Recalculation | 100% | 100% | 100% | PENDING |
| Ceiling Recalculation | 100% | 100% | 100% | PENDING |
| Checkpoint Persistence | 100% | 100% | 100% | PENDING |
| Crash Recovery | 100% | 100% | 100% | PENDING |
| Logbook Metadata | 100% | 100% | 100% | PENDING |
| Offline Autonomy | 100% | 100% | 100% | PENDING |
| Performance / Memory | 100% | 100% | 100% | PENDING |
| **Overall Internal Readiness** | **100%** | **100%** | **100%** | **Separate QA** |

---

## Remaining external / PENDING items

- Real-world underwater FC multigas dive validation (hardware)
- Long-duration offline queue stress on physical Watch + iPhone pair
- Field verification of travel/bailout Policy A copy with divers
- Command 11 (Apnea) external QA remains independent

---

## Remaining risks (low)

- Plan activation replaces bottom/deco from import; diver must re-verify travel/bailout if not previously configured locally.
- Corrupt `UserDefaults` pending payload returns nil pending (safe); no quarantine UI for FC plan store (checkpoint quarantine exists for active dive).

---

*Remediation V1.0 — Full Computer Commands 07–10 internal readiness.*
