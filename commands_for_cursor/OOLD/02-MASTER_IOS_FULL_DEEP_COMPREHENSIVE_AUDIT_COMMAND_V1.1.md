# LAUNCH ORDER 02

**Launch order note:** SECOND — iOS deep audit. Run after Watch core to validate iOS Planner, Bühlmann parity, CCR/reference-only, gas planning, Equipment, Checklist, Logbook and briefing-card generation.

**Canonical numbered filename:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING iOS FULL DEEP COMPREHENSIVE AUDIT — V1.1

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Primary target:** `DIRDiving iOS`  
**Primary test target:** `DIRDiving iOS Algorithm Tests`  
**Secondary scope:** Apple Watch and Shared code only where they feed, validate, sync, receive, compare or display iOS-generated mathematical/planner/logbook/settings data  
**Task type:** audit-only, read-only, release-hard readiness audit  
**Merged source commands:**

```text
0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0.md
1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md
3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
```

**Updated for latest development:**  

```text
Multi-activity product architecture
Diving / Apnea / Snorkeling as first-class vertical product areas
iOS Companion Settings mode switcher
iOS Settings content for Diving / Apnea / Snorkeling
Dashboard gear routing to mode-scoped Settings
Activity-specific Settings ownership
Activity-specific Logbook ownership
Watch briefing cards as reference-only
CCR / Rebreather planner concepts as reference-only unless independently validated
Strict no cross-activity leakage policy
```

---

# 0. ABSOLUTE EXECUTION RULE

This is a single merged master audit command for the iOS Companion.

Audit the production implementation exactly as it exists.

Do **not** modify:

- production code;
- tests;
- project configuration;
- localization;
- assets;
- mockups;
- algorithms;
- business logic;
- planner logic;
- CCR / Rebreather logic;
- Ratio Deco logic;
- gas planning logic;
- UI/UX;
- sync schemas;
- persistence schemas;
- security model;
- Git history.

Do **not** refactor, fix, commit, push or merge.

The only permitted writes are audit outputs under `Docs/`.

If a defect is found, record it as an open finding with:

```text
severity
priority
root cause
affected files/symbols
canonical-vs-presentation classification
mathematical impact
safety impact
user impact
required remediation
acceptance tests
release impact
```

Do not implement the fix during this audit.

Never claim:

- physical iPhone QA;
- physical Apple Watch QA;
- paired-device QA;
- underwater QA;
- external Subsurface validation;
- external Bühlmann validation;
- App Store readiness;

unless actual evidence exists.

If evidence is unavailable, mark:

```text
PENDING_PHYSICAL
PENDING_PAIRED_DEVICE_QA
PENDING_EXTERNAL_VALIDATION
NOT_EXECUTED
```

---

# 1. MASTER OBJECTIVE

Perform a complete, deep, release-hard audit of the DIR Diving iOS Companion application.

This merged audit must cover:

1. Complete iOS mathematical-functions audit.
2. Complete iOS Bühlmann comprehensive readiness audit.
3. Complete iOS algorithm / planner / data-readiness audit.
4. Multi-activity architecture: Diving, Apnea, Snorkeling.
5. Activity-specific Settings and Logbooks.
6. iOS Settings mode switcher and latest activity-scoped Settings UX.
7. Bühlmann / Planner / Full Computer parity with Watch where relevant.
8. CCR / Rebreather concepts as reference-only unless fully validated.
9. Ratio Deco as heuristic/comparative unless otherwise proven.
10. Gas roles, MOD, PPO2, Dalton validation and switch-depth safety.
11. Emergency / Rock Bottom.
12. Schedule-aware gas consumption and gas ledger.
13. Repetitive-dive residual tissues.
14. Tissue loading, narcotic loading, CNS and OTU.
15. Structured Equipment and operational checklist.
16. CCR checklist import/export.
17. Manual dives, Logbooks, analytics and exports.
18. Planner briefing card / PNG export to Apple Watch.
19. Cloud, sync, persistence, privacy, security and schema integrity.
20. Unit conversion, localization and accessibility for math-bearing UI.
21. Test coverage, release-hard matrix and prioritized remediation plan.

The audit must answer whether the iOS Companion is mathematically, architecturally, functionally and release-wise ready as the central planning, logbook, settings, export and companion application for DIR Diving.

---

# 2. CURRENT PRODUCT ARCHITECTURE TO RESPECT

The current product architecture is:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Both iOS Companion and Apple Watch must be treated as multi-activity applications.

The audit must not reduce Apnea and Snorkeling to three logbooks or placeholder modules.

## Startup/root-flow requirements

Audit:

```text
Launch
→ legal/onboarding gate when required
→ activity selection
   ├── Diving
   ├── Apnea
   └── Snorkeling
→ activity-owned root, dashboard, functions, Settings and Logbook
```

Verify:

- selection persistence;
- safe migration from Diving-only installations;
- no placeholder route presented as production-ready;
- no remote switch of an active Watch session;
- no duplicate root coordinator;
- no duplicate NavigationStack authority;
- correct deep-link ownership;
- correct state-restoration ownership;
- Italian and English;
- accessibility;
- deterministic tests.

## Activity-specific feature ownership

### Diving

Audit:

- Gauge;
- Full Computer;
- Bühlmann ZH-L16C;
- Gradient Factors;
- NDL, TTS, Ceiling;
- decompression-stop state machine;
- multilevel tissue update;
- gas configuration;
- runtime gas switching;
- gas planning;
- CNS/OTU;
- PPO2/MOD;
- Planner;
- Ratio Deco;
- CCR / Rebreather planner concepts;
- Emergency / Rock Bottom;
- Diving equipment and checklist;
- Diving Logbook;
- Diving-specific Settings.

### Apnea

Audit:

- automatic session/dive lifecycle;
- depth/time profile;
- descent/ascent;
- surface interval;
- configurable recovery;
- targets;
- alarms;
- markers;
- profiles/planner;
- statistics and records;
- Apnea equipment/buddy;
- Apnea Logbook;
- Apnea-specific Settings;
- iOS Settings content under Apnea mode.

