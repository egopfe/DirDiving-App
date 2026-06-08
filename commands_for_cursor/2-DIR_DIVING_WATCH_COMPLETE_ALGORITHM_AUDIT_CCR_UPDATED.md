# CURSOR / CODEX COMMAND — DIR DIVING WATCH COMPLETE ALGORITHM / SAFETY / RUNTIME AUDIT UPDATED WITH CCR & CO.

You are working on the DIR DIVING repository.

## TARGET

ONLY branch `main`.

## TARGET APP

ONLY Apple Watch MAIN target:

- DIRDiving Watch App

## FILE NAME / POSITION IN AUDIT SEQUENCE

This is audit command number **2** in the DIR DIVING recurring audit sequence.

Use this file name:

`2-DIR_DIVING_WATCH_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED.md`

This audit is intended to be launched after the primary iOS Bühlmann / CCR readiness audit:

`1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED.md`

## TASK TYPE

FULL WATCH AUDIT ONLY.

DO NOT MODIFY CODE.  
DO NOT REFACTOR.  
DO NOT FIX ISSUES.  
DO NOT CHANGE UI.  
DO NOT CHANGE BUSINESS LOGIC.  
DO NOT CHANGE ALGORITHMS.  
DO NOT CHANGE SECURITY MODEL.  
DO NOT CHANGE SYNC MODEL.  
DO NOT CHANGE MISSION MODE SEMANTICS.  
DO NOT CHANGE SENSOR SOURCE POLICY.  
DO NOT CHANGE APP INTENTS.

## OBJECTIVE

Perform a complete and deep audit of the Apple Watch MAIN app after the latest DIR DIVING developments, including:

1. Core Watch dive lifecycle algorithms.
2. Manual and automatic dive start.
3. Depth sensor automation and simulation/fallback policy.
4. Dive reminders engine.
5. User images / dive images / image inventory / deletion sync.
6. Mission Mode invariants.
7. Developer Sensor Source settings.
8. App Intents / Action Button safety gating.
9. Branding/icon consistency.
10. Metric/imperial unit consistency.
11. WatchConnectivity sync with iOS Companion.
12. Security/privacy/data-integrity issues.
13. CCR / Rebreather & advanced planner compatibility impacts on Watch.

The output must be a detailed Markdown report:

`Docs/WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

The report must include:
- executive summary;
- readiness percentages;
- all detected issues;
- affected files/functions;
- severity;
- priority;
- safety impact;
- security/privacy impact;
- performance impact;
- user impact;
- proposed fix;
- estimated effort;
- regression risk;
- test strategy;
- detailed action plan;
- physical Watch Ultra QA plan;
- paired Watch/iPhone QA plan;
- TestFlight/App Store readiness verdict.

---

# ABSOLUTE RULES

## DO NOT

- touch experimental branches;
- touch Apnea experimental;
- touch Snorkeling experimental;
- touch Buddy Assist experimental;
- touch Exploration Lab;
- modify files excluded from `project.yml`;
- apply patches;
- auto-fix issues;
- redesign Watch UI;
- change Watch visual identity;
- change Watch dive/depth/ascent algorithms;
- change TTV semantics;
- change Mission Mode semantics;
- change sensor source policy;
- change App Intents behavior;
- change WatchConnectivity trust model;
- weaken legal/safety disclaimers;
- introduce certified dive-computer claims;
- introduce certified decompression-planner claims;
- add Bühlmann / Ratio Deco / CCR decompression calculation to Watch unless already implemented and in MAIN;
- claim physical QA passed unless actually executed;
- claim Apple Watch Ultra underwater validation passed unless actually executed.

## PRESERVE

- MAIN-only scope;
- Apple Watch dark/neon underwater UI;
- BUSSOLA terminology;
- no COMPASSO;
- Mission Mode as internal UI/runtime profile only;
- TTV as informational live index only;
- non-certified diving companion positioning;
- manual/no-depth session truthfulness;
- metric internal storage;
- legal/safety onboarding;
- App Intent legal/safety gate;
- depth safety 35 / 38 / 40 m policy;
- automatic start threshold and debounce policy;
- manual start from Live screen if currently implemented;
- Watch as source of truth for Watch-stored images;
- sync HMAC/peer-secret trust model;
- signed ACK policy where implemented;
- physical QA gates as external evidence requirements.

---

# CURRENT DEVELOPMENT CONTEXT TO RESPECT

The current DIR DIVING product context includes or may include:

## iOS-side advanced planning features

The iOS Companion planner may now include or be moving toward:

- Bühlmann ZHL-16C;
- Base / Deco / Technical modes;
- CCR / Rebreather planning;
- setpoint / diluent / bailout concepts;
- OC vs CCR mode separation;
- Ratio Deco;
- Tissue Loading analytics;
- Narcotic Loading / END / PPN2;
- MOD / PPO2 / Dalton validation;
- gas roles:
  - Back Gas;
  - Travel;
  - Deco;
  - Bailout;
  - Diluent if CCR is implemented;
  - Oxygen / bailout gases if CCR is implemented;
- Planner ↔ Checklist sync;
- Manual Dive;
- PDF / Share export;
- CSV / Subsurface export;
- Unit conversion.

## Watch-side expectation

The Watch MAIN app must be audited for compatibility with these developments, but the Watch must not accidentally become a certified decompression computer.

Unless explicitly implemented in MAIN, the Watch should generally remain:
- a live underwater companion;
- depth/runtime/ascent/TTV/safety alert interface;
- log capture device;
- reminder/image/compass/GPS/sync interface;
- not a CCR decompression controller;
- not a Bühlmann decompression computer;
- not a Ratio Deco computer;
- not a primary life-support controller.

If CCR / Rebreather data is synced to Watch, the audit must verify:
- it is clearly labelled;
- it does not alter depth/runtime/ascent/TTV calculations unless explicitly designed and tested;
- it does not generate unsafe live deco authority;
- bailout / diluent / setpoint data is not confused with OC gas consumption;
- Watch export/sync preserves data without fabricating decompression advice.

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
   - all Watch targets;
   - source folders;
   - excluded files;
   - test targets;
   - entitlements;
   - bundle IDs;
   - Watch/iOS companion relationship.

6. Confirm Watch MAIN target:
   - DIRDiving Watch App.

7. Confirm experimental exclusions.

Watch excluded should include:
- `Views/ApneaView.swift`
- `Views/SnorkelingView.swift`
- `Views/BuddyAssistView.swift`
- `Views/ExperimentalConceptsView.swift`
- `Utils/ExperimentalFeatures.swift`
- Buddy / Exploration models and services if not part of MAIN.

8. Run if environment allows:

   ```bash
   xcodegen generate

   xcodebuild -scheme "DIRDiving Watch App" \
     -destination 'generic/platform=watchOS Simulator' \
     CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

   xcodebuild -scheme "DIRDiving Watch Algorithm Tests" \
     -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' test
   ```

9. If shared models/codecs are touched or audited for compatibility, optionally run iOS build/tests as validation only:

   ```bash
   xcodebuild -scheme "DIRDiving iOS" \
     -destination 'generic/platform=iOS Simulator' \
     CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

   xcodebuild -scheme "DIRDiving iOS Algorithm Tests" \
     -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
   ```

10. Do not fix build/test failures. Record them.

11. Before auditing, print:
   - branch;
   - commit;
   - dirty files;
   - targets found;
   - experimental exclusions confirmed;
   - build status;
   - test status;
   - files/directories to inspect.

STOP if branch is not `main`.

---

# PHASE 1 — WATCH REPOSITORY / ARCHITECTURE ANALYSIS

Analyze:
- repository structure;
- Watch target membership;
- shared files between Watch and iOS;
- duplicated models;
- stale/dead files;
- orphan views/services;
- accidental experimental dependencies;
- build settings;
- entitlements;
- generated project policy;
- localization resources;
- Watch test coverage;
- documentation consistency;
- App Store/TestFlight docs.

Check for:
- files compiled into wrong target;
- code included but unreachable;
- code reachable but untested;
- stale docs contradicting runtime;
- experimental references in MAIN;
- dead functions hiding real bugs;
- duplicated Watch/iOS algorithms with diverging behavior;
- build scripts that drift from `project.yml`;
- CCR/Rebreather/iOS planner docs implying Watch features that do not exist.

Output architecture findings grouped into:
- Watch runtime;
- shared models/codecs;
- build/project;
- tests;
- docs/release.

---

# PHASE 2 — WATCH CORE ALGORITHM / RUNTIME AUDIT

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

## Views using algorithmic/runtime state

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

Audit for:
- dive lifecycle bugs;
- auto-start / manual-start conflicts;
- duplicate session prevention;
- active draft restore bugs;
- pending finalization bugs;
- timer/race issues;
- stale/frozen depth bugs;
- invalid depth handling;
- 35/38/40 m safety threshold bugs;
- ascent-rate bugs;
- alarm/haptic throttling bugs;
- haptic storm risk;
- Mission Mode accidentally affecting algorithms;
- GPS authorization/lifecycle battery risk;
- App Intent legal-gate bypass;
- sensor source/simulation release risk;
- WatchConnectivity routing bugs;
- sync replay/tamper risks;
- local file persistence bugs;
- UserImageStore path traversal;
- CSV export consistency;
- crash risks in compact Watch UI state.

---

# PHASE 3 — APPLE WATCH DIVE START AUDIT

Verify:

## Manual start

- Manual Start Dive button on initial / Live screen.
- Manual start does not fake unavailable depth.
- Manual start creates a truthful session lifecycle.
- Manual start produces correct runtime.
- Manual start integrates with GPS entry/exit where intended.
- Manual start is blocked or clearly marked when illegal state exists.
- Manual start is available through App Intent / Action Button only after legal acceptance if implemented.

## Automatic start

- Automatic dive start when depth > 1.0 m or configured threshold.
- Debounce / sample count rules.
- Start threshold exact boundary.
- Submersion state handling.
- No start at repeated 0 m simulation stream.
- No duplicate auto-start when already manually active.

## Collision handling

- Manual + automatic trigger collision.
- Manual start followed by real depth transition.
- Automatic start followed by manual stop if supported.
- Repeated rapid start/stop taps.
- App relaunch during active manual dive.
- App relaunch during automatic dive.
- Draft consistency after relaunch.

Output:
- Dive Start readiness %.
- Dive Start verdict.
- Required tests and QA gaps.

---

# PHASE 4 — DIVE REMINDERS ENGINE AUDIT

Audit:
- multiple reminders support;
- maximum configured reminders;
- single reminder mode;
- recurring reminder mode;
- reminder scheduling persistence;
- reminder runtime trigger accuracy;
- reminder message length validation;
- reminder localization IT/EN;
- reminder overlay rendering;
- reminder aggregation behavior;
- haptic integration;
- reminder acknowledgement if implemented;
- reminder priority relative to alarms;
- safety alert priority over reminders;
- behavior after pause/resume;
- behavior after active draft restore;
- behavior after app relaunch;
- behavior during Mission Mode;
- behavior during high-priority depth/ascent warning.

Test:
- 1 reminder;
- 5 reminders;
- 10 reminders;
- simultaneous reminders;
- reminder during runtime alarm;
- reminder during depth alarm;
- reminder during ascent warning;
- reminder during 35/38/40 m depth safety state;
- reminder after pause/resume;
- reminder after active draft restore;
- reminder after finalization;
- reminders with too-long message;
- reminders in IT/EN locale.

Output:
- Reminder readiness %.
- Reminder verdict.
- Reminder issue list.
- Required tests.

---

# PHASE 5 — USER IMAGES / DIVE IMAGES / INVENTORY / DELETE AUDIT

Audit:
- image visibility before dive;
- image visibility during dive;
- image transfer from iPhone;
- resolution conversion workflow;
- converted image flagging;
- warning localization IT/EN;
- image inventory consistency;
- Watch as source of truth;
- iOS-sourced inventory must not be invented;
- deletion from Watch;
- deletion from iOS Companion request;
- Watch-side delete execution;
- Watch delete ACK;
- iOS success only after Watch ACK;
- stale inventory states;
- unknown ACK/request handling;
- duplicate ACK handling;
- storage limits;
- file protection;
- corrupted image handling;
- path traversal rejection;
- bundled image read-only protection;
- no effect on dive metrics;
- no collision with dive sync messages.

Verify:
- uploaded image can be deleted on Watch;
- bundled image cannot be deleted;
- iOS can list Watch-sourced uploaded images if inventory sync is implemented;
- iOS cannot delete arbitrary paths;
- Watch rejects unsafe filenames;
- image import rejects corrupted non-image bytes if implemented;
- inventory updates after import/local delete/remote delete;
- no performance storm from repeated inventory updates.

Output:
- Image subsystem readiness %.
- Image inventory/delete readiness %.
- Image subsystem verdict.
- Security/privacy findings.

---

# PHASE 6 — MISSION MODE AUDIT EXTENSION

Verify Mission Mode does NOT alter:

- depth sampling;
- runtime;
- max depth;
- average depth;
- TTV;
- ascent rate;
- GPS capture;
- safety alarms;
- reminder timing;
- sync payloads;
- export values;
- image visibility;
- image inventory/delete logic;
- CCR/Rebreather state if synced from iOS;
- any safety-critical computation.

Verify:
- Mission Mode icon visibility;
- Mission Mode persistence;
- auto-enable on dive start if configured;
- manual enable/disable behavior;
- pending manual activation for next dive if implemented;
- auto-disable after dive if designed;
- clear wording that it does not enable Apple system Low Power Mode;
- no misleading copy about battery/low-power system control.

Output:
- Mission Mode readiness %.
- Mission Mode verdict.
- Mission Mode invariant test gaps.

---

# PHASE 7 — DEVELOPER SENSOR SOURCE AUDIT

Audit:

Settings > Developer > Sensor Source

Options:
- Automatic
- Apple Sensor
- Simulation

Verify:
- hidden behind developer unlock;
- not exposed to public users;
- simulation clearly identified;
- simulation never active by default in release;
- automatic remains production default;
- stored simulation mode is migrated/reset in release if required;
- automatic fallback to Mock is visibly labelled;
- simulation/fallback never looks like real depth automation;
- legal/safety copy remains truthful;
- App Store/TestFlight risk documented.

Output:
- Sensor Source readiness %.
- Sensor Source verdict.

---

# PHASE 8 — WATCH ICON / BRANDING AUDIT

Verify:
- Apple Watch app icon updated;
- top-left octopus icon visible;
- Mission Mode icon does not conflict with octopus icon;
- icon placement consistent across screens;
- icon visible underwater;
- icon does not cover safety banners;
- icon consistent during navigation;
- icon accessible labels if needed;
- no old placeholder icon remains in compiled assets.

Output:
- Branding readiness %.
- Branding verdict.

---

# PHASE 9 — UNIT CONSISTENCY EXTENSION

Verify unit consistency for:

- depth;
- runtime;
- temperature;
- ascent rate;
- alarms;
- reminders;
- dive details;
- logbook;
- export;
- GPS if displayed;
- image metadata if displayed;
- CCR/Rebreather imported summary fields if displayed;
- synced iOS planner/checklist metadata if displayed.

Metric ↔ Imperial consistency:

- meters ↔ feet;
- Celsius ↔ Fahrenheit;
- m/min ↔ ft/min;
- bar ↔ psi if Watch displays pressure;
- runtime formatting;
- export metric policy if intentionally metric.

Output:
- Unit consistency readiness %.
- Unit consistency verdict.

---

# PHASE 10 — CCR / REBREATHER & ADVANCED PLANNER COMPATIBILITY AUDIT

This phase audits Watch compatibility with the new CCR & Co. iOS-side developments.

## Critical principle

The Watch must not accidentally become a CCR controller or certified decompression computer unless explicitly designed, validated and legally positioned as such.

Audit whether any synced or displayed CCR/Rebreather data exists in Watch MAIN.

Search for:
- CCR
- Rebreather
- setpoint
- setPoint
- diluent
- loop
- bailout
- scrubber
- CNS
- OTU
- Bühlmann
- Buhlmann
- RatioDeco
- Ratio Deco
- Tissue
- Narcotic
- END
- PPN2
- PPO2
- gas role
- planner mode
- checklist gas

Verify:

## If CCR/Rebreather is NOT implemented on Watch

- No UI falsely suggests CCR live control.
- No Watch calculation pretends to manage setpoint/deco.
- No stale iOS planner docs imply Watch has CCR control.
- Watch sync ignores unsupported CCR payloads safely or stores only documented metadata.
- Export does not fabricate CCR values.
- User sees no misleading CCR/OC mixture.

## If CCR/Rebreather metadata IS displayed on Watch

Verify:
- it is labelled as planner/checklist/reference data;
- setpoint values are not used as live PPO2 without sensor proof;
- bailout gas is not consumed as normal OC gas unless explicitly designed;
- diluent is labelled separately from bailout/deco/back gas;
- no live deco obligation is generated from CCR data;
- reminders/checklists related to CCR are informational;
- export/sync preserve values without inventing missing data;
- missing CCR fields are not displayed as zero.

## If CCR/Rebreather logic affects Watch calculations

This should be treated as a HIGH / CRITICAL finding unless supported by:
- explicit architecture;
- tests;
- disclaimers;
- validation;
- physical QA;
- legal positioning.

Output:
- CCR/Rebreather Watch compatibility readiness %.
- CCR/Rebreather Watch verdict.
- List of any unsafe CCR assumptions.

---

# PHASE 11 — APP INTENTS / ACTION BUTTON AUDIT

Audit:
- start manual dive intent if present;
- end manual dive intent if present;
- stopwatch toggle/reset;
- alarm acknowledge;
- bearing set/clear;
- reminder acknowledge if present;
- Mission Mode toggle if present;
- image-related intents if present.

Verify:
- all safety-relevant intents fail closed before legal/safety onboarding acceptance;
- legal version bump blocks intents until re-accepted;
- intent cannot start hidden simulation as if real depth;
- intent cannot bypass sensor source policy;
- intent cannot bypass active dive state validation;
- intent cannot delete images without safe Watch-side validation if image intents exist;
- haptics respect global toggle;
- error messages localized IT/EN.

Output:
- App Intents readiness %.
- Action Button safety verdict.

---

# PHASE 12 — WATCHCONNECTIVITY / SYNC / SECURITY AUDIT

Audit:
- Watch → iOS dive session sync;
- iOS → Watch session push;
- iOS → Watch photo transfer;
- Watch → iOS photo import ACK;
- Watch image inventory response;
- iOS image delete request;
- Watch image delete ACK;
- tombstones;
- duplicate ID handling;
- peer secret trust;
- HMAC signing;
- signed ACK;
- reset trust;
- replay protection;
- changed peer rejection;
- unsupported CCR/Rebreather payload handling.

Verify:
- no unsigned payload can alter safety-critical state;
- missing/invalid ACK does not falsely mark delivery complete;
- image ACKs cannot be confused with dive ACKs;
- inventory payloads cannot be routed as dive payloads;
- delete requests cannot delete outside UserImages;
- CCR/Rebreather metadata from iOS cannot corrupt Watch dive logs;
- malformed payloads fail safely.

Output:
- Sync/security readiness %.
- Sync/security verdict.

---

# PHASE 13 — PERFORMANCE / BATTERY / MEMORY AUDIT

Analyze:

## CPU

- Watch live timer updates;
- depth processing;
- ascent calculation;
- reminder scheduling;
- haptic coordinators;
- image inventory generation;
- sync payload parsing;
- export generation.

## Memory

- image decoding/storage;
- user image inventory;
- dive samples;
- retained timers/tasks;
- export buffers;
- sync queues.

## Battery

- GPS updates;
- depth sensor session;
- timers;
- haptics;
- reminders;
- WatchConnectivity retries;
- image inventory sync;
- Mission Mode invariant;
- always-on display behavior if applicable.

## SwiftUI

- excessive state publishes;
- unnecessary body invalidations;
- heavy computed properties;
- repeated formatters/allocation;
- navigation/state loops;
- overlay rendering conflicts;
- reminders + safety banners + image views interaction.

Output:
- Performance readiness %.
- Battery readiness %.
- Watch memory readiness %.

---

# PHASE 14 — TEST COVERAGE ANALYSIS

Inspect:

- `Tests/WatchAlgorithmTests/*`

Report:
- current tests;
- tests that pass/fail/skipped;
- missing tests;
- brittle tests;
- tests that do not isolate state;
- tests that rely on order;
- missing reminder tests;
- missing image inventory/delete tests;
- missing Mission Mode invariant tests;
- missing sensor source release-policy tests;
- missing App Intent legal-gate tests;
- missing CCR/Rebreather compatibility tests;
- missing WatchConnectivity payload routing tests;
- missing unit conversion tests;
- missing physical QA.

Create:
- automated Watch algorithm test plan;
- simulator QA plan;
- physical Watch Ultra QA plan;
- paired Watch/iPhone QA plan;
- underwater validation plan;
- security regression plan;
- performance regression plan;
- CCR/Rebreather compatibility QA plan.

---

# PHASE 15 — STATIC TOOLING / SCAN SUGGESTIONS

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
- grep for hardcoded secrets:
  - API keys;
  - tokens;
  - private keys;
  - Apple credentials;
- grep for TODO/FIXME in MAIN;
- grep for hardcoded user-facing strings;
- grep for URL/file path construction;
- grep for `.onChange` patterns that mutate observed state;
- grep for `DispatchQueue.main.asyncAfter`;
- grep for timers/tasks not cancelled;
- grep for file delete/write paths;
- grep for `CCR`;
- grep for `Rebreather`;
- grep for `setpoint`;
- grep for `diluent`;
- grep for `bailout`;
- grep for `reminder`;
- grep for `companionPhotoInventory`;
- grep for `companionPhotoDelete`;
- grep for `ackSignature`.

Do not fix. Record findings.

---

# PHASE 16 — ISSUE CLASSIFICATION

For every issue, classify:

Severity:
- CRITICAL;
- HIGH;
- MEDIUM;
- LOW;
- INFO.

Priority:
- P0 — must fix before compile/use;
- P1 — must fix before internal TestFlight;
- P2 — must fix before external TestFlight;
- P3 — must fix before App Store;
- P4 — post-release optimization.

Area:
- bug;
- performance;
- security;
- privacy;
- data integrity;
- sync;
- export;
- persistence;
- algorithm integration;
- UI-state logic;
- localization;
- build/release;
- tests;
- docs;
- physical QA;
- Dive Start;
- Reminders;
- Images;
- Mission Mode;
- Sensor Source;
- Branding;
- Units;
- CCR/Rebreather compatibility;
- App Intents.

Fix class:
- test-only;
- docs-only;
- copy/localization-only;
- UI-state fix;
- small functional;
- medium refactor;
- security hardening;
- performance optimization;
- architecture;
- external QA/process.

For each issue include:
- ID;
- title;
- app;
- area;
- file/function;
- description;
- evidence from code;
- user impact;
- safety impact;
- security/privacy impact;
- performance impact;
- proposed fix;
- estimated effort;
- regression risk;
- tests required;
- priority;
- dependencies;
- acceptance criteria.

---

# PHASE 17 — READINESS MATRIX ADDITIONS

Include these readiness categories:

| Feature | Readiness |
|---|---:|
| Watch Core Runtime | XX% |
| Dive Start | XX% |
| Reminders | XX% |
| Images / Inventory / Delete | XX% |
| Mission Mode | XX% |
| Sensor Source | XX% |
| Branding | XX% |
| Units | XX% |
| App Intents / Action Button | XX% |
| Sync / ACK / Trust | XX% |
| CCR/Rebreather Compatibility | XX% |
| Performance / Battery | XX% |
| Security / Privacy | XX% |
| Tests | XX% |
| Physical QA Evidence | XX% |
| Overall | XX% |

Overall readiness must include these categories.

---

# PHASE 18 — FINAL REPORT REQUIRED

Create:

`Docs/WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

The report must contain:

## A. Executive Summary

- Watch readiness %;
- mathematical/runtime robustness %;
- safety algorithm confidence %;
- lifecycle confidence %;
- sync/data confidence %;
- security readiness %;
- performance readiness %;
- CCR/Rebreather compatibility readiness %;
- TestFlight readiness;
- App Store readiness;
- most urgent issues.

## B. Scope Confirmation

- branch;
- commit;
- target list;
- experimental exclusions;
- build/test results;
- static scan results if available.

## C. Architecture Analysis

- target membership;
- shared files;
- dead/stale code;
- experimental isolation;
- build risks;
- documentation drift.

## D. Apple Watch Core Runtime Analysis

- depth lifecycle;
- manual/automatic start;
- draft restore;
- GPS;
- haptics;
- timers;
- alarms;
- TTV;
- ascent.

## E. Dive Start Verdict

Must answer:
- manual start reachable?
- automatic start works?
- duplicate prevention works?
- manual + automatic collision safe?
- restore after relaunch safe?

## F. Reminder Verdict

Must answer:
- multiple reminders implemented?
- recurring reminders reliable?
- haptics/overlays safe?
- safety alerts take priority?

## G. Image Subsystem Verdict

Must answer:
- image transfer works?
- inventory sync truthful?
- deletion from Watch safe?
- deletion from iOS requires Watch ACK?
- bundled images protected?
- image subsystem has no effect on dive metrics?

## H. Mission Mode Verdict

Must answer:
- does it affect depth sampling?
- does it affect depth display?
- does it affect reminders?
- does it affect haptics?
- does it affect GPS?
- does it affect alarms?
- does it affect sync/export?
- is Apple Low Power Mode wording truthful?

## I. Sensor Source Verdict

Must answer:
- developer unlock protected?
- automatic default safe?
- simulation clearly identified?
- release path safe?

## J. Branding Verdict

Must answer:
- icon updated?
- octopus visible?
- consistent underwater?
- no safety overlay conflicts?

## K. Unit Consistency Verdict

Must answer:
- metric/imperial consistent?
- export policy clear?
- units correct in alarms/reminders/logbook?

## L. CCR/Rebreather Compatibility Verdict

Must answer:
- does Watch implement CCR/Rebreather logic?
- if not, does it avoid implying it?
- if it displays CCR metadata, is it labelled reference-only?
- do CCR fields affect Watch calculations?
- are unsupported CCR payloads safe?
- are bailout/diluent/setpoint fields handled truthfully?

## M. App Intents / Action Button Verdict

Must answer:
- legal gate enforced?
- unsafe shortcuts blocked?
- intents localized?
- hardware behavior safe?

## N. Sync / Security / Payload Validation

- Watch → iOS;
- iOS → Watch;
- images;
- reminders if synced;
- CCR/Rebreather metadata if synced;
- tombstones;
- peer trust;
- ACKs;
- duplicate IDs;
- malformed payloads.

## O. Performance / Battery / Memory

- CPU;
- memory;
- battery;
- SwiftUI invalidation;
- Watch-specific constraints.

## P. Test Coverage Analysis

- current tests;
- failing tests;
- missing tests;
- test isolation risks;
- physical QA gaps.

## Q. Issue Matrix

Table columns:
- ID;
- severity;
- priority;
- area;
- file/function;
- title;
- user impact;
- safety/security/performance impact;
- proposed fix;
- estimated effort.

## R. Detailed Action Plan

Grouped by:
1. P0;
2. P1;
3. P2;
4. P3;
5. P4.

For every action:
- issue IDs addressed;
- files likely involved;
- implementation order;
- risk;
- tests required;
- acceptance criteria.

## S. Physical Watch Ultra QA Plan

Must include:
- real depth sensor;
- underwater start;
- underwater stop;
- ascent warnings;
- depth safety;
- haptics;
- GPS;
- reminders;
- Mission Mode;
- images;
- paired iPhone sync;
- App Intents / Action Button.

## T. CCR/Rebreather Compatibility QA Plan

Must include:
- iOS CCR plan synced to Watch if supported;
- unsupported CCR payload ignored safely if not supported;
- bailout/diluent/setpoint metadata truthfulness;
- no live CCR/deco control claim;
- export/log consistency.

## U. Final Verdict

Answer clearly:
- Is Watch algorithm/runtime ready?
- Is Watch safe for internal TestFlight?
- Is Watch safe for external TestFlight?
- Is Watch App Store ready?
- What blocks 100% Watch readiness?
- What blocks 100% Watch security readiness?
- What blocks 100% Watch performance readiness?
- What must be fixed first?

---

# PHASE 19 — VALIDATION

After creating the report, verify:
- report file exists;
- report is not empty;
- issue matrix exists;
- readiness matrix exists;
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

- No production source code is modified.
- No UI is modified.
- No business logic is modified.
- No algorithms are modified.
- No security model is modified.
- Report is created at:

  `Docs/WATCH_COMPLETE_ALGORITHM_AUDIT_CURRENT.md`

- Report includes:
  - Dive Start readiness %;
  - Reminder readiness %;
  - Image subsystem readiness %;
  - Mission Mode readiness %;
  - Sensor Source readiness %;
  - Branding readiness %;
  - Unit consistency readiness %;
  - App Intents readiness %;
  - Sync/Security readiness %;
  - CCR/Rebreather compatibility readiness %;
  - Performance/Battery readiness %;
  - full issue matrix;
  - detailed action plan;
  - physical QA plan;
  - CCR/Rebreather compatibility QA plan.

- All physical/external QA items are marked as pending, not passed.
- Final git status confirms only report/docs changed.

If anything cannot be fully analyzed:
- document the limitation;
- explain why;
- propose the exact next inspection step.
