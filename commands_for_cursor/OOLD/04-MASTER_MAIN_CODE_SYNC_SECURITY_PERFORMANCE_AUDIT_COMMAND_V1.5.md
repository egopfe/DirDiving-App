# LAUNCH ORDER 04

**Launch order note:** FOURTH — main code, sync, security, privacy, performance and concurrency audit. Run after feature-specific audits to verify cross-cutting architecture, data integrity and performance risks.

**Canonical numbered filename:** `04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.5.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING MAIN CODE / SYNC / SECURITY / PERFORMANCE AUDIT — V1.5

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Targets:**  

```text
DIRDiving Watch App
DIRDiving iOS
DIRDiving Watch Algorithm Tests
DIRDiving iOS Algorithm Tests
```

**Task type:** audit-only, read-only, full deep code / sync / persistence / schema / security / privacy / performance / concurrency / battery audit  
**Updated for latest development:**  

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

**Merged source commands:**

```text
5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md
8-DIR_DIVING_SYNC_PERSISTENCE_SCHEMA_AUDIT_V3.0.md
9-DIR_DIVING_SECURITY_PRIVACY_TRUST_AUDIT_V3.0.md
10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0.md
IOS_PERFORMANCE_OPTIMIZATION_AUDIT_COMMAND_V1.0.md
```

This command supersedes the separate deep-code, sync/persistence/schema, security/privacy/trust, global performance/concurrency/battery and iOS performance optimization audits by merging them into one single full deep comprehensive audit command.

---

# 0. ABSOLUTE EXECUTION RULE

This is strictly read-only.

Do **not** modify:

- production code;
- tests;
- project configuration;
- assets;
- mockups;
- localization resources;
- runtime documentation;
- algorithms;
- business logic;
- sync schemas;
- persistence schemas;
- security model;
- Git history.

Do **not**:

- refactor;
- apply fixes;
- change UI;
- change UX;
- change app visual identity;
- change Watch live runtime;
- change Buehlmann / Bühlmann math;
- change Schreiner;
- change Haldane;
- change Gradient Factors;
- change NDL / TTS / ceiling;
- change decompression schedule;
- change gas-switch logic;
- change Apnea recovery logic;
- change Snorkeling GPS/geodesy;
- change CCR/Rebreather logic;
- weaken HMAC/security;
- commit;
- push;
- merge.

You may create or update only the requested audit reports and matrices under `Docs/` and the validation scripts explicitly listed in this command.

If a defect is found, record it as an open finding with:

```text
severity
priority
area
platform
activity
mode
affected files/symbols
root cause
user impact
safety impact
security/privacy impact
performance impact
data-integrity impact
recommended remediation
tests required
acceptance criteria
release impact
```

Do not implement the fix.

Never claim physical Apple Watch, physical iPhone, paired-device, underwater, Instruments, penetration-test, certification, App Store or external decompression validation unless actual evidence exists.

If evidence is unavailable, mark:

```text
PENDING_PHYSICAL
PENDING_INSTRUMENTS
PENDING_PAIRED_DEVICE_QA
PENDING_EXTERNAL_VALIDATION
NOT_EXECUTED
```

---

# V1.5 NON-NEGOTIABLE ALGORITHMIC SAFETY PRIORITY

The decompression-computer mathematical core has maximum priority over every other audit area.

No consolidated readiness, release readiness, TestFlight readiness, App Store readiness, UI readiness, documentation readiness, or post-remediation readiness may be marked as positive if the Watch Full Computer forensic audit reports unresolved P0/P1 defects in:

```text
Bühlmann ZH-L16C constants
16 N2 + 16 He compartment updates
Haldane / Schreiner equation
actual elapsed-time / one-second integration
ambient pressure and altitude model
surface pressure / water density / salinity
inspired inert gas pressure
Gradient Factors and ceiling
NDL / TTS / decompression schedule
gas switch ordering
decompression stop-state machine
multilevel profile recomputation
checkpoint / restore tissue integrity
independent oracle coverage
external validation status
```

Priority rule:

```text
01 Watch Full Computer Forensic = highest-risk blocking audit
02 iOS = must not contradict or weaken 01
03 UI/UX = must present 01 truthfully
04 Main Code = must protect 01 with sync/security/performance gates
05 Release = must block release if 01 has unresolved safety findings
06 Docs = must document 01 status truthfully
07 Post-remediation = must rerun/check 01-critical gates before any 100% software-readiness claim
```

Any remediation touching Full Computer math, timing, gases, GF, decompression, pressure/depth, checkpoint/restore, schedule generation or tissue state must trigger rerun of:

```text
01 Watch Full Computer Forensic
03 UI/UX Full Deep
04 Main Code / Sync / Security / Performance
05 Release / QA / Evidence / Compliance
07 Post-Remediation Verification, if remediation has been executed
```

---


# V1.5 APNEA FIRST-CLASS SCOPE

The audit must treat Apnea as a first-class product area while preserving decompression-computer priority.

Apnea scope to verify where relevant:

```text
Apnea root/dashboard
Apnea live session
Apnea automatic detection
Apnea depth/time profile
Apnea descent/ascent metrics
Apnea surface interval
Apnea recovery countdown/state
Apnea targets
Apnea alarms
Apnea markers
Apnea statistics and records
Apnea logbook ownership
Apnea settings ownership
Apnea iOS Settings mode switch integration
Apnea Watch in-mode Settings access
Apnea water auto-open routing
Apnea Action Button behavior
Apnea active-session Digital Crown policy
Apnea localization/accessibility
Apnea sync/persistence/schema isolation
Apnea privacy positioning
Apnea physical/wet QA pending gates
```

Mandatory Apnea truthfulness:

```text
No decompression wording in Apnea.
No GF/gas/MOD/PPO2/deco settings in Apnea.
No medical guarantee for recovery.
No claim that Apnea auto-detection or wet behavior is physically validated unless evidence exists.
No claim that water auto-open starts an Apnea session.
No cross-activity Apnea/Diving/Snorkeling logbook or settings leakage.
```

---

# V1.5 ADDITIONAL REQUIRED OUTPUTS

Create or replace:

```text
Docs/MASTER_MAIN_APNEA_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
Docs/MASTER_APNEA_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv
Docs/MASTER_APNEA_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv
Docs/MASTER_APNEA_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv
Docs/MASTER_APNEA_PERFORMANCE_CONCURRENCY_MATRIX_CURRENT.csv
Docs/MASTER_MAIN_ALGORITHMIC_SAFETY_PROTECTION_GATE_CURRENT.md
```

# 1. MASTER OBJECTIVE

Perform a complete and deep audit of the entire `main` codebase covering:

1. Bugs and crash risks.
2. Data-loss and data-corruption risks.
3. Activity architecture and cross-activity isolation.
4. Settings ownership.
5. Logbook ownership.
6. Sync, schema, persistence, migration, backup and restore.
7. WatchConnectivity transport, HMAC, signed ACK and replay behavior.
8. Security, privacy and trust.
9. File import/export security.
10. Image, photo and briefing-card payload routing.
11. Planner briefing-card versioning, metadata and reference-only policy.
12. Performance, concurrency, battery, memory and thermal risks.
13. iOS-specific performance optimization.
14. Watch runtime performance and Full Computer update deadlines.
15. iOS Planner recalculation / chart / logbook / map scalability.
16. SwiftUI invalidation, MainActor overuse, retain-cycle risks and stale async publication.
17. Cloud/iCloud KVS, conflict, tombstone and payload-size behavior.
18. App Intents / Action Button safety gates.
19. Developer Sensor Source and simulation release safety.
20. External/physical QA gates that must not be falsely marked passed.

The audit must verify the current product architecture:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Both Apple Watch and iOS Companion are multi-activity apps.

---

# LATEST IMPLEMENTATION AND REMEDIATION CONTEXT — 2026-06-30

This command has been updated to include the latest implementation and remediation context known after the June 2026 development wave and the consolidated remediation command.

The audit must now explicitly account for:

```text
MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md
MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv
10-MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_CODE_READINESS_COMMAND_V1.0.md
CONS-001 command body permutation / command integrity
CONS-002 iOS ↔ Watch Gradient Factor preset parity
CONS-003 inFlightOutboundSessionIDs failed-ACK cleanup
CONS-004 symmetric Watch↔iOS diveImportAck
CONS-005 legacy unsigned tombstone hardening
CONS-006 shallow Full Computer developer testing toggle exposure
CONS-007 runtime depth capability authority versus Info.plist metadata
CONS-008 independent TTS/schedule oracle
Watch water auto-open / submerged system launch
Digital Crown underwater navigation clamp
Action Button / App Intent router-only safety policy
Cold-launch modal sequencing
Full Computer Gradient Factor presets and predive snapshot
iOS plan GF override compatibility
shallow-depth entitlement and capability separation
Developer shallow Gauge / Full Computer testing toggles
Water Lock / Action Button / Digital Crown / shallow wet physical QA pending gates
```

Mandatory policy interpretation:

```text
Software-ready can be 100 only for code, automated tests, scripts, docs and package truthfulness.
Physical Watch, underwater, Water Lock, Action Button, Digital Crown, shallow wet, paired-device and external validation gates remain PENDING unless actual evidence exists.
Do not convert simulator, static audit, unit tests, mock data, self-comparison or templates into physical/external evidence.
No command may claim App Store readiness, legal/certification approval, EN13319, ISO 6425, certified dive-computer status or certified CCR controller status without evidence.
```

All referenced documents must be searched in `Docs/` before conclusions are made.

---

# COMMAND INTEGRITY AND REMEDIATION-OUTPUT AWARENESS

Before performing the domain audit, verify command integrity because the consolidated audit found a P0 documentation/process blocker where command filenames and bodies were permuted.

Inspect:

```text
commands_for_cursor/00-MASTER_SUPER_ORCHESTRATOR_FULL_AUDIT_SEQUENCE_AND_NON_REGRESSIVE_REMEDIATION_PLAN_COMMAND_V1.5.md
commands_for_cursor/01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V1.5.md
commands_for_cursor/02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.5.md
commands_for_cursor/07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.5.md
```

Verify each file contains the expected audit body for its launch number.

If command integrity fails, mark:

```text
COMMAND_INTEGRITY_CONFLICT
AUDIT_RESULT_UNTRUSTWORTHY_UNTIL_COMMANDS_REPAIRED
```

If post-remediation outputs exist, also read:

```text
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_NON_REGRESSION_RESULTS_CURRENT.md
Docs/MASTER_CONSOLIDATED_INTERNAL_TESTFLIGHT_SOFTWARE_READINESS_CURRENT.md
Docs/MASTER_CONSOLIDATED_PHYSICAL_EXTERNAL_PENDING_AFTER_SOFTWARE_REMEDIATION_CURRENT.csv
Docs/MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_READINESS_TO_100_COMPLETION_SUMMARY_CURRENT.md
```

If these files do not exist, classify remediation verification as `POST_REMEDIATION_OUTPUTS_NOT_PRESENT` and continue the audit using current code and audit docs.

---

# 1B. POST-REMEDIATION CROSS-CUTTING CODE FOCUS

This audit must verify cross-cutting software remediation for:

```text
CONS-001 command integrity scanner and filename/body alignment
CONS-003 in-flight ACK cleanup
CONS-004 diveImportAck symmetry
CONS-005 tombstone signing and legacy migration limits
CONS-006 developer shallow testing release gate
CONS-007 runtime depth capability authority
CONS-023..027 performance/concurrency/stale async findings if present
```

Additional required outputs:

```text
Docs/MASTER_MAIN_CODE_POST_REMEDIATION_VERIFICATION_CURRENT.md
Docs/MASTER_COMMAND_INTEGRITY_POST_REMEDIATION_MATRIX_CURRENT.csv
Docs/MASTER_SYNC_SECURITY_POST_REMEDIATION_MATRIX_CURRENT.csv
Docs/MASTER_DEPTH_CAPABILITY_POST_REMEDIATION_MATRIX_CURRENT.csv
Docs/MASTER_PERFORMANCE_CONCURRENCY_POST_REMEDIATION_MATRIX_CURRENT.csv
```

Final verdict additions:

```text
MAIN_COMMAND_INTEGRITY: PASS / FAIL / NOT_EXECUTED
MAIN_SYNC_SECURITY_REMEDIATION: PASS / PARTIAL / FAIL / NOT_EXECUTED
MAIN_DEPTH_CAPABILITY_REMEDIATION: PASS / PARTIAL / FAIL / NOT_EXECUTED
MAIN_SOFTWARE_READINESS_AFTER_REMEDIATION: <0-100>
```

---

# 2. REQUIRED OUTPUT FILES

Create or replace:

```text
Docs/MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
Docs/MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv
Docs/MASTER_MAIN_ARCHITECTURE_RISK_MATRIX_CURRENT.csv
Docs/MASTER_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv
Docs/MASTER_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv
Docs/MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv
Docs/MASTER_SECURITY_THREAT_MODEL_CURRENT.md
Docs/MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv
Docs/MASTER_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
Docs/MASTER_CONCURRENCY_RISK_MATRIX_CURRENT.csv
Docs/MASTER_IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
Docs/MASTER_IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv
Docs/MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md
Docs/MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md
Docs/MASTER_MAIN_CODE_REMEDIATION_PLAN_CURRENT.md
Scripts/validate_master_main_code_sync_security_performance_audit.sh
```

Do not create production changes.

---

# 3. SEVERITY MODEL

## P0 — Must block any internal safety-critical use

Use P0 for:

- cross-activity data corruption;
- wrong activity payload decoded into wrong store;
- wrong Settings or Logbook ownership affecting safety data;
- tissue/checkpoint corruption;
- false no-decompression state due to race/performance failure;
- stale async result overwriting newer safety/planner data;
- sync/HMAC bypass or replay that can corrupt data;
- profile merge that silently fuses divergent dives;
- unbounded memory growth causing realistic termination;
- path traversal or arbitrary file write/delete;
- simulation sensor silently active in release;
- App Intent bypassing legal/safety gate;
- briefing-card metadata mutating live Watch runtime;
- cloud backup exposing sensitive data without opt-in.

## P1 — Must fix before internal TestFlight

Use P1 for:

- crash risk with realistic data;
- sync queue without backpressure;
- schema migration ambiguity;
- stale payload accepted;
- large logbook unusable;
- planner recalculation storm;
- heavy math on main thread;
- map/chart unbounded rendering;
- missing security/privacy manifest;
- missing physical/paired-device evidence for safety-relevant path;
- developer mode not safely hidden.

## P2

Use P2 for:

- bounded performance issue;
- missing performance budget;
- missing signpost;
- incomplete negative tests;
- incomplete privacy documentation;
- incomplete conflict/tombstone coverage;
- inefficient but bounded path.

## P3

Use P3 for documentation gaps, observability gaps, non-blocking optimizations and maintainability.

---

# 4. PREFLIGHT

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git rev-parse HEAD
git fetch --prune origin
git status --short
git status -sb
git rev-list --left-right --count HEAD...origin/main
git remote -v
xcodebuild -version
```

