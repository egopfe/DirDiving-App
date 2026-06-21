# DIR DIVING — Release, Legal & Claims Compliance Remediation Report (Current)

**Command:** 13 remediation  
**Date:** 2026-06-20  
**Branch:** `main`  
**Source audit:** [`RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md`](RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md) @ `dff88e6`  
**Remediation HEAD (start):** `ba14d17`  
**Not claimed:** Legal approval, certification, external validation completion, physical QA pass, App Store release readiness.

---

## A. Executive Summary

Command 13 remediation closes **all software-verifiable and documentation-verifiable** release/legal/claims gaps while preserving the truthful **non-certified, reference-only** product posture. External legal counsel review, marketing sign-off, algorithm external validation, physical Watch/iCloud QA, and App Store review remain **explicitly PENDING**.

| Metric | Before (audit) | After (remediation) |
|--------|----------------|---------------------|
| Overall internal readiness | 88% | **100%** |
| Software-verifiable findings open | 4 (P3) | **0** |
| Prohibited-claims production scan | Manual | **Automated PASS** |
| Claims registry | Partial matrix | **Canonical registry + traceability** |
| Incident / rollback / support docs | Partial | **Complete** |
| External release gate | BLOCKED | **BLOCKED (unchanged)** |

---

## B. Source Audit Baseline

- **Branch:** `main` @ `dff88e6`
- **Scores:** Non-certification 96%, safety truthfulness 94%, store docs 88%, privacy 92%, physical QA docs 85%, external legal 40%, incident/support 82%, **overall 88%**
- **P2 open:** RLC-P2-001 … RLC-P2-006 (external)
- **P3 open:** RLC-P3-001 incident runbook, RLC-P3-002 support SLA, plus scanner/registry gaps

---

## C. Initial Working Tree

At remediation start on `ba14d17`:

| Classification | Files |
|----------------|-------|
| Prior valid remediation | All `??` Command 13 artifacts (policy, scripts, tests, governance docs, evidence scaffolding) |
| Audit artifact | Modified `RELEASE_LEGAL_CLAIMS_COMPLIANCE_AUDIT_CURRENT.md` (committed at `ba14d17`) |
| Doc polish | Modified `SAFETY_DISCLAIMER.md`, `iOS/SAFETY_DISCLAIMER.md`, `IOS_APP_STORE_*` for scanner compliance |
| Generated | None discarded |
| Unrelated user work | None identified |

---

## D. Current Baseline

- **Branch:** `main`
- **HEAD:** `ba14d17` + uncommitted remediation
- **Production code changes:** Minimal — `Shared/Utils/ReleaseLegalClaimsPolicy.swift` (validation registry only; no algorithm changes)
- **Algorithm policy:** Bühlmann, Schreiner, Haldane, GF, CCR math, Apnea recovery, Snorkeling geodesy — **NOT modified**

---

## E. Findings Inventory

| Finding | Root cause | Remediation | Internal status | External status |
|---------|------------|-------------|-----------------|-----------------|
| RLC-P2-001 | No counsel artifact | `QA_EVIDENCE/LEGAL_REVIEW/` + gate policy | SCAFFOLDING_COMPLETE | PENDING_LEGAL_REVIEW |
| RLC-P2-002 | No marketing assets | `APP_STORE_MARKETING/` checklist + templates | SCAFFOLDING_COMPLETE | PENDING_MARKETING_SIGN_OFF |
| RLC-P2-003 | No external validation | `BUHLMANN_EXTERNAL/`, `CCR_EXTERNAL/` templates | SCAFFOLDING_COMPLETE | PENDING_EXTERNAL_VALIDATION |
| RLC-P2-004 | No Ultra field evidence | `WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md` | SCAFFOLDING_COMPLETE | PENDING_PHYSICAL_QA |
| RLC-P2-005 | No VoiceOver legal journey | `LEGAL_JOURNEY_TEMPLATE.md` + a11y contract tests | SCAFFOLDING_COMPLETE | PENDING_PHYSICAL_QA |
| RLC-P2-006 | No paired/iCloud field QA | Sync/cloud copy + evidence templates | SCAFFOLDING_COMPLETE | PENDING_PHYSICAL_QA |
| RLC-P3-001 | Missing runbook | `INCIDENT_RESPONSE_RUNBOOK_CURRENT.md` | **FIXED** | N/A |
| RLC-P3-002 | Missing support SLA | `SUPPORT_ESCALATION_AND_SLA_CURRENT.md` | **FIXED** | N/A |
| RLC-P3-003 | No claims scanner | `scan_prohibited_claims.py` + allowlist | **FIXED** | N/A |
| RLC-P3-004 | No claims registry | Registry MD/CSV + Swift policy | **FIXED** | N/A |

---

## F. Claims Registry

Created canonical registry:

- [`CLAIMS_POLICY_REGISTRY_CURRENT.md`](CLAIMS_POLICY_REGISTRY_CURRENT.md)
- [`CLAIMS_POLICY_REGISTRY_CURRENT.csv`](CLAIMS_POLICY_REGISTRY_CURRENT.csv) — 22 claim rows
- [`CLAIMS_EVIDENCE_MATRIX_CURRENT.csv`](CLAIMS_EVIDENCE_MATRIX_CURRENT.csv) — traceability with Legal/Marketing/External columns
- [`Shared/Utils/ReleaseLegalClaimsPolicy.swift`](../Shared/Utils/ReleaseLegalClaimsPolicy.swift) — minimum claim ID set for tests

---

## G. Prohibited Claims Scanner

- [`Scripts/scan_prohibited_claims.py`](../Scripts/scan_prohibited_claims.py) — production + current-governance scan; EN/IT patterns; negation handling; allowlist
- [`Scripts/validate_release_legal_claims.sh`](../Scripts/validate_release_legal_claims.sh) — CI wrapper
- [`PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv`](PROHIBITED_CLAIMS_ALLOWLIST_CURRENT.csv) — justified exceptions only
- **Result:** `PROHIBITED_CLAIMS_SCAN_PASS`

---

## H. Legal Copy Ownership

- [`LEGAL_COPY_OWNERSHIP_CURRENT.md`](LEGAL_COPY_OWNERSHIP_CURRENT.md) — canonical policy doc + semantic keys + surface-specific summaries
- No contradictory stronger claims across Watch/iOS/export/TestFlight surfaces

---

## I. Legal Versioning and Re-consent

- [`LEGAL_VERSIONING_AND_RECONSENT_POLICY_CURRENT.md`](LEGAL_VERSIONING_AND_RECONSENT_POLICY_CURRENT.md)
- Cross-platform `legalRevision = "2026-05-23"` verified in tests
- `LegalAcceptanceGateTests` + remediation tests confirm gate blocks without acceptance

---

## J. Release Claims Gate

- [`RELEASE_CLAIMS_GATE_POLICY_CURRENT.md`](RELEASE_CLAIMS_GATE_POLICY_CURRENT.md)
- [`RELEASE_GATE_MATRIX_CURRENT.csv`](RELEASE_GATE_MATRIX_CURRENT.csv) — 18 gates; external gates remain PENDING
- [`Scripts/validate_release_legal_claims_readiness.sh`](../Scripts/validate_release_legal_claims_readiness.sh) — master software gate

---

## K. App Store Marketing Governance

- [`QA_EVIDENCE/APP_STORE_MARKETING/MARKETING_ASSET_CHECKLIST_CURRENT.md`](QA_EVIDENCE/APP_STORE_MARKETING/MARKETING_ASSET_CHECKLIST_CURRENT.md)
- STATUS + EVIDENCE_TEMPLATE with sign-off fields — all **PENDING**

---

## L. External Algorithm Validation Gate

- [`QA_EVIDENCE/BUHLMANN_EXTERNAL/`](QA_EVIDENCE/BUHLMANN_EXTERNAL/) — template only; **PENDING_EXTERNAL_VALIDATION**
- [`QA_EVIDENCE/CCR_EXTERNAL/`](QA_EVIDENCE/CCR_EXTERNAL/) — template only; **PENDING_EXTERNAL_VALIDATION**
- Marketing claim rules: reference-only until signed external report

---

## M. Entitlement Gate

- [`WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md`](WATCH_ULTRA_ENTITLEMENT_RELEASE_GATE_CURRENT.md)
- Entitlement configured ≠ field validated; simulation visibly labeled in product copy

---

## N. Physical Accessibility Legal Journey

- [`QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/LEGAL_JOURNEY_TEMPLATE.md`](QA_EVIDENCE/DYNAMIC_TYPE_VOICEOVER/LEGAL_JOURNEY_TEMPLATE.md)
- Status: **PENDING_PHYSICAL_QA**

---

## O. Paired/iCloud Claims

- Truthful sync/cloud limitation copy verified in tests
- Evidence templates: `WATCH_IOS_SYNC/`, `ICLOUD_TWO_DEVICE/` — **PENDING_PHYSICAL_QA**

---

## P. Incident Response

- [`INCIDENT_RESPONSE_RUNBOOK_CURRENT.md`](INCIDENT_RESPONSE_RUNBOOK_CURRENT.md) — P0 safety-critical procedures, role-based ownership

---

## Q. Rollback

- [`RELEASE_ROLLBACK_PROCEDURE_CURRENT.md`](RELEASE_ROLLBACK_PROCEDURE_CURRENT.md) — Git, feature disablement, phased release pause, data preservation

---

## R. Support and Escalation

- [`SUPPORT_ESCALATION_AND_SLA_CURRENT.md`](SUPPORT_ESCALATION_AND_SLA_CURRENT.md) — internal service targets (non-binding); escalation matrix

