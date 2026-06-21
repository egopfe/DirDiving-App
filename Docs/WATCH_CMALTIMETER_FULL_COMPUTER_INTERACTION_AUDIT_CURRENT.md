# Watch CMAltimeter / Full Computer Interaction Audit (Current)

**Command:** 18 — DIR DIVING WATCH CMALTIMETER FULL COMPUTER INTERACTION AUDIT V1.0  
**Audit date:** 2026-06-17  
**Repository:** `egopfe/DirDiving-App`  
**Branch / commit:** `main` @ `8ab477698bf2d2c1fe7b2cc303f1d46de4b62fc8`  
**Auditor mode:** read-only (no production code changes)

---

## 1. Executive verdict

**WATCH_CMALTIMETER_FULL_COMPUTER_AUDIT: PARTIAL**

The Watch Full Computer implements a fail-closed, explicit-acceptance sensor proposal path using `CMAltimeter.startAbsoluteAltitudeUpdates`. Imported iPhone Plan and manual Watch environment are preserved until the diver explicitly accepts a sensor proposal. Live startup requires a validated `FullComputerEnvironmentRecord`; `runtimePlan()` returns `nil` without one, and `DiveManager.startFullComputerRuntimeIfNeeded` refuses engine creation when the plan is missing or invalid.

Software gates pass for target membership, Core Motion API choice, proposal non-authority, canonical environment validation, and macOS Watch build/tests (965/965). **Physical Apple Watch sensor validation was not executed** (Phase L). Two **P1** lifecycle defects (late error callback after success; no request-generation isolation) and several **P2** gaps (sensor timestamp ignored, incomplete negative test coverage, undocumented sampling thresholds) prevent a software `PASS` and block release readiness.

| Severity | Count | IDs |
|----------|------:|-----|
| P0 | 0 | — |
| P1 | 2 | WCMA-001, WCMA-002 |
| P2 | 6 | WCMA-003 … WCMA-008 |
| P3 | 2 | WCMA-009, WCMA-010 |
| P4 | 1 | WCMA-011 |

**SOFTWARE_READINESS_PERCENT:** 78  
**PHYSICAL_READINESS_PERCENT:** 0  
**RELEASE_BLOCKERS:** WCMA-001, WCMA-002, PENDING_PHYSICAL

---

## 2. Baseline and environment

| Item | Value | Evidence |
|------|-------|----------|
| Branch | `main` | `git branch --show-current` |
| HEAD | `8ab477698bf2d2c1fe7b2cc303f1d46de4b62fc8` | `git rev-parse HEAD` |
| origin/main | identical | `git rev-list --left-right --count HEAD...origin/main` → `0 0` |
| Worktree | clean | `git status --short` → empty |
| Xcode | 26.5 (17F42) | `xcodebuild -version` |
| watchOS SDK / deployment | 10.0+ | `project.yml` L6 |
| Simulator | Apple Watch Ultra 3 (49mm) | `simctl list devices` |
| Test date | 2026-06-17 | this audit |

**BASELINE_CURRENT_AND_CLEAN: PASS**

---

## 3. Authoritative references

| Reference | URL | Accessed |
|-----------|-----|----------|
| `CMAltimeter` | https://developer.apple.com/documentation/coremotion/cmaltimeter | 2026-06-17 |
| `isAbsoluteAltitudeAvailable()` | https://developer.apple.com/documentation/coremotion/cmaltimeter/isabsolutealtitudeavailable() | 2026-06-17 |
| `startAbsoluteAltitudeUpdates(to:withHandler:)` | https://developer.apple.com/documentation/coremotion/cmaltimeter/startabsolutealtitudeupdates(to:withhandler:) | 2026-06-17 |
| `CMAbsoluteAltitudeData` | https://developer.apple.com/documentation/coremotion/cmabsolutealtitudedata | 2026-06-17 |
| `CMLogItem.timestamp` | https://developer.apple.com/documentation/coremotion/cmlogitem/timestamp | 2026-06-17 |
| Bühlmann oracle (repo) | `Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift` | 2026-06-17 |

Apple documents absolute altitude in metres relative to mean sea level (MSL), with `accuracy` and `precision` in metres. `CMLogItem.timestamp` is the sensor log time, distinct from callback delivery time.

---

## 4. Production target and call graph

### 4.1 Target membership

