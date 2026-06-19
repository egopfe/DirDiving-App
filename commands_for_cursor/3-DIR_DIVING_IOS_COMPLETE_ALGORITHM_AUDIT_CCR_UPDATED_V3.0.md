# 3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0

## CURSOR / CODEX COMMAND — DIR DIVING iOS COMPLETE ALGORITHM / MATH / PLANNER / DATA READINESS AUDIT UPDATED WITH CCR / REBREATHER AND LATEST MAIN IMPLEMENTATIONS

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Target:** `DIRDiving iOS`  
**Task type:** complete deep audit-only

You are working on the DIR DIVING repository.

---

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

# POSITION IN AUDIT SEQUENCE

This is audit command number **3** in the recurring DIR DIVING audit sequence.

The filename must always retain the `3-` prefix. Future revisions must increment only the version suffix, for example `_V2.1`, `_V3.0`, while preserving this command's position in the sequence.

Run this command after:

1. `0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0.md`
2. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md`
3. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md`

This audit is broader than the dedicated Bühlmann audit. It must inspect the complete iOS MAIN algorithmic, data-integrity, planner, persistence, sync, export and release-hard stack while preserving all current implementation logic.

---

# ABSOLUTE RULES

## AUDIT ONLY

DO NOT:

- modify production source code;
- refactor;
- apply patches;
- auto-fix issues;
- alter UI or UX;
- alter visual identity;
- change business logic;
- change Bühlmann mathematics;
- change Ratio Deco mathematics;
- change CCR assumptions;
- change gas-planning logic;
- change Planner mode logic;
- change Rock Bottom logic;
- change ascent/descent timing logic;
- change repetitive-dive logic;
- change checklist/equipment mappings;
- change sync or cloud merge logic;
- change security or trust models;
- touch Apple Watch runtime code except read-only compatibility inspection;
- touch experimental branches or excluded files;
- commit;
- push.

## PRESERVE

- branch `main`;
- iOS MAIN-only primary scope;
- Base / Deco / Technical architecture;
- CCR as a separate, reference-only planner mode;
- Ratio Deco as heuristic/comparative only;
- non-certified planner positioning;
- no dive-computer or CCR-controller claims;
- metric internal storage;
- `PlannerEnvironment`-aware calculations;
- MOD/PPO2/switch-depth safety;
- gas-role separation;
- manual/no-depth truthfulness;
- WatchConnectivity HMAC/peer-secret/signed-ACK model;
- cloud conflict/tombstone policy;
- external and physical QA as PENDING unless evidence exists.

The audit must distinguish:

1. canonical calculation;
2. validation/preflight;
3. projection/mapping;
4. persistence/sync;
5. presentation builder;
6. formatter/localizer;
7. export/rendering;
8. documentation/test-only code.

Presentation-only code must not be credited as a separate mathematical engine.

---

# OUTPUT

Create one consolidated report:

`Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

The report must include:

- complete algorithm inventory;
- readiness percentages;
- evidence-backed findings;
- issue matrix;
- edge-case matrix;
- test coverage matrix;
- release-hard matrix;
- prioritized remediation plan;
- TestFlight/App Store verdict;
- external validation gaps;
- future Cursor remediation commands.

Do not create or modify any production source file.

---

# LATEST MAIN IMPLEMENTATIONS THAT MUST BE INCLUDED

Audit the current implementation state of:

- structured Equipment setup;
- operational pre-dive checklist generation;
- Planner ↔ Equipment ↔ Checklist mappings;
- CCR checklist import/export;
- Planner ascent-speed settings;
- Planner descent/ascent transit assumptions;
- Planner Emergency / Rock Bottom parameters;
- complete Dive Runtime presentation;
- dedicated decompression-stop section;
- gas ledger in liters;
- cylinder-equivalent pressure in bar;
- schedule-aware gas consumption;
- Technical average-depth gas-consumption option;
- repetitive-dive planning;
- residual tissue-state handling;
- route summary aggregation;
- plan-completeness and result-state gating;
- CCR bailout scenario calculator;
- CCR gas-density estimator;
- Planner briefing card / PNG export;
- Planner briefing card transfer to Apple Watch;
- Watch-side receipt/persistence of planner cards as reference-only;
- latest localization and accessibility remediation affecting mathematical interpretation.

Audit actual source paths and target membership. Do not assume implementation from filenames alone.

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

Inspect:

- `project.yml`
- iOS target membership
- test target membership
- shared models
- excluded experimental files
- Docs and existing audit reports
- localization resources
- build settings
- entitlements
- Watch companion relationship only where needed for data/export compatibility

Confirm:

- branch is `main`;
- target is `DIRDiving iOS`;
- test target is `DIRDiving iOS Algorithm Tests`;
- Watch runtime remains out of scope;
- experimental files remain excluded;
- audit-only status.

STOP if branch is not `main`.

If macOS/Xcode is available, run:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

Do not fix failures. Record exact commands, failures and environmental limitations.

---

# PHASE 1 — COMPLETE ARCHITECTURE AND FEATURE INVENTORY

Inventory and classify all MAIN iOS algorithm-bearing components.

At minimum inspect:

## Core planner

- `iOSApp/Models/DivePlan.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/PlanCalculationCompleteness.swift`

## Bühlmann

- `iOSApp/Algorithms/Buhlmann/BuhlmannConstants.swift`
- `BuhlmannGas.swift`
- `BuhlmannTissueModel.swift`
- `BuhlmannEngine.swift`
- `BuhlmannTissueHistory.swift`
- `BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`

## Gas and exposure

- `GasPlanningService`
- `PlannerGasSchedule`
- `ScheduleGasConsumptionService`
- `PlannerMODValidator`
- `GasMixValidator`
- `OxygenExposureModels`
- `PlannerEnvironment`
- `GasLedgerDisplayFormatter`

## Timing/runtime

- `PlannerAscentSpeedSettings`
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- `RouteSummaryService`
- `RouteSummaryAggregation`

## CCR

- `CCRModels`
- `CCRInspiredGasModel`
- `CCRPlanValidator`
- `CCRPlannerEngine`
- `CCRTissueHistorySampler`
- `CCRPlannerService`
- `CCRBailoutScenarioCalculator`
- `CCRGasDensityEstimator`
- `CCRPlannerSettings`

## Repetitive dive

- `RepetitiveDivePlannerService`
- prior-dive/tissue-state inputs
- surface interval handling
- residual-tissue persistence

## Equipment/checklist

- `EquipmentProfile`
- `EquipmentStructuredModels`
- `EquipmentStructuredSupport`
- `EquipmentPlannerMapper`
- `EquipmentChecklistGenerator`
- `ChecklistPlannerSyncMapper`
- `CCRChecklistImportCoordinator`
- `CCRChecklistExportCoordinator`
- `DIRChecklistConfigurationEvaluator`

## Manual dive / analytics

- `ManualDiveEditorDefaults`
- `ManualDiveEditorValidation`
- `DiveProfileMath`
- `AnalysisDashboardMath`
- tissue/narcosis services
- route-summary analytics
- pressure display math

## Export / sync

- Planner PDF builders
- Briefing PDF builders
- Equipment Setup PDF builder
- Ratio Deco PDF sections
- CCR PDF builder
- Subsurface export/import
- Watch sync codecs
- Planner briefing-card model/generation/transfer
- CloudSyncStore
- conflict and merge validators

Output an inventory table:

| Family | Canonical source | Validation | Persistence | Presentation | Export | Tests | Reachable | Readiness |
|---|---|---|---|---|---|---|---|---:|

---

# PHASE 2 — BÜHLMANN CORE AUDIT

Verify:

- ZHL-16C constants;
- 16 N2/He compartments;
- half-times;
- a/b coefficients;
- tissue initialization;
- inspired inert pressure;
- descent/ascent integration;
- GF low/high interpolation;
- ceiling;
- controlling compartment;
- first stop;
- stop rounding;
- decompression convergence;
- no-decompression limit;
- gas-switch integration;
- trimix/helium;
- O2 100%;
- surface pressure;
- altitude/salinity/freshwater;
- invalid-input guards;
- deterministic output;
- no fake/static results.

Test or inspect:

- air no-deco;
- nitrox;
- trimix;
- multigas deco;
- altitude;
- freshwater/saltwater;
- GF variants;
- invalid switch;
- missing gas;
- extreme input rejection.

Output:

- Bühlmann readiness %;
- mathematical robustness %;
- external validation status;
- blocking issues.

---

# PHASE 3 — PLANNER MODE PROJECTION AUDIT

## Base

Verify:

- one active gas;
- no hidden technical gas influence;
- no mandatory deco accepted;
- NDL uses Base projection;
- simplified output;
- no CCR leakage.

## Deco

Verify:

- bottom gas plus allowed deco gas set;
- depth/average-depth limits;
- no unsupported bailout projection;
- correct simplified schedule;
- mode-aware preview/export.

## Technical

Verify:

- travel/back/deco/bailout roles;
- multiple deco gases;
- manual GF if supported;
- full schedule;
- full analytics;
- full gas ledger;
- emergency gas;
- Technical average-depth gas-consumption toggle.

## CCR

Verify:

- separate mode;
- no OC state leakage;
- setpoint/diluent/bailout projection;
- correct result gating;
- Ratio Deco blocked unless explicitly supported;
- reference-only safety positioning.

Output:

- Base readiness %;
- Deco readiness %;
- Technical readiness %;
- CCR mode readiness %;
- projection integrity %.

---

# PHASE 4 — MOD / PPO2 / DALTON / SWITCH DEPTH AUDIT

Verify:

- single canonical MOD formula;
- automatic MOD update;
- PPO2 increments exactly 0.1;
- Air/EAN/Trimix/O2 editing rules;
- O2+He+N2 = 100%;
- environment-aware MOD;
- displayed MOD equals validated MOD;
- switch depth clamps to MOD;
- shallower switch remains allowed;
- hidden/stale values cannot bypass clamp;
- export/PDF/checklist use same values;
- CCR setpoint is not treated as FO2;
- diluent/bailout validation is role-correct.

Mandatory case:

- O2 100%, PPO2 1.6 → MOD approximately 6 m.

Output:

- MOD readiness %;
- PPO2/Dalton readiness %;
- switch-depth readiness %;
- environment consistency %.

---

# PHASE 5 — GAS ROLE AND SCHEDULE-AWARE CONSUMPTION AUDIT

Verify roles:

- Back Gas;
- Travel;
- Decompression;
- Bailout;
- CCR Diluent;
- CCR Bailout.

Audit:

- role identity/stable IDs;
- correct segment allocation;
- switch depth/runtime;
- schedule-aware consumption;
- descent/bottom/ascent/deco gas use;
- travel-gas ranges;
- bailout exclusion from normal schedule;
- CCR diluent not consumed as OC breathing gas;
- CCR bailout becomes OC only after explicit transition;
- duplicate gas handling;
- unused/standby gas;
- checklist/export integration.

Output:

- Gas Planning readiness %;
- Gas Role readiness %;
- schedule-aware consumption readiness %;
- CCR gas-role readiness %.

---

# PHASE 6 — EMERGENCY / ROCK BOTTOM AUDIT

Inspect all Emergency/Rock Bottom models, settings, calculations, persistence, UI projections and exports.

Verify:

- maximum-depth reference;
- ambient pressure;
- stressed RMV/SAC;
- team/diver multiplier;
- response/problem-solving time;
- ascent transit;
- decompression/stop inclusion;
- reserve separation;
- liters required;
- cylinder-equivalent bar;
- insufficiency warnings;
- finite guards;
- rounding direction;
- unit conversion;
- mode eligibility.

Critical invariants:

- Rock Bottom is independent from normal planned consumption;
- Technical average-depth gas mode does not weaken emergency gas;
- canonical liters remain source of truth;
- bar equivalent is display-only;
- CCR bailout emergency logic remains separate from OC bottom gas.

Generate reference cases for:

1. shallow OC;
2. 30–40 m Deco;
3. deep Technical;
4. Technical average-depth toggle enabled;
5. insufficient cylinder;
6. multiple cylinders;
7. CCR bailout;
8. metric/imperial round trip.

Output:

- Rock Bottom readiness %;
- emergency gas readiness %;
- liters/bar conversion readiness %.

---

# PHASE 7 — ASCENT SPEED / DIVE RUNTIME / DECO STOPS AUDIT

Inspect:

- global ascent-speed settings;
- descent-speed assumptions;
- persistence/migration;
- `PlannerAscentTableBuilder`;
- `DecoStopsPresentationBuilder`;
- full Dive Runtime;
- route summaries.

Verify:

- defaults/bounds;
- no zero/negative speed;
- transit-time formula;
- correct runtime accumulation;
- phase ordering;
- gas-switch placement;
- CCR setpoint-switch placement;
- dedicated deco-stop table equals canonical schedule;
- no presentation-layer recomputation;
- ascent-speed changes propagate consistently to transit gas use;
- runtime/TTS/TTR totals agree.

Output:

- transit timing readiness %;
- Dive Runtime readiness %;
- deco-stop truthfulness %;
- route-summary readiness %.

---

# PHASE 8 — TECHNICAL AVERAGE-DEPTH GAS TOGGLE AUDIT

Verify:

- default uses conservative max depth;
- toggle affects gas consumption only;
- Bühlmann unchanged;
- decompression unchanged;
- MOD/PPO2 unchanged;
- switch-depth unchanged;
- Rock Bottom unchanged;
- average depth <= max depth;
- stale toggle cannot affect Base/Deco/CCR;
- persistence is mode-safe;
- PDF/share/briefing disclose selected basis.

Output:

- average-depth gas readiness %;
- mode isolation %;
- disclosure/export readiness %.

---

# PHASE 9 — REPETITIVE DIVE / RESIDUAL TISSUE AUDIT

Inspect:

- prior-dive source;
- tissue-state import;
- chronology;
- surface interval;
- N2/He off-gassing;
- GF compatibility;
- OC/CCR compatibility;
- stale/future dive rejection;
- deterministic output;
- persistence;
- export disclosure;
- no silent fresh-tissue fallback.

Test short, medium and long surface intervals.

Output:

- repetitive-dive readiness %;
- residual-tissue integrity %;
- persistence/disclosure readiness %.

---

# PHASE 10 — RATIO DECO AUDIT

Verify:

- heuristic/comparative status;
- Bühlmann remains primary;
- presets 1:1 / 2:1 / custom;
- first stop/step/distribution/minimum stop;
- active gas projection;
- MOD/PPO2 validation;
- ceiling validation;
- comparison table;
- overlay chart;
- export/PDF;
- localization;
- CCR blocked unless explicitly supported.

Output:

- Ratio Deco readiness %;
- comparison readiness %;
- export readiness %.

---

# PHASE 11 — TISSUE / NARCOSIS / CNS / OTU AUDIT

Verify:

- 16 compartments;
- N2/He loading;
- controlling compartment;
- M-value/GF-relative loading;
- tissue trends;
- PPN2;
- END/EAD;
- active gas timeline;
- CCR setpoint/diluent model;
- bailout transition;
- full-plan CNS;
- OTU;
- warning thresholds;
- finite guards;
- planner/logbook source labeling;
- no fake/static charts;
- accessibility summaries for numerical charts.

Output:

- Tissue readiness %;
- Narcosis readiness %;
- CNS/OTU readiness %;
- CCR analytics readiness %.

---

# PHASE 12 — CCR DEDICATED AUDIT

Verify:

## Setpoint

- low/high setpoints;
- switch depth/time;
- validation;
- setpoint-driven PPO2;
- no FO2 confusion.

## Diluent

- O2/He/N2;
- inspired inert model;
- MOD/MND;
- hypoxic validation;
- END/EAD;
- gas density.

## Bailout

- explicit OC transition;
- bailout schedule;
- MOD/PPO2;
- gas quantity;
- CNS/OTU;
- tissue/narcosis transition;
- checklist/export.

## CCR engine integration

- setpoint drives oxygen partial pressure;
- inert loading remains coherent;
- GF behavior unchanged;
- bailout uses OC model;
- no mixed assumptions.

## CCR bailout scenario

Audit `CCRBailoutScenarioCalculator`.

## CCR gas density

Audit `CCRGasDensityEstimator`:

- formula;
- gas composition;
- ambient pressure;
- temperature assumptions;
- thresholds;
- warning classification;
- display rounding.

## CCR checklist round trip

Audit:

- import;
- export;
- role preservation;
- duplicate handling;
- stale-value replacement;
- cylinder size/pressure/mix integrity.

Output:

- CCR overall readiness %;
- setpoint readiness %;
- diluent readiness %;
- bailout readiness %;
- CCR Bühlmann readiness %;
- CCR exposure readiness %;
- CCR checklist readiness %;
- CCR gas-density readiness %.

---

# PHASE 13 — STRUCTURED EQUIPMENT / CHECKLIST AUDIT

Verify:

- structured profile;
- REC/TEC/CCR/custom templates;
- equipment/task/gas types;
- planner mapping;
- checklist generation;
- gas role preservation;
- cylinder volume;
- working pressure;
- gas mix;
- duplicate prevention;
- user-data preservation;
- DIR/READY badges;
- Equipment Setup PDF;
- CCR tasks/equipment;
- planner/checklist round trip.

Output:

- Equipment readiness %;
- checklist readiness %;
- planner mapping readiness %;
- CCR checklist readiness %.

---

# PHASE 14 — MANUAL DIVE / LOGBOOK / ANALYTICS AUDIT

Verify:

- max/average depth;
- profile;
- GPS;
- equipment;
- gas;
- bar in/out;
- pressure math;
- deco notes;
- CCR metadata;
- metadata-only no-depth mode;
- recorded/planned/simulated source;
- tissue/narcosis eligibility;
- malformed profile handling;
- cloud merge;
- duplicate prevention.

Output:

- Manual Dive readiness %;
- logbook math readiness %;
- CCR logbook readiness %.

---

# PHASE 15 — PDF / SHARE / CSV / BRIEFING CARD AUDIT

Audit:

- Planner PDF;
- Briefing PDF;
- Dive Pack;
- Checklist PDF;
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
- average-depth gas basis;
- disclaimers;
- units.

## Planner briefing card / PNG to Apple Watch

Verify:

- canonical values;
- rendered text;
- structured metadata;
- units/localization;
- plan mode;
- gas mixes;
- stops/runtime;
- Rock Bottom where included;
- version/timestamp;
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

Output:

- PDF readiness %;
- Share readiness %;
- CSV/Subsurface readiness %;
- briefing-card fidelity/transfer readiness %.

---

# PHASE 16 — CLOUD / SYNC / PERSISTENCE / SECURITY AUDIT

Verify:

- mathematical values survive save/load;
- unit values remain canonical;
- planner settings persist correctly;
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
- trust reset;
- privacy/GPS handling.

Output:

- persistence readiness %;
- sync integrity %;
- security/privacy readiness %;
- CCR persistence readiness %.

---

# PHASE 17 — UNIT CONVERSION / LOCALIZATION / ACCESSIBILITY AUDIT

Verify:

- m/ft;
- bar/psi;
- C/F;
- L/cu ft where used;
- m/min / ft/min;
- RMV/SAC;
- gas ledger liters/bar;
- Rock Bottom;
- CCR setpoint units;
- gas density;
- PDF/CSV/card values;
- locale-safe dates and decimal formatting;
- EN/IT mathematical labels;
- chart accessibility summaries;
- checklist toggle semantics;
- CCR chart summaries;
- no Italian-as-key leakage in math-bearing UI.

Output:

- unit readiness %;
- localization readiness %;
- accessibility readiness for mathematical outputs %.

---

# PHASE 18 — PERFORMANCE / NUMERICAL ROBUSTNESS AUDIT

Audit:

- repeated planner recomputation;
- debouncing;
- SwiftUI update loops;
- tissue timelines;
- CCR timelines;
- Ratio Deco overlay;
- repetitive-dive calculations;
- gas schedule calculations;
- Rock Bottom;
- PDF/card rendering;
- export;
- large profiles;
- many gases;
- NaN/infinite/overflow;
- stale async result publication;
- result-state race conditions.

Output:

- performance readiness %;
- numerical robustness %;
- state-concurrency readiness %.

---

# PHASE 19 — TEST COVERAGE AUDIT

Inspect all iOS algorithm tests.

Required coverage:

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
- briefing card encode/render/transfer;
- CSV/Subsurface;
- cloud conflicts;
- units;
- localization/accessibility.

Output:

- automated test readiness %;
- manual QA readiness %;
- external validation readiness %.

---

# PHASE 20 — STATIC SCANS

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
- file path construction;
- stale test-only code in MAIN.

Search for:

- `RockBottom`
- `Emergency`
- `PlannerAscentSpeedSettings`
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- `GasLedgerDisplayFormatter`
- `ScheduleGasConsumptionService`
- `RepetitiveDivePlannerService`
- `RouteSummary`
- `PlanCalculationCompleteness`
- `CCRChecklistImportCoordinator`
- `CCRBailoutScenarioCalculator`
- `CCRGasDensityEstimator`
- `PlannerBriefingCard`

Do not fix anything.

---

# PHASE 21 — ISSUE CLASSIFICATION

For every issue provide:

- ID;
- title;
- severity: CRITICAL/HIGH/MEDIUM/LOW/INFO;
- priority: P0/P1/P2/P3/P4;
- family;
- target;
- planner mode;
- file/function;
- evidence;
- user impact;
- safety impact;
- mathematical impact;
- security/privacy impact;
- performance impact;
- canonical-vs-presentation classification;
- proposed fix;
- effort;
- regression risk;
- tests;
- dependencies;
- acceptance criteria.

Issue families must include:

- Bühlmann;
- Planner modes;
- CCR;
- Ratio Deco;
- MOD/PPO2;
- Gas Roles;
- Rock Bottom;
- Transit Timing;
- Dive Runtime;
- Gas Ledger;
- Repetitive Dive;
- Tissue/Narcosis;
- CNS/OTU;
- Equipment/Checklist;
- Manual Dive;
- PDF/CSV/Card Export;
- Units;
- Sync/Persistence;
- Security;
- Performance;
- Tests;
- Docs;
- External QA.

---

# PHASE 22 — RELEASE-HARD READINESS MATRIX

Mandatory table:

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | XX% | ... | ... |
| Planner Base/Deco/Technical | XX% | ... | ... |
| CCR / Rebreather | XX% | ... | ... |
| Ratio Deco | XX% | ... | ... |
| Gas Planning | XX% | ... | ... |
| Gas Roles | XX% | ... | ... |
| MOD/PPO2/Dalton | XX% | ... | ... |
| Switch Depth Clamp | XX% | ... | ... |
| Emergency / Rock Bottom | XX% | ... | ... |
| Ascent / Descent Timing | XX% | ... | ... |
| Dive Runtime / Deco Stops | XX% | ... | ... |
| Schedule-Aware Gas Consumption | XX% | ... | ... |
| Gas Ledger / Reserve | XX% | ... | ... |
| Technical Average-Depth Gas Toggle | XX% | ... | ... |
| Repetitive Dive / Residual Tissues | XX% | ... | ... |
| Tissue Loading | XX% | ... | ... |
| Narcosis / END / PPN2 | XX% | ... | ... |
| CNS / OTU | XX% | ... | ... |
| Structured Equipment | XX% | ... | ... |
| Checklist Sync | XX% | ... | ... |
| CCR Checklist Import / Export | XX% | ... | ... |
| CCR Bailout Scenario | XX% | ... | ... |
| CCR Gas Density | XX% | ... | ... |
| Manual Dive | XX% | ... | ... |
| PDF / Share | XX% | ... | ... |
| Planner Briefing Card / Watch Transfer | XX% | ... | ... |
| CSV / Subsurface | XX% | ... | ... |
| Unit Conversion | XX% | ... | ... |
| Cloud / Sync / Persistence | XX% | ... | ... |
| Security / Privacy | XX% | ... | ... |
| Performance / Numerical Robustness | XX% | ... | ... |
| Test Coverage | XX% | ... | ... |
| Internal TestFlight | XX% | ... | ... |
| External TestFlight | XX% | ... | ... |
| App Store | XX% | ... | ... |
| Overall | XX% | ... | ... |

Every percentage must cite file/function/test evidence.

---

# PHASE 23 — FINAL REPORT STRUCTURE

Create:

`Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

