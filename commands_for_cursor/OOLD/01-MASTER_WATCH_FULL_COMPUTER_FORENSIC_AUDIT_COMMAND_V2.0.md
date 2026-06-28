# LAUNCH ORDER 01

**Launch order note:** FIRST — Watch Full Computer forensic audit. Run this first because Full Computer safety, Bühlmann/Schreiner, altitude, CMAltimeter and live decompression are the highest-risk core.

**Canonical numbered filename:** `01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V2.0.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING APPLE WATCH FULL COMPUTER FULL DEEP FORENSIC AUDIT — V2.0

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Primary target:** `DIRDiving Watch App`  
**Primary test target:** `DIRDiving Watch Algorithm Tests`  
**Secondary cross-target scope:** iOS Companion and Shared code only where they feed, validate, sync, export, compare, configure, or display values used by the Apple Watch Diving Computer / Full Computer  
**Task type:** audit-only, read-only, safety-critical, forensic  
**Updated for latest development:** Settings mode switch, activity isolation, Watch Full Computer altitude/environment policy, CMAltimeter proposal flow, multilevel Bühlmann/Schreiner runtime, live decompression state, planner briefing cards as reference-only, and strict no cross-activity leakage policy.

**Merged source commands:**

```text
MASTER_WATCH_DIVING_COMPUTER_FULL_AUDIT_COMMAND_V1.0.md
15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_V3.0.md
```

This command supersedes the previous separate Watch Full Computer master audit and the specialized Live Bühlmann/Schreiner multilevel audit by merging them into one single full deep comprehensive audit command for the Apple Watch Full Computer.

---

# 0. ABSOLUTE EXECUTION RULE

This is a **single merged master forensic audit command** for the Apple Watch Diving Computer / Full Computer.

Audit the production implementation exactly as it exists on `main`.

Do **not** modify:

- production code;
- tests;
- project configuration;
- localization;
- assets;
- mockups;
- algorithms;
- business logic;
- persistence schemas;
- sync schemas;
- Git history.

Do **not**:

- refactor;
- apply fixes;
- change UI/UX;
- change gas logic;
- change Gradient Factors;
- change decompression-stop rules;
- change sampling frequency;
- change power-management behavior;
- commit;
- push;
- merge.

The only permitted writes are audit outputs under `Docs/`.

If a defect is found, record it as an open finding with:

```text
severity
priority
root cause
affected files/symbols
affected profile/timestamp/compartment where applicable
mathematical impact
safety impact
user-visible impact
required remediation
acceptance tests
release impact
physical QA requirement
external validation requirement
```

Never claim physical Apple Watch / underwater / CMAltimeter / depth sensor / external decompression validation from simulator evidence.

If hardware, Xcode, a physical Watch, permissions, safe test location, external decompression oracle, pressure pot/chamber, or Instruments are unavailable, mark the evidence:

```text
PENDING_PHYSICAL
PENDING_EXTERNAL_VALIDATION
NOT_EXECUTED
```

Do not convert missing evidence into a pass.

---

# 1. MASTER OBJECTIVE

Perform the deepest possible audit of the Apple Watch **Full Computer** implementation.

This audit must combine:

1. Full Watch Diving Computer architecture audit.
2. Full Watch algorithm and mathematical-functions audit.
3. Full Watch live Bühlmann ZH-L16C runtime audit.
4. Full Watch Schreiner equation forensic audit.
5. Full one-second / actual elapsed-time tissue update audit.
6. Full multilevel-dive decompression-obligation audit.
7. Full altitude-aware pressure/environment audit.
8. Full CMAltimeter → Full Computer environment-source audit.
9. Full environment authority / explicit acceptance audit.
10. Full gas-switch, PPO2/MOD, TTS, ceiling, NDL and schedule audit.
11. Full decompression-stop state-machine audit.
12. Full persistence / checkpoint / restore audit.
13. Full logbook / sync / export integrity audit.
14. Full planner briefing card / CCR reference-only safety audit.
15. Full independent oracle parity and external validation plan.
16. Full physical Apple Watch QA matrix.

The complete chain to audit is:

```text
Activity selection
→ Diving
→ Full Computer
→ Predive configuration
→ environment source
   ├── imported iPhone Plan
   ├── manually entered Watch environment
   └── Watch CMAltimeter sensor proposal
→ explicit user confirmation
→ immutable Full Computer runtime plan
→ local surface pressure
→ water density / salinity
→ ambient absolute pressure
→ inspired N2 / He partial pressure
→ initial equilibrium for all 16 N2 and 16 He compartments
→ Haldane / Schreiner update
→ actual elapsed-time / one-second live integration
→ GF ceiling
→ NDL
→ TTS
→ decompression schedule
→ gas switching
→ decompression stop-state machine
→ warnings / UI / haptics
→ checkpoint / restore
→ completed-dive logbook metadata
→ sync / export / iOS parity
→ physical / external validation gates
```

---

# 2. CENTRAL FORENSIC QUESTION

The audit must explicitly answer this scenario:

```text
A diver descends to 39 m on Air.
The diver remains long enough to incur a decompression obligation.
The diver ascends to 10 m.
The diver remains at 10 m for an extended time.
The Watch must continue updating all 16 N2 and all 16 He compartments.
The Watch must continuously recalculate ceiling, NDL, TTS and schedule.
The previous decompression obligation may reduce.
The decompression obligation may disappear only if the current tissue state mathematically permits direct ascent.
The decompression obligation may reappear after a later descent.
```

The audit must not assume that decompression disappears merely because the diver spends time at 10 m.

At 10 m:

- fast compartments may off-gas;
- some compartments may remain supersaturated;
- slow compartments may still on-gas depending on current tissue pressure, gas composition, and inspired inert-gas pressure;
- the controlling compartment may change;
- the ceiling may reduce, remain stable, or evolve non-monotonically;
- decompression may disappear only when the complete current tissue state, Gradient Factors, ambient pressure, and ascent model permit surfacing.

The implementation must derive the answer from the actual 16-compartment state, not from elapsed shallow time, a cached schedule, a stop timer, or a heuristic.

---

# 3. CURRENT PRODUCT ARCHITECTURE TO RESPECT

The current product architecture is:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

This audit focuses on:

```text
Diving → Full Computer → Apple Watch live runtime
```

However, it must verify that Full Computer logic remains isolated from Gauge, Apnea and Snorkeling.

Mandatory isolation rules:

```text
Gauge math/runtime → Gauge only
Full Computer Bühlmann/decompression → Full Computer only
Apnea lifecycle/recovery math → Apnea only
Snorkeling GPS/navigation math → Snorkeling only
```

Mandatory negative checks:

- Full Computer tissues must not be mutated by Gauge.
- Full Computer tissues must not be mutated by Apnea.
- Full Computer tissues must not be mutated by Snorkeling.
- Planner briefing cards must not mutate live Watch tissues.
- iOS Planner must not mutate an active Watch Full Computer dive.
- iOS Settings mode switch must not remotely switch an active Watch session.
- Watch activity Settings must not leak Apnea/Snorkeling settings into Full Computer.
- No cross-activity checkpoint restore.
- No cross-activity logbook contamination.
- No cross-activity settings leakage.

---

# 4. PRODUCT SAFETY POSITIONING

Preserve current safety posture:

- no certified dive-computer claim;
- no certified decompression-planner claim;
- no CCR controller claim;
- no life-support controller claim;
- no EN13319 / ISO 6425 / CE claim unless official evidence exists;
- physical Apple Watch QA remains pending unless physically executed;
- depth-sensor wet validation remains pending unless physically executed;
- CMAltimeter physical validation remains pending unless physically executed;
- external Bühlmann/decompression validation remains pending unless actually executed;
- Planner briefing cards remain reference-only;
- CCR / Rebreather metadata remains reference-only unless explicitly implemented, validated and positioned as live authority.

Any unsupported claim is a release/legal finding.

---

# 5. REQUIRED OUTPUT FILES

Create or replace only these files:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md
Docs/MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_EDGE_CASE_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_ALTITUDE_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_FAILURE_INJECTION_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_NUMERICAL_ERROR_BUDGET_CURRENT.md
Docs/MASTER_WATCH_FULL_COMPUTER_FINDING_TRACEABILITY_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX_CURRENT.csv
Docs/MASTER_WATCH_FULL_COMPUTER_EXTERNAL_VALIDATION_PLAN_CURRENT.md
```

No production source writes are permitted.

---

# 6. SEVERITY MODEL

## P0 — Safety-critical / must block any Full Computer release

Use P0 for:

