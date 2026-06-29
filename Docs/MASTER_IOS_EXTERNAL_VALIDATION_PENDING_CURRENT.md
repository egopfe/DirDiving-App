# iOS Master Audit — External / Physical Validation Pending

**Command:** `02-MASTER_IOS_FULL_DEEP_COMPREHENSIVE_AUDIT_COMMAND_V1.1` (LAUNCH ORDER 02)  
**Date:** 2026-06-28  
**Branch:** `main`  
**Commit:** `5d757cc` (`5d757cc0217755f5c6d5429af2f13ce5c4748c5d`)  
**Scope:** DIR Diving iOS Companion — merged math, Bühlmann, algorithm, multi-activity audit including GF preset override compatibility and briefing-card reference-only posture

**Post-remediation note:** CONS-002 GF preset parity and CONS-027 PlannerStore deinit cancellation verified @ `5d757cc`. Software GF import **PASS**; external Bühlmann preset spot-check (CONS-043) remains pending.

All items below remain **NOT EXECUTED** or **PENDING** unless signed evidence exists in `Docs/QA_EVIDENCE/`. No physical iPhone, paired Watch, underwater, external Bühlmann, Subsurface, or App Store legal review was performed during this audit pass.

---

## Summary

| Category | Open gaps | Software substitute allowed? |
|----------|----------:|------------------------------|
| Physical Watch Ultra | 12 | **No** |
| Physical iPhone | 7 | **No** |
| Paired-device sync | 9 | **No** |
| Underwater entitlement | 1 | **No** |
| External algorithm reference | 4 | **No** |
| App Store / legal | 2 | **No** |
| Accessibility manual QA | 3 | **No** |
| **Total NOT PASSED** | **38** | — |

Integrated from: `Docs/EXTERNAL_VALIDATION_GAPS_CURRENT.md`, `Docs/ACTIVITY_ARCHITECTURE_EXTERNAL_QA_PENDING_CURRENT.md`, `Docs/WATCH_FULL_COMPUTER_GRADIENT_FACTORS_IMPLEMENTATION_REPORT_CURRENT.md`.

---

## Bühlmann external validation

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-BUHL-01 | PENDING_EXTERNAL_VALIDATION | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Algorithm marketing / third-party sign-off |
| EXT-IOS-BUHL-02 | PENDING_EXTERNAL_VALIDATION | `BUHLMANN_EXTERNAL_VALIDATION_FIXTURES_TEMPLATE.md` | `reviewerSignOff: PENDING` |

**Software baseline:** Shared `BuhlmannCore` ZH-L16C engine; iOS golden fixtures (`BuhlmannGoldenFixtureTests`, `BuhlmannReferenceFixtureTests`); **1527 executed tests, 0 failures** in `DIRDiving iOS Algorithm Tests` @ `5d757cc`. Post-remediation GF tests **15/15 PASS**. Internal consistency **PASS**; external oracle comparison **NOT EXECUTED**.

---

## Subsurface / CSV external validation

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-SS-01 | PENDING_EXTERNAL_VALIDATION | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | Desktop import compatibility claim |
| EXT-IOS-SS-02 | NOT_EXECUTED | — | Round-trip against Subsurface 4.x/5.x on real exports |

**Software baseline:** `CSVMetadataRoundTripTests`, `Docs/SUBSURFACE_CSV_ROUNDTRIP.md`. Malformed import fail-closed **PASS** in software.

---

## CCR external validation

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-CCR-01 | PENDING_EXTERNAL_VALIDATION | `QA_EVIDENCE/CCR_EXTERNAL/` | CCR planner reference sign-off |
| EXT-IOS-CCR-02 | DOCUMENTED_ACCEPTED_RISK | `Docs/CCR_REBREATHER_LIMITATIONS.md` | Heuristic bailout scenario; reference-only by design |

**Software baseline:** `CCRPlannerTests`, `CCRMathRemediationTests`, `CCRPlannerBriefingExportTests`; UI disclaimers `planner.reference_only.warning`, `ccr.reference_estimate_only`; `PlannerBriefingCardManifest.referenceOnly == true`.

---

## Ratio Deco external validation

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-RD-01 | PENDING_EXTERNAL_VALIDATION | `QA_EVIDENCE/RATIO_DECO_EXTERNAL/` | Optional comparative mode marketing |
| EXT-IOS-RD-02 | DOCUMENTED_ACCEPTED_RISK | `RatioDecoDisclaimerBanner` | Heuristic/comparative; Bühlmann primary |

---

