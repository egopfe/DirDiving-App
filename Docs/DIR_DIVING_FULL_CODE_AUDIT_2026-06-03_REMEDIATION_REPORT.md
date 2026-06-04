# DIR DIVING — Full Code Audit Remediation Report (2026-06-03)

Source audit: [`DIR_DIVING_FULL_CODE_AUDIT_2026-06-03.md`](DIR_DIVING_FULL_CODE_AUDIT_2026-06-03.md)

## A. Branch confirmed

`main`

## B. Commit confirmed (audit baseline)

`7655184` — `docs: add full code audit report`

Working-tree remediation applied on top of `7655184` (uncommitted at report generation time).

## C. Target confirmation

| Target | Status |
|--------|--------|
| DIRDiving Watch App | Built (watchOS Simulator) |
| DIRDiving iOS | Built (iOS Simulator) |
| DIRDiving iOS Algorithm Tests | 213 executed, 0 failures (3 skipped) |
| DIRDiving Watch Algorithm Tests | 68 executed, 0 failures |

## D. Experimental exclusions confirmation

`project.yml` exclusions unchanged. Experimental Watch/iOS files not modified.

## E. Files modified / added

**New**

- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Utils/DiveSessionCollectionIntegrity.swift`
- `Tests/iOSAlgorithmTests/AuditRemediationTests.swift`
- `Tests/WatchAlgorithmTests/GPSLifecycleTests.swift`
- `Docs/CSV_IMPORT_EXPORT_POLICY.md`
- `Docs/WATCH_GPS_LIFECYCLE_POLICY.md`
- `Docs/DIR_DIVING_FULL_CODE_AUDIT_2026-06-03_REMEDIATION_REPORT.md`

**Modified (representative)**

- Environment-aware MOD: `GasPlan.swift`, `PlannerGasMixCard.swift`, `PlannerView.swift`, `GasPlanningService.swift`, `PlannerGasSchedule.swift`
- Merge hardening: `DiveSessionMergeConflict.swift`, `DiveLogStore.swift`
- Preflight hook: `PlannerService.swift`
- Localization: `BuhlmannPlanner.swift`, `GasPlanningService.swift`, `en.lproj` / `it.lproj`
- CSV import: `DiveImportService.swift`
- Sync security: `WatchSyncAuth.swift` (iOS + Watch), `WatchDiveSyncCodec.swift` (iOS + Watch)
- Gas ledger audit: `ScheduleGasConsumptionService.swift`, `PlannerView.swift`
- GPS lifecycle: `GPSManager.swift`
- Test target membership: `project.yml`

## F. Issues fixed by ID

### P2.1 Environment-unaware MOD display/warnings

- Added `modMeters(environment:)` / `isSwitchDepthBeyondMOD(environment:)` on `GasMix` and `PlannerCylinderEntry`.
- Planner UI cards, cylinder MOD labels, switch-depth warnings, `GasPlanningService` MOD state, and bailout schedule lines now use `input.plannerEnvironment`.
- Sea-level computed properties retained as documented display-only legacy fallback.

### P2.2 Duplicate session ID trap

- Added `DiveSessionCollectionIntegrity.deduplicated(_:)` with deterministic newest-session selection.
- `DiveSessionMergeConflictDetector` and `DiveLogStore` conflict snapshots no longer use `Dictionary(uniqueKeysWithValues:)` on untrusted arrays.
- Duplicate IDs reported as `duplicateSessionID` merge conflicts.

### P2.3 Bühlmann gas preflight validation

- Added `BuhlmannPlanPreflightValidator` (wraps `BuhlmannEngine.validate`).
- `PlannerService` runs preflight before schedule generation and short-circuits with typed `BuhlmannPlanIssue` output when validation fails.

### P3.1 Hardcoded service-layer strings

- Localized Bühlmann planner warnings, GF comparison notes, briefing lines, and planner validation messages.
- Added matching EN/IT keys (`planner.briefing.*`, `planner.buhlmann.*`, `planner.validation.*`, gas ledger labels).
- **Remaining (classified internal/debug):** internal enum raw values, `# dirdiving_*` CSV metadata keys, `Reference gas` / `N2 reference` internal Bühlmann labels not shown in UI.

