# 6-DIR_DIVING_GIT_DOCUMENTATION_ALIGNMENT_COMMAND_CCR_UPDATED

## CURSOR / CODEX COMMAND — DIR DIVING GIT DOCUMENTATION ALIGNMENT UPDATED WITH CCR / REBREATHER & CO.

You are working on the DIR DIVING Git repository.

This is the **6th command** in the DIR DIVING recurring audit / alignment sequence.

It must be executed after:

1. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`
2. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`
3. `3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`
4. `4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED.md`
5. `5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED.md`

This command is primarily a **documentation alignment / repository consistency / Git safety task**.

It must align the documentation with the latest MAIN architecture, including the new **CCR / Rebreather & Co.** developments, without changing runtime code.

TASK:
Update and align ALL MAIN branch documentation, README files, feature matrices, branch strategy docs, release docs, TestFlight docs, UX/UI audit references, algorithm-readiness docs, safety docs, CCR/Rebreather docs, PDF/export docs, checklist docs, unit-conversion docs, and Git branch documentation according to the CURRENT DIR DIVING architecture and latest implementations.

This is primarily a DOCUMENTATION / REPOSITORY CONSISTENCY / GIT SAFETY task.

You may update documentation and repository metadata only.
Do NOT modify runtime code unless resolving a documented documentation-only conflict marker.

CURRENT PROJECT STATE TO DOCUMENT:
The repository now includes or is expected to include:

APPLE WATCH MAIN:
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
- developer sensor source selector/status where applicable
- sensor source/simulation policy
- TTV as informational live index, not NDL/TTS/deco
- BUSSOLA terminology
- Watch ↔ iPhone sync
- authenticated sync / peer secret / HMAC if implemented
- iPhone → Watch push
- tombstones
- Watch source-of-truth User Images
- User Images inventory/delete sync if implemented
- underwater-safe warning UX philosophy
- no full-screen underwater warnings
- release/TestFlight documentation
- Apple Watch Ultra entitlement notes

IOS COMPANION MAIN:
- iOS Companion MAIN
- dashboard
- dive log
- manual dive add/edit
- CCR / Rebreather planning if implemented
- CCR setpoint workflow
- CCR low setpoint / high setpoint
- CCR setpoint switch depth
- diluent gas
- CCR bailout gas
- CCR bailout transition
- CCR CNS / OTU reference estimates
- CCR tissue loading
- CCR narcotic loading / END
- CCR gas ledger / checklist / PDF-share integration
- Watch sync status
- planner safety acknowledgement
- three-mode planner architecture:
  - Base
  - Deco
  - Technical
- Bühlmann ZHL-16C multigas planning reference
- N2 + He tissue model
- Trimix / Nitrox / Air support
- Gradient Factors
- environment-aware pressure model
- repetitive planning reference behavior
- gas ledger / schedule gas consumption
- CNS / OTU reference estimates
- CNS full plan
- CNS descent + bottom
- 15% CNS descent+bottom warning
- PIANO / CURVA BÜHLMANN / GRAFICI result tabs
- real tissue-history Bühlmann curve if implemented
- NDL reference curve if retained
- decompression/ascent table with bottom/travel/deco/surface rows if implemented
- depth profile chart if implemented
- planner localization EN/IT
- planner limitations and non-certified positioning


CCR / REBREATHER & CO. DOCUMENTATION STATE:
Document and align, if implemented or planned in MAIN:
- CCR / Rebreather mode
- Open Circuit vs Closed Circuit distinction
- setpoint low / setpoint high
- setpoint switch depth
- diluent gas role
- bailout gas role
- bailout transition assumptions
- CCR Bühlmann integration
- CCR tissue loading
- CCR CNS / OTU based on setpoint assumptions
- CCR narcotic loading / END based on diluent/inert assumptions
- CCR gas ledger
- CCR Planner ↔ Checklist sync
- CCR manual dive/logbook fields
- CCR PDF/share/export
- CCR unit conversion
- CCR limitations
- CCR external validation requirement
- CCR safety disclaimers:
  - reference-only
  - not a certified CCR controller
  - not a live loop PPO2 monitor
  - not a substitute for handset/HUD/controller/manufacturer procedures
  - bailout plan is indicative and must be verified by trained divers


