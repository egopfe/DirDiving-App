# Depth Sensor & Entitlement Audit (Current)

**Project:** DIR DIVING — Apple Watch App + iOS Companion  
**Audit type:** Read-only (no code changes)  
**Baseline commit:** `06955d7` (`feat(watch,ios): add hidden Developer sensor source settings.`)  
**Audit date:** 2026-06-02  

---

## 1. Executive summary

The codebase **already implements** a depth-sensor abstraction (`DepthSensorProvider`), Apple and mock providers, a **Developer → Sensor Source** setting (Automatic / Apple Sensor / Simulation), and a **default of Simulation** (`developer.sensorSource` → `simulation`).

For **runtime** on a real Apple Watch **without** Apple granting the water-submersion capability:

| Question | Verdict |
|----------|---------|
| Compile (simulator / typical dev) | **YES** — CoreMotion links; simulator builds have been validated on this branch. |
| Install on device | **CONDITIONAL** — Watch `Config/DIRDiving.entitlements` **declares** `com.apple.developer.coremotion.water-submersion`. If the active provisioning profile does **not** include that capability, **signed device/archive builds can fail at signing time** (documented in repo QA docs). A build signed **without** that entitlement key in the profile/plist can install. |
| Launch | **YES** (expected) — `DiveManager` init does not instantiate `CMWaterSubmersionManager` when default Simulation is active. |
| Dive mode with simulated depth | **YES** — `MockDepthSensorProvider` feeds surface-level samples; **manual dive** works; **auto-start from mock alone is unlikely** (mock emits `0 m`; auto-start needs `> 1.0 m` for 2 samples). |
| Real Apple depth without entitlement | **NO** — `AppleDepthSensorProvider` requires hardware + entitlement; `waterSubmersionAvailable` is typically false and manager `start()` is a no-op. |

**CMDepthData:** not used anywhere in Swift sources (grep: zero matches).

**iOS companion:** no live underwater dive path; planner/logbook use **planned or stored** depths. CoreMotion is used only for **availability probing** when the user selects Apple Sensor in Developer settings (`AppleDepthSensorAvailability.swift`). iOS entitlements **do not** declare water-submersion.

**Sensor Source Developer setting:** **YES — already present** on Watch and iOS (hidden behind DEBUG / TestFlight / 7-tap version unlock).

**Further implementation of the Developer menu spec:** **NOT required** for the described feature set; optional hardening is listed as P2/P3 below.

---

## 2. Current implementation overview

```
┌─────────────────────────────────────────────────────────────────┐
│  DeveloperSettings / SensorSourceMode (UserDefaults)            │
│  Key: developer.sensorSource  Default: simulation               │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  DiveManager.configureDepthSensorProvider()  (Watch, @ init)    │
│  SensorProviderFactory.makeProvider(mode:)                      │
└────────────┬───────────────────────────────┬────────────────────┘
             │                               │
    ┌────────▼────────┐              ┌───────▼────────┐
    │ MockDepthSensor │              │ AppleDepthSensor│
    │ Provider        │              │ Provider        │
    │ (Simulation)    │              │ (lazy CMWater   │
    │ Timer → 0 m     │              │ SubmersionMgr)  │
    └────────┬────────┘              └───────┬────────┘
             │ callbacks                      │
             └──────────────┬─────────────────┘
                            ▼
              DiveManager.processDepthMeasurement()
              DiveManager.handleSubmersionState()
                            │
                            ▼
              DiveAlgorithm / lifecycle / logbook / UI (@Published)
```

**iOS:** same `SensorSourceMode` / `DeveloperSettings` persistence and `DeveloperSettingsView` UI; **no** `DiveManager` or `SensorProviderFactory` on iOS. Planner uses `PlannerStore` / `BuhlmannEngine` with user-entered depths.

---

## 3. Files inspected (primary)

### Watch — depth / sensor / dive runtime

