# AUDIT 03 — Full Computer Multigas, Sync and Recovery (read-only)

**Date:** 2026-06-17  
**Auditor:** Independent automated + manual code review (no code changes)  
**Command:** `03_AUDIT_FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY.md`  
**Branch:** `main` @ `5b842e1`  
**Prerequisites:** Audit 01 remediation **PASS**; Audit 02 **PASS** (`Docs/AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI_CURRENT.md`)

---

## Executive summary

| Area | Verdict |
|------|---------|
| Shared multigas models & validation (Commands 07) | **PASS** |
| iOS → Watch plan package sync (Command 08) | **PASS** |
| Runtime gas switch policy & recalculation (Command 09) | **PASS** |
| Persistence, checkpoint & recovery (Command 10) | **PASS** |
| **Gate before Command 11 (Apnea)** | **PASS** for FC multigas/sync/recovery scope |

**Overall:** **PASS** — Full Computer multigas, plan transfer, manual gas switching, TTS/ceiling recalculation, checkpoint recovery, and logbook metadata meet Audit 03 on `main`. Minor P2/P3 documentation/test-coverage notes; no P1 blockers.

**Note:** Command 11 (Apnea) is merged on `main` with a **separate** WatchConnectivity namespace (`apneaSyncPlanPackage`, `dirdiving_apnea_session`). This audit validates FC Commands **07–10** only; Apnea isolation from FC plan sync is **PASS**.

---

## Scope map (Commands 07–10)

| Command | Primary artifacts | Status |
|---------|-------------------|--------|
| 07 Multigas models & predive | `Shared/Models/FullComputerMultigasModels.swift`, `FullComputerGasProfileValidator.swift`, `FullComputerPrediveConfigurationStore.swift` | **Present** |
| 08 iOS plan package & sync | `DivePlanPackage.swift`, `DivePlanPackageCodec.swift`, `DivePlanPackageTransferSupport.swift`, iOS transfer service, `DivePlanPackageWatchReceiver` | **Present** |
| 09 Runtime gas switch | `FullComputerGasSwitchPolicy.swift`, `FullComputerGasSwitchModels.swift`, `FullComputerRuntimeEngine` gas APIs, `DiveLiveView` / gas switch UI | **Present** |
| 10 Persistence & recovery | `FullComputerRuntimeCheckpoint.swift`, draft v5 fields in `DiveManager`, `FullComputerRuntimeLogbookAccumulator`, `FullComputerDiveLogbookMetadata` | **Present** |

---

## 1. Shared multigas models

### `FullComputerGasProfile` / `FullComputerConfiguredGas`

| Role | Supported | Runtime TTS |
|------|-----------|-------------|
| Bottom (Air / EAN / Trimix) | **Yes** | Active gas at dive start |
| Travel | **Yes** (profile) | Only if enabled + **confirmed** at runtime |
| Deco | **Yes** | Only if enabled + **confirmed** |
| Bailout | **Yes** (profile + validation) | **Not** in TTS projection (schedule/reference only) |

- **FO₂ / FHe / FN₂:** `nitrogenFraction` derived; validator enforces sum ≤ 1, finite fractions.
- **MOD / PPO₂:** `FullComputerGasProfileValidator` — hypoxic, MOD exceeded, min PPO2 at switch depth.
- **GF:** validated against `BuhlmannCoreConfiguration` bounds.
- **Availability:** `FullComputerGasAvailability` (available / disabled / unavailable); `enabledDecoGases` / `enabledTravelGases` filter unavailable.
- **Future TTS policy:** `FullComputerFutureGasTTSPolicy` — `enabledSwitchGasesOnly` vs `activeGasOnly` (conservative).

### iOS plan import mapping

`FullComputerGasProfile(importing:)` maps bottom + deco from `DivePlanPackage`; **travel and bailout arrays are empty** on import (iOS package schema carries bottom/deco/switches only). Watch-native predive UI can still configure travel/bailout locally.

---

## 2. Critical rules (Audit 03)

| Rule | Implementation | Status |
|------|----------------|--------|
| No automatic gas change | Suggestions only via `evaluateSurface`; `changeGas` only from `confirmGasSwitch` / `confirmOffPlanGasSwitch` | **PASS** |
| Tissues updated only with **confirmed** active gas | `advanceTissues*` uses `plan.activeGas`; projection uses `projectionGases` (confirmed IDs only) | **PASS** |
| Switch applied at exact timestamp, not retroactive | `changeGas(at:)` advances tissues to timestamp, then applies switch + gas-switch minutes forward | **PASS** |
| Lost/unavailable gas excluded from future TTS | `unavailableGasMixIds`; `projectionGases` filters confirmed; missed prompt sets `ttsUsesActiveGasOnly` | **PASS** |
| Watch autonomous underwater | Pending plan in `UserDefaults`; runtime engine local; no iOS required in-dive | **PASS** |
| Received plan not active without validation + user action | `DivePlanPackageCodec.validate` + profile validator; `activatePendingPlan` user-driven; separate FC predive confirmation before dive | **PASS** |
| No tissue reset on recovery | `restoreEngine(from:)`; `recoverySelfCheckDiagnostics`; corrupt checkpoint quarantined + sample replay fallback | **PASS** |