Required sections:

A. Executive Summary  
B. Scope and Preflight  
C. Architecture Inventory  
D. Bühlmann  
E. Planner Modes  
F. MOD/PPO2/Dalton/Switch Depth  
G. Gas Roles and Schedule Consumption  
H. Emergency / Rock Bottom  
I. Transit Timing / Dive Runtime / Deco Stops  
J. Technical Average-Depth Gas Toggle  
K. Repetitive Dive  
L. Ratio Deco  
M. Tissue / Narcosis / CNS / OTU  
N. CCR / Rebreather  
O. Structured Equipment / Checklist  
P. Manual Dive / Logbook  
Q. PDF / Share / CSV / Briefing Card  
R. Cloud / Sync / Persistence / Security  
S. Units / Localization / Accessibility  
T. Performance / Numerical Robustness  
U. Test Coverage  
V. Detailed Issue Matrix  
W. Edge-Case Matrix  
X. Release-Hard Matrix  
Y. Prioritized Action Plan  
Z. 7-Day / 14-Day Readiness Plan  
AA. Future Cursor Remediation Commands  
AB. Final Verdict

The final verdict must answer:

- Is Bühlmann ready?
- Are Planner modes real and isolated?
- Is CCR mathematically coherent and reference-only?
- Is Ratio Deco safely comparative?
- Are MOD/PPO2/switch-depth rules consistent?
- Is Rock Bottom conservative and correct?
- Are ascent/descent timing and runtime totals coherent?
- Does the deco-stop table match the engine?
- Is gas consumption correct by segment and role?
- Is the average-depth gas toggle isolated?
- Are repetitive-dive tissues coherent?
- Are tissue/narcosis/CNS/OTU truthful?
- Are Equipment/checklist mappings safe?
- Does CCR checklist round trip preserve roles?
- Are CCR bailout and gas density traceable?
- Are manual dives and exports reliable?
- Are briefing cards numerically faithful and reference-only?
- Is sync/data integrity release-hard?
- Is the app ready for internal TestFlight?
- Is it ready for external TestFlight?
- Is it ready for App Store?
- What blocks 100% readiness?
- What must be fixed first?

