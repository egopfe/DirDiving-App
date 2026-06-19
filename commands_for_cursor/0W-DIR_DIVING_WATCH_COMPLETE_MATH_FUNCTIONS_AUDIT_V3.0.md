# CURSOR / CODEX COMMAND — DIR DIVING APPLE WATCH COMPLETE MATHEMATICAL FUNCTIONS / ALGORITHM AUDIT — V1.0

**Command version:** 1.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Primary target:** `DIRDiving Watch App`  
**Primary test target:** `DIRDiving Watch Algorithm Tests`  
**Secondary cross-target scope:** Shared Bühlmann core and iOS models/codecs only where they feed, validate, sync or export mathematical values consumed by Apple Watch  
**Task type:** audit-only, read-only

---

# POSITION IN THE AUDIT SEQUENCE

This is the dedicated Apple Watch mathematical-functions audit.

Recommended sequence:

```text
0 → 0W → 1 → 2 → 15 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 16
```

Audit `15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT` is a mandatory specialized subsection of this Watch mathematical audit.

---

# CURRENT PRODUCT ARCHITECTURE

Audit the current MAIN architecture:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Verify strict mathematical/runtime isolation:

```text
Gauge math/runtime → Gauge only
Full Computer Bühlmann/decompression → Full Computer only
Apnea lifecycle/recovery math → Apnea only
Snorkeling GPS/navigation math → Snorkeling only
```

---

# CORE OBJECTIVE

Perform a complete, deep, audit-only verification of every mathematical function, algorithm, numerical transformation, runtime accumulator, state machine and mathematical persistence/sync path used by the Apple Watch MAIN application.

Verify:

- correctness;
- completeness;
- numerical robustness;
- unit consistency;
- timing consistency;
- monotonic-time handling;
- mathematical state ownership;
- deterministic behavior;
- edge cases;
- fail-safe behavior;
- release-hard readiness;
- cross-target parity;
- activity isolation;
- persistence fidelity;
- sync fidelity;
- presentation truthfulness.

This is not a general UI/UX, security or code-style audit.

---

# AUDIT-ONLY RULE

Do not modify production code, tests, project configuration, assets, localization, mockups, algorithms, business logic, timing, persistence or sync. Do not refactor, fix, commit, push or merge.

You may create or update only the requested audit reports and matrices under `Docs/`.

---

# REQUIRED OUTPUT FILES

Create:

```text
Docs/WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_AUDIT_CURRENT.md
Docs/WATCH_MATH_FEATURE_INVENTORY_CURRENT.csv
Docs/WATCH_MATH_EDGE_CASE_MATRIX_CURRENT.csv
Docs/WATCH_MATH_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/WATCH_MATH_EXTERNAL_QA_PENDING_CURRENT.md
```

---

# SEVERITY MODEL

- **P0** — safety-critical wrong output, false deco clearance, missed stop, wrong gas, corrupted tissues, stale output presented as current, fail-open behavior.
- **P1** — mathematical defect, unit mismatch, timing defect, state discontinuity, incorrect recovery gating, wrong distance/bearing, incorrect average/max calculation.
- **P2** — test gap, bounded numerical discrepancy, unclear fallback, incomplete persistence/sync integrity.
- **P3** — documentation, diagnostics, maintainability, non-blocking clarity.
- **P4** — optional improvement.

Any false “no deco” while tissues still require decompression is P0.

---

# PHASE 0 — PREFLIGHT

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git status
git fetch origin
git status -sb
git remote -v
git branch -a
```

Stop if branch is not `main`.

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
```

Record branch, commit, dirty state, targets, tests, simulator availability, physical QA availability and external validation availability.

---

# PHASE 1 — COMPLETE WATCH MATHEMATICAL FEATURE INVENTORY

Create a full inventory of all mathematical/runtime features, recording:

```text
Activity
Mode
Feature
Canonical source
Input validation
Runtime state owner
Persistence
Sync
Presentation
Tests
External validation
Readiness %
```

Inventory at minimum:

## Gauge

- depth;
- max depth;
- average depth;
- runtime;
- ascent rate;
- TTV;
- alarms;
- reminders;
- lifecycle thresholds;
- sensor validation;
- unit conversion;
- persistence;
- sync/export.

## Full Computer

- ambient pressure;
- inspired inert pressure;
- 16 N2 and 16 He compartments;
- Haldane;
- Schreiner;
- GF Low/High;
- ceiling;
- NDL;
- TTS;
- deco schedule;
- stop state;
- controlling compartment;
- gas switching;
- PPO2/MOD;
- CNS/OTU where live;
- multilevel updates;
- checkpoint restore;
- fail-closed behavior.

## Apnea

- session/dive runtime;
- depth;
- max depth;
- ascent/descent rate;
- surface interval;
- recovery;
- early-dive gating;
- targets;
- records;
- persistence;
- sync.

