# 0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0

# VERSION 3.0 — MANDATORY CURRENT PRODUCT SCOPE

This V3.0 section supersedes any older V2.0 statement in this command that treats **Apnea** or **Snorkeling** as experimental, excluded, future-only, or out of scope.

The current product architecture to audit is:

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

Both Apple Watch and iOS Companion must be audited as multi-activity applications.

## Startup and root-flow requirements

Audit both apps for:

```text
Launch
→ legal/onboarding gate when required
→ activity selection
   ├── Diving
   ├── Apnea
   └── Snorkeling
→ activity-owned root, functions, Settings and Logbook
```

For Diving on Apple Watch:

```text
Diving
→ Gauge or Full Computer
```

The audit must verify:

- selection persistence;
- safe migration from Diving-only installations;
- feature flags;
- no placeholder route presented as production-ready;
- no remote switch of an active Watch session;
- no duplicate root coordinator or `NavigationStack`;
- correct deep-link and state-restoration ownership;
- Italian and English;
- accessibility;
- deterministic tests.

## Activity-specific feature ownership

Diving, Apnea and Snorkeling are vertical product areas. The audit must not reduce them to three Logbooks.

### Diving

Audit:

- Gauge;
- Full Computer;
- Bühlmann ZH-L16C;
- Gradient Factors;
- NDL, TTS and Ceiling;
- decompression-stop state machine;
- multilevel tissue update;
- gas configuration and runtime gas switching;
- gas planning;
- CNS/OTU;
- PPO2/MOD;
- planner;
- Diving equipment and checklist;
- Diving Logbook;
- Diving-specific Settings.

### Apnea

Audit:

- automatic session/dive lifecycle;
- depth/time profile;
- ascent/descent;
- surface interval;
- configurable recovery;
- targets;
- alarms;
- markers;
- profiles/planner;
- statistics and records;
- Apnea equipment/buddy;
- Apnea Logbook;
- Apnea-specific Settings.

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
- Snorkeling-specific Settings.

## Settings ownership

Shared settings may include only genuinely cross-activity concerns:

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

Activity settings must remain separate:

```text
Diving Settings
├── Gauge / Full Computer defaults
├── Gas
├── GF
├── PPO2 / MOD
├── CNS / OTU
├── NDL / TTS / Ceiling
├── Deco-stop and gas-switch alerts
└── Diving alarms
```

```text
Apnea Settings
├── Session detection
├── Recovery
├── Targets
├── Depth/time/speed alarms
├── Markers
└── Apnea profiles
```

```text
Snorkeling Settings
├── GPS
├── Route / Waypoints
├── Return to entry
├── Marker categories
├── Dip/session alarms
└── Location privacy
```

Mandatory negative checks:

- CNS, OTU, PPO2, MOD, GF, gas and decompression settings must not appear in Apnea or Snorkeling;
- Apnea recovery and target-training settings must not appear in Diving or Snorkeling;
- Snorkeling GPS route, waypoint and return settings must not appear in Diving or Apnea.

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
- no mixed filters, statistics, details or exports;
- no universal detail view with irrelevant optional fields.

Any cross-activity Logbook visibility or routing is P0.

## Shared infrastructure versus domain separation

Shared infrastructure is allowed for:

- authenticated WatchConnectivity transport;
- checksums;
- ACK/retry;
- backup;
- persistence helpers;
- generic visual primitives;
- localization infrastructure.

Activity payloads, stores, Settings, Logbooks, statistics and exports must remain discriminated and independently versioned.

## Audit-only rule

This command is strictly read-only.

It may create or update only audit reports under the repository's approved audit/documentation output directory.

It must not:

- modify production code;
- modify tests;
- modify project configuration;
- modify mockups;
- apply fixes;
- refactor;
- commit;
- push.

A remediation plan may describe the work required to reach 100%, but it must not perform that work.

---

## CURSOR / CODEX COMMAND — DIR DIVING COMPLETE MATHEMATICAL FUNCTIONS / ALGORITHM AUDIT UPDATED WITH CCR / REBREATHER & LATEST MAIN IMPLEMENTATIONS

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only

You are working on the DIR Diving repository.

## POSITION IN AUDIT SEQUENCE

This is the **0- audit**, the first audit to run after every meaningful change.

The filename must always retain the `0-` prefix. Future revisions of this command must increment only the version suffix, for example `_V2.1`, `_V3.0`, while preserving its position as the first audit in the sequence.

It must run before the specialized numbered audits:

1. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`
2. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`
3. `3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`
4. `4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED.md`
5. `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED.md`
6. `6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED.md`

## CORE OBJECTIVE

Perform a **complete, deep, audit-only verification of all mathematical functions and algorithms implemented in the MAIN branch**, with primary focus on the **iOS Companion Planner and algorithmic stack**, and secondary verification of Apple Watch math/runtime only where it feeds, validates, displays or syncs algorithmic data.

This command is specifically for **mathematical and algorithmic correctness**, not general UI/UX, not code style, and not documentation alignment.

The audit must verify:

- correctness
- completeness
- numerical robustness
- edge cases
- safety relevance
- unit consistency
- gas-role correctness
- profile/timeline consistency
- decompression-model consistency
- sync/persistence data integrity for mathematical values
- release-hard mathematical readiness

The audit must explicitly include the current **CCR / Rebreather** developments and the latest MAIN implementations, including:

- structured Equipment setup and operational pre-dive checklist
- CCR checklist import/export coordination
- configurable Planner ascent-speed settings
- Planner Emergency / Rock Bottom parameters
- complete operational Dive Runtime presentation
- dedicated decompression-stop presentation
- gas ledger presentation in liters and cylinder-equivalent bar
- Technical-mode average-depth gas-consumption option
- repetitive-dive planning
- route-summary and runtime aggregation
- schedule-aware gas consumption
- plan-calculation completeness and result-state gating
- planner briefing PNG/card export to Apple Watch
- CCR bailout scenario and gas-density estimation
- Watch reception, persistence and display of planner briefing cards

These additions must be audited as real mathematical/data-bearing functionality where applicable, and as presentation-only functionality where they intentionally do not alter the underlying model.

---

# TARGET

- Branch: `main` only.
- Primary target: `DIRDiving iOS`.
- Secondary target: Apple Watch only for Watch-specific mathematical/runtime features listed below.
- Shared models consumed by both apps must be inspected when they affect calculations, persistence, sync or export.

