# 17 — DIR DIVING ORCHESTRATED AUDIT FULL REMEDIATION COMMAND V1.0

## Close every P0–P4 finding from the five controlling orchestrator reports

**Command version:** 1.0
**Updated:** 2026-06-21
**Repository:** `egopfe/DirDiving-App`
**Required starting branch:** `main`
**Task type:** implementation, remediation, validation, evidence completion, and release-gate closure
**Command position:** run only after the V1.1 orchestrated audit and before any TestFlight/App Store release
**Completion rule:** this command is incomplete while any P0, P1, P2, P3, or P4 issue remains open, pending, accepted without the required evidence, or duplicated without its canonical issue being closed

---

# 0. PRIMARY OBJECTIVE

You are Codex operating inside the latest DIR DIVING repository.

Implement, test, validate, document, and provide genuine evidence for every finding in the five controlling reports:

```text
Docs/ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md
Docs/ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv
Docs/ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md
Docs/ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md
Docs/ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv
```

Supporting reports that must also be read and kept aligned:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md
Docs/WATCH_BUHLMANN_ALTITUDE_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_EDGE_CASE_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_FINDING_TRACEABILITY_CURRENT.csv
Docs/COMPLETE_UI_UX_IMPLEMENTATION_COHERENCE_AUDIT_CURRENT.md
Docs/UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv
Docs/UI_UX_NAVIGATION_REACHABILITY_MATRIX_CURRENT.csv
Docs/UI_UX_STATE_COMPLETENESS_MATRIX_CURRENT.csv
Docs/UI_UX_CROSS_PLATFORM_PARITY_MATRIX_CURRENT.csv
Docs/UI_UX_REGRESSION_RISK_MATRIX_CURRENT.csv
Docs/UI_UX_GAP_REMEDIATION_PLAN_CURRENT.md
Docs/ORCHESTRATED_AUDIT_RUN_LOG_CURRENT.md
```

The command must resolve all current issues and any additional regression found while resolving them.

The final issue register must contain:

```text
OPEN = 0
IN_PROGRESS = 0
PENDING = 0
BLOCKED = 0
DEFERRED = 0
DOCUMENTED_ACCEPTED_RISK = 0 for release-required issues
P0_OPEN = 0
P1_OPEN = 0
P2_OPEN = 0
P3_OPEN = 0
P4_OPEN = 0
```

No issue may be made to disappear by deleting it, lowering severity, weakening an acceptance criterion, narrowing scope, changing a PASS threshold, or relabeling it as accepted risk.

---

# 1. NON-NEGOTIABLE SAFETY AND TRUTHFULNESS RULES

## 1.1 Evidence is mandatory

Do not mark an issue closed unless all of the following are present:

1. root cause is identified;
2. implementation is complete;
3. focused regression tests pass;
4. relevant full suites pass;
5. required documentation is updated;
6. physical evidence exists when the issue requires physical QA;
7. external evidence exists when the issue requires independent validation;
8. legal evidence exists when the issue requires counsel or App Store review;
9. acceptance criteria are individually demonstrated;
10. the five controlling reports agree on the final status.

Never fabricate, infer, simulate, pre-fill, or self-certify physical, underwater, external, legal, or App Store evidence.

Simulator evidence is not physical evidence. Production code comparing against shared production code is not an independent oracle. A documentation change is not a software fix. A software proxy is not closure of a physical gate.

## 1.2 Do not weaken safety to make tests pass

Do not:

- force-clear decompression;
- convert an error into no-decompression;
- silently default an unknown environment to sea level;
- lower test coverage or assertions;
- enlarge numerical tolerances without independent justification;
- skip compartments, gases, profiles, devices, locales, or negative paths;
- remove fail-closed behavior;
- auto-accept unsigned or stale payloads;
- weaken HMAC, signed ACK, nonce, replay, revision, checksum, schema, trust-reset, or activity namespace controls;
- change unavailable values to zero;
- present stale/partial values as current/complete;
- strengthen certification, medical, navigation, safety, CCR-controller, or decompression claims;
- mark external validation passed using an iOS/Watch shared core comparison;
- delete historical findings or QA requirements.

## 1.3 Preserve product architecture

Preserve:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Also preserve:

- activity-owned Settings;
- activity-owned Logbooks;
- Gauge vs Full Computer separation;
- Gauge TTV vs Full Computer TTS distinction;
- iOS Planner reference-only posture;
- Watch briefing cards as reference-only data;
- live Watch Full Computer independence from planner presentation cards;
- CCR reference-only and non-controller posture;
- Apnea recovery non-medical posture;
- Snorkeling return guidance non-guaranteed posture;
- surface-only GPS limitations;
- non-certified product positioning;
- experimental Buddy/Exploration target isolation;
- privacy/file-protection/redaction guarantees;
- all existing cross-activity isolation tests.

## 1.4 Git safety

Do not use:

```text
git reset --hard
git clean -fd
git checkout --
git push --force
git rebase --onto
```

Do not discard unrelated local work. Do not commit or push unless the user explicitly requests publication after reviewing the completed remediation.

---

# 2. PREFLIGHT AND LATEST-CODE VERIFICATION

Run:

```bash
git fetch origin --prune
git branch --show-current
git rev-parse HEAD
git rev-parse origin/main
git status --porcelain=v1
git status -sb
git remote -v
git diff --check
git rev-list --left-right --count HEAD...origin/main
```

Requirements:

- start from `main`;
- local `main` must equal `origin/main`;
- ahead/behind must be `0 0`;
- the worktree must be clean;
- all five controlling reports must exist and parse;
- the issue register must have the expected columns;
- the current issue IDs and severities must be snapshotted before editing.

If local `main` is behind and clean, update with:

```bash
git pull --ff-only origin main
```

If the branch is wrong, the worktree is dirty, or `main` has diverged, stop without resetting anything and report the exact blocker.

After a clean preflight, create a dedicated remediation branch:

```bash
git switch -c codex/orchestrated-audit-full-remediation-v1
```

Record the starting commit in:

```text
Docs/ORCHESTRATED_AUDIT_FULL_REMEDIATION_EXECUTION_LOG_CURRENT.md
```

---

# 3. BUILD THE CANONICAL REMEDIATION REGISTER

Parse `Docs/ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv`.

Create a working table containing:

```text
IssueID
NormalizedSeverity
RootCause
AffectedFiles
AcceptanceCriteria
RecommendedTests
ExternalQANeeded
PhysicalQANeeded
Dependencies
Blocks
ImplementationStatus
TestStatus
PhysicalStatus
ExternalStatus
DocumentationStatus
FinalStatus
EvidenceLinks
```

Use `IssueID` as a permanent identifier. Never renumber existing issues.

Current canonical issues expected from V1.1:

```text
ORCH-001  P0  Watch Full Computer altitude environment propagation
ORCH-002  P1  Independent Watch altitude test/oracle coverage
ORCH-003  P1  Full Computer environment provenance in logbook/persistence
ORCH-004  P1  Independent Bühlmann/CCR external validation
ORCH-005  P1  Physical Watch Ultra underwater/entitlement validation
ORCH-006  P1  Paired Watch/iPhone sync/trust physical validation
ORCH-007  P1  External legal/App Store claims review
ORCH-008  P1  Current-commit macOS build/test evidence
ORCH-009  P2  Physical performance/battery/thermal/GPS evidence
ORCH-010  P2  Physical accessibility evidence
ORCH-011  P2  Manual visual/PDF/device-pixel evidence
ORCH-012  P2  External Subsurface round-trip validation
ORCH-013  P2  Contradictory historical documentation
ORCH-014  P2  Cross-platform scanner path portability
ORCH-015  P2  Physical Snorkeling GPS/navigation/privacy validation
```

If the register contains additional P0–P4 issues, add them to scope automatically. Do not limit execution to the list above.

---

# 4. PHASE A — FREEZE, BASELINES, AND FAILING TESTS

Before changing production code:

1. generate the project;
2. run both app builds;
3. run both complete algorithm test schemes;
4. run every repository readiness script;
5. record baseline failures;
6. add focused failing tests that reproduce ORCH-001, ORCH-002, and ORCH-003;
7. confirm the tests fail for the correct reason.

Do not implement the fix before the P0 reproduction is deterministic.

Required P0 reproduction:

```text
iOS planner at 1,500 m salt water
→ signed DivePlanPackage contains altitude/salinity
→ Watch import accepts package
→ Watch activation creates confirmed Full Computer configuration
→ live runtime plan is inspected
```

The pre-fix test must demonstrate that the runtime environment differs from the signed package environment.

Also reproduce:

- a 500 m Air plan;
- a 2,000 m fresh-water Trimix plan;
- a 4,500 m maximum-supported plan;
- an altitude above maximum;
- NaN/infinite/missing environment values;
- corrupt/future environment schema;
- a legacy plan with no environment;
- checkpoint/restore after altitude activation;
- completed-dive logbook metadata after altitude activation.

---

# 5. PHASE B — ORCH-001 P0 FULL COMPUTER ENVIRONMENT FIX

## 5.1 Canonical environment contract

Create or extend a versioned Full Computer environment contract containing at minimum:

```text
schemaVersion
altitudeMeters
surfacePressureBar
salinity
waterDensityKgPerM3
environmentSource
confidenceOrFallbackState
capturedAt
sensorAccuracyMeters
sensorPrecisionMeters
```

The only supported live environment sources are:

```text
iPhonePlanImported
WatchSettingsManual
WatchSensorMeasuredProposal
```

`LegacyUnknown` may exist only as a migration/forensic state and may never authorize a live Full Computer start.

Apply this source policy:

1. **Imported from iPhone Plan:** preserve and validate the complete environment received with the signed plan.
2. **Manually entered on Watch:** provide an Altitude/Environment option in Watch Full Computer Settings. Validate and persist it as a draft source until predive confirmation.
3. **Sensor-measured proposal:** immediately before Full Computer confirmation, use a retained `CMAltimeter` and `startAbsoluteAltitudeUpdates(to:withHandler:)` to collect fresh `CMAbsoluteAltitudeData` directly on Apple Watch. Validate availability, finite altitude, accuracy, precision, sample count, stability, freshness, timeout, and supported range; then present the result as a pending proposal. The user must explicitly accept it; never apply or replace another source silently. Do not use cached `CLLocationManager.location.altitude` or GPS elevation for this authority path.
4. **No explicit sea-level option:** do not expose a separate sea-level choice and do not use sea level as an explicit or implicit default. A validated source may naturally resolve to approximately zero altitude, but missing, rejected, or unavailable input must block live start.

When imported, manual, and sensor values disagree beyond a documented tolerance, show the values and sources, require an explicit selection/confirmation, record the decision, and fail closed if the conflict is not resolved. Freeze the confirmed source and values when the dive starts.

## 5.2 Package construction and validation

Update the iOS package path so `DivePlanEnvironmentPayload` contains the validated canonical environment required by Watch.

Inspect and modify as required:

```text
iOSApp/Services/DivePlanPackageBuilder.swift
Shared/Models/DivePlanPackage.swift
Shared/Utils/DivePlanPackageCodec.swift
Shared/Utils/DivePlanPackageTransferSupport.swift
```

Requirements:

- package altitude/salinity/surface pressure/density must agree;
- values must be finite and in the supported range;
- surface pressure must be recalculated and cross-checked, not trusted blindly;
- payload checksum/signature must include the environment;
- old and future schemas must be handled explicitly;
- missing environment must be rejected for live Full Computer activation;
- legacy packages may remain viewable as reference-only but cannot become live authority without a new validated predive environment.

## 5.3 Watch import and activation

Inspect and modify as required:

```text
Services/FullComputerImportedPlanStore.swift
Services/FullComputerPrediveConfigurationStore.swift
Utils/FullComputerRuntimePlan.swift
Services/DiveManager.swift
Views/FullComputerImportedPlanView.swift
Views/FullComputerPrediveSettingsView.swift
Views/FullComputerPrediveConfirmationView.swift
```

Requirements:

- preserve the exact validated package environment during import;
- provide a manually editable Altitude/Environment field in Watch Full Computer Settings;
- request a sensor measurement when Full Computer startup begins at detected elevation and present it as a confirmation proposal;
- retain the asynchronous `CMAltimeter` provider until completion and stop absolute-altitude updates on success, error, timeout, cancellation, or view exit;
- require a fresh stable sample window and persist the accepted sensor timestamp, accuracy, and precision with the canonical environment;
- block live start while sensor sampling is active or a sensor proposal remains unresolved;
- never let a sensor proposal silently overwrite an imported iPhone plan or Watch manual value;
- persist gas profile and environment atomically;
- keep draft and confirmed environment separate;
- freeze the confirmed environment at dive start;
- prevent active-dive mutation;
- remove implicit `.seaLevelSaltWater` from every live-start call path;
- require an explicit environment argument when creating a live `FullComputerRuntimePlan`;
- fail closed with a clear localized diagnostic when the environment is missing, invalid, stale, corrupt, future-schema, or inconsistent;
- expose altitude, surface pressure, salinity, source, and fallback/confidence on imported-plan and predive-confirmation UI;
- prohibit an explicit sea-level setting and every implicit sea-level fallback;
- keep planner cards reference-only.

## 5.4 Runtime propagation

Verify a single immutable environment instance feeds:

```text
tissue initialization
ambient absolute pressure
inspired PN2/PHe
all 16 N2 compartments
all 16 He compartments
Schreiner updates
Haldane updates
GF ceiling
NDL
TTS
decompression schedule
stop state
gas PPO2/MOD/eligibility
gas switching
surfacing criterion
checkpoint
restore
runtime UI
diagnostics
logbook
sync
export
```

Any computation error must produce an unavailable/degraded fail-closed state, never zero or no-decompression.

## 5.5 Migration policy

Define and test migrations for:

- existing confirmed Watch gas profiles without environment;
- existing checkpoints;
- existing completed Full Computer dives;
- old iOS plan packages;
- future schema values.

Legacy completed records must say environment unknown. Legacy active/confirmed configurations must require user reconfirmation before Full Computer start.

---

# 6. PHASE C — ORCH-002 INDEPENDENT ALTITUDE ORACLE

Create a test-only independent altitude-aware Bühlmann oracle that does not call production implementations of:

```text
AmbientPressureModel
PlannerEnvironment.make
BuhlmannTissueState loading
production ceiling
production NDL
production TTS
production schedule
production gas-switch solver
```

The oracle must independently implement and document:

- ISA/barometric pressure formula and constants;
- water-vapour pressure;
- fresh/salt water hydrostatic pressure;
- all ZH-L16C N2/He coefficients and half-times;
- initial equilibrium;
- Haldane;
- Schreiner;
- combined N2/He tolerated pressure;
- GF interpolation;
- pressure-to-depth ceiling conversion;
- multilevel replay;
- gas switching;
- stop schedule and surfacing criterion.

Record formula provenance and licenses/citations in:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_ORACLE_PROVENANCE_CURRENT.md
```