Stop if branch is not `main`.

Inspect:

```text
project.yml
README.md
Docs/**
iOSApp/**
Views/**
Services/**
Models/**
Utils/**
Shared/**
Tests/**
Scripts/**
Resources/**
Assets.xcassets/**
```

Record:

```text
branch
commit
origin/main
dirty files
Watch target
iOS target
test targets
entitlements
bundle IDs
experimental exclusions
available simulators
Xcode version
physical Watch availability
physical iPhone availability
paired-device availability
Instruments availability
external validation availability
```

---

# 5. BUILD AND TEST BASELINE

If environment allows, run:

```bash
xcodegen generate
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

Build:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Run:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Do not fix failures. Record exact command, destination, duration, passed/failed/skipped and limitations.

---

# 6. ARCHITECTURE / TARGET MEMBERSHIP AUDIT

Audit:

- repository structure;
- target membership;
- shared files between Watch and iOS;
- duplicate code;
- stale/dead files;
- orphan views/services;
- experimental leakage;
- build settings;
- entitlements;
- generated project policy;
- localization resources;
- documentation consistency;
- test target coverage.

Verify:

```text
Diving payloads → Diving store only
Apnea payloads → Apnea store only
Snorkeling payloads → Snorkeling store only
Diving Settings → Diving only
Apnea Settings → Apnea only
Snorkeling Settings → Snorkeling only
Diving Logbook → Diving only
Apnea Logbook → Apnea only
Snorkeling Logbook → Snorkeling only
```

Any cross-decoding or cross-routing is P0/P1.

---

# 7. APPLE WATCH DEEP CODE AUDIT

Inspect at minimum:

```text
Services/DiveManager.swift
Services/DepthSensorProvider.swift
Services/AppleDepthSensorProvider.swift
Services/MockDepthSensorProvider.swift
Services/SensorProviderFactory.swift
Services/GPSManager.swift
Services/HapticService.swift
Services/DepthLimitHapticCoordinator.swift
Services/AscentSafetyHapticCoordinator.swift
Services/WatchSyncService.swift
Services/WatchDiveSyncCodec.swift
Services/WatchSyncAuth.swift
Services/DiveLogStore.swift
Services/SubsurfaceExportService.swift
Services/UserImageStore.swift
Services/PlannerBriefingCardStore.swift
Services/PlannerBriefingWatchReceiver.swift
Services/ActionButtonIntents.swift
Views/DiveLiveView.swift
Views/AscentGaugeView.swift
Views/AscentWarningView.swift
Views/DepthSafetyLiveViews.swift
Views/DiveDetailView.swift
Views/DiveLogListView.swift
Views/SettingsView.swift
Views/InfoView.swift
Views/UserImagesView.swift
Views/MissionModeIndicatorView.swift
Views/WatchShortcutHelpView.swift
Views/ApneaView.swift
Views/SnorkelingView.swift
Views/WatchActivitySettingsSections.swift
Utils/**
Models/**
```

Audit for:

- dive lifecycle bugs;
- manual/automatic start conflicts;
- draft restore bugs;
- timer/race issues;
- stale depth/frozen depth;
- invalid depth;
- depth safety thresholds;
- ascent-rate bugs;
- haptic storms;
- Mission Mode invariant breaks;
- GPS lifecycle/battery risk;
- App Intent legal gate bypass;
- sensor source/simulation release risk;
- WatchConnectivity routing;
- sync replay/tamper risk;
- local persistence;
- image inventory/delete;
- path traversal;
- CSV/export consistency;
- briefing-card stale/overwrite/malformed payload;
- card values affecting live Watch state;
- Apnea lifecycle concurrency;
- Snorkeling GPS/battery/privacy;
- Full Computer one-second runtime performance;
- small-display layout performance.

---

# 8. iOS DEEP CODE AUDIT

Inspect at minimum:

```text
iOSApp/App/**
iOSApp/Services/IOSCompanionStoreCoordinator.swift
iOSApp/Services/PlannerStore.swift
iOSApp/Services/PlannerService.swift
iOSApp/Services/BuhlmannPlanner.swift
iOSApp/Services/GasPlanningService.swift
iOSApp/Services/ScheduleGasConsumptionService.swift
iOSApp/Services/GasLedgerDisplayFormatter.swift
iOSApp/Services/RepetitiveDivePlannerService.swift
iOSApp/Services/DiveLogStore.swift
iOSApp/Services/CloudSyncStore.swift
iOSApp/Services/WatchSyncService.swift
iOSApp/Services/WatchDiveSyncCodec.swift
iOSApp/Services/WatchSyncAuth.swift
iOSApp/Services/DiveImportService.swift
iOSApp/Services/SubsurfaceExportService.swift
iOSApp/Views/PlannerView.swift
iOSApp/Views/PlannerGasMixCard.swift
iOSApp/Views/LogbookView.swift
iOSApp/Views/DiveDetailView.swift
iOSApp/Views/ManualDiveEditorView.swift
iOSApp/Views/MoreView.swift
iOSApp/Views/IOSCompanionSettingsRootView.swift
iOSApp/Views/IOSCompanionSettingsModeSwitcher.swift
iOSApp/Views/Diving/**
iOSApp/Views/Apnea/**
iOSApp/Views/Snorkeling/**
iOSApp/Algorithms/Buhlmann/**
iOSApp/Models/**
iOSApp/Utils/**
Shared/**
```

Audit for:

- Base/Deco/Technical mode bugs;
- CCR leakage into OC modes;
- hidden gas affecting simpler modes;
- MOD/PPO2/switch-depth bugs;
- PlannerEnvironment fallback;
- NDL preview using wrong input;
- GasPlanningService preview mismatch;
- cloud merge silent fusing;
- duplicate session IDs;
- iCloud payload size;
- manual pressure unit bugs;
- CSV parser robustness;
- Subsurface fidelity;
- Watch sync ACK/pending-state bugs;
- iOS Watch image inventory stale state;
- delete success before Watch ACK;
- SwiftUI state loops;
- performance bottlenecks;
- privacy-sensitive iCloud behavior;
- stale ascent-speed/runtime/Rock Bottom/gas ledger/repetitive tissue results;
- structured equipment/checklist role loss;
- briefing-card metadata/PNG divergence;
- transfer success before ACK;
- unsupported schema handling.

---

# 9. SYNC / PERSISTENCE / SCHEMA AUDIT

Create:

```text
Docs/MASTER_SYNC_MESSAGE_NAMESPACE_MATRIX_CURRENT.csv
Docs/MASTER_SCHEMA_MIGRATION_COMPATIBILITY_MATRIX_CURRENT.csv
Docs/MASTER_BACKUP_RESTORE_ISOLATION_MATRIX_CURRENT.csv
```

Audit:

```text
shared transport envelope
activity discriminator
separate codecs
separate stores
revision/checksum
HMAC/peer trust
ACK/retry/idempotency
payload chunking
large profile transfer
out-of-order delivery
tombstones
conflict resolution
corrupt/future schema
legacy Diving migration
Full Computer tissue checkpoints
Apnea session with multiple dives
Snorkeling surface track + dips
Settings payload namespaces
plan/card/photo payload route separation
backup/restore isolation
```

Mandatory route checks:

```text
Diving payload → Diving store only
Apnea payload → Apnea store only
Snorkeling payload → Snorkeling store only
Planner briefing card payload → briefing-card receiver only
Image payload → image/photo handler only
Settings payload → correct activity namespace only
```

Reject all cross-decoding.

---

# 10. SECURITY / PRIVACY / TRUST AUDIT

Create:

```text
Docs/MASTER_SECURITY_THREAT_MODEL_CURRENT.md
Docs/MASTER_PRIVACY_DATA_FLOW_MATRIX_CURRENT.csv
Docs/MASTER_SECURITY_REMEDIATION_PLAN_CURRENT.md
```

Audit:

```text
WatchConnectivity authentication
peer secret lifecycle
HMAC
nonce/replay
signed ACK
trust reset
malformed payload rejection
path traversal
file import/export
image/card storage
temporary files
cloud backup opt-in
GPS privacy
photo metadata
exact-coordinate redaction
logs and diagnostics
sensitive equipment/gas data
App Intents
feature flags/developer mode
simulation release safety
deep links
activity cross-routing
data deletion
backup encryption assumptions
privacy manifests and usage descriptions
least privilege
third-party dependencies
```

Activity-specific privacy risks:

```text
Diving plan/gas/tissue data
Apnea session/health-like data
Snorkeling location routes/photos
wrong activity data exposure
```

Do not claim penetration testing or compliance certification without evidence.

---

# 11. GLOBAL PERFORMANCE / CONCURRENCY / BATTERY AUDIT

Create:

```text
Docs/MASTER_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
Docs/MASTER_CONCURRENCY_RISK_MATRIX_CURRENT.csv
Docs/MASTER_PHYSICAL_PERFORMANCE_QA_PLAN_CURRENT.md
```

Audit Watch:

```text
one-second Full Computer tissue updates
sensor sampling
GPS
haptics
reminders
Mission Mode invariants
Apnea lifecycle
Snorkeling GPS/navigation
timers/tasks
background transitions
WatchConnectivity
image/card decoding
small-screen rendering
battery/thermal risk
```

Audit iOS:

```text
planner recomputation
charts
maps
large Logbooks
large GPS tracks
tissue histories
exports
backup
sync import
SwiftUI invalidation
cancellation/stale result publication
settings mode switch
startup
file I/O
JSON encoding/decoding
large dataset behavior
```

Audit actor isolation, Sendable correctness, retain cycles, uncancelled tasks, timer duplication, race conditions and main-thread blocking.

---

# 12. iOS PERFORMANCE OPTIMIZATION AUDIT

Create:

```text
Docs/MASTER_IOS_PERFORMANCE_BUDGET_MATRIX_CURRENT.csv
Docs/MASTER_IOS_PERFORMANCE_SCALABILITY_MATRIX_CURRENT.csv
```

Audit iOS performance areas:

```text
Startup and first render
Navigation and tab switching
SwiftUI diffing and body recomputation
Diving Planner
Full Computer planning previews
Buehlmann chart rendering
Tissue loading charts
Logbook list scalability
Session detail rendering
PDF export
CSV/Subsurface export
Import parsing
Photo/image handling
WatchConnectivity processing
iCloud / KVS backup paths
Apnea dashboard
Apnea planner/settings/logbook
Snorkeling dashboard
Snorkeling route planner
Snorkeling map rendering
Snorkeling session track rendering
Settings mode switcher
Shared localization access
Shared theme/rendering components
Memory/retain-cycle hygiene
Task lifecycle and cancellation
MainActor overuse
Background queue correctness
File I/O and JSON encoding/decoding
Large dataset behavior
Battery-impacting loops
Instrumentation and observability
```

Score:

```text
IOS_STARTUP_PERFORMANCE_READINESS
IOS_SWIFTUI_RENDERING_READINESS
IOS_PLANNER_PERFORMANCE_READINESS
IOS_CHART_RENDERING_READINESS
IOS_LOGBOOK_SCALABILITY_READINESS
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS
IOS_SYNC_PERFORMANCE_READINESS
IOS_MAP_ROUTE_RENDERING_READINESS
IOS_MEMORY_READINESS
IOS_CONCURRENCY_READINESS
IOS_BATTERY_POLICY_READINESS
IOS_OBSERVABILITY_READINESS
IOS_PERFORMANCE_TEST_COVERAGE_READINESS
OVERALL_IOS_PERFORMANCE_READINESS
```

Physical Instruments profiling remains pending unless executed.

---

# 13. REQUIRED PERFORMANCE SCENARIOS

Audit/plan tests for:

```text
rapid planner depth edit 100 times
rapid planner runtime edit 100 times
rapid gas edit 100 times
GF sweep
10 gases
long deco plan
CCR reference plan if present
1k / 10k / 50k chart points
1k / 5k / 10k logbook sessions
large PDF export
large CSV/Subsurface export
large import
100 / 1k / 5k sync messages
50k snorkeling route points
settings mode switch 50 times
large Watch image inventory
briefing-card render/transfer burst
background/foreground cycle
```

Budget targets must be documented. No score without evidence.

---

# 14. OBSERVABILITY / SIGNPOST AUDIT

Search for:

```text
OSLog
Logger
os_signpost
Signposter
measure
XCTestMetrics
```

Create or update:

```text
Docs/MASTER_PERFORMANCE_SIGNPOST_CATALOG_CURRENT.md
```

Required signpost categories:

```text
startup
planner solve
chart render
logbook load
statistics compute
export
import
sync decode
sync persist
cloud backup
map simplification
route render
settings switch
Watch tissue tick
Watch schedule recompute
Watch haptic
Watch image decode
briefing-card render
briefing-card transfer
```

---

# 15. TEST COVERAGE AUDIT

Create:

```text
Docs/MASTER_MAIN_REQUIREMENT_TEST_TRACEABILITY_CURRENT.csv
```

Audit automated and missing tests for:

```text
startup and activity selection
Gauge
Full Computer
Bühlmann
gas switching
deco stop state machine
Apnea lifecycle/recovery
Snorkeling GPS/dips/navigation
Settings isolation
Logbook ownership
sync/schema
migration
backup/restore
localization/accessibility
security
performance
exports
Watch CMAltimeter pre-dive acquisition
iOS performance/scalability
Watch image inventory/delete
Planner briefing cards
CCR reference-only
Rock Bottom
Gas ledger
Repetitive dive
Structured equipment/checklist
```

Classify evidence:

```text
automated unit
integration
UI/snapshot
simulator
physical Watch
physical iPhone
paired-device
underwater
external reference
legal/compliance review
```

No evidence means not passed.

---

# 16. FINDING TRACEABILITY

Create:

```text
Docs/MASTER_MAIN_CODE_FINDING_TRACEABILITY_CURRENT.csv
```

Columns:

```text
Finding_ID
Severity
Priority
Area
Platform
Activity
Mode
Status
Root_Cause
Affected_Files
Affected_Symbols
User_Impact
Safety_Impact
Security_Privacy_Impact
Performance_Impact
Data_Integrity_Impact
Recommended_Remediation
Tests_Required
Acceptance_Criteria
Regression_Risk
Physical_QA_Required
External_Validation_Required
Evidence
Notes
```

Allowed statuses:

```text
OPEN
VERIFIED
DOCUMENTED_ACCEPTED_RISK
NOT_APPLICABLE
PENDING_PHYSICAL
PENDING_INSTRUMENTS
PENDING_EXTERNAL_VALIDATION
```

Because this is audit-only, new defects remain `OPEN`.

---

# 17. VALIDATION SCRIPT

Create or update:

```text
Scripts/validate_master_main_code_sync_security_performance_audit.sh
```

The script must:

- use `set -euo pipefail`;
- verify repository root;
- verify branch `main`;
- avoid concurrent XcodeGen;
- run target isolation;
- run secrets scan;
- run localization audit;
- build iOS app;
- build Watch app;
- run iOS algorithm tests;
- run Watch algorithm tests;
- run available performance/scalability tests;
- verify audit docs exist;
- verify finding traceability exists;
- verify budget matrices exist;
- verify threat model exists;
- verify sync/schema matrices exist;
- verify QA plan exists.

On success print:

```text
MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_GATE_PASS
MASTER_MAIN_CODE_AUDIT_DOCUMENTATION_COMPLETE
MASTER_SYNC_SCHEMA_MATRICES_COMPLETE
MASTER_SECURITY_PRIVACY_MATRICES_COMPLETE
MASTER_PERFORMANCE_BUDGETS_COMPLETE
MASTER_IOS_PERFORMANCE_MATRICES_COMPLETE
PHYSICAL_QA_PENDING_UNLESS_EVIDENCED
```

Do not print software readiness 100 unless all findings are verified and this has become an implementation/remediation command.

---

# 18. MASTER REPORT STRUCTURE

Create:

```text
Docs/MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Commands Merged  
C. Latest Development Context  
D. Branch, Commit and Scope  
E. Preflight and Build/Test Baseline  
F. Target Membership and Architecture  
G. Activity Isolation and Cross-Activity Risk  
H. Apple Watch Deep Code Analysis  
I. iOS Companion Deep Code Analysis  
J. Planner-Specific Deep Code Analysis  
K. Full Computer Runtime Integration Risk  
L. Sync / Persistence / Schema  
M. Backup / Restore Isolation  
N. Cloud / iCloud / KVS  
O. Security / Privacy / Trust  
P. Threat Model  
Q. Import / Export / File Security  
R. Watch Image / Planner Briefing Card Payload Routing  
S. App Intents / Action Button / Developer Sensor Source  
T. Performance / Concurrency / Battery — Global  
U. iOS Performance Optimization  
V. Watch Performance / Full Computer Timing  
W. Snorkeling Map / Route Performance  
X. Logbook Scalability  
Y. Memory / Retain-Cycle Hygiene  
Z. Concurrency / Cancellation / Stale Result Guards  
AA. Observability / Signposts  
AB. Test Coverage and Evidence  
AC. Physical / Instruments / External QA Pending  
AD. Detailed Findings  
AE. Readiness Matrix  
AF. Prioritized Remediation Plan  
AG. Future Cursor Remediation Commands  
AH. Final Verdict

---

# 19. REQUIRED FINAL QUESTIONS

The report must explicitly answer:

1. Is MAIN architecture clean and isolated?
2. Are Diving, Apnea and Snorkeling separated at code, sync, settings and logbook levels?
3. Are sync payloads activity-discriminated and cross-decoding rejected?
4. Are schemas versioned and migration-safe?
5. Is backup/restore activity-isolated?
6. Is WatchConnectivity authentication intact?
7. Are HMAC, nonce/replay and ACK policies safe?
8. Are file import/export paths safe?
9. Are images/cards protected from path traversal and arbitrary delete/write?
10. Are privacy flows truthful and opt-in where required?
11. Are simulation/developer modes release-safe?
12. Do App Intents respect legal/safety gates?
13. Are iOS Planner calculations performance-safe?
14. Are heavy computations off main thread where needed?
15. Are stale async results rejected?
16. Are charts/maps/logbooks bounded for realistic data?
17. Is sync queue bounded/backpressured?
18. Are caches bounded?
19. Are tasks cancellable?
20. Are there retain-cycle risks?
21. Are performance budgets documented?
22. Is Instruments profiling complete or pending?
23. What blocks 100% main-code readiness?
24. What blocks 100% security readiness?
25. What blocks 100% performance readiness?
26. What blocks internal TestFlight?
27. What blocks external TestFlight?

Every `NO`, `PARTIAL`, `UNKNOWN`, `PENDING`, or `NOT_EXECUTED` must include severity, root cause, affected files/symbols, impact, remediation and tests.

---

# 20. FINAL VERDICT

Print exactly:

```text
MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT: PASS / PARTIAL / FAIL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
TARGET_MEMBERSHIP: PASS / FAIL
MULTI_ACTIVITY_ARCHITECTURE: PASS / FAIL
ACTIVITY_ISOLATION_CODE: PASS / FAIL
SETTINGS_OWNERSHIP_CODE: PASS / FAIL
LOGBOOK_OWNERSHIP_CODE: PASS / FAIL
SYNC_ACTIVITY_DISCRIMINATORS: PASS / FAIL
SCHEMA_MIGRATION_SAFETY: PASS / FAIL
BACKUP_RESTORE_ISOLATION: PASS / FAIL
WATCHCONNECTIVITY_AUTHENTICATION: PASS / FAIL
HMAC_REPLAY_ACK_POLICY: PASS / FAIL
SECURITY_FILE_PATH_SAFETY: PASS / FAIL
PRIVACY_DATA_FLOW_TRUTHFULNESS: PASS / FAIL
SIMULATION_RELEASE_SAFETY: PASS / FAIL
APP_INTENTS_SAFETY_GATE: PASS / FAIL
WATCH_IMAGE_CARD_PAYLOAD_ROUTING: PASS / FAIL
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY_CODE: PASS / FAIL
IOS_STARTUP_PERFORMANCE_READINESS: <0-100>
IOS_SWIFTUI_RENDERING_READINESS: <0-100>
IOS_PLANNER_PERFORMANCE_READINESS: <0-100>
IOS_CHART_RENDERING_READINESS: <0-100>
IOS_LOGBOOK_SCALABILITY_READINESS: <0-100>
IOS_EXPORT_IMPORT_PERFORMANCE_READINESS: <0-100>
IOS_SYNC_PERFORMANCE_READINESS: <0-100>
IOS_MAP_ROUTE_RENDERING_READINESS: <0-100>
IOS_MEMORY_READINESS: <0-100>
IOS_CONCURRENCY_READINESS: <0-100>
IOS_BATTERY_POLICY_READINESS: <0-100>
WATCH_RUNTIME_PERFORMANCE_READINESS: <0-100>
WATCH_FULL_COMPUTER_TIMING_READINESS: <0-100>
GLOBAL_SECURITY_READINESS: <0-100>
GLOBAL_PRIVACY_READINESS: <0-100>
GLOBAL_SYNC_SCHEMA_READINESS: <0-100>
GLOBAL_PERFORMANCE_CONCURRENCY_BATTERY_READINESS: <0-100>
TEST_COVERAGE_READINESS: <0-100>
OVERALL_MAIN_CODE_READINESS: <0-100>
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
PHYSICAL_WATCH_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_IOS_QA: PASS / FAIL / PENDING_PHYSICAL
PAIRED_DEVICE_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_INSTRUMENTS_PROFILING: PASS / FAIL / PENDING_INSTRUMENTS
EXTERNAL_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

`PASS` is allowed only when every software gate passes, no P0-P2 finding remains open, and any claimed physical/external evidence actually exists.

---

# 21. SUCCESS CRITERIA

The task is complete only if:

- no production source code is modified;
- no tests are modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- no sync/security model is modified;
- all required reports/matrices/scripts are created;
- all five merged command scopes are preserved;
- latest multi-activity development is included;
- Settings and Logbook isolation are audited;
- sync/persistence/schema are audited;
- security/privacy/trust are audited;
- performance/concurrency/battery are audited;
- iOS performance optimization is audited in detail;
- physical and external QA remain pending unless executed;
- readiness percentages are evidence-based;
- final git status confirms only Docs/Scripts audit outputs changed.

Do not commit or push automatically.

Stop after producing the merged master code/sync/security/performance audit report, matrices, validation script and final summary.



# 4A. LATEST WATCH FULL COMPUTER DEVELOPMENT SCOPE — GF PRESETS, SHALLOW DEPTH AND WATER ENTRY

This forensic audit must now include the latest Watch development wave.

## 4A.1 Full Computer Gradient Factor preset audit

Inspect at minimum:

```text
Shared/Models/FullComputerGradientFactorPreset.swift
Shared/Models/DivePlanPackage.swift
Shared/Models/FullComputerDiveLogbookMetadata.swift
Services/FullComputerGradientFactorSettingsStore.swift
Services/FullComputerPrediveConfigurationStore.swift
Services/FullComputerImportedPlanStore.swift
Services/DIRActivitySelectionStore.swift
Services/DiveManager.swift
Views/FullComputerDivingSettingsView.swift
Views/FullComputerConservatismSettingsView.swift
Views/FullComputerGradientFactorsInfoView.swift
Views/FullComputerGradientFactorSelectionView.swift
Views/FullComputerGradientFactorCurrentValueView.swift
Views/FullComputerPrediveSettingsView.swift
Views/FullComputerPrediveConfirmationView.swift
Views/DiveDetailView.swift
Tests/**/FullComputerGradientFactor*
Docs/WATCH_FULL_COMPUTER_GRADIENT_FACTORS_SETTINGS.md
Docs/WATCH_FULL_COMPUTER_GRADIENT_FACTORS_IMPLEMENTATION_REPORT_CURRENT.md
Docs/QA_EVIDENCE/WATCH_FULL_COMPUTER_GF_*
```

Verify:

```text
Only supported presets are accepted on Watch.
No custom GF editor exists on Watch unless explicitly introduced and audited.
iOS plan GF override has higher precedence than Watch default only for imported/activated iOS plans.
Unsupported iOS GF pairs are rejected or safely handled.
Predive confirmation freezes a GF snapshot.
Runtime reads the frozen snapshot, not live UserDefaults.
Active Full Computer dive cannot change GF.
Logbook stores GF preset/source/low/high from the runtime snapshot.
GF does not appear in Gauge, Apnea or Snorkeling.
GF cannot be changed via Action Button / App Intent / water auto-open.
```

Create or update inside the report:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_GF_PRESET_MATRIX_CURRENT.csv
```

