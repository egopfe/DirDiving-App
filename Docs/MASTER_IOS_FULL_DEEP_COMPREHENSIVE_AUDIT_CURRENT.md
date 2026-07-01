# DIR Diving iOS — Master Full Deep Comprehensive Audit — CURRENT

**Command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.5` (LAUNCH ORDER 02)  
**Audit date:** 2026-07-01  
**Repository:** `https://github.com/egopfe/DirDiving-App.git`  
**Branch:** `main`  
**Commit:** `2c30412` (`2c30412e777e6ef40a688b9ac11215f32310764f`)  
**Scope:** DIRDiving iOS Companion — merged math + Bühlmann + algorithm + multi-activity + Apnea P1/P2/P3 @ `76f3703` + Snorkeling P1/P2/P3 + software remediation + CONS-046 V1.5  
**Execution mode:** Read-only static analysis + macOS `xcodegen` / `xcodebuild` validation  
**Xcode:** 26.6 (Build 17F113)  
**Upstream audit 01:** Watch FC Forensic @ `2c30412` — **PARTIAL**, 0 P0 FC math; WFC-P1-001 external pending; WFC-P2-005 13 routing test failures

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

**Status: Software-ready multi-activity iOS Companion — PARTIAL consolidated release readiness due to physical/external gates**

`main` @ `2c30412` delivers a **first-class multi-activity iOS Companion** with strict vertical ownership for Diving (planner reference, logbook, equipment, checklist), Apnea (companion planning/logbook/settings/export; live session on Watch @ `76f3703`), and Snorkeling (GPS routes, P1/P2/P3 route planner, map UX, analytics). Gauge and Full Computer live Bühlmann runtime execute on **Apple Watch**; iOS provides planner reference, sealed dive-plan packages, briefing cards (**reference-only**), and logbook import.

**Remediation wave closed IOS-P1-001 / CONS-049:** iOS Algorithm Tests **1655 executed, 0 failures** @ `2c30412`.  
**CONS-046 V1.5:** `validate_commands_for_cursor_integrity.sh` **PASS**.  
**Post-remediation CONS-002/003/004/005:** **PASS** in code and tests.

**Upstream constraint (V1.5):** Audit 01 reports **0 P0 FC math defects** but **WFC-P1-001** (external Bühlmann validation) and **WFC-P2-005** (13 Watch water-auto-open routing test failures after Apnea P1/P2/P3) remain open. iOS does not contradict audit 01; consolidated release remains **PARTIAL**.

### macOS validation (@ `2c30412`)

| Check | Result |
|---|---|
| Branch / commit | `main` @ `2c30412` ✓ |
| Working tree | Docs-only changes from this audit |
| `xcodegen generate` | **SUCCEEDED** |
| iOS MAIN build (`generic/platform=iOS Simulator`, `CODE_SIGNING_ALLOWED=NO`) | **BUILD SUCCEEDED** |
| iOS Algorithm Tests (`iPhone 17 Pro` simulator) | **TEST SUCCEEDED** — **1655 tests, 0 failures** (68.4s) |
| Command integrity script | **PASS** — CONS-046 V1.5 |
| Production `try!` / `as!` in `iOSApp/` | **0** matches |
| Test inventory | **1417** `func test` definitions; **1655** executed @ `2c30412` |

### Severity summary (software findings)

| Priority | Count | Notes |
|---:|---:|---|
| **P0** | **0** | No safety-critical algorithm or cross-activity routing defect |
| **P1** | **0** | IOS-P1-001 **VERIFIED CLOSED** @ `2c30412` |
| **P2** | **7** | External validation + physical QA pending (IOS-P2-001..007) |
| **P3** | **6** | Navigation restore, Apnea cloud, dual-binding, tissue replay, manual editor, map GPS quirk |
| **P4** | **4** | Keychain skips, PDF MOD asymmetry, eager stores, checklist inference |

### Release posture

| Gate | Verdict |
|---|---|
| Internal algorithm / code review | **READY** — build + 1655 tests green |
| Internal TestFlight (software) | **READY** — reference-only posture; physical disclosure required |
| External TestFlight / RC | **Not yet** — external math + paired Watch + Snorkeling/Apnea field QA **PENDING** |
| App Store | **Not yet** — legal/marketing + all external gates |
| Certified decompression planner | **Never** — reference-only by design |