## Snorkeling

- GPS filtering;
- surface distance;
- speed;
- bearing;
- waypoints;
- return-to-entry;
- dip depth/time;
- route persistence;
- unit conversion;
- sync.

---

# PHASE 2 — GAUGE MATHEMATICAL AUDIT

Audit:

## Depth

- invalid/negative/stale/spike samples;
- sample ordering;
- duplicate timestamps;
- surface noise;
- canonical depth versus display rounding.

## Runtime

- monotonic clock;
- actual dive start;
- suspend/resume;
- restore;
- duplicate timer prevention.

## Average depth

Determine and verify the exact definition: arithmetic mean, time-weighted mean, trapezoidal integral, or another method.

Test irregular sampling, missing samples, duplicate timestamps, zero duration, long dives and restore.

## Max depth

Verify monotonic maximum, invalid-sample exclusion and persistence.

## Ascent rate

Verify window, smoothing, units, sign, timestamps, stale samples, rapid reversals, thresholds and divide-by-zero protection.

## TTV

Verify formula, inputs, configuration, finite guards and strict informational semantics. TTV must not be NDL, TTS or deco authority and must not leak into Full Computer, Apnea or Snorkeling.

## Lifecycle

Verify auto-start depth, debounce, manual/automatic collision, auto-stop dwell and duplicate-session prevention.

---

# PHASE 3 — FULL COMPUTER BÜHLMANN CORE AUDIT

Inspect:

```text
Shared/BuhlmannCore/**
Services/FullComputerRuntimeEngine.swift
Utils/FullComputerDecoSolver.swift
Full Computer persistence/checkpoint models
Full Computer tests
```

Verify:

- exact ZH-L16C constants;
- 16 N2 and 16 He compartments;
- ordering and initialization;
- water-vapour and ambient-pressure model;
- Haldane and Schreiner;
- GF Low/High;
- combined N2/He coefficients;
- ceiling;
- NDL;
- TTS;
- schedule convergence;
- first stop and stop increments;
- rounding;
- gas-switch ordering;
- multigas, Trimix and O2;
- invalid-input and finite guards.

---

# PHASE 4 — MANDATORY AUDIT 15 INTEGRATION

Execute the full software scope of:

`15-DIR_DIVING_WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT`

Verify:

- Schreiner algebra;
- Haldane limiting case;
- one-second semantics;
- actual elapsed time;
- missed, delayed, duplicated and out-of-order ticks;
- multilevel continuity;
- schedule rebuilding;
- deco appearance, reduction, disappearance and reappearance;
- controlling-compartment changes;
- gas-switch interval ordering;
- stop-state separation;
- checkpoint restore;
- stale-result rejection;
- fail-closed behavior;
- independent oracle parity.

Mandatory profile:

```text
Air
39 m until mandatory deco
ascend to 10 m
remain at 10 m
update tissues every second
observe ceiling, schedule and TTS
allow deco to clear only if the complete tissue state permits surfacing
```

Explicitly report which compartments off-gas, whether slow compartments continue on-gassing, when the controlling compartment changes, when deco clears, and whether it reappears after re-descent.

---

# PHASE 5 — TIMING AUDIT

Determine whether tissues use fixed `dt`, actual monotonic time, sample intervals, accumulated quanta or a mixed strategy.

Verify UI refresh independence, no double integration, no lost exposure on delayed samples, duplicate/stale rejection, background semantics and restore semantics.

Test:

```text
0.5 s
1.0 s
1.5 s
2 s
5 s
10 s
30 s
duplicate timestamp
negative delta
out-of-order sample
suspend
restore
```

---

# PHASE 6 — GRADIENT FACTOR AUDIT

Verify validation, bounds, GF Low <= GF High, equal-GF policy, persistence, active-dive snapshot, interpolation anchors, compartment-wise ceiling, negative ceiling handling and controlling compartment.

Test 30/70, 20/80, 30/30, 50/50, invalid values, schedule transitions, deco clear and re-descent.

---

# PHASE 7 — GAS / PPO2 / MOD AUDIT

Verify gas fractions, Air/EAN/Trimix/O2 handling, MOD, PPO2, eligibility, switch depth, explicit confirmation, exact event ordering, no retroactive switch, hypoxic gas handling and stale gas rejection.

Mandatory order:

```text
integrate previous interval with old gas
→ commit switch
→ integrate next interval with new gas
→ rebuild schedule
```

---

# PHASE 8 — DECOMPRESSION-STOP STATE MACHINE AUDIT

Audit states:

```text
noDeco
decoRequired
approachingStop
atStop
aboveStop
belowStop
stopPaused
stopRestarted
stopCompleted
decoCleared
stale
error
```

Verify relationships among ceiling, rounded stop, current depth, tolerance band, timer, TTS, schedule, UI and haptics.

