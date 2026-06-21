# CURSOR / CODEX COMMAND — DIR DIVING APPLE WATCH LIVE BÜHLMANN / SCHREINER / MULTILEVEL DECOMPRESSION ENGINE FORENSIC AUDIT — V1.0

**Command version:** 1.0  
**Updated for MAIN:** 2026-06-21
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Primary target:** `DIRDiving Watch App`  
**Secondary compatibility target:** shared algorithm models and iOS reference implementation only where needed for mathematical parity  
**Task type:** audit-only, safety-critical, read-only  
**Suggested sequence position:** specialized vertical audit after command `2-` and before broad command `3-`

---

# PURPOSE

Perform the deepest possible audit of the live Apple Watch Full Computer decompression engine, with exclusive emphasis on:

- Bühlmann ZH-L16C implementation;
- Schreiner equation implementation;
- one-second tissue updates;
- continuous multilevel-dive handling;
- N2 and He loading/off-gassing across all 16 compartments;
- real-time ceiling, NDL, TTS and decompression-obligation recalculation;
- dynamic appearance, reduction and disappearance of decompression obligations;
- gas-switch handling;
- ascent/descent transitions;
- decompression-stop state machine;
- numerical stability, timing accuracy and fail-safe behavior;
- deterministic parity against an independent mathematical oracle.

This audit is not a general Watch audit, UI audit, Planner audit or code-style review.

It is a forensic review of the **live decompression model executed during an active Full Computer dive**.

---

# KEY QUESTION TO ANSWER

Determine whether the Apple Watch implementation correctly models a real multilevel profile such as:

```text
Descend to 39 m
Remain long enough to incur a decompression obligation
Ascend to 10 m
Remain at 10 m for an extended period
Continuously update all 16 tissue compartments
Continuously recalculate ceiling and decompression schedule
Allow the previously required decompression obligation to decrease
Allow the obligation to disappear only if the current tissue state mathematically permits direct ascent
```

The audit must not assume that decompression necessarily disappears merely because the diver spends time at 10 m.

At 10 m:

- some compartments may off-gas;
- some compartments may remain supersaturated;
- slow compartments may still on-gas depending on their current tissue pressure, gas composition and inspired inert-gas pressure;
- the controlling compartment may change;
- the ceiling may reduce, remain stable or occasionally evolve non-monotonically;
- decompression may disappear only when the complete current tissue state, Gradient Factors, ambient pressure and ascent model permit surfacing.

The implementation must derive the answer from the actual 16-compartment state, not from elapsed shallow time, a cached schedule or a heuristic.

---

# RELATIONSHIP TO EXISTING AUDITS

Before auditing, inspect the latest versions of:

```text
0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0.md
1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md
2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0.md
10-DIR_DIVING_PERFORMANCE_CONCURRENCY_BATTERY_AUDIT_V3.0.md
12-DIR_DIVING_TEST_QA_EVIDENCE_AUDIT_V3.0.md
```

State explicitly which parts are already covered and which gaps this specialized audit closes.

Expected overlap:

- Bühlmann constants;
- 16 compartments;
- N2/He loading;
- ceiling and decompression schedule;
- multilevel tissue update;
- one-second Watch workload;
- decompression-stop state machine;
- performance and battery;
- general test coverage.

Expected specialized gaps to close:

- exact Schreiner formula verification;
- exact units and rate conventions;
- one-second tick semantics;
- timestamp-derived versus assumed `dt`;
- missed, delayed, duplicated and out-of-order tick behavior;
- continuity across depth ramps;
- segment boundary correctness;
- live multilevel schedule invalidation and rebuilding;
- dynamic deco-obligation regression;
- controlling-compartment migration;
- tissue-state conservation across lifecycle events;
- independent second-by-second oracle parity;
- quantified numerical error budget;
- Watch-specific concurrency and stale-publication risk;
- fail-safe behavior when computation cannot keep pace.

---

# ABSOLUTE AUDIT-ONLY RULES

Do not:

- modify production code;
- modify tests;
- modify project configuration;
- alter algorithms;
- refactor;
- apply fixes;
- change UI or UX;
- change gas logic;
- change Gradient Factors;
- change stop-state rules;
- change persistence or sync;
- change sampling frequency;
- change power-management behavior;
- commit;
- push;
- merge;
- claim external or physical validation without evidence.

You may create or update only the requested audit reports and evidence matrices under `Docs/`.

The report may include exact remediation proposals and future Cursor/Codex remediation commands, but this audit must not implement them.

---

# OUTPUT FILES

Create:

```text
Docs/WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_CURRENT.md
Docs/WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv
Docs/WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv
Docs/WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md
Docs/WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md
```

The main report must be self-contained and evidence-backed.

---

# SEVERITY MODEL

Classify findings as:

- **P0** — safety-critical wrong live decompression output, corrupted tissue state, false clearance to surface, missed mandatory stop, stale schedule presented as current, invalid gas applied, NaN/Inf propagation, or fail-open behavior;
- **P1** — material Bühlmann/Schreiner error, timing drift, wrong ceiling/TTS/NDL, segment discontinuity, incorrect GF interpolation, wrong controlling compartment, or release-hard blocker;
- **P2** — bounded numerical discrepancy, insufficient tests, unclear state ownership, recoverable lifecycle defect, performance risk without proven wrong output;
- **P3** — maintainability, diagnostics, documentation or non-blocking observability gap;
- **P4** — optional improvement.

Any case where the Watch can show “no decompression required” while the independently recomputed tissue state still requires decompression is P0.

---

# PHASE 0 — PREFLIGHT AND SCOPE PROOF

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

Stop if the active branch is not `main`.

Inspect:

```text
project.yml
README.md
Docs/README.md
Docs/FULL_COMPUTER_ARCHITECTURE.md
Docs/*BUHLMANN*
Docs/*FULL_COMPUTER*
Docs/*DECO*
Docs/*SCHREINER*
Docs/*TISSUE*
Docs/*WATCH*
```

Prove:

- the Watch Full Computer code is compiled into the MAIN Watch target;
- Gauge and Full Computer are separated;
- the live decompression engine is reachable;
- no experimental implementation shadows the production one;
- there is one canonical live tissue state;
- the current commit and dirty state are recorded;
- this is audit-only.

Record every relevant source file and target membership. Do not assume filenames.

---

# PHASE 1 — LIVE ENGINE ARCHITECTURE MAP

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

Identify the exact symbols responsible for:

- tissue initialization;
- tissue update;
- Schreiner calculation;
- Haldane constant-depth calculation;
- pressure-depth conversion;
- water-vapour pressure;
- surface pressure;
- N2 and He inspired pressure;
- mixed a/b coefficients;
- GF interpolation;
- ceiling;
- NDL;
- schedule generation;
- TTS;
- first stop;
- stop rounding;
- gas switching;
- decompression-stop tracking;
- controlling compartment;
- runtime publication;
- state checkpointing/restoration.

For each component classify:

| Component | File/symbol | Canonical | Derived | Presentation-only | Stateful | Actor/thread | Tests |
|---|---|---:|---:|---:|---:|---|---|

Prove that there is no duplicated live decompression authority.

---

# PHASE 2 — BÜHLMANN ZH-L16C CONSTANTS AND MODEL IDENTITY

Verify the claimed model variant against authoritative reference constants.

For all 16 compartments inspect:

- N2 half-times;
- He half-times;
- N2 `a` coefficients;
- N2 `b` coefficients;
- He `a` coefficients;
- He `b` coefficients;
- ordering and indexing;
- precision type;
- initialization values;
- serialization order.

Mandatory checks:

- exactly 16 compartments;
- no off-by-one mapping;
- N2 and He arrays have identical compartment ordering;
- no coefficient copied from ZH-L16A/B while claiming ZH-L16C;
- no truncated or rounded constant causing material drift;
- no locale parsing;
- no percentage/fraction confusion;
- all constants are immutable during a dive;
- restored tissue vectors preserve exact compartment identity.

Create a constants table in the report and identify the source used for comparison.

External reference validation remains pending unless actually executed.

---

# PHASE 3 — SCHREINER EQUATION FORENSIC VERIFICATION

Locate every implementation or equivalent transformation of the Schreiner equation.

For each inert gas and compartment, verify the intended form:

```text
P_t(t) =
P_i0
+ R * (t - 1/k)
- (P_i0 - P_t0 - R/k) * exp(-k*t)
```

or an algebraically equivalent form, where:

```text
k = ln(2) / halfTime
P_t0 = initial tissue inert-gas pressure
P_i0 = inspired inert-gas pressure at segment start
R = linear inspired inert-gas pressure change rate
t = elapsed segment time
```

The audit must prove equivalence rather than rely on naming.

Verify:

## Formula correctness

- sign of each term;
- exponential term;
- use of `ln(2)`;
- half-time unit;
- inspired-pressure start value;
- pressure-rate sign during descent and ascent;
- use of gas fraction;
- water-vapour subtraction;
- surface/ambient pressure convention;
- N2 and He calculated independently;
- no O2 tissue compartment;
- no use of total ambient pressure as inert pressure;
- no use of end-of-segment inspired pressure in place of start pressure;
- no accidental double application of rate.

## Units

Prove consistency for:

- seconds versus minutes;
- metres versus bar/ATA;
- metres per minute versus bar per second;
- gas fractions versus percentages;
- absolute versus gauge pressure;
- salt/freshwater pressure conversion;
- altitude surface pressure.

Explicitly calculate the conversion chain from depth change to inspired-pressure rate.

## Limiting cases

Prove numerically:

1. `R = 0` reduces to the Haldane exponential equation.
2. `t = 0` returns exactly or within machine tolerance `P_t0`.
3. Very small `dt` remains stable.
4. Positive rate models descent correctly.
5. Negative rate models ascent correctly.
6. N2-only gas with He = 0 keeps He tissue behavior correct.
7. Helium removal/switch does not create negative tissue pressure.
8. Constant-depth repeated one-second updates converge toward inspired pressure.
9. A full linear segment calculated once closely matches the same segment split into one-second updates.
10. Segment splitting error is quantified and bounded.

Any unit ambiguity or equation mismatch is at least P1 and P0 if it can understate decompression.

---

# PHASE 4 — ONE-SECOND UPDATE SEMANTICS

The phrase “updated every second” must be proven from runtime behavior.

Audit:

- timer source;
- sensor callback frequency;
- computation trigger;
- timestamp source;
- monotonic clock;
- actual `dt`;
- actor/task ownership;
- cancellation;
- app lifecycle;
- background/foreground transitions;
- dropped frames;
- duplicate callbacks;
- sensor bursts;
- delayed samples;
- stale samples;
- out-of-order timestamps.

Determine whether the engine:

1. blindly assumes `dt = 1.0 s`;
2. uses actual elapsed monotonic time;
3. integrates per sensor sample;
4. accumulates time and steps in fixed quanta;
5. mixes more than one method.

Mandatory invariants:

- tissue evolution uses elapsed time, not UI timer count;
- a delayed tick does not lose decompression exposure;
- duplicated ticks do not double-count exposure;
- an out-of-order sample is rejected or safely handled;
- UI rendering frequency does not control tissue math;
- sensor sampling frequency does not create multiple integrations for the same interval;
- computations cannot overlap and publish out of order;
- a slower calculation cannot overwrite a newer tissue state;
- `dt <= 0`, huge `dt`, NaN and Inf fail safely;
- pauses/background transitions have explicit semantics;
- active dive restoration does not reset the one-second phase or tissue history.

Create a timing-fault matrix for:

```text
0.5 s
1.0 s
1.5 s
2 s
5 s
10 s
30 s
duplicate timestamp
negative timestamp delta
out-of-order timestamp
suspended app
Watch restart/restore
```

For each, compare current behavior with expected tissue integration.

---

# PHASE 5 — PRESSURE, DEPTH AND INSPIRED-GAS MODEL

Verify the complete physical conversion:

```text
sensor depth/pressure
→ validated depth
→ ambient absolute pressure
→ alveolar/inspired gas pressure
→ inert-gas partial pressure
```

Audit:

- seawater/freshwater constants;
- depth-to-pressure convention;
- altitude/surface pressure;
- water-vapour pressure;
- respiratory quotient assumptions if any;
- pressure clamping;
- negative depth;
- sensor noise near surface;
- salinity setting;
- temperature usage if any;
- rounding location.

Before tissue initialization, audit the Watch pre-dive altitude source as a separate safety-critical input path:

```text
retained CMAltimeter
→ isAbsoluteAltitudeAvailable
→ startAbsoluteAltitudeUpdates
→ fresh CMAbsoluteAltitudeData altitude/accuracy/precision
→ stable validated sample window
→ pending proposal
→ explicit acceptance
→ frozen runtime surface environment
```

Prove the Full Computer startup flow requests a new measurement immediately before confirmation, stops updates on success/error/timeout/cancellation, rejects stale, inaccurate, unstable, non-finite, or unsupported samples, and blocks start while sampling or while a proposal is unresolved. Fail the audit if cached `CLLocationManager.location.altitude`, GPS elevation, a silent sea-level default, or automatic proposal acceptance can reach the live engine. Verify that imported iPhone Plan and manual Watch environments remain unchanged unless the diver explicitly accepts the sensor proposal.

Verify gas fractions:

```text
FN2 = 1 - FO2 - FHe
```

and ensure:

- fraction sum is validated;
- inspired N2 and He pressure are derived from the active gas;
- gas switch changes the inspired-pressure model at the exact intended timestamp/depth;
- stale gas state cannot be used for a later segment;
- display-rounded depth never feeds canonical pressure;
- invalid pressure never reaches tissue math.

---

# PHASE 6 — TISSUE STATE INTEGRITY

Audit the full 16-compartment state structure.

Verify:

- N2 and He state are stored separately;
- update is atomic across all compartments;
- previous state is immutable during calculation;
- no partial publication;
- no aliasing/copy-on-write bug;
- no race between schedule generation and tissue mutation;
- controlling compartment is derived from the same snapshot;
- ceiling and TTS use the same tissue snapshot;
- persistence encodes all 32 inert values with adequate precision;
- restoration does not reorder compartments;
- version migration is explicit;
- corrupt tissue checkpoints fail closed;
- no fresh-tissue fallback during an active/restored dive unless explicitly surfaced as a critical failure.

