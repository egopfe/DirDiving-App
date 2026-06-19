# 6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED_V3.0

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

## CURSOR / CODEX COMMAND — DIR DIVING GIT DOCUMENTATION ALIGNMENT UPDATED WITH CCR / REBREATHER & LATEST MAIN IMPLEMENTATIONS

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** documentation / repository consistency / Git safety

You are working on the DIR DIVING Git repository.

This is the **6th command** in the DIR DIVING recurring audit / alignment sequence.

The filename must always retain the `6-` prefix. Future revisions must increment only the suffix version, for example `_V2.1`, `_V3.0`, without changing this command's sequence position.

It must be executed after:

1. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md`
2. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md`
3. the current versioned `3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED` command
4. `4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED_V3.0.md`
5. the current versioned `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED` command

This command is primarily a **documentation alignment / repository consistency / Git safety task**.

It must align the documentation with the latest MAIN architecture and implementations, including CCR / Rebreather, structured Equipment, Emergency / Rock Bottom, complete Dive Runtime, gas ledger, repetitive-dive planning, and Planner briefing cards to Apple Watch, without changing runtime code.

---

# CORE TASK

Update and align ALL MAIN branch documentation, README files, feature matrices, branch strategy docs, release docs, TestFlight docs, UX/UI audit references, algorithm-readiness docs, safety docs, CCR/Rebreather docs, PDF/export docs, Equipment/checklist docs, unit-conversion docs, Watch/iOS sync docs, Planner briefing-card docs, QA-evidence docs and Git branch documentation according to the CURRENT DIR DIVING architecture and latest implementations.

This is primarily a DOCUMENTATION / REPOSITORY CONSISTENCY / GIT SAFETY task.

You may update:

- Markdown documentation
- README files
- CSV/Markdown feature matrices
- release notes
- QA evidence templates
- branch strategy documents
- documentation indexes
- documentation-only metadata
- references to current command versions

Do NOT modify runtime code unless resolving a documented documentation-only conflict marker.

---

# CURRENT PROJECT STATE TO DOCUMENT

## APPLE WATCH MAIN

Document and align, if implemented in MAIN:

- Diving mode MAIN
- Apple Watch live dive visualizer/logger
- legal onboarding revision system
- depth safety discouragement at 35 / 38 / 40 m
- inline ascent warning banners
- compact GPS overlays
- GPS entry/exit finalization lifecycle
- pending finalization restore
- active draft restore
- App Intents catalog
- Action Button support via Shortcuts/App Intents
- Side Button documented as system-controlled
- Mission Mode with icon/indicator and invariant semantics
- developer sensor source selector/status
- sensor source/simulation policy
- TTV as informational live index, not NDL/TTS/deco
- BUSSOLA terminology
- Watch ↔ iPhone sync
- authenticated sync / peer secret / HMAC if implemented
- signed ACK / replay-protection behavior if implemented
- iPhone → Watch push
- tombstones / duplicate protection
- Watch source-of-truth User Images
- User Images inventory/delete sync
- horizontal image paging if implemented
- reminder manual dismiss if implemented
- reminder suppression by higher-priority safety alarms
- small-screen safety-layout behavior
- locale-adaptive Watch logbook dates
- accessibility labels for haptics-off / underwater navigation states
- Planner briefing cards received from iOS
- Planner briefing-card inventory / persistence / replacement / delete
- briefing-card versioning / stale-state behavior
- briefing-card reference-only semantics
- no live decompression authority from briefing cards
- no impact of briefing cards on live depth/runtime/ascent/alarms/reminders
- underwater-safe warning UX philosophy
- no full-screen underwater warnings
- release/TestFlight documentation
- Apple Watch Ultra entitlement notes

## iOS COMPANION MAIN

Document and align, if implemented in MAIN:

- iOS Companion MAIN
- dashboard / analysis
- dive log
- manual dive add/edit
- Watch sync status
- planner safety acknowledgement
- Base / Deco / Technical planner architecture
- CCR / Rebreather planner
- Bühlmann ZHL-16C multigas planning reference
- N2 + He tissue model
- Trimix / Nitrox / Air / O2 support
- Gradient Factors
- environment-aware pressure model
- Ratio Deco comparison
- tissue loading analytics
- narcotic loading / END / PPN2
- CNS / OTU reference estimates
- structured Equipment setup
- operational pre-dive checklist
- Planner ↔ Equipment ↔ Checklist navigation
- CCR checklist import/export
- global Planner ascent-speed settings
- complete Dive Runtime presentation
- dedicated decompression-stop section
- Planner Emergency / Rock Bottom
- Available Gas / gas ledger
- liters as canonical quantity
- cylinder-equivalent bar presentation
- schedule-aware gas consumption
- Technical average-depth gas-consumption option
- repetitive-dive residual-tissue planning
- route-summary aggregation
- plan-completeness / result-state gating
- PDF / Briefing / Dive Pack export
- Planner briefing PNG/card export to Apple Watch
- Planner briefing-card transfer state
- CCR bailout scenario
- CCR gas-density estimate
- CCR setpoint workflow
- low/high setpoint
- setpoint switch depth
- diluent gas
- bailout gas
- bailout transition
- CCR CNS / OTU
- CCR tissue loading
- CCR narcosis / END
- CCR gas ledger
- CCR checklist integration
- CCR PDF/share/export
- CCR logbook/manual-dive representation
- planner localization EN/IT
- planner limitations and non-certified positioning

## CCR / REBREATHER DOCUMENTATION STATE

Document and align:

- CCR / Rebreather mode
- Open Circuit vs Closed Circuit distinction
- setpoint low / setpoint high
- setpoint switch depth
- diluent role
- bailout role
- bailout transition assumptions
- CCR Bühlmann integration
- CCR tissue loading
- CCR CNS / OTU
- CCR narcotic loading / END
- CCR gas ledger
- CCR checklist import/export
- CCR manual dive/logbook fields
- CCR PDF/share/export
- CCR unit conversion
- CCR bailout scenario
- CCR gas-density assumptions
- CCR Planner briefing-card export to Watch
- CCR limitations
- CCR external validation requirement
- CCR safety disclaimers:
  - reference-only
  - not a certified CCR controller
  - not a live loop PPO2 monitor
  - not a substitute for handset/HUD/controller/manufacturer procedures
  - bailout plan is indicative
  - gas-density output is an estimate based on documented assumptions

## EXPERIMENTAL / ISOLATED

Document separately:

- Snorkeling architecture experimental only
- Apnea architecture experimental only
- Buddy Assist experimental only
- Exploration concepts experimental only

Experimental features must remain isolated from MAIN runtime targets.

---

# CRITICAL CONSTRAINTS

DO NOT:

- redesign UI
- change business logic
- change dive/depth/ascent algorithms
- change planner algorithms
- change Bühlmann math
- change CCR/Rebreather logic or math
- change CNS/OTU math
- change gas planning math
- change sync architecture
- change persistence models
- introduce dependencies
- introduce certified dive-computer claims
- introduce certified decompression-planner claims
- introduce certified CCR-controller claims
- imply live CCR loop PPO2 monitoring
- rewrite large docs unnecessarily
- delete existing docs
- force-push
- delete branches
- squash history
- merge experimental runtime code into MAIN

PRESERVE:

- additive documentation updates where possible
- historical/contextual documentation
- stable Diving behavior above all else
- BUSSOLA terminology
- never use `COMPASSO`
- MAIN/experimental isolation
- non-certified/reference-only positioning
- Mission Mode semantics
- TTV informational semantics
- Watch source-of-truth image policy
- HMAC/peer-secret/signed-ACK documentation
- physical/external QA gates as pending unless evidence exists
- Planner briefing-card reference-only semantics
- Rock Bottom estimate limitations
- liters/bar gas-ledger semantics
- Technical average-depth toggle scope
- CCR checklist role separation
- CCR gas-density estimate limitations

