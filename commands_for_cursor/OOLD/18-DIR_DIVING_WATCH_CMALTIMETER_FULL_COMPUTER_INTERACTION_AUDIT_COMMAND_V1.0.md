# 18 — DIR DIVING WATCH CMALTIMETER / FULL COMPUTER INTERACTION AUDIT COMMAND V1.0

**Command version:** 1.0
**Updated:** 2026-06-21
**Repository:** `egopfe/DirDiving-App`
**Required branch:** `main`
**Primary target:** `DIRDiving Watch App`
**Task type:** audit-only, read-only, safety-critical
**Suggested sequence:** after Commands `01W` and `15`, before Commands `12` and `13`

---

# 0. ABSOLUTE EXECUTION RULE

Audit the production implementation exactly as it exists. Do not modify production code, tests, project configuration, localization, assets, documentation outside the required audit outputs, or Git history. Do not commit or push.

The only permitted writes are the four reports required by this command. If a defect is found, record it as an open finding with a concrete remediation and acceptance test; do not fix it during this audit.

Never claim physical sensor validation from simulator evidence. Never infer that Apple Watch continuously supplies an app with absolute altitude merely because the hardware sensor is described as always available. Prove the app's actual subscription, callback, validation, acceptance, and Full Computer propagation path.

If macOS, Xcode, a compatible Apple Watch, required permissions, or a safe physical test location is unavailable, mark the corresponding evidence `NOT_EXECUTED` or `PENDING_PHYSICAL`. Do not convert missing evidence into a pass.

---

# 1. OBJECTIVE

Determine whether the Apple Watch Full Computer obtains a fresh absolute-altitude value directly from Core Motion immediately before dive startup, treats it only as an explicit user-confirmed proposal, converts it into the correct surface environment, freezes that environment for the dive, and applies it consistently to every Bühlmann/Schreiner calculation and persisted result.

Audit this complete chain:

```text
Apple Watch hardware capability
-> CMAltimeter.isAbsoluteAltitudeAvailable()
-> retained CMAltimeter instance
-> startAbsoluteAltitudeUpdates(to:withHandler:)
-> CMAbsoluteAltitudeData altitude / accuracy / precision / timestamp
-> sample validation and stable-window selection
-> pending Watch sensor proposal
-> explicit diver acceptance or rejection
-> canonical Full Computer environment record
-> derived local surface pressure and water density
-> confirmed immutable runtime plan
-> initial equilibrium of all 16 N2 and all 16 He compartments
-> second-by-second Haldane/Schreiner updates
-> GF ceiling / NDL / TTS / decompression schedule / stop state
-> checkpoint / restore / completed-dive logbook metadata
```

The audit must answer both questions independently:

1. Is the sensor acquisition path correct, fresh, deterministic, cancellable, and fail-safe?
2. Does the accepted value materially and correctly affect the Full Computer from initialization through completion, without silent fallback or active-dive mutation?

---

# 2. REQUIRED PRODUCT POLICY

Evaluate the implementation against this exact source policy:

1. **Imported from iPhone Plan:** preserve and validate the complete signed plan environment.
2. **Manually entered on Watch:** provide an Altitude/Environment setting on Watch and validate it before use.
3. **Sensor-measured proposal:** directly sample the Watch absolute-altitude sensor immediately before Full Computer confirmation, then require explicit acceptance.
4. **No explicit sea-level option:** do not expose or silently inject a sea-level choice or default. A validated source may naturally measure or contain approximately zero metres.

The sensor proposal must never silently overwrite an imported iPhone Plan or a manually entered Watch environment. If values disagree beyond a documented tolerance, the diver must see the source and value, choose explicitly, and have that decision recorded.

---

# 3. SEVERITY MODEL

Classify findings by worst credible effect:

- **P0:** incorrect or unvalidated altitude/surface pressure can authorize Full Computer start, initialize tissues incorrectly, corrupt decompression guidance, produce a false no-decompression state, or change the environment during an active dive.
- **P1:** sensor data can silently replace another source; stale, inaccurate, unstable, or mismatched data can become authoritative; restore changes the environment; or required runtime/logbook propagation is incomplete.
- **P2:** failures are safe but diagnostics, source visibility, accessibility, lifecycle handling, test coverage, or evidence is incomplete.
- **P3:** maintainability, duplication, naming, observability, or non-safety UX weakness.
- **P4:** cosmetic or editorial defect with no credible behavioral consequence.