| Check | Result | Evidence |
|-------|--------|----------|
| `FullComputerEnvironmentSensorService.swift` in Watch App | PASS | `project.yml` L296 |
| Same file in Watch Algorithm Tests | PASS | test target sources include `Services/` |
| `CoreMotion.framework` linked (Watch App) | PASS | `project.yml` L110 |
| `CoreMotion.framework` linked (Watch Tests) | PASS | `project.yml` L317 |
| Watch `Info.plist` motion usage | PASS | `App/Info.plist` L7–8 `NSMotionUsageDescription` |
| Only Watch production CMAltimeter user | PASS | `rg CMAltimeter` → only `FullComputerEnvironmentSensorService.swift` |

**PRODUCTION_TARGET_MEMBERSHIP: PASS**

### 4.2 Altitude source classification (`rg` sweep)

| Symbol / path | Role |
|---------------|------|
| `AppleWatchAbsoluteAltitudeProvider` | **Production authority (proposal input only)** |
| `FullComputerPrediveConfigurationStore.setDraftEnvironment` | Manual Watch authority |
| `FullComputerImportedPlanStore` / package import | iPhone Plan authority |
| `PlannerEnvironment.make` / `AmbientPressureModel` | Derived surface pressure & density |
| `FullComputerRuntimePlan.defaultAirGF3070` | Test/default fixture only — **not** live startup path |
| `GPSManager` / `CLLocationManager` | GPS track only; **not** Full Computer environment |
| `IndependentBuhlmannOracle` | Test oracle only |

### 4.3 End-to-end call graph (sensor → runtime)

```text
FullComputerPrediveSettingsView.onAppear / FullComputerPrediveConfirmationView.onAppear
  → FullComputerEnvironmentSensorService.requestProposal(into:)
    → AppleWatchAbsoluteAltitudeProvider.start
      → CMAltimeter.startAbsoluteAltitudeUpdates(to: .main)
    → FullComputerAltitudeSamplingPolicy.stableProposal
    → FullComputerEnvironmentRecord.make(source: .watchSensorMeasuredProposal)
    → FullComputerPrediveConfigurationStore.proposeSensorEnvironment  [pending only]
  → User Accept → acceptPendingSensorProposal → draftEnvironment
  → User Start → DIRActivitySelectionStore.confirmFullComputerPredive
    → commitConfirmedProfile → confirmedEnvironment
  → DiveManager.startFullComputerRuntimeIfNeeded
    → FullComputerPrediveConfigurationStore.runtimePlan()
    → FullComputerRuntimeEngine.canStart(plan:)
    → FullComputerRuntimeEngine.init(plan:sessionStart:)
      → BuhlmannTissueState.airSaturated(surfacePressureBar: plan.plannerEnvironment…)
      → all ticks use plan.plannerEnvironment via AmbientPressureModel
  → DiveManager.currentFullComputerLogbookMetadata
    → FullComputerRuntimeLogbookAccumulator.export(environmentRecord:)
```

Citations: `FullComputerEnvironmentSensorService.swift` L131–210; `FullComputerPrediveConfigurationStore.swift` L86–163; `DiveManager.swift` L1425–1455, L1523–1548; `FullComputerRuntimeEngine.swift` L67–73.

---

## 5. Core Motion lifecycle analysis

### 5.1 Implementation summary

`AppleWatchAbsoluteAltitudeProvider` (`FullComputerEnvironmentSensorService.swift` L73–111):

- Checks `CMAltimeter.isAbsoluteAltitudeAvailable()` before subscribe (L76–78, L83–86).
- Retains one `CMAltimeter` instance for the operation (L74).
- Uses **absolute** API, not relative (L88).
- Delivers callbacks on `.main` via `Task { @MainActor in … }` (L88–105).
- Calls `stopAbsoluteAltitudeUpdates()` before restart (L87) and in `stop()` (L109–110).
- `FullComputerEnvironmentSensorService.finish` and `cancel` also call `provider.stop()` (L164, L204).

### 5.2 State machine

| State | Entry | Exit events |
|-------|-------|-------------|
| `idle` | init, cancel from sampling | `requestProposal` → sampling/unavailable |
| `sampling` | available provider | stable window → `proposalReady`; timeout → `timedOut`; error → failed/unavailable; cancel → idle |
| `proposalReady` | stable proposal stored in store | (terminal until next `requestProposal` or `cancel`) |
| `unavailable` | provider not available | next `requestProposal` |
| `timedOut` / `failed` | timeout or validation/sensor error | next `requestProposal` |

**Illegal transition (defect):** late error callback after `proposalReady` can call `finish(.failed)` and clobber terminal success state — see WCMA-001.

### 5.3 Lifecycle gate

