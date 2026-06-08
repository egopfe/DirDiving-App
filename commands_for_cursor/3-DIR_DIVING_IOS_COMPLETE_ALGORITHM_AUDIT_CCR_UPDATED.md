# 3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED

## CURSOR / CODEX COMMAND — DIR DIVING iOS COMPLETE ALGORITHM AUDIT UPDATED WITH CCR / REBREATHER & CO.

You are working on the DIR DIVING repository.

TARGET:
ONLY branch `main`.

TARGET APP:
ONLY iOS Companion MAIN target:
- DIRDiving iOS

TASK TYPE:
COMPLETE ALGORITHM / MATH / PLANNER READINESS AUDIT ONLY.

DO NOT MODIFY CODE.
DO NOT REFACTOR.
DO NOT FIX ISSUES.
DO NOT CHANGE UI.
DO NOT CHANGE BUSINESS LOGIC.
DO NOT CHANGE ALGORITHMS.
DO NOT CHANGE SECURITY MODEL.
DO NOT CHANGE SYNC MODEL.
DO NOT CHANGE PLANNER MODE LOGIC.

SOURCE / BASE COMMAND:
This command updates and extends:

`3-CHECK_MATH_IOS_DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_COMMAND_v2.md`

The original command extended the Check_Math_iOS audit with:
- Ratio Deco
- Tissue & Narcosis
- MOD / Dalton validation
- Gas roles
- Planner ↔ Checklist integration
- PDF / Share validation
- Manual Dive validation
- Unit conversion validation
- Release-hard readiness matrix

This updated version keeps that structure and adds the latest CCR / Rebreather & Co. audit scope.

OUTPUT:
Create one consolidated Markdown report:

`Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

The report must merge:
- original Check_Math_iOS findings;
- all v2 extension phases;
- CCR / Rebreather readiness phases;
- OC vs CCR gas-planning differences;
- Bühlmann OC/CCR consistency;
- bailout integration;
- unit conversion;
- PDF/share/export;
- complete release-hard readiness matrix.

---

# ABSOLUTE RULES

DO NOT:
- touch Apple Watch runtime code;
- touch experimental branches;
- touch Apnea experimental;
- touch Snorkeling experimental;
- touch Buddy Assist experimental;
- touch Exploration Lab;
- modify files excluded from `project.yml`;
- apply patches;
- auto-fix issues;
- change UI graphics;
- redesign UX;
- change app visual identity;
- change iOS Bühlmann core math;
- change Ratio Deco math;
- change CCR assumptions;
- change gas-planning logic;
- change cloud merge logic;
- change WatchConnectivity trust model;
- weaken legal/safety disclaimers;
- introduce certified dive-computer claims;
- introduce certified decompression-planner claims;
- claim CCR support is validated unless verified by code/tests;
- claim external planner validation passed unless actually executed;
- claim physical QA passed unless actually executed.

PRESERVE:
- iOS MAIN only;
- iOS dark marine/cyan UI;
- iOS Planner as reference-only;
- non-certified diving companion positioning;
- Base / Deco / Technical planner architecture;
- mode-specific input projection;
- mode-specific result gating;
- MOD/PPO2/switch-depth safety;
- PlannerEnvironment-aware MOD calculations;
- gas role semantics;
- metric internal storage;
- manual/no-depth truthfulness;
- cloud backup opt-in if implemented;
- sync HMAC/peer-secret trust model;
- tombstone/conflict policy;
- physical and external QA gates as pending unless executed.

IMPORTANT:
CCR / Rebreather features must be audited as planning/reference features only.
Do not allow the report to imply that DIR DIVING becomes a certified CCR controller, life-support system, dive computer, or certified decompression planner.

---

# CURRENT DEVELOPMENT CONTEXT TO RESPECT

The current iOS Companion algorithm scope includes or may include:

## Planner modes
- Base
- Deco
- Technical

These modes must be real, not decorative. They must affect:
- visible inputs;
- active gas set;
- validation rules;
- calculation input projection;
- result sections;
- Bühlmann display level;
- warning scope;
- export/share output;
- accessibility summaries;
- localization.

## Open Circuit / Technical planning
- Bühlmann ZHL-16C;
- Gradient Factors;
- multigas planning;
- gas roles: Back Gas / Travel / Deco / Bailout;
- MOD / PPO2 / Dalton validation;
- switch-depth clamp to MOD;
- Ratio Deco comparison;
- Tissue Loading;
- Narcotic Loading / END;
- Planner ↔ Checklist sync;
- Manual Dive;
- PDF / Share;
- CSV / Subsurface;
- Unit conversion.

## New CCR / Rebreather & Co. scope
Audit whether the iOS Planner architecture correctly supports, or clearly does not yet support:
- circuit type selection:
  - Open Circuit (OC);
  - Closed Circuit Rebreather (CCR);
  - Semi-Closed Circuit Rebreather (SCR), only if implemented or referenced;
- CCR setpoint model:
  - low setpoint;
  - high setpoint;
  - setpoint switch depth/time;
  - constant PPO2 planning;
  - manual setpoint override if implemented;
- diluent gas:
  - oxygen fraction;
  - helium fraction;
  - nitrogen balance;
  - MOD / MND / hypoxic validation;
  - diluent PO2 at depth;
  - diluent END/EAD;
- bailout gases:
  - OC bailout gas roles;
  - bailout gas quantities;
  - bailout switch depths;
  - bailout ascent/deco schedule;
  - bailout CNS/OTU implications;
- oxygen exposure:
  - CCR setpoint-driven CNS/OTU;
  - OC gas-driven CNS/OTU;
  - high PPO2 warning dominance;
- tissue loading:
  - CCR constant setpoint inert loading;
  - OC multigas inert loading;
  - correct N2/He partial pressures;
- narcotic loading:
  - diluent-based narcotic gas effect;
  - active breathing loop assumptions;
  - bailout narcotic loading;
- gas consumption:
  - OC RMV/SAC schedule gas consumption;
  - CCR O2 metabolic consumption if implemented;
  - diluent usage if implemented;
  - bailout OC consumption;
  - scrubber duration if implemented or explicitly not implemented;
- planner outputs:
  - OC plan;
  - CCR plan;
  - bailout plan;
  - comparison view if implemented;
  - PDF/share/export labels;
- safety disclaimers:
  - CCR planning is reference-only;
  - not a life-support controller;
  - not a certified decompression plan;
  - verify with certified CCR computer/tables/training.

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

5. Inspect `project.yml` and confirm:
   - target: `DIRDiving iOS`;
   - test target: `DIRDiving iOS Algorithm Tests`;
   - experimental files excluded;
   - Apple Watch runtime out of scope.

6. Confirm iOS experimental exclusions:
   - `iOSApp/Models/ExplorationModels.swift`
   - `iOSApp/Models/BuddyExperimentalModels.swift`
   - `iOSApp/Services/ExplorationPlanningStore.swift`
   - `iOSApp/Services/BuddyExperimentalStore.swift`
   - `iOSApp/Views/ExplorationCenterView.swift`
   - `iOSApp/Views/ExperimentalFutureConceptsView.swift`
   - `iOSApp/Views/BuddyExperimentalView.swift`

7. Run if environment allows:

   ```bash
   xcodegen generate

   xcodebuild -scheme "DIRDiving iOS" \
     -destination 'generic/platform=iOS Simulator' \
     CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

   xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
   ```

8. Do not fix build/test failures. Record them.

9. Before auditing, print:
   - branch;
   - commit;
   - dirty files;
   - iOS target membership;
   - experimental exclusions;
   - build status;
   - test status;
   - files/directories to inspect.

STOP if branch is not `main`.

---

# PHASE 1 — ORIGINAL CHECK_MATH_iOS AUDIT

Execute the original Check_Math_iOS audit in full.

The audit must cover:
- all iOS Companion mathematical functions;
- all Planner calculations;
- all Bühlmann calculations;
- all gas calculations;
- all CNS/OTU calculations;
- all MOD/PPO2 calculations;
- all unit conversions;
- all logbook/statistics calculations;
- all CSV/PDF/export calculations;
- all import/export numerical transformations;
- all sync/cloud numerical transformations.

Output:
- Original iOS algorithm readiness %
- Original blockers
- Original TestFlight blockers
- Original App Store blockers

---

# PHASE 2 — BÜHLMANN CORE READINESS AUDIT

Inspect:
- `iOSApp/Algorithms/Buhlmann/BuhlmannEngine.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannGas.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannPlanPreflightValidator.swift`
- `iOSApp/Algorithms/Buhlmann/BuhlmannTissueHistory.swift`
- `iOSApp/Services/BuhlmannPlanner.swift`
- related tests in `Tests/iOSAlgorithmTests`

Verify:
- ZHL-16C compartment constants;
- N2 and He half-times;
- a/b coefficients;
- tissue initialization;
- surface pressure handling;
- descent/ascent segment integration;
- stop generation;
- GF low/high behavior;
- ceiling calculation;
- no-decompression limit behavior;
- multigas behavior;
- OC plan consistency;
- CCR constant PPO2 behavior if implemented;
- bailout fallback behavior if implemented;
- finite guards for invalid input;
- deterministic output;
- no fake/static Bühlmann output.

Output:
- Bühlmann readiness %
- Bühlmann blockers
- CCR compatibility note

---

# PHASE 2B — RATIO DECO ENGINE AUDIT

Inspect:
- `RatioDecoPlanner`
- `RatioDecoValidator`
- `RatioDecoPreset`
- `RatioDecoSchedule`
- comparison/overlay chart services/views
- PDF/share integration

Verify:
- Ratio Deco is heuristic only;
- Bühlmann remains primary reference layer;
- Ratio Deco never overrides safety-critical Bühlmann warnings;
- presets 1:1 / 2:1 / Custom;
- first stop logic;
- stop step logic;
- deep stop option if implemented;
- MOD validation;
- PPO2 validation;
- gas validation;
- ceiling validation;
- comparison mode;
- overlay chart;
- PDF integration;
- localization.

CCR-specific:
- Verify Ratio Deco is either explicitly OC-only, or clearly supports CCR with documented limits.
- If CCR Ratio Deco is not implemented, report it as unsupported/not applicable, not as a hidden feature.
- Ensure no CCR plan silently uses OC Ratio Deco assumptions.

Output:
- Ratio Deco readiness %
- CCR Ratio Deco readiness / not-supported status

---

# PHASE 2C — TISSUE & NARCOSIS ENGINE AUDIT

Inspect:
- `TissueAnalyticsTrace`
- `TissueAnalyticsSample`
- `TissueCompartmentLoading`
- `TissueTimelineGenerator`
- `NarcoticLoadingService`
- planner/logbook chart integration

Verify:
- 16 compartments;
- N2 loading;
- He loading;
- total inert loading;
- controlling compartment;
- GF-relative loading;
- M-value-relative loading;
- tissue timeline;
- runtime;
- depth;
- active gas;
- PPO2;
- PPN2;
- END;
- no fake/static chart data;
- model-backed planner integration;
- model-backed logbook integration.

CCR-specific:
- Tissue loading must use inert gas partial pressures consistent with CCR setpoint/diluent model.
- PPO2 is setpoint-driven in CCR, not simply gas FO2 × ambient pressure.
- Inert fraction must derive from diluent / loop model according to actual implementation.
- Bailout must switch to OC gas model.
- Narcotic loading must distinguish:
  - OC active gas;
  - CCR diluent/loop assumptions;
  - bailout gas.
- If CCR tissue/narcosis is not implemented, report it clearly as missing or not yet integrated.

Output:
- Tissue readiness %
- Narcosis readiness %
- CCR tissue readiness %
- CCR narcosis readiness %

---

# PHASE 3 — GAS PLANNING READINESS AUDIT

Inspect:
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/GasPlanningService.swift`
- `iOSApp/Services/PlannerGasSchedule.swift`
- `iOSApp/Services/ScheduleGasConsumptionService.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/GasMixValidator.swift`

