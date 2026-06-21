# CURSOR / CODEX COMMAND — WATCH BÜHLMANN ALTITUDE + SCHREINER MULTILEVEL AUDIT — V1.0

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Primary target:** `DIRDiving Watch App`  
**Task type:** audit-only, read-only

## Objective

Perform a deep audit of whether the Apple Watch Full Computer implementation of Bühlmann ZH-L16C, with second-by-second Schreiner updates for multilevel dives across all 16 N2 and all 16 He compartments, correctly accounts for dive altitude and non-sea-level surface pressure.

Verify the complete chain:

```text
altitude source
→ local atmospheric pressure
→ ambient absolute pressure
→ inspired inert-gas pressure
→ initial tissue equilibrium
→ Schreiner/Haldane updates
→ all 16 N2 and 16 He compartments
→ Gradient Factor ceiling
→ NDL
→ TTS
→ decompression schedule
→ stop state
→ persistence and restore
→ Watch/iOS parity
```

Do not modify production code. If a defect is found, document the exact remediation, affected files, mathematical impact, tests and acceptance criteria, but do not implement it.

Create:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md
Docs/WATCH_BUHLMANN_ALTITUDE_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_EDGE_CASE_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_ALTITUDE_FINDING_TRACEABILITY_CURRENT.csv
```

## Non-negotiable rules

Do not:

- modify Bühlmann constants;
- modify Schreiner or Haldane mathematics;
- change Gradient Factors;
- change gas-switch logic;
- change decompression-stop rules;
- change UI/UX;
- change persistence or sync schemas;
- refactor unrelated code;
- commit or push.

Only reports, matrices and test-only diagnostic fixtures may be added.

## Severity

Classify as **P0** any case where:

- altitude is ignored while UI or Settings imply it is applied;
- sea-level pressure is silently used at altitude;
- tissue initialization is wrong;
- the Watch shows no decompression when the altitude-aware model requires decompression;
- ceiling, NDL, TTS or schedule use the wrong surface pressure;
- restore changes the altitude model during an active dive;
- altitude changes silently during an active dive;
- a calculation failure becomes an optimistic no-decompression state.

Classify as **P1** when altitude is only partially propagated, Watch and iOS disagree, some outputs remain sea-level based, persistence loses environment data, or test coverage is inadequate.

## Phase 0 — Preflight

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git status --short
git status -sb
git fetch origin
git remote -v
git branch -a
```

Stop if branch is not `main`.

Inspect at minimum:

```text
project.yml
Shared/BuhlmannCore/**
Services/FullComputerRuntimeEngine.swift
Utils/FullComputerDecoSolver.swift
all pressure/environment/altitude models
all salinity and water-density models
Full Computer checkpoint models and codecs
Watch Settings
iOS Planner environment settings
WatchConnectivity environment payloads
Tests/**
Scripts/**
Docs/**
```

Record branch, commit, dirty state, relevant targets, source of altitude, source of surface pressure and supported altitude range.

## Phase 1 — Canonical pressure model

Locate the implementation of:

- altitude;
- local surface atmospheric pressure;
- barometric formula;
- ambient pressure at depth;
- water-vapour pressure;
- water density;
- salinity;
- freshwater/saltwater selection;
- depth-to-pressure conversion;
- inspired gas pressure.

Determine whether surface pressure is fixed, calculated, measured, manually configured, inherited from Planner or silently defaulted.

Document exact formulas, constants, units, valid range, clamping, fallback and error handling.

Search for hidden sea-level assumptions such as:

```text
1.0
1.01325
101325
10.0 m/bar
33 fsw/ata
```

For every occurrence, classify it as valid, sea-level-only, fallback, display-only or unsafe.

## Phase 2 — End-to-end altitude propagation

Trace:

```text
setting / sensor / Planner / imported metadata
→ altitude
→ surface pressure
→ Full Computer configuration
→ runtime engine
→ tissue initialization
→ every update
→ solver
→ UI
→ checkpoint
→ restore
→ export
→ sync
```

Create a propagation table containing:

```text
Field
Source
Destination
Unit
Mandatory
Fallback
Used_In_Calculation
Persisted
Restored
Synced
Tested
Evidence
```