**CORE_MOTION_ABSOLUTE_ALTITUDE_API: PASS**  
**ALTIMETER_LIFECYCLE_AND_CANCELLATION: PARTIAL** (stop/cancel present; late-callback defect)  
**LATE_CALLBACK_ISOLATION: FAIL** (WCMA-001, WCMA-002)

---

## 6. Sample quality and freshness

### 6.1 Field usage

| Field | Production use | Unit / frame | Notes |
|-------|----------------|--------------|-------|
| `data.altitude` | → `altitudeMeters` | metres MSL | Apple docs |
| `data.accuracy` | filtered ≤ 30 m | metres | `FullComputerEnvironmentRecord.maximumSensorAccuracyMeters` |
| `data.precision` | stored, must be ≥ 0 | metres | |
| `data.timestamp` | **not used** | sensor time | `receivedAt = Date()` instead — WCMA-003 |
| `receivedAt` | `capturedAt` on record | wall clock | max of window receive times |

### 6.2 Sampling policy (current constants)

| Parameter | Value | Location |
|-----------|------:|----------|
| Required samples | 5 | `FullComputerAltitudeSamplingPolicy.requiredSampleCount` L28 |
| Max accuracy | 30 m | L29 |
| Max stable spread | 12 m | L30 |
| Timeout | 8 s | L31 |
| Selection | median altitude, max accuracy/precision in window | L54–58 |
| Altitude range | −500 … 4 500 m | `PlannerEnvironment.make` |
| Sensor record max age | 120 s | `FullComputerEnvironmentRecord.maximumSensorAgeSeconds` L36 |

Policy rejects non-finite values, negative accuracy/precision, accuracy > 30 m, and spread > 12 m (`L33–40`, `L42–60`). **Safety rationale for 12 m spread and 8 s timeout is not documented in repo** — WCMA-004.

Nil `data` with nil `error` is silently ignored (`L94`), relying on timeout — WCMA-007.

**SAMPLE_QUALITY_AND_FRESHNESS: PARTIAL**

---

## 7. Proposal state machine and user authority

| Requirement | Status | Evidence |
|-------------|--------|----------|
| Proposal does not mutate draft | PASS | `consume` → `proposeSensorEnvironment` only; draft unchanged in tests L115–145 |
| Explicit accept required | PASS | `acceptPendingSensorProposal` L86–94 |
| Reject preserves manual/import | PASS | `dismissPendingSensorProposal` L97–98; test L115–145 |
| Start blocked while sampling / pending | PASS | `canStart` L128–131 (Confirmation), L254–257 (Settings) |
| `requestProposal` clears stale pending only | PASS | L134 `dismissPendingSensorProposal()` |
| Manual/import not overwritten silently | PASS | tests + store separation |
| No auto-accept on lifecycle | PASS | no accept in `onAppear` |
| Fail-closed without environment | PASS | `runtimePlan()` nil; test L20–23 |

**EXPLICIT_SENSOR_PROPOSAL_ACCEPTANCE: PASS**  
**IMPORTED_AND_MANUAL_SOURCE_PRESERVATION: PASS**

Transition table: see `Docs/WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv`.

---

## 8. Canonical environment validation

`FullComputerEnvironmentRecord` (`Shared/Models/FullComputerEnvironmentRecord.swift`):

- Schema version gate (L97).
- Source authorization (L98).
- Cross-check surface pressure and water density vs `PlannerEnvironment.make` (L103–114).
- Sensor proposals require accuracy, precision, freshness ≤ 120 s (L115–128).
- `legacyUnknown` rejected for live start (L9–15).

Independent surface-pressure check: `IndependentBuhlmannOracle.independentSurfacePressureBar` uses the same barometric formula as `AmbientPressureModel.surfacePressureBar` (compare `PlannerEnvironment.swift` L31–37 with oracle L125–131). Test at 1 500 m confirms lower ambient than sea level (`OrchestratedAltitudeEnvironmentTests.swift` L84–97).

**NO_EXPLICIT_OR_IMPLICIT_SEA_LEVEL: PASS** (UI stepper defaults 0 m as numeric entry, not a “sea level” mode; live path has no implicit default)  
**CANONICAL_ENVIRONMENT_VALIDATION: PASS**  
**SURFACE_PRESSURE_DERIVATION: PASS**

---

## 9. Full Computer startup propagation

Live startup path:

1. `runtimePlan()` requires validated `confirmedEnvironment ?? draftEnvironment` (`FullComputerPrediveConfigurationStore.swift` L155–162).
2. `DiveManager.startFullComputerRuntimeIfNeeded` returns unavailable snapshot if plan nil (`DiveManager.swift` L1430–1433).
3. `FullComputerRuntimeEngine.init` throws if `canStart` fails (L67–71).
4. Tissues initialized at `plan.plannerEnvironment.surfacePressureBar` (L73).
5. `canEdit` false during active dive blocks environment edits (L150–153).

`FullComputerRuntimePlan.defaultAirGF3070` still references `.seaLevelSaltWater` (`Utils/FullComputerRuntimePlan.swift` L13–14) but is **not** used on the live Watch startup path.

**FULL_COMPUTER_STARTUP_PROPAGATION: PASS**

---

## 10. Bühlmann / Schreiner mathematical effect

The frozen `PlannerEnvironment` in `FullComputerRuntimePlan` feeds:

- Initial `BuhlmannTissueState.airSaturated(surfacePressureBar:)` — all 16 N2 compartments (`FullComputerRuntimeEngine.swift` L73).
- He compartments start at 0 bar (standard air saturation).
- Every `advanceTissuesLinear` / ceiling / NDL / TTS / deco solve passes `plan.plannerEnvironment` (grep L218, L233, L254, L454, L469, L526, L578, L585).

Altitude is applied **once** via surface pressure in ambient pressure conversion (`AmbientPressureModel.ambientPressureBar`); depth adds hydrostatic component to existing surface pressure — no double-counting.

**Automated evidence:** import/manual/sensor acceptance tests at 500–2 000 m; independent oracle pressure at 1 500 m; logbook metadata test at 1 500 m. **Gap:** no automated all-16-compartment oracle sweep specifically for **sensor-accepted** environment at full altitude matrix (0, 500, 1000, 1500, 2000, max) with trimix — WCMA-005 / partial gates below.

**ALL_16_N2_COMPARTMENTS_ALTITUDE_AWARE: PARTIAL** (mechanism proven; sensor-path oracle sweep incomplete)  
**ALL_16_HE_COMPARTMENTS_ALTITUDE_AWARE: PARTIAL**  
**NDL_TTS_CEILING_SCHEDULE_ALTITUDE_AWARE: PARTIAL**

---

## 11. Persistence, restore, and logbook

| Boundary | Behavior | Evidence |
|----------|----------|----------|
| Draft / confirmed environment | Persisted UserDefaults | `FullComputerPrediveConfigurationStore` L211–240 |
| Pending sensor proposal | **Not persisted** | no key; in-memory only — WCMA-006 |
| Checkpoint | Full `FullComputerRuntimePlan` including `plannerEnvironment` | `FullComputerRuntimeCheckpointPayload` L18 |
| Restore | Rehydrates engine from checkpoint plan | `DiveManager.restoreFullComputerRuntimeIfNeeded` L1471–1488 |
| Logbook | Exports altitude, surface pressure, salinity, source, capturedAt, sensor accuracy/precision | `FullComputerRuntimeLogbookAccumulator.swift` L78–86; metadata test L56–81 |
| Logbook fallback source | If `confirmedEnvironment` nil, uses `legacyUnknown` then overwrites numeric fields from runtime plan | `DiveManager.swift` L1530–1539 — WCMA-008 (fail-safe numerics; weak provenance label) |

**ACTIVE_DIVE_ENVIRONMENT_IMMUTABLE: PASS**  
**CHECKPOINT_RESTORE_ENVIRONMENT: PASS**  
**LOGBOOK_SENSOR_PROVENANCE: PARTIAL** (fields exist; fallback source label weak)

---

## 12. Failure and concurrency analysis

See `Docs/WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv` for the full matrix.

Key defects:

- **WCMA-001:** Error handler in provider callback does not guard terminal states; late error after success sets `state = .failed` while `pendingSensorProposal` remains (`FullComputerEnvironmentSensorService.swift` L146–147, L203–209).
- **WCMA-002:** No request-generation token; superseded subscriptions rely on `stop()` + `state == .sampling` guard only (`L174–175`, L146–147).

No audited path converts failures into sea-level authorization or false no-deco.

---

## 13. Automated evidence review

| Test file | Relevance | Result |
|-----------|-----------|--------|
| `OrchestratedAltitudeEnvironmentTests.swift` | Sensor proposal, import, validation, oracle | 11/11 PASS |
| `FullComputerRecoveryCheckpointTests.swift` | Checkpoint restore | PASS (965 suite) |
| `FullComputerTargetMembershipTests.swift` | Compile membership | PASS (suite) |
| `IndependentBuhlmannOracle.swift` | Independent pressure math | Used in tests |