Required deterministic matrix:

```text
Altitudes: -500 if supported, 0, 500, 1,000, 1,500, 2,000, 4,500 m
Invalid: below min, above max, missing, NaN, +∞, -∞
Water: fresh, salt
Gas: Air, EAN32, Trimix 18/45, O2 where operational
Profiles: constant, linear descent/ascent, multilevel, gas-switch, repetitive, restore
Timing: 0.5, 1, 1.5, 2, 5, 10, 30 s; duplicate, negative, out-of-order
Deco: appearance, reduction, clear, reappearance after re-descent
```

Mandatory Air profile at every supported altitude:

```text
Air
39 m until mandatory deco
ascend to 10 m
remain at 10 m
update every second
record all 16 N2 and 16 He compartments
surface only when complete tissue state permits
```

For every vector record absolute error, relative error, tolerance source, controlling compartment, ceiling, NDL, TTS, stops, and final state.

Mutation tests must fail when intentionally introducing:

- sea-level pressure at altitude;
- wrong water density;
- missing water-vapour subtraction;
- reversed Schreiner rate;
- seconds/minutes mismatch;
- swapped N2/He coefficients;
- skipped compartment;
- duplicated/dropped tick;
- environment reset on gas switch;
- environment reset on restore;
- deco clear on error.

