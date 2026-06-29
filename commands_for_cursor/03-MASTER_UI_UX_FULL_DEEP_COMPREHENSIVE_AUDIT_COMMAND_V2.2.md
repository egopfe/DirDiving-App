# LAUNCH ORDER 03

**Launch order note:** THIRD — UI/UX audit. Run after core logic audits so the UI/UX review can verify that implemented behavior is reachable, truthful, activity-owned and visually coherent, including latest Watch underwater hardware interaction and water auto-open behavior.

**Canonical numbered filename:** `03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V2.1.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING UI/UX FULL DEEP COMPREHENSIVE AUDIT — V2.1

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Targets:**  

```text
DIRDiving Watch App
DIRDiving iOS
```

**Task type:** audit-only, read-only, full UI/UX, interaction, accessibility, localization, mockup, visual-regression and implementation-coherence audit  
**Scope:** Apple Watch + iOS Companion App  
**Updated for latest development:**  

```text
Multi-activity architecture: Diving / Apnea / Snorkeling
Diving submodes: Gauge / Full Computer
iOS Settings mode switcher
iOS editable Settings content for Diving / Apnea / Snorkeling
Dashboard gear routing to correct Settings mode
Apple Watch in-mode Settings access for Apnea and Snorkeling
Strict activity-specific Settings ownership
Strict activity-specific Logbook ownership
Watch Full Computer forensic audit integration
Planner briefing cards as reference-only
CCR / Rebreather reference-only UX
Mockup visual regression and implementation traceability
Apple Watch underwater Digital Crown page policy
Apple Watch Action Button / App Intent underwater primary action routing
Apple Watch underwater primary-action hint/toast UX
Water-entry / water auto-open routing policy
Watch water auto-open Settings UX and safety copy
Water Lock / physical underwater QA evidence gates
```

**Merged source commands:**

```text
4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED_V3.0.md
14-DIR_DIVING_MOCKUP_VISUAL_REGRESSION_AUDIT_V3.0.md
16-DIR_DIVING_COMPLETE_UI_UX_IMPLEMENTATION_COHERENCE_AUDIT_V1.1.md
```

This command supersedes the separate UI/UX readiness audit, mockup visual regression audit, and final implementation coherence audit by merging them into one single full deep comprehensive UI/UX audit command for both Apple Watch and iOS Companion.

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
- redesign screens;
- change UI;
- change UX;
- change visual identity;
- change graphics;
- change mockups;
- alter algorithms;
- alter Bühlmann math;
- alter CCR math;
- alter Ratio Deco logic;
- alter TTV/TTS semantics;
- alter Mission Mode semantics;
- alter Watch depth/ascent logic;
- alter Settings ownership;
- commit;
- push;
- merge.

You may create or update only the requested audit reports and matrices under `Docs/`.

If a defect is found, record it as an open finding with:

```text
severity
priority
activity
mode
platform
screen
entry point
affected files/symbols
observed behavior
expected behavior
coherence impact
completeness impact
safety impact
accessibility impact
localization impact
visual/mockup impact
regression impact
required remediation
acceptance tests
release impact
```

Do not implement the fix.

Never claim:

```text
physical Apple Watch QA
physical iPhone QA
paired-device QA
underwater QA
external Bühlmann validation
external decompression validation
external Subsurface validation
App Store approval
```

unless actual evidence exists.

If missing, mark:

```text
PENDING_PHYSICAL
PENDING_PAIRED_DEVICE_QA
PENDING_EXTERNAL_VALIDATION
NOT_EXECUTED
```

---

# 1. MASTER OBJECTIVE

Perform a complete, deep, integrated UI/UX audit of the current `main` implementation of DIR Diving across:

```text
Apple Watch App
iOS Companion App
```

The audit must verify whether every feature currently implemented in `main`:

- exists in the correct target;
- is reachable from the correct user flow;
- has a complete beginning-to-end interaction path;
- exposes correct inputs;
- shows correct outputs;
- uses correct terminology;
- preserves activity ownership;
- preserves mode ownership;
- is visually coherent;
- is functionally coherent with implementation;
- is localized in Italian and English;
- is accessible;
- handles empty, loading, partial, stale, error, unavailable and destructive states;
- does not expose unfinished/placeholder behavior as complete;
- does not duplicate or contradict another screen;
- does not create navigation dead ends;
- does not conceal safety-critical information;
- does not present reference-only data as live authority;
- does not regress previous implemented features;
- is consistent between Apple Watch and iOS where parity is intended;
- is intentionally different where platform-specific behavior is required;
- aligns with available mockups without embedding mockups as live UI;
- has deterministic visual-regression coverage or a clear gap;
- is ready for internal TestFlight, external TestFlight and App Store only where evidence supports that readiness.

This master command combines:

```text
Audit 4  → focused UI/UX, accessibility, localization and release-readiness audit
Audit 14 → mockup-path, visual-fidelity and visual-regression audit
Audit 16 → final implementation-coherence, completeness and regression audit
```

---

# 2. CURRENT PRODUCT ARCHITECTURE TO AUDIT

Audit the current architecture exactly as follows:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Both Apple Watch and iOS Companion must be treated as multi-activity applications.

Audit ownership must remain strict:

```text
Diving → Diving screens, settings, planner, logbook, data and exports
Apnea → Apnea screens, settings, planner/training, logbook, data and exports
Snorkeling → Snorkeling screens, settings, navigation, logbook, data and exports
```

For Diving:

```text
Diving
├── Gauge
└── Full Computer
```

The audit must verify that Gauge and Full Computer are:

- clearly distinguishable;
- functionally distinct;
- visually coherent;
- not misleadingly interchangeable;
- correctly selected and persisted;
- correctly represented in Settings;
- correctly represented in Live Dive;
- correctly represented in Logbook;
- correctly represented in Detail;
- correctly represented in exports;
- not mixed in UI copy or metrics.

---

# 3. LATEST DEVELOPMENT REQUIREMENTS TO INCLUDE

The audit must include and verify the latest developments:

## iOS Companion Settings

```text
iOS Companion Settings mode switcher
Diving / Apnea / Snorkeling selectable Settings scope
Editable Settings content directly visible below the switcher
No nested Form-in-ScrollView hiding activity Settings
Dashboard gear routing to Settings with correct initial mode
MoreView showing the same mode switcher and selected activity content
Mode switch does not mutate runtime
Mode switch does not remotely switch active Watch mode
Mode switch does not cause cross-activity leakage
```

## Apple Watch Settings Access

```text
Watch in-mode Settings access for Apnea
Watch in-mode Settings access for Snorkeling
Global Watch Settings page preserved
Activity-specific Watch Settings sections preserved
Active-session safety navigation blocks preserved
```

## Activity Settings ownership

Shared Settings may include only genuinely cross-activity concerns:

```text
Language
Units
Backup
Synchronization
Privacy
Appearance where supported
Global haptics where semantically valid
About
Legal
```

Activity Settings must remain separate:

```text
Diving Settings
├── Gauge / Full Computer defaults
├── Gas
├── GF
├── PPO2 / MOD
├── CNS / OTU
├── NDL / TTS / Ceiling
├── Deco-stop and gas-switch alerts
├── Environment / altitude where supported
└── Diving alarms
```

```text
Apnea Settings
├── Session detection
├── Recovery
├── Targets
├── Depth/time/speed alarms
├── Markers
├── Buddy / equipment where supported
└── Apnea profiles
```

```text
Snorkeling Settings
├── GPS
├── Route / Waypoints
├── Return to entry
├── Marker categories
├── Dip/session alarms
├── Photos / map privacy
└── Location privacy
```

Mandatory negative checks:

- CNS, OTU, PPO2, MOD, GF, gas and decompression settings must not appear in Apnea or Snorkeling.
- Apnea recovery and target-training settings must not appear in Diving or Snorkeling.
- Snorkeling GPS route, waypoint and return settings must not appear in Diving or Apnea.
- A Settings route must never mutate an active Watch session.
- A Settings route must never bypass safety/legal gating.

## Strict Logbook ownership

```text
Diving section → Diving Logbook only
Apnea section → Apnea Logbook only
Snorkeling section → Snorkeling Logbook only
```

A Logbook must be visible and reachable only inside its owning activity section.

Verify:

- no normal global mixed Logbook;
- no cross-activity menu route;
- no cross-activity deep link;
- no wrong state restoration;
- no mixed store query;
- no mixed filters;
- no mixed statistics;
- no mixed details;
- no mixed exports;
- no universal detail view with irrelevant optional fields.

Any cross-activity Logbook visibility or routing is P0.

## Apple Watch underwater hardware interaction and water auto-open

Audit the latest Apple Watch underwater interaction developments as first-class UI/UX and safety-reachability features.

Inspect at minimum:

```text
Utils/WatchUnderwaterPagePolicy.swift
Services/WatchUnderwaterActionRouter.swift
Views/WatchUnderwaterPrimaryActionHintView.swift
Services/ActionButtonIntents.swift
Views/ContentView.swift
Views/WatchWaterAutoOpenSettingsView.swift
Utils/WatchWaterAutoOpenPolicy.swift
Utils/DIRStartupSelectionPolicy.swift
Services/DIRActivitySelectionStore.swift
App/DIRDivingApp.swift
Views/SettingsView.swift
Tests/WatchAlgorithmTests/WatchUnderwaterActionRouterTests.swift
Tests/WatchAlgorithmTests/WatchWaterAutoOpenPolicyTests.swift
Docs/WATCH_UNDERWATER_FAST_CONTROLS_IMPLEMENTATION_REPORT_CURRENT.md
Docs/WATCH_WATER_AUTO_OPEN_IMPLEMENTATION_REPORT_CURRENT.md
Docs/WATCH_WATER_AUTO_OPEN_POLICY.md
Docs/QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_*
Docs/QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_*
```

Verify the latest behavior without changing the existing product logic:

```text
Digital Crown vertical paging remains the only normal underwater page-navigation model.
During active underwater sessions, page reachability is restricted by activity.
Diving active session allows only Live, Compass and User Images if images exist.
Apnea active session allows Live only.
Snorkeling active session allows Live only.
Settings, Logbook, mode selection and non-essential screens are blocked during active underwater sessions.
Blocked underwater navigation returns to Live and shows a clear toast.
Hardware primary action is context-aware and does not create unsafe hidden behavior.
Alarm / operational overlay acknowledgement has priority over non-critical actions.
Diving Live may start/stop stopwatch only when appropriate.
Full Computer hidden manual stopwatch state makes stopwatch action unavailable.
Compass page maps the primary action to set/update bearing.
User Images page maps the primary action to next image only when images exist.
Settings or other non-underwater pages map to return-to-dashboard or unavailable, never unsafe mutation.
Action Button / App Intent path requires legal acceptance.
Action Button / App Intent path does not bypass active-session, mode-selection or safety gates.
Action Button shortcut configuration requirement is clearly documented.
Side button / Crown press unsupported assumptions are not claimed.
Water auto-open mode supports Disabled, Last Selected Mode and Preferred Mode.
Water auto-open preferred destination is sanitized.
Non-diving water auto-open destinations force Gauge diving mode semantics where appropriate.
Water auto-open does not start a dive by itself.
Water auto-open does not bypass Full Computer predive configuration/confirmation.
Water auto-open does not bypass legal onboarding.
Water auto-open is blocked during any active Diving, Apnea or Snorkeling session.
System submerged Auto-Launch listing is not claimed unless Apple entitlement/provisioning and physical watchOS evidence exist.
Cold-launch water submersion detection limitations are disclosed.
Water auto-open Settings are disabled during an active dive/session where required.
Water auto-open Settings include truthful system-limitation and Full Computer warning copy.
```

Mandatory physical/evidence rule:

```text
Simulator tests may prove routing logic.
Only physical Apple Watch / Water Lock / Action Button / submerged auto-launch evidence may close physical readiness.
If physical evidence is unavailable, mark:
PENDING_PHYSICAL_WATER_LOCK_QA
PENDING_PHYSICAL_WATER_AUTO_OPEN_QA
PENDING_PHYSICAL_ACTION_BUTTON_QA
PENDING_WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_QA
```

Create findings for any unsupported claim that Apple Watch will automatically launch DIR Diving merely by entering water unless the code and physical evidence prove it.


## Mockup / visual regression

Audit recursively:

```text
mockups/**
Docs/ReferenceUI/**
snapshot fixtures
preview fixtures
visual-regression tests
```

No mockup may be embedded as live UI.

Mockups are design/reference artifacts only.

Every mockup must be mapped to:

```text
platform
activity
mode
screen
state
source view
route
preview fixture
snapshot test
visual fidelity result
functional fidelity result
accessibility state
```

---

# 4. RELATIONSHIP WITH FULL AUDIT SYSTEM

This master UI/UX audit must incorporate the outputs and requirements of all previous audits where visible, interaction-level or release-level consequences exist:

```text
0  Complete mathematical functions
1  iOS Bühlmann / Full Computer
2  Watch algorithms and runtime
3  iOS complete algorithms/data
4  UI/UX
5  Deep code analysis
6  Git/documentation alignment
7  Activity architecture, Settings and Logbooks
8  Sync, persistence and schemas
9  Security, privacy and trust
10 Performance, concurrency and battery
11 Localization and accessibility
12 Tests, QA and evidence
13 Release, legal claims and compliance
14 Mockups and visual regression
15 Watch live Bühlmann / Schreiner / multilevel decompression
16 Complete UI/UX implementation coherence
```

This audit must not mechanically repeat those reports.

It must verify whether their implementation outcomes now form a coherent product experience.

Any P0/P1 finding from audits 0–16 that has a visible or interaction-level consequence must be surfaced again under:

```text
affected screen
affected flow
affected user state
affected activity
affected platform
affected safety outcome
```

Any remediation affecting Full Computer must trigger re-run of the Watch Full Computer forensic audit and this UI/UX audit.

---

# 5. PRODUCT SAFETY AND CLAIMS POSITIONING

Preserve:

- non-certified diving companion positioning;
- no certified dive-computer claim;
- no certified decompression-planner claim;
- no CCR controller claim;
- no live loop PPO2 monitoring claim;
- no EN13319 / ISO 6425 / CE claim unless evidence exists;
- iOS Planner as reference/planning support unless formally validated;
- Watch briefing cards as reference-only;
- external validation pending unless actually executed;
- physical QA pending unless actually executed.

The UI must clearly preserve:

```text
Planner reference-only status
CCR reference-only status
No live loop PPO2 monitoring
No guaranteed decompression safety
CNS/OTU as estimates
Rock Bottom as planning estimate
Gas density as estimate
GPS surface-only limitations
Return-to-entry limitations
Briefing cards as pre-dive/reference data
Mission Mode limitations
Sensor simulation visibility
```

Unsupported release/legal claims are P0/P1.

---

# 6. OUTPUT FILES

Create or replace only these files:

```text
Docs/MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
Docs/MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_NAVIGATION_REACHABILITY_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_STATE_COMPLETENESS_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_CROSS_PLATFORM_PARITY_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_REGRESSION_RISK_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv
Docs/MASTER_MOCKUP_PATH_VALIDATION_CURRENT.csv
Docs/MASTER_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv
Docs/MASTER_VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv
Docs/MASTER_UI_UX_GAP_REMEDIATION_PLAN_CURRENT.md
Docs/MASTER_UI_UX_EXTERNAL_PHYSICAL_QA_PENDING_CURRENT.md
Docs/MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT_CURRENT.md
Docs/MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md
Docs/MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv
```

Do not create or update production files.

---

# 7. SEVERITY MODEL

## P0 — Safety-critical / release-blocking

Use P0 for:

- wrong activity ownership;
- wrong Logbook route;
- wrong Settings exposure that can change unsafe or wrong-domain state;
- live/reference confusion;
- hidden critical metric;
- false decompression state;
- stale data presented as current;
- destructive action without correct confirmation;
- route leading to unsafe interpretation;
- mockup/reference image embedded as live UI;
- visible placeholder presented as complete;
- cross-activity data contamination;
- Full Computer UI showing “no deco” while positive ceiling exists;
- Full Computer UI hiding required stop;
- Planner card shown as live decompression authority;
- CCR reference data shown as live CCR controller state;
- App Store/certification claim unsupported by evidence.

## P1 — Must fix before internal TestFlight

Use P1 for:

- major feature incomplete;
- feature implemented but unreachable;
- visible route to non-functional behavior;
- mode-incoherent flow;
- missing critical state;
- broken save/restore;
- major accessibility gap;
- major localization gap;
- major cross-platform mismatch;
- Settings switch confusing or not displaying selected content;
- Apnea/Snorkeling Settings incomplete or hidden;
- mockup fidelity failure on primary screen;
- regression of a previously completed primary flow.

## P2 — Must fix before external TestFlight

Use P2 for:

- partial UX;
- missing secondary state;
- inconsistent copy;
- cross-platform mismatch without safety impact;
- visual hierarchy weakness;
- recoverable navigation defect;
- incomplete snapshot coverage;
- incomplete mockup mapping;
- incomplete accessibility description for secondary feature.

## P3

Use P3 for polish, spacing, minor accessibility, minor visual mismatch, non-blocking inconsistency, documentation clarity.

## P4

Use P4 for optional enhancements.

---

# 8. PREFLIGHT

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
mockups/**
Docs/ReferenceUI/**
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
experimental exclusions
asset catalogs
localization files
available mockups
available screenshots
available snapshot evidence
available physical-device evidence
available accessibility evidence
```

If environment allows, run:

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
```

If tests are available:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Do not fix build or test failures. Record them.

---

# 9. COMPLETE FEATURE INVENTORY

Create:

```text
Docs/MASTER_UI_UX_FEATURE_IMPLEMENTATION_MATRIX_CURRENT.csv
```

Required columns:

```text
ID
Activity
Mode
Platform
Feature
Entry_Point
Screen
Owning_View
Owning_Store
Implementation_Status
Reachable
Interaction_Complete
State_Complete
Localized_IT
Localized_EN
Accessible
Persisted
Restored
Synced
Exported
Tested
Documented
Mockup_Aligned
Safety_Truthful
Readiness_Percent
Severity
Finding_IDs
Notes
```

At minimum include:

## Global

```text
onboarding
legal acceptance
activity selection
activity persistence
activity migration
shared Settings
About
privacy
backup
synchronization
language
units
appearance where supported
global haptics where valid
```

## Diving — Gauge

```text
mode selection
start dive
automatic start
live depth
runtime
average depth
max depth
ascent rate
TTV
alarms
reminders
Mission Mode
compass / BUSSOLA
GPS surface behavior
images
session completion
logbook
dive detail
export
Settings
```

## Diving — Full Computer

```text
mode selection
live depth
runtime
average/max depth
active gas
Bühlmann state
16 compartments where exposed
ceiling
NDL
TTS
decompression stops
gas switches
PPO2
MOD
CNS
OTU
Gradient Factors
multilevel behavior
stop-state presentation
error/stale state
session completion
logbook
detail
export
Settings
```

Full Computer UI must be checked against the latest Watch Full Computer forensic audit.

## iOS Planner

```text
Base
Deco
Technical
CCR/Rebreather
gas configuration
MOD/PPO2
Gradient Factors
ascent/descent speed settings
full Dive Runtime
deco stops
Emergency / Rock Bottom
gas ledger
available gas
average-depth gas-consumption option
repetitive dive
route summary
result completeness
Ratio Deco
tissue loading
narcosis/END
CNS/OTU
PDF
share
briefing card
Watch transfer
stale/partial/error state
```

## Equipment and Checklist

```text
structured equipment
REC template
TEC template
CCR template
custom template
equipment profile
gas cylinders
roles
checklist generation
operational checklist
planner import
planner export
checklist import
checklist export
CCR role preservation
completion state
readiness badge
PDF/export
```

## Logbook and Analysis

```text
Diving Logbook
Apnea Logbook
Snorkeling Logbook
filters
list
detail
manual dive
editing
profile chart
tissue chart
narcosis chart
CNS/OTU
gas details
equipment
notes
export
delete
sync
conflict
empty state
import
```

## Apnea

```text
activity root
session start
automatic detection
dive profile
depth/time
descent/ascent
surface interval
recovery
targets
alarms
markers
planner/profiles
statistics
records
buddy/equipment
Logbook
Settings
empty/error/restore states
```

## Snorkeling

```text
activity root
surface session
GPS
track
dips
waypoints
markers
return to entry
route planner
photos
privacy
Logbook
Settings
empty/error/permission states
```

## Watch-specific secondary systems

```text
Developer Sensor Source
App Intents
Action Button help
ExecuteUnderwaterPrimaryActionIntent
OpenWaterAutoLaunchModeIntent
WatchUnderwaterActionRouter
WatchUnderwaterPagePolicy
WatchUnderwaterPrimaryActionHintView
Water auto-open Settings
Water auto-open policy
Water Lock / physical water QA states
briefing cards
image inventory
image deletion
image paging
reminders
haptics-off
small-screen layout
localized logbook dates
transfer states
stale card states
```

---

# 10. INFORMATION ARCHITECTURE AUDIT

Audit:

- every major feature has one clear home;
- no feature appears in multiple conflicting sections;
- Shared Settings contain only cross-activity settings;
- activity Settings remain isolated;
- activity Logbooks remain isolated;
- no universal mixed Logbook;
- no cross-activity detail route;
- no cross-activity deep link;
- no cross-activity state restoration;
- no navigation stack duplication;
- no dead-end destination;
- no circular route without exit;
- back navigation predictable;
- modal ownership clear;
- destructive actions not buried;
- advanced features not exposed in simple modes without intent.

Create navigation trees for:

```text
Watch
iOS
Diving Gauge
Diving Full Computer
Apnea
Snorkeling
```

Every screen must have:

```text
valid entry
valid exit
owning activity
owning mode
state source
deep-link behavior
restoration behavior
```

---

# 11. REACHABILITY AUDIT

Create:

```text
Docs/MASTER_UI_UX_NAVIGATION_REACHABILITY_MATRIX_CURRENT.csv
```

For each implemented feature prove:

- visible entry point;
- correct label;
- correct availability condition;
- correct feature flag;
- correct target membership;
- no hidden implementation with no route;
- no visible route to placeholder-only implementation;
- no route blocked by stale state;
- no unreachable save/confirm action;
- no feature available only through accidental deep link;
- no settings page without return path;
- no user action requiring undocumented gesture.

A feature implemented but unreachable is incomplete.

A visible route to non-functional behavior is at least P1.

---

# 12. END-TO-END FLOW COMPLETENESS

Audit representative flows from beginning to end:

```text
Entry
Input
Validation
Confirmation
Execution
Result
Persistence
Restoration
Sync if applicable
Export if applicable
Error recovery
Exit
```

Required flows:

1. first launch;
2. legal acceptance;
3. activity selection;
4. Diving → Gauge;
5. Diving → Full Computer;
6. manual Watch dive;
7. automatic Watch dive;
8. Full Computer decompression dive;
9. gas switch;
10. deco stop;
11. session finalization;
12. Watch → iOS sync;
13. iOS Logbook detail;
14. manual dive creation;
15. Planner Base;
16. Planner Deco;
17. Planner Technical;
18. Planner CCR;
19. Planner → Equipment;
20. Equipment → Checklist;
21. Planner briefing card → Watch;
22. repetitive dive;
23. image transfer/delete;
24. Apnea session;
25. Snorkeling session;
26. backup/restore;
27. conflict state;
28. destructive deletion;
29. localization change;
30. unit change;
31. iOS Settings mode switch;
32. iOS Apnea Settings edit;
33. iOS Snorkeling Settings edit;
34. Watch Apnea Settings access;
35. Watch Snorkeling Settings access;
36. MoreView Settings switch and content.

---

# 13. SETTINGS OWNERSHIP AUDIT

Create:

```text
Docs/MASTER_UI_UX_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv
```

Columns:

```text
Setting_ID
Label
Activity
Mode
Shared
Platform
Screen
Backing_Store
Visible_In_Diving
Visible_In_Apnea
Visible_In_Snorkeling
Visible_In_iOS
Visible_In_Watch
Can_Edit_During_Active_Session
Syncs_To_Watch
Runtime_Effect
Accessibility_Label
Localization_EN
Localization_IT
Evidence
Pass
Notes
```

Audit:

```text
IOSCompanionSettingsRootView
IOSCompanionSettingsModeSwitcher
IOSCompanionSettingsScopeStore
IOSDivingSettingsEmbeddedContent
IOSApneaSettingsContent
IOSSnorkelingSettingsContent
IOSApneaSettingsForm
IOSSnorkelingSettingsForm
MoreView
IOSApneaRootView
IOSSnorkelingRootView
Dashboard gear buttons
Watch SettingsView
WatchActivitySettingsSections
WatchInModeSettingsAccessButton
ApneaView
SnorkelingView
```

Verify:

- switch visible;
- switch has Diving / Apnea / Snorkeling;
- selected activity content visible directly below switch;
- no nested `Form` hidden in `ScrollView`;
- Apnea Settings editable;
- Snorkeling Settings editable;
- Diving Settings intact;
- gear routes initial mode correctly;
- MoreView does not reset mode confusingly;
- mode switch no runtime mutation;
- mode switch no active Watch remote mutation;
- Settings sections do not cross-leak.

---

# 14. STRICT LOGBOOK OWNERSHIP AUDIT

Create:

```text
Docs/MASTER_UI_UX_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv
```

Columns:

```text
Logbook_ID
Activity
Platform
Entry_Point
List_View
Detail_View
Store
Session_Type
Filters
Statistics
Export
Sync
Deep_Link
Restoration
Visible_From_Diving
Visible_From_Apnea
Visible_From_Snorkeling
Cross_Activity_Leak
Evidence
Pass
Notes
```

Mandatory checks:

- Diving route sees only Diving sessions.
- Apnea route sees only Apnea sessions.
- Snorkeling route sees only Snorkeling sessions.
- No mixed query.
- No universal detail with irrelevant optional fields.
- No mixed export.
- No mixed statistics.
- No wrong state restoration.
- No wrong sync import path.

Any cross-activity Logbook route is P0.

---

# 15. MODE COHERENCE AUDIT

Audit product modes:

```text
Gauge
Full Computer
Base Planner
Deco Planner
Technical Planner
CCR Planner
Apnea
Snorkeling
```

Verify:

- labels distinct;
- behavior distinct;
- inputs match mode;
- outputs match mode;
- warnings match mode;
- Settings match mode;
- hidden data does not leak;
- inactive mode state does not affect active calculations;
- mode switching preserves user confidence;
- advanced data retained where intended;
- simpler modes do not expose irrelevant complexity;
- exports identify mode;
- Logbook identifies mode;
- Watch/iOS sync identifies mode;
- accessibility identifies mode.

Mandatory distinctions:

```text
Gauge TTV ≠ Full Computer TTS
Gauge ≠ Full Computer
OC ≠ CCR
Planner output ≠ live Watch decompression authority unless explicitly implemented
Briefing card ≠ live calculation
```

Any terminology collision is P0/P1 depending on safety impact.

---

# 16. WATCH UI/UX AUDIT

Audit all Watch screens and states.

## Live metrics

Verify hierarchy and visibility of:

```text
current depth
runtime
average depth
max depth
ascent rate
TTV or TTS
ceiling
current stop
stop time
active gas
warning state
sensor state
simulation state
Mission Mode
haptics-off
stale/error state
```

## Full Computer UI

Using latest Full Computer forensic audit requirements, verify UI truthfulness for:

```text
deco appears
deco reduces
deco clears
deco reappears
controlling compartment changes if exposed
schedule changes
multilevel behavior
gas switch
stop pause
stop restart
stale calculation
algorithm failure
sensor failure
```

The UI must never:

- show “no deco” while positive ceiling exists;
- hide a required stop;
- continue stop credit outside tolerance;
- conflate stale data with current data;
- show planner card values as live state;
- show zero when data is missing.

## Small Watch layout

Test smallest supported Watch and Apple Watch Ultra states:

```text
multiple banners
reminder
depth warning
ascent warning
decompression stop
sensor stale
GPS/sync
Mission Mode
haptics-off
briefing card
image page
```

Critical metrics must remain visible.

---

# 17. iOS UI/UX AUDIT

Audit:

```text
Dashboard
Activity selection
Logbooks
Dive details
Manual entry
Analysis
Planner
Equipment
Checklist
Watch sync
Images
Backup
Settings
More
PDF/share
Errors
Empty states
```

Verify:

- same visual language;
- consistent section hierarchy;
- consistent card behavior;
- consistent button placement;
- consistent save/cancel semantics;
- consistent destructive action style;
- consistent warnings;
- consistent loading indicators;
- consistent navigation titles;
- consistent units;
- consistent terminology;
- no duplicate setting in multiple screens;
- no obsolete screen remains reachable;
- no stale preview conflicts with final result.

---

# 18. PLANNER UI/UX AUDIT

Audit Planner UX across:

```text
Base
Deco
Technical
CCR
Ratio Deco
```

Verify inputs:

```text
depth
average depth
runtime
gas
cylinders
PPO2
GF
environment
ascent/descent speed
emergency inputs
repetitive-dive inputs
CCR inputs
```

Verify outputs:

```text
summary
NDL
ceiling
stops
TTS
runtime
gas use
reserve
Rock Bottom
CNS/OTU
tissues
narcosis
Ratio Deco
warnings
PDF
briefing card
```

Verify:

- output backed by canonical result;
- partial results not presented complete;
- old result disappears after invalid input;
- loading state explicit;
- error state explicit;
- mode-specific detail appropriate;
- average-depth gas option disclosed;
- CCR assumptions visible;
- external validation limitations visible;
- no certified claim.

---

# 19. PLANNER ASCENT SPEED / RUNTIME / DECO STOPS UX AUDIT

Audit:

- ascent-speed settings discoverability;
- defaults/reset;
- unit labels;
- validation/error copy;
- persistence feedback;
- relationship between settings and runtime estimates;
- full Dive Runtime table;
- ordering of descent, bottom, travel, gas switch, deco stop and final ascent rows;
- dedicated decompression-stop section;
- consistency between summary, runtime table, chart and PDF.

Verify:

- user understands ascent speeds affect planning estimates;
- UI does not imply control of diver’s actual ascent;
- invalid speed values cannot appear accepted;
- runtime table scannable;
- decompression stops visually distinct from transit rows;
- VoiceOver reads phase, depth, duration and cumulative runtime.

---

# 20. EMERGENCY / ROCK BOTTOM UX AUDIT

Audit:

- Emergency section entry;
- Rock Bottom terminology;
- team/diver count;
- stressed RMV/SAC;
- problem-solving time;
- required emergency gas;
- available gas comparison;
- liters and bar display;
- warning hierarchy;
- disclosure that emergency gas is separate from normal planned consumption;
- Technical average-depth interaction;
- CCR bailout interaction if present;
- PDF/share/briefing-card output.

Verify insufficiency is unmistakable and normal gas/emergency reserve are visually separate.

---

# 21. GAS LEDGER / AVAILABLE GAS UX AUDIT

Audit:

- Available Gas section;
- liters as primary quantity;
- cylinder-equivalent bar;
- per-cylinder identity;
- used/reserve/remaining values;
- role labels;
- insufficiency states;
- hidden/unused bailout;
- CCR diluent/bailout separation;
- compact iPhone layouts;
- PDF/card consistency.

Verify liters and bar are not visually interchangeable.

---

# 22. TECHNICAL AVERAGE-DEPTH GAS OPTION UX AUDIT

Verify:

- appears only in Technical mode;
- default conservative max-depth behavior clear;
- copy states only gas-consumption estimate changes;
- decompression, MOD, PPO2, switch depth and Rock Bottom not implied to change;
- selected state accessible;
- PDF/share/briefing-card disclose selected basis;
- switching modes does not leave confusing hidden state.

---

# 23. CCR / REBREATHER UX AUDIT

Audit:

```text
CCR entry point
setpoint low
setpoint high
setpoint switch depth
diluent gas
bailout gas
bailout switch depth
CCR oxygen exposure
CCR CNS / OTU
CCR tissue loading
CCR narcosis / END
gas density
bailout scenario
checklist import/export
PDF/share
Logbook/manual dive representation
```

Verify safety copy:

- CCR planning is reference-only;
- app is not certified CCR controller;
- app does not monitor live loop PPO2;
- app does not replace CCR handset/controller/HUD;
- setpoint values are assumed planning values;
- bailout planning is indicative;
- diver training and manufacturer procedures remain primary.

CCR UI must clearly separate:

```text
CCR setpoint phase
diluent role
OC bailout phase
deco phase if any
```

Setpoint PPO2 must be visually distinct from FO2-based PPO2.

---

# 24. RATIO DECO UX AUDIT

Audit:

- entry point;
- presets 1:1, 2:1, custom;
- custom controls;
- comparison mode;
- Bühlmann primary validation layer;
- overlay chart;
- warnings;
- export integration;
- accessibility.

Verify Ratio Deco is clearly heuristic/comparative and not certified.

CCR profiles must not incorrectly use OC Ratio Deco unless explicitly supported and labelled.

---

# 25. TISSUE / NARCOSIS / CNS / OTU UX AUDIT

Audit:

```text
tissue loading cards
16 compartments
grouped compartments
controlling compartment
tissue timeline
ceiling
GF-relative loading
M-value-relative loading
PPN2
END
EAD if present
active gas timeline
CNS
OTU
warnings
Planner integration
Logbook integration
Manual Dive integration
CCR integration
```

Verify:

- charts are model-backed;
- no fake/static chart shown as real;
- axes/units clear;
- legends readable;
- accessibility summary exists;
- source label is recorded/planned/simulated/CCR where relevant.

---

# 26. GAS ROLE UX AUDIT

Audit gas roles:

```text
Back Gas
Travel
Decompression
Bailout
Diluent
CCR bailout
Oxygen
Standby / unused planned gas
```

Verify:

- visually distinct;
- localized;
- clear role meaning;
- correct controls per role;
- used vs unused gas clear;
- bailout not included in scheduled consumption unless actually used;
- diluent not confused with OC gas in CCR;
- CCR bailout clearly OC bailout;
- role appears correctly in checklist, PDF/share and export.

---

# 27. EQUIPMENT / CHECKLIST UX AUDIT

Audit:

```text
My Equipment
REC templates
TEC templates
CCR templates
custom templates
equipment items
task items
gas items
Back Gas
Deco Stage
Travel
Bailout
Diluent
Oxygen cells / CCR tasks if implemented
scrubber / sorb task if implemented
READY badge
DIR badge
duplicate prevention
Planner ↔ Checklist sync
structured Equipment setup
Equipment → Planner navigation
Equipment → Checklist navigation
operational task grouping
gas-linked equipment
cylinder size / pressure / mix display
CCR checklist import
CCR checklist export
Equipment Setup PDF
```

Verify stable IDs, no duplicates, manual edits preserved, role preservation and accessibility.

---

# 28. PDF / SHARE / EXPORT UX AUDIT

Audit:

```text
Planner PDF
Briefing PDF
Checklist PDF
Dive Pack PDF
Logbook export
CSV export
Subsurface export
Share Sheet
WhatsApp
Mail
AirDrop
Files
Planner briefing card / PNG to Apple Watch
```

Verify:

- mode label appears;
- CCR setpoint/diluent/bailout correct;
- gas/deco plans understandable;
- Ratio Deco comparison clear;
- tissue/narcosis charts correct if exported;
- checklist YES/NO printable;
- disclaimers present;
- no certification implication;
- filenames safe;
- exported values match UI;
- units clear;
- briefing cards reproduce canonical plan;
- PNG and metadata consistent;
- card status pending/transferred/failed/stale;
- cards are pre-dive/reference-only.

---

# 29. IMAGE TRANSFER / WATCH IMAGE MANAGEMENT UX AUDIT

Audit:

```text
image selection on iOS
image preprocessing
resolution validation
conversion warnings
Watch visibility before dive
Watch visibility during dive
Watch full-screen view
horizontal swipe paging
page indicator
Watch image list
Watch image delete
iOS Watch image inventory
iOS delete request
Watch ACK
stale / unavailable states
```

Verify Watch remains source of truth and iOS does not invent inventory or show delete success before Watch ACK.

---

# 30. WATCH DIVE START, WATER AUTO-OPEN AND UNDERWATER HARDWARE UX AUDIT

Audit:

```text
initial Live screen
manual Start Dive button
automatic dive start when depth > 1.0 m
duplicate session prevention
manual + automatic collision
restore after relaunch
active draft consistency
Settings copy
App Intent / Action Button start if implemented
OpenWaterAutoLaunchModeIntent
ExecuteUnderwaterPrimaryActionIntent
WatchWaterAutoOpenPolicy
WatchUnderwaterPagePolicy
WatchUnderwaterActionRouter
Digital Crown vertical paging
underwater blocked-navigation toast
underwater primary-action hint
Water Lock physical behavior
watchOS system water auto-launch listing
```

Verify user understands manual vs automatic start and simulator/fallback is clearly marked.

## 30.1 Water auto-open audit

Verify:

```text
Water auto-open defaults to disabled.
Water auto-open modes are Disabled, Last Selected Mode and Preferred Mode.
Preferred destination supports Diving, Apnea and Snorkeling.
Preferred Diving mode supports Gauge and Full Computer.
Full Computer preferred auto-open routes to predive configuration/confirmation, not straight into live decompression runtime.
Water auto-open does not start a dive by itself.
Water auto-open only prepares/routs the app to the intended activity/mode.
Water auto-open never bypasses legal onboarding.
Water auto-open never bypasses Full Computer environment confirmation.
Water auto-open never mutates active Watch runtime.
Water auto-open is blocked during any active Diving, Apnea or Snorkeling session.
Water auto-open Settings are disabled during active Diving sessions.
System auto-launch listing is not claimed without Apple entitlement/provisioning and physical watchOS evidence.
Cold-launch submersion detection limitations are explicitly disclosed.
```

Mandatory negative tests:

```text
disabled mode follows normal startup
last selected mode restores last selected Diving Gauge
last selected mode restores last selected Diving Full Computer as predive
last selected mode restores Apnea as Apnea live-ready
last selected mode restores Snorkeling as Snorkeling live-ready
preferred Diving Gauge routes ready
preferred Diving Full Computer routes predive configuration
preferred Apnea routes ready
preferred Snorkeling routes ready
corrupt mode falls back disabled
corrupt activity falls back safe default
corrupt diving mode falls back Gauge
active Diving blocks water auto-open
active Apnea blocks water auto-open
active Snorkeling blocks water auto-open
legal acceptance required for OpenWaterAutoLaunchModeIntent
OpenWaterAutoLaunchModeIntent does not call startManualDive()
```

## 30.2 Digital Crown underwater page policy audit

Verify:

```text
Before active session, normal activity page policy applies.
During active Diving session, allowed pages are Live and Compass plus User Images only if images exist.
During active Apnea session, allowed page is Live only.
During active Snorkeling session, allowed page is Live only.
Settings page is not reachable during active underwater session.
Logbook page is not reachable during active underwater session.
Mode selection page is not reachable during active underwater session.
If Crown/page navigation lands on a forbidden page, app clamps back to Live.
Blocked navigation displays an underwater blocked-navigation toast.
The toast does not hide critical safety data.
The Crown hint is shown only when useful and not during an active session.
```

Mandatory negative tests:

```text
Diving active + attempt Settings → Live + toast
Diving active + attempt Logbook → Live + toast
Diving active + no images + attempt User Images → Live + toast
Diving active + images + User Images allowed
Apnea active + attempt Compass → Live + toast
Apnea active + attempt Settings → Live + toast
Snorkeling active + attempt Compass → Live + toast
Snorkeling active + attempt Settings → Live + toast
```

## 30.3 Action Button / hardware primary action audit

Verify:

```text
Action Button / App Intent requires legal acceptance.
Action Button / App Intent uses WatchUnderwaterActionRouter only.
Action Button / App Intent does not bypass active-session checks.
Action Button / App Intent does not start a dive in hidden way.
Action Button / App Intent does not reset stopwatch.
Action Button / App Intent does not clear bearing unexpectedly.
Alarm warning acknowledgement has highest priority.
Apnea operational overlay acknowledgement has highest priority.
Diving Live page toggles stopwatch only when session active and stopwatch is not hidden by Full Computer.
Full Computer hidden stopwatch state returns unavailable.
Compass page sets/updates bearing.
User Images page advances image only if images exist.
Settings returns to Live/Dashboard or unavailable; it must not mutate Settings while underwater.
Unavailable state shows toast and warning haptic only.
Side button and Crown press are not claimed unless physically supported and evidenced.
Action Button shortcut configuration requirement is documented.
```

Mandatory physical QA:

```text
real Apple Watch Ultra
Water Lock enabled
Action Button shortcut assigned to ExecuteUnderwaterPrimaryActionIntent
Action Button pressed during Diving Live
Action Button pressed during Full Computer hidden stopwatch state
Action Button pressed on Compass
Action Button pressed on User Images
Action Button pressed during alarm
Action Button pressed during Apnea overlay
Digital Crown scroll/page attempt underwater
blocked page attempt underwater
haptic/toast visibility under Water Lock
```

If not executed, mark all physical items as `PENDING_PHYSICAL`.

## 30.4 Required outputs for this subsection

Create:

```text
Docs/MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT_CURRENT.md
Docs/MASTER_WATCH_UNDERWATER_HARDWARE_INTERACTION_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_WATER_AUTO_OPEN_AUDIT_CURRENT.md
Docs/MASTER_WATCH_WATER_AUTO_OPEN_QA_MATRIX_CURRENT.csv
```

Matrix columns:

```text
Requirement_ID
Area
Feature
Source_File
Source_Symbol
Expected_Behavior
Automated_Test
Simulator_Evidence
Physical_QA
Water_Lock_QA
Action_Button_QA
Digital_Crown_QA
Legal_Gate
Safety_Gate
Result
Severity
Finding_ID
Notes
```

---

# 31. WATCH REMINDERS UX AUDIT

Audit:

```text
multiple reminders
single reminder
recurring reminder
scheduling persistence
runtime trigger accuracy
message length
overlay rendering
aggregation
haptic integration
safety alert priority
tap-to-dismiss
auto-dismiss
suppression under critical depth/ascent alerts
```

Reminder overlay must not cover essential safety data.

---

# 32. MISSION MODE UX AUDIT

Verify Mission Mode does not alter:

```text
depth sampling
runtime
max depth
average depth
TTV
ascent rate
GPS capture
safety alarms
reminder timing
sync payloads
export values
Full Computer tissue updates
```

Verify icon/state visibility, auto-enable clarity and truthful Low Power wording.

---

# 33. DEVELOPER SENSOR SOURCE UX AUDIT

Audit:

```text
Settings > Developer > Sensor Source
Automatic
Apple Sensor
Simulation
```

Verify:

- hidden behind developer unlock;
- not exposed to public users;
- simulation clearly identified;
- simulation never release default;
- automatic remains production default;
- fallback/mock state visible;
- Info explains resolved sensor source;
- user cannot confuse simulation with real underwater depth.

---

# 34. BRANDING / ICONOGRAPHY UX AUDIT

Verify:

- Watch app icon;
- iOS icon;
- octopus icon;
- Mission Mode icon near octopus;
- consistency across screens;
- underwater visibility;
- no safety-data obstruction;
- branding in screenshots/PDF/onboarding if applicable;
- briefing cards use branding without obscuring safety/reference data.

---

# 35. MANUAL DIVE UX AUDIT

Audit:

```text
manual dive creation
max depth
average depth
GPS start/end
profile
equipment
gas data
bar in/out
deco notes
CCR manual fields if implemented
tissue integration
narcosis integration
export consistency
logbook consistency
```

Manual/no-depth sessions must be truthful.

CCR manual dive must not imply live CCR data.

---

# 36. LOCALIZATION AUDIT

Audit EN/IT localization for:

```text
onboarding
Watch Live
Watch Settings
Watch reminders
Mission Mode
Sensor Source
Planner Base / Deco / Technical
CCR / Rebreather
Ratio Deco
Tissue
Narcosis
MOD / PPO2 / Dalton
Checklist
PDF / Share
Manual Dive
Image Transfer
Cloud / Sync
Planner ascent-speed settings
Dive Runtime / deco stops
Emergency / Rock Bottom
Available Gas / gas ledger
structured Equipment / operational checklist
Planner briefing cards
Date formatting
Error states
Apnea
Snorkeling
Settings mode switch
Logbook ownership labels
```

Mandatory terminology:

```text
BUSSOLA, never COMPASSO
Gauge TTV
Full Computer TTS
Ceiling
Deco stop
Gas switch
Back Gas
Travel Gas
Deco Gas
Bailout
Diluent
Setpoint
Surface interval
Apnea dive
Snorkeling dip
```

---

# 37. ACCESSIBILITY AUDIT

Audit:

```text
VoiceOver labels
VoiceOver hints
selected state
chart summaries
button labels
destructive confirmation
Dynamic Type
color contrast
reduced motion
touch targets
Watch tap targets
underwater readability
glove usability
haptic/visual redundancy
warning priority
```

Specifically check:

```text
Planner tabs
CCR setpoint controls
gas cards
MOD / switch-depth controls
Ratio Deco chart
Tissue chart
Narcosis chart
Checklist
Watch reminders
Watch image delete
Watch live safety overlays
Mission Mode indicator
CCR PPO2/END/PPN2/gas-density summaries
Watch photo transfer panel
structured Equipment checklist toggles
selected Tissue/Narcosis tabs
haptics-off badge
underwater navigation toast
Planner briefing-card inventory/detail
Emergency/Rock Bottom values
Dive Runtime rows
gas ledger liters/bar
Apnea Settings
Snorkeling Settings
Settings mode switch
```

Safety-critical state must not rely only on:

```text
color
animation
haptic
icon
position
```

---

# 38. UNIT CONSISTENCY UX AUDIT

Verify globally:

```text
meters ↔ feet
bar ↔ psi
Celsius ↔ Fahrenheit
m/min ↔ ft/min
liters
cubic feet if used
setpoint/PPO2 units
CCR diluent units
bailout pressure units
RMV/SAC
gas density
```

Across:

```text
Planner
CCR
Charts
Tissue
Narcosis
Logbook
Checklist
PDF
CSV
Briefing cards
Watch Live
Watch Settings
Watch Dive Details
Watch Export
Reminders
Apnea
Snorkeling
```

---

# 39. ERROR / EMPTY / EDGE STATE UX AUDIT

Create:

```text
Docs/MASTER_UI_UX_STATE_COMPLETENESS_MATRIX_CURRENT.csv
```

Every screen/feature must be checked for:

```text
initial
empty
loading
success
partial
stale
offline
unavailable
permission denied
validation error
algorithm error
sync error
conflict
destructive confirmation
deletion complete
retry
restored state
future schema
unsupported data
accessibility state
```

Include:

```text
no dives
no Watch paired
Watch unreachable
no iCloud
cloud backup off
cloud backup too large
sync pending
sync failed
invalid gas
invalid CCR setpoint
invalid MOD
switch depth beyond MOD
invalid environment
no GPS
no temperature
no tissue data
no narcosis data
no images
image delete failed
image inventory stale
export failed
PDF failed
CSV failed
legal onboarding not accepted
sensor unavailable
simulation active
partial calculation
stale previous Planner result
invalid ascent speed
insufficient emergency gas
missing cylinder for bar equivalent
briefing-card transfer pending
briefing-card transfer failed
stale/superseded briefing card
malformed briefing card
unsupported briefing-card schema
CCR checklist import conflict
Apnea permissions missing
Snorkeling GPS permission denied
Settings content unavailable
```

---

# 40. MOCKUP PATH AND VISUAL REGRESSION AUDIT

Recursively inventory:

```text
mockups/**
Docs/ReferenceUI/**
```

Create:

```text
Docs/MASTER_MOCKUP_PATH_VALIDATION_CURRENT.csv
Docs/MASTER_MOCKUP_IMPLEMENTATION_MATRIX_CURRENT.csv
Docs/MASTER_VISUAL_REGRESSION_COVERAGE_MATRIX_CURRENT.csv
```

For every mockup verify:

```text
path existence
exact casing
dimensions
hash
owning platform
owning activity
owning mode
screen/state
source view
presentation model
feature flag
preview fixture
snapshot test
Italian fixture
English fixture
smallest device
large device
visual fidelity
functional fidelity
accessibility
```

No mockup may be embedded as live UI.

Dedicated matrix columns:

```text
Mockup_ID
Path
Exists
Exact_Casing
Dimensions
Hash
Platform
Activity
Mode
Screen
State
Source_View
Route
Preview_Fixture
Snapshot_Test
Visual_Fidelity
Functional_Fidelity
Accessibility_Coverage
Localized_IT
Localized_EN
Small_Device
Large_Device
Readiness_Percent
Finding_ID
Notes
```

Verify:

- iOS startup selection mockups;
- Watch startup selection mockups;
- Diving Gauge;
- Diving Full Computer;
- Apnea;
- Snorkeling;
- Settings;
- Logbooks;
- Planner;
- Equipment;
- Checklist;
- Sync;
- Briefing cards;
- Watch live states;
- smallest Watch;
- Apple Watch Ultra;
- supported iPhones.

---

# 41. VISUAL COHERENCE AUDIT

Audit visual consistency against:

```text
current design system
current mockups
ReferenceUI
snapshot evidence
real screenshots where available
```

Verify:

- typography;
- spacing;
- card radius;
- iconography;
- color semantics;
- warning levels;
- disabled states;
- selected states;
- empty states;
- loading states;
- charts;
- tables;
- buttons;
- destructive styles;
- Watch/iOS brand identity;
- octopus branding;
- marine/cyan iOS style;
- dark/neon Watch style;
- Full Computer safety hierarchy.

---

# 42. CROSS-PLATFORM PARITY

Create:

```text
Docs/MASTER_UI_UX_CROSS_PLATFORM_PARITY_MATRIX_CURRENT.csv
```

Classify each feature as:

```text
Watch-only
iOS-only
shared
synchronized
reference-only
intentionally asymmetric
```

Verify parity for:

```text
names
units
mode labels
gas labels
dates
alarm names
reminder names
Mission Mode status
planner cards
dive metadata
Logbook values
Settings labels
error states
sync states
accessibility labels
```

A platform difference must be intentional and documented.

---

# 43. REGRESSION AUDIT

Create:

```text
Docs/MASTER_UI_UX_REGRESSION_RISK_MATRIX_CURRENT.csv
```

Audit whether recent implementations regressed:

```text
startup
activity selection
Gauge
Full Computer
Apnea
Snorkeling
Planner modes
gas cards
MOD/PPO2
stops
runtime
Rock Bottom
gas ledger
Equipment
Checklist
Logbooks
sync
briefing cards
images
reminders
Mission Mode
Developer settings
localization
accessibility
small Watch layout
Settings mode switch
Apnea Settings
Snorkeling Settings
mockup visual fidelity
```

Identify:

```text
replaced screen
duplicate route
hidden old screen
state mismatch
obsolete copy
old mockup assumptions
stale tests
conflicting documentation
```

---

# 44. TEST AND EVIDENCE REVIEW

Inventory:

```text
unit tests
UI tests
snapshot tests
preview fixtures
simulator evidence
physical Watch evidence
physical iPhone evidence
paired-device evidence
accessibility evidence
localization evidence
mockup comparison
underwater evidence
external validation
```

No evidence means not passed.

Create requirement-to-screen-to-test map.

---

# 45. RELEASE READINESS MATRIX

The report must include readiness percentages for:

```text
Global architecture
Activity selection
Shared Settings
Diving Settings
Apnea Settings
Snorkeling Settings
Settings mode switch
Diving Logbook
Apnea Logbook
Snorkeling Logbook
Gauge Watch
Full Computer Watch
Full Computer deco UI
iOS Planner Base
iOS Planner Deco
iOS Planner Technical
iOS Planner CCR
Planner ascent-speed settings
Dive Runtime
Deco Stops
Emergency / Rock Bottom
Gas Ledger / Available Gas
Technical average-depth gas option
CCR / Rebreather UX
Ratio Deco UX
MOD / PPO2 / Dalton UX
Switch Depth UX
Gas Role UX
Tissue Loading UX
Narcosis UX
Checklist UX
Planner ↔ Checklist UX
Structured Equipment UX
Operational Checklist UX
CCR Checklist Import/Export UX
Manual Dive UX
PDF / Share UX
Planner Briefing Card UX
Watch Briefing Card Inventory UX
Image Transfer UX
Watch Image Inventory/Delete UX
Watch Reminder UX
Reminder Dismiss/Suppression UX
Small-Watch Safety Layout UX
Watch Image Paging UX
Watch Date Localization UX
Dive Start UX
Mission Mode UX
Sensor Source UX
Branding UX
Localization UX
Accessibility UX
Unit Consistency UX
Error / Empty State UX
Mockup Path Validity
Mockup Implementation Traceability
Visual Regression Coverage
Internal TestFlight UI/UX Readiness
External TestFlight UI/UX Readiness
App Store UI/UX Readiness
Overall UI/UX Readiness
```

Every percentage must cite evidence.

---

# 46. FINDING FORMAT

Every finding must include:

```text
ID
Title
Severity
Priority
Activity
Mode
Platform
Screen
Entry point
Affected file
Affected symbol
Observed behavior
Expected behavior
Coherence impact
Completeness impact
Safety impact
Accessibility impact
Localization impact
Visual/mockup impact
Regression impact
Reproduction steps
Evidence
Proposed remediation
Acceptance criteria
Required tests
Estimated effort
Regression risk
Related audits
```

---

# 47. REMEDIATION PLAN

Create:

```text
Docs/MASTER_UI_UX_GAP_REMEDIATION_PLAN_CURRENT.md
```

Group work into:

## P0 — must fix before any safety-critical use

```text
wrong activity route
wrong Logbook
unsafe Settings exposure
hidden critical metric
stale/live confusion
false decompression state
destructive action defect
mockup embedded as live UI
```

## P1 — must fix before internal TestFlight

```text
incomplete primary flow
unreachable implementation
missing error state
broken persistence
major accessibility
major localization
mode incoherence
primary visual mismatch
Settings mode switch incomplete
Apnea/Snorkeling Settings incomplete
```

## P2 — must fix before external TestFlight

```text
cross-platform inconsistency
visual hierarchy issue
secondary state gap
partial export
minor navigation issue
visual regression coverage gap
```

## P3 — before App Store polish

```text
spacing
icon consistency
copy refinement
optional accessibility enhancement
minor mockup mismatch
```

For each remediation item include:

```text
affected audit(s) to rerun
acceptance criteria
test requirement
manual QA requirement
physical QA requirement if any
```

Any remediation affecting Full Computer must rerun:

```text
Watch Full Computer forensic audit
Master UI/UX audit
```

---

# 48. MASTER REPORT STRUCTURE

Create:

```text
Docs/MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Commands Merged  
C. Latest Development Update  
D. Scope and Commit  
E. Relationship to Audits 0–16  
F. Product Architecture  
G. Feature Inventory  
H. Information Architecture  
I. Reachability  
J. End-to-End Flow Completeness  
K. Settings Mode Switch and Activity Settings  
L. Strict Logbook Ownership  
M. Mode Coherence  
N. Watch UI/UX  
O. Full Computer UI/UX  
P. iOS UI/UX  
Q. Planner UI/UX  
R. Planner Runtime / Emergency / Gas Ledger  
S. CCR / Rebreather UX  
T. Ratio Deco UX  
U. Tissue / Narcosis / CNS / OTU UX  
V. Equipment / Checklist UX  
W. PDF / Share / Export UX  
X. Planner Briefing Card / Watch Transfer UX  
Y. Image Transfer / Watch Image Management UX  
Z. Dive Start / Reminders / Mission Mode / Sensor Source UX  
AA. Manual Dive UX  
AB. Localization  
AC. Accessibility  
AD. Unit Consistency  
AE. Error / Empty / Edge States  
AF. Mockup Path Validation  
AG. Mockup Implementation Traceability  
AH. Visual Regression Coverage  
AI. Visual Coherence  
AJ. Cross-Platform Parity  
AK. Regression Findings  
AL. Test / Evidence Coverage  
AM. Release Readiness Matrix  
AN. Detailed Findings  
AO. Prioritized Remediation Plan  
AP. TestFlight UX Checklist  
AQ. App Store UX Checklist  
AR. Screenshot / Marketing Asset Checklist  
AS. External / Physical QA Pending  
AT. Final Verdict

---

# 49. REQUIRED FINAL QUESTIONS

The report must explicitly answer:

1. Is the UI/UX truly multi-activity?
2. Are Diving, Apnea and Snorkeling first-class product areas?
3. Are Gauge and Full Computer clearly separated?
4. Is the iOS Settings mode switch implemented, visible and safe?
5. Are Apnea/Snorkeling Settings editable and visible?
6. Are Settings activity-owned without leakage?
7. Are Logbooks activity-owned without leakage?
8. Are all implemented features reachable?
9. Are all primary flows complete end-to-end?
10. Are all critical states represented?
11. Are placeholder/demo/reference elements prevented from appearing complete?
12. Is Full Computer UI truthful against live decompression state?
13. Does Watch UI distinguish Gauge TTV from Full Computer TTS?
14. Are planner briefing cards reference-only?
15. Is CCR UX reference-only and not controller-like?
16. Is Ratio Deco UX clearly heuristic/comparative?
17. Is Rock Bottom visually separated from normal gas consumption?
18. Are liters/bar gas-ledger values understandable?
19. Is Technical average-depth gas option accurately disclosed?
20. Is structured Equipment/checklist navigation coherent?
21. Are CCR checklist import/export flows clear?
22. Are PDF/share/export values consistent with UI?
23. Are Watch briefing cards numerically faithful and reference-only?
24. Are image transfer/delete flows truthful?
25. Are reminders safe and subordinate to critical alerts?
26. Is Mission Mode truthful and non-algorithmic?
27. Is Developer Sensor Source safe and hidden?
28. Is small-Watch critical information always visible?
29. Is localization EN/IT complete?
30. Is accessibility complete enough for internal TestFlight?
31. Are mockup paths valid and current?
32. Are mockups mapped to implemented views/routes?
33. Is visual-regression coverage sufficient?
34. Are cross-platform differences intentional?
35. Are recent developments regression-free?
36. Is UI/UX ready for internal TestFlight?
37. Is UI/UX ready for external TestFlight?
38. Is UI/UX ready for App Store?
39. What blocks 100% UI/UX readiness?
40. What must be fixed first?

Every `NO`, `PARTIAL`, `UNKNOWN`, `PENDING`, or `NOT_EXECUTED` must include:

```text
severity
priority
root cause
affected files/symbols
affected screen/flow
credible user impact
safety impact
required remediation
acceptance tests
release impact
```

---

# 50. FINAL VERDICT

Print exactly:

```text
MASTER_UI_UX_FULL_DEEP_AUDIT: PASS / PARTIAL / FAIL
WATCH_UNDERWATER_HARDWARE_INTERACTION_AUDIT: PASS / PARTIAL / FAIL
WATCH_WATER_AUTO_OPEN_AUDIT: PASS / PARTIAL / FAIL
DIGITAL_CROWN_UNDERWATER_PAGE_POLICY: PASS / FAIL / PENDING_PHYSICAL
ACTION_BUTTON_UNDERWATER_PRIMARY_ACTION: PASS / FAIL / PENDING_PHYSICAL
WATER_AUTO_OPEN_ROUTING_POLICY: PASS / FAIL / PENDING_PHYSICAL
WATER_LOCK_PHYSICAL_QA: PASS / FAIL / PENDING_PHYSICAL
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE: PASS / FAIL / PENDING_PHYSICAL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
TARGET_MEMBERSHIP: PASS / FAIL
MULTI_ACTIVITY_ARCHITECTURE: PASS / FAIL
ROOT_FLOW_ACTIVITY_SELECTION: PASS / FAIL
LEGAL_SAFETY_GATE_UI: PASS / FAIL
IOS_SETTINGS_MODE_SWITCH: PASS / FAIL
IOS_DIVING_SETTINGS_OWNERSHIP: PASS / FAIL
IOS_APNEA_SETTINGS_OWNERSHIP: PASS / FAIL
IOS_SNORKELING_SETTINGS_OWNERSHIP: PASS / FAIL
WATCH_APNEA_SETTINGS_ACCESS: PASS / FAIL
WATCH_SNORKELING_SETTINGS_ACCESS: PASS / FAIL
SETTINGS_NO_CROSS_ACTIVITY_LEAKAGE: PASS / FAIL
LOGBOOK_STRICT_OWNERSHIP: PASS / FAIL
GAUGE_FULL_COMPUTER_DISTINCTION: PASS / FAIL
WATCH_FULL_COMPUTER_UI_TRUTHFULNESS: PASS / FAIL
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY: PASS / FAIL
CCR_REFERENCE_ONLY_UX: PASS / FAIL
MOCKUPS_NOT_EMBEDDED_AS_LIVE_UI: PASS / FAIL
MOCKUP_PATH_VALIDITY: PASS / FAIL
MOCKUP_IMPLEMENTATION_TRACEABILITY: PASS / FAIL
VISUAL_REGRESSION_COVERAGE: PASS / FAIL
GLOBAL_ARCHITECTURE_READINESS: <0-100>
ACTIVITY_SELECTION_READINESS: <0-100>
SHARED_SETTINGS_READINESS: <0-100>
DIVING_SETTINGS_READINESS: <0-100>
APNEA_SETTINGS_READINESS: <0-100>
SNORKELING_SETTINGS_READINESS: <0-100>
DIVING_LOGBOOK_READINESS: <0-100>
APNEA_LOGBOOK_READINESS: <0-100>
SNORKELING_LOGBOOK_READINESS: <0-100>
GAUGE_WATCH_READINESS: <0-100>
FULL_COMPUTER_WATCH_READINESS: <0-100>
FULL_COMPUTER_DECO_UI_READINESS: <0-100>
IOS_PLANNER_BASE_READINESS: <0-100>
IOS_PLANNER_DECO_READINESS: <0-100>
IOS_PLANNER_TECHNICAL_READINESS: <0-100>
IOS_PLANNER_CCR_READINESS: <0-100>
ASCENT_SPEED_SETTINGS_READINESS: <0-100>
DIVE_RUNTIME_READINESS: <0-100>
DECO_STOPS_READINESS: <0-100>
EMERGENCY_ROCK_BOTTOM_READINESS: <0-100>
GAS_LEDGER_READINESS: <0-100>
TECHNICAL_AVERAGE_DEPTH_GAS_OPTION_READINESS: <0-100>
CCR_REBREATHER_UX_READINESS: <0-100>
RATIO_DECO_UX_READINESS: <0-100>
MOD_PPO2_DALTON_UX_READINESS: <0-100>
SWITCH_DEPTH_UX_READINESS: <0-100>
GAS_ROLE_UX_READINESS: <0-100>
TISSUE_LOADING_UX_READINESS: <0-100>
NARCOSIS_UX_READINESS: <0-100>
CHECKLIST_UX_READINESS: <0-100>
PLANNER_CHECKLIST_UX_READINESS: <0-100>
STRUCTURED_EQUIPMENT_UX_READINESS: <0-100>
PDF_SHARE_EXPORT_UX_READINESS: <0-100>
PLANNER_BRIEFING_CARD_UX_READINESS: <0-100>
WATCH_BRIEFING_CARD_INVENTORY_UX_READINESS: <0-100>
IMAGE_TRANSFER_UX_READINESS: <0-100>
WATCH_IMAGE_INVENTORY_DELETE_UX_READINESS: <0-100>
WATCH_REMINDER_UX_READINESS: <0-100>
SMALL_WATCH_SAFETY_LAYOUT_READINESS: <0-100>
MISSION_MODE_UX_READINESS: <0-100>
SENSOR_SOURCE_UX_READINESS: <0-100>
BRANDING_UX_READINESS: <0-100>
LOCALIZATION_READINESS: <0-100>
ACCESSIBILITY_READINESS: <0-100>
UNIT_CONSISTENCY_READINESS: <0-100>
ERROR_EMPTY_STATE_READINESS: <0-100>
CROSS_PLATFORM_PARITY_READINESS: <0-100>
REGRESSION_RESISTANCE_READINESS: <0-100>
INTERNAL_TESTFLIGHT_UI_UX_READINESS: <0-100>
EXTERNAL_TESTFLIGHT_UI_UX_READINESS: <0-100>
APP_STORE_UI_UX_READINESS: <0-100>
OVERALL_UI_UX_READINESS: <0-100>
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
P4_FINDINGS: <number>
PHYSICAL_WATCH_UI_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_IOS_UI_QA: PASS / FAIL / PENDING_PHYSICAL
PAIRED_WATCH_IOS_UI_QA: PASS / FAIL / PENDING_PHYSICAL
ACCESSIBILITY_MANUAL_QA: PASS / FAIL / PENDING_PHYSICAL
APP_STORE_REVIEW_READINESS: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

`PASS` is permitted only when:

- all software UI/UX gates pass;
- no P0-P2 UI/UX finding remains open;
- every critical feature is reachable;
- every primary flow is complete;
- Settings and Logbooks are activity-isolated;
- Full Computer safety UI is truthful;
- mockup path and visual-regression coverage are sufficient;
- localization and accessibility are complete enough for claimed readiness;
- physical QA is actually executed if claimed;
- App Store review readiness is supported by legal/asset evidence if claimed.

If physical/manual/App Store evidence is missing, final audit can be `PARTIAL` at best for those areas.

---

# 51. SUCCESS CRITERIA

The task is complete only if:

- no source code is modified;
- no tests are modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- no project configuration is modified;
- no mockups/assets are modified;
- all required output reports and matrices are created;
- all three merged command scopes are preserved;
- latest Settings mode switch / activity Settings development is included;
- Apnea and Snorkeling are audited as first-class product areas;
- Settings and Logbook ownership are audited;
- Watch and iOS parity is audited;
- Full Computer UI truthfulness is checked against live decompression requirements;
- mockups are recursively inventoried;
- mockup paths/casing/dimensions/hash are checked;
- visual-regression coverage is mapped;
- all critical user flows are replayed;
- all states are assessed;
- EN/IT localization is checked;
- accessibility is checked;
- release readiness is evidence-based;
- external and physical QA remain pending unless actually executed;
- report contains prioritized remediation plan;
- final git status confirms only Docs outputs changed.

Do not commit or push automatically.

Stop after producing the merged master UI/UX audit report, matrices, mockup visual regression matrices, QA pending report, remediation plan and final summary.



# 6A. LATEST iOS / WATCH INTEROP DEVELOPMENT SCOPE — GF OVERRIDE, WATER ROUTING AND BRIEFING SAFETY

The iOS audit must include the latest Watch-facing interoperability changes.

Inspect and verify:

```text
Shared/Models/DivePlanPackage.swift
Shared/Models/FullComputerGradientFactorPreset.swift
Shared/Models/FullComputerDiveLogbookMetadata.swift
iOSApp planner/package builders that emit GF low/high or preset fields
FullComputerImportedPlanStore compatibility expectations on Watch
Planner briefing card metadata
Watch transfer payloads
Logbook metadata displayed on iOS
Docs/WATCH_FULL_COMPUTER_GRADIENT_FACTORS_SETTINGS.md
```

Mandatory checks:

```text
iOS plans either emit a supported GF preset or low/high values that map to a supported Watch preset.
Unsupported GF pairs are rejected safely by Watch and surfaced truthfully to the user.
iOS Planner does not assume Watch accepted an unsupported GF pair.
iOS plan override is reference/configuration input only until Watch predive confirmation.
iOS Settings mode switch cannot mutate active Watch GF/runtime.
Briefing cards cannot mutate Watch GF, environment, gases or tissues.
Logbook GF metadata, if synced from Watch, is activity-owned and Full Computer only.
```

Water auto-open / shallow-depth cross-checks for iOS:

```text
iOS docs, settings, TestFlight wording and companion screens must not claim guaranteed water auto-open from iPhone.
iOS must not imply shallow-depth entitlement equals full-depth decompression validation.
iOS must not expose developer shallow-depth testing toggles as public user-facing features.
```

Create or update inside the audit:

```text
Docs/MASTER_IOS_GF_PRESET_WATCH_INTEROP_MATRIX_CURRENT.csv
```

---