**Missing tests (WCMA-005):** timeout, cancel mid-window, late callback after `proposalReady`, rapid double `requestProposal`, provider error after valid samples, nil-data-only stream, NaN/Inf at provider boundary, physical sensor integration.

**AUTOMATED_NEGATIVE_COVERAGE: FAIL**

---

## 14. macOS build and test evidence

```bash
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
# ** BUILD SUCCEEDED **

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
# Executed 965 tests, 0 failures — ** TEST SUCCEEDED ** (561.9 s)
```

Orchestrated altitude subset: 11 tests, 0 failures.

**MACOS_WATCH_BUILD: PASS**  
**WATCH_ALGORITHM_TESTS: PASS**

GitHub Actions for `8ab4776` not re-queried in this session; local evidence above is authoritative for this audit.

---

## 15. Physical Apple Watch evidence

**PHYSICAL_APPLE_WATCH_SENSOR_QA: PENDING_PHYSICAL**

No compatible physical Watch, controlled elevation reference, or permission-denial scenario was executed. Simulator does not prove `CMAltimeter` absolute altitude behaviour.

Mandatory scenarios documented in `Docs/WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv` — all `NOT_EXECUTED`.

---

## 16. Findings (P0 → P4)

### P1

| ID | Summary | Root cause | Impact | Remediation | Acceptance |
|----|---------|------------|--------|-------------|------------|
| WCMA-001 | Late error callback can overwrite `proposalReady` with `failed` without clearing `pendingSensorProposal` | Failure handler unconditional on terminal state (`L146–147`) | UI/state desync; start remains blocked but sensor state misleading; edge race after success | Add request generation ID; ignore callbacks after terminal state; on failure after proposal, clear pending or preserve `proposalReady` | Unit test: emit success window → `proposalReady` → emit error → assert state and store unchanged |
| WCMA-002 | No request-generation isolation for superseded subscriptions | `cancel()` stops updates but in-flight `Task { @MainActor }` blocks may still run | Theoretically stale sample/error could affect new sampling window | Monotonic request ID checked in handler and `consume`/`finish` | Test rapid `requestProposal` ×2 with delayed callback from request 1 |

### P2

| ID | Summary | Remediation |
|----|---------|-------------|
| WCMA-003 | `receivedAt` / `capturedAt` use `Date()` not `CMAbsoluteAltitudeData.timestamp` | Map Apple sensor timestamp; freshness uses sensor time |
| WCMA-004 | Sampling thresholds (12 m, 8 s, 5 samples, 30 m) lack documented safety rationale | Document in safety spec; justify with physical QA |
| WCMA-005 | Missing automated negative/lifecycle tests (see §13) | Add injected-provider tests per failure matrix |
| WCMA-006 | `pendingSensorProposal` not persisted across relaunch | Document as intentional or persist with stale rejection |
| WCMA-007 | Nil data + nil error silently dropped until timeout | Treat as degraded sample or fail fast with diagnostic |
| WCMA-008 | Logbook metadata may label `legacyUnknown` when confirmed record missing | Prefer runtime plan source snapshot captured at commit |

### P3

| ID | Summary |
|----|---------|
| WCMA-009 | Both Settings and Confirmation call `requestProposal` on appear — duplicate sampling |
| WCMA-010 | `NSMotionUsageDescription` mentions depth/motion but not altitude/environment proposal |

### P4

| ID | Summary |
|----|---------|
| WCMA-011 | Settings environment stepper uses 100 m steps — coarse for sensor comparison UX |

---

## 17. Remediation plan (summary)

1. **WCMA-001 / WCMA-002** — Add request generation token; harden callback guards (priority before release).
2. **WCMA-003** — Use sensor timestamp for freshness.
3. **WCMA-005** — Expand `OrchestratedAltitudeEnvironmentTests` per failure matrix.
4. **Phase L** — Execute physical QA matrix on supported Watch hardware with reference elevation.
5. **WCMA-004** — Publish threshold rationale after physical data.

---

## 18. Residual risks and release blockers

| Blocker | Reason |
|---------|--------|
| WCMA-001 | P1 lifecycle / state integrity |
| WCMA-002 | P1 concurrency isolation |
| PENDING_PHYSICAL | Command requires real Watch proof for PASS |

---

## 19. Required answers (Command §19)