---

# 7. PHASE D — ORCH-003 LOGBOOK, PERSISTENCE, SYNC, AND EXPORT

Extend the versioned Full Computer logbook metadata with:

```text
environmentSchemaVersion
altitudeMeters
surfacePressureBar
salinity
waterDensityKgPerM3
environmentSource
environmentConfidenceOrFallback
environmentCapturedAt
```

Inspect and modify as required:

```text
Shared/Models/FullComputerDiveLogbookMetadata.swift
Utils/FullComputerRuntimeLogbookAccumulator.swift
Models/DiveSession.swift
iOSApp/Models/DiveSession.swift
Watch/iOS sync codecs
Subsurface/CSV export services
PDF/share builders
backup/restore and migration code
logbook detail UI
```

Requirements:

- runtime and completed record must use the same frozen environment;
- Watch/iOS encode/decode round trips must preserve exact canonical values;
- conflict, duplicate, tombstone, out-of-order, and replay behavior must remain correct;
- legacy data must be explicit `unknown`, not zero/sea level;
- CSV/PDF/logbook detail must disclose environment and source where relevant;
- external formats that cannot represent the field must document the limitation without silently changing calculations;
- privacy redaction and file protection must remain intact.

Add migration and round-trip tests for every schema version.

---

# 8. PHASE E — ORCH-008 CURRENT-COMMIT MACOS SOFTWARE GATE

