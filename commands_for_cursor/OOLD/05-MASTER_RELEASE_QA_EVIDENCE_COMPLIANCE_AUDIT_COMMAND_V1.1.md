# LAUNCH ORDER 05

**Launch order note:** FIFTH — release, QA, evidence, legal claims and Apple platform gate. Run only after technical/UI/code audits, because this is the evidence and release-readiness gate.

**Canonical numbered filename:** `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING RELEASE / QA / EVIDENCE / LEGAL CLAIMS AUDIT — V1.1

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Targets:**  

```text
DIRDiving Watch App
DIRDiving iOS
DIRDiving Watch Algorithm Tests
DIRDiving iOS Algorithm Tests
```

**Task type:** audit-only, read-only, full release-gate / QA-evidence / legal-claims / compliance / TestFlight / App Store readiness audit  

**Merged source commands:**

```text
12-DIR_DIVING_TEST_QA_EVIDENCE_AUDIT_V3.0.md
13-DIR_DIVING_RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_V3.0.md
```

**Updated for latest development:**

```text
Diving / Gauge / Full Computer
Apnea
Snorkeling
iOS Settings mode switcher
Activity-specific Settings
Strict activity-specific Logbooks
Watch Full Computer forensic audit
iOS Planner / CCR reference-only
Planner briefing cards
Apple platform entitlement/capability gates
Physical QA and external validation separation
```

---

# 0. ABSOLUTE EXECUTION RULE

This is strictly read-only.

Do **not** modify:

- production code;
- tests;
- project configuration;
- assets;
- mockups;
- localization resources;
- runtime documentation;
- algorithms;
- business logic;
- sync schemas;
- persistence schemas;
- security model;
- Git history.

You may create or update only the requested audit reports and matrices under `Docs/`.

Do not give legal certification approval.

Do not claim:

```text
Apple Watch is certified
DIR Diving is EN13319 certified
DIR Diving is ISO 6425 certified
DIR Diving is a medical device
DIR Diving is a certified decompression computer
DIR Diving is a certified CCR controller
Apple Watch physical underwater QA passed
CMAltimeter physical QA passed
Depth sensor QA passed
paired Watch/iPhone QA passed
Subsurface/external Bühlmann validation passed
App Store readiness passed
```

unless actual evidence exists.

If evidence is unavailable, mark:

```text
PENDING_PHYSICAL
PENDING_EXTERNAL_VALIDATION
PENDING_LEGAL_REVIEW
PENDING_CERTIFICATION_REVIEW
PENDING_APP_STORE_REVIEW
NOT_EXECUTED
```

---

# 1. MASTER OBJECTIVE

Perform the final release-gate audit combining:

1. Automated test coverage.
2. Simulator QA evidence.
3. Physical device QA evidence.
4. Paired Watch/iPhone QA evidence.
5. Underwater/depth sensor QA evidence.
6. External validation evidence.
7. Requirement-to-test traceability.
8. Claims-to-evidence traceability.
9. Release readiness.
10. Safety wording.
11. Legal/compliance wording.
12. TestFlight metadata.
13. App Store metadata.
14. Privacy disclosures.
15. Entitlements and Apple platform capabilities.
16. Store assets and screenshots.
17. Support, incident, rollback and escalation process.
18. Professional-product truthfulness.

This is the final gate after the technical and UI/UX master audits.

---

# 2. REQUIRED OUTPUT FILES

Create or replace:

```text
Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md
Docs/MASTER_REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv
Docs/MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv
Docs/MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md
Docs/MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv
Docs/MASTER_RELEASE_GATE_MATRIX_CURRENT.csv
Docs/MASTER_APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md
Docs/MASTER_PLATFORM_ENTITLEMENT_CAPABILITY_MATRIX_CURRENT.csv
Docs/MASTER_PRIVACY_MANIFEST_DISCLOSURE_MATRIX_CURRENT.csv
Docs/MASTER_READINESS_TO_100_PLAN_CURRENT.md
Docs/MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv
Docs/MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv
Docs/MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv
Docs/MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv
Docs/MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md
```

---


# 2A. LATEST RELEASE GATES — SHALLOW DEPTH, SUBMERGED AUTO-LAUNCH, ACTION BUTTON AND GF PRESETS

The release audit must explicitly verify the evidence and claims for the latest Watch developments.

## 2A.1 Apple shallow-depth entitlement gate

Audit:

```text
Config/DIRDiving.WithShallowDepth.entitlements
Config/DIRDiving.WithWaterSubmersion.entitlements
Config/DIRDiving.entitlements
project.yml
App/Info.plist
Docs/BUILD_AND_XCODEGEN_WORKFLOW.md
Apple provisioning profile evidence if present
```

Classify:

```text
shallow-depth capability available
full-depth capability unavailable / pending unless evidenced
default signing alignment
Info.plist DIRDepthEntitlementTier alignment
WKSupportsAutomaticDepthLaunch alignment
WKBackgroundModes underwater-depth alignment
TestFlight eligibility
App Store entitlement risk
```

## 2A.2 Physical QA gates for water auto-open and hardware controls

Do not mark these passed without real evidence:

```text
WATCHOS_SYSTEM_AUTO_LAUNCH_LISTING_EVIDENCE
WATER_AUTO_OPEN_PHYSICAL_QA
WATER_LOCK_PHYSICAL_QA
ACTION_BUTTON_PHYSICAL_QA
DIGITAL_CROWN_PHYSICAL_QA
SHALLOW_DEPTH_WET_QA
GAUGE_SHALLOW_WATER_QA
FULL_COMPUTER_SHALLOW_INTERNAL_TEST_QA
```

## 2A.3 Developer shallow testing release gate

Verify:

```text
Developer shallow Gauge testing is hidden from public users.
Developer shallow Full Computer testing is hidden from public users.
TestFlight/internal flags are labelled as internal testing.
No App Store metadata or screenshots expose developer shallow testing as a public feature.
No claim says shallow testing is certified decompression guidance.
```

## 2A.4 Full Computer GF preset release evidence

Verify:

```text
GF preset selection has automated tests.
GF iOS plan override has automated tests.
GF active-dive lock has automated tests or QA templates.
GF logbook persistence has automated tests or QA templates.
Physical Watch GF Settings QA remains pending unless executed.
Release copy describes GF as user conservatism setting, not validation/certification.
```

Create or update:

```text
Docs/MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv
Docs/MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv
Docs/MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv
Docs/MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv
Docs/MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md
```

---

# 3. SEVERITY MODEL

## P0 — blocks any release/TestFlight

Use P0 for:

- unsupported safety/certification claim;
- false claim that physical QA passed;
- false claim that external decompression validation passed;
- Apple Watch Full Computer claim unsupported by validation;
- App Store metadata implying certified dive computer;
- CCR controller implication;
- missing legal/safety disclaimer on safety-relevant flow;
- missing privacy disclosure for sensitive data;
- missing entitlement/capability for a required runtime feature;
- requirement with no test/evidence for a safety-critical path.

## P1 — blocks internal TestFlight

Use P1 for:

- safety-relevant feature lacking automated test evidence;
- no requirement-to-test matrix;
- physical QA plan missing for depth/altitude/sync path;
- legal wording incomplete;
- TestFlight metadata misleading;
- App Store screenshots incomplete or misleading;
- privacy manifest incomplete;
- support/rollback process missing.

## P2

Use P2 for incomplete external validation plan, non-safety test gaps, secondary claims lacking citation/evidence, incomplete screenshots, incomplete accessibility QA evidence.

## P3

Documentation clarity, polish, non-blocking release-process improvements.

---

# 4. PREFLIGHT

Run:

```bash
git branch --show-current
git rev-parse --short HEAD
git rev-parse HEAD
git fetch --prune origin
git status --short
git status -sb
git remote -v
xcodebuild -version
```

Stop if branch is not `main`.

Inspect:

```text
project.yml
README.md
Docs/**
Tests/**
Scripts/**
iOSApp/**
Views/**
Services/**
Models/**
Utils/**
Shared/**
Resources/**
Assets.xcassets/**
PrivacyInfo.xcprivacy
*.entitlements
fastlane/**
metadata/**
screenshots/**
```

Record:

```text
branch
commit
dirty files
test targets
available test results
physical QA evidence files
external validation files
legal review files
privacy manifests
entitlements
App Store / TestFlight metadata
screenshots
support docs
rollback docs
```

---

# 5. TEST / QA / EVIDENCE AUDIT

Create:

```text
Docs/MASTER_REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv
Docs/MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv
Docs/MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md
```

Cover:

```text
startup and activity selection
Diving Gauge
Diving Full Computer
Bühlmann
Schreiner
altitude / CMAltimeter
gas switching
deco stop state machine
multilevel decompression
Apnea lifecycle/recovery
Snorkeling GPS/dips/navigation
Settings isolation
Logbook ownership
sync/schema
migration
backup/restore
localization/accessibility
security/privacy
performance
exports
Planner
CCR reference-only
briefing cards
Watch image inventory/delete
App Intents
Developer Sensor Source
Mission Mode
```

Classify evidence:

```text
automated unit
integration
UI/snapshot
simulator
physical Watch
physical iPhone
paired-device
underwater
pressure chamber / pressure pot
external reference
legal/compliance review
manual accessibility QA
manual localization QA
Instruments profiling
App Store Connect evidence
```

No evidence means not passed.

---

# 6. MANDATORY WATCH FULL COMPUTER EVIDENCE GATE

Trace production Watch path from:

```text
CMAltimeter.startAbsoluteAltitudeUpdates(to:withHandler:)
→ CMAbsoluteAltitudeData
→ sample validation
→ pending pre-dive environment proposal
→ explicit diver acceptance
→ confirmed environment
→ Full Computer start
→ logbook provenance
```

Evidence must prove:

- sample acquired immediately before Full Computer start;
- sample is fresh;
- sample is sufficiently accurate;
- sample is stable;
- sample remains non-authoritative until explicit acceptance;
- imported iPhone Plan is preserved unless diver accepts replacement;
- manual Watch setting is preserved unless diver accepts replacement;
- cancellation/timeout/error/inaccurate/unstable/stale samples fail closed;
- physical Apple Watch CoreMotion sample evidence exists or is marked pending.

Simulator-only evidence is insufficient for the physical gate.

Reject:

```text
cached CLLocationManager.location.altitude
hard-coded altitude
implicit sea-level fallback
missing sensor metadata
unretained async provider
unvalidated sample
automatic sensor authority
```

---

# 7. PHYSICAL DEVICE QA MATRIX

Create:

```text
Docs/MASTER_PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv
```

Include:

## Apple Watch

```text
physical install
depth sensor entitlement behavior
dry-run no environment start blocked
manual Watch environment accepted
imported iPhone plan accepted
CMAltimeter available
CMAltimeter unavailable
permission denied
stable sensor proposal
unstable sensor proposal
sensor accepted
sensor rejected preserving previous authority
background/foreground during sampling
relaunch before dive start
Full Computer checkpoint/restore
paired sync
logbook provenance
smallest Watch display
Apple Watch Ultra display
VoiceOver
haptics
Mission Mode
reminders
image inventory/delete
briefing cards
depth sensor wet test
ascent warning wet/dry safe test
controlled multilevel dive if possible
battery/thermal observation
```

## iPhone

```text
iPhone 14+
iPhone 15 Pro or dev device
startup
activity selection
Settings mode switch
Apnea Settings
Snorkeling Settings
Planner
Logbook 1k/5k
Snorkeling 50k route
PDF export
CSV export
Watch sync
iCloud backup
Privacy prompts
VoiceOver
Dynamic Type
Instruments profiling
```

Every unexecuted item remains `PENDING_PHYSICAL`.

---

# 8. EXTERNAL VALIDATION GAPS

Create:

```text
Docs/MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md
```

Cover:

```text
Bühlmann external validation
Schreiner external validation
Subsurface comparison
CCR external validation
Ratio Deco validation
Rock Bottom reference cases
Gas ledger reference cases
Repetitive-dive validation
PDF/export validation
privacy/legal review
certification strategy
accessibility manual review
App Store review readiness
```

External validation remains pending unless actual evidence exists.

---

# 9. CLAIMS / LEGAL / RELEASE AUDIT

Create:

```text
Docs/MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv
Docs/MASTER_RELEASE_GATE_MATRIX_CURRENT.csv
Docs/MASTER_APP_STORE_TESTFLIGHT_BLOCKERS_CURRENT.md
```

Audit all user-facing and release-facing claims:

```text
README
Docs
onboarding
legal acceptance
Settings
Planner
Full Computer
Watch live UI
PDF exports
briefing cards
App Store metadata
TestFlight metadata
screenshots
marketing copy
support docs
release notes
privacy policy
```

Verify:

- no unsupported certification claim;
- no claim that Apple Watch is certified where it is not;
- Full Computer wording consistent with capability and validation;
- Planner reference-only wording;
- CCR limitations;
- Apnea recovery not framed as medical guarantee;
- Snorkeling return guidance not framed as guaranteed navigation;
- GPS surface-only disclosure;
- CNS/OTU estimate wording;
- equipment/checklist limitations;
- Rock Bottom estimate wording;
- Gas ledger/cylinder bar estimate wording;
- briefings/cards reference-only wording;
- physical/external QA gates visible where needed;
- EN13319 strategy documentation;
- incident/rollback/release process;
- support/escalation path.

---

# 10. APPLE PLATFORM / ENTITLEMENT / CAPABILITY AUDIT

Create:

```text
Docs/MASTER_PLATFORM_ENTITLEMENT_CAPABILITY_MATRIX_CURRENT.csv
```

Audit:

```text
Submerged Depth and Pressure entitlement
CoreMotion / CMAltimeter usage
Location permission
Photos/files permissions
iCloud/KVS capability
WatchConnectivity capability
App Groups if used
HealthKit if used
Background modes if used
PrivacyInfo.xcprivacy
Info.plist usage descriptions
Watch/iOS bundle relationship
App Store category and age rating
Export/share file handling
Developer Sensor Source release gating
Simulation mode release gating
```

Classify:

```text
Required
Implemented
Missing
Simulator-only
Physical-device required
Apple approval required
Release blocker
```

---

# 11. PRIVACY MANIFEST / DISCLOSURE AUDIT

Create:

```text
Docs/MASTER_PRIVACY_MANIFEST_DISCLOSURE_MATRIX_CURRENT.csv
```

Audit data categories:

```text
dive profiles
depth samples
location/GPS
Snorkeling routes
photos/images
equipment/gas data
CCR/bailout data
notes
sync identifiers
device identifiers
diagnostics/logs
iCloud backup
exported files
briefing cards
App Intents
```

For each:

```text
collected
stored
synced
exported
shared
backed up
encrypted/protected
user-controllable
disclosed in privacy policy
declared in privacy manifest
release risk
```

---

# 12. RELEASE GATES

Create release gates for:

```text
Internal TestFlight
External TestFlight
App Store
Professional/Beta Diver Trial
Public Release
```

For each gate score:

```text
Build readiness
Automated test evidence
Simulator QA evidence
Physical Watch QA
Physical iPhone QA
Paired-device QA
External validation
Privacy readiness
Legal claims readiness
App Store assets
Support/rollback
Known blockers
Release decision
```

Allowed statuses:

```text
READY
CONDITIONAL
NOT_READY
PENDING_EVIDENCE
```

---

# 13. READINESS TO 100 PLAN

Create:

```text
Docs/MASTER_READINESS_TO_100_PLAN_CURRENT.md
Docs/MASTER_SHALLOW_DEPTH_RELEASE_GATE_MATRIX_CURRENT.csv
Docs/MASTER_WATER_AUTO_OPEN_PHYSICAL_QA_GATE_CURRENT.csv
Docs/MASTER_WATCH_HARDWARE_CONTROLS_QA_GATE_CURRENT.csv
Docs/MASTER_GF_PRESET_RELEASE_EVIDENCE_MATRIX_CURRENT.csv
Docs/MASTER_TESTFLIGHT_SHALLOW_DEPTH_RISK_ASSESSMENT_CURRENT.md
```

Group work:

## P0 before any safety-critical TestFlight

- unsupported claims;
- missing legal gate;
- missing privacy manifest;
- missing safety-critical test evidence;
- missing entitlement for required feature;
- false physical/external QA claim.

## P1 before internal TestFlight

- automated test gaps;
- basic physical install;
- paired sync smoke;
- Watch Full Computer dry-run evidence;
- Settings/Logbook ownership evidence;
- privacy policy update;
- TestFlight metadata wording.

## P2 before external TestFlight

- full physical matrix;
- Instruments profiling;
- external validation plan execution;
- screenshots;
- App Store metadata;
- support process.

## P3 before App Store

- final legal review;
- accessibility manual QA;
- localization manual QA;
- final release notes;
- incident/rollback drill.

---

# 14. MASTER REPORT STRUCTURE

Create:

```text
Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Commands Merged  
C. Latest Development Context  
D. Branch, Commit and Scope  
E. Build/Test Baseline  
F. Requirement-to-Test Traceability  
G. Automated Test Evidence  
H. Simulator QA Evidence  
I. Physical Apple Watch QA  
J. Physical iPhone QA  
K. Paired Watch/iPhone QA  
L. Underwater / Depth Sensor QA  
M. Watch Full Computer Altimeter Evidence Gate  
N. External Bühlmann / Schreiner Validation  
O. External Subsurface Validation  
P. CCR / Rebreather Validation  
Q. Ratio Deco / Rock Bottom / Gas Ledger Validation  
R. Localization / Accessibility Evidence  
S. Performance / Instruments Evidence  
T. Security / Privacy Evidence  
U. Claims Evidence Matrix  
V. Release Gate Matrix  
W. Apple Platform / Entitlement / Capability Audit  
X. Privacy Manifest / Disclosure Audit  
Y. TestFlight Readiness  
Z. App Store Readiness  
AA. Legal / Certification / EN13319 Strategy  
AB. Support / Incident / Rollback Process  
AC. Detailed Findings  
AD. Readiness to 100 Plan  
AE. Final Verdict

---

# 15. REQUIRED FINAL QUESTIONS

The report must explicitly answer:

1. Is the app ready for internal TestFlight?
2. Is the app ready for external TestFlight?
3. Is the app ready for App Store?
4. Are all safety-relevant requirements mapped to tests?
5. Are all physical-device gates executed or clearly pending?
6. Is Watch Full Computer altitude acquisition physically validated?
7. Is depth sensor / underwater QA complete or pending?
8. Is paired Watch/iPhone sync physically validated?
9. Is external Bühlmann/Schreiner validation complete?
10. Is Subsurface validation complete?
11. Is CCR validation complete or reference-only/pending?
12. Are all user-facing claims supported by evidence?
13. Is privacy manifest complete?
14. Are App Store/TestFlight metadata and screenshots truthful?
15. Are Apple entitlements/capabilities aligned?
16. Are support and rollback processes ready?
17. What blocks 100% release readiness?
18. What blocks internal TestFlight?
19. What blocks external TestFlight?
20. What blocks App Store?

Every `NO`, `PARTIAL`, `UNKNOWN`, `PENDING`, or `NOT_EXECUTED` must include severity, root cause, evidence gap, remediation and release impact.

---

# 16. FINAL VERDICT

Print exactly:

```text
MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT: PASS / PARTIAL / FAIL
BASELINE_CURRENT_AND_CLEAN: PASS / FAIL
BUILD_IOS: PASS / FAIL / NOT_EXECUTED
BUILD_WATCH: PASS / FAIL / NOT_EXECUTED
IOS_TESTS: PASS / FAIL / NOT_EXECUTED
WATCH_TESTS: PASS / FAIL / NOT_EXECUTED
REQUIREMENT_TEST_TRACEABILITY: PASS / FAIL
PHYSICAL_WATCH_QA: PASS / FAIL / PENDING_PHYSICAL
PHYSICAL_IOS_QA: PASS / FAIL / PENDING_PHYSICAL
PAIRED_WATCH_IOS_QA: PASS / FAIL / PENDING_PHYSICAL
UNDERWATER_DEPTH_SENSOR_QA: PASS / FAIL / PENDING_PHYSICAL
WATCH_FULL_COMPUTER_ALTITUDE_QA: PASS / FAIL / PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
EXTERNAL_SCHREINER_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
CCR_EXTERNAL_VALIDATION: PASS / FAIL / PENDING_EXTERNAL_VALIDATION
CLAIMS_EVIDENCE_ALIGNMENT: PASS / FAIL
LEGAL_CERTIFICATION_REVIEW: PASS / FAIL / PENDING_LEGAL_REVIEW
APPLE_ENTITLEMENT_CAPABILITY_ALIGNMENT: PASS / FAIL
PRIVACY_MANIFEST_DISCLOSURE_ALIGNMENT: PASS / FAIL
TESTFLIGHT_METADATA_TRUTHFULNESS: PASS / FAIL
APP_STORE_METADATA_TRUTHFULNESS: PASS / FAIL
SUPPORT_ROLLBACK_PROCESS: PASS / FAIL
INTERNAL_TESTFLIGHT_READINESS: READY / CONDITIONAL / NOT_READY
EXTERNAL_TESTFLIGHT_READINESS: READY / CONDITIONAL / NOT_READY
APP_STORE_READINESS: READY / CONDITIONAL / NOT_READY
P0_FINDINGS: <number>
P1_FINDINGS: <number>
P2_FINDINGS: <number>
P3_FINDINGS: <number>
OVERALL_QA_EVIDENCE_READINESS: <0-100>
OVERALL_CLAIMS_COMPLIANCE_READINESS: <0-100>
OVERALL_RELEASE_READINESS: <0-100>
RELEASE_BLOCKERS: <comma-separated IDs or NONE>
```

`PASS` is allowed only when all evidence exists. Missing physical/external/legal evidence means `PARTIAL` or `FAIL` depending on claimed readiness.

---

# 17. SUCCESS CRITERIA

The task is complete only if:

- no production code is modified;
- no tests are modified;
- no UI is modified;
- no business logic is modified;
- no algorithms are modified;
- all required reports/matrices are created;
- test/QA evidence is separated by evidence type;
- physical evidence is never faked;
- external validation is never faked;
- claims are mapped to evidence;
- Apple platform entitlements/capabilities are audited;
- privacy manifest/disclosures are audited;
- TestFlight/App Store blockers are listed;
- readiness-to-100 plan is produced;
- final git status confirms only Docs outputs changed.

Do not commit or push automatically.

Stop after producing the release/QA/evidence/compliance master audit and final summary.
