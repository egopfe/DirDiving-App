# DIR DIVING — Master App Store & TestFlight Blockers (Current)

**Command:** 05 — Master Release / QA / Evidence / Compliance Audit V1.0  
**Date:** 2026-06-22  
**Branch:** `main` @ `1f62235`  
**Merged sources:** Commands 12 + 13

**Verdict:** **Internal TestFlight — CONDITIONAL.** **External TestFlight and App Store — BLOCKED (NOT READY).**

This document lists blockers only. It does **not** grant legal approval or certification.

---

## Blocker summary

| Category | Open blockers | Blocks external TF | Blocks App Store |
|----------|--------------:|:------------------:|:----------------:|
| Legal / marketing sign-off | 2 | Yes | Yes |
| Physical Watch (incl. CMAltimeter) | 31 | Yes | Yes |
| Physical iPhone / a11y | 16 | Partial | Yes |
| Paired-device sync | 8 | Yes | Yes |
| Underwater entitlement depth | 1 | Yes | Yes |
| External algorithm validation | 4 | Yes | Yes |
| App Store marketing assets | 1 | No | Yes |
| **Total tracked** | **63** | — | — |

---

## P0 — Must not ship with false claims

| Blocker | Software status @ 1f62235 | Field status |
|---------|----------------------------|--------------|
| Certified dive computer claim | **CLEAR** | N/A |
| Certified decompression planner claim | **CLEAR** | N/A |
| Certified CCR / life-support claim | **CLEAR** | N/A |
| Guaranteed navigation / medical recovery | **CLEAR** | N/A |
| False physical QA passed claim | **CLEAR** — all matrices PENDING | N/A |
| False external Bühlmann validation passed | **CLEAR** | N/A |

**P0 blockers: NONE** in production copy or audit posture.

---

## P1 — External release blockers (NOT PASSED)

### Legal & marketing

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-L-01 | External legal counsel review | `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` | Legal row signed |
| MASB-L-02 | Product/marketing sign-off | Same checklist | Marketing row signed |
| MASB-L-03 | App Store screenshots + copy pack | `QA_EVIDENCE/APP_STORE_MARKETING/` | Checklist PASS + assets |

### Physical / entitlement / CMAltimeter

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| MASB-P-01 | Watch Ultra physical QA matrix | `QA_EVIDENCE/WATCH_ULTRA/` | Signed artifacts |
| MASB-P-02 | Underwater entitlement depth session | `HARDWARE_QA_MATRIX` QA-002 | Signed Ultra build log |
| MASB-P-03 | CMAltimeter physical CoreMotion samples | `QA_EVIDENCE/WATCH_CMALTIMETER_PHYSICAL/` | EVIDENCE_TEMPLATE complete |
| MASB-P-04 | VoiceOver / Dynamic Type journeys | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | Procedure PASS |
| MASB-P-05 | Planner visual QA Dynamic Type XL | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | Screenshots |
| MASB-P-06 | PDF render/share manual QA | `QA_EVIDENCE/PDF_RENDER/` | Checklist PASS |

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
| MASB-E-04 | Subsurface CSV external round-trip | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | External tool PASS |

---

## Internal TestFlight — allowed with conditions

Software gates that **PASS** on `1f62235`:

- **iOS Algorithm Tests:** 1519 tests, 0 failures (2026-06-22 audit run)
- **Watch Algorithm Tests:** in progress / see master audit §E
- **Build iOS + Watch:** PASS (simulator builds verified 2026-06-22)
- Legal onboarding + non-certified disclaimers EN/IT
- Privacy manifests; `NSPrivacyTracking=false`
- TestFlight review notes aligned with limitations
- Demo logbook toggle for reviewers without Watch hardware
- WCMA software remediation (request generation, timestamp freshness)

**Conditions:**

1. Review notes and in-app copy must **not** imply certification.
2. Depth/automatic dive features must disclose entitlement/simulation status per `TESTFLIGHT_REVIEW_NOTES.md`.
3. Do **not** expand external cohort until P1 blockers close or documented accepted risk in `RELEASE_CHECKLIST.md`.
4. Do **not** claim CMAltimeter or depth entitlement physically validated.

---

## App Store — blocked

Submission remains **BLOCKED** until:

1. All P1 blockers above close or receive documented product/legal accepted risk.
2. `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` sign-off complete.
3. Prohibited-claims checklist verified against final store metadata.
4. Privacy nutrition labels match `PRIVACY_MANIFEST_DECLARATION_CURRENT.md`.
5. Physical accessibility journeys complete.

---

## Non-blockers (software verified @ 1f62235)

- Reference-only planner/FC/CCR copy in repo
- EN13319 / ISO 6425 documented out of scope
- CSV metadata round-trip software tests
- Command 9 security/privacy software readiness
- Command 12 traceability software readiness (68 requirements; software PASS on safety-critical automated paths)
- Incident/rollback/support documentation present

---

## Closure rule

Remove a blocker only when the linked evidence folder or checklist row contains completed tester/reviewer fields and required artifacts. **Do not** close from simulator tests or audit documents alone.

---

## Related

- [`MASTER_RELEASE_GATE_MATRIX_CURRENT.csv`](MASTER_RELEASE_GATE_MATRIX_CURRENT.csv)
- [`MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](MASTER_CLAIMS_EVIDENCE_MATRIX_CURRENT.csv)
- [`MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md`](MASTER_EXTERNAL_VALIDATION_GAPS_CURRENT.md)
- [`TEST_QA_EVIDENCE_AUDIT_CURRENT.md`](TEST_QA_EVIDENCE_AUDIT_CURRENT.md)
- [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md)
