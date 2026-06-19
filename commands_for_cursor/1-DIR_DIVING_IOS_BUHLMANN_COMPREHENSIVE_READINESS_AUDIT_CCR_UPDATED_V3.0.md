# CURSOR / CODEX COMMAND — 1-DIR DIVING iOS BÜHLMANN COMPREHENSIVE READINESS AUDIT UPDATED WITH CCR / REBREATHER — V3.0

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

You are working on the DIR DIVING repository.

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only


## TARGET

ONLY branch `main`.

## TARGET APP

ONLY iOS Companion MAIN target:

- `DIRDiving iOS`

## AUDIT PRIORITY ORDER

This is the **first audit command** to run after every meaningful Planner / algorithm / gas / CCR / Ratio Deco / export / checklist / logbook change.

The filename intentionally starts with `1-` because this audit is the first readiness gate before any follow-up remediation command.

The `1-` prefix must always be preserved. Future revisions must change only the version suffix, for example `_V2.1`, `_V3.0`, while keeping this command in the same audit-sequence position.

`Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md`

## TASK TYPE

FULL DEEP AUDIT ONLY.

DO NOT MODIFY CODE.  
DO NOT REFACTOR.  
DO NOT FIX ISSUES.  
DO NOT CHANGE UI.  
DO NOT CHANGE BUSINESS LOGIC.  
DO NOT CHANGE ALGORITHMS.  
DO NOT CHANGE SECURITY MODEL.  
DO NOT CHANGE SYNC MODEL.  
DO NOT CHANGE PLANNER MODE LOGIC.  
DO NOT IMPLEMENT CCR / REBREATHER FEATURES DURING THIS AUDIT.  
DO NOT SILENTLY CONVERT OPEN-CIRCUIT LOGIC INTO CCR LOGIC.  

This is a read-only audit that must produce a detailed Markdown report and a prioritized remediation plan.

---

# SOURCE CONTEXT TO INCLUDE

Use and integrate the latest project context and existing docs if present:

- `Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md` if already present
- `Docs/DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_V3.md`
- `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_CURRENT.md`
- `Docs/IOS_MAIN_ALGORITHM_MATH_AUDIT_REMEDIATION_REPORT.md`
- `Docs/DIR_Diving_Planner_Tabs_Implementation_Plan.md`
- `Docs/DIR_Diving_Planner_Tabs_Implementation_Report.md`
- `Docs/IOS_PLANNER_LIMITATIONS.md`
- `Docs/IOS_PLANNER_MOD_SWITCH_DEPTH_AUTOCLAMP_REPORT.md`
- `Docs/DIR_DIVING_IOS_OXYGEN_EXPOSURE_MODEL.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_MATH_VERIFICATION.md`
- `Docs/DIR_DIVING_IOS_BUHLMANN_EXTERNAL_VALIDATION_PLAN.md`
- `Docs/CSV_IMPORT_EXPORT_POLICY.md`
- `Docs/SUBSURFACE_CSV_ROUNDTRIP.md`
- `Docs/RELEASE_CHECKLIST.md`
- `Docs/TESTFLIGHT_REVIEW_NOTES.md`
- `Docs/UI_UX_MAIN_AUDIT_CURRENT.md`
- `Docs/UI_UX_MAIN_AUDIT_REMEDIATION_REPORT.md`
- documentation for Planner ascent-speed settings
- documentation for Planner Emergency / Rock Bottom
- documentation for full Dive Runtime and dedicated deco-stop presentation
- documentation for gas ledger / reserve presentation
- documentation for structured Equipment and operational checklist
- documentation for CCR checklist import/export
- documentation for repetitive-dive planning
- documentation for Planner briefing cards exported to Apple Watch

If any document is missing, note it in the final report. Do not invent evidence from missing files.

---

# OBJECTIVE

Perform a complete and deep **iOS Bühlmann algorithm completeness and functionality readiness audit** covering the Planner, decompression engine, gas model, CCR / rebreather extension readiness, Ratio Deco, tissue loading, narcotic loading, MOD/PPO2/Dalton validation, gas roles, checklist sync, manual dive integration, PDF/share export, CSV import/export, unit conversion and release-hard readiness matrix.

The audit must include the latest MAIN implementations, especially:

- structured Equipment setup and operational pre-dive checklist;
- CCR checklist import and export;
- Planner ascent-speed settings;
- Planner Emergency / Rock Bottom parameters;
- complete Dive Runtime presentation;
- dedicated decompression-stop section;
- gas ledger and reserve display in liters and cylinder-equivalent bar;
- Technical-mode average-depth gas-consumption option;
- schedule-aware gas consumption;
- repetitive-dive planning and residual tissue handling;
- route summary and plan-completeness/result-state gating;
- CCR bailout scenario calculator;
- CCR gas-density estimator;
- Planner briefing card / PNG export to Apple Watch.

The audit must distinguish canonical algorithm changes from presentation-only changes and must not treat display builders as independent decompression algorithms.

The audit must answer:

1. Is the Bühlmann implementation complete enough for internal validation?
2. Are the Base / Deco / Technical Planner modes correctly projected into Bühlmann input?
3. Are MOD/PPO2/Dalton checks consistent across Planner, Ratio Deco, Bühlmann, gas cards, export and validation?
4. Are gas roles coherent across Back Gas, Travel, Deco, Bailout and CCR-specific gases?
5. Are CCR / Rebreather concepts implemented, partially implemented, not implemented, or only planned?
6. If CCR exists, does it preserve open-circuit logic and explicitly model CCR-specific concepts?
7. Are tissue loading and narcotic loading model-backed, chart-backed and export-backed without fake/static values?
8. Are manual dives, logbook profiles, planner simulations and exports using consistent math?
9. What blocks 100% Bühlmann / Planner readiness?
10. Are Rock Bottom/emergency gas calculations conservative and isolated from normal planned consumption?
11. Are ascent/descent speeds, runtime rows and decompression-stop rows mathematically consistent?
12. Is schedule-aware gas consumption coherent across segments and gas roles?
13. Is the Technical average-depth gas toggle limited to gas-consumption estimation only?
14. Are repetitive-dive residual tissues handled explicitly and correctly?
15. Do gas ledger liters/bar values match canonical gas calculations?
16. Do structured Equipment and CCR checklist mappings preserve gas roles and numerical values?
17. Are Planner briefing cards transferred to Apple Watch numerically faithful and clearly reference-only?
18. What must be fixed first, without changing the product logic already implemented?