Any unresolved P0 means the audit verdict is `FAIL`. Missing physical-Watch evidence prevents `PASS` and requires at least `PARTIAL`.

---

# 4. AUTHORITATIVE REFERENCES

Use current primary sources only and record exact URLs and access dates:

- Apple `CMAltimeter` documentation;
- `CMAltimeter.isAbsoluteAltitudeAvailable()`;
- `CMAltimeter.startAbsoluteAltitudeUpdates(to:withHandler:)`;
- `CMAbsoluteAltitudeData` and inherited `CMLogItem.timestamp` semantics;
- Apple platform availability and permission/privacy documentation;
- the Bühlmann/Schreiner references already accepted by the repository's independent oracle documentation.

Do not treat blog posts, forum answers, generated summaries, or the production implementation itself as an independent authority.

---

# 5. PREFLIGHT AND BASELINE

Run and record:

```bash
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --short
git fetch --prune origin
git rev-list --left-right --count HEAD...origin/main
gh auth status
```

Requirements:

- branch is exactly `main`;
- local `HEAD`, `origin/main`, and GitHub `main` are identical;
- worktree is clean before report generation;
- commit SHA, Xcode version, watchOS SDK, simulator/device model, watchOS version, and test date are recorded.

Stop and report `BASELINE_INVALID` if code is behind, diverged, or dirty. Do not audit a mixed or stale checkout.

---

# 6. PHASE A — TARGET MEMBERSHIP, ENTITLEMENTS, AND PRIVACY

Prove from `project.yml`, generated Xcode project membership, build logs, and source imports that:

- `Services/FullComputerEnvironmentSensorService.swift` is compiled into the production Watch target;
- `CoreMotion.framework` is linked to the production Watch target and relevant test target;
- the Watch deployment target supports the absolute-altitude API;
- the required motion usage description is present in the effective Watch `Info.plist`;
- the service is not experimental, dead code, test-only, or shadowed by another implementation;
- no iOS-only altitude provider accidentally supplies the live Watch Full Computer path.

Search every altitude source:

```bash
rg -n "CMAltimeter|CMAbsoluteAltitudeData|startAbsoluteAltitudeUpdates|startRelativeAltitudeUpdates|CLLocationManager|location\.altitude|altitudeMeters|surfacePressureBar" App Services Shared Utils Views iOSApp Tests project.yml
```

Classify every match as production authority, proposal input, derived value, display-only value, test fixture, reference oracle, or prohibited fallback.

---

# 7. PHASE B — CORE MOTION API AND OBJECT LIFETIME

Inspect `AppleWatchAbsoluteAltitudeProvider` and every caller. Prove:

- availability is checked with `CMAltimeter.isAbsoluteAltitudeAvailable()` before subscription;
- one retained `CMAltimeter` instance survives for the entire asynchronous sampling operation;
- the absolute API is used, not relative-altitude updates or cached GPS elevation;
- callbacks execute on a documented queue and cross actor boundaries safely;
- each callback handles both `data` and `error` correctly;
- `stopAbsoluteAltitudeUpdates()` is called on success, error, timeout, cancellation, view exit, and replacement by a new request;
- callbacks arriving after cancellation or after a newer request cannot contaminate the new request;
- repeated starts, rapid navigation, re-entry, and deallocation cannot leak a subscription or leave an orphan timeout task;
- the provider does not assume availability means a sample is guaranteed.

Explicitly audit whether request identity or generation tracking is required to reject late callbacks from a previous subscription.

Document the exact lifecycle state machine and all legal/illegal transitions.

---

# 8. PHASE C — SAMPLE SEMANTICS, QUALITY, AND FRESHNESS

For every `CMAbsoluteAltitudeData` field used, document:

- unit;
- reference frame;
- sign convention;
- accuracy meaning;
- precision meaning;
- sensor timestamp meaning;
- conversion, rounding, clamping, and storage behavior.

Do not assume callback receipt time is equivalent to sensor measurement time. Compare the production freshness logic with `CMLogItem.timestamp` and determine whether wall-clock changes, suspension, delayed delivery, or queued callbacks can make stale data appear fresh.