### Snorkeling

Audit:

- surface session lifecycle;
- GPS surface track;
- dips;
- waypoints;
- markers;
- return to entry;
- route planner;
- photos;
- map/privacy;
- Snorkeling Logbook;
- Snorkeling-specific Settings;
- iOS Settings content under Snorkeling mode.

---

# 3. SETTINGS OWNERSHIP AND LATEST DEVELOPMENT REQUIREMENTS

The latest development introduced / must be audited for:

```text
iOS Companion Settings mode switcher
Diving / Apnea / Snorkeling selectable Settings scope
Dashboard gear routing to Settings with correct initial activity
Editable Settings content directly visible below the switcher
No nested Form-in-ScrollView hiding activity Settings
Activity-owned Settings content
Shared Settings only where semantically shared
Watch in-mode Settings access for Apnea and Snorkeling where relevant
```

## Shared Settings may include only genuinely shared concerns

```text
Shared Settings
├── Language
├── Units
├── Backup
├── Synchronization
├── Privacy
├── Appearance where supported
├── Global haptic preference where semantically valid
└── About / Legal
```

## Activity Settings must remain separate

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
├── Mission Mode where supported
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
├── Location privacy
├── Photos/map privacy
└── Snorkeling route defaults
```

## Mandatory negative checks

- CNS, OTU, PPO2, MOD, GF, gas and decompression settings must not appear in Apnea or Snorkeling.
- Apnea recovery and target-training settings must not appear in Diving or Snorkeling.
- Snorkeling GPS route, waypoint and return settings must not appear in Diving or Apnea.
- iOS Settings mode switch must not mutate Watch active runtime.
- iOS Settings mode switch must not remotely change active Watch activity.
- Opening Settings for Apnea must not eagerly initialize unrelated Snorkeling or Diving-heavy stores unless explicitly shared and justified.
- Opening Settings for Snorkeling must not eagerly initialize unrelated Apnea or Diving-heavy stores unless explicitly shared and justified.
- Dashboard gear must open the Settings root with the correct initial selected mode.
- MoreView Settings must expose the same mode switch and content.
- Activity Settings content must not be hidden by nested `Form` inside `ScrollView`.

Any cross-activity Settings leakage is at least P1 and may be P0 if it affects live Full Computer/decompression behavior.

---

# 4. STRICT LOGBOOK OWNERSHIP

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

---

# 5. SHARED INFRASTRUCTURE VERSUS DOMAIN SEPARATION

Shared infrastructure is allowed for:

- authenticated WatchConnectivity transport;
- checksums;
- ACK/retry;
- backup;
- persistence helpers;
- generic visual primitives;
- localization infrastructure;
- theme components;
- common file I/O helpers;
- generic PDF rendering primitives.

Activity payloads, stores, Settings, Logbooks, statistics and exports must remain discriminated and independently versioned.

---

# 6. PRODUCT SAFETY POSITIONING

Preserve:

- non-certified planner positioning;
- no certified dive-computer claim;
- no certified decompression planner claim;
- no CCR controller claim;
- no live loop PPO2 monitoring claim;
- no EN13319 / ISO 6425 / CE claim unless official evidence exists;
- iOS Planner is reference/planning support unless formally validated;
- Watch briefing cards are reference-only;
- external validation remains pending unless actually executed;
- physical QA remains pending unless actually executed.

Unsupported release/legal claim is a finding.

---

# 7. REQUIRED OUTPUT FILES

Create or replace only these files:

```text
Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv
Docs/MASTER_IOS_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/MASTER_IOS_EDGE_CASE_MATRIX_CURRENT.csv
Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv
Docs/MASTER_IOS_RELEASE_HARD_MATRIX_CURRENT.csv
Docs/MASTER_IOS_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv
Docs/MASTER_IOS_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv
Docs/MASTER_IOS_EXTERNAL_VALIDATION_PENDING_CURRENT.md
```

No production source writes are permitted.

---

# 8. SEVERITY MODEL

## P0 — Safety-critical / release-blocking

Use P0 for:

- false or misleading decompression output;
- false no-decompression status;
- wrong ceiling/NDL/TTS/schedule due to algorithm or projection error;
- gas switch deeper than MOD persisting;
- invalid gas used in Bühlmann;
- stale hidden planner values exported as valid plan;
- cross-activity Logbook or Settings routing that can corrupt or display wrong safety data;
- iOS plan/briefing card mutating live Watch runtime;
- unsupported CCR metadata affecting live decompression authority;
- cloud/sync merge corrupting mathematical profile data;
- failure path turning unavailable values into zero.

## P1 — Must fix before internal TestFlight

Use P1 for:

- Bühlmann or Planner algorithm correctness gaps;
- incomplete CCR / OC separation where CCR is visible;
- MOD/PPO2/Dalton inconsistency;
- Ratio Deco displayed without Bühlmann validation;
- incomplete gas-role mapping;
- Rock Bottom unsafe or non-conservative behavior;
- repetitive-dive tissue ambiguity;
- incomplete planner result-state gating;
- non-traceable PDF/card numerical output;
- incomplete test coverage for safety-relevant math;
- Settings mode switch causing broad runtime mutation or cross-activity leakage.

## P2 — Must fix before external TestFlight

Use P2 for:

- bounded numerical discrepancy;
- missing docs/tests;
- incomplete export labels;
- incomplete localization/accessibility for math-bearing labels;
- incomplete performance safeguards;
- incomplete validation matrices.

## P3 — Before App Store / polish

Use P3 for:

- maintainability;
- observability;
- non-blocking performance;
- documentation clarity;
- polish.

## P4 — Post-release improvement

Optional improvements.

---

# 9. PREFLIGHT

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git rev-parse HEAD
git fetch --prune origin
git status --short
git status -sb
git remote -v
git branch -a
xcodebuild -version
```

Stop if branch is not `main`.

Inspect:

```text
project.yml
README.md
Docs/**
iOSApp/**
Shared/**
Services/**
Models/**
Utils/**
Views/**
Tests/**
Scripts/**
Resources/**
```

