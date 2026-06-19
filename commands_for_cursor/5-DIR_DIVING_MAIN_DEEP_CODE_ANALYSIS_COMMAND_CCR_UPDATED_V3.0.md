# 5-DIR_DIVING_MAIN_DEEP_CODE_ANALYSIS_COMMAND_CCR_UPDATED_V3.0

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

## CURSOR / CODEX COMMAND — DIR DIVING MAIN COMPLETE DEEP CODE ANALYSIS / BUG / PERFORMANCE / SECURITY AUDIT UPDATED WITH CCR / REBREATHER & LATEST MAIN IMPLEMENTATIONS

**Command version:** 3.0  
**Updated for MAIN:** 2026-06-19  
**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only

You are working on the DIR DIVING repository.

## TARGET

ONLY branch `main`.

## TARGET APPS

1. Apple Watch MAIN  
   - DIRDiving Watch App

2. iOS Companion MAIN  
   - DIRDiving iOS

## TASK TYPE

FULL DEEP AUDIT ONLY.

This is the **5th audit command** in the DIR DIVING recurring audit sequence.

The filename must always retain the `5-` prefix. Future revisions must increment only the version suffix, for example `_V2.1`, `_V3.0`, while preserving this command's position in the recurring sequence.

It must be executed after:

1. `1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md`
2. `2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md`
3. the current versioned `3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED` command
4. `4-DIR_DIVING_UI_UX_AUDIT_CCR_UPDATED_V3.0.md`

This audit is a **deep code analysis** across MAIN, focused on bugs, crashes, data-loss risks, performance, security, privacy, persistence, sync, cloud, import/export, release risks and cross-feature integration regressions.

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

---

# OBJECTIVE

Perform a complete and deep static + build/test-supported code analysis of the entire MAIN codebase to identify:

1. Bugs
2. Crash risks
3. Data-loss risks
4. Race conditions
5. State-management bugs
6. Memory/performance bottlenecks
7. Battery/performance risks
8. SwiftUI update-loop risks
9. WatchConnectivity issues
10. Cloud/iCloud KVS issues
11. Security vulnerabilities
12. Privacy risks
13. Unsafe persistence
14. Unsafe import/export paths
15. Weak validation
16. Test gaps
17. Build/release risks
18. App Store/TestFlight risks
19. Algorithmic integration bugs
20. UI/UX functional bugs, only where caused by code/state logic
21. Planner Base / Deco / Technical regressions
22. MOD / PPO2 / switch-depth safety regressions
23. Watch image inventory/delete sync regressions
24. Mission Mode invariant regressions
25. Manual vs automatic dive-start regressions
26. Sensor source / simulation release-policy regressions
27. App Intents / Action Button legal-gate regressions
28. Cloud merge profile-conflict regressions
29. iCloud payload-size / sync cap regressions
30. External QA gaps that must not be falsely marked as passed
31. CCR / Rebreather planning regressions
32. CCR setpoint / diluent / bailout regressions
33. CCR CNS / OTU / tissue / narcosis regressions
34. CCR Ratio Deco / Buhlmann integration regressions
35. CCR cloud / sync / export / PDF regressions
36. Planner ascent-speed settings regressions
37. Dive Runtime ordering and decompression-stop presentation regressions
38. Emergency / Rock Bottom calculation and UI-state regressions
39. Schedule-aware gas-consumption regressions
40. Gas-ledger liters/bar conversion and presentation regressions
41. Technical average-depth gas-consumption isolation regressions
42. Repetitive-dive residual-tissue and chronology regressions
43. Structured Equipment mapping regressions
44. Operational checklist generation regressions
45. CCR checklist import/export role-mapping regressions
46. CCR bailout-scenario and gas-density regressions
47. Planner briefing-card encode/render/transfer/persistence regressions
48. Briefing-card stale-version and payload-routing regressions
49. Small-Watch critical-layout regressions
50. Reminder manual-dismiss/suppression regressions
51. Watch image-paging regressions
52. Localization/accessibility regressions introduced by recent UI changes

---

# OUTPUT

Create one detailed Markdown report:

```text
Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md
```

The report must include:

- executive summary
- readiness percentages
- all detected issues
- affected files/functions
- severity
- priority
- security impact
- privacy impact
- performance impact
- user impact
- safety impact
- CCR impact if relevant
- proposed fix
- estimated effort
- regression risk
- test strategy
- detailed action plan
- 7-day / 14-day / pre-TestFlight / pre-App-Store remediation roadmap
- separate future remediation command drafts at the end of the report

---

# CURRENT DEVELOPMENT CONTEXT TO RESPECT

The latest MAIN development context includes or may include the following. The audit must explicitly verify whether each item is correctly implemented, still partial, or missing.

## A. iOS Planner three-mode architecture

The Planner has or should have three real modes:

1. Base
2. Deco
3. Technical

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

Audit specifically for:

- hidden Technical gases accidentally used in Base or Deco
- Base / Deco result views showing too much technical detail
- Technical mode losing full multigas capability
- mode switching causing data loss
- mode switching preserving draft technical gases while excluding them from simpler calculations
- NDL preview using draft input instead of mode-projected input
- GasPlanningService preview using `.technical` validation instead of selected mode

## B. iOS Planner MOD / PPO2 / switch-depth behavior

The Planner should enforce the following behavior:

- Changing O2 percentage recalculates MOD.
- Changing max PPO2 recalculates MOD.
- Environment changes should recalculate MOD if altitude/salinity are supported.
- Non-bottom gases must clamp `switchDepthMeters` to the gas MOD.
- User may choose a switch depth shallower than MOD.
- User may not persist a switch depth deeper than MOD.
- MOD must be environment-aware through `PlannerEnvironment`.
- Existing helpers such as `PlannerMODValidator.modMeters(...)` or `GasMix.modMeters(environment:)` must be used.
- No duplicated MOD formula should be introduced.
- No recursive SwiftUI `.onChange` loops should exist.

Audit specifically for:

- stale MOD display after O2/PPO2 changes
- stale switch depth after O2/PPO2 changes
- persisted `switchDepthMeters > MOD`
- stepper allowing repeated increment beyond MOD
- O2 100% at PPO2 1.6 not clamping around 6 m
- non-bottom gas normalization not applied to travel/deco/bailout
- Base/Deco hidden gases still affecting calculations
- environment-aware MOD not used
- `.onChange(of: plannerCylinders)` or similar recursive state writes

## C. Known recent iOS algorithm audit themes

Audit for the following known high-priority areas:

- HIGH-001: cloud merge must not silently fuse divergent dive profiles.
- HIGH-002: NDL preview must use mode-projected input.
- PPO2 tolerance policy must be centralized.
- Base/Deco must validate `PlannerEnvironment`.
- `GasPlanningService` preview analysis must be mode-aware.
- share/export must include active Planner mode.
- cloud KVS payload size must be guarded.
- Subsurface external regression remains external QA.

## D. Apple Watch MAIN semantics

The Watch app must preserve these semantics:

- DIR DIVING Watch is not a certified dive computer.
- TTV is an informational live index, not NDL, TTS, or decompression obligation.
- Mission Mode is an internal UI/runtime profile only.
- Mission Mode must not alter depth, GPS, alarms, haptics, logging, sync, export, or calculations.
- Manual dive start is allowed from the Live screen and via App Intents only when legal onboarding is accepted.
- Settings may show manual-start information but must not falsely imply direct start if not implemented there.
- Automatic dive start is depth-triggered when the app is running and depth automation is available.
- Simulation sensor mode must not be silently active in public/release paths.
- App Intents
- Transit / Runtime / Deco Presentation
- Emergency / Rock Bottom
- Schedule-Aware Gas
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Operational Checklist
- Planner Briefing Cards
- Accessibility / Localization must not bypass legal/safety onboarding.
- Watch remains source of truth for Watch-stored user images.

## E. Watch image management latest scope

Audit the image-management system if present in MAIN:

- uploaded images can be deleted directly from Watch
- iOS Companion may request deletion of Watch-stored images
- Watch performs actual deletion and returns ACK
- iOS must not show success before Watch ACK
- full Watch image inventory may be synced to iOS
- iOS should list Watch-uploaded images from Watch-sourced inventory
- bundled app images are read-only and must never be deleted
- path traversal must be rejected
- inventory/delete messages must not interfere with dive sync messages


## G. CCR / Rebreather & Co. latest development context

The audit must include CCR/Rebreather code paths if present in MAIN.

Expected CCR concepts may include:

- CCR mode / Rebreather mode
- open-circuit mode vs closed-circuit mode
- low setpoint
- high setpoint
- setpoint switch depth
- diluent gas
- bailout gas
- CCR bailout transition
- CCR decompression calculation
- CCR Bühlmann integration
- CCR tissue loading
- CCR CNS / OTU based on setpoint
- CCR narcosis / END based on diluent/inert gases
- CCR gas planning / gas ledger
- CCR checklist sync
- CCR manual dive/logbook fields
- CCR PDF/share/export
- CCR unit conversion
- CCR warnings and disclaimers

Audit specifically for:

- CCR setpoint confused with gas FO2 PPO2
- CCR setpoint values applied to open-circuit segments
- diluent incorrectly treated as breathed gas at setpoint
- bailout gas incorrectly included as scheduled consumption before bailout
- bailout transition not represented or not validated
- CCR CNS/OTU not based on setpoint where appropriate
- CCR narcosis not based on diluent/inert gases
- CCR tissue loading using wrong gas source
- CCR profile mixing OC and CCR assumptions silently
- CCR outputs implying live loop monitoring
- CCR outputs implying certified CCR controller behavior
- CCR warnings missing or hidden behind generic planner warnings
- CCR export/share omitting setpoint/diluent/bailout assumptions
- CCR checklist not synchronized or duplicating gases/tasks
- CCR mode leaking into Base/Deco unexpectedly
- CCR code path untested


## F. Physical/external QA gates

These must remain external and must not be marked as passed unless actually executed:

- Apple Watch Ultra real depth/underwater tests
- paired Watch/iPhone sync matrix
- real iCloud two-device conflict validation
- external Subsurface import/export validation
- CCR external reference validation against trusted tools/tables
- CCR physical dive procedure validation
- App Store screenshots/assets
- Apple entitlement validation

---


## H. Latest MAIN implementation context

The current `main` branch includes or may include the following cross-cutting additions that must be audited:

- `PlannerAscentSpeedSettings`
- `PlannerAscentTableBuilder`
- `DecoStopsPresentationBuilder`
- Planner Emergency / Rock Bottom inputs and outputs
- `ScheduleGasConsumptionService`
- `GasLedgerDisplayFormatter`
- Technical average-depth gas-consumption option
- `RepetitiveDivePlannerService`
- `RouteSummaryService`
- `RouteSummaryAggregation`
- `PlanCalculationCompleteness`
- `PlannerResultState`
- structured Equipment models/support/mappers
- operational pre-dive checklist generation
- CCR checklist import/export coordinators
- CCR bailout-scenario calculator
- CCR gas-density estimator
- shared `PlannerBriefingCard`
- iOS briefing-card rendering/export
- Watch briefing-card receiver/store/inventory
- Watch reminder manual-dismiss behavior
- Watch image horizontal paging
- locale-adaptive Watch logbook dates
- expanded accessibility summaries and labels
- small-Watch live-layout density changes

Audit actual files, target membership, code paths, tests and documentation. Do not assume a feature is complete merely because symbols or files exist.

## I. Canonical-calculation / projection / presentation classification

For every recent feature, classify code into:

1. canonical algorithm/calculation;
2. validation/preflight;
3. planner-mode projection;
4. schedule/route aggregation;
5. persistence/sync;
6. presentation builder;
7. formatter/rounding;
8. export/rendering;
9. UI state;
10. documentation/tests.

A presentation builder must never be credited as a separate algorithm, but it must be audited for fidelity to canonical data.


# ABSOLUTE RULES

## DO NOT

- touch experimental branches
- touch Apnea experimental
- touch Snorkeling experimental
- touch Buddy Assist experimental
- touch Exploration Lab
- modify files excluded from `project.yml`
- apply patches
- auto-fix issues
- change UI graphics
- redesign UX
- change app visual identity
- change Watch dive/depth/ascent algorithms
- change iOS Bühlmann/planner math
- change CCR/Rebreather math
- change MOD/PPO2/switch-depth behavior
- change TTV semantics
- change Mission Mode semantics
- change Base / Deco / Technical planner mode logic
- change gas-planning logic
- change cloud merge logic
- change WatchConnectivity trust model
- weaken legal/safety disclaimers
- introduce certified dive-computer claims
- introduce certified decompression-planner claims
- introduce certified CCR controller claims
- claim physical QA passed unless actually executed
- claim external Subsurface validation passed unless actually executed
- claim Apple Watch Ultra underwater validation passed unless actually executed

## PRESERVE

- MAIN-only scope
- Apple Watch dark/neon underwater UI
- iOS dark marine/cyan UI
- BUSSOLA terminology
- no COMPASSO
- Mission Mode as internal UI/runtime profile only
- TTV as informational index only
- iOS Planner as reference-only
- CCR Planner as reference-only if implemented
- non-certified diving companion positioning
- Base / Deco / Technical planner architecture
- mode-specific input projection
- mode-specific result gating
- MOD/switch-depth clamp safety
- PlannerEnvironment-aware MOD calculations
- manual/no-depth truthfulness
- metric internal storage
- legal/safety onboarding
- iOS cloud backup opt-in if implemented
- Watch as source of truth for Watch-stored images
- sync HMAC/peer-secret trust model
- signed ACK policy
- tombstone/conflict policy
- physical QA gates as external evidence requirements
- Planner briefing cards as reference-only
- live Watch measurements independent from synced planner data
- canonical liters separate from bar-equivalent display
- Rock Bottom/emergency gas separate from normal planned consumption
- Technical average-depth option limited to gas estimation
- repetitive-dive state explicit and never silently fresh-tissue
- no stale/partial plan exported as complete

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