If unsure whether a change affects runtime behavior:

- DO NOT change code
- add a documentation TODO
- report the uncertainty

---

# PHASE 0 — PREFLIGHT REPOSITORY AUDIT

Before changing anything, inspect:

- repository structure
- branches
- `project.yml`
- `README.md`
- `Docs/*`
- `CHANGELOG.md`
- `ROADMAP.md`
- `CONTRIBUTING.md`
- release docs
- TestFlight docs
- App Store docs
- safety disclaimer docs
- onboarding/legal docs
- feature comparison tables
- CSV/XLSX docs if present
- UI reference folders
- QA evidence folders
- localization docs
- branch-specific docs
- algorithm audit docs
- Watch audit docs
- iOS Bühlmann audit docs
- UI/UX audit docs
- CNS/OTU docs
- chart-truthfulness docs
- CCR/Rebreather docs
- CCR setpoint/diluent/bailout docs
- CCR export/PDF docs
- CCR checklist docs
- CCR limitations/safety docs
- Equipment/checklist docs
- ascent-speed / Dive Runtime docs
- Emergency / Rock Bottom docs
- gas-ledger / schedule-aware gas docs
- repetitive-dive docs
- Planner briefing-card / Watch-transfer docs
- accessibility remediation reports
- QA evidence / ReferenceUI documentation

Run:

```bash
git status
git branch -a
git remote -v
git rev-parse --short HEAD
git fetch origin
git status -sb
```

Verify:

- branch is `main`
- MAIN build targets
- iOS target name
- Watch target name
- test target names
- experimental isolation
- bundle IDs
- entitlement references
- branch naming consistency
- documentation referencing outdated architecture
- documentation using outdated terminology
- documentation implying certification
- documentation implying Watch is a decompression computer
- documentation implying Planner briefing cards are live guidance
- documentation claiming physical/external QA without evidence

STOP if branch is not `main`.

---

# PHASE 1 — MAIN DOCUMENTATION UPDATE

## A. WATCH MAIN

Update documentation for:

- live depth/runtime/temperature/ascent UI
- TTV informational semantics
- manual and automatic dive start
- depth safety and ascent warnings
- compact GPS overlays
- draft/finalization restore
- BUSSOLA
- Mission Mode
- App Intents / Action Button
- Side Button limitation
- Watch logs/export
- Watch sync/authentication
- User Images and delete/inventory
- reminder engine
- manual dismiss / suppression
- image paging
- sensor source / simulation
- Apple Watch Ultra entitlement
- Planner briefing-card reception
- card inventory/detail/delete
- card versioning/staleness
- card reference-only semantics
- no effect of cards on live calculations
- small-screen safety-layout behavior
- accessibility and date localization

## B. iOS MAIN

Update documentation for:

- iOS Companion
- logbook/manual dive
- analysis dashboard
- Planner modes
- Bühlmann
- Ratio Deco
- Tissue/Narcosis
- MOD/PPO2/Dalton
- gas roles
- structured Equipment
- operational checklist
- Planner ↔ Equipment ↔ Checklist
- ascent-speed settings
- full Dive Runtime
- dedicated deco stops
- Emergency / Rock Bottom
- Available Gas / gas ledger
- schedule-aware gas consumption
- Technical average-depth gas option
- repetitive-dive planning
- route summary
- plan completeness/result state
- CCR planner
- CCR checklist import/export
- CCR bailout scenario
- CCR gas density
- PDFs/share/export
- Planner briefing cards to Watch
- reference-only/non-certified positioning

## C. SAFETY PHILOSOPHY

Document:

- not a certified dive computer
- no decompression authority
- Watch TTV is not NDL/TTS/deco
- iOS Planner is reference-only
- CCR Planner is reference-only
- no live CCR PPO2 monitoring
- CNS/OTU are estimates
- GPS surface-only behavior
- depth-limit discouragement
- non-blocking underwater warnings
- no hidden critical metrics
- haptic/visual redundancy
- Mission Mode invariants
- Action Button limitations
- sensor-source limitations
- entitlement limitations
- briefing cards are reference-only
- Rock Bottom is an estimate
- bar equivalents depend on cylinder configuration
- average-depth gas mode affects gas estimation only
- gas-density values are estimates