On macOS run:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Run all readiness scripts present in `Docs/ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md`, including:

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

Create a dedicated altitude readiness script and add it to CI.

No current-commit software issue may be closed until these commands pass on the same commit.

---

# 9. PHASE F — ORCH-014 TOOLING PORTABILITY

Fix path normalization in repository scanners without weakening their policies.

Inspect:

```text
Scripts/audit_localization.sh
Scripts/scan_prohibited_claims.py
Scripts/validate_release_legal_claims.sh
all scripts using relative-path exclusions or allowlists
```

Requirements:

- normalize paths using POSIX `/` before matching;
- support Windows and macOS path separators;
- keep exclusions target-aware;
- never exclude production sources accidentally;
- keep prohibited-claim allowlists exact by file, line/pattern, justification, reviewer, and date;
- reject stale allowlist entries when line or pattern no longer matches;
- add Windows/macOS golden tests;
- ensure Buddy/Exploration exclusions are honored only when `project.yml` excludes them;
- rerun localization and claims scans with zero false positives and zero real violations.

Do not solve this issue by adding broad wildcard exclusions.

---

# 10. PHASE G — ORCH-013 DOCUMENTATION TRUTHFULNESS

Audit and update:

```text
README.md
Docs/README.md
Docs/INDEX.md
Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md
Docs/DIR_DIVING_Feature_Comparison.csv
architecture, release, TestFlight, App Store, safety, and limitations documents
```