| File | Role |
|------|------|
| `Services/DiveManager.swift` | Central dive runtime; wires provider → `processDepthMeasurement` |
| `Services/DepthSensorProvider.swift` | Provider protocol |
| `Services/AppleDepthSensorProvider.swift` | `CMWaterSubmersionManager` wrapper |
| `Services/MockDepthSensorProvider.swift` | Simulation provider |
| `Services/SensorProviderFactory.swift` | Mode → provider selection |
| `Utils/SensorSourceMode.swift` | Enum + `developer.sensorSource` persistence |
| `Utils/DeveloperSettings.swift` | Visibility + unlock |
| `Utils/DeveloperVersionUnlock.swift` | 7-tap version gesture |
| `Utils/DiveAlgorithmConfiguration.swift` | Auto start/stop depth thresholds |
| `Utils/DiveLifecycleAlgorithm.swift` | Depth-based start/stop debounce |
| `Utils/DepthSampleValidation.swift` | Sample validation |
| `Views/DeveloperSettingsView.swift` | Sensor Source UI (Watch) |
| `Views/SettingsView.swift` | Developer navigation link |
| `Views/InfoView.swift` | Version 7-tap unlock; diagnostics |
| `Views/DiveLiveView.swift` | UI subscribes to `DiveManager` |
| `App/DIRDivingApp.swift` | Creates `DiveManager` at launch |
| `App/Info.plist` | `WKSupportsAutomaticDepthLaunch`, `underwater-depth` BG mode |
| `Config/DIRDiving.entitlements` | `com.apple.developer.coremotion.water-submersion` |

### iOS — companion

| File | Role |
|------|------|
| `iOSApp/Utils/SensorSourceMode.swift` | Same persistence key (local to iPhone) |
| `iOSApp/Utils/DeveloperSettings.swift` | Same visibility rules |
| `iOSApp/Utils/AppleDepthSensorAvailability.swift` | `waterSubmersionAvailable` probe only |
| `iOSApp/Views/DeveloperSettingsView.swift` | Sensor Source UI (iOS) |
| `iOSApp/Views/MoreView.swift` | Developer link + version unlock |
| `iOSApp/Views/PlannerView.swift` | Planner UI (depth inputs, not live sensor) |
| `iOSApp/Algorithms/Buhlmann/*` | Bühlmann math (planned depth) |
| `iOSApp/Config/DIRDivingiOS.entitlements` | iCloud only — **no** water-submersion |

### Tests

| File | Role |
|------|------|
| `Tests/WatchAlgorithmTests/DeveloperSensorSourceTests.swift` | Factory + persistence |
| `Tests/WatchAlgorithmTests/DiveManagerAlgorithmIntegrationTests.swift` | `testHook_processDepthMeasurement` |
| `Tests/iOSAlgorithmTests/DeveloperSensorSourceTests.swift` | iOS persistence defaults |

### Build / project

| File | Role |
|------|------|
| `project.yml` | Watch: CoreMotion + sensor sources; iOS: CoreMotion (availability only) |
| `Documentation/DeveloperSensorSource.md` | Feature documentation |

---

## 4. Key questions (answers 1–20)