- all targets
- source folders
- excluded files
- test targets
- entitlements
- bundle IDs
- Watch/iOS companion relationship

6. Confirm MAIN targets:

- DIRDiving Watch App
- DIRDiving iOS

7. Confirm experimental exclusions.

Watch excluded should include:

- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- Buddy/Exploration models and services if not part of MAIN

iOS excluded should include:

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

xcodebuild -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test

xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

9. Do not fix build/test failures. Record them.

10. Before auditing, print:

- branch
- commit
- dirty files
- targets found
- excluded experimental files confirmed
- build status
- test status
- files/directories to inspect

STOP if branch is not `main`.

---

# PHASE 1 — REPOSITORY / ARCHITECTURE ANALYSIS

Analyze:

- repository structure
- target membership
- shared files between Watch and iOS
- duplicated models
- stale/dead files
- orphan views/services
- accidental experimental dependencies
- build settings
- entitlements
- generated project policy
- localization resources
- test target coverage
- documentation consistency
- App Store/TestFlight docs
- recent report/docs consistency with runtime code
- README / release docs consistency with non-certified positioning

Check for:

- files compiled into wrong target
- code included but unreachable
- code reachable but untested
- stale docs contradicting runtime
- experimental references in MAIN
- dead functions hiding real bugs
- duplicated algorithms between Watch/iOS
- build scripts that can drift from `project.yml`
- planner docs contradicting Base/Deco/Technical behavior
- Watch image-management docs contradicting actual Watch-source-of-truth behavior
- recent planner/runtime/emergency docs contradicting source behavior
- briefing-card docs contradicting payload/version behavior
- structured Equipment docs contradicting mappings
- CCR checklist docs contradicting implemented role round trip

Output architecture findings grouped into:

- Watch
- iOS
- shared
- build/project
- tests
- docs/release

---

# PHASE 2 — APPLE WATCH DEEP CODE ANALYSIS

Inspect at least:

## Core runtime

- `Services/DiveManager.swift`
- `Services/DepthSensorProvider.swift`
- `Services/AppleDepthSensorProvider.swift`
- `Services/MockDepthSensorProvider.swift`
- `Services/SensorProviderFactory.swift`
- `Services/GPSManager.swift`
- `Services/HapticService.swift`
- `Services/DepthLimitHapticCoordinator.swift`
- `Services/AscentSafetyHapticCoordinator.swift`
- `Services/WatchSyncService.swift`
- `Services/WatchDiveSyncCodec.swift`
- `Services/WatchSyncAuth.swift`
- `Services/DiveLogStore.swift`
- `Services/SubsurfaceExportService.swift`
- `Services/UserImageStore.swift`
- `Services/PlannerBriefingCardStore.swift`
- `Services/PlannerBriefingWatchReceiver.swift`
- `Services/ActionButtonIntents.swift`

## Models / utils

- `Models/DiveSession.swift`
- `Models/DiveSample.swift`
- `Models/DepthSafetyConfiguration.swift`
- `Models/AscentRateLimits.swift`
- `Models/AscentStatus.swift`
- `Models/AscentRateSettingsStore.swift`
- `Utils/DiveAlgorithmConfiguration.swift`
- `Utils/DiveLifecycleAlgorithm.swift`
- `Utils/DepthSampleValidation.swift`
- `Utils/DiveSessionAlgorithmValidator.swift`
- `Utils/DiveSessionPersistenceClass.swift`
- `Utils/DiveSessionMerge.swift`
- `Utils/DiveLogbookPolicy.swift`
- `Utils/MonotonicElapsedClock.swift`
- `Utils/MissionModeRuntimeProfile.swift`
- `Utils/SensorSourceMode.swift`
- `Utils/DeveloperVersionUnlock.swift`
- `Utils/WatchDepthFormatting.swift`
- `Utils/DIRUnitConversions.swift`
- `Utils/Formatters.swift`
- `Utils/WatchSyncKeys.swift`
- `Utils/CompanionPhotoImportSupport.swift`
- `Models/PlannerBriefingCard.swift`
- any briefing-card codec/validator/versioning helpers

## Views

- `Views/DiveLiveView.swift`
- `Views/AscentGaugeView.swift`
- `Views/AscentWarningView.swift`
- `Views/DepthSafetyLiveViews.swift`
- `Views/AlarmSettingsView.swift`
- `Views/AscentRateSettingsView.swift`
- `Views/CompassView.swift`
- `Views/DiveDetailView.swift`
- `Views/DiveLogListView.swift`
- `Views/SettingsView.swift`
- `Views/InfoView.swift`
- `Views/UserImagesView.swift`
- `Views/MissionModeIndicatorView.swift`
- `Views/WatchShortcutHelpView.swift`
- briefing-card list/detail/full-screen views if present

Audit for:

- dive lifecycle bugs
- auto-start / manual-start conflicts
- manual start reachability and truthful Settings copy
- draft restore bugs
- pending finalization bugs
- timer/race issues
- stale depth/frozen depth bugs
- invalid depth handling
- 35/38/40 m safety threshold bugs
- ascent-rate bugs
- alarm/haptic throttling bugs
- haptic storm risk
- Mission Mode accidentally affecting algorithms
- Mission Mode manual/auto enable lifecycle
- GPS authorization/lifecycle battery risk
- App Intent legal-gate bypass
- Action Button shortcut state safety
- sensor source/simulation release risk
- automatic fallback to Mock/simulation visibility
- WatchConnectivity routing bugs
- sync replay/tamper risks
- local file persistence bugs
- UserImageStore path traversal
- Watch image inventory correctness
- iOS-requested image delete ACK routing
- bundled image deletion protection
- CSV export consistency
- crash risks in compact Watch UI state
- briefing-card payload routing collisions
- briefing-card stale/overwrite bugs
- metadata/PNG mismatch
- card data affecting live Watch state
- reminder dismiss cancelling safety alerts
- image paging selection/delete races
- fixed-locale date bugs
- accessibility regressions
- small-display banner-stack regressions

Performance focus:

- repeated timers
- main-thread blocking
- excessive state publishes
- excessive haptics
- unnecessary GPS updates
- unnecessary file reloads
- Watch memory pressure
- long CSV/export operations
- image decoding/storage memory risks
- image inventory update spam
- SwiftUI invalidation loops

Security focus:

- unsigned payload paths
- peer secret overwrite
- HMAC/ACK validation
- replay protection
- path traversal
- arbitrary file write/delete
- untrusted image bytes
- bundled image protection
- briefing-card file confinement
- rendered PNG validation
- unsafe briefing-card filename/path rejection
- sensitive data in logs
- cloud/sync trust assumptions
- App Intent safety bypass

---

# PHASE 3 — iOS COMPANION DEEP CODE ANALYSIS

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

## Bühlmann / gas

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


## CCR / Rebreather if implemented

Search and inspect files containing:

- `CCR`
- `Rebreather`
- `Setpoint`
- `Diluent`
- `Bailout`
- `ClosedCircuit`
- `OpenCircuit`
- `Loop`
- `Scrubber`
- `Sorb`
- `Cell`
- `ppO2Setpoint`
- `setpointLow`
- `setpointHigh`
- `diluentGas`
- `bailoutGas`

Likely files may include, if present:

- `iOSApp/Models/CCRPlan.swift`
- `iOSApp/Models/RebreatherPlan.swift`
- `iOSApp/Models/GasPlan.swift`
- `iOSApp/Services/CCRPlannerService.swift`
- `iOSApp/Services/RebreatherPlannerService.swift`
- `iOSApp/Services/CCRGasPlanningService.swift`
- `iOSApp/Services/CCROxygenExposureService.swift`
- `iOSApp/Services/CCRTissueAnalyticsService.swift`
- `iOSApp/Services/CCRPlannerValidator.swift`
- `iOSApp/Services/CCR/CCRBailoutScenarioCalculator.swift`
- `iOSApp/Services/CCR/CCRGasDensityEstimator.swift`
- `iOSApp/Utils/CCRChecklistImportCoordinator.swift`
- `iOSApp/Utils/CCRChecklistExportCoordinator.swift`
- `iOSApp/Views/CCRPlannerView.swift`
- `iOSApp/Views/PlannerView.swift`
- `iOSApp/Views/PlannerGasMixCard.swift`
- `iOSApp/Utils/PlannerModePolicy.swift`
- `iOSApp/Utils/GasMixValidator.swift`


## Logbook/import/export/sync/cloud

- `iOSApp/Services/DiveLogStore.swift`
- `iOSApp/Services/CloudSyncStore.swift`
- `iOSApp/Services/WatchSyncService.swift`
- `iOSApp/Services/WatchDiveSyncCodec.swift`
- `iOSApp/Services/WatchSyncAuth.swift`
- `iOSApp/Services/DiveImportService.swift`
- `iOSApp/Services/SubsurfaceExportService.swift`
- `iOSApp/Utils/DiveSessionMerge.swift`
- `iOSApp/Utils/DiveSessionMergeConflict.swift`
- `iOSApp/Utils/DiveProfileMath.swift`
- `iOSApp/Utils/AnalysisDashboardMath.swift`
- `iOSApp/Utils/PressureDisplayMath.swift`
- `iOSApp/Views/ManualDiveEditorView.swift`
- `iOSApp/Views/DiveDetailView.swift`
- `iOSApp/Views/AnalysisView.swift`
- `iOSApp/Views/LogbookView.swift`
- `iOSApp/Views/EquipmentView.swift`
- `iOSApp/Views/MoreView.swift`
- `iOSApp/Views/WatchPhotoTransferPanel.swift`
- `iOSApp/Models/EquipmentStructuredModels.swift`
- `iOSApp/Utils/EquipmentStructuredSupport.swift`
- `iOSApp/Utils/EquipmentPlannerMapper.swift`
- `iOSApp/Utils/EquipmentChecklistGenerator.swift`
- `iOSApp/Services/PDF/EquipmentSetupPDFBuilder.swift`
- `Models/PlannerBriefingCard.swift`
- iOS briefing-card rendering/export/transfer files

Audit for:

- Base / Deco / Technical mode bugs
- CCR mode leaking into Base/Deco unexpectedly
- CCR state lost when switching modes
- hidden gas accidentally used in wrong mode
- MOD display not updating after O2/PPO2 change
- switchDepthMeters not clamped to MOD
- switchDepthMeters deeper than MOD persisted
- CCR bailout switchDepthMeters not clamped to bailout MOD
- CCR setpoint vs gas PPO2 confusion
- diluent gas incorrectly used as breathed gas under CCR setpoint
- bailout gas incorrectly consumed before bailout transition
- recursive SwiftUI onChange/binding loops in gas cards
- PPO2 tolerance fragmentation
- NDL preview vs projected input mismatch
- GasPlanningService preview mismatch
- invalid PlannerEnvironment fallback
- cloud profile silent merge bugs
- duplicate session ID crashes
- iCloud KVS payload size issues
- manual pressure unit bugs
- CSV parser robustness
- Subsurface export fidelity
- Watch sync ACK/pending-state bugs
- photo transfer / inventory sync bugs
- iOS Watch image inventory stale-state bugs
- iOS delete success before Watch ACK
- SwiftUI state loops
- memory/performance bottlenecks
- privacy-sensitive iCloud behavior
- localization/user-facing string issues
- invalid/stale ascent-speed settings
- runtime/deco row reordering bugs
- partial plan exported as complete
- Rock Bottom using display-rounded values
- Rock Bottom incorrectly affected by Technical average-depth mode
- gas-ledger liters/bar unit mixing
- schedule-aware gas segment misallocation
- repetitive-dive silent fresh-tissue fallback
- prior-dive chronology errors
- structured Equipment role/cylinder mapping loss
- checklist generation duplication/loss
- CCR checklist role contamination
- briefing-card metadata/PNG divergence
- briefing-card stale version overwrite
- transfer success before ACK/completion
- unsupported briefing-card schema handling

Performance focus:

- heavy calculations on main thread
- repeated Bühlmann recomputation
- repeated CCR setpoint/tissue recomputation
- repeated Planner preview recomputation
- repeated MOD/switch-depth normalization
- non-debounced O2/PPO2 stepper updates
- Swift Charts overdraw
- large CSV full-string parsing
- large iCloud KVS payloads
- repeated file writes
- unnecessary WatchConnectivity retransmits
- image preprocessing memory spikes
- image inventory update storms
- SwiftUI `.onChange` recursion
- non-debounced sliders/steppers causing recalculation storm
- repeated route-summary/runtime rebuilding
- repeated Rock Bottom recalculation
- repeated gas-ledger formatting/allocation
- repetitive-dive tissue recomputation
- briefing-card rendering memory spikes
- briefing-card Watch transfer retry storms

Security focus:

- cloud backup opt-in enforcement
- GPS/privacy data leakage
- CCR plan sensitive notes / equipment / bailout data in cloud
- untrusted CSV parsing
- path traversal in import/export
- unsafe temp file sharing
- WatchConnectivity trust/ACK
- stale peer secret overwrite
- image transfer validation
- image delete request validation
- Watch inventory trust model
- sensitive data in logs
- iCloud conflict poisoning
- malformed cloud payload handling
- malformed briefing-card payload handling
- briefing-card file/path validation
- untrusted PNG/metadata mismatch
- stale briefing-card replay
- structured Equipment payload poisoning
- CCR checklist import poisoning

---

# PHASE 4 — PLANNER-SPECIFIC DEEP AUDIT

Audit the full iOS Planner as a dedicated section.

## A. Base / Deco / Technical

- modes are real, not decorative
- visible inputs match mode
- active gas set matches mode
- hidden gases do not affect simpler modes
- mode switching preserves hidden advanced data
- calculation uses active projection
- result sections match mode
- Bühlmann display matches mode
- export/share includes active mode label if implemented