### P3.2 Optional CSV temperature import

- `temperature_c` no longer required; time/depth remain required.
- Nil temperature stats when column absent.

### P3.3 Watch sync key hardening

- Replaced public zero-key `syncKey()` with throwing `deriveSyncKey()`.
- Codecs guard on `hasPeerSecret()` and reject empty / legacy `"acknowledged"` ack strings.

### P3.4 Keychain migration symmetry

- **Intentionally asymmetric:** iOS migrates legacy `dirmotion` keychain service once; Watch always used canonical `dirdiving` service. Documented in both `WatchSyncAuth` implementations.

### P3.5 Unused planned gas visibility

- `GasConsumptionLedger.unusedPlannedEntries` lists standby/bailout/unused cylinders without changing consumption totals.
- Planner gas ledger UI shows separate unused/standby section.

### P3.6 GPS lifecycle ownership

- Documented `DiveManager` ownership; added `stopUpdatesWhenComplete` to `captureBestEffortPoint`.
- Policy: [`WATCH_GPS_LIFECYCLE_POLICY.md`](WATCH_GPS_LIFECYCLE_POLICY.md)

### P3.7 Additional fixtures

- `AuditRemediationTests.swift` covers MOD/environment, merge dedup, preflight, CSV temperature, sync key, unused gas, GF comparison regression.
- **Pending external golden validation:** third-party decompression planner numeric tolerances (documented; internal regression fixtures used instead of invented external numbers).

## G. Tests added

- `Tests/iOSAlgorithmTests/AuditRemediationTests.swift`
- `Tests/WatchAlgorithmTests/GPSLifecycleTests.swift`
- Updates to `WatchSyncConflictTests.swift`

## H. Tests run

| Suite | Result |
|-------|--------|
| DIRDiving iOS Algorithm Tests | **PASS** (213 tests, 3 skipped) |
| DIRDiving Watch Algorithm Tests | **PASS** (68 tests) |

Skipped tests: keychain-dependent sync signing when simulator keychain unavailable (`XCTSkip`).

## I. Build results

| Command | Result |
|---------|--------|
| `xcodegen generate` | **PASS** |
| `xcodebuild` DIRDiving iOS (iPhone 17 Simulator) | **PASS** |
| `xcodebuild` DIRDiving Watch App (watchOS Simulator) | **PASS** |

## J. Localization validation results

- EN/IT localization key sets match (diff empty on quoted keys).
- EN: 1039 lines; IT: 1037 lines (comment/blank variance only).
- New audit remediation keys present in both locales.

## K. Security validation results

- No public zero-key sync material API.
- Missing peer secret fails closed (throw / empty signed ack).
- Legacy unsigned `"acknowledged"` ack rejected.
- Duplicate cloud/local session IDs cannot trap merge detection.

## L. Remaining external QA

- Apple Watch Ultra depth entitlement on device
- Real depth sensor / haptics / GPS field validation
- WatchConnectivity field pairing under real latency
- App Intents on device
- External certified decompression planner cross-check (golden numbers pending)

## M. Remaining risks

- Preflight currently mirrors `BuhlmannEngine.validate`; additional ascent-window checks were deferred to avoid rejecting valid multigas plans—runtime engine still appends `gasNotOperationalInSegment` if needed.
- Keychain-dependent sync tests skip in some simulator environments.
- Altitude MOD display uses absolute ambient model (MOD depth in meters increases at altitude vs sea level for same gas/PPO2 limit—consistent with existing `PressureModelUnificationTests`).

## N. Confirmation

- MAIN only; experimental branches untouched
- No UI redesign; dark marine/cyan planner identity preserved
- No Watch TTV semantic change
- No certified dive-computer claim introduced
- No Apple Low Power Mode false claim
- Planner remains reference-only
- Bühlmann core math unchanged except audit-required validation wiring

## O. Final readiness estimate

**Simulator/build/test readiness: high** for MAIN Watch + iOS companion.

**Field/release readiness: unchanged** — still requires physical Watch Ultra QA, entitlement-approved device builds, and external planner golden validation before App Store gate sign-off.

---

Remediation executed: 2026-06-03 (macOS, Xcode 26.x simulator matrix).
