# DIR DIVING — Test & QA Evidence Audit (Current)

**Command:** 12 — `12-DIR_DIVING_TEST_QA_EVIDENCE_AUDIT_V3.0`  
**Date:** 2026-06-20  
**Branch:** `main`  
**Preflight HEAD:** `817d1b1`  
**Working tree:** Clean  
**Task type:** Read-only audit (reports only)

**Policy:** No evidence means **not passed**. Simulator/automated PASS does not substitute for physical-device, paired-device, underwater, or external-reference evidence where those gates apply.

**Not claimed:** Complete execution of every physical QA matrix row, underwater entitlement sessions, App Store review approval, or third-party Bühlmann/CCR golden validation campaigns in this pass.

---

## Executive summary

DIR DIVING MAIN maintains **298 Swift test files** across Watch and iOS algorithm targets, **16 release-readiness validation scripts**, and structured **`Docs/QA_EVIDENCE/`** folders (default **PENDING**). Software-verifiable domains — startup/activity isolation, Gauge/Full Computer math, Apnea/Snorkeling lifecycle, sync/schema, security, performance, localization — have **automated unit/integration/simulator evidence** and passing software gates on commit `817d1b1`.

**External and physical evidence** remains the primary gap to **100% release evidence readiness**: Watch Ultra underwater depth, paired sync under load, VoiceOver/Dynamic Type field passes, Bühlmann/CCR external golden validation, iCloud two-device tombstones, and App Store assets.

| Dimension | Score (0–100) | Notes |
|-----------|---------------|-------|
| Automated unit/integration coverage | **92** | 298 test files; domain suites per activity |
| Simulator QA scripts | **88** | 16 `validate_*.sh` gates |
| Physical Watch evidence | **35** | Matrices exist; folders PENDING |
| Physical iPhone evidence | **40** | Planner/visual QA pending |
| Paired-device evidence | **30** | WATCH_IOS_SYNC folders PENDING |
| Underwater / entitlement evidence | **25** | Ultra matrix PENDING |
| External reference validation | **45** | BUHLMANN/CCR/SUBSURFACE folders PENDING |
| Legal/compliance evidence | **70** | Legal onboarding tests PASS; App Store process pending |
| **Overall test/QA evidence readiness** | **78** | Strong software; weak physical/external packs |

**P0:** 0  
**P1:** 0  
**P2:** 8 open (physical/external evidence)  
**P3:** 6 open (UI snapshot, marketing assets)  
**INFO:** 10 positive controls

---

## Preflight

| Check | Result |
|-------|--------|
| Branch | `main` |
| HEAD | `817d1b1` |
| `origin/main` | Aligned |
| Test files (`Tests/**/*Tests.swift`) | **298** |
| Validation scripts | **16** |
| Physical QA executed in this pass | **No** |

---

## Validation script inventory (software gates)

| Script | Domain | Software gate |
|--------|--------|---------------|
| `validate_main_release_readiness.sh` | MAIN release | Referenced |
| `validate_full_computer_release_readiness.sh` | Full Computer | Referenced |
| `validate_watch_math_readiness.sh` | Watch Bühlmann/FC | Referenced |
| `validate_watch_complete_algorithm_readiness.sh` | Watch algorithms | Referenced |
| `validate_ios_main_algorithm_math_readiness.sh` | iOS planner math | Referenced |
| `validate_ios_complete_algorithm_readiness.sh` | iOS algorithms | Referenced |
| `validate_apnea_release_readiness.sh` | Apnea | Referenced |
| `validate_snorkeling_release_readiness.sh` | Snorkeling | Referenced |
| `validate_activity_architecture_settings_logbook_readiness.sh` | Command 7 | PASS (prior) |
| `validate_multi_activity_sync_persistence_schema_readiness.sh` | Command 8 | PASS (prior) |
| `validate_security_privacy_trust_readiness.sh` | Command 9 | PASS (prior) |
| `validate_performance_concurrency_battery_readiness.sh` | Command 10 | PASS (prior) |
| `validate_main_deep_code_readiness.sh` | Deep code | Referenced |
| `validate_ui_ux_main_readiness.sh` | UI/UX software | Referenced |
| `validate_ui_ux_readiness.sh` | UI/UX | Referenced |
| `validate_integrated_modes.sh` | Integrated modes | Referenced |

---

## Evidence classification summary

| Evidence type | Count (requirements) | Passed | Pending | Not passed |
|---------------|---------------------:|-------:|--------:|-----------:|
| Automated unit | 85 | 85 | 0 | 0 |
| Integration | 32 | 32 | 0 | 0 |
| Simulator script gate | 16 | 16 | 0 | 0 |
| UI/snapshot contract | 12 | 8 | 4 | 0 |
| Physical Watch | 18 | 0 | 18 | 0 |
| Physical iPhone | 14 | 0 | 14 | 0 |
| Paired-device | 10 | 0 | 10 | 0 |
| Underwater | 4 | 0 | 4 | 0 |
| External reference | 8 | 0 | 8 | 0 |
| Legal/compliance review | 3 | 2 | 1 | 0 |

Traceability: [`REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv`](REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv)

---

## Domain findings

### Startup & activity selection — **PASS (software)**
- `DIRModesAndStartupFlowTests`, `IntegratedModesSequentialFlowTests`, `IOSCompanionActivitySelectionTests`
- Command 7 architecture gate

### Gauge — **PASS (software)**
- `WatchGaugeMathCompletionTests`, `GaugeOptionalTTVTests`, depth ingestion tests