## B. MOD / PPO2 / switchDepthMeters

- O2 changes recalculate MOD
- max PPO2 changes recalculate MOD
- environment changes recalculate MOD
- non-bottom switchDepthMeters auto-updates to usable MOD after gas/PPO2 change
- user can lower switch depth below MOD
- user cannot persist switch depth deeper than MOD
- validation catches bypassed invalid switch depths
- environment-aware helper is used
- no duplicated MOD formula
- no SwiftUI freeze or recursion from normalization

## C. PlannerEnvironment

- Base, Deco, Technical validate environment
- invalid altitude/salinity never silently falls back to sea level
- MOD/PPO2 display uses environment-aware pressure model

## D. Preview parity

- NDL preview uses mode-projected input
- gas analysis preview uses mode-projected input
- reserve/consumption tiles do not contradict calculated plan

## E. PPO2 tolerance

- central constants exist or gap is reported
- preflight/runtime/display differences are documented
- exact MOD boundary behavior is tested

Report all findings as:

- bug
- safety issue
- performance issue
- test gap
- documentation gap

---


# PHASE 4B — PLANNER TRANSIT / RUNTIME / DECO PRESENTATION DEEP AUDIT

Inspect:

- ascent/descent speed settings;
- persistence/migration;
- transit-time calculations;
- `PlannerAscentTableBuilder`;
- `DecoStopsPresentationBuilder`;
- full Dive Runtime ordering;
- route summaries;
- total runtime / TTS / TTR consistency;
- stale-result invalidation.

Audit for:

- zero/negative speed division;
- non-finite runtime;
- duplicated or missing rows;
- stop rows grouped incorrectly;
- gas-switch rows at wrong runtime;
- presentation builder mutating canonical data;
- route totals disagreeing with canonical segments;
- stale previous result after invalid inputs;
- export using incomplete result state;
- locale formatting changing parse/rounding behavior.

# PHASE 4C — EMERGENCY / ROCK BOTTOM DEEP AUDIT

Inspect all Emergency / Rock Bottom code paths.

Audit:

- ambient pressure;
- maximum-depth basis;
- stressed RMV/SAC;
- team/diver multiplier;
- problem-solving time;
- ascent/stop gas;
- reserve separation;
- liters required;
- bar equivalent;
- available-versus-required comparison;
- validation bounds;
- metric/imperial conversion;
- persistence;
- export/PDF/briefing-card output.

Critical checks:

- normal gas consumption and Rock Bottom remain separate;
- Technical average-depth gas option cannot weaken Rock Bottom unintentionally;
- display-rounded bar never feeds canonical liters;
- CCR bailout does not silently reuse OC bottom assumptions;
- no overflow/NaN/infinite result;
- insufficient-gas state cannot be hidden by formatting.

# PHASE 4D — SCHEDULE-AWARE GAS / GAS LEDGER DEEP AUDIT

Inspect:

- `GasPlanningService`;
- `PlannerGasSchedule`;
- `ScheduleGasConsumptionService`;
- `GasLedgerDisplayFormatter`;
- gas-role allocation;
- liters/bar display;
- reserve/available/remaining calculations.

Audit for:

- wrong segment depth/time;
- wrong gas assignment;
- travel/deco/bailout role contamination;
- CCR diluent consumed as OC gas;
- bailout consumed before bailout transition;
- ascent-speed changes not reflected in gas use;
- duplicate aggregation;
- unit mixing;
- rounding feedback;
- cylinder mismatch;
- stale ledger after input changes.

# PHASE 4E — TECHNICAL AVERAGE-DEPTH GAS OPTION DEEP AUDIT

Verify:

- only Technical mode can activate it;
- default remains max-depth conservative;
- only gas consumption changes;
- Bühlmann, deco, MOD, PPO2, switch depth and Rock Bottom remain unaffected;
- average depth validation;
- hidden-state isolation across modes;
- persistence and migration;
- disclosure in UI/PDF/briefing card;
- no stale toggle leakage.

# PHASE 4F — REPETITIVE DIVE / RESIDUAL TISSUE DEEP AUDIT

Inspect:

- `RepetitiveDivePlannerService`;
- prior-dive selection;
- chronology;
- surface interval;
- N2/He tissue state;
- off-gassing;
- GF compatibility;
- CCR/OC compatibility;
- persistence/sync;
- UI/export disclosure.

Audit for:

- future or stale prior dive;
- silent fresh-tissue fallback;
- partial tissue state;
- compartment-order mismatch;
- non-deterministic results;
- duplicate prior dive use;
- wrong units/timestamps;
- cloud conflict contamination.

# PHASE 4G — STRUCTURED EQUIPMENT / OPERATIONAL CHECKLIST DEEP AUDIT

Inspect:

- structured Equipment models/support;
- Equipment-to-Planner mapping;
- Equipment-to-Checklist mapping;
- operational task generation;
- gas-linked items;
- cylinder size/pressure/mix/role;
- duplicate prevention;
- stable IDs;
- persistence/sync;
- Equipment Setup PDF;
- CCR checklist import/export.

Audit for:

- role loss;
- duplicate items/tasks;
- user-edit loss;
- stale planner links;
- wrong cylinder values;
- CCR diluent/bailout contamination;
- OC/CCR round-trip mismatch;
- malformed import handling;
- destructive merge behavior.

# PHASE 4H — PLANNER BRIEFING CARD / WATCH TRANSFER DEEP AUDIT

Inspect end to end:

- shared `PlannerBriefingCard`;
- iOS card generation;
- rendered PNG;
- structured metadata;
- version/schema;
- transfer;
- ACK/status;
- Watch receiver;
- Watch store;
- replacement/deletion;
- inventory;
- stale-card handling;
- malformed payload rejection.

Audit for:

- PNG/metadata mismatch;
- unit mismatch;
- stale card overwrite;
- unsupported schema accepted;
- transfer marked complete too early;
- payload routed as dive/image data;
- card values mutating live Watch state;
- path traversal/unsafe filenames;
- excessive memory during render/decode;
- retry storms;
- missing reference-only labeling;
- CCR/Rock Bottom/gas-ledger values shown as live authority.


# PHASE 5 — WATCH IMAGE INVENTORY / DELETE DEEP AUDIT

Audit if implementation exists in MAIN.

## Watch side

- `UserImageStore` delete API
- `canDeleteImage`
- `deleteImage`
- inventory model
- metadata persistence
- `Documents/UserImages` confinement
- path traversal rejection
- bundled image read-only protection
- reload/imageNames publishing
- inventory update after import/delete
- ACK after iOS delete request

## iOS side

- `WatchPhotoTransferPanel` inventory UI
- `requestWatchImageInventory`
- `handleWatchImageInventoryResponse`
- `requestDeletePhotoOnWatch`
- pending delete state
- `handleWatchPhotoDeleteAck`
- stale/unavailable inventory states
- success only after ACK
- duplicate/unknown ACK handling

## Sync routing

- photo import payload
- photo inventory request/response
- photo delete request/ACK
- no collision with dive sync payloads
- no false route to dive import handler
- no inventory update storm