| # | Question | Answer |
|---|----------|--------|
| 1 | Is `CMWaterSubmersionManager` used? | **YES** — `Services/AppleDepthSensorProvider.swift`, `iOSApp/Utils/AppleDepthSensorAvailability.swift` (static availability only). |
| 2 | Instantiated during app launch? | **NO** for `CMWaterSubmersionManager()` — default Simulation uses `MockDepthSensorProvider` only. **`configureDepthSensorProvider()` runs in `DiveManager.init`** (line 150). |
| 3 | Lazy or immediate? | **Lazy** for manager instance (`AppleDepthSensorProvider.start()` lines 19–24). **`waterSubmersionAvailable` may run at init** if persisted mode is `automatic` or `appleSensor` (factory / fallback checks). |
| 4 | `DepthSensorProvider` abstraction? | **YES** — `Services/DepthSensorProvider.swift`. |
| 5 | `AppleDepthSensorProvider`? | **YES** — `Services/AppleDepthSensorProvider.swift`. |
| 6 | `MockDepthSensorProvider`? | **YES** — `Services/MockDepthSensorProvider.swift`. |
| 7 | Simulation / demo mode? | **YES** — Simulation = `MockDepthSensorProvider`; default mode. iOS **demo logbook** (`DemoDiveCatalog`, `includeDemoLogbook`) is separate from live depth. |
| 8 | Depth source hardcoded? | **NO** — `DeveloperSettings.sensorSourceMode` → `UserDefaults` key `developer.sensorSource`, default `simulation`. |
| 9 | Run without entitlement (runtime)? | **YES** with Simulation default; real depth **NO**. |
| 10 | Compile without entitlement? | **YES** for simulator/dev compile; **signed device build may fail** if entitlements plist requires capability not in profile (see §8). |
| 11 | Install on real Watch without entitlement? | **CONDITIONAL** — depends on signing profile vs `Config/DIRDiving.entitlements` (see §8). |
| 12 | Launch without entitlement? | **YES** (expected) with Simulation; no manager alloc on that path. |
| 13 | Fallback if Apple sensor unavailable? | **YES** — Automatic → mock in factory; Apple Sensor → persist Simulation + warning (`DiveManager` 164–167, `DeveloperSettingsView`). |
| 14 | Crash if entitlement missing? | **Low** — delegate `errorOccurred` sets `lastErrorMessage`; no force-unwrap on manager. Risk higher if user forces Apple mode and APIs throw (not observed in static review). |
| 15 | Protected API at startup? | **Only if** non-simulation mode persisted: `CMWaterSubmersionManager.waterSubmersionAvailable` (static). **Not** with factory-default Simulation. |
| 16 | Depth samples separated from business logic? | **Partial** — ingestion isolated in provider → `processDepthMeasurement`; dive math remains in `DiveManager` + `DiveAlgorithm` (by design). |
| 17 | Planner/Bühlmann independent of live sensor? | **YES** on iOS — no `DiveManager`. Watch planner N/A; Watch runtime uses live/mock samples only in dive mode. |
| 18 | watchOS vs iOS consistent? | **Settings UI/persistence yes**; **runtime no** — only Watch runs `SensorProviderFactory` / dive depth loop. |
| 19 | Simulator data? | **Mock** by default (`MockDepthSensorProvider`); Apple path inactive when `waterSubmersionAvailable == false`. |
| 20 | Tests / previews use fake depth? | **YES** — `testHook_processDepthMeasurement`; no SwiftUI `#Preview` using CoreMotion for dive depth. |

---

## 5. Code references (CMWaterSubmersion & CoreMotion)

### `CMWaterSubmersionManager` — availability (no instantiation)

```7:9:Services/AppleDepthSensorProvider.swift
    static var isAvailable: Bool {
        CMWaterSubmersionManager.waterSubmersionAvailable
    }
```

```4:7:iOSApp/Utils/AppleDepthSensorAvailability.swift
enum AppleDepthSensorAvailability {
    static var isAvailable: Bool {
        CMWaterSubmersionManager.waterSubmersionAvailable
    }
}
```

### `CMWaterSubmersionManager` — lazy instantiation

```19:24:Services/AppleDepthSensorProvider.swift
    func start() {
        guard Self.isAvailable else { return }
        let manager = CMWaterSubmersionManager()
        manager.delegate = self
        self.manager = manager
    }
```

### Delegate → depth / temperature / errors

```47:70:Services/AppleDepthSensorProvider.swift
    nonisolated func manager(_ manager: CMWaterSubmersionManager, didUpdate measurement: CMWaterSubmersionMeasurement) {
        Task { @MainActor in
            onDepthMeasurement?(
                measurement.depth?.converted(to: .meters).value,
                Date(),
                lastTemperatureCelsius
            )
        }
    }
    // ... CMWaterTemperature, errorOccurred ...
```

### `DiveManager` — provider wiring at init (not direct CoreMotion)