Identify any altitude or pressure value that is stored or displayed but never used mathematically.

## Phase 3 — Tissue initialization

Verify initial equilibrium for every N2 and He compartment uses local pressure, equivalent to:

```text
PN2_initial = (surfacePressure - waterVapourPressure) × FN2
PHe_initial = (surfacePressure - waterVapourPressure) × FHe
```

Check:

- Air;
- Nitrox;
- Trimix;
- zero helium;
- water-vapour subtraction;
- negative inspired-pressure guards;
- repetitive-dive residual tissues;
- restore;
- invalid or missing altitude;
- sea-level fallback.

Verify tissues are not initialized at sea level and only later switched to altitude.

## Phase 4 — Ambient pressure at depth

Verify the runtime uses the equivalent of:

```text
ambientAbsolutePressure =
localSurfacePressure +
hydrostaticPressureFromDepth
```

and not a hardcoded sea-level model such as:

```text
1.0 + depth / 10
```

Check saltwater, freshwater, custom density, metres, feet, zero depth, invalid depth, high altitude and restore.

Confirm the same pressure model feeds:

- tissues;
- PPO2;
- MOD;
- ceiling;
- NDL;
- TTS;
- schedule;
- gas switches;
- stop depths;
- surfacing criterion.

## Phase 5 — Schreiner at altitude

Audit the production Schreiner equation and verify:

- initial inspired pressure is altitude-aware;
- pressure rate uses absolute pressure correctly;
- the interval start pressure is altitude-aware;
- N2 and He are independent;
- all 16 compartments are updated;
- time units are correct;
- descent/ascent signs are correct;
- one-second nominal updates use actual elapsed time;
- altitude is not applied twice;
- duplicate timestamps do not double-integrate;
- delayed ticks do not lose exposure;
- out-of-order ticks are rejected;
- restore preserves the pressure model.

Explicitly identify any sea-level constant in interval construction or inspired-pressure calculation.

## Phase 6 — Haldane at constant depth

Verify constant-depth Haldane updates use altitude-aware inspired pressure.

Test surface equilibrium, constant depth, 10 m level, decompression stops, shallow levels, surface intervals and gas switches.

Confirm Schreiner with zero pressure rate agrees with Haldane within documented tolerance for compartments 1, 4, 8, 12 and 16, for N2 and He.

## Phase 7 — Gradient Factor ceiling

Verify tolerated pressure and ceiling conversion use local surface pressure.

Check:

- N2/He weighted coefficients;
- GF Low and GF High;
- first-stop and surface anchors;
- controlling compartment;
- negative ceiling;
- pressure-to-depth conversion;
- final surfacing criterion.

Verify the implementation equivalent of:

```text
ceilingDepth =
(requiredAmbientPressure - localSurfacePressure) /
waterPressureGradient
```

A sea-level constant here is a safety-relevant finding.

## Phase 8 — NDL

Verify NDL projection uses:

- current altitude-aware tissues;
- altitude-aware ambient pressure;
- altitude-aware inspired pressure;
- local surface pressure as surfacing target;
- current GF, gas and water density.

Compare sea-level and altitude NDL for identical profiles. Explain the model reason for differences rather than assuming their direction.

## Phase 9 — TTS and decompression schedule

Verify:

- ascent simulation is altitude-aware;
- stop ambient pressures use local surface pressure;
- final ascent targets local atmospheric pressure;
- stop depths remain local depth values;
- gas PPO2 is correct at altitude;
- schedule rebuilds after multilevel changes and re-descent;
- controlling compartment changes correctly;
- no sea-level fallback produces optimistic TTS.

## Phase 10 — Mandatory altitude scenarios

Run the same deterministic profiles at:

```text
0 m
500 m
1,000 m
1,500 m
2,000 m
maximum supported altitude
one value above maximum
```

### Profile A

```text
Air
descent to 39 m
remain until mandatory decompression exists
ascend to 10 m
remain at 10 m
update all 16 N2 and He compartments every second
observe ceiling, controlling compartment, TTS and schedule
surface only when the altitude-aware model permits it
```