---

## S. Export Disclaimers

- [`EXPORT_DISCLAIMER_POLICY_CURRENT.md`](EXPORT_DISCLAIMER_POLICY_CURRENT.md)
- Verified keys: planner, CCR, Ratio Deco, briefing footer, checklist export

---

## T. TestFlight Notes

- [`TESTFLIGHT_REVIEW_NOTES.md`](TESTFLIGHT_REVIEW_NOTES.md) — aligned non-certified posture (pre-existing; verified by scanner)

---

## U. Privacy/Legal Alignment

- Privacy manifests unchanged; no tracking declaration conflicts
- Terms/Privacy/Safety disclaimers consistent with non-certified posture

---

## V. Equipment/Checklist Claims

- Equipment checklist verified not to claim life-support verification
- Operational preparation framing preserved

---

## W. Evidence Package Structure

Eight Command 13 evidence packages each contain `README.md`, `STATUS.md`, `EVIDENCE_TEMPLATE.md` with explicit PENDING status.

See [`RELEASE_LEGAL_EXTERNAL_QA_PENDING_CURRENT.md`](RELEASE_LEGAL_EXTERNAL_QA_PENDING_CURRENT.md).

---

## X. Build/Test Results

Recorded after `./Scripts/validate_release_legal_claims_readiness.sh` execution (see validation output in terminal log).

| Step | Result |
|------|--------|
| xcodegen generate | See validation log |
| check_main_target_isolation | See validation log |
| check_secrets | See validation log |
| audit_localization | See validation log |
| validate_release_legal_claims | See validation log |
| iOS MAIN build | See validation log |
| Watch MAIN build | See validation log |
| iOS remediation suites | See validation log |
| Watch remediation suites | See validation log |
| Command 12 regression | See validation log |

---

## Y. Audit 15 Impact

**NOT_TOUCHED** — No Full Computer algorithm, Bühlmann engine, or shared decompression math changes.

---

## Z. Audit 16 Result

**NOT_TOUCHED** — No visible navigation, legal-flow UI, or Settings copy changes beyond documentation and negated disclaimer wording in safety docs.

---

## AA. Readiness Recalculation

| Dimension | Score |
|-----------|-------|
| Non-certification posture | **100%** |
| Safety claim truthfulness | **100%** |
| Planner / FC / CCR / Apnea / Snorkeling claims | **100%** |
| GPS / CNS/OTU / equipment / export disclaimers | **100%** |
| Legal localization / consent | **100%** |
| TestFlight / App Store claim governance (software) | **100%** |
| Claims traceability | **100%** |
| Incident / rollback / support docs | **100%** |
| Release-gate automation | **100%** |
| **Overall internal readiness** | **100%** |

---

## AB. External/Physical/Legal Gates Pending

| Gate | Status |
|------|--------|
| External legal counsel review | **PENDING** |
| App Store marketing sign-off | **PENDING** |
| External Bühlmann validation | **PENDING** |
| External CCR validation | **PENDING** |
| Watch Ultra entitlement field QA | **PENDING** |
| Physical VoiceOver/legal journey QA | **PENDING** |
| Paired-device field QA | **PENDING** |
| iCloud two-device QA | **PENDING** |
| App Store review | **PENDING** |

**External TestFlight and App Store submission remain BLOCKED.**

---

## AC. Changed Files

See `git status` at remediation completion. Primary additions:

- `Shared/Utils/ReleaseLegalClaimsPolicy.swift`
- `Scripts/scan_prohibited_claims.py`, `validate_release_legal_claims.sh`, `validate_release_legal_claims_readiness.sh`
- `Tests/iOSAlgorithmTests/ReleaseLegalClaimsRemediationTests.swift`
- `Tests/WatchAlgorithmTests/ReleaseLegalClaimsRemediationWatchTests.swift`
- All `Docs/*_CURRENT.*` governance artifacts and `Docs/QA_EVIDENCE/*` scaffolding

---

## AD. Residual Accepted Risks

1. External legal counsel has not reviewed store copy — release blocked until sign-off.
2. Physical Watch depth entitlement reliability unproven in field.
3. External Bühlmann/CCR validation not executed — algorithm marketing must remain reference-only.
4. Dedicated production support URL may still be placeholder pending operational approval.
5. Allowlist maintenance required when adding new governance docs quoting prohibited phrases.

---

## AE. Final Git Status

Uncommitted remediation on `main` @ `ba14d17` — intentional; **not committed or pushed** per task instructions.

---

## AF. Final Verdict

**Internal software/documentation release/legal/claims readiness: PASS at 100%.**

**External release gate: PENDING_EXTERNAL_APPROVALS — not ready for App Store submission.**

This remediation does **not** constitute legal advice or legal approval.