## PDF / export validation

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-PDF-01 | PENDING_PHYSICAL | `QA_EVIDENCE/PDF_RENDER/` | Manual PDF render/share on device |
| EXT-IOS-PDF-02 | PENDING_EXTERNAL_VALIDATION | — | Pixel/numerical diff vs on-screen planner |

**Software baseline:** `PDFExportServiceTests`, `BriefingPDFBuilderTests`, `PlannerBriefingImageExportServiceTests`.

---

## GF preset / iOS plan → Watch Full Computer override

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-GF-01 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Physical confirm iOS plan GF lock on Watch predive |
| EXT-IOS-GF-02 | OPEN (software) | — | iOS conservative/standard presets rejected at import (`IOS-MASTER-F016`) |

**Software baseline:** Watch `FullComputerGradientFactorSettingsStoreTests` PASS; iOS `PlannerGFPresetDisplayTests` PASS for iOS values; cross-preset mapping **FAIL** for 20/70 and 30/80 until remediated.

---

## Physical iPhone QA

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-IPH-01 | PENDING_PHYSICAL | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | Dynamic Type XL planner layout |
| EXT-IOS-IPH-02 | PENDING_PHYSICAL | Performance external QA | 500+ logbook scroll latency |
| EXT-IOS-IPH-03 | PENDING_PHYSICAL | `QA_EVIDENCE/SNORKELING_IOS_MAPS/` | Snorkeling map long-route interaction |
| EXT-IOS-IPH-04 | PENDING_PHYSICAL | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | VoiceOver full multi-activity journey |
| EXT-IOS-IPH-05 | PENDING_PHYSICAL | `QA_EVIDENCE/PDF_RENDER/` | Share sheet / Files integration |
| EXT-IOS-IPH-06 | PENDING_PHYSICAL | — | Settings mode switcher gear routing from each dashboard |
| EXT-IOS-IPH-07 | PENDING_PHYSICAL | — | Cold-launch activity picker UX |

---

## Paired Watch / iPhone sync QA

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-PAIR-01 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Signed ACK under load |
| EXT-IOS-PAIR-02 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Offline queue flush on reconnect |
| EXT-IOS-PAIR-03 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | iCloud tombstones two-device |
| EXT-IOS-PAIR-04 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/APNEA_IOS_WATCH_SYNC/` | Apnea activity sync matrix |
| EXT-IOS-PAIR-05 | PENDING_PAIRED_DEVICE_QA | `QA_EVIDENCE/SNORKELING_IOS_WATCH_SYNC/` | Snorkeling activity sync matrix |
| EXT-IOS-PAIR-06 | PENDING_PAIRED_DEVICE_QA | — | Planner briefing card PNG transfer + ACK on paired hardware |
| EXT-IOS-PAIR-07 | PENDING_PAIRED_DEVICE_QA | — | iOS Settings mode switch does not mutate Watch runtime (physical confirm) |
| EXT-IOS-PAIR-08 | PENDING_PAIRED_DEVICE_QA | Performance external QA | Low-battery paired sync |
| EXT-IOS-PAIR-09 | PENDING_PAIRED_DEVICE_QA | — | iOS plan GF override end-to-end on paired Watch FC |

---

## App Store / legal review

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-LEGAL-01 | NOT_EXECUTED | `QA_EVIDENCE/APP_STORE_MARKETING/` | Screenshots and marketing copy |
| EXT-IOS-LEGAL-02 | NOT_EXECUTED | `Docs/RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md` | Non-certified planner / CCR / briefing disclaimers legal sign-off |

**Software baseline:** `ReleaseLegalClaimsRemediationTests`; no EN13319/ISO 6425/CE claims in production strings audited at `5d757cc`.

---

## Accessibility manual QA

| ID | Status | Evidence folder | Blocking |
|----|--------|-----------------|----------|
| EXT-IOS-A11Y-01 | PENDING_PHYSICAL | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | VoiceOver math-bearing labels |
| EXT-IOS-A11Y-02 | PENDING_PHYSICAL | — | Chart accessibility summaries on device |
| EXT-IOS-A11Y-03 | PARTIAL | `UIUXRemediationV3AccessibilityTests` | Software contract tests pass; manual journey pending |

---

## Audit pass limitations

| Limitation | Impact |
|------------|--------|
| No physical iPhone QA | Layout, haptics, share sheet unverified |
| No paired Watch QA | Briefing transfer ACK and GF override unverified on hardware |
| No external Bühlmann oracle | Cannot claim third-party decompression parity |
| No Subsurface desktop round-trip | CSV compatibility claim software-only |
| GF preset cross-target gap | iOS conservative/standard plans cannot activate Watch FC override until aligned |

---

*End of external validation pending report — post-remediation audit @ `5d757cc`.*