---

## B. Source Commands Merged

This report merges three iOS audit command scopes plus V1.5 requirements: Apnea first-class scope, Settings mode switcher, activity-owned Settings/Logbooks, Snorkeling P1/P2/P3 route planner, map UX, fake logbook toggles, GF/sync post-remediation verification, algorithmic parity with Watch gate, cross-cutting water-entry/GF/entitlements scope (read-only).

---

## C. Latest Development Update

Since prior iOS audit (`451f8fb`), `main` @ `2c30412` includes:

- **Software remediation to 100%** (`7a429a7`) — IOS-P1-001 Snorkeling test compile fixed; test suite green.
- **CONS-046 V1.5** (`6a0005b`) — command integrity script aligned to V1.5 audit commands.
- **Apnea P1/P2/P3** (`76f3703`) — Watch training compound features; iOS companion boundary verified; WFC-P2-005 routing test drift on Watch.
- **Snorkeling P1/P2/P3** — return-to-entry, safety check, profiles, gated Watch transfer, off-route Watch runtime.
- **Snorkeling map UX** — center-on-location, map type picker, reset map confirmation.
- **Activity fake logbook toggles** — per-activity Settings; default OFF; not in `DeveloperSettings`.
- **CONS remediations retained** — GF parity, sync ACK cleanup, symmetric diveImportAck, tombstone HMAC.

---

## D. Branch, Commit and Scope

| Item | Value |
|---|---|
| Required branch | `main` ✓ |
| Audited commit | `2c30412` |
| Primary target | `DIRDiving iOS` |
| Primary test target | `DIRDiving iOS Algorithm Tests` |
| Secondary scope | Shared/BuhlmannCore, Watch GF/briefing/sync codecs (read-only parity) |
| Apnea Watch baseline | `76f3703` |

---

## E. Preflight and Build/Test Baseline

### Preflight commands executed

```bash
git branch --show-current          # main
git rev-parse --short HEAD         # 2c30412
git fetch --prune origin
git status -sb
xcodegen generate
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS" \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
xcodebuild -project DIRDiving.xcodeproj -scheme "DIRDiving iOS Algorithm Tests" \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO test
bash Scripts/validate_commands_for_cursor_integrity.sh  # PASS CONS-046 V1.5
```

### Results

| Step | Outcome |
|---|---|
| Branch / commit | `main` @ `2c30412` ✓ |
| iOS build | **BUILD SUCCEEDED** |
| iOS Algorithm Tests | **TEST SUCCEEDED** — 1655 executed, 0 failures |
| Command integrity | **PASS** @ V1.5 |
| Prior regression | `451f8fb`: compile failure IOS-P1-001 — **CLOSED** |

---

## F. Target Membership and Architecture