---

# TASK TYPE

AUDIT ONLY.

## DO NOT

- modify code
- refactor
- redesign UI
- change business logic
- change planner algorithms
- change Bühlmann logic
- change Ratio Deco logic
- change CCR / Rebreather logic
- change gas planning logic
- change checklist logic
- change Apple Watch runtime logic
- change sync/persistence
- commit
- push

## PRESERVE

- reference-only / non-certified planner positioning
- iOS Planner as reference-only
- CCR/Rebreather planner as reference-only if implemented
- Apple Watch as non-certified companion, not dive computer
- TTV as informational only, not NDL/TTS/deco
- MAIN-only scope
- experimental isolation
- Base / Deco / Technical planner modes
- CCR safety disclaimers and limitations
- no certified CCR controller claims
- no live loop PPO2 monitoring claims unless real validated sensor integration exists

---

# OUTPUT FILE

Create:

```text
Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md
```

The report must be a single consolidated mathematical/algorithmic audit report.

It must include a readiness matrix and final verdict for:

- Bühlmann
- CCR / Rebreather
- Ratio Deco
- Gas Planning
- Emergency / Rock Bottom Gas
- Gas Ledger / Reserve Display
- Schedule-Aware Gas Consumption
- Ascent / Descent Transit Timing
- Repetitive Dive Planning
- MOD / PPO2 / Dalton
- Switch Depth
- Tissue Loading
- Narcotic Loading / END
- CNS / OTU
- Planner Modes
- Checklist Sync where it affects gas/math
- Manual Dive math fields
- PDF / Share mathematical output
- Planner Briefing Card / Watch Transfer Values
- CSV / Subsurface import/export values
- Unit Conversion
- Watch companion math/runtime features
- Sync / Persistence of mathematical values
- Overall Mathematical Readiness

---

# PHASE 0 — PREFLIGHT

Run/inspect:

```bash
git branch --show-current
git status
git rev-parse --short HEAD
git remote -v
git branch -a
```

Then inspect:

- `project.yml`
- `README.md`
- `Docs/*`
- iOS target files
- Watch target files only where relevant
- test targets
- localization files
- excluded/experimental files

Confirm:

- current branch is `main`
- no files modified
- no experimental branches touched
- audit only
- iOS MAIN target membership
- Watch MAIN target membership only where relevant
- experimental files excluded from MAIN runtime targets

STOP if branch is not `main`.

---

# PHASE 1 — UPDATED MATHEMATICAL FEATURE INVENTORY

Create a full inventory of implemented/current algorithmic features.

## iOS Planner

Inventory and classify:

- Base / Deco / Technical modes
- CCR / Rebreather mode if implemented
- Bühlmann ZH-L16C
- Ratio Deco
- Bühlmann vs Ratio Deco comparison
- Ratio Deco presets
- Ratio Deco PDF export
- Air / EAN / Trimix / O2 gas selector
- CCR setpoint low / high
- CCR setpoint switch depth
- CCR diluent gas
- CCR bailout gas
- CCR bailout transition
- PPO2/FPO2 step 0.1
- automatic MOD update
- Dalton MOD validation
- gas switch validation
- switchDepthMeters clamp to MOD
- Back Gas / Travel / Decompression / Bailout roles
- CCR Diluent / CCR Bailout roles
- average depth vs max depth planning reference
- emergency gas always on max depth
- Base mode no-deco validation through Bühlmann
- Deco mode max/average depth <= 40 m
- Technical unrestricted except safety/gas validation
- CCR restrictions and validation gates if implemented

## iOS Checklist / Equipment where it affects math

Inventory:

- My Equipment templates
- REC / TEC templates
- CCR templates if implemented
- custom templates
- Equipment / Task / GAS item types
- GAS switch conditional fields
- Air / EAN / Trimix / O2 in checklist
- CCR Diluent / CCR Bailout if implemented
- Deco Stage / Back Gas / Travel / Bailout cylinder role
- Planner ↔ Checklist guided sync
- structured Equipment setup ↔ Planner mapping
- structured Equipment setup ↔ operational checklist mapping
- CCR checklist import and export round trip
- task items linked to equipment/gas
- DIR / READY badge logic where gas readiness affects planning

## iOS Logbook / Analytics

Inventory:

- manual dive entry
- tissue loading analytics
- narcotic loading analytics
- CCR tissue/narcosis analytics if implemented
- planner + logbook integration
- recorded/planned/simulated source handling
- CSV/Subsurface import/export
- manual profile math
- pressure/bar in/out calculations

## iOS PDF / Share

Inventory math-bearing outputs:

- plan PDF
- briefing PDF
- checklist PDF
- Dive Pack PDF
- Ratio Deco section
- Bühlmann comparison section
- tissue/narcosis section if implemented
- CCR setpoint/diluent/bailout section if implemented
- iOS share sheet numerical text

## Apple Watch

Audit only mathematical/runtime features:

- Start Dive button
- automatic dive start > 1 m
- depth / runtime / average depth / max depth
- ascent rate
- configurable max depth alarm
- default max depth 40 m
- option 30 m
- default time threshold 30 min
- multiple configurable dive reminders
- reminder runtime trigger timing
- unit consistency
- export values
- sync values

## Common / Shared

Inventory:

- metric / imperial units
- localization IT/EN where numerical labels are user-facing
- sync payloads carrying mathematical values
- persistence models carrying mathematical values
- tombstones/conflicts affecting mathematical data
- cloud/iCloud KVS mathematical data integrity

---


# PHASE 1B — LATEST MAIN IMPLEMENTATION INVENTORY

Explicitly locate, inspect and classify the following current MAIN components and any adjacent tests/documentation:

## Planner timing and runtime

- `PlannerAscentSpeedSettings`
- global ascent-speed settings persistence
- descent-speed assumptions
- ascent transit estimates
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- full Dive Runtime ordering
- interleaving of descent, bottom, travel, gas-switch, decompression-stop and final-ascent rows
- consistency among segment time, runtime, TTS/TTR and total plan duration
- presentation-only transformations versus engine-backed values

Verify that presentation builders do not silently recalculate or mutate the Bühlmann/CCR schedule.

## Emergency / Rock Bottom