Confirm:

- target `DIRDiving iOS`;
- test target `DIRDiving iOS Algorithm Tests`;
- Watch runtime is secondary/cross-target only;
- experimental files remain excluded;
- audit-only state;
- dirty files;
- docs found/missing;
- simulator availability.

If macOS/Xcode available:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

If Watch parity/briefing-card receiver is relevant:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Do not fix failures.

Record exact commands, destination, result, failure summary and limitations.

---

# 10. MASTER FEATURE INVENTORY

Create:

```text
Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv
```

Required columns:

```text
Family
Activity
Mode
Feature
Files
Canonical_Source
Validation_Source
Projection_Source
Persistence_Source
Presentation_Source
Export_Source
Tests
Reachable_From_UI
Target_Membership
Physical_QA
External_Validation
Readiness_Percent
Notes
```

Families must include:

```text
Startup / Root Flow
Activity Selection
iOS Settings Mode Switch
Diving Settings
Apnea Settings
Snorkeling Settings
Shared Settings
Diving Logbook
Apnea Logbook
Snorkeling Logbook
Bühlmann
Planner Base
Planner Deco
Planner Technical
Full Computer parity
CCR / Rebreather
Ratio Deco
Gas Roles
MOD / PPO2 / Dalton
Switch Depth Clamp
Emergency / Rock Bottom
Ascent / Descent Transit
Dive Runtime
Decompression Stops
Schedule-Aware Gas Consumption
Gas Ledger / Reserve
Technical Average-Depth Gas Toggle
Repetitive Dive / Residual Tissues
Tissue Loading
Narcosis / END / PPN2
CNS / OTU
Structured Equipment
Operational Checklist
CCR Checklist Import / Export
CCR Bailout Scenario
CCR Gas Density
Manual Dive
PDF / Share Export
Planner Briefing Card / Watch Transfer
CSV / Subsurface
Cloud / Sync / Persistence
Unit Conversion
Localization
Accessibility
Performance / Numerical Robustness
Security / Privacy
Test Coverage
Release / Legal Claims
```

---

# 11. PHASE A — STARTUP, ROOT FLOW AND ACTIVITY ARCHITECTURE

Audit:

```text
Launch
→ legal/onboarding
→ activity selection
→ Diving / Apnea / Snorkeling
→ activity root
→ activity dashboard
→ activity functions
→ activity Settings
→ activity Logbook
```

Verify:

- selection persistence;
- safe migration from Diving-only installs;
- feature flags;
- no placeholder production route;
- no duplicate root coordinator;
- no duplicate NavigationStack authority;
- no remote active-Watch mode switch;
- deep-link/state restoration ownership;
- iOS/Watch consistency;
- legal/safety gate where required.

Create findings for any cross-activity leakage.

---

# 12. PHASE B — IOS SETTINGS MODE SWITCH AND ACTIVITY SETTINGS

Audit latest Settings implementation.

Inspect:

```text
IOSCompanionSettingsRootView
IOSCompanionSettingsModeSwitcher
IOSCompanionSettingsScopeStore
MoreView
IOSDivingSettingsEmbeddedContent
IOSApneaSettingsContent
IOSSnorkelingSettingsContent
IOSApneaSettingsForm
IOSSnorkelingSettingsForm
IOSApneaRootView
IOSSnorkelingRootView
Dashboard gear buttons
Settings environment injection
Store coordinator
```

Verify:

- switch includes Diving, Apnea, Snorkeling;
- Diving opens Diving Settings;
- Apnea gear opens Settings with Apnea selected;
- Snorkeling gear opens Settings with Snorkeling selected;
- MoreView exposes switch and selected content;
- selected content visible directly below switch;
- no nested `Form` inside `ScrollView` hiding content;
- Apnea content has backed editable controls;
- Snorkeling content has backed editable controls;
- Diving settings remain intact;
- switching Settings mode does not mutate runtime/session state;
- switching Settings mode does not remotely change Watch active mode;
- activity-owned settings do not leak;
- shared settings are documented;
- EN/IT localization;
- VoiceOver labels/hints;
- Dynamic Type;
- tests exist.

Create:

```text
Docs/MASTER_IOS_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv
```

Columns:

```text
Setting_ID
Label
Activity
Shared
Backing_Store
Visible_In_Diving
Visible_In_Apnea
Visible_In_Snorkeling
Visible_In_iOS
Visible_In_Watch
Can_Edit_During_Active_Session
Syncs_To_Watch
Runtime_Effect
Evidence
Pass
Notes
```

---

# 13. PHASE C — STRICT LOGBOOK OWNERSHIP

Audit:

```text
DiveLogStore
IOSApneaLogbookStore
IOSSnorkelingLogbookStore
Diving Logbook views
Apnea sessions/logbook views
Snorkeling sessions/logbook views
statistics views
detail views
exports
deep links
state restoration
sync routing
```

Create:

```text
Docs/MASTER_IOS_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv
```

Verify:

- Diving route only sees Diving sessions.
- Apnea route only sees Apnea sessions.
- Snorkeling route only sees Snorkeling sessions.
- no mixed query;
- no universal detail with irrelevant optional fields;
- no cross-activity export;
- no cross-activity stats;
- no wrong restoration;
- no wrong sync import path.

Any cross-activity Logbook route is P0.

---

# 14. PHASE D — BÜHLMANN CORE AUDIT

Audit:

```text
BuhlmannConstants
BuhlmannGas
BuhlmannTissueModel
BuhlmannEngine
BuhlmannTissueHistory
BuhlmannPlanPreflightValidator
BuhlmannPlanner
PlannerEnvironment
```

Verify:

- ZH-L16C constants;
- 16 N2/He compartments;
- half-times;
- a/b coefficients;
- tissue initialization;
- inspired inert pressure;
- altitude/salinity/freshwater if present;
- GF Low/High;
- ceiling;
- controlling compartment;
- NDL;
- first stop;
- stop rounding;
- TTS;
- schedule convergence;
- gas switch integration;
- Trimix/He;
- O2 100%;
- invalid gas preflight;
- finite guards;
- deterministic output;
- no fake/static values;
- parity with Watch runtime where relevant.