## 4A.2 Shallow-depth entitlement and developer testing audit

Inspect at minimum:

```text
Config/DIRDiving.WithShallowDepth.entitlements
Config/DIRDiving.WithWaterSubmersion.entitlements
Config/DIRDiving.entitlements
App/Info.plist
project.yml
Utils/DepthCapabilityPolicy.swift
Utils/DepthCapabilityResolver.swift
Utils/DepthCapabilityEntitlementProbe.swift
Services/AppleDepthSensorProvider.swift
Services/SensorProviderFactory.swift
Views/DeveloperSettingsView.swift
Utils/DeveloperSettings.swift
Tests/WatchAlgorithmTests/DepthCapabilityTests.swift
Docs/BUILD_AND_XCODEGEN_WORKFLOW.md
```

Verify:

```text
Default Watch signing intentionally uses the shallow-depth entitlement only when the provisioned capability supports it.
DIRDepthEntitlementTier = shallow is consistent with signed entitlements.
Full-depth behavior remains separate and requires full Apple capability/provisioning.
Shallow-depth capability does not imply full decompression-depth validation.
Developer shallow Gauge testing and developer shallow Full Computer testing are gated separately.
Developer shallow toggles are DEBUG/TestFlight/internal only and never public production defaults.
Shallow Full Computer runtime remains clearly labelled as internal testing only, not certified decompression guidance.
Simulation fallback cannot be confused with real Apple depth samples.
```

Create or update inside the report:

```text
Docs/MASTER_WATCH_DEPTH_CAPABILITY_SHALLOW_TESTING_MATRIX_CURRENT.csv
```

## 4A.3 Water auto-open interaction with Full Computer audit

Verify:

```text
Water auto-open may route to Diving Full Computer predive configuration/confirmation.
Water auto-open never starts Full Computer live runtime directly.
Water auto-open never bypasses environment confirmation.
Water auto-open never bypasses GF predive snapshot.
Water auto-open never mutates tissues, gases, GF, environment or runtime state.
System submerged auto-launch remains physical/watchOS evidence gated.
```

These checks must be cross-referenced with Audit 03, 04 and 05.

---