- false no-decompression clearance;
- Watch shows no decompression while oracle says decompression is required;
- wrong ceiling due to math, altitude, tissue, gas or timing error;
- missed mandatory decompression stop;
- tissue reset during active dive;
- corrupted tissue state;
- stale schedule presented as current;
- gas switch retroactively applied;
- stop timer force-clears ceiling;
- sea-level pressure silently used when altitude-aware mode is implied;
- stale/unvalidated sensor environment authorizes Full Computer start;
- active-dive environment changes silently;
- checkpoint/restore substitutes a different environment or fresh tissues;
- failure path becomes optimistic NDL/TTS/zero ceiling;
- NaN/Inf propagates into user-facing deco state;
- cross-activity state corrupts Full Computer runtime;
- planner/CCR/reference-card value affects live decompression authority.

## P1 — Serious algorithm/release blocker

Use P1 for:

- material Bühlmann/Schreiner error;
- timing drift causing material ceiling/TTS/NDL error;
- segment discontinuity;
- incorrect GF interpolation;
- wrong controlling compartment;
- incomplete altitude propagation;
- incomplete all-16 N2/He coverage;
- TTS or schedule not fully oracle-swept;
- request-generation/lifecycle risk in CMAltimeter sampling;
- missing fail-closed behavior for sampling/restore/timing faults;
- Watch/iOS parity mismatch;
- insufficient independent oracle coverage;
- inadequate persistence/logbook provenance.

## P2

Use P2 for safe failures with incomplete diagnostics, bounded numerical discrepancy, incomplete UI truthfulness, missing negative tests, incomplete documentation, incomplete QA plan, performance risk without proven wrong output, or incomplete observability.

## P3

Use P3 for maintainability, observability, non-blocking performance, documentation clarity and polish.

## P4

Use P4 for optional improvements.

Any unresolved P0 means final audit verdict is `FAIL`.

Missing physical Watch or external decompression evidence prevents full `PASS`.

---