| # | Question | Answer |
|---|----------|--------|
| 1 | Production uses `startAbsoluteAltitudeUpdates` on Watch? | **YES** — `FullComputerEnvironmentSensorService.swift` L88 |
| 2 | Altimeter retained for async operation? | **YES** — L74 |
| 3 | Old callback can contaminate newer request? | **PARTIAL** — mitigated by `state == .sampling`; not proven for errors — WCMA-002 |
| 4 | Measurement time vs receipt time distinguished? | **NO** — WCMA-003 |
| 5 | Quality thresholds justified and enforced? | **PARTIAL** — enforced in code; justification incomplete — WCMA-004 |
| 6 | Proposal non-authoritative until accept? | **YES** |
| 7 | Rejection preserves import/manual? | **YES** |
| 8 | Bypass sampling/pending to start? | **NO** — `canStart` gates |
| 9 | Sea level absent as explicit/implicit fallback? | **YES** on live path |
| 10 | Surface pressure independently derived? | **YES** — oracle matches formula |
| 11 | Salinity/density consistent? | **YES** — cross-validated |
| 12 | Start revalidates sensor record? | **YES** — `validateForLiveStart(now:)` at `runtimePlan()` |
| 13 | Live runtime plans explicit? | **YES** |
| 14 | All 16 N2 compartments altitude-aware? | **PARTIAL** — mechanism yes; sensor-path oracle sweep incomplete |
| 15 | All 16 He compartments altitude-aware? | **PARTIAL** |
| 16 | Ceiling/NDL/TTS/schedule altitude-aware? | **PARTIAL** |
| 17 | Altitude applied exactly once? | **YES** |
| 18 | Environment mutable during active dive? | **NO** |
| 19 | Checkpoint/restore preserves environment? | **YES** — plan embedded in checkpoint |
| 20 | Logbook preserves source/timestamp/accuracy/precision? | **YES** when confirmed record present |
| 21 | Failures fail-closed? | **YES** |
| 22 | Deterministic tests cover negative paths? | **NO** — WCMA-005 |
| 23 | Watch target compiles with service? | **YES** |
| 24 | Real sensor path on physical Watch? | **NO** — PENDING_PHYSICAL |
| 25 | What blocks 100% readiness? | P1 WCMA-001/002, P2 test/timestamp gaps, physical QA |

---

## 20. Final verdict block

```text
WATCH_CMALTIMETER_FULL_COMPUTER_AUDIT: PARTIAL
BASELINE_CURRENT_AND_CLEAN: PASS
PRODUCTION_TARGET_MEMBERSHIP: PASS
CORE_MOTION_ABSOLUTE_ALTITUDE_API: PASS
ALTIMETER_LIFECYCLE_AND_CANCELLATION: PARTIAL
LATE_CALLBACK_ISOLATION: FAIL
SAMPLE_QUALITY_AND_FRESHNESS: PARTIAL
EXPLICIT_SENSOR_PROPOSAL_ACCEPTANCE: PASS
IMPORTED_AND_MANUAL_SOURCE_PRESERVATION: PASS
NO_EXPLICIT_OR_IMPLICIT_SEA_LEVEL: PASS
CANONICAL_ENVIRONMENT_VALIDATION: PASS
SURFACE_PRESSURE_DERIVATION: PASS
FULL_COMPUTER_STARTUP_PROPAGATION: PASS
ALL_16_N2_COMPARTMENTS_ALTITUDE_AWARE: PARTIAL
ALL_16_HE_COMPARTMENTS_ALTITUDE_AWARE: PARTIAL
NDL_TTS_CEILING_SCHEDULE_ALTITUDE_AWARE: PARTIAL
ACTIVE_DIVE_ENVIRONMENT_IMMUTABLE: PASS
CHECKPOINT_RESTORE_ENVIRONMENT: PASS
LOGBOOK_SENSOR_PROVENANCE: PARTIAL
AUTOMATED_NEGATIVE_COVERAGE: FAIL
MACOS_WATCH_BUILD: PASS
WATCH_ALGORITHM_TESTS: PASS
PHYSICAL_APPLE_WATCH_SENSOR_QA: PENDING_PHYSICAL
P0_FINDINGS: 0
P1_FINDINGS: 2
P2_FINDINGS: 6
P3_FINDINGS: 2
P4_FINDINGS: 1
SOFTWARE_READINESS_PERCENT: 78
PHYSICAL_READINESS_PERCENT: 0
RELEASE_BLOCKERS: WCMA-001, WCMA-002, PENDING_PHYSICAL
```