---

## 3. iOS → Watch plan package sync

### Schema & integrity

- **Schema version:** 1 (`DivePlanPackageCodec.currentSchemaVersion`)
- **Algorithm version:** `buhlmann-gf-shared-1`
- **Checksum:** SHA-256 over canonical sorted JSON body
- **Revision:** monotonic per `planID` on iOS sender; Watch rejects **lower** revision for same plan
- **Expiry:** optional `expiresAt` validated
- **Capabilities:** `minimumWatchSchemaVersion`, `minimumAlgorithmVersion`

### Namespace isolation

| Channel | FC plan | Other |
|---------|---------|-------|
| `transferType` | `fullComputerPlanPackage` / `Ack` / `Snapshot` | Apnea: `apneaSyncPlanPackage`; dive session: existing WC keys |
| Application context | `dirdiving_fc_plan_*` | Briefing / logbook / settings unchanged |

### Transport & ACK

- iOS: `transferUserInfo` queue + application context snapshot; pending until signed ACK.
- Watch: `DivePlanPackageWatchReceiver` validates, ACK via HMAC (`DivePlanPackageAckSigner`).
- **Replay protection:** ACK `issuedAt` skew ≤ 5 min (`maxIssuedAtSkew`).
- **Idempotency:** `FullComputerImportedPlanStore` fingerprint `planID|revision|checksum`; duplicate returns success without re-pending.
- **Out-of-order:** same `planID` with `revision < pending.revision` → rejected (returns false).

### Offline

- Watch stores pending package locally; predive/runtime independent of live phone link.
- iOS queues pending transfers until session activated.

---

## 4. Runtime gas switching (Command 09)

| Scenario | Behaviour | Test |
|----------|-----------|------|
| Suggested at switch depth | `suggestedSwitchGas` + UI prompt; long-press confirm | `testSuggestedGasAtSwitchDepth` |
| Ignored switch | `ignoreSuggestedGasSwitch` → missed surface, TTS active-gas only | `testIgnoredSwitchShowsMissedSurface` |
| Confirmed switch | `confirmedGasMixIds` updated; tissues advanced at timestamp | `testTimestampedGasSwitchRecalculatesImmediately` |
| Unavailable gas | `markGasUnavailable`; excluded from suggestion/projection | Policy + runtime rows |
| Off-plan switch | `confirmOffPlanGasSwitch` with audit event `.offPlan` | Engine API |
| TTS/ceiling/stop recalc | `refreshSnapshot` → `runtimeProjection` + `FullComputerDecoSolver` on each tick/ingest | Engine integration |

**Confirmation UX:** `FullComputerGasSwitchPolicy.confirmationHoldSeconds` (0.8 s long-press); no instant tap switch.

---

## 5. Persistence & checkpoint (Command 10)

### Draft v5 (`DiveManager.ActiveDiveDraft`)

Includes: `fullComputerGasSwitchTracker`, `fullComputerCheckpoint`, `fullComputerLogbookMetadata`, `sessionDivingMode`.

### Checkpoint payload (`FullComputerRuntimeCheckpointPayload`)

| Field | Present |
|-------|---------|
| Tissue state | **Yes** |
| GF (via `plan.gfLow` / `gfHigh`) | **Yes** |
| Gas list & active gas (in `plan`) | **Yes** |
| Gas switch tracker (confirmed / ignored / unavailable / events) | **Yes** |
| NDL / TTS / ceiling snapshots | **Yes** |
| Stop state & engaged stop depth | **Yes** |
| Monotonic elapsed clock | **Yes** |
| Schema + SHA-256 checksum | **Yes** |

### Recovery paths

1. **Valid checkpoint** → `FullComputerRuntimeEngine.restoreEngine` + optional sample replay after checkpoint timestamp.
2. **Invalid checksum / schema** → quarantine; diagnostics banner; replay from samples (no silent tissue reset).
3. **Legacy draft v4** → decodes without checkpoint; sample replay path (`testLegacyDraftWithoutCheckpointStillDecodes`).

### Logbook & session sync

- `FullComputerRuntimeLogbookAccumulator` captures NDL/ceiling/TTS extremes, gas events, violations.
- `DiveSessionMerge` preserves `fullComputerLogbookMetadata` and FC diving mode (`testWatchMergePreservesFullComputerLogbookMetadata`).

---

## 6. Minimum tests (Audit 03 checklist)