Required scenarios:

```text
Air no-deco
Nitrox no-deco
Air deco
EAN50 deco gas
Trimix bottom
O2 stop gas
Altitude profile
Freshwater/saltwater if supported
GF 30/70
GF 20/80
Invalid gas
Missing gas
Extreme input rejection
```

---

# 15. PHASE E — PLANNER MODE PROJECTION

Audit Base, Deco, Technical and CCR/reference-only mode.

## Base

- one active gas;
- no hidden technical gas influence;
- NDL uses Base projection;
- mandatory deco detected;
- full technical schedule hidden;
- no CCR leakage.

## Deco

- bottom + allowed deco gases;
- depth/average depth limits;
- simplified schedule;
- mode-aware preview/export;
- no unsupported bailout projection.

## Technical

- back/travel/deco/bailout;
- multiple deco gases;
- manual GF if supported;
- full Bühlmann schedule;
- gas ledger;
- Emergency/Rock Bottom;
- average-depth gas toggle isolated;
- full analytics.

## CCR

- explicit reference-only mode;
- OC/CCR separation;
- setpoint/diluent/bailout projection;
- Ratio Deco blocked unless supported;
- no live CCR controller claim.

---

# 16. PHASE F — MOD / PPO2 / DALTON / SWITCH DEPTH

Verify:

- single canonical MOD formula;
- automatic MOD update;
- PPO2 increments exactly 0.1;
- Air lock;
- EAN O2-only;
- Trimix O2+He;
- O2 100%;
- O2+He+N2 = 100;
- environment-aware MOD;
- displayed MOD == validated MOD;
- switch depth <= MOD;
- shallower switch allowed;
- hidden/stale values cannot bypass clamp;
- export/PDF/checklist use same values;
- CCR setpoint not treated as FO2;
- diluent/bailout validation role-correct.

Mandatory example:

```text
O2 100%, PPO2 1.6 → MOD approximately 6 m
```

---

# 17. PHASE G — GAS ROLES AND SCHEDULE-AWARE CONSUMPTION

Audit:

```text
GasPlanningService
PlannerGasSchedule
ScheduleGasConsumptionService
GasLedgerDisplayFormatter
gas role models
cylinder models
```

Roles:

```text
Back Gas
Travel
Decompression
Bailout
CCR Diluent
CCR Oxygen Supply
CCR Bailout
```

Verify:

- stable IDs;
- segment allocation;
- switch depth/runtime;
- schedule-aware consumption;
- ascent/descent gas;
- travel gas ranges;
- bailout excluded from normal consumption unless bailout scenario;
- CCR diluent not consumed as OC breathing gas in setpoint phases;
- CCR bailout becomes OC only after explicit transition;
- liters canonical;
- cylinder-equivalent bar display only;
- duplicate gas/cylinder aggregation deterministic;
- insufficient-gas warnings use compatible units.

---

# 18. PHASE H — EMERGENCY / ROCK BOTTOM

Audit:

- maximum-depth reference;
- ambient pressure;
- stressed RMV/SAC;
- team size / affected diver count;
- response/problem-solving time;
- ascent transit;
- stop/deco gas inclusion policy;
- reserve separation;
- liters required;
- cylinder bar equivalent;
- available vs required comparison;
- rounding direction;
- unit conversion;
- invalid/NaN/Inf guards;
- Base/Deco/Technical/CCR eligibility;
- PDF/share/briefing-card consistency.

Critical invariants:

- Emergency/Rock Bottom gas is independent from normal planned consumption.
- Technical average-depth gas toggle must not reduce Rock Bottom unless explicitly safe.
- Canonical liters are source of truth.
- CCR bailout emergency logic must not reuse OC assumptions silently.

---

# 19. PHASE I — ASCENT SPEED / RUNTIME / DECO STOP PRESENTATION

Audit:

```text
PlannerAscentSpeedSettings
PlannerAscentTableBuilder
DecoStopsPresentationBuilder
RouteSummaryService
RouteSummaryAggregation
Dive Runtime rows
TTS/TTR totals
```

Verify:

- defaults/bounds;
- no zero/negative speed;
- unit semantics;
- transit duration formula;
- runtime accumulation;
- phase ordering;
- descent, bottom, ascent, gas switch, deco stop, final ascent;
- dedicated deco-stop table exactly matches canonical schedule;
- presentation builders do not mutate/recompute canonical results incorrectly;
- ascent speed affects transit and gas consistently;
- CCR setpoint switch placement if present.

---

# 20. PHASE J — TECHNICAL AVERAGE-DEPTH GAS TOGGLE

Verify:

- default conservative max-depth consumption;
- toggle affects gas consumption only;
- Bühlmann unchanged;
- decompression unchanged;
- MOD/PPO2 unchanged;
- switch depth unchanged;
- Rock Bottom unchanged;
- average depth <= max depth;
- state does not leak to Base/Deco/CCR;
- persistence safe;
- PDF/share/briefing card disclose selected basis.

---

# 21. PHASE K — REPETITIVE DIVE / RESIDUAL TISSUE

Audit:

```text
RepetitiveDivePlannerService
prior dive source
tissue state inputs
surface interval
residual tissue persistence
export disclosure
```

Verify:

- previous tissue source explicit;
- chronology;
- surface interval;
- N2/He off-gassing;
- GF compatibility;
- OC/CCR compatibility;
- stale/future dive rejection;
- deterministic output;
- no silent fresh-tissue fallback;
- UI/output distinguishes fresh vs repetitive.

---

# 22. PHASE L — RATIO DECO

Verify:

- heuristic/comparative status;
- Bühlmann remains primary;
- disclaimer visible;
- presets 1:1, 2:1, custom;
- custom persistence;
- first stop/step/distribution/minimum stop;
- schedule generation;
- active gas projection;
- gas assignment;
- MOD/PPO2 validation;
- ceiling validation;
- comparison table;
- overlay chart;
- PDF export;
- localization;
- CCR blocked unless explicitly supported and labelled.