---

# PHASE 24 — FINAL VALIDATION

Verify:

- report exists;
- report is non-empty;
- no production source modified;
- no experimental file touched;
- issue matrix exists;
- edge-case matrix exists;
- release-hard matrix exists;
- action plan exists;
- exact build/test commands and results are recorded;
- external/physical validation is never marked PASS without evidence;
- git status shows only report/docs changes.

---

# SUCCESS CRITERIA

The task is complete only if:

- audit-only rules were respected;
- no production code, UI, business logic, algorithms, sync or security model changed;
- report created at `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`;
- all latest MAIN implementations listed above were audited;
- canonical calculation and presentation-only logic were separated;
- readiness percentages are evidence-backed;
- external validation remains PENDING unless executed;
- the report contains a complete remediation roadmap;
- final git status confirms only report/docs changed.

If any area cannot be fully analyzed:

- state the limitation;
- explain why;
- identify the exact file, test, device or external validation required next.

---

# VERSION HISTORY

## V3.0 — 2026-06-19

Updated against the current `main` implementation.

Added explicit audit coverage for:

- Planner Emergency / Rock Bottom;
- ascent-speed settings;
- complete Dive Runtime;
- dedicated decompression-stop section;
- schedule-aware gas consumption;
- gas ledger liters/bar;
- Technical average-depth gas toggle;
- repetitive-dive residual tissues;
- route-summary and result-state gating;
- structured Equipment;
- CCR checklist import/export;
- CCR bailout scenario;
- CCR gas-density estimation;
- Planner briefing-card / PNG export to Apple Watch;
- briefing-card numerical fidelity, sync and reference-only presentation;
- latest localization/accessibility relevant to mathematical outputs.

Preserved:

- `3-` audit-sequence prefix;
- iOS MAIN-only primary scope;
- audit-only behavior;
- all existing planner, CCR, Ratio Deco, safety, security and release-gate logic;
- no code modification, commit or push.

---

# V3.0 IOS COMPLETE ALGORITHM EXPANSION

Extend the iOS audit beyond Diving.

Audit:

- iOS root activity selection;
- activity-specific dashboards and feature routes;
- Apnea planner/profile/session analytics;
- Snorkeling route/GPS/dip analytics;
- three Settings domains plus Shared Settings;
- three session stores and sync codecs;
- three Logbooks with strict ownership;
- three export families;
- cross-activity schema isolation;
- migration from legacy Diving-only data.

Do not award readiness for a model or view that is not reachable from its owning activity root.
