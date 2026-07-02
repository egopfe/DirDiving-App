# LAUNCH ORDER 08

**Launch order note:** EIGHTH — dedicated post-remediation Snorkeling Watch P1/P2/P3 vertical audit. Run after `07` when Snorkeling remediation outputs exist.

**Canonical numbered filename:** `08-MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_DEEP_AUDIT_COMMAND_V1.7.md`

---

# MASTER CURSOR / CODEX COMMAND — DIR DIVING SNORKELING WATCH P1/P2/P3 POST-REMEDIATION DEEP AUDIT — V1.7

**Repository:** `egopfe/DirDiving-App`  
**Required branch:** `main`  
**Task type:** audit-only, read-only, vertical Snorkeling post-remediation verification / non-regression / QA truthfulness audit  
**Primary purpose:** verify that the Snorkeling Watch P1/P2/P3 remediation is implemented, tested and documented without regressing Diving, Full Computer, Gauge, Apnea, GPS/logbook policies, privacy, release claims or QA truthfulness.

---

# 0. ABSOLUTE EXECUTION RULE

This command is strictly read-only.

Do **not** modify production code, tests, project configuration, assets, localization, documentation outside requested audit outputs, algorithms, sync schemas, persistence schemas, security model or Git history.

You may create or update only the requested verification outputs under `Docs/`.

Do not mark manual UI QA, physical Watch/iPhone QA, paired-device WatchConnectivity QA, open-water QA, App Store readiness, certification or legal review as PASS unless actual evidence exists.

If evidence is missing, preserve:

```text
MANUAL_UI_QA_PENDING
PENDING_PHYSICAL
PENDING_PAIRED_DEVICE_QA
PENDING_OPEN_WATER_QA
PENDING_APP_STORE_REVIEW
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


# 1. INPUTS TO READ

Read all available Snorkeling audit/remediation sources in `Docs/`:

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
Docs/QA_EVIDENCE/SNORKELING_*
```

# 2. CODE AREAS TO INSPECT

Search and inspect:

```text
Views/SnorkelingView.swift
Services/SnorkelingWatchRuntimeStore.swift
Utils/SnorkelingWatchBatteryFractionPolicy.swift
Utils/SnorkelingWatchReturnPrimaryActionPolicy.swift
Utils/SnorkelingWatchReadyPresentationPolicy.swift
iOSApp/Views/Snorkeling/IOSSnorkelingSessionDetailView.swift
iOSApp/Views/Snorkeling/IOSSnorkelingSessionsListView.swift
iOSApp/Views/Snorkeling/IOSSnorkelingRoutePlannerView.swift
iOSApp/Views/Snorkeling/IOSSnorkelingSettingsContent.swift
iOSApp/Utils/SnorkelingRoutePendingSendQueuePersistence.swift
iOSApp/Utils/SnorkelingSessionLogbookSyncPresentation.swift
iOSApp/Services/IOSSnorkelingWatchTransferService.swift
iOSApp/Utils/SnorkelingPlannedVsActualAnalytics.swift
Tests/WatchAlgorithmTests/SnorkelingWatchRuntimeBatteryTests.swift
Tests/WatchAlgorithmTests/SnorkelingWatchBatteryPresentationTests.swift
Tests/WatchAlgorithmTests/SnorkelingWatchReturnPrimaryActionTests.swift
Tests/WatchAlgorithmTests/SnorkelingWatchUIViewContractTests.swift
Tests/WatchAlgorithmTests/SnorkelingWatchReadyRoutePresentationTests.swift
Tests/iOSAlgorithmTests/SnorkelingPendingRouteQueuePersistenceTests.swift
Tests/iOSAlgorithmTests/SnorkelingSessionLogbookSyncPresentationTests.swift
Tests/iOSAlgorithmTests/IOSSnorkelingUIViewContractTests.swift
Tests/iOSAlgorithmTests/SnorkelingRouteAckRoundTripTests.swift
Scripts/validate_snorkeling_release_readiness.sh
```

# 3. REQUIRED OUTPUTS

Create:

```text
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_DEEP_AUDIT_CURRENT.md
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_STATUS_MATRIX_CURRENT.csv
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_TEST_MATRIX_CURRENT.csv
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_QA_PENDING_MATRIX_CURRENT.csv
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_NON_REGRESSION_MATRIX_CURRENT.csv
Docs/MASTER_SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_FINAL_VERDICT_CURRENT.md
```

# 4. FINAL VERDICT

Print exactly:

```text
SNORKELING_WATCH_P1_P2_P3_POST_REMEDIATION_DEEP_AUDIT: PASS / PARTIAL / FAIL
SOURCE_DOCS_READ: PASS / PARTIAL / FAIL
R1_REQUIRED_VERIFIED: PASS / PARTIAL / FAIL
R1_OPTIONAL_SAFE_VERIFIED: PASS / PARTIAL / FAIL
R2_REQUIRED_VERIFIED: PASS / PARTIAL / FAIL
R2_OPTIONAL_VERIFIED: PASS / PARTIAL / FAIL
R3_SOFTWARE_ONLY_VERIFIED: PASS / PARTIAL / FAIL
HEATMAP_BLOCKED: PASS / FAIL
NO_ALWAYS_LOCATION: PASS / FAIL
NO_UNDERWATER_GPS_CLAIMS: PASS / FAIL
NO_FAKE_DEMO_CONTAMINATION: PASS / FAIL
ACTIVITY_ISOLATION_PRESERVED: PASS / FAIL
FULL_COMPUTER_UNTOUCHED: PASS / FAIL
APNEA_UNTOUCHED: PASS / FAIL
GAUGE_UNTOUCHED: PASS / FAIL
WATCH_BUILD: PASS / FAIL / NOT_EXECUTED
IOS_BUILD: PASS / FAIL / NOT_EXECUTED
WATCH_TESTS: PASS / FAIL / NOT_EXECUTED
IOS_TESTS: PASS / FAIL / NOT_EXECUTED
SNORKELING_RELEASE_READINESS_SCRIPT: PASS / FAIL / NOT_EXECUTED
MANUAL_UI_QA_STATUS: PENDING_MANUAL_QA / PASS / FAIL
PAIRED_DEVICE_QA_STATUS: PENDING_PAIRED_DEVICE_QA / PASS / FAIL
OPEN_WATER_QA_STATUS: PENDING_OPEN_WATER_QA / PASS / FAIL
PHYSICAL_QA_STATUS: PENDING_PHYSICAL / PASS / FAIL
SNORKELING_SOFTWARE_READINESS: READY / PARTIAL / FAIL
SNORKELING_RELEASE_READINESS: NOT_READY / CONDITIONAL / READY
NEXT_REQUIRED_ACTION: <text>
```

Do not commit or push automatically.