Inspect all models, services, views and tests associated with:

- Emergency section
- Rock Bottom
- minimum gas
- reserve gas
- team size / stressed diver assumptions
- stressed SAC/RMV
- response or problem-solving time
- ascent and stop gas requirements
- cylinder volume and starting pressure
- liters-to-bar conversion
- available-gas comparison
- insufficiency warnings

Verify that:

- Rock Bottom is calculated independently from normal planned consumption.
- Emergency gas is based on conservative maximum depth unless explicitly and safely documented otherwise.
- Technical average-depth gas-consumption mode does not weaken Rock Bottom.
- CCR bailout calculations do not silently reuse OC Rock Bottom assumptions unless explicitly intended.
- no emergency result is derived from display-rounded values.
- all units and pressure-equivalent values are coherent.

## Gas ledger and reserve presentation

Inspect:

- `GasLedgerDisplayFormatter`
- gas ledger cards
- available gas presentation
- reserve presentation
- liters as primary display
- cylinder-specific bar equivalent
- rounding and formatting
- duplicate gas/cylinder aggregation

Verify that display values remain traceable to canonical liters and that bar values are presentation equivalents only.

## Schedule-aware gas consumption

Inspect:

- `GasPlanningService`
- `PlannerGasSchedule`
- `ScheduleGasConsumptionService`
- all segment/gas-role allocation
- normal consumption versus reserve/emergency consumption
- CCR versus OC segment handling
- travel, back gas, decompression, bailout and diluent roles

Verify that:

- consumption is integrated over the correct depth/time segments.
- gas switches apply at the intended runtime/depth.
- bailout is excluded from the normal schedule unless a bailout scenario is explicitly calculated.
- CCR setpoint segments do not consume diluent as if they were OC breathing segments.
- ascent-speed configuration consistently affects transit time and gas use.

## Technical average-depth gas-consumption option

Audit the Technical-mode option that allows average depth for gas-consumption calculations.

Verify that:

- default remains conservative max-depth planning.
- the toggle affects gas-consumption estimation only.
- Bühlmann, decompression, MOD, PPO2, switch-depth, Rock Bottom and emergency gas remain based on their intended conservative depth.
- average depth is validated and cannot exceed max depth.
- hidden/stale toggle state cannot affect Base, Deco or CCR.
- UI, PDF, briefing card and persisted plan clearly disclose when average-depth gas consumption was selected.

## Repetitive-dive planning

Inspect:

- `RepetitiveDivePlannerService`
- surface interval handling
- residual tissue state
- initial tissue-state import
- prior-dive chronology
- units and timestamps
- planner-mode compatibility
- CCR/OC compatibility
- persistence and export of repetitive-dive metadata

Verify that:

- residual loading is model-backed.
- surface off-gassing is calculated correctly.
- stale or future prior dives are rejected.
- repetitive planning cannot silently fall back to fresh tissues.
- the UI/output explicitly distinguishes fresh-tissue and repetitive-dive calculations.

## Route summary and completeness gates

Inspect:

- `RouteSummaryService`
- `RouteSummaryAggregation`
- `PlanCalculationCompleteness`
- `PlannerResultState`
- any calculation/loading/error/partial state

Verify that:

- summary totals equal canonical plan segments.
- partial plans cannot be exported as complete.
- stale previous results are not displayed after invalid input.
- missing CNS/OTU, tissue, gas or stop data is not silently represented as zero.
- failure states remain explicit.

## Structured Equipment and operational checklist

Inspect:

- `EquipmentStructuredModels`
- `EquipmentStructuredSupport`
- `EquipmentPlannerMapper`
- `EquipmentChecklistGenerator`
- structured setup/profile
- planner links
- checklist links
- operational pre-dive tasks
- gas-role mapping
- CCR-specific equipment/tasks
- Equipment Setup PDF

Verify mathematical/data-bearing mappings, especially cylinder size, working pressure, gas mix, gas role and planner import/export.

## CCR checklist import/export

Inspect:

- `CCRChecklistImportCoordinator`
- `CCRChecklistExportCoordinator`
- role mapping for diluent and bailout
- duplicate prevention
- validation on import
- stale-value replacement rules
- round-trip integrity

Verify that CCR checklist import is now real if compiled into MAIN and that imported values cannot cross-contaminate OC gas roles.

## CCR bailout and gas density

Inspect:

- `CCRBailoutScenarioCalculator`
- `CCRGasDensityEstimator`
- bailout scenario inputs and outputs
- gas density thresholds
- depth/pressure/temperature assumptions
- setpoint versus diluent semantics
- bailout schedule transition

Verify that density results are mathematically traceable and clearly identified as estimates where environmental inputs are assumed.

## Planner briefing cards to Apple Watch

Inspect:

- `PlannerBriefingCard`
- iOS briefing-card generation
- PNG/card rendering
- Watch transfer payload
- `PlannerBriefingCardStore`
- `PlannerBriefingWatchReceiver`
- persistence, replacement and deletion
- units, localization and numerical formatting
- stale-plan/version handling

Verify that:

- cards reproduce canonical plan values.
- rendered PNG text and structured metadata agree.
- no display-only rounding changes safety-critical values.
- the Watch presents briefing data as reference-only, not live sensor or certified decompression guidance.
- outdated cards are detectable and do not overwrite newer plans.
- transfer failure does not imply successful synchronization.


# PHASE 2 — CORE ALGORITHM AUDIT

Audit:

- Bühlmann constants
- N2/He tissue half-times
- a/b values
- N2/He tissues
- Gradient Factors
- ceiling calculation
- NDL calculation
- decompression schedule
- ascent/descent assumptions
- stop rounding
- gas switches
- Trimix / Helium handling
- O2 100% handling
- MOD / PPO2 / Dalton validation
- CNS / OTU
- gas consumption
- SAC/RMV
- Base no-deco enforcement
- Deco 40 m enforcement
- Technical unrestricted mode
- Ratio Deco generator
- Ratio Deco validation through Bühlmann
- Bühlmann vs Ratio Deco comparison
- tissue analytics trace
- narcotic loading / PPN2 / END
- CCR setpoint calculation path if implemented
- CCR diluent inert-gas path if implemented
- CCR bailout path if implemented
- planner ascent/descent speed assumptions
- Rock Bottom / emergency gas calculations
- gas-ledger liters/bar conversion
- schedule-aware gas consumption
- repetitive-dive residual tissue handling
- route-summary totals
- plan-completeness gating
- CCR bailout scenario calculator
- CCR gas-density estimator