Requirements:

- canonical current sections must state Diving/Gauge/Full Computer, Apnea, and Snorkeling are on `main` where true;
- Buddy/legacy Exploration remain clearly experimental/excluded;
- historical sections must be labelled with date/commit and `HISTORICAL — NOT CURRENT PRODUCT SCOPE`, moved to a historical document, or archived;
- no current reader should encounter an unqualified statement that Apnea/Snorkeling are excluded from MAIN;
- environment/altitude support wording must match the remediated runtime exactly;
- no unsupported certification claim;
- all report links and commit references must be current;
- documentation scans and link checks must pass.

---

# 11. PHASE H — PHYSICAL QA: ORCH-005, ORCH-009, ORCH-010, ORCH-015

These issues are in scope and must be genuinely completed. They may not be converted to software-proxy closure.

## 11.1 Watch Ultra underwater and entitlement — ORCH-005

Execute on supported Apple Watch Ultra hardware:

- depth sensor entitlement and release provisioning;
- real submersion and surface transitions;
- Water Lock;
- wet/glove/crown interaction;
- manual and automatic Gauge start/stop;
- Full Computer start with imported iPhone, Watch Settings manual, and a fresh physical-Watch `CMAbsoluteAltitudeData` proposal, including validated near-zero and elevated configurations where safely testable;
- sensor unavailable, stale, spike, gap, out-of-order, relaunch, checkpoint restore;
- deco/stop/gas-switch UI states using safe replay/simulation where real decompression exposure is inappropriate;
- haptics enabled/disabled alternatives;
- critical metrics under combined banners;
- 41/45/49 mm screenshots where supported.

Record device model, OS, app commit, entitlement/provisioning, steps, expected/actual, media, reviewer, date, and result.

## 11.2 Performance, battery, and thermal — ORCH-009

Run documented budgets for:

- long Gauge session;
- long Full Computer one-second tissue/schedule updates;
- Apnea repeated dives/recovery;
- Snorkeling GPS/navigation;
- paired sync and large payloads;
- low battery;
- thermal pressure;
- background/suspend/resume;
- poor GPS and intermittent connectivity.

Capture Instruments/signposts, battery delta, thermal state, memory, CPU, update latency, dropped work, and user-visible degradation. Do not raise budgets merely to pass.

## 11.3 Accessibility — ORCH-010

Execute VoiceOver, Dynamic Type, contrast, reduced motion, haptics-off, color-independent state, touch-target, and reading-order matrices on physical Watch/iPhone.

Include every safety-critical Full Computer state, altitude/environment confirmation/error, activity selection, Settings, all Logbooks, Planner modes, Apnea recovery, Snorkeling navigation, sync errors, and destructive confirmations.

## 11.4 Snorkeling field QA — ORCH-015

Execute surface-only field tests for:

- permission denied/restricted/authorized;
- stale/poor/spike/gap GPS;
- surface-distance and route consistency;
- bearing wrap and return-to-entry;
- waypoint/marker flows;
- no-fix/degraded states;
- photo metadata and exact-coordinate redaction;
- privacy/export;
- battery/thermal;
- paired sync and offline recovery;
- explicit non-guaranteed guidance wording.

No unsafe water test is required. Use controlled surface conditions and trained reviewers.

---

# 12. PHASE I — PAIRED SYNC/TRUST QA: ORCH-006

Execute on a real paired iPhone and Watch:

- first pairing/trust bootstrap;
- trusted reconnect;
- trust mismatch;
- trust reset and re-pair;
- HMAC rejection;
- signed ACK verification;
- nonce/replay rejection;
- stale/future timestamp rejection;
- duplicate and out-of-order delivery;
- retry/idempotency;
- offline queue and reconnect;
- large payload/chunk interruption/resume;
- tombstone/delete propagation;
- conflicts;
- future/corrupt schema;
- Diving/Apnea/Snorkeling cross-decode rejection;
- Full Computer environment transfer and acknowledgement;
- two-device iCloud/backup interaction where applicable.

Preserve exact payload logs without exposing secrets. Record hashes/IDs only where sufficient.

---

