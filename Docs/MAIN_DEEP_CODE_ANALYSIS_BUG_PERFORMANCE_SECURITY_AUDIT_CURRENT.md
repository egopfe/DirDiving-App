# DIR DIVING MAIN Deep Code Analysis, Bug, Performance, and Security Audit

Date: 2026-06-07  
Scope: MAIN branch only  
Target branch: `main`  
Audited commit: `8c7d6e6`  
Repository: DIR DIVING  
Output file: `Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md`

## A. Executive Summary

This audit was performed against branch `main` only. The working tree was clean before the report was created, and `git status -sb` after `git fetch origin` reported `## main...origin/main`.

No production source code, UI, business logic, algorithms, security model, sync model, planner mode logic, or experimental files were modified during this audit.

### Readiness Percentages

These percentages are static-audit readiness estimates. Build and test execution could not be verified in this Windows environment because `xcodegen` and `xcodebuild` were unavailable.

| Readiness area | Estimate | Rationale |
|---|---:|---|
| Overall static code readiness | 78% | No critical source-code issue found, but one high sync/data-integrity issue and several medium hardening/performance issues remain. |
| Watch MAIN readiness | 84% | Watch lifecycle, haptic throttling, legal gate, protected persistence, and sensor fallback controls are mostly defensive. Remaining Watch risk is sync/photo-management hardening plus physical QA. |
| iOS MAIN readiness | 74% | iOS planner and Buhlmann coverage is broad, but outbound sync ACK semantics, planner state churn, PDF temp privacy, photo preprocessing, and cloud payload hardening need work. |
| Bug risk readiness | 76% | Medium planner-state and crash-hardening issues remain. |
| Performance readiness | 72% | Planner recalculation, photo preprocessing, CSV parsing, KVS payloads, and SwiftUI invalidation need performance budgets/tests. |
| Security readiness | 79% | HMAC peer-secret model is strong for dive sync, but photo-management payloads and replay hardening remain. |
| Privacy readiness | 73% | Protected logbook files are good; PDF temp files and generic cloud local payloads need protection/cleanup. |
| Data integrity readiness | 70% | iOS-to-Watch queued sync can drop pending outbound sessions without signed import ACK. |
| Sync/cloud readiness | 68% | Watch-to-iOS pending ACK policy is stronger than iOS-to-Watch queued policy; KVS payload handling needs stricter preflight. |
| Internal TestFlight readiness | Not ready | Requires macOS/Xcode build/test evidence, high sync issue remediation, and simulator QA. |
| External TestFlight readiness | Not ready | Requires paired Watch/iPhone QA, iCloud two-device QA, photo sync hardening, and physical Watch Ultra evidence. |
| App Store readiness | Not ready | Requires physical QA evidence, privacy hardening, App Store wording review, and external validation evidence where claimed. |

### Most Urgent Issues

1. `MAIN-AUD-001`: iOS drops queued outbound Watch sync sessions on WatchConnectivity delivery instead of waiting for signed import ACK.
2. `MAIN-AUD-013`: Xcode build and simulator tests were not runnable in the current environment.
3. `MAIN-AUD-014`: Physical/external QA evidence remains pending and must not be represented as passed.
4. `MAIN-AUD-003` and `MAIN-AUD-004`: Privacy hardening needed for generic cloud local payloads and PDF temp exports.
5. `MAIN-AUD-006` and `MAIN-AUD-007`: Planner state handling can overwrite switch depth intent and cause recalculation storms.

No `CRITICAL` severity issue was confirmed by static review. The highest confirmed source-code issue is `HIGH` severity due to data-integrity risk in iOS-to-Watch queued sync.

## B. Scope Confirmation

### Git / Remote State

| Check | Result |
|---|---|
| Branch | `main` |
| Commit | `8c7d6e6` |
| Remote alignment | `## main...origin/main` after `git fetch origin` |
| Dirty files before report | None |
| Experimental branches | Not touched |
| Apnea/Snorkeling/Buddy Assist/Exploration Lab | Not modified; excluded files not edited |

### Commands Attempted