Verify:
- Back Gas;
- Travel;
- Decompression;
- Bailout;
- gas role identities;
- stable IDs;
- mode-specific gas projection;
- gas ledger;
- schedule consumption;
- unused planned gas;
- standby/bailout gas;
- planner integration;
- checklist integration;
- PDF integration.

CCR-specific:
Verify whether models support:
- circuit type: OC / CCR / SCR if present;
- diluent gas;
- oxygen setpoint;
- setpoint changes;
- oxygen supply;
- bailout OC gases;
- scrubber duration if present;
- CNS/OTU exposure based on setpoint;
- inert loading based on CCR model;
- gas consumption:
  - OC RMV;
  - CCR oxygen metabolic consumption if implemented;
  - diluent usage if implemented;
  - bailout OC RMV;
- emergency bailout ascent plan.

If these are not present, report:
- missing model fields;
- missing validation;
- missing UI exposure;
- missing tests;
- whether CCR is currently unsupported, partial, or unsafe to expose.

Output:
- Gas Planning readiness %
- Gas Role readiness %
- CCR Gas Planning readiness %
- Bailout readiness %

---

# PHASE 3B — MOD / DALTON VALIDATION AUDIT

Inspect:
- `iOSApp/Services/PlannerMODValidator.swift`
- `iOSApp/Utils/PlannerInputValidator.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- related tests

Verify:
- MOD auto recalculation;
- PPO2 step exactly 0.1;
- no hidden 0.05 increments;
- Air lock;
- EAN edits O2 only;
- Trimix edits O2 + He;
- O2 locks 100%;
- displayed MOD == used MOD;
- planner uses same MOD;
- Bühlmann uses same gas;
- Ratio Deco uses same gas;
- switchDepthMeters clamp to MOD;
- user can choose shallower switch depth;
- user cannot persist switch depth deeper than MOD;
- PlannerEnvironment altitude/salinity respected.

CCR-specific:
- Diluent MOD / maximum operating depth validation;
- hypoxic diluent minimum operating depth validation;
- diluent PO2 at max depth;
- bailout gas MOD validation;
- setpoint PPO2 limits;
- setpoint switch-depth validation;
- high setpoint warning if out of range;
- oxygen toxicity warnings for CCR setpoint;
- Dalton consistency between setpoint, diluent, inert fractions and ambient pressure.

Output:
- MOD/PPO2 readiness %
- Dalton readiness %
- CCR MOD/Dalton readiness %

---

# PHASE 4 — PLANNER MODE ARCHITECTURE AUDIT

Audit Base / Deco / Technical.

Verify:
- modes are real, not decorative;
- visible inputs match mode;
- active gas set matches mode;
- hidden gases do not affect simpler modes;
- mode switching preserves advanced data;
- calculation uses active projection;
- result sections match mode;
- Bühlmann display matches mode;
- export/share includes active mode label if implemented.

CCR-specific:
- CCR should only be available in the correct mode, preferably Technical.
- Base should not expose CCR.
- Deco should not silently use CCR unless explicitly designed.
- Technical should expose CCR inputs only if validation and algorithm support are ready.
- If CCR UI exists but engine support is incomplete, flag as HIGH or CRITICAL depending on exposure.

Output:
- Planner Mode readiness %
- CCR mode-integration readiness %

---

# PHASE 5 — PLANNER ↔ CHECKLIST AUDIT

Inspect:
- checklist stores/models;
- equipment profiles;
- gas checklist sync;
- planner gas IDs;
- template logic;
- PDF checklist export.

Verify:
- REC templates;
- TEC templates;
- Custom templates;
- Checklist → Planner;
- Planner → Checklist;
- Back Gas;
- Deco Stage;
- Travel;
- Bailout;
- duplicate prevention;
- stable IDs;
- persistence.

CCR-specific:
Verify checklist support for:
- CCR unit;
- loop check;
- oxygen cell calibration;
- oxygen supply;
- diluent supply;
- bailout cylinders;
- scrubber duration;
- handset/controller if modeled;
- pre-breathe reminder if modeled;
- CCR-specific tasks;
- PDF checklist output;
- Planner ↔ Checklist sync for CCR gas requirements.

If missing, classify:
- unsupported;
- partial;
- required before CCR public exposure.

Output:
- Checklist readiness %
- Planner Sync readiness %
- CCR Checklist readiness %

---

# PHASE 6 — MANUAL DIVE AUDIT

Inspect:
- `ManualDiveEditorView`
- manual dive models
- pressure display math
- logbook integration
- analysis integration
- tissue/narcosis integration
- CSV export

Verify:
- max depth;
- average depth;
- GPS start/end;
- equipment;
- bar in/out;
- deco notes;
- dive profile;
- CSV export;
- Logbook integration;
- Tissue integration;
- Narcosis integration.

CCR-specific:
- manual dive circuit type;
- manual CCR setpoint notes/fields if implemented;
- diluent/bailout fields if implemented;
- CCR-specific equipment;
- scrubber duration if implemented;
- manual profile can generate tissue/narcosis only if enough data exists;
- if not enough CCR data, output must be labelled incomplete/not available, not fake.

Output:
- Manual Dive readiness %
- CCR Manual Dive readiness %

---

# PHASE 7 — LOGBOOK / ANALYTICS / CHART AUDIT

Verify:
- logbook metrics;
- analysis dashboard;
- depth profile charts;
- tissue loading charts;
- narcotic loading charts;
- gas timeline;
- PPO2 timeline;
- ceiling timeline;
- planner/logbook separation;
- demo-data isolation;
- manual-dive handling.

CCR-specific:
- CCR dives are labelled as CCR;
- OC and CCR analytics are not mixed incorrectly;
- PPO2 timeline for CCR uses setpoint model;
- bailout segment is represented if available;
- tissue timeline differentiates CCR loop and bailout;
- narcotic loading uses correct assumptions;
- missing CCR fields do not create fake charts.

Output:
- Logbook readiness %
- Analytics readiness %
- CCR Analytics readiness %

---

# PHASE 8 — PDF / SHARE / EXPORT AUDIT

Inspect:
- Planner PDF;
- Briefing PDF;
- Checklist PDF;
- Dive Pack PDF;
- share text;
- CSV/Subsurface export;
- WhatsApp / Mail / AirDrop / Files paths.

Verify:
- Planner PDF;
- briefing;
- gas plan;
- deco plan;
- Ratio Deco;
- comparison;
- checklist YES/NO boxes;
- equipment;
- tasks;
- gases;
- mode label;
- reference-only disclaimer;
- CNS/OTU labels;
- unit consistency.

CCR-specific:
PDF/share must clearly label:
- OC vs CCR;
- setpoints;
- diluent;
- bailout gases;
- CCR-specific assumptions;
- bailout plan;
- scrubber if implemented;
- not a CCR controller;
- not a certified decompression plan.

CSV/Subsurface:
- If CCR fields are not supported by export format, document limitation.
- Do not silently export CCR as OC without a clear label or warning.
- External Subsurface validation remains pending unless executed.

Output:
- PDF readiness %
- Share readiness %
- Export readiness %
- CCR PDF/Export readiness %

---

# PHASE 9 — UNIT CONVERSION AUDIT

Verify globally:
- meters ↔ feet;
- bar ↔ psi;
- Celsius ↔ Fahrenheit;
- liters ↔ cubic feet if present;
- RMV/SAC conversions if present;
- CCR oxygen/diluent units if present.

Areas:
- Planner;
- Charts;
- Tissue;
- Narcosis;
- Logbook;
- Checklist;
- PDF;
- CSV;
- CCR setpoints;
- diluent/bailout pressure;
- scrubber duration if present.

Output:
- Unit Conversion readiness %
- CCR Unit Conversion readiness %

---

# PHASE 10 — CCR / REBREATHER DEDICATED READINESS AUDIT

This is the dedicated CCR section.

Inspect the repository for any of these terms:
- CCR
- Rebreather
- Closed Circuit
- Semi Closed
- SCR
- setpoint
- diluent
- loop
- bailout
- scrubber
- oxygen cell
- PO2
- pO2
- constant PPO2
- metabolic oxygen
- solenoid
- controller
- handset

Classify current CCR support as:
- Not present;
- Documentation only;
- UI only;
- Partial model;
- Partial calculation;
- Planner-integrated;
- Release-hard internal;
- Ready for external TestFlight;
- Not safe to expose.

Audit CCR capability families:

## 10.1 Circuit type model
Verify:
- circuit type enum/model;
- OC vs CCR differentiation;
- mode-specific visibility;
- persistence;
- export;
- logbook;
- checklist.

## 10.2 Setpoint model
Verify:
- low setpoint;
- high setpoint;
- setpoint switch depth/time;
- setpoint validation;
- PPO2 bounds;
- CNS/OTU integration;
- chart/PDF/export.

## 10.3 Diluent model
Verify:
- O2/He/N2;
- MOD/MND;
- END/EAD;
- hypoxic validation;
- depth compatibility;
- bailout relation.

## 10.4 Bailout model
Verify:
- bailout gas roles;
- switch depth;
- gas quantity;
- OC bailout ascent;
- deco on bailout;
- gas ledger;
- checklist sync;
- PDF/export.

## 10.5 Decompression engine integration
Verify:
- CCR setpoint drives oxygen partial pressure;
- inert loading is correct under CCR assumptions;
- OC bailout switches to OC gas model;
- GF behavior unchanged;
- no fake static results;
- no OC math reused incorrectly for CCR.

## 10.6 Oxygen exposure
Verify:
- CNS from setpoint;
- OTU from setpoint;
- descent/bottom/deco/bailout separation if implemented;
- high PPO2 warning dominance;
- finite guards.

## 10.7 Consumption model
Verify:
- oxygen consumption if implemented;
- diluent use if implemented;
- bailout OC consumption;
- RMV/SAC separation;
- scrubber duration if implemented;
- missing consumption fields do not create fake estimates.

## 10.8 UI/UX exposure
Verify:
- CCR not exposed in Base;
- CCR only exposed when calculation/validation is safe;
- incomplete CCR features are clearly labelled beta/unsupported or hidden;
- warnings are clear.

## 10.9 Tests
Verify tests for:
- CCR constant setpoint shallow profile;
- CCR constant setpoint deep profile;
- setpoint switch;
- hypoxic diluent;
- bailout switch;
- CCR CNS/OTU;
- CCR tissue loading;
- CCR PDF/export;
- CCR unit conversion.

Output:
- CCR Overall readiness %
- CCR Model readiness %
- CCR Setpoint readiness %
- CCR Diluent readiness %
- CCR Bailout readiness %
- CCR Bühlmann integration readiness %
- CCR Oxygen exposure readiness %
- CCR Consumption readiness %
- CCR UI exposure readiness %
- CCR Test coverage readiness %

---

# PHASE 11 — PERFORMANCE / NUMERICAL ROBUSTNESS AUDIT

Audit:
- repeated Bühlmann recomputation;
- CCR setpoint timeline recomputation;
- tissue timeline generation;
- narcotic timeline generation;
- Ratio Deco overlay;
- PDF generation;
- chart rendering;
- CSV/export generation;
- SwiftUI `.onChange` loops;
- non-debounced Planner sliders/steppers;
- MOD/switch-depth normalization loops.

CCR-specific:
- setpoint timeline performance;
- long CCR plans;
- many bailout gases;
- tissue timeline with CCR + bailout;
- PDF generation with CCR tables/charts.

Output:
- Performance readiness %
- Numerical robustness readiness %

---

# PHASE 12 — SECURITY / PRIVACY / SAFETY COPY AUDIT

Audit:
- sensitive dive profile data;
- GPS;
- gas plans;
- CCR equipment/checklist data;
- iCloud backup opt-in;
- share/export files;
- PDF temporary file handling;
- CSV import/export;
- malformed cloud payloads.

CCR-specific safety copy must clearly state:
- reference-only;
- not a CCR controller;
- not a life-support system;
- not a certified decompression plan;
- verify with certified CCR computer, training and tables;
- bailout planning is indicative;
- scrubber/oxygen/diluent checks remain diver responsibility.

Output:
- Security readiness %
- Privacy readiness %
- CCR Safety Copy readiness %

---

# PHASE 13 — TEST COVERAGE AUDIT

Inspect:
- `Tests/iOSAlgorithmTests/*`

Report missing tests for:
- Bühlmann;
- Ratio Deco;
- MOD/PPO2;
- Gas Roles;
- Tissue;
- Narcosis;
- Checklist sync;
- Manual Dive;
- PDF/export;
- Unit conversion;
- CCR circuit type;
- CCR setpoint;
- CCR diluent;
- CCR bailout;
- CCR oxygen exposure;
- CCR tissue/narcosis;
- CCR PDF/export;
- CCR unit conversion.

Output:
- Test Coverage readiness %
- CCR Test Coverage readiness %

---

# PHASE 14 — RELEASE HARD READINESS MATRIX

Provide:

| Feature | Readiness |
|---|---:|
| Bühlmann | XX% |
| Ratio Deco | XX% |
| Gas Planning | XX% |
| Gas Roles | XX% |
| MOD/PPO2/Dalton | XX% |
| Tissue Loading | XX% |
| Narcosis | XX% |
| Planner Modes | XX% |
| Checklist | XX% |
| Planner Sync | XX% |
| Manual Dive | XX% |
| PDF Export | XX% |
| CSV/Subsurface | XX% |
| Localization | XX% |
| Units | XX% |
| Performance | XX% |
| Security/Privacy | XX% |
| Documentation | XX% |
| Internal TestFlight | XX% |
| External TestFlight | XX% |
| CCR Model | XX% |
| CCR Setpoint | XX% |
| CCR Diluent | XX% |
| CCR Bailout | XX% |
| CCR Bühlmann Integration | XX% |
| CCR Oxygen Exposure | XX% |
| CCR Consumption | XX% |
| CCR UI Exposure | XX% |
| CCR Test Coverage | XX% |
| Overall | XX% |

Mandatory final verdicts:
- Bühlmann verdict
- Ratio Deco verdict
- Gas Planning verdict
- Gas Role verdict
- MOD/PPO2 verdict
- Tissue verdict
- Narcosis verdict
- Checklist verdict
- PDF verdict
- Manual Dive verdict
- Unit Conversion verdict
- CCR verdict
- Internal TestFlight verdict
- External TestFlight verdict
- App Store verdict

---

# PHASE 15 — ACTION PLAN

For every issue, provide:
- ID;
- severity:
  - CRITICAL
  - HIGH
  - MEDIUM
  - LOW
  - INFO
- priority:
  - P0 — must fix before compile/use
  - P1 — must fix before internal TestFlight
  - P2 — must fix before external TestFlight
  - P3 — must fix before App Store
  - P4 — post-release
- affected files;
- user impact;
- safety impact;
- algorithmic impact;
- proposed fix;
- tests required;
- acceptance criteria.

Group action plan by:
1. Immediate blockers
2. Internal TestFlight blockers
3. External TestFlight blockers
4. App Store blockers
5. Post-release improvements

---

# FINAL OUTPUT FILE

Create:

`Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

The report must contain:
- original Check_Math_iOS findings;
- all v2 extension findings;
- CCR / Rebreather findings;
- single consolidated readiness verdict;
- release-hard matrix;
- action plan;
- test plan;
- external QA gates;
- recommended next Cursor remediation commands.

Do not modify code.

---

# SUCCESS CRITERIA

The audit is complete only if:

- No production source code is modified.
- No UI is modified.
- No business logic is modified.
- No algorithms are modified.
- No security model is modified.
- Report is created at:

  `Docs/IOS_MAIN_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

- Report includes:
  - Bühlmann readiness;
  - Ratio Deco readiness;
  - Tissue readiness;
  - Narcosis readiness;
  - Gas Planning readiness;
  - MOD/PPO2/Dalton readiness;
  - Planner ↔ Checklist readiness;
  - Manual Dive readiness;
  - PDF/Share readiness;
  - Unit Conversion readiness;
  - CCR / Rebreather readiness;
  - release-hard matrix;
  - detailed action plan.

- All external/physical QA items are marked as pending, not passed.
- Final git status confirms only report/docs changed.

If anything cannot be fully analyzed:
- document the limitation;
- explain why;
- propose the exact next inspection step.