# 13. PHASE J — EXTERNAL VALIDATION: ORCH-004 AND ORCH-012

## 13.1 Independent Bühlmann/CCR validation — ORCH-004

Use one or more genuinely independent, documented reference implementations or qualified external reviewers.

Validate:

- sea level and all supported altitude points;
- Air, Nitrox, Trimix, O2;
- N2/He tissues;
- Haldane and Schreiner;
- GF ceiling;
- NDL;
- TTS;
- decompression schedule;
- multilevel profiles;
- gas switches;
- repetitive dives;
- restore continuity;
- CCR setpoint/diluent/bailout estimates where supported;
- CNS/OTU and gas-density assumptions.

Record tool/version, configuration, source/provenance, input vectors, raw outputs, absolute/relative differences, tolerances, reviewer, and disposition.

Do not claim certification unless a qualified certifying body actually provides it.

## 13.2 Subsurface round trip — ORCH-012

Test real external Subsurface import/export with:

- metric/imperial;
- locale differences;
- single/multilevel;
- Gauge/Full Computer;
- gases/switches;
- altitude/environment where the format supports it;
- legacy/future/malformed rows;
- duplicate IDs;
- privacy-redacted coordinates;
- export→Subsurface→export comparison.

Document fields that cannot round-trip and ensure UI/export copy is truthful.

---

# 14. PHASE K — VISUAL, PDF, AND DEVICE EVIDENCE: ORCH-011

Populate all existing manual visual and physical-pixel QA evidence folders.

Required:

- Watch 41/45/49 mm or supported equivalents;
- smallest and largest supported iPhones;
- Italian and English;
- light/dark where supported;
- normal, empty, loading, partial, stale, error, permission, destructive, and restored states;
- Gauge and every critical Full Computer/Audit 15 state;
- altitude/environment confirmation and rejection states;
- Planner Base/Deco/Technical/CCR;
- Equipment/Checklist;
- all activity Logbooks;
- Apnea and Snorkeling;
- sync/security states;
- PDF plan, checklist, Dive Pack, logbook, and export outputs.

Perform deterministic pixel comparison where stable and manual scoring where rendering is inherently dynamic. Every mismatch must be resolved or added as a new issue and closed before finalization.

No mockup may be embedded as live UI.

---

# 15. PHASE L — LEGAL, CLAIMS, AND APP STORE: ORCH-007

Obtain real external review of:

- non-certified positioning;
- Watch Full Computer wording;
- altitude/environment wording;
- iOS Planner reference-only wording;
- CCR limitations and non-controller wording;
- CNS/OTU estimate wording;
- Rock Bottom/gas-density estimate wording;
- Apnea non-medical recovery wording;
- Snorkeling surface-GPS and non-guaranteed return wording;
- privacy/data deletion/backup/export disclosures;
- TestFlight/App Store metadata and screenshots;
- entitlement/provisioning statements;
- incident/rollback/support process;
- EN 13319/ISO 6425 strategy claims.

Store reviewer identity/role, date, reviewed version, findings, requested changes, resolution, and final disposition in the existing evidence structure.

Do not mark ORCH-007 closed with an internal self-review.

---

# 16. PHASE M — FIX EVERY ADDITIONAL P3/P4 AND REGRESSION

After P0–P2 remediation, parse all updated audits again.

Implement and close every remaining P3/P4 item, including polish, diagnostics, documentation clarity, optional accessibility improvements, and bounded performance improvements, provided the change does not weaken safety or expand product claims.

If any test, build, static scan, physical QA, external comparison, visual review, or legal review finds a new issue:

1. assign a permanent new `ORCH-*` ID;
2. normalize severity;
3. add it to the issue register;
4. implement the fix;
5. add regression coverage;
6. repeat the relevant phase;
7. close only with evidence.

The command must not finish with “new issue found, future work.” New issues are part of this remediation scope.

---

# 17. REQUIRED STATIC SCANS

Run and manually review:

```bash
rg -n "COMPASSO" .
rg -n "certified|certificazione|medical|guaranteed|safe route|blackout|rescue" Docs Shared Services Models Views iOSApp Resources Tests
rg -n "DiveManager|DiveLogStore|ApneaSessionEngine|Snorkeling|FullComputerRuntimeEngine|ExplorationStore" Shared Services Models Views Tests
rg -n "fullComputerPlanPackage|apneaSyncPlanPackage|dirdiving_apnea_session|dirdiving_snorkeling|dirdiving_dive_session" .
rg -n "TODO|FIXME" Shared Services Models Views iOSApp Tests Docs Scripts
rg -n "plannerEnvironment|altitudeMeters|surfacePressureBar|seaLevelSaltWater" Shared Services Models Utils Views iOSApp Tests
rg -n "CMAltimeter|startAbsoluteAltitudeUpdates|CMAbsoluteAltitudeData|CLLocationManager\.location\.altitude|pendingSensorProposal|sensorAccuracyMeters|sensorPrecisionMeters" Services Shared Utils Views Tests project.yml
rg -n "FullComputerRuntimePlan\(profile:|FullComputerGasProfile\(importing:" Services Shared Utils Tests
rg -n "P0|P1|P2|P3|P4|OPEN|PENDING|BLOCKED|DEFERRED" Docs/ORCHESTRATED_AUDIT_* Docs/WATCH_BUHLMANN_ALTITUDE_* Docs/UI_UX_*
```