| Command | Result |
|---|---|
| `git branch --show-current` | `main` |
| `git rev-parse --short HEAD` | `8c7d6e6` |
| `git status -sb` | `## main...origin/main` |
| `git fetch origin` | Completed; branch remained aligned |
| `xcodegen generate` | Blocked: `xcodegen` was not recognized in this Windows PowerShell environment |
| `xcodebuild -scheme "DIRDiving Watch App" -destination 'generic/platform=watchOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | Blocked: `xcodebuild` was not recognized |
| `xcodebuild -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build` | Blocked: `xcodebuild` was not recognized |
| `xcodebuild -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test` | Blocked: `xcodebuild` was not recognized |
| `xcodebuild -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test` | Blocked: `xcodebuild` was not recognized |

Build and test pass/fail status is therefore unverified, not passed.

### Targets Found In `project.yml`

| Target | Type/platform | Bundle ID | Entitlements | Key relationship |
|---|---|---|---|---|
| `DIRDiving Watch App` | watchOS app | `com.egopfe.dirdiving.ios.watch` | `Config/DIRDiving.entitlements` | Companion app bundle ID set to `com.egopfe.dirdiving.ios` |
| `DIRDiving iOS` | iOS app | `com.egopfe.dirdiving.ios` | `iOSApp/Config/DIRDivingiOS.entitlements` | Embeds `DIRDiving Watch App` |
| `DIRDiving Watch Algorithm Tests` | watchOS unit tests | `com.egopfe.dirdiving.watch.algorithmtests` | None found | Tests Watch app target |
| `DIRDiving iOS Algorithm Tests` | iOS unit tests | `com.egopfe.dirdiving.ios.algorithmtests` | None found | Tests iOS app target |

### Entitlements

Both Watch and iOS entitlement files declare:

- iCloud container: `iCloud.com.egopfe.dirdiving`
- iCloud service: `CloudKit`
- ubiquity KVS identifier: `$(TeamIdentifierPrefix)com.egopfe.dirdiving`

### Experimental Exclusions Confirmed

Watch target exclusions in `project.yml` include:

- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- `Models/ExplorationModels.swift`
- `Models/BuddyAssistMessage.swift`
- `Models/BuddyPairingHandshake.swift`
- `Services/ExplorationStore.swift`
- `Services/BuddyAssistService.swift`
- `Services/BuddyAssistPeripheralService.swift`
- `Services/BuddyPairingKeyAgreement.swift`
- `Services/SecureBuddyStore.swift`

iOS target exclusions in `project.yml` include:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

### Static Scan Summary

| Scan | Result |
|---|---|
| Force unwrap / `try!` / `as!` | No production `try!` or `as!` blocker found. `iOSApp/Views/PlannerView.swift:2420` has a reachable `columnHeaders!` force unwrap inside a reusable helper. Other production force unwraps are guarded by non-empty checks. |
| `Dictionary(uniqueKeysWithValues:)` | `iOSApp/Utils/DiveSessionMergeConflict.swift:29` uses it after deduplication; safe by current invariant but worth test/backstop hardening. |
| Hardcoded secrets | No API keys, tokens, private keys, or Apple credentials found in MAIN code during text scan. |
| TODO/FIXME/debug | No MAIN release blocker from TODO/FIXME scan. Experimental TODOs are in excluded files. |
| File writes | Most log/session/export files use `.completeFileProtection`; `iOSApp/Services/PDF/PDFDocumentBuilder.swift:198` writes PDF temp output with `.atomic` only. |
| SwiftUI `.onChange` / timers / async tasks | Several expected patterns; the strongest perf risks are planner recalculation on every mutation and overlapping cloud sync status tasks. |
| WatchConnectivity/HMAC | Dive payloads use signed HMAC envelopes and signed ACKs, but iOS queued outbound delivery does not preserve pending state until signed import ACK. |

### Files And Directories Inspected

Primary inspected areas:

- `project.yml`
- `App/`, `Models/`, `Services/`, `Utils/`, `Views/`
- `iOSApp/App/`, `iOSApp/Algorithms/`, `iOSApp/Models/`, `iOSApp/Services/`, `iOSApp/Utils/`, `iOSApp/Views/`
- `Tests/WatchAlgorithmTests/`
- `Tests/iOSAlgorithmTests/`
- `Config/`, `iOSApp/Config/`
- `Docs/` for release/QA consistency context

## C. Architecture Analysis

### Watch

Watch MAIN is generated from `project.yml` with explicit exclusions for experimental Apnea, Snorkeling, Buddy Assist, Exploration, and future concepts. Runtime services are split by responsibility:

- Dive lifecycle and persistence: `Services/DiveManager.swift`, `Services/DiveLogStore.swift`
- Sensor abstraction: `DepthSensorProvider`, `AppleDepthSensorProvider`, `MockDepthSensorProvider`, `SensorProviderFactory`
- Haptics: `HapticService`, `DepthLimitHapticCoordinator`, `AscentSafetyHapticCoordinator`
- Sync: `WatchSyncService`, `WatchDiveSyncCodec`, `WatchSyncAuth`
- Media: `UserImageStore`, `CompanionPhotoImportSupport`
- Safety and presentation views under `Views/`

Positive controls observed:

- Active dive draft writes use `.atomic` and `.completeFileProtection`.
- Corrupt/expired active dive drafts are quarantined before deletion.
- Manual no-depth sessions are represented explicitly and validation allows them only when the manual/no-depth truth is preserved.
- Action Button/App Intent safety paths call `ActionButtonSafetyGate.requireLegalAcceptance()` before stopwatch/dive/bearing/alarm actions.
- Haptic warning paths have throttle/generation guards, reducing haptic storm risk.
- Simulation sensor selection is DEBUG/TestFlight-only and release-safe migration resets legacy `.simulation` to `.automatic`.
- Mission Mode is runtime/profile state only and does not change the dive algorithm configuration.

Architecture risks:

- Watch and iOS sync implementations are duplicated rather than shared; this enabled the iOS queued-ACK asymmetry in `MAIN-AUD-001`.
- Companion photo management is a parallel message family outside the signed dive envelope path.
- Full physical Watch Ultra depth/sensor/GPS/haptics validation remains external and pending.

### iOS

iOS MAIN contains planner, Buhlmann, logbook, cloud sync, Watch sync, import/export, equipment, and analysis paths. The three planner modes are implemented with projection and result presentation policy:

- Base mode projects to bottom gas only and hides full Buhlmann/ascent tables.
- Deco mode projects to bottom plus one deco gas and fixed GF preset logic.
- Technical mode preserves travel/deco/bailout and manual GF controls.

Positive controls observed:

- Buhlmann and gas planning have broad algorithm tests and canonical fixtures.
- MOD/PPO2, environment pressure, salinity, altitude, repetitive planning, CNS/OTU, and mode projection are covered by named tests.
- Logbook sessions are stored in protected document files; cloud backup for logbook sessions is gated by `CloudBackupSettings.isEnabled`.
- CSV import has size, row, column, and field caps.
- Watch sync secrets use Keychain and peer pinning.

Architecture risks:

- `PlannerStore` is `@MainActor` and recalculates/persists on every published input mutation.
- `CloudSyncStore` is generic for planner/equipment/deleted-ID KVS state and writes local data before checking the cloud payload cap.
- `PDFDocumentBuilder` uses temp files without complete file protection.
- Several iOS UI helpers are compiled but legacy/test-only, including `PlannerGasMixCard.swift` as an `EmptyView` alias.

### Shared / Duplicated Code

Several concepts exist in both Watch root folders and `iOSApp/`:

- `DiveSession`, `DiveSample`
- `DiveLogStore`
- `WatchSyncService`
- `WatchDiveSyncCodec`
- `WatchSyncAuth`
- `DiveSessionMerge`
- `SubsurfaceExportService`
- Unit conversion and formatting helpers

This duplication is understandable because the targets have different platforms, but it creates drift risk. The main confirmed drift is pending sync semantics:

- Watch-to-iOS queued userInfo keeps pending until signed ACK.
- iOS-to-Watch queued userInfo removes pending when WatchConnectivity delivery completes, without signed import ACK.

### Build / Project

`project.yml` is the source of truth for target membership. That is good for preventing accidental experimental inclusion, but it also means `xcodegen generate` must be part of release CI. It could not be run in this environment.

No generated `.xcodeproj` validation was possible here. Release readiness depends on a macOS machine with Xcode, XcodeGen, paired simulator destinations, and signing profiles.

### Tests

Test target inventory:

- Watch algorithm tests: 29 Swift files, 169 `func test...` entries found by static count.
- iOS algorithm tests: 64 Swift files, 390 `func test...` entries found by static count.

Coverage is strong for algorithms, sync codec/auth, mission mode invariants, legal gate, MOD switching, pressure model, cloud backup policy, CSV round trip, PDF export, and photo transfer basics.

Important gaps remain:

- iOS queued userInfo outbound must retain pending until signed Watch import ACK.
- Companion photo management messages need signed-envelope/replay tests.
- Planner pressure-only edits must not reset switch depth.
- Performance tests for planner mutation storms and photo preprocessing memory.
- Physical Watch Ultra, paired-device, iCloud two-device, and external Subsurface evidence.

### Docs / Release

Release documentation must continue to avoid certified dive-computer or certified decompression-planner claims. Physical/external validation items are pending and must stay marked pending until actually executed.

## D. Apple Watch Code Analysis

### Bugs / Crash Risks

No high-severity Watch lifecycle crash was confirmed by static review. Key observations:

- `DiveManager` guards active/finalizing state before start/end transitions.
- Active dive draft restore handles unsupported schema, corrupt data, expired TTL, and pending finalization.
- Automatic surface ending uses cancellable tasks and rechecks active/finalizing state before finalizing.
- Depth sample ingestion uses `DepthSampleValidationState` and rejects stale, frozen, non-finite, out-of-range, and implausible transitions.
- Watch `DiveLogStore.delete(at:)` guards `sessions.indices.contains(index)`, unlike the iOS version.

### Performance / Battery

Watch runtime uses expected 1-second timers for runtime/stopwatch and a 0.45-second blink timer only while alarm sources exist. Haptic throttles are present:

- General warning throttle in `HapticService.warnIfNeeded()`.
- Ascent repeat throttle in `HapticService.ascentAlarmRepeatIfNeeded()`.
- Depth threshold intervals in `DepthLimitHapticCoordinator`.

Battery risks remain mostly QA/process:

- GPS starts on dive start and stops after exit best-effort capture completes.
- Location updates remain active for the 6-second exit capture after dive end by design.
- Physical testing must verify no GPS/haptic/sensor loop remains active after interrupted finalization, background/resume, or force quit.

### Security / Privacy

Positive controls:

- Watch active dive draft and log files use complete file protection.
- `UserImageStore` validates uploaded image filenames and prevents `..` and slash path traversal.
- Watch sync HMAC and signed ACK verification are present for dive payloads.
- Peer-secret pinning rejects changed peer secrets unless trust is reset.
- Action Button/App Intent paths enforce legal onboarding acceptance.

Remaining security/privacy issues:

- `MAIN-AUD-002`: Companion photo inventory/delete payloads are not signed like dive sync.
- `MAIN-AUD-012`: Signed dive payload replay protection depends on timestamp skew and duplicate/imported IDs, not a transport nonce replay cache.

### Mission Mode

Mission Mode is represented as runtime profile state:

- `isMissionModeActive`
- `missionModeActivationSource`
- `missionModeManualPendingForSession`
- `missionModeRuntimeProfile`

No code path was found that changes Watch depth/ascent/dive lifecycle algorithms because Mission Mode is active. Tests named `MissionModeAlgorithmInvariantTests` are present.

### App Intents

`Services/ActionButtonIntents.swift` calls `requireLegalAcceptanceForSafetyIntent()` before:

- Toggle stopwatch
- Reset stopwatch
- Start manual dive
- End manual dive
- Set bearing
- Clear bearing
- Acknowledge alarm

No legal-gate bypass was found in these intent implementations.

### Depth Lifecycle / Safety Thresholds

Depth state is driven by:

- `DepthSampleValidationState`
- `DiveLifecycleAlgorithm`
- `DepthSafetyState.from(depthMeters:)`
- `DiveAlgorithmConfiguration`
- `DepthSafetyConfiguration`

Static review found no obvious 35/38/40 m threshold miswire. Physical validation is still required for Apple Watch depth sensor behavior.

## E. iOS Companion Code Analysis

### Planner Base / Deco / Technical

Mode projection appears mostly correct:

- Base mode projects to one bottom cylinder and ignores hidden non-bottom gases.
- Deco mode keeps bottom plus the deepest one deco gas and applies fixed GF presets unless invalid.
- Technical mode preserves travel, deco, bailout, and manual GF controls.

Confirmed planner issue:

- `MAIN-AUD-006`: Pressure-unit/working-pressure edits call the same callback used for gas/PPO2 changes, which normalizes switch depth to MOD and can overwrite intentional switch depth choices.

Performance issue:

- `MAIN-AUD-007`: Planner recalculation and cloud save happen on every input mutation.

### Buhlmann / Gas Planning

Static review found strong coverage for:

- Pressure model/environment handling.
- MOD and PPO2 validation.
- GF comparison.
- Repetitive planning snapshot validation.
- CNS/OTU warnings.
- Gas ledger/reserve/minimum gas states.
- Buhlmann NDL/ceiling/tissue history fixtures.

No direct algorithmic Buhlmann math bug was confirmed in this pass. However, build/test execution was blocked, so pass/fail cannot be claimed.

### Logbook / Import / Export / Sync / Cloud

Positive controls:

- iOS logbook sessions persist to `dirdiving_ios_dive_sessions.json` with `.completeFileProtection`.
- Logbook cloud backup is gated by `CloudBackupSettings.isEnabled`.
- CSV import enforces max import bytes, row count, column count, and field length.
- Subsurface CSV export uses complete file protection.
- Watch sync codec validates and normalizes sessions before storage.

Confirmed issues:

- `MAIN-AUD-001`: iOS-to-Watch queued sync drops pending state without signed import ACK.
- `MAIN-AUD-003`: Generic cloud sync writes local `UserDefaults` data before checking KVS payload size.
- `MAIN-AUD-004`: PDF temp exports do not use complete file protection.
- `MAIN-AUD-008`: iOS `DiveLogStore.delete(at:)` indexes `sessions[index]` without an index guard.

### UI-State Logic

Confirmed issues:

- `MAIN-AUD-006`: switch depth reset on pressure-only edits.
- `MAIN-AUD-009`: `PlannerView.tableRow` force unwraps `columnHeaders![index]` without checking header count.
- `MAIN-AUD-010`: `CloudSyncStore.synchronize()` can spawn overlapping delayed tasks that race `isSynchronizing`.

## F. Cross-App Sync / Data Integrity Analysis

### Watch To iOS

Watch queued transfer semantics are strong:

- `Services/WatchSyncService.swift:304` verifies signed ACK before removing pending.
- `Services/WatchSyncService.swift:390-404` marks userInfo as delivered but keeps pending until signed ACK.

### iOS To Watch

iOS direct send semantics are strong, but queued semantics are weaker:

- Direct `sendMessage` verifies signed ACK before removing pending.
- Queued `transferUserInfo` completion calls `markPushedToWatch(id)` and `removeOutboundSession(id:)` when WatchConnectivity delivery completes, without verifying that Watch imported the session and signed an ACK.

This is `MAIN-AUD-001`.

### Tombstones / Deletes

Shared delete key `WatchSyncKeys.deletedSessionIDsKey` is used by both apps. iOS and Watch merge legacy deleted keys. Watch delete offset handling is guarded; iOS offset handling is not.

### Peer Trust

Positive controls:

- Peer-secret pinning exists.
- Changed peer detection exists.
- HMAC signing and signed ACK verification reject unsigned `"acknowledged"` ACKs for dive sync.

Hardening:

- Add replay nonce cache for signed envelopes.
- Sign companion photo management messages, not only dive payloads.

### Duplicate IDs

Duplicate session ID handling exists through normalization/deduplication and conflict detectors. `Dictionary(uniqueKeysWithValues:)` in `DiveSessionMergeConflict.swift` relies on the dedupe invariant and should keep explicit regression coverage.

### Manual / No-Depth Policy

Manual no-depth sessions are explicitly represented and tests exist on both Watch/iOS sync normalization. No manual/no-depth truthfulness bug was confirmed.

## G. Performance Analysis

### CPU

Highest CPU risks:

- Planner recalculation on every `@Published input` mutation.
- Repeated `GasPlanningService.analyze` through computed `analysis`.
- Buhlmann plan updates and cloud saves during rapid picker/stepper/slider interaction.
- Full CSV string parsing, though bounded to 10 MB.

### Memory

Highest memory risks:

- iOS photo preprocessing loads user-selected image bytes into `Data`, decodes to `UIImage`, and only then resizes/reencodes.
- Large planner/equipment payloads can be stored locally in `UserDefaults` before cloud size rejection.
- CSV parser builds whole strings/row arrays, acceptable only because caps are enforced.

### Battery

Watch:

- Timers and haptics are throttled and mostly lifecycle-bound.
- GPS lifecycle looks intentional but requires physical interruption/resume testing.

iOS:

- Repeated WatchConnectivity retransmits are mitigated by queues, but iOS queued delivery semantics need ACK hardening.
- iCloud KVS writes on every planner/equipment mutation can increase background work and energy use.

### SwiftUI Invalidation

Highest risks:

- `PlannerStore.input.didSet` cascades enforce/save/recalculate.
- Views reading `store.analysis` may recompute gas analysis repeatedly.
- `CloudSyncStore.publishDeferred` avoids publishing-during-render faults, but repeated synchronize calls can cause status churn.

## H. Security / Privacy Analysis

### Trust Model

Dive sync trust model is strong:

- Peer secret stored in Keychain.
- HMAC signing.
- Signed ACKs.
- Peer mismatch detection.
- Shared secret publication through application context.

Hardening gaps:

- Queued iOS-to-Watch pending removal bypasses signed ACK.
- Companion photo inventory/delete messages are not signed.
- Replay protection should add nonce/request ID cache to the signed envelope path.

### Cloud Privacy

Positive:

- Logbook backup opt-in is enforced for iOS sessions.
- Protected local logbook files are used.

Risk:

- Generic cloud sync for planner/equipment/deleted IDs stores local data before payload size preflight and uses `UserDefaults`.

### GPS Privacy

Dive sessions may include entry/exit GPS points. Logbook protected file storage helps. Export/share flows must continue to treat GPS as sensitive. No sensitive GPS logging issue was confirmed.

### File Security

Positive:

- Watch active drafts, Watch logbook, iOS logbook, CSV export, and user images mostly use complete file protection.

Risk:

- PDF temp exports use `.atomic` only.
- Temp output cleanup policies need release QA.

### Import / Export

CSV import is bounded and robust for basic malformed input. Subsurface export protection is good. PDF export privacy needs hardening.

### Image Handling

Watch uploaded image storage and filename validation are strong. iOS preprocessing needs byte/dimension preflight before full decode.

### App Intents

Legal gate is present for safety-related App Intents. No bypass found.

### Secret Scan

No hardcoded API keys, tokens, private keys, or Apple credentials were found in MAIN Swift sources during static text scan.

## I. Test Coverage Analysis

### Current Test Targets

| Target | Files | Static test function count |
|---|---:|---:|
| `DIRDiving Watch Algorithm Tests` | 29 | 169 |
| `DIRDiving iOS Algorithm Tests` | 64 | 390 |

### Build/Test Status

Tests were not executed. `xcodebuild` is unavailable in this environment, so no pass/fail/skipped status can be claimed.

### Strong Existing Coverage Areas

- Watch legal acceptance gate and Action Button safety gate.
- Watch haptic throttling and mission mode invariants.
- Watch/iOS sync codec, ACK verification, peer-secret pinning.
- Watch manual no-depth sync.
- iOS Buhlmann NDL, ceilings, gas validation, pressure model, GF comparisons.
- Planner mode policy and switch-depth MOD clamping.
- Cloud backup policy and cloud session merge.
- CSV round trip and PDF export service.
- Photo transfer pipeline and companion photo management basics.

### Missing / Needed Tests

- iOS queued `transferUserInfo` must preserve pending outbound until signed Watch import ACK.
- Companion photo inventory/delete messages should fail closed on missing/invalid HMAC.
- Planner pressure-unit and working-pressure edits must not call MOD reset for gas/PPO2 changes.
- Planner mutation storm performance test with rapid input changes.
- `PlannerView.tableRow` header/value count mismatch crash regression.
- iOS `DiveLogStore.delete(at:)` stale offset guard.
- `CloudSyncStore.save` oversized payload should not leave oversized local `UserDefaults` blob.
- PDF temp export file protection and cleanup test.
- Photo preprocessing rejects oversized bytes/dimensions before full decode.
- Signed envelope replay nonce/cache tests.
- Large CSV import performance test at cap.
- Paired Watch/iPhone sync QA with queued/offline paths.
- iCloud two-device conflict/tombstone QA.
- Physical Watch Ultra underwater depth/GPS/haptic QA.
- External Subsurface import/export regression evidence.

### Simulator QA Plan

1. Generate project with XcodeGen on macOS.
2. Build both MAIN schemes with signing disabled.
3. Run both algorithm test schemes on the requested simulator destinations.
4. Exercise iOS planner mode switching, gas edits, pressure edits, and invalid environment inputs.
5. Exercise Watch manual start/end, draft restore, alarms, haptic toggles, and mock sensor fallback.
6. Exercise CSV import/export and PDF export temp file lifecycle.

### Physical Watch Ultra QA Plan

Pending. Required before external TestFlight or App Store claims:

- Depth sensor availability and submersion callbacks.
- Automatic start/stop thresholds.
- Manual no-depth truthfulness.
- 35/38/40 m safety threshold behavior.
- Haptic intensity/throttle underwater.
- GPS entry/exit behavior and lifecycle stop.
- App background/resume and force quit during finalization.
- Battery behavior during realistic sessions.

### Paired Watch/iPhone QA Plan

Pending:

- Online direct sync both directions.
- Offline queued sync both directions.
- Signed ACK rejection.
- Peer secret mismatch and reset.
- Tombstone propagation.
- Duplicate session ID conflict.
- Companion photo import, inventory, and delete.

### iCloud Two-Device QA Plan

Pending:

- Opt-in logbook backup.
- Opt-out privacy behavior.
- Conflicting edits.
- Tombstone merge.
- KVS payload cap.
- Malformed cloud payload.
- Planner/equipment KVS updates under rapid edits.

### External Subsurface Regression Plan

Pending:

- Import exported CSV into Subsurface.
- Compare timestamps, depth samples, temperatures, notes, GPS, gases, manual/no-depth representation.
- Record Subsurface version, OS, fixture files, and observed diffs.

## J. Issue Matrix

| ID | Severity | Priority | App | Area | File/function | Title | User impact | Security/performance impact | Proposed fix | Effort |
|---|---|---|---|---|---|---|---|---|---|---|
| MAIN-AUD-001 | HIGH | P1 | iOS/Watch | sync, data integrity | `iOSApp/Services/WatchSyncService.swift:934-949` | Queued iOS-to-Watch sync removes pending without signed import ACK | iOS can report sent while Watch never imported session | Data-loss risk; trust model inconsistency | Keep outbound pending after userInfo delivery until signed Watch ACK; add retry/status state | M |
| MAIN-AUD-002 | MEDIUM | P2 | Watch/iOS | security, data integrity | `Services/WatchSyncService.swift:150-214`; `iOSApp/Utils/CompanionPhotoManagementSupport.swift:36-117` | Companion photo management messages are unsigned | Paired companion can request inventory/delete without peer-secret envelope | Hardening gap for image metadata/deletes | Sign inventory/delete request/ack with HMAC, timestamp, request ID replay cache | M |
| MAIN-AUD-003 | MEDIUM | P2 | iOS | privacy, cloud, performance | `iOSApp/Services/CloudSyncStore.swift:136-150` | Oversized generic cloud payload is saved locally before KVS cap check | Large planner/equipment data can remain in UserDefaults | Privacy/storage risk; KVS bloat | Check size before local/cloud write or use protected file storage for generic payloads | S-M |
| MAIN-AUD-004 | MEDIUM | P2 | iOS | privacy, export | `iOSApp/Services/PDF/PDFDocumentBuilder.swift:195-198` | PDF temp exports lack complete file protection | Dive plans/equipment/site info may remain in less protected temp files | Privacy risk | Write with `.completeFileProtection`, use protected export dir, cleanup old files | S |
| MAIN-AUD-005 | MEDIUM | P2 | iOS | performance, crash | `iOSApp/Views/WatchPhotoTransferPanel.swift:180-201`; `iOSApp/Services/WatchPhotoPreprocessor.swift:24-53` | Photo preprocessing decodes arbitrary image data on MainActor before caps | Huge image can freeze/crash transfer UI | Memory/CPU spike | Preflight byte count and image dimensions using ImageIO, offload processing | M |
| MAIN-AUD-006 | MEDIUM | P2 | iOS | planner, UI-state logic | `iOSApp/Views/PlannerCylinderGasEditorView.swift:253-258,419-428`; `iOSApp/Views/PlannerView.swift:610-611` | Pressure-only edits reset switch depth to MOD | User-selected shallower switch depth can be overwritten | Safety/UX confusion; algorithm input drift | Split callbacks: gas/PPO2 changes reset/clamp; pressure changes recalc only | S |
| MAIN-AUD-007 | MEDIUM | P2 | iOS | performance, SwiftUI | `iOSApp/Services/PlannerStore.swift:16-31,110-136` | Planner recalculates and persists on every input mutation | Sliders/pickers can stutter and write repeatedly | CPU, iCloud, battery churn | Debounce UI edits, cache analysis, separate draft mutation from calculation | M |
| MAIN-AUD-008 | LOW | P3 | iOS | crash, concurrency | `iOSApp/Services/DiveLogStore.swift:119-126` | iOS delete offsets are not index-guarded | Stale List offsets during cloud/sync mutation can crash | Low-frequency crash | Mirror Watch guard with `sessions.indices.contains(index)` | S |
| MAIN-AUD-009 | LOW | P3 | iOS | crash, UI-state logic | `iOSApp/Views/PlannerView.swift:2403-2420` | Table row accessibility helper force unwraps header array | Future mismatched header/value arrays can crash result UI | Crash hardening | Use safe indexing or zip headers/values | S |
| MAIN-AUD-010 | LOW | P3 | iOS | cloud, UI-state | `iOSApp/Services/CloudSyncStore.swift:164-183` | Overlapping sync status tasks can clear `isSynchronizing` early | Sync indicator can flicker or lie under rapid saves | UI correctness/perf | Track generation/cancellable sync-status task | S |
| MAIN-AUD-011 | LOW | P4 | iOS | import/export, performance | `iOSApp/Services/DiveImportService.swift:52-80` | CSV import uses full-string parsing | 10 MB file can still allocate heavily | Bounded memory/CPU risk | Stream parse or lower caps; add large fixture perf test | M |
| MAIN-AUD-012 | LOW | P3 | Watch/iOS | security, sync | `WatchDiveSyncCodec`; `WatchSyncService` | Signed sync payloads lack nonce replay cache | Signed recent duplicate payload may be reprocessed/conflicted | Defense-in-depth | Add bounded nonce/request ID replay cache per peer | M |
| MAIN-AUD-013 | HIGH | P1 | build/release | build, tests | Toolchain | XcodeGen/Xcode build/test status unverified | Cannot claim compile readiness | Release blocker | Run exact commands on macOS/Xcode and record results | S |
| MAIN-AUD-014 | HIGH | P1 | Watch/iOS | physical QA, safety | QA process | Physical/external QA evidence is pending | Cannot validate underwater behavior or external export fidelity | Safety/release blocker | Execute Watch Ultra, paired-device, iCloud, Subsurface QA plans | L |
| MAIN-AUD-015 | INFO | P4 | iOS | hardening | `iOSApp/Utils/DiveSessionMergeConflict.swift:29` | `Dictionary(uniqueKeysWithValues:)` relies on dedupe invariant | Low if invariant holds | Trap risk if invariant regresses | Keep duplicate tests; prefer safe dictionary builder | S |
| MAIN-AUD-016 | INFO | P4 | iOS | stale/dead code | `iOSApp/Views/PlannerGasMixCard.swift` | Legacy `GasMixCard` compiles as `EmptyView` alias | Confusing for maintainers/tests | No runtime UI impact if unused | Document/test-only status or remove from MAIN when safe | S |

## Detailed Issue Records

### MAIN-AUD-001 - Queued iOS-to-Watch sync removes pending without signed import ACK

- Severity: HIGH
- Priority: P1
- App: iOS and Watch
- Area: sync, data integrity
- Fix class: security hardening / small functional
- Files/functions: `iOSApp/Services/WatchSyncService.swift:934-949`, `sendOutbound(_:)`, `removeOutboundSession(id:)`; compare Watch `Services/WatchSyncService.swift:304-404`
- Evidence: Direct iOS send verifies `ackSignature` before `removeOutboundSession`. In `session(_:didFinish userInfoTransfer:error:)`, iOS calls `markPushedToWatch(id)` and `removeOutboundSession(id:)` on WatchConnectivity delivery success only. Watch queued transfers only mark `userInfoDeliveredAt` and keep pending until signed ACK.
- User impact: A dive manually added/edited on iOS can disappear from the iOS outbound queue while never appearing on Watch.
- Safety impact: Diver may believe both devices have the same logbook/reference data when they do not.
- Security/privacy impact: Undermines the stated signed ACK trust model for queued iOS-to-Watch sync.
- Performance impact: Retries stop too early; false success prevents repair.
- Proposed fix: Add outbound pending state `deliveredToConnectivityPendingAck`; only remove after Watch returns signed import ACK via direct reply, userInfo ack, or application-context ack. Preserve retries until retention/attempt policy expires.
- Estimated effort: Medium.
- Regression risk: Medium, because sync status UI and retry queues change.
- Tests required: iOS unit test for queued userInfo completion preserving pending; paired simulator test where Watch rejects/misses import; signed ACK success test; retry-retention test.
- Dependencies: Watch must be able to send signed ACK for queued imports.
- Acceptance criteria: No queued iOS outbound session is removed until a signed Watch ACK is verified.

### MAIN-AUD-002 - Companion photo management messages are unsigned

- Severity: MEDIUM
- Priority: P2
- App: Watch and iOS
- Area: security, privacy, data integrity
- Fix class: security hardening
- Files/functions: `Services/WatchSyncService.swift:150-214`, `iOSApp/Services/WatchSyncService.swift:303-349`, `iOSApp/Utils/CompanionPhotoManagementSupport.swift`
- Evidence: Inventory/delete requests are dictionaries keyed by type/request ID/file name. Watch handles delete requests before signed dive-payload parsing and replies with plain `"acknowledged"`.
- User impact: Uploaded Watch reference images can be inventoried/deleted through unsigned management messages from the paired companion path.
- Safety impact: Loss of reference images can affect dive-prep workflows.
- Security/privacy impact: Image metadata and deletion authority are not covered by peer-secret HMAC.
- Performance impact: Minimal.
- Proposed fix: Wrap management requests and ACKs in the same HMAC/timestamp/peer-secret envelope style as dive payloads, with request ID replay cache and explicit stale rejection.
- Estimated effort: Medium.
- Regression risk: Medium for photo transfer/delete UX.
- Tests required: Missing signature rejected, wrong signature rejected, stale request rejected, replay rejected, valid signed delete succeeds.
- Dependencies: Shared signing support between Watch and iOS.
- Acceptance criteria: Unsigned photo management payloads cannot list or delete Watch images.

### MAIN-AUD-003 - Oversized generic cloud payload is saved locally before KVS cap check

- Severity: MEDIUM
- Priority: P2
- App: iOS
- Area: cloud, privacy, performance
- Fix class: security hardening / persistence
- File/function: `iOSApp/Services/CloudSyncStore.swift:136-150`
- Evidence: `save(_:forKey:)` encodes data, writes to `UserDefaults`, then checks `data.count > IOSAlgorithmConfiguration.maxSyncPayloadBytes`.
- User impact: Large planner/equipment state can remain locally even when cloud sync reports payload too large.
- Safety impact: Low direct safety risk, but stale planner state can confuse restoration if oversized data persists.
- Security/privacy impact: Planner/equipment data is stored in `UserDefaults` rather than protected files after cap failure.
- Performance impact: Large defaults payload can slow app startup/sync.
- Proposed fix: Check payload size before any local or cloud write; for generic local persistence, use protected file storage or a capped local fallback.
- Estimated effort: Small to medium.
- Regression risk: Medium for planner/equipment persistence migration.
- Tests required: Oversized payload does not update local defaults; previous valid local payload remains; status reports payload too large.
- Dependencies: Decide whether planner/equipment KVS state should be opt-in or protected-local only.
- Acceptance criteria: Oversized data is neither uploaded nor stored unprotected.

### MAIN-AUD-004 - PDF temp exports lack complete file protection

- Severity: MEDIUM
- Priority: P2
- App: iOS
- Area: privacy, export
- Fix class: security hardening
- File/function: `iOSApp/Services/PDF/PDFDocumentBuilder.swift:195-198`
- Evidence: PDF writer creates `FileManager.default.temporaryDirectory/DIRDivingPDF` and writes with `.atomic` only.
- User impact: Exported plan/equipment PDFs may remain in temp storage after sharing.
- Safety impact: Low.
- Security/privacy impact: PDFs can contain dive plan, gases, equipment, site, and notes data without complete file protection.
- Performance impact: Old temp files can accumulate.
- Proposed fix: Write with `.completeFileProtection`, store in protected app document/cache export folder, and clean stale exports.
- Estimated effort: Small.
- Regression risk: Low.
- Tests required: File attributes include complete protection; stale temp cleanup; share sheet still opens file.
- Dependencies: None.
- Acceptance criteria: PDF exports are protected at rest and old temp files are pruned.

### MAIN-AUD-005 - Photo preprocessing decodes arbitrary image data on MainActor before caps

- Severity: MEDIUM
- Priority: P2
- App: iOS
- Area: performance, crash, image handling
- Fix class: performance optimization / validation
- Files/functions: `iOSApp/Views/WatchPhotoTransferPanel.swift:180-201`, `iOSApp/Services/WatchPhotoPreprocessor.swift:24-53`
- Evidence: `PhotosPickerItem.loadTransferable(type: Data.self)` loads bytes, then `UIImage(data:)`/ImageIO decodes before dimension/byte validation and resizing.
- User impact: Large photo selection can freeze or crash the transfer panel.
- Safety impact: Low direct safety risk.
- Security/privacy impact: Untrusted image bytes are decoded without preflight.
- Performance impact: MainActor CPU and memory spike.
- Proposed fix: Preflight byte count and image metadata dimensions with `CGImageSourceCopyPropertiesAtIndex`; reject huge files before decode; move processing off MainActor where safe.
- Estimated effort: Medium.
- Regression risk: Medium for image compatibility.
- Tests required: Oversized byte rejection, huge-dimension rejection, valid HEIC/JPEG/PNG conversion, memory/performance fixture.
- Dependencies: ImageIO helper.
- Acceptance criteria: Huge images fail fast and UI remains responsive.

### MAIN-AUD-006 - Pressure-only edits reset switch depth to MOD

- Severity: MEDIUM
- Priority: P2
- App: iOS
- Area: planner, UI-state logic, algorithm integration
- Fix class: UI-state fix / small functional
- Files/functions: `iOSApp/Views/PlannerCylinderGasEditorView.swift:253-258`, `iOSApp/Views/PlannerCylinderGasEditorView.swift:419-428`, `iOSApp/Views/PlannerView.swift:610-611`, `iOSApp/Services/PlannerStore.swift:66-72`
- Evidence: Pressure unit and working pressure changes call `onGasOrPressureChanged()`, which `PlannerView` maps to `store.normalizeSwitchDepthAfterGasOrPPO2Change(cylinderID:)`. That method updates changed non-bottom gas switch depth to MOD.
- User impact: A user can set a shallower switch depth and lose it after changing cylinder pressure/unit.
- Safety impact: Planner input intent can drift silently; this is especially confusing for staged gas planning.
- Security/privacy impact: None.
- Performance impact: Extra recalculation/save.
- Proposed fix: Split callbacks into `onGasOrPPO2Changed` and `onPressureChanged`. Only gas/PPO2 composition changes should initialize to MOD; pressure changes should recalculate gas consumption without touching switch depth.
- Estimated effort: Small.
- Regression risk: Medium for planner UI.
- Tests required: Pressure unit/working pressure edit preserves switch depth; oxygen/PPO2 edit still clamps or initializes to MOD; mode projection remains unchanged.
- Dependencies: None.
- Acceptance criteria: Switch depth changes only when gas/PPO2/environment rules require it.

### MAIN-AUD-007 - Planner recalculates and persists on every input mutation

- Severity: MEDIUM
- Priority: P2
- App: iOS
- Area: performance, SwiftUI, cloud
- Fix class: performance optimization
- File/function: `iOSApp/Services/PlannerStore.swift:16-31`, `iOSApp/Services/PlannerStore.swift:110-136`
- Evidence: `@Published var input` didSet enforces limits, saves, and calls `applyInputToPlanningOutputs()`. `analysis` is a computed property that calls `GasPlanningService.analyze(input:mode:)`.
- User impact: Rapid controls can feel laggy and may produce UI stutter.
- Safety impact: Low direct safety risk, but stale/in-flight planner presentations can confuse a reference-only planner.
- Security/privacy impact: More frequent cloud/local writes of planner data.
- Performance impact: Repeated Buhlmann, gas planning, cloud save, and SwiftUI invalidation.
- Proposed fix: Debounce UI-driven edits, cache `analysis`, batch saves, and separate draft editing from explicit calculation for heavy paths.
- Estimated effort: Medium.
- Regression risk: Medium because planner live-preview behavior may change.
- Tests required: Rapid mutation budget test; analysis cache invalidation; no stale result after mode/gas/environment change.
- Dependencies: Planner UX decision on live preview latency.
- Acceptance criteria: Rapid 100-edit sequence stays responsive and performs bounded recalculations/saves.

### MAIN-AUD-008 - iOS delete offsets are not index-guarded

- Severity: LOW
- Priority: P3
- App: iOS
- Area: crash, concurrency
- Fix class: small functional
- File/function: `iOSApp/Services/DiveLogStore.swift:119-126`
- Evidence: `delete(at offsets:)` directly indexes `sessions[index]`. Watch implementation guards `sessions.indices.contains(index)`.
- User impact: Rare crash if SwiftUI delete offsets race with cloud/sync reload.
- Safety impact: Low.
- Security/privacy impact: None.
- Performance impact: None.
- Proposed fix: Add `where sessions.indices.contains(index)` guard like Watch store.
- Estimated effort: Small.
- Regression risk: Low.
- Tests required: Stale out-of-range `IndexSet` does not crash and valid deletes still publish tombstones.
- Dependencies: None.
- Acceptance criteria: Out-of-range offsets are ignored safely.

### MAIN-AUD-009 - Table row accessibility helper force unwraps header array

- Severity: LOW
- Priority: P3
- App: iOS
- Area: crash, UI-state logic
- Fix class: small functional
- File/function: `iOSApp/Views/PlannerView.swift:2403-2420`
- Evidence: `columnHeaders![index]` is used when `columnHeaders != nil`, but there is no `index < columnHeaders!.count` guard.
- User impact: Future helper call with fewer headers than values can crash planner result UI.
- Safety impact: Low.
- Security/privacy impact: None.
- Performance impact: None.
- Proposed fix: Use safe indexing, `zip`, or default to value-only accessibility label when a header is missing.
- Estimated effort: Small.
- Regression risk: Low.
- Tests required: Header/value mismatch renders and has accessibility label.
- Dependencies: None.
- Acceptance criteria: No force unwrap crash path remains.

### MAIN-AUD-010 - Overlapping sync status tasks can clear `isSynchronizing` early

- Severity: LOW
- Priority: P3
- App: iOS
- Area: cloud, UI-state logic, performance
- Fix class: UI-state fix
- File/function: `iOSApp/Services/CloudSyncStore.swift:164-183`
- Evidence: Every `synchronize()` starts a new `Task` that sleeps 0.9 seconds and sets `isSynchronizing = false`.
- User impact: Cloud sync indicator can flicker or report idle while a newer sync is still inside its delay window.
- Safety impact: Low.
- Security/privacy impact: None.
- Performance impact: Minor task churn during rapid saves.
- Proposed fix: Keep a cancellable task or generation token so only the newest sync call clears the flag.
- Estimated effort: Small.
- Regression risk: Low.
- Tests required: Rapid synchronize calls keep status true until final generation completes.
- Dependencies: None.
- Acceptance criteria: `isSynchronizing` reflects the latest sync request.

### MAIN-AUD-011 - CSV import uses full-string parsing

- Severity: LOW
- Priority: P4
- App: iOS
- Area: import/export, performance
- Fix class: performance optimization
- File/function: `iOSApp/Services/DiveImportService.swift`
- Evidence: Import validates size caps but reads/parses the full CSV string and row matrix.
- User impact: A valid near-cap CSV can pause UI/import.
- Safety impact: Low if imported data remains validated.
- Security/privacy impact: Low; malformed input caps exist.
- Performance impact: Bounded memory/CPU overhead.
- Proposed fix: Stream rows or keep full parsing but add performance budget tests and lower cap if needed.
- Estimated effort: Medium.
- Regression risk: Medium if parser changes.
- Tests required: Large CSV fixture at cap; malformed quote/column/row tests; import time budget.
- Dependencies: Parser design.
- Acceptance criteria: Import remains responsive and bounded at configured max size.

### MAIN-AUD-012 - Signed sync payloads lack nonce replay cache

- Severity: LOW
- Priority: P3
- App: Watch and iOS
- Area: security, sync
- Fix class: security hardening
- Files/functions: `WatchDiveSyncCodec`, `WatchSyncService`
- Evidence: Signed payloads validate HMAC and timestamp skew, and duplicate IDs are bounded. No explicit signed envelope nonce/request replay cache was found.
- User impact: Low in paired-device threat model.
- Safety impact: Low to medium if a stale signed payload creates a conflict or overwrites preferred data.
- Security/privacy impact: Defense-in-depth gap.
- Performance impact: Minimal.
- Proposed fix: Add request/nonce field to signed payloads and bounded replay cache per peer.
- Estimated effort: Medium.
- Regression risk: Medium for sync compatibility/migration.
- Tests required: Replay rejected; new nonce accepted; cache bounded; old payload migration strategy.
- Dependencies: Codec versioning.
- Acceptance criteria: Same signed envelope cannot be processed twice inside replay window.

### MAIN-AUD-013 - XcodeGen/Xcode build and test status unverified

- Severity: HIGH
- Priority: P1
- App: build/release
- Area: build, tests
- Fix class: external QA/process
- Files/functions: Toolchain validation
- Evidence: `xcodegen` and `xcodebuild` commands were not recognized in Windows PowerShell.
- User impact: Cannot know whether MAIN compiles or tests pass from this environment.
- Safety impact: Release claims cannot be made.
- Security/privacy impact: Compiler warnings and test failures may be hidden.
- Performance impact: Performance tests not run.
- Proposed fix: Run requested preflight commands on macOS with Xcode/XcodeGen and record exact output.
- Estimated effort: Small once on proper machine.
- Regression risk: None.
- Tests required: Both app builds and both algorithm test schemes.
- Dependencies: macOS/Xcode/XcodeGen/simulators.
- Acceptance criteria: Report updated or attached evidence showing pass/fail summaries.

### MAIN-AUD-014 - Physical/external QA evidence is pending

- Severity: HIGH
- Priority: P1
- App: Watch and iOS
- Area: physical QA, safety, release
- Fix class: external QA/process
- Files/functions: QA gates
- Evidence: No physical Apple Watch Ultra underwater validation, paired-device validation, iCloud two-device validation, or external Subsurface validation was executed in this audit.
- User impact: Real-device behavior remains unknown.
- Safety impact: High for diving-adjacent product positioning.
- Security/privacy impact: Paired sync and cloud privacy behavior need real-world validation.
- Performance impact: Battery and haptic performance unknown on device.
- Proposed fix: Execute and document the QA plans in this report or release dossier.
- Estimated effort: Large.
- Regression risk: None from evidence gathering; fixes discovered may be larger.
- Tests required: Physical Watch Ultra, paired Watch/iPhone, iCloud two-device, external Subsurface import/export.
- Dependencies: Hardware, Apple IDs/iCloud, Subsurface install, test fixtures.
- Acceptance criteria: Every physical/external gate has dated evidence or remains clearly pending.

### MAIN-AUD-015 - `Dictionary(uniqueKeysWithValues:)` relies on dedupe invariant

- Severity: INFO
- Priority: P4
- App: iOS
- Area: hardening
- Fix class: small functional / test-only
- File/function: `iOSApp/Utils/DiveSessionMergeConflict.swift:29`
- Evidence: `Dictionary(uniqueKeysWithValues:)` is called after `DiveSessionCollectionIntegrity.deduplicated`.
- User impact: None while invariant holds.
- Safety impact: None.
- Security/privacy impact: None.
- Performance impact: None.
- Proposed fix: Keep duplicate regression tests and optionally replace with safe dictionary builder for consistency with `DiveLogStore.safeDictionary`.
- Estimated effort: Small.
- Regression risk: Low.
- Tests required: Duplicate local/cloud conflict detection does not trap.
- Dependencies: None.
- Acceptance criteria: Duplicate IDs cannot trap conflict detection.

### MAIN-AUD-016 - Legacy `GasMixCard` compiles as an `EmptyView` alias

- Severity: INFO
- Priority: P4
- App: iOS
- Area: stale/dead code
- Fix class: docs-only or small cleanup
- File/function: `iOSApp/Views/PlannerGasMixCard.swift`
- Evidence: Comment says legacy alias retained for tests; body is `EmptyView()`.
- User impact: None if unused by runtime.
- Safety impact: None.
- Security/privacy impact: None.
- Performance impact: Minimal.
- Proposed fix: Document as test-only compatibility shim or remove from MAIN after test migration.
- Estimated effort: Small.
- Regression risk: Low to medium depending on tests/imports.
- Tests required: Build/test after removal or documentation.
- Dependencies: Test target references.
- Acceptance criteria: Maintainers cannot mistake it for active planner UI.

## K. Detailed Action Plan

### P0

No P0 source-code blocker was confirmed by static review. Build status remains unverified because the toolchain was unavailable.

### P1

1. Address `MAIN-AUD-013`.
   - Files likely involved: none unless build failures appear.
   - Order: install/use XcodeGen and Xcode on macOS; generate project; run Watch/iOS build commands; run Watch/iOS algorithm tests.
   - Risk: low process risk.
   - Tests: exact requested build/test commands.
   - Acceptance: pass/fail summaries captured; no pass claim without actual pass.

2. Address `MAIN-AUD-001`.
   - Files likely involved: `iOSApp/Services/WatchSyncService.swift`, `Services/WatchSyncService.swift`, `WatchDiveSyncCodec`, sync tests.
   - Order: design queued signed ACK path; add pending state; update iOS removal logic; add Watch ack emission; add tests.
   - Risk: medium sync regression risk.
   - Tests: queued/offline direct and userInfo paths, signed/unsigned ACK, retention/retry.
   - Acceptance: queued iOS-to-Watch sessions remain pending until signed Watch import ACK.

3. Address `MAIN-AUD-014`.
   - Files likely involved: QA docs/evidence only unless bugs found.
   - Order: simulator QA, physical Watch Ultra QA, paired sync QA, iCloud QA, Subsurface QA.
   - Risk: none for evidence; discovered bugs may create new work.
   - Tests: physical/external plans.
   - Acceptance: dated evidence or clearly pending status for each gate.

### P2

1. Address `MAIN-AUD-002`.
   - Add signed photo management envelopes and replay cache.
   - Tests: unsigned, wrong signature, replay, stale, valid signed delete/inventory.

2. Address `MAIN-AUD-003`.
   - Move size check before local `UserDefaults` write; consider protected generic storage.
   - Tests: oversized payload does not update local defaults.

3. Address `MAIN-AUD-004`.
   - Apply complete file protection and cleanup to PDF temp exports.
   - Tests: file attributes and share sheet behavior.

4. Address `MAIN-AUD-005`.
   - Add image byte/dimension preflight and off-main processing.
   - Tests: huge-image rejection and valid-image conversion.

5. Address `MAIN-AUD-006`.
   - Split planner pressure callback from gas/PPO2 callback.
   - Tests: pressure edits preserve switch depth; gas/PPO2 edits still clamp.

6. Address `MAIN-AUD-007`.
   - Debounce/batch planner recalculation and persistence.
   - Tests: rapid mutation budget and no stale output.

### P3

1. Address `MAIN-AUD-008`.
   - Guard iOS delete offsets.
   - Tests: stale offset no crash.

2. Address `MAIN-AUD-009`.
   - Safe-index planner table headers.
   - Tests: mismatched header/value arrays.

3. Address `MAIN-AUD-010`.
   - Add sync status generation/cancellable task.
   - Tests: rapid synchronize calls.

4. Address `MAIN-AUD-012`.
   - Add signed payload nonce/replay cache.
   - Tests: replay rejection and cache bounds.

### P4

1. Address `MAIN-AUD-011`.
   - Stream CSV import or add performance budget tests.

2. Address `MAIN-AUD-015`.
   - Keep duplicate-ID tests and consider safe dictionary builder.

3. Address `MAIN-AUD-016`.
   - Document or remove legacy `GasMixCard` shim after test migration.

## L. 7-Day Remediation Plan

| Day | Actions | Expected output | Verification |
|---|---|---|---|
| 1 | Run XcodeGen, app builds, and both algorithm test schemes on macOS | Build/test evidence for `MAIN-AUD-013` | Exact command logs and pass/fail summaries |
| 2 | Fix iOS-to-Watch queued ACK retention (`MAIN-AUD-001`) | Pending queue keeps delivered-pending-ACK state | Unit tests and paired simulator queued sync |
| 3 | Fix planner pressure callback split (`MAIN-AUD-006`) | Pressure edits preserve switch depth | Planner regression tests |
| 4 | Fix PDF file protection and CloudSync oversized preflight (`MAIN-AUD-003`, `MAIN-AUD-004`) | Protected export/local persistence behavior | File attribute and oversized payload tests |
| 5 | Add photo preprocessing preflight (`MAIN-AUD-005`) | Huge images rejected before full decode | Image fixture tests and UI responsiveness check |
| 6 | Add P3 crash/status hardening (`MAIN-AUD-008`, `MAIN-AUD-009`, `MAIN-AUD-010`) | Low-risk crash/status fixes | Unit tests |
| 7 | Run full simulator regression and produce internal TestFlight readiness notes | Updated readiness matrix | Both app builds, both test schemes, manual simulator smoke |

## M. 14-Day Remediation Plan

| Days | Focus | Expected output | Verification |
|---|---|---|---|
| 1-3 | Build/test evidence and `MAIN-AUD-001` sync hardening | Compile/test baseline and queued ACK fix | macOS CI logs, sync tests |
| 4-6 | Privacy/security hardening | Signed photo management, protected PDFs, cloud payload preflight | Security regression tests |
| 7-8 | Planner performance/state cleanup | Debounced/batched planner recalculation | Performance tests and no stale outputs |
| 9-10 | Crash hardening and replay hardening | Safe offsets/headers, nonce replay cache | Unit tests |
| 11-12 | Paired-device and iCloud QA | Real paired and two-device evidence | QA log with screenshots/notes |
| 13 | Physical Watch Ultra QA | Underwater/depth/GPS/haptic evidence | Dated physical QA record |
| 14 | Release review | Updated TestFlight/App Store checklists | No unverified claims; privacy/safety wording reviewed |

## N. Pre-Internal-TestFlight Checklist

- [ ] `xcodegen generate` passes on macOS.
- [ ] `DIRDiving Watch App` builds for watchOS simulator.
- [ ] `DIRDiving iOS` builds for iOS simulator.
- [ ] Watch algorithm tests run and failures are fixed or documented.
- [ ] iOS algorithm tests run and failures are fixed or documented.
- [ ] `MAIN-AUD-001` is fixed.
- [ ] Legal/safety onboarding still blocks safety shortcuts until accepted.
- [ ] Planner Base/Deco/Technical mode projection tests pass.
- [ ] No experimental views/services are included in MAIN targets.
- [ ] No physical QA is claimed as passed unless actually executed.

## O. Pre-External-TestFlight Checklist

- [ ] All internal TestFlight checklist items complete.
- [ ] Paired Watch/iPhone direct and queued sync pass both directions.
- [ ] Signed ACK rejection and peer-secret mismatch scenarios pass.
- [ ] Companion photo import/inventory/delete pass with signed management payloads.
- [ ] iCloud opt-in/off/tombstone/conflict tests pass on two devices.
- [ ] PDF/CSV export privacy behavior verified.
- [ ] Planner rapid-edit performance acceptable.
- [ ] Physical Watch Ultra underwater/depth/haptic/GPS QA completed or external TestFlight withheld.
- [ ] App copy remains non-certified and reference-only.

## P. Pre-App-Store Checklist

- [ ] All external TestFlight checklist items complete.
- [ ] Physical QA evidence archived with device/watchOS/iOS versions.
- [ ] External Subsurface validation executed and documented.
- [ ] Privacy manifest/App Store privacy answers match actual GPS, iCloud, logbook, equipment, image, and export behavior.
- [ ] No certified dive-computer or certified decompression-planner claims.
- [ ] Legal/safety disclaimers are intact and localized.
- [ ] No DEBUG-only or simulation sensor behavior is available in App Store release.
- [ ] Cloud backup opt-in behavior verified.
- [ ] Crash/performance telemetry reviewed from TestFlight.
- [ ] Final `git status` and generated project membership reviewed.

## Q. Recommended Cursor Remediation Commands

Do not execute these during this audit. They are draft future commands.

### 1. Bug / Data-Integrity Fixes

```text
CURSOR COMMAND - DIR DIVING MAIN BUG/DATA-INTEGRITY FIX PASS

