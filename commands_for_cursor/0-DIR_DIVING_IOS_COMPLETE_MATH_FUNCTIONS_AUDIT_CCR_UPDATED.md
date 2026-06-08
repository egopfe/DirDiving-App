# 0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED

## CURSOR / CODEX COMMAND — DIR DIVING COMPLETE MATHEMATICAL FUNCTIONS / ALGORITHM AUDIT UPDATED WITH CCR / REBREATHER & CO.

You are working on the DIR Diving repository.

## POSITION IN AUDIT SEQUENCE

This is the **0- audit**, the first audit to run after every meaningful change.

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

The audit must explicitly include the new **CCR / Rebreather & Co.** developments.

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
- MOD / PPO2 / Dalton
- Switch Depth
- Tissue Loading
- Narcotic Loading / END
- CNS / OTU
- Planner Modes
- Checklist Sync where it affects gas/math
- Manual Dive math fields
- PDF / Share mathematical output
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

---

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
- TestFlight readiness

Flag stale or missing docs.

---

# PHASE 17 — BUILD / TEST EXECUTION

On macOS run:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build
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

## H. Tissue & Narcosis Assessment

## I. CNS / OTU Assessment

## J. Charts / Tables Assessment

## K. Checklist / Equipment Assessment

## L. PDF / Share Assessment

## M. Logbook / Manual Dive / Import Export Assessment

## N. Apple Watch Companion Assessment

## O. Sync / Persistence Assessment

## P. Localization / Accessibility Assessment

## Q. Findings by Priority

## R. Edge Case Matrix

## S. Test Plan

## T. Readiness Matrix

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
| MOD / PPO2 / Dalton | XX% |
| Switch Depth Clamp | XX% |
| Tissue Loading | XX% |
| Narcosis / END | XX% |
| CNS / OTU | XX% |
| Checklist Gas Sync | XX% |
| Manual Dive Math | XX% |
| PDF / Share Math Output | XX% |
| CSV / Subsurface Math Output | XX% |
| Watch Math Runtime | XX% |
| Sync / Persistence Math Integrity | XX% |
| Unit Conversion | XX% |
| Overall Math Readiness | XX% |

## U. Prioritized Roadmap

1. Must fix before compile/use
2. Must fix before internal TestFlight
3. Must fix before external TestFlight
4. Must fix before App Store
5. Post-release improvements

## V. Final Verdict

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
