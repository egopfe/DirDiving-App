# CURSOR / CODEX COMMAND — 1-DIR DIVING iOS BÜHLMANN COMPREHENSIVE READINESS AUDIT UPDATED WITH CCR / REBREATHER

You are working on the DIR DIVING repository.

## TARGET

ONLY branch `main`.

## TARGET APP

ONLY iOS Companion MAIN target:

- `DIRDiving iOS`

## AUDIT PRIORITY ORDER

This is the **first audit command** to run after every meaningful Planner / algorithm / gas / CCR / Ratio Deco / export / checklist / logbook change.

The filename intentionally starts with `1-` because this audit is the first readiness gate before any follow-up remediation command:

`Docs/1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`

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

If any document is missing, note it in the final report. Do not invent evidence from missing files.

---

# OBJECTIVE

Perform a complete and deep **iOS Bühlmann algorithm completeness and functionality readiness audit** covering the Planner, decompression engine, gas model, CCR / rebreather extension readiness, Ratio Deco, tissue loading, narcotic loading, MOD/PPO2/Dalton validation, gas roles, checklist sync, manual dive integration, PDF/share export, CSV import/export, unit conversion and release-hard readiness matrix.

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
10. What must be fixed first, without changing the product logic already implemented?

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

## Bühlmann / gas / exposure

- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
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
14. Release-hard matrix

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
- full gas ledger and bailout separation.

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
- mode-aware behavior.

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
- reference-only disclaimer.

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
- CCR setpoint remains PPO2 bar and is not converted as pressure tank units.

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
- no hybrid profile sample merge.

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
- performance boundaries.

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
| MOD/PPO2/Dalton | XX% |
| Switch Depth Clamp | XX% |
| Tissue Loading | XX% |
| Narcosis / END / PPN2 | XX% |
| CNS / OTU | XX% |
| Checklist Sync | XX% |
| Manual Dive | XX% |
| PDF / Share Export | XX% |
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

## J. Tissue Loading Audit

## K. Narcotic Loading Audit

## L. CNS / OTU Audit

## M. Planner ↔ Checklist Audit

## N. Manual Dive / Logbook Audit

## O. PDF / Share / CSV / Subsurface Audit

## P. Unit Conversion Audit

## Q. Cloud / Sync / Persistence Audit

## R. Test Coverage Audit

## S. Release Hard Matrix

Mandatory table:

| Feature | Readiness | Blockers | Priority |
|---|---:|---|---|
| Bühlmann | XX% | ... | ... |
| Planner Base/Deco/Technical | XX% | ... | ... |
| CCR / Rebreather | XX% | ... | ... |
| Ratio Deco | XX% | ... | ... |
| Gas Roles | XX% | ... | ... |
| MOD/PPO2/Dalton | XX% | ... | ... |
| Switch Depth Clamp | XX% | ... | ... |
| Tissue Loading | XX% | ... | ... |
| Narcosis | XX% | ... | ... |
| CNS/OTU | XX% | ... | ... |
| Checklist Sync | XX% | ... | ... |
| Manual Dive | XX% | ... | ... |
| PDF Export | XX% | ... | ... |
| CSV/Subsurface | XX% | ... | ... |
| Unit Conversion | XX% | ... | ... |
| Cloud/Sync | XX% | ... | ... |
| Overall | XX% | ... | ... |

## T. Detailed Action Plan

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

## U. 7-Day / 14-Day Readiness Plan

## V. Recommended Cursor Remediation Commands

Draft separate future commands:

1. Bühlmann core remediation;
2. CCR / Rebreather implementation or hardening;
3. Ratio Deco remediation;
4. MOD/PPO2/switch-depth remediation;
5. Tissue/Narcosis analytics remediation;
6. Checklist/PDF/manual-dive/export remediation;
7. Unit conversion and test coverage remediation.

Do not execute them.

## W. Final Verdict

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
- final git status confirms only report/docs changed.

If anything cannot be fully analyzed:

- document the limitation;
- explain why;
- propose the exact next inspection step.