Include rules:

- timer pauses outside the permitted band;
- too shallow never credits the stop;
- material descent may restart the stop;
- stop timer never changes tissues;
- completing a displayed stop never force-clears deco.

Test exact stop, 0.5 m above, 1 m above, 1 m below, more than 2 m below, jitter, leave/re-enter, gas switch, shortening schedule, disappearing stop and re-descent.

---

# PHASE 9 — CNS / OTU AUDIT

If live CNS/OTU exists, verify PPO2 timeline integration, gas switching, valid zero versus unavailable, stale-state handling, persistence and restore.

If not implemented live, verify no fake values, no planner-card values shown as live and no zero placeholders.

---

# PHASE 10 — APNEA MATHEMATICAL AUDIT

Verify depth/time, max depth, ascent/descent rate, timestamps, surface interval, recovery policy, early-dive gating, suspend/resume, relaunch, targets, records and statistics.

Recovery path must be:

```text
ApneaRecoveryPolicy
→ requiredRecoverySeconds
→ lifecycle state
→ start gating
→ presentation
```

Test 1:1, 2:1, fixed, custom, minimum, early dive enabled/disabled, exact completion, one second before/after, suspend/resume and relaunch.

---

# PHASE 11 — SNORKELING MATHEMATICAL AUDIT

Verify GPS filtering, stale/poor/spike/gap rejection, underwater fix rejection, distance formula, bearing, speed, zero-time guards, waypoint and return-to-entry calculations, dip depth/time and persistence.

Ensure live, persisted, Logbook and export distance remain consistent within a documented tolerance.

---

# PHASE 12 — UNIT CONVERSION AUDIT

Audit metres/feet, Celsius/Fahrenheit, bar/PSI, m/min/ft/min, km/miles, knots if shown, duration and locale formatting.

Verify metric canonical storage, presentation-only conversion, no round-trip drift, canonical threshold comparisons and canonical persistence.

---

# PHASE 13 — PERSISTENCE / RESTORE INTEGRITY

Audit all mathematical persistence for Gauge, Full Computer, Apnea and Snorkeling.

Mandatory invariants:

- no fresh-state fallback during an active session;
- no duplicate session/dive/dip;
- no cross-activity restore;
- no rounded persistence;
- no stale checkpoint overwrite;
- corrupt/future schema fails safely;
- restore is idempotent.

Full Computer restore must preserve tissue vectors, active gas, GF, runtime, depth, stop state and timestamp continuity.

---

# PHASE 14 — SYNC MATHEMATICAL INTEGRITY

Verify exact units and precision, schema version, HMAC/checksum, activity discriminator, ACK/retry, replay, idempotency, malformed/future schema, duplicate IDs and stale updates.

Planner briefing cards are reference-only and must never mutate live mathematical state.

---

# PHASE 15 — PLANNER BRIEFING-CARD NUMERICAL AUDIT

Verify metadata/PNG consistency, units, rounding, GF, gases, switch depths, MOD/PPO2, stops, TTS, gas ledger, Rock Bottom, CCR values, unavailable values and stale/version handling.

No unavailable value may become zero, no partial plan may appear complete, and old cards may not overwrite newer ones.

---

# PHASE 16 — NUMERICAL ROBUSTNESS AUDIT

Audit Double versus Float, NaN, infinity, negative values, division by zero, overflow, underflow, exponentials, cancellation, epsilon policy, integer truncation, timestamp conversion and rounding.

Use adversarial inputs including zero/tiny/extreme depth, long duration, invalid gas, zero inert fraction, invalid coordinates, duplicate samples, negative time, corrupt state and future schema.

---

# PHASE 17 — CONCURRENCY / ORDERING AUDIT

Audit actor ownership, one mutable owner per runtime, cancellation, overlapping updates, stale publication, timer duplication, sensor ordering, gas-switch ordering, restore ordering, sync arrival during active sessions and computation overrun.

Test races around Full Computer updates, gas switching, restore, reminders, Apnea start, Snorkeling finalization, sync and settings changes.

---

# PHASE 18 — PERFORMANCE BUDGET AUDIT

Measure or estimate Gauge processing, Full Computer tissue update, ceiling, NDL, schedule, stop-state update, checkpoint write, restore, Apnea processing, Snorkeling GPS processing, sync encode/decode and briefing-card import.

Create a software budget and separate simulator evidence from physical Watch evidence. Physical battery/thermal QA remains pending.

---

# PHASE 19 — CROSS-TARGET PARITY AUDIT

Compare iOS and Watch for Bühlmann constants, initialization, pressure model, Schreiner, GF, ceiling, schedule, gas switch, units, briefing-card values and codecs.

The iOS Planner is not automatically an independent oracle. Use an independent oracle where needed.

---

# PHASE 20 — TEST COVERAGE AUDIT