Audit the complete sampling policy, including current values for:

- required sample count;
- maximum accepted accuracy;
- maximum stable spread;
- timeout;
- selection statistic such as median;
- supported altitude range;
- sensor record maximum age.

For each threshold require provenance, safety rationale, units, boundary tests, and conservative behavior. A constant existing in code is not evidence that the value is appropriate.

Test or inspect behavior for:

- NaN and infinity;
- negative accuracy or precision;
- missing data without an error;
- provider error before and after valid samples;
- isolated spikes;
- slow drift;
- oscillating unstable windows;
- five individually accurate but mutually inconsistent samples;
- repeated identical samples;
- below-sea-level values when supported;
- exactly zero and near-zero values;
- minimum and maximum supported altitude;
- just outside the supported range;
- delayed callbacks after timeout;
- wall-clock change during sampling;
- app suspension and resumption.

The audit must not declare the current threshold values safe without independent justification or physical evidence.

---

# 9. PHASE D — PROPOSAL STATE MACHINE AND USER AUTHORITY

Trace these symbols and their state transitions:

```text
FullComputerEnvironmentSensorState
FullComputerEnvironmentSensorService.requestProposal
FullComputerPrediveConfigurationStore.pendingSensorProposal
proposeSensorEnvironment
acceptPendingSensorProposal
dismissPendingSensorProposal
draftEnvironment
confirmedEnvironment
```

Prove:

- starting measurement clears only an obsolete pending proposal, not the imported/manual authority;
- a valid sensor window creates a pending proposal and does not mutate `draftEnvironment`;
- only explicit acceptance promotes the proposal;
- rejection/"Keep current" preserves the prior value and source exactly;
- acceptance is revalidated at the moment of promotion;
- start/review controls remain blocked while sampling or while a proposal is unresolved;
- missing current environment plus rejected/unavailable sensor remains fail-closed;
- sensor, manual, and imported values display source, altitude, and relevant quality/conflict information;
- automatic UI lifecycle events cannot count as acceptance;
- double taps, Digital Crown input, view transitions, and accessibility actions cannot bypass the gate.

Create a transition table with state, event, guard, next state, environment mutation, UI state, and expected evidence.

---

# 10. PHASE E — CANONICAL ENVIRONMENT VALIDATION

Audit `FullComputerEnvironmentRecord` and `PlannerEnvironment` end to end.

Prove that an accepted sensor value produces one internally consistent record containing or deriving:

```text
schemaVersion
altitudeMeters
surfacePressureBar
salinity
waterDensityKgPerM3
environmentSource
capturedAt
sensorAccuracyMeters
sensorPrecisionMeters
```

Verify:

- altitude is finite and in the documented supported range;
- local surface pressure is derived with the intended atmospheric model and independently cross-checked;
- surface pressure is not silently fixed to sea level;
- water density agrees with salinity;
- future schema versions are rejected for live start;
- sensor records require complete, finite, acceptable quality metadata;
- stale sensor records are rejected at every live-start boundary, not only when first proposed;
- imported/manual records are not incorrectly subjected to sensor-only metadata rules;
- serialization and decoding of older records cannot create an authorized but incomplete sensor environment.

Use an independent implementation or hand-checkable reference values for altitude-to-surface-pressure conversion. Do not use production `AmbientPressureModel` as its own oracle.

---

# 11. PHASE F — FULL COMPUTER STARTUP INTERACTION

Build a symbol-level call graph from the accepted proposal to engine creation:

```text
predive Settings / Confirmation
-> accepted environment record
-> commitConfirmedProfile
-> FullComputerRuntimePlan
-> FullComputerPrediveReadiness
-> DiveManager Full Computer start
-> FullComputerRuntimeEngine.init(plan:sessionStart:)
```

Prove:

- every live `FullComputerRuntimeEngine` initializer and `canStart` call receives an explicit runtime plan;
- no default `.seaLevelSaltWater`, default runtime plan, cached planner environment, or legacy unknown source can authorize start;
- the profile and environment are committed atomically enough to prevent a mixed gas/environment start;
- the confirmed record used for logbook provenance is the same environment used by the runtime plan;
- start revalidates freshness and internal consistency immediately before engine creation;
- accepted sensor altitude is frozen when the dive starts;
- no later altimeter callback, Watch setting change, iPhone sync, or UI update can mutate the active environment.