```149:197:Services/DiveManager.swift
        loadStopwatchState()
        configureDepthSensorProvider()
        restoreActiveDiveDraftIfAvailable()
    }
    // ...
    private func configureDepthSensorProvider() {
        depthSensorProvider?.stop()
        // ...
        var mode = DeveloperSettings.sensorSourceMode
        if mode == .appleSensor, !AppleDepthSensorProvider.isAvailable {
            DeveloperSettings.persistSensorSource(.simulation)
            mode = .simulation
            developerSensorSourceWarning = String(localized: "developer.sensor_source.apple_fallback")
        }
        let provider = SensorProviderFactory.makeProvider(mode: mode)
        // callbacks → processDepthMeasurement / handleSubmersionState
        provider.start()
        // isDepthAutomationAvailable: true for simulation & automatic; appleSensor uses isAvailable
    }
```

### Simulation provider

```13:19:Services/MockDepthSensorProvider.swift
    func start() {
        stop()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.onDepthMeasurement?(0, Date(), 20.0)
            }
        }
    }
```

### Default persistence

```10:14:Utils/SensorSourceMode.swift
    static let storageKey = "developer.sensorSource"

    static var persisted: SensorSourceMode {
        let raw = UserDefaults.standard.string(forKey: storageKey) ?? SensorSourceMode.simulation.rawValue
        return SensorSourceMode(rawValue: raw) ?? .simulation
```

### App launch creates `DiveManager` (triggers provider config)

```16:24:App/DIRDivingApp.swift
    init() {
        let logStore = DiveLogStore()
        let gpsManager = GPSManager()
        let ascentSettings = AscentRateSettingsStore()
        // ...
        _diveManager = StateObject(wrappedValue: DiveManager(logStore: logStore, gpsManager: gpsManager, ascentSettings: ascentSettings))
```

---

## 6. Entitlement & provisioning dependency

### Watch entitlements (`Config/DIRDiving.entitlements`)

```15:16:Config/DIRDiving.entitlements
    <key>com.apple.developer.coremotion.water-submersion</key>
    <true/>
```

This is Apple’s **water submersion / submerged depth** capability (repo and Apple docs refer to it as required for production depth). It is **not** present on iOS entitlements.

### Watch Info.plist (system dive integration)

```13:18:App/Info.plist
    <key>WKSupportsAutomaticDepthLaunch</key>
    <true/>
    <key>WKBackgroundModes</key>
    <array>
        <string>underwater-depth</string>
    </array>
```

These affect **watchOS system** automatic dive launch and background mode; they are independent of the in-app Developer Sensor Source toggle but may matter for **system-level** auto-launch without a full entitlement stack.

### iOS entitlements

`iOSApp/Config/DIRDivingiOS.entitlements` — iCloud/KVS only; **no** `coremotion.water-submersion`.

### Signing risk (documented in repo)

`Docs/BUILD_VALIDATION.md` and readiness audits note failures such as:

> `Entitlement com.apple.developer.coremotion.water-submersion not found and could not be included in profile.`

**Implication:** “Compile/install without entitlement” must distinguish:

1. **Code path / runtime** without Apple granting capability → supported via Simulation.  
2. **Signing** with entitlements plist requiring capability not in profile → **can block device install/archive** until profile is updated or entitlement is removed from plist for dev builds.

---

## 7. Startup behavior analysis

| Step | On cold launch (default Simulation) | On launch with persisted `automatic` / `appleSensor` |
|------|--------------------------------------|------------------------------------------------------|
| `DIRDivingApp.init` | Creates `DiveManager` | Same |
| `DiveManager.init` | `configureDepthSensorProvider()` | Same |
| `CMWaterSubmersionManager()` alloc | **No** | **Only if** `isAvailable` and factory selects Apple |
| `waterSubmersionAvailable` | **Skipped** (Simulation factory path) | **Yes** — static query in factory and/or apple fallback |
| `MockDepthSensorProvider.start` | **Yes** — 1 Hz timer, 0 m | Only if factory returns mock |
| UI / legal / onboarding | Unaffected | Unaffected |