Verify:

- no fake/static math is used
- no illustrative chart is labelled as model-backed
- no user-facing numerical result is derived from stale/hidden inactive data
- no certified-decompression wording appears in mathematical output

---

# PHASE 2B — CCR / REBREATHER MATHEMATICAL AUDIT

Audit CCR/Rebreather algorithmic paths if present in MAIN.

Search for and inspect symbols/files containing:

- `CCR`
- `Rebreather`
- `ClosedCircuit`
- `OpenCircuit`
- `Setpoint`
- `Diluent`
- `Bailout`
- `Loop`
- `Scrubber`
- `Sorb`
- `Cell`
- `ppO2Setpoint`
- `setpointLow`
- `setpointHigh`
- `diluentGas`
- `bailoutGas`

Verify:

## CCR model separation

- CCR mode is explicit.
- Open Circuit and Closed Circuit calculations are not silently mixed.
- CCR mode does not leak into Base/Deco unless explicitly supported and labelled.
- OC mode does not accidentally use setpoint PPO2.

## Setpoint math

- low setpoint is validated.
- high setpoint is validated.
- setpoint switch depth is validated.
- setpoint PPO2 is not treated as gas fraction.
- setpoint PPO2 is not confused with FO2-based MOD.
- setpoint changes update CCR exposure/tissue outputs consistently.

## Diluent math

- diluent gas is validated.
- diluent inert fractions are used for tissue/narcosis assumptions where applicable.
- diluent is not treated as breathed OC gas during CCR setpoint phases unless explicitly modeled.
- diluent MOD / operating range is validated or clearly documented if not applicable.

## Bailout math

- bailout gas is validated as open-circuit gas.
- bailout MOD / PPO2 is validated.
- bailout switch depth is clamped to bailout MOD.
- bailout is excluded from scheduled normal gas consumption until bailout transition.
- bailout transition is explicit or clearly documented as unsupported.

## CCR Bühlmann integration

- CCR tissue loading uses setpoint PPO2 plus correct inert-gas model if implemented.
- CCR decompression schedule does not silently combine inconsistent OC and CCR assumptions.
- CCR profile timeline correctly labels CCR segments vs OC bailout segments.

## CCR CNS / OTU

- CCR CNS uses setpoint PPO2 where appropriate.
- CCR OTU uses setpoint PPO2 where appropriate.
- high setpoint warnings dominate normal values.
- setpoint values above safe limits are blocked or warning-prioritized.

## CCR narcotic loading / END

- narcotic loading uses diluent/inert gas assumptions, not setpoint as a narcotic gas.
- PPN2 and END are coherent across CCR segments.
- bailout narcosis switches to bailout gas assumptions after bailout transition.

## CCR bailout scenario and gas-density math

- bailout scenario uses explicit transition depth/time and OC bailout gas.
- normal CCR schedule and emergency bailout schedule remain separate.
- bailout liters/bar requirements are not mixed with normal diluent usage.
- gas-density calculations use explicit, documented assumptions.
- gas density is calculated from current gas composition and ambient pressure.
- warnings and thresholds are traceable to configured constants.
- temperature assumptions and ideal/real-gas limitations are documented.
- display rounding does not alter threshold classification.

## CCR checklist round-trip

- checklist import maps diluent only to CCR diluent.
- checklist import maps bailout only to CCR bailout.
- imported cylinder size/pressure/mix survive validation and persistence.
- export then import preserves roles and numerical values.
- invalid or duplicate entries are rejected or reconciled deterministically.

## CCR output truthfulness

- CCR results do not imply live loop PPO2 monitoring.
- CCR results do not imply certified CCR control.
- CCR results do not imply manufacturer-procedure replacement.
- limitations are explicit.

Output:

- CCR mathematical readiness %
- CCR setpoint readiness %
- CCR diluent readiness %
- CCR bailout readiness %
- CCR tissue readiness %
- CCR CNS/OTU readiness %
- CCR narcosis readiness %

---

# PHASE 3 — PLANNER MODE AUDIT

## Base

Verify:

- no-deco only
- Bühlmann detects mandatory deco
- invalid depth/time combinations are blocked
- Base does not use hidden technical gases
- Base does not use CCR state unless explicitly supported
- warnings IT/EN

## Deco

Verify:

- max depth <= 40 m
- average depth <= 40 m
- decompression allowed
- no over-40 m plan accepted
- only allowed active gas set is used
- hidden Technical/CCR data does not affect Deco
- warnings IT/EN

## Technical

Verify:

- full multigas
- no artificial depth/time caps
- MOD/PPO2/gas validations remain active
- travel/deco/bailout logic remains active
- CCR/Rebreather mode integration is explicit if present

## CCR / Rebreather if present

Verify:

- CCR mode is not a decorative flag
- CCR setpoint/diluent/bailout affect actual projected input
- CCR output complexity is appropriate
- CCR and OC calculations are separated
- switching CCR ↔ OC does not silently corrupt gas plan
- hidden CCR values do not affect OC plans

## Cross-mode transit, emergency and result-state rules

Verify:

- global ascent-speed settings are used consistently by all supported OC/CCR calculations.
- mode-specific restrictions cannot be bypassed by stored ascent-speed settings.
- full Dive Runtime rows preserve canonical segment ordering.
- dedicated deco-stop table matches the actual engine schedule.
- Rock Bottom/emergency calculations appear only where supported and use conservative inputs.
- partial or failed calculations cannot leave stale successful output on screen.
- briefing cards and PDFs cannot be generated from incomplete plan state.

Output:

- Base readiness %
- Deco readiness %
- Technical readiness %
- CCR mode readiness %
- Planner mode readiness %

---

# PHASE 4 — GAS LOGIC AUDIT

Verify gas roles:

## Open Circuit roles

Back Gas:

- surface to first gas switch
- primary gas

Travel:

- used only in defined depth ranges
- not treated as deco gas unless explicitly configured

Decompression:

- ascent/deco only

Bailout:

- emergency only
- not automatically planned as normal gas

## CCR roles if present

Diluent:

- validated separately from bailout
- used for inert gas assumptions where appropriate
- not confused with OC bottom gas