Mandatory invariants:

- tissue pressure remains finite;
- tissue pressure never becomes materially negative;
- no discontinuity at a segment boundary;
- no spontaneous reset on gas switch;
- no reset when decompression obligation appears or disappears;
- no reset when moving between UI screens;
- no reset under Mission Mode;
- Gauge state cannot contaminate Full Computer tissue state;
- iOS planner card data cannot alter live tissue state.

---

# PHASE 7 — GRADIENT FACTORS AND CEILING

Verify:

- GF Low and GF High validation;
- bounds and ordering;
- storage/persistence;
- dive-start snapshot;
- no unsafe mid-dive remote mutation;
- interpolation method;
- interpolation anchors;
- first-stop/deepest-ceiling reference;
- surface endpoint;
- compartment-wise allowable ambient pressure;
- N2/He combined `a` and `b`;
- zero-total-inert edge case;
- controlling compartment selection;
- ceiling conversion to depth;
- ceiling rounding;
- negative ceiling handling.

The audit must determine whether GF interpolation is:

- based on current ambient pressure;
- based on first stop and surface;
- recomputed consistently when the schedule changes;
- stable when deco obligation disappears and later reappears.

Mandatory scenarios:

- fresh tissues at surface;
- no-deco descent;
- newly incurred deco;
- reduced ceiling during shallow multilevel stay;
- ceiling reaches zero;
- re-descent after ceiling reaches zero;
- controlling compartment changes;
- gas switch changes controlling compartment.

Any cached interpolation anchor that produces stale or discontinuous ceilings must be reported.

---

# PHASE 8 — LIVE NDL, DECOMPRESSION SCHEDULE AND TTS RECOMPUTATION

Determine exactly how often the Watch recomputes:

- NDL;
- current ceiling;
- decompression schedule;
- first stop;
- stop list;
- TTS;
- controlling compartment.

Verify whether schedule generation uses:

- the latest tissue state;
- the latest active gas;
- the current depth;
- configured ascent rates;
- configured stop increments;
- current GF state;
- valid future gas switches.

Mandatory requirements:

- a schedule generated at 39 m must not remain authoritative after a prolonged stay at 10 m;
- schedule cache invalidation must be deterministic;
- TTS must reduce when the tissue state permits;
- stop times must reduce or disappear only through recomputation;
- no negative stop time;
- no stale stop retained after ceiling clears;
- no “NDL” displayed while a positive ceiling exists;
- no “no deco” state while schedule still contains mandatory stops;
- no schedule disappearance solely because the diver entered a shallower depth band;
- no schedule generation from display-rounded tissues/depth;
- calculation timeout or failure must retain a conservative, clearly stale/error state rather than publish optimistic zero-deco output.

Quantify schedule recomputation latency and maximum stale-output window.

---

# PHASE 9 — MULTILEVEL DIVE FORENSIC TESTS

Generate deterministic second-by-second test vectors and compare the Watch engine against an independent oracle.

At minimum include:

## ML-01 — Deco incurred, then shallow level

```text
Gas: Air
GF: project defaults and at least 30/70
Surface: sea level
Descent: configured rate to 39 m
Bottom: duration sufficient to produce mandatory deco
Ascent: configured rate to 10 m
Level: remain at 10 m until:
  a. ceiling reduces;
  b. controlling compartment changes;
  c. schedule changes;
  d. deco obligation possibly disappears, if mathematically permitted
Then ascend to surface only when allowed by the model.
```

Record every second:

- runtime;
- depth;
- ambient pressure;
- active gas;
- inspired PN2/PHe;
- each N2 tissue pressure;
- each He tissue pressure;
- compartment ceiling;
- controlling compartment;
- overall ceiling;
- GF applied;
- NDL/deco state;
- stop list;
- TTS.

The audit must identify the exact second at which:

- deco first appears;
- deepest ceiling occurs;
- each schedule transition occurs;
- controlling compartment changes;
- deco clears, if it clears.

## ML-02 — Same profile with EAN50 switch at 21 m

Verify:

- exact gas-switch boundary;
- tissue continuity;
- accelerated off-gassing where expected;
- MOD/PPO2 validity;
- schedule rebuild;
- CNS/OTU isolation from Bühlmann tissue math.

## ML-03 — Trimix bottom gas + deco gases

Verify N2/He dual-gas tissue behavior and changing combined coefficients.

## ML-04 — Sawtooth profile

```text
39 m → 18 m → 30 m → 12 m → 24 m → 9 m
```

Verify no schedule cache assumption and no tissue reset.

## ML-05 — Deco clears, then re-descent

After the ceiling reaches zero, descend again.

Verify that:

- the existing tissue state is preserved;
- NDL is not reset to a fresh-dive value;
- deco can reappear;
- controlling compartment may change;
- schedule is rebuilt.