**Residual launch-time API touch:** If a tester previously set **Automatic** or **Apple Sensor**, the next launch may call `waterSubmersionAvailable` before mock is selected. This is a **static property** query, not manager instantiation. Requirement interpretation: “no protected API at startup” is **mostly satisfied** for default/fresh install; **not strictly** for all persisted modes.

---

## 8. Compile / install / run risk matrix (without Apple entitlement)

| Risk class | Severity | Notes |
|------------|----------|-------|
| Compile-time (link CoreMotion) | Low | Framework linked in `project.yml` for Watch and iOS; no compile-time entitlement check. |
| Signing / provisioning mismatch | **P0** (for device release) | Plist declares water-submersion; profile without it → build/sign failure. |
| Launch crash (missing entitlement) | Low | Simulation path avoids manager creation. |
| Runtime error callback | P2 | Apple mode may populate `lastErrorMessage` via `errorOccurred`. |
| Auto dive never starts (mock) | P2 | Mock holds 0 m; threshold 1.0 m + 2 samples (`DiveLifecycleAlgorithm` 47–62). |
| System auto-launch (`WKSupportsAutomaticDepthLaunch`) | P2 | May not engage without full stack; in-app manual dive still available. |
| Stale depth UI in manual dive | P3 | With Simulation, `isDepthAutomationAvailable == true`; not `isManualNoDepthSession`. |

---

## 9. Watch App findings

- **Manual dive:** `startManualDive()` → `beginDiveIfNeeded(isManual: true)` (lines 496–497, 519–561) — **does not require** real sensor.  
- **Automatic dive start:** `processDepthMeasurement` → `evaluateLifecycle` → depth **> 1.0 m** for 2 samples (`Utils/DiveLifecycleAlgorithm.swift` 46–62). Mock at 0 m → **will not auto-start**.  
- **Automatic dive end:** depth ≤ 0.3 m + dwell 8 s, or submersion `.notSubmerged` via `handleSubmersionState` (mock does not emit submersion events).  
- **Submersion events:** Only from `AppleDepthSensorProvider` delegate.  
- **UI:** `DiveLiveView`, `SettingsView`, `InfoView` observe `DiveManager` (`isDepthAutomationAvailable`, `currentDepthMeters`, etc.).  
- **Developer menu:** `SettingsView` 238–251 → `DeveloperSettingsView` when `DeveloperSettings.isDeveloperSectionVisible`.  
- **7-tap unlock:** `InfoView` `versionRow` + `DeveloperVersionUnlockGesture` (`tapCount >= 7`).

---

## 10. iOS Companion findings

- **No `DiveManager`**, no `SensorProviderFactory`, no live depth loop on iPhone.  
- **Planner / Bühlmann:** `iOSApp/Services/BuhlmannPlanner.swift`, `BuhlmannEngine`, `PlannerView` — depths from `PlannerStore` / user input.  
- **Logbook:** Sessions from local store + Watch sync (`WatchDiveSyncCodec`); depths in `DiveSession` / `DiveSample` models, not from `CMWaterSubmersionManager`.  
- **Developer Sensor Source:** Preference only on iOS (`iOSApp/Views/DeveloperSettingsView.swift`); Apple Sensor checks `AppleDepthSensorAvailability.isAvailable` then falls back to Simulation.  
- **Demo data:** `DemoDiveCatalog`, `includeDemoLogbook` — reviewer toggle, not underwater API.

---

## 11. Existing mock / simulation capability

| Mechanism | Location | Behavior |
|-----------|----------|----------|
| **Simulation mode (default)** | `MockDepthSensorProvider` | 1 Hz, 0 m, 20 °C |
| **Factory fallback** | `SensorProviderFactory` | Automatic / Apple → mock if `!isAvailable` |
| **Unit tests** | `testHook_processDepthMeasurement` | Injects arbitrary depths |
| **iOS demo logbook** | `DemoDiveCatalog` | Static demo sessions |

**Gap:** Mock does not simulate a depth profile (ramp/submerge) for auto-start QA without manual start or test hooks.

---

## 12. Missing / weak abstractions (post-implementation)