CCR Bailout:

- emergency OC gas
- MOD/PPO2 checked
- switch depth clamped to MOD
- excluded from scheduled normal gas consumption unless bailout transition occurs

Oxygen / setpoint:

- setpoint PPO2 is not a gas fraction
- O2 gas still behaves as gas FO2 = 100%
- O2 MOD remains gas-based, not setpoint-based

Verify:

- Air locks 21/0/79
- EAN edits O2 only
- Trimix edits O2 + He
- O2 locks 100/0/0
- N2 always calculated coherently
- O2 + He + N2 = 100
- MOD updates automatically
- switch depth <= MOD
- PPO2 step is exactly 0.1
- no hidden 0.05 values
- Bühlmann receives current UI gas values
- Ratio Deco receives current UI gas values
- CCR receives correct setpoint/diluent/bailout values

Output:

- Gas logic readiness %
- CCR gas logic readiness %
- Rock Bottom readiness %
- Schedule-aware gas consumption readiness %
- Gas ledger / reserve display readiness %
- Technical average-depth gas-consumption readiness %

---


# PHASE 4B — EMERGENCY GAS / ROCK BOTTOM AUDIT

Audit every Rock Bottom and emergency-gas formula and input source.

At minimum verify:

- ambient pressure calculation
- max-depth reference
- stressed diver count/team-size multiplier
- stressed RMV/SAC combination
- problem-solving time
- ascent transit time
- decompression/stop inclusion policy
- gas-switch policy
- reserve policy
- liters required
- cylinder bar equivalent
- available versus required comparison
- rounding direction
- unit conversion
- validation bounds
- overflow/NaN/infinite handling
- Base/Deco/Technical/CCR mode eligibility
- PDF/share/briefing-card consistency

Generate independent hand-calculated reference cases for:

1. shallow no-deco OC dive
2. 30–40 m Deco dive
3. deep Technical trimix dive
4. Technical plan with average-depth gas toggle enabled
5. insufficient single-cylinder case
6. multiple-cylinder case
7. CCR bailout case, if integrated
8. metric/imperial round trip

Output:

- Emergency / Rock Bottom readiness %
- emergency unit-conversion readiness %
- emergency export consistency %

# PHASE 4C — TRANSIT SPEED / RUNTIME / STOP PRESENTATION AUDIT

Audit configured descent/ascent speeds and all runtime builders.

Verify:

- valid bounds and defaults
- persistence and migration
- correct unit semantics
- no zero/negative speed
- no division-by-zero
- transit duration calculation
- correct runtime accumulation
- correct ordering of descent, bottom, ascent, gas switches and stops
- dedicated deco-stop section exactly matches decompression engine output
- Dive Runtime and deco table remain mutually consistent
- CCR setpoint-switch row placement
- gas use integrates over transit duration
- localization does not alter numeric parsing
- presentation builders never mutate canonical results

Output:

- Transit timing readiness %
- Dive Runtime readiness %
- Deco-stop presentation truthfulness %

# PHASE 4D — REPETITIVE DIVE / RESIDUAL TISSUE AUDIT

Audit repetitive-dive planning end to end.

Verify:

- previous tissue state source
- surface interval computation
- tissue off-gassing
- N2/He compartment preservation
- GF compatibility
- CCR/OC transition compatibility
- chronology validation
- fresh-tissue fallback prohibition
- explicit source labelling
- persistence/sync integrity
- export disclosure
- deterministic repeated calculations

Generate test vectors for short, medium and long surface intervals and compare against independent reference calculations.

Output:

- Repetitive-dive readiness %
- residual-tissue integrity readiness %


# PHASE 5 — RATIO DECO AUDIT

Verify:

- Ratio Deco is heuristic/comparative only
- disclaimer visible
- Bühlmann remains primary
- Ratio Deco does not bypass MOD/PPO2
- Ratio Deco does not bypass CCR limitations if CCR profiles are unsupported
- Ratio Deco is not applied to CCR unless explicitly supported and labelled
- presets 1:1 / 2:1 / custom
- custom preset persistence
- first stop / step / distribution / minimum stop
- schedule generation
- gas assignment
- bailout excluded from normal plan
- Bühlmann validation of Ratio Deco
- ceiling violations detected
- MOD violations detected
- comparison table
- overlay chart
- PDF export integration
- localization IT/EN

Output:

- Ratio Deco readiness %
- Ratio Deco CCR compatibility readiness % if applicable

---

# PHASE 6 — TISSUE & NARCOSIS AUDIT

Verify iOS Planner + Logbook analytics:

- TissueAnalyticsTrace
- TissueAnalyticsSample
- TissueCompartmentLoading
- 16 compartments C1-C16
- controlling compartment
- tissue loading %
- tissue trend
- Bühlmann ZH-L16C source
- M-value / GF-relative loading
- 100% reference line
- chart colors/thresholds
- PPN2 over runtime
- END based on PPN2
- PPO2 tooltip
- source label:
  - recorded
  - planned
  - simulated
  - CCR if implemented
- insufficient data empty state
- cache/performance
- no fake/static charts
- analytics informational only

CCR-specific if implemented:

- tissue source uses setpoint/diluent model correctly
- CCR segments are labelled
- bailout segment uses bailout gas assumptions
- END uses diluent/bailout inert assumptions as appropriate
- no static/fake CCR analytics

Output:

- Tissue readiness %
- Narcosis readiness %
- CCR Tissue readiness %
- CCR Narcosis readiness %

---

# PHASE 7 — CNS / OTU AUDIT

Verify:

- CNS full plan
- descent + bottom CNS
- ascent/deco CNS if implemented
- 15% descent+bottom rule
- deco gas CNS contribution
- O2 100% handling
- labels IT/EN
- warning visibility
- no misleading bottom-only CNS after full calculation

CCR-specific if implemented:

- CCR CNS uses setpoint PPO2
- CCR OTU uses setpoint PPO2
- high setpoint warnings are visible
- bailout segment CNS/OTU uses OC bailout gas if bailout transition occurs
- CCR exposure labels clearly say setpoint-based estimate
- no live PPO2 monitoring implication

Output:

- CNS/OTU readiness %
- CCR CNS/OTU readiness %

---

# PHASE 8 — CHART / TABLE AUDIT

Audit:

- PIANO table
- ascent plan
- depth/time chart
- Bühlmann curve
- tissue chart
- narcotic chart
- Ratio Deco overlay
- gas bars
- CCR setpoint timeline if implemented
- CCR diluent/bailout timeline if implemented
- decompression stop labels
- complete Dive Runtime rows
- dedicated decompression-stop section
- gas ledger in liters and bar equivalent
- Rock Bottom / emergency gas cards
- repetitive-dive/source indicators
- route summary totals
- runtime/TTS/TTR consistency
- no static/fake rows
- chart accessibility
- chart localization

Output:

- Chart/table mathematical truthfulness readiness %
- CCR chart readiness %

---

# PHASE 9 — CHECKLIST / EQUIPMENT AUDIT

Verify:

- Equipment templates
- My Equipment
- REC / TEC / custom
- CCR template if implemented
- add/remove equipment
- add/remove tasks
- task linked to equipment/gas
- GAS switch hides fields when OFF
- GAS fields appear when ON
- gas mix selector in checklist
- O2 pure in checklist
- cylinder role:
  - Back Gas
  - Deco Stage
  - Travel / Trasporto
  - Bailout
  - Diluent if implemented
  - CCR Bailout if implemented
- Planner ↔ Checklist guided sync
- structured Equipment setup ↔ Planner mapping
- structured Equipment setup ↔ operational checklist mapping
- CCR checklist import and export round trip
- duplicate prevention
- PDF YES/NO checklist export
- DIR badge:
  - red until required items ready
  - green when complete
- READY badge preserved
- FIELD badge removed

DIR required items:

- bibo configured
- backup mask
- SMB
- spool
- at least one configured gas
- wet notes
- signaling buoy with spool

CCR checklist if implemented:

- oxygen cells
- diluent configured
- bailout configured
- scrubber/sorb task if present
- loop/check tasks if present
- no CCR tasks shown for OC plan unless relevant

Output:

- Checklist math/gas readiness %
- CCR Checklist readiness %

---

# PHASE 10 — PDF / SHARE AUDIT

Audit mathematical correctness of:

- Planner share icon top-right
- Checklist share icon top-right
- plan PDF
- briefing PDF
- checklist PDF
- Dive Pack PDF
- YES/NO printable checklist fields
- disclaimer footer
- Ratio Deco section
- Bühlmann comparison section
- tissue/narcosis inclusion if implemented
- CCR setpoint/diluent/bailout section if implemented
- CCR limitations/disclaimer if implemented
- Equipment Setup PDF
- planner briefing PNG/card generation
- planner briefing card transfer to Apple Watch
- Share Sheet works with WhatsApp/Mail/AirDrop/Files
- file naming
- empty/invalid state handling
- localization

Verify exported values match internal model:

- depths
- times
- stops
- gas mixes
- switch depths
- MOD
- PPO2
- CNS/OTU
- tissue/narcosis if exported
- CCR setpoints/diluent/bailout if exported
- units
- Rock Bottom / emergency values
- ascent-speed assumptions
- full runtime and dedicated deco stops
- gas ledger liters/bar equivalents
- repetitive-dive status
- planner briefing card values

Output:

- PDF/share mathematical output readiness %
- CCR PDF/share readiness %

---

# PHASE 11 — LOGBOOK / MANUAL DIVE / IMPORT EXPORT AUDIT

Audit:

- manual dive add/edit/delete
- max depth
- average depth
- GPS start/end
- profile
- equipment
- bar in/out
- textual deco description
- CCR manual dive fields if implemented
- CSV export
- Subsurface compatibility
- CCR Subsurface/export limitations if applicable
- duplicate handling
- malformed import handling
- metric/imperial consistency
- tissue/narcosis on recorded profiles
- CCR tissue/narcosis on CCR profiles if implemented

Output:

- Manual Dive math readiness %
- Import/export readiness %
- CCR logbook readiness %

---

# PHASE 12 — APPLE WATCH AUDIT

Audit only Watch-specific mathematical/runtime features:

- Start Dive button on initial screen
- manual start state
- automatic start >1 m still active
- no duplicate sessions
- depth sampling
- average depth
- max depth
- runtime
- TTV informational semantics
- ascent rate
- max depth alarm configurable
- default 40 m
- allows 30 m
- time threshold default 30 min
- multiple dive reminders:
  - enabled/disabled globally
  - multiple items max 10
  - single after X minutes
  - recurring every X minutes
  - message max 24 chars
  - haptic optional
  - overlay 3 seconds
  - simultaneous aggregation
  - safety alert priority
  - runtime starts at actual dive start
- unit consistency
- localization IT/EN
- sync/export numerical values
- Planner briefing card reception
- briefing-card persistence and replacement
- briefing-card numerical fidelity
- briefing-card reference-only wording
- stale/outdated briefing-card handling

Watch CCR-specific:

- Watch must not imply live CCR monitoring unless real integration exists.
- Watch must not display CCR plan data as live sensor data.
- Synced CCR plan/log data, if any, must be labelled reference-only.

Output:

- Watch math/runtime readiness %
- Watch CCR display safety readiness %

---

# PHASE 13 — SYNC / DATA / PERSISTENCE AUDIT

Audit:

- Watch sync
- CloudSyncStore
- DiveLogStore
- EquipmentStore
- PlannerStore
- checklist persistence
- reminder persistence
- image persistence
- manual dive persistence
- CCR plan persistence if implemented
- CCR manual dive/logbook persistence if implemented
- Planner ascent-speed settings persistence
- Rock Bottom/emergency settings persistence
- Technical average-depth gas toggle persistence
- repetitive-dive tissue/source persistence
- structured Equipment setup persistence
- CCR checklist import/export role persistence
- Planner briefing card transfer/persistence/versioning
- unit settings sync
- duplicate IDs
- tombstones
- conflict handling
- malformed data
- migration/backward compatibility

Verify:

- mathematical values survive save/load
- mathematical values survive sync
- mathematical values survive cloud conflict handling
- CCR values survive save/load/sync if implemented
- cloud merge does not silently fuse divergent profiles
- imported/exported values match internal model

Output:

- Sync/data mathematical integrity readiness %
- CCR persistence readiness %

---

# PHASE 14 — LOCALIZATION / ACCESSIBILITY AUDIT FOR MATH OUTPUTS

