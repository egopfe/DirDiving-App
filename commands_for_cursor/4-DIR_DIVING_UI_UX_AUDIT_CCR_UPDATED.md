# 4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED

## CURSOR / CODEX COMMAND — DIR DIVING COMPLETE UI / UX / ACCESSIBILITY / RELEASE READINESS AUDIT UPDATED WITH CCR / REBREATHER & CO.

You are working on the DIR DIVING repository.

## TARGET

ONLY branch `main`.

## TARGET APPS

1. Apple Watch MAIN
   - DIRDiving Watch App

2. iOS Companion MAIN
   - DIRDiving iOS

## TASK TYPE

FULL UI / UX / INTERACTION / ACCESSIBILITY / RELEASE READINESS AUDIT ONLY.

This is the **4th audit command** in the DIR DIVING recurring audit sequence.

It must be executed after:

1. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`
2. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`
3. `3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`

This audit focuses on **UI/UX readiness**, not mathematical remediation.

## SOURCE / BASE COMMAND

This command updates and extends:

`4-COMANDO_DIR_DIVING_UI_UX_AUDIT_COMMAND_COMPLETE_v2.md`

The original command already covered:

- iOS Companion
- Apple Watch Companion
- Planner
- Ratio Deco
- Tissue & Narcosis
- Checklist
- PDF / Share
- Image Transfer
- Manual Dive Entry
- Localization
- Accessibility
- Release Readiness

This updated version adds the latest CCR / Rebreather & Co. developments and keeps the same audit-only philosophy.

---

# OBJECTIVE

Perform a complete and deep **UI / UX / interaction / accessibility / localization / release readiness audit** of DIR DIVING MAIN.

The audit must verify whether every implemented or planned MAIN feature is:

- reachable
- understandable
- visually consistent
- safe to use
- accessible
- localized
- correctly gated
- correctly documented
- not misleading
- compatible with the DIR DIVING non-certified positioning
- coherent across Apple Watch and iOS Companion
- ready for internal TestFlight
- ready for external TestFlight
- ready for App Store only after required physical/external QA

The audit must specifically include latest developments:

- CCR / Rebreather planning
- setpoint workflow
- diluent gas
- bailout gas
- CCR open-circuit bailout transition
- CCR CNS / OTU display
- CCR tissue loading
- CCR narcosis / END
- CCR gas role UI
- CCR Planner ↔ Checklist sync
- CCR PDF / Share output
- CCR Logbook / Manual Dive representation
- CCR Unit Conversion
- Planner Base / Deco / Technical tabs
- MOD / PPO2 / switch-depth auto-clamp UI
- Ratio Deco UX
- Tissue Loading UX
- Narcotic Loading UX
- Watch dive start UX
- Watch reminders UX
- Watch image transfer / image inventory / image deletion UX
- Mission Mode UX
- Developer Sensor Source UX
- Apple Watch branding / octopus icon UX
- Safety overlays
- Localization EN / IT
- Accessibility
- TestFlight / App Store UI readiness

---

# ABSOLUTE RULES

## DO NOT

- modify source code
- refactor
- fix issues
- change business logic
- change algorithmic logic
- change Bühlmann math
- change CCR math
- change Ratio Deco logic
- change TTV semantics
- change Mission Mode semantics
- change Watch dive/depth/ascent logic
- change UI graphics
- redesign screens
- change visual identity
- touch experimental branches
- touch Apnea experimental
- touch Snorkeling experimental
- touch Buddy Assist experimental
- touch Exploration Lab
- modify files excluded from `project.yml`
- weaken safety/legal disclaimers
- introduce certified dive-computer claims
- introduce certified decompression-planner claims
- claim CCR planner is certified
- claim Apple Watch is a certified dive computer
- claim physical Watch Ultra underwater validation passed unless actually executed
- claim external Subsurface validation passed unless actually executed
- claim App Store readiness if store assets / entitlement / physical QA are missing

## PRESERVE

