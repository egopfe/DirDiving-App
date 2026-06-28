# DIR DIVING — Master App Store & TestFlight Blockers (Current)

**Command:** 05 — `05-MASTER_RELEASE_QA_EVIDENCE_COMPLIANCE_AUDIT_COMMAND_V1.1.md`  
**Date:** 2026-06-28  
**Branch:** `main` @ `7dfefe2`  
**Merged sources:** Commands 12 + 13; upstream audits 01–04

**Verdict:** **Internal TestFlight — CONDITIONAL.** **External TestFlight and App Store — BLOCKED (NOT READY).**

This document lists blockers only. It does **not** grant legal approval or certification.

---

## Blocker summary

| Category | Open blockers | Blocks internal TF | Blocks external TF | Blocks App Store |
|----------|--------------:|:------------------:|:------------------:|:----------------:|
| Software P1 (GF import, sync) | **7** | Partial | Yes | Yes |
| Legal / marketing sign-off | **2** | No | Yes | Yes |
| Physical Watch (incl. shallow/wet/CMA) | **38** | Disclosure only | Yes | Yes |
| Physical iPhone / a11y | **16** | No | Partial | Yes |
| Paired-device sync | **8** | Partial | Yes | Yes |
| Water auto-open physical | **3** | No | Yes | Yes |
| Hardware controls physical | **4** | No | Yes | Yes |
| External algorithm validation | **4** | No | Yes | Yes |
| App Store marketing assets | **1** | No | No | Yes |
| **Total tracked** | **83** | — | — | — |

---

## P0 — Must not ship with false claims

| Blocker | Software status @ 7dfefe2 | Field status |
|---------|----------------------------|--------------|
| Certified dive computer claim | **CLEAR** | N/A |
| Certified decompression planner claim | **CLEAR** | N/A |
| Certified CCR / life-support claim | **CLEAR** | N/A |
| Guaranteed navigation / medical recovery | **CLEAR** | N/A |
| False physical QA passed claim | **CLEAR** — all matrices PENDING_PHYSICAL | N/A |
| False external Bühlmann validation passed | **CLEAR** | N/A |
| Shallow testing marketed as certified deco | **CLEAR** | N/A |

**P0 blockers: NONE** in production copy or audit posture.

---

## P1 — Internal TestFlight blockers (software)

| ID | Blocker | Evidence | Exit criteria |
|----|---------|----------|---------------|
| MASB-SW-01 | iOS GF preset → Watch import mismatch (IOS-MASTER-F016) | GF-E-013, REQ-GF-02 | Align preset pairs or document limitation |
| MASB-SW-02 | iOS sync in-flight stuck state (MASTER-SYNC-001) | Main code audit §AD | Remediation + test |
| MASB-SW-03 | Asymmetric userInfo ACK (MASTER-SYNC-002) | Main code audit | Symmetric ACK |
| MASB-SW-04 | Legacy unsigned tombstones (MASTER-SYNC-003) | Main code audit | Policy + migration |
| MASB-SW-05 | Shallow FC TestFlight exposure labeling (SDG-008) | Shallow risk assessment | TF notes + in-app label |
| MASB-SW-06 | Depth tier metadata trust (MASTER-DEPTH-002) | Shallow gate matrix | CI signing check |
| MASB-SW-07 | Watch test suite 2 failures (startup flow drift) | xcresult 2026-06-28 | Update tests or routing expectations |

---

## P1 — External release blockers (NOT PASSED)

### Legal & marketing

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-L-01 | External legal counsel review | `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` | Legal row signed |
| MASB-L-02 | Product/marketing sign-off | Same checklist | Marketing row signed |
| MASB-L-03 | App Store screenshots + copy pack | `QA_EVIDENCE/APP_STORE_MARKETING/` | Checklist PASS + assets |

### Physical / entitlement / CMAltimeter / shallow

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-P-01 | Watch Ultra physical QA matrix | `QA_EVIDENCE/WATCH_ULTRA/` | Signed artifacts |
| MASB-P-02 | Underwater entitlement depth session | `HARDWARE_QA_MATRIX` QA-002 | Signed Ultra build log |
| MASB-P-03 | CMAltimeter physical CoreMotion samples | `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | EVIDENCE_TEMPLATE complete |
| MASB-P-04 | Shallow wet Gauge session | `QA_EVIDENCE/HARDWARE_ENTITLEMENT/` | SDG-010 PASS |
| MASB-P-05 | Developer shallow FC wet (internal only) | `QA_EVIDENCE/WATCH_ULTRA/` | SDG-011 if TF scope includes FC |
| MASB-P-06 | VoiceOver / Dynamic Type journeys | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | Procedure PASS |
| MASB-P-07 | PDF render/share manual QA | `QA_EVIDENCE/PDF_RENDER/` | Checklist PASS |

### Water auto-open / hardware controls

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-WAO-01 | End-to-end water auto-open | `QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_PREFERRED/` | WAO-PHY-001 |
| MASB-WAO-02 | System Auto-Launch listing | `QA_EVIDENCE/WATCH_WATER_AUTO_OPEN_SYSTEM_LISTING/` | WAO-PHY-002 |
| MASB-HW-01 | Water Lock physical QA | `QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_WATER_LOCK/` | HWC-PHY-004 |
| MASB-HW-02 | Action Button underwater | `QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_ACTION_BUTTON/` | HWC-PHY-003 |
| MASB-HW-03 | Crown paging underwater | `QA_EVIDENCE/WATCH_UNDERWATER_FAST_CONTROLS_CROWN/` | HWC-PHY-002 |

### Paired / cloud

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-S-01 | Watch↔iPhone sync under load | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Matrix PASS |
| MASB-S-02 | iCloud two-device tombstones | `QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | Matrix PASS |
| MASB-S-03 | Low-battery paired sync | Performance external QA | Logs in evidence folder |
| MASB-S-04 | Briefing card WC transfer | `QA_EVIDENCE/PLANNER_BRIEFING_WATCH/` | Paired smoke PASS |

### External reference

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-E-01 | External Bühlmann golden validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Signed report |
| MASB-E-02 | External Schreiner golden validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Signed report |
| MASB-E-03 | External CCR rebreather validation | `QA_EVIDENCE/CCR_EXTERNAL/` | Signed report |
| MASB-E-04 | Subsurface CSV external round-trip | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | Signed report |

---

## Internal TestFlight conditions (must all hold)

1. `TESTFLIGHT_REVIEW_NOTES.md` states non-certified, shallow-depth default, developer toggles internal-only.
2. Demo logbook / simulation disclosure if simulation enabled.
3. No marketing copy implying certified decompression or full-depth without entitlement evidence.
4. Watch test failures tracked — not blocking if disclosed as known test maintenance (MRQA-P1-007).

---

## What blocks 100% release readiness

All **PENDING_PHYSICAL**, **PENDING_EXTERNAL_VALIDATION**, **PENDING_LEGAL_REVIEW**, and **PENDING_APP_STORE_REVIEW** rows in physical matrix, external gaps doc, and claims matrix — plus software P1 items above.

**RELEASE_BLOCKERS:** MASB-SW-01..07, MASB-P-01..07, MASB-WAO-01..02, MASB-HW-01..03, MASB-S-01..04, MASB-E-01..04, MASB-L-01..03