## Security

- iOS cannot delete arbitrary paths
- Watch validates filename before deletion
- bundled images cannot be deleted
- non-image files rejected on import if implemented
- iOS inventory is Watch-sourced, not invented

## Performance

- inventory update throttling
- image metadata loading cost
- repeated WatchConnectivity transfers
- large image memory pressure

---

# PHASE 6 — BUG HUNT CHECKLIST

Look specifically for:

## State / lifecycle bugs

- stale state after edit
- stale detail view after manual edit
- restore active session after completed session
- duplicate log entries
- hidden gas still affecting Base/Deco
- CCR state leaking into OC planner
- CCR state lost during mode switching
- stale NDL preview
- stale gas analysis preview
- stale CCR preview
- stale MOD display
- `switchDepthMeters > MOD` persisted
- CCR bailout switchDepthMeters > bailout MOD persisted
- stale cloud conflict state
- stale Watch sync queue status
- stale image inventory state
- iOS delete shown as success before Watch ACK
- lost tombstones
- demo data mixed into real analysis
- stale Dive Runtime rows
- stale deco-stop table
- stale Rock Bottom result
- stale gas ledger
- stale repetitive-dive tissue state
- stale Equipment mapping
- stale briefing-card status

## Boundary bugs

- depth 0 / negative / NaN / > cap
- time 0 / negative / huge
- gas fraction invalid
- CCR setpoint invalid / zero / too high
- diluent invalid
- bailout invalid
- PPO2 exact boundary
- MOD exact boundary
- `switchDepthMeters > MOD`
- O2 100% at PPO2 1.6 should clamp switch depth around 6 m
- altitude/salinity invalid
- pressure start < end
- empty samples
- one sample
- duplicate timestamps
- duplicate session IDs
- huge CSV
- huge iCloud payload
- missing GPS
- missing temperature
- unsafe image filenames
- unknown Watch image inventory ACK/request IDs
- zero/negative ascent speed
- invalid average depth
- invalid Rock Bottom team/RMV/problem time
- missing cylinder for bar equivalent
- future prior dive
- malformed tissue state
- duplicate Equipment IDs
- malformed briefing-card schema/version
- mismatched briefing-card PNG/metadata

## Concurrency bugs

- async GPS callback after dive end
- WatchConnectivity callback race
- iCloud update race
- timer race
- haptic delayed task after state clear
- SwiftUI binding writing during render
- simultaneous import/delete/sync
- simultaneous image import/delete/inventory update
- app background/resume
- force quit during finalization
- repeated rapid O2/PPO2/setpoint button presses
- repeated rapid gas switch-depth increments
- simultaneous plan recompute + briefing render
- simultaneous card transfer + replacement/delete
- repetitive-dive recompute during prior-dive sync update
- Equipment edit during checklist regeneration

## Crash risks

- force unwraps
- array index access
- dictionary uniqueKeys traps
- JSON decode assumptions
- invalid URL/path
- non-finite doubles
- empty collections
- unsupported image data
- missing localization keys if fatal
- missing resource files
- malformed briefing-card image
- stale briefing-card file reference
- missing route/runtime segment
- zero-speed division
- corrupted residual tissue array

---

# PHASE 7 — PERFORMANCE ANALYSIS

Analyze:

## CPU

- Bühlmann repeated calculations
- oxygen exposure loops
- CCR CNS/OTU loops
- gas schedule generation
- MOD/switch-depth normalization loops
- Planner preview updates
- analysis dashboard aggregation
- CSV parsing
- Swift Charts data generation
- Watch live timer updates
- haptic coordinator loops
- runtime/deco presentation rebuilding
- Rock Bottom recalculation
- gas-ledger formatting
- repetitive-dive tissue propagation
- briefing-card rendering

## Memory

- full CSV string loading
- image transfer/preprocessing
- image inventory metadata
- large dive sample arrays
- large CCR tissue timeline arrays
- large iCloud payloads
- chart data arrays
- retained timers/tasks
- cached inventories/logbooks
- briefing-card PNG buffers
- briefing-card metadata inventory
- residual tissue histories
- structured Equipment snapshots

## Battery

- GPS updates
- Watch depth sensor polling
- timers
- haptics
- WatchConnectivity retries
- image inventory sync
- iCloud writes
- SwiftUI animation loops
- Mission Mode effect/invariant

## SwiftUI

- unnecessary body invalidations
- `@Published` storms
- recursive `onChange`
- non-debounced bindings
- heavy work in body
- heavy computed properties in views
- repeated formatter allocation
- Charts recomputing on every state change
- gas card stepper updates triggering full planner recomputation
- CCR setpoint updates triggering full planner recomputation
- inventory UI refreshing too often
- route summary rebuilding too often
- briefing-card rendering on every minor state change
- card-transfer retry storms
- operational checklist regeneration storms

For each finding include:

- file/function
- performance risk
- likely user-visible symptom
- suggested optimization
- safety/business logic risk
- priority

---

# PHASE 8 — SECURITY / PRIVACY ANALYSIS

Analyze:

## Authentication / trust

- `WatchSyncAuth`
- peer secret handling
- reset trust
- HMAC validation
- signed ACK validation
- replay/skew validation
- changed peer rejection
- delete ACK trust
- inventory response trust
- briefing-card payload trust
- briefing-card schema/version validation
- briefing-card ACK trust

## Data integrity

- cloud merge
- profile sample conflict detection
- CCR profile conflict detection if CCR data exists
- duplicate IDs
- tombstones
- malformed payloads
- import/export
- iCloud KVS caps
- Watch image inventory truthfulness
- briefing-card numerical fidelity
- structured Equipment integrity
- CCR checklist round-trip integrity
- repetitive-dive tissue-source integrity

## File security

- file protection
- temp files
- CSV import
- CSV export
- image import
- image delete
- path traversal
- unsafe filenames
- arbitrary file write/delete
- bundled image protection
- briefing-card file confinement
- rendered PNG validation
- unsafe briefing-card filename/path rejection

## Privacy

- GPS points
- CCR plan data
- bailout data
- dive logs
- notes
- gas/equipment data
- iCloud backup opt-in
- share/export files
- image filenames/metadata
- logs/debug output
- App Store privacy risk

## App Intent / Shortcut safety

- legal onboarding bypass
- unsafe start/end shortcuts
- alarm acknowledge shortcut
- bearing shortcuts

For each security finding include:

- exploit scenario
- affected data
- likelihood
- impact
- severity
- proposed mitigation
- tests required

Severity:

- CRITICAL — exploitable data corruption/security/privacy issue
- HIGH — realistic user data loss/security bypass
- MEDIUM — hardening needed before broad release
- LOW — polish/hygiene
- INFO — document/monitor

---

# PHASE 9 — TEST COVERAGE ANALYSIS

Inspect:

- `Tests/iOSAlgorithmTests/*`
- `Tests/WatchAlgorithmTests/*`

Report:

- current test targets
- tests that pass/fail/skipped
- missing tests
- brittle tests
- tests that do not isolate state
- tests that rely on order
- missing performance tests
- missing security tests
- missing import/export tests
- missing cloud conflict tests
- missing CCR tests
- missing CCR cloud conflict tests
- missing WatchConnectivity tests
- missing Planner mode tests
- missing MOD/switch-depth tests
- missing UI-state-loop tests
- missing Watch image inventory/delete tests
- missing App Intent legal-gate tests
- missing Mission Mode invariant tests
- missing physical QA
- missing ascent-speed tests
- missing runtime ordering tests
- missing deco-stop equivalence tests
- missing Rock Bottom reference vectors
- missing gas-ledger liters/bar tests
- missing schedule-aware gas tests
- missing average-depth toggle isolation tests
- missing repetitive-dive tests
- missing structured Equipment mapping tests
- missing CCR checklist round-trip tests
- missing briefing-card fidelity/routing/version tests
- missing small-Watch layout tests
- missing reminder-dismiss tests
- missing image-paging tests
- missing date-localization/accessibility tests

Create:

- automated test plan
- simulator QA plan
- physical Watch Ultra QA plan
- CCR external validation plan
- paired Watch/iPhone QA plan
- iCloud two-device QA plan
- external Subsurface regression plan
- security regression plan
- performance regression plan

---

# PHASE 10 — STATIC TOOLING / SCAN SUGGESTIONS

If tools are available, run or suggest:

- xcodebuild warnings
- Swift compiler warnings
- SwiftLint if configured
- grep for force unwraps:
  - `!`
  - `try!`
  - `as!`
- grep for unsafe dictionary constructors:
  - `Dictionary(uniqueKeysWithValues:)`
- grep for hardcoded secrets:
  - API keys
  - tokens
  - private keys
  - Apple credentials
- grep for TODO/FIXME in MAIN
- grep for hardcoded user-facing strings
- grep for URL/file path construction
- grep for `.onChange` patterns that mutate observed state
- grep for `DispatchQueue.main.asyncAfter`
- grep for timers/tasks not cancelled
- grep for file delete/write paths
- grep for `switchDepthMeters`
- grep for `PlannerMODValidator`
- grep for `CCR`
- grep for `Rebreather`
- grep for `Setpoint`
- grep for `Diluent`
- grep for `Bailout`
- grep for `modMeters`
- grep for `companionPhotoInventory`
- grep for `companionPhotoDelete`
- grep for `ackSignature`
- grep for `PlannerAscentSpeedSettings`
- grep for `PlannerAscentTableBuilder`
- grep for `DecoStopsPresentationBuilder`
- grep for `RockBottom`
- grep for `Emergency`
- grep for `ScheduleGasConsumptionService`
- grep for `GasLedgerDisplayFormatter`
- grep for `RepetitiveDivePlannerService`
- grep for `RouteSummary`
- grep for `EquipmentStructured`
- grep for `CCRChecklistImportCoordinator`
- grep for `CCRBailoutScenarioCalculator`
- grep for `CCRGasDensityEstimator`
- grep for `PlannerBriefingCard`
- grep for fixed `dd/MM/yyyy` date formats

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

- bug
- performance
- security
- privacy
- data integrity
- sync
- cloud
- import/export
- persistence
- algorithm integration
- UI-state logic
- localization
- build/release
- tests
- docs
- physical QA
- Planner modes
- MOD/PPO2/switch-depth
- CCR/Rebreather
- Ratio Deco
- Watch image management
- Mission Mode
- App Intents
- Transit / Runtime / Deco Presentation
- Emergency / Rock Bottom
- Schedule-Aware Gas
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Operational Checklist
- Planner Briefing Cards
- Accessibility / Localization

## Fix class

- test-only
- docs-only
- copy/localization-only
- UI-state fix
- small functional
- medium refactor
- security hardening
- performance optimization
- architecture
- external QA/process

For each issue include:

- ID
- title
- app
- area
- file/function
- description
- evidence from code
- user impact
- safety impact
- CCR impact if relevant
- security/privacy impact
- performance impact
- proposed fix
- estimated effort
- regression risk
- tests required
- priority
- dependencies
- acceptance criteria

---

# PHASE 12 — REPORT REQUIRED

Create:

```text
Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md
```

The report must contain:

## A. Executive Summary

- overall code readiness %
- Watch readiness %
- iOS readiness %
- bug risk %
- performance readiness %
- security readiness %
- privacy readiness %
- data integrity readiness %
- sync/cloud readiness %
- Planner readiness %
- CCR / Rebreather readiness %
- Watch image-management readiness %
- TestFlight readiness
- App Store readiness
- most urgent issues

## B. Scope Confirmation

- branch
- commit
- target list
- experimental exclusions
- build/test results
- static scan results if available

## C. Architecture Analysis

- target membership
- shared files
- dead/stale code
- experimental isolation
- build risks
- documentation drift

## D. Apple Watch Code Analysis

- bugs
- performance
- security/privacy
- persistence
- sync
- App Intents
- Transit / Runtime / Deco Presentation
- Emergency / Rock Bottom
- Schedule-Aware Gas
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Operational Checklist
- Planner Briefing Cards
- Accessibility / Localization
- Mission Mode
- manual/automatic start
- depth lifecycle
- sensor source/simulation
- GPS/haptics
- image inventory/delete if present

## E. iOS Companion Code Analysis

- bugs
- performance
- security/privacy
- Planner Base/Deco/Technical
- MOD/PPO2/switch-depth
- CCR/Rebreather
- Ratio Deco clamp
- Bühlmann/gas planning
- logbook
- cloud
- import/export
- Watch sync
- Watch image inventory/delete UI if present

## F. Planner-Specific Deep Analysis

- Base/Deco/Technical behavior
- active input projection
- visible vs active gases
- NDL preview parity
- gas analysis preview parity
- MOD display
- switchDepthMeters clamping
- PPO2 tolerance policy
- PlannerEnvironment
- export/share copy

## G. CCR / Rebreather Deep Analysis

- CCR mode architecture
- setpoint handling
- setpoint switch depth
- diluent gas
- bailout gas
- bailout transition
- CCR tissue loading
- CCR CNS/OTU
- CCR narcosis/END
- CCR cloud/sync/export behavior
- CCR performance risks
- CCR security/privacy risks
- CCR documentation gaps
- CCR external QA gates

## H. Transit / Runtime / Deco Presentation Analysis

## I. Emergency / Rock Bottom Analysis

## J. Schedule-Aware Gas / Gas Ledger Analysis

## K. Technical Average-Depth Gas Option Analysis

## L. Repetitive Dive / Residual Tissue Analysis

## M. Structured Equipment / Operational Checklist Analysis

## N. Planner Briefing Card / Watch Transfer Analysis

## O. Watch Image Inventory / Delete Analysis

- Watch source-of-truth
- inventory model
- iOS list state
- delete request/ACK
- path traversal
- bundled image protection
- briefing-card file confinement
- rendered PNG validation
- unsafe briefing-card filename/path rejection
- sync routing
- performance/security risks

