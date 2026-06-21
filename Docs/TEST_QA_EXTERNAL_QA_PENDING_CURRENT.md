# DIR DIVING — Test & QA External Evidence Pending (Current)

**Command:** 12 remediation — software gate closed; field/external evidence **PENDING**  
**Date:** 2026-06-20  
**Policy:** No evidence = not passed for physical/external gates. Software gates PASS does **not** upgrade these rows.

---

## Physical Watch

| Gap | Folder | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Ultra mock-fallback / depth lifecycle | `QA_EVIDENCE/WATCH_ULTRA/` | MockDepthSensorProvider + DepthSafetyConfiguration tests | **PENDING** |
| Full Computer 2–4 h battery/thermal | Performance external QA | DIRPerformanceBudgets + timing-fault tests | **PENDING** |
| Apnea wet/battery/thermal | `QA_EVIDENCE/APNEA_*` | ApneaReleaseHardValidationTests | **PENDING** |
| Snorkeling GPS / battery / water lock | `QA_EVIDENCE/SNORKELING_*` | SnorkelingNavigationReturnEngineTests | **PENDING** |
| 41 mm layout clipping | `QA_EVIDENCE/SNORKELING_WATCH_LAYOUTS/` | SnorkelingAccessibilityContractTests (Watch IDs) | **PENDING** |

---

## Physical iPhone

| Gap | Folder | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Planner visual QA Dynamic Type XL | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | PlannerVisualContractTests | **PENDING** |
| 500+ logbook scroll interaction | Performance external QA | 5k synthetic decode budget tests | **PENDING** |
| VoiceOver full journey | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | Identifier contract tests | **PENDING** |
| PDF render/share manual | `QA_EVIDENCE/PDF_RENDER/` | PDFExportServiceTests | **PENDING** |

---

## Paired-device

| Gap | Folder | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Watch↔iPhone signed ACK under load | `QA_EVIDENCE/WATCH_IOS_SYNC/` | ACK burst + MultiActivitySequentialSyncTests | **PENDING** |
| iCloud two-device tombstones | `QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | ActivitySyncTombstoneTests + CloudBackupCapabilityTests | **PENDING** |
| Low-battery paired sync | Performance external QA | Queue/codec negative tests | **PENDING** |

---

## External reference

| Gap | Folder | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Bühlmann external golden | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | BuhlmannReferenceFixtureTests | **PENDING** |
| CCR external rebreather | `QA_EVIDENCE/CCR_EXTERNAL/` | CCRMathRemediationTests | **PENDING** |
| Subsurface external round-trip | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | CSVMetadataRoundTripTests | **PENDING** |

---

## App Store / compliance

| Gap | Folder | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Screenshots / marketing copy | `QA_EVIDENCE/APP_STORE_MARKETING/` | IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md | **PENDING** |
| TestFlight sensor-source disclosure | WATCH_TESTFLIGHT_SENSOR_SOURCE_QA.md | SensorSourceMode + InfoView disclosure keys | **PENDING** |

---

## Underwater entitlement

| Gap | Matrix | Software substitute | Field status |
|-----|--------|---------------------|--------------|
| Submersion depth API session | HARDWARE_QA_MATRIX QA-002 | AppleDepthSensorAvailability probe + mock depth provider | **PENDING** |

---

## Closure rule

Upgrade a row to **PASS** only when the evidence folder contains completed README fields, required artifacts, and validator PASS for release mode where applicable.