Classify every match. Prohibition text, test fixtures, and historical records are not automatically defects, but unqualified current-product contradictions are.

---

# 18. MANDATORY AUDIT RERUNS

After remediation, rerun the complete current audit sequence:

```text
0 → 0W → 01W → 1 → 2 → 15 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 16
```

Do not reuse old verdicts without a current-commit delta and evidence review.

All reports must record the same final commit and evidence set.

---

# 19. REQUIRED OUTPUTS

Create or update:

```text
Docs/ORCHESTRATED_AUDIT_FULL_REMEDIATION_EXECUTION_LOG_CURRENT.md
Docs/ORCHESTRATED_AUDIT_FULL_REMEDIATION_COMPLETION_REPORT_CURRENT.md
Docs/ORCHESTRATED_AUDIT_FULL_REMEDIATION_TRACEABILITY_CURRENT.csv
Docs/ORCHESTRATED_AUDIT_ISSUE_REGISTER_CURRENT.csv
Docs/ORCHESTRATED_AUDIT_CONSOLIDATED_REPORT_CURRENT.md
Docs/ORCHESTRATED_AUDIT_REMEDIATION_ROADMAP_CURRENT.md
Docs/ORCHESTRATED_AUDIT_NON_REGRESSION_PLAN_CURRENT.md
Docs/ORCHESTRATED_AUDIT_RELEASE_READINESS_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md
Docs/WATCH_BUHLMANN_ALTITUDE_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_EDGE_CASE_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_FINDING_TRACEABILITY_CURRENT.csv
Docs/COMPLETE_UI_UX_IMPLEMENTATION_COHERENCE_AUDIT_CURRENT.md
Docs/UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv
Docs/UI_UX_NAVIGATION_REACHABILITY_MATRIX_CURRENT.csv
Docs/UI_UX_STATE_COMPLETENESS_MATRIX_CURRENT.csv
Docs/UI_UX_CROSS_PLATFORM_PARITY_MATRIX_CURRENT.csv
Docs/UI_UX_REGRESSION_RISK_MATRIX_CURRENT.csv
Docs/UI_UX_GAP_REMEDIATION_PLAN_CURRENT.md
```

The traceability CSV must contain:

```text
IssueID
Severity
OriginalStatus
RootCause
ProductionFilesChanged
TestsAddedOrChanged
DocsChanged
PhysicalEvidence
ExternalEvidence
LegalEvidence
AcceptanceCriterion
ValidationCommand
ValidationResult
EvidencePath
RegressionRisk
FinalStatus
ClosingCommit
Notes
```

---

# 20. FINAL ISSUE-REGISTER RULES

Update, never replace, the canonical issue register.

For duplicates:

- retain every row;
- set `DuplicateOf` to the canonical root issue;
- close the duplicate only after the canonical issue passes all acceptance criteria;
- do not reduce total historical finding traceability.

Allowed final status for a successfully completed remediation:

```text
CLOSED_VERIFIED
```

Physical/external/legal issues may use `CLOSED_VERIFIED` only when their actual evidence is attached and reviewed.

No release-required row may end as:

```text
OPEN
PENDING
BLOCKED
DEFERRED
ACCEPTED_RISK
SOFTWARE_PROXY_CLOSED
SCAFFOLDING_COMPLETE
CODE_READY_PHYSICAL_QA_PENDING
```

---

# 21. FINAL RELEASE MATRIX REQUIREMENTS

The release matrix must contain no `FAIL`, `PENDING`, `BLOCKED`, or `CODE_READY_PHYSICAL_QA_PENDING` rows.

Every required row must be `PASS` with a direct evidence path:

```text
Internal code
Internal tests
Documentation
UI/UX
Watch runtime
iOS planner
Full Computer
Gauge
Apnea
Snorkeling
Sync/security
Privacy/export
Performance/battery
Localization/accessibility
Mockups/visual regression
Release/legal
TestFlight
App Store
```

Do not change a gate to `NOT_APPLICABLE` merely to avoid completing it.

---