- MAIN-only scope
- current Apple Watch dark / neon underwater UI
- current iOS dark marine / cyan UI
- current DIR DIVING visual identity
- octopus branding
- BUSSOLA terminology
- no COMPASSO terminology
- Mission Mode as DIR DIVING runtime / UI profile only
- TTV as informational index only
- iOS Planner as reference-only
- non-certified diving companion positioning
- Base / Deco / Technical Planner architecture
- mode-specific input projection
- mode-specific result gating
- manual / no-depth truthfulness
- metric internal storage
- legal/safety onboarding
- iOS cloud backup opt-in if implemented
- Watch as source of truth for Watch-stored images
- signed ACK / HMAC / peer-secret sync trust model
- tombstone / conflict policy
- physical QA gates as external evidence requirements

---

# PHASE 0 — PREFLIGHT

1. Confirm current branch:

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

- all targets
- source folders
- excluded files
- test targets
- entitlements
- bundle IDs
- Watch / iOS companion relationship

6. Confirm MAIN targets:

- `DIRDiving Watch App`
- `DIRDiving iOS`

7. Confirm experimental exclusions.

Watch excluded should include:

- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- Buddy / Exploration models and services if not part of MAIN

iOS excluded should include:

- `iOSApp/Models/ExplorationModels.swift`
- `iOSApp/Models/BuddyExperimentalModels.swift`
- `iOSApp/Services/ExplorationPlanningStore.swift`
- `iOSApp/Services/BuddyExperimentalStore.swift`
- `iOSApp/Views/ExplorationCenterView.swift`
- `iOSApp/Views/ExperimentalFutureConceptsView.swift`
- `iOSApp/Views/BuddyExperimentalView.swift`

8. Run build only if environment allows:

```bash
xcodegen generate

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

9. Do not fix build failures. Record them.

10. Before auditing, print:

- branch
- commit
- dirty files
- targets found
- experimental exclusions confirmed
- build status
- files / directories to inspect

STOP if branch is not `main`.

---

# PHASE 1 — GLOBAL UI / UX INVENTORY

Create a complete inventory of all user-facing UI flows.

Group by:

## Apple Watch

- onboarding / legal gate
- live dive screen
- manual start
- automatic start
- ascent gauge
- safety overlays
- surfacing speed warning
- reminders
- compass / BUSSOLA
- Mission Mode
- Settings
- Developer Sensor Source
- Info
- Dive log
- Dive detail
- Export
- user images
- image inventory / delete if implemented
- App Intents / Action Button help
- errors / empty states

## iOS Companion

- onboarding / legal gate
- Logbook
- Dive detail
- Manual dive editor
- Analysis
- Planner Base
- Planner Deco
- Planner Technical
- CCR Planner / Rebreather workflow if implemented
- Ratio Deco
- Tissue Loading
- Narcotic Loading
- Checklist
- Equipment
- Watch sync
- Cloud backup / sync
- Image transfer / Watch inventory / delete
- PDF / Share
- More / Settings
- Localization / Units
- Error / empty states

For each flow list:

- entry point
- visibility
- navigation path
- exit path
- save / confirm action
- destructive actions
- persisted state
- sync state
- localized copy
- accessibility labels
- readiness %
- blockers

---

# PHASE 2 — iOS PLANNER BASE / DECO / TECHNICAL UX AUDIT

Audit whether the Planner tabs are real and clear from the user's perspective.

## Base

Verify:

- one-gas workflow
- Air / Nitrox simple gas UX
- no confusing travel / bailout / multi-deco controls
- no full technical chart overload
- clear Base-mode limitation copy
- clear “switch to Deco / Technical” guidance when profile exceeds Base
- MOD and PPO2 visible and understandable
- reference-only disclaimer visible

## Deco

Verify:

- bottom gas + one deco gas workflow
- one-deco-gas limit clear
- no hidden multi-deco confusion
- simplified Bühlmann output
- clear stop table / summary
- clear NDL reference scope if visible
- clear gas switch depth UX
- MOD / PPO2 warnings visible and understandable
- reference-only disclaimer visible

## Technical

Verify:

- full multigas workflow
- bottom gas
- travel gas
- deco gases
- bailout
- trimix
- switch depths
- manual GF if supported
- full Bühlmann output
- tissue / compartment details
- gas ledger
- CNS / OTU
- END / EAD
- gas density if implemented
- warnings visible and prioritized
- reference-only disclaimer visible

## Mandatory UI checks

- tab labels are localized EN / IT
- selected tab is visually obvious
- tab state is accessible to VoiceOver
- hidden advanced data does not confuse simpler modes
- switching modes does not visually erase user confidence
- switching modes does not imply data was deleted
- calculations and displayed result complexity match the active tab

Output:

- Base UX readiness %
- Deco UX readiness %
- Technical UX readiness %
- Planner mode UX readiness %

---

# PHASE 3 — CCR / REBREATHER UX AUDIT

Audit all CCR / Rebreather & Co. UI / UX if implemented or partially implemented.

## CCR entry point

Verify:

- CCR / Rebreather mode is reachable only where appropriate
- not mixed confusingly with OC mode
- clear label:
  - `CCR`
  - `Rebreather`
  - `Closed Circuit`
- clear distinction from:
  - Open Circuit
  - Bailout
  - Deco gas
  - Diluent

## CCR input UX

Verify user can understand and configure:

- setpoint low
- setpoint high
- setpoint switch depth
- diluent gas
- bailout gas
- bailout switch depth
- CCR oxygen exposure
- CCR CNS / OTU
- CCR tissue loading
- CCR narcosis / END
- loop / diluent assumptions if shown
- open-circuit bailout assumptions

## CCR safety copy

Verify the UI clearly states:

- CCR planning is reference-only
- this app is not a certified CCR controller
- this app does not monitor live loop PPO2
- this app does not replace CCR handset / controller / HUD
- setpoint values are assumed planning values
- bailout planning is indicative
- diver training and CCR manufacturer procedures remain primary

## CCR Planner results

Verify:

- CCR plan output clearly separates:
  - CCR setpoint phase
  - diluent role
  - OC bailout phase
  - deco phase if any
- setpoint PPO2 is visually distinct from gas FO2 PPO2
- CNS / OTU labels are unambiguous
- tissue loading chart indicates CCR setpoint source
- narcosis chart uses diluent / inert gas logic
- no fake data
- no static chart presented as real

## CCR error states

Verify clear warnings for:

- missing setpoint
- impossible setpoint
- missing diluent
- hypoxic diluent
- bailout missing
- bailout MOD exceeded
- invalid bailout switch
- setpoint above limits
- oxygen exposure high
- CCR profile unsupported by current engine

Output:

- CCR UX readiness %
- CCR safety-copy readiness %
- CCR planner-result readiness %
- CCR release-readiness %

---

# PHASE 4 — MOD / PPO2 / DALTON / SWITCH-DEPTH UX AUDIT

Verify:

- MOD auto recalculates after O2 change
- MOD auto recalculates after PPO2 change
- MOD respects PlannerEnvironment
- displayed MOD equals used MOD
- Planner, Bühlmann, Ratio Deco and CCR use same MOD source
- PPO2 step is exactly 0.1 where required
- no hidden 0.05 increment remains
- Air locks correct gas fractions
- EAN allows O2-only editing
- Trimix allows O2 + He editing
- O2 locks 100%
- switchDepthMeters for non-bottom gases clamps to MOD
- user can select shallower switch depth than MOD
- user cannot persist switch depth deeper than MOD
- UI does not freeze with repeated +/- taps
- warnings are visible without covering essential planner data

CCR-specific:

- setpoint PPO2 is not confused with FO2-based MOD
- diluent MOD / gas safety remains visible
- bailout MOD / switch-depth clamp visible
- CCR bailout switch depth cannot exceed bailout MOD
- setpoint warning copy is distinct from gas MOD warning copy

Output:

- MOD / PPO2 UX readiness %
- Dalton validation UX readiness %
- switch-depth UX readiness %
- CCR MOD / setpoint UX readiness %

---

# PHASE 5 — RATIO DECO UX AUDIT

Audit:

- Ratio Deco mode entry point
- presets:
  - 1:1
  - 2:1
  - Custom
- custom ratio controls
- comparison mode
- Bühlmann primary validation layer
- overlay chart
- warnings
- export integration
- accessibility

Verify:

- Ratio Deco is clearly presented as heuristic
- Bühlmann remains primary / validation reference
- Ratio Deco does not appear certified
- Ratio Deco can be compared without confusing user
- gas compatibility warnings remain visible
- Ratio Deco respects MOD / PPO2
- CCR profiles do not incorrectly use OC Ratio Deco unless explicitly supported and labelled

Output:

- Ratio Deco UX readiness %

---

# PHASE 6 — TISSUE LOADING UX AUDIT

Audit:

- tissue loading cards
- 16 compartments
- grouped compartments:
  - 1–4
  - 5–8
  - 9–12
  - 13–16
- controlling compartment
- tissue timeline
- ceiling
- GF-relative loading
- M-value-relative loading
- Planner integration
- Logbook integration
- Manual Dive integration
- CCR integration if implemented

Verify:

- chart is model-backed
- no fake data
- no static chart shown as real
- axes are labeled
- units are clear
- colors are consistent
- legends are readable
- tooltips are readable
- accessibility summary exists
- Base / Deco / Technical visibility is appropriate
- CCR setpoint / diluent tissue source is clear

Output:

- Tissue Loading UX readiness %
- CCR Tissue UX readiness %

---

# PHASE 7 — NARCOTIC LOADING / END UX AUDIT

Audit:

- PPN2
- END
- active gas integration
- runtime integration
- Planner integration
- Logbook integration
- Manual Dive integration
- CCR integration if implemented

Verify:

- END is clearly labelled
- narcotic assumptions are explained
- helium effect is shown clearly if Trimix
- diluent / bailout logic is clear for CCR
- chart axes and units are clear
- warnings are understandable
- no narcotic chart is shown from missing/fake data

Output:

- Narcotic Loading UX readiness %
- CCR Narcosis UX readiness %

---

# PHASE 8 — GAS ROLE UX AUDIT

Audit gas roles across iOS Planner, Checklist, PDF and Watch sync:

- Back Gas
- Travel
- Decompression
- Bailout
- Diluent
- CCR bailout
- Oxygen
- Standby / unused planned gas

Verify:

- roles are visually distinct
- role labels are localized
- role meaning is clear
- gas cards show correct controls per role
- used gas vs unused gas is clear
- bailout is not included in scheduled consumption unless actually used
- diluent is not confused with breathed OC gas in CCR
- CCR bailout is clearly OC bailout
- gas role appears correctly in checklist
- gas role appears correctly in PDF/share
- gas role appears correctly in export if supported

Output:

- Gas Role UX readiness %
- CCR Gas Role UX readiness %

---

# PHASE 9 — CHECKLIST UX AUDIT

Audit:

- My Equipment
- REC templates
- TEC templates
- CCR templates if implemented
- Custom templates
- Equipment items
- Task items
- GAS items
- Back Gas
- Deco Stage
- Travel
- Bailout
- Diluent
- Oxygen cells / CCR tasks if implemented
- scrubber / sorb task if implemented
- READY badge
- DIR badge
- duplicate prevention
- Planner ↔ Checklist sync

Verify:

- Checklist → Planner sync clarity
- Planner → Checklist sync clarity
- stable IDs
- no duplicates
- manual user edits are preserved
- CCR checklist tasks are not shown unless relevant
- YES / NO boxes in PDF remain clear
- accessibility labels exist

Output:

- Checklist UX readiness %
- Planner ↔ Checklist UX readiness %
- CCR Checklist UX readiness %

---

# PHASE 10 — PDF / SHARE / EXPORT UX AUDIT

Audit:

- Planner PDF
- Briefing PDF
- Checklist PDF
- Dive Pack PDF
- Logbook export
- CSV export
- Subsurface export
- Share Sheet
- WhatsApp
- Mail
- AirDrop
- Files

Verify:

- planner mode label appears:
  - Base
  - Deco
  - Technical
  - CCR if applicable
- CCR setpoint / diluent / bailout info appears correctly
- gas plan is understandable
- deco plan is understandable
- Ratio Deco comparison appears correctly
- tissue and narcosis charts appear correctly if exported
- checklist YES / NO boxes are printable
- legal/reference-only disclaimers are present
- PDF does not imply certification
- share filenames are safe and meaningful
- exported values match UI
- exported units are clear

Output:

- PDF / Share UX readiness %
- CCR PDF readiness %
- Export UX readiness %

---

# PHASE 11 — IMAGE TRANSFER / WATCH IMAGE MANAGEMENT UX AUDIT

Audit:

- image selection on iOS
- image preprocessing
- resolution validation
- conversion warnings
- IT / EN localization
- Watch visibility before dive
- Watch visibility during dive
- Watch full-screen view
- Watch image list
- Watch image delete
- iOS Watch image inventory
- iOS delete request
- Watch ACK
- stale / unavailable Watch states

Verify:

- Watch remains source of truth
- iOS does not invent inventory
- iOS does not show delete success before Watch ACK
- bundled images cannot be deleted
- uploaded images are clearly user-managed
- error states are understandable
- image transfer does not affect dive metrics
- image UI is accessible

Output:

- Image Transfer UX readiness %
- Watch Image Inventory UX readiness %
- Image Delete UX readiness %

---

# PHASE 12 — WATCH DIVE START UX AUDIT

Audit:

- initial Live screen
- manual Start Dive button
- automatic dive start when depth > 1.0 m
- duplicate session prevention
- manual + automatic trigger collision handling
- restore after app relaunch
- active draft consistency
- Settings copy
- App Intent / Action Button start if implemented

Verify:

- user understands manual start
- user understands automatic start
- manual start does not look like fake sensor depth
- automatic mode availability is truthful
- simulator / fallback is clearly marked
- manual end behavior is understandable
- no critical info is hidden

Output:

- Dive Start UX readiness %

---

# PHASE 13 — WATCH REMINDERS UX AUDIT

Audit:

- multiple reminders support
- maximum configured reminders
- single reminder mode
- recurring reminder mode
- reminder scheduling persistence
- reminder runtime trigger accuracy
- message length validation
- IT / EN localization
- overlay rendering
- aggregation behavior
- haptic integration
- safety alert priority over reminders

Test visually / logically:

- 1 reminder
- 5 reminders
- 10 reminders
- simultaneous reminders
- reminder during alarm
- reminder during ascent warning
- reminder after pause / resume
- reminder after active draft restore
- reminder during Mission Mode

Verify:

- reminder overlay does not cover essential safety data
- safety alarms have priority
- text is readable underwater
- haptic behavior is not excessive
- accessibility labels exist

Output:

- Reminder UX readiness %

---

# PHASE 14 — MISSION MODE UX AUDIT

Verify Mission Mode does NOT alter:

- depth sampling
- runtime
- max depth
- average depth
- TTV
- ascent rate
- GPS capture
- safety alarms
- reminder timing
- sync payloads
- export values

Verify:

- Mission Mode icon visibility
- Mission Mode state visible
- Mission Mode persistence
- auto-enable on dive start if configured
- manual enable/disable clarity
- Apple Low Power Mode wording is truthful
- Settings copy is clear

Output:

- Mission Mode UX readiness %

---

# PHASE 15 — DEVELOPER SENSOR SOURCE UX AUDIT

Audit:

`Settings > Developer > Sensor Source`

Options:

- Automatic
- Apple Sensor
- Simulation

Verify:

- hidden behind developer unlock
- not exposed to public users
- simulation clearly identified
- simulation never active by default in release
- automatic remains production default
- fallback/mock state is visible if automatic resolves to mock
- Info screen explains actual resolved sensor source
- user cannot confuse simulation with real underwater depth

Output:

- Sensor Source UX readiness %

---

# PHASE 16 — WATCH ICON / BRANDING UX AUDIT

Verify:

- Apple Watch app icon updated
- iOS icon updated
- top-left octopus icon visible
- icon consistent across screens
- icon consistent underwater
- icon does not cover safety data
- Mission Mode icon near octopus is understandable
- branding is consistent in screenshots / PDF / onboarding if applicable

Output:

- Branding UX readiness %

---

# PHASE 17 — MANUAL DIVE UX AUDIT

Audit:

- manual dive creation
- max depth
- average depth
- GPS start
- GPS end
- dive profile
- equipment
- gas data
- bar in
- bar out
- deco notes
- CCR manual dive fields if implemented
- tissue integration
- narcosis integration
- export consistency
- logbook consistency

Verify:

- manual/no-depth sessions are truthful
- pressure units are clear
- editing does not create stale detail view
- CCR manual dive does not imply live CCR data
- missing fields have clear empty states

Output:

- Manual Dive UX readiness %
- CCR Manual Dive UX readiness %

---

# PHASE 18 — LOCALIZATION UX AUDIT

Audit EN / IT localization for:

- onboarding
- Watch Live
- Watch Settings
- Watch reminders
- Mission Mode
- Sensor Source
- Planner Base / Deco / Technical
- CCR / Rebreather
- Ratio Deco
- Tissue
- Narcosis
- MOD / PPO2 / Dalton
- Checklist
- PDF / Share
- Manual Dive
- Image Transfer
- Cloud / Sync
- Error states

Verify:

- no obvious Italian appears in EN locale
- no obvious English appears in IT locale
- technical acronyms remain consistent:
  - MOD
  - PPO2
  - CNS
  - OTU
  - GF
  - END
  - EAD
  - CCR
  - OC
  - RMV
  - SAC
- warning tone is clear
- labels fit compact Watch UI
- PDF/share text is localized

Output:

- Localization readiness %

---

# PHASE 19 — ACCESSIBILITY AUDIT

Audit:

- VoiceOver labels
- VoiceOver hints
- selected tab state
- chart summaries
- button labels
- destructive action confirmation
- dynamic type
- color contrast
- reduced motion
- touch targets
- Watch tap targets
- underwater readability
- glove usability
- haptic/visual redundancy
- warning priority

Specifically check:

- Planner tabs
- CCR setpoint controls
- gas cards
- MOD / switch-depth controls
- Ratio Deco chart
- Tissue chart
- Narcosis chart
- Checklist
- Watch reminders
- Watch image delete
- Watch live safety overlays
- Mission Mode indicator

Output:

- Accessibility readiness %

---

# PHASE 20 — UNIT CONSISTENCY UX AUDIT

Verify globally:

- meters ↔ feet
- bar ↔ psi
- Celsius ↔ Fahrenheit
- m/min ↔ ft/min
- liters if displayed
- cubic feet if displayed
- setpoint units / PPO2 units
- CCR diluent units
- bailout pressure units

Across:

- Planner
- CCR
- Charts
- Tissue
- Narcosis
- Logbook
- Checklist
- PDF
- CSV
- Watch Live
- Watch Settings
- Watch Dive Details
- Watch Export
- Reminders

Output:

- Unit Consistency UX readiness %

---

# PHASE 21 — ERROR / EMPTY / EDGE STATE UX AUDIT

Audit user-facing states for:

- no dives
- no Watch paired
- Watch unreachable
- no iCloud
- cloud backup off
- cloud backup too large
- sync pending
- sync failed
- invalid gas
- invalid CCR setpoint
- invalid MOD
- switch depth beyond MOD
- invalid environment
- no GPS
- no temperature
- no tissue data
- no narcosis data
- no images
- image delete failed
- image inventory stale
- export failed
- PDF failed
- CSV failed
- legal onboarding not accepted
- sensor unavailable
- simulation active

Verify:

- error text is clear
- recovery path exists
- no silent failure
- no scary false warning in simulator
- no success state before confirmation / ACK
- no empty view looks broken

Output:

- Error / Empty State readiness %

---

# PHASE 22 — RELEASE READINESS MATRIX

Provide readiness percentages for:

| Feature | Readiness |
|---|---:|
| iOS Companion UX | XX% |
| Apple Watch UX | XX% |
| Planner Base UX | XX% |
| Planner Deco UX | XX% |
| Planner Technical UX | XX% |
| CCR / Rebreather UX | XX% |
| Ratio Deco UX | XX% |
| MOD / PPO2 / Dalton UX | XX% |
| Switch Depth UX | XX% |
| Gas Role UX | XX% |
| Tissue Loading UX | XX% |
| Narcosis UX | XX% |
| Checklist UX | XX% |
| Planner ↔ Checklist UX | XX% |
| Manual Dive UX | XX% |
| PDF / Share UX | XX% |
| Image Transfer UX | XX% |
| Watch Image Inventory/Delete UX | XX% |
| Watch Reminder UX | XX% |
| Dive Start UX | XX% |
| Mission Mode UX | XX% |
| Sensor Source UX | XX% |
| Branding UX | XX% |
| Localization UX | XX% |
| Accessibility UX | XX% |
| Unit Consistency UX | XX% |
| Error / Empty State UX | XX% |
| Internal TestFlight UX Readiness | XX% |
| External TestFlight UX Readiness | XX% |
| App Store UX Readiness | XX% |
| Overall UI/UX Readiness | XX% |

---

# FINAL REPORT REQUIRED

Create:

`Docs/UI_UX_MAIN_AUDIT_CURRENT.md`

The report must include:

A. Executive Summary

- overall UX readiness %
- Watch UX readiness %
- iOS UX readiness %
- Planner UX readiness %
- CCR UX readiness %
- accessibility readiness %
- localization readiness %
- TestFlight UX readiness
- App Store UX readiness
- top blockers

B. Scope Confirmation

- branch
- commit
- targets
- experimental exclusions
- build status if run
- audit-only confirmation

C. Global Navigation Map

- iOS flows
- Watch flows
- unreachable screens
- dead ends
- hidden features
- missing entry points

D. Apple Watch UX Analysis

- Live
- Start Dive
- Reminders
- Images
- Mission Mode
- Sensor Source
- BUSSOLA
- Logbook
- Settings
- Haptics / Alerts
- Safety overlays

E. iOS Companion UX Analysis

- Logbook
- Manual Dive
- Analysis
- Planner
- CCR
- Ratio Deco
- Tissue / Narcosis
- Checklist
- PDF / Share
- Watch sync
- Cloud
- Images
- More / Settings

F. Planner UI/UX Analysis

- Base
- Deco
- Technical
- MOD/PPO2/switch-depth
- warnings
- result sections
- export/share

G. CCR / Rebreather UX Analysis

- setpoint
- diluent
- bailout
- CCR warnings
- CCR result clarity
- CCR disclaimers
- CCR integration

H. Accessibility Analysis

I. Localization Analysis

J. Error / Empty State Analysis

K. Readiness Matrix

L. Issue Matrix

For every issue:

- ID
- severity
- priority
- platform
- feature
- screen / file
- issue
- user impact
- safety impact
- accessibility impact
- proposed solution
- estimated effort
- regression risk
- acceptance criteria

M. Prioritized Action Plan

Group actions by:

1. P0 — must fix before compile/use
2. P1 — must fix before internal TestFlight
3. P2 — must fix before external TestFlight
4. P3 — must fix before App Store
5. P4 — post-release improvements

N. TestFlight UX Checklist

O. App Store UX Checklist

P. Screenshot / Marketing Asset Checklist

Q. Final Verdict

Answer clearly:

- Is the UI/UX ready for internal TestFlight?
- Is the UI/UX ready for external TestFlight?
- Is the UI/UX ready for App Store?
- What blocks 100% UX readiness?
- What must be fixed first?

---

# SUCCESS CRITERIA

The task is complete only if:

- no source code is modified
- no UI is modified
- no business logic is modified
- no algorithm is modified
- report is created at `Docs/UI_UX_MAIN_AUDIT_CURRENT.md`
- report includes all readiness percentages
- report includes CCR / Rebreather UX
- report includes Ratio Deco UX
- report includes Tissue / Narcosis UX
- report includes Checklist UX
- report includes PDF / Share UX
- report includes Image Transfer UX
- report includes Watch Reminder UX
- report includes Manual Dive UX
- report includes Localization UX
- report includes Accessibility UX
- report includes Unit Consistency UX
- report includes TestFlight / App Store readiness
- physical/external QA items are marked pending, not passed
- final git status confirms only docs/report changed

If anything cannot be fully analyzed:

- document the limitation
- explain why
- propose the exact next inspection step