Verify EN/IT coverage for math-bearing labels:

- planner modes
- CCR / Rebreather if implemented
- setpoint
- diluent
- bailout
- Ratio Deco
- gases
- checklist
- tasks
- PDF/share
- tissue/narcosis
- CNS/OTU
- MOD/PPO2/Dalton
- Watch reminders
- warnings
- errors
- disclaimers

Audit accessibility only where it affects numerical interpretation:

- chart accessibility
- math chart summaries
- gas card labels
- selected Planner mode
- CCR setpoint controls
- warning readability
- dark mode contrast
- small iPhone layout
- Apple Watch readability

Output:

- Localization readiness for math outputs %
- Accessibility readiness for math outputs %

---

# PHASE 15 — TEST COVERAGE AUDIT

Verify tests for:

- planner modes
- no-deco Base
- 40 m Deco
- Technical unrestricted
- CCR mode if implemented
- CCR setpoint/diluent/bailout if implemented
- gas mix modes
- MOD/Dalton
- switchDepthMeters clamp
- PPO2 step 0.1
- Bühlmann
- Ratio Deco
- tissue analytics
- narcotic loading
- CCR tissue/narcosis if implemented
- CNS/OTU
- CCR CNS/OTU if implemented
- checklist templates
- GAS field visibility
- DIR badge
- PDF export
- manual dive
- import/export
- Watch reminders
- Watch start dive
- image transfer
- localization
- Planner ascent/descent speed settings
- runtime ordering
- dedicated deco-stop table equivalence
- Rock Bottom/emergency gas
- gas-ledger liters/bar conversion
- schedule-aware gas consumption
- Technical average-depth gas toggle isolation
- repetitive-dive residual tissues
- route-summary aggregation
- plan-completeness/result-state gating
- structured Equipment mappings
- CCR checklist import/export round trip
- CCR bailout scenario
- CCR gas density
- Planner briefing card encode/render/transfer/receive/persist

Flag missing tests.

---

# PHASE 16 — DOCUMENTATION AUDIT FOR MATH ACCURACY

Verify docs explain:

- non-certified positioning
- planner modes
- CCR/Rebreather limitations if implemented
- CCR setpoint/diluent/bailout assumptions
- CCR not-a-controller / not-live-loop-monitor disclaimer
- Bühlmann
- Ratio Deco heuristic status
- gas roles
- MOD/PPO2
- switchDepth clamp
- CNS/OTU
- tissue/narcosis analytics
- checklist workflow
- PDF sharing
- Watch reminders
- image transfer
- manual dive
- limitations
- Planner ascent-speed assumptions
- Rock Bottom/emergency gas assumptions
- gas ledger liters/bar semantics
- Technical average-depth gas toggle scope
- repetitive-dive limitations
- full Dive Runtime and dedicated deco stops
- structured Equipment/checklist workflow
- CCR checklist import/export
- CCR bailout and gas-density assumptions
- Planner briefing cards on Apple Watch
- TestFlight readiness

Flag stale or missing docs.

---

# PHASE 17 — BUILD / TEST EXECUTION