## D. UI / UX DESIGN SYSTEM

Document:

- Watch dark/neon style
- iOS dark marine/cyan style
- underwater readability
- large touch targets
- inline warnings
- BUSSOLA terminology
- Mission Mode indicator
- depth safety states
- Planner mode structure
- Dive Runtime conventions
- dedicated deco-stop conventions
- Emergency warning hierarchy
- gas-ledger conventions
- structured Equipment/checklist conventions
- CCR visual conventions
- chart truthfulness
- briefing-card visual conventions

## E. BUILD / RELEASE

Document:

- XcodeGen
- bundle IDs
- Watch companion architecture
- entitlements
- TestFlight process
- App Store risks
- internal QA
- physical-device QA
- paired Watch/iPhone QA
- external Bühlmann validation
- external CCR validation
- accessibility QA
- underwater QA
- briefing-card paired-device QA
- Rock Bottom reference-case validation
- repetitive-dive validation
- ReferenceUI screenshot requirements

---

# PHASE 2 — README STRATEGY UPDATE

README must include/update:

1. Project overview
2. Supported platforms
3. MAIN vs experimental
4. Branch strategy
5. Build instructions
6. XcodeGen
7. Entitlement notes
8. Safety disclaimer
9. UI references
10. Feature matrix link
11. Watch/iPhone sync
12. Authenticated sync
13. User Images
14. Planner modes
15. Bühlmann reference-only positioning
16. CCR reference-only positioning
17. CNS/OTU
18. Structured Equipment/checklist
19. Ascent-speed / Dive Runtime / deco stops
20. Emergency / Rock Bottom
21. Available Gas / gas ledger
22. Repetitive-dive limitations
23. Planner briefing cards to Watch
24. Known limitations
25. TestFlight status
26. App Store status

Add or update `Branch Strategy`:

- MAIN = stable production-oriented
- experimental = isolated
- documentation alignment must not change business logic
- Diving stability has highest priority
- experimental runtime code is never merged automatically
- docs-only changes remain separate from runtime changes

---

# PHASE 3 — FEATURE MATRIX UPDATE

Create/update:

```text
Docs/DIR_DIVING_Feature_Comparison.csv
```

Do not delete historical rows.

Required columns:

- Area
- Branch
- App
- Mode
- Feature
- Status
- Reachable
- UX Complete
- Safety Complete
- Algorithm Complete
- Documentation Complete
- Description
- UI Reference
- Localization
- Notes

Allowed statuses:

- Implemented
- Stable
- Partial
- UI-only
- Placeholder
- Experimental
- Planned
- TODO
- Blocked by entitlement
- Requires physical QA
- Requires external validation
- Requires legal/safety review
- Reference-only

Add/update rows for:

- Watch MAIN
- iOS MAIN
- experimental modes
- Base / Deco / Technical
- CCR / Rebreather
- Ratio Deco
- Tissue Loading
- Narcosis / END / PPN2
- CNS / OTU
- structured Equipment
- operational checklist
- CCR checklist import/export
- Planner ascent-speed settings
- Dive Runtime
- dedicated deco stops
- Emergency / Rock Bottom
- Available Gas / Gas Ledger
- schedule-aware gas consumption
- Technical average-depth gas option
- repetitive dive
- route summary / completeness gating
- Planner briefing-card export
- Watch briefing-card inventory
- CCR bailout scenario
- CCR gas density
- User Images
- reminders
- Mission Mode
- Sensor Source
- App Intents
- Action Button
- accessibility
- localization
- TestFlight readiness
- App Store readiness

---

# PHASE 4 — AUDIT / READINESS DOCUMENT ALIGNMENT

Update all audit/readiness docs to reflect:

- current MAIN commit
- actual implemented state
- current readiness
- current blockers
- physical/external QA still pending unless evidenced
- no stale scores carried forward without evidence
- no feature marked implemented merely because scaffolding exists
- presentation-only components identified as presentation-only

Align documentation for:

- Watch runtime
- iOS Planner
- Bühlmann
- Ratio Deco
- CCR
- Tissue/Narcosis
- MOD/PPO2
- gas roles
- structured Equipment
- checklist
- ascent-speed settings
- Dive Runtime
- deco stops
- Emergency / Rock Bottom
- gas ledger
- repetitive dive
- Planner briefing cards
- accessibility
- localization
- sync/security
- TestFlight/App Store

---

# PHASE 4A — STRUCTURED EQUIPMENT / CHECKLIST DOCUMENTATION

Document:

- Equipment profile
- cylinder size / pressure / mix / role
- Planner links
- checklist links
- operational task generation
- REC / TEC / CCR applicability
- duplicate prevention
- user-edit preservation
- Equipment Setup PDF
- accessibility/localization

---

# PHASE 4B — ASCENT SPEED / DIVE RUNTIME / DECO STOPS DOCUMENTATION

Document:

- global ascent-speed settings
- valid defaults/bounds
- planning-estimate semantics
- full Dive Runtime phases
- dedicated decompression-stop section
- relationship to canonical schedule
- presentation-only builders
- no claim that app controls actual ascent

---

# PHASE 4C — EMERGENCY / ROCK BOTTOM DOCUMENTATION

Document:

- purpose
- conservative assumptions
- team/stressed RMV inputs
- problem-solving time
- liters required
- cylinder-equivalent bar
- available/required comparison
- separation from normal consumption
- average-depth toggle scope
- CCR bailout relationship
- estimate/reference-only limitation

---

# PHASE 4D — GAS LEDGER / SCHEDULE-AWARE GAS DOCUMENTATION

Document:

- liters as canonical quantity
- bar as cylinder-specific equivalent
- schedule consumption
- role allocation
- reserve/remaining semantics
- display rounding
- insufficiency warnings
- PDF/briefing-card consistency

---

# PHASE 4E — REPETITIVE DIVE DOCUMENTATION

Document:

- residual tissues
- surface interval
- prior-dive chronology
- fresh vs repetitive state
- OC/CCR compatibility
- external validation status
- limitations

---

# PHASE 4F — CCR DOCUMENTATION

Create/update as applicable:

- `Docs/CCR_REBREATHER_PLANNER.md`
- `Docs/CCR_REBREATHER_LIMITATIONS.md`
- `Docs/CCR_REBREATHER_SAFETY_DISCLAIMER.md`
- `Docs/CCR_REBREATHER_VALIDATION_PLAN.md`
- `Docs/CCR_REBREATHER_CHECKLIST_SYNC.md`
- `Docs/CCR_REBREATHER_EXPORT_POLICY.md`

Document:

- setpoints
- diluent
- bailout
- bailout transition
- CNS/OTU
- tissue/narcosis
- checklist import/export
- bailout scenario
- gas density
- briefing-card export
- external validation
- reference-only limitations

---

# PHASE 4G — PLANNER BRIEFING CARD / WATCH DOCUMENTATION

Document:

- iOS generation
- structured metadata
- rendered PNG
- transfer to Watch
- receiver/store/inventory
- replacement/delete
- stale/unsupported schema
- transfer status/ACK
- numerical fidelity
- reference-only semantics
- no live decompression authority
- no effect on Watch live metrics
- CCR card-data limitations

---

# PHASE 5 — BRANCH ALIGNMENT STRATEGY

Inspect all local and remote branches.

For each branch record:

- divergence from MAIN
- branch purpose
- stale docs
- stale screenshots
- stale feature matrices
- stale release notes
- experimental leakage risk
- merge recommendation

Do NOT:

- force-push
- delete branches
- squash history
- auto-merge runtime changes
- merge experimental runtime code into MAIN