Do not assume decompression must disappear at 10 m.

### Profile B

```text
Air
descent to 30 m
multilevel ascent through 24 m, 18 m, 12 m and 6 m
compare sea-level and altitude behavior
```

### Profile C

```text
Trimix or another helium-containing gas
verify altitude propagation for N2 and He
verify gas-switch ordering
verify controlling-compartment changes
```

Record each second:

- altitude;
- surface pressure;
- depth;
- runtime;
- ambient pressure;
- active gas;
- inspired PN2 and PHe;
- all 16 PN2 values;
- all 16 PHe values;
- all compartment ceilings;
- controlling compartment;
- overall ceiling;
- NDL;
- TTS;
- current stop;
- complete schedule;
- decompression state.

## Phase 11 — Independent oracle

Do not compare production only with itself.

Use or create a test-only independent altitude-aware Bühlmann oracle that does not call production tissue, ceiling or schedule functions.

It must independently implement:

- altitude-to-surface-pressure conversion;
- inspired gas pressure;
- all 16 N2 and He compartments;
- Haldane;
- Schreiner;
- GF ceiling;
- multilevel replay;
- gas switches;
- freshwater/saltwater pressure.

The iOS Planner is not independent if it shares the same core.

Document constants, formulas, provenance, tolerances, absolute error and relative error.

## Phase 12 — Product altitude policy

Determine whether altitude comes from:

- manual setting;
- sensor;
- Planner;
- GPS elevation;
- imported metadata;
- default sea level;
- mixed sources.

For the Watch sensor path, prove from target membership and the live call graph that the pre-dive proposal is obtained directly from Core Motion absolute-altitude updates:

```text
CMAltimeter.isAbsoluteAltitudeAvailable()
→ CMAltimeter.startAbsoluteAltitudeUpdates(to:withHandler:)
→ fresh CMAbsoluteAltitudeData.altitude samples
→ accuracy/precision and stability validation
→ pending WatchSensorMeasuredProposal
→ explicit diver acceptance
→ immutable confirmed environment at dive start
```

Fail this check if the implementation uses `CLLocationManager.location.altitude`, cached GPS elevation, a hard-coded value, an implicit sea-level fallback, or an unretained/one-shot provider that cannot reliably deliver the asynchronous samples. Verify that sampling starts immediately before the Full Computer confirmation flow, stops on completion/cancellation/timeout, and never silently overwrites an imported iPhone Plan or manually entered Watch value.

Require deterministic tests with an injected altitude provider for unavailable hardware, provider error, timeout, inaccurate samples, unstable samples, stale samples, valid near-zero altitude, valid elevated altitude, explicit acceptance, explicit rejection, and preservation of the previously selected source. Require a physical Apple Watch test because simulator evidence cannot prove the sensor path.

Verify whether it is configurable, synchronized, snapshotted at dive start, mutable during an active dive, persisted, exported and restored.

Required safety policy:

- snapshot environment at dive start;
- no silent active-dive change;
- unavailable altitude must not look measured;
- no explicit sea-level option and no implicit sea-level fallback;
- invalid altitude must fail safely.

If the product is intentionally sea-level-only, UI and documentation must state that clearly.

## Phase 13 — Persistence and restore

Verify the Full Computer checkpoint preserves:

- altitude;
- surface pressure;
- water density;
- salinity;
- environment source;
- fallback/confidence state;
- gas;
- GF;
- all tissues;
- last timestamp.

Test restore:

- at depth;
- during ascent;
- during decompression;
- at 10 m;
- after gas switch;
- before/after controlling-compartment change;
- after relaunch.

Assert:

- no tissue reinitialization;
- no sea-level fallback;
- schedule recomputed from tissues and environment;
- corrupt/missing environment fails safely;
- legacy migration explicit;
- repeated restore idempotent.

## Phase 14 — Watch/iOS parity

Compare Watch, iOS and the independent oracle for:

- surface pressure;
- depth-to-pressure;
- water vapour;
- water density;
- salinity;
- tissue initialization;
- Schreiner;
- Haldane;
- ceiling;
- NDL;
- TTS;
- schedule.

