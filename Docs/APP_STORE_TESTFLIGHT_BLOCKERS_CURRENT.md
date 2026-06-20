# DIR DIVING — App Store & TestFlight Blockers (Current)

**Command:** 13 — Release, Legal & Claims Compliance Audit  
**Date:** 2026-06-20  
**Branch:** `main` @ `dff88e6` (+ uncommitted remediation)  
**Claims audit:** [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md)

**Verdict:** **Internal TestFlight (software cohort) — conditionally allowed.** **External TestFlight and App Store — BLOCKED.**

This document lists blockers only. It does **not** grant legal approval.

---

## Blocker summary

| Category | Open blockers | Blocks external TF | Blocks App Store |
|----------|--------------:|:------------------:|:----------------:|
| Legal / marketing sign-off | 2 | Yes | Yes |
| Physical Watch evidence | 12+ | Yes | Yes |
| Physical iPhone / a11y | 7+ | Partial | Yes |
| Paired-device sync | 8+ | Yes | Yes |
| Underwater entitlement depth | 1 | Yes | Yes |
| External algorithm validation | 3 | Yes | Yes |
| App Store marketing assets | 1 | No | Yes |
| **Total tracked** | **34+** | — | — |

---

## P0 — Must not ship with false claims (software status)

| Blocker | Software status | Field status |
|---------|-----------------|--------------|
| Certified dive computer claim in copy | **CLEAR** — no unsupported claim found | N/A |
| Certified decompression planner claim | **CLEAR** | N/A |
| Certified CCR / life-support claim | **CLEAR** | N/A |
| Guaranteed navigation / medical recovery | **CLEAR** | N/A |

No P0 copy blockers remain in MAIN software audit.

---

## P1 — External release blockers (NOT PASSED)

### Legal & marketing

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| ASB-L-01 | External legal counsel review | `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` | Legal row signed |
| ASB-L-02 | Product/marketing sign-off | Same checklist | Marketing row signed |
| ASB-L-03 | App Store screenshots + copy pack | `QA_EVIDENCE/APP_STORE_MARKETING/` | README PASS + assets |

### Physical / entitlement

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| ASB-P-01 | Watch Ultra physical QA matrix | `QA_EVIDENCE/WATCH_ULTRA/` | Signed artifacts |
| ASB-P-02 | Underwater entitlement depth session | `HARDWARE_QA_MATRIX` QA-002 | Signed Ultra build log |
| ASB-P-03 | VoiceOver / Dynamic Type journeys | `QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/` | Procedure PASS |
| ASB-P-04 | Planner visual QA at Dynamic Type XL | `QA_EVIDENCE/IOS_ACCESSIBILITY/` | Screenshots |
| ASB-P-05 | PDF render/share manual QA | `QA_EVIDENCE/PDF_RENDER/` | Checklist PASS |

### Paired / cloud

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| ASB-S-01 | Watch↔iPhone sync under load | `QA_EVIDENCE/WATCH_IOS_SYNC/` | Matrix PASS |
| ASB-S-02 | iCloud two-device tombstones | `QA_EVIDENCE/ICLOUD_TWO_DEVICE/` | Matrix PASS |
| ASB-S-03 | Low-battery paired sync | Performance external QA | Logs in evidence folder |

### External reference

| ID | Blocker | Folder / doc | Exit criteria |
|----|---------|--------------|---------------|
| ASB-E-01 | External Bühlmann golden validation | `QA_EVIDENCE/BUHLMANN_EXTERNAL/` | Signed report |
| ASB-E-02 | External CCR rebreather validation | `QA_EVIDENCE/CCR_EXTERNAL/` | Signed report |
| ASB-E-03 | Subsurface CSV external round-trip | `QA_EVIDENCE/SUBSURFACE_EXTERNAL/` | External tool PASS |

---

## Internal TestFlight — allowed with conditions

Software gates that **PASS** and support truthful internal testing:

- Command 7–12 software validation scripts (incl. `validate_test_qa_evidence_readiness.sh` on working tree)
- Legal onboarding + non-certified disclaimers in EN/IT
- Privacy manifests; no tracking declared
- TestFlight review notes aligned with product limitations
- Demo logbook toggle for reviewers without Watch hardware

**Conditions:**

1. Review notes and in-app copy must **not** be edited to imply certification.
2. Depth/automatic dive features must disclose entitlement/simulation status per `TESTFLIGHT_REVIEW_NOTES.md`.
3. Do **not** expand external cohort until P1 blockers above close or are explicitly accepted in `RELEASE_CHECKLIST.md`.

---

## App Store — blocked

Submission remains **BLOCKED** until:

1. All P1 blockers in this document close or receive documented product/legal accepted risk.
2. `IOS_APP_STORE_ALGORITHM_MARKETING_REVIEW_CHECKLIST.md` sign-off complete.
3. Prohibited-claims checklist verified against final store metadata (screenshots, subtitle, description, keywords).
4. Privacy nutrition labels match `PRIVACY_MANIFEST_DECLARATION_CURRENT.md`.

---

## Non-blockers (software verified)

These do **not** block internal TestFlight on software grounds:

- Reference-only planner/FC/CCR copy in repo
- EN13319 / ISO 6425 documented as out of scope
- CSV metadata round-trip software tests
- Command 9 security/privacy software readiness 100%
- Command 12 traceability software readiness 100%

---

## Closure rule

Remove a blocker only when the linked evidence folder or checklist row contains completed tester/reviewer fields and required artifacts. **Do not** close from simulator tests or audit documents alone.

---

## Related

- [`RELEASE_GATE_MATRIX_CURRENT.csv`](RELEASE_GATE_MATRIX_CURRENT.csv)
- [`CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](CLAIMS_EVIDENCE_MATRIX_CURRENT.csv)
- [`TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md`](TEST_QA_EXTERNAL_QA_PENDING_CURRENT.md)
- [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)