| Scenario | Coverage | Result |
|----------|----------|--------|
| Air / EAN / Trimix profiles | `FullComputerGasProfileTests` | **PASS** |
| Multiple deco gases | `testMultipleDecoGasesOrderedBySwitchDepth` | **PASS** |
| Confirmed / ignored switch | `FullComputerGasSwitchPolicyTests` | **PASS** |
| Unavailable / missed gas | Policy missed surface + engine APIs | **PASS** |
| Crash / checkpoint | `testCheckpointRoundTripPreservesTissueState` | **PASS** |
| Corrupt checkpoint | `testCorruptChecksumIsRejected` | **PASS** |
| Gas switch timestamp | `testTimestampedGasSwitchRecalculatesImmediately` | **PASS** |
| Watch offline (import persist) | `FullComputerImportedPlanStore` UserDefaults persistence | **PASS** (code) |
| Corrupt plan package | `testChecksumRejectsTamperedPayload` | **PASS** |
| Legacy session draft | `testLegacyDraftWithoutCheckpointStillDecodes` | **PASS** |
| iOS builder + WC payload | `DivePlanPackageBuilderTests` (2) | **PASS** |

### Focused test execution (2026-06-17)

| Suite | Tests | Failures |
|-------|-------|----------|
| `FullComputerGasProfileTests` | 8 | 0 |
| `FullComputerGasSwitchPolicyTests` | 3 | 0 |
| `FullComputerRecoveryCheckpointTests` | 5 | 0 |
| `DivePlanPackageCodecTests` | 5 | 0 |
| `DivePlanPackageBuilderTests` (iOS) | 2 | 0 |
| **Subtotal** | **23** | **0** |

Related: `FullComputerRuntimeEngineTests` (gas switch, multilevel), `FullComputerReleaseHardValidationTests` (differential TTS, multilevel).

### Builds

| Target | Result |
|--------|--------|
| DIRDiving Watch App | **BUILD SUCCEEDED** (prior audits) |
| DIRDiving iOS | **BUILD SUCCEEDED** (prior audits) |

---

## 7. Findings

| ID | Severity | Finding | Recommendation |
|----|----------|---------|----------------|
| — | — | No P1 blockers | — |
| **P2** | Info | Bailout gases validated in profile but excluded from runtime TTS and iOS plan import | Document as schedule-only; extend package schema only if product requires bailout in TTS |
| **P2** | Info | Travel gases not populated from iOS `DivePlanPackage` import | Watch predive can add travel manually; extend import if iOS planner exports travel |
| **P3** | Low | No dedicated Watch unit tests for `FullComputerImportedPlanStore` revision/idempotency (logic present; Apnea store has parallel tests) | Optional: add `FullComputerImportedPlanStoreTests` mirroring Apnea patterns |
| **P3** | Low | No explicit “crash mid gas-switch” integration test | Checkpoint round-trip + gas-switch timestamp tests mitigate; optional stress test |

---

## 8. Command 11 readiness gate

| Gate criterion | Result |
|----------------|--------|
| FC multigas predive valid on Watch | **PASS** |
| FC plan sync namespace isolated from Apnea/session sync | **PASS** |
| Manual gas policy enforced (no auto switch) | **PASS** |
| Checkpoint recovery without tissue reset | **PASS** |
| Logbook metadata preserved on merge | **PASS** |
| **FC Commands 07–10 ready; Command 11 (Apnea) may proceed independently** | **YES** |

---

## 9. Related documentation

| Document | Role |
|----------|------|
| `Docs/DIR_DIVING_MULTIGAS_MODELS_AND_PREDIVE_CONFIGURATION_REPORT.md` | Command 07 |
| `Docs/DIR_DIVING_IOS_PLAN_PACKAGE_AND_WATCH_SYNC_REPORT.md` | Command 08 |
| `Docs/DIR_DIVING_RUNTIME_GAS_SWITCH_AND_RECALCULATION_REPORT.md` | Command 09 |
| `Docs/DIR_DIVING_FULL_COMPUTER_PERSISTENCE_LOGBOOK_RECOVERY_REPORT.md` | Command 10 |
| `Docs/AUDIT_FULL_COMPUTER_RUNTIME_DECO_UI_CURRENT.md` | Prior audit |

---

*Audit 03 — read-only. No application code modified.*

---

## Remediation addendum (V1.0 — 2026-06-17)

Post-audit hardening on `main` closes Audit 03 P2/P3 findings without schema changes.

| Finding | Resolution |
|---------|------------|
| **P2** Bailout excluded from TTS / iOS import | **Policy A** — intentional; documented + `FullComputerTravelBailoutPolicyTests` |
| **P2** Travel not in iOS package import | **Policy A** — bottom+deco only in `DivePlanPackage` v1; Watch-native travel preserved on activation |
| **P3** No `FullComputerImportedPlanStore` tests | `FullComputerImportedPlanStoreTests` (21 cases) |
| **P3** No crash-mid-switch integration test | `FullComputerGasSwitchRecoveryIntegrationTests` (7 cases) |

**Code hardening:** `FullComputerImportedPlanStore` rejects equal revision + different checksum; activation preserves Watch-native travel/bailout; `confirmGasSwitch` rejects unavailable gas IDs.

**Report:** `Docs/FULL_COMPUTER_MULTIGAS_SYNC_RECOVERY_REMEDIATION_REPORT_V1.0.md`
