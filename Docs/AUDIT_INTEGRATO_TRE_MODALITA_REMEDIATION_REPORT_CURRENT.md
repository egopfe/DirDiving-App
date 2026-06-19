# Audit 13 — Integrated Three-Mode Remediation Report (Current)

**Date:** 2026-06-19  
**Authoritative audit:** [`AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md) (Audit 13, baseline `9e8c797` / historical evidence `67e5d95`)  
**Branch:** `main` (uncommitted remediation working tree)  
**Validation baseline:** post-remediation automated re-run 2026-06-19  

---

## Executive summary

Software remediations for Audit 13 P1–P3 findings are **complete for internal automated gates**. Root cause of Apnea suspend/resume failures was **session monotonic clock anchoring**: `ApneaSessionEngine.init` reset `sessionClock` with `ProcessInfo.systemUptime` while deterministic tests inject synthetic uptime, corrupting `tracker.diveStartedAt` and preventing valid dive commit after restore.

| Gate | Verdict |
|------|---------|
| **Internal integrated software** | **GO** — `validate_integrated_modes.sh --internal` PASS |
| **External / TestFlight / App Store** | **NO-GO** — physical QA unsigned (0%) |

```
INTEGRATED_MODES_INTERNAL_RELEASE_GATE_PASS
INTEGRATED_MODES_EXTERNAL_RELEASE_PENDING_PHYSICAL_QA
INTEGRATED_EXTERNAL_NO_GO_PHYSICAL_QA_PENDING
```

---

## Root causes

1. **Apnea suspend/resume (AUDIT13-INT-007):** `armSession` did not re-anchor `sessionClock` to the provided wall/uptime pair. Checkpoint restore then mixed system-uptime-scale `diveStartedAt` with export-normalized session clock snapshots, so surface dwell could not commit dives (`dives.count` stayed 0).
2. **Stale iOS companion test (AUDIT13-INT-001):** Test expected Snorkeling unavailable on iOS; product policy and `IOSCompanionActivitySelectionTests` expose both Apnea and Snorkeling on iOS Companion.
3. **Checkpoint configuration loss:** `init(checkpoint:)` used `.default` lifecycle configuration instead of persisted test/production configuration, risking minimum-dive-duration mismatch after restore.
4. **XcodeGen race (AUDIT13-INT-004):** Parallel validators invoked concurrent `xcodegen generate` against one `DIRDiving.xcodeproj`.
5. **Integrated automation gap (AUDIT13-INT-003):** No chained integrated validator or sequential automated flow test.

---

## Production changes

| File | Change |
|------|--------|
| `Shared/Utils/ApneaSessionEngine.swift` | `armSession` resets `sessionClock` with wall/uptime; checkpoint restore keeps config/policy, syncs active dive tracker, clears `lastMeasurementMonotonic` |
| `Shared/Utils/ApneaSessionCheckpoint.swift` | Persist `lifecycleConfiguration` + `recoveryPolicy`; backward-compatible decode |

## Test / script changes

| File | Change |
|------|--------|
| `Tests/iOSAlgorithmTests/IOSApneaCompanionTests.swift` | `testApneaAndSnorkelingSelectionAvailableOnIOSCompanion` |
| `Tests/WatchAlgorithmTests/IntegratedModesSequentialFlowTests.swift` | Sequential Gauge → FC → Apnea (suspend/resume) → Snorkeling automated flow |
| `Scripts/lib/xcodegen_once.sh` | Serialized XcodeGen with stamp + lock |
| `Scripts/validate_integrated_modes.sh` | Integrated internal release gate |
| `Scripts/validate_*_release_readiness.sh` | Use `xcodegen_once` |

---

## Validation executed (2026-06-19)

| Command | Result |
|---------|--------|
| `./Scripts/check_main_target_isolation.sh` | **PASS** |
| `./Scripts/check_secrets.sh` | **PASS** |
| `./Scripts/audit_localization.sh` | **PASS** (Watch EN=1195 IT=1195; iOS EN=2512 IT=2512) |
| `./Scripts/validate_full_computer_release_readiness.sh` | **PASS** |
| `./Scripts/validate_apnea_release_readiness.sh --internal` | **PASS** |
| `./Scripts/validate_snorkeling_release_readiness.sh --internal` | **PASS** (Watch 212 + iOS 89) |
| `./Scripts/validate_integrated_modes.sh --internal` | **PASS** |
| `ApneaSuspendResumeLifecycleIntegrationTests` | **PASS** (26 tests, 0 failures) |
| `IntegratedModesSequentialFlowTests` | **PASS** (2 tests) |

**Environmental note:** First concurrent FC validator attempt hit Xcode DerivedData lock (`database is locked`) when run parallel to Snorkeling; sequential re-run **PASS**.

---

## Audit 15 / 16 scope

| Audit | Scope | Result |
|-------|-------|--------|
| **15** Bühlmann / FC tissue math | Not modified | **NOT_TOUCHED** |
| **16** UI/UX coherence | Activity selection, Apnea restore, iOS availability | **PASS** (automated subset via integrated + companion tests) |

---

## Physical / external QA (unchanged)

- Apnea 19 + Snorkeling 21 + Diving/FC physical matrices: **PENDING** (0% signed evidence)
- Underwater / paired Watch+iPhone QA: **PENDING**
- External Bühlmann validation: **PENDING**

---

## Related documents

- [`INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv`](INTEGRATED_MODES_RELEASE_VALIDATION_MATRIX_CURRENT.csv)
- [`INTEGRATED_MODES_REMEDIATION_TRACEABILITY_CURRENT.csv`](INTEGRATED_MODES_REMEDIATION_TRACEABILITY_CURRENT.csv)
- [`AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md`](AUDIT_INTEGRATO_TRE_MODALITA_CURRENT.md)