Documentation conflicts may be resolved conservatively.

---

# PHASE 6 — MERGE / CONFLICT POLICY

Preserve priority:

1. buildable code
2. stable Diving behavior
3. safety/legal truthfulness
4. latest UI references
5. latest algorithm docs
6. latest CCR docs
7. latest Equipment/checklist docs
8. latest Emergency/gas-ledger/runtime docs
9. latest briefing-card docs
10. release/TestFlight docs
11. audit consistency
12. experimental isolation

Never overwrite:

- BUSSOLA terminology
- inline warning strategy
- depth-limit philosophy
- Watch sync/security docs
- User Images source-of-truth docs
- planner non-certified disclaimer
- CCR safety disclaimer
- briefing-card reference-only wording
- Rock Bottom estimate limitations
- liters/bar semantics
- average-depth toggle scope
- latest legal disclaimers

---

# PHASE 7 — PR INSPECTION

For each open PR inspect:

- source branch
- affected files
- runtime risk
- documentation risk
- experimental leakage risk
- merge recommendation
- required QA

Do not auto-merge runtime PRs.

---

# PHASE 8 — GIT SAFETY

Before changes:

```bash
git status
git rev-parse --short HEAD
```

Optional backup branch:

```text
backup/docs-alignment-YYYYMMDD
```

Commit documentation separately from conflict fixes.

Suggested commits:

- `docs: align DIR DIVING architecture and release documentation`
- `docs: update feature matrix and branch strategy`
- `docs: document structured equipment checklist and planner links`
- `docs: document planner runtime emergency and gas ledger`
- `docs: document CCR checklist bailout and gas density`
- `docs: document planner briefing cards to Apple Watch`
- `docs: update QA evidence and release gates`

Do not commit if:

- runtime code changed unexpectedly
- algorithm files changed
- sync/security code changed
- experimental files leaked into MAIN
- project consistency cannot be verified

Do not push unless explicitly requested or the command context clearly authorizes it.

---

# PHASE 9 — BUILD / PROJECT CONSISTENCY

Verify:

- `project.yml`
- README build instructions
- bundle IDs
- entitlements
- target names
- test targets
- MAIN source membership
- experimental exclusions

