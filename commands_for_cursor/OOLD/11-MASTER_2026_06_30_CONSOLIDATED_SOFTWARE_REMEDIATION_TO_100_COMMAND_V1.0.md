# 11 — MASTER CURSOR / CODEX COMMAND — DIR DIVING CONSOLIDATED REMEDIATION FROM 2026-06-30 AUDIT TO 100% SOFTWARE READINESS — V1.0

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Baseline audit report:** `Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md`  
**Execution HEAD referenced by audit:** `451f8fb`  
**Relevant recent commits referenced by audit:**  
- `5d757cc` — Command 10 software remediation  
- `dbe5d8b` / `70cf0d9` — Snorkeling P1/P2/P3 software wave  
- `bb204f5` — command upgrade  
- `451f8fb` — full audit rerun  

**Command type:** implementation / remediation / tests / scripts / documentation truthfulness / non-regression  
**Execution mode:** code changes allowed only to solve software-actionable findings described in the audit report and related `Docs/` documents  
**Goal:** take **software/code readiness to 100%**, excluding physical QA, underwater QA, paired-device QA, external validation, legal review, certification review and App Store review, which must remain pending unless real evidence exists.

---

# 0. ABSOLUTE EXECUTION RULE

You are implementing remediation for the consolidated audit report:

```text
Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md
```

Before editing code, search and read every related document mentioned by the report inside the repository `Docs/` directory.

Required source documents to search/read if present:

```text
Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md
Docs/MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv
Docs/MASTER_FINDING_DEDUPLICATION_MATRIX_CURRENT.csv
Docs/MASTER_FINDING_DEPENDENCY_GRAPH_CURRENT.md
Docs/MASTER_REMEDIATION_PRIORITY_MATRIX_CURRENT.csv
Docs/MASTER_NON_REGRESSION_GATE_MATRIX_CURRENT.csv
Docs/MASTER_CURSOR_REMEDIATION_COMMAND_SEQUENCE_CURRENT.md
Docs/MASTER_AUDIT_RERUN_PLAN_CURRENT.md
Docs/MASTER_RELEASE_BLOCKER_BURNDOWN_PLAN_CURRENT.md
Docs/MASTER_READINESS_ROADMAP_7_14_30_DAYS_CURRENT.md
Docs/MASTER_UNRESOLVED_PHYSICAL_EXTERNAL_QA_REGISTER_CURRENT.csv
Docs/MASTER_DO_NOT_TOUCH_POLICY_REGISTER_CURRENT.md
Docs/MASTER_AUDIT_COMMAND_INTEGRITY_STATUS_CURRENT.csv
Docs/MASTER_REMEDIATION_OUTPUT_CONSUMPTION_MATRIX_CURRENT.csv
Docs/MASTER_ORCHESTRATOR_SEQUENTIAL_EXECUTION_LOG_CURRENT.csv
Docs/MASTER_ORCHESTRATOR_UPSTREAM_OUTPUT_COMPLETENESS_MATRIX_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_NON_REGRESSION_RESULTS_CURRENT.md
Docs/MASTER_CONSOLIDATED_INTERNAL_TESTFLIGHT_SOFTWARE_READINESS_CURRENT.md
Docs/MASTER_CONSOLIDATED_PHYSICAL_EXTERNAL_PENDING_AFTER_SOFTWARE_REMEDIATION_CURRENT.csv
Docs/MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_READINESS_TO_100_COMPLETION_SUMMARY_CURRENT.md
```

Also search for all documents containing these IDs:

```text
CONS-046
CONS-047
CONS-048
CONS-049
IOS-P1-001
Snorkeling
validate_commands_for_cursor_integrity
iOS Algorithm Tests
```

Use `rg` or equivalent:

```bash
rg -n "CONS-046|CONS-047|CONS-048|CONS-049|IOS-P1-001|Snorkeling|validate_commands_for_cursor_integrity|iOS Algorithm Tests" Docs commands_for_cursor Scripts Tests iOSApp Views Services Utils Shared project.yml
```

Do **not** guess missing findings.