Work only on branch main. Do not touch experimental files. Fix MAIN-AUD-001, MAIN-AUD-006, MAIN-AUD-008, MAIN-AUD-009, and MAIN-AUD-010 from Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md. Preserve Watch dive/depth/ascent algorithms, iOS Buhlmann math, TTV semantics, Mission Mode semantics, planner mode architecture, gas-planning semantics, cloud merge policy, WatchConnectivity peer-secret trust model, and legal/safety disclaimers. Add focused regression tests. Run XcodeGen/build/tests on macOS if available. Report exact results.
```

### 2. Performance Optimization Pass

```text
CURSOR COMMAND - DIR DIVING MAIN PERFORMANCE OPTIMIZATION PASS

Work only on branch main. Do not alter algorithms or planner semantics. Address MAIN-AUD-005, MAIN-AUD-007, and MAIN-AUD-011. Add image preflight, planner recalculation batching/caching, and import performance tests without changing reference-only planner outputs. Preserve UI identity and all safety copy. Record before/after performance evidence where possible.
```

### 3. Security Hardening Pass

```text
CURSOR COMMAND - DIR DIVING MAIN SECURITY/PRIVACY HARDENING PASS

Work only on branch main. Address MAIN-AUD-002, MAIN-AUD-003, MAIN-AUD-004, and MAIN-AUD-012. Do not weaken the existing HMAC/peer-secret model. Extend signing to companion photo management payloads, add replay cache hardening, protect PDF exports, and prevent oversized generic cloud payloads from being stored unprotected. Add negative security tests and document any migration behavior.
```

### 4. Test Coverage Pass

```text
CURSOR COMMAND - DIR DIVING MAIN TEST COVERAGE PASS