## P. Cross-App Sync / Data Integrity Analysis

- Watch → iOS
- iOS → Watch
- image inventory/delete messages
- tombstones
- peer trust
- ACKs
- duplicate IDs
- cloud conflict
- manual/no-depth policy

## Q. Performance Analysis

- CPU
- memory
- battery
- SwiftUI invalidation
- Watch-specific performance
- iOS planner/charts performance
- image inventory performance

## R. Security / Privacy Analysis

- trust model
- cloud privacy
- GPS privacy
- file security
- import/export
- image handling
- App Intents
- Transit / Runtime / Deco Presentation
- Emergency / Rock Bottom
- Schedule-Aware Gas
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Operational Checklist
- Planner Briefing Cards
- Accessibility / Localization
- secret scanning

## S. Test Coverage Analysis

- current tests
- failing tests
- missing tests
- test isolation risks
- physical QA gaps

## T. Issue Matrix

Table columns:

- ID
- severity
- priority
- app
- area
- file/function
- title
- user impact
- security/performance impact
- proposed fix
- estimated effort

## U. Detailed Action Plan

Grouped by:

1. P0
2. P1
3. P2
4. P3
5. P4

For every action:

- issue IDs addressed
- files likely involved
- implementation order
- risk
- tests required
- acceptance criteria

## V. 7-Day Remediation Plan

- day-by-day actions
- expected output
- verification

## W. 14-Day Remediation Plan

- broader stabilization
- performance/security work
- QA evidence

## X. Pre-Internal-TestFlight Checklist

## Y. Pre-External-TestFlight Checklist

## Z. Pre-App-Store Checklist

## AA. Recommended Cursor Remediation Commands

At the end of the report, draft separate future Cursor commands:

1. Bug/data-integrity fixes
2. Performance optimization pass
3. Security hardening pass
4. Test coverage pass
5. Planner MOD/switch-depth specific remediation if needed
6. CCR/Rebreather hardening if needed
7. Watch image inventory/delete hardening if needed
8. Cloud merge / iCloud conflict remediation if needed
9. App Intent / Action Button safety remediation if needed
10. Transit/runtime/deco presentation remediation if needed
11. Emergency / Rock Bottom remediation if needed
12. Gas-ledger / schedule-aware gas remediation if needed
13. Repetitive-dive remediation if needed
14. Structured Equipment / checklist remediation if needed
15. Planner briefing-card / Watch transfer remediation if needed

Do not execute them.

## AB. Final Verdict

Answer clearly:

- Is the code ready to compile?
- Is it safe for internal TestFlight?
- Is it safe for external TestFlight?
- Is it ready for App Store?
- What blocks 100% code readiness?
- What blocks 100% CCR readiness?
- What blocks 100% security readiness?
- What blocks 100% performance readiness?
- Are transit/runtime/deco presentation layers faithful to canonical data?
- Is Rock Bottom conservative and isolated?
- Is schedule-aware gas allocation correct?
- Are gas ledger liters/bar values trustworthy?
- Is the Technical average-depth option isolated?
- Are repetitive-dive residual tissues safe?
- Are structured Equipment/checklist mappings lossless?
- Are briefing cards numerically faithful, version-safe and reference-only?
- What must be fixed first?

---

# PHASE 13 — VALIDATION

After creating the report, verify:

- report file exists
- report is not empty
- issue matrix exists
- action plan exists
- no source code modified
- git status only shows the new report file, unless build artifacts were generated
- no experimental files touched

If build/test commands were run:

- include exact commands and results
- include failure summaries
- do not claim pass unless they passed

---

# SUCCESS CRITERIA

The task is complete only if:

- No production source code is modified.
- No UI is modified.
- No business logic is modified.
- No algorithms are modified.
- No CCR/Rebreather logic is modified.
- No security model is modified.
- Report is created at:

```text
Docs/MAIN_DEEP_CODE_ANALYSIS_BUG_PERFORMANCE_SECURITY_AUDIT_CURRENT.md
```

- Report includes:
  - deep bug analysis
  - performance analysis
  - security/privacy analysis
  - Planner-specific audit
  - MOD/PPO2/switch-depth
- CCR/Rebreather
- Ratio Deco audit
- Transit/runtime/deco presentation audit
- Emergency / Rock Bottom audit
- Schedule-aware gas / gas ledger audit
- Technical average-depth gas audit
- Repetitive-dive audit
- Structured Equipment / operational checklist audit
- Planner briefing-card / Watch transfer audit
  - Watch image inventory/delete audit if implemented
  - Mission Mode invariant audit
  - App Intents
- Transit / Runtime / Deco Presentation
- Emergency / Rock Bottom
- Schedule-Aware Gas
- Gas Ledger / Reserve
- Repetitive Dive
- Structured Equipment
- Operational Checklist
- Planner Briefing Cards
- Accessibility / Localization legal-gate audit
  - issue matrix
  - severity/priority
  - detailed action plan
  - 7-day/14-day roadmap
  - TestFlight/App Store checklist
  - future remediation command drafts

- All physical/external QA items are marked as pending, not passed.
- Final git status confirms only report/docs changed.

If anything cannot be fully analyzed:

- document the limitation
- explain why
- propose the exact next inspection step


---

# VERSION HISTORY

## V3.0 — 2026-06-19

Updated against the current `main` implementation state.

Added explicit deep-code audit coverage for:

- Planner ascent-speed settings;
- full Dive Runtime and decompression-stop presentation;
- Planner Emergency / Rock Bottom;
- schedule-aware gas consumption;
- gas ledger / Available Gas liters-bar presentation;
- Technical average-depth gas-consumption option;
- repetitive-dive residual tissues;
- route-summary and plan-completeness/result-state gating;
- structured Equipment setup;
- operational pre-dive checklist generation;
- CCR checklist import/export;
- CCR bailout scenario;
- CCR gas-density estimation;
- Planner briefing-card encode/render/transfer/persistence;
- Watch briefing-card receiver/store/inventory;
- stale-version and malformed-payload handling;
- small-Watch layout regressions;
- reminder manual-dismiss regressions;
- image-paging regressions;
- date localization and accessibility regressions.

Preserved:

- `5-` prefix and recurring-audit position;
- audit-only behavior;
- complete MAIN scope;
- no production code, UI, business-logic, algorithm, security or sync modification;
- non-certified/reference-only positioning;
- external and physical QA gates as pending unless evidenced.

---

# V3.0 DEEP CODE MULTI-ACTIVITY EXPANSION

The deep-code audit must include:

- root coordinator state;
- activity preference migration;
- feature flags;
- separate Settings stores;
- separate Log stores;
- activity-discriminated sync;
- cross-activity payload rejection;
- deep-link ownership;
- state restoration;
- backup/restore isolation;
- activity-specific export;
- Apnea lifecycle concurrency;
- Snorkeling GPS/battery/privacy;
- Full Computer one-second runtime performance;
- cross-activity memory and queue pressure.

Any cross-activity data corruption, routing or settings leakage is P0.
