# LAUNCH ORDER 07

**Launch order note:** SEVENTH — post-remediation code-readiness verification audit. Run after audit commands `01–06` and after any consolidated software remediation command has been executed.

**Canonical numbered filename:** `07-MASTER_POST_REMEDIATION_CODE_READINESS_VERIFICATION_AUDIT_COMMAND_V1.7.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING POST-REMEDIATION CODE READINESS VERIFICATION AUDIT — V1.7

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

# V1.7 NON-NEGOTIABLE ALGORITHMIC SAFETY PRIORITY

The decompression-computer mathematical core has maximum priority over every other audit area.

No consolidated readiness, release readiness, TestFlight readiness, App Store readiness, UI readiness, documentation readiness, or post-remediation readiness may be marked as positive if the Watch Full Computer forensic audit reports unresolved P0/P1 defects in:

```text
Bühlmann ZH-L16C constants
16 N2 + 16 He compartment updates
Haldane / Schreiner equation
actual elapsed-time / one-second integration
ambient pressure and altitude model
surface pressure / water density / salinity
inspired inert gas pressure
Gradient Factors and ceiling
NDL / TTS / decompression schedule
gas switch ordering
decompression stop-state machine
multilevel profile recomputation
checkpoint / restore tissue integrity
independent oracle coverage
external validation status
```

Priority rule:

```text
01 Watch Full Computer Forensic = highest-risk blocking audit
02 iOS = must not contradict or weaken 01
03 UI/UX = must present 01 truthfully
04 Main Code = must protect 01 with sync/security/performance gates
05 Release = must block release if 01 has unresolved safety findings
06 Docs = must document 01 status truthfully
07 Post-remediation = must rerun/check 01-critical gates before any 100% software-readiness claim
```

Any remediation touching Full Computer math, timing, gases, GF, decompression, pressure/depth, checkpoint/restore, schedule generation or tissue state must trigger rerun of:

```text
01 Watch Full Computer Forensic
03 UI/UX Full Deep
04 Main Code / Sync / Security / Performance
05 Release / QA / Evidence / Compliance
07 Post-Remediation Verification, if remediation has been executed
```

---


# V1.7 APNEA FIRST-CLASS SCOPE

The audit must treat Apnea as a first-class product area while preserving decompression-computer priority.

Apnea scope to verify where relevant:

```text
Apnea root/dashboard
Apnea live session
Apnea automatic detection
Apnea depth/time profile
Apnea descent/ascent metrics
Apnea surface interval
Apnea recovery countdown/state
Apnea targets
Apnea alarms
Apnea markers
Apnea statistics and records
Apnea logbook ownership
Apnea settings ownership
Apnea iOS Settings mode switch integration
Apnea Watch in-mode Settings access
Apnea water auto-open routing
Apnea Action Button behavior
Apnea active-session Digital Crown policy
Apnea localization/accessibility
Apnea sync/persistence/schema isolation
Apnea privacy positioning
Apnea physical/wet QA pending gates
```

Mandatory Apnea truthfulness:

```text
No decompression wording in Apnea.
No GF/gas/MOD/PPO2/deco settings in Apnea.
No medical guarantee for recovery.
No claim that Apnea auto-detection or wet behavior is physically validated unless evidence exists.
No claim that water auto-open starts an Apnea session.
No cross-activity Apnea/Diving/Snorkeling logbook or settings leakage.
```

---

# V1.7 POST-REMEDIATION VERIFICATION ORDER

The post-remediation audit must verify algorithmic/decompression safety first.

It cannot mark code/software readiness as 100 unless the post-remediation evidence shows:

```text
01-critical mathematical gates rerun or explicitly verified
no P0/P1 Watch Full Computer math findings remain open
no regression in Bühlmann/Schreiner/GF/NDL/TTS/schedule/gas switch/stop-state/checkpoint/restore
Apnea remediation did not contaminate Diving Full Computer
physical/external/legal gates remain pending unless evidenced
```

---
# V1.7 ADDITIONAL REQUIRED OUTPUTS

Create or replace:

```text
Docs/MASTER_POST_REMEDIATION_ALGORITHMIC_SAFETY_VERIFICATION_CURRENT.md
Docs/MASTER_POST_REMEDIATION_APNEA_VERIFICATION_CURRENT.md
Docs/MASTER_POST_REMEDIATION_APNEA_BOUNDARY_MATRIX_CURRENT.csv
```

# V1.7 LATEST IMPLEMENTATION WAVE — 2026-07-02

This command is updated for the 2026-07-02 implementation and verification wave.

The audit must explicitly account for:

```text
Apnea P1/P2/P3 test verification evidence at HEAD
21 iOS Apnea algorithm tests PASS
25 Watch Apnea algorithm tests PASS
orchestrator V1.5 full audit sequence 01–06 completed at 2c30412
internal TestFlight software readiness READY while physical/external gates remain pending
CONS-050 water-auto-open routing tests closed
R09 water-auto-open routing remediation documentation refresh
audit 07 post-remediation verification at 48f8af2
1655/1655 iOS tests PASS
1152/1152 Watch tests PASS
CONS-050 / CONS-053 / CONS-054 closed in consolidated docs
Watch GPS capture through activity-specific logbooks end-to-end
Diving surface-only entry/exit GPS metadata
Apnea surface-only start/end GPS metadata
Snorkeling GPS track/logbook pipeline
When In Use-only location policy
No continuous underwater GPS claim
No fake coordinate policy
activity-specific GPS logbook stores and sync
iOS unified per-activity logbook view toggle
presentation-only unified activity timeline
read-only aggregation across Diving / Snorkeling / Apnea
no merged persistent storage
no cross-activity store contamination
no Watch sync mutation from unified logbook presentation
demo/fake log exclusion in real unified view
manual UI QA pending for unified logbook
Snorkeling and Apnea planner section order before Watch send
route safety / incomplete-state messaging placed before transfer actions
Docs/INDEX baseline refresh for unified logbook and latest audits
```

Mandatory interpretation:

```text
The unified iOS logbook is presentation-only. It must not weaken strict activity-owned stores.
GPS metadata is activity-specific. It must not become a cross-activity route, underwater navigation authority, decompression input, or medical/safety guarantee.
When In Use location only remains the privacy policy unless deliberately changed and audited.
Physical Watch/iPhone GPS QA, open-water Snorkeling QA, underwater QA and paired-device QA remain PENDING_PHYSICAL unless real evidence exists.
Manual UI QA for the unified logbook remains PENDING_MANUAL_QA unless executed.
The 1655/1655 iOS and 1152/1152 Watch PASS evidence may support software/test readiness only; it does not close physical/external/legal gates.
```

---


# V1.7 GPS AND UNIFIED LOGBOOK NON-REGRESSION POLICY

GPS and logbook changes must preserve activity isolation.

```text
Diving: surface-only entry/exit GPS metadata; no continuous underwater GPS; no decompression authority.
Apnea: surface-only start/end GPS metadata; no runtime navigation, maps, waypoints, route progress or recovery guarantee.
Snorkeling: GPS track, GPS quality, route safety, off-route and return-to-entry metadata remain Snorkeling-owned.
Unified iOS logbook: optional read-only presentation-only aggregate; default OFF; no merged storage; no cross-write; no sync mutation; no unified canonical export.
```

Do not mark GPS, unified-logbook manual UI, open-water Snorkeling, paired-device or physical Watch/iPhone QA as passed without real evidence.

---


# V1.7 ALGORITHMIC SAFETY REMAINS NON-NEGOTIABLE

The Watch Full Computer mathematical/decompression audit remains the highest-priority gate.

No V1.7 GPS, logbook, Apnea, Snorkeling, UI, sync, release or documentation improvement may cause regression in:

```text
Bühlmann ZH-L16C
Schreiner / Haldane
16 N2 + 16 He compartments
actual elapsed-time integration
ambient pressure / altitude / water density model
inspired gas pressure
Gradient Factors
NDL / TTS / ceiling
decompression schedule
gas switching
stop-state machine
checkpoint / restore
independent oracle evidence
```

Any unresolved P0/P1 in this area blocks positive consolidated readiness.

---

# V1.7 POST-REMEDIATION VERIFICATION — JULY 1 TEST EVIDENCE AND NEW FEATURES

Verify if present:

```text
1655/1655 iOS PASS
1152/1152 Watch PASS
CONS-050 / CONS-053 / CONS-054 closure
Apnea P1/P2/P3 21 iOS + 25 Watch tests PASS
iOS unified logbook subset 22 tests PASS
manual UI QA pending
physical GPS QA pending
open-water Snorkeling QA pending
```

Additional outputs:

```text
Docs/MASTER_POST_REMEDIATION_V1_6_LATEST_WAVE_VERIFICATION_CURRENT.md
Docs/MASTER_POST_REMEDIATION_UNIFIED_LOGBOOK_VERIFICATION_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_GPS_LOGBOOK_VERIFICATION_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_TEST_EVIDENCE_1655_1152_MATRIX_CURRENT.csv
Docs/MASTER_POST_REMEDIATION_MANUAL_PHYSICAL_PENDING_V1_6_CURRENT.csv
```

---

# V1.7 LATEST IMPLEMENTATION WAVE — 2026-07-02

This command is updated for the 2026-07-02 implementation and remediation wave.

The audit must explicitly account for these latest repository developments:

```text
741aa37 — CCR planner safety acknowledgement independent toggle and mode-aware UI policy
fc781aa — removal of generic GAS toggle from equipment checklist items; gas/cylinder section separated
d362795 — Snorkeling Watch P1 visibility and unified logbook navigation fix
38bc09e — Snorkeling Watch P2 premium runtime and iOS operational configuration
e052903 — Snorkeling Watch P3 advanced navigation preview and iOS analytics
c982fe3 — Snorkeling Watch P1/P2/P3 deep audit and unified remediation plan
7c459cb — Snorkeling Watch P1/P2/P3 unified remediation implementation
a9fc8a6 — Docs/INDEX baseline for unified remediation
f90b671 — demo logbook fix
7ae527b — Docs/INDEX baseline for demo logbook fix
```

The audit must search and read these latest Docs outputs where present:

```text
Docs/SNORKELING_WATCH_P1_P2_P3_DEEP_AUDIT_CURRENT.md
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_PLAN_CURRENT.md
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_IMPLEMENTATION_REPORT_CURRENT.md
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_STATUS_CURRENT.csv
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_TEST_EVIDENCE_CURRENT.md
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_NON_REGRESSION_CURRENT.md
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_QA_PENDING_CURRENT.csv
Docs/SNORKELING_WATCH_P1_P2_P3_UNIFIED_REMEDIATION_RERUN_CHECKLIST_CURRENT.md
Docs/QA_EVIDENCE/SNORKELING_ROUTE_PUSH/PROCEDURE.md
```

Mandatory interpretation:

```text
Snorkeling software remediation may be considered applied only where code/tests/docs support it.
The Snorkeling unified remediation report verdict may remain PARTIAL because manual UI QA, paired-device QA and physical/open-water QA remain pending.
Do not downgrade implemented software fixes merely because physical QA is pending.
Do not upgrade pending manual/physical QA to PASS from automated tests, docs, simulator runs or templates.
The new Snorkeling P1/P2/P3 work must not contaminate Diving, Full Computer, Gauge or Apnea.
The new Snorkeling GPS/navigation and analytics features must not become decompression authority, medical advice, or underwater GPS guarantee.
The CCR safety acknowledgement fix must preserve CCR as reference-only and must not become live CCR controller authority.
The equipment gas UI fix must preserve usesGas persistence and planner compatibility while removing misleading generic GAS toggle behavior.
The demo logbook fix must preserve no fake/demo contamination in real logbooks and unified logbook views.
```

---


# V1.7 SNORKELING WATCH P1/P2/P3 NON-REGRESSION POLICY

The latest Snorkeling P1/P2/P3 remediation must be audited as first-class scope.

Required software-remediation facts to verify:

```text
R1-001 — iOS route/session sync visibility on session detail/planner
R1-003 — Watch battery fraction policy and runtime wiring tests
R1-004 — pending route activation UX and accessibility hint
R1-005 — session sync failure/pending on list/detail
R1-006 — per-session source row: Watch / Manual / Imported
R1-007 — persisted iOS route pending send queue
R1-009 — WatchConnectivity E2E procedure documented; paired-device QA pending
R2-001 — returnIsPrimaryAction drives Watch UI contract
R2-002 — iOS settings re-send required banner, unless a tested settings-only sync exists
R2-005 — ready panel route summary UI contract
R3-001 — heatmap remains blocked from production
R3-002 — planned-vs-actual adherence clarity with non-safety wording
R3-003 — QA evidence templates remain pending unless real evidence exists
```

Negative checks:

```text
No production heatmap.
No Always Location.
No underwater GPS claims.
No fake/demo contamination in real logbooks.
No cross-activity logbook/store contamination.
No Diving/Full Computer/Gauge/Apnea runtime regression.
No Snorkeling route safety claim beyond available evidence.
No manual UI QA, open-water QA, paired-device QA or physical QA marked PASS unless real evidence exists.
```

Additional V1.7 outputs, where applicable:

```text
Docs/MASTER_V1_7_SNORKELING_REMEDIATION_VERIFICATION_CURRENT.md
Docs/MASTER_V1_7_SNORKELING_REMEDIATION_STATUS_CONSUMPTION_MATRIX_CURRENT.csv
Docs/MASTER_V1_7_SNORKELING_QA_PENDING_GATE_MATRIX_CURRENT.csv
Docs/MASTER_V1_7_SNORKELING_NO_REGRESSION_MATRIX_CURRENT.csv
```

---


# V1.7 CCR ACKNOWLEDGEMENT AND EQUIPMENT GAS UI NON-REGRESSION POLICY

The audit must include the latest iOS planner/equipment fixes.

CCR planner acknowledgement:

```text
CCR acknowledgement persistence must be independent from generic planner gates.
CCR acknowledgement UI must be mode-aware.
CCR acknowledgement must not be treated as legal/certification approval.
CCR / Rebreather remains reference-only unless separately validated and legally positioned.
No live loop PPO2 monitoring claim.
No certified CCR controller claim.
Italian and English copy must be correct and localized.
```

Equipment gas/cylinder UI:

```text
Generic GAS toggle must not appear as misleading checklist-item behavior.
Gas/cylinder items must have a dedicated section and creation path.
usesGas persistence and planner compatibility must be preserved.
Existing equipment/checklist exports must not regress.
No cross-activity equipment leakage into Apnea/Snorkeling unless explicitly intended and safe.
```

Demo logbook fix:

```text
Demo/fake logs must not appear in real activity logbooks.
Demo/fake logs must not appear in unified logbook real view.
Demo mode, previews or fixtures must be clearly isolated from production data paths.
```

Additional V1.7 outputs, where applicable:

```text
Docs/MASTER_V1_7_CCR_ACKNOWLEDGEMENT_AUDIT_CURRENT.md
Docs/MASTER_V1_7_EQUIPMENT_GAS_UI_AUDIT_CURRENT.md
Docs/MASTER_V1_7_DEMO_LOGBOOK_CONTAMINATION_AUDIT_CURRENT.md
```

---


# V1.7 ALGORITHMIC SAFETY REMAINS HIGHEST PRIORITY

The Watch Full Computer mathematical/decompression gate remains non-negotiable.

No Snorkeling, Apnea, CCR planner, equipment, logbook, GPS, UI, sync, release or documentation improvement may create regression in:

```text
Bühlmann ZH-L16C
Schreiner / Haldane
16 N2 + 16 He compartments
elapsed-time integration
ambient pressure / altitude / water density
inspired gas pressure
Gradient Factors
NDL / TTS / ceiling
decompression schedule
gas switching
stop-state machine
checkpoint / restore
independent oracle evidence
```

If any P0/P1 Full Computer math finding is open, positive consolidated readiness remains blocked regardless of other feature readiness.

---

# V1.7 POST-REMEDIATION VERIFICATION — SNORKELING AND LATEST IOS FIXES

Verify:

```text
R1/R2/R3 Snorkeling remediation status CSV rows
Snorkeling test evidence document
Snorkeling non-regression document
Snorkeling QA pending CSV
CCR acknowledgement gate tests
equipment gas UI tests/docs
demo logbook contamination fix evidence
Docs/INDEX latest baseline
```

Additional outputs:

```text
Docs/MASTER_POST_REMEDIATION_V1_7_SNORKELING_VERIFICATION_CURRENT.md
Docs/MASTER_POST_REMEDIATION_V1_7_CCR_EQUIPMENT_VERIFICATION_CURRENT.md
Docs/MASTER_POST_REMEDIATION_V1_7_DEMO_LOGBOOK_VERIFICATION_CURRENT.md
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