## ML-06 — Hover around stop/ceiling boundary

Oscillate around a stop depth with realistic sensor noise.

Verify stop timer/state-machine logic separately from tissue math.

## ML-07 — Very slow ascent

Verify Schreiner rate handling and compare with one-second stepping.

## ML-08 — Rapid but valid ascent

Verify negative rate, no instability and correct alarm/math separation.

## ML-09 — Long shallow level at 10 m

Show that slow compartments may continue loading depending on state and gas. The report must not describe all compartments as automatically desaturating.

## ML-10 — Surface interval and repetitive continuation

Where live repetitive state is supported, verify off-gassing and next-dive initialization.

For every profile create:

- Watch result;
- oracle result;
- absolute error;
- relative error;
- pass/fail tolerance;
- first divergence timestamp;
- affected compartment;
- user-visible consequence.

---

# PHASE 10 — INDEPENDENT ORACLE REQUIREMENT

Do not validate the production implementation only against itself.

Build or use an independent audit oracle that:

- does not import the production tissue-update function;
- does not reuse production constants without independently checking them;
- implements Bühlmann/Schreiner separately;
- supports the same pressure/environment assumptions;
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

External tools may differ because of rounding, ascent model, GF implementation, water-vapour assumptions or stop strategy. Normalize assumptions before judging differences.

Never claim equivalence without documenting all configuration differences.

---

# PHASE 11 — SCHREINER ANALYTIC VS ONE-SECOND PARITY

For each test gas and compartment, compare:

```text
A. One analytic Schreiner update over the complete linear segment
B. Repeated 1-second Schreiner updates
C. Repeated 1-second constant-depth/Haldane approximation using sampled end depths, if the production code does this
D. Production Watch result
```

Test segments:

- surface to 39 m;
- 39 m to 10 m;
- 10 m to 3 m;
- 3 m to surface;
- 60 m to 21 m;
- slow 1 m/min ascent;
- fast configured ascent;
- depth reversal mid-segment.

Quantify:

- maximum compartment pressure error;
- ceiling error in metres;
- TTS error in seconds/minutes;
- time-to-deco-clear error;
- accumulated error after 30, 60, 120 and 240 minutes.

Define explicit acceptance tolerances and justify them.

A tolerance must not be selected merely because the current implementation passes.

---

# PHASE 12 — DECOMPRESSION OBLIGATION STATE TRANSITIONS

Audit the semantic state machine:

```text
noDecompression
approachingNDL
decompressionRequired
atStop
aboveStop
belowStop
stopPaused
stopReset/restarted
decompressionCleared
surfaced
error/stale
```

Verify exact relationships among:

- mathematical ceiling;
- rounded stop depth;
- current depth;
- stop tolerance band;
- stop timer;
- schedule;
- TTS;
- UI status;
- haptic status.

Include current product rules, where implemented, such as:

- stop timer pauses when the diver is outside the permitted stop band;
- being too shallow must never continue crediting the stop;
- descending materially below the stop may require the stop to be performed again;
- these UI/state rules must not mutate or reset tissue pressures;
- the decompression schedule must remain mathematically authoritative;
- completing a displayed stop must not force-clear deco if the recomputed ceiling still requires it.

Test at least:

- exact stop depth;
- 0.5 m above;
- 1.0 m above;
- 1.0 m below;
- more than 2.0 m below;
- sensor jitter;
- leave and re-enter band;
- gas switch during stop;
- schedule shortens while at stop;
- stop disappears because ceiling clears;
- deeper stop appears after re-descent.

Flag any conflict between timer state and tissue-derived obligation.

---

# PHASE 13 — GAS SWITCHES DURING LIVE MULTILEVEL DIVES

Audit:

- configured gas inventory;
- active gas identity;
- switch eligibility;
- MOD;
- PPO2;
- switch depth;
- user confirmation if required;
- timestamp/order of gas switch;
- tissue update before and after switch;
- schedule future-gas assumptions;
- duplicate/rejected switch;
- reversion to previous gas;
- unavailable gas;
- hypoxic gas;
- O2 100%;
- trimix.

Mandatory ordering proof at switch timestamp:

```text
previous interval integrated with old gas
→ switch event committed
→ next interval integrated with new gas
→ schedule rebuilt with new current/future gas state
```

Reject ambiguous ordering.

Verify that a gas switch cannot retroactively change the preceding second.

---

# PHASE 14 — NUMERICAL ROBUSTNESS

Audit all floating-point operations for:

- `Double` versus `Float`;
- exponent underflow/overflow;
- cancellation error;
- `exp`;
- division by near-zero;
- negative square/invalid roots if present;
- NaN;
- infinity;
- denormals;
- comparison epsilon;
- exact zero checks;
- repeated rounding;
- integer truncation;
- time conversion;
- pressure conversion;
- serialization precision.