On macOS, if appropriate:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 3 (49mm)' test
```

On non-macOS:

- do not run Xcode build commands
- perform static consistency inspection
- document macOS validation as pending

---

# PHASE 10 — DOCUMENTATION INDEX

Create/update:

```text
Docs/README.md
```

Link to:

- project overview
- safety philosophy
- Watch MAIN
- iOS Companion
- Planner
- Bühlmann
- Ratio Deco
- Tissue/Narcosis
- CNS/OTU
- CCR
- structured Equipment/checklist
- ascent-speed / Dive Runtime / deco stops
- Emergency / Rock Bottom
- gas ledger
- repetitive dive
- Planner briefing cards
- sync/security
- export/PDF
- localization/accessibility
- release/TestFlight/App Store
- feature matrix
- UI references
- QA evidence
- audit reports
- experimental docs

Mark stale duplicates as superseded; do not delete them automatically.

---

# PHASE 11 — FINAL REPORT

Create:

```text
Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md
```

Include:

A. Scope and commit  
B. Files updated  
C. Docs created  
D. Docs marked superseded  
E. README changes  
F. Feature-matrix changes  
G. Branches inspected  
H. Conflicts found/resolved  
I. PRs inspected  
J. Remaining documentation gaps  
K. Release/TestFlight/App Store blockers  
L. Experimental isolation confirmation  
M. Watch documentation alignment  
N. iOS Planner documentation alignment  
O. Bühlmann/Ratio Deco/Tissue documentation alignment  
P. CCR documentation alignment  
Q. Structured Equipment/checklist documentation alignment  
R. Ascent-speed / Dive Runtime / deco-stop alignment  
S. Emergency / Rock Bottom documentation alignment  
T. Gas-ledger / schedule-consumption alignment  
U. Repetitive-dive documentation alignment  
V. Planner briefing-card / Watch-transfer alignment  
W. Accessibility/localization documentation alignment  
X. QA evidence / ReferenceUI status  
Y. Git status before/after  
Z. Commits created  
AA. Push status  
AB. Risks / assumptions

---

# PHASE 12 — FINAL VALIDATION

Verify:

- only documentation / metadata files changed
- no production Swift changed
- no algorithm files changed
- no security/sync code changed
- no experimental runtime leakage
- docs index works
- internal links resolve
- referenced files exist
- feature matrix is valid CSV
- no false PASS claims
- no unsupported certification claims
- all external QA remains pending unless evidence exists
- final `git status` is documented

---

# FINAL OUTPUT

After completion report:

- files updated
- docs created
- docs superseded
- feature-matrix status
- branches/PRs inspected
- commits created
- push status
- remaining blockers
- CCR documentation status
- structured Equipment/checklist documentation status
- Emergency/Rock Bottom documentation status
- runtime/deco-stop/gas-ledger documentation status
- repetitive-dive documentation status
- Planner briefing-card documentation status
- QA evidence / ReferenceUI status

---

# SUCCESS CRITERIA

The task is complete only if:

- `6-` prefix is preserved
- version suffix is present
- documentation is aligned to current MAIN
- README is current
- feature matrix is current
- Docs index is current
- release/TestFlight/App Store docs are aligned
- CCR documentation is truthful
- structured Equipment/checklist docs are aligned
- ascent-speed/runtime/deco-stop docs are aligned
- Emergency/Rock Bottom docs are aligned
- gas-ledger docs are aligned
- repetitive-dive docs are aligned
- Planner briefing-card docs are aligned
- no runtime code is modified
- no algorithm is modified
- no security/sync model is modified
- no experimental runtime code enters MAIN
- physical/external QA remains pending without evidence
- final report is created
- final Git status confirms documentation-only changes

---

# VERSION HISTORY

## V3.0 — 2026-06-19

Updated against the current `main` implementation state.

Added documentation-alignment coverage for:

- structured Equipment setup
- operational pre-dive checklist
- Planner ↔ Equipment ↔ Checklist navigation
- Planner ascent-speed settings
- full Dive Runtime
- dedicated decompression-stop section
- Planner Emergency / Rock Bottom
- Available Gas / gas ledger in liters and cylinder-equivalent bar
- schedule-aware gas consumption
- Technical average-depth gas-consumption option
- repetitive-dive residual tissues
- route-summary / result-completeness gating
- CCR checklist import/export
- CCR bailout scenario
- CCR gas-density estimate
- Planner briefing PNG/card export to Apple Watch
- Watch briefing-card receiver/store/inventory
- reminder dismiss, image paging and locale-adaptive date documentation
- accessibility/localization remediation reports
- QA evidence and ReferenceUI documentation

Preserved:

- `6-` prefix and sequence position
- documentation/repository consistency scope
- additive-update preference
- runtime-code protection
- no algorithm, UI, security, sync or persistence changes
- MAIN/experimental isolation
- non-certified/reference-only positioning
- BUSSOLA terminology
- physical/external QA marked pending unless evidenced

---

# V3.0 DOCUMENTATION AUDIT-ONLY OVERRIDE

This command is now **audit-only**.

Do not update documentation during execution.

Instead, audit all documentation and produce:

- a documentation truthfulness report;
- an outdated-document inventory;
- a command-version alignment matrix;
- a proposed documentation remediation plan;
- a list of exact files requiring updates.

Documentation must reflect:

- Diving, Apnea and Snorkeling as current product areas when implemented;
- startup selection on iOS and Watch;
- activity-specific features;
- Shared Settings and activity-specific Settings;
- strict Logbook ownership;
- Full Computer on Watch where actually implemented;
- non-certified/reference-only claims;
- pending external/physical QA.

Do not carry forward any statement that Apnea or Snorkeling is experimental without current repository evidence.