Search mandatory startup risks:

```bash
rg -n "FullComputerRuntimeEngine\(|FullComputerRuntimeEngine\.canStart|FullComputerRuntimePlan\(|seaLevelSaltWater|legacyUnknown|runtimePlan\(\)" Services Shared Utils Views Tests
```

Classify every live call path and every default.

---

# 12. PHASE G — BÜHLMANN / SCHREINER MATHEMATICAL EFFECT

Prove that the frozen surface environment materially feeds:

- local surface ambient pressure;
- depth-to-absolute-pressure conversion;
- inspired N2 and He partial pressure;
- initial equilibrium for all 16 N2 compartments;
- initial equilibrium for all 16 He compartments;
- constant-depth Haldane updates;
- ascent/descent Schreiner updates;
- gradient-factor ceiling;
- controlling compartment;
- NDL;
- TTS;
- decompression schedule;
- decompression stop state machine;
- gas-switch calculations;
- surfacing criterion.

Verify altitude is applied exactly once. Reject both patterns:

- tissues initialized at sea level and switched to altitude later;
- altitude-adjusted surface pressure added again to a pressure that already includes it.

Run independent-oracle comparisons at representative supported altitudes, including near zero, 500 m, 1,000 m, 1,500 m, 2,000 m, and the maximum supported altitude. Include Air and at least one helium-containing profile, multilevel ascent/descent, gas switches, NDL-to-deco transition, and checkpoint restore.

For every comparison record all 16 N2 and He tissue pressures, ceiling, controller, NDL, TTS, schedule, absolute error, relative error, tolerance provenance, and result.

---

# 13. PHASE H — PERSISTENCE, RESTORE, AND LOGBOOK

Trace:

```text
FullComputerPrediveConfigurationStore persistence
FullComputerRuntimeCheckpoint
DiveManager checkpoint/restore
FullComputerRuntimeLogbookAccumulator
FullComputerDiveLogbookMetadata
```

Prove that:

- the accepted sensor record survives the intended pre-dive persistence boundary with source, timestamp, accuracy, and precision;
- checkpoint/restore preserves the exact active runtime altitude, surface pressure, salinity, density, and decompression state;
- restore cannot substitute the current sensor reading, current Watch setting, sea level, or a newly imported plan;
- completed-dive metadata matches the frozen runtime environment, not a later store value;
- logbook source and sensor-quality metadata are preserved when available;
- old-schema records fail safely or migrate explicitly without inventing sensor provenance;
- export and sync do not mislabel a manual/imported value as measured.

Include relaunch, corrupt checkpoint, missing environment, future schema, stale stored sensor record, and storage write failure.

---

# 14. PHASE I — FAILURE, CONCURRENCY, AND FAIL-CLOSED BEHAVIOR

Create a failure-injection matrix covering:

- absolute altitude unavailable;
- permission/privacy denial where applicable;
- Core Motion callback error;
- timeout with no data;
- inaccurate-only data;
- unstable-only data;
- valid samples followed by error;
- cancellation before first sample;
- cancellation after partial window;
- cancellation concurrent with final sample;
- two rapid `requestProposal` calls;
- late callback from the first request during the second request;
- settings-to-confirmation navigation race;
- confirmation view dismissal;
- app background/suspension/relaunch;
- clock discontinuity;
- corrupt persisted proposal;
- active-dive attempt to change altitude;
- sensor value outside model range;
- missing sensor metadata;
- derived pressure/density mismatch.

For each case record expected state, actual state, whether start is enabled, which environment remains authoritative, displayed diagnostic, subscription cleanup, persistence effect, and severity.

Any error path that becomes "sea level", "no deco", zero ceiling, zero TTS, or an authorized legacy environment is P0.

---

# 15. PHASE J — AUTOMATED TEST FORENSICS

Inspect all relevant tests, especially:

```text
Tests/WatchAlgorithmTests/OrchestratedAltitudeEnvironmentTests.swift
Tests/WatchAlgorithmTests/FullComputerRuntimeEngineTests.swift
Tests/WatchAlgorithmTests/FullComputerRecoveryCheckpointTests.swift
Tests/WatchAlgorithmTests/FullComputerReleaseHardValidationTests.swift
Tests/WatchAlgorithmTests/FullComputerTargetMembershipTests.swift
Tests/WatchAlgorithmTests/FullComputerUIStateMatrixTests.swift
Tests/WatchAlgorithmTests/Support/IndependentBuhlmannOracle.swift
```