Run adversarial values:

- zero depth;
- tiny depth;
- extreme but bounded depth;
- very long runtime;
- GF limits;
- FO2/He boundary values;
- zero inert fraction;
- tiny `dt`;
- huge `dt`;
- invalid half-time;
- corrupt tissue state;
- negative rate;
- rate sign reversal.

Canonical calculations must not use display rounding.

Create `WATCH_BUHLMANN_NUMERICAL_ERROR_BUDGET_CURRENT.md` with:

| Source of error | Bound | Measured worst case | Safety direction | Accepted? |
|---|---:|---:|---|---|

---

# PHASE 15 — CONCURRENCY, ORDERING AND STALE RESULT AUDIT

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
- no UI-triggered mutation of the canonical tissue snapshot.

Construct race scenarios:

1. new depth sample while schedule calculation is running;
2. gas switch while prior tissue update is pending;
3. app background during update;
4. restore while stale task completes;
5. rapid UI navigation;
6. WatchConnectivity payload arrives during dive;
7. settings change attempt during active dive;
8. duplicate sensor callback;
9. timer and sensor callback at same timestamp;
10. computation exceeds one second.

Any older result overwriting a newer state is P0/P1 depending on output.

---

# PHASE 16 — PERFORMANCE, BATTERY AND DEADLINE BEHAVIOR

Measure or statically estimate:

- tissue update duration;
- ceiling calculation duration;
- NDL calculation duration;
- full schedule/TTS generation duration;
- allocations per tick;
- memory growth;
- CPU wakeups;
- main-thread work;
- thermal/battery implications;
- worst-case multigas technical profile;
- longest schedule;
- chart/history sampling if live.

Performance must never be improved by silently reducing mathematical correctness.

Verify:

- one-second deadline is normally met;
- missed deadline policy is explicit;
- actual `dt` accounts for delay;
- backlog cannot accumulate indefinitely;
- schedule calculation can be throttled only if current ceiling remains updated and staleness is visible/conservative;
- Mission Mode does not reduce tissue-update fidelity;
- low-power UI behavior does not reduce decompression authority;
- background policy is documented and truthful.

Separate simulator measurements from physical Apple Watch Ultra evidence.

---

# PHASE 17 — PERSISTENCE, CHECKPOINT AND RESTORE

Audit active-dive persistence:

- tissue vector;
- active gas;
- GF;
- runtime;
- last monotonic/wall timestamp;
- current depth;
- ceiling;
- schedule cache;
- stop-state;
- schema version;
- checksum/integrity;
- atomic write;
- restore validation.

Verify:

- tissue state is the source of truth after restore;
- schedule is recomputed, not blindly trusted;
- elapsed time during suspension is handled according to documented sensor/dive semantics;
- wall-clock changes do not corrupt `dt`;
- corrupt checkpoint fails closed;
- incompatible future schema fails safely;
- no fresh-tissue fallback;
- no Gauge-to-Full-Computer migration corruption;
- no remote planner card or iOS state replaces live tissues.

Generate restore tests at:

- no-deco bottom;
- immediately after deco appears;
- during ascent;
- at a deco stop;
- during prolonged 10 m level;
- immediately after deco clears;
- after gas switch;
- after controlling-compartment change.

---

# PHASE 18 — FAIL-SAFE AND ERROR SEMANTICS

Audit behavior for:

- invalid sensor data;
- stale depth;
- missing depth entitlement;
- simulated sensor;
- tissue calculation error;
- schedule non-convergence;
- invalid gas;
- corrupt settings;
- corrupt checkpoint;
- memory pressure;
- computation timeout;
- unsupported profile;
- NaN/Inf.
- unavailable absolute-altitude hardware, Core Motion error, sampling timeout, inaccurate/unstable altitude window, stale pre-dive proposal, and user rejection.

Required safety posture:

- never convert an error into “no deco”;
- never display zero ceiling/TTS because a calculation failed;
- retain last valid state only if clearly marked stale and conservatively handled;
- block unsafe surfacing guidance;
- preserve logging/evidence;
- prioritize critical error UI/haptics;
- distinguish sensor failure from algorithm failure;
- simulation must be unmistakable and not release-default.

Classify every failure as fail-open or fail-closed.

Any fail-open decompression path is P0.

---

# PHASE 19 — TEST SUITE FORENSIC REVIEW

Inventory all tests that exercise:

- Bühlmann constants;
- Haldane;
- Schreiner;
- one-second update;
- descent;
- ascent;
- constant depth;
- multilevel;
- trimix;
- gas switch;
- GF;
- ceiling;
- NDL;
- TTS;
- schedule convergence;
- stop state;
- restore;
- concurrency;
- performance;
- invalid input.

For each requirement classify evidence:

| Requirement | Unit | Integration | Replay | Oracle | Simulator | Physical Watch | External |
|---|---:|---:|---:|---:|---:|---:|---:|

Mandatory negative checks:

- tests that only compare the engine with its own helper do not count as independent validation;
- snapshot/UI tests do not prove tissue correctness;
- planner tests do not automatically prove live Watch parity;
- a passing build does not prove algorithm validity;
- code coverage without assertion quality does not count as readiness.

Flag missing mutation tests.

Propose mutations such as:

- reverse Schreiner rate sign;
- use seconds as minutes;
- swap N2/He half-times;
- alter one coefficient;
- skip one compartment;
- cache schedule indefinitely;
- drop a one-second update;
- duplicate a tick;
- use end pressure as `P_i0`;
- reset tissues on gas switch.

The existing test suite should fail each material mutation.

---

# PHASE 20 — REQUIRED REFERENCE TEST VECTORS

Create `WATCH_SCHREINER_TEST_VECTOR_MATRIX_CURRENT.csv`.

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

Include hand-checkable vectors for at least compartments:

```text
1
4
8
12
16
```

and all 16 compartments for the core multilevel profiles.

Create `WATCH_MULTILEVEL_DECO_TRANSITION_MATRIX_CURRENT.csv` with:

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

# PHASE 21 — CROSS-ENGINE PARITY

Where iOS and Watch have separate implementations, compare:

- constants;
- initial tissues;
- pressure model;
- Schreiner equation;
- GF;
- ceiling;
- schedule;
- gas switch;
- result rounding.

Determine whether:

- code is shared;
- one engine wraps another;
- implementations are duplicated;
- outputs diverge.

Run identical profile replays through both.

Differences must be explained by intentional configuration, not platform drift.

The iOS Planner is not automatically the oracle. It must also be independently validated.

---

# PHASE 22 — USER SCENARIO VERDICT

The final report must answer this scenario explicitly:

> A diver incurs decompression at 39 m, then spends a long time at 10 m. Can DIR Diving correctly reduce or remove the decompression obligation?

Answer using evidence:

1. Does the Watch preserve and update every N2/He compartment each second?
2. Is the update based on actual elapsed time?
3. Is Schreiner/Haldane selected or applied correctly for changing/constant depth?
4. Does the active gas influence the correct interval?
5. Is the ceiling recalculated from the current tissue state?
6. Is the schedule rebuilt rather than merely counting down the old plan?
7. Can the controlling compartment change?
8. Can some slow compartments continue loading at 10 m?
9. Can deco clear only when the model permits direct ascent?
10. Is the exact transition deterministic and oracle-validated?
11. Can deco reappear after a later descent?
12. Does stop-timer behavior remain separate from tissue physics?
13. Does any error path falsely clear deco?
14. What residual uncertainty requires external or physical validation?

Do not answer “yes” solely because a multilevel flag or one-second timer exists.

---

# PHASE 23 — READINESS MATRIX

Include:

| Area | Readiness | P0 | P1 | Evidence | External validation |
|---|---:|---:|---:|---|---|
| ZH-L16C constants | XX% | | | | |
| N2 tissue model | XX% | | | | |
| He tissue model | XX% | | | | |
| Schreiner formula | XX% | | | | |
| Unit/rate correctness | XX% | | | | |
| One-second timing | XX% | | | | |
| Actual-dt handling | XX% | | | | |
| Multilevel continuity | XX% | | | | |
| GF interpolation | XX% | | | | |
| Ceiling | XX% | | | | |
| NDL | XX% | | | | |
| Live deco schedule | XX% | | | | |
| TTS | XX% | | | | |
| Dynamic deco regression | XX% | | | | |
| Controlling compartment | XX% | | | | |
| Gas switching | XX% | | | | |
| Stop-state separation | XX% | | | | |
| Persistence/restore | XX% | | | | |
| Concurrency/order | XX% | | | | |
| Numerical robustness | XX% | | | | |
| Performance/deadline | XX% | | | | |
| Fail-safe behavior | XX% | | | | |
| Automated tests | XX% | | | | |
| Independent oracle parity | XX% | | | | |
| Physical Watch evidence | XX% | | | | |
| External reference parity | XX% | | | | |
| Overall live engine | XX% | | | | |

No score may be awarded without file/function/test evidence.

---

# PHASE 24 — ISSUE MATRIX

For every finding include:

```text
ID
Title
Severity
Priority
Affected file
Affected symbol
Affected compartment/profile
Root cause
Mathematical explanation
Observed result
Expected result
Maximum error
User-visible impact
Safety impact
Reproducibility
Evidence
Proposed remediation
Acceptance criteria
Required tests
Regression risk
Estimated effort
External validation required
```

Group by:

- model constants;
- Schreiner;
- timing;
- pressure model;
- tissue state;
- GF/ceiling;
- schedule/TTS/NDL;
- multilevel;
- gas switch;
- stop state;
- persistence;
- concurrency;
- numerical stability;
- performance;
- fail-safe;
- tests/docs.