```text
DIR Diving (iOS Companion @ 2c30412)
├── Shared/BuhlmannCore              → canonical ZH-L16C (shared with Watch FC)
├── Shared/Models/                   → FullComputerGradientFactorPreset; DivePlanPackage
├── iOSApp/
│   ├── Services/                    → Planner, sync, logbooks, Snorkeling route planner, Apnea stores
│   ├── Views/                       → Activity roots, Settings mode switcher, Apnea/Snorkeling verticals
│   └── Utils/PlannerModePolicy.swift
├── Apnea iOS companion             → planning, logbook, settings, export (live session on Watch)
├── Snorkeling P1/P2/P3             → IOSSnorkelingRoutePlannerView + Shared validators
└── Tests/iOSAlgorithmTests/         → 1655 tests PASS @ 2c30412
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

## Apnea iOS Companion Scope (@ `76f3703` cross-read)

Detailed report: `Docs/MASTER_IOS_APNEA_FULL_DEEP_AUDIT_CURRENT.md`

| iOS Companion (in scope) | Watch @76f3703 (authoritative) |
|---|---|
| Dashboard, sessions, statistics, profiles tabs | Live session engine |
| Session planner, profiles, training tables | Automatic detection, wet behavior |
| Settings (recovery, targets, alarms, markers) | Runtime alarms, recovery countdown |
| Logbook import/display/export | Depth/time profile sampling |
| Equipment, buddy, checklist | Training P1/P2/P3 compound steps |
| Signed plan transfer to Watch | Action Button, Digital Crown, water auto-open |

**Mandatory truthfulness:** No decompression/GF/gas/MOD in Apnea iOS; no medical recovery guarantee; water auto-open does **not** start Apnea session on Watch.

---

## J. Feature Inventory

`Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv` — 65 feature rows including Apnea companion, Snorkeling P1/P2/P3, map UX, fake logbook toggles.

Apnea detail: `Docs/MASTER_IOS_APNEA_FEATURE_INVENTORY_CURRENT.csv`

---

## K. Bühlmann Core

ZH-L16C shared core: 16 N2+He compartments, GF interpolation, multigas, preflight validation, deterministic output. No P0 math defect identified on iOS or upstream Watch FC @ audit 01. External validation **PENDING** (IOS-P2-001 / WFC-P1-001).

---

## L. Planner Mode Projection

| Mode | Isolation | Readiness |
|---|---|---|
| Base | Single gas; GF forced 30/70; no deco leakage | 92% |
| Deco | Simplified schedule; GF preset cards | 91% |
| Technical | Full schedule + gas ledger + rock bottom | 92% |
| CCR | Separate engine; reference-only | 90% |

---

## M–U. Gas, Rock Bottom, Runtime, CCR, Equipment

Schedule-aware consumption, rock bottom independent from planned consumption, deco-stop presentation matches canonical schedule, CCR reference-only with explicit OC/CCR separation, equipment/checklist role mapping tested. Parity gate: `Docs/MASTER_IOS_ALGORITHMIC_PARITY_WITH_WATCH_GATE_CURRENT.md`.

---

## Snorkeling Route Planner P1/P2/P3

| Tier | iOS software | Verdict |
|---|---|---|
| **P1** | Return-to-entry preview, safety check, checklist, gated Watch transfer | **PASS** software |
| **P2** | Profile kinds, validation warnings, return alert policy | **PASS** software |
| **P3** | Off-route detection (Watch runtime 50 m) | **PASS** software (Watch primary) |

Physical open-water QA: **PENDING** (IOS-P2-006, CONS-048).

---

## Post-Remediation CONS Verification

| CONS ID | iOS impact | Verdict @2c30412 |
|---|---|---|
| CONS-002 | GF preset parity | **PASS** |
| CONS-003 | inFlight ACK cleanup | **PASS** |
| CONS-004 | diveImportAck symmetry | **PASS** |
| CONS-005 | Tombstone HMAC | **PASS** |
| CONS-046 | Command integrity V1.5 | **PASS** |
| CONS-028 | Navigation restoration | **PARTIAL** |
| CONS-040 | Dual diving settings binding | **OPEN P3** |

Detail: `Docs/MASTER_IOS_POST_REMEDIATION_GF_SYNC_VERIFICATION_CURRENT.md`

---

## AB. Test Coverage

**1655** tests executed, **0 failures** @ `2c30412`. **1417** test function definitions in `Tests/iOSAlgorithmTests`. Coverage spans Bühlmann, planner modes, MOD/clamp, CCR, Ratio Deco, gas roles, rock bottom, equipment, sync, multi-activity routing, Apnea companion, Snorkeling P1/P2/P3, briefing cards, CSV, cloud merge.

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
| IOS-P1-001 | P1 | Snorkeling test compile failure | **VERIFIED CLOSED** |
| IOS-P2-001..007 | P2 | External/physical QA; Watch routing cross-gate | PENDING / OPEN |
| IOS-P3-001..006 | P3 | Nav restore, Apnea cloud, dual-binding, tissue replay, manual editor, map GPS | OPEN |
| IOS-P4-001..004 | P4 | Keychain skip, PDF MOD, eager stores, checklist inference | VERIFIED |

Full traceability: `Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv`

---

## AH. Prioritized Remediation Plan

1. **P2 — External QA:** Execute Bühlmann external review (WFC-P1-001), paired briefing transfer, iCloud two-device, Subsurface CSV, Snorkeling 12-folder field matrix, Apnea wet field QA.
2. **P2 — Watch routing:** Resolve WFC-P2-005 (13 routing test failures) — Watch-side; iOS cross-read only.
3. **P3 — IOS-P3-001:** Wire navigation persistence tokens into root tab selection.
4. **Regression guard:** Retain 1655-test suite on any planner/sync/Apnea/Snorkeling change.

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
| 7 | Bühlmann complete | **YES** (external pending WFC-P1-001) |
| 8–9 | Planner/Watch parity / mode isolation | **PASS** — CONS-002 verified |
| 10–11 | CCR reference-only / Ratio Deco safe | **YES** |
| 12–19 | Gas/MOD/Rock Bottom/runtime/repetitive | **YES** |
| 20 | Tissue/narcosis/CNS/OTU | **PARTIAL** — IOS-P3-004 |
| 21–23 | Equipment/checklist/CCR traceable | **YES** |
| 24 | Manual dives/exports | **PARTIAL** — IOS-P3-005 |
| 25 | Briefing cards faithful + reference-only | **YES** (software) |
| 26–28 | Sync/units/performance | **PARTIAL** — field QA pending |
| 29 | Internal TestFlight | **YES** (software) — physical disclosure |
| 30–31 | External TestFlight / App Store | **Not yet** |
| 32–33 | Blocks 100% / fix first | **External + physical QA matrix**; WFC-P1-001 |

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
TEST_COVERAGE_READINESS: 96
P0_FINDINGS: 0
P1_FINDINGS: 0
P2_FINDINGS: 7
P3_FINDINGS: 6
P4_FINDINGS: 4
OVERALL_IOS_SOFTWARE_READINESS: 94
INTERNAL_TESTFLIGHT_READINESS: 92
EXTERNAL_TESTFLIGHT_READINESS: 52
APP_STORE_READINESS: 48
PHYSICAL_IOS_QA: PENDING_PHYSICAL
PAIRED_WATCH_IOS_QA: PENDING_PHYSICAL
EXTERNAL_BUHLMANN_VALIDATION: PENDING_EXTERNAL_VALIDATION
EXTERNAL_SUBSURFACE_VALIDATION: PENDING_EXTERNAL_VALIDATION
RELEASE_BLOCKERS: IOS-P2-001,IOS-P2-004,IOS-P2-006,WFC-P1-001
IOS_GF_PRESET_PARITY: PASS
IOS_INFLIGHT_ACK_CLEANUP: PASS
IOS_DIVE_IMPORT_ACK_SYMMETRY: PASS
IOS_TOMBSTONE_SECURITY: PASS
IOS_SOFTWARE_READINESS_AFTER_REMEDIATION: 94
CONS-046_V1.5: PASS
```

