# DIR Diving Watch MAIN Algorithm / Mathematical Logic Audit

**Audit date:** 2026-06-07  
**Repository:** DIR DIVING (`DirDiving-App`)  
**Branch audited:** `main`  
**Code baseline:** `c314b93` (`docs: index Bühlmann hardening pass @ 74035fd`)  
**Remote alignment:** `main...origin/main` (0 ahead / 0 behind after fetch)  
**Target audited:** `DIRDiving Watch App` only  
**Mode:** Read-only audit + macOS build/test. **No code, UI, persistence, sync, or algorithm files were modified. No commit. No push.**

**Supersedes:** prior `DIR_DIVING_WATCH_ALGORITHM_MATH_AUDIT.md` @ 2026-05-27; parallel current snapshot in [`WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`](WATCH_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md) @ `5415213` (pre-remediation test failures).

---

## Executive Summary

The Apple Watch MAIN app at `c314b93` is a **mature non-certified dive companion**: live depth visualizer, logger, safety-warning layer, GPS surface capture, authenticated WatchConnectivity sync, and reference-only TTV index. It is **not** a Bühlmann/decompression computer; iOS Companion owns planning math.

### Readiness estimates

| Dimension | Estimate | Notes |
|---:|---:|---|
| **Watch MAIN algorithm readiness** | **94%** | Centralized `DiveAlgorithmConfiguration`; validated ingest; two-phase draft/finalization |
| **Mathematical robustness** | **95%** | Finite guards, 350 m cap, monotonic runtime clock, metric internal storage |
| **Safety algorithm confidence** | **91%** | 35/38/40 m depth policy, ascent zones, token-guarded delayed haptics; **physical Ultra QA still required** |
| **Runtime / lifecycle confidence** | **93%** | Auto start/stop debounce, manual paths, crash-safe `.finalizing` draft |
| **Sync / data confidence** | **90%** | HMAC v2 dive payloads, signed ACK on direct messages, peer TOFU pinning; pending-queue gap on `transferUserInfo` |
| **Mission Mode safety** | **96%** | UI-only profile; invariant tests pass |
| **App Intents safety** | **94%** | All safety intents gated by `LegalAcceptanceGate`; wiring untested end-to-end |
| **Test coverage confidence** | **88%** | **135 XCTest pass** @ this baseline; gaps on Watch sync E2E, ascent haptic coordinator, App Intent wiring |

### Severity summary

| Priority | Count | Summary |
|---:|---:|---|
| **P0** | **0** | No safety-critical live-math blocker or auth bypass on dive payloads |
| **P1** | **4** | Sync pending dequeue on userInfo; mock depth fallback visibility; TestFlight simulation policy; ascent haptic regression gap |
| **P2** | **9** | Silent persistence I/O; draft restore avg-depth tail; auto-end integration test gap; Watch sync service untested on Watch target; App Intent E2E; haptic interval tests; GPS placeholder test; companion photo WC unauthenticated |
| **P3** | **8** | 40 m ascent/safety band split; double classify; expired draft discard; temperature bounds; CSV header-only helper; documentation drift |
| **P4** | **5** | Process/physical QA, TTV naming clarity, arithmetic analysis N/A on Watch |

### Critical blockers

| Gate | Status |
|---|---|
| **Compile / internal use** | **Ready** — Watch build succeeded |
| **Internal algorithm validation (macOS)** | **Ready** — 135 tests, 0 failures |
| **Internal TestFlight (Watch)** | **Almost ready** — physical Ultra depth + haptic smoke; sync matrix |
| **External TestFlight** | **Not yet** — paired device QA, underwater ascent/depth-limit validation |
| **App Store** | **Not yet** — external TestFlight blockers + legal review unchanged |
| **Certified dive computer claim** | **Never supported / not claimed** |

---

## Scope Confirmation

### Preflight

| Check | Result |
|---|---|
| Branch | `main` |
| HEAD | `c314b93` |
| Working tree | Clean at audit time |
| Remote | `origin/main` aligned |
| Watch target | `DIRDiving Watch App` |
| iOS Companion | **Not audited** except shared models/codec (`Models/DiveSession.swift`, `Models/DiveSample.swift`, sync codec consumed by Watch) |
| Experimental scope | **Excluded** per `project.yml` |
| Code modified | **No** |
| Commit / push | **No** |

### Experimental exclusions (`project.yml` — confirmed unchanged)

Excluded from Watch MAIN build:

| Category | Files |
|---|---|
| Models | `ExplorationModels.swift`, `BuddyAssistMessage.swift`, `BuddyPairingHandshake.swift` |
| Services | `ExplorationStore.swift`, `BuddyAssistService.swift`, `BuddyAssistPeripheralService.swift`, `BuddyPairingKeyAgreement.swift`, `SecureBuddyStore.swift` |
| Views | `ApneaView.swift`, `SnorkelingView.swift`, `BuddyAssistView.swift`, `ExperimentalConceptsView.swift` |
| Utils | `ExperimentalFeatures.swift` |

Snorkeling / Apnea / Buddy / Exploration Lab remain **out of scope**.

### Product semantics preserved (audit confirms)