Shared code does not prove correct integration; verify that each target passes the correct environment values.

## Phase 15 — UI and documentation truthfulness

Without redesigning UI, verify:

- altitude setting is visible where supported;
- environment source is clear;
- sea-level fallback is labelled;
- Planner and Watch terminology agree;
- Logbook records environment;
- exports and briefing cards disclose environment;
- no screen or document claims altitude support when runtime ignores it.

Inspect:

```text
README.md
Docs/FULL_COMPUTER_ARCHITECTURE.md
Docs/IOS_PLANNER_LIMITATIONS.md
Docs/SAFETY_DISCLAIMER.md
Docs/**
localization catalogs
Settings
Planner environment views
Watch predive views
Logbook details
PDF/CSV exports
briefing-card models
```

## Phase 16 — Requirement matrix

Create:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_REQUIREMENT_TEST_MATRIX_CURRENT.csv
```

Columns:

```text
Requirement_ID
Area
Requirement
Production_Source
Test
Sea_Level
Altitude_500m
Altitude_1000m
Altitude_1500m
Altitude_2000m
Max_Altitude
Invalid_Altitude
Result
Evidence
Severity
Notes
```

## Phase 17 — Edge-case matrix

Create:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_EDGE_CASE_MATRIX_CURRENT.csv
```

Include:

- 0 m;
- negative altitude if supported;
- 500 m;
- 1,000 m;
- 1,500 m;
- 2,000 m;
- maximum;
- above maximum;
- missing, NaN and infinite altitude;
- altitude changed before/during dive;
- freshwater and saltwater;
- Air, Nitrox and Trimix;
- repetitive and restored dives;
- gas switch;
- deco clear;
- re-descent;
- surface interval;
- legacy/future checkpoint.

Columns:

```text
ID
Altitude
Surface_Pressure
Water_Type
Gas
Profile
Expected_Behavior
Actual_Behavior
Oracle_Result
Absolute_Error
Relative_Error
Pass
Severity
Evidence
Notes
```

## Phase 18 — Build and test

Run:

```bash
xcodegen generate
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

Build:

```text
DIRDiving Watch App
DIRDiving iOS
```

Run:

```text
DIRDiving Watch Algorithm Tests
DIRDiving iOS Algorithm Tests
```

Run focused suites for altitude, pressure model, initialization, Schreiner, Haldane, multilevel, GF ceiling, NDL, TTS, schedule, persistence, restore, parity and Audit 15.

Do not modify production code to make tests pass.

Record exact commands, simulators, test counts, failures, skips and environment limitations.

## Phase 19 — Required answers

The report must explicitly answer:

1. Is altitude currently supported?
2. Where does altitude originate?
3. How is surface pressure calculated?
4. Is altitude used in tissue initialization?
5. Is altitude used in every Schreiner update?
6. Are all 16 N2 compartments altitude-aware?
7. Are all 16 He compartments altitude-aware?
8. Is ambient pressure altitude-aware?
9. Is inspired inert-gas pressure altitude-aware?
10. Is GF ceiling altitude-aware?
11. Is NDL altitude-aware?
12. Is TTS altitude-aware?
13. Is the schedule altitude-aware?
14. Is surfacing based on local atmospheric pressure?
15. Does persistence preserve altitude?
16. Does restore preserve altitude?
17. Are Watch and iOS consistent?
18. Does documentation match implementation?
19. Are there hidden sea-level constants?
20. Can altitude change unsafely during a dive?
21. What blocks 100% readiness?
22. Does the Watch proposal come directly from fresh `CMAbsoluteAltitudeData` sampled immediately before Full Computer start?
23. Are accuracy, stability, freshness, timeout, cancellation, and explicit acceptance enforced before the sensor value becomes authoritative?

For each negative or partial answer provide severity, root cause, affected files, mathematical consequence, required remediation, tests and acceptance criteria.

## Phase 20 — Report structure

Create:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_SCHREINER_AUDIT_CURRENT.md
```

Sections:

A. Executive Summary  
B. Branch, Commit and Scope  
C. Altitude Feature Inventory  
D. Canonical Pressure Model  
E. Altitude Data Flow  
F. Surface Pressure Formula  
G. Tissue Initialization  
H. Ambient Pressure at Depth  
I. Schreiner Altitude Propagation  
J. Haldane Altitude Propagation  
K. All 16 N2 Compartments  
L. All 16 He Compartments  
M. GF Ceiling  
N. NDL  
O. TTS  
P. Decompression Schedule  
Q. Multilevel Profiles  
R. Air 39 m → 10 m Profile  
S. Independent Oracle  
T. Altitude Source Policy  
U. Persistence and Restore  
V. Cross-Target Parity  
W. UI and Documentation Truthfulness  
X. Test Coverage  
Y. Findings  
Z. Readiness Matrix  
AA. Prioritized Remediation Plan  
AB. External/Physical QA  
AC. Final Verdict

## Phase 21 — Finding traceability

Create:

```text
Docs/WATCH_BUHLMANN_ALTITUDE_FINDING_TRACEABILITY_CURRENT.csv
```

Columns:

```text
Finding_ID
Severity
Status
Area
Root_Cause
Affected_Files
Mathematical_Impact
User_Impact
Tests_Required
Acceptance_Criteria
Evidence
Residual_Risk
Physical_QA_Required
External_Validation_Required
Notes
```

Because this is audit-only, newly discovered defects remain `OPEN`.

## Final verdict

Print exactly:

```text
WATCH_BUHLMANN_ALTITUDE_AUDIT: PASS / PARTIAL / FAIL
ALTITUDE_SUPPORTED: YES / PARTIAL / NO
ALTITUDE_SOURCE: MANUAL / SENSOR / PLANNER / DEFAULT_SEA_LEVEL / MIXED / UNKNOWN
WATCH_CMALTIMETER_PREDIVE_ACQUISITION: PASS / FAIL
SENSOR_PROPOSAL_EXPLICIT_ACCEPTANCE: PASS / FAIL
SENSOR_SAMPLE_QUALITY_AND_FRESHNESS: PASS / FAIL
SURFACE_PRESSURE_ALTITUDE_AWARE: PASS / FAIL
TISSUE_INITIALIZATION_ALTITUDE_AWARE: PASS / FAIL
SCHREINER_ALTITUDE_AWARE: PASS / FAIL
HALDANE_ALTITUDE_AWARE: PASS / FAIL
ALL_16_N2_COMPARTMENTS_ALTITUDE_AWARE: PASS / FAIL
ALL_16_HE_COMPARTMENTS_ALTITUDE_AWARE: PASS / FAIL
AMBIENT_PRESSURE_ALTITUDE_AWARE: PASS / FAIL
INSPIRED_GAS_PRESSURE_ALTITUDE_AWARE: PASS / FAIL
GF_CEILING_ALTITUDE_AWARE: PASS / FAIL
NDL_ALTITUDE_AWARE: PASS / FAIL
TTS_ALTITUDE_AWARE: PASS / FAIL
DECO_SCHEDULE_ALTITUDE_AWARE: PASS / FAIL
SURFACING_CRITERION_ALTITUDE_AWARE: PASS / FAIL
MULTILEVEL_ALTITUDE_PROFILE: PASS / FAIL
AIR39_TO_10M_ALTITUDE_PROFILE: PASS / FAIL
TRIMIX_ALTITUDE_PROFILE: PASS / FAIL
INDEPENDENT_ORACLE_PARITY: PASS / FAIL
PERSISTENCE_ALTITUDE_AWARE: PASS / FAIL
RESTORE_ALTITUDE_AWARE: PASS / FAIL
CROSS_TARGET_PARITY: PASS / FAIL
DOCUMENTATION_TRUTHFULNESS: PASS / FAIL
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
ALTITUDE_BUHLMANN_SOFTWARE_READINESS: <percentage>
PHYSICAL_ALTITUDE_DIVE_QA: PENDING
EXTERNAL_BUHLMANN_ALTITUDE_VALIDATION: PENDING
```

Do not commit or push automatically.

Stop after producing the audit report, matrices, test evidence and final summary.