Work only on branch main. Add missing tests identified in the audit report: queued iOS-to-Watch signed ACK retention, photo management HMAC rejection, planner pressure-edit switch-depth preservation, CloudSync oversized payload, PDF file protection, image preflight limits, stale delete offsets, table header mismatch, replay cache, large CSV performance, paired sync QA documentation hooks, and physical QA evidence checklist docs. Do not modify production logic except where a test exposes an existing confirmed bug and the user explicitly approves fixes.
```

## R. Final Verdict

### Is The Code Ready To Compile?

Unknown in this environment. Static review did not find an obvious compile blocker, but `xcodegen` and `xcodebuild` were unavailable, so compile readiness cannot be claimed.

### Is It Safe For Internal TestFlight?

Not yet. Internal TestFlight should wait for macOS build/test evidence and remediation of `MAIN-AUD-001`.

### Is It Safe For External TestFlight?

Not yet. External TestFlight should wait for paired Watch/iPhone QA, iCloud two-device QA, privacy/security hardening, and physical Watch Ultra evidence.

### Is It Ready For App Store?

No. App Store readiness is blocked by unverified build/test status, physical/external QA, privacy hardening, sync ACK asymmetry, and final App Store safety/privacy wording review.

### What Blocks 100% Code Readiness?

- `MAIN-AUD-001` queued sync ACK/data-integrity gap.
- `MAIN-AUD-006` planner switch-depth state bug.
- P2 privacy/performance hardening.
- Unverified Xcode build/test status.

### What Blocks 100% Security Readiness?

- Unsigned companion photo management messages.
- Lack of signed-payload nonce replay cache.
- Generic cloud local payload writes before size preflight.
- PDF temp exports without complete file protection.

### What Blocks 100% Performance Readiness?

- Planner mutation/recalculation storm risk.
- Photo preprocessing memory spike risk.
- Full-string CSV parsing at cap.
- Cloud sync status/write churn during rapid mutations.

### What Must Be Fixed First?

Fix and test `MAIN-AUD-001` first, then obtain macOS build/test evidence (`MAIN-AUD-013`). Without those two, MAIN cannot be honestly marked ready for internal TestFlight.

## Validation Notes

Post-report validation to perform after file creation:

- Confirm report file exists.
- Confirm report file is non-empty.
- Confirm issue matrix exists.
- Confirm detailed action plan exists.
- Confirm no source code files were modified.
- Confirm `git status` only shows this new report file.
- Confirm no experimental files were touched.

Physical/external QA status: pending, not passed.
