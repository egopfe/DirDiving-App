# DIR Diving iOS — Master Full Deep Comprehensive Audit — CURRENT

**Command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.2` (LAUNCH ORDER 02)  
**Audit date:** 2026-06-30  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Branch:** `main`  
**Commit:** `451f8fb` (`451f8fb644a85d8d205d53ef769e29ff9ed4f958`)  
**Scope:** DIRDiving iOS Companion — merged math + Bühlmann + algorithm + multi-activity + Snorkeling P1/P2/P3 + map UX + fake logbook toggles + post-remediation CONS verification  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Xcode:** 26.6 (Build 17F113)

**Post-remediation focus:** CONS-002 GF preset parity; CONS-003 inFlight ACK cleanup; CONS-004 diveImportAck symmetry; CONS-005 tombstone HMAC; Snorkeling route planner P1/P2/P3; activity fake logbook toggles; map UX.

**Merged source commands:**

```text
0-DIR_DIVING_IOS_COMPLETE_MATH_FUNCTIONS_AUDIT_CCR_UPDATED_V3.0.md
1-DIR_DIVING_IOS_BUHLMANN_COMPREHENSIVE_READINESS_AUDIT_CCR_UPDATED_V3.0.md
3-DIR_DIVING_IOS_COMPLETE_ALGORITHM_AUDIT_CCR_UPDATED_V3.0.md
```

**Permitted writes:** Audit outputs under `Docs/` only. No production code, tests, or `project.yml` modified.

---

## A. Executive Summary

### Overall verdict

**Status: Software-ready architecture with test-gate regression at HEAD — non-certified reference planner + first-class multi-activity iOS Companion**

`main` @ `451f8fb` delivers a **first-class multi-activity iOS Companion** with strict vertical ownership for Diving (planner reference, logbook, equipment, checklist), Apnea (sessions, profiles, statistics), and Snorkeling (GPS routes, P1/P2/P3 route planner, map UX, analytics). Gauge and Full Computer live Bühlmann runtime execute on **Apple Watch**; iOS provides planner reference, sealed dive-plan packages, briefing cards (**reference-only**), and logbook import.

**Post-remediation CONS verification @ `451f8fb`:** CONS-002/003/004/005 **PASS** in code (see `Docs/MASTER_IOS_POST_REMEDIATION_GF_SYNC_VERIFICATION_CURRENT.md`).

**Regression @ `451f8fb`:** iOS Algorithm Tests **BUILD FAILED** — Snorkeling test compile errors (**IOS-P1-001**). Prior baseline `5d757cc` reported 1527 tests, 0 failures.

### macOS validation (@ `451f8fb`)

| Check | Result |
|---|---|
| Branch / commit | `main` @ `451f8fb` ✓ |
| Working tree | Clean at audit start |
| `xcodegen generate` | **SUCCEEDED** |
| iOS MAIN build (`generic/platform=iOS Simulator`, `CODE_SIGNING_ALLOWED=NO`) | **BUILD SUCCEEDED** |
| iOS Algorithm Tests (`iPhone 17 Pro` simulator) | **TEST FAILED** — compile errors in Snorkeling tests (IOS-P1-001) |
| Production `try!` / `as!` in `iOSApp/` | **0** matches |
| Test inventory | **1290+** `func test` definitions in `Tests/iOSAlgorithmTests` |

### Severity summary (software findings)

| Priority | Count | Notes |
|---:|---:|---|
| **P0** | **0** | No safety-critical algorithm or cross-activity routing defect |
| **P1** | **1** | IOS-P1-001 Snorkeling test compile failure blocks CI gate |
| **P2** | **6** | External validation + physical QA pending (IOS-P2-001..006) |
| **P3** | **6** | Navigation restore, Apnea cloud, dual-binding, tissue replay, manual editor, map GPS quirk |
| **P4** | **4** | Keychain skips, PDF MOD asymmetry, eager stores, checklist inference |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **Conditional** — app build green; test suite compile blocked |
| Internal TestFlight (algorithm) | **Conditional** — fix IOS-P1-001; reference-only posture |
| External TestFlight / RC | **Not yet** — external math + paired Watch + Snorkeling field QA **PENDING** |
| App Store | **Not yet** — legal/marketing + all external gates |
| Certified decompression planner | **Never** — reference-only by design |

---

## B. Source Commands Merged

This report merges three iOS audit command scopes plus V1.2 requirements: Settings mode switcher, activity-owned Settings/Logbooks, Apnea/Snorkeling as first-class verticals, Snorkeling P1/P2/P3 route planner, map UX, fake logbook toggles, GF/sync post-remediation verification, cross-cutting water-entry/GF/entitlements scope (read-only).

---

## C. Latest Development Update

Since prior iOS master audit (`5d757cc`), `main` @ `451f8fb` includes:

- **Snorkeling P1/P2/P3 route planner** — return-to-entry, safety check, profiles, gated Watch transfer, off-route Watch runtime (P3).
- **Snorkeling map UX** — center-on-location, map type picker, reset map confirmation, tap-to-place waypoints.
- **Activity fake logbook toggles** — `IOSActivityDemoLogbookSettingsStore` in Apnea/Snorkeling Settings (NOT `DeveloperSettings`); Diving uses `DiveLogStore.includeDemoLogbook`.
- **Second `SnorkelingDistanceCalculator.distanceMeters` overload** — introduced `[SnorkelingRoutePlannerPoint]` overload; test compile ambiguity at HEAD (IOS-P1-001).
- **CONS remediations retained** — GF parity, sync ACK cleanup, symmetric diveImportAck, tombstone HMAC (verified static @ `451f8fb`).

---

## D. Branch, Commit and Scope

| Item | Value |
|---|---|
| Required branch | `main` ✓ |
| Audited commit | `451f8fb` |
| Primary target | `DIRDiving iOS` |
| Primary test target | `DIRDiving iOS Algorithm Tests` |
| Secondary scope | Shared/BuhlmannCore, Watch GF/briefing/sync codecs (read-only parity) |

---

## E. Preflight and Build/Test Baseline

### Preflight commands executed

```bash
git branch --show-current          # main
git rev-parse --short HEAD         # 451f8fb
git fetch --prune origin
git status -sb                     # clean
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
```

### Results

| Step | Outcome |
|---|---|
| Branch / commit | `main` @ `451f8fb` ✓ |
| iOS build | **BUILD SUCCEEDED** |
| iOS Algorithm Tests | **TEST FAILED** — compile: ambiguous `distanceMeters(points:)`; `SnorkelingRoutePlannerDraft` type mismatch test vs app module |
| Prior baseline | `5d757cc`: 1527 executed, 0 failures |

---

## F. Target Membership and Architecture

```text
DIR Diving (iOS Companion @ 451f8fb)
├── Shared/BuhlmannCore              → canonical ZH-L16C
├── Shared/Models/                   → FullComputerGradientFactorPreset; DivePlanPackage
├── iOSApp/
│   ├── Services/                    → Planner, sync, logbooks, Snorkeling route planner
│   ├── Views/                       → Activity roots, Settings mode switcher, route planner map
│   └── Utils/PlannerModePolicy.swift
├── Snorkeling P1/P2/P3              → IOSSnorkelingRoutePlannerView + Shared validators
└── Tests/iOSAlgorithmTests/         → 1290+ test functions (compile blocked @ HEAD)
```

---

## G. Multi-Activity Root Flow

```text
Launch → IOSLegalOnboardingView (if required)
      → IOSCompanionActivitySelectionView (if required)
      → .apnea    → IOSApneaRootView
      → .snorkeling → IOSSnorkelingRootView
      → else (Diving) → ContentView