---

# 23. PHASE M — TISSUE / NARCOSIS / CNS / OTU

Audit:

- tissue analytics;
- 16 compartments;
- N2/He loading;
- controlling compartment;
- M-value / GF-relative loading;
- tissue trends;
- chart data source;
- source label: recorded/planned/simulated/CCR;
- PPN2;
- END;
- EAD if present;
- active gas timeline;
- CCR setpoint/diluent model;
- bailout transition;
- CNS full-plan;
- OTU;
- warnings;
- finite guards;
- no fake/static charts;
- accessibility summaries.

---

# 24. PHASE N — CCR / REBREATHER

Search and audit:

```text
CCR
Rebreather
ClosedCircuit
OpenCircuit
Setpoint
Diluent
Bailout
Loop
Scrubber
Sorb
Cell
ppO2Setpoint
setpointLow
setpointHigh
diluentGas
bailoutGas
CCRBailoutScenarioCalculator
CCRGasDensityEstimator
CCRChecklistImportCoordinator
CCRChecklistExportCoordinator
```

Verify:

## CCR mode separation

- explicit CCR mode;
- no OC/CCR silent mixing;
- no CCR leakage into Base/Deco;
- no OC state using setpoint PPO2.

## Setpoint

- low/high validation;
- switch depth/time;
- setpoint PPO2 not gas fraction;
- exposure/tissue outputs consistent.

## Diluent

- O2/He/N2 validation;
- inert gas assumptions;
- MOD/MND if applicable;
- hypoxic validation;
- END/EAD;
- gas density.

## Bailout

- explicit OC transition;
- bailout schedule;
- MOD/PPO2;
- gas quantity;
- CNS/OTU;
- tissue/narcosis transition.

## CCR integration

- setpoint drives oxygen partial pressure;
- inert loading coherent;
- GF behavior unchanged;
- bailout uses OC model.

## CCR output truthfulness

- no live loop PPO2 monitoring claim;
- no certified CCR controller claim;
- limitations explicit;
- all CCR planner/card/export data reference-only unless externally validated.

---

# 25. PHASE O — STRUCTURED EQUIPMENT / CHECKLIST

Audit:

```text
EquipmentStructuredModels
EquipmentStructuredSupport
EquipmentPlannerMapper
EquipmentChecklistGenerator
ChecklistPlannerSyncMapper
CCRChecklistImportCoordinator
CCRChecklistExportCoordinator
DIRChecklistConfigurationEvaluator
Equipment Setup PDF
```

Verify:

- equipment templates;
- REC/TEC/CCR/custom;
- gas types;
- cylinder role;
- planner mapping;
- checklist generation;
- duplicate prevention;
- task/equipment/gas linkage;
- cylinder size;
- pressure;
- gas mix;
- gas role;
- DIR/READY badge semantics;
- CCR role round trip;
- no user-data loss.

---

# 26. PHASE P — MANUAL DIVE / LOGBOOK / ANALYTICS

Verify:

- max depth;
- average depth;
- profile;
- GPS start/end;
- equipment;
- gases;
- bar in/out;
- pressure math;
- deco notes;
- CCR metadata;
- metadata-only no-depth truthfulness;
- recorded/planned/simulated source;
- tissue/narcosis eligibility;
- malformed profile handling;
- duplicate prevention;
- cloud merge.

---

# 27. PHASE Q — PDF / SHARE / CSV / BRIEFING CARD

Audit:

- plan PDF;
- briefing PDF;
- Dive Pack;
- checklist PDF;
- Equipment Setup PDF;
- CCR PDF;
- Ratio Deco sections;
- tissue/narcosis;
- CNS/OTU;
- Rock Bottom;
- ascent-speed assumptions;
- full runtime;
- deco stops;
- gas ledger;
- repetitive-dive status;
- average-depth basis;
- disclaimers;
- units.

## Planner briefing card / PNG to Watch

Verify:

- canonical values;
- rendered PNG/card text;
- structured metadata;
- units/localization;
- plan mode;
- gas mixes;
- stops/runtime;
- Rock Bottom where included;
- timestamp/version;
- stale-card policy;
- transfer ACK;
- failure handling;
- Watch reference-only labeling;
- no live-deco implication.

## CSV / Subsurface

Verify:

- metric policy;
- time base;
- samples;
- GPS;
- gas fields;
- CCR limitations;
- malformed import;
- round trip;
- external validation status.

---

# 28. PHASE R — CLOUD / SYNC / PERSISTENCE / SECURITY

Verify:

- mathematical values survive save/load;
- unit values canonical;
- planner settings persistence;
- ascent-speed settings;
- emergency settings;
- average-depth toggle;
- repetitive-dive metadata;
- structured Equipment values;
- CCR values;
- checklist roles;
- briefing-card versioning;
- conflict/tombstone behavior;
- duplicate IDs;
- no hybrid profile merge;
- payload size limits;
- HMAC/signature/nonce validation;
- malformed data fail-safe;
- privacy/GPS handling.

---

# 29. PHASE S — UNIT CONVERSION / LOCALIZATION / ACCESSIBILITY

Verify:

- m/ft;
- bar/psi;
- Celsius/Fahrenheit;
- liters/cubic feet where used;
- m/min and ft/min;
- RMV/SAC;
- gas ledger liters/bar;
- Rock Bottom;
- CCR setpoint units;
- gas density;
- PDF/CSV/card values;
- locale-safe decimals/dates;
- EN/IT mathematical labels;
- chart accessibility summaries;
- no Italian-as-key leakage;
- Dynamic Type.

---

# 30. PHASE T — PERFORMANCE / NUMERICAL ROBUSTNESS

Audit:

- repeated planner recomputation;
- debouncing;
- stale async result publication;
- result-state races;
- SwiftUI update loops;
- tissue timelines;
- CCR timelines;
- Ratio Deco overlay;
- repetitive calculations;
- gas schedule calculations;
- Rock Bottom;
- PDF/card rendering;
- export;
- large profiles;
- many gases;
- NaN/Inf/overflow;
- zero/negative inputs.