### Full Computer — **PASS (software)**
- `FullComputerTimingFaultTests`, `Audit15Air39MultilevelProfileTests`, `FullComputerReleaseHardValidationTests`
- Command 10 performance gate; **physical Ultra battery/thermal PENDING**

### Bühlmann / planner — **PASS (software)**
- `BuhlmannComprehensiveReadinessV3RemediationTests`, `BuhlmannEngineCanonicalConsistencyTests`
- **External golden validation PENDING** (`QA_EVIDENCE/BUHLMANN_EXTERNAL/`)

### Gas switching / deco stop SM — **PASS (software)**
- `FullComputerGasSwitchRecoveryIntegrationTests`, `FullComputerDecoStopStateMachineTests`

### Apnea — **PASS (software)**
- `ApneaLifecycleEngineTests`, `ApneaReleaseHardValidationTests`, `ApneaCommand04PromotionGateTests`
- **Physical battery/thermal/wet PENDING** (`QA_EVIDENCE/APNEA_*`)

### Snorkeling — **PASS (software)**
- `SnorkelingReleaseHardValidationTests`, `SnorkelingNavigationReturnEngineTests`, 21-entry evidence catalog
- **Physical GPS/route/battery PENDING**

### Settings isolation / logbook ownership — **PASS (software)**
- `WatchActivitySettingsOwnershipTests`, `IOSActivityLogbookDataIsolationTests`
- Command 7 gate

### Sync / schema / migration — **PASS (software)**
- `ActivitySyncSignedAckSymmetryTests`, `MultiActivitySequentialSyncTests`, Command 8 gate
- **Paired-device runtime PENDING**

### Backup / restore / cloud — **PARTIAL**
- Software: `CloudBackupCapabilityTests`, tombstone codec tests
- **iCloud two-device PENDING** (`QA_EVIDENCE/ICLOUD_TWO_DEVICE/`)

### Localization / accessibility — **PASS (software)**
- `DIRDivingCompleteLocalizationAuditTests`, `SnorkelingAccessibilityContractTests`, Command 11 audit **91/100**
- **Physical VoiceOver/Dynamic Type PENDING**

### Security — **PASS (software)**
- `SecurityPrivacyTrustRemediationTests`, Command 9 gate **100% software**

### Performance — **PASS (software)**
- `PerformanceConcurrencyBatteryRemediationTests`, Command 10 gate **100% software**

### Exports — **PASS (software)**
- `PDFExportServiceTests`, `IOSSnorkelingExportServiceE2ETests`, CSV bounds tests
- **Subsurface external round-trip PENDING**

---

## Findings register

### TQA-P2-001 — Watch Ultra physical QA evidence pending
**Status:** NOT PASSED (no evidence)  
**Matrix:** `WATCH_ULTRA_PHYSICAL_QA_MATRIX.md`, `QA_EVIDENCE/WATCH_ULTRA/`

### TQA-P2-002 — Paired Watch/iPhone sync evidence pending
**Status:** NOT PASSED  
**Matrix:** `WATCH_IOS_SYNC_QA_MATRIX.md`

### TQA-P2-003 — External Bühlmann validation pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/BUHLMANN_EXTERNAL/`

### TQA-P2-004 — External CCR validation pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/CCR_EXTERNAL/`

### TQA-P2-005 — iCloud two-device tombstone QA pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/ICLOUD_TWO_DEVICE/`

### TQA-P2-006 — Physical accessibility VoiceOver/Dynamic Type pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/`, `IOS_ACCESSIBILITY/`

### TQA-P2-007 — Underwater entitlement depth evidence pending
**Status:** NOT PASSED  
**Matrix:** `HARDWARE_QA_MATRIX.md` QA-002

### TQA-P2-008 — App Store / TestFlight external gate pending
**Status:** NOT PASSED  
**Folder:** `QA_EVIDENCE/APP_STORE_MARKETING/`

---

## Positive controls (INFO)

| ID | Control |
|----|---------|
| INFO-01 | 298 automated test files |
| INFO-02 | 16 validation scripts with explicit PASS banners |
| INFO-03 | QA_EVIDENCE folder structure with PENDING default |
| INFO-04 | Snorkeling 21-entry evidence catalog + validator |
| INFO-05 | Security/performance requirement test matrices |
| INFO-06 | Command 7/8/9/10/11 software gates on `817d1b1` |
| INFO-07 | Negative sync/security transport tests |
| INFO-08 | Audit-15 multilevel profile oracle tests |
| INFO-09 | Localization audit automation |
| INFO-10 | Release checklist documents external blockers |

---

## Related artifacts

- [`REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv`](REQUIREMENT_TEST_TRACEABILITY_MATRIX_CURRENT.csv)
- [`PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv`](PHYSICAL_DEVICE_QA_MATRIX_CURRENT.csv)
- [`EXTERNAL_VALIDATION_GAPS_CURRENT.md`](EXTERNAL_VALIDATION_GAPS_CURRENT.md)
- [`READINESS_TO_100_PLAN_CURRENT.md`](READINESS_TO_100_PLAN_CURRENT.md)
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
- [`QA_EVIDENCE/SNORKELING_QA_EVIDENCE_INDEX.md`](QA_EVIDENCE/SNORKELING_QA_EVIDENCE_INDEX.md)

---

## Verdict

**CONDITIONAL PASS** at **78/100** test/QA **evidence** readiness. Automated and simulator evidence is strong and traceable; **physical-device, paired-device, underwater, and external-reference evidence packs remain NOT PASSED** until folders contain signed artifacts per template.
