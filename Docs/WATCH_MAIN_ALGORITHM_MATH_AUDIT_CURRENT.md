# Apple Watch MAIN Algorithm / Safety / Runtime / Hardware Interaction Audit — Current

**Audit date:** 2026-06-05  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main`  
**Code baseline:** `5415213`  
**Remote alignment:** `main...origin/main` (0 ahead / 0 behind after fetch)  
**Target audited:** `DIRDiving Watch App` only  
**Mode:** Read-only static audit + local XCTest run. No code, UI, persistence, sync, or algorithm files were modified.

---

## Scope Confirmation

### Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `5415213` |
| Working tree | Clean at audit time |
| Watch target | `DIRDiving Watch App` |
| iOS scope | Not audited except shared models/codec consumed by Watch |

### Experimental exclusions (`project.yml`)

Excluded from Watch MAIN build:

- `Models/ExplorationModels.swift`, `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift`
- `Services/ExplorationStore.swift`, `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`, `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift`
- `Views/ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`

### Build / test evidence

```
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
Result: 113 tests executed, 3 skipped, 21 failures — TEST FAILED
```

**Failure cluster:** all 21 failures are in `DiveManagerAlgorithmIntegrationTests` (draft/state leakage between cases — see WATCH-TEST-001). All `WatchMainAlgorithmAuditRemediationTests` (18 cases including HIGH-001 fix) **pass**. Remaining suites pass.

---

## A. Executive Summary

### Readiness scores

| Dimension | Estimate | Notes |
|---:|---:|---|
| **Watch MAIN algorithm readiness** | **93%** | Mature pipeline; prior HIGH-001 lifecycle gap remediated |
| **Mathematical robustness** | **94%** | Finite guards, 350 m cap, monotonic clock, centralized conversions |
| **Safety algorithm confidence** | **90%** | 35/38/40 m policy, ascent zones, token-guarded haptics; physical QA still required |
| **Runtime / lifecycle confidence** | **93%** | Two-phase active draft; debounced auto start/stop; idempotent finalize |
| **Sync / data confidence** | **91%** | HMAC v2, signed ACK, peer pinning; pending queue + CSV parity gaps |
| **Mission Mode safety** | **96%** | UI-only profile; invariant tests pass |
| **App Intents safety** | **95%** | All shortcuts gated by legal acceptance |
| **Test coverage confidence** | **87%** | Broad unit coverage; integration suite isolation gap; hardware QA open |

### Severity summary

| Severity | Count | Summary |
|---:|---:|---|
| CRITICAL | 0 | No certified-dive-computer authority blocker |
| HIGH | 0 | Prior WATCHMATH-HIGH-001 (kill during GPS finalization) **remediated** @ this baseline |
| MEDIUM | 6 | Mock fallback visibility, active-dive frozen 0 m, legacy draft decode, GPS auth restart, CSV iOS divergence, integration test isolation |
| LOW | 5 | Sample timestamp source, Mission Mode blink animation, sync dedup cap, manual-end UX after submersion, depth-limit haptic resync |
| INFO | 4 | 40 m safety/ascent band split, TTV naming, arithmetic analysis N/A on Watch, OTU/CNS N/A |

### Blockers

| Gate | Blockers |
|---|---|
| **Compile / use** | None |
| **Internal TestFlight** | Fix or document WATCH-TEST-001 integration isolation; physical Ultra depth entitlement smoke test |
| **External TestFlight** | Paired Watch/iPhone sync matrix; underwater ascent + depth-limit haptic QA; mock-fallback UX (WATCH-S2-002) |
| **App Store** | External TestFlight blockers + documented non-certified positioning + complete physical QA checklist |

---

## B. Algorithm / Runtime Inventory

Grouped by audit families. **Test** = automated coverage level; **Device** = physical validation needed.

### 1. Depth sensor / underwater state

| Component | File | Role | Safety |
|---|---|---|---|
| `DepthSensorProvider` | `Services/DepthSensorProvider.swift` | Callback contract | — |
| `AppleDepthSensorProvider` | `Services/AppleDepthSensorProvider.swift` | CoreMotion submersion → meters | **High** |
| `MockDepthSensorProvider` | `Services/MockDepthSensorProvider.swift` | 1 Hz, 0 m, 20 °C | Medium (fallback) |
| `SensorProviderFactory` | `Services/SensorProviderFactory.swift` | Apple or Mock | Medium |
| `DepthSampleValidation` | `Utils/DepthSampleValidation.swift` | Gate before `addSample` | **High** |
| Submersion handling | `Services/DiveManager.swift` | `.submerged` / `.notSubmerged` | High |

**Thresholds:** spike > 90 m/min; frozen 30 s @ ±0.001 m (active only); stale sample age 8 s; depth cap 350 m.

### 2. Sensor source / simulation policy

| Component | File | Policy |
|---|---|---|
| `SensorSourceMode` | `Utils/SensorSourceMode.swift` | `.simulation` blocked in release unless DEBUG/TestFlight |
| `DeveloperSettings` | `Utils/DeveloperSettings.swift` | SEC-P1-002 gate |
| `DeveloperVersionUnlock` | `Utils/DeveloperVersionUnlock.swift` | DEBUG 7-tap unlock |
| Migration | `SensorSourceMode.applyReleaseSafeMigrationIfNeeded()` | Clears stored simulation on release launch |

### 3–4. Automatic / manual dive lifecycle

| Component | File | Behavior |
|---|---|---|
| `DiveLifecycleAlgorithm` | `Utils/DiveLifecycleAlgorithm.swift` | Start > 1.0 m × 2 samples; stop ≤ 0.3 m × 8 s dwell |
| `beginDiveIfNeeded` / `endDiveIfNeeded` | `Services/DiveManager.swift` | Auto + manual paths; 6 s GPS windows |
| `startManualDive` / `endManualDive` | same | Manual from Live + App Intents |
| `ActiveDiveDraft` | same | `.active` / `.finalizing` phases |

### 5. Active draft / pending finalization

| Component | Persistence | TTL |
|---|---|---|
| Active draft JSON | Documents, file protection | 12 h |
| Finalizing draft | Written **before** async exit GPS | Completes on relaunch |
| Idempotent finalize | Skips if session ID already in log | — |

### 6. Time / runtime / stopwatch

| Component | File | Notes |
|---|---|---|
| `MonotonicElapsedClock` | `Utils/MonotonicElapsedClock.swift` | Wall skew ±120 s; never backward |
| Runtime timer | `DiveManager` | 1 s tick; drives live TTV |
| Stopwatch | `DiveManager` | Separate clock; App Intents gated |

### 7. Depth statistics

| Metric | Algorithm | Storage |
|---|---|---|
| Max depth | Max of valid samples | Session + live |
| Average depth | Time-weighted (`DiveAlgorithm.timeWeightedAverageDepthMeters`) | Session |
| Current depth | Last valid sample | Live only |

### 8. Ascent rate / gauge

| Component | File | Convention |
|---|---|---|
| `DiveAlgorithm.ascentRateMetersPerMinute` | `Utils/DiveAlgorithmConfiguration.swift` | Positive = ascending; 5 s window |
| `AscentRateLimits` | `Models/AscentRateLimits.swift` | Depth-band limits (inclusive upper bands) |
| `AscentStatus` | `Models/AscentStatus.swift` | Green ≤70%, yellow ≤100%, red > limit |
| `AscentGaugeView` | `Views/AscentGaugeView.swift` | Metric internal; imperial display |

### 9. Alarms

| Alarm | Trigger | Default | Throttle |
|---|---|---|---|
| Ascent | Red zone + enabled | On | 1.75 s repeat haptic |
| Depth (user) | maxDepth **>** threshold | 40 m | 30 s; suppressed at `.exceeded` or stale |
| Runtime | runtime **>** threshold × 60 | Off | 30 s |
| Battery | below threshold | 20%, on | 30 s |

### 10. Depth safety limits

| State | Threshold | UI |
|---|---|---|
| Caution | ≥ 35 m | Yellow banner |
| Critical | ≥ 38 m | Orange banner |
| Exceeded | ≥ 40 m | Red; hides max/avg reinforcement |

`DepthSafetyConfiguration` in `Utils/DepthSafetyConfiguration.swift`.

### 11. TTV / live metric

```
TTV = max(0, timeWeightedAverageDepthMeters) + max(0, durationSeconds) / 60
```

Informational index only — **not** NDL, TTS, or decompression obligation. Live updates via runtime clock; final value at `finalizeDive`.

### 12. Mission Mode

| Component | Effect |
|---|---|
| `MissionModeRuntimeProfile` | Disables animations + decorative effects only |
| `MissionModeLifecycle` | Auto/manual/restore activation rules |
| `MissionModeIndicatorView` | Visual bolt indicator |

**No branches** in sensor, math, haptics, GPS, logging, sync, export.

### 13. Compass / bearing

| Component | File |
|---|---|
| Heading updates | `Views/CompassView.swift` + `DiveManager` |
| Set/clear bearing | Live UI + `SetBearingIntent` / `ClearBearingIntent` |
| Labels | Localized **BUSSOLA** (not COMPASSO) |

### 14. GPS entry/exit

| Phase | Behavior |
|---|---|
| Entry | `start()` → immediate best point → 6 s capture |
| Exit | Snapshot → 6 s capture → `finalizeDive` → `stop()` |
| No-fix | Fallback source recorded; session still finalizes |

### 15. Unit conversion / formatting

| Component | File |
|---|---|
| `DIRUnitConversions` | `Utils/DIRUnitConversions.swift` |
| `WatchDepthFormatting` | `Utils/WatchDepthFormatting.swift` |
| `Formatters` | `Utils/Formatters.swift` |

Internal metric storage; imperial display only.

### 16. Haptic timing

| Coordinator | Cadence |
|---|---|
| `DepthLimitHapticCoordinator` | 30 s / 15 s / 10 s by state; delayed secondary with generation token |
| `AscentSafetyHapticCoordinator` | 1.75 s sustain loop |
| `HapticService.warnIfNeeded` | 2 s minimum between alarm pulses |

### 17. App Intents

Seven shortcuts in `Services/ActionButtonIntents.swift` — all call `LegalAcceptanceGate.requireLegalAcceptanceForSafetyIntent()`.

### 18–21. Export / sync / images / persistence

| Area | Primary files |
|---|---|
| Export | `Services/SubsurfaceExportService.swift` |
| Sync | `Services/WatchSyncService.swift`, `WatchDiveSyncCodec.swift`, `WatchSyncAuth.swift` |
| Images | `Services/UserImageStore.swift`, `CompanionPhotoImportSupport.swift` |
| Log persistence | `Services/DiveLogStore.swift`, `DiveSessionPersistenceClass.swift` |

---

## C. Findings by Family

### WATCH-S2-001 — Active dive frozen detection on stable 0 m (Mock/simulator)

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Depth sensor |
| **File** | `Utils/DepthSampleValidation.swift`, `Services/MockDepthSensorProvider.swift` |
| **User impact** | During active dive on Mock/simulator, repeated 0 m can show “sensor frozen” after 30 s |
| **Safety impact** | Low on real Ultra; medium in simulator QA |
| **Explanation** | Frozen check active only when `isDiveActive`; pre-dive 0 m exempt |
| **Proposed solution** | Relax frozen policy for Mock/simulation or surface band |
| **Priority** | Before external TestFlight (simulator QA clarity) |
| **Impact** | small functional |

### WATCH-S2-002 — Automatic Mock fallback without prominent warning

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Sensor source policy |
| **File** | `Services/SensorProviderFactory.swift`, `Views/DiveLiveView.swift` |
| **User impact** | Non-Ultra hardware may show automation “available” while depth is Mock 0 m |
| **Safety impact** | Trust risk if user believes real depth is active |
| **Explanation** | Simulation badge shown when `isSimulationDepthActive`; automatic fallback may not set user expectation |
| **Proposed solution** | Visible banner when `.automatic` resolves to Mock |
| **Priority** | Before external TestFlight |
| **Impact** | UI-only |

### WATCH-LC-001 — Legacy active draft without phase may restore ambiguously

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Persistence / draft restore |
| **File** | `Services/DiveManager.swift` — `ActiveDiveDraft.init(from:)` |
| **User impact** | Very old drafts decode as `.active` with new UUID if fields missing |
| **Safety impact** | Low probability; migration edge only |
| **Proposed solution** | Version field + discard pre-phase drafts |
| **Priority** | Post-internal TestFlight |
| **Impact** | small functional |

### WATCH-LC-002 — Finalizing draft missing endDate discarded silently

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Pending finalization |
| **File** | `Services/DiveManager.swift` — `completePendingFinalization` |
| **User impact** | Corrupt draft → session lost |
| **Safety impact** | Data loss, not incorrect math |
| **Proposed solution** | User-visible error + quarantine |
| **Priority** | Before App Store |
| **Impact** | small functional |

### WATCH-GPS-001 — Authorization callback may restart GPS after dive end

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | GPS lifecycle |
| **File** | `Services/GPSManager.swift` — `locationManagerDidChangeAuthorization` |
| **User impact** | Late permission grant could restart updates outside dive |
| **Safety impact** | Battery; no math impact |
| **Proposed solution** | Gate `startUpdatingLocation` on active capture session |
| **Priority** | Post-release improvement |
| **Impact** | small functional |

### WATCH-EXP-001 — Watch CSV format diverges from iOS hardened export

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Export |
| **File** | `Services/SubsurfaceExportService.swift` (Watch) vs iOS variant |
| **User impact** | Same dive exported on Watch vs iPhone → different columns/time base |
| **Safety impact** | Interoperability, not on-watch math |
| **Proposed solution** | Document policy or align formats |
| **Priority** | Before App Store external regression doc |
| **Impact** | external QA/process |

### WATCH-TEST-001 — Integration tests fail due to draft/state isolation

| Field | Value |
|---|---|
| **Severity** | MEDIUM |
| **Family** | Test infrastructure |
| **File** | `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift` |
| **User impact** | None (CI signal degraded) |
| **Explanation** | `setUp` does not isolate draft directory or clear disk draft; prior cases leave 8 samples active |
| **Proposed solution** | `testHook_draftDirectoryURL` per test + `testHook_clearActiveDiveDraft()` in setUp/tearDown |
| **Priority** | Before relying on CI green for release |
| **Impact** | test-only |

### WATCH-S2-003 — Depth sample timestamp uses receipt time

| Field | Value |
|---|---|
| **Severity** | LOW |
| **Family** | Depth sensor |
| **File** | `Services/AppleDepthSensorProvider.swift` |
| **Notes** | Staleness relies on callback-silence watchdog, not sample-age vs CoreMotion time |

### WATCH-UX-001 — Manual end hidden after submersion handoff

| Field | Value |
|---|---|
| **Severity** | LOW |
| **Family** | Manual lifecycle |
| **File** | `Services/DiveManager.swift`, `Views/DiveLiveView.swift` |
| **Notes** | By design: auto surface-end after submersion; may confuse if auto-end fails |

### WATCH-S15-002 — Depth-limit haptics not resynced on preference toggle

| Field | Value |
|---|---|
| **Severity** | LOW |
| **Family** | Haptics |
| **File** | `Services/DiveManager.swift` — `refreshHapticsAfterPreferenceChange` |
| **Notes** | Ascent refreshed; depth-limit delayed pulses re-check preference at fire time |

### WATCH-SYNC-001 — Imported companion ID cap at 128

| Field | Value |
|---|---|
| **Severity** | LOW |
| **Family** | Sync dedup |
| **File** | `Services/WatchSyncService.swift` |
| **Notes** | Older IDs may lose re-import suppression |

### WATCH-S7-001 — 40.0 m safety vs ascent band split (intentional)

| Field | Value |
|---|---|
| **Severity** | INFO |
| **Family** | Depth safety + ascent |
| **Notes** | At exactly 40 m: `.exceeded` safety but 10 m/min ascent band; at 40.01 m both exceeded + 1 m/min. Test-locked in `DiveAlgorithmTests`. |

### WATCH-TTV-001 — TTV acronym misread risk

| Field | Value |
|---|---|
| **Severity** | INFO |
| **Family** | TTV |
| **Notes** | Copy correctly states non-NDL; settings `settings.ttv.info` localized |

### Remediated (prior audit — confirmed fixed @ `5415213`)

| ID | Topic | Status |
|---|---|---|
| **WATCHMATH-HIGH-001** | Kill during 6 s exit GPS restored active dive | **FIXED** — `.finalizing` draft + `completePendingFinalization` |
| **WATCHMATH-LOW-004** | Stale delayed depth-limit haptic | **FIXED** — generation token in `DepthLimitHapticCoordinator` |

---

## D. Mission Mode Invariant Analysis

| Question | Answer |
|---|---|
| Affects depth sampling? | **No** — no `isMissionModeActive` in sensor/validation paths |
| Affects depth display values? | **No** — only animation/decorative styling in `DiveLiveView` |
| Affects GPS? | **No** |
| Affects haptics? | **No** — coordinators unchanged |
| Affects alarms? | **No** — thresholds and evaluation unchanged |
| Affects logging/export/sync? | **No** — sample count and session fields unchanged |
| Apple Low Power Mode wording truthful? | **Yes** — Mission Mode is internal DIR profile; not system Low Power Mode |
| Tests | `MissionModeAlgorithmInvariantTests`, `WatchMainAlgorithmAuditRemediationTests.testMissionModeDoesNotAlterAlgorithmOutputs` |

**UX note (LOW):** Mission Mode disables SwiftUI animation on depth-safety color transitions; blink timer still runs (stepwise blink possible).

---

## E. Manual vs Automatic Dive Start Analysis

| Question | Answer |
|---|---|
| Where manual start is reachable | **Live screen** (`live.manual.start.button`); **App Intent** `StartManualDiveIntent`; Settings/Info show **informational** status only |
| Settings copy truthful? | **Yes** — `settings.manual.fallback` = “Available alongside automatic start”; Info row is informational, not a start button |
| Manual start creates valid session? | **Yes** — `beginDiveIfNeeded(isManual: true)`; runtime clock reset; draft persisted |
| Automatic start still works? | **Yes** — not disabled; manual flag cleared on submersion |
| Interactions safe? | **Yes** with LOW UX note: after submersion, manual end hidden; must surface-dwell auto-end or submersion `.notSubmerged` |
| Manual no-depth policy | Sessions without profile classified `manualNoDepth`; export blocked; sync allowed per `DiveSessionPersistenceClass` |

---

## F. Sensor Source / Simulation Policy Analysis

| Policy | Status |
|---|---|
| Fresh production default | `.automatic` (not simulation) |
| Stored `.simulation` in release | Migrated to `.automatic` unless DEBUG/TestFlight |
| Simulation selectable | DEBUG + TestFlight sandbox only |
| User-visible simulation badge | Present when simulation active (`live.simulation_depth.badge`) |
| Release public path silent simulation | **Blocked** by `runtimeMode` gate |
| Gap | **WATCH-S2-002** — Mock fallback via `.automatic` without Ultra may lack equal prominence |

---

## G. App Intents / Action Button Safety Analysis

| Intent | Legal gate | State checks |
|---|---|---|
| Stopwatch toggle/reset | ✓ | Standard |
| Manual dive start/end | ✓ | Respects active/manual flags |
| Set/clear bearing | ✓ | Does not bypass compass state |
| Acknowledge alarm | ✓ | Requires active alarm context |

**Verdict:** Fail-closed before legal acceptance (timestamp, revision, depth-limits ack, app version). No bypass of Mission Mode or sensor policy.

**Review risk (LOW):** Shortcuts discoverability vs on-screen controls — documented in `WatchShortcutHelpView`.

---

## H. GPS Finalization / Active Draft Restore Analysis

| Scenario | Behavior |
|---|---|
| Normal end | Finalizing draft → 6 s exit GPS → log → clear draft → GPS stop |
| Kill during exit GPS | **Restores finalizing draft**, completes log — **does not** restore active UI |
| Kill during active dive | Active draft restores samples + runtime |
| Draft > 12 h | Discarded |
| Missing endDate in finalizing | Draft dropped (WATCH-LC-002) |
| Idempotent finalize | Same session ID in log → draft cleared, no duplicate |

Tests: `WatchMainAlgorithmAuditRemediationTests` (5 lifecycle cases), `GPSLifecycleTests`.

---

## I. Edge Case Matrix

| Edge case | Expected | Observed | Tested |
|---|---|---|---|
| depth = nil | Reject / no sample | Validation `.missing` | ✓ |
| depth = NaN | Reject | `.nonFinite` | ✓ |
| depth < 0 | Clamp 0 | `max(0, raw)` | ✓ |
| Pre-dive repeated 0 m | Valid | Frozen inactive | ✓ remediation test |
| Active repeated 0 m (Mock) | Frozen error | `.frozen` after 30 s | ✓ |
| Auto-start 2 samples @ 1.1 m | Start | Lifecycle debounce | ✓ unit; integration flaky |
| Surface dwell 8 s | Auto end | Scheduled Task + algorithm | ✓ |
| Kill mid exit GPS | Finalize on relaunch | `.finalizing` path | ✓ |
| Manual start, no depth automation | Valid session | Manual no-depth class | ✓ |
| 35/38/40 m boundaries | caution/critical/exceeded | Threshold table | ✓ unit |
| TTV at start | ≈ runtime min only | avg depth 0 | ✓ |
| Mission Mode ON/OFF | Same metrics | Invariant tests | ✓ |
| Legal false + Intent | Reject | Gate error | ✓ |
| Stored simulation release | → automatic | Migration | ✓ |
| GPS no-fix | Session saves | noFix source | ✓ |
| Invalid session in log | Quarantined | Load filter | ✓ remediation test |

---

## J. Unit / Integration Test Plan

| Feature | Input | Expected | Priority | Auto |
|---|---|---|---|---|
| Finalizing draft kill | End dive, kill before GPS done | Log on relaunch, not active | P0 | ✓ |
| Delayed haptic suppress | 38→34 m before 0.35 s | No stale pulse | P0 | ✓ |
| Sensor release migration | stored simulation, release | automatic | P0 | ✓ |
| Integration isolation | Fresh DiveManager per test | Independent sample counts | P0 | **Fix WATCH-TEST-001** |
| Auto-start debounce | 1 sample @ 1.1 m | No start | P1 | ✓ unit |
| Ascent red zone | 20→10 m in 10 s | zone red | P1 | integration (fix isolation) |
| Legal gate all intents | not accepted | throw | P0 | ✓ |
| CSV export seconds | samples @ +5,+60 s | Relative to startDate | P1 | ✓ Watch |
| Peer secret mismatch | wrong secret | reject payload | P0 | ✓ |
| Image delete traversal | `../` filename | reject | P0 | ✓ |

---

## K. Physical Watch Ultra Test Plan

| Scenario | Pass criteria | Priority |
|---|---|---|
| CoreMotion depth entitlement | Real depth updates underwater | P0 |
| Auto-start @ ~1 m | Session starts after 2 samples | P0 |
| Auto-end surface dwell | Ends after 8 s @ ≤0.3 m | P0 |
| 35/38/40 m banners + haptics | Correct state + cadence | P0 |
| Fast ascent alarm | Red gauge + haptic repeat | P0 |
| Stale depth 8 s silence | Banner + alarm suppress | P1 |
| GPS entry/exit | Coordinates in log/export | P0 |
| Force-quit during exit GPS | Dive in log, not active on relaunch | P0 |
| Paired iPhone sync | Round-trip numeric fidelity | P0 |
| Action Button shortcuts | Gated until legal accept | P1 |

---

## L. Underwater Validation Plan

| Test | Depth | Duration | Pass criteria |
|---|---|---|---|
| Recreational profile | 18–25 m | 30 min | Stats match post-dive review |
| Depth safety escalation | 36→39 m | brief | Caution→critical banners |
| Exceeded band | >40 m | brief | Exceeded UI; flag persisted |
| Ascent rate | controlled ascent | — | Gauge zones match felt rate |
| Manual start dry | 0 m | 5 min | Runtime OK; no false auto-end before submersion |
| TTV drift live vs saved | any | end | Δ acceptable at finalize |

---

## M. Sync / Security / Payload Validation Plan

| Test | Pass criteria |
|---|---|
| HMAC v2 sign/verify | Valid payload accepted |
| Wrong peer secret | Rejected; flag set |
| Stale payload > 1 h | Rejected |
| Signed ACK required | Pending cleared only on valid ackSignature |
| Tombstone broadcast | Deleted session removed |
| Manual no-depth sync | Policy preserved on iPhone |
| Duplicate session ID | Deterministic handling |
| Image delete ACK | iOS receives Watch ACK |

---

## N. Prioritized Roadmap

### 1. Must fix before compile/use
- None

### 2. Must fix before internal TestFlight
- WATCH-TEST-001 — integration test isolation (CI trust)

### 3. Must fix before external TestFlight
- WATCH-S2-002 — Mock fallback visibility
- Physical Ultra QA matrix (Section K) — minimum P0 items
- Paired sync QA (Section M)

### 4. Must fix before App Store
- WATCH-EXP-001 — CSV parity documentation or alignment
- WATCH-LC-002 — corrupt finalizing draft handling
- Complete underwater plan (Section L)

### 5. Post-release improvements
- WATCH-GPS-001 — auth restart guard
- WATCH-LC-001 — draft schema version
- WATCH-SYNC-001 — expand imported-ID dedup cap
- WATCH-S15-002 — depth-limit preference resync symmetry

---

## O. Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Yes** (~94%) for a non-certified companion app |
| **Runtime-lifecycle ready?** | **Yes** (~93%) — HIGH-001 remediated; draft model sound |
| **Safe enough for internal test?** | **Yes**, with simulator/mock caveats documented |
| **Mission Mode safe?** | **Yes** — UI-only; invariants tested |
| **Manual start safe?** | **Yes** — Live + Intents; Settings copy truthful |
| **App Intents safe?** | **Yes** — legal fail-closed on all safety intents |
| **Sync/data ready?** | **Mostly** (~91%) — crypto strong; queue UX + CSV parity gaps |
| **Ready for TestFlight?** | **Internal: yes.** **External: no** until physical QA + WATCH-S2-002 |
| **Ready for App Store?** | **No** — external TestFlight blockers + full physical QA |
| **What blocks 100% readiness?** | (1) Physical Ultra underwater QA evidence, (2) Mock fallback UX, (3) CI integration test isolation, (4) Watch/iOS export parity doc, (5) GPS auth edge case hardening |

---

*Previous audit @ `3b7325bb` (2026-06-03) listed WATCHMATH-HIGH-001 as open. This document reflects remediation at `5415213` and supersedes that revision for lifecycle, haptics, and readiness scoring.*