Require deterministic injected-provider coverage for every Phase C, D, and I boundary. Verify tests assert both state and absence of forbidden mutation. A test that merely observes a pending proposal is insufficient if it does not prove the prior environment remains intact.

Check test quality for:

- production code actually compiled into the test target;
- fake provider behavior matching asynchronous lifecycle semantics;
- fixed dates for freshness boundaries;
- timeout tests without real-time flakiness;
- late-callback/request-generation tests;
- independent oracle isolation from production pressure/tissue code;
- exact boundary values and one-unit-beyond cases;
- all 16 N2/He compartments;
- mutation-resistance tests that fail when altitude propagation is removed.

Report every untested requirement as a gap. Do not add tests during this audit.

---

# 16. PHASE K — MACOS BUILD AND TEST GATES

On macOS with the repository's supported Xcode, regenerate the project and run the exact production/test targets:

```bash
xcodegen generate
xcodebuild build \
  -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination "generic/platform=watchOS Simulator" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

xcodebuild test \
  -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination "platform=watchOS Simulator,name=<available device>"
```

Also inspect the GitHub Actions run for the audited commit. Separate:

- altimeter/Full Computer failures caused by the audited path;
- unrelated pre-existing failures;
- skipped tests;
- simulator limitations.

Record commands, destinations, test count, failures, skips, duration, and logs. A build that fails before the relevant sources compile is not evidence for this feature.

---

# 17. PHASE L — PHYSICAL APPLE WATCH QA

Execute on at least one production-supported physical Apple Watch and record model, sensor capability, watchOS version, app commit, pairing state, permissions, location, weather/pressure context, and reference instrument/source.

Mandatory scenarios:

1. validated near-zero elevation;
2. safely accessible elevated location;
3. sensor unavailable or denied if reproducible;
4. stable measurement accepted;
5. stable measurement rejected while preserving manual value;
6. imported iPhone Plan preserved against a different sensor proposal;
7. app background/foreground during sampling;
8. rapid Settings/Confirmation navigation;
9. relaunch before dive start;
10. completed controlled dry-run/simulation proving the accepted environment reaches runtime and logbook without real decompression exposure.

Compare sensor proposal with a documented independent elevation/reference and record observed spread, accuracy metadata, time to stable proposal, timeout behavior, and UI state. Do not claim geodetic accuracy from a single consumer reference or simulator.

Real underwater decompression exposure is not required and must not be created for audit purposes. Use safe dry-run, simulation, chamber, or reference replay evidence for decompression-state interaction as appropriate.

---

# 18. REQUIRED OUTPUTS

Create or replace only:

```text
Docs/WATCH_CMALTIMETER_FULL_COMPUTER_INTERACTION_AUDIT_CURRENT.md
Docs/WATCH_CMALTIMETER_REQUIREMENT_TRACEABILITY_CURRENT.csv
Docs/WATCH_CMALTIMETER_FAILURE_INJECTION_MATRIX_CURRENT.csv
Docs/WATCH_CMALTIMETER_PHYSICAL_QA_MATRIX_CURRENT.csv
```

The main report must contain:

1. executive verdict;
2. baseline and environment;
3. authoritative references;
4. production target/call graph;
5. Core Motion lifecycle analysis;
6. sample-quality/freshness analysis;
7. proposal state machine;
8. canonical environment validation;
9. Full Computer startup propagation;
10. Bühlmann/Schreiner mathematical effect;
11. persistence/restore/logbook analysis;
12. failure and concurrency analysis;
13. automated evidence review;
14. macOS build/test evidence;
15. physical-Watch evidence;
16. findings ordered P0 through P4;
17. remediation plan for every finding;
18. residual risks and release blockers.

Every claim must cite file and line, test/log evidence, official reference, or physical evidence. Mark inference explicitly.

---

# 19. REQUIRED ANSWERS

The report must answer explicitly:

1. Is production using `CMAltimeter.startAbsoluteAltitudeUpdates` directly on Watch?
2. Is the altimeter retained for the complete asynchronous operation?
3. Can an old callback contaminate a newer request?
4. Is sensor measurement time distinguished safely from callback receipt time?
5. Are accuracy, precision, stability, sample count, timeout, range, and freshness justified and enforced?
6. Does the proposal remain non-authoritative until explicit acceptance?
7. Can rejection preserve imported/manual authority exactly?
8. Can sampling or an unresolved proposal be bypassed to start Full Computer?
9. Is sea level absent as both an explicit choice and an implicit fallback?
10. Is surface pressure independently and correctly derived from accepted altitude?
11. Are salinity and water density consistent with the frozen environment?
12. Does start revalidate the sensor record immediately before engine creation?
13. Are all live runtime plans explicit and free of sea-level defaults?
14. Are all 16 N2 compartments initialized and updated with the altitude-aware environment?
15. Are all 16 He compartments initialized and updated with the altitude-aware environment?
16. Are ceiling, NDL, TTS, schedule, stop state, gas switching, and surfacing altitude-aware?
17. Is altitude applied exactly once?
18. Can the environment change during an active dive?
19. Does checkpoint/restore preserve the exact runtime environment?
20. Does completed-dive logbook metadata preserve source, timestamp, accuracy, and precision?
21. Do failures remain fail-closed without false no-decompression output?
22. Do deterministic tests cover unavailable/error/timeout/inaccurate/unstable/stale/cancel/late-callback paths?
23. Does the production Watch target compile with the service included?
24. Has the real sensor path been proven on physical supported Apple Watch hardware?
25. What specifically blocks 100% readiness?

For each `NO`, `PARTIAL`, or `UNKNOWN`, provide severity, root cause, affected symbols, credible impact, exact remediation, regression tests, and acceptance evidence.

---

# 20. FINAL VERDICT

Print exactly:

```text
WATCH_CMALTIMETER_FULL_COMPUTER_AUDIT: PASS / PARTIAL / FAIL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
PRODUCTION_TARGET_MEMBERSHIP: PASS / FAIL
CORE_MOTION_ABSOLUTE_ALTITUDE_API: PASS / FAIL
ALTIMETER_LIFECYCLE_AND_CANCELLATION: PASS / FAIL
LATE_CALLBACK_ISOLATION: PASS / FAIL
SAMPLE_QUALITY_AND_FRESHNESS: PASS / FAIL
EXPLICIT_SENSOR_PROPOSAL_ACCEPTANCE: PASS / FAIL
IMPORTED_AND_MANUAL_SOURCE_PRESERVATION: PASS / FAIL
NO_EXPLICIT_OR_IMPLICIT_SEA_LEVEL: PASS / FAIL
CANONICAL_ENVIRONMENT_VALIDATION: PASS / FAIL
SURFACE_PRESSURE_DERIVATION: PASS / FAIL
FULL_COMPUTER_STARTUP_PROPAGATION: PASS / FAIL
ALL_16_N2_COMPARTMENTS_ALTITUDE_AWARE: PASS / FAIL
ALL_16_HE_COMPARTMENTS_ALTITUDE_AWARE: PASS / FAIL
NDL_TTS_CEILING_SCHEDULE_ALTITUDE_AWARE: PASS / FAIL
ACTIVE_DIVE_ENVIRONMENT_IMMUTABLE: PASS / FAIL
CHECKPOINT_RESTORE_ENVIRONMENT: PASS / FAIL
LOGBOOK_SENSOR_PROVENANCE: PASS / FAIL
AUTOMATED_NEGATIVE_COVERAGE: PASS / FAIL
MACOS_WATCH_BUILD: PASS / FAIL / NOT_EXECUTED
WATCH_ALGORITHM_TESTS: PASS / FAIL / NOT_EXECUTED
PHYSICAL_APPLE_WATCH_SENSOR_QA: PASS / FAIL / PENDING_PHYSICAL
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
P4_FINDINGS: <number>
SOFTWARE_READINESS_PERCENT: <0-100>
PHYSICAL_READINESS_PERCENT: <0-100>
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

`PASS` is permitted only when every software gate passes, no P0-P2 finding remains open, the physical Apple Watch sensor path passes, and every claim is traceable to genuine evidence.