---

# PHASE 25 — EXTERNAL VALIDATION PLAN

Create `WATCH_LIVE_DECO_EXTERNAL_VALIDATION_PLAN_CURRENT.md`.

Include:

- reference implementations/tools;
- exact shared configuration;
- profile CSV format;
- environmental assumptions;
- GF assumptions;
- ascent/descent rates;
- stop increments;
- gas-switch rules;
- tolerated differences;
- comparison fields;
- discrepancy triage;
- physical dry-run;
- simulator replay;
- paired-device logging;
- controlled-water testing;
- chamber/pressure-pot strategy where appropriate;
- real Apple Watch Ultra underwater validation;
- safety governance;
- independent reviewer sign-off.

Do not claim EN 13319, medical, decompression or dive-computer certification.

---

# PHASE 26 — FINAL REPORT STRUCTURE

`Docs/WATCH_LIVE_BUHLMANN_SCHREINER_MULTILEVEL_AUDIT_CURRENT.md` must contain:

A. Executive Summary  
B. Scope and Commit  
C. Existing Audit Coverage and Specialized Gap  
D. Live Engine Call Graph  
E. Model Identity and Constants  
F. Schreiner Formula Verification  
G. Units and Pressure Model  
H. One-Second Timing Semantics  
I. Tissue State Integrity  
J. Gradient Factors and Ceiling  
K. NDL / Schedule / TTS  
L. Multilevel Profiles  
M. 39 m → 10 m Scenario  
N. Gas Switches  
O. Deco Stop State Machine  
P. Numerical Error Budget  
Q. Concurrency and Stale Results  
R. Performance and Battery  
S. Persistence and Restore  
T. Fail-Safe Behavior  
U. Test and Mutation Coverage  
V. Independent Oracle Results  
W. Cross-Engine Parity  
X. Detailed Findings  
Y. Readiness Matrix  
Z. Prioritized Remediation Plan  
AA. External Validation Plan  
AB. Final Verdict

---

# FINAL VERDICT REQUIREMENTS

The final verdict must state separately:

- mathematically correct in static inspection: YES / NO / PARTIAL;
- Schreiner equation verified: YES / NO / PARTIAL;
- one-second actual-time integration verified: YES / NO / PARTIAL;
- multilevel tissue continuity verified: YES / NO / PARTIAL;
- dynamic deco appearance verified: YES / NO / PARTIAL;
- dynamic deco reduction verified: YES / NO / PARTIAL;
- dynamic deco disappearance verified: YES / NO / PARTIAL;
- deco reappearance after re-descent verified: YES / NO / PARTIAL;
- independent oracle parity passed: YES / NO / PENDING;
- physical Apple Watch validation passed: YES / NO / PENDING;
- external decompression-reference validation passed: YES / NO / PENDING;
- internal TestFlight Full Computer readiness: READY / CONDITIONAL / NOT READY;
- external TestFlight Full Computer readiness: READY / CONDITIONAL / NOT READY;
- App Store Full Computer readiness: READY / CONDITIONAL / NOT READY.

“PARTIAL” and “CONDITIONAL” must list exact blockers.

---

# SUCCESS CRITERIA

The audit is complete only if:

- the active branch and commit are recorded;
- the live Watch Full Computer path is proven;
- every relevant source file/symbol is inventoried;
- the exact Schreiner implementation is algebraically verified;
- units are proven end to end;
- actual one-second timing semantics are proven;
- all 16 N2/He compartments are tested;
- the 39 m → 10 m scenario is replayed second by second;
- dynamic deco reduction/disappearance is verified from tissues;
- controlling-compartment changes are recorded;
- schedule cache invalidation is verified;
- stop-state logic is separated from tissue physics;
- missed/duplicated/out-of-order ticks are tested;
- persistence/restore is tested mid-deco;
- an independent oracle is used;
- numerical tolerances are justified;
- fail-open paths are identified;
- all P0/P1 issues have acceptance criteria;
- external and physical QA remain pending unless evidenced;
- only audit reports/matrices are changed;
- no code, test, UI, project, sync or algorithm file is modified;
- final Git status is documented.

---

# VERSION HISTORY

## V1.0 — 2026-06-19

Initial specialized audit command dedicated to:

- live Apple Watch Bühlmann ZH-L16C;
- Schreiner equation;
- one-second tissue integration;
- actual elapsed-time handling;
- N2/He 16-compartment state;
- multilevel dive continuity;
- dynamic decompression appearance, reduction and disappearance;
- 39 m → 10 m scenario;
- controlling-compartment migration;
- gas switches;
- stop-state separation;
- independent mathematical oracle;
- numerical error budget;
- Watch concurrency, performance, persistence and fail-safe behavior.