# 22. FINAL COMPLETION CHECK

Run:

```bash
git status -sb
git diff --check
git diff --stat
git diff --name-status
```

Verify:

- no unrelated file changed;
- no experimental target was promoted;
- no generated secret or user data was added;
- no physical/external evidence contains sensitive personal data;
- all CSV files parse with their declared column count;
- all Markdown links resolve;
- all five controlling reports agree;
- all rerun audits agree;
- all test/build/static/physical/external/legal evidence references the same remediation commit;
- issue register contains zero open P0–P4;
- release matrix contains only PASS for required gates.

If any condition fails, continue remediation. Do not print the success verdict.

---

# 23. REQUIRED FINAL SUMMARY

Print:

```text
REMEDIATION_BRANCH: <branch>
STARTING_COMMIT: <sha>
FINAL_WORKTREE_COMMIT_CANDIDATE: <sha or uncommitted>
TOTAL_ISSUES_PROCESSED: <number>
P0_CLOSED: <number>
P1_CLOSED: <number>
P2_CLOSED: <number>
P3_CLOSED: <number>
P4_CLOSED: <number>
OPEN_P0: 0
OPEN_P1: 0
OPEN_P2: 0
OPEN_P3: 0
OPEN_P4: 0
WATCH_ALTITUDE_END_TO_END: PASS
WATCH_CMALTIMETER_PREDIVE_ACQUISITION: PASS
WATCH_SENSOR_PROPOSAL_EXPLICIT_ACCEPTANCE: PASS
INDEPENDENT_ALTITUDE_ORACLE: PASS
FULL_COMPUTER_ENVIRONMENT_PERSISTENCE: PASS
FULL_COMPUTER_LOGBOOK_ENVIRONMENT: PASS
WATCH_IOS_PARITY: PASS
MACOS_BUILD_GATE: PASS
MACOS_TEST_GATE: PASS
PHYSICAL_WATCH_GATE: PASS
PAIRED_SYNC_GATE: PASS
PERFORMANCE_BATTERY_GATE: PASS
ACCESSIBILITY_GATE: PASS
SNORKELING_FIELD_GATE: PASS
VISUAL_PDF_GATE: PASS
EXTERNAL_BUHLMANN_CCR_GATE: PASS
SUBSURFACE_GATE: PASS
LEGAL_APP_STORE_GATE: PASS
INTERNAL_CODE_READINESS: GO
INTERNAL_TEST_READINESS: GO
TESTFLIGHT_READINESS: GO
APP_STORE_READINESS: GO
PRODUCTION_CODE_CHANGED: YES
COMMIT_PERFORMED: NO unless explicitly requested
PUSH_PERFORMED: NO unless explicitly requested
```

Then list:

1. every production file changed;
2. every test added/changed;
3. every issue and its closing evidence;
4. exact build/test counts;
5. physical devices and OS versions;
6. external tools/reviewers and versions;
7. legal reviewer/disposition;
8. residual risks, which must be non-release-blocking and not unresolved P0–P4;
9. final `git status`;
10. paths to all updated controlling reports.

End exactly with:

```text
Full orchestrated remediation complete. All P0–P4 findings are closed with verified software, physical, external, and legal evidence. No commit or push was performed unless separately authorized by the user.
```

---

# 24. STOP CONDITIONS

This command deliberately includes software, physical, external, and legal work. If required hardware, macOS, independent tools, or qualified reviewers are temporarily unavailable:

- finish every safely executable prerequisite;
- preserve all failing and passing evidence;
- keep affected issues OPEN or PENDING;
- state exactly what resource is missing;
- do not print the success verdict;
- resume from the execution log when the resource becomes available.

Unavailability is not permission to remove the issue from scope. The command remains incomplete until every P0–P4 issue is genuinely closed.

---

# 25. SUCCESS CRITERIA

This command is complete only when:

- all five controlling reports have been updated;
- every original and newly discovered P0–P4 issue is `CLOSED_VERIFIED`;
- ORCH-001 through ORCH-015 meet every acceptance criterion;
- the Watch Full Computer altitude environment is correct end to end;
- independent altitude and Bühlmann/CCR validation passes;
- logbook/persistence/sync/export preserve environment provenance;
- current-commit macOS builds and full suites pass;
- physical Watch, paired sync, performance, accessibility, Snorkeling, visual/PDF, and device QA pass;
- external Subsurface and legal/App Store review pass;
- documentation and portable scanners are truthful and clean;
- audits 0–16 have been rerun at the final commit candidate;
- the issue register has zero open P0–P4;
- every required release matrix row is PASS;
- no safety, security, privacy, product-architecture, or claims regression was introduced;
- no commit or push occurs without separate user authorization.