---

# CURRENT DEVELOPMENT CONTEXT TO RESPECT

The current DIR DIVING iOS Planner context includes or may include:

## A. Three-mode Planner architecture

- Base
- Deco
- Technical

These modes must be real, not decorative. They must affect:

- visible inputs
- active gas set
- validation rules
- calculation input projection
- result sections
- Bühlmann display level
- warning scope
- export/share output
- accessibility summaries
- localization

## B. MOD / PPO2 / switch-depth safety behavior

- changing oxygen percentage and/or max PPO2 must update calculated MOD;
- non-bottom gases must clamp `switchDepthMeters` to MOD;
- user may choose a shallower switch depth than MOD;
- user may not persist a switch depth deeper than MOD;
- MOD must respect `PlannerEnvironment`;
- existing `PlannerMODValidator` / `GasMix.modMeters(environment:)` helpers must be used;
- no duplicated MOD formula;
- no recursive SwiftUI `.onChange` loop.

## C. Current audit themes to preserve

- cloud merge must not silently fuse divergent dive profiles;
- NDL preview must use mode-projected input;
- PPO2 tolerance must be centralized;
- Base and Deco must validate `PlannerEnvironment`;
- `GasPlanningService` preview analysis must be mode-aware;
- share/export must include active Planner mode;
- cloud KVS payload size must be guarded;
- Subsurface validation remains external unless actually executed.

## D. CCR / Rebreather extension context

The audit must explicitly inspect whether the repository contains CCR / Rebreather features or scaffolding. If present, verify them. If absent, report readiness as 0% / not implemented and provide a safe implementation gap plan.

CCR / Rebreather audit scope includes:

- open-circuit vs CCR mode separation;
- setpoint low / high;
- setpoint switch depth;
- diluent gas;
- bailout gas;
- oxygen supply gas;
- loop PPO2 model;
- diluent PPO2 / END / MOD checks;
- bailout switch logic;
- CNS/OTU exposure under setpoint control;
- tissue loading using CCR setpoint vs open-circuit gas fractions;
- bailout decompression recalculation or bailout schedule comparison;
- CCR gas consumption model, if present;
- scrubber duration / CO2 warning, if present;
- CCR-specific export/share/checklist/manual dive/logbook fields, if present.

Do not implement CCR features during this audit. Report only.

---


## E. Latest MAIN implementation context

The current `main` branch includes or may include the following additional components that must be audited where present:

- `PlannerAscentSpeedSettings`
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- `GasLedgerDisplayFormatter`
- `ScheduleGasConsumptionService`
- `RepetitiveDivePlannerService`
- `RouteSummaryService`
- `RouteSummaryAggregation`
- `PlanCalculationCompleteness`
- `PlannerResultState`
- `EquipmentStructuredModels`
- `EquipmentStructuredSupport`
- `EquipmentPlannerMapper`
- `EquipmentChecklistGenerator`
- `CCRChecklistImportCoordinator`
- `CCRChecklistExportCoordinator`
- `CCRBailoutScenarioCalculator`
- `CCRGasDensityEstimator`
- `PlannerBriefingCard`
- `PlannerBriefingCardStore`
- `PlannerBriefingWatchReceiver`

Audit actual source paths and target membership instead of assuming names or implementation status.

## F. Canonical math versus presentation-only logic

The audit must classify every relevant component as one of:

1. canonical calculation source;
2. validation/preflight;
3. projection/mapping;
4. persistence/sync;
5. presentation builder;
6. numerical formatter;
7. export/rendering;
8. documentation/test only.

Presentation-only components must be verified for fidelity to canonical results but must not be credited as separate mathematical engines.


# ABSOLUTE RULES

DO NOT:

- touch Apple Watch runtime code;
- touch experimental branches;
- touch Exploration Lab;
- touch Buddy experimental;
- touch Snorkeling experimental;
- touch Apnea experimental;
- modify files excluded from `project.yml`;
- apply patches;
- auto-fix issues;
- change UI graphics;
- redesign UX;
- change app visual identity;
- change Bühlmann core math;
- change Ratio Deco logic;
- change gas-planning logic;
- change Base / Deco / Technical Planner mode logic;
- change MOD/PPO2/switch-depth behavior;
- change cloud merge logic;
- change WatchConnectivity trust model;
- weaken legal/safety disclaimers;
- introduce certified decompression-planner claims;
- claim CCR readiness if CCR is only stubbed or absent;
- claim physical QA passed unless actually executed;
- claim external Subsurface validation passed unless actually executed;
- claim external decompression-planner validation passed unless actually executed.

PRESERVE:

- iOS MAIN only;
- current iOS dark marine/cyan UI;
- current Planner visual language;
- current reference-only Planner positioning;
- non-certified planning disclaimer;
- Base / Deco / Technical architecture;
- mode-specific input projection;
- mode-specific result gating;
- MOD/switch-depth clamp safety;
- `PlannerEnvironment`-aware MOD calculations;
- metric internal storage;
- existing export/import safety guards;
- existing Watch/iOS sync validation model;
- existing tombstone/conflict policy;
- all physical/external QA gates as pending unless actually executed.

---

# PHASE 0 — PREFLIGHT

1. Confirm branch:

```bash
git branch --show-current
```

2. Confirm current commit:

```bash
git rev-parse --short HEAD
```

3. Confirm working tree:

```bash
git status
```

4. Confirm remote alignment:

```bash
git fetch origin
git status -sb
```

5. Inspect `project.yml` and list:

- all targets;
- source folders;
- excluded files;
- test targets;
- bundle IDs;
- iOS target membership.

6. Confirm target:

- `DIRDiving iOS`

7. Confirm iOS experimental exclusions:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

8. Run if environment allows:

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

9. Do not fix build/test failures. Record them.

10. Before auditing, print:

- branch;
- commit;
- dirty files;
- iOS target confirmed;
- experimental exclusions confirmed;
- build status;
- test status;
- docs found / docs missing;
- files/directories to inspect.

STOP if branch is not `main`.

---

# PHASE 1 — BÜHLMANN ARCHITECTURE INVENTORY

Inspect at least:

## Planner / modes

- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Services/PlannerStore.swift`
- `iOSApp/Services/PlannerService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/PlannerResultState.swift`
- `iOSApp/Utils/PlanCalculationCompleteness.swift`
- `iOSApp/Models/PlannerAscentSpeedSettings.swift`
- `iOSApp/Services/PlannerAscentTableBuilder.swift`
- `iOSApp/Services/DecoStopsPresentationBuilder.swift`
- `iOSApp/Services/RouteSummaryService.swift`
- `iOSApp/Utils/RouteSummaryAggregation.swift`

## Bühlmann / gas / exposure

- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Services/GasLedgerDisplayFormatter.swift`
- `iOSApp/Services/RepetitiveDivePlannerService.swift`
- `iOSApp/Services/PlannerEnvironment.swift`
- `iOSApp/Services/OxygenExposureModels.swift`
- `iOSApp/Utils/GasMixValidator.swift`
- `iOSApp/Utils/IOSUnitConversions.swift`
- `iOSApp/Utils/Formatters.swift`

## Ratio Deco / charts / analytics

Search for:

- `RatioDecoPlanner`
- `RatioDecoValidator`
- `RatioDeco`
- `TissueLoading`
- `Tissue`
- `Narcotic`
- `Narcosis`
- `END`
- `EAD`
- `PPN2`
- `Ceiling`
- `Compartment`
- `TissueHistory`

## Logbook / manual dive / export / checklist

- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Views/ManualDiveEditorView.swift`
- `iOSApp/Views/DiveDetailView.swift`
- `iOSApp/Views/AnalysisView.swift`
- `iOSApp/Views/LogbookView.swift`
- `iOSApp/Views/EquipmentView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Models/EquipmentStructuredModels.swift`
- `iOSApp/Utils/EquipmentStructuredSupport.swift`
- `iOSApp/Utils/EquipmentPlannerMapper.swift`
- `iOSApp/Utils/EquipmentChecklistGenerator.swift`
- `iOSApp/Utils/CCRChecklistImportCoordinator.swift`
- `iOSApp/Utils/CCRChecklistExportCoordinator.swift`
- `iOSApp/Services/PDF/EquipmentSetupPDFBuilder.swift`
- `Models/PlannerBriefingCard.swift`
- Watch-side briefing-card receiver/store files only to verify iOS export fidelity and reference-only semantics

Search for:

- `Checklist`
- `Equipment`
- `PDF`
- `Share`
- `Export`
- `ManualDive`

Output an inventory table:

| Family | Files | Implemented | Reachable | Tested | Readiness % | Notes |
|---|---|---:|---:|---:|---:|---|

Families:

1. Bühlmann core
2. Planner modes
3. Gas roles
4. MOD/PPO2/Dalton
5. Ratio Deco
6. Tissue Loading
7. Narcotic Loading
8. CCR / Rebreather
9. Planner ↔ Checklist
10. Manual Dive
11. PDF / Share
12. CSV / Subsurface
13. Unit conversion
14. Emergency / Rock Bottom
15. Transit timing / Dive Runtime
16. Gas ledger / reserve display
17. Repetitive Dive
18. Structured Equipment mapping
19. Planner briefing card export
20. Release-hard matrix

---

# PHASE 2 — BASE / DECO / TECHNICAL PLANNER READINESS AUDIT

Verify:

## Base

- one active gas;
- hidden technical gases ignored;
- mode-projected input used;
- NDL preview uses Base projection;
- full technical schedule hidden;
- deco obligation triggers guidance to Deco / Technical;
- no hidden gas affects calculation.

## Deco

- bottom gas + max one deco gas;
- no bailout in active projection;
- no multiple deco gas in active projection;
- NDL / Bühlmann summary simplified;
- one gas switch max;
- Deco projection used in Planner, NDL preview, gas analysis, export/share.

## Technical

- bottom gas;
- travel gas;
- multiple deco gases;
- bailout gases;
- manual GF low/high if supported;
- full Bühlmann schedule;
- full tissue/compartment charts where implemented;
- full gas ledger and bailout separation;
- Technical average-depth gas-consumption toggle is isolated to gas consumption;
- Emergency/Rock Bottom remains conservative;
- complete Dive Runtime and dedicated deco-stop sections match canonical results.

Output:

- Planner mode readiness %;
- mode projection correctness %;
- mode-specific validation readiness %;
- mode-specific export/readiness %.

---

# PHASE 3 — BÜHLMANN CORE READINESS AUDIT

Verify:

- ZHL model variant, expected ZHL-16C if claimed;
- 16 compartments;
- N2 and He handling;
- tissue halftime constants;
- M-values / a/b coefficients;
- GF low / high interpolation;
- surface pressure handling;
- altitude / freshwater / salinity via `PlannerEnvironment`;
- ascent/descent segment handling;
- stop depth rounding;
- first stop calculation;
- ceiling calculation;
- controlling compartment identification if implemented;
- no-decompression limit preview;
- decompression schedule convergence;
- invalid gas preflight;
- hypoxic gas checks;
- MOD/PPO2 checks;
- bailout/standby separation.

Test / inspect edge cases:

- no-deco air profile;
- nitrox profile;
- trimix profile;
- multigas deco profile;
- altitude profile;
- freshwater/saltwater if supported;
- GF 30/70 vs 50/80;
- invalid gas switch;
- missing gas;
- empty schedule;
- extreme depth/time rejected.

Output:

- Bühlmann readiness %;
- mathematical robustness %;
- external validation status;
- blocking issues.

---

# PHASE 3B — RATIO DECO READINESS AUDIT

Verify:

- `RatioDecoPlanner`
- `RatioDecoValidator`
- comparison mode with Bühlmann
- overlay chart
- presets:
  - 1:1
  - 2:1
  - custom
- Bühlmann validation layer
- Ratio Deco output gating by Planner mode
- Ratio Deco export/share/PDF if claimed
- localization
- safety wording: Ratio Deco must not be presented as certified decompression model

Verify consistency:

- active gas set matches Planner mode;
- MOD/PPO2 rules reused;
- gas roles respected;
- no fake overlay data;
- no static charts presented as calculated;
- Ratio Deco comparison labels are clear.

Output:

- Ratio Deco readiness %;
- comparison readiness %;
- export readiness %;
- validation gaps.

---

# PHASE 3C — GAS ROLE AUDIT

Verify gas roles:

## Back Gas

- surface → first valid switch;
- bottom gas projection by mode;
- integration with Bühlmann;
- integration with gas ledger;
- checklist sync.

## Travel Gas

- configured depth ranges;
- switch depth validation;
- breathable range validation;
- not used in Base/Deco unless explicitly intended;
- integrated in Technical.

## Decompression Gas

- ascent only;
- switch depth <= MOD;
- EAN50 / O2 100% behavior;
- no switch deeper than MOD;
- gas ledger integration;
- PDF/export integration.

## Bailout

- emergency only;
- excluded from scheduled consumption totals;
- clearly labelled standby / bailout;
- included in checklist if configured;
- not treated as planned deco gas unless bailout schedule exists.

## CCR-specific gas roles, if present

- diluent;
- oxygen supply;
- bailout OC gas;
- offboard bailout;
- setpoint-controlled loop gas;
- gas role separation from open-circuit back/deco gas.

Verify:

- Planner integration;
- Bühlmann integration;
- gas ledger integration;
- PDF integration;
- Checklist integration;
- stable IDs;
- no duplicate gas identity corruption.

Output:

- Gas Role readiness %;
- Back Gas readiness %;
- Travel readiness %;
- Deco readiness %;
- Bailout readiness %;
- CCR Gas Role readiness % if present.

---

# PHASE 3D — MOD / DALTON / PPO2 AUDIT

Verify:

- MOD auto update;
- PPO2 step 0.1;
- no hidden 0.05 increments;
- Air lock;
- EAN O2-only edit;
- Trimix O2 + He edit;
- O2 100%;
- Dalton validation;
- active `PlannerEnvironment` used;
- displayed MOD == used MOD;
- switchDepthMeters clamped to MOD;
- user can choose shallower switch;
- user cannot persist deeper switch.

Verify consistency across:

- Planner gas card;
- Planner validation;
- Bühlmann preflight;
- Ratio Deco;
- GasPlanningService;
- export/share/PDF;
- checklist gas labels.

Mandatory example:

- O2 100%, PPO2 1.6 -> MOD about 6 m -> switch depth max about 6 m.

Output:

- MOD readiness %;
- Dalton/PPO2 readiness %;
- switch-depth clamp readiness %;
- environment consistency readiness %.

---


# PHASE 3E — EMERGENCY / ROCK BOTTOM READINESS AUDIT

Inspect all models, services, views, persistence and tests related to:

- Planner Emergency section;
- Rock Bottom;
- minimum gas;
- reserve gas;
- stressed RMV/SAC;
- team size / affected diver count;
- problem-solving time;
- ascent and stop gas;
- available gas;
- liters required;
- bar-equivalent display;
- insufficiency warnings.

Verify:

- ambient pressure calculation;
- maximum-depth reference;
- ascent-speed dependency;
- problem-solving time;
- stressed diver multiplier;
- stop/decompression inclusion policy;
- reserve separation;
- rounding direction;
- cylinder-volume conversion;
- liters-to-bar conversion;
- metric/imperial round trip;
- invalid/zero/negative/NaN/infinite guards;
- Base/Deco/Technical/CCR eligibility;
- export/PDF/briefing-card fidelity.

Critical invariants:

- Emergency/Rock Bottom gas is not merged into normal planned consumption.
- Technical average-depth gas mode must not reduce Rock Bottom unless explicitly and safely documented.
- Display-rounded bar values must never feed back into canonical liters.
- CCR bailout emergency gas must not silently reuse normal OC bottom-gas assumptions.

Output:

- Rock Bottom readiness %;
- emergency gas mathematical readiness %;
- emergency unit conversion readiness %;
- export consistency readiness %.

# PHASE 3F — ASCENT SPEED / DIVE RUNTIME / DECO STOP AUDIT

Inspect:

- global Planner ascent-speed settings;
- descent-speed assumptions;
- persistence and migration;
- `PlannerAscentTableBuilder`;
- `DecoStopsPresentationBuilder`;
- full Dive Runtime rows;
- route summary;
- total runtime / TTS / TTR consistency.

Verify:

- defaults and valid bounds;
- no zero/negative speed;
- transit time formula;
- runtime accumulation;
- correct phase ordering;
- descent, bottom, travel, gas switch, decompression stop and final ascent ordering;
- dedicated decompression-stop section exactly matches canonical Bühlmann/CCR schedule;
- presentation builders do not mutate or recompute canonical decompression results;
- ascent-speed changes propagate consistently to transit time and schedule-aware gas use;
- localization and formatting do not alter numeric values.

Output:

- ascent/descent speed readiness %;
- Dive Runtime readiness %;
- decompression-stop presentation truthfulness %;
- route-summary readiness %.

# PHASE 3G — SCHEDULE-AWARE GAS CONSUMPTION / GAS LEDGER AUDIT

Inspect:

- `GasPlanningService`;
- `PlannerGasSchedule`;
- `ScheduleGasConsumptionService`;
- `GasLedgerDisplayFormatter`;
- segment-to-gas-role mapping;
- liters and bar-equivalent presentation.

Verify:

- consumption integrates over correct depth/time segments;
- travel/back/deco/bailout/diluent roles are respected;
- switch depth and runtime are correct;
- ascent-speed settings affect transit gas coherently;
- bailout remains excluded from normal consumption unless an explicit bailout scenario is calculated;
- CCR diluent is not consumed as OC breathing gas during setpoint phases;
- liters remain canonical;
- bar is a cylinder-specific display equivalent;
- rounding is display-only;
- duplicate cylinder/gas aggregation is deterministic;
- insufficient-gas warnings compare compatible units.

Output:

- schedule-aware gas readiness %;
- gas ledger readiness %;
- reserve display readiness %;
- liters/bar conversion readiness %.

# PHASE 3H — TECHNICAL AVERAGE-DEPTH GAS TOGGLE AUDIT

Verify the Technical-mode option that allows average depth for gas-consumption estimation.

Mandatory rules:

- default remains conservative max-depth gas consumption;
- toggle affects gas consumption only;
- Bühlmann, decompression, MOD, PPO2, switch depth and Rock Bottom remain based on intended conservative inputs;
- average depth must be valid and <= max depth;
- hidden/stale state cannot affect Base, Deco or CCR;
- PDF/share/briefing cards disclose the chosen gas-consumption basis;
- persistence does not leak the toggle across unsupported modes.

Output:

- Technical average-depth gas readiness %;
- mode isolation readiness %;
- disclosure/export readiness %.

# PHASE 3I — REPETITIVE DIVE / RESIDUAL TISSUE AUDIT

Inspect `RepetitiveDivePlannerService` and all related tissue-state inputs, persistence and tests.

Verify:

- previous tissue-state source;
- chronology;
- surface interval;
- N2/He off-gassing;
- GF compatibility;
- fresh-tissue versus repetitive state;
- invalid/future/stale prior dive handling;
- deterministic repeated calculations;
- CCR/OC compatibility;
- export and UI disclosure;
- no silent fallback to fresh tissues.

Generate or inspect tests for short, medium and long surface intervals.

Output:

- repetitive-dive readiness %;
- residual-tissue integrity readiness %;
- disclosure/persistence readiness %.


# PHASE 4 — CCR / REBREATHER READINESS AUDIT

Search for CCR / Rebreather concepts:

- `CCR`
- `Rebreather`
- `Setpoint`
- `Diluent`
- `Loop`
- `Bailout`
- `Scrubber`
- `CO2`
- `OxygenCylinder`
- `O2Supply`
- `ClosedCircuit`
- `OC`
- `OpenCircuit`

If CCR is absent:

- mark CCR readiness as 0% / not implemented;
- list missing model families;
- provide implementation roadmap;
- do not treat absence as a bug unless current UI claims CCR support.

If CCR is partially present, audit:

## CCR Planner Model

- OC vs CCR planner mode separation;
- setpoint low/high;
- setpoint switch depth;
- diluent gas;
- bailout gas;
- oxygen supply;
- CCR depth/time profile;
- bailout scenario selection;
- CCR-specific gas role projection.

## CCR Bühlmann Integration

- tissues loaded from loop PPO2, not OC gas FO2;
- inert gas loading from diluent fraction under loop setpoint assumptions;
- inspired inert pressure correctly derived;
- setpoint changes during descent/bottom/ascent/stops;
- bailout OC schedule uses bailout gases and not CCR setpoint;
- no accidental reuse of OC gas calculations.

## CCR MOD / PPO2 / END

- diluent MOD;
- setpoint PPO2 limits;
- hypoxic diluent validation;
- diluent END/PPN2;
- bailout MOD;
- oxygen toxicity under setpoint.

## CCR Checklist Import / Export

Verify:

- checklist import maps diluent only to CCR diluent;
- checklist import maps bailout only to CCR bailout;
- cylinder size, pressure, mix and role survive round trip;
- duplicate prevention;
- validation of imported values;
- stale-value replacement rules;
- OC and CCR gas-role separation.

## CCR Bailout Scenario / Gas Density

Verify:

- `CCRBailoutScenarioCalculator` inputs and outputs;
- explicit CCR-to-OC bailout transition;
- bailout schedule separation from normal CCR schedule;
- required bailout gas in liters/bar;
- `CCRGasDensityEstimator`;
- gas composition and ambient-pressure assumptions;
- temperature assumptions;
- thresholds and warnings;
- display rounding does not change threshold classification;
- results are labelled estimates where environmental assumptions are incomplete.

## CCR Gas Consumption

- oxygen consumption model if present;
- diluent usage model if present;
- bailout gas plan if present;
- scrubber duration if present;
- CO2 warnings if present.

## CCR Output / Export

- CCR plan labelled as CCR;
- OC bailout plan separate;
- PDF/share identifies setpoint and diluent;
- CSV/logbook/manual dive fields preserve CCR mode;
- checklist includes CCR unit, scrubber, oxygen, diluent, bailout.

Output:

- CCR readiness %;
- CCR Bühlmann integration readiness %;
- CCR gas role readiness %;
- CCR exposure readiness %;
- CCR bailout readiness %;
- whether CCR is safe to show, hide, or keep as future work.

---

# PHASE 4B — TISSUE LOADING ANALYTICS AUDIT

Verify:

- 16 compartments;
- group 1–4;
- group 5–8;
- group 9–12;
- group 13–16;
- tissue timeline;
- runtime;
- depth;
- gas;
- PPO2;
- ceiling;
- controlling compartment if present;
- no fake data;
- no static chart;
- no illustrative chart presented as calculated.

Planner:

- simulated profile;
- Bühlmann output backed;
- Base/Deco/Technical visibility policy.

Logbook:

- recorded profile;
- imported profile;
- manual dive behavior;
- tissue chart only if enough model data exists.

CCR:

- tissue loading uses CCR setpoint/diluent if CCR implemented;
- otherwise CCR tissue readiness marked not implemented.

Output:

- Tissue readiness %;
- chart readiness %;
- Planner integration readiness %;
- Logbook integration readiness %;
- CCR tissue readiness %.

---

# PHASE 4C — NARCOTIC LOADING AUDIT

Verify:

- PPN2;
- END;
- EAD if present;
- active gas integration;
- runtime integration;
- gas switch integration;
- chart integration;
- export/share labels;
- unit conversion.

Planner:

- simulated profile;
- Base/Deco/Technical visibility;
- no fake static chart.

Logbook:

- recorded profile;
- imported profile;
- manual dive notes if no profile.

CCR:

- diluent-based END / PPN2 if CCR implemented;
- bailout END if bailout schedule exists;
- setpoint does not magically reduce narcotic inert gas exposure.

Output:

- Narcosis readiness %;
- END/PPN2 readiness %;
- chart readiness %;
- CCR narcotic readiness %.

---

# PHASE 5 — OXYGEN EXPOSURE / CNS / OTU AUDIT

Verify:

- CNS full-plan model;
- CNS descent+bottom subset if present;
- CNS ascent/deco estimate if present;
- OTU canonical formula;
- OTU monotonicity;
- high PPO2 finite guard;
- high PPO2 warning dominance;
- NOAA / exposure table limits if referenced;
- gas switch integration;
- Planner/export/share labels.

CCR-specific checks if implemented:

- CNS/OTU based on setpoint PPO2 over time;
- setpoint switch included;
- bailout switch changes PPO2 source;
- oxygen exposure not derived from diluent FO2 while CCR loop setpoint is active;
- high/low setpoint exposure segments separated if available.

Output:

- CNS readiness %;
- OTU readiness %;
- CCR oxygen exposure readiness %.

---

# PHASE 5B — PLANNER ↔ CHECKLIST AUDIT

Verify:

## Checklist → Planner

- Back Gas;
- Travel;
- Deco Stage;
- Bailout;
- CCR diluent / oxygen / bailout if present.

## Planner → Checklist

- deco gases;
- travel gases;
- bailout gases;
- CCR gases/equipment if present.

Verify:

- duplicate prevention;
- stable IDs;
- persistence;
- sync with gas roles;
- equipment/task generation;
- no accidental deletion of user checklist data;
- mode-aware behavior;
- structured Equipment setup mapping;
- operational checklist generation;
- CCR checklist import/export round trip;
- cylinder size, pressure, mix and role preservation;
- Equipment Setup PDF numerical fidelity.

Output:

- Planner Checklist readiness %;
- CCR Checklist readiness % if applicable.

---

# PHASE 6 — MANUAL DIVE / LOGBOOK AUDIT

Verify manual dive fields:

- max depth;
- average depth;
- GPS start;
- GPS end;
- dive profile;
- equipment;
- bar in;
- bar out;
- deco notes;
- gases;
- CCR mode / setpoint / diluent / bailout fields if present.

Verify integration:

- CSV export;
- logbook detail;
- tissue loading;
- narcotic loading;
- gas consumption;
- analysis dashboard;
- cloud merge;
- Watch sync if manual dive can be pushed.

Output:

- Manual Dive readiness %;
- Manual CCR dive readiness % if applicable.

---

# PHASE 6B — PDF / SHARE / EXPORT AUDIT

Verify:

## Planner PDF / Share

- briefing;
- active Planner mode;
- gas plan;
- deco plan;
- Bühlmann schedule;
- Ratio Deco;
- comparison;
- tissue summary if claimed;
- narcotic summary if claimed;
- CCR setpoint/diluent/bailout if claimed;
- reference-only disclaimer;
- Rock Bottom/emergency section if exposed;
- ascent/descent assumptions;
- full Dive Runtime;
- dedicated decompression stops;
- gas ledger liters/bar;
- repetitive-dive status;
- Technical average-depth gas basis if enabled.

## Planner briefing card / PNG to Apple Watch

Verify:

- `PlannerBriefingCard` canonical values;
- rendered PNG/card text;
- structured metadata versus rendered content;
- units and localization;
- version/staleness handling;
- transfer status and failure handling;
- Watch-side reception/persistence;
- explicit reference-only semantics;
- no implication of live decompression guidance;
- no stale card overwriting newer plan data.

## Checklist PDF

- YES/NO boxes;
- equipment;
- tasks;
- gases;
- CCR equipment/tasks if present.

Verify share targets:

- WhatsApp;
- Mail;
- AirDrop;
- Files.

Verify:

- no certified-plan wording;
- no stale data;
- no hidden Technical gas leaking into Base/Deco export;
- CNS labels are unambiguous.

Output:

- PDF readiness %;
- Share readiness %;
- CCR export readiness %.

---

# PHASE 6C — CSV / SUBSURFACE EXPORT AUDIT

Verify:

- exported columns;
- metric policy;
- time base;
- sample rows;
- temperature optionality;
- GPS metadata;
- gas fields if supported;
- CCR fields if supported;
- manual/no-profile behavior;
- imported profile round-trip;
- duplicate session prevention;
- external Subsurface validation status.

Do not claim Subsurface validation unless actually executed.

Output:

- CSV readiness %;
- Subsurface readiness %;
- CCR CSV readiness % if applicable.

---

# PHASE 7 — UNIT CONVERSION AUDIT

Verify:

- meters ↔ feet;
- bar ↔ psi;
- Celsius ↔ Fahrenheit;
- liters ↔ cubic feet if present;
- m/min ↔ ft/min;
- MOD display;
- switch depth display;
- Planner;
- Charts;
- Tissue;
- Narcosis;
- Logbook;
- PDF;
- CSV;
- CCR setpoint remains PPO2 bar and is not converted as pressure tank units;
- Rock Bottom liters ↔ bar equivalent;
- cylinder-volume-dependent pressure display;
- ascent/descent speeds;
- gas ledger liters/bar;
- briefing card values.

Output:

- Unit Conversion readiness %;
- CCR unit readiness %.

---

# PHASE 8 — CLOUD / SYNC / DATA INTEGRITY AUDIT

Verify:

- divergent profile conflict detection;
- duplicate session ID safety;
- tombstone policy;
- cloud KVS payload size cap;
- opt-in backup if implemented;
- manual dive preservation;
- gas role preservation;
- Planner export/import preservation;
- CCR fields preserved if present;
- Watch sync payloads do not corrupt iOS algorithm data;
- no hybrid profile sample merge;
- ascent-speed settings persistence;
- emergency/Rock Bottom settings persistence;
- Technical average-depth toggle persistence;
- repetitive-dive metadata and tissue-source persistence;
- structured Equipment numerical values;
- CCR checklist role persistence;
- Planner briefing-card versioning and transfer integrity.

Output:

- Cloud readiness %;
- Sync data integrity readiness %;
- CCR persistence readiness % if applicable.

---

# PHASE 9 — TEST COVERAGE AUDIT

Inspect:

- `Tests/iOSAlgorithmTests/*`
- relevant test fixtures
- docs describing manual QA

Report missing tests for:

- Bühlmann core;
- Planner modes;
- mode projection;
- MOD/PPO2/switch depth;
- Ratio Deco;
- tissue loading;
- narcotic loading;
- CCR setpoint/diluent/bailout if present;
- gas role projections;
- checklist sync;
- manual dive;
- PDF/share;
- CSV/Subsurface;
- cloud conflicts;
- unit conversion;
- performance boundaries;
- Rock Bottom reference vectors;
- ascent/descent transit timing;
- runtime ordering;
- deco-stop table equivalence;
- schedule-aware gas consumption;
- liters/bar conversion;
- Technical average-depth toggle isolation;
- repetitive-dive residual tissues;
- structured Equipment mappings;
- CCR checklist round trip;
- CCR bailout scenario;
- CCR gas density;
- Planner briefing-card encode/render/transfer/receive.

Output:

- automated test readiness %;
- manual QA readiness %;
- external validation readiness %.

---

# PHASE 9B — RELEASE HARD MATRIX UPDATE

Provide readiness percentages:

| Feature | Readiness |
|---|---:|
| Bühlmann | XX% |
| Planner Base/Deco/Technical | XX% |
| CCR / Rebreather | XX% |
| Ratio Deco | XX% |
| Gas Roles | XX% |
| Emergency / Rock Bottom | XX% |
| Ascent / Descent Transit Timing | XX% |
| Dive Runtime / Deco Stops | XX% |
| Schedule-Aware Gas Consumption | XX% |
| Gas Ledger / Reserve Display | XX% |
| Technical Average-Depth Gas Toggle | XX% |
| Repetitive Dive / Residual Tissues | XX% |
| MOD/PPO2/Dalton | XX% |
| Switch Depth Clamp | XX% |
| Tissue Loading | XX% |
| Narcosis / END / PPN2 | XX% |
| CNS / OTU | XX% |
| Checklist Sync | XX% |
| Structured Equipment Mapping | XX% |
| CCR Checklist Import / Export | XX% |
| CCR Bailout Scenario | XX% |
| CCR Gas Density | XX% |
| Manual Dive | XX% |
| PDF / Share Export | XX% |
| Planner Briefing Card / Watch Transfer | XX% |
| CSV / Subsurface | XX% |
| Unit Conversion | XX% |
| Cloud / Sync Integrity | XX% |
| Test Coverage | XX% |
| Overall | XX% |

Each percentage must include evidence and blockers.

---

# PHASE 10 — STATIC TOOLING / SCAN SUGGESTIONS

If tools are available, run or suggest:

- xcodebuild warnings;
- Swift compiler warnings;
- SwiftLint if configured;
- grep for force unwraps:
  - `!`
  - `try!`
  - `as!`
- grep for unsafe dictionary constructors:
  - `Dictionary(uniqueKeysWithValues:)`
- grep for hardcoded secrets;
- grep for TODO/FIXME in MAIN;
- grep for hardcoded user-facing strings;
- grep for `.onChange` patterns that mutate observed state;
- grep for `DispatchQueue.main.asyncAfter`;
- grep for file delete/write paths;
- grep for:
  - `CCR`
  - `Rebreather`
  - `Setpoint`
  - `Diluent`
  - `Loop`
  - `RatioDeco`
  - `TissueLoading`
  - `Narcotic`
  - `PPN2`
  - `switchDepthMeters`
  - `PlannerMODValidator`
  - `modMeters`
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

Do not fix. Record findings.

---

# PHASE 11 — ISSUE CLASSIFICATION

For every issue, classify:

## Severity

- CRITICAL
- HIGH
- MEDIUM
- LOW
- INFO

## Priority

- P0 — must fix before compile/use
- P1 — must fix before internal TestFlight
- P2 — must fix before external TestFlight
- P3 — must fix before App Store
- P4 — post-release optimization

## Area

- Bühlmann core
- CCR / Rebreather
- Ratio Deco
- Tissue Loading
- Narcotic Loading
- MOD/PPO2/Dalton
- Gas Roles
- Planner modes
- Switch Depth Clamp
- Oxygen Exposure
- Checklist Sync
- Manual Dive
- PDF / Share
- CSV / Subsurface
- Unit Conversion
- Cloud / Sync
- Persistence
- UI-state logic
- Localization
- Tests
- Docs
- External QA
- Emergency / Rock Bottom
- Transit Timing
- Dive Runtime / Deco Stops
- Schedule-Aware Gas Consumption
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Planner Briefing Card

For each issue include:

- ID
- title
- area
- file/function
- description
- evidence from code
- user impact
- safety impact
- mathematical impact
- security/privacy impact if any
- performance impact if any
- proposed solution
- estimated effort
- regression risk
- tests required
- priority
- dependencies
- acceptance criteria

---

# PHASE 12 — REPORT REQUIRED

Create:

`Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`

The report must contain:

## A. Executive Summary

- overall readiness %;
- Bühlmann readiness %;
- CCR readiness %;
- Planner readiness %;
- Ratio Deco readiness %;
- MOD/PPO2 readiness %;
- Tissue readiness %;
- Narcosis readiness %;
- Checklist readiness %;
- Manual Dive readiness %;
- PDF/export readiness %;
- Unit conversion readiness %;
- critical blockers;
- TestFlight blockers;
- App Store blockers.

## B. Scope Confirmation

- branch;
- commit;
- iOS target;
- experimental exclusions;
- build/test results;
- docs found / missing.

## C. Architecture Inventory

- files inspected;
- implemented components;
- unreachable components;
- test coverage.

## D. Bühlmann Core Audit

## E. Planner Base / Deco / Technical Audit

## F. CCR / Rebreather Audit

## G. Ratio Deco Audit

## H. Gas Role Audit

## I. MOD / PPO2 / Dalton / Switch Depth Audit

## J. Emergency / Rock Bottom Audit

## K. Ascent Speed / Dive Runtime / Deco Stops Audit

## L. Schedule-Aware Gas Consumption / Gas Ledger Audit

## M. Technical Average-Depth Gas Toggle Audit

## N. Repetitive Dive / Residual Tissue Audit

## O. Tissue Loading Audit

## P. Narcotic Loading Audit

## Q. CNS / OTU Audit

## R. Planner ↔ Checklist / Structured Equipment Audit

## S. Manual Dive / Logbook Audit

## T. PDF / Share / Briefing Card / CSV / Subsurface Audit

## U. Unit Conversion Audit

## V. Cloud / Sync / Persistence Audit

## W. Test Coverage Audit

## X. Release Hard Matrix

Mandatory table:

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | XX% | ... | ... |
| Planner Base/Deco/Technical | XX% | ... | ... |
| CCR / Rebreather | XX% | ... | ... |
| Ratio Deco | XX% | ... | ... |
| Gas Roles | XX% |
| Emergency / Rock Bottom | XX% |
| Ascent / Descent Transit Timing | XX% |
| Dive Runtime / Deco Stops | XX% |
| Schedule-Aware Gas Consumption | XX% |
| Gas Ledger / Reserve Display | XX% |
| Technical Average-Depth Gas Toggle | XX% |
| Repetitive Dive / Residual Tissues | XX% | ... | ... |
| MOD/PPO2/Dalton | XX% | ... | ... |
| Switch Depth Clamp | XX% | ... | ... |
| Tissue Loading | XX% | ... | ... |
| Narcosis | XX% | ... | ... |
| CNS/OTU | XX% | ... | ... |
| Checklist Sync | XX% |
| Structured Equipment Mapping | XX% |
| CCR Checklist Import / Export | XX% |
| CCR Bailout Scenario | XX% |
| CCR Gas Density | XX% | ... | ... |
| Manual Dive | XX% | ... | ... |
| PDF Export | XX% | ... | ... |
| Planner Briefing Card / Watch Transfer | XX% | ... | ... |
| CSV/Subsurface | XX% | ... | ... |
| Unit Conversion | XX% | ... | ... |
| Cloud/Sync | XX% | ... | ... |
| Overall | XX% | ... | ... |

## Y. Detailed Action Plan

Grouped by:

1. P0
2. P1
3. P2
4. P3
5. P4

For every action:

- issue IDs addressed;
- files likely involved;
- implementation order;
- risk;
- tests required;
- acceptance criteria.

## Z. 7-Day / 14-Day Readiness Plan

## AA. Recommended Cursor Remediation Commands

Draft separate future commands:

1. Bühlmann core remediation;
2. CCR / Rebreather implementation or hardening;
3. Ratio Deco remediation;
4. MOD/PPO2/switch-depth remediation;
5. Tissue/Narcosis analytics remediation;
6. Checklist/PDF/manual-dive/export remediation;
7. Unit conversion and test coverage remediation.

Do not execute them.

## AB. Final Verdict

Answer clearly:

- Is Bühlmann ready?
- Is the Planner ready?
- Is CCR implemented, partial, or absent?
- Is CCR safe to expose?
- Is Ratio Deco ready?
- Is tissue loading real/model-backed?
- Is narcotic loading real/model-backed?
- Are MOD/PPO2 and switch-depth rules consistent?
- Are manual dives integrated?
- Are exports reliable?
- Is it safe for internal TestFlight?
- Is it safe for external TestFlight?
- Is it ready for App Store?
- Are Rock Bottom/emergency gas calculations conservative and correct?
- Are ascent/descent speeds and runtime totals coherent?
- Does the dedicated deco-stop section match the canonical schedule?
- Is schedule-aware gas consumption correct by segment and role?
- Is the Technical average-depth toggle isolated to gas estimation?
- Are repetitive-dive residual tissues coherent and explicit?
- Are gas ledger liters/bar values truthful?
- Are structured Equipment mappings safe?
- Does CCR checklist import/export preserve roles?
- Are CCR bailout and gas-density estimates traceable?
- Are Planner briefing cards numerically faithful and reference-only?
- What blocks 100% readiness?
- What must be fixed first?

---

# PHASE 13 — VALIDATION

After creating the report, verify:

- report file exists;
- report is not empty;
- issue matrix exists;
- Release Hard Matrix exists;
- action plan exists;
- no source code modified;
- git status only shows the new report file, unless build artifacts were generated;
- no experimental files touched.

If build/test commands were run:

- include exact commands and results;
- include failure summaries;
- do not claim pass unless they passed.

---

# SUCCESS CRITERIA

The task is complete only if:

- no production source code is modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- no security model is modified;
- report is created at:

`Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_CURRENT.md`

- report includes:
  - Bühlmann core audit;
  - CCR / Rebreather audit;
  - Ratio Deco audit;
  - Gas Role audit;
  - MOD/PPO2/Dalton audit;
  - Switch Depth Clamp audit;
  - Tissue Loading audit;
  - Narcotic Loading audit;
  - Planner ↔ Checklist audit;
  - Manual Dive audit;
  - PDF / Share audit;
  - CSV / Subsurface audit;
  - Unit Conversion audit;
  - Release Hard Matrix;
  - detailed action plan;
  - 7-day / 14-day roadmap;
  - future remediation command drafts.

- all physical/external QA items are marked as pending, not passed;
- final git status confirms only report/docs changed;
- latest MAIN implementations are explicitly audited;
- canonical algorithms are distinguished from presentation builders;
- Rock Bottom, transit timing, runtime/deco-stop presentation, gas ledger, repetitive dive and briefing-card transfer are covered;
- structured Equipment and CCR checklist round-trip are covered;
- no readiness score is assigned without file/function/test evidence.

If anything cannot be fully analyzed:

- document the limitation;
- explain why;
- propose the exact next inspection step.


---

# VERSION HISTORY

## V3.0 — 2026-06-19

Updated for the current `main` implementation state.

Added explicit audit coverage for:

- Planner Emergency / Rock Bottom;
- Planner ascent-speed settings;
- complete Dive Runtime presentation;
- dedicated decompression-stop section;
- schedule-aware gas consumption;
- gas ledger and reserve display in liters/bar;
- Technical average-depth gas-consumption toggle;
- repetitive-dive planning and residual tissues;
- route-summary and plan-completeness/result-state gating;
- structured Equipment setup and operational checklist;
- CCR checklist import/export;
- CCR bailout scenario calculator;
- CCR gas-density estimator;
- Planner briefing card / PNG export to Apple Watch;
- Watch-side briefing-card reception, persistence and reference-only semantics.

Preserved:

- `1-` prefix and audit-sequence position;
- iOS MAIN-only scope;
- audit-only behavior;
- no code, UI, business-logic or algorithm modification;
- current Base / Deco / Technical / CCR / Ratio Deco logic;
- non-certified and reference-only product positioning;
- external/physical validation gates as pending unless evidenced.

---

# V3.0 FULL COMPUTER BÜHLMANN EXPANSION

The iOS Bühlmann audit must now verify parity with the Apple Watch Full Computer runtime.

Audit:

- one-second multilevel tissue updates;
- Schreiner iterative integration;
- NDL → TTS/Ceiling transition;
- operational versus raw ceiling;
- active stop and next stop;
- stop timer pause thresholds;
- stop reset when the diver descends beyond the approved threshold;
- gas-switch confirmed/ignored/lost behavior;
- recalculation from the gas actually active;
- tissue checkpoints;
- Watch ↔ iOS replay fidelity;
- Diving Logbook profile overlays;
- no Full Computer data leakage into Apnea/Snorkeling.

Report iOS planner vs Watch runtime parity separately.