```

| Check | Verdict |
|---|---|
| Selection persistence | **PASS** |
| Legacy Diving migration | **PASS** |
| No placeholder production route | **PASS** |
| Settings scope ≠ runtime activity | **PASS** |
| Cross-activity deep links | **PASS** — rejected |
| Navigation state restoration | **PARTIAL** — IOS-P3-001 |

**Q1–2:** iOS is **truly multi-activity**; Diving, Apnea, and Snorkeling are **first-class product areas**.

---

## H. iOS Settings Mode Switch and Activity Settings

| Check | Verdict |
|---|---|
| Switch includes Diving/Apnea/Snorkeling | **PASS** |
| Content visible below switcher | **PASS** |
| Gear routing initial mode | **PASS** |
| No cross-activity leakage | **PASS** — CNS/GPS/recovery isolated |
| Apnea/Snorkeling editable controls | **PASS** |
| Fake logbook toggles | **PASS** — activity Settings; default OFF |

See `Docs/MASTER_IOS_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv`.

---

## I. Strict Logbook Ownership

| Activity | Store | Isolation |
|---|---|---|
| Diving | `DiveLogStore` | Diving route only |
| Apnea | `IOSApneaLogbookStore` | Separate JSON; no `DiveLogStore` env |
| Snorkeling | `IOSSnorkelingLogbookStore` | Separate JSON; fake logbook isolated |

Cross-activity routes: **6/6 blocked** (tests). See `Docs/MASTER_IOS_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv`.

---

## J. Feature Inventory

`Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv` — 58 feature rows including Snorkeling P1/P2/P3, map UX, fake logbook toggles.

---

## K. Bühlmann Core

ZH-L16C shared core: 16 N2+He compartments, GF interpolation, multigas, preflight validation, deterministic output. No P0 math defect identified. External validation **PENDING** (IOS-P2-001).

---

## L. Planner Mode Projection

| Mode | Isolation | Readiness |
|---|---|---|
| Base | Single gas; GF forced 30/70; no deco leakage | 92% |
| Deco | Simplified schedule; GF preset cards | 91% |
| Technical | Full schedule + gas ledger + rock bottom | 92% |
| CCR | Separate engine; reference-only | 90% |

---

## M. MOD / PPO2 / Dalton / Switch Depth

Canonical MOD formula; switch depth ≤ MOD enforced. Mandatory O2 100% @ PPO2 1.6 → ~6 m tested. CCR setpoint not treated as FO2.

---

## N–U. Gas, Rock Bottom, Runtime, CCR, Equipment

Schedule-aware consumption, rock bottom independent from planned consumption, deco-stop presentation matches canonical schedule, CCR reference-only with explicit OC/CCR separation, equipment/checklist role mapping tested. Rock bottom uses simplified average-ascent depth model (conservative direction).

---

## Snorkeling Route Planner P1/P2/P3 (V1.2 scope)

| Tier | iOS software | Verdict |
|---|---|---|
| **P1** | Return-to-entry preview, safety check, checklist, gated Watch transfer | **PASS** software |
| **P2** | Profile kinds, validation warnings, return alert policy | **PASS** software |
| **P3** | Off-route detection (Watch runtime 50 m) | **PASS** software (Watch primary) |

Physical open-water QA: **PENDING** (IOS-P2-006, CONS-048).

---

## Snorkeling Map UX (V1.2 scope)

Center-on-location button, map type (standard/satellite/hybrid), reset map confirmation, tap-to-place coordinates, route polyline/markers. **IOS-P3-006:** slow GPS may require second center tap.

---

## Fake Logbook Toggles (V1.2 scope)

| Activity | Toggle location | Default | Isolation |
|---|---|---|---|
| Diving | `DiveLogStore.includeDemoLogbook` | OFF | Demo section separate |
| Apnea | `dirdiving.ios.apnea.fakeLogbook.enabled` | OFF | Independent toggle |
| Snorkeling | `dirdiving.ios.snorkeling.fakeLogbook.enabled` | OFF | DEMO banner; no stat pollution |

**Not** in `DeveloperSettings.swift` (shallow testing toggles remain Watch-side developer gates).

---

## Post-Remediation CONS Verification

| CONS ID | iOS impact | Verdict |
|---|---|---|
| CONS-002 | GF preset parity | **PASS** |
| CONS-003 | inFlight ACK cleanup | **PASS** |
| CONS-004 | diveImportAck symmetry | **PASS** |
| CONS-005 | Tombstone HMAC | **PASS** (legacy diving UUID mirror documented) |
| CONS-028 | Navigation restoration | **PARTIAL** |
| CONS-040 | Dual diving settings binding | **OPEN P3** |

Detail: `Docs/MASTER_IOS_POST_REMEDIATION_GF_SYNC_VERIFICATION_CURRENT.md`

---

## AB. Test Coverage

**1290+** test function definitions. @ `451f8fb`: **compile failure** in Snorkeling suites prevents execution. Prior `5d757cc`: 1527 executed, 0 failures.

**IOS-P1-001 root cause:** `SnorkelingDistanceCalculator.distanceMeters(points: [])` ambiguous between `[SnorkelingCoordinate]` and `[SnorkelingRoutePlannerPoint]` overloads; test-local `SnorkelingRoutePlannerDraft` types mismatch app module types in export payload tests.

---

## AC. Static Scans

| Scan | Result |
|---|---|
| `try!` / `as!` in `iOSApp/` | **0** |
| Settings cross-activity keys in UI | **None** — routing tests PASS |
| Hardcoded secrets | **None found** |

---

## AF. Findings P0–P4

| ID | Priority | Summary | Status |
|---|---|---|---|
| IOS-P1-001 | **P1** | Snorkeling test compile failure blocks algorithm test suite | **OPEN** |
| IOS-P2-001..006 | P2 | External/physical QA pending (Bühlmann, iCloud, Subsurface, briefing, Snorkeling GPS, Snorkeling field) | PENDING |
| IOS-P3-001..006 | P3 | Nav restore, Apnea cloud, dual-binding, tissue replay, manual editor, map GPS quirk | OPEN |
| IOS-P4-001..004 | P4 | Keychain skip, PDF MOD, eager stores, checklist inference | VERIFIED |
| CONS-002/027 | — | GF parity + PlannerStore deinit | **VERIFIED** |

Full traceability: `Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv`

---

## AH. Prioritized Remediation Plan

1. **P1 — IOS-P1-001:** Disambiguate Snorkeling test calls (`[] as [SnorkelingCoordinate]`); use production `SnorkelingRoutePlannerDraft` in tests or shared test support module.
2. **P2 — External QA:** Execute Bühlmann external review, paired briefing transfer, iCloud two-device, Subsurface CSV, Snorkeling 12-folder field matrix.
3. **P3 — IOS-P3-001:** Wire navigation persistence tokens into root tab selection.
4. **Regression guard:** Retain GF package builder tests on any planner/sync change.

---

## AK. External / Physical QA Pending

See `Docs/MASTER_IOS_EXTERNAL_VALIDATION_PENDING_CURRENT.md`.

---

## AL. Final Verdict

### Required final questions (summary)

| # | Question | Answer |
|---|---|---|
| 1–2 | Multi-activity / first-class verticals | **YES** |
| 3–5 | Settings switch safe / editable / no leakage | **YES** |
| 6 | Logbook strict ownership | **YES** |
| 7 | Bühlmann complete | **YES** (external pending) |
| 8–9 | Planner/Watch parity / mode isolation | **PASS** — CONS-002 verified |
| 10–11 | CCR reference-only / Ratio Deco safe | **YES** |
| 12–19 | Gas/MOD/Rock Bottom/runtime/repetitive | **YES** |
| 20 | Tissue/narcosis/CNS/OTU | **PARTIAL** — IOS-P3-004 |
| 21–23 | Equipment/checklist/CCR traceable | **YES** |
| 24 | Manual dives/exports | **PARTIAL** — IOS-P3-005 |
| 25 | Briefing cards faithful + reference-only | **YES** (software) |
| 26–28 | Sync/units/performance | **PARTIAL** — field QA pending |
| 29 | Internal TestFlight | **Conditional** — fix IOS-P1-001 |
| 30–31 | External TestFlight / App Store | **Not yet** |
| 32–33 | Blocks 100% / fix first | **IOS-P1-001**, then external QA matrix |

### Machine-readable verdict block

```text
MASTER_IOS_FULL_DEEP_AUDIT: PARTIAL
BASELINE_CURRENT_AND_CLEAN: PASS
TARGET_MEMBERSHIP: PASS
MULTI_ACTIVITY_ARCHITECTURE: PASS
ROOT_FLOW_ACTIVITY_SELECTION: PASS
LEGAL_SAFETY_GATE: PASS
IOS_SETTINGS_MODE_SWITCH: PASS
IOS_DIVING_SETTINGS_OWNERSHIP: PASS
IOS_APNEA_SETTINGS_OWNERSHIP: PASS
IOS_SNORKELING_SETTINGS_OWNERSHIP: PASS
IOS_SETTINGS_NO_CROSS_ACTIVITY_LEAKAGE: PASS
IOS_LOGBOOK_STRICT_OWNERSHIP: PASS
BUHLMANN_CORE_READINESS: 94
IOS_PLANNER_WATCH_PARITY_READINESS: 95
BASE_MODE_READINESS: 92
DECO_MODE_READINESS: 91
TECHNICAL_MODE_READINESS: 92
CCR_REFERENCE_ONLY_READINESS: 90
RATIO_DECO_READINESS: 86
MOD_PPO2_DALTON_READINESS: 93
SWITCH_DEPTH_CLAMP_READINESS: 93
GAS_ROLE_READINESS: 90
ROCK_BOTTOM_READINESS: 90
ASCENT_DESCENT_RUNTIME_READINESS: 92
DECO_STOP_PRESENTATION_READINESS: 91
SCHEDULE_AWARE_GAS_READINESS: 91
GAS_LEDGER_READINESS: 91
TECHNICAL_AVERAGE_DEPTH_GAS_TOGGLE_READINESS: 93
REPETITIVE_DIVE_READINESS: 90
TISSUE_LOADING_READINESS: 90
NARCOSIS_END_PPN2_READINESS: 89
CNS_OTU_READINESS: 91
STRUCTURED_EQUIPMENT_READINESS: 90
CHECKLIST_SYNC_READINESS: 90
CCR_CHECKLIST_ROUNDTRIP_READINESS: 91
CCR_BAILOUT_SCENARIO_READINESS: 88
CCR_GAS_DENSITY_READINESS: 90
MANUAL_DIVE_READINESS: 88
PDF_SHARE_EXPORT_READINESS: 90
PLANNER_BRIEFING_CARD_WATCH_TRANSFER_READINESS: 90
CSV_SUBSURFACE_READINESS: 86
CLOUD_SYNC_PERSISTENCE_READINESS: 88
SECURITY_PRIVACY_READINESS: 88
UNIT_CONVERSION_READINESS: 93
LOCALIZATION_READINESS: 91
ACCESSIBILITY_READINESS: 86
PERFORMANCE_NUMERICAL_ROBUSTNESS_READINESS: 91
TEST_COVERAGE_READINESS: 78
P0_FINDINGS: 0
P1_FINDINGS: 1
P2_FINDINGS: 6
P3_FINDINGS: 6
P4_FINDINGS: 4
OVERALL_IOS_SOFTWARE_READINESS: 90
INTERNAL_TESTFLIGHT_READINESS: 88
EXTERNAL_TESTFLIGHT_READINESS: 50
APP_STORE_READINESS: 46
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_WATCH_IOS_QA: PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: IOS-P1-001,IOS-P2-001,IOS-P2-004,IOS-P2-006
IOS_GF_PRESET_PARITY: PASS
IOS_INFLIGHT_ACK_CLEANUP: PASS
IOS_DIVE_IMPORT_ACK_SYMMETRY: PASS
IOS_TOMBSTONE_SECURITY: PASS
IOS_SOFTWARE_READINESS_AFTER_REMEDIATION: 91
```

---

## Deliverables Index

| File | Status |
|---|---|
| `Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md` | Replaced |
| `Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_REQUIREMENT_TEST_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_EDGE_CASE_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_RELEASE_HARD_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_EXTERNAL_VALIDATION_PENDING_CURRENT.md` | Replaced |
| `Docs/MASTER_IOS_POST_REMEDIATION_GF_SYNC_VERIFICATION_CURRENT.md` | Created |
| `Docs/MASTER_IOS_GF_PRESET_PARITY_POST_REMEDIATION_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_SYNC_ACK_POST_REMEDIATION_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_TOMBSTONE_SECURITY_POST_REMEDIATION_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_WATER_AUTO_OPEN_CODE_RISK_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_APP_INTENT_UNDERWATER_SAFETY_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_GF_PRESET_SYNC_SCHEMA_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_DEPTH_CAPABILITY_ENTITLEMENT_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_DEVELOPER_SHALLOW_TESTING_RELEASE_GATE_MATRIX_CURRENT.csv` | Created |

**Git status after audit:** Only `Docs/MASTER_IOS_*` and related matrix files modified/created. No production code changes.

---

*End of master iOS audit — V1.2 @ `451f8fb`, audit-only.*
