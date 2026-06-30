# LAUNCH ORDER 07

**Launch order note:** SEVENTH — post-remediation code-readiness verification audit. Run after audit commands `01–06` and after any consolidated software remediation command has been executed.

**Canonical numbered filename:** `07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.0.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING POST-REMEDIATION CODE READINESS VERIFICATION AUDIT — V1.0

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only, read-only, post-remediation verification / code-readiness / non-regression / evidence-truthfulness audit  
**Primary purpose:** verify whether the consolidated software remediation actually took code/software readiness to 100% without falsely closing physical, external, legal, certification or App Store gates.

---

# 0. ABSOLUTE EXECUTION RULE

This is strictly read-only.

Do **not** modify production code, tests, project configuration, assets, mockups, localization resources, runtime documentation, algorithms, sync schemas, persistence schemas, security model or Git history.

You may create or update only the requested verification audit outputs under `Docs/`.

Do not claim physical, external, legal, certification or App Store readiness unless real evidence exists.

If evidence is missing, preserve:

```text
PENDING_PHYSICAL
PENDING_EXTERNAL_VALIDATION
PENDING_LEGAL_REVIEW
PENDING_CERTIFICATION_REVIEW
PENDING_APP_STORE_REVIEW
```

---

# 1. INPUTS TO READ

Read all available audit and remediation sources from `Docs/`.

Mandatory consolidated inputs:

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
```

Mandatory remediation outputs if present:

```text
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TO_100_REPORT_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv
Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_TEST_EVIDENCE_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_NON_REGRESSION_RESULTS_CURRENT.md
Docs/MASTER_CONSOLIDATED_INTERNAL_TESTFLIGHT_SOFTWARE_READINESS_CURRENT.md
Docs/MASTER_CONSOLIDATED_PHYSICAL_EXTERNAL_PENDING_AFTER_SOFTWARE_REMEDIATION_CURRENT.csv
Docs/MASTER_CONSOLIDATED_POST_REMEDIATION_AUDIT_RERUN_CHECKLIST_CURRENT.md
Docs/MASTER_CONSOLIDATED_SOFTWARE_READINESS_TO_100_COMPLETION_SUMMARY_CURRENT.md
```

Mandatory domain audit outputs:

```text
Docs/MASTER_WATCH_FULL_COMPUTER_FORENSIC_AUDIT_CURRENT.md
Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
Docs/MASTER_UI_UX_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md
Docs/MASTER_MAIN_CODE_SYNC_SECURITY_PERFORMANCE_AUDIT_CURRENT.md
Docs/MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_CURRENT.md
Docs/MASTER_DOCUMENTATION_REPOSITORY_ALIGNMENT_AUDIT_CURRENT.md
```

If remediation outputs are missing, set:

```text
POST_REMEDIATION_OUTPUTS_PRESENT: FAIL
CODE_READINESS_VERIFICATION: NOT_EXECUTED
```

and generate a precise missing-output report.

---

# 2. DEVELOPMENT POLICIES TO PRESERVE

Verify that remediation did not violate these policies:

```text
DIR Diving architecture: Diving / Gauge / Full Computer / Apnea / Snorkeling
Diving data/settings/logbook remain Diving-only
Apnea data/settings/logbook remain Apnea-only
Snorkeling data/settings/logbook remain Snorkeling-only
Gauge TTV remains informational and does not become Full Computer TTS
Full Computer remains Bühlmann ZH-L16C with 16 N2 + 16 He compartments
iOS Planner and briefing cards remain reference-only until Watch predive confirmation
CCR/Rebreather remains reference-only unless independently validated and legally positioned
Water auto-open never starts a dive automatically
Full Computer water auto-open routes to predive confirmation
Action Button / App Intent does not bypass legal/safety/router gates
Digital Crown underwater navigation remains activity-restricted
shallow-depth entitlement does not imply full-depth decompression validation
developer shallow testing toggles remain internal only
HMAC / signed ACK / replay / peer secret policies are not weakened
documentation does not claim physical/external/legal/App Store readiness without evidence
```

---

# 3. FINDING CLOSURE VERIFICATION

Verify that every row in `Docs/MASTER_CONSOLIDATED_FINDINGS_REGISTER_CURRENT.csv` has exactly one corresponding row in `Docs/MASTER_CONSOLIDATED_SOFTWARE_REMEDIATION_FINDING_STATUS_CURRENT.csv`.

Create:

```text
Docs/MASTER_POST_REMEDIATION_FINDING_CLOSURE_VERIFICATION_CURRENT.csv
```

Columns:

```text
Consolidated_Finding_ID
Original_Severity
Original_Status
Title
Remediation_Status
Claimed_New_Status
Expected_Status
Files_Changed
Tests_Evidence
Docs_Evidence
Scripts_Evidence
Physical_QA_Status
External_Validation_Status
Legal_Status
Verification_Result
Reason
Regression_Risk
Notes
```

Required focus:

```text
CONS-001 command permutation
CONS-002 GF preset parity
CONS-003 in-flight ACK cleanup
CONS-004 diveImportAck symmetry
CONS-005 tombstone security
CONS-006 shallow toggle release gate
CONS-007 depth capability authority
CONS-008 independent oracle
CONS-009..013 external/physical evidence gates
CONS-021..022 water auto-open / hardware physical gates
CONS-034 command/docs index drift
CONS-044 legal/release wording if present
```

---

# 4. BUILD / TEST / SCRIPT VERIFICATION

Run if environment allows:

```bash
git branch --show-current
git rev-parse --short HEAD
git rev-parse HEAD
git fetch --prune origin
git status --short
git status -sb
xcodegen generate
./Scripts/check_main_target_isolation.sh
./Scripts/check_secrets.sh
./Scripts/audit_localization.sh
```

Build:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch App" \
  -destination 'generic/platform=watchOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```

Tests:

```bash
xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving Watch Algorithm Tests" \
  -destination 'platform=watchOS Simulator,name=Apple Watch Series 11 (46mm)' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test

xcodebuild -project DIRDiving.xcodeproj \
  -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

Run remediation scanners if present:

```bash
Scripts/validate_commands_for_cursor_integrity.sh
Scripts/validate_no_fake_physical_evidence_claims.sh
Scripts/validate_no_fake_external_validation_claims.sh
Scripts/validate_release_claims_against_evidence.sh
Scripts/validate_developer_shallow_testing_release_gate.sh
Scripts/validate_depth_capability_runtime_authority.sh
Scripts/validate_consolidated_software_readiness.sh
```

Record exact pass/fail/not executed status.

---

# 5. COMMAND INTEGRITY VERIFICATION

Create:

```text
Docs/MASTER_POST_REMEDIATION_COMMAND_INTEGRITY_AUDIT_CURRENT.csv
```

Verify:

```text
00 filename/body = Super Orchestrator
01 filename/body = Watch Full Computer Forensic
02 filename/body = iOS Full Deep
03 filename/body = UI/UX Full Deep
04 filename/body = Main Code / Sync / Security / Performance
05 filename/body = Release / QA / Evidence / Compliance
06 filename/body = Documentation / Repository Alignment
07 filename/body = Post-Remediation Code Readiness Verification
10 filename/body = Consolidated Software Remediation Implementation
```

If `10` exists, it must be clearly documented as remediation, not audit-only.

---

# 6. READINESS VERIFICATION

Create:

```text
Docs/MASTER_POST_REMEDIATION_CODE_READINESS_AUDIT_CURRENT.md
Docs/MASTER_POST_REMEDIATION_READINESS_MATRIX_CURRENT.csv
```

Score:

```text
COMMAND_INTEGRITY_READINESS
WATCH_FC_SOFTWARE_READINESS
IOS_SOFTWARE_READINESS
UI_UX_SOFTWARE_READINESS
MAIN_SYNC_SECURITY_PERFORMANCE_SOFTWARE_READINESS
RELEASE_PACKAGE_SOFTWARE_READINESS
DOCUMENTATION_TRUTHFULNESS_READINESS
AUTOMATED_TEST_READINESS
NON_REGRESSION_READINESS
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS
EXTERNAL_TESTFLIGHT_SOFTWARE_PACKAGE_READINESS
PHYSICAL_QA_READINESS
EXTERNAL_VALIDATION_READINESS
LEGAL_REVIEW_READINESS
APP_STORE_OVERALL_READINESS
```

Rules:

```text
Software readiness may reach 100 if code/tests/scripts/docs support it.
Physical QA remains PENDING_PHYSICAL without real evidence.
External validation remains PENDING_EXTERNAL_VALIDATION without real evidence.
Legal review remains PENDING_LEGAL_REVIEW without real evidence.
App Store remains NOT_READY or CONDITIONAL if legal/physical/external gates are missing.
```

---

# 7. REGRESSION VERIFICATION

Create:

```text
Docs/MASTER_POST_REMEDIATION_REGRESSION_AUDIT_CURRENT.csv
```

Verify no regression in:

```text
Watch Full Computer Bühlmann / Schreiner / GF / schedule
iOS Planner math and exports
GF preset parity and unsupported-pair rejection
Watch↔iOS sync ACK/retry/idempotency
tombstone security
depth capability authority
developer shallow testing gates
water auto-open safety
Action Button router-only policy
Digital Crown underwater clamp
activity Settings ownership
activity Logbook ownership
privacy/security claims
release wording
Docs command alignment
```

---

# 8. REQUIRED OUTPUTS

Create or replace:

```text
Docs/MASTER_POST_REMEDIATION_CODE_READINESS_AUDIT_CURRENT.md
Docs/MASTER_POST_REMEDIATION_FINDING_CLOSURE_VERIFICATION_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_READINESS_MATRIX_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_COMMAND_INTEGRITY_AUDIT_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_REGRESSION_AUDIT_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_PHYSICAL_EXTERNAL_PENDING_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md
```

---

# 9. FINAL REPORT STRUCTURE

Create:

```text
Docs/MASTER_POST_REMEDIATION_CODE_READINESS_AUDIT_CURRENT.md
```

Sections:

A. Executive Summary  
B. Inputs Read  
C. Branch / Commit / Baseline  
D. Remediation Outputs Present / Missing  
E. Finding Closure Verification  
F. Command Integrity Verification  
G. Build/Test/Script Verification  
H. Development Policies Preservation  
I. Software Readiness Scores  
J. Internal TestFlight Software Readiness  
K. External TestFlight / App Store Conditional Gates  
L. Remaining Physical Gates  
M. Remaining External Validation Gates  
N. Remaining Legal / Certification / App Store Gates  
O. Regression Audit  
P. Required Reruns  
Q. Final Verdict

---

# 10. FINAL VERDICT

Print exactly:

```text
MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT: PASS / PARTIAL / FAIL
BASELINE_BRANCH_MAIN: PASS / FAIL
POST_REMEDIATION_OUTPUTS_PRESENT: PASS / FAIL
ALL_CONSOLIDATED_FINDINGS_MAPPED: PASS / FAIL
COMMAND_INTEGRITY: PASS / FAIL
CONS_001_COMMAND_PERMUTATION_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_002_GF_PARITY_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_003_INFLIGHT_ACK_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_004_DIVE_IMPORT_ACK_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_005_TOMBSTONE_SECURITY_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_006_SHALLOW_TOGGLE_GATE_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_007_DEPTH_CAPABILITY_AUTHORITY_VERIFIED: PASS / FAIL / NOT_EXECUTED
CONS_008_INDEPENDENT_ORACLE_VERIFIED: PASS / PARTIAL_PENDING_EXTERNAL / FAIL / NOT_EXECUTED
ALL_SOFTWARE_ACTIONABLE_FINDINGS_VERIFIED_FIXED: PASS / PARTIAL / FAIL
NO_POLICY_REGRESSION: PASS / FAIL
NO_FAKE_PHYSICAL_EVIDENCE_CLAIMS: PASS / FAIL
NO_FAKE_EXTERNAL_VALIDATION_CLAIMS: PASS / FAIL
NO_UNSUPPORTED_CERTIFICATION_CLAIMS: PASS / FAIL
IOS_BUILD: PASS / FAIL / NOT_EXECUTED
WATCH_BUILD: PASS / FAIL / NOT_EXECUTED
IOS_TESTS: PASS / FAIL / NOT_EXECUTED
WATCH_TESTS: PASS / FAIL / NOT_EXECUTED
CODE_READINESS: <0-100>
SOFTWARE_READINESS: <0-100>
AUTOMATED_TEST_READINESS: <0-100>
INTERNAL_TESTFLIGHT_SOFTWARE_READINESS: <0-100>
EXTERNAL_TESTFLIGHT_SOFTWARE_PACKAGE_READINESS: <0-100>
PHYSICAL_QA_READINESS: PENDING_PHYSICAL / <0-100>
EXTERNAL_VALIDATION_READINESS: PENDING_EXTERNAL_VALIDATION / <0-100>
LEGAL_REVIEW_READINESS: PENDING_LEGAL_REVIEW / <0-100>
APP_STORE_OVERALL_READINESS: READY / CONDITIONAL / NOT_READY
NEXT_REQUIRED_ACTION: <text>
```

---

# 11. SUCCESS CRITERIA

This audit passes only if:

```text
all consolidated findings are mapped
all claimed software fixes have evidence
command integrity is verified
core policies are preserved
build/test/script evidence is recorded
no fake physical/external/legal readiness is claimed
remaining gates are explicit
final readiness scores are evidence-based
```

Do not commit or push automatically.