EXPERIMENTAL / ISOLATED:
- Snorkeling architecture experimental only
- Apnea architecture experimental only
- Buddy Assist experimental only
- Exploration concepts experimental only
- Experimental features must remain isolated from MAIN runtime targets.

MANDATORY UI REFERENCES:
Verify, document, and preserve references if present:
- Docs/ReferenceUI/Watch_LIVE_reference.png
- Docs/ReferenceUI/iOS_Companion_reference.png
- latest ascent-warning inline mockup
- latest Snorkeling Live / Waypoint / Return Map screenshots
- latest Apnea workflow screenshots
- any Bühlmann planner/tissue curve screenshots or chart truthfulness references if present
- any CNS/OTU UI references if present
- any CCR/Rebreather planner screenshots or UI references if present
- any CCR setpoint/diluent/bailout screenshots if present
- any CCR PDF/checklist/export screenshots if present

CRITICAL CONSTRAINTS:
- DO NOT redesign UI.
- DO NOT change business logic.
- DO NOT change dive/depth/ascent algorithms.
- DO NOT change planner algorithms.
- DO NOT change Bühlmann math.
- DO NOT change CCR/Rebreather logic or math.
- DO NOT change CNS/OTU math.
- DO NOT change CCR CNS/OTU or CCR setpoint semantics.
- DO NOT change gas planning math.
- DO NOT change sync architecture unless resolving a documented merge conflict.
- DO NOT change persistence models.
- DO NOT introduce dependencies.
- DO NOT introduce certified CCR controller claims.
- DO NOT imply live CCR loop PPO2 monitoring unless real CCR sensor integration exists and is documented.
- DO NOT rewrite large docs unnecessarily.
- DO NOT delete existing docs.
- Prefer additive updates over rewrites.
- Preserve historical/contextual documentation.
- Preserve stable Diving behavior above all else.
- Preserve BUSSOLA terminology.
- NEVER use “COMPASSO”.
- Experimental features must remain isolated from MAIN runtime targets.
- If unsure whether a change affects runtime behavior, DO NOT change code; document uncertainty instead.

==================================================
PHASE 0 — PREFLIGHT REPOSITORY AUDIT
==================================================

Before changing anything, inspect:

- repository structure
- branches
- project.yml
- README.md
- Docs/*
- CHANGELOG.md
- ROADMAP.md
- CONTRIBUTING.md
- release docs
- TestFlight docs
- safety disclaimer docs
- onboarding/legal docs
- feature comparison tables
- CSV/XLSX docs if present
- UI reference folders
- localization docs
- branch-specific docs
- algorithm audit docs
- Watch audit docs
- iOS Bühlmann audit docs
- graphics/UI/text audit docs
- CNS/OTU docs
- chart truthfulness docs
- CCR/Rebreather docs
- CCR setpoint/diluent/bailout docs
- CCR export/PDF docs
- CCR checklist docs
- CCR limitations / safety docs

Run:

git status
git branch -a
git remote -v
git rev-parse --short HEAD
git fetch origin
git status -sb

Verify:

- MAIN build targets
- iOS target names
- Watch target names
- experimental isolation
- branch naming consistency
- bundle IDs consistency
- entitlement references
- docs referencing outdated architecture
- docs using outdated “COMPASSO” terminology
- docs implying certified decompression or certified dive-computer behavior
- docs implying Watch is a decompression computer
- docs implying iOS planner is certified decompression advice

==================================================
PHASE 1 — MAIN DOCUMENTATION UPDATE
==================================================

Update documentation to reflect CURRENT architecture.

A. MAIN BRANCH

Document MAIN as stable production-oriented branch.

Features to document:

Watch MAIN:
- Diving mode
- Apple Watch app
- live depth/runtime/temperature/ascent UI
- TTV informational index semantics
- manual start from Live screen
- automatic depth-triggered start
- legal onboarding
- depth safety discouragement
- inline ascent alarms
- compact GPS overlays
- GPS finalization
- active draft restore
- pending finalization restore
- BUSSOLA navigation
- Mission Mode semantics
- App Intents
- Action Button integration through Shortcuts
- Side Button limitation
- Watch logs
- Watch export
- Watch sync
- authenticated Watch sync if implemented
- User Images conditional visibility
- User Images inventory/delete sync if implemented
- sensor source / simulation policy
- Apple Watch Ultra entitlement notes

iOS MAIN:
- iOS Companion app
- logbook
- manual dive editing
- dashboard / analysis
- Watch sync
- planner
- Base / Deco / Technical planner modes
- Bühlmann ZHL-16C planning reference
- multigas / trimix / helium
- GF support
- environment-aware pressure model
- repetitive planning reference state
- gas ledger
- CNS/OTU reference estimates
- CNS descent+bottom 15% rule
- PIANO / CURVA BÜHLMANN / GRAFICI
- tissue-history chart if implemented
- NDL reference curve if retained
- depth profile chart if implemented
- planner export/share semantics
- CCR / Rebreather planner if implemented
- CCR setpoint workflow
- diluent gas documentation
- bailout gas documentation
- CCR bailout transition assumptions
- CCR CNS/OTU documentation
- CCR tissue/narcosis documentation
- CCR checklist/PDF/export documentation
- CCR external validation requirements
- reference-only/non-certified positioning

B. EXPERIMENTAL BRANCHES

Document separately:
- Snorkeling
- Apnea
- Buddy Assist
- exploration concepts

Clearly mark:
- experimental
- not production-ready
- isolated from MAIN runtime
- not automatically merged into MAIN
- excluded from MAIN build targets unless verified otherwise

C. SAFETY PHILOSOPHY

Document:
- NOT a certified dive computer
- no decompression authority
- Watch TTV is not NDL/TTS/deco
- iOS Bühlmann planner is reference-only
- CCR/Rebreather planner is reference-only if implemented
- CCR planner is not a certified CCR controller and does not monitor live loop PPO2
- CNS/OTU are reference estimates
- GPS surface-only behavior
- depth-limit discouragement philosophy
- underwater non-blocking warning strategy
- no hidden critical metrics underwater
- haptics philosophy
- Mission Mode invariant semantics
- Action Button limitations
- Side Button limitations
- sensor source/simulation limitations
- Apple Watch Ultra entitlement limitations

D. UI / UX DESIGN SYSTEM

Document:
- premium dark/neon Watch style
- dark marine iOS companion style
- underwater readability philosophy
- large touch targets
- inline warning philosophy
- BUSSOLA terminology
- no full-screen underwater warnings
- compact Mission Mode indicator
- depth safety visual states
- iOS Planner PIANO / CURVA BÜHLMANN / GRAFICI structure
- CNS/OTU warning display
- gas ledger visual conventions
- CCR setpoint/diluent/bailout visual conventions if implemented
- CCR bailout/standby visual conventions
- chart truthfulness conventions

E. BUILD / RELEASE

Document:
- XcodeGen
- bundle IDs
- Watch companion architecture
- entitlement requirements
- Apple Watch Ultra depth entitlement requirements
- TestFlight process
- App Store risks
- internal QA requirements
- physical-device validation requirements
- paired Watch/iPhone validation
- external Bühlmann validation requirement
- external CCR/Rebreather validation requirement if CCR exists
- CCR-specific safety/legal review requirement
- accessibility QA requirement
- underwater validation requirement

==================================================
PHASE 2 — README STRATEGY UPDATE
==================================================

README must include/update:

1. Project overview
2. Supported platforms
3. MAIN vs experimental overview
4. Branch structure
5. Branch strategy
6. Build instructions
7. XcodeGen instructions
8. Apple entitlement notes
9. Safety disclaimer
10. UI references
11. Feature matrix link
12. Watch/iPhone sync overview
13. Authenticated sync note if implemented
14. User Images sync note if implemented
15. Subsurface export notes
16. iOS Planner overview
17. Bühlmann planner reference-only positioning
18. CNS/OTU note
19. Known limitations
20. Release readiness status
21. TestFlight notes
22. App Store notes

Add/update section:
“Branch Strategy”

Explain:
- MAIN = stable production-oriented
- experimental = isolated feature development
- UI alignment must not change business logic
- Diving mode stability has highest priority
- experimental features never automatically merged into MAIN
- documentation changes must not merge experimental runtime code into MAIN

==================================================
PHASE 3 — FEATURE MATRIX UPDATE
==================================================

Find:
- Excel
- CSV
- Markdown feature tables

Update without deleting rows.

Create/update:

Docs/DIR_DIVING_Feature_Comparison.csv

Columns:
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

Statuses:
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

Separate rows for:
- Watch MAIN
- Watch Experimental
- iOS MAIN
- iOS Experimental

Include:
- Diving
- Snorkeling
- Apnea
- Buddy
- Planner
- Base Planner
- Deco Planner
- Technical Planner
- Bühlmann ZHL-16C
- Tissue-history chart
- NDL reference curve
- CNS/OTU
- Gas ledger
- Sync
- Authenticated sync
- User Images
- Export
- GPS
- BUSSOLA
- Mission Mode
- App Intents
- Action Button
- onboarding
- legal
- depth safety
- haptics
- cloud/sync
- accessibility
- CCR / Rebreather
- CCR Setpoint
- CCR Diluent
- CCR Bailout
- CCR Bailout transition
- CCR CNS/OTU
- CCR Tissue Loading
- CCR Narcotic Loading / END
- CCR Checklist
- CCR PDF/Share
- CCR Unit Conversion
- CCR External Validation
- TestFlight readiness

==================================================
PHASE 4 — UX / AUDIT DOCUMENT ALIGNMENT
==================================================

Update all audit/readiness docs to align with current state:

Watch:
- ascent inline warning architecture
- no full-screen underwater warnings
- GPS compact overlays
- GPS finalization
- active draft/pending finalization
- App Intents catalog
- Action Button philosophy
- Side Button truthful limitations
- legal onboarding revision
- depth-limit discouragement
- Mission Mode semantics
- sensor source/simulation policy
- authenticated sync if implemented
- User Images conditional visibility and inventory/delete sync if implemented

iOS:
- iOS three-mode planner
- Bühlmann multigas readiness
- tissue-history curve
- decompression/ascent table
- depth-profile chart
- CNS/OTU and 15% rule
- gas ledger
- repetitive planning
- environment assumptions
- chart truthfulness
- planner reference-only disclaimers
- CCR/Rebreather reference-only disclaimers
- CCR not-a-controller / not-live-loop-monitoring disclaimers

Ensure all audits consistently reflect:
- current MAIN state
- current readiness
- current risks
- current App Store blockers
- current TestFlight blockers
- remaining external validation needs

==================================================
PHASE 5 — BRANCH ALIGNMENT STRATEGY
==================================================

Inspect ALL local and remote branches.

For each branch:
- divergence from MAIN
- missing docs
- stale docs
- stale screenshots
- stale feature matrices
- stale release notes
- experimental runtime leakage risk
- branch purpose clarity

Handle if present:
- main
- main-iOS
- watch-main
- watch-experimental
- ios-experimental
- codex/*
- feature/*
- backup/*
- release/*

Do NOT:
- force-push
- delete branches
- squash history
- merge unsafe runtime code
- merge experimental runtime code into MAIN

If branch docs are stale:
- update branch documentation only if safe.
- otherwise report recommended update.

==================================================
PHASE 6 — MERGE / CONFLICT POLICY
==================================================

If merge conflicts exist, resolve documentation conflicts conservatively.

Preserve priority:
1. buildable code
2. stable Diving functionality
3. latest UI references
4. latest underwater warning UX
5. latest Bühlmann planner docs
6. latest CNS/OTU docs
7. latest Snorkeling/Apnea docs
8. latest release docs
9. latest audits
10. experimental isolation

Never overwrite:
- BUSSOLA terminology
- inline warning strategy
- depth-limit philosophy
- Watch sync documentation
- authenticated sync documentation
- User Images source-of-truth docs
- planner non-certified disclaimer
- CNS/OTU reference-only disclaimer
- latest legal disclaimers
- release/TestFlight docs

==================================================
PHASE 7 — PR INSPECTION
==================================================

If PRs exist:
- inspect
- summarize
- evaluate merge safety

For each PR:
- branch
- affected files
- runtime risk
- documentation risk
- experimental leakage risk
- merge recommendation
- required QA

Do NOT auto-merge unsafe PRs.
Do NOT auto-merge runtime changes.
Do NOT auto-merge experimental branches.

==================================================
PHASE 8 — GIT SAFETY
==================================================

Before branch-wide changes:
- git status
- optional backup branch:
  backup/docs-alignment-YYYYMMDD

Commit documentation separately from conflict fixes.

Suggested commit messages:
- docs: align DIR DIVING architecture and release documentation
- docs: update feature comparison matrix and branch strategy
- docs: update Watch safety and TestFlight readiness docs
- docs: update iOS Bühlmann planner documentation
- docs: update CNS OTU and chart truthfulness references
- docs: align snorkeling apnea experimental specifications
- merge: resolve documentation conflicts conservatively

Do not commit if:
- runtime code was modified unexpectedly
- Watch/iOS algorithm files changed unexpectedly
- experimental files leaked into MAIN
- build/project consistency cannot be verified

==================================================
PHASE 9 — BUILD / PROJECT CONSISTENCY
==================================================

After documentation alignment verify:
- project.yml valid
- README build instructions accurate
- bundle IDs accurate
- entitlement references accurate
- XcodeGen instructions current
- MAIN build paths correctly documented
- iOS target documented
- Watch target documented
- test targets documented
- experimental isolation documented

Do not run build unless specifically available in environment.

If on macOS and build validation is requested/appropriate, run:

xcodegen generate

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" -destination 'platform=iOS Simulator,name=iPhone 17' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch App" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' build

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" -destination 'platform=iOS Simulator,name=iPhone 17' test

xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving Watch Algorithm Tests" -destination 'platform=watchOS Simulator,name=Apple Watch Ultra 2 (49mm)' test

If simulators are unavailable, use available simulators and document them.

On Windows:
- DO NOT run xcodegen.
- DO NOT run xcodebuild.
- Perform static consistency inspection only.
- Document that macOS validation remains required.

==================================================
PHASE 10 — DOCUMENTATION INDEX / NAVIGATION
==================================================

Create or update a documentation index if missing:

Docs/README.md

It must link to:
- project overview
- safety philosophy
- Watch MAIN docs
- iOS Companion docs
- iOS Bühlmann planner docs
- CNS/OTU docs
- chart truthfulness docs
- CCR/Rebreather docs
- CCR setpoint/diluent/bailout docs
- CCR export/PDF docs
- CCR checklist docs
- CCR limitations / safety docs
- release/TestFlight docs
- feature matrix
- UI reference docs
- audit reports
- experimental docs

Ensure naming is consistent and stale duplicate docs are marked superseded instead of deleted.

==================================================
PHASE 11 — FINAL REPORT REQUIRED
==================================================

Create:

Docs/DIR_DIVING_DOCUMENTATION_BRANCH_ALIGNMENT_REPORT.md

The report must include:

A. Files updated
B. Docs created
C. Docs marked superseded
D. README changes
E. Feature matrix changes
F. Branches inspected
G. Branches updated
H. Conflicts found
I. Conflicts resolved
J. PRs inspected
K. PRs safe to merge
L. PRs requiring manual review
M. Remaining documentation gaps
N. Remaining release blockers
O. Remaining TestFlight blockers
P. Remaining App Store blockers
Q. Suggested next commits
R. Risks / assumptions
S. Experimental isolation confirmation
T. MAIN stability confirmation
U. Watch documentation alignment confirmation
V. iOS Bühlmann planner documentation alignment confirmation
W. CNS/OTU documentation alignment confirmation
X. Chart truthfulness documentation confirmation
Y. CCR/Rebreather documentation alignment confirmation
Z. CCR external validation documentation confirmation
AA. CCR safety disclaimer confirmation
Y. Git status before/after
Z. Push status if performed

==================================================
PHASE 12 — FINAL RULES
==================================================

If unsure whether a change affects runtime behavior:
- DO NOT change code
- add TODO documentation
- report uncertainty

DO NOT:
- redesign UI
- change business logic
- alter dive algorithms
- alter planner algorithms
- alter Bühlmann math
- alter CNS/OTU math
- alter sync algorithms
- alter persistence
- accidentally merge experimental runtime code into MAIN
- force-push
- delete branches

This task is primarily:
- documentation alignment
- release readiness alignment
- branch consistency
- repository consistency
- audit consistency
- Git safety
- local Git update
- remote Git push only if explicitly safe

FINAL OUTPUT:
After completion, output only:
- files updated
- docs created
- feature matrix status
- git commits created
- push status
- remaining blockers
- CCR/Rebreather documentation status
- CCR external validation documentation status

==================================================
PHASE 1B — 2026 ROADMAP DOCUMENTATION ALIGNMENT
==================================================

Additional features to document and align:

iOS:
- Ratio Deco planner
- Ratio Deco presets (1:1, 2:1, Custom)
- Bühlmann vs Ratio Deco comparison mode
- Ratio Deco PDF export
- Planner share workflow
- Tissue Loading analytics
- Narcotic Loading analytics
- PPN2
- END
- Controlling compartment
- Tissue timeline
- Planner ↔ Checklist synchronization
- My Equipment templates
- REC / TEC templates
- Task items
- GAS items
- DIR badge logic
- READY badge logic
- FIELD removal
- Manual dive entry/edit/export
- Image transfer to Watch
- Image conversion warnings
- PDF checklist export
- PDF Dive Pack export

Apple Watch:
- Start Dive button
- Auto-start >1 m
- Multiple reminders
- Recurring reminders
- Reminder messages
- Reminder haptics
- Reminder overlay
- Image viewing before dive
- Mission Mode
- Developer Sensor Source menu

==================================================
PHASE 3B — FEATURE MATRIX EXPANSION
==================================================

Add/update rows for:
- Ratio Deco
- Tissue Loading
- Narcotic Loading
- Planner Comparison Mode
- Manual Dive
- My Equipment
- Task Checklist
- DIR Badge
- Reminder Engine
- Dive Start Button
- Image Transfer
- Image Conversion
- Planner PDF
- Checklist PDF
- Dive Pack PDF

==================================================
PHASE 4B — ALGORITHM DOCUMENTATION ALIGNMENT
==================================================

Verify documentation correctly describes:
- Air mode
- EAN mode
- Trimix mode
- O2 mode
- MOD auto-update
- PPO2 step 0.1
- Dalton validation
- Back Gas
- Travel Gas
- Deco Gas
- Bailout Gas

==================================================
PHASE 4C — TISSUE & NARCOSIS DOCUMENTATION
==================================================

Document:
- 16 Bühlmann compartments
- Tissue loading chart
- Controlling compartment
- Tissue timeline
- PPN2 chart
- END chart
- Planner integration
- Logbook integration
- Informational-only positioning

==================================================
PHASE 4D — CHECKLIST DOCUMENTATION
==================================================

Document:
- Equipment items
- Task items
- Gas items
- Back Gas
- Travel
- Deco Stage
- Bailout
- GAS switch behavior
- Template workflow
- Planner synchronization

==================================================
PHASE 4E — REMINDER DOCUMENTATION
==================================================

Document:
- Multiple reminders
- Single reminders
- Recurring reminders
- Reminder limits
- Reminder runtime semantics
- Reminder overlay behavior
- Reminder haptics



==================================================
PHASE 1C — CCR / REBREATHER DOCUMENTATION ALIGNMENT
==================================================

Add or update documentation for CCR / Rebreather & Co. if the feature exists in MAIN or is described in the roadmap.

Create or update:

- Docs/CCR_REBREATHER_PLANNER.md
- Docs/CCR_REBREATHER_LIMITATIONS.md
- Docs/CCR_REBREATHER_SAFETY_DISCLAIMER.md
- Docs/CCR_REBREATHER_VALIDATION_PLAN.md
- Docs/CCR_REBREATHER_CHECKLIST_SYNC.md
- Docs/CCR_REBREATHER_EXPORT_POLICY.md

Document:

1. CCR / Rebreather scope
   - reference-only planning
   - not a certified CCR controller
   - not a live PPO2 monitor
   - not a replacement for CCR handset/HUD/controller
   - not a replacement for manufacturer procedures or formal CCR training

2. CCR inputs
   - low setpoint
   - high setpoint
   - setpoint switch depth
   - diluent gas
   - bailout gas
   - bailout switch depth
   - CCR environment assumptions

3. CCR calculations
   - Bühlmann integration if implemented
   - setpoint-based oxygen exposure
   - setpoint-based CNS/OTU estimates
   - diluent/inert-based tissue loading assumptions
   - diluent/inert-based narcotic loading / END assumptions
   - open-circuit bailout transition assumptions
   - gas ledger assumptions
   - limitations and unsupported cases

4. CCR validation
   - setpoint validation
   - diluent validation
   - bailout MOD/PPO2 validation
   - bailout switch-depth clamp to MOD
   - CCR external validation requirement
   - no false release-hard claim without validation

5. CCR UX / output
   - Planner display
   - tissue/narcosis charts
   - warnings
   - checklist sync
   - PDF/share/export
   - manual dive/logbook representation

6. CCR release gating
   - internal TestFlight requirements
   - external TestFlight requirements
   - App Store review language
   - legal/safety review requirement
   - external CCR validation pending status

==================================================
PHASE 3C — CCR FEATURE MATRIX EXPANSION
==================================================

Add/update rows in `Docs/DIR_DIVING_Feature_Comparison.csv` for:

- CCR / Rebreather Planner
- CCR low setpoint
- CCR high setpoint
- CCR setpoint switch depth
- CCR diluent gas
- CCR bailout gas
- CCR bailout transition
- CCR Bühlmann integration
- CCR CNS/OTU
- CCR Tissue Loading
- CCR Narcotic Loading / END
- CCR Gas Ledger
- CCR Checklist Sync
- CCR Manual Dive
- CCR PDF Export
- CCR Share
- CCR Unit Conversion
- CCR Validation Plan
- CCR Safety Disclaimer
- CCR External Validation

Use statuses:
- Implemented
- Partial
- Planned
- Blocked by external validation
- Requires physical QA
- Requires legal/safety review
- Reference-only

==================================================
PHASE 4F — CCR DOCUMENTATION TRUTHFULNESS AUDIT
==================================================

Verify all CCR docs:

- do not claim certified decompression planning
- do not claim certified CCR control
- do not claim live loop PPO2 monitoring
- do not claim manufacturer-procedure replacement
- clearly separate setpoint PPO2 from gas FO2 PPO2
- clearly separate diluent from bailout
- clearly explain OC bailout assumption
- clearly state external validation status
- clearly explain limitations of CCR PDF/share/export
- clearly explain CCR checklist sync behavior
- clearly explain CCR manual dive/logbook behavior if present

