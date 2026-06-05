# DIR DIVING Full Code Bug and Improvement Audit

Date: 2026-06-03

Branch audited: `main`

Repository HEAD audited: `31d5976ffb5c61eec1d2e76e39ae7e3daa5c393d`

Remote checked: `origin/main`

Audit type: static source review on Windows. XcodeGen, Xcode, Swift compiler, simulator, and XCTest execution were not available in this environment, so build and runtime validation still require macOS.

## Executive Summary

The repository is broadly coherent and much cleaner than earlier audit states. Main branch target isolation is in place, the iOS Bühlmann/multigas planner has a dedicated algorithm layer, Watch algorithm hardening is present, localization key counts match between English and Italian resources, sync uses authenticated payloads, exports reject empty profiles, and no unresolved merge markers were found in Swift/YAML/project code.

No confirmed P0 safety-critical code defect was found during this static pass.

The main remaining risks are not visual or architectural regressions, but release-hardening details:

- a few planner MOD/warning display paths still use sea-level default assumptions while the engine supports altitude/salinity environments;
- duplicate session IDs in corrupted cloud/merge inputs can still trap through `Dictionary(uniqueKeysWithValues:)`;
- several user-facing warnings are still hardcoded in Swift instead of localization resources;
- CSV import is stricter than necessary because it requires `temperature_c`;
- macOS build/test execution has not been performed from this environment.

## Repository and Build Status

| Check | Result |
|---|---|
| Current branch | `main` |
| Local vs remote | Local HEAD matches `origin/main` at `31d5976` |
| Merge conflict markers | No active code conflict markers found |
| XcodeGen available | Not available on Windows |
| xcodebuild available | Not available on Windows |
| Swift compiler available | Not available on Windows |
| Static target isolation | Main iOS and Watch exclusions are present in `project.yml` |
| Experimental TODOs | Present mostly in excluded experimental placeholder files |

## Positive Findings

1. `project.yml` excludes the expected experimental iOS files from the main iOS target and excludes experimental Watch features from the main Watch target.
2. Watch and iOS localization key counts match:
   - iOS English: 973 keys
   - iOS Italian: 973 keys
   - Watch English: 556 keys
   - Watch Italian: 556 keys
3. The iOS Bühlmann engine has a dedicated algorithm folder under `iOSApp/Algorithms/Buhlmann`.
4. The previous environment ceiling issue in `BuhlmannTissueModel.ceiling(gf:environment:)` appears fixed.
5. `PlannerService` now derives planner output from a single engine plan instead of repeatedly recalculating divergent plan objects.
6. `ScheduleGasConsumptionService` uses UUID-backed cylinder allocation keys, avoiding duplicate-label cylinder crashes.
7. iOS sync payload validation includes HMAC, payload size, schema version, issued-at skew, bundle identity, and normalized session validation.
8. `SubsurfaceExportService` rejects empty sample arrays and normalizes/sorts exportable samples.
9. Watch `GPSManager.captureBestEffortPoint` now completes a previous best-effort capture before replacing it.
10. No obvious hardcoded credentials were found; sync secret labels are keychain identifiers, not literal shared secrets.

## Priority Findings

### P0 - Safety Critical

No confirmed P0 issue was found in this static audit.

### P1 - Compile or Release Blockers

No confirmed source-level P1 blocker was found by static inspection.

Required external validation remains:

- Run `xcodegen generate` on macOS.
- Build the iOS target.
- Build the Watch target.
- Run iOS algorithm tests.
- Run Watch algorithm tests.
- Perform physical Apple Watch Ultra validation for depth entitlement, depth sensor, haptics, GPS, WatchConnectivity, and App Intents.

### P2 - Important Bugs or Data Integrity Risks

#### P2.1 Environment-unaware MOD display and warning paths

Affected files:

- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`

Issue:

Several UI/model helper paths still use default sea-level MOD calculations through `GasMix.modMeters`, `PlannerCylinderEntry.modMeters`, or `PlannerMODValidator.modMeters(...)` without the active `PlannerEnvironment`. The engine and `PlannerMODValidator` support environment-aware validation, but display cards and some warning helpers can disagree with engine results when altitude or freshwater settings are selected.

User impact:

A planner card or warning can show a MOD/switch-depth assessment that does not match the actual engine environment. This is especially important because the planner now exposes altitude/salinity context.

Recommended fix:

Create environment-aware display helpers and pass `PlannerEnvironment` into all MOD display/warning paths. Keep sea-level helpers only for legacy/default contexts and label them clearly.

Estimated impact:

Small functional fix, no UI redesign required.

#### P2.2 Duplicate session IDs can trap during cloud/local conflict detection

Affected file:

- `iOSApp/Utils/DiveSessionMergeConflict.swift`

Issue:

`DiveSessionMergeConflictDetector.detect(local:cloud:)` uses `Dictionary(uniqueKeysWithValues:)` for cloud sessions. If corrupted or duplicated cloud data contains the same session ID more than once, Swift can trap. `DiveLogStore.updateMergeConflictState` also builds dictionaries from conflict snapshots and should be checked for the same pattern.

User impact:

A corrupted iCloud/local payload could crash or interrupt logbook loading/merge conflict evaluation.

Recommended fix:

Replace `Dictionary(uniqueKeysWithValues:)` with a deterministic grouping/reduction policy:

- sort by `updatedAt` or `startDate`;
- keep the newest valid session per ID;
- record duplicate IDs as a conflict/integrity warning;
- never trap on duplicated external input.

Estimated impact:

Small functional/data integrity fix.

#### P2.3 Bühlmann gas validation should preflight all ascent/deco operating ranges

Affected files:

- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Services/PlannerMODValidator.swift`

Issue:

The planner validates descent and bottom segments, and runtime ascent logic can append `.gasNotOperationalInSegment`. However, full preflight validation for all ascent/deco gases, switch depths, hypoxic minimum operating depths, and MOD windows should be made explicit before schedule generation. This will make failure states easier to reason about and test.

User impact:

Complex multigas plans may fail late in schedule generation instead of producing a clear early validation error.

Recommended fix:

Add a dedicated `BuhlmannPlanPreflightValidator` or extend the existing request validation to evaluate every gas over every planned usable depth range before schedule generation.

Estimated impact:

Medium algorithmic hardening.

### P3 - Maintainability, UX Hardening, and Release Polish

#### P3.1 Hardcoded user-facing strings remain in Swift

Affected files include:

- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`

Issue:

Several planner, validation, export, and briefing strings are hardcoded in Italian or English, even though resource key counts match between English and Italian localization files.

User impact:

The language switch/localization system may show mixed-language output in planner warnings, export errors, and validation feedback.

Recommended fix:

Move all user-facing service/view-model strings into localization resources. Keep internal enum cases language-neutral and map them to localized text at the presentation boundary.

Estimated impact:

Copy/localization only.

#### P3.2 CSV import requires temperature even when temperature should be optional

Affected file:

- `iOSApp/Services/DiveImportService.swift`

Issue:

The import schema requires `temperature_c`. Existing sample validation can handle optional temperature, but the column requirement rejects profiles that otherwise contain valid time/depth data.

User impact:

Valid external dive CSV profiles without temperature cannot be imported.

Recommended fix:

Make `temperature_c` optional. If absent, import samples with `nil` temperature and ensure derived temperature stats remain unavailable rather than invalid.

Estimated impact:

Small import compatibility fix.

#### P3.3 Watch sync key fallback should be impossible to misuse

Affected files:

- `iOSApp/Services/WatchSyncAuth.swift`
- `Services/WatchSyncAuth.swift`

Issue:

The implementation correctly checks `hasPeerSecret` before signing/parsing. However, the lower-level `syncKey` path can return zeroed data if future callers bypass that guard.

User impact:

No immediate issue was found, but this is a future hardening concern.

Recommended fix:

Make sync key acquisition throwing/private and require all payload signing/parsing through guarded public APIs.

Estimated impact:

Small security hardening.

#### P3.4 Legacy keychain migration appears asymmetric

Affected files:

- `iOSApp/Services/WatchSyncAuth.swift`
- `Services/WatchSyncAuth.swift`

Issue:

iOS has explicit legacy `dirmotion` keychain migration behavior. The Watch-side implementation should be checked for equivalent migration if older Watch builds stored compatible peer secrets under previous labels.

User impact:

Some upgraded users might need to reset pairing trust instead of migrating seamlessly.

Recommended fix:

Document expected migration behavior and add matching migration if old Watch-side labels existed in released builds.

Estimated impact:

Small compatibility hardening.

#### P3.5 Planned but unused gas cylinders are not shown in gas ledger totals

Affected file:

- `iOSApp/Services/ScheduleGasConsumptionService.swift`

Issue:

The ledger is based on gases/cylinders used by the generated engine plan. Unused planned cylinders are not included in `totalRemaining`.

User impact:

This is mathematically consistent for consumed gas, but a diver reviewing a plan may expect every configured cylinder to appear in a gas audit, including standby/unused/bailout gases.

Recommended fix:

Keep consumption math unchanged, but expose a separate "unused planned gases" or "standby gases" list for audit completeness.

Estimated impact:

Small service/view-model enhancement.

#### P3.6 GPS best-effort capture starts location updates but does not stop them itself

Affected file:

- `Services/GPSManager.swift`

Issue:

`captureBestEffortPoint` starts location updates and completes captures safely. It does not stop updates inside the capture path. This may be intentional if another owner manages GPS lifecycle, but the policy should be explicit.

User impact:

Possible battery impact if GPS updates continue longer than needed in a standalone capture flow.

Recommended fix:

Document ownership of start/stop updates or add an opt-in one-shot capture mode that stops updates after completion when no broader location session is active.

Estimated impact:

Small energy/lifecycle hardening.

#### P3.7 More external numerical fixtures are needed for Bühlmann confidence

Affected area:

- `Tests/iOSAlgorithmTests`

Issue:

The iOS algorithm tests are extensive, but a release-hard technical planner benefits from externally sourced golden fixtures across more scenarios.

Recommended additional fixtures:

- altitude plus freshwater MOD/ceiling scenarios;
- trimix travel gas switch sequence;
- multiple deco gas switch sequence;
- GF 30/70 vs 50/80 against a documented external planner tolerance;
- hypoxic gas shallow rejection;
- duplicate session ID cloud merge corruption;
- environment-aware MOD display consistency.

Estimated impact:

Test hardening.

## Feature and Architecture Observations

### Apple Watch Main

Observed:

- Canonical algorithmic pieces are present for validated depth, lifecycle, runtime, ascent rate, haptics coordination, logbook cap, GPS best-effort handling, export validation, and sync payload validation.
- Main Watch target excludes experimental Watch features.
- The Watch UI was not modified during this audit.

Remaining Watch-specific validation:

- Physical device depth entitlement behavior.
- Real sensor freshness/frozen-value behavior.
- Haptic throttling behavior on device.
- App Intents and Action Button mapping through Shortcuts.
- WatchConnectivity timing across disconnect/reconnect.

### iOS Companion Main

Observed:

- iOS planner has centralized algorithm/configuration utilities.
- Bühlmann ZHL-16C N2/He implementation is present under `iOSApp/Algorithms/Buhlmann`.
- Planner service uses a single engine plan and safe typed states.
- Export/import/sync validation are much stronger than earlier states.
- Main iOS target excludes experimental-only views/models/services.

Remaining iOS-specific validation:

- Environment-aware MOD display consistency.
- Full macOS XCTest pass.
- External decompression-planner fixture comparison.
- Localization of service-layer warning strings.

## Files Inspected

Key files reviewed in this pass:

- `project.yml`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueModel.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannEnvironment.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchSyncAuth.swift`
- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Utils/DiveSessionMergeConflict.swift`
- `Services/DiveManager.swift`
- `Services/GPSManager.swift`
- `Services/DiveLogStore.swift`
- `Services/WatchDiveSyncCodec.swift`
- `Services/WatchSyncAuth.swift`
- `Resources/en.lproj/Localizable.strings`
- `Resources/it.lproj/Localizable.strings`
- `iOSApp/Resources/en.lproj/Localizable.strings`
- `iOSApp/Resources/it.lproj/Localizable.strings`

## Recommended Roadmap

### Must do before TestFlight

1. Run XcodeGen, iOS build, Watch build, and all tests on macOS.
2. Fix environment-unaware MOD display/warnings.
3. Fix duplicate session ID trap risk in merge conflict detection.
4. Add regression tests for the two fixes above.

### Must do before App Store or broader beta

1. Move remaining user-facing hardcoded strings to localization resources.
2. Expand external Bühlmann fixture comparisons.
3. Confirm Watch Ultra physical-device behavior for entitlement, depth sensor, GPS, haptics, and WatchConnectivity.
4. Confirm CSV import/export roundtrip with real external sample files.

### Post-release hardening

1. Make temperature optional in CSV import.
2. Add explicit gas audit treatment for unused planned cylinders.
3. Harden sync key API to make zero-key fallback unreachable by construction.
4. Document or refine GPS update lifecycle ownership.

## Final Verdict

Based on static analysis, the codebase looks substantially aligned, internally consistent, and close to release-hard for internal validation.

It is not possible to certify it as compile-ready or TestFlight-ready from this Windows environment because XcodeGen, xcodebuild, simulator, and XCTest execution were unavailable.

The most important code fixes to do next are:

1. environment-aware MOD display/warning consistency;
2. duplicate session ID safe handling in merge conflict detection;
3. localization of remaining service-layer user-facing strings.

No code changes were made as part of this audit other than creating this report.