---

# 31. PHASE U — TEST COVERAGE

Inspect all iOS algorithm tests and relevant Watch parity tests.

Required coverage:

- root activity architecture;
- activity Settings ownership;
- activity Logbook ownership;
- Bühlmann;
- Base/Deco/Technical/CCR;
- MOD/PPO2/switch clamp;
- Ratio Deco;
- gas roles;
- schedule-aware consumption;
- Rock Bottom vectors;
- ascent/descent timing;
- runtime ordering;
- deco-stop equivalence;
- average-depth toggle isolation;
- repetitive dive;
- tissue/narcosis;
- CNS/OTU;
- CCR setpoint/diluent/bailout;
- CCR bailout scenario;
- CCR gas density;
- structured Equipment;
- CCR checklist round trip;
- manual dive;
- PDF/export;
- briefing card encode/render/transfer/receive;
- CSV/Subsurface;
- cloud conflicts;
- units;
- localization/accessibility;
- performance/numerical robustness.

Classify missing tests by priority.

---

# 32. STATIC SCANS

Run or suggest:

- compiler warnings;
- SwiftLint if configured;
- force unwraps;
- `try!`;
- `as!`;
- unsafe dictionary construction;
- TODO/FIXME;
- hardcoded secrets;
- hardcoded user-facing strings;
- recursive `.onChange`;
- uncancelled tasks/timers;
- temporary file handling;
- stale test-only code in MAIN.

Search for:

```text
RockBottom
Emergency
PlannerAscentSpeedSettings
PlannerAscentTableBuilder
DecoStopsPresentationBuilder
GasLedgerDisplayFormatter
ScheduleGasConsumptionService
RepetitiveDivePlannerService
RouteSummary
PlanCalculationCompleteness
CCRChecklistImportCoordinator
CCRBailoutScenarioCalculator
CCRGasDensityEstimator
PlannerBriefingCard
IOSCompanionSettingsRootView
IOSCompanionSettingsModeSwitcher
IOSApneaSettingsContent
IOSSnorkelingSettingsContent
```

Do not fix anything.

---

# 33. REQUIREMENT / TEST MATRIX

Create:

```text
Docs/MASTER_IOS_REQUIREMENT_TEST_MATRIX_CURRENT.csv
```

Columns:

```text
Requirement_ID
Area
Activity
Mode
Requirement
Production_Source
Test_File
Test_Name
Expected_Result
Actual_Result
Oracle_or_Reference
Physical_QA
External_Validation
Result
Evidence
Severity
Notes
```

---

# 34. EDGE-CASE MATRIX

Create:

```text
Docs/MASTER_IOS_EDGE_CASE_MATRIX_CURRENT.csv
```

Columns:

```text
Case_ID
Area
Activity
Mode
Input
Initial_State
Expected_Result
Actual_Result
Absolute_Error
Relative_Error
Pass
Severity
Evidence
Notes
```

Include:

- invalid gases;
- invalid MOD;
- switch depth deeper than MOD;
- average depth > max depth;
- zero/negative speed;
- repetitive future dive;
- stale previous tissues;
- CCR setpoint invalid;
- diluent invalid;
- bailout invalid;
- route/gps invalid;
- mixed activity restore;
- mixed logbook deep link;
- settings mode switch during active Watch session;
- missing export fields;
- malformed CSV;
- invalid sync payload.

---

# 35. FINDING TRACEABILITY

Create:

```text
Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv
```

Columns:

```text
Finding_ID
Severity
Priority
Family
Activity
Mode
Status
Root_Cause
Affected_Files
Affected_Symbols
Canonical_vs_Presentation
Mathematical_Impact
Safety_Impact
User_Impact
Security_Privacy_Impact
Performance_Impact
Recommended_Remediation
Tests_Required
Acceptance_Criteria
Regression_Risk
Physical_QA_Required
External_Validation_Required
Evidence
Notes
```

Statuses:

```text
OPEN
VERIFIED
DOCUMENTED_ACCEPTED_RISK
NOT_APPLICABLE
PENDING_PHYSICAL
PENDING_EXTERNAL_VALIDATION
```

Because this is audit-only, new defects remain `OPEN`.

---

# 36. RELEASE-HARD MATRIX

Create:

```text
Docs/MASTER_IOS_RELEASE_HARD_MATRIX_CURRENT.csv
```

Mandatory rows:

```text
Bühlmann
Planner Base/Deco/Technical
Full Computer Watch parity
CCR / Rebreather
CCR Setpoint
CCR Diluent
CCR Bailout
Ratio Deco
Gas Planning
Gas Roles
MOD/PPO2/Dalton
Switch Depth Clamp
Emergency / Rock Bottom
Ascent / Descent Timing
Dive Runtime / Deco Stops
Schedule-Aware Gas Consumption
Gas Ledger / Reserve
Technical Average-Depth Gas Toggle
Repetitive Dive / Residual Tissues
Tissue Loading
Narcosis / END / PPN2
CNS / OTU
Structured Equipment
Operational Checklist
CCR Checklist Import / Export
CCR Bailout Scenario
CCR Gas Density
Manual Dive
Diving Logbook
Apnea Logbook
Snorkeling Logbook
Diving Settings
Apnea Settings
Snorkeling Settings
Shared Settings
PDF / Share
Planner Briefing Card / Watch Transfer
CSV / Subsurface
Cloud / Sync / Persistence
Security / Privacy
Unit Conversion
Localization
Accessibility
Performance / Numerical Robustness
Test Coverage
Internal TestFlight
External TestFlight
App Store
Overall
```

Columns:

```text
Feature
Readiness_Percent
Blockers
Priority
Evidence
Physical_QA
External_Validation
Notes
```

Every percentage must cite evidence.

---

# 37. EXTERNAL VALIDATION PENDING REPORT

Create:

```text
Docs/MASTER_IOS_EXTERNAL_VALIDATION_PENDING_CURRENT.md
```

Include:

- Bühlmann external validation;
- Subsurface validation;
- CCR external validation;
- Ratio Deco validation;
- PDF/export validation;
- physical iPhone QA;
- paired Watch/iPhone sync QA;
- App Store legal/release review;
- accessibility manual QA.

Mark pending unless actually executed.

---

# 38. MASTER REPORT STRUCTURE

Create:

```text
Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Commands Merged  
C. Latest Development Update  
D. Branch, Commit and Scope  
E. Preflight and Build/Test Baseline  
F. Target Membership and Architecture  
G. Multi-Activity Root Flow  
H. iOS Settings Mode Switch and Activity Settings  
I. Strict Logbook Ownership  
J. Feature Inventory  
K. Bühlmann Core  
L. Planner Mode Projection  
M. MOD / PPO2 / Dalton / Switch Depth  
N. Gas Roles and Schedule-Aware Consumption  
O. Emergency / Rock Bottom  
P. Ascent Speed / Runtime / Deco Stops  
Q. Technical Average-Depth Gas Toggle  
R. Repetitive Dive / Residual Tissues  
S. Ratio Deco  
T. Tissue / Narcosis / CNS / OTU  
U. CCR / Rebreather  
V. Structured Equipment / Checklist  
W. Manual Dive / Logbook / Analytics  
X. PDF / Share / CSV / Briefing Card  
Y. Cloud / Sync / Persistence / Security  
Z. Unit Conversion / Localization / Accessibility  
AA. Performance / Numerical Robustness  
AB. Test Coverage  
AC. Static Scans  
AD. Requirement / Test Matrix  
AE. Edge-Case Matrix  
AF. Findings P0-P4  
AG. Release-Hard Matrix  
AH. Prioritized Remediation Plan  
AI. 7-Day / 14-Day Readiness Plan  
AJ. Future Cursor Remediation Commands  
AK. External / Physical QA Pending  
AL. Final Verdict

---

# 39. REQUIRED FINAL QUESTIONS

The report must explicitly answer:

1. Is the iOS app truly multi-activity?
2. Are Diving, Apnea and Snorkeling each first-class product areas?
3. Is the Settings mode switch implemented, visible and safe?
4. Are Apnea/Snorkeling Settings editable and not hidden by layout?
5. Are Settings activity-owned without leakage?
6. Are Logbooks activity-owned without leakage?
7. Is Bühlmann complete and internally consistent?
8. Is iOS Planner parity with Watch Full Computer understood and separated?
9. Are Base/Deco/Technical modes real and isolated?
10. Is CCR mathematically coherent and reference-only?
11. Is Ratio Deco safely comparative?
12. Are MOD/PPO2/Dalton/switch-depth rules consistent?
13. Are gas roles preserved end to end?
14. Is Rock Bottom conservative and correct?
15. Are ascent/descent timing and runtime rows coherent?
16. Does deco-stop presentation match canonical schedule?
17. Is schedule-aware gas consumption correct by segment and role?
18. Is Technical average-depth gas toggle isolated to gas estimation?
19. Are repetitive-dive residual tissues coherent?
20. Are tissue/narcosis/CNS/OTU truthful?
21. Are Equipment/checklist mappings safe?
22. Does CCR checklist round trip preserve roles?
23. Are CCR bailout and gas density traceable?
24. Are manual dives and exports reliable?
25. Are briefing cards numerically faithful and reference-only?
26. Is cloud/sync/data integrity release-hard?
27. Are unit/localization/accessibility outputs safe?
28. Are performance/numerical robustness acceptable?
29. Is the app ready for internal TestFlight?
30. Is it ready for external TestFlight?
31. Is it ready for App Store?
32. What blocks 100% readiness?
33. What must be fixed first?

Every `NO`, `PARTIAL` or `UNKNOWN` must include:

```text
severity
priority
root cause
affected files/symbols
credible impact
required remediation
acceptance tests
release impact
```

---

# 40. FINAL VERDICT

Print exactly:

```text
MASTER_IOS_FULL_DEEP_AUDIT: PASS / PARTIAL / FAIL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
TARGET_MEMBERSHIP: PASS / FAIL
MULTI_ACTIVITY_ARCHITECTURE: PASS / FAIL
ROOT_FLOW_ACTIVITY_SELECTION: PASS / FAIL
LEGAL_SAFETY_GATE: PASS / FAIL
IOS_SETTINGS_MODE_SWITCH: PASS / FAIL
IOS_DIVING_SETTINGS_OWNERSHIP: PASS / FAIL
IOS_APNEA_SETTINGS_OWNERSHIP: PASS / FAIL
IOS_SNORKELING_SETTINGS_OWNERSHIP: PASS / FAIL
IOS_SETTINGS_NO_CROSS_ACTIVITY_LEAKAGE: PASS / FAIL
IOS_LOGBOOK_STRICT_OWNERSHIP: PASS / FAIL
BUHLMANN_CORE_READINESS: <0-100>
IOS_PLANNER_WATCH_PARITY_READINESS: <0-100>
BASE_MODE_READINESS: <0-100>
DECO_MODE_READINESS: <0-100>
TECHNICAL_MODE_READINESS: <0-100>
CCR_REFERENCE_ONLY_READINESS: <0-100>
RATIO_DECO_READINESS: <0-100>
MOD_PPO2_DALTON_READINESS: <0-100>
SWITCH_DEPTH_CLAMP_READINESS: <0-100>
GAS_ROLE_READINESS: <0-100>
ROCK_BOTTOM_READINESS: <0-100>
ASCENT_DESCENT_RUNTIME_READINESS: <0-100>
DECO_STOP_PRESENTATION_READINESS: <0-100>
SCHEDULE_AWARE_GAS_READINESS: <0-100>
GAS_LEDGER_READINESS: <0-100>
TECHNICAL_AVERAGE_DEPTH_GAS_TOGGLE_READINESS: <0-100>
REPETITIVE_DIVE_READINESS: <0-100>
TISSUE_LOADING_READINESS: <0-100>
NARCOSIS_END_PPN2_READINESS: <0-100>
CNS_OTU_READINESS: <0-100>
STRUCTURED_EQUIPMENT_READINESS: <0-100>
CHECKLIST_SYNC_READINESS: <0-100>
CCR_CHECKLIST_ROUNDTRIP_READINESS: <0-100>
CCR_BAILOUT_SCENARIO_READINESS: <0-100>
CCR_GAS_DENSITY_READINESS: <0-100>
MANUAL_DIVE_READINESS: <0-100>
PDF_SHARE_EXPORT_READINESS: <0-100>
PLANNER_BRIEFING_CARD_WATCH_TRANSFER_READINESS: <0-100>
CSV_SUBSURFACE_READINESS: <0-100>
CLOUD_SYNC_PERSISTENCE_READINESS: <0-100>
SECURITY_PRIVACY_READINESS: <0-100>
UNIT_CONVERSION_READINESS: <0-100>
LOCALIZATION_READINESS: <0-100>
ACCESSIBILITY_READINESS: <0-100>
PERFORMANCE_NUMERICAL_ROBUSTNESS_READINESS: <0-100>
TEST_COVERAGE_READINESS: <0-100>
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
P4_FINDINGS: <number>
OVERALL_IOS_SOFTWARE_READINESS: <0-100>
INTERNAL_TESTFLIGHT_READINESS: <0-100>
EXTERNAL_TESTFLIGHT_READINESS: <0-100>
APP_STORE_READINESS: <0-100>
PHYSICAL_IOS_QA: PASS / FAIL / PENDING_PHYSICAL
PAIRED_WATCH_IOS_QA: PASS / FAIL / PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