---

## Deliverables Index

| File | Status |
|---|---|
| `Docs/MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_CURRENT.md` | Replaced |
| `Docs/MASTER_IOS_FEATURE_INVENTORY_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_REQUIREMENT_TEST_MATRIX_CURRENT.csv` | Updated |
| `Docs/MASTER_IOS_EDGE_CASE_MATRIX_CURRENT.csv` | Updated |
| `Docs/MASTER_IOS_FINDING_TRACEABILITY_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_RELEASE_HARD_MATRIX_CURRENT.csv` | Replaced |
| `Docs/MASTER_IOS_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv` | Retained (valid @2c30412) |
| `Docs/MASTER_IOS_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv` | Retained (valid @2c30412) |
| `Docs/MASTER_IOS_EXTERNAL_VALIDATION_PENDING_CURRENT.md` | Replaced |
| `Docs/MASTER_IOS_APNEA_FULL_DEEP_AUDIT_CURRENT.md` | Created |
| `Docs/MASTER_IOS_APNEA_FEATURE_INVENTORY_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_APNEA_SETTINGS_OWNERSHIP_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_APNEA_LOGBOOK_OWNERSHIP_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_APNEA_SYNC_SCHEMA_MATRIX_CURRENT.csv` | Created |
| `Docs/MASTER_IOS_ALGORITHMIC_PARITY_WITH_WATCH_GATE_CURRENT.md` | Created |
| `Docs/MASTER_IOS_POST_REMEDIATION_GF_SYNC_VERIFICATION_CURRENT.md` | Updated |
| V1.5 cross-cutting matrices | Updated @2c30412 |

**Git status after audit:** Only `Docs/MASTER_IOS_*` and related matrix files modified/created. No production code changes.

---

*End of master iOS audit — V1.5 @ `2c30412`, audit-only.*