| Rule | Code alignment |
|---|---|
| Non-certified companion | Legal onboarding + disclaimers present; no decompression obligation on Watch |
| TTV informational only | `ttvIndex = avgDepth + durationMinutes`; not NDL/TTS |
| Mission Mode internal profile | `MissionModeRuntimeProfile` — animations/effects only |
| Manual dive from Live | `startManualDive` / App Intent paths present |
| Auto start depth-triggered | `DiveLifecycleAlgorithm` > 1.0 m × 2 samples |
| Simulation not silent in release | `SensorSourceMode.applyReleaseSafeMigrationIfNeeded()` + `runtimeMode` sanitization |
| App Intents fail closed pre-legal | `ActionButtonIntents.requireLegalAcceptanceForSafetyIntent()` |
| Watch source of truth for user images | `UserImageStore` + inventory publish |
| Depth safety conservative | 35/38/40 m; no positive reinforcement beyond 40 m |
| **BUSSOLA** terminology | IT key `"BUSSOLA"`; **no `COMPASSO` in Watch MAIN Swift or IT strings** |

---

## Repository State

| Item | Value |
|---|---|
| Branch | `main` @ `c314b93` |
| Remote | `https://github.com/egopfe/DirDiving-App` |
| Build host | macOS (Darwin), XcodeGen + xcodebuild |
| Watch simulator | **Apple Watch Ultra 3 (49mm)** — Ultra 2 (49mm) unavailable on this host |
| Watch app build | **BUILD SUCCEEDED** |
| Watch algorithm tests | **135 executed, 3 skipped, 0 failures** (~3.6 s) |

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
```

**Regression note:** Prior audit @ `5415213` reported **21 failures** in `DiveManagerAlgorithmIntegrationTests` (state leakage). At `c314b93` the full Watch suite passes — remediation verified.

---

## Files Inspected

### Core runtime & services (Watch MAIN)

- `Services/DiveManager.swift`
- `Services/DepthSensorProvider.swift`
- `Services/AppleDepthSensorProvider.swift`
- `Services/MockDepthSensorProvider.swift`
- `Services/SensorProviderFactory.swift`
- `Services/GPSManager.swift`
- `Services/HapticService.swift`
- `Services/DepthLimitHapticCoordinator.swift`
- `Services/AscentSafetyHapticCoordinator.swift`
- `Services/WatchSyncService.swift`
- `Services/WatchDiveSyncCodec.swift`
- `Services/WatchSyncAuth.swift`
- `Services/DiveLogStore.swift`
- `Services/SubsurfaceExportService.swift`
- `Services/UserImageStore.swift`
- `Services/CompassManager.swift`
- `Services/ActionButtonIntents.swift`
- `Services/AscentRateSettingsStore.swift`
- `Services/AlarmSettingsStore.swift`
- `Services/DiveReminderSettingsStore.swift`

### Models (shared + Watch)

- `Models/DiveSession.swift`
- `Models/DiveSample.swift`
- `Models/GPSPoint.swift`
- `Models/AscentRateLimits.swift`
- `Models/AscentStatus.swift`
- `Models/DepthSafetyConfiguration.swift`
- `Models/DiveGPSConfirmation.swift`

### Utilities & algorithm core

- `Utils/DiveAlgorithmConfiguration.swift` (includes `DiveAlgorithm` enum)
- `Utils/DiveLifecycleAlgorithm.swift`
- `Utils/DepthSampleValidation.swift`
- `Utils/DiveSessionAlgorithmValidator.swift`
- `Utils/DiveSessionMerge.swift`
- `Utils/DiveSessionPersistenceClass.swift`
- `Utils/DiveLogbookPolicy.swift`
- `Utils/MonotonicElapsedClock.swift`
- `Utils/MissionModeRuntimeProfile.swift`
- `Utils/SensorSourceMode.swift`
- `Utils/DeveloperSettings.swift`
- `Utils/DeveloperVersionUnlock.swift`
- `Utils/DepthSensorSourceResolution.swift`
- `Utils/DiveDepthMeasurementIngestion.swift`
- `Utils/GPSFallbackPolicy.swift`
- `Utils/GPSConfirmationPresentation.swift`
- `Utils/WatchDepthFormatting.swift`
- `Utils/DIRUnitConversions.swift`
- `Utils/Formatters.swift`
- `Utils/WatchSyncKeys.swift`
- `Utils/WatchSyncNotifications.swift`
- `Utils/CompanionPhotoImportSupport.swift`
- `Utils/CompanionPhotoManagementSupport.swift`
- `Utils/WatchCompanionPhotoValidator.swift`
- `Utils/LegalAcceptanceGate.swift`
- `Utils/DiveAlgorithmSelfCheck.swift`
- `Utils/DepthSafetySelfCheck.swift` (debugger helper)

### Views (algorithmic/runtime bindings)

- `Views/DiveLiveView.swift`
- `Views/AscentGaugeView.swift`
- `Views/AscentWarningView.swift`
- `Views/AscentWarningBannerView.swift`
- `Views/DepthSafetyLiveViews.swift`
- `Views/AlarmSettingsView.swift`
- `Views/AscentRateSettingsView.swift`
- `Views/CompassView.swift`
- `Views/DiveDetailView.swift`
- `Views/DiveLogListView.swift`
- `Views/SettingsView.swift`
- `Views/InfoView.swift`
- `Views/UserImagesView.swift`
- `Views/MissionModeIndicatorView.swift`
- `Views/WatchShortcutHelpView.swift`
- `Views/WatchLegalOnboardingView.swift`
- `Views/ExportView.swift`
- `Views/WatchSyncDiagnosticsView.swift`

### Localization

- `Resources/en.lproj/Localizable.strings`
- `Resources/it.lproj/Localizable.strings`

### Tests (all 21 files)

- `Tests/WatchAlgorithmTests/*.swift` (135 test methods)

### Project & reference docs (read-only)

- `project.yml`
- `README.md`
- `Docs/WATCH_SENSOR_SOURCE_RELEASE_POLICY.md`
- `Docs/WATCH_GPS_LIFECYCLE_POLICY.md`
- `Docs/MISSION_MODE_MAIN_WATCH.md`
- `Docs/WATCH_MANUAL_NODEPTH_SYNC_POLICY.md`
- `Docs/WATCH_CSV_EXPORT_POLICY.md`
- `Docs/WATCH_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`
- `Docs/WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`

### Shared iOS consumed by Watch (inspection only)

- `iOSApp/Services/WatchDiveSyncCodec.swift` (parity reference)
- `iOSApp/Services/WatchSyncAuth.swift` (v2 secret derivation parity)

---

## Algorithm / Runtime Inventory

Grouped inventory. **Safety** = user-facing risk if wrong. **Device** = requires physical Watch Ultra validation.

### 1. Depth sensor / underwater state

| Component | File | Input → Output | Safety | Tests | Device |
|---|---|---|---|---|---|
| Provider protocol | `DepthSensorProvider.swift` | callbacks: depth, submersion, temp | High | Indirect | Yes |
| Apple HW | `AppleDepthSensorProvider.swift` | CMWaterSubmersion → meters | **Critical** | None (HW) | **Yes** |
| Mock | `MockDepthSensorProvider.swift` | 1 Hz, 0 m, 20 °C | Medium | `DeveloperSensorSourceTests` | Sim |
| Factory | `SensorProviderFactory.swift` | mode → provider | Medium | `DeveloperSensorSourceTests` | Yes |
| Validation | `DepthSampleValidation.swift` | raw → valid/reject reason | **Critical** | `DiveAlgorithmTests`, remediation suites | Partial |
| Ingestion | `DiveDepthMeasurementIngestion.swift` | measurement → sample policy | High | `DiveDepthMeasurementIngestionTests` | Partial |
| Orchestration | `DiveManager.processDepthMeasurement` | validated → lifecycle + stats | **Critical** | Integration + remediation | **Yes** |

**Thresholds:** depth cap **350 m**; spike **> 90 m/min**; frozen **30 s @ ±0.001 m** (active); stale age **8 s**; callback silence **8 s** (active dive).

### 2. Sensor source / simulation policy

| Component | File | Policy | Tests |
|---|---|---|---|
| `SensorSourceMode` | `Utils/SensorSourceMode.swift` | Release sanitizes `.simulation` → `.automatic` | `DeveloperSensorSourceTests` |
| `DeveloperSettings` | `Utils/DeveloperSettings.swift` | Simulation only DEBUG/TestFlight | Same |
| `DeveloperVersionUnlock` | `Utils/DeveloperVersionUnlock.swift` | `#if DEBUG` 7-tap unlock | **None** |
| Launch migration | `App/DIRDivingApp.swift` | `applyReleaseSafeMigrationIfNeeded()` | Indirect |

### 3–4. Automatic / manual dive lifecycle

| Component | File | Behavior | Tests |
|---|---|---|---|
| `DiveLifecycleAlgorithm` | `Utils/DiveLifecycleAlgorithm.swift` | Start **> 1.0 m × 2**; stop **≤ 0.3 m × 8 s** | `DiveAlgorithmTests` |
| Auto paths | `DiveManager.beginDiveIfNeeded/endDiveIfNeeded` | GPS 6 s windows; submersion handoff | Remediation + integration |
| Manual paths | `startManualDive/endManualDive` | No fake depth; manual no-depth policy | Integration |
| App Intents | `ActionButtonIntents.swift` | Manual start/end after legal gate | Gate only |

### 5–6. Active draft / time / stopwatch

| Component | Persistence | TTL / clock | Tests |
|---|---|---|---|
| `ActiveDiveDraft` | UserDefaults JSON | **12 h** TTL; `.active` / `.finalizing` | `WatchMainAlgorithmAuditRemediationTests` |
| Runtime | `MonotonicElapsedClock` + 1 s timer | 120 s forward skew tolerance | `WatchReadinessAlgorithmTests`; Manager gap |
| Stopwatch | UserDefaults | Independent of dive runtime | **Gap** |
| TTV | computed each tick | `avgDepth + duration/60` | Algorithm + validator tests |

### 7–8. Depth statistics & ascent rate

| Metric | Formula / source | Tests |
|---|---|---|
| Max depth | max valid sample depth | Integration |
| Avg depth | Time-weighted; tail to `endDate` or restore `Date()` | `DiveAlgorithmTests`, integration |
| Ascent rate | 5 s window, min Δt 1 s, ascent-only, cap 90 m/min | `DiveAlgorithmTests`, `MissionModeAlgorithmInvariantTests` |
| Ascent limits | 10 / 5 / 3 / 1 m/min bands (`AscentRateLimits.standard`) | `WatchReadinessAlgorithmTests` |
| Zones | Green ≤70%, yellow ≤100%, red >100% of limit | Same |

### 9–11. Alarms & depth safety

| System | Thresholds | Tests |
|---|---|---|
| Depth safety states | 35 caution / 38 critical / 40 exceeded | Integration + invariants |
| Depth limit haptics | Throttle 30/15/10 s; delayed +0.35 s / +0.25 s | `WatchMainAlgorithmAuditRemediationTests` |
| Ascent haptics | Repeat **1.75 s** while red | **None** (coordinator) |
| User depth alarm | Default 40 m, `maxDepth > threshold` | Partial |
| Runtime / battery alarms | `WatchAlarmDefaults` | Reminder integration |

### 12–13. TTV & Mission Mode

| Item | Semantics | Mission Mode effect |
|---|---|---|
| TTV | `avgDepthMeters + durationSeconds/60` — **informational index** | **None** (invariant tests) |
| Mission Mode | Disables SwiftUI animations/decorative effects only | **None** on math/logging/haptics/GPS |

### 14–15. Compass / GPS

| Item | File | Notes |
|---|---|---|
| Heading / bearing | `CompassManager.swift`, `DiveAlgorithmConfiguration.normalizedDegrees` | Wrap 0–360; signed delta |
| BUSSOLA UI | `CompassView.swift`, Localizable.strings | IT: **BUSSOLA** |
| GPS capture | `GPSManager.swift` | Best-effort 6 s; one-shot optional stop |
| Finalization | `DiveManager` two-phase draft | Crash recovery tested |

### 16–22. Units, haptics, intents, export, sync, persistence

See phase assessments below. Central modules: `DIRUnitConversions.swift`, `WatchDepthFormatting.swift`, `Formatters.swift`, `SubsurfaceExportService.swift`, `WatchDiveSyncCodec.swift`, `WatchSyncService.swift`, `DiveLogStore.swift`.

---

## Depth Sensor / Underwater State Assessment

**Verdict: Pass with hardware QA required**

| Check | Result |
|---|---|
| Pipeline order | Provider → validate → lifecycle / addSample |
| Sign convention | Depth ≥ 0 stored; negative rejected/clamped |
| Auto-start threshold | **Strict > 1.0 m** (1.0 m does not start) |
| Auto-stop | **≤ 0.3 m** for 8 s dwell |
| Invalid depth | Non-finite, out of range, spike, stale, frozen rejected |
| Nil depth | Treated as missing → validation failure / no auto-start |
| Mock at 0 m | Cannot auto-start; surface frozen exempt when mock/simulation |
| Sensor loss mid-dive | 8 s callback silence → `isDepthDataStale` |
| Submersion API | `.submerged` enables manual auto-end handoff; `.notSubmerged` uses **previous** sample |

| Edge case | Expected (code) | Tested |
|---|---|---|
| depth = nil | Reject / no start | Partial |
| depth = NaN | Reject | Yes |
| depth < 0 | Reject/clamp | Yes |
| depth just below/above 1 m | No start / start after 2 samples | Yes |
| Sudden jump > 90 m/min | Spike reject | Yes |
| Frozen 30 s same depth | Reject (active, non-exempt) | Yes |
| Sensor disappears 8+ s | Stale flag | Integration |
| Manual dive, sensor unavailable | Manual no-depth path | `WatchReadinessAlgorithmTests` |

**Risks:** P1 mock fallback on hardware without submersion entitlement (0 m forever, UI badge mitigates). P2 Apple depth timestamps use **receipt time** (`Date()`), weakening stale detection vs sensor clock.

---

## Sensor Source / Simulation Policy Assessment

**Verdict: Pass for release paths**

| Check | Result |
|---|---|
| Default stored mode | `.automatic` |
| Release `.simulation` | Sanitized to `.automatic` at read + migration on launch |
| Selectable in release | `.automatic`, `.appleSensor` only |
| TestFlight | Simulation allowed (intentional QA) — **P1 policy risk** if misused |
| DEBUG unlock | 7-tap → developer section (`DeveloperVersionUnlock`) |
| User-visible simulation | `isSimulationDepthActive` / mock fallback flags in UI |
| Fresh production install | Does **not** default to simulation |

Tests: `DeveloperSensorSourceTests.swift` (5 tests).

---

## Dive Lifecycle Assessment

**Verdict: Pass — integration gap on auto-end E2E**

| Path | Behavior |
|---|---|
| Automatic start | 2 samples > 1.0 m; triggering sample retained once |
| Automatic end | 8 s dwell ≤ 0.3 m OR submersion `.notSubmerged` with shallow prior |
| Manual start | Sets manual flags; does not inject fake depth |
| Manual end | Ends session; GPS exit capture |
| Duplicate prevention | Idempotent finalize by session ID |
| Draft restore | `.active` resumes dive; `.finalizing` completes without re-GPS |
| Cooldowns | Surface candidate cleared if depth re-rises above 0.3 m |

| Gap | Severity |
|---|---|
| Automatic end via `scheduleAutomaticSurfaceEnd` not fully integration-tested in `DiveManager` | P2 |
| Expired active draft (>12 h) discarded without quarantine | P2 |
| Auto dive ending with empty depth profile → `invalid` on persist | P2 |

Tests: `DiveLifecycleAlgorithm` strong; `WatchMainAlgorithmAuditRemediationTests` for draft/GPS crash paths.

---

## Time / Runtime / Stopwatch Assessment

**Verdict: Pass — stopwatch integration gap**

| Item | Implementation |
|---|---|
| Dive runtime | `MonotonicElapsedClock` + 1 s `Timer`; max(date, monotonic) with skew guard |
| TTV update | Each runtime tick from avg depth + duration |
| Stopwatch | Independent UserDefaults state; App Intent toggle/reset |
| Reset stopwatch intent | Blocked when `stopwatchTime > 0` |
| Background | Clock uses monotonic uptime on resume |
| Draft restore | Re-anchors runtime to `startDate` |

Tests: `WatchReadinessAlgorithmTests` (clock skew); stopwatch App Intent **not** wired in tests.

---

## Depth Statistics Assessment

**Verdict: Pass**

| Metric | Rule |
|---|---|
| Max depth | Max of valid sample depths |
| Average depth | Time-weighted; on restore uses `Date()` as tail end (may skew if long offline) |
| Temperature | Optional; stale attach window 30 s; non-finite rejected |
| exceeded flag | Set at ≥ 40 m current or max ≥ 40 m on finalize |

Consistency: validator recomputes TTV/avg on session normalize; export/sync use stored session fields.

Tests: `DiveAlgorithmTests`, `DiveDepthTemperatureTests`, integration tests.

---

## Ascent Rate / Gauge Assessment

**Verdict: Pass — document 40 m band split**

**Standard limits (`AscentRateLimits.standard`):**

| Depth band | Max rate (m/min) |
|---|---|
| ≥ 30 m (incl. 40.0) | 10 |
| 20 – < 30 m | 5 |
| 6 – < 20 m | 3 |
| 0 – < 6 m | 1 |
| **> 40 m** (above API support) | **1** (fallback) |

At exactly **40.0 m**: depth safety = **exceeded**, ascent limit still **10 m/min**; at **40.01 m** limit drops to **1** — documented, tested, physically ambiguous at API ceiling (P3 INFO).

Gauge: pointer maps rate vs limit; green/yellow/red from `AscentStatus`. Mission Mode does **not** alter math (`MissionModeAlgorithmInvariantTests`).

**Gap:** `AscentSafetyHapticCoordinator` has **no** dedicated unit tests (P1).

---

## Alarm Logic Assessment

**Verdict: Pass**

| Alarm | Trigger | Default |
|---|---|---|
| Ascent | Red zone + enabled toggle | On |
| Depth | `maxDepth > threshold` | 40 m |
| Runtime | `runtime >= threshold` | From defaults |
| Battery | `level <= threshold` | 20% |

Depth alarm suppressed when `depthSafetyState == .exceeded` or depth stale. Acknowledge clears active alarm state; haptics respect global toggle.

Mission Mode: alarms **unchanged** (only animation gating in UI).

---

## Depth Safety Limit Assessment

**Verdict: Pass — delayed haptic token binding verified**

| Depth | State | Primary haptic | Delayed secondary |
|---|---|---|---|
| ≥ 35 m | caution | notification | — |
| ≥ 38 m | critical | failure | +0.35 s retry |
| ≥ 40 m | exceeded | failure | +0.25 s failure |

Token/generation guards cancel stale delayed pulses on state change, haptics off, or dive end. No positive reinforcement beyond supported range (`suppressesPositiveDepthReinforcement`).

Tests: `WatchMainAlgorithmAuditRemediationTests`, `WatchMainAlgorithmRemediationPhaseTests`.

---

## TTV / Live Metric Assessment

**Formula (canonical):**

```text
ttvIndex = max(0, avgDepthMeters) + max(0, durationSeconds) / 60.0
```

| Check | Result |
|---|---|
| Not NDL/TTS/deco | UI copy informational; no Bühlmann on Watch |
| Dimensional meaning | avg depth (m) + duration (min) — **unit-mixed index by design** |
| Zero time/depth | Returns finite ≥ 0 |
| Persisted | Stored on `DiveSession.ttv`; validator checks recompute |
| Mission Mode | Invariant tests confirm unchanged |
| Sync | Included in HMAC payload |

**P3 INFO:** Name "TTV" can be confused with planning terms — disclaimers present in Info/legal copy.

---

## Water Temperature Assessment

**Verdict: Pass with P3 bound gap**

| Check | Result |
|---|---|
| Acquisition | Optional on depth callback |
| Missing | nil allowed in samples |
| Non-finite | Rejected at sanitization |
| Extreme finite values | **Not bounded** (P3) |
| Unit display | °C internal; °F via `DIRUnitConversions` |
| Log/export/sync | Same stored °C values |

Tests: `DiveDepthTemperatureTests.swift`.

---

## Mission Mode Invariant Analysis

| Question | Answer |
|---|---|
| Affects depth sampling? | **No** |
| Affects depth display values? | **No** (only animation on presentation) |
| Affects GPS? | **No** |
| Affects haptics? | **No** |
| Affects alarms? | **No** |
| Affects logging/export/sync? | **No** |
| Apple Low Power Mode wording truthful? | **Yes** — copy states Mission Mode is **internal DIR profile**, not Apple system LPM (`settings.mission_mode.apple_lpm_disclaimer`) |

Implementation: `MissionModeRuntimeProfile` sets `animationsEnabled` / `decorativeEffectsEnabled` only. Lifecycle: auto on dive start preference, manual pending, restore, deactivate on dive end.

Tests: `MissionModeTests`, `MissionModeAlgorithmInvariantTests`, `WatchMainAlgorithmAuditRemediationTests.testMissionModeDoesNotAlterAlgorithmOutputs`.

---

## Compass / BUSSOLA / Bearing Assessment

**Verdict: Pass**

| Check | Result |
|---|---|
| Heading normalization | `normalizedDegrees` 0–360 |
| Bearing delta | Signed shortest arc ±180° |
| Set/clear bearing | UI + App Intents after legal gate |
| **BUSSOLA** | IT strings use **BUSSOLA**; EN maps key to "COMPASS" display only |
| **COMPASSO** | **Not present** in Watch MAIN compiled strings or Swift |
| Mission Mode | Visual-only (shadows/animations) |

Tests: bearing math in `DiveAlgorithmTests`; legal gate for intents not end-to-end.

---

## GPS Entry/Exit / Finalization Assessment

**Verdict: Pass — physical QA still required**

| Phase | Behavior |
|---|---|
| Dive start | `gpsManager.start()`; immediate snapshot; 6 s best-effort entry |
| Dive end | Exit snapshot; write `.finalizing` draft; clear memory; 6 s exit capture; `finalizeDive` |
| Crash during finalization | Restore `.finalizing` → `completePendingFinalization` (no duplicate) |
| No fix | `GPSFixSource.noFix` / `.fallback`; no false green success banner |
| Timeout | Best-effort window completes at deadline |

Tests: `WatchMainAlgorithmAuditRemediationTests` (strong), `GPSLifecycleTests` (one placeholder — P2).

---

## Unit Conversion / Formatter Assessment

**Verdict: Pass**

| Conversion | Module |
|---|---|
| m ↔ ft | `DIRUnitConversions` |
| °C ↔ °F | Same |
| m/min ↔ ft/min | Ascent display + gauge labels |
| Internal storage | Metric |
| Rounding | Formatters / `WatchDepthFormatting` |

Tests: `WatchReadinessAlgorithmTests` imperial paths; `DiveAlgorithmTests` round trips.

---

## Haptic Timing / Throttle Assessment

**Verdict: Pass — test gaps**

| Path | Interval / behavior |
|---|---|
| `warnIfNeeded` | 2 s throttle |
| Ascent alarm repeat | 1.75 s while red session active |
| Depth limit coordinator | 30/15/10 s + delayed secondary |
| Buddy pulses | 8 s / 12 s |
| Global gate | `dirdiving_watch_haptics_enabled` |

Overlapping events: depth coordinator uses generation tokens; ascent coordinator clears on zone exit.

**Gaps:** `HapticService` intervals untested (P2); ascent coordinator untested (P1).

---

## App Intents / Action Button Safety Assessment

**Verdict: Pass — E2E test gap**

All intents call `LegalAcceptanceGate.requireAccepted()` (timestamp, app version, legal revision, depth limits acknowledged).

| Intent | Safety notes |
|---|---|
| Start/end manual dive | Respects active state |
| Stopwatch toggle/reset | Reset blocked mid-run |
| Set/clear bearing | Requires `CompassManager` |
| Acknowledge alarm | Gated |

**Gap:** No test asserts intent → `legalAcceptanceRequired` error (P2).

---

## User Image Inventory / Delete Sync Assessment

**Verdict: Pass — WC messages unauthenticated (paired trust)**

| Check | Result |
|---|---|
| Watch source of truth | Local `UserImageStore` |
| iOS delete request | Sanitized filename; bundled images rejected |
| ACK | `deleted | notFound | rejected | failed` |
| Path traversal | Prefix confinement + sanitizer |
| Dive math isolation | Image messages do not alter dive metrics |

Tests: `UserImageStorePolicyTests`, `CompanionPhotoManagementTests`, `CompanionPhotoImportSupportTests`.

**P2:** Photo delete/inventory WC not HMAC-signed (unlike dive sessions).

---

## Export / Sync Numerical Consistency Assessment

**Verdict: Pass on dive payloads — P1 pending queue gap**

| Check | Result |
|---|---|
| CSV export | Depth, runtime, GPS, temp, flags from session |
| HMAC dive payload | v2 canonical signing; skew ≤ 3600 s |
| Signed ACK | Required on `sendMessage` reply |
| Peer secret | TOFU pin; mismatch rejects |
| Manual no-depth | Sync allowed; export rules via `DiveSessionPersistenceClass` |
| Validator | Rejects non-finite, inconsistent TTV recompute |

**P1:** `transferUserInfo` path does not verify signed ACK → pending queue may not dequeue → duplicate transfer risk when companion later reachable.

Tests: `WatchSyncCodecAlgorithmTests`, `WatchAckVerifierSecurityTests`, `WatchSyncPeerSecretPinningTests`; full round-trip primarily on **iOS** target.

---

## Persistence / Replay Consistency Assessment

**Verdict: Pass with P2 silent I/O**

| Check | Result |
|---|---|
| Log file | `dirdiving_sessions.json` |
| Cap | 40 sessions after filter (`DiveLogbookPolicy`) |
| Invalid legacy | Quarantined on load |
| Corrupt array elements | Skipped in resilient decode |
| Tombstones | Deleted IDs preserved across reload |
| Active draft | Schema v1; 12 h TTL |

**P2:** `save()` / draft write failures logged only — user not notified.

Tests: policy/quarantine in remediation suites; direct `DiveLogStore.add()` rejection untested.

---

## Mathematical Robustness Sweep

| Category | Finding |
|---|---|
| Magic numbers | Most centralized in `DiveAlgorithmConfiguration`; haptic delays in coordinators |
| Duplicated formulas | TTV in `DiveAlgorithmConfiguration` + validator recompute (intentional check) |
| Divide-by-zero | Guarded in avg depth, ascent rate, TTV |
| NaN / infinity | Rejected at validation and validator |
| Nil vs zero | Depth nil → missing; 0 m valid at surface |
| Stale state | Delayed haptics use generation tokens |
| Race conditions | `@MainActor` on DiveManager; GPS capture replaces in-flight window safely |
| Untested branches | Ascent haptic loop, userInfo sync dequeue, stopwatch persistence |

---

## Test Coverage Assessment

**Executed @ `c314b93`:** 135 tests, 3 skipped, 0 failures.

| Area | Coverage | Primary files |
|---|---|---|
| Depth validation | **Strong** | `DiveAlgorithmTests`, remediation suites |
| Sensor source | **Good** | `DeveloperSensorSourceTests` |
| Lifecycle algorithm | **Good** | `DiveAlgorithmTests` |
| DiveManager integration | **Good** (fixed vs 5415213) | `DiveManagerAlgorithmIntegrationTests` |
| Draft/GPS finalization | **Strong** | `WatchMainAlgorithmAuditRemediationTests` |
| Mission Mode invariants | **Strong** | `MissionModeAlgorithmInvariantTests` |
| Depth limit haptics | **Good** | Remediation tests |
| Ascent haptics | **Missing** | — |
| WatchSyncService E2E | **Missing on Watch** | iOS mirror partial |
| App Intents | **Missing** | Gate tested in isolation |
| HapticService throttles | **Missing** | — |
| Legal gate | **Good** | `LegalAcceptanceGateTests` |
| Image policy | **Good** | `UserImageStorePolicyTests` |
| Sync crypto | **Partial** | Negative ack tests only on Watch |

### Recommended tests still missing (priority)

1. Watch `WatchSyncService` queue + userInfo + ack dequeue (P1)
2. `AscentSafetyHapticCoordinator` repeat/cancel (P1)
3. `DiveManager` automatic surface end E2E (P2)
4. `ActionButtonIntents` + legal gate wiring (P2)
5. `HapticService` interval matrix (P2)
6. `DiveLogStore.add` invalid rejection (P2)
7. `GPSLifecycleTests` one-shot assertion (replace placeholder) (P2)

---

## Edge Case Matrix

| Edge case | Expected behavior | Test status |
|---|---|---|
| depth nil | No auto-start; validation fail | Partial |
| depth NaN | Rejected | Tested |
| depth < 0 | Rejected/clamped | Tested |
| depth 0 repeated | No auto-start | Tested (mock) |
| depth 1.0 m | No start | Tested |
| depth 1.1 m × 2 | Auto-start | Tested |
| Sudden depth jump | Spike reject | Tested |
| Frozen depth 30 s | Reject active | Tested |
| Sensor silent 8 s | Stale flag | Integration |
| Manual no-depth session | Sync yes; export rules | Tested |
| depth > 40 m | exceeded state + flag | Tested |
| Mission Mode ON/OFF same samples | Identical metrics | Tested |
| Legal gate false + intent | Error | **Untested E2E** |
| GPS crash mid-finalize | Restore finalize | Tested |
| Invalid HMAC payload | Reject | Tested (partial) |
| Stale delayed haptic | Cancelled | Tested |
| Changed peer secret | Mismatch detect | Tested |
| Compass 359° → 1° wrap | Correct delta | Tested (math) |
| Metric/imperial toggle | Display only | Tested |

---

## Physical Watch Ultra Test Plan

1. Depth entitlement: real submersion auto-start > 1 m, auto-stop dwell at surface.
2. Depth safety haptics at 35/38/40 m (controlled pool — **not** encouragement to exceed limits).
3. Ascent rate gauge vs known controlled ascent rates per band.
4. Delayed critical/exceeded haptic cancellation on rapid ascent to shallow.
5. GPS entry/exit on surface with/without fix; crash app during `.finalizing` restore.
6. Mission Mode ON/OFF — verify identical logged max/avg/TTV/samples.
7. Action Button intents before/after legal acceptance.
8. Mock fallback badge on non-submersion hardware (if applicable).
9. Battery/runtime alarms on long surface session.
10. BUSSOLA heading/bearing on deck (magnetic interference documented).

Reference: [`WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`](WATCH_ULTRA_PHYSICAL_QA_MATRIX.md).

---

## Underwater Validation Plan

1. Shallow oscillation around 1 m — no duplicate auto-starts.
2. Slow ascent within green bands — no false red haptics.
3. Fast ascent red zone — repeating haptic at ~1.75 s until slow or surfaced.
4. Depth limit policy — caution/critical/exceeded sequencing; no reward copy beyond 40 m.
5. Manual dive without depth — session classified manual-no-depth; sync/export policy.
6. Submersion sensor vs depth-only paths on Ultra.
7. Temperature display when sensor provides water temp.

---

## Sync / Security / Payload Validation Plan

1. Pair Watch + iPhone; verify TOFU secret pin + mismatch recovery UI.
2. Complete dive; verify HMAC payload + signed ACK on reachable `sendMessage`.
3. Complete dive while iPhone unreachable; verify pending queue behavior and **document userInfo dequeue gap (P1)**.
4. Tombstone delete propagates both directions.
5. Manual no-depth session sync round-trip.
6. Changed peer secret rejects old signatures.
7. Companion photo delete ACK + inventory update (no dive metric side effects).
8. Invalid depth session rejected at validator before sync enqueue.

Reference: [`WATCH_IOS_SYNC_QA_MATRIX.md`](WATCH_IOS_SYNC_QA_MATRIX.md).

---

## Risk Matrix

### P0 — Safety-critical

*None identified.*

### P1 — Major

| ID | Title | Family | Impact |
|---|---|---|---|
| WATCH-P1-001 | Pending sync sessions may not dequeue after `transferUserInfo` | Sync | Duplicate iPhone imports / stale queue |
| WATCH-P1-002 | Mock depth fallback on hardware without submersion API | Depth sensor | User may think auto depth works; 0 m forever |
| WATCH-P1-003 | TestFlight allows simulation sensor selection | Simulation policy | Misconfigured QA build behaves unlike production |
| WATCH-P1-004 | No tests for `AscentSafetyHapticCoordinator` | Haptics | Regression on over-limit ascent warnings |

### P2 — Medium

| ID | Title | Family |
|---|---|---|
| WATCH-P2-001 | Silent draft/log persistence failures | Persistence |
| WATCH-P2-002 | Draft restore avg-depth tail uses wall `Date()` | Depth stats |
| WATCH-P2-003 | Automatic dive end not integration-tested in `DiveManager` | Lifecycle |
| WATCH-P2-004 | No Watch-target `WatchSyncService` integration tests | Sync |
| WATCH-P2-005 | App Intent legal gates not tested end-to-end | App Intents |
| WATCH-P2-006 | `HapticService` throttle intervals untested | Haptics |
| WATCH-P2-007 | Companion photo WC messages unauthenticated | Image sync |
| WATCH-P2-008 | `importedFromCompanionIDs` retention order non-deterministic | Sync codec |
| WATCH-P2-009 | `GPSLifecycleTests` placeholder assertion | GPS tests |

### P3 — Low / polish

| ID | Title |
|---|---|
| WATCH-P3-001 | 40.0 m exceeded state vs 10 m/min ascent limit split |
| WATCH-P3-002 | Double `classify()` in `DiveLogStore.add` |
| WATCH-P3-003 | Expired active draft discarded without quarantine |
| WATCH-P3-004 | Finite temperature not bounded |
| WATCH-P3-005 | `DeveloperVersionUnlock` untested (DEBUG-only) |
| WATCH-P3-006 | TTV naming vs planning terminology — disclaimer reliance |
| WATCH-P3-007 | `DepthSafetySelfCheck` not in CI |
| WATCH-P3-008 | CSV `makeCSV()` header-only if called directly |

### P4 — Informational / process

| ID | Title |
|---|---|
| WATCH-P4-001 | External paired-device QA matrices not executed |
| WATCH-P4-002 | Underwater haptic/gauge validation pending |
| WATCH-P4-003 | Bühlmann/planner N/A on Watch by design |
| WATCH-P4-004 | Post-dive CNS/OTU N/A on Watch by design |
| WATCH-P4-005 | Apple Watch Ultra 2 simulator unavailable — used Ultra 3 |

---

## Prioritized Roadmap

1. **Must fix before compile/use** — None.
2. **Must fix before internal TestFlight** — Document or fix WATCH-P1-001 pending queue; physical Ultra smoke (depth + one sync path).
3. **Must fix before external TestFlight** — P1 items + full sync matrix + underwater ascent/depth-limit QA.
4. **Must fix before App Store** — External TestFlight evidence + legal review + resolve/document all P1/P2 sync and haptic test gaps.
5. **Post-release** — P3 polish, expanded Watch sync integration tests, temperature bounds.

---

## Final Verdict

| Question | Answer |
|---|---|
| **Mathematically ready?** | **Yes** for Watch companion scope — finite-safe, validated ingest, conservative missing-data behavior. |
| **Runtime-lifecycle ready?** | **Yes** on macOS evidence; auto-end E2E test gap remains (P2). |
| **Safe enough for internal test?** | **Yes** — 135/135 pass; prior integration failures remediated. |
| **Mission Mode safe?** | **Yes** — UI-only; invariant tests pass; LPM wording truthful. |
| **Manual start safe?** | **Yes** — no fake depth; manual-no-depth policy tested. |
| **Automatic start safe?** | **Yes** — debounced > 1 m; mock fallback visibility required (P1 on non-Ultra). |
| **Sensor source policy safe?** | **Yes** in release; TestFlight simulation exposure noted (P1). |
| **App Intents safe?** | **Yes** in code — legal fail-closed; add E2E tests (P2). |
| **GPS finalization robust?** | **Yes** — two-phase draft tested; physical QA still required. |
| **Active draft / pending finalization robust?** | **Yes** — crash recovery + idempotent finalize tested @ `c314b93`. |
| **Image inventory sync isolated?** | **Yes** — does not affect dive math; WC trust model documented (P2). |
| **Authenticated sync/data ready?** | **Mostly** — dive payloads strong; userInfo dequeue gap (P1). |
| **Ready for TestFlight?** | **Internal almost**; **external not yet** without device QA + P1 sync policy. |
| **Ready for App Store?** | **No** — external validation + physical QA + P1/P2 closure. |
| **What blocks 100% readiness?** | Physical Ultra QA; Watch sync E2E on device; P1 pending-queue behavior; ascent haptic test coverage; external paired sync matrix execution. |

### Overall readiness verdict

**READY FOR INTERNAL WATCH MAIN ALGORITHM VALIDATION (macOS)**  
**NOT READY for external TestFlight / App Store without physical QA and sync hardening evidence**

---

## Appendix — Finding detail samples

### WATCH-P1-001 — Pending sync dequeue on userInfo

| Field | Value |
|---|---|
| Severity | HIGH |
| Priority | P1 |
| File | `Services/WatchSyncService.swift` |
| Impact | Watch may retain pending sessions after iPhone processed userInfo transfer |
| Safety | Data duplication risk, not live-dive math |
| Proposed solution | Dequeue on verified delivery or idempotent iPhone ingest + document behavior |
| Code impact | Small functional |
| Acceptance | Paired test: unreachable → userInfo → single iPhone row |

### WATCH-P1-004 — Ascent haptic coordinator untested

| Field | Value |
|---|---|
| Severity | HIGH |
| Priority | P1 |
| File | `Services/AscentSafetyHapticCoordinator.swift` |
| Impact | Regression could miss over-limit ascent warnings |
| Safety | Safety-warning UX |
| Proposed solution | Unit tests for enter/exit red zone + 1.75 s repeat + dive end cancel |
| Code impact | Test-only |
| Acceptance | XCTest passes; no haptic fire after zone clears |

---

*End of audit report. No application code was modified.*