# 7. PREFLIGHT AND BASELINE

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git rev-parse HEAD
git fetch --prune origin
git rev-parse --short origin/main
git status --short
git status -sb
git rev-list --left-right --count HEAD...origin/main
git remote -v
xcodebuild -version
```

If available:

```bash
gh auth status
```

Requirements:

- branch must be exactly `main`;
- local HEAD and origin/main status must be recorded;
- dirty worktree must be recorded;
- no production files may be changed;
- if code is behind/diverged/dirty, document limitation and decide whether baseline is valid.

Stop and report `BASELINE_INVALID` if branch is not `main`.

Inspect:

```text
project.yml
README.md
Docs/**
Shared/**
App/**
Views/**
Services/**
Models/**
Utils/**
Tests/**
Scripts/**
Resources/**
iOSApp/**
```

Record:

```text
branch
commit
origin/main
dirty files
targets
source folders
excluded files
test targets
entitlements
bundle IDs
deployment targets
available simulators
Xcode version
watchOS SDK
iOS SDK
physical Watch availability
external oracle availability
```

---

# 8. BUILD AND TEST BASELINE

If environment allows:

```bash
xcodegen generate

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

Build Watch:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Run Watch tests:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

If shared code, parity or iOS planner inputs are relevant:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Record:

```text
exact command
destination
build result
test count
failures
skips
duration
simulator limitations
```

Do not fix failures.

---

# 9. EXISTING AUDIT COVERAGE AND SPECIALIZED GAP

Before auditing, inspect the latest relevant reports/commands if present:

```text
0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0.md
1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md
2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md
10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0.md
12-DIR_DIVING_TEST_QA_EVIDENCE_AUDIT_V3.0.md
15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_V3.0.md
MASTER_WATCH_DIVING_COMPUTER_FULL_AUDIT_COMMAND_V1.0.md
```

State explicitly:

- what is already covered by broad Watch audits;
- what is newly covered by this merged forensic audit;
- which gaps this command closes.

Expected specialized coverage:

```text
exact Schreiner formula verification
unit and rate conventions
one-second / actual-dt semantics
missed/delayed/duplicated/out-of-order tick behavior
continuity across depth ramps
segment boundary correctness
live multilevel schedule invalidation and rebuilding
dynamic deco-obligation regression
controlling-compartment migration
tissue-state conservation across lifecycle events
independent second-by-second oracle parity
numerical error budget
Watch-specific concurrency and stale-publication risk
fail-safe behavior when computation cannot keep pace
```

---

# 10. TARGET MEMBERSHIP AND SOURCE AUTHORITY AUDIT

From `project.yml`, generated project membership and build logs, prove:

- Full Computer production files are compiled into `DIRDiving Watch App`;
- shared Bühlmann core files are compiled into correct targets;
- `FullComputerEnvironmentSensorService.swift`, if present, is compiled into production Watch target;
- CoreMotion is linked where required;
- effective Watch `Info.plist` contains Motion usage disclosure where required;
- Full Computer runtime is not dead/test-only code;
- no experimental implementation shadows production one;
- there is one canonical live tissue state;
- no duplicated live decompression authority exists;
- no iOS-only altitude provider supplies live Watch Full Computer path;
- no legacy Gauge-only path can start Full Computer accidentally;
- no Planner briefing card path can become live runtime authority.

Search:

```bash
rg -n "FullComputer|Buhlmann|Buehlmann|Schreiner|Haldane|Gradient|GF|ceiling|NDL|TTS|deco|decompression|tissue|compartment|gasSwitch|CMAltimeter|CMAbsoluteAltitudeData|altitude|surfacePressure|waterDensity|seaLevel|legacyUnknown|PlannerBriefingCard|CCR|Rebreather|setpoint|diluent|bailout" App Services Shared Utils Views Models Tests iOSApp project.yml
```

Classify each match as:

```text
production live authority
predive proposal
manual/imported source
derived runtime value
test fixture
independent oracle
reference-only planner card
display-only
persistence/cache
unsupported payload
unsafe fallback
```

---

# 11. FULL FEATURE INVENTORY

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_FEATURE_INVENTORY_CURRENT.csv
```

Required columns:

```text
Feature_ID
Activity
Mode
Feature
Canonical_Source
Runtime_Owner
Input_Validation
Mathematical_Functions
Persistence
Restore
Sync
Presentation
Tests
Independent_Oracle
External_Validation
Physical_QA
Readiness_Percent
Notes
```

Inventory:

## Diving / Gauge boundary

```text
depth
max depth
average depth
runtime
ascent rate
TTV
alarms
reminders
lifecycle thresholds
sensor validation
unit conversion
persistence
sync/export
Gauge → Full Computer boundary
```

## Diving / Full Computer

```text
environment source
CMAltimeter proposal
manual Watch environment
imported iPhone Plan environment
local surface pressure
salinity
water density
ambient pressure
inspired inert pressures
water-vapour pressure
all 16 N2 compartments
all 16 He compartments
Haldane
Schreiner
actual elapsed time
one-second semantics
GF Low/High
ceiling
NDL
TTS
decompression schedule
first stop
stop increments
stop-state machine
gas definitions
gas switching
PPO2/MOD
CNS/OTU if live
controlling compartment
multilevel continuity
checkpoint restore
logbook metadata
export/sync
UI/haptic warnings
fail-closed states
```

## Reference-only compatibility

```text
Planner briefing cards
PNG card rendering
structured metadata
decompression stop reference values
Rock Bottom / emergency gas
gas ledger
CCR setpoints
diluent
bailout
gas density
stale/superseded card policy
```

---

# 12. LIVE ENGINE ARCHITECTURE MAP

Build a call graph from sensor sample to displayed result:

```text
Depth/pressure sample
→ validation/filtering
→ monotonic timestamp
→ depth/ambient-pressure conversion
→ active gas resolution
→ inspired inert-gas pressure
→ tissue update
→ GF/ceiling computation
→ NDL/decompression schedule/TTS
→ stop-state machine
→ published runtime state
→ UI/haptic/persistence
```

Identify exact symbols responsible for:

```text
tissue initialization
tissue update
Schreiner calculation
Haldane constant-depth calculation
pressure-depth conversion
water-vapour pressure
surface pressure
N2 inspired pressure
He inspired pressure
mixed a/b coefficients
GF interpolation
ceiling
NDL
schedule generation
TTS
first stop
stop rounding
gas switching
decompression-stop tracking
controlling compartment
runtime publication
state checkpointing/restoration
```

Classify each component:

```text
Component
File/Symbol
Canonical
Derived
PresentationOnly
Stateful
ActorOrThread
Tests
Evidence
```

---

# 13. ROOT FLOW AND FULL COMPUTER STARTUP AUTHORITY

Audit:

```text
Launch
→ legal/onboarding gate
→ activity selection
→ Diving
→ Full Computer
→ Predive Settings / Confirmation
→ accepted environment
→ confirmed profile
→ commitConfirmedProfile
→ FullComputerRuntimePlan
→ FullComputerPrediveReadiness
→ DiveManager Full Computer start
→ FullComputerRuntimeEngine.init(plan:sessionStart:)
```

Verify:

- legal/safety prerequisites before Full Computer start;
- no default sea-level runtime plan authorizes start;
- no incomplete environment authorizes start;
- profile/environment committed atomically;
- start revalidates freshness;
- gas/environment cannot be mixed from different sources;
- accepted environment frozen at dive start;
- later altimeter callback cannot mutate active plan;
- Watch setting change cannot mutate active plan;
- iPhone sync cannot mutate active plan;
- Planner briefing card cannot mutate active plan.

Search:

```bash
rg -n "FullComputerRuntimeEngine\\(|FullComputerRuntimeEngine\\.canStart|FullComputerRuntimePlan\\(|seaLevelSaltWater|legacyUnknown|runtimePlan\\(|commitConfirmedProfile|confirmedEnvironment|draftEnvironment|pendingSensorProposal" Services Shared Utils Views Tests
```

---

# 14. ENVIRONMENT SOURCE POLICY

Evaluate exact policy:

## Imported from iPhone Plan

- preserve complete signed/validated plan environment;
- never silently overwritten by sensor proposal;
- source displayed and logged.

## Manually entered on Watch

- altitude/environment setting on Watch;
- validated before use;
- source displayed and logged.

## Sensor-measured proposal

- sampled directly from Watch absolute-altitude sensor immediately before Full Computer confirmation;
- requires explicit diver acceptance;
- never becomes authority automatically.

## No sea-level fallback

- no exposed sea-level shortcut;
- no implicit sea-level fallback;
- validated zero/near-zero altitude may naturally occur;
- missing environment must fail closed.

Verify:

```text
source precedence
conflict detection
explicit user choice
source provenance
start blocking
active-dive immutability
logbook provenance
restore provenance
```

---

# 15. CMALTIMETER / ABSOLUTE ALTITUDE FORENSIC AUDIT

Inspect:

```text
FullComputerEnvironmentSensorService
AppleWatchAbsoluteAltitudeProvider
FullComputerPrediveConfigurationStore
FullComputerPrediveConfirmationView
FullComputerPrediveSettingsView
Watch Settings
tests involving altitude provider
```

Prove:

- `CMAltimeter.isAbsoluteAltitudeAvailable()` is checked;
- a retained `CMAltimeter` instance survives asynchronous sampling;
- `CMAltimeter.startAbsoluteAltitudeUpdates(to:withHandler:)` is used;
- relative altitude is not used as authoritative source;
- GPS altitude is not used as authoritative source;
- callbacks use documented queue/actor behavior;
- both `data` and `error` are handled;
- nil data + nil error handled fail-closed;
- `stopAbsoluteAltitudeUpdates()` called on success/error/timeout/cancel/replacement;
- repeated starts cannot leak subscriptions;
- callback after cancellation ignored;
- callback from superseded request ignored;
- request-generation identity exists where needed;
- old request cannot contaminate newer request;
- late error after success cannot overwrite proposalReady;
- imported/manual authority is preserved unless diver explicitly accepts the sensor proposal.

Audit sample policy:

```text
required sample count
maximum accepted accuracy
maximum stable spread
timeout
median/selection statistic
supported altitude range
sensor max age
timestamp/freshness logic
NaN/Inf rejection
negative accuracy/precision rejection
stale sample rejection
future timestamp rejection
```

Distinguish:

```text
sensor measurement timestamp
callback receipt time
wall-clock conversion
freshness age
diagnostic receipt timestamp
```

---

# 16. SENSOR PROPOSAL STATE MACHINE

Trace:

```text
FullComputerEnvironmentSensorState
requestProposal
pendingSensorProposal
proposeSensorEnvironment
acceptPendingSensorProposal
dismissPendingSensorProposal
draftEnvironment
confirmedEnvironment
```

Create transition table:

```text
State
Event
Guard
Next_State
Environment_Mutation
UI_State
Persistence_Effect
Start_Allowed
Evidence
```

Verify:

- sampling clears obsolete pending proposal only;
- sampling does not mutate imported/manual authority;
- valid sensor window creates pending proposal;
- only explicit acceptance promotes proposal;
- rejection preserves previous authority exactly;
- acceptance revalidates freshness and quality;
- start/review controls blocked while sampling/unresolved proposal;
- no automatic lifecycle event counts as acceptance;
- VoiceOver/Digital Crown/double tap cannot bypass acceptance;
- active dive cannot accept or alter environment.

---

# 17. CANONICAL ENVIRONMENT RECORD AUDIT

Audit:

```text
FullComputerEnvironmentRecord
PlannerEnvironment
AmbientPressureModel
FullComputerRuntimePlan
FullComputerPrediveReadiness
```

A valid environment must include or derive:

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

- finite altitude;
- supported range;
- altitude-to-pressure formula;
- independent surface-pressure cross-check;
- no fixed sea-level pressure;
- salinity/density consistency;
- future schema rejection;
- stale sensor rejection;
- source-specific validation;
- old schema cannot authorize incomplete sensor environment;
- `.seaLevelSaltWater` or default runtime plan cannot authorize live Full Computer start.

---

# 18. PRESSURE, DEPTH AND INSPIRED-GAS MODEL

Verify complete conversion:

```text
sensor depth/pressure
→ validated depth
→ local surface pressure
→ hydrostatic pressure
→ ambient absolute pressure
→ water-vapour subtraction
→ inspired gas pressure
→ inert-gas partial pressure
```

Audit:

```text
seawater/freshwater constants
depth-to-pressure convention
altitude/surface pressure
water-vapour pressure
respiratory assumptions if any
pressure clamping
negative depth
sensor noise near surface
salinity setting
water density
temperature usage if any
rounding location
```

Verify ambient pressure equivalent:

```text
ambientAbsolutePressure =
localSurfacePressure +
hydrostaticPressureFromDepth
```

Reject hardcoded sea-level models where altitude is claimed:

```text
ambient = 1.0 + depth / 10
```

Verify gas fractions:

```text
FN2 = 1 - FO2 - FHe
```

Ensure:

- fraction sum validated;
- inspired N2/He derived from active gas;
- gas switch changes inspired model exactly at intended timestamp/depth;
- stale gas not used for later interval;
- display-rounded depth never feeds canonical pressure;
- invalid pressure never reaches tissue math.

---

# 19. BÜHLMANN ZH-L16C CONSTANTS AND MODEL IDENTITY

Verify claimed ZH-L16C model variant against authoritative reference constants.

For all 16 compartments inspect:

```text
N2 half-times
He half-times
N2 a coefficients
N2 b coefficients
He a coefficients
He b coefficients
ordering and indexing
precision type
initialization values
serialization order
```

Mandatory checks:

- exactly 16 compartments;
- no off-by-one mapping;
- N2 and He arrays have identical compartment ordering;
- no coefficient copied from ZH-L16A/B while claiming ZH-L16C;
- no truncated/rounded constant causing material drift;
- no locale parsing;
- no percentage/fraction confusion;
- constants immutable during dive;
- restored tissue vectors preserve exact compartment identity.

Create constants table.

External reference validation remains pending unless actually executed.

---

# 20. TISSUE INITIALIZATION WITH ALTITUDE

Verify all initial equilibrium states use local surface pressure:

```text
PN2_initial = (surfacePressure - waterVapourPressure) × FN2
PHe_initial = (surfacePressure - waterVapourPressure) × FHe
```

Check:

```text
Air
Nitrox
Trimix
zero helium
helium-containing gas
high altitude
near-zero altitude
freshwater
saltwater
repetitive residual state
restore
invalid/missing altitude
manual environment
imported environment
accepted sensor proposal
```

Reject:

- tissue initialization at sea level followed by altitude later;
- altitude/surface pressure applied twice;
- missing He initialization;
- fresh fallback on restore;
- default fresh tissues after active checkpoint restore.

---

# 21. SCHREINER EQUATION FORENSIC VERIFICATION

Locate every implementation or equivalent transformation of the Schreiner equation.

For each inert gas and compartment, verify algebraic equivalence to:

```text
P_t(t) =
P_i0
+ R * (t - 1/k)
- (P_i0 - P_t0 - R/k) * exp(-k*t)
```

where:

```text
k = ln(2) / halfTime
P_t0 = initial tissue inert-gas pressure
P_i0 = inspired inert-gas pressure at segment start
R = linear inspired inert-gas pressure change rate
t = elapsed segment time
```

The audit must prove equivalence rather than rely on naming.

Verify formula correctness:

- sign of each term;
- exponential term;
- use of ln(2);
- half-time unit;
- inspired-pressure start value;
- pressure-rate sign during descent/ascent;
- gas fraction;
- water-vapour subtraction;
- surface/ambient pressure convention;
- N2 and He independently;
- no O2 tissue compartment;
- no total ambient pressure used as inert pressure;
- no end-of-segment inspired pressure substituted for start pressure;
- no double rate application.

Verify units:

```text
seconds vs minutes
metres vs bar/ATA
metres/min vs bar/second
gas fractions vs percentages
absolute vs gauge pressure
salt/freshwater pressure conversion
altitude surface pressure
```

Mandatory limiting cases:

1. `R = 0` reduces to Haldane exponential equation.
2. `t = 0` returns `P_t0`.
3. Very small `dt` stable.
4. Positive rate models descent.
5. Negative rate models ascent.
6. N2-only gas with He = 0 keeps He behavior correct.
7. Helium removal/switch never creates negative tissue pressure.
8. Constant-depth repeated one-second updates converge toward inspired pressure.
9. Full linear segment once ≈ same segment split into one-second updates.
10. Segment splitting error quantified and bounded.

Any unit ambiguity or equation mismatch is at least P1 and P0 if it can understate decompression.

---

# 22. HALDANE CONSTANT-DEPTH PARITY

Verify constant-depth Haldane update:

- altitude-aware inspired pressure;
- all 16 N2 and all 16 He compartments;
- finite guards;
- zero-rate Schreiner parity;
- tested at compartments 1, 4, 8, 12, 16;
- tested at sea level and altitude;
- tested for Air, Nitrox, Trimix, O2 stop gas where relevant.

Zero-rate Schreiner and Haldane must agree within documented tolerance.

---

# 23. ONE-SECOND AND ACTUAL-DT SEMANTICS

The phrase “updated every second” must be proven from runtime behavior.

Audit:

```text
timer source
sensor callback frequency
computation trigger
timestamp source
monotonic clock
actual dt
actor/task ownership
cancellation
app lifecycle
background/foreground
dropped frames
duplicate callbacks
sensor bursts
delayed samples
stale samples
out-of-order timestamps
```

Determine whether engine:

1. blindly assumes `dt = 1.0 s`;
2. uses actual elapsed monotonic time;
3. integrates per sensor sample;
4. accumulates time and steps in fixed quanta;
5. mixes more than one method.

Mandatory invariants:

- tissue evolution uses elapsed time, not UI timer count;
- delayed tick does not lose exposure;
- duplicate tick does not double-count;
- out-of-order sample rejected or safely handled;
- UI frequency does not control tissue math;
- sensor frequency does not double-integrate same interval;
- computations cannot overlap and publish out of order;
- slow calculation cannot overwrite newer tissue state;
- `dt <= 0`, huge dt, NaN and Inf fail safely;
- app background/restore semantics explicit;
- active dive restore does not reset tissue history.

Create timing-fault coverage for:

```text
0.5 s
1.0 s
1.5 s
2 s
5 s
10 s
30 s
120 s
121 s
5 min
10 min
30 min
duplicate timestamp
negative timestamp delta
out-of-order timestamp
suspended app
Watch restart/restore
```

---

# 24. TISSUE STATE INTEGRITY

Audit full 16-compartment state.

Verify:

- N2 and He stored separately;
- update atomic across all compartments;
- previous state immutable during calculation;
- no partial publication;
- no aliasing/copy-on-write bug;
- no race between schedule generation and tissue mutation;
- controlling compartment derived from same snapshot;
- ceiling and TTS use same tissue snapshot;
- persistence encodes all 32 inert values with adequate precision;
- restoration does not reorder compartments;
- version migration explicit;
- corrupt checkpoints fail closed;
- no fresh-tissue fallback during active/restored dive unless surfaced as critical failure.

Mandatory invariants:

- tissue pressure finite;
- tissue pressure never materially negative;
- no discontinuity at segment boundary;
- no reset on gas switch;
- no reset when deco appears/disappears;
- no reset when moving between UI screens;
- no reset under Mission Mode;
- Gauge cannot contaminate Full Computer tissue state;
- iOS planner card cannot alter live tissue state.

---

# 25. GRADIENT FACTORS AND CEILING

Verify:

```text
GF Low/High validation
bounds and ordering
storage/persistence
dive-start snapshot
no unsafe mid-dive remote mutation
interpolation method
interpolation anchors
first-stop/deepest-ceiling reference
surface endpoint
compartment-wise allowable ambient pressure
N2/He combined a/b
zero-total-inert edge
controlling compartment
ceiling conversion to depth
ceiling rounding
negative ceiling handling
```

Ceiling conversion must be equivalent:

```text
ceilingDepth =
(requiredAmbientPressure - localSurfacePressure) /
waterPressureGradient
```

Determine whether GF interpolation is:

- based on current ambient pressure;
- based on first stop and surface;
- recomputed consistently when schedule changes;
- stable when deco obligation disappears and later reappears.

Mandatory scenarios:

```text
fresh tissues at surface
no-deco descent
newly incurred deco
reduced ceiling during shallow multilevel stay
ceiling reaches zero
re-descent after zero ceiling
controlling compartment changes
gas switch changes controlling compartment
GF 30/70
GF 20/80
GF 30/30
GF 50/50
invalid GF values
```

---

# 26. LIVE NDL, SCHEDULE AND TTS RECOMPUTATION

Determine exactly how often the Watch recomputes:

```text
NDL
current ceiling
decompression schedule
first stop
stop list
TTS
controlling compartment
```

Verify schedule generation uses:

- latest tissue state;
- latest active gas;
- current depth;
- configured ascent rates;
- configured stop increments;
- current GF;
- valid future gas switches.

Mandatory requirements:

- a schedule generated at 39 m must not remain authoritative after prolonged 10 m stay;
- schedule cache invalidation deterministic;
- TTS reduces when tissue state permits;
- stop times reduce/disappear only through recomputation;
- no negative stop time;
- no stale stop retained after ceiling clears;
- no NDL displayed while positive ceiling exists;
- no no-deco state while mandatory stops remain;
- no schedule disappearance merely because diver entered shallower band;
- no schedule generated from display-rounded tissues/depth;
- failure/timeout retains conservative stale/error state, not optimistic zero-deco.

Quantify schedule recomputation latency and maximum stale-output window.

---

# 27. GAS / PPO2 / MOD / SWITCH AUDIT

Audit:

```text
gas inventory
active gas identity
switch eligibility
MOD
PPO2
switch depth
user confirmation if required
timestamp/order of switch
tissue update before/after switch
schedule future-gas assumptions
duplicate/rejected switch
reversion to previous gas
unavailable gas
hypoxic gas
O2 100%
Trimix
```

Mandatory ordering proof:

```text
previous interval integrated with old gas
→ switch event committed
→ next interval integrated with new gas
→ schedule rebuilt with new current/future gas state
```

A gas switch must not retroactively change the preceding second.

---

# 28. DECOMPRESSION STOP STATE MACHINE

Audit semantic states:

```text
noDecompression
approachingNDL
decompressionRequired
approachingStop
atStop
aboveStop
belowStop
stopPaused
stopReset/restarted
stopCompleted
decompressionCleared
surfaced
error/stale
```

Verify relationships among:

```text
mathematical ceiling
rounded stop depth
current depth
stop tolerance band
stop timer
schedule
TTS
UI status
haptic status
```

Product stop rules to verify:

- timer pauses outside permitted band;
- too shallow never credits stop;
- descending materially below the stop may require stop again;
- UI/state rules do not mutate tissue pressure;
- schedule remains mathematically authoritative;
- completing displayed stop does not force-clear deco if ceiling still requires it.

Test:

```text
exact stop
0.5 m above
1.0 m above
1.0 m below
more than 2.0 m below
sensor jitter
leave/re-enter band
gas switch during stop
schedule shortens while at stop
stop disappears because ceiling clears
deeper stop appears after re-descent
```

---

# 29. MULTILEVEL DIVE FORENSIC PROFILES ML-01 THROUGH ML-10

Generate deterministic second-by-second test vectors and compare Watch engine against independent oracle.

## ML-01 — Air 39 m → 10 m, deco incurred then shallow level

```text
Gas: Air
GF: project defaults and at least 30/70
Surface: sea level and at least one altitude case
Descent: configured rate to 39 m
Bottom: duration sufficient to produce mandatory deco
Ascent: configured rate to 10 m
Level: remain at 10 m until:
  a. ceiling reduces;
  b. controlling compartment changes;
  c. schedule changes;
  d. deco obligation possibly disappears, if mathematically permitted
Then ascend to surface only when model allows.
```

Record every second:

```text
runtime
depth
ambient pressure
active gas
inspired PN2
inspired PHe
N2_01 ... N2_16
He_01 ... He_16
compartment ceiling
controlling compartment
overall ceiling
GF applied
NDL/deco state
stop list
TTS
event
production result
oracle result
absolute error
relative error
pass/fail
```

Identify exact second:

- deco first appears;
- deepest ceiling occurs;
- each schedule transition occurs;
- controlling compartment changes;
- deco clears if it clears.

## ML-02 — Same profile with EAN50 switch at 21 m

Verify gas-switch boundary, tissue continuity, accelerated off-gassing where expected, MOD/PPO2 validity, schedule rebuild and CNS/OTU isolation.

## ML-03 — Trimix bottom gas + deco gases

Verify N2/He dual-gas tissue behavior and changing combined coefficients.

## ML-04 — Sawtooth profile

```text
39 m → 18 m → 30 m → 12 m → 24 m → 9 m
```

Verify no schedule cache assumption and no tissue reset.

## ML-05 — Deco clears, then re-descent

Verify preserved tissue state, no fresh NDL reset, deco reappears if required, controller changes and schedule rebuilt.

## ML-06 — Hover around stop/ceiling boundary

Verify stop timer/state logic separately from tissue math.

## ML-07 — Very slow ascent

Verify Schreiner rate handling and one-second stepping parity.

## ML-08 — Rapid but valid ascent

Verify negative rate, stability and alarm/math separation.

## ML-09 — Long shallow 10 m level

Show slow compartments may continue loading depending on state and gas.

## ML-10 — Surface interval and repetitive continuation

Verify off-gassing and next-dive initialization where supported.

For every profile create:

```text
Watch result
oracle result
absolute error
relative error
pass/fail tolerance
first divergence timestamp
affected compartment
user-visible consequence
```

---

# 30. ALTITUDE SCENARIO MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_ALTITUDE_MATRIX_CURRENT.csv
```

Run deterministic profiles at:

```text
0 m
500 m
1,000 m
1,500 m
2,000 m
maximum supported altitude
one value above maximum
```

For each altitude run:

```text
Air profile
Nitrox profile
Trimix / helium profile
multilevel ascent
gas switch
NDL-to-deco transition
checkpoint/restore
invalid altitude
```

Columns:

```text
Case_ID
Altitude_m
SurfacePressure_bar
Water_Type
Gas
Profile
Runtime_s
N2_01 ... N2_16
He_01 ... He_16
Ceiling_m
Controlling_Compartment
NDL_s
TTS_s
Schedule
Production_Result
Oracle_Result
Absolute_Error
Relative_Error
Pass
Severity
Evidence
Notes
```

---

# 31. SCHREINER TEST VECTOR MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv
```

Minimum columns:

```text
ID
Profile
Gas
GF_Low
GF_High
Environment
Compartment
HalfTime
Initial_PN2
Initial_PHe
Start_Depth
End_Depth
Duration_s
Rate
Expected_PN2
Expected_PHe
Watch_PN2
Watch_PHe
Absolute_Error
Relative_Error
Expected_Ceiling
Watch_Ceiling
Expected_Controller
Watch_Controller
Expected_Deco_State
Watch_Deco_State
Pass
Evidence
Notes
```

Include hand-checkable vectors for compartments:

```text
1
4
8
12
16
```

and all 16 compartments for core multilevel profiles.

---

# 32. MULTILEVEL DECO TRANSITION MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv
```

Columns:

```text
Profile_ID
Timestamp
Depth
Gas
Overall_Ceiling
Rounded_Stop
TTS
NDL
Controlling_Compartment
Deco_State
Expected_Transition
Actual_Transition
Pass
Evidence
```

---

# 33. INDEPENDENT ORACLE REQUIREMENT

Do not compare production only with itself.

Use or create a test-only independent oracle that:

- does not import production tissue update;
- does not reuse production constants without independent checking;
- implements Bühlmann/Schreiner separately;
- supports same pressure/environment assumptions;
- emits all 16 N2/He compartment values;
- supports one-second and analytic segment calculations;
- produces ceiling and controlling compartment;
- can replay CSV depth/gas timelines.

Preferred evidence hierarchy:

1. independently implemented mathematical oracle;
2. trusted open decompression implementation with documented assumptions;
3. hand calculations for selected compartments/timestamps;
4. external comparison against established tools;
5. production self-tests only as supplementary evidence.

The iOS Planner is not automatically independent if it shares core logic.

Self-comparison masquerading as oracle is a P1 finding.

---

# 34. SCHREINER ANALYTIC VS ONE-SECOND PARITY

For each test gas and compartment compare:

```text
A. One analytic Schreiner update over complete linear segment
B. Repeated 1-second Schreiner updates
C. Repeated 1-second constant-depth/Haldane approximation using sampled end depths, if production does this
D. Production Watch result
```

Test segments:

```text
surface to 39 m
39 m to 10 m
10 m to 3 m
3 m to surface
60 m to 21 m
slow 1 m/min ascent
fast configured ascent
depth reversal mid-segment
```

Quantify:

```text
maximum compartment pressure error
ceiling error in metres
TTS error in seconds/minutes
time-to-deco-clear error
accumulated error after 30, 60, 120 and 240 minutes
```

Define explicit acceptance tolerances and justify them.

A tolerance must not be selected merely because current implementation passes.

---

# 35. CROSS-ENGINE PARITY

Where iOS and Watch have separate or shared implementations, compare:

```text
constants
initial tissues
pressure model
Schreiner equation
Haldane
GF
ceiling
schedule
gas switch
result rounding
environment source
Planner briefing card values
logbook/export fields
```

Determine whether:

- code is shared;
- one engine wraps another;
- implementations are duplicated;
- outputs diverge.

Run identical profile replays through both if possible.

Differences must be explained by intentional configuration, not platform drift.

---

# 36. PERSISTENCE / CHECKPOINT / RESTORE

Trace:

```text
FullComputerPrediveConfigurationStore
FullComputerRuntimeCheckpoint
DiveManager checkpoint/restore
FullComputerRuntimeLogbookAccumulator
FullComputerDiveLogbookMetadata
DiveLogStore
WatchSyncService
```

Verify checkpoint preserves:

```text
altitude
surface pressure
water density
salinity
environment source
sensor timestamp
accuracy
precision
gas
GF
runtime
depth
all 16 N2 tissues
all 16 He tissues
active gas
current ceiling
current schedule
stop state
last timestamp
degraded state
schema version
checksum/integrity if present
```

Restore invariants:

- no fresh tissue fallback;
- no sea-level fallback;
- no current sensor substitution;
- no current Watch setting substitution;
- no newly imported plan substitution;
- schedule recomputed from restored tissues/environment;
- corrupt/missing environment fails safely;
- future schema fails safely;
- repeated restore idempotent;
- elapsed suspension handled explicitly;
- wall-clock changes do not corrupt dt.

Generate restore tests at:

```text
no-deco bottom
immediately after deco appears
during ascent
at a deco stop
during prolonged 10 m level
immediately after deco clears
after gas switch
after controlling-compartment change
during degraded state
after relaunch
```

---

# 37. LOGBOOK / EXPORT / SYNC MATHEMATICAL INTEGRITY

Verify completed-dive metadata matches frozen runtime environment, not later store value.

Logbook must preserve:

```text
environment source
altitude
surface pressure
salinity
water density
sensor timestamp
accuracy
precision
degraded state
gas switches
GF
ceiling/TTS/deco events where intended
```

Verify sync/export:

- units exact;
- precision preserved;
- schema version;
- HMAC/signature preserved;
- activity discriminator;
- duplicate ID handling;
- future schema handling;
- malformed payloads fail safely;
- Watch/iOS parity;
- no manual/imported value mislabeled as sensor-measured;
- unavailable CCR/planner values not shown as zero.

---

# 38. PLANNER BRIEFING CARD / CCR REFERENCE-ONLY

Audit:

```text
PlannerBriefingCard
PlannerBriefingWatchReceiver
PlannerBriefingCardStore
briefing card views
structured metadata
rendered PNG
transfer ACK/status
replacement/deletion/stale handling
```

Verify briefing cards are reference-only and cannot:

- change live Watch dive state;
- start/stop a dive;
- change alarms/reminders/Mission Mode/sensor source;
- change Full Computer environment;
- change gases;
- change tissues;
- execute decompression schedule.

If CCR/Rebreather metadata exists:

- setpoint reference-only;
- diluent labelled separately;
- bailout labelled separately;
- gas density estimate labelled;
- bailout scenario reference-only;
- no live CCR controller claim;
- no live PPO2 control.

Any CCR/planner reference value feeding live decompression calculation is P0 unless explicitly designed, validated and legally positioned.

---

# 39. UI / HAPTIC / SAFETY PRESENTATION TRUTHFULNESS

Without redesigning UI, audit truthfulness:

- environment source visible;
- altitude support truthful;
- no hidden sea-level fallback;
- Full Computer unavailable/degraded states visible;
- NDL/TTS not shown authoritative when stale;
- critical alerts prioritized;
- stop state truthful;
- gas switch confirmation truthful;
- physical QA pending not hidden in docs;
- reference-only planner/CCR data labelled.

Small-screen safety visibility:

- depth hero visible;
- runtime visible;
- ceiling/deco/stop visible;
- ascent warning visible;
- critical banners visible;
- non-critical badges collapse;
- Mission Mode does not hide safety;
- VoiceOver order logical;
- no scroll required to discover primary critical metric.

Reminder/haptic interaction:

- reminder cannot suppress critical alert;
- critical alert cannot be dismissed like reminder;
- haptic storm avoided;
- haptics respect global toggle;
- degraded state has appropriate alert policy.

---

# 40. APP INTENTS / ACTION BUTTON AUDIT

Audit any intent related to:

```text
start dive
stop dive
Full Computer start
alarm acknowledgement
bearing set/clear
reminder acknowledgement
Mission Mode
briefing cards
gas switch
settings
```

Verify:

- legal/safety gate enforced;
- unsafe shortcuts blocked;
- active state validation;
- no simulation-as-real bypass;
- no sensor source bypass;
- no briefing-card execution;
- no CCR/planner metadata live authority;
- error messages localized;
- haptic policy respected.

---

# 41. FAILURE INJECTION MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_FAILURE_INJECTION_MATRIX_CURRENT.csv
```

Include:

```text
absolute altitude unavailable
Core Motion permission/privacy denied
Core Motion callback error
timeout with no data
inaccurate-only data
unstable-only data
valid samples followed by error
nil data + nil error
cancel before first sample
cancel after partial window
cancel concurrent with final sample
two rapid requestProposal calls
late callback from old request
late error after success
settings-to-confirmation race
confirmation dismissal
app background during sampling
app relaunch before start
clock discontinuity
corrupt persisted proposal
active-dive altitude change attempt
sensor value outside range
missing sensor metadata
derived pressure mismatch
invalid gas
NaN depth
Inf depth
negative depth
duplicate timestamp
negative dt
out-of-order tick
long suspension
checkpoint corruption
future schema
stale planner card
malformed planner card
unsupported CCR card
sync replay
duplicate ACK
missing ACK
HMAC failure
calculation timeout
schedule non-convergence
memory pressure
```

Columns:

```text
Case_ID
Area
Initial_State
Fault
Expected_Result
Actual_Result
Environment_Authority_After_Fault
Start_Allowed
Runtime_Output
UI_Diagnostic
Subscription_Cleanup
Persistence_Effect
Severity
Evidence
Required_Remediation
Acceptance_Test
```

Any error path that becomes sea level, no-deco, zero ceiling, zero TTS, or authorized legacy environment is P0.

---

# 42. EDGE-CASE MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_EDGE_CASE_MATRIX_CURRENT.csv
```

Columns:

```text
ID
Activity
Mode
Feature
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

```text
zero depth
negative depth
high depth
exact thresholds
invalid depth
irregular timing
long dive
multilevel deco
gas switch
deco clear
re-descent
stop-band violations
altitude changes
freshwater/saltwater
unit conversion
restore
malformed sync
stale sensor
future schema
no physical evidence
```

---

# 43. REQUIREMENT / TEST MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_REQUIREMENT_TEST_MATRIX_CURRENT.csv
```

Required columns:

```text
Requirement_ID
Area
Requirement
Production_Source
Test_File
Test_Name
Sea_Level
Altitude_500m
Altitude_1000m
Altitude_1500m
Altitude_2000m
Max_Altitude
Invalid_Case
Oracle_Coverage
Physical_QA
External_Validation
Result
Evidence
Severity
Notes
```

Cover:

```text
target membership
legal gate
activity isolation
environment source policy
CMAltimeter lifecycle
sample quality
explicit acceptance
no sea-level fallback
pressure model
tissue initialization
all 16 N2
all 16 He
Haldane
Schreiner
actual dt
GF
ceiling
NDL
TTS
schedule
gas switch
stop state
persistence
restore
logbook
sync/export
briefing cards
CCR reference-only
physical QA
```

---

# 44. NUMERICAL ROBUSTNESS AND ERROR BUDGET

Audit:

```text
Double vs Float
exponent underflow/overflow
cancellation error
exp
division by near-zero
NaN
infinity
denormals
comparison epsilon
exact zero checks
rounding
integer truncation
time conversion
pressure conversion
serialization precision
```

Run adversarial values:

```text
zero depth
tiny depth
extreme bounded depth
very long runtime
GF limits
FO2/He boundaries
zero inert fraction
tiny dt
huge dt
invalid half-time
corrupt tissue state
negative rate
rate sign reversal
```

Canonical calculations must not use display rounding.

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_NUMERICAL_ERROR_BUDGET_CURRENT.md
```

with:

```text
Source_of_Error
Bound
Measured_Worst_Case
Safety_Direction
Accepted
Evidence
```

---

# 45. CONCURRENCY, ORDERING AND STALE RESULTS

Inspect Swift concurrency and state publication.

Verify:

- one owner for mutable tissue state;
- actor/main-actor boundaries;
- no unsynchronized access;
- no overlapping update tasks;
- schedule calculation cancellation;
- generation/version token for async results;
- stale result rejection;
- deterministic event ordering;
- sensor event ordering;
- gas-switch event ordering;
- lifecycle event ordering;
- persistence ordering;
- UI cannot mutate canonical tissue snapshot.

Race scenarios:

```text
new depth sample while schedule calculation is running
gas switch while prior tissue update pending
app background during update
restore while stale task completes
rapid UI navigation
WatchConnectivity payload during dive
settings change attempt during active dive
duplicate sensor callback
timer and sensor callback at same timestamp
computation exceeds one second
```

Older result overwriting newer state is P0/P1 depending on output.

---

# 46. PERFORMANCE, BATTERY AND DEADLINE BEHAVIOR

Measure or statically estimate:

```text
tissue update duration
ceiling calculation duration
NDL calculation duration
full schedule/TTS generation duration
allocations per tick
memory growth
CPU wakeups
main-thread work
thermal/battery risk
worst-case multigas technical profile
longest schedule
history/chart sampling if live
```

Requirements:

- one-second deadline normally met;
- missed deadline policy explicit;
- actual dt accounts for delay;
- backlog cannot accumulate indefinitely;
- schedule throttling cannot hide stale/optimistic output;
- Mission Mode does not reduce tissue update fidelity;
- low-power UI behavior does not reduce decompression authority;
- background policy truthful.

Separate simulator measurements from physical Apple Watch evidence.

---

# 47. TEST COVERAGE AND MUTATION AUDIT

Inventory tests covering:

```text
Bühlmann constants
Haldane
Schreiner
one-second update
descent
ascent
constant depth
multilevel
Trimix
gas switch
GF
ceiling
NDL
TTS
schedule convergence
stop state
restore
concurrency
performance
invalid input
CMAltimeter lifecycle
altitude source
proposal state
logbook provenance
planner briefing card reference-only
```

Classify evidence:

```text
unit
integration
replay
oracle
simulator
physical Watch
paired device
underwater
external reference
```

Negative checks:

- production self-comparison does not count as independent validation;
- snapshot/UI tests do not prove tissue correctness;
- planner tests do not automatically prove live Watch parity;
- build success does not prove algorithm validity;
- code coverage without assertion quality does not count as readiness.

Propose mutation tests:

```text
reverse Schreiner rate sign
use seconds as minutes
swap N2/He half-times
alter one coefficient
skip one compartment
cache schedule indefinitely
drop one-second update
duplicate tick
use end pressure as Pi0
reset tissues on gas switch
clear deco on error
sea-level fallback at altitude
stale sensor accepted
late callback overwrites proposal
stop timer clears tissue ceiling
planner card mutates live runtime
cross-activity checkpoint contamination
```

The existing test suite should fail each material mutation.

---

# 48. PHYSICAL WATCH QA MATRIX

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_PHYSICAL_QA_MATRIX_CURRENT.csv
```

Every unexecuted scenario must be `PENDING_PHYSICAL`.

Include:

```text
physical Watch target install
real depth sensor availability
dry-run Full Computer start blocked without valid environment
manual Watch environment accepted
imported iPhone plan accepted
CMAltimeter available
CMAltimeter unavailable
CMAltimeter permission denied
stable sensor proposal
unstable sensor proposal
sensor accepted
sensor rejected preserving manual/imported value
background/foreground during sampling
rapid Settings/Confirmation navigation
relaunch before dive start
controlled dry-run runtime plan source preservation
checkpoint/restore dry run
paired iPhone sync
logbook provenance
smallest Watch display
VoiceOver traversal
haptic priority
depth sensor wet test
ascent warning wet/dry safe test
controlled multilevel replay if possible
battery/thermal observation
```

---

# 49. EXTERNAL VALIDATION PLAN

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_EXTERNAL_VALIDATION_PLAN_CURRENT.md
```

Include:

```text
independent Bühlmann implementation comparison
Subsurface/reference tool where applicable
exported replay vectors
sea-level and altitude profiles
Air / Nitrox / Trimix
39 m → 10 m profile
gas-switch profile
re-descent profile
surface interval profile
TTS/schedule comparison
tolerance table
profile CSV format
environment assumptions
GF assumptions
ascent/descent rates
stop increments
gas-switch rules
discrepancy triage
physical dry run
simulator replay
paired-device logging
controlled-water testing
pressure-pot/chamber strategy where appropriate
real Apple Watch Ultra underwater validation
safety governance
independent reviewer sign-off
```

Status remains `PENDING_EXTERNAL_VALIDATION` unless actual evidence exists.

Do not claim EN13319, medical, decompression or dive-computer certification.

---

# 50. MASTER REPORT STRUCTURE

Create:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Commands Merged  
C. Latest Development Update  
D. Branch, Commit and Scope  
E. Preflight and Build/Test Baseline  
F. Existing Audit Coverage and Specialized Gap  
G. Target Membership and Architecture  
H. Product Safety Positioning  
I. Activity Isolation and Root Flow  
J. Full Computer Startup Authority  
K. Feature Inventory  
L. Environment Source Policy  
M. CMAltimeter / Sensor Proposal Path  
N. Sensor Sample Quality and Freshness  
O. Sensor Proposal State Machine  
P. Canonical Environment Record  
Q. Pressure, Depth and Inspired-Gas Model  
R. Bühlmann ZH-L16C Constants  
S. Tissue Initialization  
T. Schreiner Equation Forensic Verification  
U. Haldane Constant-Depth Parity  
V. One-Second / Actual-DT Semantics  
W. Tissue State Integrity  
X. Gradient Factors and Ceiling  
Y. NDL / Schedule / TTS  
Z. Gas / PPO2 / MOD / Switch Logic  
AA. Decompression Stop State Machine  
AB. Multilevel Profiles ML-01 through ML-10  
AC. 39 m → 10 m Scenario Verdict  
AD. Altitude Scenario Matrix  
AE. Schreiner Test Vector Matrix  
AF. Multilevel Deco Transition Matrix  
AG. Independent Oracle Results  
AH. Schreiner Analytic vs One-Second Parity  
AI. Cross-Engine Parity  
AJ. Persistence / Checkpoint / Restore  
AK. Logbook / Export / Sync Integrity  
AL. Planner Briefing Cards / CCR Reference-Only  
AM. UI / Haptics / Safety Presentation Truthfulness  
AN. App Intents / Action Button  
AO. Failure Injection Matrix  
AP. Edge-Case Matrix  
AQ. Requirement / Test Matrix  
AR. Numerical Error Budget  
AS. Concurrency and Stale Results  
AT. Performance / Battery / Deadline Behavior  
AU. Test Coverage and Mutation Audit  
AV. Physical Watch QA Matrix  
AW. External Validation Plan  
AX. Findings P0-P4  
AY. Readiness Matrix  
AZ. Prioritized Remediation Plan  
BA. Release Blockers  
BB. Final Verdict

---

# 51. REQUIRED FINAL QUESTIONS

The report must explicitly answer:

1. Is Full Computer implemented and compiled into Watch MAIN?
2. Is the live Full Computer path proven from sensor/depth sample to UI?
3. Is there one canonical live tissue state?
4. Is Full Computer isolated from Gauge, Apnea and Snorkeling?
5. Is there any route to start Full Computer without legal/safety prerequisites?
6. Is there any route to start Full Computer without explicit valid environment?
7. Is sea level absent as explicit choice and implicit fallback?
8. Does Watch directly use CMAltimeter absolute-altitude updates where sensor proposal is supported?
9. Is the altimeter retained during async sampling?
10. Can an old callback contaminate a newer request?
11. Is sensor timestamp distinguished from callback receipt time?
12. Are sample count, accuracy, precision, stability, timeout, range and freshness enforced?
13. Does proposal remain non-authoritative until explicit acceptance?
14. Does rejection preserve imported/manual authority exactly?
15. Can unresolved sampling/proposal be bypassed to start Full Computer?
16. Is the accepted environment frozen at dive start?
17. Can environment change during active dive?
18. Are all live runtime plans explicit and free from default sea-level authorization?
19. Is surface pressure independently derived from accepted altitude?
20. Is water density consistent with salinity?
21. Are ZH-L16C constants exact and ordered?
22. Are all 16 N2 compartments initialized altitude-aware?
23. Are all 16 He compartments initialized altitude-aware?
24. Are all 16 N2 compartments updated every interval?
25. Are all 16 He compartments updated every interval?
26. Is Schreiner algebraically correct?
27. Are Schreiner units and pressure rates correct?
28. Is Haldane correct at altitude?
29. Does zero-rate Schreiner equal Haldane within tolerance?
30. Is actual elapsed time handled correctly?
31. Is long suspension fail-closed or accurately integrated?
32. Is tissue state atomic and snapshot-consistent?
33. Is GF ceiling altitude-aware?
34. Is NDL altitude-aware?
35. Is schedule rebuilt from current tissue state?
36. Is TTS altitude-aware and not stale?
37. Is gas switch ordering correct?
38. Is stop-state timer separated from tissue state?
39. Can a completed displayed stop force-clear deco incorrectly?
40. Can deco appear, reduce, disappear and reappear correctly in multilevel profiles?
41. Is the 39 m Air → 10 m profile oracle-validated second-by-second?
42. Are ML-01 through ML-10 covered?
43. Are Trimix / helium profiles oracle-validated?
44. Is analytic Schreiner parity with one-second stepping quantified?
45. Are numerical tolerances justified independently?
46. Does checkpoint/restore preserve tissues/environment/stop state?
47. Is restore idempotent and fail-safe?
48. Does logbook preserve environment source and sensor quality?
49. Do sync/export preserve mathematical values and activity discriminator?
50. Are planner briefing cards reference-only?
51. Can planner/CCR metadata affect live decompression?
52. Are UI and docs truthful about altitude, Full Computer and validation limits?
53. Are critical metrics visible on small Watch screens?
54. Are haptics/reminders subordinate to critical alerts?
55. Are App Intents safety-gated?
56. Is performance sufficient to keep up with runtime?
57. What happens if computation exceeds one second?
58. Are fail-open paths impossible or documented as open blockers?
59. Are all findings traceable to evidence?
60. What blocks 100% software readiness?
61. What blocks physical readiness?
62. What blocks external release readiness?

Every `NO`, `PARTIAL`, `UNKNOWN`, `PENDING`, or `NOT_EXECUTED` must include:

```text
severity
priority
root cause
affected files/symbols
affected profile/timestamp/compartment if applicable
credible impact
required remediation
acceptance tests
release impact
```

---

# 52. READINESS MATRIX

The report must score:

```text
TARGET_MEMBERSHIP_READINESS
ACTIVITY_ISOLATION_READINESS
LEGAL_SAFETY_GATE_READINESS
LIVE_ENGINE_CALL_GRAPH_READINESS
FULL_COMPUTER_STARTUP_AUTHORITY_READINESS
ENVIRONMENT_SOURCE_POLICY_READINESS
CMALTIMETER_ACQUISITION_READINESS
CMALTIMETER_LIFECYCLE_READINESS
REQUEST_GENERATION_ISOLATION_READINESS
LATE_CALLBACK_ISOLATION_READINESS
SENSOR_SAMPLE_QUALITY_READINESS
PROPOSAL_STATE_MACHINE_READINESS
NO_SEA_LEVEL_FALLBACK_READINESS
CANONICAL_ENVIRONMENT_READINESS
SURFACE_PRESSURE_READINESS
WATER_DENSITY_READINESS
ZH_L16C_CONSTANTS_READINESS
TISSUE_INITIALIZATION_READINESS
N2_TISSUE_READINESS
HE_TISSUE_READINESS
HALDANE_READINESS
SCHREINER_FORMULA_READINESS
SCHREINER_UNIT_RATE_READINESS
ONE_SECOND_TIMING_READINESS
ACTUAL_DT_READINESS
TISSUE_STATE_INTEGRITY_READINESS
GF_CEILING_READINESS
NDL_READINESS
TTS_READINESS
LIVE_DECO_SCHEDULE_READINESS
GAS_SWITCH_READINESS
STOP_STATE_READINESS
MULTILEVEL_ORACLE_READINESS
AIR39_TO_10M_READINESS
TRIMIX_HELIUM_READINESS
ALTITUDE_AWARENESS_READINESS
ANALYTIC_VS_ONE_SECOND_PARITY_READINESS
NUMERICAL_ERROR_BUDGET_READINESS
CONCURRENCY_STALE_RESULT_READINESS
PERSISTENCE_RESTORE_READINESS
LOGBOOK_PROVENANCE_READINESS
SYNC_EXPORT_INTEGRITY_READINESS
PLANNER_BRIEFING_CARD_SAFETY_READINESS
CCR_REFERENCE_ONLY_READINESS
UI_TRUTHFULNESS_READINESS
APP_INTENTS_SAFETY_READINESS
FAILURE_INJECTION_COVERAGE_READINESS
TEST_COVERAGE_READINESS
PERFORMANCE_BATTERY_READINESS
PHYSICAL_WATCH_QA_READINESS
EXTERNAL_VALIDATION_READINESS
OVERALL_WATCH_FULL_COMPUTER_SOFTWARE_READINESS
OVERALL_WATCH_FULL_COMPUTER_RELEASE_READINESS
```

No percentage may be awarded without evidence.

---

# 53. FINAL VERDICT

Print exactly:

```text
MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT: PASS / PARTIAL / FAIL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
TARGET_MEMBERSHIP: PASS / FAIL
LIVE_ENGINE_PATH_PROVEN: PASS / FAIL
SINGLE_CANONICAL_TISSUE_STATE: PASS / FAIL
ACTIVITY_ISOLATION: PASS / FAIL
LEGAL_SAFETY_GATE: PASS / FAIL
FULL_COMPUTER_STARTUP_AUTHORITY: PASS / FAIL
ENVIRONMENT_SOURCE_POLICY: PASS / FAIL
NO_EXPLICIT_OR_IMPLICIT_SEA_LEVEL: PASS / FAIL
WATCH_CMALTIMETER_PREDIVE_ACQUISITION: PASS / FAIL / NOT_SUPPORTED
CMALTIMETER_LIFECYCLE_AND_CANCELLATION: PASS / FAIL
REQUEST_GENERATION_ISOLATION: PASS / FAIL
LATE_CALLBACK_ISOLATION: PASS / FAIL
SENSOR_SAMPLE_QUALITY_AND_FRESHNESS: PASS / FAIL
EXPLICIT_SENSOR_PROPOSAL_ACCEPTANCE: PASS / FAIL
IMPORTED_AND_MANUAL_SOURCE_PRESERVATION: PASS / FAIL
CANONICAL_ENVIRONMENT_VALIDATION: PASS / FAIL
SURFACE_PRESSURE_DERIVATION: PASS / FAIL
WATER_DENSITY_SALINITY_CONSISTENCY: PASS / FAIL
ACTIVE_DIVE_ENVIRONMENT_IMMUTABLE: PASS / FAIL
ZH_L16C_CONSTANTS: PASS / FAIL
TISSUE_INITIALIZATION_ALTITUDE_AWARE: PASS / FAIL
ALL_16_N2_COMPARTMENTS: PASS / FAIL
ALL_16_HE_COMPARTMENTS: PASS / FAIL
HALDANE_PARITY: PASS / FAIL
SCHREINER_FORMULA_VERIFIED: PASS / FAIL
SCHREINER_UNIT_RATE_CONVENTIONS: PASS / FAIL
SCHREINER_PARITY: PASS / FAIL
ONE_SECOND_UPDATE_SEMANTICS: PASS / FAIL
TIMING_ACTUAL_DT: PASS / FAIL
TISSUE_STATE_INTEGRITY: PASS / FAIL
GF_CEILING_ALTITUDE_AWARE: PASS / FAIL
NDL_ALTITUDE_AWARE: PASS / FAIL
TTS_ALTITUDE_AWARE: PASS / FAIL
LIVE_DECO_SCHEDULE_RECOMPUTATION: PASS / FAIL
GAS_SWITCH_ORDERING: PASS / FAIL
STOP_STATE_SEPARATION: PASS / FAIL
MULTILEVEL_ORACLE_PROFILES: PASS / FAIL
AIR39_TO_10M_PROFILE: PASS / FAIL
DYNAMIC_DECO_REDUCTION: PASS / FAIL
DYNAMIC_DECO_DISAPPEARANCE_WHEN_MODEL_PERMITS: PASS / FAIL
DECO_REAPPEARANCE_AFTER_REDESCENT: PASS / FAIL
TRIMIX_HELIUM_PROFILE: PASS / FAIL
INDEPENDENT_ORACLE_PARITY: PASS / FAIL
ANALYTIC_VS_ONE_SECOND_PARITY: PASS / FAIL
NUMERICAL_ERROR_BUDGET: PASS / FAIL
CONCURRENCY_STALE_RESULT_GUARDS: PASS / FAIL
CHECKPOINT_RESTORE_ENVIRONMENT: PASS / FAIL
PERSISTENCE_TISSUE_STATE: PASS / FAIL
LOGBOOK_SENSOR_PROVENANCE: PASS / FAIL
SYNC_EXPORT_MATH_INTEGRITY: PASS / FAIL
PLANNER_BRIEFING_CARDS_REFERENCE_ONLY: PASS / FAIL
CCR_REFERENCE_ONLY_SAFETY: PASS / FAIL
UI_DOCUMENTATION_TRUTHFULNESS: PASS / FAIL
APP_INTENTS_SAFETY_GATE: PASS / FAIL
FAILURE_INJECTION_COVERAGE: PASS / FAIL
WATCH_ALGORITHM_TESTS: PASS / FAIL / NOT_EXECUTED
IOS_PARITY_TESTS: PASS / FAIL / NOT_EXECUTED
MACOS_WATCH_BUILD: PASS / FAIL / NOT_EXECUTED
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
P4_FINDINGS: <number>
SOFTWARE_READINESS_PERCENT: <0-100>
PHYSICAL_WATCH_QA_READINESS_PERCENT: <0-100>
EXTERNAL_VALIDATION_READINESS_PERCENT: <0-100>
OVERALL_RELEASE_READINESS_PERCENT: <0-100>
PHYSICAL_APPLE_WATCH_SENSOR_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_DEPTH_SENSOR_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_ALTITUDE_DIVE_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_MULTILEVEL_DIVE_QA: PASS / FAIL / PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
EXTERNAL_LIVE_DECO_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

`PASS` is permitted only when:

- every software gate passes;
- no P0-P2 finding remains open;
- live engine path is proven;
- independent oracle parity is passed;
- all 16 N2 and all 16 He compartments are verified;
- ML-01 through ML-10 are covered;
- physical Watch sensor path passes if claimed;
- physical depth-related QA passes if release readiness is claimed;
- external decompression validation passes if release readiness is claimed;
- every claim is traceable to code, test, official reference, physical evidence or external validation.

If physical/external evidence is missing, final audit can be `PARTIAL` at best even if software evidence is strong.

---

# 54. SUCCESS CRITERIA

The task is complete only if:

- no production source code is modified;
- no tests are modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- no sync/security model is modified;
- all required report files are created;
- both merged command scopes are preserved;
- Watch Full Computer master audit is included;
- live Bühlmann/Schreiner multilevel forensic audit is included;
- CMAltimeter/environment-source audit is included;
- all 16 N2 and all 16 He compartments are audited;
- altitude-aware initialization/update/ceiling/NDL/TTS/schedule are audited;
- exact Schreiner formula is algebraically verified;
- units and rate conventions are verified;
- actual-dt / one-second semantics are verified;
- ML-01 through ML-10 profile coverage is evaluated;
- 39 m → 10 m scenario is answered with evidence;
- dynamic deco reduction/disappearance/reappearance is evaluated from tissue state;
- analytic-vs-one-second parity is quantified;
- independent oracle requirements are evaluated;
- numerical error budget is produced;
- persistence/restore/logbook/sync/export are audited;
- planner briefing cards and CCR reference-only safety are audited;
- physical Watch QA is separated from simulator/software evidence;
- external validation is separated from internal tests;
- readiness percentages are evidence-based;
- all findings have remediation and acceptance tests;
- final git status is recorded.

Do not commit or push automatically.

Stop after producing the merged forensic master audit reports, matrices, QA plan, external validation plan and final summary.