| Item | Status |
|------|--------|
| Provider protocol + factory | **Present** |
| Developer Sensor Source UI | **Present** (both platforms) |
| Inject provider in tests without timer | Partial — hooks exist; mock timer still runs in integration tests |
| Strip water-submersion from dev signing flavor | **Not present** — single Watch entitlements file always declares capability |
| Deferred `waterSubmersionAvailable` until user selects Apple/Automatic | **Not present** — query can run at init for non-simulation persisted mode |
| Rich mock profile (auto-start/end testing) | **Not present** |

---

## 13. Crash-risk analysis

| Scenario | Risk |
|----------|------|
| Simulation default, fresh install | **Low** |
| Apple Sensor selected, unavailable | **Low** — fallback to Simulation + alert |
| Apple Sensor selected, available, no entitlement at runtime | **Low–Medium** — errors via delegate, not fatal in code review |
| Force unwrap / implicit manager use | **None found** in `AppleDepthSensorProvider` |
| Timer on deinit / leak | Standard `weak self` in mock timer |

---

## 14. Fallback-risk analysis

| Mode | Fallback |
|------|----------|
| Simulation | N/A (by design) |
| Automatic | Mock when `!AppleDepthSensorProvider.isAvailable` (no UserDefaults persist) |
| Apple Sensor | Persist Simulation + `developer.sensor_source.apple_fallback` string |

**Risk:** User on Automatic without hardware gets mock **silently** (no persist). Acceptable per spec.

---

## 15. Manual dive start compatibility

**YES.** `startManualDive()` does not check entitlement. With Simulation, `isDepthAutomationAvailable = true`, so UI shows live-depth path, not `isManualNoDepthSession` (which requires `!isDepthAutomationAvailable` — line 424–425).

---

## 16. Automatic dive start compatibility

| Source | Auto-start |
|--------|------------|
| Real Apple sensor + entitlement | **YES** (depth + submersion events) |
| Mock (0 m) | **NO** (below 1.0 m threshold) |
| Tests (`testHook_processDepthMeasurement`) | **YES** (injected depths) |
| watchOS system (`WKSupportsAutomaticDepthLaunch`) | **Separate** from in-app mock; needs entitlement/hardware |

---

## 17. Planner / Bühlmann independence

| Component | Live Watch sensor? |
|-----------|-------------------|
| `BuhlmannEngine` / `BuhlmannPlanner` (iOS) | **No** |
| `GasPlanningService` / `GasPlan` | **No** |
| `RepetitiveDivePlannerService` | **No** (tissue state from planning, not CM) |
| Watch `DiveManager` runtime TTV/ascent | **Yes** (from samples, mock or Apple) |
| Watch logbook export | Uses completed `DiveSession` samples |

---

## 18. Architecture map (samples → consumers)

| Stage | Location |
|-------|----------|
| **1. Depth samples created** | `AppleDepthSensorProvider` / `MockDepthSensorProvider` → callbacks |
| **2. Consumed** | `DiveManager.processDepthMeasurement` (640+) |
| **3. Dive start** | `evaluateLifecycle` / `beginDiveIfNeeded` / `startManualDive` |
| **4. Dive end** | `evaluateLifecycle` / `endDiveIfNeeded` / submersion handler |
| **5. Average depth** | `DiveAlgorithm.timeWeightedAverageDepth` in `addSample` (727) |
| **6. Ascent rate** | `DiveAlgorithm.ascentRateMetersPerMinute` in `updateAscentRate` (766+) |
| **7. Runtime** | `MonotonicElapsedClock` / `updateRuntimeFromClock` (374+) |
| **8. TTV** | `DiveAlgorithm.ttvIndex` in `updateRuntimeFromClock` (379) |
| **9. Logbook** | `finalizeDive` → `logStore.add(session)` (636) |
| **10. UI** | `@Published` on `DiveManager`; SwiftUI views via `@EnvironmentObject` |

---

## 19. Recommended remediation plan (hardening only)

The **Developer → Sensor Source** feature is **already implemented** (`06955d7`). Remaining items are optional hardening:

### P0 — blocks compile/install/launch without entitlement (signing)