Inventory all Watch mathematical tests across Gauge, Full Computer, Bühlmann, Haldane, Schreiner, multilevel, GF, ceiling, NDL, TTS, schedule, gas switching, stop state, restore, CNS/OTU, Apnea, Snorkeling, persistence, sync, units, concurrency, performance and malformed inputs.

Classify evidence as unit, integration, replay, oracle, simulator, physical Watch, paired device, underwater or external reference.

Identify missing tests, skipped software tests, self-comparison tests, weak assertions, flaky timing and untested mutations.

Propose mutation tests for reversed Schreiner rate sign, seconds/minutes mismatch, swapped N2/He half-times, skipped compartments, duplicate/dropped ticks, rounded depth, tissue reset on switch, deco clear on error and cross-activity checkpoint contamination.

---

# PHASE 21 — BUILD / TEST EXECUTION

On macOS run:

```bash
xcodegen generate

./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

Use the closest installed simulator if necessary and document it.

Do not modify code to make tests pass during this audit.

---

# PHASE 22 — EDGE-CASE MATRIX

Create `Docs/WATCH_MATH_EDGE_CASE_MATRIX_CURRENT.csv` with:

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

Include zero depth, thresholds, invalid depth, irregular timing, long dive, multilevel deco, gas switch, deco clear/re-descent, stop-band violations, Apnea recovery, early dive, GPS filtering, route distance, bearing wrap, unit round trip, restore and malformed sync payload.

---

# PHASE 23 — READINESS MATRIX

The report must score:

- Gauge depth/runtime/average/max/ascent/TTV/lifecycle;
- Bühlmann constants;
- N2/He tissues;
- Schreiner/Haldane;
- one-second and actual-dt handling;
- multilevel continuity;
- GF;
- ceiling/NDL/TTS/schedule;
- stop state;
- gas switching;
- MOD/PPO2;
- CNS/OTU;
- Full Computer restore;
- Apnea;
- Snorkeling;
- unit conversion;
- persistence;
- sync;
- briefing-card fidelity;
- numerical robustness;
- concurrency;
- performance;
- parity;
- test coverage;
- external validation;
- physical Watch evidence;
- overall Watch math readiness.

No percentage may be awarded without evidence.

---

# PHASE 24 — FINAL REPORT STRUCTURE

Create `Docs/WATCH_MAIN_COMPLETE_MATH_FUNCTIONS_AUDIT_CURRENT.md` with:

A. Executive Summary  
B. Scope and Commit  
C. Architecture and Ownership  
D. Feature Inventory  
E. Gauge Mathematics  
F. Full Computer Bühlmann  
G. Audit 15 Integration  
H. Timing  
I. Gradient Factors  
J. Gas/PPO2/MOD  
K. Deco Stop State Machine  
L. CNS/OTU  
M. Apnea Mathematics  
N. Snorkeling Mathematics  
O. Unit Conversion  
P. Persistence/Restore  
Q. Sync Integrity  
R. Briefing Cards  
S. Numerical Robustness  
T. Concurrency  
U. Performance  
V. Cross-Target Parity  
W. Test Coverage  
X. Edge-Case Matrix  
Y. Findings  
Z. Readiness Matrix  
AA. Prioritized Remediation Plan  
AB. External/Physical QA Gaps  
AC. Final Verdict

---

# PHASE 25 — FINAL VERDICT QUESTIONS

Answer explicitly whether Gauge depth/runtime/average/ascent/TTV are correct; Full Computer Bühlmann and Schreiner are correct; tissues use actual elapsed time; all 16 N2/He compartments are preserved; multilevel deco appears, reduces, disappears and reappears correctly; gas switches and stop state are correct; restore is safe; Apnea and Snorkeling math are coherent; units, persistence, sync and briefing cards are faithful; concurrency and performance are acceptable; and which physical/external gates remain pending.

---

# SUCCESS CRITERIA

The audit is complete only if:

- branch and commit are recorded;
- no code is modified;
- every Watch mathematical feature is inventoried;
- Gauge, Full Computer, Apnea and Snorkeling are fully audited;
- audit 15 is incorporated;
- persistence, sync, units, concurrency, performance and parity are audited;
- tests and edge cases are inventoried;
- external/physical evidence is clearly separated;
- no readiness score is unsupported;
- all P0/P1 findings have acceptance criteria;
- final Git status is recorded.

---

# VERSION HISTORY

## V1.0 — 2026-06-19

Initial dedicated Apple Watch mathematical-functions audit covering Gauge, Full Computer Bühlmann, mandatory audit 15 integration, Schreiner/Haldane, one-second updates, multilevel decompression, stop-state mathematics, gas/PPO2/MOD, CNS/OTU, Apnea, Snorkeling, units, persistence, sync, briefing-card fidelity, concurrency, performance and cross-target parity.