On macOS run:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'generic/platform=iOS Simulator' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
```

If simulators unavailable, use available equivalents and document.

On non-macOS:

- do not run xcodebuild
- do static audit only
- clearly state macOS validation required

---

# PHASE 18 — FINDINGS CLASSIFICATION

Classify all findings:

- P0 — safety-critical / misleading decompression or oxygen output / crash / certified-advice risk
- P1 — math correctness / release-hard blocker
- P2 — UX clarity around math / validation / data integrity / test gap
- P3 — documentation / maintainability / polish
- P4 — nice-to-have

For each issue include:

- ID
- title
- family
- file/function
- severity
- affected target:
  - iOS
  - Watch
  - Shared
- affected planner mode:
  - Base
  - Deco
  - Technical
  - CCR
  - Ratio Deco
  - Shared
- user impact
- safety impact
- mathematical explanation
- proposed fix
- acceptance criteria
- estimated impact:
  - copy-only
  - UI-only
  - small functional
  - medium refactor
  - architectural
  - external QA/process

Findings must also identify whether the defect is in:

- canonical calculation
- input validation
- persistence/sync
- role mapping
- presentation builder
- numerical formatting/rounding
- export/rendering
- documentation/test coverage

---

# PHASE 19 — TEST PLAN GENERATION

Generate test plan for:

- unit tests
- integration tests
- simulator tests
- physical iPhone/Watch tests
- paired-device tests
- planner boundary tests
- CCR boundary tests
- Ratio Deco tests
- tissue/narcosis tests
- CNS/OTU tests
- PDF/share tests
- checklist tests
- sync tests
- import/export tests
- iCloud merge tests
- localization/accessibility tests
- Rock Bottom reference-vector tests
- ascent/descent transit tests
- runtime-ordering tests
- gas-ledger conversion tests
- schedule-aware gas-use tests
- repetitive-dive tissue tests
- CCR checklist round-trip tests
- briefing-card fidelity and transfer tests

For each test include:

- feature
- input
- expected output
- pass/fail criteria
- priority

---

# PHASE 20 — FINAL REPORT

Create:

```text
Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md
```

Report must include:

## A. Executive Summary

- readiness %
- mathematical robustness %
- planner confidence %
- Bühlmann readiness %
- CCR/Rebreather readiness %
- Ratio Deco readiness %
- tissue/narcosis readiness %
- CNS/OTU readiness %
- checklist readiness %
- Watch companion readiness %
- sync/data confidence %
- TestFlight blockers
- App Store blockers

## B. Algorithm Inventory

## C. Planner Mode Audit

## D. Bühlmann Mathematical Assessment

## E. CCR / Rebreather Mathematical Assessment

Must include:

- CCR mode readiness
- setpoint readiness
- diluent readiness
- bailout readiness
- CCR Bühlmann readiness
- CCR tissue readiness
- CCR CNS/OTU readiness
- CCR narcosis/END readiness
- CCR export/share readiness
- CCR external validation status

## F. Ratio Deco Assessment

## G. Gas / MOD / PPO2 / SAC Assessment

## H. Emergency / Rock Bottom Assessment

## I. Transit Speed / Dive Runtime / Deco Stops Assessment

## J. Schedule-Aware Gas Consumption / Gas Ledger Assessment

## K. Repetitive Dive / Residual Tissue Assessment

## L. Tissue & Narcosis Assessment

## M. CNS / OTU Assessment

## N. Charts / Tables Assessment

## O. Checklist / Equipment Assessment

## P. PDF / Share / Planner Briefing Card Assessment

## Q. Logbook / Manual Dive / Import Export Assessment

## R. Apple Watch Companion Assessment

## S. Sync / Persistence Assessment

## T. Localization / Accessibility Assessment

## U. Findings by Priority

## V. Edge Case Matrix

## W. Test Plan

## X. Readiness Matrix

Mandatory table:

| Feature | Readiness |
|---|---:|
| Bühlmann | XX% |
| CCR / Rebreather | XX% |
| CCR Setpoint | XX% |
| CCR Diluent | XX% |
| CCR Bailout | XX% |
| Ratio Deco | XX% |
| Gas Planning | XX% |
| Emergency / Rock Bottom | XX% |
| Schedule-Aware Gas Consumption | XX% |
| Gas Ledger / Reserve Display | XX% |
| Ascent / Descent Transit Timing | XX% |
| Dive Runtime / Deco Stop Truthfulness | XX% |
| Repetitive Dive / Residual Tissues | XX% |
| MOD / PPO2 / Dalton | XX% |
| Switch Depth Clamp | XX% |
| Tissue Loading | XX% |
| Narcosis / END | XX% |
| CNS / OTU | XX% |
| Checklist Gas Sync | XX% |
| Manual Dive Math | XX% |
| PDF / Share Math Output | XX% |
| Planner Briefing Card / Watch Transfer | XX% |
| Structured Equipment / Checklist Mapping | XX% |
| CCR Checklist Import / Export | XX% |
| CCR Bailout Scenario | XX% |
| CCR Gas Density | XX% |
| CSV / Subsurface Math Output | XX% |
| Watch Math Runtime | XX% |
| Sync / Persistence Math Integrity | XX% |
| Unit Conversion | XX% |
| Overall Math Readiness | XX% |

## Y. Prioritized Roadmap

1. Must fix before compile/use
2. Must fix before internal TestFlight
3. Must fix before external TestFlight
4. Must fix before App Store
5. Post-release improvements

## Z. Final Verdict

Answer clearly:

- mathematically ready?
- are Base/Deco/Technical modes real?
- is CCR/Rebreather mathematically coherent?
- is CCR clearly reference-only?
- is Ratio Deco safely comparative?
- is Bühlmann truthful?
- are tissue/narcosis charts truthful?
- are CNS/OTU correct?
- is the checklist operationally ready for gas/math sync?
- are PDFs/share mathematically truthful?
- are Watch reminders/start dive mathematically/runtime ready?
- is sync/data ready?
- ready for internal TestFlight?
- ready for external TestFlight?
- ready for App Store?
- are Rock Bottom/emergency gas calculations conservative and coherent?
- are ascent/descent speeds and runtime rows mathematically consistent?
- does the dedicated deco-stop section exactly match the engine schedule?
- is schedule-aware gas consumption correct by segment and gas role?
- is the Technical average-depth gas toggle isolated to gas consumption?
- are repetitive-dive residual tissues coherent and explicitly identified?
- are gas ledger liters/bar values truthful?
- are structured Equipment/checklist mappings numerically safe?
- does CCR checklist import/export preserve gas roles?
- are CCR bailout and gas-density results mathematically traceable?
- do Planner briefing cards transferred to Watch match canonical plan values?
- what blocks 100% mathematical readiness?

STRICT FINAL RULE:

Do not fix anything during this task.
Only inspect, verify, classify, test if possible, and report.

---

# SUCCESS CRITERIA

The task is complete only if:

- no code is modified
- no business logic is modified
- no algorithms are modified
- no CCR/Rebreather logic is modified
- no Watch runtime is modified
- report is created at `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`
- report contains CCR/Rebreather mathematical assessment
- report contains full readiness matrix
- report contains issue classification
- report contains test plan
- all external validation gaps are clearly marked as pending, not passed
- latest MAIN features listed in Phase 1B are explicitly assessed
- Rock Bottom, ascent-speed settings, runtime/deco presentation, gas ledger, repetitive-dive planning and briefing-card transfer are included
- structured Equipment and CCR checklist import/export mappings are included
- presentation-only components are not mistaken for independent algorithms
- no readiness percentage is awarded without file/function/test evidence


---

# VERSION HISTORY

## V3.0 — 2026-06-19

Updated against the current `main` architecture and latest implementations.

Added explicit audit coverage for:

- structured Equipment setup and operational pre-dive checklist
- CCR checklist import/export round-trip
- global Planner ascent-speed settings
- Planner Emergency / Rock Bottom
- complete Dive Runtime ordering
- dedicated deco-stop presentation
- gas ledger in liters and cylinder-equivalent bar
- schedule-aware gas consumption
- Technical average-depth gas-consumption toggle
- repetitive-dive planning and residual tissues
- route-summary aggregation
- plan completeness and result-state gating
- CCR bailout scenario calculator
- CCR gas-density estimator
- Planner briefing card / PNG transfer to Apple Watch
- Watch briefing-card reception, persistence and reference-only presentation

Preserved:

- `0-` audit sequence position
- audit-only behavior
- MAIN-only scope
- safety and non-certified positioning
- separation of OC, CCR and Ratio Deco logic
- prohibition on code modification, commit and push

---

# V3.0 MATHEMATICAL SCOPE EXPANSION

In addition to the existing Diving/CCR mathematical audit, audit the new activity engines without conflating their semantics.

## Apnea mathematics

Verify:

- depth/time sample integrity;
- monotonic timers;
- descent/ascent speed;
- surface-interval computation;
- configurable recovery formulas;
- target/record calculations;
- session aggregation;
- no unsupported physiological prediction;
- unit conversion;
- persistence and replay determinism.

## Snorkeling mathematics

Verify:

- surface distance;
- GPS accuracy filtering;
- speed;
- route length;
- waypoint bearing;
- return-to-entry distance and bearing;
- dip depth/time aggregation;
- no underwater GPS interpolation presented as measured;
- map simplification without canonical-data loss;
- unit conversion.

Add readiness scores for Apnea math, Snorkeling math and cross-activity numerical isolation.