| ID | Action |
|----|--------|
| P0-1 | Provide a **dev signing flavor** or documented workflow that builds Watch **without** `com.apple.developer.coremotion.water-submersion` in the active profile when Apple has not granted the capability (alternate entitlements plist or build configuration). |
| P0-2 | Document in release checklist: TestFlight build with entitlement vs internal dev build without. |

### P1 — high risk of unusable dive mode

| ID | Action |
|----|--------|
| P1-1 | Optional mock depth profile (ramp > 1 m) for entitlement-free auto-start QA. |
| P1-2 | On Apple delegate errors without entitlement, avoid alarming `lastErrorMessage` when mode is Automatic and mock is active. |

### P2 — architectural / fallback

| ID | Action |
|----|--------|
| P2-1 | Defer `waterSubmersionAvailable` until user selects Automatic/Apple (not at init for persisted modes). |
| P2-2 | Emit mock submersion state if auto-stop testing without Apple hardware is required. |

### P3 — docs / tests

| ID | Action |
|----|--------|
| P3-1 | Update stale docs that still describe `DiveManager` owning `CMWaterSubmersionManager` directly (e.g. older audit markdown). |
| P3-2 | Add launch test: fresh install + Simulation → assert no `CMWaterSubmersionManager` alloc (instrumentation or spy). |

---

## 20. Implementation plan — Developer → Sensor Source (reference)

**Status: IMPLEMENTED** on `main` @ `06955d7`.

| Requirement | Implementation |
|-------------|----------------|
| Settings → Developer → Sensor Source | `Views/DeveloperSettingsView.swift`, `iOSApp/Views/DeveloperSettingsView.swift` |
| Automatic / Apple Sensor / Simulation | `SensorSourceMode` enum |
| Persistence `developer.sensorSource` | `SensorSourceMode.storageKey`, default `simulation` |
| Hidden unless DEBUG / TestFlight / 7 taps | `DeveloperSettings.isDeveloperSectionVisible`, `DeveloperVersionUnlockGesture` |
| Lazy Apple API | `AppleDepthSensorProvider` |
| Entitlement-free default | `MockDepthSensorProvider` + factory |

No duplicate implementation required unless product scope changes.

---

## 21. Acceptance criteria (verification)

- [ ] Fresh Watch install: `developer.sensorSource` unset → Simulation; app launches.  
- [ ] No `CMWaterSubmersionManager()` alloc on Simulation (Instruments / log).  
- [ ] Manual dive starts and logs session on Watch without entitlement.  
- [ ] Apple Sensor on device without capability → fallback to Simulation + warning.  
- [ ] Signed build with/without water-submersion profile documented and reproducible.  
- [ ] iOS Developer settings persist independently; planner runs offline.  
- [ ] Watch + iOS algorithm tests pass.

---

## 22. Tests to run after changes

```bash
xcodegen generate
xcodebuild -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build
xcodebuild -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild test -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)'
xcodebuild test -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17'
```

**Manual (real Watch, no entitlement):** Simulation default → launch → manual dive → logbook entry → sync to iOS.  
**Manual (with entitlement):** Apple Sensor / Automatic → shallow water depth updates.

---

## 23. Final concise status

| Question | Answer |
|----------|--------|
| Can the app currently compile without entitlement? | **YES** (simulator/dev); **CONDITIONAL** for signed device if plist/profile mismatch |
| Can it install on Apple Watch without entitlement? | **CONDITIONAL** — signing/profile dependent |
| Can it launch without entitlement? | **YES** (with Simulation default) |
| Can dive mode run using simulated depth? | **YES** (manual dive; auto-start from mock alone: **NO** at 0 m) |
| Is a Sensor Source Developer Setting already present? | **YES** |
| Is implementation required? | **NO** (for spec as written); **optional P0–P3 hardening** |
| Recommended next Cursor command | `Run validate_main_release_readiness.sh, then install on a real Apple Watch with Simulation default and execute manual dive + logbook sync QA.` |

---

*End of audit — read-only; no source files were modified.*