---

# 41. SUCCESS CRITERIA

The task is complete only if:

- no production code is modified;
- no tests are modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- no CCR/Rebreather logic is modified;
- no Watch runtime is modified;
- no sync/security model is modified;
- all required report files are created;
- all three source command scopes are preserved;
- latest Settings mode switch / activity Settings development is included;
- Apnea and Snorkeling are audited as first-class product areas;
- Settings and Logbook ownership are audited;
- Bühlmann, Planner, CCR, Ratio Deco and gas logic are audited;
- latest MAIN components are audited;
- canonical calculation and presentation-only logic are separated;
- readiness percentages are evidence-backed;
- external validation remains pending unless executed;
- physical QA remains pending unless executed;
- report contains prioritized remediation plan;
- final git status confirms only report/docs changed.

Do not commit or push automatically.

Stop after producing the merged master iOS audit report, matrices, external validation pending report and final summary.



# 1A. LATEST CROSS-CUTTING DEVELOPMENT SCOPE — WATER ENTRY, INTENTS, GF, ENTITLEMENTS, SHALLOW TESTING

This audit must include the 2026-06-27 / 2026-06-28 development wave as cross-cutting code, sync, security, privacy, performance and concurrency scope.

Inspect at minimum:

```text
Utils/WatchLaunchRoutingPolicy.swift
Utils/WatchSubmersionLaunchProbe.swift
Utils/WatchAutomaticDepthLaunchConfiguration.swift
Utils/WatchWaterAutoOpenPolicy.swift
Utils/WatchUnderwaterNavigationClampPolicy.swift
Services/DIRActivitySelectionStore.swift
Services/ActionButtonIntents.swift
Services/WatchUnderwaterActionRouter.swift
Services/WatchIntentSafetyPolicy.swift
Shared/Models/FullComputerGradientFactorPreset.swift
Services/FullComputerGradientFactorSettingsStore.swift
Services/FullComputerPrediveConfigurationStore.swift
Services/FullComputerImportedPlanStore.swift
Utils/DepthCapabilityPolicy.swift
Utils/DepthCapabilityResolver.swift
Utils/DepthCapabilityEntitlementProbe.swift
Utils/DeveloperSettings.swift
Views/DeveloperSettingsView.swift
Config/DIRDiving.WithShallowDepth.entitlements
Config/DIRDiving.WithWaterSubmersion.entitlements
Config/DIRDiving.entitlements
App/Info.plist
project.yml
Tests/WatchAlgorithmTests/WatchLaunchRoutingPolicyTests.swift
Tests/WatchAlgorithmTests/WatchSubmersionLaunchProbeTests.swift
Tests/WatchAlgorithmTests/WatchIntentSafetyPolicyTests.swift
Tests/WatchAlgorithmTests/DepthCapabilityTests.swift
Tests/**/FullComputerGradientFactor*
Scripts/validate_watch_underwater_uiux_readiness.sh
```

Audit for:

```text
cold-launch routing race
overlapping fullScreenCover prevention
submersion probe timeout / nil / error / stale behavior
systemWaterAutoLaunch route not starting a session
waterAutoLaunchIntent route not starting a session
active-session block on water routing
App Intent legacy safety blocking during active session
Action Button router-only policy
developer shallow testing flag leakage into production
shallow-depth entitlement / Info.plist / runtime capability mismatch
full-depth entitlement separation
GF setting persistence race
GF active-dive lock
GF iOS plan override validation
GF snapshot immutability at runtime
GF logbook metadata schema compatibility
WatchConnectivity payload compatibility after GF fields
privacy manifest impact of submerged launch / App Intents / depth samples
performance impact of submersion probe at cold launch
battery impact of underwater Auto-Launch probing
```

Create or update:

```text
Docs/MASTER_WATER_AUTO_OPEN_CODE_RISK_MATRIX_CURRENT.csv
Docs/MASTER_APP_INTENT_UNDERWATER_SAFETY_MATRIX_CURRENT.csv
Docs/MASTER_GF_PRESET_SYNC_SCHEMA_MATRIX_CURRENT.csv
Docs/MASTER_DEPTH_CAPABILITY_ENTITLEMENT_MATRIX_CURRENT.csv
Docs/MASTER_DEVELOPER_SHALLOW_TESTING_RELEASE_GATE_MATRIX_CURRENT.csv
```

---
