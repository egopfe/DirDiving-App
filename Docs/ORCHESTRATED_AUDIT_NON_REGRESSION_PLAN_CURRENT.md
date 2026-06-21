# Orchestrated Audit Non-Regression Plan — Current

## 1. Required build gates

Run on macOS at the remediation commit:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

## 2. Required full test gates

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Use the closest installed devices only if documented; do not silently change coverage.

## 3. Focused safety suites

Required existing/future suites include:

- Bühlmann core: `BuhlmannEngineCanonicalConsistencyTests`, pressure/model tests, mutation resistance, N2/He constants, Haldane/Schreiner parity.
- **New altitude gate:** signed package activation, invalid/future environment, independent ISA formula, all 16 N2/He compartments at 0/500/1,000/1,500/2,000/4,500 m, fresh/salt, Air/Nitrox/Trimix, checkpoint/restore, gas switch, clear/re-descent, Watch/iOS parity.
- Audit 15: `Audit15Air39MultilevelProfileTests`, `Audit15MultilevelOracleProfilesTests`, `Audit15RedescentOracleTests`, `Audit15TTSScheduleOracleSweepTests`, timing faults, schedule and stop-state tests.
- Full Computer runtime/deco: startup fail-closed, actual-dt, stale/out-of-order samples, gas-switch ordering, unavailable gas, deco-stop state machine, recovery and logbook metadata.
- Gauge: depth validation, time-weighted average, max/ascent/TTV isolation, lifecycle and alarms.
- Apnea: lifecycle/recovery/start gating, suspend/restore, targets/markers, logbook and sync.
- Snorkeling: sensor/GPS ingestion, route/bearing/return, dips, persistence, privacy/export, sync.
- Ownership: Watch/iOS activity routing, six forbidden logbook routes, Settings isolation, sequential cross-activity flows.
- Sync/security: cross-decode rejection, envelopes, schema/revision, HMAC/signed ACK, nonce/replay, trust reset, large payload, tombstones, conflicts, malformed/future data.
- Persistence/export: migrations, backup/restore isolation, file protection, CSV/PDF/Subsurface, privacy redaction.
- Localization/accessibility/visual: key parity, forbidden terminology, Dynamic Type/VoiceOver contracts, snapshots, mockup anti-embedding, claims policy.

## 4. Repository readiness scripts

```bash
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
./Scripts/validate_watch_math_readiness.sh
./Scripts/validate_ios_complete_algorithm_readiness.sh
./Scripts/validate_ui_ux_main_readiness.sh
./Scripts/validate_main_deep_code_readiness.sh
./Scripts/validate_activity_architecture_settings_logbook_readiness.sh
./Scripts/validate_multi_activity_sync_persistence_schema_readiness.sh
./Scripts/validate_security_privacy_trust_readiness.sh
./Scripts/validate_performance_concurrency_battery_readiness.sh
./Scripts/validate_test_qa_evidence_readiness.sh
./Scripts/validate_release_legal_claims_readiness.sh
./Scripts/validate_mockup_visual_regression_readiness.sh
./Scripts/validate_watch_live_buhlmann_schreiner_multilevel_readiness.sh
```

Add a dedicated altitude readiness script only after the independent tests exist. Normalize scanner paths before relying on Windows results.

## 5. Static scans

```bash
rg -n "COMPASSO" .
rg -n "certified|certificazione|medical|guaranteed|safe route|blackout|rescue" Docs Shared Services Models Views iOSApp Resources Tests
rg -n "DiveManager|DiveLogStore|ApneaSessionEngine|Snorkeling|FullComputerRuntimeEngine|ExplorationStore" Shared Services Models Views Tests
rg -n "fullComputerPlanPackage|apneaSyncPlanPackage|dirdiving_apnea_session|dirdiving_snorkeling|dirdiving_dive_session" .
rg -n "TODO|FIXME" Shared Services Models Views iOSApp Tests Docs Scripts
```

Review every match. Prohibition text, tests, history, and excluded experimental files are not production findings by themselves.

Add altitude-focused scans:

```bash
rg -n "plannerEnvironment|altitudeMeters|surfacePressureBar|seaLevelSaltWater" Shared Services Utils Views iOSApp Tests
rg -n "FullComputerRuntimePlan\(profile:|FullComputerGasProfile\(importing:" Services Shared Utils Tests
```

## 6. Acceptance invariants for ORCH-001

- An imported environment is validated before activation.
- Watch Full Computer Settings accepts and validates a manual Altitude/Environment source.
- Full Computer startup at detected elevation obtains a sensor measurement and presents it as a proposal requiring confirmation.
- A sensor proposal never silently overwrites an imported iPhone plan or Watch manual value.
- There is no explicit sea-level option and no implicit sea-level fallback; a validated source may resolve naturally to near-zero altitude.
- No live Full Computer plan can omit an explicit environment.
- Source disagreements beyond tolerance require explicit resolution or fail closed.
- Environment is immutable during an active dive.
- All calculations, UI, checkpoint, restore, logbook, sync, and export agree bit-for-bit or within documented serialization tolerance.
- Missing/corrupt/future environment fails closed and never becomes “no deco.”
- Legacy records remain explicitly unknown.
- Independent oracle absolute/relative tolerances are documented per output.

## 7. Physical QA gates

Remain PENDING until evidence is attached:

- Apple Watch Ultra underwater; depth entitlement; Water Lock; wet/glove; sensor fail/recovery.
- 41/45/49 mm critical-state screenshots, VoiceOver, haptics-off, Dynamic Type/contrast.
- Paired iPhone/Watch sync/trust/reset/retry/replay/conflict/large payload.
- Long Dive Full Computer, Apnea cycles, Snorkeling GPS, low battery, thermal, background/resume.
- iOS supported-device matrix, PDF/share, privacy permissions, location/photo/export.
- External Bühlmann/CCR altitude and multilevel validation; Subsurface round trip; legal/certification/App Store review.

No physical or external gate may be inferred from simulator/unit evidence.