If a required document is missing, report it in the final remediation report and continue only if the baseline report provides enough evidence to fix the issue safely.

Do **not** commit or push automatically.

Do **not** modify physical QA status, external validation status, legal review status, certification status or App Store readiness to PASS unless actual evidence exists.

---

# 1. READINESS TARGET

This command targets:

```text
SOFTWARE_READINESS = 100
CODE_READINESS = 100
AUTOMATED_TEST_GATE_READINESS = 100
COMMAND_INTEGRITY_SCRIPT_READINESS = 100
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS = READY
```

This command must **not** mark these as complete without real evidence:

```text
PHYSICAL_QA
UNDERWATER_QA
SHALLOW_DEPTH_WET_QA
SNORKELING_OPEN_WATER_QA
WATER_LOCK_PHYSICAL_QA
ACTION_BUTTON_PHYSICAL_QA
DIGITAL_CROWN_PHYSICAL_QA
PAIRED_WATCH_IPHONE_QA
EXTERNAL_BUHLMANN_VALIDATION
EXTERNAL_SCHREINER_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION
LEGAL_REVIEW
CERTIFICATION_REVIEW
APP_STORE_REVIEW
```

Expected final external/physical/legal posture:

```text
PHYSICAL_QA = PENDING_PHYSICAL
EXTERNAL_VALIDATION = PENDING_EXTERNAL_VALIDATION
LEGAL_REVIEW = PENDING_LEGAL_REVIEW
APP_STORE_READINESS = NOT_READY or CONDITIONAL
```

---

# 2. DEVELOPMENT POLICIES TO PRESERVE

Preserve all existing DIR Diving policies.

## 2.1 Highest-priority algorithmic safety gate

The decompression-computer mathematical core has maximum priority.

No software readiness may be marked 100 if there are unresolved P0/P1 findings in:

```text
Bühlmann ZH-L16C constants
16 N2 + 16 He tissue compartments
Haldane / Schreiner
actual elapsed-time / one-second update
ambient pressure / altitude / water density
inspired inert gas pressure
Gradient Factors
NDL
TTS
ceiling
decompression schedule
gas switching
decompression stop-state machine
multilevel recomputation
checkpoint / restore tissue integrity
independent oracle coverage
```

If remediation touches any of these, rerun or prepare rerun of:

```text
01 Watch Full Computer Forensic
03 UI/UX Full Deep
04 Main Code / Sync / Security / Performance
05 Release / QA / Evidence / Compliance
07 Post-Remediation Code Readiness Verification
```

## 2.2 Product architecture

```text
DIR Diving
├── Diving
│   ├── Gauge
│   └── Full Computer
├── Apnea
└── Snorkeling
```

## 2.3 Activity ownership

```text
Diving data/settings/logbook → Diving only
Apnea data/settings/logbook → Apnea only
Snorkeling data/settings/logbook → Snorkeling only
```

No cross-activity leakage.

No cross-activity restore.

No cross-activity deep link.

No mixed normal global logbook.

## 2.4 Gauge versus Full Computer

Gauge:

```text
depth
runtime
average depth
max depth
ascent rate
TTV informational only
no NDL
no TTS
no ceiling
no decompression schedule
```

Full Computer:

```text
Bühlmann ZH-L16C
16 N2 compartments
16 He compartments
Haldane / Schreiner
GF
NDL
TTS
ceiling
decompression schedule
gas switch
stop state
```

Never mix Gauge TTV with Full Computer TTS.

## 2.5 Apnea first-class but isolated

Apnea is first-class product scope, but it must remain isolated.

Preserve:

```text
Apnea recovery
Apnea surface interval
Apnea profile
Apnea alarms
Apnea markers
Apnea logbook
Apnea settings
```

Do not introduce:

```text
decompression wording in Apnea
GF/gas/MOD/PPO2/deco settings in Apnea
medical recovery guarantees
cross-activity Apnea/Diving/Snorkeling leakage
```

## 2.6 Snorkeling first-class but isolated

Snorkeling route/navigation features must remain isolated from Diving and Apnea.

Preserve:

```text
Snorkeling route safety checks
GPS quality
off-route evaluation
return-to-entry
waypoints
dips
markers
Snorkeling logbook
Snorkeling settings
Snorkeling sync payloads
```

Do not claim field/open-water QA is complete unless evidence exists.

## 2.7 Water auto-open / hardware policy

```text
Water auto-open may route to a configured destination.
Water auto-open must not start a dive.
Full Computer water auto-open routes to predive confirmation.
Action Button / App Intent does not bypass legal/safety/router gates.
Digital Crown underwater navigation remains activity-restricted.
Physical Water Lock / Action Button / Crown behavior requires physical evidence.
```

## 2.8 Shallow-depth policy

```text
Apple shallow-depth capability does not equal full-depth decompression validation.
Developer shallow Gauge / Full Computer toggles are internal only.
Production users must not see developer shallow-depth testing as a public feature.
```

## 2.9 Security policy

Do not weaken:

```text
HMAC
nonce / replay protection
signed ACK
peer secret lifecycle
trust reset
malformed payload rejection
privacy opt-in
file path safety
payload route separation
tombstone signing
legacy migration limits
```

---

# 3. BASELINE FINDINGS FROM THE AUDIT REPORT

The audit report states:

```text
Overall verdict: PARTIAL
Software-actionable remediations CONS-001..045 remain closed
Open software gates:
  CONS-046 — command integrity script drift
  IOS-P1-001 / CONS-049 — iOS Algorithm Tests compile failure at HEAD
Physical/external:
  CONS-048 — 12 Snorkeling QA templates / field QA pending
  CONS-010 / CONS-021 / CONS-022 / CONS-042 and aggregate physical matrices — 0% executed
Internal TestFlight: CONDITIONAL
External TestFlight: NOT READY
App Store: NOT READY
```

Primary remediation priorities:

```text
1. Fix IOS-P1-001 / CONS-049 iOS Algorithm Tests compile failure
2. Fix CONS-046 validate_commands_for_cursor_integrity.sh script drift
3. Preserve CONS-001..045 closed status
4. Preserve Snorkeling P1/P2/P3 software readiness
5. Keep CONS-048 and all physical/external/legal gates pending unless evidence exists
6. Rerun/refresh audit outputs as required by the plan
```

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
git rev-list --left-right --count HEAD...origin/main
xcodebuild -version
```

Stop if branch is not `main`.

Record:

```text
branch
HEAD
origin/main relation
dirty files
Xcode version
available simulators
current command versions
presence of Docs/ related files
presence of commands_for_cursor/
```

Run:

```bash
xcodegen generate
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

If any gate fails, document it before remediation.

---

# 5. BATCH A — FIX IOS-P1-001 / CONS-049 iOS ALGORITHM TESTS COMPILE FAILURE

## 5.1 Goal

Fix the iOS Algorithm Tests compile failure reported at HEAD `451f8fb`.

This is the top software blocker because it prevents internal TestFlight software readiness from becoming READY.

## 5.2 Required analysis

Search/read:

```bash
rg -n "IOS-P1-001|CONS-049|iOS Algorithm Tests|BUILD FAILED|compile failure|Snorkeling" Docs Tests iOSApp Shared Services Utils Views project.yml
```

Inspect:

```text
Tests/**
iOSApp/**
Shared/**
Services/**
Utils/**
Views/**
project.yml
Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
Docs/MASTER_IOS_REQUIREMENT_TEST_MATRIX_CURRENT.csv
Docs/MASTER_IOS_EDGE_CASE_MATRIX_CURRENT.csv
Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv
Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md
Docs/MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv
```

Run the failing gate:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

If the named simulator is unavailable, use an equivalent iOS simulator and document the substitution.

## 5.3 Required remediation

Fix only the root cause of the compile failure.

Allowed changes:

```text
test target membership
test imports
test compile errors
missing test fixtures
renamed symbols
Snorkeling test helpers
iOS Algorithm Tests project.yml references
access control needed only for tests
minor test-only adapters
```

Forbidden unless proven necessary:

```text
changing production algorithm behavior to satisfy tests
weakening Snorkeling route safety
weakening Diving Full Computer math
weakening Apnea isolation
removing tests instead of fixing them
commenting out failing coverage
marking tests skipped without root-cause evidence
changing release policy
```

## 5.4 Required test result

After fixing, run:

```bash
xcodegen generate

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Also run if relevant:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

## 5.5 Acceptance

```text
IOS-P1-001 = FIXED_SOFTWARE
CONS-049 = FIXED_SOFTWARE
iOS Algorithm Tests compile and run
No Snorkeling test removed
No algorithmic/decompression regression introduced
No physical QA status changed
```

---

# 6. BATCH B — FIX CONS-046 COMMAND INTEGRITY SCRIPT DRIFT

## 6.1 Goal

Fix the command integrity automation failure.

The report states that:

```text
commands_for_cursor/01–07 bodies are aligned
validate_commands_for_cursor_integrity.sh still references stale versions
script gate FAIL
```

## 6.2 Required analysis

Inspect:

```text
Scripts/validate_commands_for_cursor_integrity.sh
commands_for_cursor/**
Docs/MASTER_AUDIT_COMMAND_INTEGRITY_STATUS_CURRENT.csv
Docs/MASTER_COMMAND_VERSION_ALIGNMENT_MATRIX_CURRENT.csv
Docs/MASTER_COMMAND_SEQUENCE_VERSION_ALIGNMENT_CURRENT.csv
Docs/MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md
Docs/MASTER_CONSOLIDATED_AUDIT_AND_NON_REGRESSIVE_REMEDIATION_PLAN_CURRENT.md
```

Search:

```bash
rg -n "V2\\.1|V2\\.2|V1\\.1|V1\\.2|V1\\.3|V1\\.4|V1\\.5|01-MASTER|02-MASTER|03-MASTER|04-MASTER|05-MASTER|06-MASTER|07-MASTER|validate_commands_for_cursor_integrity" Scripts commands_for_cursor Docs
```

## 6.3 Required remediation

Update the integrity script to match the current active command structure.

Expected active audit command set after the V1.5 update:

```text
commands_for_cursor/00-MASTER_SUPER_ORCHESTRATOR_FULL_AUDIT_SEQUENCE_AND_NON_REGRESSIVE_REMEDIATION_PLAN_COMMAND_V1.5.md
commands_for_cursor/01-MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_COMMAND_V1.5.md
commands_for_cursor/02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/03-MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/04-MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.5.md
commands_for_cursor/06-MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_COMMAND_V1.5.md
commands_for_cursor/07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.5.md
```

Important policy:

```text
00 orchestrates only 01–06
07 exists but is not executed by 00
10 is remediation and must not be treated as an audit-only domain command
```

The script must verify:

```text
file exists
launch-order marker matches filename
canonical numbered filename matches actual filename
title/body matches expected audit domain
00 has strict sequential execution policy
00 does not execute 07
00 does not execute 10
01 is Watch Full Computer Forensic
02 is iOS Full Deep
03 is UI/UX Full Deep
04 is Main Code / Sync / Security / Performance
05 is Release / QA / Evidence / Compliance
06 is Documentation / Repository Alignment
07 is Post-Remediation Code Readiness Verification
```

Add robust body markers rather than version-only brittle checks.

Suggested marker map:

```text
00 → SUPER ORCHESTRATOR
01 → APPLE WATCH FULL COMPUTER / FORENSIC / Bühlmann / Schreiner
02 → iOS FULL DEEP / Planner / Companion
03 → UI/UX FULL DEEP
04 → MAIN CODE / SYNC / SECURITY / PERFORMANCE
05 → RELEASE / QA / EVIDENCE / LEGAL CLAIMS
06 → DOCUMENTATION / REPOSITORY ALIGNMENT
07 → POST-REMEDIATION CODE READINESS VERIFICATION
```

## 6.4 Required validation

Run:

```bash
chmod +x Scripts/validate_commands_for_cursor_integrity.sh
Scripts/validate_commands_for_cursor_integrity.sh
```

If the repo has a consolidated readiness script, also run:

```bash
Scripts/validate_consolidated_software_readiness.sh
```

## 6.5 Acceptance

```text
CONS-046 = FIXED_SOFTWARE
validate_commands_for_cursor_integrity.sh = PASS
command bodies aligned
script no longer references stale versions
00 excludes 07 and 10 from pre-remediation orchestration
```

---

# 7. BATCH C — PRESERVE CONS-001..045 CLOSED STATUS

## 7.1 Goal

The audit states that CONS-001..045 remain closed. Do not regress them.

## 7.2 Required non-regression focus

Verify that no change in Batch A/B reopens:

```text
CONS-001 command permutation
CONS-002 iOS/Watch GF preset parity
CONS-003 inFlightOutboundSessionIDs failed ACK cleanup
CONS-004 symmetric diveImportAck
CONS-005 tombstone signing / legacy migration
CONS-006 shallow Full Computer developer toggle exposure
CONS-007 runtime depth capability authority
CONS-008 independent oracle
CONS-021/022 water auto-open / hardware physical gate separation
CONS-042 shallow-depth wet QA gate separation
CONS-044 legal/release wording
CONS-045 physical/external aggregate status
```

## 7.3 Required tests/scripts

Run all available relevant scripts:

```bash
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
Scripts/validate_commands_for_cursor_integrity.sh
Scripts/validate_no_fake_physical_evidence_claims.sh
Scripts/validate_no_fake_external_validation_claims.sh
Scripts/validate_release_claims_against_evidence.sh
Scripts/validate_developer_shallow_testing_release_gate.sh
Scripts/validate_depth_capability_runtime_authority.sh
Scripts/validate_consolidated_software_readiness.sh
```

If a script does not exist, record `NOT_PRESENT` and do not fabricate execution.

## 7.4 Acceptance

```text
CONS-001..045 remain closed where previously closed
no command integrity regression
no GF parity regression
no sync ACK/tombstone regression
no shallow-depth gate regression
no water auto-open safety regression
no physical/external fake pass
```

---

# 8. BATCH D — SNORKELING SOFTWARE READINESS PRESERVATION

## 8.1 Goal

Preserve Snorkeling P1/P2/P3 software readiness while fixing iOS tests.

## 8.2 Required analysis

Inspect Snorkeling-related code and tests touched by IOS-P1-001:

```text
iOSApp/**
Views/**
Services/**
Utils/**
Shared/**
Tests/**
Docs/*SNORKELING*
Docs/*Snorkeling*
```

Search:

```bash
rg -n "Snorkeling|snorkeling|RouteSafety|off-route|offRoute|return-to-entry|ReturnToEntry|waypoint|GPSQuality|dip|surface route" iOSApp Views Services Utils Shared Tests Docs
```

## 8.3 Required preservation

Preserve:

```text
Snorkeling route safety check
Snorkeling validation
Watch runtime evaluator
GPS quality handling
off-route / return-to-entry logic
route sync iOS→Watch
Snorkeling cross-activity isolation
Snorkeling shared helpers
Snorkeling logbook ownership
Snorkeling settings ownership
```

Do not mark Snorkeling physical QA complete.

## 8.4 Acceptance

```text
Snorkeling software readiness remains SOFTWARE_READY
Snorkeling iOS tests compile
Snorkeling route safety tests still present
CONS-048 remains PENDING_PHYSICAL_WITH_TEMPLATES
12 Snorkeling physical QA templates remain pending unless evidence exists
```

---

# 9. BATCH E — DOCUMENTATION AND STATUS UPDATE AFTER FIXES

## 9.1 Goal

Update only remediation/result documents, not marketing claims.

Create or update:

```text
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_FINDING_STATUS_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_TEST_EVIDENCE_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_NON_REGRESSION_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_PHYSICAL_EXTERNAL_PENDING_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_RERUN_CHECKLIST_CURRENT.md
```

Do not overwrite physical/external pending registers with fake passes.

## 9.2 Finding status CSV

Create:

```text
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_FINDING_STATUS_CURRENT.csv
```

Columns:

```text
Finding_ID
Original_Severity
Original_Status
Title
Batch
Classification
Files_Changed
Tests_Added_Or_Updated
Scripts_Changed
Docs_Changed
New_Status
Software_Readiness_Impact
Physical_QA_Status
External_Validation_Status
Legal_Status
Acceptance_Evidence
Notes
```

Required rows at minimum:

```text
IOS-P1-001
CONS-049
CONS-046
CONS-047
CONS-048
CONS-001..045 preservation summary
CONS-010
CONS-021
CONS-022
CONS-042
CONS-044
CONS-045
```

Expected statuses:

```text
IOS-P1-001 → FIXED_SOFTWARE
CONS-049 → FIXED_SOFTWARE
CONS-046 → FIXED_SOFTWARE
CONS-047 → READY_FOR_AUDIT_RERUN or FIXED_IF_01_TO_06_RERUN_COMPLETED
CONS-048 → PENDING_PHYSICAL_WITH_TEMPLATES
CONS-010/021/022/042/045 → PENDING_PHYSICAL_OR_EXTERNAL
CONS-044 → PENDING_LEGAL_REVIEW_WITH_SAFE_WORDING or unchanged
CONS-001..045 → PRESERVED_CLOSED where applicable
```

---

# 10. VALIDATION GATES

After remediation, run:

```bash
git status --short
git status -sb
xcodegen generate
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

Builds:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Tests:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Scripts:

```bash
Scripts/validate_commands_for_cursor_integrity.sh
Scripts/validate_no_fake_physical_evidence_claims.sh
Scripts/validate_no_fake_external_validation_claims.sh
Scripts/validate_release_claims_against_evidence.sh
Scripts/validate_developer_shallow_testing_release_gate.sh
Scripts/validate_depth_capability_runtime_authority.sh
Scripts/validate_consolidated_software_readiness.sh
```

If a named simulator is unavailable, use an equivalent available simulator and document:

```text
requested destination
actual destination
reason
impact
```

If a command cannot run because of environment, record:

```text
NOT_EXECUTED_ENVIRONMENT
exact command
failure
root cause
rerun requirement
release impact
```

---

# 11. AUDIT RERUN REQUIREMENT

After fixing IOS-P1-001 / CONS-049 and CONS-046, run or prepare rerun of the strict sequential orchestrator:

```text
commands_for_cursor/00-MASTER_SUPER_ORCHESTRATOR_FULL_AUDIT_SEQUENCE_AND_NON_REGRESSIVE_REMEDIATION_PLAN_COMMAND_V1.5.md
```

The orchestrator must execute:

```text
01 → 02 → 03 → 04 → 05 → 06
```

one at a time.

Do not run `07` until after remediation outputs exist.

After remediation and after audit rerun outputs exist, run:

```text
commands_for_cursor/07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.5.md
```

---

# 12. FINAL REPORT STRUCTURE

Create:

```text
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FROM_2026_06_30_AUDIT_REPORT_CURRENT.md
```

Required sections:

A. Executive Summary  
B. Source Audit Inputs Read  
C. Branch / Commit / Baseline  
D. Findings Addressed  
E. Development Policies Preserved  
F. Batch A — IOS-P1-001 / CONS-049 iOS Test Compile Fix  
G. Batch B — CONS-046 Command Integrity Script Fix  
H. Batch C — CONS-001..045 Closed-Status Preservation  
I. Batch D — Snorkeling Software Readiness Preservation  
J. Batch E — Documentation / Status Update  
K. Files Changed  
L. Tests Added / Updated  
M. Scripts Changed  
N. Docs Changed  
O. Build/Test/Script Results  
P. Non-Regression Results  
Q. Remaining Physical / External / Legal Gates  
R. Audit Rerun Checklist  
S. Readiness Before / After  
T. Final Verdict

---

# 13. FINAL VERDICT

Print exactly:

```text
MASTER_2026_06_30_SOFTWARE_REMEDIATION_TO_100: PASS / PARTIAL / FAIL
BASELINE_BRANCH_MAIN: PASS / FAIL
SOURCE_AUDIT_REPORT_READ: PASS / FAIL
RELATED_DOCS_SEARCHED_IN_DOCS: PASS / PARTIAL / FAIL
DEVELOPMENT_POLICIES_PRESERVED: PASS / FAIL
ALGORITHMIC_SAFETY_PRIORITY_PRESERVED: PASS / FAIL
IOS_P1_001_TEST_COMPILE: FIXED / FAIL / NOT_EXECUTED
CONS_049_IOS_TEST_GATE: FIXED / FAIL / NOT_EXECUTED
CONS_046_COMMAND_INTEGRITY_SCRIPT: FIXED / FAIL / NOT_EXECUTED
CONS_047_AUDIT_RERUN_STATUS: READY_FOR_RERUN / FIXED_AFTER_RERUN / FAIL
CONS_048_SNORKELING_PHYSICAL_QA: PENDING_PHYSICAL_WITH_TEMPLATES / PASS / FAIL
CONS_001_TO_045_CLOSED_STATUS_PRESERVED: PASS / PARTIAL / FAIL
SNORKELING_SOFTWARE_READINESS_PRESERVED: PASS / FAIL
NO_FAKE_PHYSICAL_QA_CLAIMS: PASS / FAIL
NO_FAKE_EXTERNAL_VALIDATION_CLAIMS: PASS / FAIL
NO_UNSUPPORTED_CERTIFICATION_CLAIMS: PASS / FAIL
IOS_BUILD: PASS / FAIL / NOT_EXECUTED
WATCH_BUILD: PASS / FAIL / NOT_EXECUTED
IOS_ALGORITHM_TESTS: PASS / FAIL / NOT_EXECUTED
WATCH_ALGORITHM_TESTS: PASS / FAIL / NOT_EXECUTED
COMMAND_INTEGRITY_SCRIPT: PASS / FAIL / NOT_EXECUTED
TARGET_ISOLATION: PASS / FAIL / NOT_EXECUTED
SECRETS_SCAN: PASS / FAIL / NOT_EXECUTED
LOCALIZATION_AUDIT: PASS / FAIL / NOT_EXECUTED
CODE_READINESS: <0-100>
SOFTWARE_READINESS: <0-100>
AUTOMATED_TEST_GATE_READINESS: <0-100>
COMMAND_INTEGRITY_SCRIPT_READINESS: <0-100>
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS: READY / CONDITIONAL / NOT_READY
EXTERNAL_TESTFLIGHT_READINESS_WITH_PHYSICAL_GATES: READY / CONDITIONAL / NOT_READY
APP_STORE_READINESS_WITH_LEGAL_PHYSICAL_EXTERNAL_GATES: READY / CONDITIONAL / NOT_READY
PHYSICAL_QA_READINESS: PENDING_PHYSICAL / <0-100>
EXTERNAL_VALIDATION_READINESS: PENDING_EXTERNAL_VALIDATION / <0-100>
LEGAL_REVIEW_READINESS: PENDING_LEGAL_REVIEW / <0-100>
REMAINING_SOFTWARE_P0: <number>
REMAINING_SOFTWARE_P1: <number>
REMAINING_SOFTWARE_P2: <number>
REMAINING_PHYSICAL_GATES: <number>
REMAINING_EXTERNAL_VALIDATION_GATES: <number>
NEXT_REQUIRED_ACTION: <text>
```

---

# 14. SUCCESS CRITERIA

This command succeeds only if:

```text
IOS-P1-001 / CONS-049 is fixed
iOS Algorithm Tests compile and run
CONS-046 script drift is fixed
validate_commands_for_cursor_integrity.sh passes
CONS-001..045 remain closed where previously closed
Snorkeling P1/P2/P3 software readiness remains preserved
no decompression-computer algorithmic safety regression is introduced
no Apnea/Snorkeling/Diving cross-activity leakage is introduced
no physical/external/legal gate is falsely closed
all related Docs documents are searched/read
final remediation report and finding status CSV are produced
audit rerun checklist is produced
```

Do not commit or push automatically.

Stop after producing remediation outputs and final verdict.
